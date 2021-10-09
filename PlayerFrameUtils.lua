local _G = _G

_G.PlayerFrameSettings = {}

PlayerFrameSettings = _G.PlayerFrameSettings;
PlayerFrameSettings.Funcs = {};

PlayerFrameSettings.Vars = {}
PlayerFrameSettings.Vars.Loaded = false;
PlayerFrameSettings.Vars.PlayerLoaded = false;
PlayerFrameSettings.Vars.PlayerFrame = {}
PlayerFrameSettings.Vars.PlayerFrame.Animated = false
PlayerFrameSettings.Vars.PlayerFrame.AnimationInit = false

PlayerFrameSettings.Vars.TargetFrame = {}
PlayerFrameSettings.Vars.TargetFrame.Animated = false
PlayerFrameSettings.Vars.TargetFrame.Enabled = true

PlayerFrameSettings.Tables = {};
PlayerFrameSettings.Tables.Points = {};

PlayerFrameSettings.animation_frame = CreateFrame("Frame", nil, UIParent)

PlayerFrameSettings.accent_frames = {};
PlayerFrameSettings.accent_frames.player_frame = CreateFrame("Frame", nil, UIParent);
PlayerFrameSettings.accent_frames.player_frame_texture = PlayerFrameSettings.accent_frames.player_frame:CreateTexture(nil, "ARTWORK")
PlayerFrameSettings.accent_frames.minimap_border_frame = CreateFrame("Frame", nil, UIParent);
PlayerFrameSettings.accent_frames.minimap_border_texture = PlayerFrameSettings.accent_frames.minimap_border_frame:CreateTexture(nil, "OVERLAY")

PlayerFrameSettings.Funcs.Display = {};

-- [ Texture info ] --
local PlayerFrameTextureInfo = {
    Str = "Interface\\AddOns\\Hardcore\\Textures\\hardcore_frame_placeholder.blp",
    AccentStr = "Interface\\AddOns\\Hardcore\\Textures\\hardcore_frame_placeholder_accent.blp",
    OffsetX_0 = 16,
    OffsetX_1 = 50,
    OffsetY_0 = 30,
    OffsetY_1 = -4,
    LevelOffsetX = -31,
    LevelOffsetY = -11,
    RestIconOffsetX = 1.5,
    RestIconOffsetY = 3,
    TexCoords = {0, 1, 0, 1},
}
local TargetFrameTextureInfo = {
    Str = "Interface\\AddOns\\Hardcore\\Textures\\hardcore_frame_placeholder.blp",
    AccentStr = "Interface\\AddOns\\Hardcore\\Textures\\hardcore_frame_placeholder_accent.blp",
    OffsetX_0 = -50,
    OffsetX_1 = -16,
    OffsetY_0 = 30,
    OffsetY_1 = -4,
    LevelOffsetX = -.8,
    LevelOffsetY = 1.2,
    RestIconOffsetX = 1.5,
    RestIconOffsetY = 3,
    TexCoords = {1, 0, 0, 1},
}

local PlayerFrameAnimatedTextureInfo = {
    Str = "Interface\\AddOns\\Hardcore\\Textures\\hardcore_frame_placeholder_animated.blp",
    OffsetX_0 = 16,
    OffsetX_1 = 50,
    OffsetY_0 = 30,
    OffsetY_1 = -4,
    LevelOffsetX = -31,
    LevelOffsetY = -11,
    RestIconOffsetX = 1.5,
    RestIconOffsetY = 3,
    TexCoords = {0, 1, 0, 1},
}

local OriginalTextureInfo = {
    Str = "Interface\\TargetingFrame\\UI-TargetingFrame.blp",
    OffsetX_0 = 0,
    OffsetX_1 = 0,
    OffsetY_0 = 0,
    OffsetY_1 = 0,
    LevelOffsetX = 0,
    LevelOffsetY = 0,
    RestIconOffsetX = 0,
    RestIconOffsetY = 0,
    TexCoords = {1, 0.09375, 0, .78125},
}

local HardcoreMinimapBorderInfo = {
    Str = "Interface\\AddOns\\Hardcore\\Textures\\hardcore_minimap_placeholder.blp",
    AccentStr = "Interface\\AddOns\\Hardcore\\Textures\\hardcore_frame_placeholder_accent.blp",
    OffsetX_0 = 35,
    OffsetX_1 = -10,
    OffsetY_0 = 0,
    OffsetY_1 = 45,
    LevelOffsetX = 0,
    LevelOffsetY = 0,
    RestIconOffsetX = 0,
    RestIconOffsetY = 0,
    TexCoords = {-.001, 1, -.001, 1},
}

