// Componentes.swift
// Piezas visuales reutilizables en toda la app.

import SwiftUI

// Fondo oscuro con degradado vertical (violeta muy oscuro → casi negro).
struct FondoGambito: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.10, green: 0.08, blue: 0.16),
                Color(red: 0.03, green: 0.03, blue: 0.06)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()      // que cubra también detrás de la barra de estado
    }
}

// Tablero 8x8 sin piezas, dibujado con Canvas.
// Fila 0 = fila 8 del tablero, columna 0 = columna "a": a8 es casilla clara.
struct TableroDecorativo: View {
    var body: some View {
        Canvas { contexto, area in
            let claro = Color(red: 0.93, green: 0.85, blue: 0.70)    // madera clara
            let oscuro = Color(red: 0.55, green: 0.38, blue: 0.24)   // madera oscura
            let lado = min(area.width, area.height) / 8              // tamaño de cada casilla
            for fila in 0..<8 {
                for columna in 0..<8 {
                    let casilla = CGRect(
                        x: CGFloat(columna) * lado,
                        y: CGFloat(fila) * lado,
                        width: lado,
                        height: lado
                    )
                    // Si fila + columna es par, la casilla es clara
                    let color = (fila + columna).isMultiple(of: 2) ? claro : oscuro
                    contexto.fill(Path(casilla), with: .color(color))
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)     // siempre cuadrado
        .clipShape(.rect(cornerRadius: 14))    // esquinas redondeadas
        .accessibilityHidden(true)             // decorativo: VoiceOver lo ignora
    }
}
