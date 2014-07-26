local VERSION = "0.8.1"

local Isys_ThreatMeter = Apollo.GetPackage("DaiAddon-1.0").tPackage:NewAddon("Isys_ThreatMeter", true, {})
Isys_ThreatMeter.Version = VERSION

Isys_ThreatMeter.db = {
  nWarningSoundId       = 162,
  crNormalText          = "White",
  crPlayer              = "xkcdLavender",
  crPlayerPet           = "xkcdLightIndigo",
  crGroupMember         = "xkcdLightForestGreen",
  crNotPlayer           = "xkcdScarlet",
  nTPSWindow            = 10,
  fWarningThreshold     = 90,
  fWarningOpacity       = 100,
  fMainWindowOpacity    = 100,
  fArtWorkOpacity       = 100,
  bLockWarningWindow    = true,
  bLockMainWindow       = true,
  bShowWhenInGroup      = true,
  bShowWhenHavePet      = true,
  bShowWhenInRaid       = true,
  bShowWhenAlone        = false,
  bHideWhenNotInCombat  = true,
  bHideWhenInPvP        = true,
  bWarningUseSound      = true,
  bWarningUseMessage    = true,
  bWarningTankDisable   = true,
  bThreatTotalPrecision = false,
}