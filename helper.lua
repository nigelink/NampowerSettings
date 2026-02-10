if not Nampower then
	return
end

if not Nampower:HasMinimumVersion(2, 14, 0) then
	return
end

local function GetSpellMod(num)
	local modifierTypes = {
		[0] = "DAMAGE",
		[1] = "DURATION",
		[2] = "THREAT",
		[3] = "ATTACK_POWER",
		[4] = "CHARGES",
		[5] = "RANGE",
		[6] = "RADIUS",
		[7] = "CRITICAL_CHANCE",
		[8] = "ALL_EFFECTS",
		[9] = "NOT_LOSE_CASTING_TIME",
		[10] = "CASTING_TIME",
		[11] = "COOLDOWN",
		[12] = "SPEED",
		[14] = "COST",
		[15] = "CRIT_DAMAGE_BONUS",
		[16] = "RESIST_MISS_CHANCE",
		[17] = "JUMP_TARGETS",
		[18] = "CHANCE_OF_SUCCESS",
		[19] = "ACTIVATION_TIME",
		[20] = "EFFECT_PAST_FIRST",
		[21] = "CASTING_TIME_OLD",
		[22] = "DOT",
		[23] = "HASTE",
		[24] = "SPELL_BONUS_DAMAGE",
		[27] = "MULTIPLE_VALUE",
		[28] = "RESIST_DISPEL_CHANCE"
	}
	return modifierTypes[num] or "UNKNOWN"
end

function PrintTable(tbl, indent)
	indent = indent or 0
	local prefix = string.rep("  ", indent)

	for k, v in pairs(tbl) do
		if type(v) == "table" then
			print(prefix .. tostring(k) .. ":")
			PrintTable(v, indent + 1)
		else
			print(prefix .. tostring(k) .. ": " .. tostring(v))
		end
	end
end

if CombatLogAdd then
	function PrintTableToCombatLog(tbl, indent)
		indent = indent or 0
		local prefix = string.rep("  ", indent)

		for k, v in pairs(tbl) do
			if type(v) == "table" then
				CombatLogAdd(prefix .. tostring(k) .. ":")
				PrintTableToCombatLog(v, indent + 1)
			else
				CombatLogAdd(prefix .. tostring(k) .. ": " .. tostring(v))
			end
		end
	end

	function LogUnitData(unit)
		local data = GetUnitData(unit)
		if data then
			PrintTableToCombatLog(data)
		else
			print("No unit data available")
		end
	end

	function LogSpellData(spellId)
		local data = GetSpellRec(spellId)
		if data then
			PrintTableToCombatLog(data)
		else
			print("No spell data available")
		end
	end
end

function PrintBuffs(unit)
  for i = 1, 32 do
    local texture, stacks, spellId = UnitBuff(unit, i)
    if not texture then
      break
    end
    print(tostring(i) .. " " .. tostring(spellId))
  end
end

function PrintUnitData(unit)
	local data = GetUnitData(unit)
	if data then
		PrintTable(data)
	else
		print("No unit data available")
	end
end

function PrintSpellMods(spellId)
	for i = 0, 28 do
		local flatMod, percentMod, ret = GetSpellModifiers(spellId, i)
		if ret > 0 then
			print(GetSpellMod(i) .. " (" .. tostring(i) .. "): flat:" .. tostring(flatMod) .. " percent:" .. tostring(percentMod))
		end
	end
end

function PrintSpellData(spellId)
	local data = GetSpellRec(spellId)
	if data then
		PrintTable(data)
	else
		print("No spell data available")
	end
end

if not Nampower:HasMinimumVersion(2, 16, 0) then
	return
end

function PrintItemLocation(itemNameOrId)
	local bagIndex, slot = FindPlayerItemSlot(itemNameOrId)
	print(tostring(bagIndex) .. " " .. tostring(slot))
end

function PrintEquippedItems()
	local target = "player"
	if UnitExists("target") then
		target = "target"
	end
	local data = GetEquippedItems(target)
	PrintTable(data)
