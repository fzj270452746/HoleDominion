// StagePortalScene.swift
// HoleDominion - Campaign level selection

import SpriteKit

final class StagePortalScene: SKScene {

    private let totalStages = CelestialConfig.totalCampaignStages
    fileprivate var scrollNode: SKNode!
    private var contentHeight: CGFloat = 0
    fileprivate var scrollableHeight: CGFloat = 0

    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        backgroundColor = ChromaPalette.deepVoid
        scaleMode = .aspectFill
        assembleBackground()
        assembleHeader()
        assembleStageGrid()
    }

    // MARK: - Background
    private func assembleBackground() {
        let bg = SKSpriteNode(color: UIColor(hex: "#0A1628"), size: size)
        bg.position  = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = ZStrata.cosmicBackdrop
        addChild(bg)

        for _ in 0..<80 {
            let r    = CGFloat.random(in: 0.5...1.8)
            let star = SKShapeNode(circleOfRadius: r)
            star.fillColor   = .white.withAlphaComponent(CGFloat.random(in: 0.2...0.7))
            star.strokeColor = .clear
            star.position    = CGPoint(x: CGFloat.random(in: 0...size.width),
                                       y: CGFloat.random(in: 0...size.height))
            star.zPosition   = ZStrata.starfieldLayer
            addChild(star)
        }
    }

    // MARK: - Visible bounds helpers
    private var viewSize: CGSize {
        view?.bounds.size ?? UIApplication.shared.currentKeyWindow?.bounds.size ?? CGSize(width: 390, height: 844)
    }

    private var visibleTopY: CGFloat {
        ViewportCalibrator.shared.visibleTopY(sceneSize: size, viewSize: viewSize)
    }

    // MARK: - Header
    private func assembleHeader() {
        let cx       = size.width / 2
        let headerY  = visibleTopY - 30   // 30pt below safe area bottom edge

        // Back button
        let backBtn = NexusButton(
            title: "Back",
            size: CGSize(width: 90, height: 38),
            gradientTop: UIColor(hex: "#2A2A5E"),
            gradientBot: UIColor(hex: "#1A1A3E")
        )
        backBtn.position = CGPoint(x: 60, y: headerY)
        backBtn.zPosition = 5
        backBtn.onTap = { [weak self] in
            guard let self = self else { return }
            let menu = PrimordialMenuScene(size: self.size)
            menu.scaleMode = .aspectFill
            self.view?.presentScene(menu, transition: .push(with: .right, duration: 0.4))
        }
        addChild(backBtn)

        // Title
        let title = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        title.text                    = "Campaign"
        title.fontSize                = 26
        title.fontColor               = ChromaPalette.crystalWhite
        title.verticalAlignmentMode   = .center
        title.horizontalAlignmentMode = .center
        title.position = CGPoint(x: cx, y: headerY)
        title.zPosition = 5
        addChild(title)

        // Energy indicator
        let energyLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        energyLabel.text                    = "Energy: \(PersistenceVault.shared.energyReserve)"
        energyLabel.fontSize                = 14
        energyLabel.fontColor               = ChromaPalette.solargold
        energyLabel.verticalAlignmentMode   = .center
        energyLabel.horizontalAlignmentMode = .right
        energyLabel.position = CGPoint(x: size.width - 18, y: headerY)
        energyLabel.zPosition = 5
        addChild(energyLabel)
    }

    // MARK: - Stage grid
    private func assembleStageGrid() {
        scrollNode = SKNode()
        scrollNode.position = CGPoint(x: 0, y: 0)
        scrollNode.zPosition = 2
        addChild(scrollNode)

        let cols: Int = 4
        let cellSize: CGFloat = (size.width - 40) / CGFloat(cols)
        let cellH:    CGFloat = cellSize * 0.9
        let unlocked = PersistenceVault.shared.stallarUnlocked

        let startX = 20 + cellSize / 2
        // Place grid below header: headerY = visibleTopY - 30, button height 38 → bottom at headerY - 19
        let headerY = visibleTopY - 30
        let startY  = headerY - 19 - 20 - cellH / 2   // header bottom + 20pt gap + half cell

        for i in 0..<totalStages {
            let col = i % cols
            let row = i / cols
            let x   = startX + CGFloat(col) * cellSize
            let y   = startY - CGFloat(row) * (cellH + 10)

            let isUnlocked = i <= unlocked
            let cell = buildStageCell(stageIndex: i, unlocked: isUnlocked,
                                      size: CGSize(width: cellSize - 10, height: cellH - 8))
            cell.position = CGPoint(x: x, y: y)
            scrollNode.addChild(cell)
        }

        contentHeight = CGFloat((totalStages + cols - 1) / cols) * (cellH + 10) + 130

        // Visible height in scene space (aspectFill may crop design canvas on iPad)
        let scale = viewSize.width / size.width
        let visibleH = viewSize.height / scale
        let cropY = (size.height - visibleH) / 2   // scene Y of visible bottom edge
        let headerBottom = visibleTopY - 30 - 19   // bottom edge of header row
        let availableH = headerBottom - cropY       // scrollable area height
        scrollableHeight = max(contentHeight - availableH, 0)

    }

    private func buildStageCell(stageIndex: Int, unlocked: Bool, size: CGSize) -> SKNode {
        let container = SKNode()

        let bg = SKShapeNode(rectOf: size, cornerRadius: 12)
        if unlocked {
            bg.fillColor      = UIColor(hex: "#0D0D2B")
            bg.strokeColor    = ChromaPalette.violetCore.withAlphaComponent(0.6)
        } else {
            bg.fillColor   = UIColor(hex: "#0A0A1E")
            bg.strokeColor = UIColor(hex: "#1A1A3E")
        }
        bg.lineWidth = 1.2
        bg.zPosition = 0
        container.addChild(bg)

        // Stage number
        let numLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        numLabel.text                    = "\(stageIndex + 1)"
        numLabel.fontSize                = unlocked ? 20 : 18
        numLabel.fontColor               = unlocked ? ChromaPalette.crystalWhite : ChromaPalette.dimGhost.withAlphaComponent(0.4)
        numLabel.verticalAlignmentMode   = .center
        numLabel.horizontalAlignmentMode = .center
        numLabel.position                = CGPoint(x: 0, y: 5)
        numLabel.zPosition               = 1
        container.addChild(numLabel)

        if !unlocked {
            let lock = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
            lock.text                    = "LOCK"
            lock.fontSize                = 14
            lock.verticalAlignmentMode   = .center
            lock.horizontalAlignmentMode = .center
            lock.position                = CGPoint(x: 0, y: -12)
            lock.zPosition               = 1
            container.addChild(lock)
        } else {
            let cfg = CelestialConfig.campaignConfig(for: stageIndex)
            let detailLabel = SKLabelNode(fontNamed: "HelveticaNeue")
            detailLabel.text                   = "\(cfg.nebulonCount) foes"
            detailLabel.fontSize               = 10
            detailLabel.fontColor              = ChromaPalette.dimGhost
            detailLabel.verticalAlignmentMode  = .center
            detailLabel.horizontalAlignmentMode = .center
            detailLabel.position               = CGPoint(x: 0, y: -11)
            detailLabel.zPosition              = 1
            container.addChild(detailLabel)

            // Tap gesture via the stageIndex
            let btn = InvisibleTapNode(size: size, stageIndex: stageIndex) { [weak self] idx in
                self?.launchStage(idx)
            }
            btn.zPosition = 2
            container.addChild(btn)
        }

        return container
    }

    // MARK: - Launch
    private func launchStage(_ stageIndex: Int) {
        let arena = VortexArenaScene(size: size, gameMode: .campaign, stageIndex: stageIndex)
        arena.scaleMode = .aspectFill
        view?.presentScene(arena, transition: .doorsOpenVertical(withDuration: 0.4))
    }

    // MARK: - Touch scroll
    fileprivate var lastTouchY: CGFloat = 0

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            lastTouchY = touch.location(in: self).y
        }
        // Don't call super - we handle it ourselves
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentY = touch.location(in: self).y
        let delta    = currentY - lastTouchY
        lastTouchY   = currentY

        let newY = scrollNode.position.y + delta
        let minY = -scrollableHeight
        scrollNode.position.y = newY.clamped(to: minY...0)
    }
}

// MARK: - Invisible tap node
private final class InvisibleTapNode: SKSpriteNode {
    private let stageIndex: Int
    private let onTap: (Int) -> Void
    private var startY: CGFloat = 0
    private var didScroll = false

    init(size: CGSize, stageIndex: Int, onTap: @escaping (Int) -> Void) {
        self.stageIndex = stageIndex
        self.onTap      = onTap
        super.init(texture: nil, color: .clear, size: size)
        isUserInteractionEnabled = true
        alpha = 0.01   // nearly invisible but hittable
    }
    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        startY = touches.first?.location(in: scene!).y ?? 0
        didScroll = false
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let scene = scene as? StagePortalScene else { return }
        let currentY = touch.location(in: scene).y
        let dy = abs(currentY - startY)
        if !didScroll && dy > 6 {
            didScroll = true
            scene.lastTouchY = currentY
        }
        if didScroll {
            let delta = currentY - scene.lastTouchY
            scene.lastTouchY = currentY
            let newY = scene.scrollNode.position.y + delta
            scene.scrollNode.position.y = newY.clamped(to: -scene.scrollableHeight...0)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !didScroll { onTap(stageIndex) }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        didScroll = true
    }
}
