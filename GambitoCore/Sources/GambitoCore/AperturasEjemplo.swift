// AperturasEjemplo.swift
// Las 5 aperturas de prueba de la Fase 1. Textos originales.
// Cada línea se valida en los tests (legal + notación correcta).

public struct AperturaEjemplo: Identifiable, Hashable, Sendable {
    public let id: String
    public let nombre: String
    public let nombreOriginal: String
    public let bando: ColorPieza        // para qué bando es la apertura
    public let pgn: String
    public let resumen: String

    /// Reproduce y valida la línea.
    public func linea() throws -> LineaReproducible {
        try MotorAjedrez.reproducir(pgn: pgn)
    }
}

public enum AperturasEjemplo {
    public static let todas: [AperturaEjemplo] = [
        AperturaEjemplo(
            id: "italiana",
            nombre: "Italiana · Giuoco Piano",
            nombreOriginal: "Italian Game",
            bando: .blancas,
            pgn: "1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5 4. c3 Nf6 5. d3 d6 6. O-O O-O",
            resumen: "El alfil de c4 apunta a f7, la casilla más delicada del enroque negro. Con c3 y d3 las blancas levantan un centro sólido y maniobran sin prisa antes de abrir el juego."
        ),
        AperturaEjemplo(
            id: "espanola-cerrada",
            nombre: "Española · Variante Cerrada",
            nombreOriginal: "Ruy Lopez: Closed",
            bando: .blancas,
            pgn: "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O Be7 6. Re1 b5 7. Bb3 d6 8. c3 O-O",
            resumen: "El alfil de b5 presiona al caballo que defiende e5. En la Cerrada los dos bandos enrocan, las negras ganan espacio con …b5 y empieza una lucha larga y estratégica por el centro."
        ),
        AperturaEjemplo(
            id: "siciliana-najdorf",
            nombre: "Siciliana · Najdorf",
            nombreOriginal: "Sicilian Defense: Najdorf Variation",
            bando: .negras,
            pgn: "1. e4 c5 2. Nf3 d6 3. d4 cxd4 4. Nxd4 Nf6 5. Nc3 a6 6. Be3 e5 7. Nb3 Be6",
            resumen: "Las negras cambian su peón c por el peón d blanco y se quedan con más peones en el centro. La jugada …a6 vigila b5 y deja abiertas varias ideas, como …e5 para ganar espacio."
        ),
        AperturaEjemplo(
            id: "gambito-dama-rehusado",
            nombre: "Gambito de Dama Rehusado · Ortodoxa",
            nombreOriginal: "Queen's Gambit Declined: Orthodox Defense",
            bando: .negras,
            pgn: "1. d4 d5 2. c4 e6 3. Nc3 Nf6 4. Bg5 Be7 5. e3 O-O 6. Nf3 Nbd7",
            resumen: "Las negras no aceptan el peón de c4: sostienen d5 con …e6, desarrollan con calma y enrocan pronto. Más adelante suelen buscar aire con …c5 o …e5."
        ),
        AperturaEjemplo(
            id: "caro-kann-clasica",
            nombre: "Caro-Kann · Clásica",
            nombreOriginal: "Caro-Kann Defense: Classical Variation",
            bando: .negras,
            pgn: "1. e4 c6 2. d4 d5 3. Nc3 dxe4 4. Nxe4 Bf5 5. Ng3 Bg6 6. h4 h6 7. Nf3 Nd7",
            resumen: "Con …c6 las negras preparan …d5 y sacan su alfil de casillas blancas a f5 antes de cerrar la cadena de peones. Posiciones sólidas, con pocas debilidades."
        )
    ]
}
