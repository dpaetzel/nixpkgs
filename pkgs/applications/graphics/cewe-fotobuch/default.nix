{ stdenv, fetchurl, perl, unzip, which, less, wget, zlib, qt5 }:

stdenv.mkDerivation rec {
  name = "cewe-fotobuch-1.0";

  src = fetchurl {
    url = https://dls.photoprintit.com/api/getClient/16523/hps/om_coop_website_1497626693_cwfbde_16060524_7ElqJypLDe9fB/linux;
    sha256 = "54a87dca60e0a65ae1e61f1a3c11a5d67632381b62eac49eebe19a57c6aeda9a";
  };

  unpackPhase = ''
    tar xaf $src

    sed --in-place '/system("clear");/d' "install.pl"
    sed --in-place '/showEula();/d' "install.pl"
    sed --in-place 's/chomp($answer = <STDIN>);/chomp($answer = "ja");/' "install.pl"
  '';

  buildInputs = [ less perl wget which unzip ];

  buildPhase = ''
    perl install.pl --installDir=.

    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "Mein CEWE FOTOBUCH"
    patchelf --set-rpath $libPath "Mein CEWE FOTOBUCH"

    rm install.pl
  '';

  installPhase = ''
    mkdir -p $out/lib
    mv libCW* $out/lib/

    mkdir -p $out/bin
    mv * $out/bin/

    mv $out/bin/{"Mein CEWE FOTOBUCH",cewe-fotobuch}
  '';

  libPath = stdenv.lib.makeLibraryPath [ stdenv.cc.cc zlib qt5.full ];
}
