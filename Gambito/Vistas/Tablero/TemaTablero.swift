// TemaTablero.swift — los cuatro temas del tablero.

import SwiftUI

/// Colores que necesita el tablero. Es Sendable: se puede pasar sin peligro al Canvas.
struct ColoresTablero: Sendable {
    let claro: Color
    let oscuro: Color
    let resaltado: Color          // capa sobre la última jugada (semitransparente)
    let textoSobreClaro: Color    // coordenadas en casillas claras
    let textoSobreOscuro: Color   // coordenadas en casillas oscuras
}

enum TemaTablero: String, CaseIterable, Identifiable {
    case madera, marmol, clasico, neon

    var id: String { rawValue }

    var nombre: String {
        switch self {
        case .madera: "Madera"
        case .marmol: "Mármol"
        case .clasico: "Clásico"
        case .neon: "Neón"
        }
    }

    var colores: ColoresTablero {
        switch self {
        case .madera:
            ColoresTablero(claro: Color(hex: 0xE8C99B), oscuro: Color(hex: 0xA6703F),
                           resaltado: Color(hex: 0xF6D54A, opacidad: 0.5),
                           textoSobreClaro: Color(hex: 0xA6703F), textoSobreOscuro: Color(hex: 0xE8C99B))
        case .marmol:
            ColoresTablero(claro: Color(hex: 0xEDEBE7), oscuro: Color(hex: 0x8F9AA7),
                           resaltado: Color(hex: 0x7DB4DA, opacidad: 0.55),
                           textoSobreClaro: Color(hex: 0x6E7884), textoSobreOscuro: Color(hex: 0xEDEBE7))
        case .clasico:
            ColoresTablero(claro: Color(hex: 0xEEEEDC), oscuro: Color(hex: 0x6F8E6C),
                           resaltado: Color(hex: 0xF2E27A, opacidad: 0.55),
                           textoSobreClaro: Color(hex: 0x6F8E6C), textoSobreOscuro: Color(hex: 0xEEEEDC))
        case .neon:
            ColoresTablero(claro: Color(hex: 0x2D2456), oscuro: Color(hex: 0x15102C),
                           resaltado: Color(hex: 0x00E5FF, opacidad: 0.35),
                           textoSobreClaro: Color(hex: 0x7FF6FF), textoSobreOscuro: Color(hex: 0xFF7BE5))
        }
    }
}

extension Color {
    /// Color a partir de un número hexadecimal, por ejemplo 0xE8C99B.
    init(hex: UInt32, opacidad: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacidad
        )
    }
}
