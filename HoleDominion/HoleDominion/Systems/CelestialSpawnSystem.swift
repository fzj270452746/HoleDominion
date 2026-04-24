// CelestialSpawnSystem.swift
// HoleDominion - Manages spawning of orbs and nebulons

import SpriteKit

final class CelestialSpawnSystem {

    // MARK: - Dependencies (weak to avoid retain cycles)
    weak var arenaScene: SKScene?
    weak var worldNode: SKNode?

    private var activeOrbs: [LuminiteOrbNode] = []
    private var nebulonCounter: Int = 0
    private var orbRefillTimer: TimeInterval = 0

    // MARK: - Init
    init(scene: SKScene, worldNode: SKNode) {
        self.arenaScene = scene
        self.worldNode  = worldNode
    }

    // MARK: - Orb Spawning

    func bootstrapOrbField(holePositions: [CGPoint]) {
        let needed = max(0, CelestialConfig.orbPoolCapacity - activeOrbs.count)
        for _ in 0..<needed {
            spawnOneOrb(avoidingPositions: holePositions)
        }
    }

    func tickRefill(deltaTime: TimeInterval, holePositions: [CGPoint]) {
        orbRefillTimer += deltaTime
        if orbRefillTimer >= CelestialConfig.orbRefillInterval {
            orbRefillTimer = 0
            let deficit = CelestialConfig.orbPoolCapacity - countAliveOrbs()
            guard deficit > 0 else { return }
            let toSpawn = min(deficit, 6)
            for _ in 0..<toSpawn {
                spawnOneOrb(avoidingPositions: holePositions)
            }
        }
    }

    func triggerEnergyStorm(holePositions: [CGPoint]) {
        for _ in 0..<CelestialConfig.energyStormExtraOrbs {
            spawnOneOrb(avoidingPositions: holePositions, forceRank: .smolSpore)
        }
        for _ in 0..<8 {
            spawnOneOrb(avoidingPositions: holePositions, forceRank: .midSpore)
        }
    }

    @discardableResult
    func spawnOneOrb(avoidingPositions holes: [CGPoint], forceRank: OrbRank? = nil) -> LuminiteOrbNode? {
        guard let world = worldNode else { return nil }

        let rank   = forceRank ?? OrbRank.randomByWeight()
        let mapW   = CelestialConfig.chartWidth
        let mapH   = CelestialConfig.chartHeight
        let offset = CGPoint(x: mapW / 2, y: mapH / 2)  // world origin offset

        var attempts = 0
        var spawnPos = CGPoint.zero

        repeat {
            spawnPos = CGPoint(
                x: CGFloat.random(in: 80...(mapW - 80)) - offset.x,
                y: CGFloat.random(in: 80...(mapH - 80)) - offset.y
            )
            attempts += 1
            let tooClose = holes.contains { hypot($0.x - spawnPos.x, $0.y - spawnPos.y) < CelestialConfig.orbSpawnMinDistFromHole }
            if !tooClose { break }
        } while attempts < 12

        let orb = LuminiteOrbNode(rank: rank)
        orb.position = spawnPos
        world.addChild(orb)
        activeOrbs.append(orb)
        return orb
    }

    func removeOrb(_ orb: LuminiteOrbNode) {
        activeOrbs.removeAll { $0 === orb }
    }

    func countAliveOrbs() -> Int {
        activeOrbs = activeOrbs.filter { $0.parent != nil && !$0.isConsumed }
        return activeOrbs.count
    }

    // MARK: - Nebulon Spawning

    @discardableResult
    func spawnNebulon(girthMultiplier: CGFloat = 1.0,
                      avoidingPosition: CGPoint) -> NebulonNode? {
        guard let world = worldNode else { return nil }

        let idx    = nebulonCounter; nebulonCounter += 1
        let mapW   = CelestialConfig.chartWidth
        let mapH   = CelestialConfig.chartHeight
        let offset = CGPoint(x: mapW / 2, y: mapH / 2)

        var spawnPos = CGPoint.zero
        var attempts = 0
        repeat {
            spawnPos = CGPoint(
                x: CGFloat.random(in: 150...(mapW - 150)) - offset.x,
                y: CGFloat.random(in: 150...(mapH - 150)) - offset.y
            )
            attempts += 1
        } while hypot(spawnPos.x - avoidingPosition.x,
                      spawnPos.y - avoidingPosition.y) < 150 && attempts < 20

        let initialGirth = CelestialConfig.nebulonInitialGirth * girthMultiplier
        let nebulon = NebulonNode(girth: initialGirth, index: idx)
        nebulon.position = spawnPos
        world.addChild(nebulon)
        return nebulon
    }

    // MARK: - Retrieve nearest orb to a position
    func nearestOrbPosition(to position: CGPoint) -> CGPoint? {
        let alive = activeOrbs.filter { $0.parent != nil && !$0.isConsumed }
        return alive.min(by: {
            hypot($0.position.x - position.x, $0.position.y - position.y) <
            hypot($1.position.x - position.x, $1.position.y - position.y)
        })?.position
    }
}
