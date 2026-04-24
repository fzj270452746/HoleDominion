// AscendantUpgradePanel.swift
// HoleDominion - Full-screen upgrade shop panel (used in menu)

import SpriteKit

final class AscendantUpgradePanel: SKNode {

    private let sceneW: CGFloat
    private let sceneH: CGFloat
    private var currencyLabel: SKLabelNode!
    private var slotNodes: [UpgradeSlotNode] = []

    var onDismiss: (() -> Void)?

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
        let cardH: CGFloat = 540
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
        title.text                    = "UPGRADES"
        title.fontSize                = 24
        title.fontColor               = ChromaPalette.crystalWhite
        title.verticalAlignmentMode   = .center
        title.horizontalAlignmentMode = .center
        title.position                = CGPoint(x: 0, y: cardH / 2 - 40)
        title.zPosition               = 2
        addChild(title)

        // Currency row
        currencyLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        currencyLabel.text                    = "Energy: \(PersistenceVault.shared.energyReserve)"
        currencyLabel.fontSize                = 16
        currencyLabel.fontColor               = ChromaPalette.solargold
        currencyLabel.verticalAlignmentMode   = .center
        currencyLabel.horizontalAlignmentMode = .center
        currencyLabel.position                = CGPoint(x: 0, y: cardH / 2 - 74)
        currencyLabel.zPosition               = 2
        addChild(currencyLabel)

        // Divider
        let div = SKShapeNode(rectOf: CGSize(width: cardW - 40, height: 1))
        div.fillColor   = ChromaPalette.dimGhost.withAlphaComponent(0.4)
        div.strokeColor = .clear
        div.position    = CGPoint(x: 0, y: cardH / 2 - 92)
        div.zPosition   = 2
        addChild(div)

        // Upgrade slots
        let upgradeSystem = AscendantUpgradeSystem.shared
        let allInfo       = upgradeSystem.allUpgradeInfo
        let slotStartY    = cardH / 2 - 140
        let slotSpacing:  CGFloat = 128

        for (i, info) in allInfo.enumerated() {
            let slot = UpgradeSlotNode(info: info, slotWidth: cardW - 32)
            slot.position = CGPoint(x: 0, y: slotStartY - CGFloat(i) * slotSpacing)
            slot.zPosition = 2
            slot.onPurchase = { [weak self] in self?.handlePurchase(type: info.type) }
            addChild(slot)
            slotNodes.append(slot)
        }

        // Close button
        let closeBtn = NexusButton(
            title: "Close",
            size: CGSize(width: 120, height: 44),
            gradientTop: UIColor(hex: "#2A2A5E"),
            gradientBot: UIColor(hex: "#1A1A3E")
        )
        closeBtn.position = CGPoint(x: 0, y: -(cardH / 2 - 32))
        closeBtn.zPosition = 3
        closeBtn.onTap = { [weak self] in self?.animateOut() }
        addChild(closeBtn)
    }

    // MARK: - Purchase handler
    private func handlePurchase(type: AscendantUpgradeType) {
        let success = AscendantUpgradeSystem.shared.attemptPurchase(type: type)
        if success {
            currencyLabel.text = "Energy: \(PersistenceVault.shared.energyReserve)"
            refreshSlots()
        } else {
            shakeCurrencyLabel()
        }
    }

    private func refreshSlots() {
        for slot in slotNodes { slot.refreshDisplay() }
    }

    private func shakeCurrencyLabel() {
        let shake = SKAction.sequence([
            .moveBy(x: -6, y: 0, duration: 0.05),
            .moveBy(x: 12, y: 0, duration: 0.05),
            .moveBy(x: -12, y: 0, duration: 0.05),
            .moveBy(x: 6, y: 0, duration: 0.05)
        ])
        currencyLabel.run(shake)
        currencyLabel.fontColor = ChromaPalette.scarletEdge
        currencyLabel.run(.sequence([.wait(forDuration: 0.5),
                                     .run { [weak self] in
                                         self?.currencyLabel.fontColor = ChromaPalette.solargold
                                     }]))
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
        ])) { [weak self] in self?.onDismiss?() }
    }
}

