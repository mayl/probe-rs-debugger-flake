{ lib
, fetchurl
, vscode-utils

  # maybe needed for build
, stdenv
, fetchFromGitHub
, mkYarnPackage
, nodePackages
, buildFromSrc ? false
}:

let
  pname = "probe-rs-debugger";
  publisher = "probe-rs";
  version = "0.4.0";
  releaseTag = "v0.4.0";

  src = fetchFromGitHub {
    owner = "probe-rs";
    repo = "vscode";
    rev = releaseTag;
    sha256 = "sha256-kIj5Zx5D1C32uptmOk/GhS5rd8XjBd9aWNjeZT9sf2E=";
  };

  probe-rs-extension = mkYarnPackage {
    name = "probe-rs-extension";
    src = src;
    packageJson = "${src}/package.json";
    yarnLock = ./yarn.lock;
    yarnNix = ./yarn.nix;
    nativeBuildInputs = with nodePackages; [ webpack webpack-cli ];
  };

  vsix_built = "${probe-rs-extension}/build/vsix";

  vsix_fetched = fetchurl {
    url = "https://github.com/probe-rs/vscode/releases/download/v0.4.0/probe-rs-debugger-0.4.0.vsix";
    sha256 = "sha256-o+NN03TSX7RIZtPMiw17Hb0cqQBoXWxudYwFU5anH+Y=";
    name = "${pname}-${version}.zip";
  };

  vsix = if buildFromSrc then vsix_built else vsix_fetched;

in
vscode-utils.buildVscodeExtension {
  inherit vsix version;
  src = vsix;
  name = "${pname}-${version}";
  vscodeExtUniqueId = "${publisher}.${pname}";

  meta = with lib; {
    description = "A probe-rs frontend for debugging ARM and RISC-V targets in vscode";
    homepage = "https://probe.rs/docs/tools/vscode/";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
