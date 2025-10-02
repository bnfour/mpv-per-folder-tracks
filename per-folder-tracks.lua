--[[
    A script to automatically set audio and subtitles tracks on file load,
    if a configuration file is present in the folder with the video file.
    Also provides a hotkey to create the configuration file with currently selected tracks.

    See https://github.com/bnfour/mpv-per-folder-tracks
    Available under the terms of the MIT license.

    bnfour, October–November 2022, October 2025
]]

-- configuration

local hotkey = "y" -- can also be overridden via mpv's own keybind settings
local file_name = ".mpv" -- relative path by default

-- settings definition
-- if changing, please note that spaces in these will break the very "sophisticated" parsing logic

local audio_key = "AUDIO"
local sub_key = "SUB"

local script_name = mp.get_script_name()

-- tries to parse the configuration file:
-- if file does not exist, returns nil
-- else returns a table from every "[key][space][value]" pairs found in file
--   if a key is set more than once, returns last set value
local function parse_config()
    local file = io.open(file_name, "r")
    if file ~= nil then
        local parsed = {}
        local line = file:read("*line")
        while line do
            for k, v in string.gmatch(line, "(%S+)%s+(%S+)") do
                parsed[k] = v
            end
            line = file:read("*line")
        end
        file:close()
        return parsed
    else
        return nil
    end
end

-- returns false if provided string value cannot be parsed as a number
-- maximum is assumed to be a number
local function is_number_less_or_equal_than(value, maximum)
    local n = tonumber(value)
    if n ~= nil then
        return n <= maximum
    else
        return false
    end
end

-- silently does nothing if provided track is invalid
-- returns a boolean: false if unable to set the value (format or track count issues),
-- true if everything went ok, even if the function did not change the track id
local function try_set_property(property, value, maximum)
    if property ~= nil and value ~= nil then
        -- do nothing successfully if the property already has the value to set
        if mp.get_property(property) == value
        then
            return true
        end
        -- if the value to set seems legit, set the property
        if value == "no" or is_number_less_or_equal_than(value, maximum) then
            mp.set_property(property, value)
            return true
        -- or skip it and warn the user
        else
            require 'mp.msg'.warn("Skipping", property, "value", value, "(there are", maximum, "total tracks in the file, not a number or others in the folder have more?)")
            return false
        end
    end
end

-- returns number of audio and sub tracks present in the file
local function get_number_of_tracks()
    local result = { audio = 0, sub = 0 }
    local tracks_count = tonumber(mp.get_property("track-list/count"))
    for i = 0, tracks_count - 1 do
        local kind = mp.get_property("track-list/" .. i .. "/type")
        if kind == "audio" then
            result.audio = result.audio + 1
        elseif kind == "sub" then
            result.sub = result.sub + 1
        end
    end
    return result
end

-- load event handler: load and apply settings from file, if available
local function set_tracks_from_file(_)
    local config = parse_config()
    if config ~= nil then
        local available_tracks = get_number_of_tracks()
        local audio_ok = try_set_property("aid", config[audio_key], available_tracks.audio)
        local subs_ok = try_set_property("sid", config[sub_key], available_tracks.sub)
        if not (audio_ok and subs_ok) then
            mp.osd_message(string.format("[%s] Error setting track(s), check the console for details", script_name))
        end
    end
end

-- keypress event handler: store current audio and sub track indices to a configured file
-- overwrites existing file
local function store_current_tracks_to_file(_)
    local f = io.open(file_name, "w")
    if f ~= nil then
        f:write(string.format("%s %s\n", audio_key, mp.get_property("aid")))
        f:write(string.format("%s %s\n", sub_key, mp.get_property("sid")))
        f:close()
        mp.osd_message(string.format("[%s] Stored audio+sub track selection", script_name))
    else
        mp.osd_message(string.format("[%s] Error writing file", script_name))
    end

end

mp.register_event("file-loaded", set_tracks_from_file)
mp.add_key_binding(hotkey, "store-current-tracks", store_current_tracks_to_file)
