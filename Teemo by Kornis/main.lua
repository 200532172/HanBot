local version = "1.0"

local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")

local common = module.load("TeemoKornis", "common")

local ShroomTableVIP = {
	{x = 3700.708, y = -11.22648, z = 9294.094},
	{x = 3700.708, y = -11.22648, z = 9294.094},
	{x = 2314, y = 53.165, z = 9722},
	{x = 3090, y = -68.03732, z = 10810},
	{x = 4722, y = -71.2406, z = 10010},
	{x = 5208, y = -71.2406, z = 9114},
	{x = 4724, y = 52.53909, z = 7590},
	{x = 4564, y = 51.83786, z = 6060},
	{x = 2760, y = 52.96445, z = 5178},
	{x = 4440, y = 56.8484, z = 11840},
	{x = 2420, y = 52.8381, z = 13482},
	{x = 1630, y = 52.8381, z = 13008},
	{x = 1172, y = 52.8381, z = 12302},
	{x = 5666, y = 52.8381, z = 12722},
	{x = 8004, y = 56.4768, z = 11782},
	{x = 9194, y = 53.35013, z = 11368},
	{x = 8280, y = 50.06194, z = 10254},
	{x = 6728, y = 53.82967, z = 11450},
	{x = 6242, y = 54.09851, z = 10270},
	{x = 6484, y = -71.2406, z = 8380},
	{x = 8380, y = -71.2406, z = 6502},
	{x = 9099.75, y = 52.95337, z = 7376.637},
	{x = 7376, y = 52.8726, z = 8802},
	{x = 7602, y = 52.56985, z = 5928},
	{x = 9372, y = -71.2406, z = 5674},
	{x = 10148, y = -71.2406, z = 4801.525},
	{x = 9772, y = 9.031885, z = 6458},
	{x = 9938, y = 51.62378, z = 7900},
	{x = 11465, y = 51.72557, z = 7157.772},
	{x = 12481, y = 51.7294, z = 5232.559},
	{x = 11266, y = -7.897567, z = 5542},
	{x = 11290, y = 64.39886, z = 8694},
	{x = 12676, y = 51.6851, z = 7310.818},
	{x = 12022, y = 9154, z = 51.25105},
	{x = 6544, y = 48.257, z = 4732},
	{x = 5576, y = 51.42581, z = 3512},
	{x = 6888, y = 51.94016, z = 3082},
	{x = 8070, y = 51.5508, z = 3472},
	{x = 8594, y = 51.73177, z = 4668},
	{x = 10388, y = 49.81641, z = 3046},
	{x = 9160, y = 59.97022, z = 2122},
	{x = 12518, y = 53.66707, z = 1504},
	{x = 13404, y = 51.3669, z = 2482},
	{x = 11854, y = -68.06037, z = 3922}
}
local spellQ = {
	range = 700
}

local spellW = {}

local spellE = {}

local spellR = {
	range = 400,
	delay = 1.4,
	speed = 1400,
	radius = 50,
	boundingRadiusMod = 1
}

local menu = menu("TeemoKornis", "Teemo By Kornis")

menu:menu("combo", "Combo")
menu.combo:boolean("qcombo", "Use Q in Combo", true)
menu.combo:boolean("qaa", " ^- Only for Auto Attack reset", true)
menu.combo:boolean("wcombo", "Use W in Combo", true)
menu.combo:boolean("waa", " ^- Only if in AA Range", true)
menu.combo:boolean("rcombo", "Use R in Combo", true)
menu.combo:slider("hpr", " ^- Min. R Stacks", 1, 1, 3, 1)
menu.combo:header("aaa", " ---- ")
menu.combo:boolean("items", "Use Items", true)

menu:menu("blacklist", "Q Blacklist")
local enemy = common.GetEnemyHeroes()
for i, allies in ipairs(enemy) do
	menu.blacklist:boolean(allies.charName, "Block: " .. allies.charName, false)
end

menu:menu("harass", "Harass")
menu.harass:boolean("qcombo", "Use Q in Harass", true)
menu.harass:boolean("qaa", " ^- Only for Auto Attack reset", false)

