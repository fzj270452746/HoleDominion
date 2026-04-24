// AbyssVortexNode.swift
// HoleDominion - Base class for all black hole entities

import SpriteKit

class AbyssVortexNode: SKNode {

    // MARK: - Properties
    var girth: CGFloat {
        didSet { synchronizeDimensions() }
    }

    var absorptionRadius: CGFloat {
        girth * absorptionMultiplier
    }

    var absorptionMultiplier: CGFloat = CelestialConfig.baseAbsorptionMult

    // Score points earned this game
    var tallyScore: Int = 0

    // MARK: - Visual sub-nodes
    private(set) var coreSprite:    SKSpriteNode!
    private(set) var glowHalo:      SKShapeNode!
    private(set) var absorptionRim: SKShapeNode!

    // MARK: - Init
    init(girth: CGFloat, textureName: String, tintColor: UIColor) {
        self.girth = girth
        super.init()
        assembleVisuals(textureName: textureName, tintColor: tintColor)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Visual Assembly
    private func assembleVisuals(textureName: String, tintColor: UIColor) {
        // Outer glow halo
        glowHalo = SKShapeNode(circleOfRadius: girth * 1.25)
        glowHalo.fillColor   = tintColor.withAlphaComponent(0.18)
        glowHalo.strokeColor = tintColor.withAlphaComponent(0.55)
        glowHalo.lineWidth   = 2.5
        glowHalo.zPosition   = -1
        glowHalo.name = "glowHalo"
        addChild(glowHalo)

        // Core sprite using asset texture
        let tex = SKTexture(imageNamed: textureName)
        coreSprite = SKSpriteNode(texture: tex,
                                  size: CGSize(width: girth * 2, height: girth * 2))
        coreSprite.zPosition = 0
        addChild(coreSprite)

        // Absorption range ring (shown faintly)
        absorptionRim = SKShapeNode(circleOfRadius: absorptionRadius)
        absorptionRim.fillColor   = .clear
        absorptionRim.strokeColor = tintColor.withAlphaComponent(0.20)
        absorptionRim.lineWidth   = 1.0
        absorptionRim.zPosition   = -2
        addChild(absorptionRim)

        // Idle pulse animation on glow
        let expandGlow = SKAction.scale(to: 1.15, duration: 1.2)
        let shrinkGlow = SKAction.scale(to: 0.92, duration: 1.2)
        expandGlow.timingMode = .easeInEaseOut
        shrinkGlow.timingMode = .easeInEaseOut
        glowHalo.run(.repeatForever(.sequence([expandGlow, shrinkGlow])))
    }

    // MARK: - Sync size changes
    func synchronizeDimensions() {
        guard coreSprite != nil, glowHalo != nil, absorptionRim != nil else { return }
        let diameter = girth * 2
        coreSprite.size = CGSize(width: diameter, height: diameter)

        glowHalo.path        = CGPath(ellipseIn: CGRect(x: -girth * 1.25, y: -girth * 1.25,
                                                         width: girth * 2.5, height: girth * 2.5),
                                      transform: nil)
        absorptionRim.path   = CGPath(ellipseIn: CGRect(x: -absorptionRadius, y: -absorptionRadius,
                                                         width: absorptionRadius * 2, height: absorptionRadius * 2),
                                      transform: nil)
    }

    // MARK: - Expansion animation
    func animateExpansion(by delta: CGFloat, completion: (() -> Void)? = nil) {
        let newGirth = min(girth + delta, CelestialConfig.wandererMaxGirth)
        let bounceScale: CGFloat = 1.18
        let growAction = SKAction.scale(to: bounceScale, duration: 0.12)
        growAction.timingMode = .easeOut
        let settleAction = SKAction.scale(to: 1.0, duration: 0.18)
        settleAction.timingMode = .easeIn
        let seq = SKAction.sequence([growAction, settleAction])
        coreSprite.run(seq) { completion?() }
        girth = newGirth
    }

    // MARK: - Devour flash effect
    func emitDevourBurst(at worldPosition: CGPoint, in scene: SKScene, color: UIColor) {
        guard let emitter = SKEmitterNode(fileNamed: "DevourBurst") else {
            // Fallback: manual particles
            emitManualBurst(color: color)
            return
        }
        emitter.position = scene.convert(worldPosition, to: self)
        emitter.particleColor = color
        emitter.numParticlesToEmit = 20
        emitter.zPosition = ZStrata.particleLayer
        scene.addChild(emitter)
        emitter.run(.sequence([.wait(forDuration: 1.0), .removeFromParent()]))
    }

    func emitManualBurst(color: UIColor) {
        for _ in 0..<18 {
            let dot = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            dot.fillColor = color
            dot.strokeColor = .clear
            dot.zPosition = ZStrata.particleLayer
            addChild(dot)

            let angle = CGFloat.random(in: 0...(2 * .pi))
            let dist  = CGFloat.random(in: girth * 0.8...girth * 2.5)
            let dx = cos(angle) * dist
            let dy = sin(angle) * dist
            let move = SKAction.moveBy(x: dx, y: dy, duration: 0.5)
            let fade = SKAction.fadeOut(withDuration: 0.5)
            move.timingMode = .easeOut
            dot.run(.sequence([.group([move, fade]), .removeFromParent()]))
        }
    }

    // MARK: - Velocity for given girth
    func computeActualVelocity(base: CGFloat) -> CGFloat {
        let ratio = girth / CelestialConfig.wandererInitialGirth
        return base / sqrt(ratio)
    }

    // MARK: - Devour classification
    var devourCategory: String {
        if girth < CelestialConfig.smallHoleThreshold  { return "small" }
        if girth < CelestialConfig.mediumHoleThreshold { return "medium" }
        return "large"
    }

    func growthFromDevouring(_ target: AbyssVortexNode) -> CGFloat {
        switch target.devourCategory {
        case "small":  return CelestialConfig.devourSmallBonus
        case "medium": return CelestialConfig.devourMediumBonus
        default:       return CelestialConfig.devourLargeBonus
        }
    }
}
