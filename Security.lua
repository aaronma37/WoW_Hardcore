-- Security.lua
-- Simple data file security for the WOW Hardcore addon
-- Written by Frank de Jong

local tampered_status = false

local WARNING_MESSAGE = "CHANGES TO THIS FILE ARE MONITORED AND WILL LEAD TO IRREVOCABLE LOSS OF VERIFICATION STATUS!"

-- Hash function for the checksum
local function Hardcore_Checksum(data)
	local sum1 = 0
	local sum2 = 0
	for index=1,#data do
		sum1 = (sum1 + string.byte(string.sub(data,index,index))) % 255;
		sum2 = (sum2 + sum1) % 255;
	end
	return bit.bor(bit.lshift(sum2,8), sum1)
end

-- Calculate a checksum for the relevant data
local function Hardcore_CalculateChecksum()
	if Hardcore_Character ~= nil then
		local function GetRunString( run )
			local d = run.name .. run.date .. run.level .. run.id
			if run.iid ~= nil then
				d = d .. run.iid
			end
			if run.party ~= nil then
				d = d .. run.party
			end
			if run.num_kills ~= nil then
				d = d .. run.num_kills
			end
			if run.start ~= nil then
				d = d .. run.start
			end
			if run.last_seen ~= nil then
				d = d .. run.last_seen
			end
			if run.idle ~= nil then
				d = d .. run.idle
			end
			if run.bosses ~= nil then
				d = d .. #run.bosses
			end
			return d
		end

		local function GetAchievementsString( ach )
			local d = ""
			for _, v in ipairs(ach) do
				d = d .. v
			end
			return d
		end

		local hc = Hardcore_Character
		local data = #hc.deaths .. #hc.trade_partners .. #hc.bubble_hearth_incidents ..
				#hc.achievements .. #hc.passive_achievements ..
				hc.time_played .. hc.time_tracked

		-- Checksum for the logged, pending and current runs
		if hc.dt.runs ~= nil then
			for i, v in ipairs( hc.dt.runs ) do
				data = data .. GetRunString( v )
			end
		end
		if hc.dt.pending ~= nil then
			for i, v in ipairs( hc.dt.pending ) do
				data = data .. GetRunString( v )
			end
		end
		if hc.dt.current ~= nil and next( hc.dt.current ) then
			data = data .. GetRunString( hc.dt.current )
		end
		if hc.dt.repeated_runs ~= nil then
			data = data .. hc.dt.repeated_runs
		end
		if hc.dt.overleveled_runs ~= nil then
			data = data .. hc.dt.overleveled_runs
		end

		-- Add achievement names
		if hc.achievements ~= nil then
			data = data .. GetAchievementsString( hc.achievements )
		end
		if hc.passive_achievements ~= nil then
			data = data .. GetAchievementsString( hc.passive_achievements )
		end

		return Hardcore_Checksum( data )
	end
	return ""
end

-- Insert a warning in the data file and on the console
local function Hardcore_InsertModificationWarning()
	if WARNING == nil or WARNING == "" then
		WARNING = "-- " .. WARNING_MESSAGE .. " --"
		Hardcore_Character.checksum = 1
		Hardcore:Print( "Data file security mechanism engaged")
	end
end

-- Returns a string identifying the data file security status
function Hardcore_GetSecurityStatus()
	if tampered_status == true then
		return "TAMPERED"
	end
	if Hardcore_Character.checksum == nil then
		return "?"
	elseif Hardcore_Character.checksum >= 65536 then
		return "TAMPERED"
	else
		return "OK"
	end
end

-- Calculate and store the checksum to the file
function Hardcore_StoreChecksum()
	if Hardcore_Character ~= nil then
		if tampered_status == false then
			Hardcore_Character["checksum"] = Hardcore_CalculateChecksum()
		else
			Hardcore_Character["checksum"] = 65536 + ((Hardcore_Character.time_played * Hardcore_Character.time_tracked) % 34000)			-- This will trigger data integrity warning the next time
		end
	end
end

-- Do a check of the checksum
function Hardcore_VerifyChecksum()
	if WARNING == nil or WARNING == "" then 
		Hardcore_InsertModificationWarning()
	elseif Hardcore_Character ~= nil then
		local the_checksum = Hardcore_CalculateChecksum()
		local tampered = false
		if Hardcore_Character["checksum"] == nil then
			tampered = true
		elseif Hardcore_Character["checksum"] ~= the_checksum then
			tampered = true
		end
		if tampered == true then
			Hardcore:Print( "You have tampered with the data file -- your run is now invalid!")
			Hardcore:Print( "The Hardcore mods will be notified.")
			-- Make sure the warning is displayed again!
			WARNING = "-- " .. WARNING_MESSAGE .. " ---"
			tampered_status = true
		else
			Hardcore:Print( "Data file integrity okay")
		end
	end
end

