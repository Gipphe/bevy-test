{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    { flake-utils, nixpkgs, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        inherit (nixpkgs) lib;
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell rec {
          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs =
            builtins.attrValues {
              inherit (pkgs)
                alsa-lib
                cargo
                libx11
                libxcursor
                libxi
                libxkbcommon
                libxrandr
                pkg-config
                rustc
                udev
                vulkan-loader
                wayland
                ;
            }
            ++ [ pkgs.rustPlatform.bindgenHook ];
          LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
        };
      }
    );
}
