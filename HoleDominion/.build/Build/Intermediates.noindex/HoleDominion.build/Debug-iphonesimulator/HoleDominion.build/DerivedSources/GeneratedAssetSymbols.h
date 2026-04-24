#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "ai_hole" asset catalog image resource.
static NSString * const ACImageNameAiHole AC_SWIFT_PRIVATE = @"ai_hole";

/// The "energy_orb_large" asset catalog image resource.
static NSString * const ACImageNameEnergyOrbLarge AC_SWIFT_PRIVATE = @"energy_orb_large";

/// The "energy_orb_medium" asset catalog image resource.
static NSString * const ACImageNameEnergyOrbMedium AC_SWIFT_PRIVATE = @"energy_orb_medium";

/// The "energy_orb_small" asset catalog image resource.
static NSString * const ACImageNameEnergyOrbSmall AC_SWIFT_PRIVATE = @"energy_orb_small";

/// The "energy_orb_super" asset catalog image resource.
static NSString * const ACImageNameEnergyOrbSuper AC_SWIFT_PRIVATE = @"energy_orb_super";

/// The "event_energy_storm" asset catalog image resource.
static NSString * const ACImageNameEventEnergyStorm AC_SWIFT_PRIVATE = @"event_energy_storm";

/// The "event_hole_burst_aura" asset catalog image resource.
static NSString * const ACImageNameEventHoleBurstAura AC_SWIFT_PRIVATE = @"event_hole_burst_aura";

/// The "player_hole" asset catalog image resource.
static NSString * const ACImageNamePlayerHole AC_SWIFT_PRIVATE = @"player_hole";

/// The "upgrade_absorption_range" asset catalog image resource.
static NSString * const ACImageNameUpgradeAbsorptionRange AC_SWIFT_PRIVATE = @"upgrade_absorption_range";

/// The "upgrade_growth_efficiency" asset catalog image resource.
static NSString * const ACImageNameUpgradeGrowthEfficiency AC_SWIFT_PRIVATE = @"upgrade_growth_efficiency";

/// The "upgrade_movement_speed" asset catalog image resource.
static NSString * const ACImageNameUpgradeMovementSpeed AC_SWIFT_PRIVATE = @"upgrade_movement_speed";

#undef AC_SWIFT_PRIVATE
