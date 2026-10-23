// Modelos.swift
// Tipos propios de Gambito. La app SOLO usa estos tipos;
// los de ChessKit se quedan dentro de GambitoCore (ver MotorAjedrez.swift).

/// Color de un bando.
public enum ColorPieza: String, CaseIterable, Hashable, Sendable {
    case blancas, negras

    /// El bando contrario.
    public var contrario: ColorPieza { self == .blancas ? .negras : .blancas }
}

/// Tipo de pieza.
public enum TipoPieza: String, CaseIterable, Hashable, Sendable {
    case rey, dama, torre, alfil, caballo, peon

    /// Nombre en español (para VoiceOver y textos).
    public var nombre: String {
        switch self {
        case .rey: "rey"
        case .dama: "dama"
        case .torre: "torre"
        case .alfil: "alfil"
        case .caballo: "caballo"
        case .peon: "peón"
        }
    }

    /// Letra inglesa de la notación (K, Q, R, B, N) y «P» para el peón.
    /// También forma el nombre de las imágenes de las piezas.
    public var letraIngles: String {
        switch self {
        case .rey: "K"
        case .dama: "Q"
        case .torre: "R"
        case .alfil: "B"
        case .caballo: "N"
        case .peon: "P"
        }
    }
}

/// Una casilla. columna: 0 = a … 7 = h · fila: 0 = fila 1 … 7 = fila 8.
public struct Casilla: Hashable, Comparable, Sendable, CustomStringConvertible {
    public let columna: Int
    public let fila: Int

    /// Devuelve nil si se sale del tablero.
    public init?(columna: Int, fila: Int) {
        guard (0..<8).contains(columna), (0..<8).contains(fila) else { return nil }
        self.columna = columna
        self.fila = fila
    }

    /// Crea una casilla desde su nombre, por ejemplo "e4". Devuelve nil si no es válido.
    public init?(_ notacion: String) {
        let caracteres = Array(notacion)
        guard caracteres.count == 2,
              let columna = Casilla.letras.firstIndex(of: caracteres[0]),
              let numero = caracteres[1].wholeNumberValue
        else { return nil }
        self.init(columna: columna, fila: numero - 1)
    }

    static let letras: [Character] = ["a", "b", "c", "d", "e", "f", "g", "h"]

    /// Las 64 casillas, de a1 a h8.
    public static let todas: [Casilla] = (0..<64).compactMap { Casilla(columna: $0 % 8, fila: $0 / 8) }

    public var letraColumna: String { String(Casilla.letras[columna]) }
    public var notacion: String { letraColumna + String(fila + 1) }
    /// a1 es oscura: las claras tienen columna + fila impar.
    public var esClara: Bool { (columna + fila) % 2 == 1 }
    /// Número de 0 (a1) a 63 (h8).
    public var indice: Int { fila * 8 + columna }

    /// Distancia en «pasos de rey» entre dos casillas.
    public func distancia(a otra: Casilla) -> Int {
        max(abs(columna - otra.columna), abs(fila - otra.fila))
    }

    public static func < (izquierda: Casilla, derecha: Casilla) -> Bool { izquierda.indice < derecha.indice }
    public var description: String { notacion }
}

/// Una pieza colocada en una casilla.
public struct PiezaColocada: Hashable, Sendable {
    public let color: ColorPieza
    public let tipo: TipoPieza
    public let casilla: Casilla

    public init(color: ColorPieza, tipo: TipoPieza, casilla: Casilla) {
        self.color = color
        self.tipo = tipo
        self.casilla = casilla
    }
}

/// Una posición completa: piezas, a quién le toca y su FEN.
public struct Posicion: Hashable, Sendable {
    public let piezas: [PiezaColocada]   // ordenadas de a1 a h8
    public let turno: ColorPieza
    public let fen: String

    public init(piezas: [PiezaColocada], turno: ColorPieza, fen: String) {
        self.piezas = piezas.sorted { $0.casilla < $1.casilla }
        self.turno = turno
        self.fen = fen
    }

    public func pieza(en casilla: Casilla) -> PiezaColocada? {
        piezas.first { $0.casilla == casilla }
    }

    public func rey(de color: ColorPieza) -> Casilla? {
        piezas.first { $0.tipo == .rey && $0.color == color }?.casilla
    }
}

/// Lo que provoca una jugada sobre el rey contrario.
public enum EstadoJaque: String, Hashable, Sendable {
    case ninguno, jaque, mate, ahogado
}

/// Una jugada ya comprobada por el motor de reglas.
public struct Jugada: Hashable, Sendable {
    public let san: String            // notación correcta, p. ej. "Nbd7" o "Qxf7#"
    public let color: ColorPieza
    public let tipo: TipoPieza        // en una coronación, es el peón
    public let origen: Casilla
    public let destino: Casilla
    public let esCaptura: Bool
    public let esEnroque: Bool
    public let coronacion: TipoPieza?
    public let jaque: EstadoJaque
}

/// Una jugada y la posición que deja.
public struct PasoLinea: Hashable, Sendable {
    public let jugada: Jugada
    public let posicion: Posicion
}

/// Una línea de jugadas ya validada, lista para reproducir.
public struct LineaReproducible: Hashable, Sendable {
    public let posicionInicial: Posicion
    public let pasos: [PasoLinea]

    /// Posición inicial + la posición tras cada jugada.
    public var posiciones: [Posicion] { [posicionInicial] + pasos.map(\.posicion) }

    /// Número de jugada para mostrar ("1.", "1…") según el paso (0 = primera jugada).
    public func numero(dePaso indice: Int) -> (numero: Int, deBlancas: Bool) {
        let campos = posicionInicial.fen.split(separator: " ")
        let primera = campos.count == 6 ? (Int(campos[5]) ?? 1) : 1
        let desfase = (posicionInicial.turno == .blancas ? 0 : 1) + indice
        return (primera + desfase / 2, desfase % 2 == 0)
    }
}
