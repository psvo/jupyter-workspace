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
        javaKernel = pkgs.callPackage ./java-kernel.nix {
          inherit python;
          inherit jdk;
        };
        jupyterEnv = python.withPackages (ps:
          with ps; [
            jupyter
            ipykernel
            javaKernel
            #bash_kernel
          ]);
        jupyterRunner = pkgs.writeShellApplication {
          name = "jupyterRunner";
          runtimeInputs = [
            jupyterEnv
            jdk
          ];
          text = ''
            if [[ $# -eq 0 ]]; then
              exec jupyter notebook
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