end

function LogEquippedItems()
	local target = "player"
	if UnitExists("target") then
		target = "target"
	end
	local data = GetEquippedItems(target)
	PrintTableToCombatLog(data)
end

function PrintBagItems()
	local data = GetBagItems()
	PrintTable(data)
end

function LogBagItems()
	local data = GetBagItems()
	PrintTableToCombatLog(data)
end

function TestBagItems(bagIndex)
  local items = GetBagItems(bagIndex)
  local numItemsChecked = 0
  for slot, itemData in pairs(items) do
    local itemLink = GetContainerItemLink(bagIndex, slot)
    if not itemLink then
      print(tostring(bagIndex) .. " " .. tostring(slot))
      PrintTable(itemData)
    end
    local _, _, itemId = strfind(itemLink, "(%d+):")
    numItemsChecked = numItemsChecked + 1
    if (tostring(itemData.itemId) ~= itemId) then
      print("Item mismatch at " .. tostring(bagIndex) .. " " .. tostring(slot) .. " " .. tostring(itemData.itemId) .. " " .. tostring(itemId))
      print(itemLink)
    end
  end
  print("checked " .. tostring(numItemsChecked) .. " items")
end

function TestAllBagItems()
  local data = GetBagItems()
  local numItemsChecked = 0
  for bagIndex, items in pairs(data) do
    for slot, itemData in pairs(items) do
      local itemLink = GetContainerItemLink(bagIndex, slot)
      if not itemLink then
        print(tostring(bagIndex) .. " " .. tostring(slot))
        PrintTable(itemData)
      end
      local _, _, itemId = strfind(itemLink, "(%d+):")
      numItemsChecked = numItemsChecked + 1
      if (tostring(itemData.itemId) ~= itemId) then
        print("Item mismatch at " .. tostring(bagIndex) .. " " .. tostring(slot) .. " " .. tostring(itemData.itemId) .. " " .. tostring(itemId))
        print(itemLink)
      end
    end
  end
  print("checked " .. tostring(numItemsChecked) .. " items")
end

function TestTrinkets()
  local data = GetTrinkets()
  for index, trinketData in pairs(data) do
    local bagIndex = trinketData.bagIndex
    local slot = trinketData.slotIndex
    local itemLink
    if bagIndex then
      itemLink = GetContainerItemLink(bagIndex, slot)
    else
      itemLink = GetInventoryItemLink("player", slot)
    end
    local _, _, itemId = strfind(itemLink, "(%d+):")
    if (tostring(trinketData.itemId) ~= itemId) then
      print("Trinket mismatch at " .. tostring(bagIndex) .. " " .. tostring(slot) .. " " .. tostring(itemData.itemId) .. " " .. tostring(itemId))
      print(itemLink)
    end
  end
end

if not Nampower:HasMinimumVersion(2, 17, 0) then
	return
end

function PrintCastInfo()
	local data = GetCastInfo()
	if data then
		PrintTable(data)
	end
end

function PrintSpellCooldown(spellId)
	local data = GetSpellIdCooldown(spellId)
	if data then
		PrintTable(data)
	end
end

function PrintItemCooldown(itemId)
	local data = GetItemIdCooldown(itemId)
	if data then
		PrintTable(data)
	end
end

function PrintTrinketCooldown(trinketId)
	local data = GetTrinketCooldown(trinketId)
	if data then
		PrintTable(data)
	end
end

function PrintTrinkets()
	local data = GetTrinkets(1)
	if data then
		PrintTable(data)
	end
end

if not Nampower:HasMinimumVersion(2, 24, 0) then
	return
end

