local version = "1.0"
local evade = module.seek("evade")
local common = module.load("JaxKornis", "common")

local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")

local spellQ = {
	range = 700
}

local spellW = {range = 300}

local spellE = {
	range = 350
}

local spellR = {
	range = 0
}
local menu = menu("JaxKornis", "Jax By Kornis")
--dts = tSelector(menu, 1100, 1)
--dts:addToMenu()
menu:menu("combo", "Combo")
menu.combo:dropdown("combomode", "Combo Mode", 2, {"Q > E", "E > Q"})
menu.combo:header("qset", " -- Q Settings-- ")
menu.combo:boolean("qcombo", "Use Q in Combo", true)
menu.combo:slider("minq", " ^- Min. Range ", 300, 1, 400, 5)
menu.combo:header("wset", " -- W Settings-- ")
menu.combo:boolean("wcombo", "Use W in Combo", true)
menu.combo:boolean("waa", " ^- Only for Auto Attack reset", true)
menu.combo:header("eset", " -- E Settings-- ")
menu.combo:boolean("ecombo", "Use E in Combo", true)
menu.combo:dropdown("emode", "E Mode", 2, {"Instant", "Delayed"})
menu.combo:keybind("changemode", "Mode Changing: ", "T", nil)
menu.combo:slider("edelay", "E Delay (ms)", 1300, 0, 2000, 5)
menu.combo:header("rset", " -- R Settings-- ")
menu.combo:boolean("rcombo", "Use R in Combo", false)
menu.combo:slider("minr", "Min. Enemies for R", 2, 1, 5, 1)
menu.combo:slider("minhp", "Min. Health Percent for R", 30, 1, 100, 1)
menu.combo:header("hmmm", " --- ")
menu.combo:boolean("items", "Use Items", true)

menu:menu("harass", "Harass")
menu.harass:dropdown("combomode", "Harass Mode", 2, {"Q > E", "E > Q"})
menu.harass:header("qset", " -- Q Settings-- ")
menu.harass:boolean("qcombo", "Use Q in Harass", true)
menu.harass:slider("minq", " ^- Min. Range ", 300, 1, 400, 5)
menu.harass:header("wset", " -- W Settings-- ")
menu.harass:boolean("wcombo", "Use W in Harass", true)
menu.harass:boolean("waa", " ^- Only for Auto Attack reset", true)
menu.harass:header("eset", " -- E Settings-- ")
menu.harass:boolean("ecombo", "Use E in Harass", false)
menu.harass:slider("edelay", "E Delay (ms)", 1300, 0, 2000, 5)

menu:menu("farming", "Farming")
menu.farming:menu("laneclear", "Lane Clear")
menu.farming.laneclear:boolean("farmw", "Use W to Farm", true)
menu.farming:menu("jungleclear", "Jungle Clear")
menu.farming.jungleclear:boolean("useq", "Use Q in Jungle Clear", true)
menu.farming.jungleclear:boolean("farmw", "Use W in Jungle Clear", true)
menu.farming.jungleclear:boolean("usee", "Use E in Jungle Clear", true)
menu.farming.jungleclear:slider("edelay", "E Delay (ms)", 1300, 0, 2000, 5)

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawe", "Draw E Range", true)
menu.draws:color("colore", "  ^- Color", 255, 0x66, 0x33, 0x00)
menu.draws:boolean("drawtoggle", "Draw Toggles", true)
menu.draws:boolean("damage", "Draw Damage", true)
menu.draws:slider("includeaa", " ^- Include X AA Damage", 3, 1, 10, 1)
menu:menu("wardjump", "Wardjump")
menu.wardjump:boolean("useq", "Use Q to Wardjump", true)
menu.wardjump:keybind("fleeq", "Wardjump Key:", "G", nil)
menu:header("aa", " ---- ")
menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit Key", "X", nil)
TS.load_to_menu(menu)
local TargetSelection = function(res, obj, dist)
	if dist < spellQ.range then
		res.obj = obj
		return true
	end
end

local GetTarget = function()
	return TS.get_result(TargetSelection).obj
end
local TargetSelection2 = function(res, obj, dist)
	if dist < spellQ.range + 100 then
		res.obj = obj
		return true
	end
end

local GetTarget2 = function()
	return TS.get_result(TargetSelection2).obj
end
function GetJumpObject(pos, rad)
	local distance = math.huge
	local objToJump = nil
	local radi = rad or 300
	for i = 0, objManager.maxObjects - 1 do
		local obj = objManager.get(i)
		if obj and (obj.type == TYPE_MINION or obj.type == TYPE_HERO) and obj.ptr ~= player.ptr and common.IsValidTarget(obj) then
			if obj.pos:dist(pos) <= radi and obj.pos:dist(pos) < distance then
				distance = obj.pos:dist(pos)
				objToJump = obj
			end
		end
	end
	return objToJump
