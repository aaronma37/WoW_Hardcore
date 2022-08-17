
local AceGUI = LibStub("AceGUI-3.0")

local function errorhandler(err)
	return geterrorhandler()(err)
end

local function safecall(func, ...)
	if func then
		return xpcall(func, errorhandler, ...)
	end
end
AceGUI:RegisterLayout("ListTight",
	function(content, children)
		local height = 0
		local width = content.width or content:GetWidth() or 0
		for i = 1, #children do
			local child = children[i]

			local frame = child.frame
			frame:ClearAllPoints()
			frame:Show()
			if i == 1 then
				frame:SetPoint("TOPLEFT", content,0,20)
			else
				frame:SetPoint("TOPLEFT", children[i-1].frame, "BOTTOMLEFT",0,23)
			end

			if child.width == "fill" then
				child:SetWidth(width)
				frame:SetPoint("RIGHT", content)

				if child.DoLayout then
					child:DoLayout()
				end
			elseif child.width == "relative" then
				child:SetWidth(width * child.relWidth)

				if child.DoLayout then
					child:DoLayout()
				end
			end

			height = height + (frame.height or frame:GetHeight() or 0)
		end
		safecall(content.obj.LayoutFinished, content.obj, nil, height)
	end)

AceGUI:RegisterLayout("FlowTight",
	function(content, children)
		if layoutrecursionblock then return end
		--used height so far
		local height = 0
		--width used in the current row
		local usedwidth = 0
		--height of the current row
		local rowheight = 0
		local rowoffset = 0

		local width = content.width or content:GetWidth() or 0

		--control at the start of the row
		local rowstart
		local rowstartoffset
		local isfullheight

		local frameoffset
		local lastframeoffset
		local oversize
		for i = 1, #children do
			local child = children[i]
			oversize = nil
			local frame = child.frame
			local frameheight = frame.height or frame:GetHeight() or 0
			local framewidth = frame.width or frame:GetWidth() or 0
			lastframeoffset = frameoffset
			-- HACK: Why did we set a frameoffset of (frameheight / 2) ?
			-- That was moving all widgets half the widgets size down, is that intended?
			-- Actually, it seems to be neccessary for many cases, we'll leave it in for now.
			-- If widgets seem to anchor weirdly with this, provide a valid alignoffset for them.
			-- TODO: Investigate moar!
			frameoffset = child.alignoffset or (frameheight / 2)

			if child.width == "relative" then
				framewidth = width * child.relWidth
			end

			frame:Show()
			frame:ClearAllPoints()
			if i == 1 then
				-- anchor the first control to the top left
				frame:SetPoint("TOPLEFT", content)
				rowheight = frameheight
				rowoffset = frameoffset
				rowstart = frame
				rowstartoffset = frameoffset
				usedwidth = framewidth
				if usedwidth > width then
					oversize = true
				end
			else
				-- if there isn't available width for the control start a new row
				-- if a control is "fill" it will be on a row of its own full width
				if usedwidth == 0 or ((framewidth) + usedwidth > width) or child.width == "fill" then
					if isfullheight then
						-- a previous row has already filled the entire height, there's nothing we can usefully do anymore
						-- (maybe error/warn about this?)
						break
					end
					--anchor the previous row, we will now know its height and offset
					rowstart:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(height + (rowoffset - rowstartoffset) + 3))
					height = height + rowheight - 10
					--save this as the rowstart so we can anchor it after the row is complete and we have the max height and offset of controls in it
					rowstart = frame
					rowstartoffset = frameoffset
					rowheight = frameheight
					rowoffset = frameoffset
					usedwidth = framewidth
					if usedwidth > width then
						oversize = true
					end
				-- put the control on the current row, adding it to the width and checking if the height needs to be increased
				else
					--handles cases where the new height is higher than either control because of the offsets
					--math.max(rowheight-rowoffset+frameoffset, frameheight-frameoffset+rowoffset)

					--offset is always the larger of the two offsets
					rowoffset = math.max(rowoffset, frameoffset)
					rowheight = math.max(rowheight, rowoffset + (frameheight / 2))

					frame:SetPoint("TOPLEFT", children[i-1].frame, "TOPRIGHT", 0, frameoffset - lastframeoffset)
					usedwidth = framewidth + usedwidth
				end
			end

			if child.width == "fill" then
				safelayoutcall(child, "SetWidth", width)
				frame:SetPoint("RIGHT", content)

				usedwidth = 0
				rowstart = frame
				rowstartoffset = frameoffset

				if child.DoLayout then
					child:DoLayout()
				end
				rowheight = frame.height or frame:GetHeight() or 0
				rowoffset = child.alignoffset or (rowheight / 2)
				rowstartoffset = rowoffset
			elseif child.width == "relative" then
				safelayoutcall(child, "SetWidth", width * child.relWidth)

				if child.DoLayout then
					child:DoLayout()
				end
			elseif oversize then
				if width > 1 then
					frame:SetPoint("RIGHT", content)
				end
			end

			if child.height == "fill" then
				frame:SetPoint("BOTTOM", content)
				isfullheight = true
			end
		end

		--anchor the last row, if its full height needs a special case since  its height has just been changed by the anchor
		if isfullheight then
			rowstart:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -height)
		elseif rowstart then
			rowstart:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(height + (rowoffset - rowstartoffset) + 3))
		end

		height = height + rowheight + 3
		safecall(content.obj.LayoutFinished, content.obj, nil, height)
	end)