-- Auto Attack Event Constants
local HITINFO_NORMALSWING = 0
local HITINFO_UNK0 = 1
local HITINFO_AFFECTS_VICTIM = 2
local HITINFO_LEFTSWING = 4
local HITINFO_UNK3 = 8
local HITINFO_MISS = 16
local HITINFO_ABSORB = 32
local HITINFO_RESIST = 64
local HITINFO_CRITICALHIT = 128
local HITINFO_UNK8 = 256
local HITINFO_UNK9 = 8192
local HITINFO_GLANCING = 16384
local HITINFO_CRUSHING = 32768
local HITINFO_NOACTION = 65536
local HITINFO_SWINGNOHITSOUND = 524288

local VICTIMSTATE_UNAFFECTED = 0
local VICTIMSTATE_NORMAL = 1
local VICTIMSTATE_DODGE = 2
local VICTIMSTATE_PARRY = 3
local VICTIMSTATE_INTERRUPT = 4
local VICTIMSTATE_BLOCKS = 5
local VICTIMSTATE_EVADES = 6
local VICTIMSTATE_IS_IMMUNE = 7
local VICTIMSTATE_DEFLECTS = 8

local victimStateNames = {
	[0] = "Unaffected",
	[1] = "Normal",
	[2] = "Dodged",
	[3] = "Parried",
	[4] = "Interrupted",
	[5] = "Blocked",
	[6] = "Evaded",
	[7] = "Immune",
	[8] = "Deflected"
}

function GetHitType(hitInfo)
	local isCrit = bit.band(hitInfo, HITINFO_CRITICALHIT) ~= 0
	local isGlancing = bit.band(hitInfo, HITINFO_GLANCING) ~= 0
	local isCrushing = bit.band(hitInfo, HITINFO_CRUSHING) ~= 0
	local isMiss = bit.band(hitInfo, HITINFO_MISS) ~= 0
	local isOffHand = bit.band(hitInfo, HITINFO_LEFTSWING) ~= 0

	local hitType = "Normal"
	if isMiss then
		hitType = "Miss"
	elseif isCrit then
		hitType = "Critical"
	elseif isGlancing then
		hitType = "Glancing"
	elseif isCrushing then
		hitType = "Crushing"
	end

	if isOffHand then
		hitType = hitType .. " (Off-hand)"
	end

	return hitType
end

function GetVictimStateName(victimState)
	return victimStateNames[victimState] or "Unknown"
end

local function onAutoAttack(attackerGuid, targetGuid, totalDamage, hitInfo, victimState, subDamageCount, blockedAmount, totalAbsorb, totalResist)
	local hitType = GetHitType(hitInfo)
	local victimStateName = GetVictimStateName(victimState)

	print(string.format(
		"Auto Attack: %s -> %s | %d damage (%s) | State: %s | SubDmg: %d | Absorbed: %d | Resisted: %d | Blocked: %d",
		attackerGuid, targetGuid, totalDamage, hitType, victimStateName,
		subDamageCount, totalAbsorb, totalResist, blockedAmount
	))
end

-- helpful event hooks for debugging
--Nampower:RegisterEvent("UNIT_CASTEVENT", function(casterGuid, targetGuid, event, spellID, castDuration)
--  if(casterGuid=="0x00000000001CD43C") then
--    print("CASTEVENT: " .. tostring(casterGuid) .. " -> " .. tostring(targetGuid) .. " event: " .. tostring(event) .. " spellID: " .. tostring(spellID) .. " castDuration: " .. tostring(castDuration))
--  end
--end)

--Nampower:RegisterEvent("AURA_CAST_ON_OTHER", function(spellId, caster, target, effect, effectname)
--  local unitName = target and UnitName(target) or ""
--  print("AURA_CAST_ON_OTHER: " .. tostring(spellId) .. " " .. tostring(GetSpellRecField(spellId, "name")) .. " by " .. tostring(UnitName(caster)) .. " on " .. unitName .. " effect: " .. tostring(effect) .. " effectname: " .. tostring(effectname))
--end)
--
--Nampower:RegisterEvent("AURA_CAST_ON_SELF", function(spellId, caster, target, effect, effectname)
--    local unitName = target and UnitName(target) or ""
--  print("AURA_CAST_ON_SELF: " .. tostring(spellId) .. " " .. tostring(GetSpellRecField(spellId, "name")) .. " by " .. tostring(UnitName(caster)) .. " on " .. unitName .. " effect: " .. tostring(effect) .. " effectname: " .. tostring(effectname))
--end)
--