local OriginalMinimapBorderInfo = {
    Str = "Interface\\Minimap\\UI-Minimap-Border",
    OffsetX_0 = -65,
    OffsetX_1 = 0,
    OffsetY_0 = 33,
    OffsetY_1 = -25,
    LevelOffsetX = 0,
    LevelOffsetY = 0,
    RestIconOffsetX = 0,
    RestIconOffsetY = 0,
    TexCoords = {-.001, 1, -.001, 1},
}


function PlayerIsHardcore()
	return true;
end


-- [ Player Loaded handler ] --
function PlayerFrameSettings.Funcs.PlayerLoaded(reload)
    PlayerFrameSettings.Vars.PlayerLoaded = false;
    PlayerFrameSettings.Funcs.FillPlayerFramePointsTable(); -- Never reset manually, only when Blizzard updates the layout
    PlayerFrameSettings.Funcs.FillLevelTextPointsTable(); -- Never reset manually, only when Blizzard updates the layout
    PlayerFrameSettings.Funcs.FillRestIconPointsTable(); -- Never reset manually, only when Blizzard updates the layout
    PlayerFrameSettings.Funcs.FillMinimapPointsTable(); -- Never reset manually, only when Blizzard updates the layout
    PlayerFrameSettings.Funcs.FillTargetFramePointsTable();
    PlayerFrameSettings.Vars.PlayerLoaded = true;

    hooksecurefunc("TargetFrame_CheckClassification",function(self,lock)
	    if (PlayerFrameSettings.Vars.TargetFrame.Enabled and PlayerIsHardcore()) then
		   --PlayerFrameSettings.Funcs.FillTargetFramePointsTable();
		   PlayerFrameSettings.Funcs.FillTargetLevelTextPointsTable()

		   local texture_info = TargetFrameTextureInfo
		   PlayerFrameSettings.Funcs.Display.UpdateTexture(TargetFrame.borderTexture, PlayerFrameSettings.Tables.Points.TargetFrameTexture, texture_info)

		   PlayerFrameSettings.Funcs.Display.UpdateLevelText(TargetFrame.levelText, PlayerFrameSettings.Tables.Points.TargetLevelText ,texture_info);
	    end
end);
end

