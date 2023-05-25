-- ReloadReminder.lua
-- Reload reminder for the WOW Hardcore addon
-- Written by Frank de Jong

----- LOCAL VARIABLES ----------

local AceGUI = LibStub("AceGUI-3.0")

local rr_last_reload = 0                -- Last time of a reload (basically, last time since ReloadReminderInitiate())
local rr_last_warning = 0               -- Last time of an actually output warning
local rr_last_played_msg = 0            -- Last time of a PLAYED_TIME_MSG in Hardcore.lua
local rr_last_track_msg = 0             -- Last time of a tracked time ticker in Hardcore.lua
local rr_last_dung_msg = 0              -- Last time of a dungeon ticker in Hardcore.lua
local rr_frame

-- These variables correspond to the HC options
local rr_show_warning = true
local rr_set_interval = 0               -- 0 indicates automatic

-- Definitions
local RR_TIME_STEP = 1                  -- How often our timer is called
local RR_WARN_SUPPRESS = 60             -- How long to wait before another warning is output, to prevent spamming the user

local RR_LOST_VS_AUTO_INTERVAL = {
    { 3600, 3600 },         -- With less than 1 hour of lost time, warn every hour
    { 7200, 2700 },         -- With 1-2 hours of lost time, warn every 45m
    {10800, 1800 },         -- With 2-3 hours of lost time, warn every 30m
    {   -1,  900 }          -- All other cases: warn every 15m; this is crazy, really... You're reloading mroe than playing. But okay, this is just a warning
}

-- debug values
if false then
    RR_WARN_SUPPRESS = 10
    RR_LOST_VS_AUTO_INTERVAL = {
        { 3600, 30 },         -- With less than 1 hour of lost time, warn every hour
        { 7200, 20 },         -- With 1-2 hours of lost time, warn every 45m
        { 1800, 10 },         -- With 2-3 hours of lost time, warn every 30m
        {   -1, 5 }           -- All other cases: warn every 15m; this is crazy, really... You're reloading mroe than playing. But okay, this is just a warning
    }
end

----- LOCAL FUNCTIONS ----------

-- ReloadReminderGetInterval()
--
-- Returns the option-set interval or an automatically determined value from RR_LOST_VS_AUTO_INTERVAL if option-set is 0

local function ReloadReminderGetInterval( rr_lost_time )

    if rr_set_interval <= 0 then
        for _, v in ipairs( RR_LOST_VS_AUTO_INTERVAL ) do
            if v[1] == -1 then
                return v[2]             -- Last value in the array, always return this
            end
            if rr_lost_time <= v[1] then
                return v[2]
            end
        end
    end

    return rr_set_interval

end

local function ReloadReminderDoReload()

    Hardcore:Print("Attempting reload")    
    ReloadUI()
    Hardcore:Print("Reload failed")

end

local function ReloadReminderCleanup(widget)

    AceGUI:Release(widget) 
    rr_frame = nil
    rr_last_warning = GetServerTime()           -- Suppress warnings for maximum time from now

end

local function ReloadReminderCreateWindow()

    -- Create the window if it isn't simply hidden
    if rr_frame == nil then
        rr_frame = AceGUI:Create("Frame")
        rr_frame:SetTitle("Reload Reminder")
        rr_frame:SetStatusText("Reload when safe!")
        rr_frame:SetCallback("OnClose", function(widget) ReloadReminderCleanup(widget) end )
        rr_frame:SetLayout("Flow")
        rr_frame:SetWidth(300)
        rr_frame:SetHeight(125)

        local button = AceGUI:Create("Button")
        button:SetText("Reload now")
        button:SetWidth(250)
        button:SetCallback("OnClick", function() ReloadReminderDoReload() end)
        rr_frame:AddChild(button)
    end

    rr_frame:Show()

end



----- GLOBAL FUNCTIONS ----------


-- ReloadReminderPlayedTimeUpdate()
-- ReloadReminderTrackedTimeUpdate()
-- ReloadReminderDungeonTrackerUpdate()
--
-- Watchdog functions that track if the three vital tickers for tracked, played and dungeon tracking
-- are still operational