local achievement_icons = {}
local CLASSES = {
	-- Classic:
	[1] = "Warrior",
	[2] = "Paladin",
	[3] = "Hunter",
	[4] = "Rogue",
	[5] = "Priest",
	[7] = "Shaman",
	[8] = "Mage",
	[9] = "Warlock",
	[11] = "Druid",
}

local function FormatStrForParty(input_str)
  local ouput_str = string.lower(input_str)
  output_str = ouput_str:gsub("^%l", string.upper)
  return output_str

end

function ShowFirstMenu(_hardcore_character, _failure_function_executor, leaderboard)
	local AceGUI = LibStub("AceGUI-3.0")
	local f = AceGUI:Create("HardcoreFrame")
	f:SetCallback("OnClose", function(widget)
		AceGUI:Release(widget)
	end)
	f:SetTitle("Classic Hardcore")
	f:SetStatusText("")
	f:SetLayout("Flow")

	-- function that draws the widgets for the second tab
	local function DrawAchievementRow(achievement, _scroll_frame)
		local btn_container = AceGUI:Create("SimpleGroup")
		btn_container:SetWidth(800)
		btn_container:SetHeight(60)
		btn_container:SetLayout("Flow")
		_scroll_frame:AddChild(btn_container)

		btn_container_frame = AceGUI:Create("SimpleGroup")
		btn_container_frame:SetLayout("Flow")

		-- Create a button
		local achievement_icon = AceGUI:Create("Icon")
		achievement_icons[achievement.name] = achievement_icon
		achievement_icon:SetWidth(60)
		achievement_icon:SetHeight(60)
		achievement_icon:SetImage(achievement.icon_path)
		achievement_icon:SetImageSize(60, 60)
		achievement_icon.image:SetVertexColor(0.2, 0.2, 0.2)
		if _hardcore_character.achievements == nil then
			_hardcore_character.achievements = {}
		end
		for i, v in ipairs(_hardcore_character.achievements) do
			if v == achievement.name then
				achievement_icon.image:SetVertexColor(1, 1, 1)
			end
		end
		achievement_icon:SetCallback("OnClick", function()
			local activate = true
			for i, v in ipairs(_hardcore_character.achievements) do
				if v == achievement.name then
					activate = false
					table.remove(_hardcore_character.achievements, i)
					achievement_icon.image:SetVertexColor(0.1, 0.1, 0.1)
					achievement:Unregister()
					Hardcore:Print("Removed " .. achievement.name .. " challenge!")
				end
			end

			if activate then
				local _, _, _class_id = UnitClass("player")
				if CLASSES[_class_id] ~= achievement.class and achievement.class ~= "All" then
					Hardcore:Print(
						"Cannot start achievement " .. achievement.title .. " as class " .. CLASSES[_class_id]
					)
				else
					table.insert(_hardcore_character.achievements, achievement.name)
					achievement_icon.image:SetVertexColor(1, 1, 1)
					achievement:Register(_failure_function_executor, _hardcore_character)
					Hardcore:Print("Added " .. achievement.name .. " challenge!")

					if achievement.forces ~= nil then
					  for i, other_a in ipairs(achievement.forces) do
					    table.insert(_hardcore_character.achievements, _G.achievements[other_a].name)
					    achievement_icons[other_a].image:SetVertexColor(1, 1, 1)
					    _G.achievements[other_a]:Register(_failure_function_executor, _hardcore_character)
					    Hardcore:Print("Added " .. _G.achievements[other_a].name .. " challenge!")
					  end
					end
				end
			end
		end)
		btn_container:AddChild(achievement_icon)

		local buffer_frame = AceGUI:Create("SimpleGroup")
		buffer_frame:SetWidth(30)
		buffer_frame:SetHeight(30)
		buffer_frame:SetLayout("Flow")
		btn_container:AddChild(buffer_frame)

		local btn_container_frame = AceGUI:Create("SimpleGroup")
		btn_container_frame:SetLayout("Flow")
		btn_container:AddChild(btn_container_frame)

		local title = AceGUI:Create("Label")
		title:SetWidth(550)
		title:SetText(achievement.title)
		title:SetPoint("TOP", 2, 5)
		title:SetFont("Interface\\Addons\\Hardcore\\Media\\BreatheFire.ttf", 20)
		btn_container_frame:AddChild(title)

		local description = AceGUI:Create("InteractiveLabel")
		description:SetWidth(520)
		description:SetFont("", 16)
		local description_text = achievement.description
		if achievement.forces ~= nil then
		  description_text = description_text .. "\n |c00FFFF00Selecting ".. achievement.title .. " forces "
		  for i=1,#achievement.forces do

		    if i == #achievement.forces and #achievement.forces > 1 then
		      description_text = description_text .. "and "
		    end
		    description_text = description_text .. _G.achievements[achievement.forces[i]].title
		    if i~= #achievement.forces then
		      description_text = description_text .. ", "
		    end
		  end
		  description_text = description_text .. ".|r"
		end
		description:SetText(description_text)
		description:SetPoint("BOTTOM", 200, 5)
		btn_container_frame:AddChild(description)
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
		first_menu_description_title:SetFont("Interface\\Addons\\Hardcore\\Media\\BreatheFire.ttf", 20)
		-- first_menu_description_title:SetPoint("TOP", 2,5)
		scroll_frame:AddChild(first_menu_description_title)

		local first_menu_description = AceGUI:Create("Label")
		first_menu_description:SetWidth(550)
		first_menu_description:SetText(
			"\n\nIf playing in a duo or trio, click the `Party` tab.\n\nTo select achievements, click on an icon in the achievement tab.\n\nAt any point during the run, open the HC tab on the character screen to check party status and achievements. \n\nThis window will not appear past level 2 and configuration cannot be changed later so make sure to fill these out correctly."
		)
		first_menu_description:SetFont("Fonts\\FRIZQT__.TTF", 12)
		-- first_menu_description:SetPoint("TOP", 2,5)
		scroll_frame:AddChild(first_menu_description)
	end

	local function DrawClassTitleRow(_scroll_frame, _title)
		local row_container = AceGUI:Create("SimpleGroup")
		row_container:SetWidth(800)
		row_container:SetHeight(60)
		row_container:SetLayout("Flow")
		_scroll_frame:AddChild(row_container)

		local title = AceGUI:Create("HardcoreClassTitleLabel")
		title:SetWidth(700)
		title:SetHeight(60)
		local CLASS_COLOR_BY_NAME = {
			["Druid"] = "FF7C0A",
			["Warlock"] = "8788EE",
			["Warrior"] = "C69B6D",
			["Mage"] = "3FC7EB",
			["Hunter"] = "AAD372",
			["Priest"] = "FFFFFF",
			["Shaman"] = "0070DD",
			["Paladin"] = "F48CBA",
			["Rogue"] = "FFF468",
			["General"] = "FFFFFF",
		}
		title:SetText("|c00" .. CLASS_COLOR_BY_NAME[_title] .. _title .. "|r Achievements")
		title:SetFont("Interface\\Addons\\Hardcore\\Media\\BreatheFire.ttf", 20)
		row_container:AddChild(title)
	end

	local function DrawPartyTab(container, _scroll_frame)
		local title = AceGUI:Create("Label")
		title:SetWidth(700)
		title:SetHeight(60)
		title:SetText("Rules for Duos and Trios\n\n")
		title:SetFont("Interface\\Addons\\Hardcore\\Media\\BreatheFire.ttf", 20)
		_scroll_frame:AddChild(title)

		local first_menu_description = AceGUI:Create("Label")
		first_menu_description:SetWidth(620)
		first_menu_description:SetText(
			"1. For new runs, all players need to start with the new Hardcore addon.\n2. You must choose a combo that spawns in the same starting location (unless you can find a way to travel to other players at level 1).\n3. You must stay in the same zone together eg Darkshore (unless you are a Druid going to Moonglade to complete essential class quests). \n4. You must be logged on together at the same time even if not questing.\n5. You are Soulbound and share one life. If one of you dies, the other/s must fall on the sword and the run is over.\n6. You can trade any solo self found items or crafted items to each other including conjurables and gold.\n\n\n\n\n"
		)
		first_menu_description:SetFont("Fonts\\FRIZQT__.TTF", 12)
		first_menu_description:SetPoint("TOP", 2, 5)
		_scroll_frame:AddChild(first_menu_description)

		local row_container = AceGUI:Create("SimpleGroup")
		row_container:SetWidth(800)
		row_container:SetHeight(60)
		row_container:SetLayout("Flow")
		_scroll_frame:AddChild(row_container)

		local first_menu_description = AceGUI:Create("Label")
		first_menu_description:SetWidth(300)
		first_menu_description:SetText("Enter your party mode and partners.\n")
		first_menu_description:SetFont("Fonts\\FRIZQT__.TTF", 12)
		first_menu_description:SetPoint("TOP", 2, 5)
		row_container:AddChild(first_menu_description)

		local dropdown = AceGUI:Create("Dropdown")
		dropdown:SetWidth(80)
		dropdown:SetLabel("Party type\n")
		dropdown:AddItem("Solo", "Solo")
		dropdown:AddItem("Duo", "Duo")
		dropdown:AddItem("Trio", "Trio")
		dropdown:SetValue(_hardcore_character.party_mode)
		dropdown:SetPoint("TOP", 2, 5)
		row_container:AddChild(dropdown)

		local tm1 = AceGUI:Create("EditBox")
		tm1:SetWidth(120)
		tm1:SetDisabled(true)
		tm1:SetLabel("Teammate 1\n")
		tm1:SetPoint("TOP", 2, 5)
		if _hardcore_character.team ~= nil then
			if _hardcore_character.team[1] ~= nil then
				tm1:SetText(_hardcore_character.team[1])
			end
		end
		tm1:SetPoint("TOP", 2, 5)
		tm1:DisableButton(true)
		row_container:AddChild(tm1)

		local tm2 = AceGUI:Create("EditBox")
		tm2:SetWidth(120)
		tm2:SetDisabled(true)
		tm2:SetLabel("Teammate 2\n")
		tm2:SetPoint("TOP", 2, 5)
		if _hardcore_character.team ~= nil then
			if _hardcore_character.team[2] ~= nil then
				tm2:SetText(_hardcore_character.team[2])
			end
		end
		tm2:DisableButton(true)
		row_container:AddChild(tm2)

		dropdown:SetCallback("OnValueChanged", function(args)
			local new_mode = dropdown:GetValue()
			tm1:SetText("")
			tm2:SetText("")
			_hardcore_character.party_mode = new_mode
			_hardcore_character.team = {}
			if new_mode == "Solo" then
				tm1:SetDisabled(true)
				tm2:SetDisabled(true)
			elseif new_mode == "Duo" then
				tm1:SetDisabled(false)
				tm2:SetDisabled(true)
			elseif new_mode == "Trio" then
				tm1:SetDisabled(false)
				tm2:SetDisabled(false)
			end
		end)
		tm1:SetCallback("OnTextChanged", function()
			_hardcore_character.team = {}
			table.insert(_hardcore_character.team, FormatStrForParty(tm1:GetText()))
			table.insert(_hardcore_character.team, FormatStrForParty(tm2:GetText()))
		end)

		tm2:SetCallback("OnTextChanged", function()
			_hardcore_character.team = {}
			table.insert(_hardcore_character.team, FormatStrForParty(tm1:GetText()))
			table.insert(_hardcore_character.team, FormatStrForParty(tm2:GetText()))
		end)
	end

	local function DrawAchievementsTab(container, _scroll_frame)
		DrawClassTitleRow(_scroll_frame, "General")
		for k, achievement in pairs(_G.achievements) do
			if achievement.class == "All" then
				DrawAchievementRow(achievement, _scroll_frame)
			end
		end

		local class_list = { "Paladin", "Priest", "Rogue", "Shaman", "Druid", "Mage", "Hunter", "Warlock", "Warrior" }

		for i, class in ipairs(class_list) do
			DrawClassTitleRow(_scroll_frame, class)
			for k, achievement in pairs(_G.achievements) do
				if achievement.class == class then
					DrawAchievementRow(achievement, _scroll_frame)
				end
			end
		end
		local bottom_buffer = AceGUI:Create("SimpleGroup")
		bottom_buffer:SetWidth(1)
		bottom_buffer:SetHeight(5)
		bottom_buffer:SetLayout("Flow")
		_scroll_frame:AddChild(bottom_buffer)
	end

	-- function that draws the widgets for the second tab
	local function DrawLeaderboardPlayerRow(player_data, _scroll_frame, rank)
		-- local btn_container = AceGUI:Create("SimpleGroup")
		local btn_container = AceGUI:Create("HardcoreLeaderboardRowInlineGroup")
		btn_container:SetWidth(600)
		btn_container:SetHeight(10)
		btn_container:SetLayout("Flow")
		btn_container:SetPoint("TOP", 0, 0)
		_scroll_frame:AddChild(btn_container)

		local title = AceGUI:Create("Label")
		title:SetWidth(35)
		title:SetText(rank)
		title:SetPoint("TOP", 0, 0)
		title:SetFont("", 14)
		btn_container:AddChild(title)

		local title = AceGUI:Create("Label")
		title:SetWidth(150)
		-- title:SetColor(1,1,0)
		title:SetText(player_data.name)
		title:SetPoint("TOP", 0, 0)
		-- title:SetFont("", 14)
		title:SetFontObject(NumberFontNormalYellow)
		title:SetColor(1,1,0)
		btn_container:AddChild(title)

		local title = AceGUI:Create("Label")
		title:SetWidth(35)
		title:SetText(player_data["number"])
		title:SetPoint("TOP", 0, 10)
		title:SetFont("", 14)
		btn_container:AddChild(title)

		local achievements_container = AceGUI:Create("SimpleGroup")
		achievements_container:SetWidth(150)
		achievements_container:SetHeight(10)
		achievements_container:SetLayout("FlowTight")
		btn_container:AddChild(achievements_container)
		local classes = {
		  ["Druid"] = "Interface\\Addons\\Hardcore\\Media\\icon_druid.blp",
		  ["Hunter"] = "Interface\\Addons\\Hardcore\\Media\\icon_hunter.blp",
		  ["Mage"] = "Interface\\Addons\\Hardcore\\Media\\icon_mage.blp",
		  ["Paladin"] = "Interface\\Addons\\Hardcore\\Media\\icon_paladin.blp",
		  ["Priest"] = "Interface\\Addons\\Hardcore\\Media\\icon_priest.blp",
		  ["Rogue"] = "Interface\\Addons\\Hardcore\\Media\\icon_rogue.blp",
		  ["Shaman"] = "Interface\\Addons\\Hardcore\\Media\\icon_shaman.blp",
		  ["Warlock"] = "Interface\\Addons\\Hardcore\\Media\\icon_warlock.blp",
		  ["Warrior"] = "Interface\\Addons\\Hardcore\\Media\\icon_warrior.blp",
		}
		-- "Death Knight" = "Interface\\Addons\\Hardcore\\Media\\icon_death_knight.blp",
		for k,v in pairs(classes) do
		  if player_data[k] ~= nil and player_data[k] ~= "" then
		    print(v)
		    for n=1,player_data[k] do
		      local achievement_icon = AceGUI:Create("Icon")
		      achievement_icon:SetWidth(20)
		      achievement_icon:SetHeight(20)
		      achievement_icon:SetImage(v)
		      achievement_icon:SetImageSize(20, 20)
		      achievement_icon.image:SetVertexColor(1,1,1)
		      achievements_container:AddChild(achievement_icon)
		    end
		  end
		end

		local classes_container = AceGUI:Create("SimpleGroup")
		classes_container:SetWidth(150)
		classes_container:SetHeight(10)
		classes_container:SetLayout("Flow")
		btn_container:AddChild(classes_container)

		for i,k in ipairs(player_data["achievements"]) do
		  if _G.achievements[k] ~= nil then
		    local achievement_icon = AceGUI:Create("Icon")
		    achievement_icon:SetWidth(25)
		    achievement_icon:SetHeight(25)
		    achievement_icon:SetImage(_G.achievements[k].icon_path)
		    achievement_icon:SetImageSize(25, 25)
		    achievement_icon.image:SetVertexColor(1,1,1)
		    classes_container:AddChild(achievement_icon)
		  end
		end




	end

	local function DrawLeaderboardTab(container, _scroll_frame)
		local num = 0
		for k, achievement in pairs(leaderboard) do
		      num = num + 1
		      DrawLeaderboardPlayerRow(achievement, _scroll_frame, num)
		end

		local bottom_buffer = AceGUI:Create("SimpleGroup")
		bottom_buffer:SetWidth(1)
		bottom_buffer:SetHeight(5)
		bottom_buffer:SetLayout("Flow")
		_scroll_frame:AddChild(bottom_buffer)
	end

	tabcontainer = AceGUI:Create("TabGroup") -- "InlineGroup" is also good
	tabcontainer:SetTabs({
		{ value = "WelcomeTab", text = "General" },
		{ value = "PartyTab", text = "Party" },
		{ value = "AchievementsTab", text = "Achievements" },
		{ value = "Player Leaderboard", text = "Player Leaderboard" },
		{ value = "Character Leaderboard", text = "Character Leaderboard" },
	}) -- ,
	tabcontainer:SetFullWidth(true)
	tabcontainer:SetFullHeight(true) -- probably?
	tabcontainer:SetLayout("Fill") -- important!

	-- Callback function for OnGroupSelected
	local function SelectGroup(container, event, group)
		container:ReleaseChildren()
		if group == "WelcomeTab" then
			DrawGeneralTab(container)
		elseif group == "PartyTab" then
			local scroll_container = AceGUI:Create("SimpleGroup")
			scroll_container:SetFullWidth(true)
			scroll_container:SetFullHeight(true)
			scroll_container:SetLayout("Fill")
			tabcontainer:AddChild(scroll_container)

			local scroll_frame = AceGUI:Create("ScrollFrame")
			scroll_frame:SetLayout("Flow")
			scroll_container:AddChild(scroll_frame)

			DrawPartyTab(container, scroll_frame)
		elseif group == "AchievementsTab" then
			local scroll_container = AceGUI:Create("SimpleGroup")
			scroll_container:SetFullWidth(true)
			scroll_container:SetFullHeight(true)
			scroll_container:SetLayout("Fill")
			tabcontainer:AddChild(scroll_container)

			local scroll_frame = AceGUI:Create("ScrollFrame")
			scroll_frame:SetLayout("Flow")
			scroll_container:AddChild(scroll_frame)
			DrawAchievementsTab(container, scroll_frame)
		elseif group == "Player Leaderboard" then
			local leaderboard_container = AceGUI:Create("SimpleGroup")
			leaderboard_container:SetFullWidth(true)
			leaderboard_container:SetHeight(600)
			leaderboard_container:SetLayout("List")
			tabcontainer:AddChild(leaderboard_container)

			local leaderboard_container_header_options = AceGUI:Create("SimpleGroup")
			leaderboard_container_header_options:SetWidth(600)
			leaderboard_container_header_options:SetHeight(200)
			leaderboard_container_header_options:SetLayout("Flow")
			leaderboard_container_header_options:SetPoint("BOTTOM", 0, -100)
			leaderboard_container:AddChild(leaderboard_container_header_options)

			local dropdown = AceGUI:Create("Dropdown")
			dropdown:SetWidth(120)
			dropdown:SetLabel("Game\n")
			dropdown:AddItem("SoM", "SoM")
			dropdown:AddItem("Classic TBC", "Classic TBC")
			dropdown:AddItem("Classic Vanilla", "Classic Vanilla")
			dropdown:AddItem("Classic WotLK", "Classic WotLK")
			dropdown:SetValue(_hardcore_character.party_mode)
			dropdown:SetPoint("TOP", 2, 5)
			leaderboard_container_header_options:AddChild(dropdown)

			local tm1 = AceGUI:Create("EditBox")
			tm1:SetWidth(120)
			tm1:SetHeight(120)
			tm1:SetDisabled(false)
			tm1:SetLabel("Player search")
			tm1:SetPoint("TOP", 20, 5)
			tm1:DisableButton(true)
			leaderboard_container_header_options:AddChild(tm1)

			local tm1 = AceGUI:Create("Button")
			tm1:SetText("Achievement Filter")
			tm1:SetPoint("TOP", 20, 5)
			leaderboard_container_header_options:AddChild(tm1)

			local leaderboard_container_header = AceGUI:Create("SimpleGroup")
			leaderboard_container_header:SetFullWidth(true)
			leaderboard_container_header:SetHeight(200)
			leaderboard_container_header:SetLayout("Flow")
			leaderboard_container_header:SetPoint("BOTTOM", 0, -100)
			leaderboard_container:AddChild(leaderboard_container_header)

			local description = AceGUI:Create("Label")
			description:SetWidth(35)
			description:SetFont("", 16)
			local description_text = "Rank"
			description:SetText(description_text)
			description:SetPoint("BOTTOM", 0, -30)
			leaderboard_container_header:AddChild(description)

			local description = AceGUI:Create("Label")
			description:SetWidth(150)
			description:SetFont("", 16)
			-- description:SetFontObject(GameFontNormalSmall)
			local description_text = "Player Name"
			description:SetText(description_text)
			description:SetPoint("BOTTOM", 0, 0)
			leaderboard_container_header:AddChild(description)

			local description = AceGUI:Create("Label")
			description:SetWidth(50)
			description:SetFont("", 16)
			local description_text = "60's"
			description:SetText(description_text)
			description:SetPoint("BOTTOM", 0, 0)
			leaderboard_container_header:AddChild(description)

			local description = AceGUI:Create("Label")
			description:SetWidth(150)
			description:SetFont("", 16)
			local description_text = "Classes"
			description:SetText(description_text)
			description:SetPoint("BOTTOM", 0, 0)
			leaderboard_container_header:AddChild(description)

			local description = AceGUI:Create("Label")
			description:SetWidth(150)
			description:SetFont("", 16)
			local description_text = "Achievements"
			description:SetText(description_text)
			description:SetPoint("BOTTOM", 0, 0)
			leaderboard_container_header:AddChild(description)

			local scroll_container = AceGUI:Create("SimpleGroup")
			scroll_container:SetFullWidth(true)
			scroll_container:SetHeight(300)
			scroll_container:SetLayout("Flow")
			leaderboard_container:AddChild(scroll_container)
			local scroll_frame = AceGUI:Create("ScrollFrame")
			scroll_frame:SetHeight(300)
			scroll_frame:SetLayout("ListTight")
			scroll_container:AddChild(scroll_frame)
			DrawLeaderboardTab(container, scroll_frame)
		end
	end

	tabcontainer:SetCallback("OnGroupSelected", SelectGroup)
	tabcontainer:SelectTab("WelcomeTab")

	f:AddChild(tabcontainer)
	f:SetCallback("OnClose", function()
		local party_modes = {
			"Solo",
			"Duo",
			"Trio",
		}
		for i, mode in ipairs(party_modes) do
			if _G.extra_rules[mode] ~= nil then
				_G.extra_rules[mode]:Unregister()
			end
		end
		if _G.extra_rules[_hardcore_character.party_mode] ~= nil then
			_G.extra_rules[_hardcore_character.party_mode]:Register(_, _hardcore_character)
		end
	end)
end
