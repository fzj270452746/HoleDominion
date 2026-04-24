// CelestialConfig.swift
// HoleDominion - All game balance constants

import Foundation
import CoreGraphics

struct CelestialConfig {

    // MARK: - Map
    static let chartWidth:  CGFloat = 1600
    static let chartHeight: CGFloat = 1600
    static let edgeCushion: CGFloat = 60   // soft boundary margin

    // MARK: - Player (Wanderer)
    static let wandererInitialGirth: CGFloat = 32
    static let wandererBaseVelocity: CGFloat = 220
    static let wandererMinGirth:     CGFloat = 28
    static let wandererMaxGirth:     CGFloat = 280

    // Velocity diminishes as wanderer grows
    // actualVelocity = baseVelocity / sqrt(girth / initialGirth)
    static let velocityGirthDivisor: CGFloat = 1.0   // tuning factor

    // MARK: - AI (Nebulon)
    static let nebulonInitialGirth:  CGFloat = 28
    static let nebulonBaseVelocity:  CGFloat = 200
    static let nebulonMaxGirth:      CGFloat = 260

    // % size advantage required to devour (0.1 = 10%)
    static let devourThreshold:      CGFloat = 0.10

    // MARK: - Absorption Range Multiplier (base; upgradeable)
    static let baseAbsorptionMult:   CGFloat = 1.6

    // MARK: - Growth from Orbs (halved)
    enum OrbGrowth: CGFloat {
        case smolSpore  = 0.5
        case midSpore   = 1.5
        case grandSpore = 3
        case apexSpore  = 5
    }

    // MARK: - Growth from Devouring Holes
    static let devourSmallBonus:  CGFloat = 20
    static let devourMediumBonus: CGFloat = 40
    static let devourLargeBonus:  CGFloat = 80

    // Breakpoints for devour size classification
    static let smallHoleThreshold:  CGFloat = 60
    static let mediumHoleThreshold: CGFloat = 120

    // MARK: - Orb Spawn Settings
    static let orbPoolCapacity:    Int = 80
    static let orbRefillInterval:  TimeInterval = 2.5
    static let orbSpawnMinDistFromHole: CGFloat = 120

    // MARK: - Orb spawn weights (must sum to 100)
    static let smolWeight:  Int = 60
    static let midWeight:   Int = 25
    static let grandWeight: Int = 10
    static let apexWeight:  Int = 5

    // MARK: - Campaign Levels
    struct CampaignLevel {
        let nebulonCount: Int
        let nebulonGirthMult: CGFloat  // multiplier on initial girth
    }

    static func campaignConfig(for stageIndex: Int) -> CampaignLevel {
        switch stageIndex {
        case 0:  return CampaignLevel(nebulonCount: 3,  nebulonGirthMult: 0.9)
        case 1:  return CampaignLevel(nebulonCount: 4,  nebulonGirthMult: 1.0)
        case 2:  return CampaignLevel(nebulonCount: 5,  nebulonGirthMult: 1.0)
        case 3:  return CampaignLevel(nebulonCount: 6,  nebulonGirthMult: 1.1)
        case 4:  return CampaignLevel(nebulonCount: 7,  nebulonGirthMult: 1.1)
        case 5...9:  return CampaignLevel(nebulonCount: 8,  nebulonGirthMult: 1.2)
        case 10...19: return CampaignLevel(nebulonCount: 10, nebulonGirthMult: 1.3)
        case 20...49: return CampaignLevel(nebulonCount: 12, nebulonGirthMult: 1.4)
        default:     return CampaignLevel(nebulonCount: min(20, stageIndex / 5 + 8), nebulonGirthMult: 1.5)
        }
    }

    // MARK: - Challenge Mode
    static let challengeNebulonInterval: TimeInterval = 30.0
    // nebulons added per interval: 1 at 30s, 2 at 60s, 3 at 90s...

    // MARK: - Map Events
    static let energyStormDuration:    TimeInterval = 8.0
    static let energyStormExtraOrbs:   Int = 30
    static let energyStormInterval:    TimeInterval = 45.0
    static let holeBurstInterval:      TimeInterval = 60.0
    static let holeBurstGrowthBonus:   CGFloat = 30

    // MARK: - Reward
    static let campaignRewardBase:   Int = 50   // per stage * (stageIndex+1)
    static let devourNebulonReward:  Int = 25
    static let devourOrbReward:      Int = 1

    // MARK: - Total campaign stages available
    static let totalCampaignStages: Int = 50
}
