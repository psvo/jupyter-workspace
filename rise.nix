{
  python,
  ...
}:
with python.pkgs;
buildPythonPackage rec {
  pname = "rise";
  version = "5.7.1";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-ZB23d8uQe/Xm3AUwmNf9ITgT+pqUZULlK5AOtwlSiaY=";
  };
  propagatedBuildInputs = [
    notebook
  ];
}
