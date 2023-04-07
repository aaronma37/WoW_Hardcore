_G["HardcoreBuildLabel"] = nil
local build_num = select(4, GetBuildInfo())
if build_num > 29999 then
	_G["HardcoreBuildLabel"] = "WotLK"
elseif build_num > 19999 then
	_G["HardcoreBuildLabel"] = "TBC"
else
	_G["HardcoreBuildLabel"] = "Classic"
end
function Hardcore_stringOrNumberToUnicode(val)
	local str
	if Hardcore_IsNumber(val) then
		str = tostring(val)
	else
		str = val
	end

	local unicode = ""
	for i = 1, #str do
		local char = str:sub(i, i)
		unicode = unicode
			.. string.byte(char)
			.. Hardcore_generateRandomString(Hardcore_generateRandomIntegerInRange(2, 3))
	end
	return unicode
end

function Hardcore_tableToUnicode(tbl)
	local unicode = ""
	for i, _ in ipairs(tbl) do
		for k, v in pairs(tbl[i]) do
			unicode = unicode .. Hardcore_stringOrNumberToUnicode(v) .. "%"
		end
		unicode = strsub(unicode, 0, #unicode - 1) .. "?"
	end
	return strsub(unicode, 0, #unicode - 1)
end

function Hardcore_generateRandomString(character_count)
	local str = ""
	for i = 1, character_count do
		str = str .. Hardcore_generateRandomLetter()
	end
	return str
end

function Hardcore_generateRandomLetter()
	local validLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
	local randomIndex = math.floor(math.random() * #validLetters)
	return validLetters:sub(randomIndex, randomIndex)
end

function Hardcore_generateRandomIntegerInRange(min, max)
	return math.floor(math.random() * (max - min + 1)) + min
end

function Hardcore_map(tbl, f)
	local t = {}
	for k, v in pairs(tbl) do
		t[k] = f(v)
	end
	return t
end

function Hardcore_join(tbl, separator)
	local str = ""
	for k, v in pairs(tbl) do
		if str == "" then
			str = v
		else
			str = str .. separator .. v
		end
	end
	return str
end

-- function borrowed from Questie
function Hardcore_GetAddonVersionInfo(version_string)
	local name = GetAddOnInfo("Hardcore")
	local version

	if version_string then
		version = version_string
	else
		version = GetAddOnMetadata(name, "Version")
	end

	local major, minor, patch = string.match(version, "(%d+)%p(%d+)%p(%d+)")
	local hash = "nil"

	local buildType

	return tonumber(major), tonumber(minor), tonumber(patch), tostring(hash), tostring(buildType)
end

local versionToValue = {}

function Hardcore_GetVersionParts(version_string)
	local cached = versionToValue[version_string]
	if cached then
		return cached.major, cached.minor, cached.patch
	end

	local major, minor, patch = string.match(version_string, "(%d+)%p(%d+)%p(%d+)")
	major = major or 0
	minor = minor or 0
	patch = patch or 0

	versionToValue[version_string] = {
		major = tonumber(major),
		minor = tonumber(minor),
		patch = tonumber(patch),
	}
	local thisVersionParts = versionToValue[version_string]

	return thisVersionParts.major, thisVersionParts.minor, thisVersionParts.patch
end

function Hardcore_GetGreaterVersion(version_stringA, version_stringB)
	local majorA, minorA, patchA = Hardcore_GetVersionParts(version_stringA)
	local majorB, minorB, patchB = Hardcore_GetVersionParts(version_stringB)

	-- Compare Majors
	if majorA > majorB then
		return version_stringA
	elseif majorA < majorB then
		return version_stringB
	else
		-- Compare Minors
		if minorA > minorB then
			return version_stringA
		elseif minorA < minorB then
			return version_stringB
		else
			-- Compare Patches
			if patchA > patchB then
				return version_stringA
			elseif patchA < patchB then
				return version_stringB
			else
				return version_stringA
			end
		end
	end
end

-- Useful for getting full player name
-- Same format as CHAT_MSG_ADDON
function Hardcore_GetPlayerPlusRealmName()
	local longName, serverName = UnitFullName("player")
	local FULL_PLAYER_NAME = longName .. "-" .. serverName

	return FULL_PLAYER_NAME
end

function Hardcore_IsNumber(val)
	return type(val) == "number"
end

function Hardcore_FilterUnique(tbl)
	local hash = {}
	local res = {}

	for _, v in ipairs(tbl) do
		if not hash[v] then
			res[#res + 1] = v
			hash[v] = true
		end
	end

	return res
end

function Hardcore_fletcher16(data)
	local sum1 = 0
	local sum2 = 0
	for index=1,#data do
		sum1 = (sum1 + string.byte(string.sub(data,index,index))) % 255;
		sum2 = (sum2 + sum1) % 255;
	end
	return bit.bor(bit.lshift(sum2,8), sum1)
end

local function encodeDataRecovery(_hardcore_character)
  local code = ""
  local str = tostring(_hardcore_character.time_tracked)
  for i = 1, #str do
      local c = str:sub(i,i)
      code = code .. string.char(tonumber(c+65))
  end
  code = code .. "@"
  if _hardcore_character.first_recorded ~= -1 then
    str = tostring(_hardcore_character.first_recorded)
    for i = 1, #str do
	local c = str:sub(i,i)
	code = code .. string.char(tonumber(c+65))
    end
  end

  code = code .. "@"
  for idx, k in ipairs(_hardcore_character.achievements) do
      code = code .. tostring(_G.a_id[k]) .. "&"
  end

  code = code .. "@"
  for idx, k in ipairs(_hardcore_character.passive_achievements) do
      code = code .. tostring(_G.pa_id[k]) .. "&"
  end

  return code
end

function Hardcore_GenerateRecoveryCode(_hardcore_character)
	  local player_name = UnitGUID("player")
	  local encoded = encodeDataRecovery(_hardcore_character)
	  return Hardcore_fletcher16(player_name .. encoded) .. "-" ..  encoded
end

function Hardcore_VerifyRecoveryCode(_hardcore_character, text)
  Hardcore_GenerateRecoveryCode(_hardcore_character)
  local player_name = UnitGUID("player")
  local checksum, data = strsplit("-", text, 2)
  if checksum == nil or data == nil then return end
  local received_checksum = tonumber(Hardcore_fletcher16(player_name .. data))
  if received_checksum == tonumber(checksum) then 
    local time_tracked_str, time_started_str, achievement_str, passive_achievements_str = strsplit("@", data)

    local time_tracked = ""
    for i = 1, #time_tracked_str do
	local c = time_tracked_str:sub(i,i)
	time_tracked = time_tracked .. tonumber(string.byte(c) - 65)
    end
    time_tracked = tonumber(time_tracked)

    local first_recorded = ""
    for i = 1, #time_started_str do
	local c = time_started_str:sub(i,i)
	first_recorded = first_recorded .. tonumber(string.byte(c) - 65)
    end

    local achievements = {}
    local achievements = {strsplit("&", tostring(achievement_str))}
    local achievement_list = {}
    for k,v in ipairs(achievements) do
      if v ~= nil and _G.id_a[v] then 
	table.insert(achievement_list, _G.id_a[v])
      end
    end

    local passive_achievements = {}
    local passive_achievements = {strsplit("&", tostring(passive_achievements_str))}
    local passive_achievement_list = {}
    for k,v in ipairs(passive_achievements) do
      if v ~= nil and _G.id_pa[v] then 
	table.insert(passive_achievement_list, _G.id_pa[v])
      end
    end
    return time_tracked, first_recorded, achievement_list, passive_achievement_list
  end
  return nil, nil, nil
end

function Hardcore_DecodeRecoveryCode(_hardcore_character)
  Hardcore_GenerateRecoveryCode(_hardcore_character)
  local player_name = UnitGUID("player")
  local checksum, data = strsplit("-", recovery_box:GetText(), 2)
  if checksum == nil or data == nil then return end
  local received_checksum = tonumber(Hardcore_fletcher16(player_name .. data))
  if received_checksum == tonumber(checksum) then 
    return true
  end
  return false
end