menu:menu("farming", "Farming")
menu.farming:menu("laneclear", "Lane Clear")
menu.farming.laneclear:boolean("farmq", "Use Q to Farm", true)
menu.farming.laneclear:boolean("lastq", " ^- Only for Last Hit", true)

menu.farming.laneclear:boolean("farmr", "Use R in Lane Clear", true)
menu.farming.laneclear:slider("hitsr", " ^- if Hits X Minions", 3, 1, 6, 1)
menu.farming:menu("jungleclear", "Jungle Clear")
menu.farming.jungleclear:boolean("useq", "Use Q in Jungle Clear", true)
menu.farming.jungleclear:boolean("user", "Use R in Jungle Clear", true)
menu:menu("lasthit", "Last Hit")
menu.lasthit:boolean("useq", "Use Q to Last Hit", true)

menu:menu("killsteal", "Killsteal")
menu.killsteal:boolean("ksq", "Killsteal with Q", true)

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawr", "Draw R Range", true)
menu.draws:color("colorr", "  ^- Color", 255, 0x66, 0x33, 0x00)
menu.draws:boolean("drawmushroom", "Draw Mushroom Positions", true)
menu.draws:boolean("drawdamage", "Draw Damage", true)
menu:menu("misc", "Misc.")
menu.misc:menu("Gap", "Gapcloser Settings")
menu.misc.Gap:boolean("GapA", "Use Q for Anti-Gapclose", true)
menu:header("aaa", " ---- ")
menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)

TS.load_to_menu(menu)
local meowwwwwwwwwwwwww = 0
local function AutoInterrupt(spell)
	if spell and spell.owner == player and spell.name == "TeemoRCast" then
		meowwwwwwwwwwwwww = game.time + 2.2
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

local TargetSelectionW = function(res, obj, dist)
	if dist <= 1000 then
		res.obj = obj
		return true
	end
end

local GetTargetW = function()
	return TS.get_result(TargetSelectionW).obj
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

orb.combat.register_f_after_attack(
	function()
		if menu.keys.combokey:get() then
			if orb.combat.target then
				if
					menu.combo.qaa:get() and menu.combo.qcombo:get() and orb.combat.target and common.IsValidTarget(orb.combat.target) and
						player.pos:dist(orb.combat.target.pos) < 700
				 then
					if menu.blacklist[orb.combat.target.charName] and not menu.blacklist[orb.combat.target.charName]:get() then
						if player:spellSlot(0).state == 0 then
							player:castSpell("obj", 0, orb.combat.target)
							orb.core.set_server_pause()
							orb.combat.set_invoke_after_attack(false)
							return "on_after_attack_hydra"
						end
					end
				end
			end
		end
		if menu.keys.harasskey:get() then
			if orb.combat.target then
				if
					menu.harass.qaa:get() and menu.harass.qcombo:get() and orb.combat.target and
						common.IsValidTarget(orb.combat.target) and
						player.pos:dist(orb.combat.target.pos) < 700
				 then
					if player:spellSlot(0).state == 0 then
						player:castSpell("obj", 0, orb.combat.target)
						orb.core.set_server_pause()
						orb.combat.set_invoke_after_attack(false)
						return "on_after_attack_hydra"
					end
				end
			end
		end
		orb.combat.set_invoke_after_attack(false)
	end
)

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

local QLevelDamage = {80, 125, 170, 215, 260}
function QDamage(target)
	local damage = 0
	if player:spellSlot(0).level > 0 then
		damage =
			common.CalculateMagicDamage(target, (QLevelDamage[player:spellSlot(0).level] + (common.GetTotalAP() * 0.8)), player)
	end
	return damage
end
local ELevelDamage = {34, 68, 102, 136, 170}
function EDamage(target)
	local damage = 0
	if player:spellSlot(2).level > 0 then
		damage =
			common.CalculateMagicDamage(target, (ELevelDamage[player:spellSlot(2).level] + (common.GetTotalAP() * 0.7)), player)
	end
	return damage + common.CalculateAADamage(target)
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
			if pred_pos and pred_pos:dist(player.path.serverPos2D) <= spellQ.range then
				player:castSpell("obj", 0, target)
			end
		end
	end
