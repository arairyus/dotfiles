{
  lib,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "git-cz";
  version = "4.9.0";

  src = ./.;

  npmDepsHash = "sha256-5EiSZJY0xZJdoMBYRssNpZrQsD7cP8ZdMGlWkDTUxC4=";

  dontNpmBuild = true;

  meta = {
    description = "Semantic Git commits (streamich/git-cz)";
    homepage = "https://github.com/streamich/git-cz";
    license = lib.licenses.mit;
    mainProgram = "git-cz";
  };
}
