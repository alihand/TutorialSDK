//
//  TutorialFonts.swift
//  TutorialView
//
//  Created by Ali Han DEMIR on 19.08.2025.
//

import UIKit
import CoreText

public enum TutorialFonts {
    // Lazily runs exactly once in a thread-safe way
    private static let _registerOnce: Void = {
        let fontFiles = [
            "TTNormsPro-Medium",
            "TTNormsPro-DemiBold"
        ]
        fontFiles.forEach { registerFont(named: $0, ext: "otf") }
    }()

    // Call this anywhere; it just touches the once token
    @inline(__always)
    public static func registerIfNeeded() {
        _ = _registerOnce
    }

    // MARK: - Font helpers
    public static func medium(_ size: CGFloat) -> UIFont {
        registerIfNeeded()
        return UIFont(name: "TTNormsPro-Medium", size: size) ?? .systemFont(ofSize: size, weight: .medium)
    }

    public static func demiBold(_ size: CGFloat) -> UIFont {
        registerIfNeeded()
        return UIFont(name: "TTNormsPro-DemiBold", size: size)
            ?? .systemFont(ofSize: size, weight: .semibold)
    }

    // MARK: - Registration
    private static func registerFont(named name: String, ext: String) {
        guard let url = Bundle.module.url(forResource: name, withExtension: ext),
              let provider = CGDataProvider(url: url as CFURL),
              let cgFont = CGFont(provider) else {
            print("TutorialFonts: \(name).\(ext) not found in Bundle.module")
            return
        }
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(cgFont, &error) {
            let msg = (error?.takeUnretainedValue() as Error?)?.localizedDescription ?? "unknown"
            if !msg.lowercased().contains("already registered") {
                print("TutorialFonts: failed to register \(name): \(msg)")
            }
        }
    }
}
