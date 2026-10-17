{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          android_sdk.accept_license = true;
        };
      };
      media = import ./nix/native-media { inherit system pkgs; };
      targets = [
        "android-arm64"
        "android-armv7"
        "android-x86_64"
        "mingw-x86_64"
      ];
      # Include the exact runtime-dependency sources alongside the build recipe.
      sources = pkgs.runCommand "nova-media-sources" { } ''
        mkdir -p "$out/upstream" "$out/build-recipe/nix"
        cp ${./flake.nix} "$out/build-recipe/flake.nix"
        cp ${./flake.lock} "$out/build-recipe/flake.lock"
        cp -R ${./nix/native-media} "$out/build-recipe/nix/native-media"
        cp ${./README.md} "$out/build-recipe/README.md"
        cp ${./LICENSE} "$out/build-recipe/LICENSE"
        ${pkgs.lib.concatMapStringsSep "\n"
          (package: ''
            destination="$out/upstream/${package.pname}-${package.version}"
            if test -d ${package.src}; then
              cp -R ${package.src} "$destination"
            else
              mkdir -p "$destination"
              tar -xf ${package.src} -C "$destination" --strip-components=1
            fi
          '')
          [
            pkgs.ffmpeg
            pkgs.mpv-unwrapped
            pkgs.zlib
            pkgs.dav1d
            pkgs.freetype
            pkgs.fribidi
            pkgs.harfbuzz
            pkgs.libass
            pkgs.libplacebo
            pkgs.fast-float
            pkgs.mbedtls
            pkgs.pkgsCross.mingwW64.windows.mcfgthreads
          ]
        }
      '';
      archive =
        name: bundle:
        pkgs.runCommand "nova-media-${name}.tar.gz"
          {
            nativeBuildInputs = [
              pkgs.gnutar
              pkgs.gzip
            ];
          }
          ''
            tar --sort=name --format=gnu --mtime=@1 --owner=0 --group=0 --numeric-owner \
              -czf "$out" -C ${bundle} .
          '';
    in
    {
      packages.${system} =
        builtins.listToAttrs (
          builtins.concatMap (target: [
            {
              name = "bundle-${target}";
              value = media."bundle-${target}";
            }
            {
              name = "archive-${target}";
              value = archive target media."bundle-${target}";
            }
            {
              name = "probe-${target}";
              value = media."probe-${target}";
            }
          ]) targets
        )
        // {
          inherit sources;
          archive-sources = archive "sources" sources;
        };
    };
}
