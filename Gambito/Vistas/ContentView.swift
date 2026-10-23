// ContentView.swift — barra de pestañas (Liquid Glass automático en iOS 26).

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Inicio", systemImage: "house.fill") {
                InicioView()
            }
            Tab("Explorar", systemImage: "magnifyingglass") {
                ExplorarDemoView()
            }
            Tab("Entrenar", systemImage: "target") {
                PantallaPendiente(titulo: "Entrenar", icono: "target", fase: 5)
            }
            Tab("Repertorio", systemImage: "star.fill") {
                PantallaPendiente(titulo: "Mi repertorio", icono: "star.fill", fase: 5)
            }
            Tab("Ajustes", systemImage: "gearshape.fill") {
                PantallaPendiente(titulo: "Ajustes", icono: "gearshape.fill", fase: 7)
            }
        }
    }
}

/// Pantalla provisional para las pestañas de fases futuras.
struct PantallaPendiente: View {
    let titulo: String
    let icono: String
    let fase: Int

    var body: some View {
        ContentUnavailableView {
            Label(titulo, systemImage: icono)
        } description: {
            Text("Llegará en la Fase \(fase).")
        }
        .background(FondoGambito())
    }
}
