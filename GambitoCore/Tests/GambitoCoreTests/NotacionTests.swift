// NotacionTests.swift — figuritas y letras españolas.

import XCTest
@testable import GambitoCore

final class NotacionTests: XCTestCase {

    func testFigurinas() {
        XCTAssertEqual(Notacion.mostrar("Nf3", estilo: .figurinas), "♘f3")
        XCTAssertEqual(Notacion.mostrar("Qxf7#", estilo: .figurinas), "♕xf7#")
        XCTAssertEqual(Notacion.mostrar("exd5", estilo: .figurinas), "exd5")
        XCTAssertEqual(Notacion.mostrar("O-O", estilo: .figurinas), "O-O")
        XCTAssertEqual(Notacion.mostrar("b8=Q+", estilo: .figurinas), "b8=♕+")
    }

    func testLetrasEnEspanol() {
        XCTAssertEqual(Notacion.mostrar("Nbd7", estilo: .letrasEspanol), "Cbd7")
        XCTAssertEqual(Notacion.mostrar("Rxe1+", estilo: .letrasEspanol), "Txe1+")
        XCTAssertEqual(Notacion.mostrar("Kf1", estilo: .letrasEspanol), "Rf1")
        XCTAssertEqual(Notacion.mostrar("Bb5", estilo: .letrasEspanol), "Ab5")
    }
}
