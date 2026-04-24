// VortexArenaScene.swift
// HoleDominion - Main gameplay scene

import SpriteKit
import UIKit

enum ArenaGameMode {
    case campaign
    case challenge
}

final class VortexArenaScene: SKScene, MapEventDelegate {

    // MARK: - Mode / Config
    let gameMode:   ArenaGameMode
    let stageIndex: Int
    private var campaignCfg: CelestialConfig.CampaignLevel?

    // MARK: - Game world
    private var worldNode:      SKNode!
    private var cameraNode:     SKCameraNode!

    // MARK: - Entities
    private var wanderer:    WandererNode!
    private var nebulons:    [NebulonNode] = []

    // MARK: - Systems
    private var spawnSystem:    CelestialSpawnSystem!
    private var mapEventSystem: MapEventSystem!

    // MARK: - HUD
    private var nexusHUD: NexusHUD!

    // MARK: - State
    private var sessionScore:    Int = 0
    private var sessionEnergy:   Int = 0
    private var survivalSeconds: TimeInterval = 0
    private var isGamePaused:    Bool = false
    private var isGameOver:      Bool = false
    private var challengeNebulonTimer: TimeInterval = CelestialConfig.challengeNebulonInterval

    // Map bounds (centered at 0,0)
    private lazy var mapBounds: CGRect = {
        let w = CelestialConfig.chartWidth
        let h = CelestialConfig.chartHeight
        return CGRect(x: -w/2, y: -h/2, width: w, height: h)
    }()

    // MARK: - Init
    init(size: CGSize, gameMode: ArenaGameMode, stageIndex: Int) {
        self.gameMode   = gameMode
        self.stageIndex = stageIndex
        super.init(size: size)
        if gameMode == .campaign {
            campaignCfg = CelestialConfig.campaignConfig(for: stageIndex)
        }
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        scaleMode = .aspectFill
        assembleWorld()
        assembleCamera()
        assembleWanderer()
        populateNebulons()
        populateOrbs()
        assembleHUD()
        assembleMapOverlay()
        mapEventSystem = MapEventSystem()
        mapEventSystem.delegate = self
    }

    // MARK: - World setup
    private func assembleWorld() {
        worldNode = SKNode()
        addChild(worldNode)

        // Background: use a small tiled gradient texture instead of full map size
        let bgSprite = SKSpriteNode(color: UIColor(hex: "#060614"),
                                    size: CGSize(width: CelestialConfig.chartWidth,
                                                 height: CelestialConfig.chartHeight))
        bgSprite.zPosition = ZStrata.cosmicBackdrop
        worldNode.addChild(bgSprite)

        // Grid
        assembleCosmicGrid()

        // Stars
        for _ in 0..<250 {
            let r    = CGFloat.random(in: 0.5...2.0)
            let star = SKShapeNode(circleOfRadius: r)
            star.fillColor   = .white.withAlphaComponent(CGFloat.random(in: 0.2...0.8))
            star.strokeColor = .clear
            star.position    = CGPoint(
                x: CGFloat.random(in: -CelestialConfig.chartWidth/2...CelestialConfig.chartWidth/2),
                y: CGFloat.random(in: -CelestialConfig.chartHeight/2...CelestialConfig.chartHeight/2)
            )
            star.zPosition = ZStrata.starfieldLayer
            worldNode.addChild(star)
        }
    }

