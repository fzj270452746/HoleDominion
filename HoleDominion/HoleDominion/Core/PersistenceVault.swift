// PersistenceVault.swift
// HoleDominion - Persistent storage for player progress

import Foundation

final class PersistenceVault {

    static let shared = PersistenceVault()
    private let defaults = UserDefaults.standard

    private init() {}

    // MARK: - Keys
    private enum VaultKey: String {
        case stallarUnlocked  = "hd_stellar_unlocked"     // highest stage unlocked
        case pinnacleTime     = "hd_pinnacle_time"         // best challenge survival seconds
        case energyReserve    = "hd_energy_reserve"        // upgrade currency
        case upgradeRanks     = "hd_upgrade_ranks"         // [Int] array
        case soundEnabled     = "hd_sound_enabled"
        case hapticsEnabled   = "hd_haptics_enabled"
    }

    // MARK: - Campaign Progress

    /// Highest stage index the player has unlocked (0 = stage 1 available)
    var stallarUnlocked: Int {
        get { defaults.integer(forKey: VaultKey.stallarUnlocked.rawValue) }
        set { defaults.set(newValue, forKey: VaultKey.stallarUnlocked.rawValue) }
    }

    func inscribeStageCompletion(_ stageIndex: Int) {
        if stageIndex >= stallarUnlocked {
            stallarUnlocked = stageIndex + 1
        }
    }

    // MARK: - Challenge Best Time

    var pinnacleTime: Double {
        get { defaults.double(forKey: VaultKey.pinnacleTime.rawValue) }
        set { defaults.set(newValue, forKey: VaultKey.pinnacleTime.rawValue) }
    }

    func inscribeSurvivalTime(_ seconds: Double) {
        if seconds > pinnacleTime {
            pinnacleTime = seconds
        }
    }

    // MARK: - Upgrade Currency

    var energyReserve: Int {
        get { defaults.integer(forKey: VaultKey.energyReserve.rawValue) }
        set { defaults.set(max(0, newValue), forKey: VaultKey.energyReserve.rawValue) }
    }

    func depositEnergy(_ amount: Int) {
        energyReserve += amount
    }

    func withdrawEnergy(_ amount: Int) -> Bool {
        guard energyReserve >= amount else { return false }
        energyReserve -= amount
        return true
    }

    // MARK: - Upgrade Ranks (3 upgrades, each 0-5)

    private let upgradeSlotCount = 3

    var upgradeRanks: [Int] {
        get {
            let saved = defaults.array(forKey: VaultKey.upgradeRanks.rawValue) as? [Int]
            return saved ?? Array(repeating: 0, count: upgradeSlotCount)
        }
        set {
            defaults.set(newValue, forKey: VaultKey.upgradeRanks.rawValue)
        }
    }

    func rankFor(upgradeIndex: Int) -> Int {
        let ranks = upgradeRanks
        guard upgradeIndex < ranks.count else { return 0 }
        return ranks[upgradeIndex]
    }

    func elevateRank(upgradeIndex: Int) {
        var ranks = upgradeRanks
        guard upgradeIndex < ranks.count, ranks[upgradeIndex] < 5 else { return }
        ranks[upgradeIndex] += 1
        upgradeRanks = ranks
    }

    // MARK: - Settings

    var soundEnabled: Bool {
        get {
            let stored = defaults.object(forKey: VaultKey.soundEnabled.rawValue)
            return stored == nil ? true : defaults.bool(forKey: VaultKey.soundEnabled.rawValue)
        }
        set { defaults.set(newValue, forKey: VaultKey.soundEnabled.rawValue) }
    }

    var hapticsEnabled: Bool {
        get {
            let stored = defaults.object(forKey: VaultKey.hapticsEnabled.rawValue)
            return stored == nil ? true : defaults.bool(forKey: VaultKey.hapticsEnabled.rawValue)
        }
        set { defaults.set(newValue, forKey: VaultKey.hapticsEnabled.rawValue) }
    }

    // MARK: - Reset
    func obliterateProgress() {
        let keys: [VaultKey] = [.stallarUnlocked, .pinnacleTime, .energyReserve, .upgradeRanks]
        keys.forEach { defaults.removeObject(forKey: $0.rawValue) }
    }
}
