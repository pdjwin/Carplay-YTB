import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {

        Log.write(
            "Phone scene willConnect role=\(session.role.rawValue)"
        )

        guard let windowScene = scene as? UIWindowScene else {

            Log.write("Invalid UIWindowScene")
            return
        }

        let window = UIWindow(windowScene: windowScene)

        window.rootViewController = BrowserViewController(
            showsStatus: true
        )

        window.makeKeyAndVisible()

        self.window = window

        Log.write(
            "Phone window initialized: \(window.bounds.size)"
        )

        Log.displayInfo(
            windowScene,
            name: "iPhone Display"
        )
    }

    func sceneDidBecomeActive(_ scene: UIScene) {

        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        Log.write("Phone scene became active")

        Log.displayInfo(
            windowScene,
            name: "iPhone Display Active"
        )
    }

    func windowScene(
        _ windowScene: UIWindowScene,
        didUpdate previousCoordinateSpace: UICoordinateSpace,
        interfaceOrientation previousInterfaceOrientation: UIInterfaceOrientation,
        traitCollection previousTraitCollection: UITraitCollection
    ) {

        Log.write("Display configuration changed")

        Log.displayInfo(
            windowScene,
            name: "iPhone Display Updated"
        )

        window?.rootViewController?.view.setNeedsLayout()
    }
}
