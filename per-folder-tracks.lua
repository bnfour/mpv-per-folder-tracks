--[[ If present, load and apply audio/sub tracks config from ./.mpv
    On hotkey, write current settings to the file,
    overwriting previous config, if any. ]]

-- configuration
hotkey = "y"
file_name = ".mpv"

-- settings definition
-- if changing, please note that spaces in these will break the very "sophisticated" parsing logic
audio_key = "AUDIO"
sub_key = "SUB"

function on_load(event)
    local f = io.open(file_name, "r")
    if f ~= nil then
        -- TODO read, apply
        f:close()
    end
    -- do nothing if file not found
end

-- store current audio and sub track indices to a file in the same folder
function on_keypress(event)
    local f = io.open(file_name, "w")
    f:write(string.format("%s %d\n", audio_key, get_audio_id()))
    f:write(string.format("%s %d\n", sub_key, get_sub_id()))
    f:close()
    mp.osd_message("Stored audio+sub track selection")
end

-- get_*_id return 0 instead of nil for disabled tracks
-- in order to keep the config file simplier by storing only ints as values
-- (is it really simplier though?)

function get_audio_id()
    local cur_audio_id = mp.get_property_number("current-tracks/audio/id")
    if cur_audio_id ~= nil
    then
        return cur_audio_id
    else
        return 0
    end
end

function get_sub_id()
    local cur_sub_id = mp.get_property_number("current-tracks/sub/id")
    if cur_sub_id ~= nil
    then
        return cur_sub_id
    else
        return 0
    end
end

mp.register_event("file-loaded", on_load)
mp.add_key_binding(hotkey, on_keypress)
