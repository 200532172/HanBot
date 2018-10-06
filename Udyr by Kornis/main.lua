local version = "1.0"

local common = module.load("UdyrKornis", "common")

local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")

local spellQ = {}

local spellW = {}

local spellE = {
	range = 800
}

local spellR = {}

local menu = menu("UdyrKornis", "Udyr By Kornis")

menu:menu("combo", "Combo")

menu.combo:boolean("qcombo", "Use Q  in Combo", true)
menu.combo:boolean("wcombo", "Use W in Combo", true)
menu.combo:slider("whp", " ^- Priority W if X Health", 30, 0, 100, 1)
menu.combo:boolean("ecombo", "Use E in Combo", true)
menu.combo:boolean("rcombo", "Use R in Combo", true)

menu.combo:dropdown("stance", "Stance Rotations:  ", 1, {"E > R > W > Q", "E  > Q > R > W"})
menu.combo:header("aaa", " ---- ")
menu.combo:boolean("items", "Use Items", true)

menu:menu("farming", "Farming")
menu.farming:dropdown("stance", "Stance Rotations:  ", 2, {"R > W > R", "Q > R > W"})
menu.farming:menu("laneclear", "Lane Clear")
menu.farming.laneclear:boolean("farmq", "Use Q to Farm", true)
menu.farming.laneclear:boolean("farmw", "Use W to Farm", true)
menu.farming.laneclear:boolean("farmr", "Use R to Farm", true)
menu.farming:menu("jungleclear", "Jungle Clear")
menu.farming.jungleclear:boolean("useq", "Use Q in Jungle Clear", true)
menu.farming.jungleclear:boolean("usew", "Use W in Jungle Clear", true)
menu.farming.jungleclear:boolean("user", "Use R in Jungle Clear", true)

menu:menu("flee", "Flee")
menu.flee:boolean("stune", "Stun with E while Flee", true)
menu.flee:keybind("fleekey", "Flee Key", "G", nil)

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawe", "Draw E Engage Range", true)
menu.draws:color("colore", "  ^- Color", 255, 255, 255, 255)
menu:header("aaa", " ---- ")
menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)

TS.load_to_menu(menu)
local TargetSelection = function(res, obj, dist)
	if dist < spellE.range then
		res.obj = obj
		return true
	end
end

local GetTarget = function()
	return TS.get_result(TargetSelection).obj
end
local TargetSelectionW = function(res, obj, dist)
	if dist < 270 then
		res.obj = obj
		return true
	end
end

local GetTargetW = function()
	return TS.get_result(TargetSelectionW).obj
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

