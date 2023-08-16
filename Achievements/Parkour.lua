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
	_achievement:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function _achievement:Unregister()
	_achievement:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	_achievement:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

-- Event handling
_achievement:SetScript("OnEvent", function(self, event, ...)
	local arg = { ... }
	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		local unit, cast_guid, spell_id = ...
		print( unit .. "," .. cast_guid .. "," .. spell_id )
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
		local _, subevent, _, 
			source_guid, _, _, _,
			dest_guid, _, _, _,
			spell_id, spell_name, spell_school = CombatLogGetCurrentEventInfo()
		if subevent == "SPELL_CAST_SUCCESS" then
			-- Check if it was a bandage
			print(spell_id .. spell_name .. spell_school )
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
				local x,y = UnitPosition("player")
				x=math.floor((tonumber(x) * 10) + 0.5)/10
				if x < 1614.7 or x > 1615.5 or y < 4385.6 or y > 4386.3 then
					print( "Not in the right place: (" .. x .. "," .. y .. ")" )
					return
				end

				print( "Achievement awarded!" )
				_achievement.succeed_function_executor.Succeed(_achievement.name)
			end
		end
	end
end)
