--[[ If present, load and apply audio/sub tracks config from ./.mpv
    On hotkey, write current settings to the file,
    overwriting previous config, if any. ]]

-- just making sure this works
function on_load(event)
    mp.osd_message("file-loaded fired")
end

function on_keypress(event)
    mp.osd_message("keypress!")
end

mp.register_event("file-loaded", on_load)
mp.add_key_binding("y", on_keypress)
