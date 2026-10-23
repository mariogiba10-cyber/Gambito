// InicioView.swift — Inicio provisional: tablero con la posición inicial y versión.

import SwiftUI
import GambitoCore

struct InicioView: View {
    @AppStorage("temaTablero") private var temaGuardado = TemaTablero.madera.rawValue

    private var textoVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let compilacion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        return "Versión \(version) · compilación \(compilacion)"
    }

    /// Piezas de la posición inicial (calculadas con GambitoCore).
    private var piezasIniciales: [PiezaConID] {
        guard let posicion = try? MotorAjedrez.posicion(fen: MotorAjedrez.fenInicial) else { return [] }
        return IdentidadPiezas.encadenar([posicion]).first ?? []
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                TableroView(piezas: piezasIniciales, tema: TemaTablero(rawValue: temaGuardado) ?? .madera, mostrarCoordenadas: false)
                    .frame(maxWidth: 280)
                    .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
                    .padding(.top, 40)

                VStack(spacing: 8) {
                    Text("Gambito")
                        .font(.system(.largeTitle, design: .serif, weight: .bold))
                    Text("Tu biblioteca de ajedrez de bolsillo")
                        .font(.system(.title3, design: .serif))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Label("Fase 1 · tablero y reproductor", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .glassEffect()

                Text("Abre la pestaña Explorar para ver las cinco aperturas de ejemplo.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text(textoVersion)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .background(FondoGambito())
    }
}
