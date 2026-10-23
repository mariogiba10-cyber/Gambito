// swift-tools-version: 6.0
// Paquete local con la lógica de ajedrez de Gambito.
// La app solo depende de GambitoCore; GambitoCore es quien usa ChessKit.

import PackageDescription

let package = Package(
    name: "GambitoCore",
    platforms: [
        .iOS(.v18),    // la app pide iOS 26 (mayor): no hay conflicto
        .macOS(.v15)   // para ejecutar «swift test» en el Mac de GitHub
    ],
    products: [
        .library(name: "GambitoCore", targets: ["GambitoCore"])
    ],
    dependencies: [
        // Versión EXACTA: la que hemos leído (commit 44ef7a1a)
        .package(url: "https://github.com/chesskit-app/chesskit-swift.git", exact: "0.17.0")
    ],
    targets: [
        .target(
            name: "GambitoCore",
            dependencies: [.product(name: "ChessKit", package: "chesskit-swift")]
        ),
        .testTarget(
            name: "GambitoCoreTests",
            dependencies: [
                "GambitoCore",
                .product(name: "ChessKit", package: "chesskit-swift")
            ]
        )
    ]
)
