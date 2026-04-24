// VortexConstants.swift
// HoleDominion - Core layer: static identifiers and categories

import SpriteKit

// MARK: - Physics Bitmask Categories
struct PhysicsLineage {
    static let dormant:       UInt32 = 0
    static let wandererBody:  UInt32 = 0x1 << 0
    static let nebulonBody:   UInt32 = 0x1 << 1
    static let luminiteOrb:   UInt32 = 0x1 << 2
    static let rampartEdge:   UInt32 = 0x1 << 3
}

// MARK: - Z-position layers
struct ZStrata {
    static let cosmicBackdrop: CGFloat = -10
    static let starfieldLayer: CGFloat = -8
    static let gridOverlay:    CGFloat = -7
    static let luminiteLayer:  CGFloat = 0
    static let nebulonLayer:   CGFloat = 1
    static let wandererLayer:  CGFloat = 2
    static let particleLayer:  CGFloat = 3
    static let hudLayer:       CGFloat = 10
    static let overlayLayer:   CGFloat = 20
    static let dialogLayer:    CGFloat = 30
}

// MARK: - Node name tokens
struct NodeTokens {
    static let wandererIdent   = "wanderer_node"
    static let nebulonPrefix   = "nebulon_"
    static let luminitePrefix  = "luminite_"
    static let starDot         = "star_dot"
    static let cosmicGrid      = "cosmic_grid"
    static let absorptionRing  = "absorption_ring"
}

// MARK: - Palette
struct ChromaPalette {
    // Backgrounds
    static let deepVoid     = UIColor(hex: "#0D0D2B")
    static let voidMidtone  = UIColor(hex: "#1A1A4E")
    // Player / Accent
    static let auroraBlue   = UIColor(hex: "#4A90E2")
    static let violetCore   = UIColor(hex: "#7B2FBE")
    static let cyanPulse    = UIColor(hex: "#00D4FF")
    // AI
    static let emberstrike  = UIColor(hex: "#FF6B35")
    static let scarletEdge  = UIColor(hex: "#FF1744")
    // Orbs
    static let verdantSpark = UIColor(hex: "#A8FF78")
    static let aquaflux     = UIColor(hex: "#00E5FF")
    static let solargold    = UIColor(hex: "#FFD700")
    static let novaBurst    = UIColor(hex: "#FF9800")
    // UI
    static let crystalWhite = UIColor(hex: "#EAEDFF")
    static let dimGhost     = UIColor(hex: "#6B7AA1")
    static let successGreen = UIColor(hex: "#4CAF50")
    static let warningAmber = UIColor(hex: "#FFC107")
}

// MARK: - UIColor hex initializer
extension UIColor {
    convenience init(hex: String) {
        var hexStr = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexStr = hexStr.hasPrefix("#") ? String(hexStr.dropFirst()) : hexStr
        var rgb: UInt64 = 0
        Scanner(string: hexStr).scanHexInt64(&rgb)
        let r = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let g = CGFloat((rgb >>  8) & 0xFF) / 255.0
        let b = CGFloat( rgb        & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

// MARK: - Window helpers (iOS 14+ compatible)
extension UIApplication {
    var currentKeyWindow: UIWindow? {
        if #available(iOS 15.0, *) {
            return connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.keyWindow
        }
        return connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first
    }
}
