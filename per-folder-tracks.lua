--[[ If present, load and apply audio/sub tracks config from ./.mpv
    On hotkey, write current settings to the file,
    overwriting previous config, if any. ]]

-- configuration
file_name = ".mpv"
hotkey = "y"

function on_load(event)
    local f = io.open(file_name, "r")
    if f ~= nil then
        mp.osd_message("found, applying?")
        -- TODO read, apply
        f:close()
    end
    -- do nothing if file not found
end

function on_keypress(event)
    local f = io.open(file_name, "w")
    -- TODO actual audio/sub track ids/indices/whatever
    f:write("test message please ignore")
    f:close()
    mp.osd_message("(not yet) Stored current audio/sub tracks selection")
end

mp.register_event("file-loaded", on_load)
mp.add_key_binding(hotkey, on_keypress)
