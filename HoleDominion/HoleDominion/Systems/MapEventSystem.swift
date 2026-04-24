// MapEventSystem.swift
// HoleDominion - Manages random map events (energy storm, hole burst)

import SpriteKit

enum MapEventKind {
    case energyTempest
    case nebulonSurge
}

protocol MapEventDelegate: AnyObject {
    func mapEventDidTrigger(_ kind: MapEventKind)
    func mapEventDidEnd(_ kind: MapEventKind)
}

final class MapEventSystem {

    weak var delegate: MapEventDelegate?

    private var tempestCooldown:  TimeInterval = CelestialConfig.energyStormInterval
    private var surgeCooldown:    TimeInterval = CelestialConfig.holeBurstInterval
    private var tempestActive:    Bool = false
    private var tempestDuration:  TimeInterval = 0

    // Called each frame
    func tickEvents(deltaTime: TimeInterval) {
        // Energy tempest countdown
        tempestCooldown -= deltaTime
        if tempestCooldown <= 0, !tempestActive {
            tempestActive   = true
            tempestDuration = CelestialConfig.energyStormDuration
            tempestCooldown = CelestialConfig.energyStormInterval
            delegate?.mapEventDidTrigger(.energyTempest)
        }

        if tempestActive {
            tempestDuration -= deltaTime
            if tempestDuration <= 0 {
                tempestActive = false
                delegate?.mapEventDidEnd(.energyTempest)
            }
        }

        // Nebulon surge
        surgeCooldown -= deltaTime
        if surgeCooldown <= 0 {
            surgeCooldown = CelestialConfig.holeBurstInterval
            delegate?.mapEventDidTrigger(.nebulonSurge)
        }
    }

    func reset() {
        tempestCooldown = CelestialConfig.energyStormInterval
        surgeCooldown   = CelestialConfig.holeBurstInterval
        tempestActive   = false
        tempestDuration = 0
    }

    // Visual overlay shown in scene when event fires
    static func buildEventBannerNode(for kind: MapEventKind, in sceneSize: CGSize) -> SKNode {
        let container = SKNode()

        let bg = SKShapeNode(rectOf: CGSize(width: sceneSize.width * 0.8, height: 54),
                             cornerRadius: 14)
        switch kind {
        case .energyTempest:
            bg.fillColor   = UIColor(hex: "#FFD700").withAlphaComponent(0.88)
            bg.strokeColor = UIColor(hex: "#FF9800")
        case .nebulonSurge:
            bg.fillColor   = UIColor(hex: "#FF1744").withAlphaComponent(0.88)
            bg.strokeColor = UIColor(hex: "#FF6B35")
        }
        bg.lineWidth = 2
        bg.zPosition = 1
        container.addChild(bg)

        let label = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        label.fontSize = 18
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.zPosition = 2
        switch kind {
        case .energyTempest: label.text = "ENERGY TEMPEST!"
        case .nebulonSurge:  label.text = "🔴 NEBULON SURGE!"
        }
        container.addChild(label)

        // Animate in/out
        container.alpha = 0
        container.setScale(0.7)
        let appear = SKAction.group([
            .fadeIn(withDuration: 0.3),
            .scale(to: 1.0, duration: 0.3)
        ])
        let hold   = SKAction.wait(forDuration: 2.0)
        let vanish = SKAction.group([
            .fadeOut(withDuration: 0.4),
            .scale(to: 0.7, duration: 0.4)
        ])
        container.run(.sequence([appear, hold, vanish, .removeFromParent()]))

        return container
    }
}