end
local uhh2 = false
local something2 = 0

local function Toggle()
	if menu.combo.changemode:get() then
		if (uhh2 == false and os.clock() > something2) then
			uhh2 = true
			menu.combo.emode:set("value", 1)
			something2 = os.clock() + 0.2
		end
		if (uhh2 == true and os.clock() > something2) then
			uhh2 = false
			menu.combo.emode:set("value", 2)
			something2 = os.clock() + 0.2
		end
	end
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
local meowmeowmeow = 0
local hellooooooo = 0
sheenTimer = 0
local function CreateObj(object)
	if object and object.pos:dist(player.pos) < 300 and object.name:find("Glow_buf") then
		sheenTimer = os.clock() + 1.7
	end
end
local function AutoInterrupt(spell)
	if spell and spell.owner == player and spell.name == "JaxCounterStrike" then
		if menu.keys.clearkey:get() then
			meowmeowmeow = game.time + menu.farming.jungleclear.edelay:get() / 1000
		end
		if menu.keys.harasskey:get() then
			meowmeowmeow = game.time + menu.harass.edelay:get() / 1000
		end
		if menu.keys.combokey:get() then
			meowmeowmeow = game.time + menu.combo.edelay:get() / 1000
		end
	end
end
local QLevelDamage = {80, 120, 160, 200, 240}
function QDamage(target)
	local damage = 0
	if player:spellSlot(0).level > 0 then
		damage =
			common.CalculatePhysicalDamage(
			target,
			(QLevelDamage[player:spellSlot(0).level] + (common.GetBonusAD() * 1) + common.GetTotalAP() * 0.6),
			player
		)
	end
	return damage
end

local hasSheen = false
local hasTF = false
local last_item_update = 0
local WLevelDamage = {40, 75, 110, 145, 180}

function WDamage(target)
	local onhitPhysical = 0
	if os.clock() > last_item_update then
		hasSheen = false
		hasTF = false
		for i = 0, 5 do
			if player:itemID(i) == 3078 then
				hasTF = true
			end
			if player:itemID(i) == 3057 then
				hasSheen = true
			end
		end

		last_item_update = os.clock() + 2
	end
	if hasTF and (os.clock() >= sheenTimer or common.CheckBuff(player, "sheen")) then
		onhitPhysical = 2 * player.baseAttackDamage
	end
	if hasSheen and not hasTF and (os.clock() >= sheenTimer or common.CheckBuff(player, "sheen")) then
		onhitPhysical = onhitPhysical + player.baseAttackDamage
	end

	local damage = 0
	if player:spellSlot(1).level > 0 then
		damage =
			common.CalculatePhysicalDamage(
			target,
			(WLevelDamage[player:spellSlot(1).level] + common.GetTotalAP() * 0.6) + onhitPhysical,
			player
		)
	end
	return damage + common.CalculateAADamage(target)
end

