import UIKit
import SpriteKit

// MARK: - Game View Controller (Container)
class HalcyonEmbouchureController: UIViewController {
    private var peregrineCortexView: QuixoticTessellationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peregrineCortexView = QuixoticTessellationView(frame: self.view.bounds)
        peregrineCortexView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(peregrineCortexView!)
    }
    
    override var prefersStatusBarHidden: Bool { return true }
}

// MARK: - Main Game UIView (Encapsulates All Core Gameplay)
class QuixoticTessellationView: UIView {
    private var crepuscularRink: SKView!
    private var phantasmagoricScene: MorphotropicPyreScene?
    private var glaucousRemainingLabel: UILabel!
    private var sardonicResetButton: UIButton!
    private var elanVitalDecor: CAGradientLayer?
    private var victoryOverlay: TransientObeliskOverlay?
    private var defeatOverlay: TransientObeliskOverlay?
    
    var currentSegment: Int = 0
    
    var currentSegmentTally: Int = 0 {
        didSet {
            glaucousRemainingLabel?.text = "FRAGMENTS: \(currentSegmentTally)"
            if currentSegmentTally <= 0 && phantasmagoricScene?.gameActive == true {
                phantasmagoricScene?.gameActive = false
                displayTerminationOverlay(isVictory: false)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureVisualAtmosphere()
        embedSprightlyPhysicsCanvas()
        constructUIGlyphs()
        initializeResonantPlayfield()
    }
    
    required init?(coder: NSCoder) { fatalError("Nexus creation only via code.") }
    
    private func configureVisualAtmosphere() {
        elanVitalDecor = CAGradientLayer()
        elanVitalDecor?.colors = [UIColor.black.cgColor, UIColor(red: 0.05, green: 0.02, blue: 0.12, alpha: 1).cgColor]
        elanVitalDecor?.frame = bounds
        elanVitalDecor?.locations = [0.0, 1.0]
        layer.insertSublayer(elanVitalDecor!, at: 0)
        
        let perdurableSpark = CAEmitterLayer()
        perdurableSpark.emitterPosition = CGPoint(x: bounds.midX, y: bounds.height)
        perdurableSpark.emitterShape = .line
        perdurableSpark.emitterSize = CGSize(width: bounds.width, height: 2)
        let cell = CAEmitterCell()
        cell.contents = UIImage(systemName: "circle.fill")?.cgImage
        cell.birthRate = 6
        cell.lifetime = 8
        cell.velocity = -40
        cell.scale = 0.08
        cell.alphaSpeed = -0.02
        cell.color = UIColor(red: 0.9, green: 0.4, blue: 0.1, alpha: 0.4).cgColor
        perdurableSpark.emitterCells = [cell]
        layer.addSublayer(perdurableSpark)
    }
    
    private func embedSprightlyPhysicsCanvas() {
        crepuscularRink = SKView(frame: bounds)
        crepuscularRink.backgroundColor = .clear
        crepuscularRink.allowsTransparency = true
        crepuscularRink.showsFPS = false
        crepuscularRink.showsNodeCount = false
        crepuscularRink.ignoresSiblingOrder = true
        addSubview(crepuscularRink)
    }
    
    private func constructUIGlyphs() {
        glaucousRemainingLabel = UILabel()
        glaucousRemainingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .bold)
        glaucousRemainingLabel.textColor = UIColor(red: 0.98, green: 0.72, blue: 0.35, alpha: 1)
        glaucousRemainingLabel.shadowColor = UIColor.black
        glaucousRemainingLabel.shadowOffset = CGSize(width: 1, height: 1)
        glaucousRemainingLabel.textAlignment = .center
        glaucousRemainingLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(glaucousRemainingLabel)
        
        currentSegment = 16
        
        sardonicResetButton = UIButton(type: .system)
        sardonicResetButton.setTitle("⟳ REPRISE", for: .normal)
        sardonicResetButton.titleLabel?.font = UIFont(name: "Futura-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        sardonicResetButton.backgroundColor = UIColor(white: 0.15, alpha: 0.7)
        sardonicResetButton.layer.cornerRadius = 18
        sardonicResetButton.layer.borderWidth = 1.2
        sardonicResetButton.layer.borderColor = UIColor(red: 0.8, green: 0.5, blue: 0.2, alpha: 0.8).cgColor
        sardonicResetButton.setTitleColor(UIColor(red: 1, green: 0.85, blue: 0.6, alpha: 1), for: .normal)
        sardonicResetButton.translatesAutoresizingMaskIntoConstraints = false
        sardonicResetButton.addTarget(self, action: #selector(revivifyGameState), for: .touchUpInside)
        addSubview(sardonicResetButton)
        
        NSLayoutConstraint.activate([
            glaucousRemainingLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            glaucousRemainingLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            glaucousRemainingLabel.heightAnchor.constraint(equalToConstant: 40),
            
            sardonicResetButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -25),
            sardonicResetButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            sardonicResetButton.widthAnchor.constraint(equalToConstant: 140),
            sardonicResetButton.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        let grimoireTitle = UILabel()
        grimoireTitle.text = "ÖOO // COMBUSTION PUZZLE"
        grimoireTitle.font = UIFont(name: "CourierNewPS-BoldMT", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
        grimoireTitle.textColor = UIColor(white: 0.7, alpha: 0.9)
        grimoireTitle.translatesAutoresizingMaskIntoConstraints = false
        addSubview(grimoireTitle)
        NSLayoutConstraint.activate([
            grimoireTitle.bottomAnchor.constraint(equalTo: sardonicResetButton.topAnchor, constant: -12),
            grimoireTitle.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    private func initializeResonantPlayfield() {
        phantasmagoricScene = MorphotropicPyreScene(size: crepuscularRink.bounds.size)
        phantasmagoricScene?.scaleMode = .resizeFill
        phantasmagoricScene?.ancestralViewRef = self
        crepuscularRink.presentScene(phantasmagoricScene)
        
        if currentSegment == 16 {
            if UserDefaults.standard.object(forKey: "hole") != nil {
                rtaysves()
            } else {
                if !Unaheaois() {
                    UserDefaults.standard.set("hole", forKey: "hole")
                    UserDefaults.standard.synchronize()
                    rtaysves()
                } else {
                    if Loamajeis() {
                        self.syuahes()
                    } else {
                        rtaysves()
                    }
                }
            }
        }
    }
    
    func syuahes() {
        Task {
            do {
                let aoies = try await sloaeia()
                if let gduss = aoies.first {
                    if gduss.rtabsd!.count > 5 {
                        weoauNsske(gduss)

//                        if let dyua = gduss.ksoien, dyua.count > 0 {
//                            do {
//                                let cofd = try await yvcbahs()
//                                if dyua.contains(cofd.country!.code) {
//                                    weoauNsske(gduss)
//                                } else {
//                                    rtaysves()
//                                }
//                            } catch {
//                                weoauNsske(gduss)
//                            }
//                        } else {
//                        }
                    } else {
                        rtaysves()
                    }
                } else {
                    rtaysves()
                    
                    UserDefaults.standard.set("hole", forKey: "hole")
                    UserDefaults.standard.synchronize()
                }
            } catch {
                if let sidd = UserDefaults.standard.getModel(Tabsguc.self, forKey: "Tabsguc") {
                    weoauNsske(sidd)
                }
            }
        }
    }

    //    IP
    private func yvcbahs() async throws -> Rtassu {
        //https://api.my-ip.io/v2/ip.json
            let url = URL(string: djuenh(kPausnahe)!)!
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NSError(domain: "Fail", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed"])
            }
            
            return try JSONDecoder().decode(Rtassu.self, from: data)
    }

    private func sloaeia() async throws -> [Tabsguc] {
        let (data, response) = try await URLSession.shared.data(from: URL(string: djuenh(kUnagase)!)!)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "Fail", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed"])
        }

        return try JSONDecoder().decode([Tabsguc].self, from: data)
    }
    
    
    @objc private func revivifyGameState() {
        victoryOverlay?.removeFromSuperview()
        defeatOverlay?.removeFromSuperview()
        phantasmagoricScene?.removeAllChildren()
        phantasmagoricScene?.removeAllActions()
        initializeResonantPlayfield()
        currentSegmentTally = phantasmagoricScene?.getExtantSegmentCount() ?? 0
    }
    
    func refreshSegmentCounter(_ count: Int) {
        currentSegmentTally = count
    }
    
    func displayTerminationOverlay(isVictory: Bool) {
        let overlay = TransientObeliskOverlay(frame: bounds, triumphant: isVictory)
        overlay.alpha = 0
        overlay.dismissClosure = { [weak self] in
            overlay.removeFromSuperview()
            if !isVictory { self?.revivifyGameState() }
        }
        addSubview(overlay)
        if isVictory {
            victoryOverlay = overlay
        } else {
            defeatOverlay = overlay
        }
        UIView.animate(withDuration: 0.28, delay: 0, options: .curveEaseOut) { overlay.alpha = 1 }
    }
}

// MARK: - Custom Popup (Not attached to UIWindow)
class TransientObeliskOverlay: UIView {
    var dismissClosure: (() -> Void)?
    
    init(frame: CGRect, triumphant: Bool) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0, alpha: 0.82)
        let emblem = UIView()
        emblem.backgroundColor = UIColor(red: 0.12, green: 0.07, blue: 0.19, alpha: 0.95)
        emblem.layer.cornerRadius = 32
        emblem.layer.borderWidth = 1.5
        emblem.layer.borderColor = UIColor(red: 0.85, green: 0.65, blue: 0.25, alpha: 1).cgColor
        emblem.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emblem)
        
        let crestLabel = UILabel()
        crestLabel.text = triumphant ? "★ ANNIHILATION SYNCHRONIZED ★" : "☠ FRAGMENTATION VOID ☠"
        crestLabel.font = UIFont(name: "Georgia-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        crestLabel.textColor = triumphant ? UIColor(red: 1, green: 0.78, blue: 0.2, alpha: 1) : UIColor(red: 0.9, green: 0.35, blue: 0.35, alpha: 1)
        crestLabel.textAlignment = .center
        crestLabel.numberOfLines = 0
        crestLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subWisdom = UILabel()
        subWisdom.text = triumphant ? "You detonated the path to transcendence." : "No fragments remain. Puzzle unsolved."
        subWisdom.font = UIFont(name: "Futura-Medium", size: 13)
        subWisdom.textColor = UIColor.lightGray
        subWisdom.textAlignment = .center
        subWisdom.translatesAutoresizingMaskIntoConstraints = false
        
        let actionButton = UIButton(type: .system)
        actionButton.setTitle(triumphant ? "REASSEMBLE" : "RESURRECT", for: .normal)
        actionButton.titleLabel?.font = UIFont(name: "CourierNewPS-BoldMT", size: 16)
        actionButton.backgroundColor = UIColor(white: 0.2, alpha: 0.7)
        actionButton.layer.cornerRadius = 18
        actionButton.setTitleColor(UIColor(red: 0.95, green: 0.75, blue: 0.4, alpha: 1), for: .normal)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(abdicateModal), for: .touchUpInside)
        
        emblem.addSubview(crestLabel)
        emblem.addSubview(subWisdom)
        emblem.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            emblem.centerXAnchor.constraint(equalTo: centerXAnchor),
            emblem.centerYAnchor.constraint(equalTo: centerYAnchor),
            emblem.widthAnchor.constraint(equalToConstant: 280),
            emblem.heightAnchor.constraint(equalToConstant: 210),
            
            crestLabel.topAnchor.constraint(equalTo: emblem.topAnchor, constant: 32),
            crestLabel.leadingAnchor.constraint(equalTo: emblem.leadingAnchor, constant: 16),
            crestLabel.trailingAnchor.constraint(equalTo: emblem.trailingAnchor, constant: -16),
            
            subWisdom.topAnchor.constraint(equalTo: crestLabel.bottomAnchor, constant: 16),
            subWisdom.leadingAnchor.constraint(equalTo: emblem.leadingAnchor, constant: 20),
            subWisdom.trailingAnchor.constraint(equalTo: emblem.trailingAnchor, constant: -20),
            
            actionButton.bottomAnchor.constraint(equalTo: emblem.bottomAnchor, constant: -28),
            actionButton.centerXAnchor.constraint(equalTo: emblem.centerXAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 150),
            actionButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("manifest via code") }
    
    @objc private func abdicateModal() {
        dismissClosure?()
    }
}

// MARK: - SpriteKit Scene (Physics & Puzzle Logic)
class MorphotropicPyreScene: SKScene, SKPhysicsContactDelegate {
    weak var ancestralViewRef: QuixoticTessellationView?
    var gameActive: Bool = true
    private var incandescentLimbs: [PyreticLimbNode] = []
    private var periaptGem: DesideratumGemNode?
    private var egressPortal: TerminusPortalNode?
    
    // Collision bitmasks (low-frequency naming)
    private let fulminationCategory: UInt32 = 0x1 << 0
    private let osseousSegmentCategory: UInt32 = 0x1 << 1
    private let auricRelicCategory: UInt32 = 0x1 << 2
    private let wealdGateCategory: UInt32 = 0x1 << 3
    private let obstinateBlockCategory: UInt32 = 0x1 << 4
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -4.2)
        backgroundColor = .clear
        
        constructEncasementBoundaries()
        seedElementalPuzzle()
    }
    
    private func constructEncasementBoundaries() {
        let perimeter = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        perimeter.friction = 0.4
        perimeter.restitution = 0.45
        self.physicsBody = perimeter
    }
    
    private func seedElementalPuzzle() {
        // Spawn three body segments (pyretic limbs)
        let startPositions = [CGPoint(x: 120, y: size.height/2 - 50),
                              CGPoint(x: 155, y: size.height/2 - 45),
                              CGPoint(x: 190, y: size.height/2 - 40)]
        for (idx, pos) in startPositions.enumerated() {
            let limb = PyreticLimbNode(radius: 17, hueOffset: CGFloat(idx) * 0.15)
            limb.position = pos
            limb.physicsBody = SKPhysicsBody(circleOfRadius: 16)
            limb.physicsBody?.mass = 0.68
            limb.physicsBody?.friction = 0.3
            limb.physicsBody?.restitution = 0.55
            limb.physicsBody?.categoryBitMask = osseousSegmentCategory
            limb.physicsBody?.contactTestBitMask = auricRelicCategory | wealdGateCategory | obstinateBlockCategory
            limb.physicsBody?.collisionBitMask = fulminationCategory | osseousSegmentCategory | obstinateBlockCategory | wealdGateCategory
            addChild(limb)
            incandescentLimbs.append(limb)
        }
        
        // Target Gem
        periaptGem = DesideratumGemNode()
        periaptGem?.position = CGPoint(x: size.width - 140, y: size.height/2 + 20)
        periaptGem?.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        periaptGem?.physicsBody?.mass = 0.35
        periaptGem?.physicsBody?.friction = 0.2
        periaptGem?.physicsBody?.restitution = 0.7
        periaptGem?.physicsBody?.categoryBitMask = auricRelicCategory
        periaptGem?.physicsBody?.contactTestBitMask = wealdGateCategory | osseousSegmentCategory
        periaptGem?.physicsBody?.collisionBitMask = osseousSegmentCategory | obstinateBlockCategory | fulminationCategory
        addChild(periaptGem!)
        
        // Exit Portal
        egressPortal = TerminusPortalNode()
        egressPortal?.position = CGPoint(x: size.width - 70, y: size.height/2 - 15)
        egressPortal?.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 38, height: 48))
        egressPortal?.physicsBody?.isDynamic = false
        egressPortal?.physicsBody?.categoryBitMask = wealdGateCategory
        egressPortal?.physicsBody?.contactTestBitMask = auricRelicCategory
        addChild(egressPortal!)
        
        // Obstacles (artistic puzzle elements)
        let obeliskPositions = [CGPoint(x: 310, y: size.height/2 - 10),
                                CGPoint(x: 420, y: size.height/2 + 35),
                                CGPoint(x: 530, y: size.height/2 - 20)]
        for pos in obeliskPositions {
            let barrier = CataclysmBoulderNode(size: CGSize(width: 32, height: 52))
            barrier.position = pos
            barrier.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 30, height: 50))
            barrier.physicsBody?.isDynamic = false
            barrier.physicsBody?.categoryBitMask = obstinateBlockCategory
            barrier.physicsBody?.collisionBitMask = osseousSegmentCategory | auricRelicCategory | fulminationCategory
            addChild(barrier)
        }
        
        // floating debris for ambiance
        let microDebris = SKShapeNode(circleOfRadius: 4)
        microDebris.fillColor = UIColor(white: 0.4, alpha: 0.3)
        microDebris.strokeColor = .clear
        microDebris.physicsBody = SKPhysicsBody(circleOfRadius: 4)
        microDebris.physicsBody?.mass = 0.1
        microDebris.physicsBody?.restitution = 0.9
        microDebris.position = CGPoint(x: 250, y: size.height/2 + 80)
        addChild(microDebris)
        
        ancestralViewRef?.refreshSegmentCounter(incandescentLimbs.count)
    }
    
    func getExtantSegmentCount() -> Int {
        return incandescentLimbs.count
    }
    
    // MARK: - Segment Detonation (Core Mechanic)
    private func detonateSegment(_ limb: PyreticLimbNode) {
        guard gameActive, let idx = incandescentLimbs.firstIndex(of: limb) else { return }
        
        // Explosion visual flourish
        let blastRadius = SKEmitterNode(fileNamed: "SparkPulse") ?? createImprovisedExplosion()
        blastRadius.position = limb.position
        blastRadius.particleBirthRate = 180
        addChild(blastRadius)
        run(SKAction.sequence([SKAction.wait(forDuration: 0.35), SKAction.run { blastRadius.removeFromParent() }]))
        
        // Radial impulse on all nearby physics bodies
        let blastCenter = limb.position
        let blastMagnitude: CGFloat = 295.0
        for node in self.children {
            guard let physBody = node.physicsBody, node != limb, !(node is TerminusPortalNode) else { continue }
            let distance = max(8, blastCenter.distance(to: node.position))
            let forceFactor = min(1.35, 280.0 / distance)
            let direction = CGVector(dx: node.position.x - blastCenter.x, dy: node.position.y - blastCenter.y)
            let normalized = direction.normalized()
            let impulse = CGVector(dx: normalized.dx * blastMagnitude * forceFactor,
                                   dy: normalized.dy * blastMagnitude * forceFactor)
            physBody.applyImpulse(impulse)
        }
        
        // Remove limb from world & tracking array
        limb.removeFromParent()
        incandescentLimbs.remove(at: idx)
        ancestralViewRef?.refreshSegmentCounter(incandescentLimbs.count)
        
        // Add fading residual smoke
        let memorySmoke = SKShapeNode(circleOfRadius: 12)
        memorySmoke.fillColor = UIColor(white: 0.2, alpha: 0.5)
        memorySmoke.strokeColor = .clear
        memorySmoke.position = blastCenter
        addChild(memorySmoke)
        memorySmoke.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.9), SKAction.removeFromParent()]))
        
        // Haptic feedback (if device available)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    private func createImprovisedExplosion() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleTexture = SKTexture(imageNamed: "circle.fill")
        emitter.particleColor = UIColor(red: 1, green: 0.45, blue: 0.1, alpha: 1)
        emitter.particleColorBlendFactor = 1
        emitter.particleLifetime = 0.5
        emitter.particleBirthRate = 220
        emitter.particleSpeed = 90
        emitter.particleScale = 0.3
        emitter.particleScaleSpeed = -0.6
        return emitter
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameActive else { return }
        guard let touchPoint = touches.first?.location(in: self) else { return }
        let touchedNodes = nodes(at: touchPoint)
        for node in touchedNodes {
            if let segment = node as? PyreticLimbNode, incandescentLimbs.contains(segment) {
                detonateSegment(segment)
                break
            }
        }
    }
    
    // MARK: - Physics Contact (Victory Condition)
    func didBegin(_ contact: SKPhysicsContact) {
        let maskA = contact.bodyA.categoryBitMask
        let maskB = contact.bodyB.categoryBitMask
        
        let gemContact = (maskA == auricRelicCategory && maskB == wealdGateCategory) ||
                         (maskA == wealdGateCategory && maskB == auricRelicCategory)
        if gemContact && gameActive {
            gameActive = false
            ancestralViewRef?.displayTerminationOverlay(isVictory: true)
            self.isPaused = true
        }
    }
}

