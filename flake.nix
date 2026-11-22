{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };
  outputs =
    {
      flake-utils,
      nixpkgs,
      rust-overlay,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        inherit (nixpkgs) lib;
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };
      in
      {
        devShells.default = pkgs.mkShell rec {
          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs =
            builtins.attrValues {
              inherit (pkgs)
                alsa-lib
                clang
                libx11
                libxcursor
                libxi
                libxkbcommon
                libxrandr
                mold
                pkg-config
                udev
                vulkan-loader
                wayland
                ;
            }
            ++ [
              pkgs.rustPlatform.bindgenHook
              (pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml)
            ];
          LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
        };
      }
    );
}
