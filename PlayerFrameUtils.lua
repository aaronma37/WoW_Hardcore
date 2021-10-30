local _G = _G

_G.PlayerFrameSettings = {}

local TI = _G.HCTextureInfo
local TU = _G.HCTextureUtils
local test_frame = CreateFrame("Frame", nil, UIParent);
local FrameData = {
	PlayerFrameTexture = {texture = PlayerFrameTexture, points = nil},
	TargetFrameTexture = {texture = TargetFrame.borderTexture, points = nil},
	TargetToTFrameTexture = {texture = TargetFrameToTTextureFrameTexture, points = nil},
	PetFrameTexture = {texture = PetFrameTexture, points = nil},
	PartyMember1FrameTexture = {texture = PartyMemberFrame1Texture, points = nil},
	PartyMember2FrameTexture = {texture = PartyMemberFrame2Texture, points = nil},
	PartyMember3FrameTexture = {texture = PartyMemberFrame3Texture, points = nil},
	PartyMember4FrameTexture = {texture = PartyMemberFrame4Texture, points = nil},
	MinimapFrameTexture = {texture = MinimapBorder, points = nil},
}
local LevelFrameData = {
	TargetLevelText = {texture = TargetFrame.levelText, points = nil},
	PlayerLevelText = {texture = PlayerLevelText, points = nil},
}
local RestFrameData = {
	PlayerRestIcon = {texture = PlayerRestIcon, points = nil},
}

local ButtonsToUpdate = {
	{button = MinimapZoomIn, name = "MinimapZoomIn"},
	{button = MinimapZoomOut, name = "MinimapZoomOut"},
}

PlayerFrameSettings = _G.PlayerFrameSettings;
PlayerFrameSettings.Funcs = {};

PlayerFrameSettings.Vars = {}
PlayerFrameSettings.Vars.Loaded = false;
PlayerFrameSettings.Vars.PlayerLoaded = false;
PlayerFrameSettings.Vars.PlayerFrame = {}
PlayerFrameSettings.Vars.PlayerFrame.AnimationInit = false

PlayerFrameSettings.Vars.TargetFrame = {}
PlayerFrameSettings.Vars.TargetFrame.Animated = false

PlayerFrameSettings.animation_frame = CreateFrame("Frame", nil, UIParent)

PlayerFrameSettings.accent_frames = {};
PlayerFrameSettings.accent_frames.player_frame = CreateFrame("Frame", nil, UIParent);
PlayerFrameSettings.accent_frames.player_frame_texture = PlayerFrameSettings.accent_frames.player_frame:CreateTexture(nil, "ARTWORK")
PlayerFrameSettings.accent_frames.minimap_border_frame = CreateFrame("Frame", nil, UIParent);
PlayerFrameSettings.accent_frames.minimap_border_texture = PlayerFrameSettings.accent_frames.minimap_border_frame:CreateTexture(nil, "OVERLAY")

PlayerFrameSettings.Funcs.Display = {};

-- Temporary function to fake if player is hardcore (for testing).
-- @return Return true if player is HC according to addon.
function PlayerIsHardcore()
	return true;
end


-- [ Player Load functions ] --
-- Load points and hook functions on player loaded.
function PlayerFrameSettings.Funcs.PlayerLoaded(reload)
    PlayerFrameSettings.Vars.PlayerLoaded = false;
    TU.FillRestIconPointsTable(RestFrameData.PlayerRestIcon); -- Never reset manually, only when Blizzard updates the layout

    for _, v in pairs(FrameData) do
	    TU.FillTexturePointsTable(v);
    end

     for _, v in pairs(LevelFrameData) do
	    TU.FillLevelTextPointsTable(v);
     end

    PlayerFrameSettings.Vars.PlayerLoaded = true;

     -- Todo  remove
  if test_frame.tex == nil then
    test_frame = CreateFrame("Frame", nil, UIParent);
    test_frame:SetSize(200, 200)
    test_frame:SetPoint("TOPLEFT")
    test_frame.tex = test_frame:CreateTexture(nil, "ARTWORK")
    test_frame.tex:SetTexture('Interface\\AddOns\\Hardcore\\Textures\\warlock_sprite.blp')
    test_frame.tex:SetAllPoints(test_frame)
    test_frame.tex:SetSize(200,200)
    test_frame.tex:SetDrawLayer("Background", 0)
    test_frame.tex:Show()
    test_frame:Show()
    TU.AddToAnimationFrames("TestFrame", test_frame.tex, TI.TestFrame.animated.AnimationInfo)
  end


    -- Hook TargetFrame classification. This is called after the target has been classified (elite, level colors, etc.)
    hooksecurefunc("TargetFrame_CheckClassification",function(self, lock)
	    if (Hardcore_Settings.target_frame == "hardcore" and PlayerIsHardcore()) then
		   TU.FillLevelTextPointsTable(LevelFrameData.TargetLevelText)
		   TU.UpdateTexture(TargetFrame.borderTexture, FrameData.TargetFrameTexture.points, TI.TargetFrame.hardcore)
		   TU.UpdateLevelText(TargetFrame.levelText, LevelFrameData.TargetLevelText.points ,TI.TargetFrame.hardcore);
	    end
end);
    hooksecurefunc("PlayerFrame_UpdateLevelTextAnchor", ForceUpdateLevel);
