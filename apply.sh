#!/usr/bin/env bash
# apply.sh — merge rule files from rules/ into ~/.config/karabiner/karabiner.json.
#
# karabiner.json is the only file Karabiner-Elements reads; the files under
# rules/ are inert until their contents are copied into it. This script does
# that copy without going through the GUI, so several Macs can share one set of
# rules through git while each keeps its own devices[] and machine_specific.
#
# Rules are matched by "description". A rule already in the profile is replaced
# where it sits, so evaluation order (first match wins) does not drift. A rule
# not in the profile yet is appended. Rules the profile has that no rule file
# claims are left alone, which is what keeps machine-local experiments alive.
#
# Usage: ./apply.sh [-p PROFILE] [-n] [RULE_FILE...]
#   -p PROFILE  target profile name (default: the profile Karabiner has selected)
#   -n          dry run — print the plan, write nothing
#   RULE_FILE   rule files to apply (default: rules/*.json)

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KARABINER_JSON="${KARABINER_JSON:-$HOME/.config/karabiner/karabiner.json}"
BACKUP_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/karabiner-rules-sync/backups"
KEEP_BACKUPS=10

PROFILE=""
DRY_RUN=0

while getopts ":p:nh" opt; do
  case "$opt" in
    p) PROFILE="$OPTARG" ;;
    n) DRY_RUN=1 ;;
    h) sed -n '2,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    :) echo "apply.sh: -$OPTARG needs a value" >&2; exit 2 ;;
    \?) echo "apply.sh: unknown option -$OPTARG" >&2; exit 2 ;;
  esac
done
shift $((OPTIND - 1))

if [[ $# -gt 0 ]]; then
  RULE_FILES=("$@")
else
  RULE_FILES=("$REPO"/rules/*.json)
fi

[[ -f "$KARABINER_JSON" ]] || { echo "apply.sh: no $KARABINER_JSON" >&2; exit 1; }

# The Settings window holds the configuration in memory and writes it back on
# any change, which would silently undo this script. Refuse to run behind it.
if pgrep -x "Karabiner-Elements" >/dev/null 2>&1; then
  echo "apply.sh: quit the Karabiner-Elements Settings window first — it would overwrite these changes." >&2
  exit 1
fi

if [[ $DRY_RUN -eq 0 ]]; then
  mkdir -p "$BACKUP_DIR"
  cp "$KARABINER_JSON" "$BACKUP_DIR/karabiner-$(date +%Y%m%d-%H%M%S).json"
  # Keep the backup directory from growing without bound.
  ls -1t "$BACKUP_DIR"/karabiner-*.json 2>/dev/null | tail -n +$((KEEP_BACKUPS + 1)) | while read -r old; do
    rm -f "$old"
  done
fi

python3 -I - "$KARABINER_JSON" "$PROFILE" "$DRY_RUN" "${RULE_FILES[@]}" <<'PY'
import json
import sys

path, profile_name, dry_run = sys.argv[1], sys.argv[2], sys.argv[3] == "1"
rule_files = sys.argv[4:]

with open(path, encoding="utf-8") as fh:
    config = json.load(fh)

profiles = config.get("profiles", [])
if profile_name:
    matches = [p for p in profiles if p.get("name") == profile_name]
    if not matches:
        names = ", ".join(repr(p.get("name")) for p in profiles)
        sys.exit(f"apply.sh: no profile named {profile_name!r} (have: {names})")
    profile = matches[0]
else:
    selected = [p for p in profiles if p.get("selected")]
    if not selected:
        sys.exit("apply.sh: no profile is selected; pass -p PROFILE")
    profile = selected[0]

# Both keys are optional in karabiner.json and absent on a fresh profile.
complex_mods = profile.setdefault("complex_modifications", {})
existing = complex_mods.setdefault("rules", [])

incoming = []
seen = {}
for rule_file in rule_files:
    with open(rule_file, encoding="utf-8") as fh:
        payload = json.load(fh)
    for rule in payload.get("rules", []):
        description = rule.get("description")
        if not description:
            sys.exit(f"apply.sh: {rule_file} has a rule with no description")
        if description in seen:
            sys.exit(
                f"apply.sh: {description!r} appears in both {seen[description]} "
                f"and {rule_file}; descriptions are the merge key and must be unique"
            )
        seen[description] = rule_file
        incoming.append(rule)

by_description = {rule["description"]: rule for rule in incoming}
replaced, unchanged, consumed = [], [], set()
merged = []
for rule in existing:
    description = rule.get("description")
    if description in by_description:
        if description in consumed:
            continue  # drop a duplicate the GUI left behind
        consumed.add(description)
        new_rule = by_description[description]
        (unchanged if new_rule == rule else replaced).append(description)
        merged.append(new_rule)
    else:
        merged.append(rule)

added = [r["description"] for r in incoming if r["description"] not in consumed]
merged.extend(r for r in incoming if r["description"] not in consumed)

untracked = [
    r.get("description", "<no description>")
    for r in existing
    if r.get("description") not in by_description
]

print(f"profile: {profile['name']}")
for label, items in (
    ("added", added),
    ("updated", replaced),
    ("already current", unchanged),
    ("left alone (no rule file claims it)", untracked),
):
    print(f"  {label}: {len(items)}")
    for description in items:
        print(f"    - {description}")

if dry_run:
    print("\ndry run — karabiner.json not written")
elif not added and not replaced and len(merged) == len(existing):
    print("\nnothing to do")
else:
    complex_mods["rules"] = merged
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(config, fh, ensure_ascii=False, indent=4)
        fh.write("\n")
    print("\nwrote karabiner.json — Karabiner reloads it on its own")
PY