-- Store the relevant verification data to the Hardcore_Character
-- This should not be called too soon after login, because then some variables aren't ready yet
function Hardcore_StoreCharacterInfo( level )

	if Hardcore_Character.char_info == nil then
		Hardcore_Character.char_info = {}
	end

	-- Check if we aren't running this too soon after 
	local class, race, name, realm
	local guid = UnitGUID("player")
	if guid ~= nil then
		_, class, _, race, _, name = GetPlayerInfoByGUID(UnitGUID("player"))
	end
	realm = GetRealmName()
	if guid == nil or class == nil or race == nil or name == nil or realm == nil then
		--Hardcore:Print( "GUID / name / race / realm = nil, postponing by one second")
		C_Timer.After(1, function()
			Hardcore_StoreCharacterInfo( level )
		end)
		return
	end
	Hardcore_Character.char_info.race = race
	Hardcore_Character.char_info.class = class
	Hardcore_Character.char_info.name = name
	Hardcore_Character.char_info.realm = realm
	Hardcore_Character.char_info.version = GetAddOnMetadata("Hardcore", "Version")
	if level == nil then
		Hardcore_Character.char_info.level = UnitLevel("player")
	else
		Hardcore_Character.char_info.level = level
	end

	-- Calculate the checksum, mix in the GUID to prevent copying this in from someone else
	local _ci = Hardcore_Character.char_info
	local data = _ci.version .. _ci.realm .. _ci.level .. _ci.race .. _ci.class .. _ci.name .. UnitGUID("player")
	Hardcore_Character.char_info.checksum = Hardcore_Checksum(data)

end


local function Hardcore_GoldTrackerChecksum()

	-- Fool proofing. If any of these variables don't exist, the checksum is invalid
	if Hardcore_Character.gt.time_stamp == nil or
		Hardcore_Character.gt.played == nil or
		Hardcore_Character.gt.amount == nil or
		Hardcore_Character.gt.track_start == nil or
		Hardcore_Character.gt.events == nil
	then
		return -1
	end

	local data = Hardcore_Character.gt.time_stamp .. Hardcore_Character.gt.amount .. Hardcore_Character.gt.played
	data = data .. Hardcore_Character.gt.track_start .. Hardcore_Character.guid

	-- Add the money difference events to the checksum
	for i,v in ipairs( Hardcore_Character.gt.events ) do
		data = data .. v.time_stamp_old .. v.time_stamp_new .. v.played_old .. v.played_new .. v.difference
	end

	-- Store the checksum
	return Hardcore_Checksum( data )

end

-- Hardcore_GoldTrackerCheck
--
-- Checks if there were changes in gold since the last logout

function Hardcore_GoldTrackerCheck()

	-- First time we are called, then there is nothing to do
	-- If the user just throws away all his gold tracker data, it will show in the track_start
	if Hardcore_Character.gt == nil then
		return
	end

	-- See if the GUID is available already. If not, postpone by a second and try again
	local guid = UnitGUID("player")
	if guid == nil then
		C_Timer.After(1, function()
			Hardcore_GoldTrackerCheck()
		end)
		return
	end

	-- Calculate the checksum, if we have all the data
	local checksum_calc = Hardcore_GoldTrackerChecksum()

	-- Now check if the checksum is still valid
	if checksum_calc ~= Hardcore_Character.gt.checksum then
		Hardcore:Print( "You have tampered with the data file -- your run is now invalid!")
		tampered_status = true
	end

	-- Now check if the gold amount has changed
	local difference = GetMoney() - Hardcore_Character.gt.amount
	if difference ~= 0 then
		MONEY_DIFF = {}
		MONEY_DIFF.time_stamp_old = Hardcore_Character.gt.time_stamp
		MONEY_DIFF.time_stamp_new = date("%m/%d/%y %H:%M:%S")
		MONEY_DIFF.played_old = Hardcore_Character.gt.played
		MONEY_DIFF.played_new = Hardcore_Character.time_played
		MONEY_DIFF.difference = difference
		table.insert( Hardcore_Character.gt.events, MONEY_DIFF )

		Hardcore:Print( "Detected that the amount of money on your character has changed since last logout")
		Hardcore:Print( "The Hardcore mods will be notified.")

		-- Now recalculate the checksum with the actual amount
		Hardcore_Character.gt.amount = GetMoney()
		Hardcore_Character.gt.checksum = Hardcore_GoldTrackerChecksum()
	end
end


-- Hardcore_GoldTrackerPlayerMoney 
--
-- Fired after the PLAYER_MONEY event. 
-- Stores the current gold to the data file

function Hardcore_GoldTrackerPlayerMoney()
	if Hardcore_Character ~= nil then
		local now = date("%m/%d/%y %H:%M:%S")
		if Hardcore_Character.gt == nil then
			Hardcore_Character.gt = {}
			Hardcore_Character.gt.events = {}
			Hardcore_Character.gt.track_start = now
		end
		Hardcore_Character.gt.time_stamp = now
		Hardcore_Character.gt.played = Hardcore_Character.time_played
		Hardcore_Character.gt.amount = GetMoney()
		Hardcore_Character.gt.checksum = Hardcore_GoldTrackerChecksum()
	end
end
