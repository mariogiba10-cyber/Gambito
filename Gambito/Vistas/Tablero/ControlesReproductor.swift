// ControlesReproductor.swift — botones, deslizador y lista de jugadas.

import SwiftUI
import GambitoCore

struct ControlesReproductor: View {
    let reproductor: ReproductorLinea
    @State private var valorDeslizador: Double = 0

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 26) {
                boton("backward.end.fill", etiqueta: "Ir al principio") { reproductor.alInicio() }
                boton("chevron.backward", etiqueta: "Jugada anterior") { reproductor.anterior() }
                boton(reproductor.reproduciendo ? "pause.fill" : "play.fill",
                      etiqueta: reproductor.reproduciendo ? "Pausar" : "Reproducir") {
                    reproductor.alternarReproduccion()
                }
                boton("chevron.forward", etiqueta: "Jugada siguiente") {
                    reproductor.detener()
                    reproductor.siguiente()
                }
                boton("forward.end.fill", etiqueta: "Ir al final") { reproductor.alFinal() }
            }
            .font(.title2)
            .padding(.horizontal, 22)
            .padding(.vertical, 12)
            .glassEffect()

            Slider(value: $valorDeslizador, in: 0...Double(max(reproductor.total, 1)), step: 1)
                .padding(.horizontal, 24)
                .accessibilityLabel("Avanzar o retroceder en la línea")
                .accessibilityValue("Paso \(reproductor.indice) de \(reproductor.total)")
        }
        .onAppear { valorDeslizador = Double(reproductor.indice) }
        .onChange(of: reproductor.indice) { _, nuevo in
            valorDeslizador = Double(nuevo)
        }
        .onChange(of: valorDeslizador) { _, nuevo in
            let paso = Int(nuevo.rounded())
            if paso != reproductor.indice {
                reproductor.detener()
                reproductor.ir(a: paso)
            }
        }
    }

    private func boton(_ icono: String, etiqueta: String, accion: @escaping @MainActor () -> Void) -> some View {
        Button(action: accion) {
            Image(systemName: icono)
                .frame(width: 40, height: 40)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(etiqueta)
    }
}

/// Jugadas en fila horizontal; la actual se resalta y se puede tocar cualquiera.
struct ListaJugadasView: View {
    let reproductor: ReproductorLinea
    let estilo: EstiloNotacion

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(Array(reproductor.linea.pasos.enumerated()), id: \.offset) { indice, paso in
                        let numero = reproductor.linea.numero(dePaso: indice)
                        if numero.deBlancas || indice == 0 {
                            Text(numero.deBlancas ? "\(numero.numero)." : "\(numero.numero)…")
                                .font(.callout.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                        Button {
                            reproductor.detener()
                            reproductor.ir(a: indice + 1)
                        } label: {
                            Text(Notacion.mostrar(paso.jugada.san, estilo: estilo))
                                .font(.system(.body, design: .serif).weight(.medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    indice + 1 == reproductor.indice ? Color.accentColor.opacity(0.35) : Color.white.opacity(0.07),
                                    in: .capsule
                                )
                        }
                        .buttonStyle(.plain)
                        .id(indice)
                        .accessibilityLabel("\(numero.numero), \(numero.deBlancas ? "blancas" : "negras"): \(Notacion.mostrar(paso.jugada.san, estilo: .letrasEspanol))")
                    }
                }
                .padding(.horizontal)
            }
            .onChange(of: reproductor.indice) { _, nuevo in
                withAnimation { proxy.scrollTo(max(nuevo - 1, 0), anchor: .center) }
            }
        }
    }
}