orb.combat.register_f_after_attack(
	function()
		if menu.keys.clearkey:get() and menu.farming.laneclear.farmw:get() and player:spellSlot(1).state == 0 then
			for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
				local minion = objManager.minions[TEAM_ENEMY][i]
				if
					minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
						minion.pos:dist(player.pos) < 300
				 then
					player:castSpell("self", 1)
					player:attack(minion)

					return "on_after_attack_hydra"
				end
			end
		end
		if menu.keys.clearkey:get() and menu.farming.jungleclear.farmw:get() and player:spellSlot(1).state == 0 then
			for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
				local minion = objManager.minions[TEAM_NEUTRAL][i]
				if
					minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
						minion.pos:dist(player.pos) < 300
				 then
					player:castSpell("self", 1)
					player:attack(minion)

					return "on_after_attack_hydra"
				end
			end
		end
		if menu.keys.harasskey:get() and player:spellSlot(1).state == 0 then
			if orb.combat.target then
				if orb.combat.target and common.IsValidTarget(orb.combat.target) and player.pos:dist(orb.combat.target.pos) < 300 then
					if menu.harass.waa:get() and menu.harass.wcombo:get() then
						player:castSpell("self", 1)
						player:attack(orb.combat.target)

						return "on_after_attack_hydra"
					end
				end
			end
		end
		if menu.keys.combokey:get() and player:spellSlot(1).state == 0 then
			if orb.combat.target then
				if orb.combat.target and common.IsValidTarget(orb.combat.target) and player.pos:dist(orb.combat.target.pos) < 300 then
					if menu.combo.waa:get() and menu.combo.wcombo:get() then
						player:castSpell("self", 1)
						player:attack(orb.combat.target)

						return "on_after_attack_hydra"
					end
				end
			end
		end
		if menu.keys.combokey:get() or menu.keys.harasskey:get() then
			if orb.combat.target then
				if orb.combat.target and common.IsValidTarget(orb.combat.target) and player.pos:dist(orb.combat.target.pos) < 300 then
					if menu.combo.items:get() then
						for i = 6, 11 do
							local item = player:spellSlot(i).name
							if item and (item == "ItemTitanicHydraCleave" or item == "ItemTiamatCleave") and player:spellSlot(i).state == 0 then
								player:castSpell("obj", i, player)
								player:attack(orb.combat.target)

								return "on_after_attack_hydra"
							end
						end
					end
				end
			end
		end

		orb.combat.set_invoke_after_attack(false)
	end
)
local hewoo = 0
local function Combo()
	local target = GetTarget()
	local target2 = GetTarget2()

	if target then
		if menu.combo.combomode:get() == 1 then
			if menu.combo.qcombo:get() and common.IsValidTarget(target) and (target.pos:dist(player) <= spellQ.range) then
				if target.pos:dist(player.pos) > menu.combo.minq:get() then
					player:castSpell("obj", 0, target)
				end
				if QDamage(target) >= target.health then
					player:castSpell("obj", 0, target)
				end
				if target.path.isActive and target.path.isDashing then
					player:castSpell("obj", 0, target)
				end
			end
			if menu.combo.wcombo:get() then
				if orb.combat.target then
					if
						common.IsValidTarget(orb.combat.target) and WDamage(orb.combat.target) >= orb.combat.target.health and
							player.pos:dist(orb.combat.target.pos) < 250
					 then
						player:castSpell("self", 1)
					end
				end
			end
			if menu.combo.wcombo:get() and not menu.combo.waa:get() then
				if orb.combat.target then
					if common.IsValidTarget(orb.combat.target) and player.pos:dist(orb.combat.target.pos) < c250 then
						player:castSpell("self", 1)
					end
				end
			end
			if menu.combo.ecombo:get() and target.pos:dist(player.pos) <= spellE.range then
				if menu.combo.emode:get() == 1 then
					if not common.CheckBuff(player, "JaxCounterStrike") then
						player:castSpell("self", 2)
					end

					if common.CheckBuff(player, "JaxCounterStrike") then
						player:castSpell("self", 2)
					end
				end
				if menu.combo.emode:get() == 2 then
					if not common.CheckBuff(player, "JaxCounterStrike") then
						player:castSpell("self", 2)
					end

					if common.CheckBuff(player, "JaxCounterStrike") and game.time > meowmeowmeow then
						player:castSpell("self", 2)
					end
				end
			end
		end
	end

	if target2 then
		if menu.combo.combomode:get() == 2 then
			if menu.combo.ecombo:get() and target2.pos:dist(player.pos) <= hewoo and player:spellSlot(2).state == 0 then
				if menu.combo.emode:get() == 1 then
					if not common.CheckBuff(player, "JaxCounterStrike") then
						player:castSpell("self", 2)
						hellooooooo = game.time + 0.1
					end

					if common.CheckBuff(player, "JaxCounterStrike") then
						player:castSpell("self", 2)
					end
				end
				if menu.combo.emode:get() == 2 then
					if not common.CheckBuff(player, "JaxCounterStrike") then
						player:castSpell("self", 2)
						hellooooooo = game.time + 0.1
					end

					if
						common.CheckBuff(player, "JaxCounterStrike") and game.time > meowmeowmeow and
							target2.pos:dist(player.pos) <= spellE.range
					 then
						player:castSpell("self", 2)
					end
				end
			end

			if hellooooooo < game.time then
				if menu.combo.qcombo:get() and common.IsValidTarget(target2) and (target2.pos:dist(player) <= spellQ.range) then
					if target.pos:dist(player.pos) > menu.combo.minq:get() then
						player:castSpell("obj", 0, target)
					end
					if QDamage(target2) >= target2.health then
						player:castSpell("obj", 0, target)
					end
					if target2.path.isActive and target2.path.isDashing then
						player:castSpell("obj", 0, target2)
					end
				end
			end
			if menu.combo.wcombo:get() then
				if orb.combat.target then
					if
						common.IsValidTarget(orb.combat.target) and WDamage(orb.combat.target) >= orb.combat.target.health and
							player.pos:dist(orb.combat.target.pos) < 250
					 then
						player:castSpell("self", 1)
					end
				end
			end
			if menu.combo.wcombo:get() and not menu.combo.waa:get() then
				if orb.combat.target then
					if
						common.IsValidTarget(orb.combat.target) and
							player.pos:dist(orb.combat.target.pos) < common.GetAARange(orb.combat.target)
					 then
						player:castSpell("self", 1)
					end
				end
			end
		end
	end
	if
		menu.combo.rcombo:get() and (player.health / player.maxHealth) * 100 <= menu.combo.minhp:get() and
			#count_enemies_in_range(player.pos, 700) >= menu.combo.minr:get()
	 then
		player:castSpell("self", 3)
	end
