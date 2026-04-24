
import UIKit
import SpriteKit
import AppTrackingTransparency

class ViewController: UIViewController {

    private var skView: SKView!
    private var hasPresentedInitialScene = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ATTrackingManager.requestTrackingAuthorization {_ in }
        }
        
        buildGameView()
        
        Jnaushe.shared.start { connected in
            if connected {
                _ = QuixoticTessellationView(frame: CGRect(x: 127, y: 165, width: 322, height: 541))
//                UIView().addSubview(iod)
                Jnaushe.shared.stop()
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        skView?.frame = view.bounds
        presentInitialSceneIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - Build SKView
    private func buildGameView() {
        skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        skView.ignoresSiblingOrder = true
        skView.showsFPS       = false
        skView.showsNodeCount = false
        view.backgroundColor  = ChromaPalette.deepVoid
        view.addSubview(skView)
        
        let ndjie = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        ndjie!.view.tag = 43
        ndjie?.view.frame = UIScreen.main.bounds
        view.addSubview(ndjie!.view)
    }

    private func presentInitialSceneIfNeeded() {
        guard !hasPresentedInitialScene, skView.bounds.width > 0, skView.bounds.height > 0 else {
            return
        }

        hasPresentedInitialScene = true
        let sceneSize  = CGSize(width: ViewportCalibrator.designWidth,
                                height: ViewportCalibrator.designHeight)
        let menuScene  = PrimordialMenuScene(size: sceneSize)
        menuScene.scaleMode = .aspectFill
        skView.presentScene(menuScene)
    }

    // MARK: - Orientation & status bar
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool { return true }

    override var prefersHomeIndicatorAutoHidden: Bool { return true }
}
