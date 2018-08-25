local version = "1.0"
local evade = module.seek("evade")

local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")

local common = module.load("SupportAIO" .. player.charName, "common")

local spellQ = {
	range = 800,
	delay = 0.7,
	width = 100,
	speed = math.huge,
	boundingRadiusMod = 1
}

local spellW = {
	range = 850,
	delay = 0.65,
	radius = 150,
	speed = 1000,
	boundingRadiusMod = 1
}

local spellE = {
	range = 1050,
	delay = 0.25,
	width = 60,
	speed = 1200,
	boundingRadiusMod = 1
}

local spellR = {
	range = 750,
	delay = 0.3,
	radius = 60,
	speed = 1000,
	boundingRadiusMod = 1
}

local str = {[-1] = "P", [0] = "Q", [1] = "W", [2] = "E", [3] = "R"}
local menu = menu("SupportAIO" .. player.charName, "Support AIO - Zyra")
--dts = tSelector(menu, 1100, 1)
--dts:addToMenu()
menu:menu("combo", "Combo")
menu.combo:dropdown("combomode", "Combo Mode", 1, {"Q-W-R-E-W", "E-W-R-Q-W"}, 1)
menu.combo:boolean("qcombo", "Use Q in Combo", true)
menu.combo:boolean("wcombo", "Use W in Combo", true)
menu.combo:boolean("ecombo", "Use E in Combo", true)
menu.combo:boolean("rcombo", "Use R in Combo", true)
menu.combo:dropdown("rmode", "R Mode", 1, {"If hits X enemies", "Only if Killlable"}, 1)
menu.combo:slider("hitr", "If hits X enemies", 2, 1, 5, 1)
menu.combo:keybind("semir", "Semi-R Key", "T", nil)
menu.combo.semir:set("tooltip", "It Ignores how many Enemies it can hit.")

menu:menu("harass", "Harass")
menu.harass:boolean("qcombo", "Use Q in Harass", true)
menu.harass:boolean("wcombo", "Use W in Harass", true)
menu.harass:boolean("ecombo", "Use E in Harass", true)

menu:menu("laneclear", "Farming")
menu.laneclear:keybind("toggle", "Farm Toggle", "Z", nil)
menu.laneclear:menu("push", "Lane Clear")
menu.laneclear.push:slider("mana", "Mana Manager", 30, 0, 100, 1)
menu.laneclear.push:boolean("useq", "Use Q to Farm", true)
menu.laneclear.push:slider("hitq", " ^- If Hits", 3, 0, 6, 1)
menu.laneclear.push:boolean("usew", "Use W to Farm", true)

