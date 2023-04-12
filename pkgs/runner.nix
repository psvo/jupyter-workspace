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
    name = "jupyter-runner";
    buildInputs = [jupyterEnv] ++ extraPkgs;
    phases = ["buildPhase"];
    runnerScript = ''
      #!${stdenv.shell}
      export PATH="${lib.makeBinPath buildInputs}:$PATH"
      ${shellHook}

      if [[ $# -eq 0 ]]; then
        exec jupyter notebook --no-browser
      else
        exec "$@"
      fi
    '';
    buildPhase = ''
      mkdir -p "$out/bin"
      echo "$runnerScript" > "$out/bin/$name"
      chmod +x "$out/bin/$name"
    '';
    shellHook = with builtins; (
      concatStringsSep "\n" (attrValues (mapAttrs (name: value: ''export ${name}="${toString value}"'') env))
    );
  }
