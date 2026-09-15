-- trimtui marks.lua
-- F1 = mark start, F2 = mark end, F3 = save & quit
-- F-keys avoid conflicts with mpv built-in bindings

local marks_file = mp.get_opt("trimtui-marks-file") or "/tmp/trimtui_marks"
local start_time = nil
local end_time   = nil

local function fmt(secs)
    if secs < 0 then secs = 0 end
    local h = math.floor(secs / 3600)
    local m = math.floor((secs % 3600) / 60)
    local s = math.floor(secs % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

local function save()
    local f, err = io.open(marks_file, "w")
    if not f then
        mp.osd_message("[trimtui] Could not write marks file: " .. tostring(err), 4)
        return false
    end
    if start_time then f:write("START=" .. fmt(start_time) .. "\n") end
    if end_time   then f:write("END="   .. fmt(end_time)   .. "\n") end
    f:close()
    return true
end

local function osd(msg) mp.osd_message(msg, 2) end

-- Warns rather than silently writing a backwards range the shell will reject.
local function check_order()
    if start_time and end_time and end_time <= start_time then
        osd("[trimtui] Warning: end is not after start")
    end
end

mp.add_key_binding("F1", "trimtui-start", function()
    local t = mp.get_property_number("time-pos")
    if not t then return end
    start_time = t
    osd("[trimtui] START: " .. fmt(start_time))
    check_order()
    save()
end)

mp.add_key_binding("F2", "trimtui-end", function()
    local t = mp.get_property_number("time-pos")
    if not t then return end
    end_time = t
    osd("[trimtui] END: " .. fmt(end_time))
    check_order()
    save()
end)

mp.add_key_binding("F3", "trimtui-quit", function()
    save()
    local ok = start_time and end_time and end_time > start_time
    osd(ok and "[trimtui] Marks saved. Quitting..."
           or  "[trimtui] Marks incomplete — quitting anyway.")
    mp.commandv("quit")
end)

-- Also save on a normal quit (q), so marks aren't lost.
mp.register_event("shutdown", function()
    save()
end)

mp.register_event("file-loaded", function()
    mp.osd_message("[trimtui]  F1=start   F2=end   F3=save & quit", 5)
end)
