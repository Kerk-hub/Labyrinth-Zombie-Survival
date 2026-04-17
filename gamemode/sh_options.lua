-- zombie escape primary weapons
GM.ZombieEscapeWeaponsPrimary = {
	"weapon_zs_zeakbar",
	"weapon_zs_zesweeper",
	"weapon_zs_zesmg",
	"weapon_zs_zeinferno",
	"weapon_zs_zestubber",
	"weapon_zs_zebulletstorm",
	"weapon_zs_zesilencer",
	"weapon_zs_zequicksilver",
	"weapon_zs_zeamigo",
	"weapon_zs_zem4",
}

-- zombie escape secondary weapons
GM.ZombieEscapeWeaponsSecondary = {
	"weapon_zs_zedeagle",
	"weapon_zs_zebattleaxe",
	"weapon_zs_zeeraser",
	"weapon_zs_zeglock",
	"weapon_zs_zetempest",
}

-- Change this if you plan to alter the cost of items or you severely change how Worth works.
-- Having separate cart files allows people to have separate loadouts for different servers.
GM.CartFile = "zscarts.txt"
GM.SkillLoadoutsFile = "zsskloadouts.txt"

-- item category constants
ITEMS_GUNS = 1
ITEMS_AMMO = 2
ITEMS_MELEE = 3
ITEMS_TOOLS = 4
ITEMS_DEPLOYABLES = 5
ITEMS_TRINKETS = 6
ITEMS_OTHER = 7

GM.ItemCategories = {
	[ITEMS_GUNS] = "Guns",
	[ITEMS_AMMO] = "Ammunition",
	[ITEMS_MELEE] = "Melee",
	[ITEMS_TOOLS] = "Tools",
	[ITEMS_DEPLOYABLES] = "Deployables",
	[ITEMS_TRINKETS] = "Trinkets",
	[ITEMS_OTHER] = "Other",
}

-- trinket item subcategories
TRINKETS_DEFENSIVE = 1
TRINKETS_OFFENSIVE = 2
TRINKETS_MELEE = 3
TRINKETS_PERFORMANCE = 4
TRINKETS_SUPPORT = 5
TRINKETS_SPECIAL = 6

GM.ItemSubCategories = {
	[TRINKETS_DEFENSIVE] = "Defensive",
	[TRINKETS_OFFENSIVE] = "Offensive",
	[TRINKETS_MELEE] = "Melee",
	[TRINKETS_PERFORMANCE] = "Performance",
	[TRINKETS_SUPPORT] = "Support",
	[TRINKETS_SPECIAL] = "Special",
}

