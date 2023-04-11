{
  inputs = {
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        python = pkgs.python3;
        jdk = pkgs.jdk17_headless;
        risePkg = pkgs.callPackage ./rise.nix {inherit python;};
        javaKernel = pkgs.callPackage ./java-kernel.nix {
          inherit python;
          inherit jdk;
        };
        bashKernel = python.pkgs.bash_kernel.override {
          python = python.withPackages (ps: [ps.bash_kernel]);
        };
        jupyterEnv = python.withPackages (ps:
          with ps; [
            jupyter
            risePkg
            ipykernel
            javaKernel
            bashKernel
          ]);
        jupyterRunner = {
          pkgs,
          runtimeInputs ? [],
          ...
        }:
          pkgs.writeShellApplication {
            name = "jupyterRunner";
            runtimeInputs = with pkgs; [jupyterEnv] ++ runtimeInputs;
            text = ''
              if [[ $# -eq 0 ]]; then
                exec jupyter notebook --no-browser
              else
                exec jupyter "$@"
              fi
            '';
          };
      in rec {
        formatter = pkgs.alejandra;
        packages.java-kernel = javaKernel;
        packages.jupyter-env = jupyterEnv;
        packages.default = pkgs.callPackage jupyterRunner {};
        devShells.default = with pkgs;
          mkShell {
            buildInputs = [
              bashInteractive
              packages.jupyter-env
              jdk
            ];
          };
      }
    );
}
