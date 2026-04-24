// PrimordialMenuScene.swift
// HoleDominion - Main menu scene with animated starfield

import SpriteKit

final class PrimordialMenuScene: SKScene {

    // MARK: - Design metrics
    private let vc = ViewportCalibrator.shared
    private var starNodes: [SKShapeNode] = []

    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        backgroundColor = ChromaPalette.deepVoid
        scaleMode = .aspectFill
        assembleBackdrop()
        assembleTitleGroup()
        assembleMenuButtons()
        assembleFooterInfo()
        animateEntrance()
    }

    // MARK: - Starfield backdrop
    private func assembleBackdrop() {
        let bgSprite = SKSpriteNode(color: UIColor(hex: "#0A1628"),
                                    size: CGSize(width: size.width, height: size.height))
        bgSprite.position  = CGPoint(x: size.width / 2, y: size.height / 2)
        bgSprite.zPosition = ZStrata.cosmicBackdrop
        addChild(bgSprite)

        // Stars
        for _ in 0..<130 {
            let r = CGFloat.random(in: 0.5...2.5)
            let star = SKShapeNode(circleOfRadius: r)
            star.fillColor   = .white.withAlphaComponent(CGFloat.random(in: 0.3...0.9))
            star.strokeColor = .clear
            star.position    = CGPoint(x: CGFloat.random(in: 0...size.width),
                                       y: CGFloat.random(in: 0...size.height))
            star.zPosition   = ZStrata.starfieldLayer
            star.name        = NodeTokens.starDot
            addChild(star)
            starNodes.append(star)

            // Twinkle
            let twinkle = SKAction.sequence([
                .fadeAlpha(to: CGFloat.random(in: 0.1...0.5), duration: CGFloat.random(in: 0.8...2.5)),
                .fadeAlpha(to: CGFloat.random(in: 0.6...1.0), duration: CGFloat.random(in: 0.8...2.5))
            ])
            star.run(.repeatForever(twinkle))
        }

        // Decorative hole glow circles
        for i in 0..<3 {
            let r = CGFloat.random(in: 50...120)
            let glow = SKShapeNode(circleOfRadius: r)
            glow.fillColor   = ChromaPalette.violetCore.withAlphaComponent(0.06)
            glow.strokeColor = ChromaPalette.violetCore.withAlphaComponent(0.18)
            glow.lineWidth   = 1.5
            glow.position    = [
                CGPoint(x: size.width * 0.15, y: size.height * 0.78),
                CGPoint(x: size.width * 0.88, y: size.height * 0.60),
                CGPoint(x: size.width * 0.50, y: size.height * 0.10)
            ][i]
            glow.zPosition = ZStrata.starfieldLayer + 1
            addChild(glow)
            let pulse = SKAction.sequence([
                .scale(to: 1.15, duration: 2.5),
                .scale(to: 0.88, duration: 2.5)
            ])
            glow.run(.repeatForever(pulse))
        }
    }

    // MARK: - Visible bounds helpers
    private var viewSize: CGSize {
        view?.bounds.size ?? UIApplication.shared.currentKeyWindow?.bounds.size ?? CGSize(width: 390, height: 844)
    }

    private var visibleTopY: CGFloat {
        ViewportCalibrator.shared.visibleTopY(sceneSize: size, viewSize: viewSize)
    }
    private var visibleBottomY: CGFloat {
        ViewportCalibrator.shared.visibleBottomY(sceneSize: size, viewSize: viewSize)
    }

    // MARK: - Title
    private func assembleTitleGroup() {
        let cx   = size.width / 2
        let topY = visibleTopY - 100

        // Subtitle
        let subtitle = SKLabelNode(fontNamed: "HelveticaNeue")
        subtitle.text                    = "HOLE  DOMINION"
        subtitle.fontSize                = 13
        subtitle.fontColor               = ChromaPalette.cyanPulse.withAlphaComponent(0.8)
        subtitle.verticalAlignmentMode   = .center
        subtitle.horizontalAlignmentMode = .center
        subtitle.position = CGPoint(x: cx, y: topY + 28)
        subtitle.zPosition = 2
        subtitle.isHidden = true
        addChild(subtitle)

        // Main title with glow
        let titleShadow = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        titleShadow.text                    = "Vortex Dominion"
        titleShadow.fontSize                = 42
        titleShadow.fontColor               = ChromaPalette.violetCore.withAlphaComponent(0.5)
        titleShadow.verticalAlignmentMode   = .center
        titleShadow.horizontalAlignmentMode = .center
        titleShadow.position = CGPoint(x: cx + 3, y: topY - 3)
        titleShadow.zPosition = 2
        addChild(titleShadow)

        let titleMain = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        titleMain.text                    = "Vortex Dominion"
        titleMain.fontSize                = 42
        titleMain.fontColor               = ChromaPalette.crystalWhite
        titleMain.verticalAlignmentMode   = .center
        titleMain.horizontalAlignmentMode = .center
        titleMain.position = CGPoint(x: cx, y: topY)
        titleMain.name     = "mainTitle"
        titleMain.zPosition = 3
        addChild(titleMain)

        // Title float
        let floatUp = SKAction.moveBy(x: 0, y: 7, duration: 1.8)
        let floatDn = SKAction.moveBy(x: 0, y: -7, duration: 1.8)
        floatUp.timingMode = .easeInEaseOut
        floatDn.timingMode = .easeInEaseOut
        titleMain.run(.repeatForever(.sequence([floatUp, floatDn])))
        titleShadow.run(.repeatForever(.sequence([floatUp.copy() as! SKAction,
                                                  floatDn.copy() as! SKAction])))
    }

    // MARK: - Menu Buttons
    private func assembleMenuButtons() {
        let cx = size.width / 2
        let midY = size.height / 2 + 20

        // Campaign button
        let campaignBtn = NexusButton(
            title: "Campaign",
            size: CGSize(width: 220, height: 54),
            gradientTop: ChromaPalette.violetCore,
            gradientBot: ChromaPalette.cyanPulse
        )
        campaignBtn.position = CGPoint(x: cx, y: midY + 30)
        campaignBtn.zPosition = 3
        campaignBtn.onTap = { [weak self] in self?.navigateToCampaign() }
        addChild(campaignBtn)

        // Challenge button
        let challengeBtn = NexusButton(
            title: "Challenge",
            size: CGSize(width: 220, height: 54),
            gradientTop: ChromaPalette.emberstrike,
            gradientBot: ChromaPalette.scarletEdge
        )
        challengeBtn.position = CGPoint(x: cx, y: midY - 38)
        challengeBtn.zPosition = 3
        challengeBtn.onTap = { [weak self] in self?.navigateToChallenge() }
        addChild(challengeBtn)

        // Upgrade button
        let upgradeBtn = NexusButton(
            title: "Upgrades",
            size: CGSize(width: 220, height: 54),
            gradientTop: UIColor(hex: "#1B6CA8"),
            gradientBot: ChromaPalette.auroraBlue
        )
        upgradeBtn.position = CGPoint(x: cx, y: midY - 106)
        upgradeBtn.zPosition = 3
        upgradeBtn.onTap = { [weak self] in self?.showUpgradePanel() }
        addChild(upgradeBtn)

        // How to Play button
        let howToBtn = NexusButton(
            title: "How to Play",
            size: CGSize(width: 220, height: 54),
            gradientTop: UIColor(hex: "#1A3A2A"),
            gradientBot: UIColor(hex: "#0F2A1A")
        )
        howToBtn.position = CGPoint(x: cx, y: midY - 174)
        howToBtn.zPosition = 3
        howToBtn.onTap = { [weak self] in self?.showHowToPlay() }
        addChild(howToBtn)
    }

    // MARK: - Footer stats
    private func assembleFooterInfo() {
        let vault = PersistenceVault.shared
        let cx    = size.width / 2
        let botY  = visibleBottomY + 24

        // Best time label (challenge)
        let bestTime = vault.pinnacleTime
        let timeStr  = bestTime > 0 ? formatTime(bestTime) : "--:--"
        let bestLabel = buildFooterLabel("Best Survival: \(timeStr)", y: botY + 40)
        bestLabel.name = "bestTimeLabel"
        addChild(bestLabel)

        // Stage reached
        let stageLabel = buildFooterLabel("Stage Reached: \(vault.stallarUnlocked + 1)", y: botY + 20)
        stageLabel.name = "stageLabel"
        addChild(stageLabel)

        let cx2 = cx
        _ = cx2  // suppress warning

        // Energy
        let energyLabel = buildFooterLabel("Energy: \(vault.energyReserve)", y: botY)
        energyLabel.fontColor = ChromaPalette.solargold
        energyLabel.name = "energyLabel"
        addChild(energyLabel)
    }

    private func buildFooterLabel(_ text: String, y: CGFloat) -> SKLabelNode {
        let l = SKLabelNode(fontNamed: "HelveticaNeue")
        l.text                    = text
        l.fontSize                = 13
        l.fontColor               = ChromaPalette.dimGhost
        l.verticalAlignmentMode   = .center
        l.horizontalAlignmentMode = .center
        l.position                = CGPoint(x: size.width / 2, y: y)
        l.zPosition               = 3
        return l
    }

    // MARK: - Entrance animation
    private func animateEntrance() {
        for child in children {
            child.alpha = 0
            child.run(.sequence([.wait(forDuration: 0.1), .fadeIn(withDuration: 0.6)]))
        }
    }

    // MARK: - Navigation

    private func navigateToCampaign() {
        let stageScene = StagePortalScene(size: size)
        stageScene.scaleMode = .aspectFill
        view?.presentScene(stageScene, transition: .push(with: .left, duration: 0.4))
    }

    private func navigateToChallenge() {
        let arenaScene = VortexArenaScene(size: size, gameMode: .challenge, stageIndex: 0)
        arenaScene.scaleMode = .aspectFill
        view?.presentScene(arenaScene, transition: .doorsOpenVertical(withDuration: 0.4))
    }

    private func showHowToPlay() {
        let panel = HowToPlayPanel(sceneWidth: size.width, sceneHeight: size.height)
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        panel.zPosition = ZStrata.overlayLayer
        addChild(panel)
    }

    private func showUpgradePanel() {
        let panel = AscendantUpgradePanel(sceneWidth: size.width, sceneHeight: size.height)
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        panel.zPosition = ZStrata.overlayLayer
        panel.onDismiss = { [weak self] in
            self?.refreshFooterLabels()
        }
        addChild(panel)
    }

    private func refreshFooterLabels() {
        let vault = PersistenceVault.shared
        if let l = childNode(withName: "bestTimeLabel") as? SKLabelNode {
            let t = vault.pinnacleTime
            l.text = "Best Survival: \(t > 0 ? formatTime(t) : "--:--")"
        }
        if let l = childNode(withName: "energyLabel") as? SKLabelNode {
            l.text = "Energy: \(vault.energyReserve)"
        }
        if let l = childNode(withName: "stageLabel") as? SKLabelNode {
            l.text = "Stage Reached: \(vault.stallarUnlocked + 1)"
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%d:%02d", m, s)
    }
}
