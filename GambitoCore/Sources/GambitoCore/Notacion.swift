// Notacion.swift
// Muestra las jugadas con figuritas (♘f3) o con letras españolas (Cf3).

public enum EstiloNotacion: String, CaseIterable, Hashable, Sendable {
    case figurinas, letrasEspanol, letrasIngles
}

public enum Notacion {

    /// Convierte una jugada en notación inglesa (la interna) al estilo elegido.
    public static func mostrar(_ san: String, estilo: EstiloNotacion) -> String {
        switch estilo {
        case .letrasIngles:
            san
        case .figurinas:
            reemplazar(san, por: ["K": "♔", "Q": "♕", "R": "♖", "B": "♗", "N": "♘"])
        case .letrasEspanol:
            reemplazar(san, por: ["K": "R", "Q": "D", "R": "T", "B": "A", "N": "C"])
        }
    }

    /// Solo las MAYÚSCULAS son piezas: las columnas van en minúscula y «O-O» no se toca.
    /// Se recorre carácter a carácter, así «R» (torre) → «T» no choca con «K» (rey) → «R».
    static func reemplazar(_ san: String, por tabla: [Character: String]) -> String {
        var resultado = ""
        for caracter in san {
            if let sustituto = tabla[caracter] {
                resultado += sustituto
            } else {
                resultado.append(caracter)
            }
        }
        return resultado
    }
}