menu.laneclear:menu("jungle", "Jungle Clear")
menu.laneclear.jungle:slider("mana", "Mana Manager", 30, 0, 100, 1)
menu.laneclear.jungle:boolean("useq", "Use Q in Jungle", true)
menu.laneclear.jungle:boolean("usew", "Use W in Jungle", true)
menu.laneclear.jungle:boolean("usee", "Use E in Jungle", true)

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("draww", "Draw W Range", false)
menu.draws:color("colorw", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("drawe", "Draw E Range", false)
menu.draws:color("colore", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawr", "Draw R Range", false)
menu.draws:color("colorr", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawdamage", "Draw Damage", true)
menu.draws:boolean("drawtoggle", "Draw Farm Toggle", true)
menu.draws:boolean("drawseeds", "Draw Seeds", true)

menu:menu("misc", "Anti-Gapclose Settings")
menu.misc:boolean("GapA", "Use E for Anti-Gapclose", true)
menu.misc:menu("blacklist", "Anti-Gapclose Blacklist")

local enemy = common.GetEnemyHeroes()
for i, allies in ipairs(enemy) do
	menu.misc.blacklist:boolean(allies.charName, "Block: " .. allies.charName, false)
end
menu:header("uhh", " --- ")
menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)
local uhh = false
local something = 0
local objSomething = {}
local function DeleteObj(object)
	if object and object.name:find("W_Seed") then
		objSomething[object.ptr] = nil
	end
end

local function CreateObj(object)
	if object and object.name:find("W_Seed") then
		objSomething[object.ptr] = object
	end
end
local function Toggle()
	if menu.laneclear.toggle:get() then
		if (uhh == false and os.clock() > something) then
			uhh = true
			something = os.clock() + 0.3
		end
		if (uhh == true and os.clock() > something) then
			uhh = false
			something = os.clock() + 0.3
		end
	end
end
local TargetSelectionQ = function(res, obj, dist)
	if dist < spellQ.range then
		res.obj = obj
		return true
	end
end
local GetTargetQ = function()
	return TS.get_result(TargetSelectionQ).obj
end

local TargetSelectionE = function(res, obj, dist)
	if dist < spellE.range then
		res.obj = obj
		return true
	end
end
local GetTargetE = function()
	return TS.get_result(TargetSelectionE).obj
end

local TargetSelectionR = function(res, obj, dist)
	if dist < spellR.range then
		res.obj = obj
		return true
	end
end

local GetTargetR = function()
	return TS.get_result(TargetSelectionR).obj
end
local QLevelDamage = {60, 95, 130, 165, 200}
function QDamage(target)
	local damage = 0
	if player:spellSlot(0).level > 0 then
		damage =
			common.CalculateMagicDamage(target, (QLevelDamage[player:spellSlot(0).level] + (common.GetTotalAP() * .6)), player)
	end
	return damage
end
local ELevelDamage = {60, 105, 150, 195, 240}
function EDamage(target)
	local damage = 0
	if player:spellSlot(2).level > 0 then
		damage =
			common.CalculateMagicDamage(target, (ELevelDamage[player:spellSlot(2).level] + (common.GetTotalAP() * .5)), player)
	end
	return damage
end
local RLevelDamage = {180, 265, 350}
function RDamage(target)
	local damage = 0
	if player:spellSlot(3).level > 0 then
		damage =
			common.CalculateMagicDamage(target, (RLevelDamage[player:spellSlot(3).level] + (common.GetTotalAP() * .7)), player)
	end
	return damage
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
local function Combo()
	local target = GetTargetE()
	if target and target.isVisible then
		if common.IsValidTarget(target) then
			if menu.combo.combomode:get() == 1 then
				if menu.combo.wcombo:get() and (player:spellSlot(0).state == 0 or player:spellSlot(2).state == 0) then
					if target.pos:dist(player.pos) < spellW.range then
						local pos = preds.circular.get_prediction(spellW, target)
						if pos and pos.startPos:dist(pos.endPos) < spellW.range then
							player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
				if menu.combo.qcombo:get() then
					if target.pos:dist(player.pos) < spellQ.range and player:spellSlot(0).state == 0 then
						local pos = preds.linear.get_prediction(spellQ, target)
						if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
							if target.pos:dist(player.pos) < spellW.range and menu.combo.wcombo:get() then
								local pos2 = preds.circular.get_prediction(spellW, target)
								if pos2 and pos2.startPos:dist(pos2.endPos) < spellW.range then
									player:castSpell("pos", 1, vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y))
								end
							end
							player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
				if menu.combo.rcombo:get() then
					if target.pos:dist(player.pos) < spellR.range then
						if menu.combo.rmode:get() == 1 then
							if (#count_enemies_in_range(target.pos, 500) >= menu.combo.hitr:get()) then
								local pos = preds.circular.get_prediction(spellR, target)
								if pos and pos.startPos:dist(pos.endPos) < spellR.range then
									player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
						if menu.combo.rmode:get() == 2 then
							if target.health <= (QDamage(target) + RDamage(target) + EDamage(target)) then
								local pos = preds.circular.get_prediction(spellR, target)
								if pos and pos.startPos:dist(pos.endPos) < spellR.range then
									player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					end
				end
				if menu.combo.ecombo:get() then
					if target.pos:dist(player.pos) < spellE.range and player:spellSlot(2).state == 0 then
						local pos = preds.linear.get_prediction(spellE, target)
						if pos and pos.startPos:dist(pos.endPos) < spellE.range then
							if target.pos:dist(player.pos) < spellW.range and menu.combo.wcombo:get() then
								local pos2 = preds.circular.get_prediction(spellW, target)
								if pos2 and pos2.startPos:dist(pos2.endPos) < spellW.range then
									player:castSpell("pos", 1, vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y))
								end
							end
							player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
			end
			if menu.combo.combomode:get() == 2 then
				if menu.combo.wcombo:get() and (player:spellSlot(0).state == 0 or player:spellSlot(2).state == 0) then
					if target.pos:dist(player.pos) < spellW.range then
						local pos = preds.circular.get_prediction(spellW, target)
						if pos and pos.startPos:dist(pos.endPos) < spellW.range then
							player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
				if menu.combo.ecombo:get() then
					if target.pos:dist(player.pos) < spellE.range then
						local pos = preds.linear.get_prediction(spellE, target)
						if pos and pos.startPos:dist(pos.endPos) < spellE.range then
							if target.pos:dist(player.pos) < spellW.range and menu.combo.wcombo:get() then
								local pos2 = preds.circular.get_prediction(spellW, target)
								if pos2 and pos2.startPos:dist(pos2.endPos) < spellW.range then
									player:castSpell("pos", 1, vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y))
								end
							end
							player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
				if menu.combo.qcombo:get() then
					if target.pos:dist(player.pos) < spellQ.range then
						local pos = preds.linear.get_prediction(spellQ, target)
						if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
							if target.pos:dist(player.pos) < spellW.range and menu.combo.wcombo:get() then
								local pos2 = preds.circular.get_prediction(spellW, target)
								if pos2 and pos2.startPos:dist(pos2.endPos) < spellW.range then
									player:castSpell("pos", 1, vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y))
								end
							end
							player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
				if menu.combo.rcombo:get() then
					if target.pos:dist(player.pos) < spellR.range then
						if menu.combo.rmode:get() == 1 then
							if (#count_enemies_in_range(target.pos, 500) >= menu.combo.hitr:get()) then
								local pos = preds.circular.get_prediction(spellR, target)
								if pos and pos.startPos:dist(pos.endPos) < spellR.range then
									player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
						if menu.combo.rmode:get() == 2 then
							if target.health <= (QDamage(target) + RDamage(target) + EDamage(target)) then
								local pos = preds.circular.get_prediction(spellR, target)
								if pos and pos.startPos:dist(pos.endPos) < spellR.range then
									player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					end
				end
			end
		end
	end
end

local function Harass()
	local target = GetTargetE()
	if target and target.isVisible then
		if common.IsValidTarget(target) then
			if menu.harass.wcombo:get() and (player:spellSlot(0).state == 0 or player:spellSlot(2).state == 0) then
				if target.pos:dist(player.pos) < spellW.range then
					local pos = preds.circular.get_prediction(spellW, target)
					if pos and pos.startPos:dist(pos.endPos) < spellW.range then
						player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
			end
			if menu.harass.qcombo:get() then
				if target.pos:dist(player.pos) < spellQ.range then
					local pos = preds.linear.get_prediction(spellQ, target)
					if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
						player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						if target.pos:dist(player.pos) < spellW.range and menu.harass.wcombo:get() then
							local pos = preds.circular.get_prediction(spellW, target)
							if pos and pos.startPos:dist(pos.endPos) < spellW.range then
								if target.pos:dist(player.pos) < spellW.range and menu.harass.wcombo:get() then
									local pos2 = preds.circular.get_prediction(spellW, target)
									if pos2 and pos2.startPos:dist(pos2.endPos) < spellW.range then
										player:castSpell("pos", 1, vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y))
									end
								end
								player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
						end
					end
				end
			end
			if menu.harass.ecombo:get() then
				if target.pos:dist(player.pos) < spellE.range then
					local pos = preds.linear.get_prediction(spellE, target)
					if pos and pos.startPos:dist(pos.endPos) < spellE.range then
						player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						if target.pos:dist(player.pos) < spellW.range and menu.harass.wcombo:get() then
							local pos = preds.circular.get_prediction(spellW, target)
							if pos and pos.startPos:dist(pos.endPos) < spellW.range then
								if target.pos:dist(player.pos) < spellW.range and menu.harass.wcombo:get() then
									local pos2 = preds.circular.get_prediction(spellW, target)
									if pos2 and pos2.startPos:dist(pos2.endPos) < spellW.range then
										player:castSpell("pos", 1, vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y))
									end
								end
								player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
							end
						end
					end
				end
			end
		end
	end
