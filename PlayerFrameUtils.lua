local _G = _G

local HCTI = _G.HCTextureInfo

--- Config
--
function ShowColorPicker(r, g, b, a, changedCallback)
 ColorPickerFrame:SetColorRGB(r,g,b);
 ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = (a ~= nil), a;
 ColorPickerFrame.previousValues = {r,g,b,a};
 ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc =
  changedCallback, changedCallback, changedCallback;
 ColorPickerFrame.func = myColorCallback
 ColorPickerFrame:Hide(); -- Need to run the OnShow handler.
 ColorPickerFrame:Show();
end

function myColorCallback(restore)
 Hardcore:Print(Hardcore_Settings.ui_color_scheme[0])
 local newR, newG, newB, newA;
 if restore then
  newR, newG, newB, newA = unpack(restore);
 else
  newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
 end
 Hardcore:Print(newR)
 Hardcore_Settings.ui_color_scheme = {newR, newG, newB, newA}

        PlayerFrameSettings.Funcs.PlayerLoaded()
        PlayerFrameSettings.Funcs.Display.UpdatePlayerFrame(Hardcore_Settings.show_hc_player_frame, Hardcore_Settings.show_hc_player_frame_animation)
        PlayerFrameSettings.Funcs.StartAnimating()
end

function Hardcore_OptionsOnLoad(f)
	f.name = GetAddOnMetadata("Hardcore", "Title")
	f.okay = Hardcore.SetOptions
	f.default = Hardcore.SetDefaultOptions
	InterfaceOptions_AddCategory(f)
end

if InterfaceOptionsFrame then
	InterfaceOptionsFrame:HookScript("OnShow", function(self)
		-- Hardcore_OptionsOnShow()
	end)
end

--- EndConfig


_G.PlayerFrameSettings = {}


local FramesToUpdate = {
	{texture = PlayerFrameTexture, name = "PlayerFrameTexture"},
	{texture = TargetFrame.borderTexture,name =  "TargetFrameTexture"},
	{texture = TargetFrameToTTextureFrameTexture,name =  "TargetToTFrameTexture"},
	{texture = PetFrameTexture,name =  "PetFrameTexture"},
	{texture = PartyMemberFrame1Texture,name =  "PartyMember1FrameTexture"},
	{texture = PartyMemberFrame2Texture,name =  "PartyMember2FrameTexture"},
	{texture = PartyMemberFrame3Texture,name =  "PartyMember3FrameTexture"},
	{texture = PartyMemberFrame4Texture,name =  "PartyMember4FrameTexture"},
	{texture = MinimapBorder,name =  "MinimapFrameTexture"},
}
local LevelsToUpdate = {
	{texture = TargetFrame.levelText, name = "TargetLevelText"},
	{texture = PlayerLevelText, name =  "PlayerLevelText"},
}
local ButtonsToUpdate = {
	{button = MinimapZoomIn, name = "MinimapZoomIn"},
	{button = MinimapZoomOut, name = "MinimapZoomOut"},
}
    --MinimapZoomIn:SetNormalTexture(HCTI.PlayerFrame[Hardcore_Settings.player_frame].Str)
    --
    --MinimapZoneTextButton:Hide() not the border
    -- local clockFrame, clockTime = TimeManagerClockButton:GetRegions()
    --clockFrame:SetTexture(HCTI.PlayerFrame[Hardcore_Settings.player_frame].Str)
    --clockFrame:Hide()


    --MiniMapTrackingFrame:Hide()
    --MiniMapWorldMapButton:Hide()
    --GameTimeTexture:Hide() THIS IS THE SUN AND MOON!!!

--TimeManagerClockButton:GetRegions()

PlayerFrameSettings = _G.PlayerFrameSettings;
PlayerFrameSettings.Funcs = {};

PlayerFrameSettings.Vars = {}
PlayerFrameSettings.Vars.Loaded = false;
PlayerFrameSettings.Vars.PlayerLoaded = false;
PlayerFrameSettings.Vars.PlayerFrame = {}
PlayerFrameSettings.Vars.PlayerFrame.AnimationInit = false

PlayerFrameSettings.Vars.TargetFrame = {}
PlayerFrameSettings.Vars.TargetFrame.Animated = false

PlayerFrameSettings.Tables = {};
PlayerFrameSettings.Tables.Points = {};

PlayerFrameSettings.animation_frame = CreateFrame("Frame", nil, UIParent)

