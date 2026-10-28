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

## License

[MIT](LICENSE)
