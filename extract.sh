#!/usr/bin/env bash
# extract.sh — copy rules back out of karabiner.json into rules/, ready to commit.
#
# The reverse of apply.sh. Tuning a rule in the Karabiner GUI only changes
# karabiner.json, so without this step the change lives on one Mac and the next
# `apply.sh` on that Mac would overwrite it with the older version from git.
#
# Each file under rules/ keeps its own rule list: a rule is written back to the
# file that already names it, matched by "description". Rules in the profile
# that no file names are reported as untracked — move one into a rule file by
# hand (or create a new file for it) to start tracking it.
#
# Usage: ./extract.sh [-p PROFILE] [-n] [RULE_FILE...]
#   -p PROFILE  source profile name (default: the profile Karabiner has selected)
#   -n          dry run — print what would change, write nothing
#   RULE_FILE   rule files to refresh (default: rules/*.json)

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KARABINER_JSON="${KARABINER_JSON:-$HOME/.config/karabiner/karabiner.json}"

PROFILE=""
DRY_RUN=0

while getopts ":p:nh" opt; do
  case "$opt" in
    p) PROFILE="$OPTARG" ;;
    n) DRY_RUN=1 ;;
    h) sed -n '2,19p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    :) echo "extract.sh: -$OPTARG needs a value" >&2; exit 2 ;;
    \?) echo "extract.sh: unknown option -$OPTARG" >&2; exit 2 ;;
  esac
done
shift $((OPTIND - 1))

if [[ $# -gt 0 ]]; then
  RULE_FILES=("$@")
else
  RULE_FILES=("$REPO"/rules/*.json)
fi

[[ -f "$KARABINER_JSON" ]] || { echo "extract.sh: no $KARABINER_JSON" >&2; exit 1; }

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
        sys.exit(f"extract.sh: no profile named {profile_name!r} (have: {names})")
    profile = matches[0]
else:
    selected = [p for p in profiles if p.get("selected")]
    if not selected:
        sys.exit("extract.sh: no profile is selected; pass -p PROFILE")
    profile = selected[0]

live = profile.get("complex_modifications", {}).get("rules", [])
by_description = {}
for rule in live:
    description = rule.get("description")
    if description:
        by_description.setdefault(description, rule)

print(f"profile: {profile['name']}")
claimed = set()
for rule_file in rule_files:
    with open(rule_file, encoding="utf-8") as fh:
        payload = json.load(fh)

    rebuilt, missing, changed = [], [], []
    for rule in payload.get("rules", []):
        description = rule.get("description")
        claimed.add(description)
        current = by_description.get(description)
        if current is None:
            # Still in git but not enabled here: keep the stored copy so a Mac
            # that has the rule turned off cannot delete it for everyone.
            missing.append(description)
            rebuilt.append(rule)
            continue
        if current != rule:
            changed.append(description)
        rebuilt.append(current)

    name = rule_file.split("/")[-1]
    if changed:
        print(f"  {name}: {len(changed)} changed")
        for description in changed:
            print(f"    - {description}")
    else:
        print(f"  {name}: up to date")
    for description in missing:
        print(f"    ! not enabled in this profile, kept as-is: {description}")

    if changed and not dry_run:
        payload["rules"] = rebuilt
        with open(rule_file, "w", encoding="utf-8") as fh:
            json.dump(payload, fh, ensure_ascii=False, indent=2)
            fh.write("\n")

untracked = [d for d in by_description if d not in claimed]
if untracked:
    print(f"\n  untracked in this profile: {len(untracked)}")
    for description in untracked:
        print(f"    ? {description}")
    print("  move one into a rule file (or add a new file) to start tracking it")

if dry_run:
    print("\ndry run — rule files not written")
else:
    print("\nreview with `git diff`, then commit and push")
PY