local function Combo()
	if menu.combo.items:get() then
		local target = GetTarget()
		if target then
			if common.IsValidTarget(target) then
				if (target.pos:dist(player) <= 650) then
					for i = 6, 11 do
						local item = player:spellSlot(i).name

						if item and (item == "ItemSwordOfFeastAndFamine") then
							player:castSpell("obj", i, target)
						end
						if item and (item == "BilgewaterCutlass") then
							player:castSpell("obj", i, target)
						end
					end
				end
			end
		end
	end
	if
		menu.combo.wcombo:get() and menu.combo.whp:get() >= (player.health / player.maxHealth) * 100 and
			player:spellSlot(1).state == 0
	 then
		local target = GetTargetW()
		if target then
			if common.IsValidTarget(target) then
				player:castSpell("self", 1)
			end
		end
	end
	if menu.combo.ecombo:get() and player:spellSlot(2).state == 0 then
		local target = GetTarget()
		if target then
			if common.IsValidTarget(target) and target.pos:dist(player.pos) > 250 then
				player:castSpell("self", 2)
			--	return meow
			end
		end
	end

	if menu.combo.ecombo:get() and player:spellSlot(2).state == 0 then
		local target = GetTarget()
		if target then
			if
				common.IsValidTarget(target) and
					(common.CountBuff2(player, "UdyrPhoenixStance") ~= 3 or
						(common.CountBuff2(player, "UdyrPhoenixStance") == 3 and target.pos:dist(player.pos) > 250)) and
					not common.CheckBuff(target, "udyrbearstuncheck")
			 then
				player:castSpell("self", 2)
			--	return meow
			end
		end
	end
	if orb.combat.target then
		if common.IsValidTarget(orb.combat.target) and player.pos:dist(orb.combat.target.pos) < 250 then
			if menu.combo.stance:get() == 1 then
				if menu.combo.ecombo:get() and player:spellSlot(2).state == 0 then
					local target = GetTarget()
					if target then
						if
							common.IsValidTarget(target) and
								(common.CountBuff2(player, "UdyrPhoenixStance") ~= 3 or
									(common.CountBuff2(player, "UdyrPhoenixStance") == 3 and target.pos:dist(player.pos) > 250)) and
								not common.CheckBuff(target, "udyrbearstuncheck")
						 then
							player:castSpell("self", 2)
						--	return meow
						end
					end
				end
				local target = GetTargetW()

				if target then
					if orb.core.can_attack() then
						if
							common.CheckBuff(target, "udyrbearstuncheck") or player:spellSlot(2).level == 0 or
								menu.combo.ecombo:get() == false
						 then
							if menu.combo.rcombo:get() and player:spellSlot(3).state == 0 then
								player:castSpell("self", 3)
								return meow
							end
							if
								(player:spellSlot(3).state ~= 0 or menu.combo.rcombo:get() == false) and
									common.CountBuff2(player, "UdyrPhoenixStance") ~= 3 or
									player:spellSlot(3).level == 0
							 then
								if menu.combo.wcombo:get() and player:spellSlot(1).state == 0 then
									player:castSpell("self", 1)
									return meow
								end
							end
							if
								(player:spellSlot(1).state ~= 0 or menu.combo.wcombo:get() == false) and
									common.CountBuff2(player, "UdyrPhoenixStance") ~= 3 or
									player:spellSlot(1).level == 0
							 then
								if menu.combo.qcombo:get() and player:spellSlot(0).state == 0 then
									player:castSpell("self", 0)
									return meow
								end
							end
						end
					end
				end
			end
			if menu.combo.stance:get() == 2 then
				local target = GetTargetW()

				if target then
					if
						common.CheckBuff(target, "udyrbearstuncheck") or player:spellSlot(2).level == 0 or
							menu.combo.ecombo:get() == false
					 then
						if orb.core.can_attack() then
							if menu.combo.qcombo:get() and player:spellSlot(0).state == 0 then
								player:castSpell("self", 0)
								return meow
							end
							if (player:spellSlot(0).state ~= 0 or menu.combo.qcombo:get() == false) or player:spellSlot(0).level == 0 then
								if menu.combo.rcombo:get() and player:spellSlot(3).state == 0 then
									player:castSpell("self", 3)
									return meow
								end
							end
							if
								(player:spellSlot(3).state ~= 0 or menu.combo.rcombo:get() == false) and
									common.CountBuff2(player, "UdyrPhoenixStance") ~= 3 or
									player:spellSlot(3).level == 0
							 then
								if menu.combo.wcombo:get() and player:spellSlot(1).state == 0 then
									player:castSpell("self", 1)
									return meow
								end
							end
						end
					end
				end
			end
		end
	end
