local _G = _G
local _achievement = CreateFrame("Frame")
_G.passive_achievements.Parkour = _achievement

-- General info
_achievement.name = "Parkour"
_achievement.title = "Parkour (1)"
_achievement.class = "All"
_achievement.icon_path = "Interface\\Addons\\Hardcore\\Media\\icon_speedrunner.blp"
_achievement.category = "Miscellaneous"
_achievement.level_cap = 60
_achievement.bl_text = "Miscellaneous"
_achievement.pts = 5
_achievement.description = "Jump to the Orgrimmar bank ledge and then apply a bandage to Ambassador Rokhstrom"
_achievement.restricted_game_versions = {
	["WotLK"] = 1,
}

local first_aid_name = "First Aid"		-- Will be overwritten in the locale by UNIT_SPELLCAST_SUCCEEDED

-- Registers
function _achievement:Register(succeed_function_executor)
	_achievement.succeed_function_executor = succeed_function_executor
	_achievement:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")			-- Can't get target reliably from this
	_achievement:RegisterEvent("CHAT_MSG_TEXT_EMOTE")
	_achievement:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function _achievement:Unregister()
	_achievement:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	_achievement:UnregisterEvent("CHAT_MSG_TEXT_EMOTE")
	_achievement:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

-- UpdateParkourAchievement
--
-- Redoes the count of how many places you've reached and updates the achievement title

local function UpdateParkourAchievement()
	return
end


local function IsPlayerWithinTriangle( x1, y1, x2, y2, x3, y3)

	local x,y = UnitPosition("player")
	x=math.floor((tonumber(x) * 10) + 0.5)/10		-- Round to first decimal
	y=math.floor((tonumber(y) * 10) + 0.5)/10		-- Round to first decimal

	-- Calculate coords with respect to vertices
	local dx1, dy1, dx2, dy2, dx3, dy3
	dx1 = x - x1
	dy1 = y - y1
	dx2 = x - x2
	dy2 = y - y2
	dx3 = x - x3
	dy3 = y - y3

	-- Calculate normal vectors to the edges starting at the three vertices and going clockwise to the next
	local nx1, ny1, nx2, ny2, nx3, ny3
	nx1 = y2 - y1
	ny1 = -(x2 - x1)
	nx2 = y3 - y2
	ny2 = -(x3 - x2)
	nx3 = y1 - y3
	ny3 = -(x1 - x3)

	-- Calculate inner products, should all be positive for points inside the triangle
	local ip1, ip2, ip3
	ip1 = dx1 * nx1 + dy1 * ny1
	ip2 = dx2 * nx2 + dy2 * ny2
	ip3 = dx3 * nx3 + dy3 * ny3

	if ip1 >= 0 and ip2 >= 0 and ip3 >= 0 then
		return true
	end
	return false
end

local function OnOrgrimmarBankLedge()
	if IsPlayerWithinTriangle( 1614.8, -4384.7, 1616.4, -4388.4, 1613.8, -4386.0 ) then
		return true
	end
	return false
end

local function OnOrgrimmarAuctionHouseLedge()
	if IsPlayerWithinTriangle( 1671.5, -4429.7, 1671.6, -4428.4, 1675.8, -4427.6 ) then
		return true
	end
	return false
end



-- Event handling
_achievement:SetScript("OnEvent", function(self, event, ...)
	local arg = { ... }
	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		local unit, cast_guid, spell_id = ...
		-- print( unit .. "," .. cast_guid .. "," .. spell_id )
		if unit ~= "player" then
			return
		end
		-- Checks where the position is confirmed by First Aid range to a mob
		if spell_id == 746 or spell_id == 1159 or spell_id == 3267 or spell_id == 3268 or
			spell_id == 7926 or spell_id == 7927 or spell_id == 10838 or spell_id == 10839 or
			spell_id == 18608 or spell_id == 23696 then
			-- Check if we are in the Orgrimmar bank ledge and the target is Rokhstrom
			print( "You cast first aid, " .. unit .. ", " .. cast_guid .. ", " .. spell_id )
			first_aid_name = GetSpellInfo(spell_id)
		end
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, subevent, _, source_guid, _, _, _,	dest_guid, _, _, _,	espell_id, spell_name, spell_school = CombatLogGetCurrentEventInfo()
		if subevent == "SPELL_CAST_SUCCESS" then
			-- Check if it was a bandage
			--print(spell_id .. spell_name .. spell_school )
			if spell_name == first_aid_name then
				-- Check if we are in the Orgrimmar bank ledge and the target is Rokhstrom
				print( "Someone cast first aid: " .. source_guid .. "=>" .. dest_guid )

				-- Check if it was the player who cast the bandage
				if source_guid ~= UnitGUID("player") then
					return
				end
				print( "It was you!" )

				-- Check if it was Rokhstrom that got bandaged
				local target_type, _, server, map_id, instance_id, target_type_id = string.split("-", dest_guid)
				map_id = tonumber( map_id )
				target_type_id = tonumber( target_type_id )
				if target_type ~= "Creature" or map_id ~= 1 or target_type_id ~= 13842 then
					return
				end
				print( "And you bandaged the Ambassador" )

				-- Check if the coordinates are correct
				if OnOrgrimmarBankLedge() == false then
					return
				end

				print( "Achievement awarded!" )
				_achievement.succeed_function_executor.Succeed(_achievement.name)
			end
		end
	elseif event == "CHAT_MSG_TEXT_EMOTE" then			-- For debugging purposes
		if IsInInstance() == false then
			mapID = C_Map.GetBestMapForUnit("player")
			if mapID == 1454 then
				if OnOrgrimmarBankLedge() then
					print( "On Orgrimmar Bank ledge" )
				else
					print( "Not on Orgrimmar Bank ledge" )
				end
				if OnOrgrimmarAuctionHouseLedge() then
					print( "On Orgrimmar AH ledge" )
				else
					print( "Not on Orgrimmar AH ledge" )
				end
			end
			return
		end
	end

end)