--Nampower:RegisterEvent("AUTO_ATTACK_SELF", onAutoAttack)
--Nampower:RegisterEvent("AUTO_ATTACK_OTHER", onAutoAttack)

if not Nampower:HasMinimumVersion(2, 25, 0) then
	return
end

local function onSpellStart(itemId, spellId, casterGuid, targetGuid, castFlags, castTime)
	local spellName = GetSpellRecField and GetSpellRecField(spellId, "name") or spellId
	print(string.format(
		"SPELL_START: %s (id:%d) | Caster: %s -> Target: %s | ItemId: %d | Flags: %d | CastTime: %d",
		tostring(spellName), spellId, casterGuid, targetGuid, itemId, castFlags, castTime
	))
end

local function onSpellGo(itemId, spellId, casterGuid, targetGuid, castFlags, numTargetsHit, numTargetsMissed)
	local spellName = GetSpellRecField and GetSpellRecField(spellId, "name") or spellId
	print(string.format(
		"SPELL_GO: %s (id:%d) | Caster: %s -> Target: %s | ItemId: %d | Flags: %d | Hit: %d | Missed: %d",
		tostring(spellName), spellId, casterGuid, targetGuid, itemId, castFlags, numTargetsHit, numTargetsMissed
	))
end

local function onSpellFailedSelf(spellId, spellResult, failedByServer)
	local spellName = GetSpellRecField and GetSpellRecField(spellId, "name") or spellId
	local source = failedByServer == 1 and "Server" or "Client"
	print(string.format(
		"SPELL_FAILED_SELF: %s (id:%d) | Result: %d | Source: %s",
		tostring(spellName), spellId, spellResult, source
	))
end

local function onSpellFailedOther(casterGuid, spellId)
	local spellName = GetSpellRecField and GetSpellRecField(spellId, "name") or spellId
	print(string.format(
		"SPELL_FAILED_OTHER: %s (id:%d) | Caster: %s",
		tostring(spellName), spellId, casterGuid
	))
end

local function onSpellDelayed(casterGuid, delayMs)
	print(string.format(
		"SPELL_DELAYED: Caster: %s | Delay: %dms",
		casterGuid, delayMs
	))
end

local function onSpellChannelStart(spellId, targetGuid, durationMs)
	local spellName = GetSpellRecField and GetSpellRecField(spellId, "name") or spellId
	print(string.format(
		"SPELL_CHANNEL_START: %s (id:%d) | Target: %s | Duration: %dms",
		tostring(spellName), spellId, targetGuid, durationMs
	))
end

local function onSpellChannelUpdate(spellId, targetGuid, remainingMs)
	local spellName = GetSpellRecField and GetSpellRecField(spellId, "name") or spellId
	print(string.format(
		"SPELL_CHANNEL_UPDATE: %s (id:%d) | Target: %s | Remaining: %dms",
		tostring(spellName), spellId, targetGuid, remainingMs
	))
end

--Nampower:RegisterEvent("SPELL_START_SELF", onSpellStart)
--Nampower:RegisterEvent("SPELL_START_OTHER", onSpellStart)
--Nampower:RegisterEvent("SPELL_GO_SELF", onSpellGo)
--Nampower:RegisterEvent("SPELL_GO_OTHER", onSpellGo)
--Nampower:RegisterEvent("SPELL_FAILED_SELF", onSpellFailedSelf)
--Nampower:RegisterEvent("SPELL_FAILED_OTHER", onSpellFailedOther)
--Nampower:RegisterEvent("SPELL_DELAYED_SELF", onSpellDelayed)
--Nampower:RegisterEvent("SPELL_DELAYED_OTHER", onSpellDelayed)
--Nampower:RegisterEvent("SPELL_CHANNEL_START", onSpellChannelStart)
--Nampower:RegisterEvent("SPELL_CHANNEL_UPDATE", onSpellChannelUpdate)

