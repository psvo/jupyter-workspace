{
  fetchzip,
  python,
  jdk,
  ...
}:
python.pkgs.buildPythonPackage rec {
  pname = "java-kernel";
  version = "1.3.0";

  src = fetchzip {
    url = "https://github.com/SpencerPark/IJava/releases/download/v${version}/ijava-${version}.zip";
    sha256 = "sha256-duuJC5iUz1jj1xshHjhEoa8lb5YmPjOMz42naFrGGCU=";
    stripRoot = false;
  };

  nativeBuildInputs = [python.pkgs.notebook];

  prePatch = ''
    cat > setup.py <<-EOF
    from setuptools import setup
    setup(
      name='java-kernel',
    )
    EOF
  '';

  doCheck = false;

  installPhase = ''
    ${python.interpreter} install.py --prefix $out
  '';

  fixupPhase = ''
    substituteInPlace "$out/share/jupyter/kernels/java/kernel.json" --replace '"java"' '"${jdk}/bin/java"'
  '';
}
