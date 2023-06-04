HCU_rule_ids = {
	[1] = "No Auction House",
	[2] = "No Mailbox",
	[3] = "No Bubble Hearth",
	[4] = "Max Group Size: 1",
	[5] = "Max Group Size: 2",
	[6] = "Max Group Size: 3",
	[7] = "No Trading",
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
	local rule_list = {}
	local bin = ascii85ToBinary(code)
	for i = 1, #bin do
		if bin:sub(i, i) == "1" and HCU_rule_ids[i] then
			table.insert(rule_list, i)
		end
	end
	return rule_list
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
		for _, rule_id in ipairs(hcu_character.rules) do
			HCU_rules[rule_id].enable()
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
name = "No Auction House"
HCU_rules[HCU_rule_name_to_id[name]] = {
	["name"] = name,
	["icon"] = "ICONS\\INV_Misc_Coin_01",
	["description"] = "Disables the auction house.",
	["enable"] = function()
		registerFunction("AUCTION_HOUSE_SHOW", HCU_rule_name_to_id[name], function()
			Hardcore:Print("Auction house is blocked by `No Auction House` rule.")
			CloseAuctionHouse()
		end)
	end,
	["disable"] = function()
		unregisterFunction("AUCTION_HOUSE_SHOW", HCU_rule_name_to_id[name])
	end,
}

name = "No Mailbox"
HCU_rules[HCU_rule_name_to_id[name]] = {
	["name"] = name,
	["icon"] = "ICONS\\INV_Letter_17",
	["description"] = "Disables the mailbox.",
	["enable"] = function()
		registerFunction("MAIL_SHOW", HCU_rule_name_to_id[name], function()
			Hardcore:Print("Mail is blocked by `No Mailbox` rule.")
			CloseMail()
		end)
	end,
	["disable"] = function()
		unregisterFunction("MAIL_SHOW", HCU_rule_name_to_id[name])
	end,
}

name = "No Bubble Hearth"
HCU_rules[HCU_rule_name_to_id[name]] = {
	["name"] = name,
	["icon"] = "ICONS\\Spell_Holy_DivineIntervention",
	["description"] = "Cancels bubble aura when casting hearthstone.",
	["enable"] = function() end,
	["disable"] = function() end,
}

name = "Max Group Size: 1"
HCU_rules[HCU_rule_name_to_id[name]] = {
	["name"] = name,
	["icon"] = "ICONS\\Spell_Holy_DivineSpirit",
	["description"] = "Max group size.",
	["enable"] = function() end,
	["disable"] = function() end,
}

name = "Max Group Size: 2"
HCU_rules[HCU_rule_name_to_id[name]] = {
	["name"] = name,
	["icon"] = "ICONS\\Spell_Nature_MassTeleport",
	["description"] = "Max group size.",
	["enable"] = function() end,
	["disable"] = function() end,
}

name = "Max Group Size: 3"
HCU_rules[HCU_rule_name_to_id[name]] = {
	["name"] = name,
	["icon"] = "ICONS\\Spell_Holy_PrayerofSpirit",
	["description"] = "Max group size.",
	["enable"] = function() end,
	["disable"] = function() end,
}

name = "No Trading"
HCU_rules[HCU_rule_name_to_id[name]] = {
	["name"] = name,
	["icon"] = "ICONS\\INV_Scroll_03.PNG",
	["description"] = "Max group size.",
	["enable"] = function() end,
	["disable"] = function() end,
}
