import Foundation
import UIKit

enum Log {

    private static let url: URL? = {
        let dir = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first

        return dir?.appendingPathComponent("lite.log")
    }()

    private static let queue = DispatchQueue(
        label: "duocafari.log"
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

            let line =
                "\(Date().formatted(date: .omitted, time: .standard)) \(message)\n"

            if let handle = try? FileHandle(forWritingTo: url) {

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

    static func displayInfo(
        _ windowScene: UIWindowScene,
        name: String
    ) {

        let screen = windowScene.screen

        let pointSize = screen.bounds.size
        let pixelSize = screen.nativeBounds.size
        let scale = screen.scale

        let safeArea = windowScene.windows.first?.safeAreaInsets ?? .zero

        let orientation =
            windowScene.interfaceOrientation

        let info = """

        ===== DUO DISPLAY INFORMATION =====
        Name: \(name)
        Scene: \(windowScene.session.role.rawValue)

        Point Width: \(pointSize.width)
        Point Height: \(pointSize.height)

        Pixel Width: \(pixelSize.width)
        Pixel Height: \(pixelSize.height)

        Scale: \(scale)

        Safe Area Top: \(safeArea.top)
        Safe Area Bottom: \(safeArea.bottom)
        Safe Area Left: \(safeArea.left)
        Safe Area Right: \(safeArea.right)

        Orientation: \(orientation.rawValue)

        User Interface Style: \(windowScene.traitCollection.userInterfaceStyle.rawValue)

        Display Gamut: \(screen.traitCollection.displayGamut.rawValue)

        ===================================
        """

        write(info)
    }
}
