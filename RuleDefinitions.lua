local bubble_hearth_vars = {
	spell_id = 8690,
	bubble_name = "Divine Shield",
	light_of_elune_name = "Light of Elune",
}

HCU_rule_ids = {
	[1] = "No Auction House",
	[2] = "No Mailbox",
	[3] = "No Bubble Hearth",
	[4] = "Solo",
	[5] = "Max Group Size: 2",
	[6] = "Max Group Size: 3",
	[7] = "No Trading",
	[8] = "Guild Only Trading",
	[9] = "No Petri Hearth",
	[10] = "Guild Only Grouping",
}

HCU_rule_name_to_id = {}
local num_rules = 0
for k, v in pairs(HCU_rule_ids) do
	HCU_rule_name_to_id[v] = k
	num_rules = num_rules + 1
end

function HCU_encodeRules(rule_id_tbl)
	local code = ""
	counter = 0
	local str = {}
	for i = 1, num_rules do
		counter = counter + 1
		if rule_id_tbl[i] then
			str[#str + 1] = 1
		else
			str[#str + 1] = 0
		end
		if counter >= 32 then
			local val = tonumber(table.concat(str), 2)
			code = code .. decimalToAscii85(val)
			str = {}
			counter = 0
		end
	end

	for i = 1, 32 - #str do
		str[#str + 1] = 0
	end

	local val = tonumber(table.concat(str), 2)
	code = code .. decimalToAscii85(val)
	return code
end

function HCU_decodeRules(code)
	if code == nil or tostring(code) == nil then
		return
	end
	local rule_list = {}
	local bin = ascii85ToBinary(code)
	for i = 1, #bin do
		if bin:sub(i, i) == "1" and HCU_rule_ids[i] then
			table.insert(rule_list, i)
		end
	end
	return rule_list
end

function HCU_applyFromCode(hcu_character, code)
	if code == nil then
		return
	end
	local rule_list = HCU_decodeRules(code)
	hcu_character.rules = {}
	for _, v in ipairs(rule_list) do
		hcu_character.rules[v] = 1
	end
end
-- local achievement_list = decodeAchievements(achievement_str, _G.id_a)
-- local passive_achievement_list = decodeAchievements(passive_achievements_str, _G.id_pa)
-- return time_tracked, first_recorded, achievement_list, passive_achievement_list
-- end

function HCU_disableRules(hcu_character)
	for _, rule in pairs(HCU_rules) do
		rule.disable()
	end
end

function HCU_enableRules(hcu_character)
	if hcu_character.rules then
		if hcu_character.rules then
			for rule_id, _ in pairs(hcu_character.rules) do
				HCU_rules[rule_id].enable()
			end
		end
	end
end

HCU_rules = {}

local name = nil

local rule_event_handler = nil
rule_event_handler = CreateFrame("frame")
rule_event_handler.event_functions = {}
rule_event_handler:SetScript("OnEvent", function(self, event, ...)
	if rule_event_handler.event_functions and rule_event_handler.event_functions[event] then
		for k, v in pairs(rule_event_handler.event_functions[event]) do
			v(...)
		end
	end
end)

local function registerFunction(event, rule_id, func)
	rule_event_handler:RegisterEvent(event)
	if rule_event_handler.event_functions[event] == nil then
		rule_event_handler.event_functions[event] = {}
	end
	rule_event_handler.event_functions[event][HCU_rule_name_to_id[name]] = func
end

local function unregisterFunction(event, rule_id)
	if rule_event_handler.event_functions[event] == nil then
		rule_event_handler.event_functions[event] = {}
	end
	if rule_event_handler.event_functions[event][HCU_rule_name_to_id[name]] then
		rule_event_handler.event_functions[event][HCU_rule_name_to_id[name]] = nil
	end
end

---- Rule definitions
HCU_rules[HCU_rule_name_to_id["No Auction House"]] = {
	["name"] = "No Auction House",
	["icon"] = "ICONS\\INV_Misc_Coin_01",
	["description"] = "Disables the auction house.",
	["enable"] = function()
		registerFunction("AUCTION_HOUSE_SHOW", HCU_rule_name_to_id["No Auction House"], function()
			Hardcore:Print("Auction house is blocked by `No Auction House` rule.")
			CloseAuctionHouse()
		end)
	end,
	["disable"] = function()
		unregisterFunction("AUCTION_HOUSE_SHOW", HCU_rule_name_to_id["No Auction House"])
	end,
}

HCU_rules[HCU_rule_name_to_id["No Mailbox"]] = {
	["name"] = "No Mailbox",
	["icon"] = "ICONS\\INV_Letter_17",
	["description"] = "Disables the mailbox.",
	["enable"] = function()
		registerFunction("MAIL_SHOW", HCU_rule_name_to_id["No Mailbox"], function()
			Hardcore:Print("Mail is blocked by `No Mailbox` rule.")
			CloseMail()
		end)
	end,
	["disable"] = function()
		unregisterFunction("MAIL_SHOW", HCU_rule_name_to_id["No Mailbox"])
	end,
}

HCU_rules[HCU_rule_name_to_id["No Bubble Hearth"]] = {
	["name"] = "No Bubble Hearth",
	["icon"] = "ICONS\\Spell_Holy_DivineIntervention",
	["description"] = "Cancels bubble aura when casting hearthstone.",
	["enable"] = function()
		registerFunction("UNIT_SPELLCAST_START", HCU_rule_name_to_id["No Bubble Hearth"], function(...)
			local unit, _, spell_id, _, _ = ...
			if unit == "player" and spell_id == bubble_hearth_vars.spell_id then
				for i = 1, 40 do
					local name, _, _, _, _, _, _, _, _, _, _ = UnitBuff("player", i)
					if name == nil then
						return
					elseif name == bubble_hearth_vars.bubble_name or name == bubble_hearth_vars.light_of_elune_name then
						Hardcore:Print("WARNING: Bubble-hearth Detected\nCancel Hearthing Immediately.")
						Hardcore:ShowAlertFrame(
							ALERT_STYLES.hc_red,
							"Bubble-hearth Detected\nCancel Hearthing Immediately."
						)
						return
					end
				end
			end
		end)
	end,
	["disable"] = function()
		unregisterFunction("UNIT_SPELLCAST_START", HCU_rule_name_to_id["No Bubble Hearth"])
	end,
}

HCU_rules[HCU_rule_name_to_id["Solo"]] = {
	["name"] = "Solo",
	["icon"] = "ICONS\\Spell_Holy_DivineSpirit",
	["description"] = "Max group size.",
	["enable"] = function() end,
	["disable"] = function() end,
}

HCU_rules[HCU_rule_name_to_id["Max Group Size: 2"]] = {
	["name"] = "Max Group Size: 2",
	["icon"] = "ICONS\\Spell_Nature_MassTeleport",
	["description"] = "Max group size.",
	["enable"] = function() end,
	["disable"] = function() end,
}

HCU_rules[HCU_rule_name_to_id["Max Group Size: 3"]] = {
	["name"] = "Max Group Size: 3",
	["icon"] = "ICONS\\Spell_Holy_PrayerofSpirit",
	["description"] = "Max group size.",
	["enable"] = function() end,
	["disable"] = function() end,
}

HCU_rules[HCU_rule_name_to_id["No Trading"]] = {
	["name"] = "No Trading",
	["icon"] = "ICONS\\INV_Scroll_03.PNG",
	["enabled"] = false,
	["loaded"] = false,
	["description"] = "Disallows trading.",
	["enable"] = function()
		HCU_rules[HCU_rule_name_to_id["No Trading"]].enabled = true
		if HCU_rules[HCU_rule_name_to_id["No Trading"]].loaded == false then
			hooksecurefunc("TradeFrame_OnShow", function(self, button)
				if HCU_rules[HCU_rule_name_to_id["No Trading"]].enabled then
					_G["TradeFrame"]:Hide()
				end
			end)
		end
		HCU_rules[HCU_rule_name_to_id["No Trading"]].loaded = true
	end,
	["disable"] = function(self)
		HCU_rules[HCU_rule_name_to_id["No Trading"]].enabled = false
	end,
}

HCU_rules[HCU_rule_name_to_id["Guild Only Trading"]] = {
	["name"] = "Guild Only Trading",
	["icon"] = "ICONS\\INV_Misc_Gift_01.PNG",
	["enabled"] = false,
	["loaded"] = false,
	["description"] = "Disallows trading outside of the guild.",
	["enable"] = function()
		HCU_rules[HCU_rule_name_to_id["Guild Only Trading"]].enabled = true
		if HCU_rules[HCU_rule_name_to_id["Guild Only Trading"]].loaded == false then
			hooksecurefunc("TradeFrame_OnShow", function(self, button)
				C_Timer.After(0.1, function()
					local recv_name = _G["TradeFrameRecipientNameText"]:GetText()
					local in_guild = false
					for i = 1, GetNumGuildMembers() do
						local name, _, _, _, _, _, _, _, _, _, _ = GetGuildRosterInfo(i)
						local player_name_short = string.split("-", name)
						if player_name_short == recv_name then
							in_guild = true
							break
						end
					end
					if HCU_rules[HCU_rule_name_to_id["Guild Only Trading"]].enabled and in_guild == false then
						print("Target trade recepient not in guild. " .. recv_name)
						_G["TradeFrame"]:Hide()
					end
				end)
			end)
		end
		HCU_rules[HCU_rule_name_to_id["Guild Only Trading"]].loaded = true
	end,
	["disable"] = function(self)
		HCU_rules[HCU_rule_name_to_id["Guild Only Trading"]].enabled = false
	end,
}

HCU_rules[HCU_rule_name_to_id["No Petri Hearth"]] = {
	["name"] = "No Petri Hearth",
	["icon"] = "ICONS\\INV_Potion_26.PNG",
	["enabled"] = false,
	["loaded"] = false,
	["description"] = "Cancels petrification aura if in instance without a party or raid.",
	["enable"] = function()
		registerFunction("UNIT_AURA", HCU_rule_name_to_id["No Petri Hearth"], function()
			local is_in_instance, _ = IsInInstance()
			if is_in_instance == nil or is_in_instance == False then
				return
			end
			local is_in_group = IsInGroup()
			if is_in_group == nil or is_in_group == True then
				return
			end

			if arg[1] == "player" then
				for i = 1, 40 do
					local buff_name, _, _, _, _, _, _, _, _, _, _ = UnitBuff("player", i)
					if buff_name == nil then
						return
					end
					if buff_name == "Petrification" then
						CancelUnitBuff("player", i)
						Hardcore:Print("Removing petrification buff " .. buff_name .. ".")
					end
				end
			end
		end)
	end,
	["disable"] = function(self)
		unregisterFunction("UNIT_AURA", HCU_rule_name_to_id["No Petri Hearth"])
	end,
}

-- Guild Only Grouping
HCU_rules[HCU_rule_name_to_id["Guild Only Grouping"]] = {
	["name"] = "Guild Only Grouping",
	["icon"] = "ICONS\\INV_Shirt_GuildTabard_01.PNG",
	["enabled"] = false,
	["loaded"] = false,
	["description"] = "Disallows grouping outside of the guild.",
	["enable"] = function()
		local _name = "Guild Only Grouping"
		HCU_rules[10].enabled = true
		if HCU_rules[10].loaded == false then
			C_Timer.NewTicker(2, function(self)
				if IsInGroup() then
					local identifiers = {
						"party1",
						"party2",
						"party3",
						"party4",
					}
					local my_guild_name, _, _ = GetGuildInfo("player")

					for _, id in ipairs(identifiers) do
						local other_guild_name, _, _ = GetGuildInfo(id)
						if my_guild_name ~= other_guild_name then
							print("HCU - Leaving group. Detected party member not in guild.")
							LeaveParty()
						end
					end
				end
			end)
		end
		HCU_rules[HCU_rule_name_to_id["Guild Only Grouping"]].loaded = true
	end,
	["disable"] = function(self)
		HCU_rules[HCU_rule_name_to_id["Guild Only Grouping"]].enabled = false
	end,
}
