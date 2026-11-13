{
  bc,
  gcc15,
  gcc15Stdenv,
  lzop,
  perl,
  installPhase ? "",
  variant ? ""
}: gcc15Stdenv.mkDerivation {
  name = "uboot_vrv9510kwac_${variant}";
  src = ../..;
  postPatch = ''
    patchShebangs create_uart_image.sh
    patchShebangs tools
    patchShebangs scripts
  '';
  depsBuildBuild = [
    bc
    gcc15
    lzop
    perl
  ];
  enableParallelBuilding = true;
  makeFlags = [
    "CROSS_COMPILE=${gcc15Stdenv.cc.targetPrefix}"
  ];
  configurePhase = ''
    runHook preConfigure

    make vrv9510kwac_${variant}_config

    runHook postConfigure
  '';
  installPhase = ''
    runHook preInstall

    ${installPhase}

    runHook postInstall
  '';
}
