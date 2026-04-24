// AscendantUpgradeSystem.swift
// HoleDominion - Upgrade management and application

import Foundation
import UIKit

enum AscendantUpgradeType: Int, CaseIterable {
    case vortexReach   = 0    // absorption range
    case driftCelerity = 1    // movement speed
    case massAmplifier = 2    // growth efficiency
}

struct AscendantUpgradeInfo {
    let type:         AscendantUpgradeType
    let displayTitle: String
    let briefDetail:  String
    let iconName:     String
    let accentColor:  UIColor
}

final class AscendantUpgradeSystem {

    static let shared = AscendantUpgradeSystem()
    private init() {}

    // Max ranks
    static let maxRank = 5

    // MARK: - Cost ladder
    private let rankCostLadder: [Int] = [100, 200, 400, 800, 1600]

    func rankCost(for type: AscendantUpgradeType, atRank rank: Int) -> Int {
        guard rank < rankCostLadder.count else { return 9999 }
        return rankCostLadder[rank]
    }

    func nextUpgradeCost(for type: AscendantUpgradeType) -> Int? {
        let currentRank = PersistenceVault.shared.rankFor(upgradeIndex: type.rawValue)
        guard currentRank < AscendantUpgradeSystem.maxRank else { return nil }
        return rankCost(for: type, atRank: currentRank)
    }

    // MARK: - Purchase
    @discardableResult
    func attemptPurchase(type: AscendantUpgradeType) -> Bool {
        let currentRank = PersistenceVault.shared.rankFor(upgradeIndex: type.rawValue)
        guard currentRank < AscendantUpgradeSystem.maxRank else { return false }
        let cost = rankCost(for: type, atRank: currentRank)
        guard PersistenceVault.shared.withdrawEnergy(cost) else { return false }
        PersistenceVault.shared.elevateRank(upgradeIndex: type.rawValue)
        return true
    }

    // MARK: - Applied bonus values

    /// Extra absorption range multiplier (additive)
    var absorptionRangeBonus: CGFloat {
        let rank = CGFloat(PersistenceVault.shared.rankFor(upgradeIndex: AscendantUpgradeType.vortexReach.rawValue))
        return rank * 0.12    // +12% per rank
    }

    /// Extra velocity (flat pts/s)
    var velocityBonus: CGFloat {
        let rank = CGFloat(PersistenceVault.shared.rankFor(upgradeIndex: AscendantUpgradeType.driftCelerity.rawValue))
        return rank * 14      // +14 per rank
    }

    /// Growth multiplier
    var growthBonusRate: CGFloat {
        let rank = CGFloat(PersistenceVault.shared.rankFor(upgradeIndex: AscendantUpgradeType.massAmplifier.rawValue))
        return 1.0 + rank * 0.10   // +10% per rank
    }

    // MARK: - Metadata for UI
    var allUpgradeInfo: [AscendantUpgradeInfo] {
        [
            AscendantUpgradeInfo(
                type: .vortexReach,
                displayTitle: "Vortex Reach",
                briefDetail: "+12% absorption range per level",
                iconName: "upgrade_absorption_range",
                accentColor: ChromaPalette.cyanPulse
            ),
            AscendantUpgradeInfo(
                type: .driftCelerity,
                displayTitle: "Drift Celerity",
                briefDetail: "+14 movement speed per level",
                iconName: "upgrade_movement_speed",
                accentColor: ChromaPalette.auroraBlue
            ),
            AscendantUpgradeInfo(
                type: .massAmplifier,
                displayTitle: "Mass Amplifier",
                briefDetail: "+10% growth efficiency per level",
                iconName: "upgrade_growth_efficiency",
                accentColor: ChromaPalette.solargold
            )
        ]
    }

    // MARK: - Apply to wanderer
    func applyAllBonuses(to wanderer: WandererNode) {
        wanderer.velocityBonus    = velocityBonus
        wanderer.absorptionBonus  = absorptionRangeBonus
        wanderer.growthBonusRate  = growthBonusRate
        wanderer.applyAbsorptionBonus()
    }
}