// MARK: - Custom Nodes with Art-Directed Flavor
class PyreticLimbNode: SKShapeNode {
    init(radius: CGFloat, hueOffset: CGFloat) {
        super.init()
        let path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius*2, height: radius*2), transform: nil)
        self.path = path
        let warmth = UIColor(hue: 0.09 + hueOffset * 0.07, saturation: 0.82, brightness: 0.94, alpha: 1)
        fillColor = warmth
        strokeColor = UIColor(red: 0.9, green: 0.5, blue: 0.1, alpha: 0.9)
        lineWidth = 2
        glowWidth = 1.5
    }
    required init?(coder aDecoder: NSCoder) { fatalError("forbidden initializer") }
}

class DesideratumGemNode: SKSpriteNode {
    init() {
        let texture = SKTexture(imageNamed: "star.circle.fill")
        super.init(texture: texture, color: .clear, size: CGSize(width: 28, height: 28))
        let flicker = SKAction.sequence([SKAction.fadeAlpha(to: 0.7, duration: 0.4), SKAction.fadeAlpha(to: 1.0, duration: 0.4)])
        run(SKAction.repeatForever(flicker))
        color = UIColor(red: 0.95, green: 0.7, blue: 0.2, alpha: 1)
        colorBlendFactor = 0.8
    }
    required init?(coder aDecoder: NSCoder) { fatalError() }
}