end

local function LaneClear()
	if uhh == true then
		if (player.mana / player.maxMana) * 100 >= menu.laneclear.push.mana:get() then
			if menu.laneclear.push.useq:get() then
				for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
					local minion = objManager.minions[TEAM_ENEMY][i]
					if
						minion and minion.moveSpeed > 0 and minion.isTargetable and minion.pos:dist(player.pos) <= spellQ.range and
							minion.path.count == 0 and
							not minion.isDead and
							common.IsValidTarget(minion)
					 then
						local minionPos = vec3(minion.x, minion.y, minion.z)
						if minionPos then
							if #count_minions_in_range(minionPos, 200) >= menu.laneclear.push.hitq:get() then
								local seg = preds.circular.get_prediction(spellQ, minion)
								if seg and seg.startPos:dist(seg.endPos) < spellQ.range then
									if menu.laneclear.push.usew:get() then
										local pos2 = preds.circular.get_prediction(spellW, minion)
										if pos2 and pos2.startPos:dist(pos2.endPos) < spellW.range and player:spellSlot(1).state == 0 then
											player:castSpell("pos", 1, vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y))
										end
									end
									player:castSpell("pos", 0, vec3(seg.endPos.x, minionPos.y, seg.endPos.y))
								end
							end
						end
					end
				end
			end
		end
	end