--[[
Humans select what weapons (or other things) they want to start with and can even save favorites. Each object has a number of 'Worth' points.
Signature is a unique signature to give in case the item is renamed or reordered. Don't use a number or a string number!
A human can only use 100 points (default) when they join. Redeeming or joining late starts you out with a random loadout from above.
SWEP is a swep given when the player spawns with that perk chosen.
Callback is a function called. Model is a display model. If model isn't defined then the SWEP model will try to be used.
swep, callback, and model can all be nil or empty
]]
GM.Items = {}
function GM:AddItem(signature, category, price, swep, name, desc, model, callback)
	local tab = {
		Signature = signature,
		Name = name or "?",
		Description = desc,
		Category = category,
		Price = price or 0,
		SWEP = swep,
		Callback = callback,
		Model = model,
	}

	tab.Worth = tab.Price -- compat

	self.Items[#self.Items + 1] = tab
	self.Items[signature] = tab

	return tab
end

-- function for adding a new worth menu item
function GM:WorthAdd(signature, category, price, swep, name, desc, model, callback)
	local item = self:AddItem(signature, category, price, swep, name, desc, model, callback)
	item.WorthShop = true

	return item
end

-- function for adding a new arsenal crate item
function GM:ShopAdd(signature, category, price, swep, name, desc, model, callback)
	local item = self:AddItem("ps_" .. signature, category, price, swep, name, desc, model, callback)
	item.PointShop = true

	return item
end

-- How much ammo is considered one 'clip' of ammo? For use with setting up weapon defaults. Works directly with zs_survivalclips
GM.AmmoCache = {}
GM.AmmoCache["ar2"] = 32 -- Assault rifles.
GM.AmmoCache["alyxgun"] = 24 -- Not used.
GM.AmmoCache["pistol"] = 14 -- Pistols.
GM.AmmoCache["smg1"] = 36 -- SMG's and some rifles.
GM.AmmoCache["357"] = 8 -- Rifles, especially of the sniper variety.
GM.AmmoCache["xbowbolt"] = 8 -- Crossbows
GM.AmmoCache["buckshot"] = 12 -- Shotguns
GM.AmmoCache["ar2altfire"] = 1 -- Not used.
GM.AmmoCache["slam"] = 1 -- Force Field Emitters.
GM.AmmoCache["rpg_round"] = 1 -- Not used. Rockets?
GM.AmmoCache["smg1_grenade"] = 1 -- Not used.
GM.AmmoCache["sniperround"] = 1 -- Barricade Kit
GM.AmmoCache["sniperpenetratedround"] = 1 -- Remote Det pack.
GM.AmmoCache["grenade"] = 1 -- Grenades.
GM.AmmoCache["thumper"] = 1 -- Gun turret.
GM.AmmoCache["gravity"] = 1 -- Unused.
GM.AmmoCache["battery"] = 23 -- Used with the Medical Kit.
GM.AmmoCache["gaussenergy"] = 2 -- Nails used with the Carpenter's Hammer.
GM.AmmoCache["combinecannon"] = 1 -- Not used.
GM.AmmoCache["airboatgun"] = 1 -- Arsenal crates.
GM.AmmoCache["striderminigun"] = 1 -- Message beacons.
GM.AmmoCache["helicoptergun"] = 1 -- Resupply boxes.
GM.AmmoCache["spotlamp"] = 1
GM.AmmoCache["manhack"] = 1
GM.AmmoCache["repairfield"] = 1
GM.AmmoCache["zapper"] = 1
GM.AmmoCache["pulse"] = 30
GM.AmmoCache["impactmine"] = 3
GM.AmmoCache["chemical"] = 20
GM.AmmoCache["flashbomb"] = 1
GM.AmmoCache["turret_buckshot"] = 1
GM.AmmoCache["turret_assault"] = 1
GM.AmmoCache["scrap"] = 3

GM.AmmoResupply = table.ToAssoc({
	"ar2","pistol","smg1","357","xbowbolt",
	"buckshot","battery","pulse","impactmine",
	"chemical","gaussenergy","scrap",
})

-----------
-- Worth --
-----------
GM:WorthAdd("pshtr", ITEMS_GUNS, 45, "weapon_zs_peashooter")
GM:WorthAdd("btlax", ITEMS_GUNS, 45, "weapon_zs_battleaxe")
GM:WorthAdd("owens", ITEMS_GUNS, 45, "weapon_zs_owens")
GM:WorthAdd("blstr", ITEMS_GUNS, 45, "weapon_zs_blaster")
GM:WorthAdd("tossr", ITEMS_GUNS, 45, "weapon_zs_tosser")
GM:WorthAdd("stbbr", ITEMS_GUNS, 45, "weapon_zs_stubber")
GM:WorthAdd("crklr", ITEMS_GUNS, 45, "weapon_zs_crackler")
GM:WorthAdd("sling", ITEMS_GUNS, 45, "weapon_zs_slinger")
GM:WorthAdd("z9000", ITEMS_GUNS, 45, "weapon_zs_z9000")
GM:WorthAdd("minelayer", ITEMS_GUNS, 60, "weapon_zs_minelayer")

GM:WorthAdd("2pcp", ITEMS_AMMO, 15, nil, "28 pistol ammo", nil, "ammo_pistol", function(pl)
	pl:GiveAmmo(28, "pistol", true)
end)
GM:WorthAdd("3pcp", ITEMS_AMMO, 20, nil, "42 pistol ammo", nil, "ammo_pistol", function(pl)
	pl:GiveAmmo(42, "pistol", true)
end)
GM:WorthAdd("2sgcp", ITEMS_AMMO, 15, nil, "24 shotgun ammo", nil, "ammo_shotgun", function(pl)
	pl:GiveAmmo(24, "buckshot", true)
end)
GM:WorthAdd("3sgcp", ITEMS_AMMO, 20, nil, "36 shotgun ammo", nil, "ammo_shotgun", function(pl)
	pl:GiveAmmo(36, "buckshot", true)
end)
GM:WorthAdd("2smgcp", ITEMS_AMMO, 15, nil, "72 SMG ammo", nil, "ammo_smg", function(pl)
	pl:GiveAmmo(72, "smg1", true)
end)
GM:WorthAdd("3smgcp", ITEMS_AMMO, 20, nil, "108 SMG ammo", nil, "ammo_smg", function(pl)
	pl:GiveAmmo(108, "smg1", true)
end)
GM:WorthAdd("2arcp", ITEMS_AMMO, 15, nil, "64 assault rifle ammo", nil, "ammo_assault", function(pl)
	pl:GiveAmmo(64, "ar2", true)
end)
GM:WorthAdd("3arcp", ITEMS_AMMO, 20, nil, "96 assault rifle ammo", nil, "ammo_assault", function(pl)
	pl:GiveAmmo(96, "ar2", true)
end)
GM:WorthAdd("2rcp", ITEMS_AMMO, 15, nil, "16 rifle ammo", nil, "ammo_rifle", function(pl)
	pl:GiveAmmo(16, "357", true)
end)
GM:WorthAdd("3rcp", ITEMS_AMMO, 20, nil, "24 rifle ammo", nil, "ammo_rifle", function(pl)
	pl:GiveAmmo(24, "357", true)
end)
GM:WorthAdd("2pls", ITEMS_AMMO, 15, nil, "60 pulse ammo", nil, "ammo_pulse", function(pl)
	pl:GiveAmmo(60, "pulse", true)
end)
GM:WorthAdd("3pls", ITEMS_AMMO, 20, nil, "90 pulse ammo", nil, "ammo_pulse", function(pl)
	pl:GiveAmmo(90, "pulse", true)
end)
GM:WorthAdd("xbow1", ITEMS_AMMO, 15, nil, "16 crossbow bolts", nil, "ammo_bolts", function(pl)
	pl:GiveAmmo(16, "XBowBolt", true)
end)
GM:WorthAdd("xbow2", ITEMS_AMMO, 20, nil, "24 crossbow bolts", nil, "ammo_bolts", function(pl)
	pl:GiveAmmo(24, "XBowBolt", true)
end)
GM:WorthAdd("4mines", ITEMS_AMMO, 15, nil, "6 explosives", nil, "ammo_explosive", function(pl)
	pl:GiveAmmo(6, "impactmine", true)
end)
GM:WorthAdd("6mines", ITEMS_AMMO, 20, nil, "9 explosives", nil, "ammo_explosive", function(pl)
	pl:GiveAmmo(9, "impactmine", true)
end)
GM:WorthAdd("8nails", ITEMS_AMMO, 15, nil, "8 nails", nil, "ammo_nail", function(pl)
	pl:GiveAmmo(8, "GaussEnergy", true)
end)
GM:WorthAdd("12nails", ITEMS_AMMO, 20, nil, "12 nails", nil, "ammo_nail", function(pl)
	pl:GiveAmmo(12, "GaussEnergy", true)
end)
GM:WorthAdd("60mkit", ITEMS_AMMO, 15, nil, "60 medical power", nil, "ammo_medpower", function(pl)
	pl:GiveAmmo(60, "Battery", true)
end)
GM:WorthAdd("90mkit", ITEMS_AMMO, 25, nil, "90 medical power", nil, "ammo_medpower", function(pl)
	pl:GiveAmmo(90, "Battery", true)
end)
GM:WorthAdd("3scrap", ITEMS_AMMO, 15, nil, "3 scrap", nil, "ammo_scrap", function(pl)
	pl:GiveAmmo(3, "Scrap", true)
end)
GM:WorthAdd("9scrap", ITEMS_AMMO, 25, nil, "9 scrap", nil, "ammo_scrap", function(pl)
	pl:GiveAmmo(9, "Scrap", true)
end)

GM:WorthAdd("brassknuckles", ITEMS_MELEE, 20, "weapon_zs_brassknuckles").Model =
	"models/props_c17/utilityconnecter005.mdl"
GM:WorthAdd("zpaxe", ITEMS_MELEE, 40, "weapon_zs_axe")
GM:WorthAdd("crwbar", ITEMS_MELEE, 40, "weapon_zs_crowbar")
GM:WorthAdd("stnbtn", ITEMS_MELEE, 40, "weapon_zs_stunbaton")
GM:WorthAdd("csknf", ITEMS_MELEE, 20, "weapon_zs_swissarmyknife")
GM:WorthAdd("zpplnk", ITEMS_MELEE, 20, "weapon_zs_plank")
GM:WorthAdd("zpfryp", ITEMS_MELEE, 30, "weapon_zs_fryingpan")
GM:WorthAdd("zpcpot", ITEMS_MELEE, 30, "weapon_zs_pot")
GM:WorthAdd("ladel", ITEMS_MELEE, 30, "weapon_zs_ladel")
GM:WorthAdd("pipe", ITEMS_MELEE, 40, "weapon_zs_pipe")
GM:WorthAdd("hook", ITEMS_MELEE, 40, "weapon_zs_hook")

local item
GM:WorthAdd("medkit", ITEMS_TOOLS, 45, "weapon_zs_medicalkit")
GM:WorthAdd("medgun", ITEMS_TOOLS, 40, "weapon_zs_medicgun")
item = GM:WorthAdd("strengthshot", ITEMS_TOOLS, 40, "weapon_zs_strengthshot")
item.SkillRequirement = SKILL_U_STRENGTHSHOT
item = GM:WorthAdd("antidoteshot", ITEMS_TOOLS, 40, "weapon_zs_antidoteshot")
item.SkillRequirement = SKILL_U_ANTITODESHOT
-- GM:WorthAdd("arscrate", ITEMS_DEPLOYABLES, 50, "weapon_zs_arsenalcrate").Countables = "prop_arsenalcrate" --
GM:WorthAdd("resupplybox", ITEMS_DEPLOYABLES, 50, "weapon_zs_resupplybox").Countables = "prop_resupplybox"
GM:WorthAdd("remantler", ITEMS_DEPLOYABLES, 50, "weapon_zs_remantler").Countables = "prop_remantler"
item = GM:WorthAdd("infturret", ITEMS_DEPLOYABLES, 75, "weapon_zs_gunturret", nil, nil, nil, function(pl)
	pl:GiveEmptyWeapon("weapon_zs_gunturret")
	pl:GiveAmmo(1, "thumper")
	pl:GiveAmmo(125, "smg1")
end)
item.Countables = "prop_gunturret"
item.NoClassicMode = true
item = GM:WorthAdd(
	"blastturret",
	ITEMS_DEPLOYABLES,
	75,
	"weapon_zs_gunturret_buckshot",
	nil,
	nil,
	nil,
	function(pl)
		pl:GiveEmptyWeapon("weapon_zs_gunturret_buckshot")
		pl:GiveAmmo(1, "turret_buckshot")
		pl:GiveAmmo(30, "buckshot")
	end
)
item.Countables = "prop_gunturret_buckshot"
item.NoClassicMode = true
item.SkillRequirement = SKILL_U_BLASTTURRET
item = GM:WorthAdd("repairfield", ITEMS_DEPLOYABLES, 60, "weapon_zs_repairfield", nil, nil, nil, function(pl)
	pl:GiveEmptyWeapon("weapon_zs_repairfield")
	pl:GiveAmmo(1, "repairfield")
	pl:GiveAmmo(50, "pulse")
end)
item.Countables = "prop_repairfield"
item.NoClassicMode = true
item = GM:WorthAdd("zapper", ITEMS_DEPLOYABLES, 75, "weapon_zs_zapper", nil, nil, nil, function(pl)
	pl:GiveEmptyWeapon("weapon_zs_zapper")
	pl:GiveAmmo(1, "zapper")
	pl:GiveAmmo(50, "pulse")
end)
item.Countables = "prop_zapper"
item.NoClassicMode = true

GM:WorthAdd("manhack", ITEMS_DEPLOYABLES, 50, "weapon_zs_manhack").Countables = "prop_manhack"
item = GM:WorthAdd("drone", ITEMS_DEPLOYABLES, 55, "weapon_zs_drone", nil, nil, nil, function(pl)
	pl:GiveEmptyWeapon("weapon_zs_drone")
	pl:GiveAmmo(1, "drone")
	pl:GiveAmmo(60, "smg1")
end)
item.Countables = "prop_drone"
item = GM:WorthAdd("pulsedrone", ITEMS_DEPLOYABLES, 55, "weapon_zs_drone_pulse", nil, nil, nil, function(pl)
	pl:GiveEmptyWeapon("weapon_zs_drone_pulse")
	pl:GiveAmmo(1, "pulse_cutter")
	pl:GiveAmmo(60, "pulse")
end)
item.Countables = "prop_drone_pulse"
item.SkillRequirement = SKILL_U_DRONE
item = GM:WorthAdd("hauldrone", ITEMS_DEPLOYABLES, 25, "weapon_zs_drone_hauler", nil, nil, nil, function(pl)
	pl:GiveEmptyWeapon("weapon_zs_drone_hauler")
	pl:GiveAmmo(1, "drone_hauler")
end)
item.Countables = "prop_drone_hauler"
item.SkillRequirement = SKILL_HAULMODULE
item = GM:WorthAdd("rollermine", ITEMS_DEPLOYABLES, 65, "weapon_zs_rollermine", nil, nil, nil, function(pl)
	pl:GiveEmptyWeapon("weapon_zs_rollermine")
	pl:GiveAmmo(1, "rollermine")
end)
item.Countables = "prop_rollermine"
item.SkillRequirement = SKILL_U_ROLLERMINE

GM:WorthAdd("wrench", ITEMS_TOOLS, 20, "weapon_zs_wrench").NoClassicMode = true
GM:WorthAdd("crphmr", ITEMS_TOOLS, 40, "weapon_zs_hammer").NoClassicMode = true
-- GM:WorthAdd("junkpack", ITEMS_DEPLOYABLES, 30, "weapon_zs_boardpack") -- Disabled: no longer purchasable.
GM:WorthAdd("propanetank", ITEMS_TOOLS, 30, "comp_propanecan")
GM:WorthAdd("busthead", ITEMS_TOOLS, 35, "comp_busthead")
GM:WorthAdd("sawblade", ITEMS_TOOLS, 35, "comp_sawblade").SkillRequirement = SKILL_U_CRAFTINGPACK
GM:WorthAdd("cpuparts", ITEMS_TOOLS, 35, "comp_cpuparts").SkillRequirement = SKILL_U_CRAFTINGPACK
GM:WorthAdd("electrobattery", ITEMS_TOOLS, 45, "comp_electrobattery").SkillRequirement = SKILL_U_CRAFTINGPACK
GM:WorthAdd("msgbeacon", ITEMS_DEPLOYABLES, 10, "weapon_zs_messagebeacon").Countables = "prop_messagebeacon"
item = GM:WorthAdd("ffemitter", ITEMS_DEPLOYABLES, 45, "weapon_zs_ffemitter", nil, nil, nil, function(pl)
	pl:GiveEmptyWeapon("weapon_zs_ffemitter")
	pl:GiveAmmo(1, "slam")
	pl:GiveAmmo(50, "pulse")
end)
item.Countables = "prop_ffemitter"
GM:WorthAdd("barricadekit", ITEMS_DEPLOYABLES, 50, "weapon_zs_barricadekit")
GM:WorthAdd("camera", ITEMS_DEPLOYABLES, 15, "weapon_zs_camera").Countables = "prop_camera"
GM:WorthAdd("tv", ITEMS_DEPLOYABLES, 35, "weapon_zs_tv").Countables = "prop_tv"

GM:WorthAdd("oxtank", ITEMS_TRINKETS, 5, "trinket_oxygentank").SubCategory = TRINKETS_PERFORMANCE
GM:WorthAdd("boxingtraining", ITEMS_TRINKETS, 10, "trinket_boxingtraining").SubCategory =
	TRINKETS_MELEE
GM:WorthAdd("cutlery", ITEMS_TRINKETS, 10, "trinket_cutlery").SubCategory = TRINKETS_DEFENSIVE
GM:WorthAdd("portablehole", ITEMS_TRINKETS, 10, "trinket_portablehole").SubCategory =
	TRINKETS_PERFORMANCE
GM:WorthAdd("acrobatframe", ITEMS_TRINKETS, 15, "trinket_acrobatframe").SubCategory =
	TRINKETS_PERFORMANCE
GM:WorthAdd("nightvision", ITEMS_TRINKETS, 15, "trinket_nightvision").SubCategory = TRINKETS_SPECIAL
GM:WorthAdd("targetingvisi", ITEMS_TRINKETS, 15, "trinket_targetingvisori").SubCategory =
	TRINKETS_OFFENSIVE
GM:WorthAdd("pulseampi", ITEMS_TRINKETS, 15, "trinket_pulseampi").SubCategory = TRINKETS_OFFENSIVE
GM:WorthAdd("blueprintsi", ITEMS_TRINKETS, 15, "trinket_blueprintsi").SubCategory = TRINKETS_SUPPORT
GM:WorthAdd("loadingframe", ITEMS_TRINKETS, 15, "trinket_loadingex").SubCategory =
	TRINKETS_PERFORMANCE
GM:WorthAdd("kevlar", ITEMS_TRINKETS, 15, "trinket_kevlar").SubCategory = TRINKETS_DEFENSIVE
GM:WorthAdd("momentumsupsysii", ITEMS_TRINKETS, 15, "trinket_momentumsupsysii").SubCategory =
	TRINKETS_MELEE
GM:WorthAdd("hemoadrenali", ITEMS_TRINKETS, 15, "trinket_hemoadrenali").SubCategory = TRINKETS_MELEE
GM:WorthAdd("vitpackagei", ITEMS_TRINKETS, 20, "trinket_vitpackagei").SubCategory =
	TRINKETS_DEFENSIVE
GM:WorthAdd("processor", ITEMS_TRINKETS, 20, "trinket_processor").SubCategory = TRINKETS_SUPPORT
GM:WorthAdd("cardpackagei", ITEMS_TRINKETS, 20, "trinket_cardpackagei").SubCategory =
	TRINKETS_DEFENSIVE
GM:WorthAdd("bloodpack", ITEMS_TRINKETS, 20, "trinket_bloodpack").SubCategory = TRINKETS_DEFENSIVE
GM:WorthAdd("biocleanser", ITEMS_TRINKETS, 20, "trinket_biocleanser").SubCategory = TRINKETS_SPECIAL
GM:WorthAdd("reactiveflasher", ITEMS_TRINKETS, 25, "trinket_reactiveflasher").SubCategory =
	TRINKETS_SPECIAL
GM:WorthAdd("magnet", ITEMS_TRINKETS, 25, "trinket_magnet").SubCategory = TRINKETS_SPECIAL
--GM:WorthAdd("arsenalpack", ITEMS_TRINKETS, 55, "trinket_arsenalpack").SubCategory = TRINKETS_SUPPORT
GM:WorthAdd("resupplypack", ITEMS_TRINKETS, 55, "trinket_resupplypack").SubCategory =
	TRINKETS_SUPPORT

GM:WorthAdd("stone", ITEMS_OTHER, 10, "weapon_zs_stone")
GM:WorthAdd("grenade", ITEMS_OTHER, 30, "weapon_zs_grenade")
GM:WorthAdd("flashbomb", ITEMS_OTHER, 15, "weapon_zs_flashbomb")
GM:WorthAdd("molotov", ITEMS_OTHER, 30, "weapon_zs_molotov")
GM:WorthAdd("betty", ITEMS_OTHER, 30, "weapon_zs_proxymine")
GM:WorthAdd("corgasgrenade", ITEMS_OTHER, 40, "weapon_zs_corgasgrenade")
GM:WorthAdd("crygasgrenade", ITEMS_OTHER, 35, "weapon_zs_crygasgrenade").SkillRequirement = SKILL_U_CRYGASGREN
GM:WorthAdd("detpck", ITEMS_OTHER, 35, "weapon_zs_detpack").Countables = "prop_detpack"
item = GM:WorthAdd("sigfragment", ITEMS_OTHER, 25, "weapon_zs_sigilfragment")
item.NoClassicMode = true
item = GM:WorthAdd("corfragment", ITEMS_OTHER, 35, "weapon_zs_corruptedfragment")
item.NoClassicMode = true
item.SkillRequirement = SKILL_U_CORRUPTEDFRAGMENT
item = GM:WorthAdd("medcloud", ITEMS_OTHER, 25, "weapon_zs_mediccloudbomb")
item.SkillRequirement = SKILL_U_MEDICCLOUD
item = GM:WorthAdd("nanitecloud", ITEMS_OTHER, 25, "weapon_zs_nanitecloudbomb")
item.SkillRequirement = SKILL_U_NANITECLOUD
GM:WorthAdd("bloodshot", ITEMS_OTHER, 35, "weapon_zs_bloodshotbomb")

------------
-- Point Shop --
------------
-- Tier 1
GM:ShopAdd("pshtr", ITEMS_GUNS, 15, "weapon_zs_peashooter", nil, nil, nil, function(pl)
	pl:GiveEmptyWeapon("weapon_zs_peashooter")
end)
GM:ShopAdd("btlax", ITEMS_GUNS, 15, "weapon_zs_battleaxe", nil, nil, nil, function(pl)
	pl:GiveEmptyWeapon("weapon_zs_battleaxe")
end)
GM:ShopAdd("owens", ITEMS_GUNS, 15, "weapon_zs_owens", nil, nil, nil, function(pl)
	pl:GiveEmptyWeapon("weapon_zs_owens")
end)
GM:ShopAdd("blstr", ITEMS_GUNS, 15, "weapon_zs_blaster", nil, nil, nil, function(pl)
	pl:GiveEmptyWeapon("weapon_zs_blaster")
end)
GM:ShopAdd("tossr", ITEMS_GUNS, 15, "weapon_zs_tosser", nil, nil, nil, function(pl)
	pl:GiveEmptyWeapon("weapon_zs_tosser")
end)
GM:ShopAdd("stbbr", ITEMS_GUNS, 15, "weapon_zs_stubber", nil, nil, nil, function(pl)
	pl:GiveEmptyWeapon("weapon_zs_stubber")
end)
GM:ShopAdd("crklr", ITEMS_GUNS, 15, "weapon_zs_crackler", nil, nil, nil, function(pl)
	pl:GiveEmptyWeapon("weapon_zs_crackler")
end)
GM:ShopAdd("sling", ITEMS_GUNS, 15, "weapon_zs_slinger", nil, nil, nil, function(pl)
	pl:GiveEmptyWeapon("weapon_zs_slinger")
end)
GM:ShopAdd("z9000", ITEMS_GUNS, 15, "weapon_zs_z9000", nil, nil, nil, function(pl)
	pl:GiveEmptyWeapon("weapon_zs_z9000")
end)
GM:ShopAdd("minelayer", ITEMS_GUNS, 20, "weapon_zs_minelayer", nil, nil, nil, function(pl)
	pl:GiveEmptyWeapon("weapon_zs_minelayer")
end)
-- Tier 2
GM:ShopAdd("glock3", ITEMS_GUNS, 35, "weapon_zs_glock3")
GM:ShopAdd("magnum", ITEMS_GUNS, 35, "weapon_zs_magnum")
GM:ShopAdd("eraser", ITEMS_GUNS, 35, "weapon_zs_eraser")
GM:ShopAdd("sawedoff", ITEMS_GUNS, 35, "weapon_zs_sawedoff")
GM:ShopAdd("uzi", ITEMS_GUNS, 35, "weapon_zs_uzi")
GM:ShopAdd("annabelle", ITEMS_GUNS, 35, "weapon_zs_annabelle")
GM:ShopAdd("inquisitor", ITEMS_GUNS, 35, "weapon_zs_inquisitor")
GM:ShopAdd("amigo", ITEMS_GUNS, 35, "weapon_zs_amigo")
GM:ShopAdd("hurricane", ITEMS_GUNS, 35, "weapon_zs_hurricane")
-- Tier 3
GM:ShopAdd("deagle", ITEMS_GUNS, 70, "weapon_zs_deagle")
GM:ShopAdd("tempest", ITEMS_GUNS, 70, "weapon_zs_tempest")
GM:ShopAdd("ender", ITEMS_GUNS, 70, "weapon_zs_ender")
GM:ShopAdd("shredder", ITEMS_GUNS, 70, "weapon_zs_smg")
GM:ShopAdd("silencer", ITEMS_GUNS, 70, "weapon_zs_silencer")
GM:ShopAdd("hunter", ITEMS_GUNS, 70, "weapon_zs_hunter")
GM:ShopAdd("onyx", ITEMS_GUNS, 70, "weapon_zs_onyx")
GM:ShopAdd("charon", ITEMS_GUNS, 70, "weapon_zs_charon")
GM:ShopAdd("akbar", ITEMS_GUNS, 70, "weapon_zs_akbar")
GM:ShopAdd("oberon", ITEMS_GUNS, 70, "weapon_zs_oberon")
GM:ShopAdd("hyena", ITEMS_GUNS, 70, "weapon_zs_hyena")
GM:ShopAdd("pollutor", ITEMS_GUNS, 70, "weapon_zs_pollutor")
-- Tier 4
GM:ShopAdd("longarm", ITEMS_GUNS, 125, "weapon_zs_longarm")
GM:ShopAdd("sweeper", ITEMS_GUNS, 125, "weapon_zs_sweepershotgun")
GM:ShopAdd("jackhammer", ITEMS_GUNS, 125, "weapon_zs_jackhammer")
GM:ShopAdd("bulletstorm", ITEMS_GUNS, 125, "weapon_zs_bulletstorm")
GM:ShopAdd("reaper", ITEMS_GUNS, 125, "weapon_zs_reaper")
GM:ShopAdd("quicksilver", ITEMS_GUNS, 125, "weapon_zs_quicksilver")
GM:ShopAdd("slugrifle", ITEMS_GUNS, 125, "weapon_zs_slugrifle")
GM:ShopAdd("artemis", ITEMS_GUNS, 125, "weapon_zs_artemis")
GM:ShopAdd("zeus", ITEMS_GUNS, 125, "weapon_zs_zeus")
GM:ShopAdd("stalker", ITEMS_GUNS, 125, "weapon_zs_m4")
GM:ShopAdd("inferno", ITEMS_GUNS, 125, "weapon_zs_inferno")
GM:ShopAdd("quasar", ITEMS_GUNS, 125, "weapon_zs_quasar")
GM:ShopAdd("gluon", ITEMS_GUNS, 125, "weapon_zs_gluon")
GM:ShopAdd("barrage", ITEMS_GUNS, 125, "weapon_zs_barrage")
-- Tier 5
GM:ShopAdd("novacolt", ITEMS_GUNS, 200, "weapon_zs_novacolt")
GM:ShopAdd("bulwark", ITEMS_GUNS, 200, "weapon_zs_bulwark")
GM:ShopAdd("juggernaut", ITEMS_GUNS, 200, "weapon_zs_juggernaut")
GM:ShopAdd("scar", ITEMS_GUNS, 200, "weapon_zs_scar")
GM:ShopAdd("boomstick", ITEMS_GUNS, 200, "weapon_zs_boomstick")
GM:ShopAdd("deathdlrs", ITEMS_GUNS, 200, "weapon_zs_deathdealers")
GM:ShopAdd("colossus", ITEMS_GUNS, 200, "weapon_zs_colossus")
GM:ShopAdd("renegade", ITEMS_GUNS, 200, "weapon_zs_renegade")
GM:ShopAdd("crossbow", ITEMS_GUNS, 200, "weapon_zs_crossbow")
GM:ShopAdd("pulserifle", ITEMS_GUNS, 200, "weapon_zs_pulserifle")
GM:ShopAdd("spinfusor", ITEMS_GUNS, 200, "weapon_zs_spinfusor")
GM:ShopAdd("broadside", ITEMS_GUNS, 200, "weapon_zs_broadside")
GM:ShopAdd("smelter", ITEMS_GUNS, 200, "weapon_zs_smelter")

GM:ShopAdd("pistolammo", ITEMS_AMMO, 5, nil, "14 pistol ammo", nil, "ammo_pistol", function(pl)
	pl:GiveAmmo(14, "pistol", true)
end)
GM:ShopAdd("shotgunammo", ITEMS_AMMO, 5, nil, "12 shotgun ammo", nil, "ammo_shotgun", function(pl)
	pl:GiveAmmo(12, "buckshot", true)
end)
GM:ShopAdd("smgammo", ITEMS_AMMO, 5, nil, "36 SMG ammo", nil, "ammo_smg", function(pl)
	pl:GiveAmmo(36, "smg1", true)
end)
GM:ShopAdd("rifleammo", ITEMS_AMMO, 5, nil, "8 rifle ammo", nil, "ammo_rifle", function(pl)
	pl:GiveAmmo(8, "357", true)
end)
GM:ShopAdd("crossbowammo", ITEMS_AMMO, 5, nil, "8 crossbow bolts", nil, "ammo_bolts", function(pl)
	pl:GiveAmmo(8, "XBowBolt", true)
end)
GM:ShopAdd("assaultrifleammo", ITEMS_AMMO, 5, nil, "32 assault rifle ammo", nil, "ammo_assault", function(pl)
	pl:GiveAmmo(32, "ar2", true)
end)
GM:ShopAdd("pulseammo", ITEMS_AMMO, 5, nil, "30 pulse ammo", nil, "ammo_pulse", function(pl)
	pl:GiveAmmo(30, "pulse", true)
end)
GM:ShopAdd("impactmine", ITEMS_AMMO, 5, nil, "3 explosives", nil, "ammo_explosive", function(pl)
	pl:GiveAmmo(3, "impactmine", true)
end)
GM:ShopAdd("chemical", ITEMS_AMMO, 5, nil, "20 chemical vials", nil, "ammo_chemical", function(pl)
	pl:GiveAmmo(20, "chemical", true)
end)
item = GM:ShopAdd(
	"40mkit",
	ITEMS_AMMO,
	5,
	nil,
	"40 Medical Kit power",
	"40 extra power for the Medical Kit.",
	"ammo_medpower",
	function(pl)
		pl:GiveAmmo(40, "Battery", true)
	end
)
item.CanMakeFromScrap = true
item = GM:ShopAdd("nail", ITEMS_AMMO, 2, nil, "Nail", "It's just one nail.", "ammo_nail", function(pl)
	pl:GiveAmmo(3, "GaussEnergy", true)
end)
item.NoClassicMode = true
item.CanMakeFromScrap = true
-- Tier 1
GM:ShopAdd("brassknuckles", ITEMS_MELEE, 10, "weapon_zs_brassknuckles").Model =
	"models/props_c17/utilityconnecter005.mdl"
GM:ShopAdd("knife", ITEMS_MELEE, 10, "weapon_zs_swissarmyknife")
GM:ShopAdd("zpplnk", ITEMS_MELEE, 10, "weapon_zs_plank")
GM:ShopAdd("axe", ITEMS_MELEE, 15, "weapon_zs_axe")
GM:ShopAdd("zpfryp", ITEMS_MELEE, 15, "weapon_zs_fryingpan")
GM:ShopAdd("zpcpot", ITEMS_MELEE, 15, "weapon_zs_pot")
GM:ShopAdd("ladel", ITEMS_MELEE, 15, "weapon_zs_ladel")
GM:ShopAdd("crowbar", ITEMS_MELEE, 15, "weapon_zs_crowbar")
GM:ShopAdd("pipe", ITEMS_MELEE, 15, "weapon_zs_pipe")
GM:ShopAdd("stunbaton", ITEMS_MELEE, 15, "weapon_zs_stunbaton")
GM:ShopAdd("hook", ITEMS_MELEE, 15, "weapon_zs_hook")
-- Tier 2
GM:ShopAdd("broom", ITEMS_MELEE, 30, "weapon_zs_pushbroom")
GM:ShopAdd("shovel", ITEMS_MELEE, 30, "weapon_zs_shovel")
GM:ShopAdd("sledgehammer", ITEMS_MELEE, 30, "weapon_zs_sledgehammer")
GM:ShopAdd("harpoon", ITEMS_MELEE, 30, "weapon_zs_harpoon")
GM:ShopAdd("butcherknf", ITEMS_MELEE, 30, "weapon_zs_butcherknife")
-- Tier 3
GM:ShopAdd("longsword", ITEMS_MELEE, 60, "weapon_zs_longsword")
GM:ShopAdd("executioner", ITEMS_MELEE, 60, "weapon_zs_executioner")
GM:ShopAdd("rebarmace", ITEMS_MELEE, 60, "weapon_zs_rebarmace")
GM:ShopAdd("meattenderizer", ITEMS_MELEE, 60, "weapon_zs_meattenderizer")
-- Tier 4
GM:ShopAdd("graveshvl", ITEMS_MELEE, 100, "weapon_zs_graveshovel")
GM:ShopAdd("kongol", ITEMS_MELEE, 100, "weapon_zs_kongolaxe")
GM:ShopAdd("scythe", ITEMS_MELEE, 100, "weapon_zs_scythe")
GM:ShopAdd("powerfists", ITEMS_MELEE, 100, "weapon_zs_powerfists")
-- Tier 5
GM:ShopAdd("frotchet", ITEMS_MELEE, 150, "weapon_zs_frotchet")

GM:ShopAdd("crphmr", ITEMS_TOOLS, 25, "weapon_zs_hammer", nil, nil, nil, function(pl)
	pl:GiveEmptyWeapon("weapon_zs_hammer")
	pl:GiveAmmo(5, "GaussEnergy")
end)
GM:ShopAdd("wrench", ITEMS_TOOLS, 20, "weapon_zs_wrench").NoClassicMode = true
--GM:ShopAdd("arsenalcrate", ITEMS_DEPLOYABLES, 40, "weapon_zs_arsenalcrate").Countables = "prop_arsenalcrate" --
GM:ShopAdd("resupplybox", ITEMS_DEPLOYABLES, 40, "weapon_zs_resupplybox").Countables = "prop_resupplybox"
GM:ShopAdd("remantler", ITEMS_DEPLOYABLES, 40, "weapon_zs_remantler").Countables = "prop_remantler"
GM:ShopAdd("msgbeacon", ITEMS_DEPLOYABLES, 10, "weapon_zs_messagebeacon").Countables = "prop_messagebeacon"
GM:ShopAdd("camera", ITEMS_DEPLOYABLES, 15, "weapon_zs_camera").Countables = "prop_camera"
GM:ShopAdd("tv", ITEMS_DEPLOYABLES, 25, "weapon_zs_tv").Countables = "prop_tv"
item = GM:ShopAdd("infturret", ITEMS_DEPLOYABLES, 50, "weapon_zs_gunturret", nil, nil, nil, function(pl)
	pl:GiveEmptyWeapon("weapon_zs_gunturret")
	pl:GiveAmmo(1, "thumper")
end)
item.NoClassicMode = true
item.Countables = "prop_gunturret"
item = GM:ShopAdd(
	"blastturret",
	ITEMS_DEPLOYABLES,
	50,
	"weapon_zs_gunturret_buckshot",
	nil,
	nil,
	nil,
	function(pl)
		pl:GiveEmptyWeapon("weapon_zs_gunturret_buckshot")
		pl:GiveAmmo(1, "turret_buckshot")
	end
)
item.Countables = "prop_gunturret_buckshot"
item.NoClassicMode = true
item.SkillRequirement = SKILL_U_BLASTTURRET
item = GM:ShopAdd(
	"assaultturret",
	ITEMS_DEPLOYABLES,
	125,
	"weapon_zs_gunturret_assault",
	nil,
	nil,
	nil,
	function(pl)
		pl:GiveEmptyWeapon("weapon_zs_gunturret_assault")
		pl:GiveAmmo(1, "turret_assault")
	end
)
item.NoClassicMode = true
item.Countables = "prop_gunturret_assault"
item = GM:ShopAdd(
	"rocketturret",
	ITEMS_DEPLOYABLES,
	125,
	"weapon_zs_gunturret_rocket",
	nil,
	nil,
	nil,
	function(pl)
		pl:GiveEmptyWeapon("weapon_zs_gunturret_rocket")
		pl:GiveAmmo(1, "turret_rocket")
	end
)
item.Countables = "prop_gunturret_rocket"
item.NoClassicMode = true
item.SkillRequirement = SKILL_U_ROCKETTURRET
GM:ShopAdd("manhack", ITEMS_DEPLOYABLES, 30, "weapon_zs_manhack").Countables = "prop_manhack"
item = GM:ShopAdd("drone", ITEMS_DEPLOYABLES, 40, "weapon_zs_drone")
item.Countables = "prop_drone"
item = GM:ShopAdd("pulsedrone", ITEMS_DEPLOYABLES, 40, "weapon_zs_drone_pulse")
item.Countables = "prop_drone_pulse"
item.SkillRequirement = SKILL_U_DRONE
item = GM:ShopAdd("hauldrone", ITEMS_DEPLOYABLES, 15, "weapon_zs_drone_hauler")
item.Countables = "prop_drone_hauler"
item.SkillRequirement = SKILL_HAULMODULE
item = GM:ShopAdd("rollermine", ITEMS_DEPLOYABLES, 35, "weapon_zs_rollermine")
item.Countables = "prop_rollermine"
item.SkillRequirement = SKILL_U_ROLLERMINE

item = GM:ShopAdd("repairfield", ITEMS_DEPLOYABLES, 55, "weapon_zs_repairfield", nil, nil, nil, function(pl)
	pl:GiveEmptyWeapon("weapon_zs_repairfield")
	pl:GiveAmmo(1, "repairfield")
	pl:GiveAmmo(30, "pulse")
end)
item.Countables = "prop_repairfield"
item.NoClassicMode = true
item = GM:ShopAdd("zapper", ITEMS_DEPLOYABLES, 50, "weapon_zs_zapper", nil, nil, nil, function(pl)
	pl:GiveEmptyWeapon("weapon_zs_zapper")
	pl:GiveAmmo(1, "zapper")
	pl:GiveAmmo(30, "pulse")
end)
item.Countables = "prop_zapper"
item.NoClassicMode = true
item = GM:ShopAdd("zapper_arc", ITEMS_DEPLOYABLES, 100, "weapon_zs_zapper_arc", nil, nil, nil, function(pl)
	pl:GiveEmptyWeapon("weapon_zs_zapper_arc")
	pl:GiveAmmo(1, "zapper_arc")
	pl:GiveAmmo(30, "pulse")
end)
item.Countables = "prop_zapper_arc"
item.NoClassicMode = true
item.SkillRequirement = SKILL_U_ZAPPER_ARC
item = GM:ShopAdd("ffemitter", ITEMS_DEPLOYABLES, 40, "weapon_zs_ffemitter", nil, nil, nil, function(pl)
	pl:GiveEmptyWeapon("weapon_zs_ffemitter")
	pl:GiveAmmo(1, "slam")
	pl:GiveAmmo(30, "pulse")
end)
item.Countables = "prop_ffemitter"
GM:ShopAdd("propanetank", ITEMS_TOOLS, 15, "comp_propanecan")
GM:ShopAdd("busthead", ITEMS_TOOLS, 25, "comp_busthead")
GM:ShopAdd("sawblade", ITEMS_TOOLS, 30, "comp_sawblade").SkillRequirement = SKILL_U_CRAFTINGPACK
GM:ShopAdd("cpuparts", ITEMS_TOOLS, 30, "comp_cpuparts").SkillRequirement = SKILL_U_CRAFTINGPACK
GM:ShopAdd("electrobattery", ITEMS_TOOLS, 40, "comp_electrobattery").SkillRequirement = SKILL_U_CRAFTINGPACK
GM:ShopAdd("barricadekit", ITEMS_DEPLOYABLES, 85, "weapon_zs_barricadekit")
GM:ShopAdd("medkit", ITEMS_TOOLS, 30, "weapon_zs_medicalkit")
GM:ShopAdd("medgun", ITEMS_TOOLS, 30, "weapon_zs_medicgun")
item = GM:ShopAdd("strengthshot", ITEMS_TOOLS, 30, "weapon_zs_strengthshot")
item.SkillRequirement = SKILL_U_STRENGTHSHOT
item = GM:ShopAdd("antidote", ITEMS_TOOLS, 30, "weapon_zs_antidoteshot")
item.SkillRequirement = SKILL_U_ANTITODESHOT
GM:ShopAdd("medrifle", ITEMS_TOOLS, 55, "weapon_zs_medicrifle")
GM:ShopAdd("healray", ITEMS_TOOLS, 125, "weapon_zs_healingray")

-- Tier 1
GM:ShopAdd("cutlery", ITEMS_TRINKETS, 10, "trinket_cutlery").SubCategory = TRINKETS_DEFENSIVE
GM:ShopAdd("boxingtraining", ITEMS_TRINKETS, 10, "trinket_boxingtraining").SubCategory =
	TRINKETS_MELEE
GM:ShopAdd("hemoadrenali", ITEMS_TRINKETS, 10, "trinket_hemoadrenali").SubCategory =
	TRINKETS_MELEE
GM:ShopAdd("oxtank", ITEMS_TRINKETS, 10, "trinket_oxygentank").SubCategory = TRINKETS_PERFORMANCE
GM:ShopAdd("acrobatframe", ITEMS_TRINKETS, 10, "trinket_acrobatframe").SubCategory =
	TRINKETS_PERFORMANCE
GM:ShopAdd("portablehole", ITEMS_TRINKETS, 10, "trinket_portablehole").SubCategory =
	TRINKETS_PERFORMANCE
GM:ShopAdd("magnet", ITEMS_TRINKETS, 10, "trinket_magnet").SubCategory = TRINKETS_SPECIAL
GM:ShopAdd("targetingvisi", ITEMS_TRINKETS, 10, "trinket_targetingvisori").SubCategory =
	TRINKETS_OFFENSIVE
GM:ShopAdd("pulseampi", ITEMS_TRINKETS, 10, "trinket_pulseampi").SubCategory = TRINKETS_OFFENSIVE
-- Tier 2
GM:ShopAdd("momentumsupsysii", ITEMS_TRINKETS, 15, "trinket_momentumsupsysii").SubCategory =
	TRINKETS_MELEE
GM:ShopAdd("sharpkit", ITEMS_TRINKETS, 15, "trinket_sharpkit").SubCategory = TRINKETS_MELEE
GM:ShopAdd("nightvision", ITEMS_TRINKETS, 15, "trinket_nightvision").SubCategory =
	TRINKETS_PERFORMANCE
GM:ShopAdd("loadingframe", ITEMS_TRINKETS, 15, "trinket_loadingex").SubCategory =
	TRINKETS_PERFORMANCE
GM:ShopAdd("pathfinder", ITEMS_TRINKETS, 15, "trinket_pathfinder").SubCategory =
	TRINKETS_PERFORMANCE
GM:ShopAdd("ammovestii", ITEMS_TRINKETS, 15, "trinket_ammovestii").SubCategory =
	TRINKETS_OFFENSIVE
GM:ShopAdd("olympianframe", ITEMS_TRINKETS, 15, "trinket_olympianframe").SubCategory =
	TRINKETS_OFFENSIVE
GM:ShopAdd("autoreload", ITEMS_TRINKETS, 15, "trinket_autoreload").SubCategory =
	TRINKETS_OFFENSIVE
GM:ShopAdd("curbstompers", ITEMS_TRINKETS, 15, "trinket_curbstompers").SubCategory =
	TRINKETS_OFFENSIVE
GM:ShopAdd("vitpackagei", ITEMS_TRINKETS, 15, "trinket_vitpackagei").SubCategory =
	TRINKETS_DEFENSIVE
GM:ShopAdd("cardpackagei", ITEMS_TRINKETS, 15, "trinket_cardpackagei").SubCategory =
	TRINKETS_DEFENSIVE
GM:ShopAdd("forcedamp", ITEMS_TRINKETS, 15, "trinket_forcedamp").SubCategory = TRINKETS_DEFENSIVE
GM:ShopAdd("kevlar", ITEMS_TRINKETS, 15, "trinket_kevlar").SubCategory = TRINKETS_DEFENSIVE
GM:ShopAdd("antitoxinpack", ITEMS_TRINKETS, 15, "trinket_antitoxinpack").SubCategory =
	TRINKETS_DEFENSIVE
GM:ShopAdd("hemostasis", ITEMS_TRINKETS, 15, "trinket_hemostasis").SubCategory =
	TRINKETS_DEFENSIVE
GM:ShopAdd("bloodpack", ITEMS_TRINKETS, 15, "trinket_bloodpack").SubCategory = TRINKETS_DEFENSIVE
GM:ShopAdd("reactiveflasher", ITEMS_TRINKETS, 15, "trinket_reactiveflasher").SubCategory =
	TRINKETS_SPECIAL
GM:ShopAdd("iceburst", ITEMS_TRINKETS, 15, "trinket_iceburst").SubCategory = TRINKETS_SPECIAL
GM:ShopAdd("biocleanser", ITEMS_TRINKETS, 15, "trinket_biocleanser").SubCategory =
	TRINKETS_SPECIAL
GM:ShopAdd("necrosense", ITEMS_TRINKETS, 15, "trinket_necrosense").SubCategory = TRINKETS_SPECIAL
GM:ShopAdd("blueprintsi", ITEMS_TRINKETS, 15, "trinket_blueprintsi").SubCategory =
	TRINKETS_SUPPORT
GM:ShopAdd("processor", ITEMS_TRINKETS, 15, "trinket_processor").SubCategory = TRINKETS_SUPPORT
GM:ShopAdd("acqmanifest", ITEMS_TRINKETS, 15, "trinket_acqmanifest").SubCategory =
	TRINKETS_SUPPORT
GM:ShopAdd("mainsuite", ITEMS_TRINKETS, 15, "trinket_mainsuite").SubCategory = TRINKETS_SUPPORT
-- Tier 3
--GM:ShopAdd("climbinggear",	ITEMS_TRINKETS,		30,				"trinket_climbinggear").SubCategory =							TRINKETS_PERFORMANCE
GM:ShopAdd("reachem", ITEMS_TRINKETS, 30, "trinket_reachem").SubCategory = TRINKETS_OFFENSIVE
GM:ShopAdd("momentumsupsysiii", ITEMS_TRINKETS, 30, "trinket_momentumsupsysiii").SubCategory =
	TRINKETS_MELEE
GM:ShopAdd("powergauntlet", ITEMS_TRINKETS, 30, "trinket_powergauntlet").SubCategory =
	TRINKETS_MELEE
GM:ShopAdd("hemoadrenalii", ITEMS_TRINKETS, 30, "trinket_hemoadrenalii").SubCategory =
	TRINKETS_MELEE
GM:ShopAdd("sharpstone", ITEMS_TRINKETS, 30, "trinket_sharpstone").SubCategory = TRINKETS_MELEE
GM:ShopAdd("analgestic", ITEMS_TRINKETS, 30, "trinket_analgestic").SubCategory =
	TRINKETS_PERFORMANCE
GM:ShopAdd("feathfallframe", ITEMS_TRINKETS, 30, "trinket_featherfallframe").SubCategory =
	TRINKETS_PERFORMANCE
GM:ShopAdd("aimcomp", ITEMS_TRINKETS, 30, "trinket_aimcomp").SubCategory = TRINKETS_OFFENSIVE
GM:ShopAdd("pulseampii", ITEMS_TRINKETS, 30, "trinket_pulseampii").SubCategory =
	TRINKETS_OFFENSIVE
GM:ShopAdd("extendedmag", ITEMS_TRINKETS, 30, "trinket_extendedmag").SubCategory =
	TRINKETS_OFFENSIVE
GM:ShopAdd("vitpackageii", ITEMS_TRINKETS, 30, "trinket_vitpackageii").SubCategory =
	TRINKETS_DEFENSIVE
GM:ShopAdd("cardpackageii", ITEMS_TRINKETS, 30, "trinket_cardpackageii").SubCategory =
	TRINKETS_DEFENSIVE
GM:ShopAdd("regenimplant", ITEMS_TRINKETS, 30, "trinket_regenimplant").SubCategory =
	TRINKETS_DEFENSIVE
GM:ShopAdd("barbedarmor", ITEMS_TRINKETS, 30, "trinket_barbedarmor").SubCategory =
	TRINKETS_DEFENSIVE
GM:ShopAdd("blueprintsii", ITEMS_TRINKETS, 30, "trinket_blueprintsii").SubCategory =
	TRINKETS_SUPPORT
GM:ShopAdd("curativeii", ITEMS_TRINKETS, 30, "trinket_curativeii").SubCategory = TRINKETS_SUPPORT
GM:ShopAdd("remedy", ITEMS_TRINKETS, 30, "trinket_remedy").SubCategory = TRINKETS_SUPPORT
-- Tier 4
GM:ShopAdd("hemoadrenaliii", ITEMS_TRINKETS, 50, "trinket_hemoadrenaliii").SubCategory =
	TRINKETS_MELEE
GM:ShopAdd("ammoband", ITEMS_TRINKETS, 50, "trinket_ammovestiii").SubCategory = TRINKETS_OFFENSIVE
GM:ShopAdd("resonance", ITEMS_TRINKETS, 50, "trinket_resonance").SubCategory = TRINKETS_OFFENSIVE
GM:ShopAdd("cryoindu", ITEMS_TRINKETS, 50, "trinket_cryoindu").SubCategory = TRINKETS_OFFENSIVE
GM:ShopAdd("refinedsub", ITEMS_TRINKETS, 50, "trinket_refinedsub").SubCategory =
	TRINKETS_OFFENSIVE
GM:ShopAdd("targetingvisiii", ITEMS_TRINKETS, 50, "trinket_targetingvisoriii").SubCategory =
	TRINKETS_OFFENSIVE
GM:ShopAdd("eodvest", ITEMS_TRINKETS, 50, "trinket_eodvest").SubCategory = TRINKETS_DEFENSIVE
GM:ShopAdd("composite", ITEMS_TRINKETS, 50, "trinket_composite").SubCategory = TRINKETS_DEFENSIVE
-- GM:ShopAdd("arsenalpack", ITEMS_TRINKETS, 50, "trinket_arsenalpack").SubCategory = TRINKETS_SUPPORT
GM:ShopAdd("resupplypack", ITEMS_TRINKETS, 50, "trinket_resupplypack").SubCategory =
	TRINKETS_SUPPORT
GM:ShopAdd("promanifest", ITEMS_TRINKETS, 50, "trinket_promanifest").SubCategory =
	TRINKETS_SUPPORT
GM:ShopAdd("opsmatrix", ITEMS_TRINKETS, 50, "trinket_opsmatrix").SubCategory = TRINKETS_SUPPORT
-- Tier 5
GM:ShopAdd("supasm", ITEMS_TRINKETS, 70, "trinket_supasm").SubCategory = TRINKETS_OFFENSIVE
GM:ShopAdd("pulseimpedance", ITEMS_TRINKETS, 70, "trinket_pulseimpedance").SubCategory =
	TRINKETS_OFFENSIVE

GM:ShopAdd("flashbomb", ITEMS_OTHER, 25, "weapon_zs_flashbomb")
GM:ShopAdd("molotov", ITEMS_OTHER, 30, "weapon_zs_molotov")
GM:ShopAdd("grenade", ITEMS_OTHER, 35, "weapon_zs_grenade")
GM:ShopAdd("betty", ITEMS_OTHER, 35, "weapon_zs_proxymine")
GM:ShopAdd("detpck", ITEMS_OTHER, 40, "weapon_zs_detpack")
item = GM:ShopAdd("crygasgrenade", ITEMS_OTHER, 40, "weapon_zs_crygasgrenade")
item.SkillRequirement = SKILL_U_CRYGASGREN
GM:ShopAdd("corgasgrenade", ITEMS_OTHER, 45, "weapon_zs_corgasgrenade")
GM:ShopAdd("sigfragment", ITEMS_OTHER, 30, "weapon_zs_sigilfragment")
GM:ShopAdd("bloodshot", ITEMS_OTHER, 45, "weapon_zs_bloodshotbomb")
item = GM:ShopAdd("corruptedfragment", ITEMS_OTHER, 55, "weapon_zs_corruptedfragment")
item.NoClassicMode = true
item.SkillRequirement = SKILL_U_CORRUPTEDFRAGMENT
item = GM:ShopAdd("medcloud", ITEMS_OTHER, 40, "weapon_zs_mediccloudbomb")
item.SkillRequirement = SKILL_U_MEDICCLOUD
item = GM:ShopAdd("nanitecloud", ITEMS_OTHER, 40, "weapon_zs_nanitecloudbomb")
item.SkillRequirement = SKILL_U_NANITECLOUD

-- These are the honorable mentions that come at the end of the round.

local function genericcallback(pl, magnitude)
	return pl:Name(), magnitude
end
GM.HonorableMentions = {}
GM.HonorableMentions[HM_MOSTZOMBIESKILLED] = {
	Name = "Grim Reaper",
	String = "%s killed %d zombies",
	Callback = genericcallback,
	Color = COLOR_CYAN,
}
GM.HonorableMentions[HM_MOSTDAMAGETOUNDEAD] = {
	Name = "Pain Maker",
	String = "%s dealt %d damage to zombies",
	Callback = genericcallback,
	Color = COLOR_CYAN,
}
GM.HonorableMentions[HM_MOSTHEADSHOTS] = {
	Name = "Head Hunter",
	String = "%s killed %s zombies with headshots",
	Callback = genericcallback,
	Color = COLOR_CYAN,
}
GM.HonorableMentions[HM_PACIFIST] = {
	Name = "Science Team",
	String = "%s survived without killing any zombies",
	Callback = genericcallback,
	Color = COLOR_CYAN,
}
GM.HonorableMentions[HM_MOSTHELPFUL] = {
	Name = "Sidekick",
	String = "%s assisted with %d kills",
	Callback = genericcallback,
	Color = COLOR_CYAN,
}
GM.HonorableMentions[HM_LASTHUMAN] = {
	Name = "Last Human",
	String = "%s was the last human alive",
	Callback = genericcallback,
	Color = COLOR_CYAN,
}
GM.HonorableMentions[HM_OUTLANDER] = {
	Name = "Outlander",
	String = "%s was killed %d feet from a zombie spawn",
	Callback = genericcallback,
	Color = COLOR_CYAN,
}
GM.HonorableMentions[HM_GOODDOCTOR] = {
	Name = "Least Shit Medic",
	String = "%s healed %d points of health",
	Callback = genericcallback,
	Color = COLOR_CYAN,
}
GM.HonorableMentions[HM_HANDYMAN] = {
	Name = "God Cader",
	String = "%s made %d repair points",
	Callback = genericcallback,
	Color = COLOR_CYAN,
}
GM.HonorableMentions[HM_SCARECROW] = {
	Name = "Scarecrow",
	String = "%s killed %d poor crows",
	Callback = genericcallback,
	Color = COLOR_WHITE,
}
GM.HonorableMentions[HM_MOSTBRAINSEATEN] = {
	Name = "BRRAAIINNSS!...",
	String = "%s ate %d humans",
	Callback = genericcallback,
	Color = COLOR_RED,
}
GM.HonorableMentions[HM_MOSTDAMAGETOHUMANS] = {
	Name = "HUNGER!...",
	String = "%s dealt %d damage to humans",
	Callback = genericcallback,
	Color = COLOR_RED,
}
GM.HonorableMentions[HM_LASTBITE] = {
	Name = "Last Bite",
	String = "%s ate the last human",
	Callback = genericcallback,
	Color = COLOR_RED,
}
GM.HonorableMentions[HM_USEFULTOOPPOSITE] = {
	Name = "Stupid Damn Zombie",
	String = "%s died %d times as a zombie",
	Callback = genericcallback,
	Color = COLOR_RED,
}
GM.HonorableMentions[HM_STUPID] = {
	Name = "Certified Kliener",
	String = "%s got killed %d feet from a zombie spawn",
	Callback = genericcallback,
	Color = COLOR_RED,
}
GM.HonorableMentions[HM_SALESMAN] = {
	Name = "Salesman",
	String = "is what %s is for having %d points worth of items taken from their arsenal crate.",
	Callback = genericcallback,
	Color = COLOR_CYAN,
}
GM.HonorableMentions[HM_WAREHOUSE] = {
	Name = "Take Some Ammo!",
	String = "%s had their resupply boxes used %d times",
	Callback = genericcallback,
	Color = COLOR_CYAN,
}
GM.HonorableMentions[HM_DEFENCEDMG] = {
	Name = "Defence Buff Master",
	String = "%s protected humans from %d damage with defence boosts",
	Callback = genericcallback,
	Color = COLOR_BLUE,
}
GM.HonorableMentions[HM_STRENGTHDMG] = {
	Name = "Buff Master",
	String = "%s boosted humans with an additional %d damage",
	Callback = genericcallback,
	Color = COLOR_CYAN,
}
GM.HonorableMentions[HM_BARRICADEDESTROYER] = {
	Name = "Prop Muncher",
	String = "%s dealt %d damage to barricades",
	Callback = genericcallback,
	Color = COLOR_RED,
}
GM.HonorableMentions[HM_NESTDESTROYER] = {
	Name = "Nest Destroyer",
	String = "goes to %s for destroying %d nests.",
	Callback = genericcallback,
	Color = COLOR_RED,
}
GM.HonorableMentions[HM_NESTMASTER] = {
	Name = "Nest Master",
	String = "goes to %s for having %d zombies spawn through their nest.",
	Callback = genericcallback,
	Color = COLOR_RED,
}

-- Don't let humans use these models because they look like undead models. Must be lower case.
GM.RestrictedModels = {
	"models/player/zombie_classic.mdl",
	"models/player/zombie_classic_hbfix.mdl",
	"models/player/zombine.mdl",
	"models/player/zombie_soldier.mdl",
	"models/player/zombie_fast.mdl",
	"models/player/corpse1.mdl",
	"models/player/charple.mdl",
	"models/player/skeleton.mdl",
	"models/player/combine_soldier_prisonguard.mdl",
	"models/player/soldier_stripped.mdl",
	"models/player/zelpa/stalker.mdl",
	"models/player/fatty/fatty.mdl",
	"models/player/zombie_lacerator2.mdl",
}

-- If a person has no player model then use one of these (auto-generated).
GM.RandomPlayerModels = {}
for name, mdl in pairs(player_manager.AllValidModels()) do
	if not table.HasValue(GM.RestrictedModels, string.lower(mdl)) then
		table.insert(GM.RandomPlayerModels, name)
	end
end

GM.DeployableInfo = {}
function GM:AddDeployableInfo(class, name, wepclass)
	local tab = { Class = class, Name = name or "?", WepClass = wepclass }

	self.DeployableInfo[#self.DeployableInfo + 1] = tab
	self.DeployableInfo[class] = tab

	return tab
end
GM:AddDeployableInfo("prop_arsenalcrate", "Arsenal Crate", "weapon_zs_arsenalcrate")
GM:AddDeployableInfo("prop_resupplybox", "Resupply Box", "weapon_zs_resupplybox")
GM:AddDeployableInfo("prop_remantler", "Weapon Remantler", "weapon_zs_remantler")
GM:AddDeployableInfo("prop_messagebeacon", "Message Beacon", "weapon_zs_messagebeacon")
GM:AddDeployableInfo("prop_camera", "Camera", "weapon_zs_camera")
GM:AddDeployableInfo("prop_gunturret", "Gun Turret", "weapon_zs_gunturret")
GM:AddDeployableInfo("prop_gunturret_assault", "Assault Turret", "weapon_zs_gunturret_assault")
GM:AddDeployableInfo("prop_gunturret_buckshot", "Blast Turret", "weapon_zs_gunturret_buckshot")
GM:AddDeployableInfo("prop_gunturret_rocket", "Rocket Turret", "weapon_zs_gunturret_rocket")
GM:AddDeployableInfo("prop_repairfield", "Repair Field Emitter", "weapon_zs_repairfield")
GM:AddDeployableInfo("prop_zapper", "Zapper", "weapon_zs_zapper")
GM:AddDeployableInfo("prop_zapper_arc", "Arc Zapper", "weapon_zs_zapper_arc")
GM:AddDeployableInfo("prop_ffemitter", "Force Field Emitter", "weapon_zs_ffemitter")
GM:AddDeployableInfo("prop_manhack", "Manhack", "weapon_zs_manhack")
GM:AddDeployableInfo("prop_manhack_saw", "Sawblade Manhack", "weapon_zs_manhack_saw")
GM:AddDeployableInfo("prop_drone", "Drone", "weapon_zs_drone")
GM:AddDeployableInfo("prop_drone_pulse", "Pulse Drone", "weapon_zs_drone_pulse")
GM:AddDeployableInfo("prop_drone_hauler", "Hauler Drone", "weapon_zs_drone_hauler")
GM:AddDeployableInfo("prop_rollermine", "Rollermine", "weapon_zs_rollermine")
GM:AddDeployableInfo("prop_tv", "TV", "weapon_zs_tv")

GM.MaxSigils = 3

GM.DefaultRedeem = CreateConVar(
	"zs_redeem",
	"2",
	FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY,
	"The amount of kills a zombie needs to do in order to redeem. Set to 0 to disable."
):GetInt()
cvars.AddChangeCallback("zs_redeem", function(cvar, oldvalue, newvalue)
	GAMEMODE.DefaultRedeem = math.max(0, tonumber(newvalue) or 0)
end)

GM.WaveOneZombies = 0.11 --math.Round(CreateConVar("zs_waveonezombies", "0.1", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY, "The percentage of players that will start as zombies when the game begins."):GetFloat(), 2)
-- cvars.AddChangeCallback("zs_waveonezombies", function(cvar, oldvalue, newvalue)
-- 	GAMEMODE.WaveOneZombies = math.ceil(100 * (tonumber(newvalue) or 1)) * 0.01
-- end)

-- Game feeling too easy? Just change these values!
GM.ZombieSpeedMultiplier = math.Round(
	CreateConVar(
		"zs_zombiespeedmultiplier",
		"1",
		FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY,
		"Zombie running speed will be scaled by this value."
	):GetFloat(),
	2
)
cvars.AddChangeCallback("zs_zombiespeedmultiplier", function(cvar, oldvalue, newvalue)
	GAMEMODE.ZombieSpeedMultiplier = math.ceil(100 * (tonumber(newvalue) or 1)) * 0.01
end)

-- This is a resistance, not for claw damage. 0.5 will make zombies take half damage, 0.25 makes them take 1/4, etc.
GM.ZombieDamageMultiplier = math.Round(
	CreateConVar(
		"zs_zombiedamagemultiplier",
		"1",
		FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY,
		"Scales the amount of damage that zombies take. Use higher values for easy zombies, lower for harder."
	):GetFloat(),
	2
)
cvars.AddChangeCallback("zs_zombiedamagemultiplier", function(cvar, oldvalue, newvalue)
	GAMEMODE.ZombieDamageMultiplier = math.ceil(100 * (tonumber(newvalue) or 1)) * 0.01
end)

GM.TimeLimit = CreateConVar(
	"zs_timelimit",
	"15",
	FCVAR_ARCHIVE + FCVAR_NOTIFY,
	"Time in minutes before the game will change maps. It will not change maps if a round is currently in progress but after the current round ends. -1 means never switch maps. 0 means always switch maps."
):GetInt() * 60
cvars.AddChangeCallback("zs_timelimit", function(cvar, oldvalue, newvalue)
	GAMEMODE.TimeLimit = tonumber(newvalue) or 15
	if GAMEMODE.TimeLimit ~= -1 then
		GAMEMODE.TimeLimit = GAMEMODE.TimeLimit * 60
	end
end)

GM.RoundLimit = CreateConVar(
	"zs_roundlimit",
	"3",
	FCVAR_ARCHIVE + FCVAR_NOTIFY,
	"How many times the game can be played on the same map. -1 means infinite or only use time limit. 0 means once."
):GetInt()
cvars.AddChangeCallback("zs_roundlimit", function(cvar, oldvalue, newvalue)
	GAMEMODE.RoundLimit = tonumber(newvalue) or 3
end)

-- Static values that don't need convars...

-- Initial length for wave 1.
GM.WaveOneLength = 220

-- Add this many seconds for each additional wave.
GM.TimeAddedPerWave = 15

-- New players are put on the zombie team if the current wave is this or higher. Do not put it lower than 1 or you'll break the game.
GM.NoNewHumansWave = 3

-- Humans can not commit suicide if the current wave is this or lower.
GM.NoSuicideWave = 1

-- How long 'wave 0' should last in seconds. This is the time you should give for new players to join and get ready.
GM.WaveZeroLength = 250

-- Time humans have between waves to do stuff without NEW zombies spawning. Any dead zombies will be in spectator (crow) view and any living ones will still be living.
GM.WaveIntermissionLength = 90

-- Time in seconds between end round and next map.
GM.EndGameTime = 45

-- How many clips of ammo guns from the Worth menu start with. Some guns such as shotguns and sniper rifles have multipliers on this.
GM.SurvivalClips = 4 --2

-- How long do humans have to wait before being able to get more ammo from a resupply box?
GM.ResupplyBoxCooldown = 60

-- Put your unoriginal, 5MB Rob Zombie and Metallica music here.
GM.LastHumanSound = Sound("zombiesurvival/lasthuman.ogg")

-- Sound played when humans all die.
GM.AllLoseSound = Sound("zombiesurvival/music_lose.ogg")

-- Sound played when humans survive.
GM.HumanWinSound = Sound("zombiesurvival/music_win.ogg")

-- Sound played to a person when they die as a human.
GM.DeathSound = Sound("zombiesurvival/human_death_stinger.ogg")

-- Fetch map profiles and node profiles from noxiousnet database?
GM.UseOnlineProfiles = true

-- This multiplier of points will save over to the next round. 1 is full saving. 0 is disabled.
-- Setting this to 0 will not delete saved points and saved points do not "decay" if this is less than 1.
GM.PointSaving = 0

-- Lock item purchases to waves. Tier 2 items can only be purchased on wave 2, tier 3 on wave 3, etc.
-- HIGHLY suggested that this is on if you enable point saving. Always false if objective map, zombie escape, classic mode, or wave number is changed by the map.
GM.LockItemTiers = false

-- Don't save more than this amount of points. 0 for infinite.
GM.PointSavingLimit = 0

-- For Classic Mode
GM.WaveIntermissionLengthClassic = 20
GM.WaveOneLengthClassic = 120
GM.TimeAddedPerWaveClassic = 10

-- Max amount of damage left to tick on these. Any more pending damage is ignored.
GM.MaxPoisonDamage = 50
GM.MaxBleedDamage = 50

-- Give humans this many points when the wave ends.
GM.EndWavePointsBonus = 5

-- Also give humans this many points when the wave ends, multiplied by (wave - 1)
GM.EndWavePointsBonusPerWave = 1
