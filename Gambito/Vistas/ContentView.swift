// ContentView.swift
// Estructura principal: la barra de pestañas inferior.
// En iOS 26, TabView + Tab dibuja automáticamente la barra con Liquid Glass.

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Inicio", systemImage: "house.fill") {
                InicioView()
            }
            Tab("Explorar", systemImage: "magnifyingglass") {
                PantallaPendiente(titulo: "Explorar", icono: "magnifyingglass", fase: 2)
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

// Pantalla provisional para las pestañas que llegarán en fases futuras.
struct PantallaPendiente: View {
    let titulo: String     // texto grande
    let icono: String      // nombre del símbolo SF Symbols
    let fase: Int          // fase en la que se construirá

    var body: some View {
        ContentUnavailableView {
            Label(titulo, systemImage: icono)
        } description: {
            Text("Llegará en la Fase \(fase).")
        }
        .background(FondoGambito())
    }
}
