local version = "1.0"
local evade = module.seek("evade")
local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")
if not evade then
	print(" ")
	console.set_color(79)
	print("-----------Nocturne by Kornis --------------")
	print("You need to have enabled 'Premium Evade' for Shielding.")
	print("If you don't want Evade to dodge, disable dodging but keep Module enabled. :>")
	print("--------------------------------------------")
	console.set_color(12)
end
local common = module.load("NocturneKornis", "common")
local database = module.load("NocturneKornis", "SpellDatabase")
local spellQ = {
	range = 1150,
	width = 60,
	speed = 1500,
	delay = 0.25,
	boundingRadiusMod = 1
}

local spellW = {range = 400}

local spellE = {
	range = 425
}

local spellR = {
	range = 2500
}

local interruptableSpells = {
	["anivia"] = {
		{menuslot = "R", slot = 3, spellname = "glacialstorm", channelduration = 6}
	},
	["caitlyn"] = {
		{menuslot = "R", slot = 3, spellname = "caitlynaceinthehole", channelduration = 1}
	},
	["ezreal"] = {
		{menuslot = "R", slot = 3, spellname = "ezrealtrueshotbarrage", channelduration = 1}
	},
	["fiddlesticks"] = {
		{menuslot = "W", slot = 1, spellname = "drain", channelduration = 5},
		{menuslot = "R", slot = 3, spellname = "crowstorm", channelduration = 1.5}
	},
	["gragas"] = {
		{menuslot = "W", slot = 1, spellname = "gragasw", channelduration = 0.75}
	},
	["janna"] = {
		{menuslot = "R", slot = 3, spellname = "reapthewhirlwind", channelduration = 3}
	},
	["karthus"] = {
		{menuslot = "R", slot = 3, spellname = "karthusfallenone", channelduration = 3}
	}, --common.IsValidTargetTarget will prevent from casting @ karthus while he's zombie
	["katarina"] = {
		{menuslot = "R", slot = 3, spellname = "katarinar", channelduration = 2.5}
	},
	["lucian"] = {
		{menuslot = "R", slot = 3, spellname = "lucianr", channelduration = 2}
	},
	["lux"] = {
		{menuslot = "R", slot = 3, spellname = "luxmalicecannon", channelduration = 0.5}
	},
	["malzahar"] = {
		{menuslot = "R", slot = 3, spellname = "malzaharr", channelduration = 2.5}
	},
	["masteryi"] = {
		{menuslot = "W", slot = 1, spellname = "meditate", channelduration = 4}
	},
	["missfortune"] = {
		{menuslot = "R", slot = 3, spellname = "missfortunebullettime", channelduration = 3}
	},
	["nunu"] = {
		{menuslot = "R", slot = 3, spellname = "absolutezero", channelduration = 3}
	},
	--excluding Orn's Forge Channel since it can be cancelled just by attacking him
	["pantheon"] = {
		{menuslot = "R", slot = 3, spellname = "pantheonrjump", channelduration = 2}
	},
	["shen"] = {
		{menuslot = "R", slot = 3, spellname = "shenr", channelduration = 3}
	},
	["twistedfate"] = {
		{menuslot = "R", slot = 3, spellname = "gate", channelduration = 1.5}
	},
	["varus"] = {
		{menuslot = "Q", slot = 0, spellname = "varusq", channelduration = 4}
	},
	["warwick"] = {
		{menuslot = "R", slot = 3, spellname = "warwickr", channelduration = 1.5}
	},
	["xerath"] = {
		{menuslot = "R", slot = 3, spellname = "xerathlocusofpower2", channelduration = 3}
	}
}
local str = {[-1] = "P", [0] = "Q", [1] = "W", [2] = "E", [3] = "R"}
local menu = menu("NocturneKornis", "Nocturne By Kornis")

menu:menu("combo", "Combo")
menu.combo:boolean("qcombo", "Use Q in Combo", true)
menu.combo:boolean("ecombo", "Use E in Combo", true)
menu.combo:boolean("rcombo", "Use R in Combo", true)
menu.combo:slider("hpr", " ^- Min. R Range", 500, 0, 600, 5)
menu.combo:slider("dontr", "Don't R in X Enemies", 3, 2, 5, 1)

