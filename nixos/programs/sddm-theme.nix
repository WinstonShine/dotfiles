# catppuccin mocha sddm theme
# theme source: https://github.com/catppuccin/sddm/issues/30
# package source: https://github.com/NixOS/nixpkgs/pull/296682/files#diff-ab5748dc9567516fefba8344056b51ec1866adeace380f46e58a7af3d619ea22

{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  just,
  qtsvg,
  flavor ? "mocha",
  font ? "Noto Sans",
  fontSize ? "9",
  background ? null,
  loginBackground ? false,
}:
stdenvNoCC.mkDerivation rec {
  pname = "catppuccin-sddm";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "sddm";
    rev = "v${version}";
    hash = "sha256-SdpkuonPLgCgajW99AzJaR8uvdCPi4MdIxS5eB+Q9WQ=";
  };

  dontWrapQtApps = true;

  nativeBuildInputs = [
    just
  ];

  propagatedBuildInputs = [
    qtsvg
  ];

  buildPhase = ''
    runHook preBuild
    just build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/sddm/themes/"
    cp -r dist/catppuccin-${flavor} "$out/share/sddm/themes/catppuccin-${flavor}"
    configFile=$out/share/sddm/themes/catppuccin-${flavor}/theme.conf
    substituteInPlace $configFile \
      --replace-fail 'Font="Noto Sans"' 'Font="${font}"' \
      --replace-fail 'FontSize=9' 'FontSize=${fontSize}'
    ${lib.optionalString (background != null) ''
      substituteInPlace $configFile \
        --replace-fail 'Background="backgrounds/wall.jpg"' 'Background="${background}"' \
        --replace-fail 'CustomBackground="false"' 'CustomBackground="true"'
    ''}
    ${lib.optionalString loginBackground ''
      substituteInPlace $configFile \
        --replace-fail 'LoginBackground="false"' 'LoginBackground="true"'
    ''}
    runHook postInstall
  '';

  postFixup = ''
    mkdir -p $out/nix-support
    echo ${qtsvg} >> $out/nix-support/propagated-user-env-packages
  '';

  meta = {
    description = "Soothing pastel theme for SDDM";
    homepage = "https://github.com/catppuccin/sddm";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [elysasrc];
    platforms = lib.platforms.linux;
  };
}