-- [ Fill points tables with default data] --
function PlayerFrameSettings.Funcs.FillPlayerFramePointsTable(reset)
    if (reset or not PlayerFrameSettings.Tables.Points["PlayerFrameTexture"]) then
        -- Reset used if hooked to a dynamic layout update function from Blizzard (currently not used)
        if (UnitExists("player")) then
            PlayerFrameSettings.Tables.Points["PlayerFrameTexture"] = {};
            local points = PlayerFrameTexture:GetNumPoints();
            local i = 1;
            while (i <= points) do
                local anchor, relativeFrame, relativeAnchor, x, y =
                    PlayerFrameTexture:GetPoint(i);
                tinsert(PlayerFrameSettings.Tables.Points.PlayerFrameTexture, {
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
end
function PlayerFrameSettings.Funcs.FillTargetFramePointsTable(reset)
    if (reset or not PlayerFrameSettings.Tables.Points["TargetFrameTexture"]) then
        -- Reset used if hooked to a dynamic layout update function from Blizzard (currently not used)
        if (UnitExists("player")) then
            PlayerFrameSettings.Tables.Points["TargetFrameTexture"] = {};
            local points = TargetFrame.borderTexture:GetNumPoints();
            local i = 1;
            while (i <= points) do
                local anchor, relativeFrame, relativeAnchor, x, y =
                    TargetFrame.borderTexture:GetPoint(i);
                tinsert(PlayerFrameSettings.Tables.Points.TargetFrameTexture, {
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
end
function PlayerFrameSettings.Funcs.FillTargetLevelTextPointsTable(reset)
    if (reset or not PlayerFrameSettings.Tables.Points["TargetLevelText"]) then
        -- Reset used if hooked to a dynamic layout update function from Blizzard (PlayerFrame_UpdateLevelTextAnchor)
            PlayerFrameSettings.Tables.Points["TargetLevelText"] = {};
            TargetFrame.levelText:SetWordWrap(false); -- Fixes visual vertical misalignment discrepancy between login and UI reloads for 100+
            local points = TargetFrame.levelText:GetNumPoints();
            local i = 1;
            while (i <= points) do
                local anchor, relativeFrame, relativeAnchor, x, y =
                    TargetFrame.levelText:GetPoint(i);
                tinsert(PlayerFrameSettings.Tables.Points.TargetLevelText, {
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
function PlayerFrameSettings.Funcs.FillLevelTextPointsTable(reset)
    if (reset or not PlayerFrameSettings.Tables.Points["PlayerLevelText"]) then
        -- Reset used if hooked to a dynamic layout update function from Blizzard (PlayerFrame_UpdateLevelTextAnchor)
        if (UnitExists("player")) then
            PlayerFrameSettings.Tables.Points["PlayerLevelText"] = {};
            PlayerLevelText:SetWordWrap(false); -- Fixes visual vertical misalignment discrepancy between login and UI reloads for 100+
            local points = PlayerLevelText:GetNumPoints();
            local i = 1;
            while (i <= points) do
                local anchor, relativeFrame, relativeAnchor, x, y =
                    PlayerLevelText:GetPoint(i);
                tinsert(PlayerFrameSettings.Tables.Points.PlayerLevelText, {
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
end
function PlayerFrameSettings.Funcs.FillRestIconPointsTable(reset)
    if (reset or not PlayerFrameSettings.Tables.Points["PlayerRestIcon"]) then
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
end
-- [ Fill points tables with default data] --
function PlayerFrameSettings.Funcs.FillMinimapPointsTable(reset)
    if (reset or not PlayerFrameSettings.Tables.Points["MinimapTexture"]) then
        -- Reset used if hooked to a dynamic layout update function from Blizzard (currently not used)
        if (UnitExists("player")) then
            PlayerFrameSettings.Tables.Points["MinimapTexture"] = {};
            local points = MinimapBorder:GetNumPoints();
            local i = 1;
            while (i <= points) do
                local anchor, relativeFrame, relativeAnchor, x, y =
                    MinimapBorder:GetPoint(i);
                tinsert(PlayerFrameSettings.Tables.Points.MinimapTexture, {
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
end

-- [ Display Functions ] --
-- Update location of the level text
function PlayerFrameSettings.Funcs.Display.UpdatePlayerFrame(enabled, animated)
    if animated == true and enabled == true then
        PlayerFrameSettings.Vars.PlayerFrame.Animated = true
    else
        PlayerFrameSettings.Vars.PlayerFrame.Animated = false
    end

    local texture_info = {}
    if enabled == true then
        if PlayerFrameSettings.Vars.PlayerFrame.Animated == false then
            texture_info = PlayerFrameTextureInfo
        else
            texture_info = PlayerFrameAnimatedTextureInfo
        end
    else
        texture_info = OriginalTextureInfo
    end

    PlayerFrameSettings.Funcs.Display.UpdateTexture(PlayerFrameTexture, PlayerFrameSettings.Tables.Points.PlayerFrameTexture, texture_info)

    PlayerFrameSettings.Funcs.Display.UpdateAccentTexture(PlayerFrameSettings.accent_frames.player_frame_texture, PlayerFrameSettings.Tables.Points.PlayerFrameTexture, texture_info, {1,1,1,1})
    -- Without doing this, the pets face will be covered by player overlay
    PetFrame:SetFrameStrata("High")

    if PlayerFrameSettings.Vars.PlayerLoaded == true then
        PlayerFrameSettings.Funcs.Display.UpdateLevelText(PlayerLevelText, PlayerFrameSettings.Tables.Points.PlayerLevelText ,texture_info);
    end
    PlayerFrameSettings.Funcs.Display.UpdatePlayerFrameRestIcon(texture_info);
end

function PlayerFrameSettings.Funcs.Display.UpdateMinimapFrame(enabled)
    local texture_info = {}
    if enabled == true then
        texture_info = HardcoreMinimapBorderInfo
    else
        texture_info = OriginalMinimapBorderInfo
    end

    PlayerFrameSettings.Funcs.Display.UpdateTexture(MinimapBorder, PlayerFrameSettings.Tables.Points.MinimapTexture, texture_info)
    PlayerFrameSettings.Funcs.Display.UpdateAccentTexture(PlayerFrameSettings.accent_frames.minimap_border_texture, PlayerFrameSettings.Tables.Points.MinimapTexture, texture_info, {1,1,1,1})
end

-- [ Display Functions ] --
-- Update location of the level text
function PlayerFrameSettings.Funcs.Display.EnableTargetFrame(enabled, animated)
    PlayerFrameSettings.Vars.TargetFrame.Enabled = enabled
end

function PlayerFrameSettings.Funcs.Display.UpdateTexture(texture, points, texture_info)
    texture:SetTexture(texture_info.Str);
    --TargetFrame.borderTexture:SetTexture(texture_info.Str);
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
    if PlayerFrameSettings.Vars.PlayerFrame.Animated == true then
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

