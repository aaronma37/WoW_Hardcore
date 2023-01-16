local _G = _G
local _achievement = CreateFrame("Frame")
_G.passive_achievements.AFinalBlow = _achievement

-- General info
_achievement.name = "AFinalBlow"
_achievement.title = "Death to the Legion"
_achievement.class = "All"
_achievement.icon_path = "Interface\\Addons\\Hardcore\\Media\\icon_a_final_blow.blp"
_achievement.level_cap = 55
_achievement.quest_num = 5242
_achievement.quest_name = "A Final Blow"
_achievement.zone = "Felwood"
_achievement.bl_text = "Felwood Quest"
_achievement.pts = 10 
_achievement.kill_target = "Shadow Lord Fel'dan"
_achievement.description = HCGeneratePassiveAchievementKillDescription(_achievement.kill_target, _achievement.quest_name, _achievement.zone, _achievement.level_cap)
_achievement.restricted_game_versions = {
	["WotLK"] = 1,
}

-- Registers
function _achievement:Register(succeed_function_executor)
	_achievement:RegisterEvent("QUEST_TURNED_IN")
	_achievement.succeed_function_executor = succeed_function_executor 
end

function _achievement:Unregister()
	_achievement:UnregisterEvent("QUEST_TURNED_IN")
end

-- Register Definitions
_achievement:SetScript("OnEvent", function(self, event, ...)
	local arg = { ... }
	HCCommonPassiveAchievementBasicQuestCheck(_achievement, event, arg)
end)
