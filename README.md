# Gambito ♞

Biblioteca visual de ajedrez para iPhone (SwiftUI, iOS 26). Proyecto personal.

## Estructura
- `Gambito/` — la app (SwiftUI).
- `GambitoCore/` — paquete Swift con la lógica de ajedrez. Es el único que usa ChessKit.
  Sus tests (`swift test --package-path GambitoCore`) validan todas las líneas y se
  ejecutan en el CI antes de compilar la app.

## Cómo se compila
1. XcodeGen genera `Gambito.xcodeproj` a partir de `project.yml` en GitHub Actions.
2. `.github/workflows/build-ipa.yml` ejecuta los tests, compila sin firmar y publica `Gambito.ipa`.
3. La firma y la instalación se hacen en Linux con Impactor.

Créditos y licencias: [CREDITS.md](CREDITS.md).
