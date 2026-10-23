// AperturasEjemploTests.swift — las 5 líneas de ejemplo son legales y están bien escritas.

import XCTest
@testable import GambitoCore

final class AperturasEjemploTests: XCTestCase {

    func testTodasLasLineasSonLegalesYCanonicas() {
        for apertura in AperturasEjemplo.todas {
            XCTAssertNoThrow(try apertura.linea(), "Falla la línea de \(apertura.nombre)")
        }
    }

    func testNumeroDeMediosMovimientos() {
        let esperado = [
            "italiana": 12,
            "espanola-cerrada": 16,
            "siciliana-najdorf": 14,
            "gambito-dama-rehusado": 12,
            "caro-kann-clasica": 14
        ]
        for apertura in AperturasEjemplo.todas {
            XCTAssertEqual(try apertura.linea().pasos.count, esperado[apertura.id], apertura.nombre)
        }
    }

    func testIdentificadoresUnicos() {
        let ids = AperturasEjemplo.todas.map(\.id)
        XCTAssertEqual(ids.count, 5)
        XCTAssertEqual(Set(ids).count, ids.count)
    }
}