PlayerFrameSettings.accent_frames = {};
PlayerFrameSettings.accent_frames.player_frame = CreateFrame("Frame", nil, UIParent);
PlayerFrameSettings.accent_frames.player_frame_texture = PlayerFrameSettings.accent_frames.player_frame:CreateTexture(nil, "ARTWORK")
PlayerFrameSettings.accent_frames.minimap_border_frame = CreateFrame("Frame", nil, UIParent);
PlayerFrameSettings.accent_frames.minimap_border_texture = PlayerFrameSettings.accent_frames.minimap_border_frame:CreateTexture(nil, "OVERLAY")

PlayerFrameSettings.Funcs.Display = {};


function PlayerIsHardcore()
	return true;
end


-- [ Player Loaded handler ] --
function PlayerFrameSettings.Funcs.PlayerLoaded(reload)
    PlayerFrameSettings.Vars.PlayerLoaded = false;
    PlayerFrameSettings.Funcs.FillRestIconPointsTable(); -- Never reset manually, only when Blizzard updates the layout

    for _, v in ipairs(FramesToUpdate) do
	    PlayerFrameSettings.Funcs.FillTexturePointsTable(v.texture, v.name);
    end

     for _, v in ipairs(LevelsToUpdate) do
	    PlayerFrameSettings.Funcs.FillLevelTextPointsTable(v.texture, v.name);
     end

    PlayerFrameSettings.Vars.PlayerLoaded = true;

    hooksecurefunc("TargetFrame_CheckClassification",function(self,lock)
	    if (Hardcore_Settings.target_frame == "hardcore" and PlayerIsHardcore()) then
		   PlayerFrameSettings.Funcs.FillLevelTextPointsTable(TargetFrame.levelText, "TargetLevelText")
		   PlayerFrameSettings.Funcs.Display.UpdateTexture(TargetFrame.borderTexture, PlayerFrameSettings.Tables.Points.TargetFrameTexture, HCTI.TargetFrame.hardcore)
		   PlayerFrameSettings.Funcs.Display.UpdateLevelText(TargetFrame.levelText, PlayerFrameSettings.Tables.Points.TargetLevelText ,HCTI.TargetFrame.hardcore);
	    end
end);
end


function PlayerFrameSettings.Funcs.FillTexturePointsTable(texture, var_name)
	if (UnitExists("player")) then
	    PlayerFrameSettings.Tables.Points[var_name] = {};
	    local points = texture:GetNumPoints();
	    local i = 1;
	    while (i <= points) do
		local anchor, relativeFrame, relativeAnchor, x, y =
		    texture:GetPoint(i);
		tinsert(PlayerFrameSettings.Tables.Points[var_name], {
		    ["Anchor"] = anchor,
		    ["RelativeFrame"] = relativeFrame,
		    ["RelativeAnchor"] = relativeAnchor,
		    ["OffsetX"] = x,
		    ["OffsetY"] = y
		});
		i = i + 1;
	    end
	end
end
function PlayerFrameSettings.Funcs.FillLevelTextPointsTable(level_text, var_name)
        -- Reset used if hooked to a dynamic layout update function from Blizzard (PlayerFrame_UpdateLevelTextAnchor)
            PlayerFrameSettings.Tables.Points[var_name] = {};
            TargetFrame.levelText:SetWordWrap(false); -- Fixes visual vertical misalignment discrepancy between login and UI reloads for 100+
            local points = level_text:GetNumPoints();
            local i = 1;
            while (i <= points) do
                local anchor, relativeFrame, relativeAnchor, x, y =
                    level_text:GetPoint(i);
                tinsert(PlayerFrameSettings.Tables.Points[var_name], {
                    ["Anchor"] = anchor,
                    ["RelativeFrame"] = relativeFrame,
                    ["RelativeAnchor"] = relativeAnchor,
                    ["OffsetX"] = x,
                    ["OffsetY"] = y
                });
                i = i + 1;
            end
end
function PlayerFrameSettings.Funcs.FillRestIconPointsTable()
        -- Reset used if hooked to a dynamic layout update function from Blizzard (currently not used)
        if (UnitExists("player")) then
            PlayerFrameSettings.Tables.Points["PlayerRestIcon"] = {};
            local points = PlayerRestIcon:GetNumPoints();
            local i = 1;
            while (i <= points) do
                local anchor, relativeFrame, relativeAnchor, x, y =
                    PlayerRestIcon:GetPoint(i);
                tinsert(PlayerFrameSettings.Tables.Points.PlayerRestIcon, {
                    ["Anchor"] = anchor,
                    ["RelativeFrame"] = relativeFrame,
                    ["RelativeAnchor"] = relativeAnchor,
                    ["OffsetX"] = x,
                    ["OffsetY"] = y
                });
                i = i + 1;
            end
        end
end

