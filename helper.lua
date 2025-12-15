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