    private func assembleCosmicGrid() {
        let gridSpacing: CGFloat = 160
        let halfW = CelestialConfig.chartWidth  / 2
        let halfH = CelestialConfig.chartHeight / 2
        let lineColor = UIColor(hex: "#1A1A4A").withAlphaComponent(0.6)

        var x = -halfW
        while x <= halfW {
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: x, y: -halfH))
            path.addLine(to: CGPoint(x: x, y: halfH))
            line.path        = path
            line.strokeColor = lineColor
            line.lineWidth   = 0.5
            line.zPosition   = ZStrata.gridOverlay
            worldNode.addChild(line)
            x += gridSpacing
        }

        var y = -halfH
        while y <= halfH {
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -halfW, y: y))
            path.addLine(to: CGPoint(x: halfW, y: y))
            line.path        = path
            line.strokeColor = lineColor
            line.lineWidth   = 0.5
            line.zPosition   = ZStrata.gridOverlay
            worldNode.addChild(line)
            y += gridSpacing
        }
    }

    // MARK: - Camera
    private func assembleCamera() {
        cameraNode = SKCameraNode()
        camera     = cameraNode
        addChild(cameraNode)
    }

    // MARK: - Wanderer
    private func assembleWanderer() {
        wanderer = WandererNode()
        wanderer.position = .zero
        AscendantUpgradeSystem.shared.applyAllBonuses(to: wanderer)
        worldNode.addChild(wanderer)
    }

    // MARK: - Nebulons
    private func populateNebulons() {
        let cfg = campaignCfg ?? CelestialConfig.CampaignLevel(nebulonCount: 3, nebulonGirthMult: 1.0)
        let count = gameMode == .challenge ? 3 : cfg.nebulonCount

        for _ in 0..<count {
            spawnSystem = spawnSystem ?? CelestialSpawnSystem(scene: self, worldNode: worldNode)
            spawnOneNebulon(girthMult: cfg.nebulonGirthMult)
        }
    }

    private func spawnOneNebulon(girthMult: CGFloat = 1.0) {
        if spawnSystem == nil {
            spawnSystem = CelestialSpawnSystem(scene: self, worldNode: worldNode)
        }
        if let n = spawnSystem.spawnNebulon(girthMultiplier: girthMult,
                                             avoidingPosition: wanderer?.position ?? .zero) {
            nebulons.append(n)
        }
    }

    // MARK: - Orbs
    private func populateOrbs() {
        if spawnSystem == nil {
            spawnSystem = CelestialSpawnSystem(scene: self, worldNode: worldNode)
        }
        let holePositions = currentHolePositions()
        spawnSystem.bootstrapOrbField(holePositions: holePositions)
    }

    // MARK: - HUD
    private func assembleHUD() {
        let mode: HUDDisplayMode = gameMode == .campaign
            ? .campaign(stageIndex: stageIndex)
            : .challenge
        nexusHUD = NexusHUD(displayMode: mode, sceneWidth: size.width, sceneHeight: size.height)
        nexusHUD.zPosition = ZStrata.hudLayer
        nexusHUD.onPauseTapped = { [weak self] in self?.togglePause() }
        cameraNode.addChild(nexusHUD)
    }

    // MARK: - Map ring overlay (soft boundary visual)
    private func assembleMapOverlay() {
        let borderSize = CGSize(width: CelestialConfig.chartWidth + 40,
                                height: CelestialConfig.chartHeight + 40)
        let border = SKShapeNode(rectOf: borderSize, cornerRadius: 80)
        border.fillColor   = .clear
        border.strokeColor = ChromaPalette.violetCore.withAlphaComponent(0.35)
        border.lineWidth   = 6
        border.zPosition   = ZStrata.particleLayer
        worldNode.addChild(border)
    }

    // MARK: - Game loop
    private var lastUpdateTime: TimeInterval = 0

    override func update(_ currentTime: TimeInterval) {
        guard !isGamePaused, !isGameOver else { return }

        let dt: CGFloat
        if lastUpdateTime == 0 {
            dt = 1.0 / 60.0
        } else {
            dt = CGFloat(min(currentTime - lastUpdateTime, 0.05))
        }
        lastUpdateTime = currentTime

        // Move wanderer
        wanderer.navigateFrame(deltaTime: dt, mapBounds: mapBounds)

        // Move nebulons — each finds its own nearest orb
        for n in nebulons {
            let nearestOrb = spawnSystem.nearestOrbPosition(to: n.position)
            n.cognitionFrame(deltaTime: dt, mapBounds: mapBounds,
                             wandererPosition: wanderer.position,
                             wandererGirth:    wanderer.girth,
                             nearestOrbPosition: nearestOrb)
        }

        // Orb refill
        spawnSystem.tickRefill(deltaTime: TimeInterval(dt),
                               holePositions: currentHolePositions())

        // Collision detection
        checkOrbAbsorption()
        checkHoleCollisions()

        // Challenge timer
        if gameMode == .challenge {
            survivalSeconds += TimeInterval(dt)
            nexusHUD.refreshSurvivalTime(survivalSeconds)
            tickChallengeSpawn(dt: TimeInterval(dt))
        }

        // Map events
        mapEventSystem.tickEvents(deltaTime: TimeInterval(dt))

        // Camera follow
        followWanderer()

        // HUD refresh
        nexusHUD.refreshScore(sessionScore, girth: wanderer.girth)
        if gameMode == .campaign {
            nexusHUD.refreshNebulonCount(nebulons.count)
        }

        // Win check (campaign)
        if gameMode == .campaign, nebulons.isEmpty {
            concludeVictory()
        }
    }

    // MARK: - Orb absorption check
    private func checkOrbAbsorption() {
        guard let worldChildren = worldNode?.children else { return }

        let wPos  = wanderer.position
        let wAbs  = wanderer.absorptionRadius

        for node in worldChildren {
            guard let orb = node as? LuminiteOrbNode, !orb.isConsumed else { continue }
            let dist = hypot(orb.position.x - wPos.x, orb.position.y - wPos.y)
            if dist < wAbs + orb.orbRank.visualRadius {
                orb.playAbsorptionAnimation(toward: wPos) { [weak self, weak orb] in
                    guard let self = self, let orb = orb else { return }
                    self.spawnSystem.removeOrb(orb)
                }
                wanderer.ingestOrb(growth: orb.orbRank.girthGrant)
                sessionScore  += orb.orbRank.pointValue
                sessionEnergy += CelestialConfig.devourOrbReward
            }
        }

        // Nebulon orb absorption
        for n in nebulons {
            let nPos = n.position
            let nAbs = n.absorptionRadius
            for node in worldChildren {
                guard let orb = node as? LuminiteOrbNode, !orb.isConsumed else { continue }
                let dist = hypot(orb.position.x - nPos.x, orb.position.y - nPos.y)
                if dist < nAbs + orb.orbRank.visualRadius {
                    orb.playAbsorptionAnimation(toward: nPos) { [weak self, weak orb] in
                        guard let self = self, let orb = orb else { return }
                        self.spawnSystem.removeOrb(orb)
                    }
                    n.animateExpansion(by: orb.orbRank.girthGrant)
                }
            }
        }
    }

    // MARK: - Hole collision check
    private func checkHoleCollisions() {
        let wGirth = wanderer.girth
        let wPos   = wanderer.position

        // Wanderer vs Nebulons
        var toRemove: [NebulonNode] = []
        for n in nebulons {
            let dist     = hypot(n.position.x - wPos.x, n.position.y - wPos.y)
            let touchDist = n.girth + wGirth
            guard dist < touchDist else { continue }

            let ratio = wGirth / max(n.girth, 1)
            if ratio > (1.0 + CelestialConfig.devourThreshold) {
                // Player devours nebulon
                wanderer.ingestHole(n)
                sessionScore  += 100 + Int(n.girth)
                sessionEnergy += CelestialConfig.devourNebulonReward
                triggerHaptic(style: .medium)
                n.removeFromParent()
                toRemove.append(n)
            } else if ratio < (1.0 - CelestialConfig.devourThreshold) {
                // Nebulon devours player
                n.animateExpansion(by: n.growthFromDevouring(wanderer))
                n.emitManualBurst(color: ChromaPalette.emberstrike)
                concludeDefeat()
                return
            }
            // else: near-equal size → push apart (already separated by velocity)
        }
        nebulons.removeAll { toRemove.contains($0) }

        // Nebulon vs Nebulon - collect removals first to avoid index mutation during iteration
        var nebulonRemovals = IndexSet()
        outer: for i in 0..<nebulons.count {
            if nebulonRemovals.contains(i) { continue }
            for j in (i+1)..<nebulons.count {
                if nebulonRemovals.contains(j) { continue }
                let a = nebulons[i], b = nebulons[j]
                let dist = hypot(a.position.x - b.position.x, a.position.y - b.position.y)
                guard dist < a.girth + b.girth else { continue }
                if a.girth > b.girth * (1.0 + CelestialConfig.devourThreshold) {
                    a.ingestNebulon(b)
                    b.removeFromParent()
                    nebulonRemovals.insert(j)
                } else if b.girth > a.girth * (1.0 + CelestialConfig.devourThreshold) {
                    b.ingestNebulon(a)
                    a.removeFromParent()
                    nebulonRemovals.insert(i)
                    continue outer
                }
            }
        }
        if !nebulonRemovals.isEmpty {
            nebulons = nebulons.enumerated()
                .filter { !nebulonRemovals.contains($0.offset) }
                .map { $0.element }
        }
    }

    // MARK: - Challenge spawn
    private func tickChallengeSpawn(dt: TimeInterval) {
        challengeNebulonTimer -= dt
        if challengeNebulonTimer <= 0 {
            challengeNebulonTimer = CelestialConfig.challengeNebulonInterval
            let wave = Int(survivalSeconds / CelestialConfig.challengeNebulonInterval)
            let count = min(wave + 1, 3)
            for _ in 0..<count {
                spawnOneNebulon(girthMult: 1.0 + CGFloat(wave) * 0.05)
            }
        }
    }

    // MARK: - Camera follow
    private func followWanderer() {
        let target   = wanderer.position
        let halfW    = size.width  / 2
        let halfH    = size.height / 2
        let mapHalfW = CelestialConfig.chartWidth  / 2
        let mapHalfH = CelestialConfig.chartHeight / 2

        // Dynamic zoom: scale out as wanderer grows
        // When girth == initialGirth → zoom 1.0; when girth == wandererMaxGirth → zoom 2.5
        let minGirth = CelestialConfig.wandererInitialGirth
        let maxGirth = CelestialConfig.wandererMaxGirth
        let zoomMin: CGFloat = 1.0
        let zoomMax: CGFloat = 2.8
        let t = ((wanderer.girth - minGirth) / (maxGirth - minGirth)).clamped(to: 0...1)
        let targetZoom = zoomMin + (zoomMax - zoomMin) * t

        // Smooth zoom interpolation
        let currentZoom = cameraNode.xScale
        let newZoom = currentZoom + (targetZoom - currentZoom) * 0.05
        cameraNode.setScale(newZoom)

        // Clamp camera position accounting for zoom
        let effectiveHalfW = halfW * newZoom
        let effectiveHalfH = halfH * newZoom

        let minX = -mapHalfW + effectiveHalfW
        let maxX =  mapHalfW - effectiveHalfW
        let minY = -mapHalfH + effectiveHalfH
        let maxY =  mapHalfH - effectiveHalfH

        // When zoomed out beyond map size, just center the camera
        let clampedX: CGFloat = minX <= maxX ? target.x.clamped(to: minX...maxX) : 0
        let clampedY: CGFloat = minY <= maxY ? target.y.clamped(to: minY...maxY) : 0

        let lerpFactor: CGFloat = 0.10
        let newX = cameraNode.position.x + (clampedX - cameraNode.position.x) * lerpFactor
        let newY = cameraNode.position.y + (clampedY - cameraNode.position.y) * lerpFactor
        cameraNode.position = CGPoint(x: newX, y: newY)
    }

    // MARK: - Map Events (delegate)
    func mapEventDidTrigger(_ kind: MapEventKind) {
        switch kind {
        case .energyTempest:
            spawnSystem.triggerEnergyStorm(holePositions: currentHolePositions())
        case .nebulonSurge:
            // Pick a random nebulon and boost it
            if let n = nebulons.randomElement() {
                n.animateExpansion(by: CelestialConfig.holeBurstGrowthBonus)
                n.emitManualBurst(color: ChromaPalette.scarletEdge)
            }
        }
        let banner = MapEventSystem.buildEventBannerNode(for: kind, in: size)
        banner.position = CGPoint(x: 0, y: size.height * 0.15)
        banner.zPosition = ZStrata.overlayLayer
        cameraNode.addChild(banner)
    }

    func mapEventDidEnd(_ kind: MapEventKind) {}

    // MARK: - Pause
    private func togglePause() {
        isGamePaused.toggle()
        if isGamePaused {
            worldNode.isPaused = true   // pause game world only, not the whole scene
            showPauseOverlay()
        } else {
            worldNode.isPaused = false
            hidePauseOverlay()
        }
    }

    private func showPauseOverlay() {
        let resumePanel = CrystalAlertPanel(
            title: "Paused",
            message: "Game is paused.",
            buttons: [
                CrystalButtonConfig(title: "Quit",
                                    top: ChromaPalette.dimGhost,
                                    bottom: UIColor(hex: "#3A3A5E")) { [weak self] in
                    self?.returnToMenu()
                },
                CrystalButtonConfig(title: "Resume",
                                    top: ChromaPalette.violetCore,
                                    bottom: ChromaPalette.cyanPulse) { [weak self] in
                    self?.isGamePaused    = false
                    self?.worldNode.isPaused = false
                }
            ]
        )
        resumePanel.position  = CGPoint(x: 0, y: 0)
        resumePanel.zPosition = ZStrata.dialogLayer
        resumePanel.name      = "pausePanel"
        cameraNode.addChild(resumePanel)
    }

    private func hidePauseOverlay() {
        cameraNode.childNode(withName: "pausePanel")?.removeFromParent()
    }

    // MARK: - Win/Lose
    private func concludeVictory() {
        guard !isGameOver else { return }
        isGameOver = true
        worldNode.isPaused = true

        // Rewards
        let reward = CelestialConfig.campaignRewardBase * (stageIndex + 1)
        sessionEnergy += reward
        PersistenceVault.shared.depositEnergy(sessionEnergy)
        PersistenceVault.shared.inscribeStageCompletion(stageIndex)

        triggerHaptic(style: .heavy)

        let panel = CrystalAlertPanel(
            title: "Stage Clear! 🎉",
            message: "Score: \(sessionScore)\n+\(sessionEnergy) Energy",
            buttons: [
                CrystalButtonConfig(title: "Menu",
                                    top: ChromaPalette.dimGhost,
                                    bottom: UIColor(hex: "#3A3A5E")) { [weak self] in
                    self?.returnToMenu()
                },
                CrystalButtonConfig(title: "Next →",
                                    top: ChromaPalette.violetCore,
                                    bottom: ChromaPalette.cyanPulse) { [weak self] in
                    self?.launchNextStage()
                }
            ]
        )
        panel.position  = CGPoint(x: 0, y: 0)
        panel.zPosition = ZStrata.dialogLayer
        cameraNode.addChild(panel)
    }

    private func concludeDefeat() {
        guard !isGameOver else { return }
        isGameOver = true
        worldNode.isPaused = true

        // Save partial energy
        PersistenceVault.shared.depositEnergy(sessionEnergy)

        if gameMode == .challenge {
            PersistenceVault.shared.inscribeSurvivalTime(survivalSeconds)
        }

        triggerHaptic(style: .heavy)
        triggerScreenShake()

        let timeStr = gameMode == .challenge ? "\nSurvived: \(formatTime(survivalSeconds))" : ""
        let panel = CrystalAlertPanel(
            title: "Devoured! 💀",
            message: "Score: \(sessionScore)\(timeStr)\n+\(sessionEnergy) Energy",
            buttons: [
                CrystalButtonConfig(title: "Menu",
                                    top: ChromaPalette.dimGhost,
                                    bottom: UIColor(hex: "#3A3A5E")) { [weak self] in
                    self?.returnToMenu()
                },
                CrystalButtonConfig(title: "Retry",
                                    top: ChromaPalette.emberstrike,
                                    bottom: ChromaPalette.scarletEdge) { [weak self] in
                    self?.retryCurrentGame()
                }
            ]
        )
        panel.position  = CGPoint(x: 0, y: 0)
        panel.zPosition = ZStrata.dialogLayer
        cameraNode.addChild(panel)
    }

    // MARK: - Navigation helpers
    private func returnToMenu() {
        let menu = PrimordialMenuScene(size: size)
        menu.scaleMode = .aspectFill
        view?.presentScene(menu, transition: .fade(withDuration: 0.4))
    }

    private func retryCurrentGame() {
        let arena = VortexArenaScene(size: size, gameMode: gameMode, stageIndex: stageIndex)
        arena.scaleMode = .aspectFill
        view?.presentScene(arena, transition: .fade(withDuration: 0.35))
    }

    private func launchNextStage() {
        let nextIdx = stageIndex + 1
        guard nextIdx < CelestialConfig.totalCampaignStages else {
            returnToMenu(); return
        }
        let arena = VortexArenaScene(size: size, gameMode: .campaign, stageIndex: nextIdx)
        arena.scaleMode = .aspectFill
        view?.presentScene(arena, transition: .doorsOpenVertical(withDuration: 0.4))
    }

    // MARK: - Touch controls
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver, !isGamePaused else { return }
        if let touch = touches.first {
            let worldPos = convertTouchToWorld(touch)
            wanderer.trajectoryTarget = worldPos
            wanderer.isTraversing     = true
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver, !isGamePaused else { return }
        if let touch = touches.first {
            wanderer.trajectoryTarget = convertTouchToWorld(touch)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        wanderer.isTraversing = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        wanderer.isTraversing = false
    }

    private func convertTouchToWorld(_ touch: UITouch) -> CGPoint {
        let scenePos = touch.location(in: self)
        return convert(scenePos, to: worldNode)
    }

    // MARK: - Haptics
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard PersistenceVault.shared.hapticsEnabled else { return }
        let gen = UIImpactFeedbackGenerator(style: style)
        gen.impactOccurred()
    }

    // MARK: - Screen shake
    private func triggerScreenShake() {
        let shake = SKAction.sequence([
            .moveBy(x: -8, y: 4,  duration: 0.06),
            .moveBy(x:  8, y: -4, duration: 0.06),
            .moveBy(x: -6, y: 6,  duration: 0.05),
            .moveBy(x:  6, y: -6, duration: 0.05),
            .moveBy(x:  0, y: 0,  duration: 0.0)
        ])
        cameraNode.run(shake)
    }

    // MARK: - Helpers
    private func currentHolePositions() -> [CGPoint] {
        var positions = [wanderer?.position].compactMap { $0 }
        positions += nebulons.map { $0.position }
        return positions
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%d:%02d", m, s)
    }
}
