// DuoCafari Settings
// Based on Cafari Lite
// Original project: https://github.com/rPlayAI/cafari-lite

import Foundation
import UIKit

enum Settings {

    private static let defaults = UserDefaults.standard

    // MARK: - CarPlay Settings

    /// 차량 화면의 네이티브 해상도 사용
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

    /// 차량 화면 디버그 테두리
    static var debugBorder: Bool {
        get {
            defaults.bool(forKey: "debugBorder")
        }
        set {
            defaults.set(newValue, forKey: "debugBorder")
        }
    }

    /// 차량 사이드바 영역 회피
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

    /// 정차 상태에서만 재생
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

    // MARK: - Duo Display Settings

    /// 화면 크기에 따른 자동 UI 조정
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

    /// 브라우저 툴바 표시
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

    /// 화면 여백
    static var displayMargin: Double {
        get {
            if defaults.object(forKey: "displayMargin") == nil {
                return 8
            }

            return defaults.double(forKey: "displayMargin")
        }
        set {
            defaults.set(newValue, forKey: "displayMargin")
        }
    }

    /// 브라우저 툴바 크기
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

    /// 화면 정보 로그 기록
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
