// InicioView.swift
// Pantalla de Inicio provisional: título, tablero decorativo y versión instalada.

import SwiftUI

struct InicioView: View {
    // Lee la versión y el nº de compilación del Info.plist que generó Xcode.
    // Así sabes exactamente qué compilación de GitHub Actions tienes instalada.
    private var textoVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let compilacion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        return "Versión \(version) · compilación \(compilacion)"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Tablero decorativo dibujado con Canvas (la misma técnica que usaremos para las flechas)
                TableroDecorativo()
                    .frame(maxWidth: 260)
                    .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
                    .padding(.top, 40)

                // Títulos en serif (New York); .largeTitle se adapta a Dynamic Type
                VStack(spacing: 8) {
                    Text("Gambito")
                        .font(.system(.largeTitle, design: .serif, weight: .bold))
                    Text("Tu biblioteca de ajedrez de bolsillo")
                        .font(.system(.title3, design: .serif))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Etiqueta con efecto Liquid Glass (iOS 26)
                Label("Fase 0 · cimientos listos", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .glassEffect()

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
