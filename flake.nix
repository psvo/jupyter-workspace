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
      in rec {
        formatter = pkgs.alejandra;

        packages = {
          inherit python jdk;
          jupyter = python.pkgs.jupyter;
          rise = pkgs.callPackage ./pkgs/rise.nix {
            inherit python;
          };
          java-kernel = pkgs.callPackage ./pkgs/java-kernel.nix {
            inherit python;
            inherit jdk;
          };
          bash-kernel = python.pkgs.bash_kernel.override {
            python = python.withPackages (ps: [ps.bash_kernel]);
          };
          jupyter-runner = pkgs.callPackage ./pkgs/runner.nix {
            inherit python;
            env = {
              IN_JUPYTER_ENV = 1;
            };
            extraPkgs = with packages; [
              jdk
            ];
            pythonPkgs = ps:
              with packages; [
                rise
                java-kernel
                bash-kernel
              ];
          };
          default = packages.jupyter-runner;
        };
      }
    );
}
