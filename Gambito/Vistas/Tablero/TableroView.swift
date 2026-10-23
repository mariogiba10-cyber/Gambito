// TableroView.swift — el tablero: casillas (Canvas), coordenadas y piezas animadas.

import SwiftUI
import GambitoCore

/// Traduce entre casillas reales y su sitio en pantalla (depende de si el tablero está girado).
struct OrientacionTablero: Sendable {
    let desdeNegras: Bool

    /// Qué casilla hay en la columna/fila de la PANTALLA (0,0 = arriba a la izquierda).
    func casilla(columnaVisual: Int, filaVisual: Int) -> Casilla {
        desdeNegras
            ? Casilla(columna: 7 - columnaVisual, fila: filaVisual)!
            : Casilla(columna: columnaVisual, fila: 7 - filaVisual)!
    }

    /// Centro en pantalla de una casilla.
    func centro(de casilla: Casilla, celda: CGFloat) -> CGPoint {
        let columnaVisual = desdeNegras ? 7 - casilla.columna : casilla.columna
        let filaVisual = desdeNegras ? casilla.fila : 7 - casilla.fila
        return CGPoint(x: (CGFloat(columnaVisual) + 0.5) * celda, y: (CGFloat(filaVisual) + 0.5) * celda)
    }
}

extension PiezaConID {
    /// Nombre de la imagen en Assets.xcassets, por ejemplo "cburnett-wN".
    var nombreImagen: String { "cburnett-\(color == .blancas ? "w" : "b")\(tipo.letraIngles)" }

    /// Texto para VoiceOver, por ejemplo «Caballo blanco en f3».
    var descripcionVoz: String {
        let femenina = tipo == .dama || tipo == .torre
        let textoColor = color == .blancas ? (femenina ? "blanca" : "blanco") : (femenina ? "negra" : "negro")
        return "\(tipo.nombre.prefix(1).uppercased() + tipo.nombre.dropFirst()) \(textoColor) en \(casilla.notacion)"
    }
}

struct TableroView: View {
    let piezas: [PiezaConID]
    var ultimaJugada: Jugada? = nil
    var casillaEnJaque: Casilla? = nil
    var tema: TemaTablero = .madera
    var mostrarCoordenadas = true
    var desdeNegras = false

    var body: some View {
        GeometryReader { geo in
            let lado = min(geo.size.width, geo.size.height)
            let celda = lado / 8
            let orientacion = OrientacionTablero(desdeNegras: desdeNegras)

            ZStack(alignment: .topLeading) {
                FondoCasillas(orientacion: orientacion, colores: tema.colores,
                              ultimaJugada: ultimaJugada, casillaEnJaque: casillaEnJaque, celda: celda)

                if mostrarCoordenadas {
                    CoordenadasTablero(orientacion: orientacion, colores: tema.colores, celda: celda)
                }

                // Cada pieza se identifica por su id: al cambiar de casilla, SwiftUI la desliza
                ForEach(piezas) { pieza in
                    Image(pieza.nombreImagen)
                        .resizable()
                        .interpolation(.high)
                        .frame(width: celda, height: celda)
                        .position(orientacion.centro(de: pieza.casilla, celda: celda))
                        .transition(.opacity.combined(with: .scale(scale: 0.6)))
                        .accessibilityLabel(pieza.descripcionVoz)
                }
            }
            .frame(width: lado, height: lado)
            .clipShape(.rect(cornerRadius: 10))
            .overlay {
                if tema == .neon {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color(hex: 0xFF2BD6, opacidad: 0.9), lineWidth: 1.5)
                        .shadow(color: Color(hex: 0xFF2BD6), radius: 6)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

/// Las 64 casillas, el resaltado de la última jugada y el brillo rojo del jaque.
struct FondoCasillas: View {
    let orientacion: OrientacionTablero
    let colores: ColoresTablero
    let ultimaJugada: Jugada?
    let casillaEnJaque: Casilla?
    let celda: CGFloat

    var body: some View {
        // Copias locales con valores simples: así el Canvas es seguro en Swift 6
        let orientacion = orientacion
        let colores = colores
        let marcadas: Set<Casilla> = ultimaJugada.map { Set([$0.origen, $0.destino]) } ?? []
        let jaque = casillaEnJaque
        let celda = celda

        Canvas { contexto, _ in
            for filaVisual in 0..<8 {
                for columnaVisual in 0..<8 {
                    let casilla = orientacion.casilla(columnaVisual: columnaVisual, filaVisual: filaVisual)
                    let rect = CGRect(x: CGFloat(columnaVisual) * celda, y: CGFloat(filaVisual) * celda,
                                      width: celda, height: celda)
                    contexto.fill(Path(rect), with: .color(casilla.esClara ? colores.claro : colores.oscuro))

                    if marcadas.contains(casilla) {
                        contexto.fill(Path(rect), with: .color(colores.resaltado))
                    }
                    if casilla == jaque {
                        let centro = CGPoint(x: rect.midX, y: rect.midY)
                        contexto.fill(
                            Path(ellipseIn: rect.insetBy(dx: -celda * 0.1, dy: -celda * 0.1)),
                            with: .radialGradient(
                                Gradient(colors: [Color.red.opacity(0.95), Color.red.opacity(0)]),
                                center: centro, startRadius: 0, endRadius: celda * 0.62
                            )
                        )
                    }
                }
            }
        }
    }
}

/// Letras (abajo) y números (a la izquierda) dentro de las casillas del borde.
struct CoordenadasTablero: View {
    let orientacion: OrientacionTablero
    let colores: ColoresTablero
    let celda: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(0..<8, id: \.self) { columnaVisual in
                let casilla = orientacion.casilla(columnaVisual: columnaVisual, filaVisual: 7)
                Text(casilla.letraColumna)
                    .font(.system(size: celda * 0.2, weight: .semibold, design: .rounded))
                    .foregroundStyle(casilla.esClara ? colores.textoSobreClaro : colores.textoSobreOscuro)
                    .position(x: (CGFloat(columnaVisual) + 1) * celda - celda * 0.13, y: 8 * celda - celda * 0.15)
            }
            ForEach(0..<8, id: \.self) { filaVisual in
                let casilla = orientacion.casilla(columnaVisual: 0, filaVisual: filaVisual)
                Text("\(casilla.fila + 1)")
                    .font(.system(size: celda * 0.2, weight: .semibold, design: .rounded))
                    .foregroundStyle(casilla.esClara ? colores.textoSobreClaro : colores.textoSobreOscuro)
                    .position(x: celda * 0.13, y: CGFloat(filaVisual) * celda + celda * 0.17)
            }
        }
        .frame(width: celda * 8, height: celda * 8)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
