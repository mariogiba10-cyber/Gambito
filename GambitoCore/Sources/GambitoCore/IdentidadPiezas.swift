// IdentidadPiezas.swift
// Para que SwiftUI ANIME las piezas, cada una necesita un número fijo (id)
// que la siga de casilla en casilla. Aquí se calculan esos ids para toda una línea.

/// Una pieza con identidad estable a lo largo de una línea.
public struct PiezaConID: Identifiable, Hashable, Sendable {
    public let id: Int
    public let color: ColorPieza
    public let tipo: TipoPieza
    public let casilla: Casilla

    public init(id: Int, color: ColorPieza, tipo: TipoPieza, casilla: Casilla) {
        self.id = id
        self.color = color
        self.tipo = tipo
        self.casilla = casilla
    }
}

public enum IdentidadPiezas {

    /// Devuelve, para cada posición, sus piezas con id.
    /// Se calcula siempre HACIA DELANTE, jugada a jugada, para que sea exacto.
    public static func encadenar(_ posiciones: [Posicion]) -> [[PiezaConID]] {
        guard let primera = posiciones.first else { return [] }

        var proximoID = 0
        var actuales: [PiezaConID] = []
        for pieza in primera.piezas {
            actuales.append(PiezaConID(id: proximoID, color: pieza.color, tipo: pieza.tipo, casilla: pieza.casilla))
            proximoID += 1
        }

        var fotogramas = [actuales]
        for posicion in posiciones.dropFirst() {
            actuales = siguiente(desde: actuales, hacia: posicion, proximoID: &proximoID)
            fotogramas.append(actuales)
        }
        return fotogramas
    }

    /// Reparte los ids de `anteriores` entre las piezas de `nueva`:
    /// 1. Misma pieza en la misma casilla → se queda quieta.
    /// 2. Mismo tipo y color → es la que se ha movido (también el rey y la torre al enrocar).
    /// 3. Mismo color y distinto tipo → coronación (el peón se convierte en dama).
    /// 4. Lo que sobra de `anteriores` ha sido capturado y desaparece.
    static func siguiente(desde anteriores: [PiezaConID], hacia nueva: Posicion, proximoID: inout Int) -> [PiezaConID] {
        var libres = anteriores
        var resultado: [PiezaConID] = []
        var pendientes: [PiezaColocada] = []

        for pieza in nueva.piezas {
            if let i = libres.firstIndex(where: { $0.casilla == pieza.casilla && $0.color == pieza.color && $0.tipo == pieza.tipo }) {
                resultado.append(libres.remove(at: i))
            } else {
                pendientes.append(pieza)
            }
        }

        emparejar(pendientes: &pendientes, libres: &libres, resultado: &resultado, exigirMismoTipo: true)
        emparejar(pendientes: &pendientes, libres: &libres, resultado: &resultado, exigirMismoTipo: false)

        // Por seguridad: si quedara alguna pieza sin pareja, recibe un id nuevo
        for pieza in pendientes {
            resultado.append(PiezaConID(id: proximoID, color: pieza.color, tipo: pieza.tipo, casilla: pieza.casilla))
            proximoID += 1
        }
        return resultado.sorted { $0.casilla < $1.casilla }
    }

    /// Empareja cada pieza pendiente con la pieza libre más cercana que cumpla el criterio.
    private static func emparejar(
        pendientes: inout [PiezaColocada],
        libres: inout [PiezaConID],
        resultado: inout [PiezaConID],
        exigirMismoTipo: Bool
    ) {
        var sinPareja: [PiezaColocada] = []
        for pieza in pendientes {
            let candidatas = libres.indices.filter { i in
                libres[i].color == pieza.color && (!exigirMismoTipo || libres[i].tipo == pieza.tipo)
            }
            let mejor = candidatas.min { a, b in
                let distanciaA = libres[a].casilla.distancia(a: pieza.casilla)
                let distanciaB = libres[b].casilla.distancia(a: pieza.casilla)
                return distanciaA != distanciaB ? distanciaA < distanciaB : libres[a].casilla < libres[b].casilla
            }
            if let mejor {
                let vieja = libres.remove(at: mejor)
                resultado.append(PiezaConID(id: vieja.id, color: pieza.color, tipo: pieza.tipo, casilla: pieza.casilla))
            } else {
                sinPareja.append(pieza)
            }
        }
        pendientes = sinPareja
    }
}
