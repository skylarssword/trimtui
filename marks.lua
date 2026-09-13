-- vclip marks.lua
-- F1 = mark start, F2 = mark end, F3 = quit with marks
-- F-keys avoid conflicts with mpv built-in bindings

local marks_file = mp.get_opt("vclip-marks-file") or "/tmp/vclip_marks"
local start_time = nil
local end_time   = nil

local function fmt(secs)
    local h = math.floor(secs / 3600)
    local m = math.floor((secs % 3600) / 60)
    local s = math.floor(secs % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

local function save()
    local f = io.open(marks_file, "w")
    if not f then return end
    if start_time then f:write("START=" .. fmt(start_time) .. "\n") end
    if end_time   then f:write("END="   .. fmt(end_time)   .. "\n") end
    f:close()
end

local function osd(msg) mp.osd_message(msg, 2) end

mp.add_key_binding("F1", "vclip-start", function()
    start_time = mp.get_property_number("time-pos")
    if start_time then osd("[vclip] START: " .. fmt(start_time)); save() end
end)

mp.add_key_binding("F2", "vclip-end", function()
    end_time = mp.get_property_number("time-pos")
    if end_time then osd("[vclip] END: " .. fmt(end_time)); save() end
end)

mp.add_key_binding("F3", "vclip-quit", function()
    save()
    local ok = start_time and end_time
    osd(ok and "[vclip] Marks saved. Quitting..." or "[vclip] Missing a mark — quitting anyway.")
    mp.commandv("quit")
end)

mp.register_event("file-loaded", function()
    mp.osd_message("[vclip]  F1=start   F2=end   F3=quit", 5)
end)