end
orb.combat.register_f_after_attack(
	function()
		if menu.combo.items:get() and menu.keys.combokey:get() then
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
local function JungleClear()
	if orb.core.can_attack() then
		if menu.farming.stance:get() == 1 then
			for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
				local minion = objManager.minions[TEAM_NEUTRAL][i]
				if
					minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
						minion.pos:dist(player.pos) < 300
				 then
					if (player.buff["udyrbearstance"] and minion.buff["udyrbearstuncheck"]) or player.buff["udyrbearstance"] == nil then
						if menu.farming.jungleclear.user:get() and player:spellSlot(3).state == 0 then
							if minion.pos:dist(player.pos) < 300 and player:spellSlot(3).state == 0 then
								player:castSpell("self", 3)
								return meow
							end
						end
						if player:spellSlot(3).state ~= 0 and common.CountBuff2(player, "UdyrPhoenixStance") == 1 then
							if minion.pos:dist(player.pos) < 300 then
								if menu.farming.jungleclear.usew:get() and player:spellSlot(1).state == 0 then
									player:castSpell("self", 1)
									return meow
								end
							end
						end
					end
				end
			end
		end
		if menu.farming.stance:get() == 2 then
			for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
				local minion = objManager.minions[TEAM_NEUTRAL][i]
				if
					minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
						minion.pos:dist(player.pos) < 300
				 then
					if (player.buff["udyrbearstance"] and minion.buff["udyrbearstuncheck"]) or player.buff["udyrbearstance"] == nil then
						if menu.farming.jungleclear.useq:get() then
							if minion.pos:dist(player.pos) < 300 and player:spellSlot(0).state == 0 then
								player:castSpell("self", 0)
								return meow
							end
						end
						if player:spellSlot(0).state ~= 0 or player:spellSlot(0).level == 0 then
							if minion.pos:dist(player.pos) < 300 then
								if menu.farming.jungleclear.user:get() and player:spellSlot(3).state == 0 then
									player:castSpell("self", 3)
									return meow
								end
							end
						end
						if
							player:spellSlot(3).state ~= 0 and common.CountBuff2(player, "UdyrPhoenixStance") == 1 or
								player:spellSlot(3).level == 0
						 then
							if menu.farming.jungleclear.usew:get() then
								if minion.pos:dist(player.pos) < 300 and player:spellSlot(1).state == 0 then
									player:castSpell("self", 1)
									return meow
								end
							end
						end
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
local function LaneClear()
	if orb.core.can_attack() then
		if menu.farming.stance:get() == 1 then
			for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
				local minion = objManager.minions[TEAM_ENEMY][i]
				if minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead then
					if menu.farming.laneclear.farmr:get() and player:spellSlot(3).state == 0 then
						if minion.pos:dist(player.pos) < 300 and player:spellSlot(3).state == 0 then
							player:castSpell("self", 3)
							return meow
						end
					end
					if player:spellSlot(3).state ~= 0 and common.CountBuff2(player, "UdyrPhoenixStance") == 1 then
						if minion.pos:dist(player.pos) < 300 then
							if menu.farming.laneclear.farmw:get() and player:spellSlot(1).state == 0 then
								player:castSpell("self", 1)
								return meow
							end
						end
					end
				end
			end
		end
		if menu.farming.stance:get() == 2 then
			for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
				local minion = objManager.minions[TEAM_ENEMY][i]
				if minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead then
					if menu.farming.laneclear.farmq:get() then
						if minion.pos:dist(player.pos) < 300 and player:spellSlot(0).state == 0 then
							player:castSpell("self", 0)
							return meow
						end
					end
					if player:spellSlot(0).state ~= 0 or player:spellSlot(0).level == 0 then
						if minion.pos:dist(player.pos) < 300 then
							if menu.farming.laneclear.farmr:get() and player:spellSlot(3).state == 0 then
								player:castSpell("self", 3)
								return meow
							end
						end
					end
					if
						player:spellSlot(3).state ~= 0 and common.CountBuff2(player, "UdyrPhoenixStance") == 1 and
							menu.farming.laneclear.farmw:get() or
							player:spellSlot(3).level == 0
					 then
						if minion.pos:dist(player.pos) < 300 and player:spellSlot(1).state == 0 then
							player:castSpell("self", 1)
							return meow
						end
					end
				end
			end
		end
	end
end

local function OnDraw()
	if player.isOnScreen then
		if menu.draws.drawe:get() then
			graphics.draw_circle(player.pos, spellE.range, 2, menu.draws.colore:get(), 50)
		end
	end
end

local function OnTick()
	if menu.flee.fleekey:get() then
		player:move(mousePos)
		if player:spellSlot(2).state == 0 then
			player:castSpell("self", 2)
		end
		if menu.flee.stune:get() then
			local target = GetTargetW()
			if target and target.pos:dist(player.pos) <= 240 then
				if not common.CheckBuff(target, "udyrbearstuncheck") and common.CheckBuff(player, "UdyrBearStance") then
					player:attack(target)
				end
			end
		end
	end
	if menu.keys.combokey:get() then
		Combo()
	end
	if menu.keys.clearkey:get() then
		LaneClear()
		JungleClear()
	end
end

cb.add(cb.draw, OnDraw)
orb.combat.register_f_pre_tick(OnTick)
--cb.add(cb.updatebuff, updatebuff)

--cb.add(cb.tick, OnTick)
