// HowToPlayPanel.swift
// HoleDominion - How to play instructions panel

import SpriteKit

final class HowToPlayPanel: SKNode {

    private let sceneW: CGFloat
    private let sceneH: CGFloat

    // MARK: - Init
    init(sceneWidth: CGFloat, sceneHeight: CGFloat) {
        self.sceneW = sceneWidth
        self.sceneH = sceneHeight
        super.init()
        isUserInteractionEnabled = true
        zPosition = ZStrata.overlayLayer
        assemblePanelUI()
        animateIn()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private func wrappedLines(for text: String, font: UIFont, maxWidth: CGFloat) -> [String] {
        let words = text.split(separator: " ")
        guard !words.isEmpty else { return [] }

        var lines: [String] = []
        var currentLine = ""

        for word in words {
            let candidate = currentLine.isEmpty ? String(word) : currentLine + " " + word
            let candidateWidth = (candidate as NSString).size(withAttributes: [.font: font]).width

            if candidateWidth <= maxWidth || currentLine.isEmpty {
                currentLine = candidate
            } else {
                lines.append(currentLine)
                currentLine = String(word)
            }
        }

        if !currentLine.isEmpty {
            lines.append(currentLine)
        }

        return lines
    }

    private func buildWrappedDetailNode(text: String, width: CGFloat, fontSize: CGFloat) -> SKNode {
        let container = SKNode()
        let font = UIFont(name: "HelveticaNeue", size: fontSize) ?? .systemFont(ofSize: fontSize)
        let lines = wrappedLines(for: text, font: font, maxWidth: width)
        let lineHeight = fontSize + 5

        for (index, line) in lines.enumerated() {
            let label = SKLabelNode(fontNamed: "HelveticaNeue")
            label.text = line
            label.fontSize = fontSize
            label.fontColor = ChromaPalette.dimGhost
            label.verticalAlignmentMode = .top
            label.horizontalAlignmentMode = .left
            label.position = CGPoint(x: 0, y: -CGFloat(index) * lineHeight)
            label.zPosition = 2
            container.addChild(label)
        }

        return container
    }

    // MARK: - Build UI
    private func assemblePanelUI() {
        // Dim overlay
        let dim = SKShapeNode(rectOf: CGSize(width: sceneW * 3, height: sceneH * 3))
        dim.fillColor   = UIColor.black.withAlphaComponent(0.72)
        dim.strokeColor = .clear
        dim.zPosition   = 0
        addChild(dim)

        // Panel card
        let cardW: CGFloat = sceneW - 40
        let cardH: CGFloat = 600
        let card = SKShapeNode(rectOf: CGSize(width: cardW, height: cardH), cornerRadius: 24)
        card.fillColor      = UIColor(hex: "#0A0A20")
        card.strokeColor    = ChromaPalette.violetCore.withAlphaComponent(0.6)
        card.lineWidth      = 1.5
        card.zPosition      = 1
        addChild(card)

        // Top accent
        let accent = SKShapeNode(rectOf: CGSize(width: cardW - 4, height: 4), cornerRadius: 2)
        accent.fillColor   = ChromaPalette.cyanPulse.withAlphaComponent(0.85)
        accent.strokeColor = .clear
        accent.position    = CGPoint(x: 0, y: cardH / 2 - 2)
        accent.zPosition   = 2
        addChild(accent)

        // Title
        let title = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        title.text                    = "HOW TO PLAY"
        title.fontSize                = 24
        title.fontColor               = ChromaPalette.crystalWhite
        title.verticalAlignmentMode   = .center
        title.horizontalAlignmentMode = .center
        title.position                = CGPoint(x: 0, y: cardH / 2 - 40)
        title.zPosition               = 2
        addChild(title)

        // Divider
        let div = SKShapeNode(rectOf: CGSize(width: cardW - 40, height: 1))
        div.fillColor   = ChromaPalette.dimGhost.withAlphaComponent(0.4)
        div.strokeColor = .clear
        div.position    = CGPoint(x: 0, y: cardH / 2 - 68)
        div.zPosition   = 2
        addChild(div)

        // Instructions content
        let instructions = [
            ("OBJECTIVE", "Absorb energy orbs to grow your black hole. Devour smaller enemies and survive!"),
            ("CONTROLS", "Tap and hold anywhere on screen to move your black hole in that direction."),
            ("ENERGY ORBS", "Collect glowing orbs to increase your size. Larger orbs grant more growth."),
            ("AI ENEMIES", "Red holes are AI enemies. If you're bigger, devour them. If smaller, flee!"),
            ("VICTORY", "Campaign: Eliminate all enemies. Challenge: Survive as long as possible."),
            ("UPGRADES", "Earn energy by playing. Spend it on permanent upgrades in the menu.")
        ]

        let startY: CGFloat = cardH / 2 - 96
        let contentWidth = cardW - 60
        let detailWidth = contentWidth
        var currentY = startY

        for (i, (header, detail)) in instructions.enumerated() {
            let headerLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
            headerLabel.text                    = header
            headerLabel.fontSize                = 14
            headerLabel.fontColor               = ChromaPalette.cyanPulse
            headerLabel.verticalAlignmentMode   = .top
            headerLabel.horizontalAlignmentMode = .left
            headerLabel.position                = CGPoint(x: -contentWidth / 2, y: currentY)
            headerLabel.zPosition               = 2
            addChild(headerLabel)

            let fontSize: CGFloat = 12
            let detailNode = buildWrappedDetailNode(text: detail, width: detailWidth, fontSize: fontSize)
            detailNode.position = CGPoint(x: -contentWidth / 2, y: currentY - 18)
            detailNode.zPosition = 2
            addChild(detailNode)

            let wrappedLineCount = max(detailNode.children.count, 1)
            let blockHeight = 18 + CGFloat(wrappedLineCount) * (fontSize + 5)
            currentY -= blockHeight + (i == instructions.count - 1 ? 0 : 12)
        }

        // Close button
        let closeBtn = NexusButton(
            title: "Got It!",
            size: CGSize(width: 160, height: 48),
            gradientTop: ChromaPalette.violetCore,
            gradientBot: ChromaPalette.cyanPulse
        )
        closeBtn.position = CGPoint(x: 0, y: -(cardH / 2 - 32))
        closeBtn.zPosition = 3
        closeBtn.onTap = { [weak self] in self?.animateOut() }
        addChild(closeBtn)
    }

    // MARK: - Animations
    private func animateIn() {
        alpha = 0; setScale(0.92)
        run(.group([.fadeIn(withDuration: 0.25), .scale(to: 1.0, duration: 0.25)]))
    }

    private func animateOut() {
        run(.sequence([
            .group([.fadeOut(withDuration: 0.2), .scale(to: 0.92, duration: 0.2)]),
            .removeFromParent()
        ]))
    }
}
