// CrystalAlertPanel.swift
// HoleDominion - Custom in-scene modal dialog

import SpriteKit

struct CrystalButtonConfig {
    let title:   String
    let top:     UIColor
    let bottom:  UIColor
    let action:  () -> Void
}

final class CrystalAlertPanel: SKNode {

    // MARK: - Layout
    private let panelWidth:  CGFloat = 300
    private let panelHeight: CGFloat = 220

    // MARK: - Init
    init(title: String,
         message: String,
         buttons: [CrystalButtonConfig]) {

        super.init()
        isUserInteractionEnabled = true
        zPosition = ZStrata.dialogLayer
        assemblePanelUI(title: title, message: message, buttons: buttons)
        animateAppearance()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Build
    private func assemblePanelUI(title: String, message: String, buttons: [CrystalButtonConfig]) {

        // Dim overlay
        let dimRect = UIApplication.shared.currentKeyWindow?.bounds ?? CGRect(x: 0, y: 0, width: 390, height: 844)
        let dimShape = SKShapeNode(rectOf: CGSize(width: dimRect.width * 3,
                                                   height: dimRect.height * 3))
        dimShape.fillColor   = UIColor.black.withAlphaComponent(0.65)
        dimShape.strokeColor = .clear
        dimShape.zPosition   = -1
        addChild(dimShape)

        // Panel background
        let panelBG = buildPanelBackground()
        addChild(panelBG)

        // Title
        let titleLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        titleLabel.text                     = title
        titleLabel.fontSize                 = 22
        titleLabel.fontColor                = ChromaPalette.crystalWhite
        titleLabel.verticalAlignmentMode    = .center
        titleLabel.horizontalAlignmentMode  = .center
        titleLabel.position                 = CGPoint(x: 0, y: panelHeight / 2 - 40)
        titleLabel.zPosition                = 2
        addChild(titleLabel)

        // Divider
        let divider = SKShapeNode(rectOf: CGSize(width: panelWidth - 48, height: 1))
        divider.fillColor   = ChromaPalette.dimGhost.withAlphaComponent(0.5)
        divider.strokeColor = .clear
        divider.position    = CGPoint(x: 0, y: panelHeight / 2 - 65)
        divider.zPosition   = 2
        addChild(divider)

        // Message
        let msgLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        msgLabel.text                    = String(message.prefix(90))
        msgLabel.fontSize                = 15
        msgLabel.fontColor               = ChromaPalette.dimGhost
        msgLabel.verticalAlignmentMode   = .center
        msgLabel.horizontalAlignmentMode = .center
        msgLabel.position                = CGPoint(x: 0, y: -10)
        msgLabel.zPosition               = 2
        addChild(msgLabel)

        // Buttons
        let btnCount = CGFloat(buttons.count)
        let btnW: CGFloat = buttons.count > 1 ? (panelWidth - 60) / btnCount - 8 : panelWidth - 60
        let btnH: CGFloat = 46
        let startX = buttons.count > 1 ? -(panelWidth / 2 - 30) + btnW / 2 : 0
        let stride = btnW + 12

        for (i, cfg) in buttons.enumerated() {
            let btn = NexusButton(
                title: cfg.title,
                size: CGSize(width: btnW, height: btnH),
                gradientTop: cfg.top,
                gradientBot: cfg.bottom
            )
            btn.position = CGPoint(x: startX + CGFloat(i) * stride,
                                   y: -(panelHeight / 2 - btnH / 2 - 18))
            btn.zPosition = 3
            btn.onTap = { [weak self] in
                cfg.action()
                self?.animateDismiss()
            }
            addChild(btn)
        }
    }

    // MARK: - Panel BG
    private func buildPanelBackground() -> SKNode {
        let container = SKNode()

        // Shadow
        let shadow = SKShapeNode(rectOf: CGSize(width: panelWidth + 16,
                                                 height: panelHeight + 16),
                                  cornerRadius: 26)
        shadow.fillColor   = .black.withAlphaComponent(0.45)
        shadow.strokeColor = .clear
        shadow.position    = CGPoint(x: 4, y: -6)
        shadow.zPosition   = 0
        container.addChild(shadow)

        // Main panel
        let panel = SKShapeNode(rectOf: CGSize(width: panelWidth, height: panelHeight),
                                 cornerRadius: 22)
        panel.fillColor      = UIColor(hex: "#0D0D2B")
        panel.strokeColor    = ChromaPalette.violetCore.withAlphaComponent(0.7)
        panel.lineWidth      = 1.8
        panel.zPosition      = 1
        container.addChild(panel)

        // Top accent line
        let accent = SKShapeNode(rectOf: CGSize(width: panelWidth - 4, height: 4),
                                  cornerRadius: 2)
        accent.fillColor   = ChromaPalette.cyanPulse.withAlphaComponent(0.7)
        accent.strokeColor = .clear
        accent.position    = CGPoint(x: 0, y: panelHeight / 2 - 2)
        accent.zPosition   = 2
        container.addChild(accent)

        return container
    }

    // MARK: - Animations
    private func animateAppearance() {
        alpha = 0
        setScale(0.75)
        let appear = SKAction.group([
            .fadeIn(withDuration: 0.28),
            .scale(to: 1.0, duration: 0.28)
        ])
        appear.timingMode = .easeOut
        run(appear)
    }

    private func animateDismiss() {
        let dismiss = SKAction.group([
            .fadeOut(withDuration: 0.2),
            .scale(to: 0.75, duration: 0.2)
        ])
        run(.sequence([dismiss, .removeFromParent()]))
    }

    // MARK: - Convenience factories
    static func confirmDialog(title: String,
                               message: String,
                               confirmTitle: String = "Confirm",
                               cancelTitle: String  = "Cancel",
                               onConfirm: @escaping () -> Void) -> CrystalAlertPanel {
        CrystalAlertPanel(
            title: title,
            message: message,
            buttons: [
                CrystalButtonConfig(title: cancelTitle,
                                    top: ChromaPalette.dimGhost,
                                    bottom: UIColor(hex: "#3A3A5E"),
                                    action: {}),
                CrystalButtonConfig(title: confirmTitle,
                                    top: ChromaPalette.violetCore,
                                    bottom: ChromaPalette.cyanPulse,
                                    action: onConfirm)
            ]
        )
    }

    static func infoDialog(title: String,
                            message: String,
                            buttonTitle: String = "OK",
                            onDismiss: (() -> Void)? = nil) -> CrystalAlertPanel {
        CrystalAlertPanel(
            title: title,
            message: message,
            buttons: [
                CrystalButtonConfig(title: buttonTitle,
                                    top: ChromaPalette.violetCore,
                                    bottom: ChromaPalette.cyanPulse,
                                    action: { onDismiss?() })
            ]
        )
    }
}
