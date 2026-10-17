# Nova native media

Reproducible libmpv and FFmpeg builds for Nova's Android and Windows packages.
Linux uses system libraries. Native binaries live in GitHub release assets;
this repository tracks the build recipes and source/toolchain lock.

Each release contains:

- `nova-media-android-arm64.tar.gz`
- `nova-media-android-armv7.tar.gz`
- `nova-media-android-x86_64.tar.gz`
- `nova-media-mingw-x86_64.tar.gz`
- `nova-media-sources.tar.gz`: the exact upstream runtime-dependency sources
  and the locked build recipe.
- `SHA256SUMS`: archive hashes.

Build on x86_64 Linux with Nix:

```sh
nix build .#archive-android-arm64
nix build .#archive-mingw-x86_64
nix build .#archive-sources
```

Replace `archive-` with `bundle-` to obtain an unpacked runtime/SDK bundle.
Bundles include headers, import libraries, runtime libraries, license notices,
build configurations, validation results and per-file hashes. Android bundles
also include CA roots. The archives unpack directly into those directories.

Nova pins a release URL and Nix content hash for each target. Native dependency
updates happen here independently of Nova's application releases. Push a `v*`
tag to build, validate and publish all bundles automatically.

The initial profile uses mpv 0.41.0 and FFmpeg 9.0.1. It includes MKV, HEVC,
AV1/dav1d, common playback codecs, subtitles and packet-copy remuxing. Android
uses MediaCodec; Windows uses D3D11 copy-back decoding. PNG/JPEG screenshot
encoding is included; audio/video transcoding is excluded.

See [the feature profile and build notes](nix/native-media/README.md) and
[recorded validation and sizes](nix/native-media/RESULTS.md).
