// MotorAjedrez.swift
// ÚNICO archivo que habla con ChessKit 0.17.0. Toda la API usada aquí
// está comprobada en su código fuente (Board.swift, Move.swift, Position.swift…).

import ChessKit

/// Errores al validar posiciones y líneas. Los tests hacen fallar el CI si aparecen.
public enum ErrorAjedrez: Error, Equatable, CustomStringConvertible {
    case fenInvalida(fen: String, motivo: String)
    case lineaVacia
    case jugadaIlegal(medioMovimiento: Int, san: String, fen: String)
    case notacionNoCanonica(medioMovimiento: Int, escrita: String, esperada: String)
    case faltaCoronacion(medioMovimiento: Int, san: String)
    case coronacionInesperada(medioMovimiento: Int, san: String)

    public var description: String {
        switch self {
        case let .fenInvalida(fen, motivo):
            "FEN no válida (\(motivo)): \(fen)"
        case .lineaVacia:
            "La línea no contiene jugadas."
        case let .jugadaIlegal(medio, san, fen):
            "Jugada ilegal o no reconocida en el medio movimiento \(medio): «\(san)». Posición: \(fen)"
        case let .notacionNoCanonica(medio, escrita, esperada):
            "Notación incorrecta en el medio movimiento \(medio): pone «\(escrita)» y debería ser «\(esperada)»."
        case let .faltaCoronacion(medio, san):
            "Falta la pieza de coronación en el medio movimiento \(medio): «\(san)»."
        case let .coronacionInesperada(medio, san):
            "Hay una coronación donde no corresponde en el medio movimiento \(medio): «\(san)»."
        }
    }
}

public enum MotorAjedrez {

    /// FEN de la posición inicial.
    public static let fenInicial = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

    /// Convierte una FEN (comprobada) en una Posicion de Gambito.
    public static func posicion(fen: String) throws -> Posicion {
        convertir(try posicionChessKit(fen: fen))
    }

    /// Reproduce una línea («1. e4 e5 2. Nf3…») comprobando CADA jugada:
    /// 1. ChessKit la interpreta y comprueba que sea legal.
    /// 2. Se hace en un Board (que gestiona enroques, capturas al paso, coronaciones).
    /// 3. La notación escrita debe ser idéntica a la correcta que calcula el Board
    ///    (así detectamos jaques sin «+», ambigüedades sin desambiguar, etc.).
    public static func reproducir(pgn: String, desdeFEN fen: String = fenInicial) throws -> LineaReproducible {
        let inicial = try posicionChessKit(fen: fen)
        let jugadas = jugadasSAN(de: pgn)
        guard !jugadas.isEmpty else { throw ErrorAjedrez.lineaVacia }

        var tablero = Board(position: inicial)
        var pasos: [PasoLinea] = []

        for (i, escrita) in jugadas.enumerated() {
            let medio = i + 1
            let limpia = quitarAnotaciones(escrita)
            let fenAntes = tablero.position.fen

            // Move(san:position:) es el nombre REAL (el README dice «in:», pero es incorrecto)
            guard let analizada = Move(san: limpia, position: tablero.position),
                  var hecha = tablero.move(pieceAt: analizada.start, to: analizada.end)
            else {
                throw ErrorAjedrez.jugadaIlegal(medioMovimiento: medio, san: escrita, fen: fenAntes)
            }

            // Coronación: Board se queda en estado .promotion hasta completarla
            if case .promotion = tablero.state {
                guard let coronada = analizada.promotedPiece else {
                    throw ErrorAjedrez.faltaCoronacion(medioMovimiento: medio, san: escrita)
                }
                hecha = tablero.completePromotion(of: hecha, to: coronada.kind)
            } else if analizada.promotedPiece != nil {
                throw ErrorAjedrez.coronacionInesperada(medioMovimiento: medio, san: escrita)
            }

            guard hecha.san == limpia else {
                throw ErrorAjedrez.notacionNoCanonica(medioMovimiento: medio, escrita: escrita, esperada: hecha.san)
            }

            pasos.append(PasoLinea(jugada: convertir(hecha), posicion: convertir(tablero.position)))
        }

        return LineaReproducible(posicionInicial: convertir(inicial), pasos: pasos)
    }

