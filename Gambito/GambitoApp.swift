// GambitoApp.swift
// Punto de entrada: lo primero que ejecuta iOS al abrir Gambito.

import SwiftUI

@main                                      // @main = "la app empieza aquí"
struct GambitoApp: App {
    var body: some Scene {
        WindowGroup {                      // la ventana principal
            ContentView()
                .preferredColorScheme(.dark)   // tema oscuro por defecto (en la Fase 7 será un ajuste)
        }
    }
}
