// NexusButton.swift
// HoleDominion - Custom gradient SKNode button

import SpriteKit

final class NexusButton: SKNode {

    // MARK: - Properties
    var onTap: (() -> Void)?
    private var bgNode:     SKShapeNode!
    private var labelNode:  SKLabelNode!
    private var shadowNode: SKLabelNode!
    private var iconNode:   SKSpriteNode?

    private let buttonSize: CGSize
    private let gradientTop: UIColor
    private let gradientBot: UIColor

    // MARK: - Init
    init(title: String,
         size: CGSize = CGSize(width: 220, height: 52),
         gradientTop: UIColor = ChromaPalette.violetCore,
         gradientBot: UIColor = ChromaPalette.cyanPulse,
         iconName: String? = nil) {

        self.buttonSize   = size
        self.gradientTop  = gradientTop
        self.gradientBot  = gradientBot
        super.init()
        isUserInteractionEnabled = true
        assembleButton(title: title, iconName: iconName)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Build
    private func assembleButton(title: String, iconName: String?) {
        bgNode = SKShapeNode(rectOf: buttonSize, cornerRadius: 16)
        bgNode.fillColor      = gradientBot
        bgNode.strokeColor    = .white.withAlphaComponent(0.35)
        bgNode.lineWidth      = 1.5
        bgNode.zPosition      = 0

        // Inner glow
        let glow = SKShapeNode(rectOf: CGSize(width: buttonSize.width - 4,
                                              height: buttonSize.height - 4),
                               cornerRadius: 14)
        glow.fillColor   = .clear
        glow.strokeColor = .white.withAlphaComponent(0.25)
        glow.lineWidth   = 2
        glow.zPosition   = 1
        bgNode.addChild(glow)
        addChild(bgNode)

        // Optional icon
        if let iconName = iconName {
            let icon = SKSpriteNode(imageNamed: iconName)
            let iconSize: CGFloat = buttonSize.height * 0.55
            icon.size = CGSize(width: iconSize, height: iconSize)
            icon.position = CGPoint(x: -(buttonSize.width / 2) + iconSize * 0.9, y: 0)
            icon.zPosition = 2
            bgNode.addChild(icon)
            iconNode = icon
        }

        // Label — use system font when title contains non-ASCII (emoji/symbols) so iOS 26 renders them correctly
        let btnFontName = "HelveticaNeue-Bold"
        labelNode = SKLabelNode(fontNamed: btnFontName)
        labelNode.text                  = title
        labelNode.fontSize              = 17
        labelNode.fontColor             = ChromaPalette.crystalWhite
        labelNode.verticalAlignmentMode = .center
        labelNode.horizontalAlignmentMode = .center
        labelNode.zPosition             = 2
        bgNode.addChild(labelNode)

        // Shadow text
        let shadow = SKLabelNode(fontNamed: btnFontName)
        shadow.text                     = title
        shadow.fontSize                 = 17
        shadow.fontColor                = UIColor.black.withAlphaComponent(0.3)
        shadow.verticalAlignmentMode    = .center
        shadow.horizontalAlignmentMode  = .center
        shadow.position                 = CGPoint(x: 1, y: -1)
        shadow.zPosition                = 1
        bgNode.addChild(shadow)
        shadowNode = shadow
    }

    // MARK: - Gradient texture factory
    static func buildGradientTexture(size: CGSize,
                                     top: UIColor,
                                     bottom: UIColor,
                                     cornerRadius: CGFloat) -> SKTexture {
        let safeSize = CGSize(width: max(size.width, 1), height: max(size.height, 1))
        let renderer = UIGraphicsImageRenderer(size: safeSize)
        let img = renderer.image { ctx in
            let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: safeSize),
                                    cornerRadius: min(cornerRadius, min(safeSize.width, safeSize.height) / 2))
            ctx.cgContext.addPath(path.cgPath)
            ctx.cgContext.clip()

            let colors   = [top.cgColor, bottom.cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                      colors: colors as CFArray,
                                      locations: [0, 1])!
            ctx.cgContext.drawLinearGradient(gradient,
                                             start: CGPoint(x: 0, y: 0),
                                             end:   CGPoint(x: 0, y: safeSize.height),
                                             options: [])
        }
        return SKTexture(image: img)
    }

    // MARK: - Touch handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        bgNode.setScale(0.94)
        bgNode.alpha = 0.88
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        bgNode.removeAllActions()
        bgNode.setScale(1.0)
        bgNode.alpha = 1.0
        onTap?()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        bgNode.setScale(1.0)
        bgNode.alpha = 1.0
    }

    // MARK: - Disabled state
    func setEnabled(_ enabled: Bool) {
        isUserInteractionEnabled = enabled
        bgNode.alpha = enabled ? 1.0 : 0.42
    }

    // MARK: - Update label
    func updateTitle(_ text: String) {
        labelNode.fontName  = "HelveticaNeue-Bold"
        shadowNode.fontName = "HelveticaNeue-Bold"
        labelNode.text  = text
        shadowNode.text = text
    }
}
