// ExplorarDemoView.swift — lista provisional con las 5 aperturas de ejemplo.

import SwiftUI
import GambitoCore

struct ExplorarDemoView: View {
    var body: some View {
        NavigationStack {
            List(AperturasEjemplo.todas) { apertura in
                NavigationLink {
                    FichaDemoView(apertura: apertura)
                } label: {
                    FilaApertura(apertura: apertura)
                }
                .listRowBackground(Color.white.opacity(0.05))
            }
            .scrollContentBackground(.hidden)
            .background(FondoGambito())
            .navigationTitle("Explorar")
        }
    }
}

/// Fila con mini-tablero de la posición final de la línea.
struct FilaApertura: View {
    let apertura: AperturaEjemplo
    @State private var piezasFinales: [PiezaConID] = []
    @AppStorage("temaTablero") private var temaGuardado = TemaTablero.madera.rawValue

    var body: some View {
        HStack(spacing: 14) {
            TableroView(piezas: piezasFinales, tema: TemaTablero(rawValue: temaGuardado) ?? .madera, mostrarCoordenadas: false)
                .frame(width: 64, height: 64)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(apertura.nombre)
                    .font(.system(.headline, design: .serif))
                Text(apertura.nombreOriginal)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(apertura.bando == .blancas ? "Para blancas" : "Para negras")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
            }
        }
        .padding(.vertical, 6)
        .onAppear {
            if piezasFinales.isEmpty, let linea = try? apertura.linea(), let ultima = linea.posiciones.last {
                piezasFinales = IdentidadPiezas.encadenar([ultima]).first ?? []
            }
        }
    }
}