if not Nampower:HasMinimumVersion(2, 26, 0) then
	return
end

-- Spell Heal Events (gated behind NP_EnableSpellHealEvents CVar, default 0)
-- SPELL_HEAL_BY_SELF - Fires when the active player is the caster (you healed someone)
-- SPELL_HEAL_BY_OTHER - Fires when someone other than the active player is the caster (someone else healed someone)
-- SPELL_HEAL_ON_SELF - Fires when the active player is the target (you received a heal)
-- Note: SPELL_HEAL_BY_SELF and SPELL_HEAL_ON_SELF can both fire for the same heal if you heal yourself

local function createSpellHealHandler(eventName)
	return function(targetGuid, casterGuid, spellId, amount, critical, periodic)
		local critText = critical == 1 and " (CRIT)" or ""
		local periodicText = periodic == 1 and " (PERIODIC)" or ""
		local spellName = GetSpellRecField and GetSpellRecField(spellId, "name") or spellId
		print(string.format(
			"%s: %s healed %s for %d with %s%s%s",
			eventName, UnitName(casterGuid), UnitName(targetGuid), amount, tostring(spellName), critText, periodicText
		))
	end
end

-- Spell Energize Events (gated behind NP_EnableSpellEnergizeEvents CVar, default 0)
-- SPELL_ENERGIZE_BY_SELF - Fires when the active player is the caster (you restored power to someone)
-- SPELL_ENERGIZE_BY_OTHER - Fires when someone other than the active player is the caster (someone else restored power)
-- SPELL_ENERGIZE_ON_SELF - Fires when the active player is the target (you received power)
-- Note: SPELL_ENERGIZE_BY_SELF and SPELL_ENERGIZE_ON_SELF can both fire for the same energize if you restore power to yourself

-- Power Type Constants
local POWER_MANA = 0
local POWER_RAGE = 1
local POWER_FOCUS = 2
local POWER_ENERGY = 3
local POWER_HAPPINESS = 4
local POWER_HEALTH = -2 -- 0xFFFFFFFE as unsigned

local POWER_NAMES = {
	[0] = "Mana",
	[1] = "Rage",
	[2] = "Focus",
	[3] = "Energy",
	[4] = "Happiness",
	[-2] = "Health",
}

function GetPowerTypeName(powerType)
	return POWER_NAMES[powerType] or "Unknown"
end

local function createSpellEnergizeHandler(eventName)
	return function(targetGuid, casterGuid, spellId, powerType, amount, periodic)
		local powerName = GetPowerTypeName(powerType)
		local periodicText = periodic == 1 and " (PERIODIC)" or ""
		local spellName = GetSpellRecField and GetSpellRecField(spellId, "name") or spellId
		print(string.format(
			"%s: %s restored %d %s to %s with %s%s",
			eventName, UnitName(casterGuid), amount, powerName, UnitName(targetGuid), tostring(spellName), periodicText
		))
	end
end

--Nampower:RegisterEvent("SPELL_HEAL_BY_SELF", createSpellHealHandler("SPELL_HEAL_BY_SELF"))
--Nampower:RegisterEvent("SPELL_HEAL_BY_OTHER", createSpellHealHandler("SPELL_HEAL_BY_OTHER"))
--Nampower:RegisterEvent("SPELL_HEAL_ON_SELF", createSpellHealHandler("SPELL_HEAL_ON_SELF"))
--Nampower:RegisterEvent("SPELL_ENERGIZE_BY_SELF", createSpellEnergizeHandler("SPELL_ENERGIZE_BY_SELF"))
--Nampower:RegisterEvent("SPELL_ENERGIZE_BY_OTHER", createSpellEnergizeHandler("SPELL_ENERGIZE_BY_OTHER"))
--Nampower:RegisterEvent("SPELL_ENERGIZE_ON_SELF", createSpellEnergizeHandler("SPELL_ENERGIZE_ON_SELF"))