end
-- Credits to Avada's Kalista. <3
function DrawDamagesE(target)
	if target.isVisible and not target.isDead then
		local pos = graphics.world_to_screen(target.pos)
		if
			(math.floor(
				(QDamage(target) + WDamage(target) + common.CalculateAADamage(target) * menu.draws.includeaa:get()) / target.health *
					100
			) < 100)
		 then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 255, 153, 51))

			graphics.draw_text_2D(
				tostring(
					math.floor(QDamage(target) + WDamage(target) + common.CalculateAADamage(target) * menu.draws.includeaa:get())
				) ..
					" (" ..
						tostring(
							math.floor(
								(QDamage(target) + WDamage(target) + common.CalculateAADamage(target) * menu.draws.includeaa:get()) /
									target.health *
									100
							)
						) ..
							"%)" .. "Not Killable",
				20,
				pos.x + 55,
				pos.y - 80,
				graphics.argb(255, 255, 153, 51)
			)
		end
		if
			(math.floor(
				(QDamage(target) + WDamage(target) + common.CalculateAADamage(target) * menu.draws.includeaa:get()) / target.health *
					100
			) >= 100)
		 then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_text_2D(
				tostring(
					math.floor(QDamage(target) + WDamage(target) + common.CalculateAADamage(target) * menu.draws.includeaa:get())
				) ..
					" (" ..
						tostring(
							math.floor(
								(QDamage(target) + WDamage(target) + common.CalculateAADamage(target) * menu.draws.includeaa:get()) /
									target.health *
									100
							)
						) ..
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
				player:castSpell("obj", 0, minion)
			end
		end
	end

	if menu.farming.jungleclear.usee:get() and player:spellSlot(2).state == 0 then
		for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
			local minion = objManager.minions[TEAM_NEUTRAL][i]
			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
					minion.pos:dist(player.pos) < spellQ.range
			 then
				if not common.CheckBuff(player, "JaxCounterStrike") then
					player:castSpell("self", 2)
				end

				if common.CheckBuff(player, "JaxCounterStrike") and game.time > meowmeowmeow then
					player:castSpell("self", 2)
				end
			end
		end
	end
end

local function Harass()
	local target = GetTarget()
	local target2 = GetTarget2()

	if target then
		if menu.harass.combomode:get() == 1 then
			if menu.harass.qcombo:get() and common.IsValidTarget(target) and (target.pos:dist(player) <= spellQ.range) then
				if target.pos:dist(player.pos) > menu.harass.minq:get() then
					player:castSpell("obj", 0, target)
				end
				if QDamage(target) > target.health then
					player:castSpell("obj", 0, target)
				end
				if target.path.isActive and target.path.isDashing then
					player:castSpell("obj", 0, target)
				end
			end
			if menu.harass.wcombo:get() and not menu.harass.waa:get() then
				if orb.combat.target then
					if
						common.IsValidTarget(orb.combat.target) and
							player.pos:dist(orb.combat.target.pos) < common.GetAARange(orb.combat.target)
					 then
						player:castSpell("self", 1)
					end
				end
			end
			if menu.harass.ecombo:get() and target.pos:dist(player.pos) <= spellE.range then
				if not common.CheckBuff(player, "JaxCounterStrike") then
					player:castSpell("self", 2)
				end

				if common.CheckBuff(player, "JaxCounterStrike") and game.time > meowmeowmeow then
					player:castSpell("self", 2)
				end
			end
		end
	end
	if target2 then
		if menu.harass.combomode:get() == 2 then
			if menu.harass.ecombo:get() and target2.pos:dist(player.pos) <= hewoo and player:spellSlot(2).state == 0 then
				if not common.CheckBuff(player, "JaxCounterStrike") then
					player:castSpell("self", 2)
					hellooooooo = game.time + 0.1
				end

				if
					common.CheckBuff(player, "JaxCounterStrike") and game.time > meowmeowmeow and
						target2.pos:dist(player.pos) <= spellE.range
				 then
					player:castSpell("self", 2)
				end
			end

			if hellooooooo < game.time then
				if menu.harass.qcombo:get() and common.IsValidTarget(target2) and (target2.pos:dist(player) <= spellQ.range) then
					if target.pos:dist(player.pos) > menu.harass.minq:get() then
						player:castSpell("obj", 0, target)
					end
					if QDamage(target2) > target2.health then
						player:castSpell("obj", 0, target)
					end
					if target2.path.isActive and target2.path.isDashing then
						player:castSpell("obj", 0, target2)
					end
				end
			end
			if menu.harass.wcombo:get() and not menu.harass.waa:get() then
				if orb.combat.target then
					if
						common.IsValidTarget(orb.combat.target) and
							player.pos:dist(orb.combat.target.pos) < common.GetAARange(orb.combat.target)
					 then
						player:castSpell("self", 1)
					end
				end
			end
		end
	end
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
local meowwwwwwwwwwwwwwwwwwwwwwwwwwww = 0
local function LaneClear()
	if menu.farming.laneclear.farmw:get() and player:spellSlot(1).state == 0 and orb.core.can_attack() then
		for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
			local minion = objManager.minions[TEAM_ENEMY][i]
			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
					minion.pos:dist(player.pos) < common.GetAARange(minion)
			 then
				if os.clock() > meowwwwwwwwwwwwwwwwwwwwwwwwwwww then
					player:castSpell("self", 1)
					player:attack(minion)
					meowwwwwwwwwwwwwwwwwwwwwwwwwwww = os.clock() + 0.3
				end
			end
		end
	end
end

local function OnDraw()
	if player.isOnScreen then
		if menu.draws.drawq:get() then
			graphics.draw_circle(player.pos, spellQ.range, 2, menu.draws.colorq:get(), 50)
		end
		if menu.draws.drawe:get() then
			graphics.draw_circle(player.pos, spellE.range, 2, menu.draws.colore:get(), 50)
		end
	end
	if menu.draws.drawtoggle:get() then
		local pos = graphics.world_to_screen(vec3(player.x, player.y, player.z))

		if menu.combo.emode:get() == 1 then
			graphics.draw_text_2D("E Mode: Instant", 22, pos.x - 80, pos.y + 20, graphics.argb(255, 222, 160, 255))
		else
			graphics.draw_text_2D("E Mode: Delayed", 22, pos.x - 80, pos.y + 20, graphics.argb(255, 222, 160, 255))
		end
	end

	if menu.draws.damage:get() then
		for i = 0, objManager.enemies_n - 1 do
			local enemies = objManager.enemies[i]
			if enemies and not enemies.isDead and enemies.isVisible and enemies.isTargetable and player.pos:dist(enemies) < 2000 then
				DrawDamagesE(enemies)
			end
		end
	end
end
local meowwwwwwwww = 0
local meowmeow = 0

local function OnTick()
	Toggle()
	if player:spellSlot(0).state == 0 then
		hewoo = spellQ.range + 100
	else
		hewoo = spellE.range + 100
	end
	if menu.wardjump.useq:get() and menu.wardjump.fleeq:get() then
		player:move(mousePos)
		if player:spellSlot(0).state == 0 then
			for i = 6, 12 do
				if meowwwwwwwww < os.clock() then
					if player:spellSlot(i).name == "JammerDevice" or player:spellSlot(i).name == "TrinketTotemLvl1" then
						local jumpPos = game.mousePos
						if jumpPos:dist(player.pos) > 700 then
							jumpPos = player.pos + (jumpPos - player.pos):norm() * 600
						end
						local jumpObject = GetJumpObject(jumpPos)
						if not jumpObject then
							player:castSpell("pos", player:spellSlot(i).slot, jumpPos)
							meowwwwwwwww = os.clock() + 1
						end
					end
				end
			end
			if player:spellSlot(0).state == 0 then
				local jumpPos = game.mousePos
				if jumpPos:dist(player.pos) > 700 then
					jumpPos = player.pos + (jumpPos - player.pos):norm() * 700
				end
				local jumpObject = GetJumpObject(jumpPos)
				if jumpObject then
					player:castSpell("obj", 0, jumpObject)
				end
			end
		end
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

cb.add(cb.draw, OnDraw)

orb.combat.register_f_pre_tick(OnTick)
cb.add(cb.spell, AutoInterrupt)

cb.add(cb.create_particle, CreateObj)
--cb.add(cb.tick, OnTick)
