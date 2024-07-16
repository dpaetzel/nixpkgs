{ stdenv
, lib
, fetchFromGitHub
, makeWrapper
, clipnotify
, coreutils
, gawk
, util-linux
, xdotool
, xsel
}:
stdenv.mkDerivation rec {
  pname = "clipmenu";
  version = "87e164-dev";

  src = fetchFromGitHub {
    owner  = "cdown";
    repo   = "clipmenu";
    rev = "87e1641b50ff0cc57ca850c34fe4d4c8cbb60bb0";
    sha256 = "sha256-35HA7ZxRLuZsgG4/NHG7qarSgEWZ8rwrlvXDEm+B9ws=";
  };

  postPatch = ''
    sed -i init/clipmenud.service \
      -e "s,/usr/bin,$out/bin,"
  '';

  makeFlags = [ "PREFIX=$(out)" ];
  nativeBuildInputs = [ makeWrapper xsel clipnotify ];

  postFixup = ''
    sed -i "$out/bin/clipctl" -e 's,clipmenud\$,\.clipmenud-wrapped\$,'

    wrapProgram "$out/bin/clipmenu" \
      --prefix PATH : "${lib.makeBinPath [ xsel ]}:$out/bin"

    wrapProgram "$out/bin/clipmenud" \
      --set PATH "${lib.makeBinPath [ clipnotify coreutils gawk util-linux xdotool xsel ]}:$out/bin"
  '';

  meta = with lib; {
    description = "Clipboard management using dmenu";
    inherit (src.meta) homepage;
    maintainers = with maintainers; [ jb55 ];
    license = licenses.publicDomain;
  };
}