if not Nampower:HasMinimumVersion(2, 30, 0) then
	return
end

-- Aura Duration Update Events
-- BUFF_UPDATE_DURATION_SELF - aura slot 0-31
-- DEBUFF_UPDATE_DURATION_SELF - aura slot 32-47
-- Parameters: auraSlot, durationMs, expirationTimeMs

local function createAuraDurationHandler(eventName)
	return function(auraSlot, durationMs, expirationTimeMs)
		print(string.format(
			"%s: slot %d | Duration: %dms | Expires: %d",
			eventName, auraSlot, durationMs, expirationTimeMs
		))
	end
end
--
--Nampower:RegisterEvent("DEBUFF_UPDATE_DURATION_SELF", createAuraDurationHandler("DEBUFF_UPDATE_DURATION_SELF"))
--Nampower:RegisterEvent("BUFF_UPDATE_DURATION_SELF", createAuraDurationHandler("BUFF_UPDATE_DURATION_SELF"))

-- Aura Added/Removed Events
-- BUFF_ADDED_SELF, BUFF_REMOVED_SELF, BUFF_ADDED_OTHER, BUFF_REMOVED_OTHER
-- DEBUFF_ADDED_SELF, DEBUFF_REMOVED_SELF, DEBUFF_ADDED_OTHER, DEBUFF_REMOVED_OTHER
-- Parameters: guid, luaSlot, spellId, stackCount, auraLevel, auraSlot

local function createAuraChangeHandler(eventName)
	return function(guid, luaSlot, spellId, stackCount, auraLevel, auraSlot)
		local spellName = GetSpellRecField and GetSpellRecField(spellId, "name") or spellId
		print(string.format(
			"%s: %s | luaSlot %d | %s (id:%d) | Stacks: %d | Level: %d | auraSlot: %d",
			eventName, guid, luaSlot, tostring(spellName), spellId, stackCount, auraLevel, auraSlot
		))
	end
end

--Nampower:RegisterEvent("BUFF_ADDED_SELF", createAuraChangeHandler("BUFF_ADDED_SELF"))
--Nampower:RegisterEvent("BUFF_REMOVED_SELF", createAuraChangeHandler("BUFF_REMOVED_SELF"))
--Nampower:RegisterEvent("BUFF_ADDED_OTHER", createAuraChangeHandler("BUFF_ADDED_OTHER"))
--Nampower:RegisterEvent("BUFF_REMOVED_OTHER", createAuraChangeHandler("BUFF_REMOVED_OTHER"))
--Nampower:RegisterEvent("DEBUFF_ADDED_SELF", createAuraChangeHandler("DEBUFF_ADDED_SELF"))
--Nampower:RegisterEvent("DEBUFF_REMOVED_SELF", createAuraChangeHandler("DEBUFF_REMOVED_SELF"))
--Nampower:RegisterEvent("DEBUFF_ADDED_OTHER", createAuraChangeHandler("DEBUFF_ADDED_OTHER"))
--Nampower:RegisterEvent("DEBUFF_REMOVED_OTHER", createAuraChangeHandler("DEBUFF_REMOVED_OTHER"))

-- Spell Damage Events (gated behind NP_EnableSpellDamageEvents CVar, default 0)
-- SPELL_DAMAGE_EVENT_SELF - Fires when the active player deals spell damage
-- SPELL_DAMAGE_EVENT_OTHER - Fires when someone other than the active player deals spell damage

-- Spell Damage Hit Info Constants
local SPELL_DAMAGE_HIT_NORMAL = 0
local SPELL_DAMAGE_HIT_CRIT = 2

-- Spell School Constants
local SPELL_SCHOOL_NORMAL = 0
local SPELL_SCHOOL_HOLY = 1
local SPELL_SCHOOL_FIRE = 2
local SPELL_SCHOOL_NATURE = 3
local SPELL_SCHOOL_FROST = 4
local SPELL_SCHOOL_SHADOW = 5
local SPELL_SCHOOL_ARCANE = 6