end

local function Combo()
	local target = GetTarget()
	if common.IsValidTarget(target) then
		if menu.combo.items:get() then
			if (target.pos:dist(player) <= 650) then
				for i = 6, 11 do
					local item = player:spellSlot(i).name

					if item and (item == "HextechGunblade") then
						player:castSpell("obj", i, target)
					end
					if item and (item == "BilgewaterCutlass") then
						player:castSpell("obj", i, target)
					end
				end
			end
		end
	end
	if menu.combo.qcombo:get() then
		if common.IsValidTarget(target) and not menu.combo.qaa:get() and target then
			if (target.pos:dist(player) <= spellQ.range) then
				if menu.blacklist[target.charName] and not menu.blacklist[target.charName]:get() then
					player:castSpell("obj", 0, target)
				end
			end
		end
	end
	if menu.combo.wcombo:get() then
		local target = GetTargetW()
		if common.IsValidTarget(target) and target then
			if not menu.combo.waa:get() then
				player:castSpell("self", 1)
			end
			if menu.combo.waa:get() then
				if target.pos:dist(player.pos) <= 580 then
					player:castSpell("self", 1)
				end
			end
		end
	end
	if menu.combo.rcombo:get() and player:spellSlot(3).state == 0 and meowwwwwwwwwwwwww < game.time then
		local target = GetTargetR()
		if common.IsValidTarget(target) and target then
			if (target.pos:dist(player) <= spellR.range) then
				local seg = preds.circular.get_prediction(spellR, target)
				if seg and seg.startPos:dist(seg.endPos) <= spellR.range and menu.combo.hpr:get() <= player:spellSlot(3).stacks then
					player:castSpell("pos", 3, vec3(seg.endPos.x, target.y, seg.endPos.y))
				end
			end
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
				player:castSpell("obj", 0, minion)
			end
		end
	end
	if menu.farming.jungleclear.user:get() and player:spellSlot(3).state == 0 then
		for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
			local minion = objManager.minions[TEAM_NEUTRAL][i]
			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
					game.time > meowwwwwwwwwwwwww
			 then
				local pos = preds.circular.get_prediction(spellR, minion)
				if pos and pos.startPos:dist(pos.endPos) < spellR.range and player:spellSlot(3).state == 0 then
					player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
				end
			end
		end
	end
end

local function Harass()
	local target = GetTarget()
	if menu.harass.qcombo:get() then
		if common.IsValidTarget(target) and target then
			if not menu.harass.qaa:get() then
				if (target.pos:dist(player) <= spellQ.range) then
					player:castSpell("obj", 0, target)
				end
			end
		end
	end
end
local function KillSteal()
	local enemy = common.GetEnemyHeroes()
	for i, enemies in ipairs(enemy) do
		if enemies and common.IsValidTarget(enemies) and not common.CheckBuffType(enemies, 17) then
			local hp = common.GetShieldedHealth("AP", enemies)
			if menu.killsteal.ksq:get() then
				if
					player:spellSlot(0).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellQ.range and
						QDamage(enemies) >= hp
				 then
					player:castSpell("obj", 0, enemies)
				end
			end
		end
	end
end

