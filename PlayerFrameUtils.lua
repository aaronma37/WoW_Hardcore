PlayerFrameSettings = {};
PlayerFrameSettings.Funcs = {};

PlayerFrameSettings.Vars = {}
PlayerFrameSettings.Vars.Loaded = false;
PlayerFrameSettings.Vars.PlayerLoaded = false;
PlayerFrameSettings.Vars.Enabled = true;

PlayerFrameSettings.Tables = {};
PlayerFrameSettings.Tables.Points = {};

PlayerFrameSettings.Funcs.Display = {};

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
			while(i <= points) do
				local anchor, relativeFrame, relativeAnchor, x, y = PlayerFrameTexture:GetPoint(i);
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
			PlayerLevelText:SetWordWrap(false);	-- Fixes visual vertical misalignment discrepancy between login and UI reloads for 100+
			local points = PlayerLevelText:GetNumPoints();
			local i = 1;
			while(i <= points) do
				local anchor, relativeFrame, relativeAnchor, x, y = PlayerLevelText:GetPoint(i);
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
			while(i <= points) do
				local anchor, relativeFrame, relativeAnchor, x, y = PlayerRestIcon:GetPoint(i);
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

-- [ Message writing function ] --
function PlayerFrameSettings.Funcs.Msg(msg,dbg,custom)
	-- Check debugging level
	if (custom) then
		SendChatMessage("[PlayerFrameSettings]: "..tostring(msg).."",custom.type,custom.lang,custom.to);
	else
		if (DEFAULT_CHAT_FRAME and ((dbg == nil) or ((PlayerFrameSettings_Vars.Debug and (PlayerFrameSettings_Vars.Debug >= dbg)) or ((not PlayerFrameSettings_Vars.Debug) and (1 >= dbg))))) then
			if (dbg ~= nil) then
				msg = PlayerFrameSettings.Funcs.Format(tostring(PlayerFrameSettings.Tables.DebugLevels[dbg].Prefix)..":",PlayerFrameSettings.Tables.DebugLevels[dbg]).." "..msg;
			end
			DEFAULT_CHAT_FRAME:AddMessage("[|cFFFFDD33HardcorePlayerFrame|r]: "..tostring(msg).."");
		end
	end
end

-- [ Display Functions ] --
function PlayerFrameSettings.Funcs.Display.UpdatePlayerFrame(force)
	if (PlayerFrameSettings.Vars.PlayerLoaded and PlayerFrameSettings.Vars.Enabled) then
		PlayerFrameSettings.Funcs.Info.Player();
		PlayerFrameTexture:SetTexture("Interface\\AddOns\\Hardcore\\Textures\\UI-TargetingFrame-DemonHunter.blp");
		PlayerFrameTexture:ClearAllPoints();
		for k,v in pairs(PlayerFrameSettings.Tables.Points.PlayerFrameTexture) do
			if (k == 1) then
				PlayerFrameTexture:SetPoint(v.Anchor, v.RelativeFrame, v.RelativeAnchor, v.OffsetX, v.OffsetY);
			else
				PlayerFrameTexture:SetPoint(v.Anchor, v.RelativeFrame, v.RelativeAnchor, (v.OffsetX + 24), (v.OffsetY - 28));
			end
		end
		PlayerFrameTexture:SetTexCoord(1, 0, 0, 1);
		PlayerFrameSettings.Funcs.Display.UpdateLevel();
		PlayerFrameSettings.Funcs.Display.UpdateRestIcon();
		if (PlayerFrame:IsClampedToScreen() == false or force) then
			PlayerFrame:SetClampedToScreen(true);
		end
	end
end
function PlayerFrameSettings.Funcs.Display.UpdatePlayerFrameLevel(level)
	if (PlayerFrameSettings.Vars.PlayerLoaded) then
		if (level) then
			PlayerFrameSettings.Funcs.FillLevelTextPointsTable(true);	-- Blizzard has updated the layout, so reset to new defaults
		end
		if (#PlayerFrameSettings.Tables.Points.PlayerLevelText >= 1) then
			PlayerLevelText:ClearAllPoints();
			if (PlayerFrameSettings_Vars.Mode == 7) then
				for k,v in pairs(PlayerFrameSettings.Tables.Points.PlayerLevelText) do
					PlayerLevelText:SetPoint(v.Anchor, v.RelativeFrame, v.RelativeAnchor, (v.OffsetX - 10), (v.OffsetY + 13.5));
				end
			end
		end
	end
end
function PlayerFrameSettings.Funcs.Display.UpdatePlayerFrameRestIcon()
	if (PlayerFrameSettings.Vars.PlayerLoaded) then
		for k,v in pairs(PlayerFrameSettings.Tables.Points.PlayerRestIcon) do
			if (k == 1) then
				PlayerRestIcon:SetPoint(v.Anchor, v.RelativeFrame, v.RelativeAnchor, (v.OffsetX + 1.5), v.OffsetY);
			end
		end
	end
end