menu:menu("blacklist", "E Blacklist")
local enemy = common.GetEnemyHeroes()
for i, allies in ipairs(enemy) do
	menu.blacklist:boolean(allies.charName, "Block: " .. allies.charName, false)
end

menu:menu("harass", "Harass")
menu.harass:boolean("qcombo", "Use Q in Harass", true)
menu.harass:boolean("ecombo", "Use E in Harass", true)

menu:menu("farming", "Farming")
menu.farming:menu("laneclear", "Lane Clear")

menu.farming.laneclear:boolean("farme", "Use E in Lane Clear", true)
menu.farming:menu("jungleclear", "Jungle Clear")
menu.farming.jungleclear:boolean("useq", "Use Q in Jungle Clear", true)
menu.farming.jungleclear:boolean("usee", "Use E in Jungle Clear", true)

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawe", "Draw E Range", true)
menu.draws:color("colore", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawr", "Draw R Range", true)
menu.draws:color("colorr", "  ^- Color", 255, 0x66, 0x33, 0x00)
menu.draws:boolean("drawdamage", "Draw Damage", true)

menu:menu("misc", "Misc.")
menu.misc:menu("Gap", "Gapcloser Settings")
menu.misc.Gap:boolean("GapA", "Use E for Anti-Gapclose", true)
menu.misc:menu("interrupt", "Interrupt Settings")
menu.misc.interrupt:boolean("inte", "Use Q to Interrupt", true)
menu.misc.interrupt:menu("interruptmenu", "Interrupt Settings")
for i = 1, #common.GetEnemyHeroes() do
	local enemy = common.GetEnemyHeroes()[i]
	local name = string.lower(enemy.charName)
	if enemy and interruptableSpells[name] then
		for v = 1, #interruptableSpells[name] do
			local spell = interruptableSpells[name][v]
			menu.misc.interrupt.interruptmenu:boolean(
				string.format(tostring(enemy.charName) .. tostring(spell.menuslot)),
				"Interrupt " .. tostring(enemy.charName) .. " " .. tostring(spell.menuslot),
				true
			)
		end
	end
end
menu:menu("SpellsMenu", "W Shielding")
menu.SpellsMenu:boolean("enable", "Enable Shielding", true)
menu.SpellsMenu:header("hello", " -- Enemy Skillshots -- ")
for _, i in pairs(database) do
	for l, k in pairs(common.GetEnemyHeroes()) do
		-- k = myHero
		if not database[_] then
			return
		end
		if i.charName == k.charName then
			if i.displayname == "" then
				i.displayname = _
			end
			if i.danger == 0 then
				i.danger = 1
			end
			if (menu.SpellsMenu[i.charName] == nil) then
				menu.SpellsMenu:menu(i.charName, i.charName)
			end
			menu.SpellsMenu[i.charName]:menu(_, "" .. i.charName .. " | " .. (str[i.slot] or "?") .. " " .. _)

			menu.SpellsMenu[i.charName][_]:boolean("Dodge", "Enable Block", true)

			menu.SpellsMenu[i.charName][_]:slider("hp", "HP to Dodge", 100, 1, 100, 5)
		end
	end
end
menu.SpellsMenu:header("hello", " -- Misc. -- ")
menu.SpellsMenu:boolean("targeteteteteteed", "Shield on Targeted Spells", true)

menu:header("wow", " ---- ")
menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)

TS.load_to_menu(menu)
local aaaaaaaaaasdfsaf = 0
function is_turret_near(position)
	local hewwo = false
	if aaaaaaaaaasdfsaf < os.clock() then
		aaaaaaaaaasdfsaf = os.clock() + 0.1
		objManager.loop(
			function(obj)
				if obj and obj.pos:dist(position) < 900 and obj.team == TEAM_ENEMY and obj.type == TYPE_TURRET then
					hewwo = true
				end
			end
		)

		return hewwo
	end
end
local TargetSelection = function(res, obj, dist)
	if dist <= spellQ.range then
		res.obj = obj
		return true
	end
end
local GetTarget = function()
	return TS.get_result(TargetSelection).obj
end

local TargetSelectionE = function(res, obj, dist)
	if dist <= spellE.range then
		res.obj = obj
		return true
	end
end
local GetTargetE = function()
	return TS.get_result(TargetSelectionE).obj
