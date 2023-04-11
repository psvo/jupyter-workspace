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
        jdk = pkgs.jdk17;
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
        jupyterRunner = pkgs.writeShellApplication {
          name = "jupyterRunner";
          runtimeInputs = [
            jupyterEnv
            jdk
          ];
          text = ''
            if [[ $# -eq 0 ]]; then
              exec jupyter notebook --no-browser
            else
              exec jupyter "$@"
            fi
          '';
        };
      in {
        formatter = pkgs.alejandra;
        packages.java-kernel = javaKernel;
        packages.jupyter-env = jupyterEnv;
        packages.default = jupyterRunner;
        apps.default = flake-utils.lib.mkApp rec {
          drv = jupyterRunner;
        };
      }
    );
}
