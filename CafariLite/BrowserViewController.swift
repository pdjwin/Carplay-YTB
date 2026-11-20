import UIKit
import WebKit

final class BrowserViewController: UIViewController, WKNavigationDelegate {

    private let home = URL(string: "https://m.youtube.com")!
    private let showsStatus: Bool

    private var webView: WKWebView!
    private var statusLabel: UILabel?
    private weak var toolbar: UIStackView?

    private var wasSigningIn = false
    private var loggedCarLayout = false
    private var drivingCover: UIView?

    private var toolbarHeightConstraint: NSLayoutConstraint?

    init(showsStatus: Bool) {
        self.showsStatus = showsStatus
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("not used")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        Log.write("viewDidLoad showsStatus=\(showsStatus)")

        view.backgroundColor = showsStatus
            ? UIColor(red: 0.07, green: 0.11, blue: 0.22, alpha: 1)
            : .black

        configureWebView()
        configureToolbar()
        configureNotifications()

        Log.write("loading \(home.absoluteString)")
        webView.load(URLRequest(url: home))
    }

    // MARK: - WebView

    private func configureWebView() {

        let configuration = WKWebViewConfiguration()

        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        webView = WKWebView(
            frame: .zero,
            configuration: configuration
        )

        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true

        webView.scrollView.contentInsetAdjustmentBehavior = .always
        webView.scrollView.bounces = true

        webView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(webView)
    }

    // MARK: - Toolbar

    private func configureToolbar() {

        let bar = makeToolbar()

        toolbar = bar

        bar.isHidden = showsStatus && !Settings.showToolbar

        bar.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(bar)

        if showsStatus {

            NSLayoutConstraint.activate([

                bar.topAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.topAnchor
                ),

                bar.leadingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor
                ),

                bar.trailingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor
                ),

                webView.topAnchor.constraint(
                    equalTo: bar.bottomAnchor
                ),

                webView.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor
                ),