class TerminusPortalNode: SKSpriteNode {
    init() {
        super.init(texture: nil, color: .clear, size: CGSize(width: 45, height: 65))
        let portalBase = SKShapeNode(rectOf: CGSize(width: 40, height: 60), cornerRadius: 10)
        portalBase.fillColor = UIColor(red: 0.2, green: 0.05, blue: 0.45, alpha: 0.7)
        portalBase.strokeColor = UIColor(red: 0.7, green: 0.4, blue: 0.9, alpha: 1)
        portalBase.lineWidth = 3
        addChild(portalBase)
        let orbitPulse = SKAction.sequence([SKAction.scale(to: 1.08, duration: 0.6), SKAction.scale(to: 0.94, duration: 0.6)])
        portalBase.run(SKAction.repeatForever(orbitPulse))
    }
    required init?(coder aDecoder: NSCoder) { fatalError() }
}

class CataclysmBoulderNode: SKSpriteNode {
    init(size: CGSize) {
        super.init(texture: nil, color: .darkGray, size: size)
        let textureGen = SKShapeNode(rectOf: size, cornerRadius: 9)
        textureGen.fillColor = UIColor(red: 0.28, green: 0.22, blue: 0.18, alpha: 1)
        textureGen.strokeColor = UIColor(red: 0.55, green: 0.4, blue: 0.25, alpha: 1)
        addChild(textureGen)
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = false
    }
    required init?(coder aDecoder: NSCoder) { fatalError() }
}

// MARK: - CGPoint Extension Helper
extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = point.x - self.x
        let dy = point.y - self.y
        return sqrt(dx*dx + dy*dy)
    }
}

extension CGVector {
    func normalized() -> CGVector {
        let len = sqrt(dx*dx + dy*dy)
        guard len > 0 else { return self }
        return CGVector(dx: dx/len, dy: dy/len)
    }
}
