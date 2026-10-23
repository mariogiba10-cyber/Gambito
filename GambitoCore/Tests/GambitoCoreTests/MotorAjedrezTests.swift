// MotorAjedrezTests.swift — reglas, FEN y notación.

import XCTest
import ChessKit
@testable import GambitoCore

final class MotorAjedrezTests: XCTestCase {

    func testPosicionInicialTiene32Piezas() throws {
        let posicion = try MotorAjedrez.posicion(fen: MotorAjedrez.fenInicial)
        XCTAssertEqual(posicion.piezas.count, 32)
        XCTAssertEqual(posicion.turno, .blancas)
        XCTAssertEqual(posicion.rey(de: .blancas)?.notacion, "e1")
        XCTAssertEqual(posicion.rey(de: .negras)?.notacion, "e8")
    }

    func testFENInvalidasSeRechazan() {
        let malas = [
            "hola",
            "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP w KQkq - 0 1",            // 7 filas
            "rnbqkbnr/pppppppp/9/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",   // fila con un 9
            "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKKNR w KQkq - 0 1",   // dos reyes blancos
            "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR x KQkq - 0 1",   // turno inválido
            "Pnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"    // peón en la octava
        ]
        for fen in malas {
            XCTAssertThrowsError(try MotorAjedrez.posicion(fen: fen), "Debería rechazar: \(fen)")
        }
    }

    func testMateDelPastorTerminaEnMate() throws {
        let linea = try MotorAjedrez.reproducir(pgn: "1. e4 e5 2. Bc4 Nc6 3. Qh5 Nf6 4. Qxf7#")
        XCTAssertEqual(linea.pasos.count, 7)
        XCTAssertEqual(linea.pasos.last?.jugada.jaque, .mate)
        XCTAssertEqual(linea.pasos.last?.jugada.esCaptura, true)
    }

    func testJugadaIlegalSeDetecta() {
        XCTAssertThrowsError(try MotorAjedrez.reproducir(pgn: "1. e4 e5 2. Ke3")) { error in
            guard let e = error as? ErrorAjedrez, case let .jugadaIlegal(medio, san, _) = e else {
                return XCTFail("Error inesperado: \(error)")
            }
            XCTAssertEqual(medio, 3)
            XCTAssertEqual(san, "Ke3")
        }
    }

    func testNotacionSinJaqueSeRechaza() {
        let fen = "8/1P6/8/8/8/8/8/1k5K w - - 0 1"
        XCTAssertThrowsError(try MotorAjedrez.reproducir(pgn: "1. b8=Q", desdeFEN: fen)) { error in
            guard let e = error as? ErrorAjedrez, case let .notacionNoCanonica(_, _, esperada) = e else {
                return XCTFail("Error inesperado: \(error)")
            }
            XCTAssertEqual(esperada, "b8=Q+")
        }
    }

    func testCoronacionConJaque() throws {
        let linea = try MotorAjedrez.reproducir(pgn: "1. b8=Q+", desdeFEN: "8/1P6/8/8/8/8/8/1k5K w - - 0 1")
        let jugada = try XCTUnwrap(linea.pasos.first?.jugada)
        XCTAssertEqual(jugada.coronacion, .dama)
        XCTAssertEqual(jugada.jaque, .jaque)
        XCTAssertEqual(linea.pasos.last?.posicion.pieza(en: Casilla("b8")!)?.tipo, .dama)
    }

    func testJugadaAmbiguaSinDesambiguarSeRechaza() {
        // Los dos caballos negros pueden ir a d7: lo correcto es «Nbd7»
        let pgn = "1. d4 d5 2. c4 e6 3. Nc3 Nf6 4. Bg5 Be7 5. e3 O-O 6. Nf3 Nd7"
        XCTAssertThrowsError(try MotorAjedrez.reproducir(pgn: pgn)) { error in
            guard let e = error as? ErrorAjedrez, case .notacionNoCanonica = e else {
                return XCTFail("Error inesperado: \(error)")
            }
        }
    }

    func testCapturaAlPaso() throws {
        let linea = try MotorAjedrez.reproducir(pgn: "1. e4 d5 2. e5 f5 3. exf6")
        let final = try XCTUnwrap(linea.pasos.last?.posicion)
        XCTAssertEqual(final.piezas.count, 31)
        XCTAssertNil(final.pieza(en: Casilla("f5")!))
        XCTAssertEqual(final.pieza(en: Casilla("f6")!)?.color, .blancas)
    }

    func testTokenizador() {
        XCTAssertEqual(
            MotorAjedrez.jugadasSAN(de: "1. e4 e5 2.Nf3 Nc6 3... a6 1-0"),
            ["e4", "e5", "Nf3", "Nc6", "a6"]
        )
    }

    func testAnotacionesSeIgnoran() throws {
        let linea = try MotorAjedrez.reproducir(pgn: "1. e4! e5?! 2. Nf3!?")
        XCTAssertEqual(linea.pasos.map(\.jugada.san), ["e4", "e5", "Nf3"])
    }

    func testNumeracionDesdeNegras() throws {
        let fen = "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"
        let linea = try MotorAjedrez.reproducir(pgn: "1... e5 2. Nf3", desdeFEN: fen)
        XCTAssertEqual(linea.numero(dePaso: 0).numero, 1)
        XCTAssertFalse(linea.numero(dePaso: 0).deBlancas)
        XCTAssertEqual(linea.numero(dePaso: 1).numero, 2)
        XCTAssertTrue(linea.numero(dePaso: 1).deBlancas)
    }

    func testCasillasCoincidenConChessKit() {
        // Comprueba nuestra suposición sobre el orden de Square en ChessKit
        for square in Square.allCases {
            let casilla = MotorAjedrez.convertir(square)
            XCTAssertEqual(casilla.notacion, square.notation)
            XCTAssertEqual(MotorAjedrez.square(casilla), square)
        }
    }
}