// MARK: - Single upgrade row
private final class UpgradeSlotNode: SKNode {

    var onPurchase: (() -> Void)?
    private let info: AscendantUpgradeInfo
    private var rankDots:   [SKShapeNode] = []
    private var buyButton:  NexusButton!
    private let slotWidth:  CGFloat
    private let detailFontSize: CGFloat = 11
    private let detailLineHeight: CGFloat = 15

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
        let lineHeight = fontSize + 4

        for (index, line) in lines.enumerated() {
            let label = SKLabelNode(fontNamed: "HelveticaNeue")
            label.text = line
            label.fontSize = fontSize
            label.fontColor = ChromaPalette.dimGhost
            label.verticalAlignmentMode = .top
            label.horizontalAlignmentMode = .left
            label.position = CGPoint(x: 0, y: -CGFloat(index) * lineHeight)
            container.addChild(label)
        }

        return container
    }

    private func layoutRankDots(y: CGFloat) {
        let dotStartX = -(slotWidth / 2) + 56
        for (index, dot) in rankDots.enumerated() {
            dot.position = CGPoint(x: dotStartX + CGFloat(index) * 14, y: y)
        }
    }

    init(info: AscendantUpgradeInfo, slotWidth: CGFloat) {
        self.info = info
        self.slotWidth = slotWidth
        super.init()
        isUserInteractionEnabled = false
        assembleSlot()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private func assembleSlot() {
        // Icon
        let icon = SKSpriteNode(imageNamed: info.iconName)
        icon.size     = CGSize(width: 36, height: 36)
        icon.position = CGPoint(x: -(slotWidth / 2) + 26, y: 0)
        addChild(icon)

        // Title
        let titleLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        titleLabel.text                    = info.displayTitle
        titleLabel.fontSize                = 15
        titleLabel.fontColor               = ChromaPalette.crystalWhite
        titleLabel.verticalAlignmentMode   = .center
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.position                = CGPoint(x: -(slotWidth / 2) + 56, y: 16)
        addChild(titleLabel)

        // Detail
        let detailWidth: CGFloat = slotWidth - 220
        let detailNode = buildWrappedDetailNode(text: info.briefDetail, width: detailWidth, fontSize: detailFontSize)
        detailNode.position = CGPoint(x: -(slotWidth / 2) + 56, y: 4)
        addChild(detailNode)

        let detailLineCount = max(detailNode.children.count, 1)
        let dotsY = 4 - CGFloat(detailLineCount) * detailLineHeight - 10

        // Rank dots
        for i in 0..<5 {
            let dot = SKShapeNode(circleOfRadius: 5)
            rankDots.append(dot)
            addChild(dot)
        }
        layoutRankDots(y: dotsY)

        // Buy button
        buyButton = NexusButton(
            title: "Upgrade",
            size: CGSize(width: 88, height: 34),
            gradientTop: info.accentColor,
            gradientBot: info.accentColor.withAlphaComponent(0.7)
        )
        buyButton.position = CGPoint(x: slotWidth / 2 - 54, y: max(dotsY + 10, -2))
        buyButton.onTap = { [weak self] in self?.onPurchase?() }
        addChild(buyButton)

        refreshDisplay()
    }

    func refreshDisplay() {
        let currentRank = PersistenceVault.shared.rankFor(upgradeIndex: info.type.rawValue)
        for (i, dot) in rankDots.enumerated() {
            dot.fillColor   = i < currentRank ? info.accentColor : UIColor(hex: "#2A2A4E")
            dot.strokeColor = info.accentColor.withAlphaComponent(0.5)
            dot.lineWidth   = 1
        }

        if currentRank >= AscendantUpgradeSystem.maxRank {
            buyButton.updateTitle("MAX")
            buyButton.setEnabled(false)
        } else {
            let cost = AscendantUpgradeSystem.shared.rankCost(for: info.type, atRank: currentRank)
            buyButton.updateTitle("Cost \(cost)")
            buyButton.setEnabled(true)
        }
    }
}
