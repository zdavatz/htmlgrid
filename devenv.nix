{ pkgs, ... }:

{
  # https://devenv.sh/basics/
  env.GREET = "devenv";
  env.FREEDESKTOP_MIME_TYPES_PATH = "${pkgs.shared-mime-info}/share/mime/packages/freedesktop.org.xml";

  # https://devenv.sh/packages/
  packages = [ pkgs.git pkgs.libyaml ];

  enterShell = ''
    echo This is the devenv shell for htmlgrid
    git --version
    ruby --version
  '';

  languages.ruby.enable = true;
  languages.ruby.versionFile = ./.ruby-version;

  # See full reference at https://devenv.sh/reference/options/
}