local SPELL_SCHOOL_NAMES = {
	[0] = "Physical",
	[1] = "Holy",
	[2] = "Fire",
	[3] = "Nature",
	[4] = "Frost",
	[5] = "Shadow",
	[6] = "Arcane",
}

function GetSpellSchoolName(spellSchool)
	return SPELL_SCHOOL_NAMES[spellSchool] or "Unknown"
end

local function createSpellDamageHandler(eventName)
	return function(targetGuid, casterGuid, spellId, amount, mitigationStr, hitInfo, spellSchool, effectAuraStr)
		local spellName = GetSpellRecField and GetSpellRecField(spellId, "name") or spellId
		local schoolName = GetSpellSchoolName(spellSchool)
		local critText = hitInfo == SPELL_DAMAGE_HIT_CRIT and " (CRIT)" or ""
		print(string.format(
			"%s: %s -> %s | %s (id:%d) | %d %s damage%s | Mitigation: %s | HitInfo: %d | Effects: %s",
			eventName, casterGuid, targetGuid, tostring(spellName), spellId, amount, schoolName, critText, mitigationStr, hitInfo, effectAuraStr
		))
	end
end

--Nampower:RegisterEvent("SPELL_DAMAGE_EVENT_SELF", createSpellDamageHandler("SPELL_DAMAGE_EVENT_SELF"))
--Nampower:RegisterEvent("SPELL_DAMAGE_EVENT_OTHER", createSpellDamageHandler("SPELL_DAMAGE_EVENT_OTHER"))

if not Nampower:HasMinimumVersion(2, 31, 0) then
	return
end

-- Spell Miss Events (gated behind NP_EnableSpellMissEvents CVar, default 0)
-- SPELL_MISS_SELF - Fires when the active player's spell misses/resists/is immune/etc
-- SPELL_MISS_OTHER - Fires when someone else's spell misses/resists/is immune/etc
-- Triggered by SMSG_SPELLLOGMISS, SMSG_PROCRESIST, and SMSG_SPELLORDAMAGE_IMMUNE

-- SpellMissInfo Constants
local SPELL_MISS_NONE = 0
local SPELL_MISS_MISS = 1
local SPELL_MISS_RESIST = 2
local SPELL_MISS_DODGE = 3
local SPELL_MISS_PARRY = 4
local SPELL_MISS_BLOCK = 5
local SPELL_MISS_EVADE = 6
local SPELL_MISS_IMMUNE = 7
local SPELL_MISS_IMMUNE2 = 8
local SPELL_MISS_DEFLECT = 9
local SPELL_MISS_ABSORB = 10
local SPELL_MISS_REFLECT = 11

local SPELL_MISS_NAMES = {
	[0] = "None",
	[1] = "Miss",
	[2] = "Resist",
	[3] = "Dodge",
	[4] = "Parry",
	[5] = "Block",
	[6] = "Evade",
	[7] = "Immune",
	[8] = "Immune",
	[9] = "Deflect",
	[10] = "Absorb",
	[11] = "Reflect",
}

function GetSpellMissName(missInfo)
	return SPELL_MISS_NAMES[missInfo] or "Unknown"
end

local function createSpellMissHandler(eventName)
	return function(casterGuid, targetGuid, spellId, missInfo)
		local spellName = GetSpellRecField and GetSpellRecField(spellId, "name") or spellId
		local missName = GetSpellMissName(missInfo)
		print(string.format(
			"%s: %s -> %s | %s (id:%d) | %s",
			eventName, UnitName(casterGuid), UnitName(targetGuid), tostring(spellName), spellId, missName
		))
	end
end

--Nampower:RegisterEvent("SPELL_MISS_SELF", createSpellMissHandler("SPELL_MISS_SELF"))
--Nampower:RegisterEvent("SPELL_MISS_OTHER", createSpellMissHandler("SPELL_MISS_OTHER"))