end

-- Updates the player frame texture.
-- @param arg1 This is arg1.
-- @param arg2 This is arg2.
-- @return Return something.

-- Forces a level update for positioning.
-- @param force Update positioning even if it has already been done.
function ForceUpdateLevel(force)
     for _, v in ipairs(LevelFrameData) do
	    TU.FillLevelTextPointsTable(v);
     end
     PlayerFrameSettings.Funcs.Display.UpdatePlayerFrame()
end

-- Hooks animation function.
function PlayerFrameSettings.Funcs.StartAnimating()
    if PlayerFrameSettings.Vars.PlayerFrame.AnimationInit == false then
	PlayerFrameSettings.animation_frame:HookScript("OnUpdate", function(self, elapsed)
    TU.Animate_OnUpdate(elapsed)
	end)
	PlayerFrameSettings.Vars.PlayerFrame.AnimationInit = true
    end
end

-- [ Update Functions ] --
-- Updates the player frame texture.
function PlayerFrameSettings.Funcs.Display.UpdatePlayerFrame()
    TU.UpdateTexture(PlayerFrameTexture, FrameData.PlayerFrameTexture.points, TI.PlayerFrame[Hardcore_Settings.player_frame], nil)

    TU.UpdateAccentTexture(PlayerFrameSettings.accent_frames.player_frame_texture, FrameData.PlayerFrameTexture.points, TI.PlayerFrame[Hardcore_Settings.player_frame], Hardcore_Settings.ui_color_scheme)

    -- Without doing this, the pets face will be covered by player overlay
    PetFrame:SetFrameStrata("High")

    if PlayerFrameSettings.Vars.PlayerLoaded == true then
        TU.UpdateLevelText(PlayerLevelText, LevelFrameData.PlayerLevelText.points ,TI.PlayerFrame[Hardcore_Settings.player_frame])
    end
    TU.UpdatePlayerFrameRestIcon(RestFrameData.PlayerRestIcon.points, TI.PlayerFrame[Hardcore_Settings.player_frame])

    TU.AddToAnimationFrames("PlayerFrame", PlayerFrameTexture, TI.PlayerFrame[Hardcore_Settings.player_frame].AnimationInfo)
end

-- Updates the target of target frame.
function PlayerFrameSettings.Funcs.Display.UpdateTargetToTFrame()
    TU.UpdateTexture(TargetFrameToTTextureFrameTexture, FrameData.TargetToTFrameTexture.points, TI.PlayerFrame[Hardcore_Settings.targetToT_frame])
end

-- Updates the pet frame.
function PlayerFrameSettings.Funcs.Display.UpdatePetFrame()
    TU.UpdateTexture(PetFrameTexture, FrameData.PetFrameTexture.points, TI.PetFrame[Hardcore_Settings.pet_frame])
end

-- Updates the pet frame.
function PlayerFrameSettings.Funcs.Display.UpdatePartyFrame()
    TU.UpdateTexture(PartyMemberFrame1Texture, FrameData.PetFrameTexture.points, TI.PetFrame[Hardcore_Settings.party_frame])
    TU.UpdateTexture(PartyMemberFrame2Texture, FrameData.PetFrameTexture.points, TI.PetFrame[Hardcore_Settings.party_frame])
    TU.UpdateTexture(PartyMemberFrame3Texture, FrameData.PetFrameTexture.points, TI.PetFrame[Hardcore_Settings.party_frame])
    TU.UpdateTexture(PartyMemberFrame4Texture, FrameData.PetFrameTexture.points, TI.PetFrame[Hardcore_Settings.party_frame])
end

-- Updates the minimap frame
function PlayerFrameSettings.Funcs.Display.UpdateMinimapFrame()
    TU.UpdateTexture(MinimapBorder, FrameData.MinimapFrameTexture.points, TI.MinimapFrame[Hardcore_Settings.minimap_frame])
    TU.UpdateTexture(PlayerFrameSettings.accent_frames.minimap_border_texture, FrameData.MinimapFrameTexture.points, TI.MinimapFrame[Hardcore_Settings.minimap_frame], {1,1,1,1})
end
