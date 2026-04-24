// NexusHUD.swift
// HoleDominion - In-game heads-up display (attached to camera)

import SpriteKit

enum HUDDisplayMode {
    case campaign(stageIndex: Int)
    case challenge
}

final class NexusHUD: SKNode {

    // MARK: - Sub-nodes
    private var scorePill:       SKNode!
    private var scoreLabel:      SKLabelNode!
    private var sizeLabel:       SKLabelNode!
    private var rightInfoPill:   SKNode!
    private var rightInfoLabel:  SKLabelNode!
    private var pauseButton:     NexusButton!

    private var timerAccum: TimeInterval = 0
    var onPauseTapped: (() -> Void)?

    private let sceneW: CGFloat
    private let sceneH: CGFloat

    // MARK: - Init
    init(displayMode: HUDDisplayMode, sceneWidth: CGFloat, sceneHeight: CGFloat) {
        self.sceneW = sceneWidth
        self.sceneH = sceneHeight
        super.init()
        zPosition = ZStrata.hudLayer
        assembleHUD(mode: displayMode)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Build HUD
    private func assembleHUD(mode: HUDDisplayMode) {

        // In camera space, Y=0 is scene center. Visible half-height depends on the
        // actual view size (aspectFill may crop the design canvas vertically on iPad).
        let viewSize: CGSize = UIApplication.shared.currentKeyWindow?.bounds.size ?? CGSize(width: sceneW, height: sceneH)
        let vc = ViewportCalibrator.shared
        let scale = viewSize.width / sceneW
        let visibleHalfH = viewSize.height / scale / 2
        let safeTopInScene = vc.safeInsets.top / scale
        let hudY = visibleHalfH - safeTopInScene - 30

        // Left pill: score + size
        scorePill = buildPill(width: 140, height: 46)
        scorePill.position = CGPoint(x: -sceneW / 2 + 88, y: hudY)
        addChild(scorePill)

        scoreLabel = buildLabel("0 pts", size: 13, bold: false)
        scoreLabel.position = CGPoint(x: 0, y: 8)
        scorePill.addChild(scoreLabel)

        sizeLabel = buildEmojiLabel("⬤ 32", size: 16)
        sizeLabel.fontColor = ChromaPalette.cyanPulse
        sizeLabel.position  = CGPoint(x: 0, y: -10)
        scorePill.addChild(sizeLabel)

        // Right pill
        rightInfoPill = buildPill(width: 130, height: 46)
        rightInfoPill.position = CGPoint(x: sceneW / 2 - 82, y: hudY)
        addChild(rightInfoPill)

        rightInfoLabel = buildLabel("", size: 15, bold: true)
        rightInfoLabel.position = CGPoint(x: 0, y: 0)
        rightInfoPill.addChild(rightInfoLabel)

        switch mode {
        case .campaign(let idx):
            rightInfoLabel.text = "Stage \(idx + 1)"
            rightInfoLabel.fontColor = ChromaPalette.solargold
        case .challenge:
            rightInfoLabel.text = "0:00"
            rightInfoLabel.fontColor = ChromaPalette.emberstrike
        }

        // Pause button (top center)
        pauseButton = NexusButton(
            title: "II",
            size: CGSize(width: 44, height: 44),
            gradientTop: UIColor(hex: "#2A2A5E"),
            gradientBot: UIColor(hex: "#1A1A3E")
        )
        pauseButton.position = CGPoint(x: 0, y: hudY)
        pauseButton.zPosition = 1
        pauseButton.onTap = { [weak self] in self?.onPauseTapped?() }
        addChild(pauseButton)
    }

    // MARK: - Update HUD data
    func refreshScore(_ pts: Int, girth: CGFloat) {
        scoreLabel.text = "\(pts) pts"
        sizeLabel.text  = "⬤ \(Int(girth))"
    }

    func refreshNebulonCount(_ remaining: Int) {
        rightInfoLabel.text = remaining == 0 ? "Clear!" : "\(remaining) left"
    }

    func refreshSurvivalTime(_ seconds: TimeInterval) {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        rightInfoLabel.text = String(format: "%d:%02d", m, s)
    }

    // MARK: - Helpers
    private func buildPill(width: CGFloat, height: CGFloat) -> SKNode {
        let node = SKNode()
        let bg = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 14)
        bg.fillColor      = UIColor(hex: "#0D0D2B").withAlphaComponent(0.92)
        bg.strokeColor    = ChromaPalette.violetCore.withAlphaComponent(0.55)
        bg.lineWidth      = 1.2
        bg.zPosition      = 0
        node.addChild(bg)
        return node
    }

    private func buildLabel(_ text: String, size: CGFloat, bold: Bool) -> SKLabelNode {
        let l = SKLabelNode(fontNamed: bold ? "HelveticaNeue-Bold" : "HelveticaNeue")
        l.text                     = text
        l.fontSize                 = size
        l.fontColor                = ChromaPalette.crystalWhite
        l.verticalAlignmentMode    = .center
        l.horizontalAlignmentMode  = .center
        l.zPosition                = 1
        return l
    }

    private func buildEmojiLabel(_ text: String, size: CGFloat) -> SKLabelNode {
        let l = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        l.text                    = text
        l.fontSize                = size
        l.fontColor               = ChromaPalette.crystalWhite
        l.verticalAlignmentMode   = .center
        l.horizontalAlignmentMode = .center
        l.zPosition               = 1
        return l
    }
}
