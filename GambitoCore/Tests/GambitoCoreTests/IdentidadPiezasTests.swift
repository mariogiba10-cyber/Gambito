// IdentidadPiezasTests.swift — las piezas conservan su identidad (para animarlas bien).

import XCTest
@testable import GambitoCore

final class IdentidadPiezasTests: XCTestCase {

    private func fotogramas(_ pgn: String, fen: String = MotorAjedrez.fenInicial) throws -> [[PiezaConID]] {
        IdentidadPiezas.encadenar(try MotorAjedrez.reproducir(pgn: pgn, desdeFEN: fen).posiciones)
    }

    private func pieza(en notacion: String, de fotograma: [PiezaConID]) -> PiezaConID? {
        fotograma.first { $0.casilla == Casilla(notacion) }
    }

    func testPeonQueAvanzaConservaSuIdentidad() throws {
        let f = try fotogramas("1. e4")
        let antes = try XCTUnwrap(pieza(en: "e2", de: f[0]))
        let despues = try XCTUnwrap(pieza(en: "e4", de: f[1]))
        XCTAssertEqual(antes.id, despues.id)
        XCTAssertEqual(Set(f[0].map(\.id)), Set(f[1].map(\.id)))
    }

    func testCapturaHaceDesaparecerLaPiezaComida() throws {
        let f = try fotogramas("1. e4 d5 2. exd5")
        let peonBlanco = try XCTUnwrap(pieza(en: "e2", de: f[0]))
        let peonNegro = try XCTUnwrap(pieza(en: "d7", de: f[0]))
        XCTAssertEqual(f[3].count, 31)
        XCTAssertEqual(pieza(en: "d5", de: f[3])?.id, peonBlanco.id)
        XCTAssertFalse(f[3].contains { $0.id == peonNegro.id })
    }

    func testEnroqueMueveReyYTorreSinCambiarIdentidad() throws {
        let f = try fotogramas("1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5 4. O-O")
        let rey = try XCTUnwrap(pieza(en: "e1", de: f[0]))
        let torre = try XCTUnwrap(pieza(en: "h1", de: f[0]))
        XCTAssertEqual(pieza(en: "g1", de: f[7])?.id, rey.id)
        XCTAssertEqual(pieza(en: "f1", de: f[7])?.id, torre.id)
    }

    func testCoronacionConservaLaIdentidadDelPeon() throws {
        let f = try fotogramas("1. b8=Q+", fen: "8/1P6/8/8/8/8/8/1k5K w - - 0 1")
        let peon = try XCTUnwrap(pieza(en: "b7", de: f[0]))
        let dama = try XCTUnwrap(pieza(en: "b8", de: f[1]))
        XCTAssertEqual(dama.id, peon.id)
        XCTAssertEqual(dama.tipo, .dama)
    }

    func testAlPasoEliminaElPeonCorrecto() throws {
        let f = try fotogramas("1. e4 d5 2. e5 f5 3. exf6")
        let peonBlanco = try XCTUnwrap(pieza(en: "e2", de: f[0]))
        let peonF = try XCTUnwrap(pieza(en: "f7", de: f[0]))
        XCTAssertEqual(pieza(en: "f6", de: f[5])?.id, peonBlanco.id)
        XCTAssertFalse(f[5].contains { $0.id == peonF.id })
    }
}
