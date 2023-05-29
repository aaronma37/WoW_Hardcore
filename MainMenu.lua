local _menu_width = 900
local _inner_menu_width = 800
local _menu_height = 600
local AceGUI = LibStub("AceGUI-3.0")
hardcore_modern_menu = nil
hardcore_modern_menu_state = {}
hardcore_modern_menu_state.guild_online = {}
hardcore_modern_menu_state.guild_versions = {}
hardcore_modern_menu_state.guild_versions_status = {}
hardcore_modern_menu_state.online_pulsing = {}
hardcore_modern_menu_state.levels_sort_state = "date"
hardcore_modern_menu_state.accountability_sort_state = "v"
hardcore_modern_menu_state.levels_page = 1
hardcore_modern_menu_state.total_levels = 1
hardcore_modern_menu_state.levels_max_page = 1
hardcore_modern_menu_state.changeset = {}
hardcore_modern_menu_state.entry_tbl = {}

local function RequestHCData(target_name)
	if
		other_hardcore_character_cache[target_name] == nil
		or time() - other_hardcore_character_cache[target_name].last_received > 30
	then
		Hardcore:RequestCharacterData(target_name)
	end
end

local date_to_num = {
	["Jan"] = 1,
	["Feb"] = 2,
	["Mar"] = 3,
	["Apr"] = 4,
	["May"] = 5,
	["Jun"] = 6,
	["Jul"] = 7,
	["Aug"] = 8,
	["Sep"] = 9,
	["Oct"] = 10,
	["Nov"] = 11,
	["Dec"] = 12,
}
local function convertToStamp(date_str)
	local pattern = "(%d+) (%d+):(%d+):(%d+) (%d+)"
	local pattern2 = " (%a+)"
	local runday, runhour, runminute, runseconds, runyear = date_str:match(pattern)
	local runmonth = date_str:match(pattern2)
	return time({
		year = runyear,
		month = date_to_num[runmonth],
		day = runday,
		hour = runhour,
		min = runminute,
		sec = runseconds,
	})
end

local sort_functions = {
	["Alph"] = function(t, a, b)
		return a < b
	end,
	["rAlph"] = function(t, a, b)
		return b < a
	end,
	["lvl"] = function(t, a, b)
		return t[a]["level"] > t[b]["level"]
	end,
	["rlvl"] = function(t, a, b)
		return t[b]["level"] > t[a]["level"]
	end,
	["v"] = function(t, a, b)
		return (hardcore_modern_menu_state.guild_versions[a] or "0")
			< (hardcore_modern_menu_state.guild_versions[b] or "0")
	end,
	["rv"] = function(t, a, b)
		return (hardcore_modern_menu_state.guild_versions[a] or "0")
			> (hardcore_modern_menu_state.guild_versions[b] or "0")
	end,
	["date"] = function(t, a, b)
		local t1 = convertToStamp(t[a]["localtime"])
		local t2 = convertToStamp(t[b]["localtime"])
		return t1 > t2
	end,
	["rdate"] = function(t, a, b)
		local t1 = convertToStamp(t[a]["localtime"])
		local t2 = convertToStamp(t[b]["localtime"])
		return t1 < t2
	end,
	["simpledate"] = function(t, a, b)
		local player_name_short = string.split("-", a)
		local t1 = ""
		if other_hardcore_character_cache[player_name_short] == nil then
			t1 = ""
		else
			t1 = other_hardcore_character_cache[player_name_short].first_recorded or ""
		end

		local t2 = ""
		player_name_short = string.split("-", b)
		if other_hardcore_character_cache[player_name_short] == nil then
			t2 = ""
		else
			t2 = other_hardcore_character_cache[player_name_short].first_recorded or ""
		end
		return t1 > t2
	end,
	["rsimpledate"] = function(t, a, b)
		local player_name_short = string.split("-", a)
		local t1 = ""
		if other_hardcore_character_cache[player_name_short] == nil then
			t1 = ""
		else
			t1 = other_hardcore_character_cache[player_name_short].first_recorded or ""
		end

		local t2 = ""
		player_name_short = string.split("-", b)
		if other_hardcore_character_cache[player_name_short] == nil then
			t2 = ""
		else
			t2 = other_hardcore_character_cache[player_name_short].first_recorded or ""
		end
		return t1 < t2
	end,
	["pt"] = function(t, a, b)
		return t[b]["playedtime"] > t[a]["playedtime"]
	end,
	["rpt"] = function(t, a, b)
		return t[b]["playedtime"] < t[a]["playedtime"]
	end,
	["achievements"] = function(t, a, b)
		local player_name_short = string.split("-", a)
		local t1 = 0
		if other_hardcore_character_cache[player_name_short] == nil then
			t1 = 0
		else
			t1 = #other_hardcore_character_cache[player_name_short].achievements or 0
		end

		local t2 = 0
		player_name_short = string.split("-", b)
		if other_hardcore_character_cache[player_name_short] == nil then
			t2 = 0
		else
			t2 = #other_hardcore_character_cache[player_name_short].achievements or 0
		end
		return t1 > t2
	end,
	["rachievements"] = function(t, a, b)
		local player_name_short = string.split("-", a)
		local t1 = 0
		if other_hardcore_character_cache[player_name_short] == nil then
			t1 = 0
		else
			t1 = #other_hardcore_character_cache[player_name_short].achievements or 0
		end

		local t2 = 0
		player_name_short = string.split("-", b)
		if other_hardcore_character_cache[player_name_short] == nil then
			t2 = 0
		else
			t2 = #other_hardcore_character_cache[player_name_short].achievements or 0
		end
		return t1 < t2
	end,
	["mode"] = function(t, a, b)
		local player_name_short = string.split("-", a)
		local t1 = "None"
		if other_hardcore_character_cache[player_name_short] == nil then
			t1 = "None"
		else
			t1 = other_hardcore_character_cache[player_name_short].party_mode or "None"
		end

		local t2 = "None"
		player_name_short = string.split("-", b)
		if other_hardcore_character_cache[player_name_short] == nil then
			t2 = "None"
		else
			t2 = other_hardcore_character_cache[player_name_short].party_mode or "None"
		end
		return t1 > t2
	end,
	["rmode"] = function(t, a, b)
		local player_name_short = string.split("-", a)
		local t1 = "None"
		if other_hardcore_character_cache[player_name_short] == nil then
			t1 = "None"
		else
			t1 = other_hardcore_character_cache[player_name_short].party_mode or "None"
		end

		local t2 = "None"
		player_name_short = string.split("-", b)
		if other_hardcore_character_cache[player_name_short] == nil then
			t2 = "None"
		else
			t2 = other_hardcore_character_cache[player_name_short].party_mode or "None"
		end
		return t1 < t2
	end,
	["hctag"] = function(t, a, b)
		local player_name_short = string.split("-", a)
		local t1 = "None"
		if other_hardcore_character_cache[player_name_short] == nil then
			t1 = "None"
		else
			t1 = other_hardcore_character_cache[player_name_short].hardcore_player_name or "None"
		end

		local t2 = "None"
		player_name_short = string.split("-", b)
		if other_hardcore_character_cache[player_name_short] == nil then
			t2 = "None"
		else
			t2 = other_hardcore_character_cache[player_name_short].hardcore_player_name or "None"
		end
		return t1 > t2
	end,
	["rhctag"] = function(t, a, b)
		local player_name_short = string.split("-", a)
		local t1 = "None"
		if other_hardcore_character_cache[player_name_short] == nil then
			t1 = "None"
		else
			t1 = other_hardcore_character_cache[player_name_short].hardcore_player_name or "None"
		end

		local t2 = "None"
		player_name_short = string.split("-", b)
		if other_hardcore_character_cache[player_name_short] == nil then
			t2 = "None"
		else
			t2 = other_hardcore_character_cache[player_name_short].hardcore_player_name or "None"
		end
		return t1 < t2
	end,
}

