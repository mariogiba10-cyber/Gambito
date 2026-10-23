// FichaDemoView.swift — ficha provisional de una apertura: tablero + reproductor.

import SwiftUI
import GambitoCore

extension EstiloNotacion {
    var nombreVisible: String {
        switch self {
        case .figurinas: "Figuritas (♘f3)"
        case .letrasEspanol: "Letras en español (Cf3)"
        case .letrasIngles: "Letras en inglés (Nf3)"
        }
    }
}

struct FichaDemoView: View {
    let apertura: AperturaEjemplo

    @State private var reproductor: ReproductorLinea?
    @State private var mensajeError: String?
    @State private var desdeNegras = false

    // Ajustes guardados en el iPhone (se mantienen al cerrar la app)
    @AppStorage("temaTablero") private var temaGuardado = TemaTablero.madera.rawValue
    @AppStorage("mostrarCoordenadas") private var mostrarCoordenadas = true
    @AppStorage("estiloNotacion") private var estiloGuardado = EstiloNotacion.figurinas.rawValue

    private var tema: TemaTablero { TemaTablero(rawValue: temaGuardado) ?? .madera }
    private var estilo: EstiloNotacion { EstiloNotacion(rawValue: estiloGuardado) ?? .figurinas }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                cabecera

                if let reproductor {
                    TableroView(
                        piezas: reproductor.piezas,
                        ultimaJugada: reproductor.jugadaActual,
                        casillaEnJaque: reproductor.casillaEnJaque,
                        tema: tema,
                        mostrarCoordenadas: mostrarCoordenadas,
                        desdeNegras: desdeNegras
                    )
                    .padding(.horizontal, 12)
                    .shadow(color: .black.opacity(0.45), radius: 16, y: 8)
                    .sensoryFeedback(.selection, trigger: reproductor.indice)

                    Text(textoEstado(reproductor))
                        .font(.system(.title3, design: .serif))
                        .contentTransition(.opacity)

                    ControlesReproductor(reproductor: reproductor)
                    ListaJugadasView(reproductor: reproductor, estilo: estilo)
                } else if let mensajeError {
                    Label(mensajeError, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                        .padding()
                }
            }
            .padding(.vertical)
        }
        .background(FondoGambito())
        .navigationTitle(apertura.nombre)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Tema del tablero", selection: $temaGuardado) {
                        ForEach(TemaTablero.allCases) { tema in
                            Text(tema.nombre).tag(tema.rawValue)
                        }
                    }
                    Picker("Notación", selection: $estiloGuardado) {
                        ForEach(EstiloNotacion.allCases, id: \.self) { estilo in
                            Text(estilo.nombreVisible).tag(estilo.rawValue)
                        }
                    }
                    Toggle("Coordenadas", isOn: $mostrarCoordenadas)
                    Button {
                        withAnimation(.snappy) { desdeNegras.toggle() }
                    } label: {
                        Label("Girar tablero", systemImage: "arrow.up.arrow.down")
                    }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
                .accessibilityLabel("Opciones del tablero")
            }
        }
        .onAppear(perform: cargar)
        .onDisappear { reproductor?.detener() }
    }

    private var cabecera: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(apertura.nombreOriginal)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(apertura.bando == .blancas ? "Para jugar con blancas" : "Para jugar con negras")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.accentColor)
            Text(apertura.resumen)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    /// Texto bajo el tablero: «3. ♗c4 · ¡Jaque!»
    private func textoEstado(_ reproductor: ReproductorLinea) -> String {
        guard let jugada = reproductor.jugadaActual else {
            return "Posición inicial"
        }
        let numero = reproductor.linea.numero(dePaso: reproductor.indice - 1)
        var texto = "\(numero.numero)\(numero.deBlancas ? "." : "…") \(Notacion.mostrar(jugada.san, estilo: estilo))"
        switch jugada.jaque {
        case .jaque: texto += " · ¡Jaque!"
        case .mate: texto += " · ¡Jaque mate!"
        case .ahogado: texto += " · Ahogado"
        case .ninguno: break
        }
        return texto
    }

    private func cargar() {
        guard reproductor == nil else { return }
        do {
            let linea = try apertura.linea()
            reproductor = ReproductorLinea(linea: linea)
            desdeNegras = apertura.bando == .negras   // las defensas se ven desde las negras
        } catch {
            mensajeError = "\(error)"
        }
    }
}