-- [ Display Functions ] --
-- Update location of the level text
function PlayerFrameSettings.Funcs.Display.UpdatePlayerFrame()
    PlayerFrameSettings.Funcs.Display.UpdateTexture(PlayerFrameTexture, PlayerFrameSettings.Tables.Points.PlayerFrameTexture, HCTI.PlayerFrame[Hardcore_Settings.player_frame])
    --XPBarTexture0:Hide()

    PlayerFrameSettings.Funcs.Display.UpdateAccentTexture(PlayerFrameSettings.accent_frames.player_frame_texture, PlayerFrameSettings.Tables.Points.PlayerFrameTexture, HCTI.PlayerFrame[Hardcore_Settings.player_frame], Hardcore_Settings.ui_color_scheme)

    -- Without doing this, the pets face will be covered by player overlay
    PetFrame:SetFrameStrata("High")

    if PlayerFrameSettings.Vars.PlayerLoaded == true then
        PlayerFrameSettings.Funcs.Display.UpdateLevelText(PlayerLevelText, PlayerFrameSettings.Tables.Points.PlayerLevelText ,HCTI.PlayerFrame[Hardcore_Settings.player_frame]);
    end
    PlayerFrameSettings.Funcs.Display.UpdatePlayerFrameRestIcon(HCTI.PlayerFrame[Hardcore_Settings.player_frame]);
end

function PlayerFrameSettings.Funcs.Display.UpdateTargetToTFrame()
    PlayerFrameSettings.Funcs.Display.UpdateTexture(TargetFrameToTTextureFrameTexture, PlayerFrameSettings.Tables.Points.TargetToTFrameTexture, HCTI.PlayerFrame[Hardcore_Settings.targetToT_frame])
end

function PlayerFrameSettings.Funcs.Display.UpdatePetFrame()
    PlayerFrameSettings.Funcs.Display.UpdateTexture(PetFrameTexture, PlayerFrameSettings.Tables.Points.PetFrameTexture, HCTI.PetFrame[Hardcore_Settings.pet_frame])
end

function PlayerFrameSettings.Funcs.Display.UpdatePartyFrame()
    PlayerFrameSettings.Funcs.Display.UpdateTexture(PartyMemberFrame1Texture, PlayerFrameSettings.Tables.Points.PetFrameTexture, HCTI.PetFrame[Hardcore_Settings.party_frame])
    PlayerFrameSettings.Funcs.Display.UpdateTexture(PartyMemberFrame2Texture, PlayerFrameSettings.Tables.Points.PetFrameTexture, HCTI.PetFrame[Hardcore_Settings.party_frame])
    PlayerFrameSettings.Funcs.Display.UpdateTexture(PartyMemberFrame3Texture, PlayerFrameSettings.Tables.Points.PetFrameTexture, HCTI.PetFrame[Hardcore_Settings.party_frame])
    PlayerFrameSettings.Funcs.Display.UpdateTexture(PartyMemberFrame4Texture, PlayerFrameSettings.Tables.Points.PetFrameTexture, HCTI.PetFrame[Hardcore_Settings.party_frame])
end

function PlayerFrameSettings.Funcs.Display.UpdateMinimapFrame()
    PlayerFrameSettings.Funcs.Display.UpdateTexture(MinimapBorder, PlayerFrameSettings.Tables.Points.MinimapFrameTexture, HCTI.MinimapFrame[Hardcore_Settings.minimap_frame])
    PlayerFrameSettings.Funcs.Display.UpdateAccentTexture(PlayerFrameSettings.accent_frames.minimap_border_texture, PlayerFrameSettings.Tables.Points.MinimapFrameTexture, HCTI.MinimapFrame[Hardcore_Settings.minimap_frame], {1,1,1,1})
end

-- [ Display Functions ] --
function PlayerFrameSettings.Funcs.Display.UpdateTexture(texture, points, texture_info)
    texture:SetTexture(texture_info.Str);
    texture:ClearAllPoints();
    for k, v in pairs(points) do
        if (k == 1) then
            texture:SetPoint(v.Anchor, v.RelativeFrame,
                                        v.RelativeAnchor,
                                        (v.OffsetX + texture_info.OffsetX_0),
                                        (v.OffsetY + texture_info.OffsetY_0));
        else
            texture:SetPoint(v.Anchor, v.RelativeFrame,
                                        v.RelativeAnchor,
                                        (v.OffsetX + texture_info.OffsetX_1),
                                        (v.OffsetY + texture_info.OffsetY_1));
        end
    end
    texture:SetTexCoord(texture_info.TexCoords[1],
                                   texture_info.TexCoords[2],
                                   texture_info.TexCoords[3],
                                   texture_info.TexCoords[4]);

    if (PlayerFrame:IsClampedToScreen() == false or force) then
        PlayerFrame:SetClampedToScreen(true);
    end
