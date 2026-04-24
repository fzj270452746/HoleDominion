// LuminiteOrbNode.swift
// HoleDominion - Energy orb collectible

import SpriteKit

enum OrbRank: Int, CaseIterable {
    case smolSpore  = 0
    case midSpore   = 1
    case grandSpore = 2
    case apexSpore  = 3

    var textureName: String {
        switch self {
        case .smolSpore:  return "energy_orb_small"
        case .midSpore:   return "energy_orb_medium"
        case .grandSpore: return "energy_orb_large"
        case .apexSpore:  return "energy_orb_super"
        }
    }

    var girthGrant: CGFloat {
        switch self {
        case .smolSpore:  return CelestialConfig.OrbGrowth.smolSpore.rawValue
        case .midSpore:   return CelestialConfig.OrbGrowth.midSpore.rawValue
        case .grandSpore: return CelestialConfig.OrbGrowth.grandSpore.rawValue
        case .apexSpore:  return CelestialConfig.OrbGrowth.apexSpore.rawValue
        }
    }

    var visualRadius: CGFloat {
        switch self {
        case .smolSpore:  return 7
        case .midSpore:   return 10
        case .grandSpore: return 14
        case .apexSpore:  return 19
        }
    }

    var glowColor: UIColor {
        switch self {
        case .smolSpore:  return ChromaPalette.verdantSpark
        case .midSpore:   return ChromaPalette.aquaflux
        case .grandSpore: return ChromaPalette.solargold
        case .apexSpore:  return ChromaPalette.novaBurst
        }
    }

    var pointValue: Int {
        switch self {
        case .smolSpore:  return 1
        case .midSpore:   return 3
        case .grandSpore: return 8
        case .apexSpore:  return 20
        }
    }

    // Spawn by weighted random
    static func randomByWeight() -> OrbRank {
        let roll = Int.random(in: 1...100)
        switch roll {
        case 1...CelestialConfig.smolWeight:                                    return .smolSpore
        case (CelestialConfig.smolWeight + 1)...(CelestialConfig.smolWeight + CelestialConfig.midWeight): return .midSpore
        case (CelestialConfig.smolWeight + CelestialConfig.midWeight + 1)...(CelestialConfig.smolWeight + CelestialConfig.midWeight + CelestialConfig.grandWeight): return .grandSpore
        default: return .apexSpore
        }
    }
}

// MARK: -

final class LuminiteOrbNode: SKNode {

    let orbRank: OrbRank
    private var spriteNode: SKSpriteNode!
    private var glowNode:   SKShapeNode!
    var isConsumed: Bool = false

    // MARK: - Init
    init(rank: OrbRank) {
        self.orbRank = rank
        super.init()
        name = "\(NodeTokens.luminitePrefix)\(rank.rawValue)"
        zPosition = ZStrata.luminiteLayer
        assembleVisuals()
        animateFloat()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Build visuals
    private func assembleVisuals() {
        let r = orbRank.visualRadius

        // Glow halo
        glowNode = SKShapeNode(circleOfRadius: r * 1.6)
        glowNode.fillColor   = orbRank.glowColor.withAlphaComponent(0.22)
        glowNode.strokeColor = orbRank.glowColor.withAlphaComponent(0.5)
        glowNode.lineWidth   = 1.5
        glowNode.zPosition   = -1
        addChild(glowNode)

        // Core sprite
        let tex = SKTexture(imageNamed: orbRank.textureName)
        spriteNode = SKSpriteNode(texture: tex,
                                   size: CGSize(width: r * 2, height: r * 2))
        spriteNode.zPosition = 0
        addChild(spriteNode)
    }

    // MARK: - Idle float animation
    private func animateFloat() {
        let up   = SKAction.moveBy(x: 0, y: 4, duration: 0.9)
        let down = SKAction.moveBy(x: 0, y: -4, duration: 0.9)
        up.timingMode   = .easeInEaseOut
        down.timingMode = .easeInEaseOut

        let glowExpand = SKAction.scale(to: 1.2, duration: 0.9)
        let glowShrink = SKAction.scale(to: 0.85, duration: 0.9)
        glowExpand.timingMode = .easeInEaseOut
        glowShrink.timingMode = .easeInEaseOut

        spriteNode.run(.repeatForever(.sequence([up, down])))
        glowNode.run(.repeatForever(.sequence([glowExpand, glowShrink])))
    }

    // MARK: - Absorption animation
    func playAbsorptionAnimation(toward target: CGPoint, completion: @escaping () -> Void) {
        isConsumed = true
        let shrink = SKAction.scale(to: 0.1, duration: 0.22)
        let move   = SKAction.move(to: convert(target, from: parent!), duration: 0.22)
        shrink.timingMode = .easeIn
        let group = SKAction.group([shrink, move])
        run(.sequence([group, .removeFromParent()])) { completion() }
    }
}
