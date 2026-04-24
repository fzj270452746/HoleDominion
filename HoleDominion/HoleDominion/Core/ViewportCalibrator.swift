// ViewportCalibrator.swift
// HoleDominion - Screen-size adapter for iPhone and iPad compatibility

import UIKit

final class ViewportCalibrator {

    static let shared = ViewportCalibrator()
    private init() {}

    // Base design canvas (iPhone SE / 375pt wide portrait)
    static let designWidth:  CGFloat = 375
    static let designHeight: CGFloat = 812

    // MARK: - Screen metrics
    var screenSize: CGSize {
        UIApplication.shared.currentKeyWindow?.bounds.size ?? CGSize(width: 390, height: 844)
    }

    var isPortrait: Bool {
        screenSize.height >= screenSize.width
    }

    /// Effective game canvas - in portrait, uses screen width; on iPad uses scaled iPhone width
    var canvasSize: CGSize {
        let screen = screenSize
        // On iPad, constrain to a max width to avoid oversized UI
        let effectiveWidth = min(screen.width, screen.height, 430)
        let aspectRatio = ViewportCalibrator.designHeight / ViewportCalibrator.designWidth
        return CGSize(width: effectiveWidth, height: effectiveWidth * aspectRatio)
    }

    /// Scale factor from design size to actual screen
    var scaleRatio: CGFloat {
        screenSize.width / ViewportCalibrator.designWidth
    }

    /// Scaled point - converts design-space value to screen-space
    func calibrate(_ designValue: CGFloat) -> CGFloat {
        return designValue * scaleRatio
    }

    /// Font size calibrated to screen
    func fontSize(_ designSize: CGFloat) -> CGFloat {
        return max(designSize * scaleRatio, designSize * 0.8)
    }

    /// Safe area insets helper
    var safeInsets: UIEdgeInsets {
        UIApplication.shared.currentKeyWindow?.safeAreaInsets ?? .zero
    }

    var topSafeInset: CGFloat    { safeInsets.top }
    var bottomSafeInset: CGFloat { safeInsets.bottom }

    // MARK: - aspectFill visible rect helpers
    /// When a scene of `sceneSize` is presented with .aspectFill in a view of `viewSize`,
    /// the scene is scaled so its width fills the view. This returns how many scene-space
    /// points are cropped off the top (and bottom) due to the taller design canvas.
    func aspectFillCropY(sceneSize: CGSize, viewSize: CGSize) -> CGFloat {
        let scale = viewSize.width / sceneSize.width   // scale applied by aspectFill
        let visibleSceneH = viewSize.height / scale    // how many scene pts are visible vertically
        return max((sceneSize.height - visibleSceneH) / 2, 0)
    }

    /// Safe top Y in scene space: the highest visible Y minus the safe-area inset.
    /// Use this instead of `size.height - safeTopInset` for top-anchored elements.
    func visibleTopY(sceneSize: CGSize, viewSize: CGSize) -> CGFloat {
        let cropY = aspectFillCropY(sceneSize: sceneSize, viewSize: viewSize)
        let scale = viewSize.width / sceneSize.width
        let insetInScene = safeInsets.top / scale
        return sceneSize.height - cropY - insetInScene
    }

    /// Safe bottom Y in scene space: the lowest visible Y plus the safe-area inset.
    func visibleBottomY(sceneSize: CGSize, viewSize: CGSize) -> CGFloat {
        let cropY = aspectFillCropY(sceneSize: sceneSize, viewSize: viewSize)
        let scale = viewSize.width / sceneSize.width
        let insetInScene = safeInsets.bottom / scale
        return cropY + insetInScene
    }

    // MARK: - SKScene reference size
    /// The reference size used for all SKScenes (design space)
    var skReferenceSize: CGSize {
        ViewportCalibrator.designWidth > 0
            ? CGSize(width: ViewportCalibrator.designWidth,
                     height: ViewportCalibrator.designHeight)
            : CGSize(width: 375, height: 812)
    }

    // MARK: - Helpers for positioning in SKScene coordinate space
    /// Center of the SKScene
    var sceneCenter: CGPoint {
        CGPoint(x: ViewportCalibrator.designWidth / 2,
                y: ViewportCalibrator.designHeight / 2)
    }

    var sceneWidth:  CGFloat { ViewportCalibrator.designWidth }
    var sceneHeight: CGFloat { ViewportCalibrator.designHeight }
}
