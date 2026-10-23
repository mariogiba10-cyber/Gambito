# Gambito ♞

Biblioteca visual de ajedrez para iPhone (SwiftUI, iOS 26). Proyecto personal.

## Cómo se compila
1. `project.yml` describe el proyecto; XcodeGen genera `Gambito.xcodeproj` en GitHub Actions.
2. `.github/workflows/build-ipa.yml` compila sin firmar y publica `Gambito.ipa` (artefacto `Gambito-ipa`).
3. La firma y la instalación se hacen en Linux con Impactor.

Créditos y licencias: [CREDITS.md](CREDITS.md).
