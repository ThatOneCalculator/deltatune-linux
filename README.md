# DeltaTune Linux

[DeltaTune](https://deltatune.toastworth.com/) ported to Linux (X11 & Wayland) using [Quickshell](https://quickshell.org/)

<img width="1408" height="771" alt="1754263375" src="https://github.com/user-attachments/assets/57296ec5-fd1f-45ed-a102-9af09c56bdfe" />

https://github.com/user-attachments/assets/403449fa-929f-48e9-915a-d1a5b8d6fdd0

## Requirements

- [Quickshell](https://quickshell.org/)
- [Playerctl](https://github.com/altdesktop/playerctl)

## Install & run

Arch Linux [(AUR)](https://aur.archlinux.org/packages/deltatune-linux):

```sh
yay -S deltatune-linux
deltatune
```

Other distros:

```sh
git clone https://github.com/ThatOneCalculator/deltatune-linux
sudo make install
deltatune
```

## Configuration

After installing, edit `/etc/xdg/quickshell/deltatune/config.js`. Configuration keys are explained in the file, the default configuration puts DeltaTune at the top-right.

## Features

- [x] Display title of current song
  - [x] ANSI (English, Spanish, etc)
  - [x] Japanese
  - [x] Korean
- [x] Enter/leave animation
- [x] Configuration
- [x] AUR package
- [x] Artist info(?)
- [ ] 🦀 Rewrite it in Rust

## Additional credits

- [Toastworth](https://x.com/Toastworth_) for creating the original [DeltaTune](https://deltatune.toastworth.com/) for Windows
- [Toby Fox](https://bsky.app/profile/tobyfox.undertale.com/) and team for creating [DELTARUNE](https://deltarune.com/)

This project is neither associated with the original DeltaTune nor DELTARUNE.
