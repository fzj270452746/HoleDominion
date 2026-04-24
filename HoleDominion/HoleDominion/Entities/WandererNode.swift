// WandererNode.swift
// HoleDominion - Player-controlled black hole

import SpriteKit

final class WandererNode: AbyssVortexNode {

    // MARK: - Control
    var trajectoryTarget: CGPoint?          // where the player is touching
    var isTraversing:     Bool = false

    // MARK: - Upgrade bonuses (applied from AscendantUpgradeSystem)
    var velocityBonus:    CGFloat = 0        // flat addition to base velocity
    var absorptionBonus:  CGFloat = 0        // extra multiplier on absorption radius
    var growthBonusRate:  CGFloat = 1.0      // multiplier on all girth gains

    // MARK: - Lifecycle
    init(girth: CGFloat = CelestialConfig.wandererInitialGirth) {
        super.init(girth: girth,
                   textureName: "player_hole",
                   tintColor: ChromaPalette.auroraBlue)
        name = NodeTokens.wandererIdent
        zPosition = ZStrata.wandererLayer
        applyAbsorptionBonus()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Apply upgrade modifiers
    func applyAbsorptionBonus() {
        absorptionMultiplier = CelestialConfig.baseAbsorptionMult + absorptionBonus
        synchronizeDimensions()
    }

    // MARK: - Movement update (called each frame)
    func navigateFrame(deltaTime: CGFloat, mapBounds: CGRect) {
        guard isTraversing, let target = trajectoryTarget else { return }

        let velocity = computeActualVelocity(base: CelestialConfig.wandererBaseVelocity + velocityBonus)
        let displacement = CGVector(dx: target.x - position.x,
                                    dy: target.y - position.y)
        let distance = hypot(displacement.dx, displacement.dy)

        guard distance > 4 else { return }

        let normalized = CGVector(dx: displacement.dx / distance,
                                  dy: displacement.dy / distance)
        let step = velocity * deltaTime

        var newX = position.x + normalized.dx * step
        var newY = position.y + normalized.dy * step

        // Soft boundary clamp
        let margin = CelestialConfig.edgeCushion + girth
        newX = newX.clamped(to: (mapBounds.minX + margin)...(mapBounds.maxX - margin))
        newY = newY.clamped(to: (mapBounds.minY + margin)...(mapBounds.maxY - margin))

        position = CGPoint(x: newX, y: newY)
    }

    // MARK: - Ingest orb
    func ingestOrb(growth: CGFloat) {
        let effective = growth * growthBonusRate
        animateExpansion(by: effective)
    }

    // MARK: - Ingest hole
    func ingestHole(_ target: AbyssVortexNode) {
        let baseGrowth = growthFromDevouring(target)
        let effective  = baseGrowth * growthBonusRate
        animateExpansion(by: effective)
        emitManualBurst(color: ChromaPalette.auroraBlue)
    }
}

// MARK: - CGFloat clamped helper
extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