local function LaneClear()
	if not mhh then
		if menu.farming.laneclear.farmq:get() and player:spellSlot(0).state == 0 then
			for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
				local minion = objManager.minions[TEAM_ENEMY][i]
				if
					minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
						minion.pos:dist(player.pos) <= spellQ.range
				 then
					local minionPos = vec3(minion.x, minion.y, minion.z)
					if minionPos:dist(player.pos) <= spellQ.range then
						if not menu.farming.laneclear.lastq:get() then
							player:castSpell("obj", 0, minion)
						end
						if menu.farming.laneclear.lastq:get() and player:spellSlot(0).state == 0 then
							for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
								local minion = objManager.minions[TEAM_ENEMY][i]
								if
									minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
										minion.pos:dist(player.pos) <= spellQ.range
								 then
									local minionPos = vec3(minion.x, minion.y, minion.z)
									--delay = player.pos:dist(minion.pos) / 3500 + 0.2
									delay = 0.25 + player.pos:dist(minion.pos) / 3500
									if (QDamage(minion) >= orb.farm.predict_hp(minion, delay, true)) then
										player:castSpell("obj", 0, minion)
									end
								end
							end
						end
					end
				end
			end
		end
		if player:spellSlot(3).state == 0 then
			if menu.farming.laneclear.farmr:get() then
				for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
					local minion = objManager.minions[TEAM_ENEMY][i]
					if minion and minion.pos:dist(player.pos) <= spellR.range and not minion.isDead and common.IsValidTarget(minion) then
						local minionPos = vec3(minion.x, minion.y, minion.z)
						if minionPos then
							local seg = preds.circular.get_prediction(spellR, minion)
							if seg and seg.startPos:dist(seg.endPos) < spellR.range then
								if
									#count_minions_in_range(vec3(seg.endPos.x, minionPos.y, seg.endPos.y), 450) >=
										menu.farming.laneclear.hitsr:get()
								 then
									if game.time > meowwwwwwwwwwwwww then
										player:castSpell("pos", 3, vec3(seg.endPos.x, minionPos.y, seg.endPos.y))
									end
								end
							end
						end
					end
				end
			end
		end
	end
end
local function LastHit()
	if menu.lasthit.useq:get() and player:spellSlot(0).state == 0 then
		for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
			local minion = objManager.minions[TEAM_ENEMY][i]
			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
					minion.pos:dist(player.pos) <= spellQ.range
			 then
				local minionPos = vec3(minion.x, minion.y, minion.z)
				--delay = player.pos:dist(minion.pos) / 3500 + 0.2
				delay = 0.25 + player.pos:dist(minion.pos) / 3500
				if (QDamage(minion) >= orb.farm.predict_hp(minion, delay, true)) then
					player:castSpell("obj", 0, minion)
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
			graphics.draw_circle(player.pos, spellR.range, 2, menu.draws.colorr:get(), 80)
		end
	end

	if menu.draws.drawmushroom:get() then
		for i, spot in pairs(ShroomTableVIP) do
			if spot and game.cameraPos then
				if (game.cameraPos:dist(spot) <= 3000) then
					graphics.draw_circle(spot, 100, 2, graphics.argb(255, 255, 204, 204), 3)
				end
			end
		end
	end

	if menu.draws.drawdamage:get() then
		for i = 0, objManager.enemies_n - 1 do
			local obj = objManager.enemies[i]
			if obj and obj.isVisible and obj.team == TEAM_ENEMY and obj.isOnScreen then
				--GetBestQLocation(obj)
				local hp_bar_pos = obj.barPos
				local xPos = hp_bar_pos.x + 164
				local yPos = hp_bar_pos.y + 122.5
				local Edmg = EDamage(obj)
				local Qdmg = QDamage(obj) or 0
				local damage = obj.health - (Edmg + Qdmg)
				local x1 = xPos + ((obj.health / obj.maxHealth) * 102)
				local x2 = xPos + (((damage > 0 and damage or 0) / obj.maxHealth) * 102)
				if damage > 0 then
					graphics.draw_line_2D(x1, yPos, x2, yPos, 10, 0xFFEE9922)
				else
					graphics.draw_line_2D(x1, yPos, x2, yPos, 10, 0xFF00B159)
				end
			end
		end
	end
end

local function OnTick()
	if menu.misc.Gap.GapA:get() then
		WGapcloser()
	end

	if menu.keys.lastkey:get() then
		LastHit()
	end
	KillSteal()
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
	if player:spellSlot(3).level == 1 then
		spellR.range = 400
	end
	if player:spellSlot(3).level == 2 then
		spellR.range = 650
	end
	if player:spellSlot(3).level == 3 then
		spellR.range = 900
	end
end

cb.add(cb.draw, OnDraw)
orb.combat.register_f_pre_tick(OnTick)
cb.add(cb.spell, AutoInterrupt)
--cb.add(cb.tick, OnTick)