end
local function JungleClear()
	if (player.mana / player.maxMana) * 100 >= menu.laneclear.jungle.mana:get() then
		if menu.laneclear.jungle.useq:get() then
			for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
				local minion = objManager.minions[TEAM_NEUTRAL][i]
				if
					minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
						minion.pos:dist(player.pos) < spellQ.range
				 then
					local minionPos = vec3(minion.x, minion.y, minion.z)
					if minionPos:dist(player.pos) <= spellQ.range then
						local pos = preds.linear.get_prediction(spellQ, minion)
						if pos and pos.startPos:dist(pos.endPos) < spellQ.range and player:spellSlot(0).state == 0 then
							if menu.laneclear.jungle.usew:get() then
								local pos2 = preds.circular.get_prediction(spellW, minion)
								if pos2 and pos2.startPos:dist(pos2.endPos) < spellW.range and player:spellSlot(1).state == 0 then
									player:castSpell("pos", 1, vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y))
								end
							end
							player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
			end
		end
		if menu.laneclear.jungle.usee:get() then
			for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
				local minion = objManager.minions[TEAM_NEUTRAL][i]
				if
					minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
						minion.pos:dist(player.pos) < spellE.range
				 then
					local minionPos = vec3(minion.x, minion.y, minion.z)
					if minionPos:dist(player.pos) <= spellE.range then
						local pos = preds.linear.get_prediction(spellE, minion)
						if pos and pos.startPos:dist(pos.endPos) < spellE.range and player:spellSlot(2).state == 0 then
							if menu.laneclear.jungle.usew:get() then
								local pos2 = preds.circular.get_prediction(spellW, minion)
								if pos2 and pos2.startPos:dist(pos2.endPos) < spellW.range and player:spellSlot(1).state == 0 then
									player:castSpell("pos", 1, vec3(pos2.endPos.x, mousePos.y, pos2.endPos.y))
								end
							end
							player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						end
					end
				end
			end
		end
	end
end
local function SemiR()
	local target = GetTargetR()
	if target and target.isVisible then
		if common.IsValidTarget(target) then
			local pos = preds.circular.get_prediction(spellR, target)
			if pos and pos.startPos:dist(pos.endPos) < spellR.range then
				player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
			end
		end
	end
end

local function OnTick()
	if menu.misc.GapA:get() then
		local seg = {}
		local target =
			TS.get_result(
			function(res, obj, dist)
				if dist <= spellE.range and obj.path.isActive and obj.path.isDashing then --add invulnverabilty check
					res.obj = obj
					return true
				end
			end
		).obj
		if target then
			local pred_pos = preds.core.lerp(target.path, network.latency + spellE.delay, target.path.dashSpeed)
			if pred_pos and pred_pos:dist(player.path.serverPos2D) <= spellE.range then
				seg.startPos = player.path.serverPos2D
				seg.endPos = vec2(pred_pos.x, pred_pos.y)

				if menu.misc.blacklist[target.charName] and not menu.misc.blacklist[target.charName]:get() then
					player:castSpell("pos", 2, vec3(pred_pos.x, target.y, pred_pos.y))
				end
			end
		end
	end
	if menu.combo.semir:get() then
		SemiR()
	end
	Toggle()
	if menu.keys.combokey:get() then
		Combo()
	end
	if menu.keys.harasskey:get() then
		Harass()
	end
	if menu.keys.clearkey:get() then
		JungleClear()
		LaneClear()
	end
