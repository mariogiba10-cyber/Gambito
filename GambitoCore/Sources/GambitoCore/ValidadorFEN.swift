// ValidadorFEN.swift
// ChessKit 0.17.0 solo comprueba que la FEN tenga 6 campos (FENParser.swift).
// Aquí añadimos las comprobaciones básicas que nos faltan.

enum ValidadorFEN {
    /// Devuelve el problema encontrado, o nil si la FEN parece correcta.
    static func problema(en fen: String) -> String? {
        let campos = fen.split(separator: " ", omittingEmptySubsequences: false)
        guard campos.count == 6 else { return "debe tener 6 campos separados por un espacio" }

        // 1) Colocación: 8 filas de 8 casillas, un rey por bando, sin peones en las filas 1 y 8
        let filas = campos[0].split(separator: "/", omittingEmptySubsequences: false)
        guard filas.count == 8 else { return "la colocación debe tener 8 filas" }

        var reyesBlancos = 0
        var reyesNegros = 0
        for (i, fila) in filas.enumerated() {
            var casillas = 0
            for caracter in fila {
                if let n = caracter.wholeNumberValue, (1...8).contains(n) {
                    casillas += n
                } else if "pnbrqkPNBRQK".contains(caracter) {
                    casillas += 1
                    if caracter == "K" { reyesBlancos += 1 }
                    if caracter == "k" { reyesNegros += 1 }
                    if (i == 0 || i == 7) && (caracter == "p" || caracter == "P") {
                        return "hay un peón en la primera u octava fila"
                    }
                } else {
                    return "carácter no válido «\(caracter)»"
                }
            }
            guard casillas == 8 else { return "la fila \(8 - i) no suma 8 casillas" }
        }
        guard reyesBlancos == 1, reyesNegros == 1 else { return "debe haber exactamente un rey de cada color" }

        // 2) Turno, enroques, captura al paso y contadores
        guard campos[1] == "w" || campos[1] == "b" else { return "el turno debe ser w o b" }

        let enroques = campos[2]
        guard enroques == "-" || (!enroques.isEmpty && enroques.allSatisfy { "KQkq".contains($0) }) else {
            return "derechos de enroque no válidos"
        }

        let alPaso = campos[3]
        guard alPaso == "-" || (alPaso.count == 2 && "abcdefgh".contains(alPaso.first!) && (alPaso.last == "3" || alPaso.last == "6")) else {
            return "casilla de captura al paso no válida"
        }

        guard Int(campos[4]) != nil, let total = Int(campos[5]), total >= 1 else {
            return "contadores de jugadas no válidos"
        }
        return nil
    }
}
