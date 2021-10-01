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

PlayerFrameSettings.Tables = {};
PlayerFrameSettings.Tables.Points = {};

PlayerFrameSettings.animation_frame = CreateFrame("Frame", nil, UIParent)

PlayerFrameSettings.Funcs.Display = {};

-- [ Texture info ] --
local PlayerFrameTextureInfo = {
    Str = "Interface\\AddOns\\Hardcore\\Textures\\hardcore_frame_placeholder.blp",
    OffsetX_0 = 16,
    OffsetX_1 = 50,
    OffsetY_0 = 30,
    OffsetY_1 = -4,
    LevelOffsetX = -31,
    LevelOffsetY = -11,
    RestIconOffsetX = 1.5,
    RestIconOffsetY = 3,
    TexCoords = {0, 1, 0, 1},
    reversed = true
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
    reversed = true
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
    reversed = false
}

-- [ Player Loaded handler ] --
function PlayerFrameSettings.Funcs.PlayerLoaded(reload)
    PlayerFrameSettings.Vars.PlayerLoaded = false;
    PlayerFrameSettings.Funcs.FillPlayerFramePointsTable(); -- Never reset manually, only when Blizzard updates the layout
    PlayerFrameSettings.Funcs.FillLevelTextPointsTable(); -- Never reset manually, only when Blizzard updates the layout
    PlayerFrameSettings.Funcs.FillRestIconPointsTable(); -- Never reset manually, only when Blizzard updates the layout
    PlayerFrameSettings.Vars.PlayerLoaded = true;
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
    PlayerFrameTexture:SetTexture(texture_info.Str);
    PlayerFrameTexture:ClearAllPoints();
    for k, v in pairs(PlayerFrameSettings.Tables.Points.PlayerFrameTexture) do
        if (k == 1) then
            PlayerFrameTexture:SetPoint(v.Anchor, v.RelativeFrame,
                                        v.RelativeAnchor,
                                        (v.OffsetX + texture_info.OffsetX_0),
                                        (v.OffsetY + texture_info.OffsetY_0));
        else
            PlayerFrameTexture:SetPoint(v.Anchor, v.RelativeFrame,
                                        v.RelativeAnchor,
                                        (v.OffsetX + texture_info.OffsetX_1),
                                        (v.OffsetY + texture_info.OffsetY_1));
        end
    end
    PlayerFrameTexture:SetTexCoord(texture_info.TexCoords[1],
                                   texture_info.TexCoords[2],
                                   texture_info.TexCoords[3],
                                   texture_info.TexCoords[4]);
    PlayerFrameSettings.Funcs.Display.UpdatePlayerFrameLevel(texture_info);
    PlayerFrameSettings.Funcs.Display.UpdatePlayerFrameRestIcon(texture_info);
    if (PlayerFrame:IsClampedToScreen() == false or force) then
        PlayerFrame:SetClampedToScreen(true);
    end
end

-- Update location of the level text
function PlayerFrameSettings.Funcs.Display.UpdatePlayerFrameLevel(texture_info)
    if (PlayerFrameSettings.Vars.PlayerLoaded) then
        if (#PlayerFrameSettings.Tables.Points.PlayerLevelText >= 1) then
            PlayerLevelText:ClearAllPoints();
            for k, v in pairs(PlayerFrameSettings.Tables.Points.PlayerLevelText) do
                PlayerLevelText:SetPoint(v.Anchor, v.RelativeFrame,
                                         v.RelativeAnchor, (v.OffsetX +
                                             texture_info.LevelOffsetX),
                                         (v.OffsetY + texture_info.LevelOffsetY));
            end
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