end

function DrawDamagesE(target)
	if target.isVisible and not target.isDead then
		local pos = graphics.world_to_screen(target.pos)
		if (math.floor((QDamage(target) + RDamage(target) + EDamage(target)) / target.health * 100) < 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 255, 153, 51))

			graphics.draw_text_2D(
				tostring(math.floor(QDamage(target) + RDamage(target) + EDamage(target))) ..
					" (" ..
						tostring(math.floor((QDamage(target) + RDamage(target) + EDamage(target)) / target.health * 100)) ..
							"%)" .. "Not Killable",
				20,
				pos.x + 55,
				pos.y - 80,
				graphics.argb(255, 255, 153, 51)
			)
		end
		if (math.floor((QDamage(target) + RDamage(target) + EDamage(target)) / target.health * 100) >= 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_text_2D(
				tostring(math.floor(QDamage(target) + RDamage(target) + EDamage(target))) ..
					" (" ..
						tostring(math.floor((QDamage(target) + RDamage(target) + EDamage(target)) / target.health * 100)) ..
							"%)" .. "Kilable",
				20,
				pos.x + 55,
				pos.y - 80,
				graphics.argb(255, 150, 255, 200)
			)
		end
	end
end
local function OnDraw()
	if menu.draws.drawseeds:get() then
		for _, objs in pairs(objSomething) do
			if objs and not objs.isDead then
				if objs.isOnScreen then
					graphics.draw_circle(objs.pos, 60, 2, graphics.argb(255, 255, 204, 204), 10)
				end
			end
		end
	end
	if player.isOnScreen then
		if menu.draws.drawe:get() then
			graphics.draw_circle(player.pos, spellE.range, 2, menu.draws.colore:get(), 100)
		end
		if menu.draws.drawq:get() then
			graphics.draw_circle(player.pos, spellQ.range, 2, menu.draws.colorq:get(), 100)
		end
		if menu.draws.draww:get() then
			graphics.draw_circle(player.pos, spellW.range, 2, menu.draws.colorw:get(), 100)
		end
		if menu.draws.drawr:get() then
			graphics.draw_circle(player.pos, spellR.range, 2, menu.draws.colorr:get(), 100)
		end
		if menu.draws.drawtoggle:get() then
			local pos = graphics.world_to_screen(vec3(player.x, player.y, player.z))
			if uhh == true then
				graphics.draw_text_2D("Farm: ", 17, pos.x - 20, pos.y + 10, graphics.argb(255, 255, 255, 255))
				graphics.draw_text_2D("ON", 17, pos.x + 23, pos.y + 10, graphics.argb(255, 51, 255, 51))
			else
				graphics.draw_text_2D("Farm: ", 17, pos.x - 20, pos.y + 10, graphics.argb(255, 255, 255, 255))
				graphics.draw_text_2D("OFF", 17, pos.x + 23, pos.y + 10, graphics.argb(255, 255, 0, 0))
			end
		end
	end
	if menu.draws.drawdamage:get() then
		local enemy = common.GetEnemyHeroes()
		for i, enemies in ipairs(enemy) do
			if
				enemies and common.IsValidTarget(enemies) and player.pos:dist(enemies) < 1000 and
					not common.CheckBuffType(enemies, 17)
			 then
			
				DrawDamagesE(enemies)
			end
		end
	--graphics.draw_circle(player.pos, spellQ.range + 380, 2, menu.draws.colorfq:get(), 100)
	end
end
TS.load_to_menu(menu)
--cb.add(cb.spell, SpellCasting)

cb.add(cb.tick, OnTick)
cb.add(cb.create_particle, CreateObj)
cb.add(cb.delete_particle, DeleteObj)

cb.add(cb.draw, OnDraw)
