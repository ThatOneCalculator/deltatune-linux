{
  description = "DeltaTune Linux flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in {
          default = pkgs.stdenv.mkDerivation {
            pname = "deltatune";
            version = "unstable-${self.shortRev or "dev"}";
            src = self;
            dontConfigure = true;
            dontBuild = true;
            nativeBuildInputs = [ pkgs.makeWrapper ];
            propagatedBuildInputs = [ pkgs.quickshell pkgs.playerctl ];

            installPhase = ''
              mkdir -p $out/etc/xdg/quickshell/deltatune/fonts
              install -m644 shell.qml $out/etc/xdg/quickshell/deltatune/shell.qml
              install -m644 config.js $out/etc/xdg/quickshell/deltatune/config.js
              cp -v fonts/*.png $out/etc/xdg/quickshell/deltatune/fonts/
              cp -v fonts/*.js $out/etc/xdg/quickshell/deltatune/fonts/

              install -Dm755 deltatune $out/bin/deltatune
              wrapProgram $out/bin/deltatune \
                --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.quickshell pkgs.playerctl ]} \
                --prefix XDG_CONFIG_DIRS : $out/etc/xdg
            '';

            meta = with pkgs.lib; {
              description = "DeltaTune port for Quickshell";
              homepage = "https://github.com/jesperls/deltatune-linux";
              license = licenses.mit;
              maintainers = [ ];
              platforms = platforms.linux;
              mainProgram = "deltatune";
            };
          };
        });

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/deltatune";
          meta = {
            description = "Run the DeltaTune Quickshell widget";
          };
        };
      });

      formatter = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in pkgs.alejandra);

      nixosModules.default = { lib, config, pkgs, ... }:
        let
          cfg = config.services.deltatune;
        in {
          options.services.deltatune = {
            enable = lib.mkEnableOption "DeltaTune Quickshell widget";

            package = lib.mkOption {
              type = lib.types.package;
              default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
              description = "DeltaTune package to run as a systemd user service.";
            };
          };

          config = lib.mkIf cfg.enable {
            environment.systemPackages = [ cfg.package ];

            systemd.user.services.deltatune = {
              description = "DeltaTune Quickshell widget";
              after = [ "graphical-session.target" "pipewire.service" "pulseaudio.service" ];
              wantedBy = [ "graphical-session.target" ];
              serviceConfig = {
                ExecStart = "${cfg.package}/bin/deltatune";
                Restart = "on-failure";
                RestartSec = 5;
              };
            };
          };
        };

      homeManagerModules.default = { lib, config, pkgs, ... }:
        let
          cfg = config.services.deltatune;
        in {
          options.services.deltatune = {
            enable = lib.mkEnableOption "DeltaTune Quickshell widget (Home Manager user service)";

            package = lib.mkOption {
              type = lib.types.package;
              default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
              description = "DeltaTune package to run as a systemd user service.";
            };
          };

          config = lib.mkIf cfg.enable {
            home.packages = [ cfg.package ];

            systemd.user.services.deltatune = {
              Unit = {
                Description = "DeltaTune Quickshell widget";
                After = [ "graphical-session.target" "pipewire.service" "pulseaudio.service" ];
                PartOf = [ "graphical-session.target" ];
              };
              Service = {
                ExecStart = "${cfg.package}/bin/deltatune";
                Restart = "on-failure";
                RestartSec = 5;
              };
              Install = {
                WantedBy = [ "graphical-session.target" ];
              };
            };
          };
        };
    };
}
