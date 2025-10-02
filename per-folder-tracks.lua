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

-- tries to parse the configuration file:
-- if file does not exist, returns nil
-- else returns a table from every "[key][space][value]" pairs found in file
--   if a key is set more than once, returns last set value
local function parse_config()
    local file = io.open(file_name, "r")
    if file ~= nil then
        local parsed_keyvalues = {}
        local line = file:read("*line")
        while line do
            for k, v in string.gmatch(line, "(%S+)%s+(%S+)") do
                parsed_keyvalues[k] = v
            end
            line = file:read("*line")
        end
        file:close()
        return parsed_keyvalues
    else
        return nil
    end
end

-- silently does nothing if provided track is invalid
-- TODO: consider returning some kind of error code to be verified by the caller,
--   which may do something in that case (eg. showing error message on the OSD)
local function try_set_property(property, value, maximum)
    if property ~= nil and value ~= nil then
        -- prevents switching to tracks with numbers higher than available in the file
        -- because overshoots like this turn audio/subtitles off
        if value == "no" or tonumber(value) <= maximum then
            mp.set_property(property, value)
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
        try_set_property("aid", config[audio_key], available_tracks.audio)
        try_set_property("sid", config[sub_key], available_tracks.sub)
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
        mp.osd_message("Stored audio+sub track selection")
    else
        mp.osd_message("Error writing file!")
    end

end

mp.register_event("file-loaded", set_tracks_from_file)
mp.add_key_binding(hotkey, "store-current-tracks", store_current_tracks_to_file)
