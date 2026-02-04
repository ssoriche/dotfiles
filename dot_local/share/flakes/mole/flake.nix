{
  description = "Mole - Lightweight macOS system maintenance tool";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "aarch64-darwin" "x86_64-darwin" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        version = "1.24.0";
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "mole";
          inherit version;

          src = pkgs.fetchFromGitHub {
            owner = "tw93";
            repo = "mole";
            rev = "V${version}";
            hash = "sha256-M9FoOQFjk4kYTW56SWwpT8HwtppP7WCUejGmwakD4Co=";
          };

          nativeBuildInputs = [ pkgs.go pkgs.makeWrapper ];

          buildPhase = ''
            runHook preBuild
            export HOME=$TMPDIR
            export GOCACHE=$TMPDIR/go-cache
            export GOPATH=$TMPDIR/go
            (cd cmd/analyze && go build -ldflags="-s -w" -o $TMPDIR/analyze-go .)
            (cd cmd/status && go build -ldflags="-s -w" -o $TMPDIR/status-go .)
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            mkdir -p $out/bin $out/share/mole/{bin,lib}

            # Main scripts
            install -m755 mole $out/bin/mole
            install -m755 mo $out/bin/mo

            # Libraries
            cp -r lib/* $out/share/mole/lib/

            # Go binaries
            install -m755 $TMPDIR/analyze-go $out/share/mole/bin/
            install -m755 $TMPDIR/status-go $out/share/mole/bin/

            # Patch SCRIPT_DIR - the script sets it dynamically, so we replace that line
            substituteInPlace $out/bin/mole \
              --replace 'SCRIPT_DIR="$(cd "$(dirname "''${BASH_SOURCE[0]}")" && pwd)"' \
                        "SCRIPT_DIR=\"$out/share/mole\""

            # Patch mo alias to point to correct mole location
            substituteInPlace $out/bin/mo \
              --replace 'exec "$(dirname "$0")/mole"' "exec \"$out/bin/mole\""

            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "Lightweight macOS system maintenance tool";
            homepage = "https://github.com/tw93/mole";
            license = licenses.mit;
            platforms = platforms.darwin;
            mainProgram = "mole";
          };
        };

        packages.mole = self.packages.${system}.default;
      });
}