    // MARK: - Lectura del texto

    static let resultados: Set<String> = ["1-0", "0-1", "1/2-1/2", "½-½", "*"]

    /// Separa las jugadas de un texto PGN sencillo: quita números («1.», «3...») y resultados.
    static func jugadasSAN(de pgn: String) -> [String] {
        var jugadas: [String] = []
        for trozo in pgn.split(whereSeparator: { $0.isWhitespace }) {
            let texto = String(trozo)
            if resultados.contains(texto) { continue }
            var resto = Substring(texto)
            let digitos = resto.prefix(while: { $0.isASCII && $0.isNumber })
            if !digitos.isEmpty, resto.dropFirst(digitos.count).first == "." {
                resto = resto.dropFirst(digitos.count).drop(while: { $0 == "." })
            }
            if !resto.isEmpty { jugadas.append(String(resto)) }
        }
        return jugadas
    }

    /// Quita las valoraciones del final («!», «?», «!?», «?!»…). Mantiene «+» y «#».
    static func quitarAnotaciones(_ san: String) -> String {
        var limpia = san
        while let ultimo = limpia.last, ultimo == "!" || ultimo == "?" {
            limpia.removeLast()
        }
        return limpia
    }

    // MARK: - Conversión ChessKit → Gambito

    static func posicionChessKit(fen: String) throws -> Position {
        if let motivo = ValidadorFEN.problema(en: fen) {
            throw ErrorAjedrez.fenInvalida(fen: fen, motivo: motivo)
        }
        guard let posicion = Position(fen: fen) else {
            throw ErrorAjedrez.fenInvalida(fen: fen, motivo: "ChessKit no ha podido leerla")
        }
        return posicion
    }

    static func convertir(_ color: Piece.Color) -> ColorPieza {
        color == .white ? .blancas : .negras
    }

    static func convertir(_ tipo: Piece.Kind) -> TipoPieza {
        switch tipo {
        case .king: .rey
        case .queen: .dama
        case .rook: .torre
        case .bishop: .alfil
        case .knight: .caballo
        case .pawn: .peon
        }
    }

    /// En Square.swift: file.number va de 1 a 8 y rank.value de 1 a 8.
    static func convertir(_ square: Square) -> Casilla {
        Casilla(columna: square.file.number - 1, fila: square.rank.value - 1)!
    }

    /// En Square.swift los casos van a1, b1 … h1, a2… (rawValue 0 = a1).
    static func square(_ casilla: Casilla) -> Square {
        Square(rawValue: casilla.indice)!
    }

    static func convertir(_ posicion: Position) -> Posicion {
        Posicion(
            piezas: posicion.pieces.map {
                PiezaColocada(color: convertir($0.color), tipo: convertir($0.kind), casilla: convertir($0.square))
            },
            turno: convertir(posicion.sideToMove),
            fen: posicion.fen
        )
    }

    static func convertir(_ move: Move) -> Jugada {
        var esCaptura = false
        var esEnroque = false
        switch move.result {
        case .move: break
        case .capture: esCaptura = true
        case .castle: esEnroque = true
        }

        let jaque: EstadoJaque = switch move.checkState {
        case .none: .ninguno
        case .check: .jaque
        case .checkmate: .mate
        case .stalemate: .ahogado
        }

        return Jugada(
            san: move.san,
            color: convertir(move.piece.color),
            tipo: convertir(move.piece.kind),
            origen: convertir(move.start),
            destino: convertir(move.end),
            esCaptura: esCaptura,
            esEnroque: esEnroque,
            coronacion: move.promotedPiece.map { convertir($0.kind) },
            jaque: jaque
        )
    }
}
