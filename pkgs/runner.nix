{
  stdenv,
  lib,
  pkgs,
  python,
  pythonPkgs ? (ps: []),
  extraPkgs ? [],
  env ? [],
  ...
}: let
  jupyterEnv = python.withPackages (
    ps: [ps.jupyter] ++ (pythonPkgs ps)
  );
in
  pkgs.stdenv.mkDerivation rec {
    name = "run-jupyter";
    buildInputs = [jupyterEnv] ++ extraPkgs;
    phases = ["installPhase"];

    runnerEnv = with builtins;
      concatStringsSep "\n" (attrValues (mapAttrs (name: value: ''export ${name}="${toString value}"'') env));

    runnerScript = ''
      #!${stdenv.shell}
      export PATH="${lib.makeBinPath buildInputs}:$PATH"
      ${runnerEnv}
      if [[ $# -eq 0 ]]; then
        exec jupyter notebook --no-browser
      else
        exec "$@"
      fi
    '';

    installPhase = ''
      mkdir -p "$out/bin"
      echo "$runnerScript" > "$out/bin/$name"
      chmod +x "$out/bin/$name"
    '';

    shellHook = ''
      ${runnerEnv}
      ${installPhase}
      export PATH="$out/bin:$PATH"
    '';
  }
