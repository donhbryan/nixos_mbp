{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.python3
    pkgs.python3Packages.pip
    pkgs.python3Packages.virtualenv
    # System dependencies for your music libraries
    pkgs.chromaprint # required for acoustid
    pkgs.sqlite
  ];

  shellHook = ''
    # This automatically creates/activates a venv when you enter the shell
    if [ ! -d ".venv" ]; then
      python -m venv .venv
    fi
    source .venv/bin/activate
    unset SOURCE_DATE_EPOCH 
  '';
}
