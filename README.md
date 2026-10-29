# Karabiner Complex Rules

Complex modifications for [Karabiner-Elements](https://karabiner-elements.pqrs.org/)
that I use on macOS.

## How to use

Click an **Import** link below. Karabiner-Elements opens, shows the rules in the
file, and you enable the ones you want. The link needs Karabiner-Elements to be
installed; nothing happens otherwise.

To install by hand instead, copy the `.json` file into
`~/.config/karabiner/assets/complex_modifications/`, then enable its rules under
_Settings → Complex Modifications → Add rule_.

Either way, enabling a rule **copies** it into `~/.config/karabiner/karabiner.json`,
which is the file Karabiner actually reads. Editing the file under
`assets/complex_modifications/` afterwards changes nothing until you remove the
rule and add it again.

## Index

### [SpaceFN - Filco Minila](rules/SpaceFN_FilcoMinila.json)

[Import](karabiner://karabiner/assets/complex_modifications/import?url=https://raw.githubusercontent.com/dofy/karabiner_complex_rules/main/rules/SpaceFN_FilcoMinila.json)

Use the `spacebar` as an `Fn` key on a Filco Minila keyboard. Tapping it still
types a space; holding it turns the right hand into a navigation cluster.

> - `spacebar` + `e` = `up arrow`
> - `spacebar` + `d` = `down arrow`
> - `spacebar` + `s` = `left arrow`
> - `spacebar` + `f` = `right arrow`
> - `spacebar` + `k` = `home`
> - `spacebar` + `,` = `end`
> - `spacebar` + `l` = `page up`
> - `spacebar` + `.` = `page down`
> - `spacebar` + `j` = `insert`
> - `spacebar` + `m` = `delete`
> - `spacebar` + `;` = `backspace`

### [App-specific Arrow Navigation](rules/AppArrowNavigation.json)

[Import](karabiner://karabiner/assets/complex_modifications/import?url=https://raw.githubusercontent.com/dofy/karabiner_complex_rules/main/rules/AppArrowNavigation.json)

Give `ctrl` + arrows a different meaning in each application, so the same thumb
movement means "go back one, go forward one" wherever you are. Each rule is
conditioned on the frontmost application, and every other application keeps the
stock behaviour.

> **iTerm2** — move between tmux windows (assumes `ctrl-a` as the tmux prefix):
>
> - `ctrl` + `left arrow` = `ctrl-a` `h`
> - `ctrl` + `right arrow` = `ctrl-a` `l`
>
> **Google Chrome** — walk the history, and switch tabs with the volume keys,
> since the arrows are already spoken for:
>
> - `ctrl` + `left arrow` = `cmd` + `[` (back)
> - `ctrl` + `right arrow` = `cmd` + `]` (forward)
> - `volume up` = `cmd` + `shift` + `[` (previous tab)
> - `volume down` = `cmd` + `shift` + `]` (next tab)

The Chrome rules match `com.google.Chrome` only. Beta, Canary, and Chromium ship
their own bundle identifiers, so add them to `bundle_identifiers` if you run one
of those. The volume keys keep adjusting the volume in every other application.

## Keeping several Macs in sync

Karabiner-Elements has no sync of its own, and `karabiner.json` is a poor thing
to copy between machines: it also holds `devices[]` (the hardware attached to
*that* Mac, with its own per-device `simple_modifications`) and
`machine_specific`, which is keyed by a per-installation UUID. Copy the whole
file and each Mac overwrites the other's hardware settings, with no merge and no
warning about which edit just disappeared.

So only the rules are shared, through this repository, and each Mac keeps its own
copy of everything else:

```
shared, in git   complex_modifications rules
machine-local    devices[] · machine_specific · which profile is selected
```

Two scripts move rules across that line. Both default to the profile Karabiner
currently has selected, take `-p` to name another one, and take `-n` to show
what they would do without writing anything.

```bash
./apply.sh      # rules/*.json  ->  karabiner.json
./extract.sh    # karabiner.json  ->  rules/*.json
```

Rules are matched by `description`, which is therefore the one field you cannot
edit casually — changing it makes a new rule rather than updating the old one,
and `apply.sh` refuses to run if two files claim the same description.

`apply.sh` replaces a rule where it already sits, so evaluation order (first
match wins) does not drift, and appends rules the profile has not seen. Rules no
file claims are left alone, which is what lets a machine keep a local experiment
that is not worth sharing. It backs `karabiner.json` up under
`~/.local/state/karabiner-rules-sync/backups/` first, keeping the last ten.

`extract.sh` writes each rule back to the file that already names it, and lists
anything enabled in the profile that no file tracks. A rule that is in git but
switched off on this Mac is kept as it was, so one machine cannot delete a rule
for the others by not using it.

The round trip, from either Mac:

```bash
git pull && ./apply.sh          # take what the other Mac changed
./extract.sh && git diff        # hand GUI edits back to git
git commit -am "..." && git push
```

**Quit the Karabiner-Elements Settings window before running `apply.sh`.** While
it is open it holds the configuration in memory and writes it back on any
change, which would silently undo the script; `apply.sh` checks for it and
refuses to run. With the window closed, `karabiner_console_user_server` notices
the file change and reloads on its own — no restart, no GUI step.

## License

[MIT](LICENSE)