                webView.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor
                ),

                webView.bottomAnchor.constraint(
                    equalTo: view.bottomAnchor
                )
            ])

        } else {

            bar.backgroundColor = UIColor.black.withAlphaComponent(0.45)
            bar.layer.cornerRadius = 10
            bar.clipsToBounds = true

            webView.translatesAutoresizingMaskIntoConstraints = true

            NSLayoutConstraint.activate([

                bar.topAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.topAnchor,
                    constant: 4
                ),

                bar.leadingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                    constant: 4
                )
            ])
        }
    }

    private func makeToolbar() -> UIStackView {

        let container = UIStackView()

        container.axis = .horizontal
        container.alignment = .center
        container.spacing = 12

        container.isLayoutMarginsRelativeArrangement = true

        container.layoutMargins = UIEdgeInsets(
            top: 6,
            left: 12,
            bottom: 6,
            right: 12
        )

        container.backgroundColor = .secondarySystemBackground

        func button(
            _ systemName: String,
            _ action: Selector
        ) -> UIButton {

            let button = UIButton(type: .system)

            let configuration = UIImage.SymbolConfiguration(
                pointSize: 19,
                weight: .medium
            )

            button.setImage(
                UIImage(
                    systemName: systemName,
                    withConfiguration: configuration
                ),
                for: .normal
            )

            button.addTarget(
                self,
                action: action,
                for: .touchUpInside
            )

            button.widthAnchor.constraint(
                greaterThanOrEqualToConstant: 36
            ).isActive = true

            button.heightAnchor.constraint(
                greaterThanOrEqualToConstant: 36
            ).isActive = true

            return button
        }

        container.addArrangedSubview(
            button("chevron.backward", #selector(goBack))
        )

        container.addArrangedSubview(
            button("chevron.forward", #selector(goForward))
        )

        container.addArrangedSubview(
            button("house", #selector(goHome))
        )

        container.addArrangedSubview(
            button("arrow.clockwise", #selector(reload))
        )

        if showsStatus {

            let cast = button("tv", #selector(sendToCar))
            cast.accessibilityLabel = "Send to car screen"

            container.addArrangedSubview(cast)

            let gear = button("gearshape", #selector(showSettings))
            gear.accessibilityLabel = "Settings"

            container.addArrangedSubview(gear)

            let label = UILabel()

            label.font = .preferredFont(forTextStyle: .footnote)
            label.textColor = .secondaryLabel
            label.textAlignment = .right
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.7
            label.numberOfLines = 1

            statusLabel = label

            container.addArrangedSubview(label)

            updateStatus()
        }

        return container
    }

    // MARK: - Responsive Layout

    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        if showsStatus {

            updatePhoneToolbarLayout()

        } else {

            layoutCarWebView()
        }
    }

    private func updatePhoneToolbarLayout() {

        guard let toolbar else { return }

        let width = view.bounds.width

        if width < 400 {

            toolbar.spacing = 4

            toolbar.layoutMargins = UIEdgeInsets(
                top: 4,
                left: 6,
                bottom: 4,
                right: 6
            )

        } else if width < 600 {

            toolbar.spacing = 8

            toolbar.layoutMargins = UIEdgeInsets(
                top: 5,
                left: 10,
                bottom: 5,
                right: 10
            )

        } else {

            toolbar.spacing = 14

            toolbar.layoutMargins = UIEdgeInsets(
                top: 6,
                left: 16,
                bottom: 6,
                right: 16
            )
        }
    }

    // MARK: - Browser Controls

    @objc private func goBack() {

        guard webView.canGoBack else { return }

        webView.goBack()
    }

    @objc private func goForward() {

        guard webView.canGoForward else { return }

        webView.goForward()
    }

    @objc private func reload() {

        webView.reload()
    }

    @objc private func goHome() {

        webView.load(URLRequest(url: home))
    }

    // MARK: - Settings

    @objc private func showSettings() {

        let sheet = UIAlertController(
            title: "Car screen",
            message: nil,
            preferredStyle: .actionSheet
        )

        let nativeOn = Settings.carNativeResolution

        sheet.addAction(
            UIAlertAction(
                title: (nativeOn ? "✓ " : "") +
                    "Use the car's own resolution",
                style: .default
            ) { _ in

                Settings.carNativeResolution = !nativeOn

                NotificationCenter.default.post(
                    name: .cafariLiteSettingsChanged,
                    object: nil
                )
            }
        )

        let borderOn = Settings.debugBorder

        sheet.addAction(
            UIAlertAction(
                title: (borderOn ? "✓ " : "") +
                    "Show the debug border",
                style: .default
            ) { _ in

                Settings.debugBorder = !borderOn

                NotificationCenter.default.post(
                    name: .cafariLiteSettingsChanged,
                    object: nil
                )
            }
        )

        let parkedOn = Settings.playOnlyWhenParked

        sheet.addAction(
            UIAlertAction(
                title: (parkedOn ? "✓ " : "") +
                    "Play only when parked",
                style: .default
            ) { _ in

                Settings.playOnlyWhenParked = !parkedOn

                NotificationCenter.default.post(
                    name: .cafariLiteSettingsChanged,
                    object: nil
                )
            }
        )

        let sidebarOn = Settings.avoidSidebar

        sheet.addAction(
            UIAlertAction(
                title: (sidebarOn ? "✓ " : "") +
                    "Keep clear of the sidebar",
                style: .default
            ) { _ in

                Settings.avoidSidebar = !sidebarOn

                NotificationCenter.default.post(
                    name: .cafariLiteSettingsChanged,
                    object: nil
                )
            }
        )

        sheet.addAction(
            UIAlertAction(
                title: "Done",
                style: .cancel
            )
        )

        sheet.popoverPresentationController?.sourceView = view

        sheet.popoverPresentationController?.sourceRect = CGRect(
            x: view.bounds.midX,
            y: 60,
            width: 1,
            height: 1
        )

        present(sheet, animated: true)
    }

    // MARK: - Send to Car

    @objc private func sendToCar() {

        guard let url = webView.url else { return }

        let destination = Self.playerURL(for: url) ?? url

        Log.write(
            "sendToCar \(url.absoluteString) -> \(destination.absoluteString)"
        )

        NotificationCenter.default.post(
            name: .cafariLiteSendToCar,
            object: nil,
            userInfo: ["url": destination]
        )

        let connected = UIApplication.shared.connectedScenes.contains {
            scene in

            scene.session.role == cafariLiteCarPlayRole
        }

        statusLabel?.text = connected
            ? "Sent to the car"
            : "No car screen to send to"
    }

    static func playerURL(for url: URL) -> URL? {

        guard let host = url.host?.lowercased() else {
            return nil
        }

        var videoID: String?

        if host.contains("youtu.be") {

            videoID = url.pathComponents.dropFirst().first

        } else if host.contains("youtube.com") {

            if url.path.hasPrefix("/shorts/") {

                videoID = url.pathComponents.dropFirst(2).first

            } else if let items = URLComponents(
                url: url,
                resolvingAgainstBaseURL: false
            )?.queryItems {

                videoID = items.first {
                    $0.name == "v"
                }?.value
            }
        }

        guard let id = videoID, !id.isEmpty else {
            return nil
        }

        return URL(
            string:
                "https://www.youtube.com/embed/\(id)?autoplay=1&playsinline=1&rel=0"
        )
    }

    // MARK: - Notifications

    private func configureNotifications() {

        if showsStatus {

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(carStateChanged),
                name: .cafariLiteCarConnected,
                object: nil
            )

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(carStateChanged),
                name: .cafariLiteCarDisconnected,
                object: nil
            )

        } else {

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(accountChanged),
                name: .cafariLiteAccountChanged,
                object: nil
            )

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(sendToCarRequested(_:)),
                name: .cafariLiteSendToCar,
                object: nil
            )

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(settingsChanged),
                name: .cafariLiteSettingsChanged,
                object: nil
            )

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(drivingStateChanged),
                name: CarGate.stateChanged,
                object: nil
            )

            if Settings.playOnlyWhenParked {
                CarGate.shared.start()
            }
        }
    }

    // MARK: - Navigation Errors

    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {

        showLoadFailure(error)
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {

        showLoadFailure(error)
    }

    private func showLoadFailure(_ error: Error) {

        Log.write("load FAILED: \(error.localizedDescription)")

        let label = UILabel()

        label.text = error.localizedDescription
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .body)

        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)

        NSLayoutConstraint.activate([

            label.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),

            label.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 24
            ),

            label.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -24
            )
        ])
    }

    // MARK: - Car State

    @objc private func carStateChanged() {

        updateStatus()
    }

    private func updateStatus() {

        let connected = UIApplication.shared.connectedScenes.contains {
            scene in

            scene.session.role == cafariLiteCarPlayRole
        }

        statusLabel?.text = connected
            ? "On the car screen"
            : "Car screen not connected"
    }

    // MARK: - Settings Changed

    @objc private func settingsChanged() {

        loggedCarLayout = false

        view.setNeedsLayout()

        if Settings.playOnlyWhenParked {

            CarGate.shared.start()

        } else {

            CarGate.shared.stop()
        }

        drivingStateChanged()
    }

    // MARK: - Driving State

    @objc private func drivingStateChanged() {

        let blocked =
            Settings.playOnlyWhenParked &&
            CarGate.shared.isMoving

        blocked ? showDrivingCover() : hideDrivingCover()
    }

    private func showDrivingCover() {

        webView.evaluateJavaScript(
            "document.querySelectorAll('video').forEach(v => v.pause())",
            completionHandler: nil
        )

        guard drivingCover == nil else { return }

        let cover = UIView()

        cover.backgroundColor = .black
        cover.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()

        label.text = "Paused while the car is moving"
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .headline)

        label.translatesAutoresizingMaskIntoConstraints = false

        cover.addSubview(label)
        view.addSubview(cover)

        NSLayoutConstraint.activate([

            cover.topAnchor.constraint(
                equalTo: view.topAnchor
            ),

            cover.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            cover.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            cover.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),

            label.centerXAnchor.constraint(
                equalTo: cover.centerXAnchor
            ),

            label.centerYAnchor.constraint(
                equalTo: cover.centerYAnchor
            ),

            label.leadingAnchor.constraint(
                greaterThanOrEqualTo: cover.leadingAnchor,
                constant: 16
            )
        ])

        drivingCover = cover

        Log.write("car gate: covered the car screen")
    }

    private func hideDrivingCover() {

        guard let cover = drivingCover else { return }

        cover.removeFromSuperview()

        drivingCover = nil

        Log.write("car gate: uncovered the car screen")
    }

    // MARK: - Account and Car Requests

    @objc private func sendToCarRequested(_ note: Notification) {

        guard let url = note.userInfo?["url"] as? URL else {
            return
        }

        webView.load(URLRequest(url: url))
    }

    @objc private func accountChanged() {

        webView.evaluateJavaScript(
            "!!document.querySelector('video') && !document.querySelector('video').paused"
        ) { [weak self] playing, _ in

            if (playing as? Bool) == true {
                return
            }

            self?.webView.reload()
        }
    }

    // MARK: - Display Diagnostics

    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        let screen = view.window?.windowScene?.screen

        Log.write(
            "viewDidAppear " +
            "view=\(view.bounds.size) " +
            "web=\(webView.bounds.size) " +
            "window=\(view.window?.bounds.size ?? .zero) " +
            "screen=\(screen?.bounds.size ?? .zero) " +
            "scale=\(screen?.scale ?? 0) " +
            "native=\(screen?.nativeBounds.size ?? .zero)"
        )

        if let windowScene = view.window?.windowScene {

            Log.displayInfo(
                windowScene,
                name: showsStatus ? "Phone Display" : "Car Display"
            )
        }
    }

    // MARK: - Car WebView Layout

    private func layoutCarWebView() {

        let bounds = Settings.avoidSidebar
            ? view.safeAreaLayoutGuide.layoutFrame
            : view.bounds

        guard bounds.width > 0, bounds.height > 0 else {
            return
        }

        webView.layer.borderColor = UIColor.systemGreen.cgColor

        webView.layer.borderWidth = Settings.debugBorder ? 3 : 0

        guard Settings.carNativeResolution,
              let screen = view.window?.windowScene?.screen else {

            webView.transform = .identity
            webView.frame = bounds

            return
        }

        let native = screen.nativeBounds.size

        let target = CGSize(
            width: max(native.width, native.height),
            height: min(native.width, native.height)
        )

        guard target.width > 0, target.height > 0 else {
            return
        }

        webView.transform = .identity

        webView.frame = CGRect(
            origin: .zero,
            size: target
        )

        webView.transform = CGAffineTransform(
            scaleX: bounds.width / target.width,
            y: bounds.height / target.height
        )

        webView.center = CGPoint(
            x: bounds.midX,
            y: bounds.midY
        )

        if !loggedCarLayout {

            loggedCarLayout = true

            Log.write(
                "car layout " +
                "native=\(target) " +
                "area=\(bounds) " +
                "window=\(view.bounds.size) " +
                "insets=\(view.safeAreaInsets) " +
                "scale=\(screen.scale) " +
                "sidebar=\(Settings.avoidSidebar)"
            )
        }
    }

    // MARK: - Web Navigation

    func webView(
        _ webView: WKWebView,
        didCommit navigation: WKNavigation!
    ) {

        Log.write(
            "didCommit \(webView.url?.absoluteString ?? "-")"
        )
    }

    func webView(
        _ webView: WKWebView,
        didFinish navigation: WKNavigation!
    ) {

        Log.write(
            "didFinish \(webView.url?.absoluteString ?? "-") " +
            "web=\(webView.bounds.size)"
        )

        guard showsStatus else { return }

        let host = webView.url?.host ?? ""

        if host.contains("accounts.google") ||
            host.contains("accounts.youtube") {

            wasSigningIn = true
            return
        }

        if wasSigningIn && host.contains("youtube") {

            wasSigningIn = false

            NotificationCenter.default.post(
                name: .cafariLiteAccountChanged,
                object: nil
            )
        }
    }
}
