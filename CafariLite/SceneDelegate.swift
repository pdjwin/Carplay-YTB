import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // MARK: - Connect

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

        let window = UIWindow(
            windowScene: windowScene
        )

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
            name: "DuoCafari Phone Display"
        )
    }

    // MARK: - Active

    func sceneDidBecomeActive(_ scene: UIScene) {

        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        Log.write("Phone scene became active")

        Log.displayInfo(
            windowScene,
            name: "DuoCafari Active Display"
        )
    }

    // MARK: - Background

    func sceneDidEnterBackground(_ scene: UIScene) {

        Log.write("Phone scene entered background")
    }

    // MARK: - Display Update

    func windowScene(
        _ windowScene: UIWindowScene,
        didUpdate previousCoordinateSpace: UICoordinateSpace,
        interfaceOrientation previousInterfaceOrientation: UIInterfaceOrientation,
        traitCollection previousTraitCollection: UITraitCollection
    ) {

        Log.write("Phone display configuration changed")

        Log.displayInfo(
            windowScene,
            name: "DuoCafari Updated Display"
        )

        window?.rootViewController?.view.setNeedsLayout()
    }
}
