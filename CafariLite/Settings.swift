import Foundation

enum Settings {

    private static let defaults = UserDefaults.standard

    // MARK: - Existing CarPlay Settings

    static var carNativeResolution: Bool {
        get {
            if defaults.object(forKey: "carNativeResolution") == nil {
                return true
            }
            return defaults.bool(forKey: "carNativeResolution")
        }
        set {
            defaults.set(newValue, forKey: "carNativeResolution")
        }
    }

    static var debugBorder: Bool {
        get {
            return defaults.bool(forKey: "debugBorder")
        }
        set {
            defaults.set(newValue, forKey: "debugBorder")
        }
    }

    static var avoidSidebar: Bool {
        get {
            if defaults.object(forKey: "avoidSidebar") == nil {
                return true
            }
            return defaults.bool(forKey: "avoidSidebar")
        }
        set {
            defaults.set(newValue, forKey: "avoidSidebar")
        }
    }

    static var playOnlyWhenParked: Bool {
        get {
            if defaults.object(forKey: "playOnlyWhenParked") == nil {
                return true
            }
            return defaults.bool(forKey: "playOnlyWhenParked")
        }
        set {
            defaults.set(newValue, forKey: "playOnlyWhenParked")
        }
    }

    // MARK: - Duo Adaptive Layout

    /// 화면 크기에 따라 인터페이스를 자동 조정합니다.
    static var adaptiveLayout: Bool {
        get {
            if defaults.object(forKey: "adaptiveLayout") == nil {
                return true
            }
            return defaults.bool(forKey: "adaptiveLayout")
        }
        set {
            defaults.set(newValue, forKey: "adaptiveLayout")
        }
    }

    /// 툴바 표시 여부
    static var showToolbar: Bool {
        get {
            if defaults.object(forKey: "showToolbar") == nil {
                return true
            }
            return defaults.bool(forKey: "showToolbar")
        }
        set {
            defaults.set(newValue, forKey: "showToolbar")
        }
    }

    /// 화면 가장자리 여백
    static var displayMargin: Double {
        get {
            if defaults.object(forKey: "displayMargin") == nil {
                return 8.0
            }
            return defaults.double(forKey: "displayMargin")
        }
        set {
            defaults.set(newValue, forKey: "displayMargin")
        }
    }

    /// 툴바 크기 배율
    static var toolbarScale: Double {
        get {
            if defaults.object(forKey: "toolbarScale") == nil {
                return 1.0
            }
            return defaults.double(forKey: "toolbarScale")
        }
        set {
            defaults.set(newValue, forKey: "toolbarScale")
        }
    }

    /// 화면 진단 정보 기록
    static var displayDiagnostics: Bool {
        get {
            if defaults.object(forKey: "displayDiagnostics") == nil {
                return true
            }
            return defaults.bool(forKey: "displayDiagnostics")
        }
        set {
            defaults.set(newValue, forKey: "displayDiagnostics")
        }
    }

    // MARK: - Reset

    static func resetDuoSettings() {
        defaults.removeObject(forKey: "adaptiveLayout")
        defaults.removeObject(forKey: "showToolbar")
        defaults.removeObject(forKey: "displayMargin")
        defaults.removeObject(forKey: "toolbarScale")
        defaults.removeObject(forKey: "displayDiagnostics")
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let cafariLiteSettingsChanged =
        Notification.Name("CafariLiteSettingsChanged")
}