function ReloadReminderPlayedTimeUpdate()
    rr_last_played_msg = GetServerTime()
end

function ReloadReminderTrackedTimeUpdate()
    rr_last_track_msg = GetServerTime()
end

function ReloadReminderDungeonTrackerUpdate()
    rr_last_dung_msg = GetServerTime()
end



-- ReloadReminderCheck()
--
-- Timer function that gets called every second to check the conditions for
-- advising a reload are met and putting out the advice

function ReloadReminderCheck()

    local rr_warn_interval = 0              -- Automatic or option-set time between a reload and a warning

    if rr_show_warning == false then
        return
    end

    -- Check if in combat, suppress the warning if so
    if InCombatLockdown() == true then
        return
    end

    -- Do some fool proofing now so we don't have to keep doing that later
    if _G.Hardcore_Character == nil or _G.Hardcore_Character.time_played == nil or _G.Hardcore_Character.time_tracked == nil then
        return
    end

    -- Find out current time, so we can compare against the stored times
    local now = GetServerTime()

    -- Don't warn more often than once per minute
    if now - rr_last_warning < RR_WARN_SUPPRESS then
        return
    end

    -- Check if any of the tickers are falling behind; if so, warn immediately
    if (now - rr_last_played_msg > 180) or
       (now - rr_last_track_msg > 180) or
       (now - rr_last_dung_msg > 180) then
        Hardcore:Print( "Detected a missing heartbeat -- a /reload is advised!")
        rr_last_warning = now
        ReloadReminderCreateWindow()
        return
    end

    -- Determine what is a good time to advise a reload;
    -- First determine how much tracked time was lost already
    local rr_lost_time = _G.Hardcore_Character.time_played - _G.Hardcore_Character.time_tracked
    if rr_lost_time < 0 then
        rr_lost_time = 0
    end

    -- Now derive a good warning interval; 
    rr_warn_interval = ReloadReminderGetInterval(rr_lost_time)

    -- Now see if the interval has passed already
    if now - rr_last_reload > rr_warn_interval then
        -- Okay, let's output the warning
        Hardcore:Print( "Time for a /reload, interval = " .. rr_warn_interval)
        rr_last_warning = now
        ReloadReminderCreateWindow()
    end

end

-- ReloadReminderEnableWarning( should_show )
-- ReloadReminderSetInterval( interval )
--
-- Functions called to enable or disable the reload warning and set the interval

function ReloadReminderEnableWarning( should_show )
    rr_show_warning = should_show
    Hardcore:Debug( "Reload reminder warning show is now " .. (rr_show_warning and 'true' or 'false') )
end

function ReloadReminderSetInterval( interval )
    rr_set_interval = interval
    Hardcore:Debug( "Reload reminder warning interval is now " .. rr_set_interval )
end


-- ReloadReminderInitiate()
--
-- Function to set up the reload reminder subsystem
-- Called from Hardcore.lua as follows:

function ReloadReminderInitiate()

    -- Initiate our local variables
    local now = GetServerTime()
    rr_last_reload = now
    rr_last_warning = now
    rr_last_played_msg = now

    -- Copy over the global setting
    if _G.Hardcore_Settings ~= nil and _G.Hardcore_Settings.reload_reminder_show ~= nil then
        ReloadReminderEnableWarning( _G.Hardcore_Settings.reload_reminder_show )
    else
        ReloadReminderEnableWarning( true )
    end
    if _G.Hardcore_Settings ~= nil and _G.Hardcore_Settings.reload_reminder_interval ~= nil then
        ReloadReminderSetInterval( _G.Hardcore_Settings.reload_reminder_interval )
    else
        ReloadReminderSetInterval( 0 )
    end

    -- Start our timer
	C_Timer.NewTicker(RR_TIME_STEP, function()
		ReloadReminderCheck()
	end)

    -- Show the window when needed
    --ReloadReminderCreateWindow()

end

