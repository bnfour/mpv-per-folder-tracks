--[[
    A script to automatically set audio and subtitles tracks on file load,
    if a configuration file is present in the folder with the video file.
    Also provides a hotkey to create the configuration file with currently selected tracks.

    See https://github.com/bnfour/mpv-per-folder-tracks

    bnfour, October--November 2022
]]

-- configuration
hotkey = "y"
file_name = ".mpv" -- relative path by default

-- settings definition
-- if changing, please note that spaces in these will break the very "sophisticated" parsing logic
audio_key = "AUDIO"
sub_key = "SUB"

-- load event handler: load and apply settings from file, if available
function on_load(event)
    local config = parse_config()
    if config ~= nil then
        local available_tracks = get_number_of_tracks()
        try_set_track(config, audio_key, available_tracks.audio)
        try_set_track(config, sub_key, available_tracks.sub)
    end
end

-- keypress event handler: store current audio and sub track indices to a configured file
-- overwrites existing file
function on_keypress(event)
    local f = io.open(file_name, "w")
    f:write(string.format("%s %s\n", audio_key, get_current_value(audio_key)))
    f:write(string.format("%s %s\n", sub_key, get_current_value(sub_key)))
    f:close()
    mp.osd_message("Stored audio+sub track selection")
end

-- gets the currently set value for a track of specified kind
-- returns "no" for disabled tracks, number (as seen in the UI) as a string
function get_current_value(config_key)
    return mp.get_property(get_mpv_property_name(config_key))
end

-- tries to parse the configuration file:
-- if file does not exist, returns nil
-- else returns a table from every "[key][space][value]" pairs found in file
--   if a key is set more than once, returns last set value
function parse_config()
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

-- silently fails if provided track is invalid
-- TODO: consider returning some kind of error code to be verified by the caller,
--   which may do something in that case (eg. showing error message on the OSD)
function try_set_track(config_table, key, tracks_present)
    local property = get_mpv_property_name(key)
    if config_table[key] then
        local value_to_set = config_table[key]
        -- prevents switching to tracks with numbers higher than available in the file
        -- because overshoots like this turn audio/subtitles off
        if value_to_set == "no" or tonumber(value_to_set) <= tracks_present then
            mp.set_property(property, value_to_set)
        end
    end
end

-- returns the mpv's property related to our configuration key:
-- "aid" for audio,
-- "sid" for subtitles (and anything else that is not audio configuration key)
function get_mpv_property_name(key)
    if key == audio_key then
        return "aid"
    else
        return "sid"
    end
end

-- returns number of audio and sub tracks present in the file
function get_number_of_tracks()
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

mp.register_event("file-loaded", on_load)
mp.add_key_binding(hotkey, on_keypress)
