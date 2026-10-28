# Karabiner Complex Rules

Some Karabiner complex rules I use.

## How to use

Copy the rules you want to use to
`~/.config/karabiner/assets/complex_modifications/` and enable them in
Karabiner-Elements.

## Index

- [SpaceFN - Filco Minila](rules/SpaceFN_FilcoMinila.json)
  - Use the `spacebar` as `Fn` key on a Filco Minila keyboard.
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
- [App-specific Arrow Navigation](rules/AppArrowNavigation.json)
  - Remap `ctrl` + arrows, and the volume keys, per frontmost application.
    > iTerm2:
    > - `ctrl` + `left arrow` = `ctrl-a h` (tmux previous window)
    > - `ctrl` + `right arrow` = `ctrl-a l` (tmux next window)
    >
    > Google Chrome:
    > - `ctrl` + `left arrow` = `cmd` + `[` (history back)
    > - `ctrl` + `right arrow` = `cmd` + `]` (history forward)
    > - `volume up` = `cmd` + `shift` + `[` (previous tab)
    > - `volume down` = `cmd` + `shift` + `]` (next tab)
