--- Config
--
--Player frame settings
local PFU = _G.PlayerFrameSettings

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

function PLAYERFRAMEDROPDOWN_Init(self, level)
   local info = UIDropDownMenu_CreateInfo()
   local items = {{'blizzard', SetPlayerFrameDefault}, {'hardcore', SetPlayerFrameHardcore}, {'hardcore_animated', SetPlayerFrameHardcoreAnimated}};
   for k,v in pairs(items) do
      info = UIDropDownMenu_CreateInfo()
      info.text = v[1]
      info.value = v[1]
      info.func = v[2]
      UIDropDownMenu_AddButton(info, level)
   end
end

function SetPlayerFrameDefault()
	Hardcore_Settings.player_frame = "blizzard"
	_G["PLAYERFRAMEDROPDOWN".."Text"]:SetText("blizzard")
	PFU.Funcs.PlayerLoaded()
	PFU.Funcs.Display.UpdatePlayerFrame()
	PFU.Funcs.StartAnimating()
end
function SetPlayerFrameHardcore()
	Hardcore_Settings.player_frame = "hardcore"
	_G["PLAYERFRAMEDROPDOWN".."Text"]:SetText("hardcore")
	PFU.Funcs.PlayerLoaded()
	PFU.Funcs.Display.UpdatePlayerFrame()
	PFU.Funcs.StartAnimating()
end
function SetPlayerFrameHardcoreAnimated()
	Hardcore_Settings.player_frame = "hardcore_animated"
	_G["PLAYERFRAMEDROPDOWN".."Text"]:SetText("hardcore animated")
	PFU.Funcs.PlayerLoaded()
	PFU.Funcs.Display.UpdatePlayerFrame()
	PFU.Funcs.StartAnimating()
end

function TARGETFRAMEDROPDOWN_Init(self, level)
   local info = UIDropDownMenu_CreateInfo()
   local items = {{'blizzard', SetTargetFrameDefault}, {'hardcore', SetTargetFrameHardcore}, {'hardcore_animated', SetTargetFrameHardcoreAnimated}};
   for k,v in pairs(items) do
      info = UIDropDownMenu_CreateInfo()
      info.text = v[1]
      info.value = v[1]
      info.func = v[2]
      UIDropDownMenu_AddButton(info, level)
   end
end

function SetTargetFrameDefault()
	Hardcore_Settings.target_frame = "blizzard"
	_G["TARGETFRAMEDROPDOWN".."Text"]:SetText("blizzard")
end
function SetTargetFrameHardcore()
	Hardcore_Settings.target_frame = "hardcore"
	_G["TARGETFRAMEDROPDOWN".."Text"]:SetText("hardcore")
end
function SetTargetFrameHardcoreAnimated()
	Hardcore_Settings.target_frame = "hardcore_animated"
	_G["TARGETFRAMEDROPDOWN".."Text"]:SetText("hardcore animated")
end

function MINIMAPFRAMEDROPDOWN_Init(self, level)
   local info = UIDropDownMenu_CreateInfo()
   local items = {{'blizzard', SetMinimapFrameDefault}, {'hardcore', SetMinimapFrameHardcore}, {'hardcore_animated', SetMinimapFrameHardcoreAnimated}};
   for k,v in pairs(items) do
      info = UIDropDownMenu_CreateInfo()
      info.text = v[1]
      info.value = v[1]
      info.func = v[2]
      UIDropDownMenu_AddButton(info, level)
   end
end

function SetMinimapFrameDefault()
	Hardcore_Settings.minimap_frame = "blizzard"
	_G["MINIMAPFRAMEDROPDOWN".."Text"]:SetText("blizzard")
	PFU.Funcs.PlayerLoaded()
	PlayerFrameSettings.Funcs.Display.UpdateMinimapFrame()
end
function SetMinimapFrameHardcore()
	Hardcore_Settings.minimap_frame = "hardcore"
	_G["MINIMAPFRAMEDROPDOWN".."Text"]:SetText("hardcore")
	PFU.Funcs.PlayerLoaded()
	PlayerFrameSettings.Funcs.Display.UpdateMinimapFrame()
end
function SetMinimapFrameHardcoreAnimated()
	_G["MINIMAPFRAMEDROPDOWN".."Text"]:SetText("hardcore animated")
	PFU.Funcs.PlayerLoaded()
	PlayerFrameSettings.Funcs.Display.UpdateMinimapFrame()
end