end

function PlayerFrameSettings.Funcs.Display.UpdateAccentTexture(texture, points, texture_info, color)
    texture:SetTexture(texture_info.AccentStr);
    texture:ClearAllPoints();
    for k, v in pairs(points) do
        if (k == 1) then
            texture:SetPoint(v.Anchor, v.RelativeFrame,
                                        v.RelativeAnchor,
                                        (v.OffsetX + texture_info.OffsetX_0),
                                        (v.OffsetY + texture_info.OffsetY_0));
        else
            texture:SetPoint(v.Anchor, v.RelativeFrame,
                                        v.RelativeAnchor,
                                        (v.OffsetX + texture_info.OffsetX_1),
                                        (v.OffsetY + texture_info.OffsetY_1));
        end
    end
    texture:SetTexCoord(texture_info.TexCoords[1],
                                   texture_info.TexCoords[2],
                                   texture_info.TexCoords[3],
                                   texture_info.TexCoords[4]);

    if (PlayerFrame:IsClampedToScreen() == false or force) then
        PlayerFrame:SetClampedToScreen(true);
    end


    texture:SetVertexColor(color[1], color[2], color[3], color[4])
end

-- Update location of the level text PlayerLevelText, PlayerFrameSettings.Tables.Points.PlayerLevelText
function PlayerFrameSettings.Funcs.Display.UpdateLevelText(display_text, text, texture_info)
		if (#text >= 1) then
		    display_text:ClearAllPoints();
		    for k, v in pairs(text) do
			display_text:SetPoint(v.Anchor, v.RelativeFrame,
						 v.RelativeAnchor, (v.OffsetX +
						     texture_info.LevelOffsetX),
						 (v.OffsetY + texture_info.LevelOffsetY));
		    end
		end
end

-- Update location of the rest icon
function PlayerFrameSettings.Funcs.Display.UpdatePlayerFrameRestIcon(
    texture_info)
    if (PlayerFrameSettings.Vars.PlayerLoaded) then
        for k, v in pairs(PlayerFrameSettings.Tables.Points.PlayerRestIcon) do
            if (k == 1) then
                PlayerRestIcon:SetPoint(v.Anchor, v.RelativeFrame,
                                        v.RelativeAnchor, (v.OffsetX +
                                            texture_info.RestIconOffsetX),
                                        v.OffsetY + texture_info.RestIconOffsetY);
            end
        end
    end
end

-- [ Animation functions ] --
--
-- Animate the texture by moving TexCoords.  Texture should be a sprite map.
function PlayerFrameSettings.Funcs.AnimateTexCoords(texture, textureWidth,
                                                    textureHeight, frameWidth,
                                                    frameHeight, numFrames,
                                                    elapsed, throttle)
    if (not texture.frame) then
        -- initialize everything
        texture.frame = 1;
        texture.throttle = throttle;
        texture.numColumns = floor(textureWidth / frameWidth);
        texture.numRows = floor(textureHeight / frameHeight);
        texture.columnWidth = frameWidth / textureWidth;
        texture.rowHeight = frameHeight / textureHeight;
    end
    local frame = texture.frame;
    if (not texture.throttle or texture.throttle > throttle) then
        local framesToAdvance = floor(texture.throttle / throttle);
        while (frame + framesToAdvance > numFrames) do
            frame = frame - numFrames;
        end
        frame = frame + framesToAdvance;
        texture.throttle = 0;
        local left = mod(frame - 1, texture.numColumns) * texture.columnWidth;
        local right = left + texture.columnWidth;
        local bottom = ceil(frame / texture.numColumns) * texture.rowHeight;
        local top = bottom - texture.rowHeight;
        texture:SetTexCoord(left, right, top, bottom);

        texture.frame = frame;
    else
        texture.throttle = texture.throttle + elapsed;
    end
end
function PlayerFrameSettings.Funcs.Animate_OnUpdate(elapsed)
    if Hardcore_Settings.player_frame == "hardcore_animated" then
        PlayerFrameSettings.Funcs.AnimateTexCoords(PlayerFrameTexture, 1028,
                                                   256, 257, 128, 8, elapsed,
                                                   0.1)
    end
end

function PlayerFrameSettings.Funcs.StartAnimating()
    if PlayerFrameSettings.Vars.PlayerFrame.AnimationInit == false then
	PlayerFrameSettings.animation_frame:HookScript("OnUpdate", function(self,
									elapsed)
	PlayerFrameSettings.Funcs.Animate_OnUpdate(elapsed)
	end)
	PlayerFrameSettings.Vars.PlayerFrame.AnimationInit = true
    end
end

