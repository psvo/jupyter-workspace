{
  fetchzip,
  python,
  jdk,
  ...
}:
python.pkgs.buildPythonPackage {
  name = "java-kernel";
  preBuild = ''
    cat > setup.py <<-EOF
    from setuptools import setup

    #with open('requirements.txt') as f:
    #    install_requires = f.read().splitlines()

    setup(
      name='ijava-kernel',
      #version='0',
    )
    EOF
  '';
  src = fetchzip {
    url = "https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip";
    sha256 = "sha256-duuJC5iUz1jj1xshHjhEoa8lb5YmPjOMz42naFrGGCU=";
    stripRoot = false;
  };

  propagatedBuildInputs = [
    jdk
  ];

  nativeBuildInputs = [
    python.pkgs.notebook
  ];

  doCheck = false;
  dontConfigure = true;

  installPhase = ''
    ${python.interpreter} install.py --prefix $out
  '';
}