-- sort function from stack overflow
local function spairs(t, order)
	local keys = {}
	for k in pairs(t) do
		keys[#keys + 1] = k
	end

	if order then
		table.sort(keys, function(a, b)
			return order(t, a, b)
		end)
	else
		table.sort(keys)
	end

	local i = 0
	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end
local function CreateHeadingLabel(title, frame)
	local label = AceGUI:Create("Label")
	label:SetWidth(500)
	label:SetText(title)
	label:SetFont("Fonts\\FRIZQT__.TTF", 16, "")
	frame:AddChild(label)
end
local function CreateDescriptionLabel(text, frame)
	local label = AceGUI:Create("Label")
	label:SetWidth(900)
	label:SetText(text)
	label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
	frame:AddChild(label)
end

local function DrawGeneralTab(container)
	local scroll_container = AceGUI:Create("SimpleGroup")
	scroll_container:SetFullWidth(true)
	scroll_container:SetFullHeight(true)
	scroll_container:SetLayout("Fill")
	tabcontainer:AddChild(scroll_container)

	local scroll_frame = AceGUI:Create("ScrollFrame")
	scroll_frame:SetLayout("Flow")
	scroll_container:AddChild(scroll_frame)

	local first_menu_description_title = AceGUI:Create("Label")
	first_menu_description_title:SetWidth(500)
	first_menu_description_title:SetText("Welcome to Classic hardcore!")
	first_menu_description_title:SetFont("Interface\\Addons\\HardcoreUnlocked\\Media\\BreatheFire.ttf", 20, "")
	-- first_menu_description_title:SetPoint("TOP", 2,5)
	scroll_frame:AddChild(first_menu_description_title)
end

local function DrawRulesTab(container) end

local function DrawLevelsTab(container, _hardcore_settings)
	local function DrawNameColumn(_scroll_frame, _level_list, _player_list, width, start, max_lines)
		local entry = AceGUI:Create("SimpleGroup")
		entry:SetLayout("List")
		entry:SetWidth(width)
		_scroll_frame:AddChild(entry)

		local name_str = ""
		for i = start, start + max_lines do
			if _player_list[i] == nil then
				break
			end
			name_str = name_str .. _level_list[_player_list[i]].player .. "\n"
		end

		local name_label = AceGUI:Create("Label")
		name_label:SetWidth(width)
		name_label:SetText(name_str)
		name_label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
		entry:AddChild(name_label)
	end

	local function DrawLevelColumn(_scroll_frame, _level_list, _player_list, width, start, max_lines)
		local entry = AceGUI:Create("SimpleGroup")
		entry:SetLayout("Flow")
		entry:SetWidth(width)
		_scroll_frame:AddChild(entry)

		local name_str = ""
		for i = start, start + max_lines do
			if _player_list[i] == nil then
				break
			end
			name_str = name_str .. _level_list[_player_list[i]].level .. "\n"
		end

		local name_label = AceGUI:Create("Label")
		name_label:SetWidth(width)
		name_label:SetText(name_str)
		name_label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
		entry:AddChild(name_label)
	end

	local function DrawPlayedColumn(_scroll_frame, _level_list, _player_list, width, start, max_lines)
		local entry = AceGUI:Create("SimpleGroup")
		entry:SetLayout("Flow")
		entry:SetWidth(width)
		_scroll_frame:AddChild(entry)

		local name_str = ""
		for i = start, start + max_lines do
			if _player_list[i] == nil then
				break
			end
			if _level_list[_player_list[i]].playedtime ~= nil then
				name_str = name_str .. SecondsToTime(_level_list[_player_list[i]].playedtime) .. "\n"
			else
				name_str = name_str .. "\n"
			end
		end

		local name_label = AceGUI:Create("Label")
		name_label:SetWidth(width)
		name_label:SetText(name_str)
		name_label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
		entry:AddChild(name_label)
	end

	local function DrawDateColumn(_scroll_frame, _level_list, _player_list, width, start, max_lines)
		local entry = AceGUI:Create("SimpleGroup")
		entry:SetLayout("Flow")
		entry:SetWidth(width)
		_scroll_frame:AddChild(entry)

		local name_str = ""
		for i = start, start + max_lines do
			if _player_list[i] == nil then
				break
			end
			name_str = name_str .. _level_list[_player_list[i]].localtime .. "\n"
		end

		local name_label = AceGUI:Create("Label")
		name_label:SetWidth(width)
		name_label:SetText(name_str)
		name_label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
		entry:AddChild(name_label)
	end

	local scroll_container = AceGUI:Create("SimpleGroup")
	scroll_container:SetFullWidth(true)
	scroll_container:SetFullHeight(true)
	scroll_container:SetLayout("List")
	tabcontainer:AddChild(scroll_container)

	local scroll_frame = AceGUI:Create("ScrollFrame")
	scroll_frame:SetLayout("Flow")
	scroll_frame:SetHeight(490)
	scroll_container:AddChild(scroll_frame)

	local row_header = AceGUI:Create("SimpleGroup")
	row_header:SetLayout("Flow")
	row_header:SetFullWidth(true)
	scroll_frame:AddChild(row_header)

	local name_label = AceGUI:Create("InteractiveLabel")
	name_label:SetWidth(150)
	name_label:SetText("|c00FFFF00Name|r")
	name_label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
	row_header:AddChild(name_label)

	name_label:SetCallback("OnClick", function(widget)
		container:ReleaseChildren()
		if hardcore_modern_menu_state.levels_sort_state ~= "Alph" then
			hardcore_modern_menu_state.levels_sort_state = "Alph"
		else
			hardcore_modern_menu_state.levels_sort_state = "rAlph"
		end
		DrawLevelsTab(container, _hardcore_settings)
	end)

	local level_label = AceGUI:Create("InteractiveLabel")
	level_label:SetWidth(50)
	level_label:SetText("|c00FFFF00Lvl|r")
	level_label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
	row_header:AddChild(level_label)

	level_label:SetCallback("OnClick", function(widget)
		container:ReleaseChildren()
		if hardcore_modern_menu_state.levels_sort_state ~= "lvl" then
			hardcore_modern_menu_state.levels_sort_state = "lvl"
		else
			hardcore_modern_menu_state.levels_sort_state = "rlvl"
		end
		DrawLevelsTab(container, _hardcore_settings)
	end)

	local played_time_label = AceGUI:Create("InteractiveLabel")
	played_time_label:SetWidth(200)
	played_time_label:SetText("|c00FFFF00Played Time|r")
	played_time_label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
	row_header:AddChild(played_time_label)

	played_time_label:SetCallback("OnClick", function(widget)
		container:ReleaseChildren()
		if hardcore_modern_menu_state.levels_sort_state ~= "pt" then
			hardcore_modern_menu_state.levels_sort_state = "pt"
		else
			hardcore_modern_menu_state.levels_sort_state = "rpt"
		end
		DrawLevelsTab(container, _hardcore_settings)
	end)

	local date_label = AceGUI:Create("InteractiveLabel")
	date_label:SetWidth(200)
	date_label:SetText("|c00FFFF00Date|r")
	date_label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
	row_header:AddChild(date_label)

	date_label:SetCallback("OnClick", function(widget)
		container:ReleaseChildren()
		if hardcore_modern_menu_state.levels_sort_state ~= "date" then
			hardcore_modern_menu_state.levels_sort_state = "date"
		else
			hardcore_modern_menu_state.levels_sort_state = "rdate"
		end
		DrawLevelsTab(container, _hardcore_settings)
	end)

	local sorted_player_idx = {}
	local max_lines = 500
	hardcore_modern_menu.total_levels = #_hardcore_settings.level_list
	hardcore_modern_menu.max_pages = hardcore_modern_menu.total_levels / max_lines
	for i, v in spairs(_hardcore_settings.level_list, sort_functions[hardcore_modern_menu_state.levels_sort_state]) do
		table.insert(sorted_player_idx, i)
	end

	local start = (hardcore_modern_menu_state.levels_page - 1) * max_lines + 1
	DrawNameColumn(scroll_frame, HardcoreUnlocked_Settings.level_list, sorted_player_idx, 150, start, max_lines)
	DrawLevelColumn(scroll_frame, HardcoreUnlocked_Settings.level_list, sorted_player_idx, 50, start, max_lines)
	DrawPlayedColumn(scroll_frame, HardcoreUnlocked_Settings.level_list, sorted_player_idx, 200, start, max_lines)
	DrawDateColumn(scroll_frame, HardcoreUnlocked_Settings.level_list, sorted_player_idx, 200, start, max_lines)

	local entry = AceGUI:Create("SimpleGroup")
	entry:SetLayout("Flow")
	entry:SetWidth(10)
	scroll_frame:AddChild(entry)

	local button_container = AceGUI:Create("SimpleGroup")
	button_container:SetWidth(_inner_menu_width)
	button_container:SetHeight(100)
	button_container:SetLayout("Flow")
	scroll_container:AddChild(button_container)

	local left_page_button = AceGUI:Create("Button")
	left_page_button:SetText("<")
	left_page_button:SetWidth(50)
	button_container:AddChild(left_page_button)
	left_page_button:SetCallback("OnClick", function()
		if hardcore_modern_menu_state.levels_page > 1 then
			container:ReleaseChildren()
			hardcore_modern_menu_state.levels_page = hardcore_modern_menu_state.levels_page - 1
			DrawLevelsTab(container, _hardcore_settings)
		end
	end)

	local date_label = AceGUI:Create("Label")
	date_label:SetWidth(100)
	date_label:SetText("|c00FFFF00Page " .. hardcore_modern_menu_state.levels_page .. "|r")
	date_label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
	button_container:AddChild(date_label)

	local date_label = AceGUI:Create("HardcoreClassTitleLabel")
	date_label:SetWidth(490)
	date_label:SetText("|c00FFFF00You've Leveled up " .. #_hardcore_settings.level_list .. " Times!|r")
	date_label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
	button_container:AddChild(date_label)

	local date_label = AceGUI:Create("HardcoreClassTitleLabel")
	date_label:SetWidth(100)
	date_label:SetText("")
	date_label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
	button_container:AddChild(date_label)

	local right_page_button = AceGUI:Create("Button")
	right_page_button:SetText(">")
	right_page_button:SetWidth(50)
	button_container:AddChild(right_page_button)
	right_page_button:SetCallback("OnClick", function()
		if hardcore_modern_menu_state.levels_page <= hardcore_modern_menu_state.levels_max_page + 1 then
			container:ReleaseChildren()
			hardcore_modern_menu_state.levels_page = hardcore_modern_menu_state.levels_page + 1
			DrawLevelsTab(container, _hardcore_settings)
		end
	end)
end

local function GetSpacelessRealmName()
	local name = GetRealmName()
	return string.gsub(name, "%s+", "")
end

local function DrawAccountabilityTab(container)
	local function updateLabelData(_label_tbls, player_name_short)
		if other_hardcore_character_cache[player_name_short] ~= nil then
			_label_tbls["party_mode_label"]:SetText(other_hardcore_character_cache[player_name_short].party_mode)
			_label_tbls["first_recorded_label"]:SetText(
				date("%m/%d/%y", other_hardcore_character_cache[player_name_short].first_recorded or 0)
			)

			if
				other_hardcore_character_cache[player_name_short].achievements == nil
				or #other_hardcore_character_cache[player_name_short].achievements > 0
				or #other_hardcore_character_cache[player_name_short].passive_achievements > 0
			then
				local inline_text = ""
				for i, achievement_name in ipairs(other_hardcore_character_cache[player_name_short].achievements) do
					if _G.achievements[achievement_name] then
						inline_text = inline_text
							.. "|T"
							.. _G.achievements[achievement_name].icon_path
							.. ":16:16:0:0:64:64:4:60:4:60|t"
					end
				end
				for i, achievement_name in
					ipairs(other_hardcore_character_cache[player_name_short].passive_achievements)
				do
					if _G.passive_achievements[achievement_name] then
						inline_text = inline_text
							.. "|T"
							.. _G.passive_achievements[achievement_name].icon_path
							.. ":16:16:0:0:64:64:4:60:4:60|t"
					end
				end
				_label_tbls["achievement_label"]:SetText(inline_text)
				_label_tbls["achievement_label"]:SetCallback("OnEnter", function(widget)
					GameTooltip:SetOwner(WorldFrame, "ANCHOR_CURSOR")
					GameTooltip:AddLine("achievements")
					for i, achievement_name in ipairs(other_hardcore_character_cache[player_name_short].achievements) do
						if _G.achievements[achievement_name] then
							GameTooltip:AddLine(_G.achievements[achievement_name].title)
						end
					end
					for i, achievement_name in
						ipairs(other_hardcore_character_cache[player_name_short].passive_achievements)
					do
						if _G.passive_achievements[achievement_name] then
							GameTooltip:AddLine(_G.passive_achievements[achievement_name].title)
						end
					end
					GameTooltip:Show()
				end)
				_label_tbls["achievement_label"]:SetCallback("OnLeave", function(widget)
					GameTooltip:Hide()
				end)
			else
				_label_tbls["achievement_label"]:SetText("")
			end
			_label_tbls["hc_tag_label"]:SetText(
				other_hardcore_character_cache[player_name_short].hardcore_player_name or ""
			)
		end

		local player_name_long = player_name_short .. "-" .. GetSpacelessRealmName()
		if hardcore_modern_menu_state.guild_online[player_name_long] ~= nil then
			local version_text
			if
				(
					hardcore_modern_menu_state.online_pulsing[player_name_long]
					and hardcore_modern_menu_state.guild_online[player_name_long]
				) or player_name_short == UnitName("player")
			then
				if player_name_short == UnitName("player") then
					version_text = GetAddOnMetadata("HardcoreUnlocked", "Version")
				else
					version_text = hardcore_modern_menu_state.guild_versions[player_name_long]
				end

				if hardcore_modern_menu_state.guild_versions_status[player_name_long] == "updated" then
					version_text = "|c0000ff00" .. version_text .. "|r"
				else
					version_text = "|c00ffff00" .. version_text .. "|r"
				end
			else
				version_text = "|c00ff0000Not detected|r"
			end
			_label_tbls["version_label"]:SetText(version_text)

			_label_tbls["level_label"]:SetText(hardcore_modern_menu_state.guild_online[player_name_long].level)
		end
	end
	local function addEntry(_scroll_frame, player_name_short, _self_name)
		--local _player_name = player_name_short .. "-" .. GetSpacelessRealmName()
		local entry = AceGUI:Create("SimpleGroup")
		entry:SetLayout("Flow")
		entry:SetFullWidth(true)
		_scroll_frame:AddChild(entry)

		local name_label = AceGUI:Create("Label")
		name_label:SetWidth(110)
		name_label:SetText(player_name_short)
		name_label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
		entry:AddChild(name_label)
		hardcore_modern_menu_state.entry_tbl[player_name_short] = {}

		local level_label = AceGUI:Create("Label")
		level_label:SetWidth(50)
		level_label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
		entry:AddChild(level_label)
		hardcore_modern_menu_state.entry_tbl[player_name_short]["level_label"] = level_label

		local version_label = AceGUI:Create("Label")
		version_label:SetWidth(80)
		version_label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
		entry:AddChild(version_label)
		hardcore_modern_menu_state.entry_tbl[player_name_short]["version_label"] = version_label

		local party_mode_label = AceGUI:Create("Label")
		party_mode_label:SetWidth(75)
		party_mode_label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
		entry:AddChild(party_mode_label)
		hardcore_modern_menu_state.entry_tbl[player_name_short]["party_mode_label"] = party_mode_label

		local first_recorded_label = AceGUI:Create("Label")
		first_recorded_label:SetWidth(85)
		first_recorded_label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
		entry:AddChild(first_recorded_label)
		hardcore_modern_menu_state.entry_tbl[player_name_short]["first_recorded_label"] = first_recorded_label

		local achievement_label = AceGUI:Create("InteractiveLabel")
		achievement_label:SetWidth(320)
		achievement_label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
		entry:AddChild(achievement_label)
		hardcore_modern_menu_state.entry_tbl[player_name_short]["achievement_label"] = achievement_label

		local hc_tag_label = AceGUI:Create("Label")
		hc_tag_label:SetWidth(75)
		hc_tag_label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
		entry:AddChild(hc_tag_label)
		hardcore_modern_menu_state.entry_tbl[player_name_short]["hc_tag_label"] = hc_tag_label

		updateLabelData(hardcore_modern_menu_state.entry_tbl[player_name_short], player_name_short) -- , _player_name)
	end

	local scroll_container = AceGUI:Create("SimpleGroup")
	scroll_container:SetFullWidth(true)
	scroll_container:SetFullHeight(true)
	scroll_container:SetLayout("List")
	tabcontainer:AddChild(scroll_container)

	local scroll_frame = AceGUI:Create("ScrollFrame")
	scroll_frame:SetLayout("List")
	scroll_container:AddChild(scroll_frame)

	local row_header = AceGUI:Create("SimpleGroup")
	row_header:SetLayout("Flow")
	row_header:SetFullWidth(true)
	scroll_frame:AddChild(row_header)

	local name_label = AceGUI:Create("InteractiveLabel")
	name_label:SetWidth(110)
	name_label:SetText("|c00FFFF00Name|r")
	name_label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
	row_header:AddChild(name_label)

	name_label:SetCallback("OnClick", function(widget)
		hardcore_modern_menu_state.entry_tbl = {}
		hardcore_modern_menu_state.ticker_handler:Cancel()
		hardcore_modern_menu_state.ticker_handler = nil
		container:ReleaseChildren()
		if hardcore_modern_menu_state.accountability_sort_state ~= "Alph" then
			hardcore_modern_menu_state.accountability_sort_state = "Alph"
		else
			hardcore_modern_menu_state.accountability_sort_state = "rAlph"
		end
		DrawAccountabilityTab(container)
	end)

	local level_label = AceGUI:Create("InteractiveLabel")
	level_label:SetWidth(50)
	level_label:SetText("|c00FFFF00Lvl|r")
	level_label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
	row_header:AddChild(level_label)

	level_label:SetCallback("OnClick", function(widget)
		hardcore_modern_menu_state.entry_tbl = {}
		hardcore_modern_menu_state.ticker_handler:Cancel()
		hardcore_modern_menu_state.ticker_handler = nil
		container:ReleaseChildren()
		if hardcore_modern_menu_state.accountability_sort_state ~= "lvl" then
			hardcore_modern_menu_state.accountability_sort_state = "lvl"
		else
			hardcore_modern_menu_state.accountability_sort_state = "rlvl"
		end
		DrawAccountabilityTab(container)
	end)

	local version_label = AceGUI:Create("InteractiveLabel")
	version_label:SetWidth(80)
	version_label:SetText("|c00FFFF00Version|r")
	version_label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
	row_header:AddChild(version_label)

	version_label:SetCallback("OnClick", function(widget)
		hardcore_modern_menu_state.entry_tbl = {}
		hardcore_modern_menu_state.ticker_handler:Cancel()
		hardcore_modern_menu_state.ticker_handler = nil
		container:ReleaseChildren()
		if hardcore_modern_menu_state.accountability_sort_state ~= "v" then
			hardcore_modern_menu_state.accountability_sort_state = "v"
		else
			hardcore_modern_menu_state.accountability_sort_state = "rv"
		end
		DrawAccountabilityTab(container)
	end)

	local mode_label = AceGUI:Create("InteractiveLabel")
	mode_label:SetWidth(75)
	mode_label:SetText("|c00FFFF00Mode|r")
	mode_label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
	row_header:AddChild(mode_label)

	mode_label:SetCallback("OnClick", function(widget)
		hardcore_modern_menu_state.entry_tbl = {}
		hardcore_modern_menu_state.ticker_handler:Cancel()
		hardcore_modern_menu_state.ticker_handler = nil
		container:ReleaseChildren()
		if hardcore_modern_menu_state.accountability_sort_state ~= "mode" then
			hardcore_modern_menu_state.accountability_sort_state = "mode"
		else
			hardcore_modern_menu_state.accountability_sort_state = "rmode"
		end
		DrawAccountabilityTab(container)
	end)

	local date_started_label = AceGUI:Create("InteractiveLabel")
	date_started_label:SetWidth(85)
	date_started_label:SetText("|c00FFFF00Started|r")
	date_started_label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
	row_header:AddChild(date_started_label)

	date_started_label:SetCallback("OnClick", function(widget)
		hardcore_modern_menu_state.entry_tbl = {}
		hardcore_modern_menu_state.ticker_handler:Cancel()
		hardcore_modern_menu_state.ticker_handler = nil
		container:ReleaseChildren()
		if hardcore_modern_menu_state.accountability_sort_state ~= "simpledate" then
			hardcore_modern_menu_state.accountability_sort_state = "simpledate"
		else
			hardcore_modern_menu_state.accountability_sort_state = "rsimpledate"
		end
		DrawAccountabilityTab(container)
	end)

	local achievements_label = AceGUI:Create("InteractiveLabel")
	achievements_label:SetWidth(320)
	achievements_label:SetText("|c00FFFF00Achievements|r")
	achievements_label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
	row_header:AddChild(achievements_label)

	achievements_label:SetCallback("OnClick", function(widget)
		hardcore_modern_menu_state.entry_tbl = {}
		hardcore_modern_menu_state.ticker_handler:Cancel()
		hardcore_modern_menu_state.ticker_handler = nil
		container:ReleaseChildren()
		if hardcore_modern_menu_state.accountability_sort_state ~= "achievements" then
			hardcore_modern_menu_state.accountability_sort_state = "achievements"
		else
			hardcore_modern_menu_state.accountability_sort_state = "rachievements"
		end
		DrawAccountabilityTab(container)
	end)

	local hc_tag_label = AceGUI:Create("InteractiveLabel")
	hc_tag_label:SetWidth(100)
	hc_tag_label:SetText("|c00FFFF00HC Tag|r")
	hc_tag_label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
	row_header:AddChild(hc_tag_label)

	hc_tag_label:SetCallback("OnClick", function(widget)
		hardcore_modern_menu_state.entry_tbl = {}
		hardcore_modern_menu_state.ticker_handler:Cancel()
		hardcore_modern_menu_state.ticker_handler = nil
		container:ReleaseChildren()
		if hardcore_modern_menu_state.accountability_sort_state ~= "hctag" then
			hardcore_modern_menu_state.accountability_sort_state = "hctag"
		else
			hardcore_modern_menu_state.accountability_sort_state = "rhctag"
		end
		DrawAccountabilityTab(container)
	end)

	self_name = UnitName("player")
	for _player_name, _ in
		spairs(
			hardcore_modern_menu_state.guild_online,
			sort_functions[hardcore_modern_menu_state.accountability_sort_state]
		)
	do
		local player_name_short = string.split("-", _player_name)
		addEntry(scroll_frame, player_name_short, self_name)
	end

	hardcore_modern_menu_state.ticker_handler = C_Timer.NewTicker(0.1, function()
		for k, _ in pairs(hardcore_modern_menu_state.changeset) do
			if hardcore_modern_menu_state.entry_tbl[k] == nil then
				-- addEntry(scroll_frame, k, self_name)
				-- No-op, this can look buggy
			else
				updateLabelData(hardcore_modern_menu_state.entry_tbl[k], k)
			end
		end
		hardcore_modern_menu_state.changeset = {}
	end)

	local button_container = AceGUI:Create("SimpleGroup")
	button_container:SetWidth(100)
	button_container:SetHeight(100)
	button_container:SetLayout("Flow")
	scroll_container:AddChild(button_container)

	local inspect_all_button = AceGUI:Create("Button")
	inspect_all_button:SetText("Inspect All")
	inspect_all_button:SetWidth(100)
	button_container:AddChild(inspect_all_button)
	inspect_all_button:SetCallback("OnClick", function()
		for _player_name, _ in
			spairs(
				hardcore_modern_menu_state.guild_online,
				sort_functions[hardcore_modern_menu_state.accountability_sort_state]
			)
		do
			local player_name_short = string.split("-", _player_name)
			if other_hardcore_character_cache[player_name_short] == nil then
				RequestHCData(player_name_short)
			end
		end
	end)
end

local function DrawAchievementsTab(container)
	local function addEntry(_scroll_frame, _player_name, _self_name) end

	local scroll_container = AceGUI:Create("SimpleGroup")
	scroll_container:SetFullWidth(true)
	scroll_container:SetFullHeight(true)
	scroll_container:SetLayout("List")
	tabcontainer:AddChild(scroll_container)

	local achievements_container = AceGUI:Create("SimpleGroup")
	achievements_container:SetRelativeWidth(1.0)
	achievements_container:SetHeight(50)
	achievements_container:SetLayout("CenteredFlow")
	scroll_container:AddChild(achievements_container)

	local achievements_container_second_row = AceGUI:Create("SimpleGroup")
	achievements_container_second_row:SetRelativeWidth(1.0)
	achievements_container_second_row:SetHeight(50)
	achievements_container_second_row:SetLayout("CenteredFlow")
	scroll_container:AddChild(achievements_container_second_row)
	local function DrawClassContainer(class_container, class, size)
		local c = 0
		for k, v in pairs(_G.achievements) do
			if v.class == class then
				c = c + 1
				local achievement_icon = AceGUI:Create("Icon")
				achievement_icon:SetWidth(size)
				achievement_icon:SetHeight(size)
				achievement_icon:SetImage(v.icon_path)
				achievement_icon:SetImageSize(size, size)
				achievement_icon.image:SetVertexColor(1, 1, 1)
				SetAchievementTooltip(achievement_icon, achievement, _player_name)
				class_container:AddChild(achievement_icon)
			end
		end

		local achievement_icon = AceGUI:Create("Icon")
		achievement_icon:SetWidth(1)
		achievement_icon:SetHeight(10)
		class_container:AddChild(achievement_icon)
	end

	local achievements_title = AceGUI:Create("HardcoreClassTitleLabel")
	achievements_title:SetRelativeWidth(1.0)
	achievements_title:SetHeight(40)
	achievements_title:SetText("General Achievements")
	achievements_title:SetFont("Interface\\Addons\\HardcoreUnlocked\\Media\\BreatheFire.ttf", 16, "")
	achievements_container:AddChild(achievements_title)
	DrawClassContainer(achievements_container, "All", 50)

	local function DrawClassContainer2(container, class, size)
		local class_contianer = AceGUI:Create("SimpleGroup")
		class_contianer:SetWidth(120)
		class_contianer:SetHeight(50)
		class_contianer:SetLayout("Flow")
		container:AddChild(class_contianer)

		local achievements_title = AceGUI:Create("HardcoreClassTitleLabel")
		achievements_title:SetRelativeWidth(1.0)
		achievements_title:SetHeight(40)
		achievements_title:SetText(class)
		achievements_title:SetFont("Interface\\Addons\\HardcoreUnlocked\\Media\\BreatheFire.ttf", 16, "")
		class_contianer:AddChild(achievements_title)
		DrawClassContainer(class_contianer, class, size)
	end

	local achievements_container = AceGUI:Create("SimpleGroup")
	achievements_container:SetRelativeWidth(1.0)
	achievements_container:SetHeight(200)
	achievements_container:SetLayout("CenteredFlow")
	scroll_container:AddChild(achievements_container)
	local achievements_title = AceGUI:Create("HardcoreClassTitleLabel")
	achievements_title:SetRelativeWidth(1.0)
	achievements_title:SetHeight(40)
	achievements_title:SetText("\n\n\n\n")
	achievements_title:SetFont("Interface\\Addons\\HardcoreUnlocked\\Media\\BreatheFire.ttf", 16, "")
	scroll_container:AddChild(achievements_title)

	local achievements_container = AceGUI:Create("SimpleGroup")
	achievements_container:SetRelativeWidth(1.0)
	achievements_container:SetHeight(50)
	achievements_container:SetLayout("CenteredFlow")
	scroll_container:AddChild(achievements_container)
	DrawClassContainer2(achievements_container, "Warrior", 36)
	DrawClassContainer2(achievements_container, "Hunter", 36)
	DrawClassContainer2(achievements_container, "Warlock", 36)
	DrawClassContainer2(achievements_container, "Mage", 36)
	DrawClassContainer2(achievements_container, "Druid", 36)
	DrawClassContainer2(achievements_container, "Paladin", 36)
	DrawClassContainer2(achievements_container, "Priest", 36)
	DrawClassContainer2(achievements_container, "Shaman", 36)
	DrawClassContainer2(achievements_container, "Rogue", 36)
end

local function DrawPassiveAchievementsTab(container)
	local function DrawClassContainer(class_container, class, size)
		local c = 0
		for k, v in pairs(_G.passive_achievements) do
			if v.class == class then
				c = c + 1
				local achievement_icon = AceGUI:Create("Icon")
				achievement_icon:SetWidth(size)
				achievement_icon:SetHeight(size)
				achievement_icon:SetImage(v.icon_path)
				achievement_icon:SetImageSize(size, size)
				achievement_icon.image:SetVertexColor(1, 1, 1)
				achievement_icon:SetCallback("OnEnter", function(widget)
					GameTooltip:SetOwner(WorldFrame, "ANCHOR_CURSOR")
					GameTooltip:AddLine(v.title)
					GameTooltip:AddLine(v.description, 1, 1, 1, true)
					GameTooltip:Show()
				end)
				achievement_icon:SetCallback("OnLeave", function(widget)
					GameTooltip:Hide()
				end)
				class_container:AddChild(achievement_icon)
			end
		end

		local achievement_icon = AceGUI:Create("Icon")
		achievement_icon:SetWidth(1)
		achievement_icon:SetHeight(10)
		class_container:AddChild(achievement_icon)
	end

	local function addEntry(_scroll_frame, _player_name, _self_name) end

	local scroll_container = AceGUI:Create("SimpleGroup")
	scroll_container:SetFullWidth(true)
	scroll_container:SetFullHeight(true)
	scroll_container:SetLayout("List")
	tabcontainer:AddChild(scroll_container)

	local achievements_container = AceGUI:Create("SimpleGroup")
	achievements_container:SetRelativeWidth(1.0)
	achievements_container:SetHeight(50)
	achievements_container:SetLayout("CenteredFlow")
	scroll_container:AddChild(achievements_container)

	local achievements_container_second_row = AceGUI:Create("SimpleGroup")
	achievements_container_second_row:SetRelativeWidth(1.0)
	achievements_container_second_row:SetHeight(50)
	achievements_container_second_row:SetLayout("CenteredFlow")
	scroll_container:AddChild(achievements_container_second_row)

	local achievements_title = AceGUI:Create("HardcoreClassTitleLabel")
	achievements_title:SetRelativeWidth(1.0)
	achievements_title:SetHeight(40)
	achievements_title:SetText("Passive Achievements")
	achievements_title:SetFont("Interface\\Addons\\HardcoreUnlocked\\Media\\BreatheFire.ttf", 16, "")
	achievements_container:AddChild(achievements_title)
	DrawClassContainer(achievements_container, "All", 50)

	local achievements_container = AceGUI:Create("SimpleGroup")
	achievements_container:SetRelativeWidth(1.0)
	achievements_container:SetHeight(200)
	achievements_container:SetLayout("CenteredFlow")
	scroll_container:AddChild(achievements_container)

	local achievements_title = AceGUI:Create("HardcoreClassTitleLabel")
	achievements_title:SetRelativeWidth(1.0)
	achievements_title:SetHeight(40)
	achievements_title:SetText("Alliance Only Achievements")
	achievements_title:SetFont("Interface\\Addons\\HardcoreUnlocked\\Media\\BreatheFire.ttf", 16, "")
	scroll_container:AddChild(achievements_title)

	local achievements_title = AceGUI:Create("HardcoreClassTitleLabel")
	achievements_title:SetRelativeWidth(1.0)
	achievements_title:SetHeight(40)
	achievements_title:SetText("Horde Only Achievements")
	achievements_title:SetFont("Interface\\Addons\\HardcoreUnlocked\\Media\\BreatheFire.ttf", 16, "")
	scroll_container:AddChild(achievements_title)
end

local function DrawOfficerToolsTab(container)
	local scroll_container = AceGUI:Create("SimpleGroup")
	scroll_container:SetFullWidth(true)
	scroll_container:SetFullHeight(true)
	scroll_container:SetLayout("List")
	tabcontainer:AddChild(scroll_container)

	local scroll_frame = AceGUI:Create("ScrollFrame")
	scroll_frame:SetLayout("List")
	scroll_container:AddChild(scroll_frame)

	local officer_announcement_container = AceGUI:Create("SimpleGroup")
	officer_announcement_container:SetFullWidth(true)
	officer_announcement_container:SetLayout("List")
	-- officer_announcement_container:SetTitle("Officer Announcements")
	scroll_frame:AddChild(officer_announcement_container)

	local announcement_edit_text = AceGUI:Create("EditBox")
	announcement_edit_text:SetWidth(800)
	-- announcement_edit_text:SetHeight(120)
	announcement_edit_text:SetDisabled(false)
	announcement_edit_text:SetLabel("Send Announcement")
	announcement_edit_text:SetPoint("TOP", 2, 5)
	announcement_edit_text:DisableButton(false)

	announcement_edit_text:SetCallback("OnEnterPressed", function()
		local text = announcement_edit_text:GetText()
		gw.config.channel.guild:send(GW_MTYPE_HC_ANNOUNCEMENT, text)
	end)

	officer_announcement_container:AddChild(announcement_edit_text)

	local green_wall_config_container = AceGUI:Create("InlineGroup")
	green_wall_config_container:SetFullWidth(true)
	green_wall_config_container:SetLayout("Flow")
	green_wall_config_container:SetTitle("Current Greenwall Configuration")
	scroll_frame:AddChild(green_wall_config_container)

	local current_gw_config_text = AceGUI:Create("Label")
	current_gw_config_text:SetWidth(850)

	local peer_guild_text = "    Peer Guilds:\n        "

	for k, v in pairs(gw.config.peer) do
		peer_guild_text = peer_guild_text .. "|c0000FFFF" .. k .. "|r "
	end

	peer_guild_text = peer_guild_text .. "\n\n    Custom Options:\n"

	if hc_self_block_flag and hc_self_block_flag == true then
		peer_guild_text = peer_guild_text
			.. "        |c00FFFF00Defense Mode|r  - Players from this guild will not emit death alerts\n"
	end

	if hc_gw_lfgm_mode and hc_gw_lfgm_mode == true then
		peer_guild_text = peer_guild_text
			.. "        |c00FFFF00LF Mode|r  - Only `looking for` +/- 10 levels, death alerts, and hc notifications will be communicated across guilds\n"
	end

	if hc_mute_inguild and tonumber(hc_mute_inguild) > 0 then
		peer_guild_text = peer_guild_text
			.. "        |c00FFFF00Mute low level|r  - Players in this guild under level "
			.. tonumber(hc_mute_inguild)
			.. " will be muted\n"
	end

	peer_guild_text = peer_guild_text .. "\n\n    Banned Tags:\n        "
	if gw_banned_tags then
		for k, v in pairs(gw_banned_tags) do
			peer_guild_text = peer_guild_text .. k .. " "
		end
	end

	peer_guild_text = peer_guild_text .. "\n\n"

	current_gw_config_text:SetText(peer_guild_text)

	current_gw_config_text:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
	green_wall_config_container:AddChild(current_gw_config_text)

	local officer_notes_guide_container = AceGUI:Create("InlineGroup")
	officer_notes_guide_container:SetFullWidth(true)
	officer_notes_guide_container:SetHeight(1000)
	officer_notes_guide_container:SetLayout("Flow")
	officer_notes_guide_container:SetTitle("Officer Notes Guide")
	scroll_frame:AddChild(officer_notes_guide_container)

	local officer_notes_guide_text = AceGUI:Create("Label")
	officer_notes_guide_text:SetWidth(850)
	officer_notes_guide_text:SetText(
		"The followiong commands are used in officer notes to configure greenwall.\n\n |c00FFFF00GWr:|r - Puts guild into LFG/LFM mode. In LFG/LFM mode, x-guild chat will only show up for LF messages and only if the requester is within 10 levels of the receiving character. Announcements can still be made using the announcement tool below. NOTE that there must be a color `:`.\nExample usage: |c00FFFF00GWr:|r\n\n |c00FFFF00GWd:|r - Puts guild into HC defense mode. NOTE that the colon `:` is needed. If this is put into officer notes, players in this guild will not emit a death notice.\nExample usage: |c00FFFF00GWd:|r\n\n |c00FFFF00GWi:x|r - Mute guild member under x level.\nExample usage: |c00FFFF00GWi:15|r, will mute players (within the guild) under level 15\n\n |c00FFFF00GWb:x|r - Mutes messages coming from a guild with the matching tag.\nExample usage: |c00FFFF00GWb:HG|r, will mute all messages coming from HG players.\n\n |c00FFFF00GWp:<GuildName>:<GuildTag>|r - Adds a peer guild. Messages coming from other guilds will be prefixed with <GuildTag>.\nExample usage: |c00FFFF00GWp:HC Honor Guard:HG|r - Players will get messages from HC Honor Guard, which will be prefixed with <HG>.\n\n |c00FFFF00GWc:<CustomChannelName>:<ChannelPassword>|r - [REQUIRED] This determines what channel and password to use for communication.\nExample usage: |c00FFFF00GWc:HCCommonCommunicationChannel:SomeHCPassword|r - Players will communicate over the hidden HCCommonCommunicationChannel which requires SomeHCPassword password.\n\n"
	)
	officer_notes_guide_text:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
	officer_notes_guide_container:AddChild(officer_notes_guide_text)
end

local function DrawDeathStatisticsTab(container, _hardcore_settings)
	local scroll_container = AceGUI:Create("SimpleGroup")
	scroll_container:SetFullWidth(true)
	scroll_container:SetFullHeight(true)
	scroll_container:SetLayout("Fill")
	tabcontainer:AddChild(scroll_container)

	local scroll_frame = AceGUI:Create("ScrollFrame")
	scroll_frame:SetLayout("List")
	scroll_container:AddChild(scroll_frame)

	local first_menu_description_title = AceGUI:Create("Label")
	first_menu_description_title:SetWidth(500)
	first_menu_description_title:SetText("Death Statistics")
	first_menu_description_title:SetFont("Interface\\Addons\\HardcoreUnlocked\\Media\\BreatheFire.ttf", 20, "")
	-- first_menu_description_title:SetPoint("TOP", 2,5)
	scroll_frame:AddChild(first_menu_description_title)
	if _hardcore_settings["death_log_entries"] == nil then
		return
	end

	local first_menu_description = AceGUI:Create("Label")
	first_menu_description:SetWidth(_menu_width)
	first_menu_description:SetText(
		"Statistics for deaths that you have witnessed. You have witnessed "
			.. #_hardcore_settings["death_log_entries"]
			.. " deaths.\n\n\n"
	)
	first_menu_description:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
	scroll_frame:AddChild(first_menu_description)

	local death_map_button_container = AceGUI:Create("SimpleGroup")
	local death_map_button = AceGUI:Create("Button")
	death_map_button:SetText("Show deaths in my zone")
	death_map_button:SetWidth(200)

	death_map_button:SetCallback("OnClick", function()
		local WorldMapButton = WorldMapFrame:GetCanvas()
		local death_tomb_frame = CreateFrame("frame", nil, WorldMapButton)
		death_tomb_frame:SetAllPoints()
		death_tomb_frame:SetFrameLevel(15000)
		death_tomb_frame.entry_textures = {}

		for k, v in ipairs(_hardcore_settings["death_log_entries"]) do
			if v["map_id"] and v["map_pos"] then
				local death_tomb_frame_tex = death_tomb_frame:CreateTexture(nil, "OVERLAY")
				death_tomb_frame_tex:SetTexture("Interface\\TARGETINGFRAME\\UI-TargetingFrame-Skull")
				death_tomb_frame_tex:SetDrawLayer("OVERLAY", 4)
				death_tomb_frame_tex:SetHeight(25)
				death_tomb_frame_tex:SetWidth(25)
				death_tomb_frame_tex:Hide()

				death_tomb_frame_tex.map_id = v["map_id"]
				local x, y = strsplit(",", v["map_pos"], 2)
				death_tomb_frame_tex.coordinates = { x, y }
				table.insert(death_tomb_frame.entry_textures, death_tomb_frame_tex)
			end
		end
		WorldMapFrame:SetShown(not WorldMapFrame:IsShown())
		local map_id = WorldMapFrame:GetMapID()
		local mWidth, mHeight = WorldMapFrame:GetCanvas():GetSize()
		for k, v in ipairs(death_tomb_frame.entry_textures) do
			if v.map_id == map_id then
				v:SetPoint("CENTER", WorldMapButton, "TOPLEFT", mWidth * v.coordinates[1], -mHeight * v.coordinates[2])
				v:Show()
			end
		end

		WorldMapFrame:HookScript("OnHide", function()
			if death_tomb_frame == nil then
				return
			end
			if death_tomb_frame.entry_textures == nil then
				return
			end
			for k, v in ipairs(death_tomb_frame.entry_textures) do
				v:Hide()
				v = nil
			end
			death_tomb_frame = nil
		end)
	end)
	scroll_frame:AddChild(death_map_button)

	local function getDefaultStats()
		return { ["sum"] = 0, ["num"] = 0 }
	end
	local stats = {}
	stats["avg_level"] = getDefaultStats()
	stats["avg_level_class"] = {}

	local detected_classes = {}
	for i, v in pairs(_hardcore_settings["death_log_entries"]) do
		if v["level"] then
			stats["avg_level"]["sum"] = stats["avg_level"]["sum"] + v["level"]
			stats["avg_level"]["num"] = stats["avg_level"]["num"] + 1
			if v["class_id"] then
				if stats["avg_level_class"][v["class_id"]] == nil then
					stats["avg_level_class"][v["class_id"]] = getDefaultStats()
				end
				detected_classes[v["class_id"]] = 1
				stats["avg_level_class"][v["class_id"]]["sum"] = stats["avg_level_class"][v["class_id"]]["sum"]
					+ v["level"]
				stats["avg_level_class"][v["class_id"]]["num"] = stats["avg_level_class"][v["class_id"]]["num"] + 1
			end
		end
	end

	local class_stats_container = AceGUI:Create("InlineGroup")
	class_stats_container:SetLayout("List")
	scroll_frame:AddChild(class_stats_container)

	local subtitles = {
		{ "Class", 0 },
		{ "# Recorded", 90 },
		{ "%", 180 },
		{ "Avg. Death Lvl.", 275 },
	}

	local class_types = {}

	local entry_data = {}
	for k, _ in pairs(detected_classes) do
		class_types[k] = 1
		stats["avg_level_class"][k]["avg"] = stats["avg_level_class"][k]["sum"] / stats["avg_level_class"][k]["num"]
		local class_str, _, _ = GetClassInfo(k)
		entry_data[k] = {}
		entry_data[k]["Class"] = class_str
		entry_data[k]["# Recorded"] = stats["avg_level_class"][k]["num"]
		entry_data[k]["%"] = string.format(
			"%.1f",
			stats["avg_level_class"][k]["num"] / stats["avg_level"]["num"] * 100.0
		) .. "%"
		entry_data[k]["Avg. Death Lvl."] = string.format("%.1f", stats["avg_level_class"][k]["avg"])
	end

	class_types["All"] = 1
	stats["avg_level"]["avg"] = stats["avg_level"]["sum"] / stats["avg_level"]["num"]

	entry_data["All"] = {}
	entry_data["All"]["Class"] = "All"
	entry_data["All"]["# Recorded"] = stats["avg_level"]["num"]
	entry_data["All"]["%"] = "100%"
	entry_data["All"]["Avg. Death Lvl."] = string.format("%.1f", stats["avg_level"]["avg"])

	local header = AceGUI:Create("Label")
	header:SetFont("Fonts\\FRIZQT__.TTF", 16, "")
	header:SetText(" ")
	class_stats_container:SetWidth(400)
	header.font_strings = {}
	for _, v in ipairs(subtitles) do
		header.font_strings[v[1]] = header.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		header.font_strings[v[1]]:SetPoint("LEFT", header.frame, "LEFT", v[2], 0)
		header.font_strings[v[1]]:SetText(v[1])
	end
	class_stats_container:AddChild(header)

	local entries = {}
	for k, _ in pairs(class_types) do
		local entry = AceGUI:Create("Label")
		table.insert(entries, entry)
		entry:SetText(" ")
		entry.font_strings = {}
		for _, v in ipairs(subtitles) do
			entry.font_strings[v[1]] = entry.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			entry:SetFont("Fonts\\FRIZQT__.TTF", 16, "")
			entry.font_strings[v[1]]:SetPoint("LEFT", entry.frame, "LEFT", v[2], 0)
			entry.font_strings[v[1]]:SetTextColor(1, 1, 1)
			entry.font_strings[v[1]]:SetText(entry_data[k][v[1]])
		end
		class_stats_container:AddChild(entry)
	end

	scroll_frame.frame:HookScript("OnHide", function()
		death_tomb_frame = nil
		if header ~= nil then
			for k, _ in pairs(header.font_strings) do
				header.font_strings[k]:Hide()
				header.font_strings[k] = nil
			end
			header = nil
		end

		if entries ~= nil then
			for _, v in ipairs(entries) do
				for k, _ in pairs(v.font_strings) do
					v.font_strings[k]:Hide()
					v.font_strings[k] = nil
				end
				v = nil
			end
			entries = nil
		end
	end)
end

function ShowMainMenu(_hardcore_character, _hardcore_settings, dk_button_function)
	hardcore_modern_menu = AceGUI:Create("HardcoreFrameModernMenu")
	hardcore_modern_menu:SetCallback("OnClose", function(widget)
		if hardcore_modern_menu_state.ticker_handler ~= nil then
			hardcore_modern_menu_state.ticker_handler:Cancel()
			hardcore_modern_menu_state.ticker_handler = nil
		end
		hardcore_modern_menu_state.entry_tbl = {}
		AceGUI:Release(widget)
	end)
	hardcore_modern_menu:SetCallback("OnHide", function(widget)
		if hardcore_modern_menu_state.ticker_handler ~= nil then
			hardcore_modern_menu_state.ticker_handler:Cancel()
			hardcore_modern_menu_state.ticker_handler = nil
		end
		hardcore_modern_menu_state.entry_tbl = {}
		AceGUI:Release(widget)
	end)
	_G["HardcoreModernMenu"] = hardcore_modern_menu.frame -- Close on <ESC>
	tinsert(UISpecialFrames, "HardcoreModernMenu")

	hardcore_modern_menu:SetTitle("Classic Hardcore")
	hardcore_modern_menu:SetStatusText("")
	hardcore_modern_menu:SetLayout("Flow")
	hardcore_modern_menu:SetHeight(_menu_height)
	hardcore_modern_menu:SetWidth(_menu_width)

	tabcontainer = AceGUI:Create("TabGroup") -- "InlineGroup" is also good
	local tab_table = {
		{ value = "WelcomeTab", text = "General" },
		{ value = "RulesTab", text = "Rules" },
		{ value = "LevelsTab", text = "Levels" },
		{ value = "AccountabilityTab", text = "Guild Members" },
		{ value = "AchievementsTab", text = "Achievements" },
		{ value = "DeathStatisticsTab", text = "Death Statistics" },
	}
	if hc_guild_rank_index and hc_guild_rank_index < 2 then -- 0 is GM, 1 is generally officer
		table.insert(tab_table, { value = "OfficerToolsTab", text = "Officer Tools" })
	end

	tabcontainer:SetTabs(tab_table)
	tabcontainer:SetFullWidth(true)
	tabcontainer:SetFullHeight(true) -- probably?
	tabcontainer:SetLayout("Flow") -- important!

	-- Callback function for OnGroupSelected
	local function SelectGroup(container, event, group)
		container:ReleaseChildren()
		if hardcore_modern_menu_state.ticker_handler ~= nil then
			hardcore_modern_menu_state.ticker_handler:Cancel()
			hardcore_modern_menu_state.ticker_handler = nil
			hardcore_modern_menu_state.entry_tbl = {}
		end
		if group == "WelcomeTab" then
			DrawGeneralTab(container)
		elseif group == "RulesTab" then
			DrawRulesTab(container)
		elseif group == "LevelsTab" then
			DrawLevelsTab(container, _hardcore_settings)
		elseif group == "AccountabilityTab" then
			DrawAccountabilityTab(container)
		elseif group == "PartyTab" then
			local scroll_container = AceGUI:Create("SimpleGroup")
			scroll_container:SetFullWidth(true)
			scroll_container:SetFullHeight(true)
			scroll_container:SetLayout("Fill")
			tabcontainer:AddChild(scroll_container)

			local scroll_frame = AceGUI:Create("ScrollFrame")
			scroll_frame:SetLayout("Flow")
			scroll_container:AddChild(scroll_frame)
		elseif group == "AchievementsTab" then
			achievement_tab_handler:DrawAchievementTab(tabcontainer, _hardcore_character, false)
		elseif group == "DeathStatisticsTab" then
			DrawDeathStatisticsTab(tabcontainer, _hardcore_settings)
		elseif group == "OfficerToolsTab" then
			DrawOfficerToolsTab(container)
		end
	end

	tabcontainer:SetCallback("OnGroupSelected", SelectGroup)
	tabcontainer:SelectTab("WelcomeTab")

	hardcore_modern_menu:AddChild(tabcontainer)
end

local guild_roster_handler = CreateFrame("Frame")
guild_roster_handler:RegisterEvent("GUILD_ROSTER_UPDATE")

-- Register Definitions
guild_roster_handler:SetScript("OnEvent", function(self, event, ...)
	local arg = { ... }
	if event == "GUILD_ROSTER_UPDATE" then
		-- Create a new dictionary of just online people every time roster is updated
		hardcore_modern_menu_state.guild_online = {}
		local numTotal, numOnline, numOnlineAndMobile = GetNumGuildMembers()
		for i = 1, numOnline, 1 do
			local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, GUID =
				GetGuildRosterInfo(i)

			-- name is nil after a gquit, so nil check here
			if name then
				hardcore_modern_menu_state.guild_online[name] = {
					name = name,
					level = level,
					classDisplayName = classDisplayName,
				}
			end
		end
	end
end)