function PETFRAMEDROPDOWN_Init(self, level)
   local info = UIDropDownMenu_CreateInfo()
   local items = {{'blizzard', SetPetFrameDefault}, {'hardcore', SetPetFrameHardcore}, {'hardcore_animated', SetPetFrameHardcoreAnimated}};
   for k,v in pairs(items) do
      info = UIDropDownMenu_CreateInfo()
      info.text = v[1]
      info.value = v[1]
      info.func = v[2]
      UIDropDownMenu_AddButton(info, level)
   end
end

function SetPetFrameDefault()
	Hardcore_Settings.pet_frame = "blizzard"
	_G["PETFRAMEDROPDOWN".."Text"]:SetText("blizzard")
	PFU.Funcs.PlayerLoaded()
	PlayerFrameSettings.Funcs.Display.UpdatePetFrame()
end
function SetPetFrameHardcore()
	Hardcore_Settings.pet_frame = "hardcore"
	_G["PETFRAMEDROPDOWN".."Text"]:SetText("hardcore")
	PFU.Funcs.PlayerLoaded()
	PlayerFrameSettings.Funcs.Display.UpdatePetFrame()
end
function SetPetFrameHardcoreAnimated()
	Hardcore_Settings.pet_frame = "hardcore_animated"
	_G["PETFRAMEDROPDOWN".."Text"]:SetText("hardcore animated")
	PFU.Funcs.PlayerLoaded()
	PlayerFrameSettings.Funcs.Display.UpdatePetFrame()
end

function TARGETTOTFRAMEDROPDOWN_Init(self, level)
   local info = UIDropDownMenu_CreateInfo()
   local items = {{'blizzard', SetTargetToTFrameDefault}, {'hardcore', SetTargetToTFrameHardcore}, {'hardcore_animated', SetTargetToTFrameHardcoreAnimated}};
   for k,v in pairs(items) do
      info = UIDropDownMenu_CreateInfo()
      info.text = v[1]
      info.value = v[1]
      info.func = v[2]
      UIDropDownMenu_AddButton(info, level)
   end
end

function SetTargetToTFrameDefault()
	Hardcore_Settings.targetToT_frame = "blizzard"
	_G["TARGETTOTFRAMEDROPDOWN".."Text"]:SetText("blizzard")
	PFU.Funcs.PlayerLoaded()
	PlayerFrameSettings.Funcs.Display.UpdateTargetToTFrame()
end
function SetTargetToTFrameHardcore()
	Hardcore_Settings.targetToT_frame = "hardcore"
	_G["TARGETTOTFRAMEDROPDOWN".."Text"]:SetText("hardcore")
	PFU.Funcs.PlayerLoaded()
	PlayerFrameSettings.Funcs.Display.UpdateTargetToTFrame()
end
function SetTargetToTFrameHardcoreAnimated()
	Hardcore_Settings.targetToT_frame = "hardcore_animated"
	_G["TARGETTOTFRAMEDROPDOWN".."Text"]:SetText("hardcore animated")
	PFU.Funcs.PlayerLoaded()
	PlayerFrameSettings.Funcs.Display.UpdateTargetToTFrame()
end


function PARTYFRAMEFRAMEDROPDOWN_Init(self, level)
   local info = UIDropDownMenu_CreateInfo()
   local items = {{'blizzard', SetPartyFrameDefault}, {'hardcore', SetPartyFrameHardcore}, {'hardcore_animated', SetPartyFrameHardcoreAnimated}};
   for k,v in pairs(items) do
      info = UIDropDownMenu_CreateInfo()
      info.text = v[1]
      info.value = v[1]
      info.func = v[2]
      UIDropDownMenu_AddButton(info, level)
   end
end

function SetPartyFrameDefault()
	Hardcore_Settings.party_frame = "blizzard"
	_G["PARTYFRAMEFRAMEDROPDOWN".."Text"]:SetText("blizzard")
	PFU.Funcs.PlayerLoaded()
	PlayerFrameSettings.Funcs.Display.UpdatePartyFrame()
end
function SetPartyFrameHardcore()
	Hardcore_Settings.party_frame = "hardcore"
	_G["PARTYFRAMEFRAMEDROPDOWN".."Text"]:SetText("hardcore")
	PFU.Funcs.PlayerLoaded()
	PlayerFrameSettings.Funcs.Display.UpdatePartyFrame()
end
function SetPartyFrameHardcoreAnimated()
	Hardcore_Settings.party_frame = "hardcore_animated"
	_G["PARTYFRAMEFRAMEDROPDOWN".."Text"]:SetText("hardcore animated")
	PFU.Funcs.PlayerLoaded()
	PlayerFrameSettings.Funcs.Display.UpdatePartyFrame()
end


--- EndConfig


