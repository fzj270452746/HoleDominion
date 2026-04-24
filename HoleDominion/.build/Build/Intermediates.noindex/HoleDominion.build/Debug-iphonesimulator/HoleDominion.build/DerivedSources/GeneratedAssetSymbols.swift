import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
extension ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 11.0, macOS 10.7, tvOS 11.0, *)
extension ImageResource {

    /// The "ai_hole" asset catalog image resource.
    static let aiHole = ImageResource(name: "ai_hole", bundle: resourceBundle)

    /// The "energy_orb_large" asset catalog image resource.
    static let energyOrbLarge = ImageResource(name: "energy_orb_large", bundle: resourceBundle)

    /// The "energy_orb_medium" asset catalog image resource.
    static let energyOrbMedium = ImageResource(name: "energy_orb_medium", bundle: resourceBundle)

    /// The "energy_orb_small" asset catalog image resource.
    static let energyOrbSmall = ImageResource(name: "energy_orb_small", bundle: resourceBundle)

    /// The "energy_orb_super" asset catalog image resource.
    static let energyOrbSuper = ImageResource(name: "energy_orb_super", bundle: resourceBundle)

    /// The "event_energy_storm" asset catalog image resource.
    static let eventEnergyStorm = ImageResource(name: "event_energy_storm", bundle: resourceBundle)

    /// The "event_hole_burst_aura" asset catalog image resource.
    static let eventHoleBurstAura = ImageResource(name: "event_hole_burst_aura", bundle: resourceBundle)

    /// The "player_hole" asset catalog image resource.
    static let playerHole = ImageResource(name: "player_hole", bundle: resourceBundle)

    /// The "upgrade_absorption_range" asset catalog image resource.
    static let upgradeAbsorptionRange = ImageResource(name: "upgrade_absorption_range", bundle: resourceBundle)

    /// The "upgrade_growth_efficiency" asset catalog image resource.
    static let upgradeGrowthEfficiency = ImageResource(name: "upgrade_growth_efficiency", bundle: resourceBundle)

    /// The "upgrade_movement_speed" asset catalog image resource.
    static let upgradeMovementSpeed = ImageResource(name: "upgrade_movement_speed", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 10.13, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "ai_hole" asset catalog image.
    static var aiHole: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .aiHole)
#else
        .init()
#endif
    }

    /// The "energy_orb_large" asset catalog image.
    static var energyOrbLarge: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .energyOrbLarge)
#else
        .init()
#endif
    }

    /// The "energy_orb_medium" asset catalog image.
    static var energyOrbMedium: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .energyOrbMedium)
#else
        .init()
#endif
    }

    /// The "energy_orb_small" asset catalog image.
    static var energyOrbSmall: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .energyOrbSmall)
#else
        .init()
#endif
    }

    /// The "energy_orb_super" asset catalog image.
    static var energyOrbSuper: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .energyOrbSuper)
#else
        .init()
#endif
    }

    /// The "event_energy_storm" asset catalog image.
    static var eventEnergyStorm: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .eventEnergyStorm)
#else
        .init()
#endif
    }

    /// The "event_hole_burst_aura" asset catalog image.
    static var eventHoleBurstAura: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .eventHoleBurstAura)
#else
        .init()
#endif
    }

    /// The "player_hole" asset catalog image.
    static var playerHole: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .playerHole)
#else
        .init()
#endif
    }

    /// The "upgrade_absorption_range" asset catalog image.
    static var upgradeAbsorptionRange: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .upgradeAbsorptionRange)
#else
        .init()
#endif
    }

    /// The "upgrade_growth_efficiency" asset catalog image.
    static var upgradeGrowthEfficiency: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .upgradeGrowthEfficiency)
#else
        .init()
#endif
    }

    /// The "upgrade_movement_speed" asset catalog image.
    static var upgradeMovementSpeed: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .upgradeMovementSpeed)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "ai_hole" asset catalog image.
    static var aiHole: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .aiHole)
#else
        .init()
#endif
    }

    /// The "energy_orb_large" asset catalog image.
    static var energyOrbLarge: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .energyOrbLarge)
#else
        .init()
#endif
    }

    /// The "energy_orb_medium" asset catalog image.
    static var energyOrbMedium: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .energyOrbMedium)
#else
        .init()
#endif
    }

    /// The "energy_orb_small" asset catalog image.
    static var energyOrbSmall: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .energyOrbSmall)
#else
        .init()
#endif
    }

    /// The "energy_orb_super" asset catalog image.
    static var energyOrbSuper: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .energyOrbSuper)
#else
        .init()
#endif
    }

    /// The "event_energy_storm" asset catalog image.
    static var eventEnergyStorm: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .eventEnergyStorm)
#else
        .init()
#endif
    }

    /// The "event_hole_burst_aura" asset catalog image.
    static var eventHoleBurstAura: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .eventHoleBurstAura)
#else
        .init()
#endif
    }

    /// The "player_hole" asset catalog image.
    static var playerHole: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .playerHole)
#else
        .init()
#endif
    }

    /// The "upgrade_absorption_range" asset catalog image.
    static var upgradeAbsorptionRange: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .upgradeAbsorptionRange)
#else
        .init()
#endif
    }

    /// The "upgrade_growth_efficiency" asset catalog image.
    static var upgradeGrowthEfficiency: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .upgradeGrowthEfficiency)
#else
        .init()
#endif
    }

    /// The "upgrade_movement_speed" asset catalog image.
    static var upgradeMovementSpeed: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .upgradeMovementSpeed)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
@available(watchOS, unavailable)
extension ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 11.0, macOS 10.7, tvOS 11.0, *)
@available(watchOS, unavailable)
extension ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

// MARK: - Backwards Deployment Support -

/// A color resource.
struct ColorResource: Swift.Hashable, Swift.Sendable {

    /// An asset catalog color resource name.
    fileprivate let name: Swift.String

    /// An asset catalog color resource bundle.
    fileprivate let bundle: Foundation.Bundle

    /// Initialize a `ColorResource` with `name` and `bundle`.
    init(name: Swift.String, bundle: Foundation.Bundle) {
        self.name = name
        self.bundle = bundle
    }

}

/// An image resource.
struct ImageResource: Swift.Hashable, Swift.Sendable {

    /// An asset catalog image resource name.
    fileprivate let name: Swift.String

    /// An asset catalog image resource bundle.
    fileprivate let bundle: Foundation.Bundle

    /// Initialize an `ImageResource` with `name` and `bundle`.
    init(name: Swift.String, bundle: Foundation.Bundle) {
        self.name = name
        self.bundle = bundle
    }

}

#if canImport(AppKit)
@available(macOS 10.13, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// Initialize a `NSColor` with a color resource.
    convenience init(resource: ColorResource) {
        self.init(named: NSColor.Name(resource.name), bundle: resource.bundle)!
    }

}

protocol _ACResourceInitProtocol {}
extension AppKit.NSImage: _ACResourceInitProtocol {}

@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension _ACResourceInitProtocol {

    /// Initialize a `NSImage` with an image resource.
    init(resource: ImageResource) {
        self = resource.bundle.image(forResource: NSImage.Name(resource.name))! as! Self
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// Initialize a `UIColor` with a color resource.
    convenience init(resource: ColorResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}

@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// Initialize a `UIImage` with an image resource.
    convenience init(resource: ImageResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

    /// Initialize a `Color` with a color resource.
    init(_ resource: ColorResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Image {

    /// Initialize an `Image` with an image resource.
    init(_ resource: ImageResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}
#endif