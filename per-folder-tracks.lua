--[[ If present, load and apply audio/sub tracks config from ./.mpv
    On hotkey, write current settings to the file,
    overwriting previous config, if any. ]]

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
        try_set_track(config, audio_key)
        try_set_track(config, sub_key)
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
function try_set_track(config_table, key)
    local property = get_mpv_property_name(key)
    if config_table[key] then
        mp.set_property(property, config_table[key])
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

mp.register_event("file-loaded", on_load)
mp.add_key_binding(hotkey, on_keypress)