end
local TargetSelectionR = function(res, obj, dist)
	if dist <= spellR.range then
		res.obj = obj
		return true
	end
end
local GetTargetR = function()
	return TS.get_result(TargetSelectionR).obj
end

local function count_enemies_in_range(pos, range)
	local enemies_in_range = {}
	for i = 0, objManager.enemies_n - 1 do
		local enemy = objManager.enemies[i]
		if pos:dist(enemy.pos) < range and common.IsValidTarget(enemy) then
			enemies_in_range[#enemies_in_range + 1] = enemy
		end
	end
	return enemies_in_range
end
local function count_minions_in_range(pos, range)
	local enemies_in_range = {}
	for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
		local enemy = objManager.minions[TEAM_ENEMY][i]
		if pos:dist(enemy.pos) < range and common.IsValidTarget(enemy) then
			enemies_in_range[#enemies_in_range + 1] = enemy
		end
	end
	return enemies_in_range
end

local RLevelDamage = {150, 275, 400}
function RDamage(target)
	local damage = 0
	local extra = 0
	if player:spellSlot(3).level > 0 then
		damage =
			common.CalculatePhysicalDamage(
			target,
			(RLevelDamage[player:spellSlot(3).level] + (common.GetBonusAD() * 1.2)),
			player
		)
	end
	return damage
end

local QLevelDamage = {65, 110, 155, 200, 245}
function QDamage(target)
	local damage = 0
	if player:spellSlot(0).level > 0 then
		damage =
			common.CalculatePhysicalDamage(
			target,
			(QLevelDamage[player:spellSlot(0).level] + (common.GetBonusAD() * .75)),
			player
		)
	end
	return damage
end
local ELevelDamage = {80, 125, 170, 215, 260}
function EDamage(target)
	local damage = 0
	if player:spellSlot(2).level > 0 then
		damage =
			common.CalculatePhysicalDamage(target, (ELevelDamage[player:spellSlot(2).level] + (common.GetTotalAP() * 1)), player)
	end
	return damage
end

local function AutoInterrupt(spell)
	if menu.SpellsMenu.targeteteteteteed:get() then
		if spell and spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == player then
			if not spell.name:find("crit") then
				if not spell.name:find("BasicAttack") then
					if menu.SpellsMenu.targeteteteteteed:get() then
						player:castSpell("self", 1)
					end
				end
			end
		end
	end
	if menu.misc.interrupt.inte:get() then
		if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY then
			local enemyName = string.lower(spell.owner.charName)
			if interruptableSpells[enemyName] then
				for i = 1, #interruptableSpells[enemyName] do
					local spellCheck = interruptableSpells[enemyName][i]
					if
						menu.misc.interrupt.interruptmenu[spell.owner.charName .. spellCheck.menuslot]:get() and
							string.lower(spell.name) == spellCheck.spellname
					 then
						if player.pos2D:dist(spell.owner.pos2D) < spellE.range and common.IsValidTarget(spell.owner) then
							player:castSpell("obj", 2, spell.owner)
						end
					end
				end
			end
		end
	end
end

local function WGapcloser()
	if menu.misc.Gap.GapA:get() then
		local target =
			TS.get_result(
			function(res, obj, dist)
				if dist <= spellQ.range and obj.path.isActive and obj.path.isDashing then --add invulnverabilty check
					res.obj = obj

					return true
				end
			end
		).obj
		if target then
			local pred_pos = preds.core.lerp(target.path, network.latency, target.path.dashSpeed)
			if pred_pos and pred_pos:dist(player.path.serverPos2D) <= spellE.range then
				--orb.core.set_server_pause()
				player:castSpell("obj", 2, target)
			end
		end
	end
end

local function Combo()
	local target = GetTarget()
	local targetE = GetTargetE()
	local targetR = GetTargetR()
	if menu.combo.ecombo:get() and player:spellSlot(2).state == 0 then
		if common.IsValidTarget(targetE) and targetE then
			if (targetE.pos:dist(player) <= spellE.range) then
				if menu.blacklist[target.charName] and not menu.blacklist[target.charName]:get() then
					player:castSpell("obj", 2, targetE)
				end
			end
		end
	end
	if menu.combo.qcombo:get() then
		if common.IsValidTarget(target) and target then
			if (target.pos:dist(player) <= spellQ.range) then
				local seg = preds.linear.get_prediction(spellQ, target)
				if seg and seg.startPos:dist(seg.endPos) <= spellQ.range then
					player:castSpell("pos", 0, vec3(seg.endPos.x, target.y, seg.endPos.y))
				end
			end
		end
	end
	if menu.combo.rcombo:get() and player:spellSlot(3).state == 0 then
		if
			common.IsValidTarget(targetR) and targetR and #count_enemies_in_range(targetR.pos, 900) < menu.combo.dontr:get() and
				targetR.pos:dist(player.pos) >= menu.combo.hpr:get()
		 then
			if (targetR.pos:dist(player) <= spellR.range) then
				player:castSpell("obj", 3, targetR)
			end
		end
	end
end
-- Credits to Avada's Kalista. <3
function DrawDamagesE(target)
	if target.isVisible and not target.isDead then
		for i = 0, graphics.anchor_n - 1 do
			local obj = objManager.toluaclass(graphics.anchor[i].ptr)
			if obj.type == player.type and obj.team ~= player.team and obj.isOnScreen then
				local hp_bar_pos = graphics.anchor[i].pos
				local xPos = hp_bar_pos.x - 46
				local yPos = hp_bar_pos.y + 11.5
				if obj.charName == "Annie" then
					yPos = yPos + 2
				end

				local Rdmg = 0
				local Edmg = 0
				local Wdmg = 0

				Edmg = EDamage(obj)
				Edmg = QDamage(obj)
				Wdmg = RDamage(obj)

				local damage = obj.health - (Rdmg + Edmg + Wdmg)

				local x1 = xPos + ((obj.health / obj.maxHealth) * 102)
				local x2 = xPos + (((damage > 0 and damage or 0) / obj.maxHealth) * 102)
				if ((Rdmg + Edmg + Wdmg) < obj.health) then
					graphics.draw_line_2D(x1, yPos, x2, yPos, 10, 0xFFEE9922)
				end
				if ((Rdmg + Edmg + Wdmg) > obj.health) then
					graphics.draw_line_2D(x1, yPos, x2, yPos, 10, 0xFF2DE04A)
				end
			end
		end
		local pos = graphics.world_to_screen(target.pos)
		if (math.floor((EDamage(target) + RDamage(target) + QDamage(target)) / target.health * 100) < 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 255, 153, 51))

			graphics.draw_text_2D(
				tostring(math.floor(EDamage(target) + RDamage(target) + QDamage(target))) ..
					" (" ..
						tostring(math.floor((EDamage(target) + RDamage(target) + QDamage(target)) / target.health * 100)) ..
							"%)" .. "Not Killable",
				20,
				pos.x + 55,
				pos.y - 80,
				graphics.argb(255, 255, 153, 51)
			)
		end
		if (math.floor((EDamage(target) + RDamage(target) + QDamage(target)) / target.health * 100) >= 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_text_2D(
				tostring(math.floor(EDamage(target) + RDamage(target) + QDamage(target))) ..
					" (" ..
						tostring(math.floor((EDamage(target) + RDamage(target) + QDamage(target)) / target.health * 100)) ..
							"%)" .. "Kilable",
				20,
				pos.x + 55,
				pos.y - 80,
				graphics.argb(255, 150, 255, 200)
			)
		end
	end
end

local function JungleClear()
	if menu.farming.jungleclear.useq:get() and player:spellSlot(0).state == 0 then
		for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
			local minion = objManager.minions[TEAM_NEUTRAL][i]
			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
					minion.pos:dist(player.pos) < spellQ.range
			 then
				local seg = preds.linear.get_prediction(spellQ, minion)
				if seg and seg.startPos:dist(seg.endPos) < spellQ.range then
					player:castSpell("pos", 0, vec3(seg.endPos.x, minion.y, seg.endPos.y))
				end
			end
		end
	end
	if menu.farming.jungleclear.usee:get() and player:spellSlot(2).state == 0 then
		for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
			local minion = objManager.minions[TEAM_NEUTRAL][i]
			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
					minion.pos:dist(player.pos) < spellE.range
			 then
				player:castSpell("obj", 2, minion)
			end
		end
	end
end

local function Harass()
	local target = GetTarget()
	if menu.harass.qcombo:get() then
		if common.IsValidTarget(target) and target then
			if (target.pos:dist(player) <= spellQ.range) then
				local seg = preds.linear.get_prediction(spellQ, target)
				if seg and seg.startPos:dist(seg.endPos) <= spellQ.range then
					player:castSpell("pos", 0, vec3(seg.endPos.x, target.y, seg.endPos.y))
				end
			end
		end
	end

	if menu.harass.ecombo:get() and player:spellSlot(2).state == 0 then
		if common.IsValidTarget(target) and target then
			if (target.pos:dist(player) <= spellE.range) then
				if menu.blacklist[target.charName] and not menu.blacklist[target.charName]:get() then
					player:castSpell("obj", 2, target)
				end
			end
		end
	end
end

local function LaneClear()
	if player:spellSlot(2).state == 0 then
		if menu.farming.laneclear.farme:get() then
			for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
				local minion = objManager.minions[TEAM_ENEMY][i]
				if minion and minion.pos:dist(player.pos) <= spellE.range and not minion.isDead and common.IsValidTarget(minion) then
					player:castSpell("obj", 2, minion)
				end
			end
		end
	end
end

local function OnDraw()
	if player.isOnScreen then
		if menu.draws.drawq:get() then
			graphics.draw_circle(player.pos, spellQ.range, 2, menu.draws.colorq:get(), 80)
		end
		if menu.draws.drawr:get() then
			minimap.draw_circle(player.pos, spellR.range, 2, menu.draws.colorr:get(), 30)
		end
		if menu.draws.drawe:get() then
			graphics.draw_circle(player.pos, spellE.range, 2, menu.draws.colore:get(), 80)
		end
	end
	if menu.draws.drawdamage:get() then
		for i = 0, objManager.enemies_n - 1 do
			local enemies = objManager.enemies[i]
			if
				enemies and common.IsValidTarget(enemies) and player.pos:dist(enemies) < 3000 and enemies.isOnScreen and
					not common.CheckBuffType(enemies, 17)
			 then
				DrawDamagesE(enemies)
			end
		end
	end
end

local function OnTick()
	if menu.SpellsMenu.enable:get() then
		if evade then
			for i = 1, #evade.core.active_spells do
				local spell = evade.core.active_spells[i]

				if spell.data.spell_type == "Target" and spell.target == player and spell.owner.type == TYPE_HERO then
					if not spell.name:find("crit") then
						if not spell.name:find("basicattack") then
							if menu.SpellsMenu.targeteteteteteed:get() then
								player:castSpell("self", 1)
							end
						end
					end
				elseif
					spell.polygon and spell.polygon:Contains(player.path.serverPos) ~= 0 and
						(not spell.data.collision or #spell.data.collision == 0)
				 then
					for _, k in pairs(database) do
						if
							spell.name:find(_:lower()) and menu.SpellsMenu[k.charName] and menu.SpellsMenu[k.charName][_].Dodge:get() and
								menu.SpellsMenu[k.charName][_].hp:get() >= (player.health / player.maxHealth) * 100
						 then
							if spell.missile then
								if (player.pos:dist(spell.missile.pos) / spell.data.speed < network.latency + 0.35) then
									player:castSpell("self", 1)
								end
							end
							if spell.name:find(_:lower()) then
								if k.speeds == math.huge or spell.data.spell_type == "Circular" then
									player:castSpell("self", 1)
								end
							end
							if spell.data.speed == math.huge or spell.data.spell_type == "Circular" then
								player:castSpell("self", 1)
							end
						end
					end
				end
			end
		end
	end
	if menu.misc.Gap.GapA:get() then
		WGapcloser()
	end

	if menu.keys.clearkey:get() then
		LaneClear()
		JungleClear()
	end
	if menu.keys.harasskey:get() then
		Harass()
	end
	if menu.keys.combokey:get() then
		Combo()
	end
end

--cb.add(cb.removebuff, OnRemoveBuff)
cb.add(cb.draw, OnDraw)
cb.add(cb.spell, AutoInterrupt)
orb.combat.register_f_pre_tick(OnTick)

--cb.add(cb.tick, OnTick)
