{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, rust-overlay, ... }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    devShells = forAllSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [rust-overlay.overlays.default];
        };
        # rmk 0.8.2 breaks on newer rustc (pin! macro change) — pin to the
        # stable that was current when it was released
        toolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = ["rust-src" "llvm-tools-preview" "rustfmt"];
          targets = ["thumbv7em-none-eabihf"];
        };
      in {
        default = pkgs.mkShell {
          RUST_MIN_STACK = "33554432";

          packages = [
            toolchain
            pkgs.cargo-make
            pkgs.flip-link
            pkgs.cargo-binutils
            pkgs.probe-rs-tools

            pkgs.gcc
            pkgs.pkg-config
            pkgs.llvmPackages.clang
          ];

          # bindgen (nrf-sdc-sys / nrf-mpsl-sys) needs libclang
          LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";

          shellHook = ''
            # cargo-installed helpers (e.g. cargo-hex-to-uf2) — LAST, so
            # stale rustup proxy shims can't shadow the nix toolchain
            export PATH=$PATH:$HOME/.cargo/bin
          '';
        };
      }
    );
  };
}
