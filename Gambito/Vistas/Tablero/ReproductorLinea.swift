// ReproductorLinea.swift — el «cerebro» del reproductor: en qué jugada estamos.

import SwiftUI
import Observation
import GambitoCore

@MainActor
@Observable
final class ReproductorLinea {
    let linea: LineaReproducible
    /// Piezas con identidad para cada paso (0 = posición inicial).
    let fotogramas: [[PiezaConID]]

    /// 0 = antes de la primera jugada · total = después de la última.
    private(set) var indice = 0
    private(set) var reproduciendo = false
    @ObservationIgnored private var tarea: Task<Void, Never>?

    init(linea: LineaReproducible) {
        self.linea = linea
        self.fotogramas = IdentidadPiezas.encadenar(linea.posiciones)
    }

    var total: Int { linea.pasos.count }
    var piezas: [PiezaConID] { fotogramas[indice] }
    var jugadaActual: Jugada? { indice > 0 ? linea.pasos[indice - 1].jugada : nil }
    var posicionActual: Posicion { indice > 0 ? linea.pasos[indice - 1].posicion : linea.posicionInicial }

    /// Rey en jaque (o en mate) tras la jugada actual.
    var casillaEnJaque: Casilla? {
        guard let jugada = jugadaActual, jugada.jaque == .jaque || jugada.jaque == .mate else { return nil }
        return posicionActual.rey(de: posicionActual.turno)
    }

    /// Salta a un paso con animación suave.
    func ir(a nuevoIndice: Int) {
        let destino = min(max(nuevoIndice, 0), total)
        guard destino != indice else { return }
        withAnimation(.snappy(duration: 0.32)) {
            indice = destino
        }
    }

    func siguiente() { ir(a: indice + 1) }
    func anterior() { detener(); ir(a: indice - 1) }
    func alInicio() { detener(); ir(a: 0) }
    func alFinal() { detener(); ir(a: total) }

    func alternarReproduccion() {
        if reproduciendo { detener() } else { reproducir() }
    }

    func detener() {
        tarea?.cancel()
        tarea = nil
        reproduciendo = false
    }

    /// Reproducción automática: una jugada cada 1,2 segundos.
    private func reproducir() {
        if indice >= total { ir(a: 0) }
        reproduciendo = true
        tarea = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1.2))
                guard let self, !Task.isCancelled else { return }
                if self.indice >= self.total {
                    self.reproduciendo = false
                    return
                }
                self.siguiente()
            }
        }
    }
}
