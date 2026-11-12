{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    systems.url = "github:nix-systems/x86_64-linux";
    flakeUtils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
  };

  outputs =
  { flakeUtils
  , nixpkgs
  , ...
  }: flakeUtils.lib.eachDefaultSystem (system: let
    pkgs = import nixpkgs {
      localSystem.system = system;
      crossSystem.config = "mips-unknown-linux-gnu";
    };
  in {
    packages = rec {
      default = pkgs.callPackage nixpkgs/default { };
      nandspl = default.override {
        variant = "nandspl";
        installPhase = ''
          mkdir $out
          cp u-boot.ltq.lzo.nandspl $out
        '';
      };
      ram = default.override {
        variant = "ram";
        installPhase = ''
          source create_uart_image.sh
          mkdir $out
          cp u-boot.asc $out
        '';
      };
    };
    devShells = let
      devShellPackages = {
        packages = with pkgs; [
          bc
          gcc
          gnumake
          lzop
          pkgsCross.mips-linux-gnu.buildPackages.gcc
        ];
      };
    in {
      default = pkgs.mkShell devShellPackages // {
        # shellHook = ''
        #   CROSS_COMPILE=mips-unknown-linux-gnu-
        # '';
      };
      custom = pkgs.mkShell devShellPackages // {
        shellHook = ''
          EDITOR=nvim \
          LC_CTYPE=en_US.UTF-8 \
          CROSS_COMPILE=mips-unknown-linux-gnu- \
          exec ${ pkgs.zsh }/bin/zsh
        '';
      };
    };
  });
}
