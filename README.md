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

Nix (flake):

```sh
nix run github:ThatOneCalculator/deltatune-linux
```

From a local checkout:

```sh
nix run .
```

Nix install options:
- NixOS module (user service):
  ```nix
  {
    inputs.deltatune-linux.url = "github:ThatOneCalculator/deltatune-linux";
    outputs = { self, nixpkgs, deltatune-linux, ... }: {
      nixosConfigurations.yourHost = nixpkgs.lib.nixosSystem {
        modules = [
          deltatune-linux.nixosModules.default
          {
            services.deltatune.enable = true;
          }
        ];
      };
    };
  }
  ```

- Home Manager module (user service):
  ```nix
  {
    inputs.deltatune-linux.url = "github:ThatOneCalculator/deltatune-linux";
    outputs = { self, nixpkgs, home-manager, deltatune-linux, ... }: {
      homeConfigurations.me = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        modules = [
          deltatune-linux.homeManagerModules.default
          {
            services.deltatune.enable = true;
          }
        ];
      };
    };
  }
  ```

- Plain package only: add `inputs.deltatune-linux.url = "github:ThatOneCalculator/deltatune-linux";` then `environment.systemPackages` (NixOS) or `home.packages` (Home Manager) with `inputs.deltatune-linux.packages.${pkgs.stdenv.hostPlatform.system}.default`

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
- [x] NIX flake
- [ ] Artist info(?)
- [ ] 🦀 Rewrite it in Rust

## Additional credits

- [Toastworth](https://x.com/Toastworth_) for creating the original [DeltaTune](https://deltatune.toastworth.com/) for Windows
- [Toby Fox](https://bsky.app/profile/tobyfox.undertale.com/) and team for creating [DELTARUNE](https://deltarune.com/)

This project is neither associated with the original DeltaTune nor DELTARUNE.
