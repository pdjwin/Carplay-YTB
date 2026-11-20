import Foundation
import UIKit

enum Log {

    private static let url: URL? = {
        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent("lite.log")
    }()

    private static let queue = DispatchQueue(
        label: "duocafari.diagnostics"
    )

    private static var started = false

    static func write(_ message: String) {

        queue.async {

            guard let url else { return }

            if !started {
                started = true

                try? "".write(
                    to: url,
                    atomically: true,
                    encoding: .utf8
                )
            }

            let timestamp = ISO8601DateFormatter().string(
                from: Date()
            )

            let line = "\(timestamp) \(message)\n"

            if let handle = try? FileHandle(
                forWritingTo: url
            ) {

                handle.seekToEndOfFile()
                handle.write(Data(line.utf8))
                try? handle.close()

            } else {

                try? line.write(
                    to: url,
                    atomically: true,
                    encoding: .utf8
                )
            }
        }
    }

    // MARK: - Display Information

    static func displayInfo(
        _ windowScene: UIWindowScene,
        name: String
    ) {

        guard Settings.displayDiagnostics else {
            return
        }

        let screen = windowScene.screen

        let points = screen.bounds.size
        let pixels = screen.nativeBounds.size

        let scale = screen.scale
        let nativeScale = screen.nativeScale

        let safeArea =
            windowScene.windows.first?.safeAreaInsets ?? .zero

        let orientation =
            windowScene.interfaceOrientation

        let info = """

        ========================================
        DUOCAFARI DISPLAY DIAGNOSTICS

        Name: \(name)

        Scene Role:
        \(windowScene.session.role.rawValue)

        Point Size:
        \(points.width) x \(points.height)

        Native Pixel Size:
        \(pixels.width) x \(pixels.height)

        Screen Scale:
        \(scale)

        Native Scale:
        \(nativeScale)

        Safe Area:
        Top: \(safeArea.top)
        Bottom: \(safeArea.bottom)
        Left: \(safeArea.left)
        Right: \(safeArea.right)

        Orientation:
        \(orientation.rawValue)

        User Interface Style:
        \(windowScene.traitCollection.userInterfaceStyle.rawValue)

        Display Gamut:
        \(screen.traitCollection.displayGamut.rawValue)

        ========================================
        """

        write(info)
    }
}
