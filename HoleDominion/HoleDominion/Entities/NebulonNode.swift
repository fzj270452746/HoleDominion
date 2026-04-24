// NebulonNode.swift
// HoleDominion - AI-controlled black hole entity

import SpriteKit

enum NebulonBehaviorState {
    case foraging      // collecting orbs
    case prowling      // chasing player
    case retreating    // fleeing player
    case dormant       // freshly spawned, short delay
}

final class NebulonNode: AbyssVortexNode {

    // MARK: - Properties
    var behaviorState: NebulonBehaviorState = .dormant
    var cognitionTarget: CGPoint?                 // current movement target
    var dormancyTimer:   TimeInterval = 1.0       // delay before first action
    var stateRefreshTimer: TimeInterval = 0.0     // when to re-evaluate state
    let stateRefreshInterval: TimeInterval = 1.5

    // Unique index for identification
    let nebulonIndex: Int

    // MARK: - Init
    init(girth: CGFloat = CelestialConfig.nebulonInitialGirth, index: Int) {
        self.nebulonIndex = index
        super.init(girth: girth,
                   textureName: "ai_hole",
                   tintColor: ChromaPalette.emberstrike)
        name = "\(NodeTokens.nebulonPrefix)\(index)"
        zPosition = ZStrata.nebulonLayer

        // Add a subtle rotation to differentiate AI visually
        let rotDir: CGFloat = index % 2 == 0 ? 1 : -1
        coreSprite.run(.repeatForever(.rotate(byAngle: rotDir * 0.6, duration: 3.0)))
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Frame update
    func cognitionFrame(deltaTime: CGFloat,
                        mapBounds: CGRect,
                        wandererPosition: CGPoint,
                        wandererGirth: CGFloat,
                        nearestOrbPosition: CGPoint?) {

        // Dormancy warm-up
        if dormancyTimer > 0 {
            dormancyTimer -= deltaTime
            return
        }

        // Re-evaluate behavior state every frame for responsive aggression
        recalibrateState(wandererGirth: wandererGirth, wandererPosition: wandererPosition)

        // Determine target based on state
        let margin: CGFloat = 100
        switch behaviorState {
        case .foraging, .retreating:
            if let orbPos = nearestOrbPosition {
                // Always chase nearest orb regardless of state
                cognitionTarget = orbPos
            } else if behaviorState == .retreating {
                // No orbs nearby — flee from player
                let dx = position.x - wandererPosition.x
                let dy = position.y - wandererPosition.y
                let dist = max(hypot(dx, dy), 1)
                cognitionTarget = CGPoint(
                    x: (position.x + dx / dist * 200).clamped(to: (mapBounds.minX + 60)...(mapBounds.maxX - 60)),
                    y: (position.y + dy / dist * 200).clamped(to: (mapBounds.minY + 60)...(mapBounds.maxY - 60))
                )
            } else {
                // Foraging, no orbs — wander randomly
                let needsNewTarget: Bool
                if let t = cognitionTarget {
                    needsNewTarget = hypot(t.x - position.x, t.y - position.y) < 40
                } else {
                    needsNewTarget = true
                }
                if needsNewTarget {
                    cognitionTarget = CGPoint(
                        x: CGFloat.random(in: (mapBounds.minX + margin)...(mapBounds.maxX - margin)),
                        y: CGFloat.random(in: (mapBounds.minY + margin)...(mapBounds.maxY - margin))
                    )
                }
            }
        case .prowling:
            cognitionTarget = wandererPosition
        case .dormant:
            break
        }

        guard let target = cognitionTarget else { return }

        // Move toward target
        let velocity = computeActualVelocity(base: CelestialConfig.nebulonBaseVelocity)
        let displacement = CGVector(dx: target.x - position.x,
                                    dy: target.y - position.y)
        let distance = hypot(displacement.dx, displacement.dy)
        guard distance > 4 else {
            // Reached wander target — clear so next frame picks a new one
            if nearestOrbPosition == nil {
                cognitionTarget = nil
            }
            return
        }

        let normalized = CGVector(dx: displacement.dx / distance,
                                  dy: displacement.dy / distance)
        let step = velocity * deltaTime
        let edgeMargin = CelestialConfig.edgeCushion + girth

        let newX = (position.x + normalized.dx * step).clamped(
            to: (mapBounds.minX + edgeMargin)...(mapBounds.maxX - edgeMargin))
        let newY = (position.y + normalized.dy * step).clamped(
            to: (mapBounds.minY + edgeMargin)...(mapBounds.maxY - edgeMargin))
        position = CGPoint(x: newX, y: newY)
    }

    // MARK: - State logic
    private func recalibrateState(wandererGirth: CGFloat, wandererPosition: CGPoint) {
        let sizeRatio = girth / max(wandererGirth, 1)

        if sizeRatio > 1.0 {
            // We're bigger than player → actively hunt
            behaviorState = .prowling
        } else if sizeRatio < (1.0 - CelestialConfig.devourThreshold) {
            // Wanderer is significantly bigger → flee
            behaviorState = .retreating
        } else {
            // Similar size or smaller → forage orbs to grow
            behaviorState = .foraging
        }
    }

    // MARK: - Ingest another nebulon
    func ingestNebulon(_ target: NebulonNode) {
        let baseGrowth = growthFromDevouring(target)
        animateExpansion(by: baseGrowth)
        emitManualBurst(color: ChromaPalette.emberstrike)
    }
}
