local render_circle, render_push_clip_rect, render_circle_outline, render_world_to_screen, rage_exploit, ui_get_binds, ui_get_alpha, entity_get_players, entity_get, entity_get_entities, entity_get_game_rules, common_set_clan_tag, common_is_button_down, common_get_username, common_get_date, ffi_cast, ffi_typeof, render_gradient, render_text, render_texture, render_rect_outline, render_rect, entity_get_local_player, ui_create, ui_get_style, ui_get_icon, math_floor, math_abs, math_max, math_ceil, math_min, math_random, utils_trace_bullet, render_screen_size, render_load_font, render_load_image_from_file, render_measure_text, render_poly, render_poly_blur, common_add_notify, common_add_event, utils_console_exec, utils_execute_after, utils_create_interface, utils_trace_line, ui_find, entity_get_threat, string_format, utils_get_vfunc, utils_opcode_scan, ui_get_mouse_position, ui_sidebar, render_line, utils_net_channel, render_shadow, render_camera_angles = render.circle, render.circle_outline, render.push_clip_rect, render.world_to_screen, rage.exploit, ui.get_binds, ui.get_alpha, entity.get_players, entity.get, entity.get_entities, entity.get_game_rules, common.set_clan_tag, common.is_button_down, common.get_username, common.get_date, ffi.cast, ffi.typeof, render.gradient, render.text, render.texture, render.rect_outline, render.rect, entity.get_local_player, ui.create, ui.get_style, ui.get_icon, math.floor, math.abs, math.max, math.ceil, math.min, math.random, utils.trace_bullet, render.screen_size, render.load_font, render.load_image_from_file, render.measure_text, render.poly, render.poly_blur, common.add_notify, common.add_event, utils.console_exec, utils.execute_after, utils.create_interface, utils.trace_line, ui.find, entity.get_threat, string.format, utils.get_vfunc, utils.opcode_scan, ui.get_mouse_position, ui.sidebar, render.line, utils.net_channel, render.shadow, render.camera_angles

local clipboard = require 'neverlose/clipboard'
local inspect = require 'neverlose/inspect'
local smoothy = require 'neverlose/smoothy'
local base64 = require 'neverlose/base64'
local cron = require 'neverlose/cron'
local md5 = require 'neverlose/md5'; local md5_encyption = 'removed'

local lerpVector = function(a, b, t)
    local x,y,z = a.x, a.y, a.z
    local sx,sy,sz = b.x,b.y,b.z

    return vector(
        x + (sx - x) * t,
        y + (sy - y) * t,
        z + (sz - z) * t
    )
end

local fucking_configs do
    local pc_data = files.read('configs_data.json')

    local success, data = pcall(function()
        return json.parse(pc_data)
    end)

    fucking_configs = success and data or {}
end

local http_lib = require 'neverlose/http_lib'
local http = http_lib.new({
    task_interval = 0.4,
    enable_debug = false,
    timeout = 5
})

function table.copy(t)
    local u = { }
    for k, v in pairs(t) do u[k] = v end
    return setmetatable(u, getmetatable(t))
end

local function sort_and_concat(tbl)
    local keys = {}
    for k in pairs(tbl) do
    keys[#keys + 1] = k
    end
    table.sort(keys)

    local result = ""
    for i, k in ipairs(keys) do
        local k = tostring(k)
        local j = tostring(tbl[k])

        result = result..k..j
    end

    return result
end

local json_stringify = function(tbl)
    local signature = sort_and_concat(tbl) .. md5_encyption

    if not tbl.signature then
        tbl['signature'] = md5.sumhexa(signature)
    end

    return json.stringify(tbl)
end

local fnv1a do
    fnv1a = {}

    local string_len  = string.len
    local bit_bxor    = bit.bxor
    local string_byte  = string.byte
    local bit_lshift  = bit.lshift

    local hash = 0x811c9dc5

    function fnv1a.hash(str)
        local length = string_len(str)
        for i = 1, length do
            hash = bit_bxor(hash, string_byte(str, i))
            hash = hash
            + bit_lshift(hash, 1)
            + bit_lshift(hash, 4)
            + bit_lshift(hash, 7)
            + bit_lshift(hash, 8)
            + bit_lshift(hash, 24)
        end
        return hash % 0x100000000, length
    end
end

ffi.cdef[[
    typedef void*(__thiscall* get_client_entity_t)(void*, int);

    typedef int BOOL;
    typedef long LONG;
    bool DeleteUrlCacheEntryA(const char* lpszUrlName);
    int AddFontResourceA(const char* unnamedParam1);
    void* __stdcall URLDownloadToFileA(void* LPUNKNOWN, const char* LPCSTR, const char* LPCSTR2, int a, int LPBINDSTATUSCALLBACK);
    void* __stdcall ShellExecuteA(void* hwnd, const char* op, const char* file, const char* params, const char* dir, int show_cmd);
]]

local FileVerifier do
    --main references
    local TotalEntries = 0

    local PATH = 'nl/Envious/'

    local urlmon = ffi.load 'UrlMon'
    local wininet = ffi.load 'WinInet'
    local gdi = ffi.load 'Gdi32'

    local Download = function(from, to)
        TotalEntries = TotalEntries + 1

        files.create_folder(PATH)
        --print_raw('Requested ' .. to)
        wininet.DeleteUrlCacheEntryA(from)
        urlmon.URLDownloadToFileA(nil, from, to, 0,0)
    end

    files.create_folder('nl/Envious')
    files.create_folder('csgo/sound')
    files.create_folder('csgo/sound/ym_announcer')
    files.create_folder('csgo/sound/ym_announcer/img')

    local dll = files.read('platform/sys.dll') or Download('https://cdn.discordapp.com/attachments/861338814739906580/1071175799216025720/discord-rpc.dll', 'platform/sys.dll')
    local font = files.read(PATH .. 'sans300.ttf') or Download('https://cdn.discordapp.com/attachments/999448004257923102/1049038708986351776/sans300.ttf', PATH..'sans300.ttf')
    local font2 = files.read(PATH .. 'sans500.ttf') or Download('https://cdn.discordapp.com/attachments/999448004257923102/1049038709275775036/sans500.ttf', PATH..'sans500.ttf')
    local font3 = files.read(PATH .. 'sans700.ttf') or Download('https://cdn.discordapp.com/attachments/999448004257923102/1049038709560967288/sans700.ttf', PATH..'sans700.ttf')
    local png = files.read(PATH .. 'wave.png') or Download('https://cdn.discordapp.com/attachments/999448004257923102/1049038709862961162/wave.png', PATH..'wave.png')


    --other references
    local PATH = 'csgo/sound/ym_announcer/'

    local snd = files.read(PATH .. 'hs.wav') or Download('https://cdn.discordapp.com/attachments/999448004257923102/1049046716600557579/hs.wav', PATH..'hs.wav')
    local snd2 = files.read(PATH .. '1.wav') or Download('https://cdn.discordapp.com/attachments/999448004257923102/1049046714092376064/1.wav', PATH..'1.wav')
    local snd3 = files.read(PATH .. '2.wav') or Download('https://cdn.discordapp.com/attachments/999448004257923102/1049046714406928404/2.wav', PATH..'2.wav')
    local snd4 = files.read(PATH .. '3.wav') or Download('https://cdn.discordapp.com/attachments/999448004257923102/1049046714683760720/3.wav', PATH..'3.wav')
    local snd5 = files.read(PATH .. '4.wav') or Download('https://cdn.discordapp.com/attachments/999448004257923102/1049046715015122964/4.wav', PATH..'4.wav')
    local snd6 = files.read(PATH .. '5.wav') or Download('https://cdn.discordapp.com/attachments/999448004257923102/1049046715325481020/5.wav', PATH..'5.wav')
    local snd7 = files.read(PATH .. '6.wav') or Download('https://cdn.discordapp.com/attachments/999448004257923102/1049046715577147452/6.wav', PATH..'6.wav')
    local snd8 = files.read(PATH .. 'enemy_body_hit.wav') or Download('https://cdn.discordapp.com/attachments/999448004257923102/1049046715958841414/enemy_body_hit.wav', PATH..'enemy_body_hit.wav')
    local snd9 = files.read(PATH .. 'enemy_death.wav') or Download('https://cdn.discordapp.com/attachments/999448004257923102/1049046716290170901/enemy_death.wav', PATH..'enemy_death.wav')
    local snd10 = files.read(PATH .. 'player_death.wav') or Download('https://cdn.discordapp.com/attachments/999448004257923102/1049046716957085806/player_death.wav', PATH..'player_death.wav')

    if TotalEntries > 0 then
        common_add_notify('Envious.lua', 'Successully downloaded '..TotalEntries..' entries..')
    end
end

local function get_type(value)
    if type(getmetatable(value)) == 'table' and value.__type then
        return value.__type.name:lower()
    end

    if type(value) == 'boolean' then
        value = value and 1 or 0
    end

    return type(value)
end

local function has_nightly()
    local ref = ui_find("Miscellaneous", "Main", "Other", "Log Events")
    local list = ref:list()

    for i=1, #list do
        if list[i] == 'Aimbot Shots' then
            return true
        end
    end

    return
end

local function ui_handle(ref, var)
    if get_type(var) == 'table' then
        for n,v in pairs(var) do
            v:visibility(
                get_type(ref) == 'function' and ref:get() or ref
            )
        end
    else
        var:visibility(
            get_type(ref) == 'function' and ref:get() or ref
        )
    end
end

local function table_unhash(x)
    assert(get_type(x) == 'table', 'bad parameter #1: must be table')

    local mt = {}
    local keys, indxs, all = 0, 0, 0

    for k, v in pairs(x) do
      if (type(k) == 'number') and (k == math.floor(k)) then indxs = indxs + 1
      else keys = keys + 1 end

      all = all + 1
    end

    mt.__newindex = function(t, k, v)
      if (type(k) == 'number') and (k == math.floor(k)) then indxs = indxs + 1
      else keys = keys + 1 end

      all = all + 1
      t[k] = v
    end

    mt.__index = function(t, k)
      if k == 'keyCount' then return keys
      elseif k == 'indexCount' then return indxs
      elseif k == 'totalCount' then return all end
    end

    return setmetatable(x, mt)
end

local dragging_fn = function()
    local system = {}

    local screen_size = render_screen_size()

    system.list = {}
    system.windows = {}

    system.__index = system
    system.register = function(position, size, global_name, ins_function)
        local data = {
            size = size,
            position = vector(position[1]:get(), position[2]:get()),

            is_dragging = false,
            drag_position = vector(),

            global_name = global_name,
            ins_function = ins_function,

            ui_callbacks = {x = position[1], y = position[2]}
        }

        events.createmove:set(function(c)
            if data.is_dragging then
                c.in_attack = 0
            end
        end)

        table.insert(system.windows, data)
        system.mt_data = setmetatable(data, system)

        return system.mt_data
    end

    function system:limit_positions()
        if self.position.x <= 0 then
            self.position.x = 0
        end

        if self.position.x + self.size.x >= screen_size.x - 1 then
            self.position.x = screen_size.x - self.size.x - 1
        end

        if self.position.y <= 0 then
            self.position.y = 0
        end

        if self.position.y + self.size.y >= screen_size.y - 1 then
            self.position.y = screen_size.y - self.size.y - 1
        end
    end

    function system:is_in_area(mouse_position)
        return mouse_position.x >= self.position.x and mouse_position.x <= self.position.x + self.size.x and mouse_position.y >= self.position.y and mouse_position.y <= self.position.y + self.size.y
    end

    function system:update(should_magnitize, ...)
        local is_menu_visible = ui_get_alpha() == 1

        if is_menu_visible then

            local x,y = render_screen_size().x, render_screen_size().y

            local mouse_position = ui_get_mouse_position()
            local is_in_area = self:is_in_area(mouse_position)

            local list = system.list
            local is_key_pressed = common.is_button_down(0x1)

            list.in_drag_area = is_in_area

            if (is_in_area or self.is_dragging) and is_key_pressed and (list.target == "" or list.target == self.global_name) then
                is_dragging = true
                list.target = self.global_name

                if not self.is_dragging then
                    self.is_dragging = true
                    self.drag_position = mouse_position - self.position
                else
                    self.position = mouse_position - self.drag_position

                    if should_magnitize and self.position.x + self.size.x > x/2 and self.position.x < x/2 then
                        self.position = vector(x/2 - self.size.x/2 , self.position.y)
                    end

                    if should_magnitize and self.position.y + self.size.y > y/2 and self.position.y < y/2 then
                        self.position = vector(self.position.x, y/2 - self.size.y/2)
                    end

                    self:limit_positions()

                    self.ui_callbacks.x:set(math.floor(self.position.x))
                    self.ui_callbacks.y:set(math.floor(self.position.y))
                end
            elseif not is_key_pressed then
                list.target = ""
                self.is_dragging = false
                self.drag_position = vector()
            end
        end

        self.ins_function(self, ...)
    end

    --@on_config_load
    for _, point in pairs(system.windows) do
        point.position = vector(point.ui_callbacks.x:get(), point.ui_callbacks.y:get())
    end

    return system
end

local buffer = {}

local render_indicator = function(color, name)
    for i=1, #buffer do
        if buffer[i].name == name then
            return
        end
    end

    table.insert(buffer, {
        name = name,
        color = color
    })
end

local ctx = new_class()
    :struct 'cheat' {
        active_this_frame = {res = false, idx = 0},
        screen_size = render_screen_size(),
        lua = 'Envious',
        build = has_nightly and 'Nightly' or 'Release',
        username = common_get_username(),
    }

    :struct 'tools' {
        split = function(Text, Separator)
            local Table = {  }
            for String in string.gmatch(Text, "([^" .. Separator .. "]+)") do
                Table[#Table + 1] = String
            end
            return Table
        end,
        delayed_msg = function(delay, msg)
            return utils_execute_after(delay, function() utils_console_exec('say ' .. msg) end)
        end,
        warn = function()
            return '\aE0C152FF\xef\x81\xb1\aDEFAULT'
        end,
        get_delta = function(delay)
            local clamp = function(b,c,d)local e=b;e=e<c and c or e;e=e>d and d or e;return e end
        curtime = globals.curtime
        if curtime - last_update > delay then
            fake_stren = math_floor(clamp(math_abs(math_ceil(rage.antiaim:get_rotation(true) - rage.antiaim:get_rotation())), 0, 30))
            last_update = curtime
        end
        return fake_stren
        end,
        clamp = function(b,c,d)local e=b;e=e<c and c or e;e=e>d and d or e;return e end,

        gradient_text = function(r1, g1, b1, a1, r2, g2, b2, a2, text)
        local output = ''
        local len = #text-1
        local rinc = (r2 - r1) / len
        local ginc = (g2 - g1) / len
        local binc = (b2 - b1) / len
        local ainc = (a2 - a1) / len
        for i=1, len+1 do
            output = output .. ('\a%02x%02x%02x%02x%s'):format(r1, g1, b1, a1, text:sub(i, i))
            r1 = r1 + rinc
            g1 = g1 + ginc
            b1 = b1 + binc
            a1 = a1 + ainc
        end

        return output
        end,
        native_GetAttachment = utils_get_vfunc(84, 'bool(__thiscall*)(void*, int, void*)'),
        native_GetAttachmentIDX_1stperson = utils_get_vfunc(468, 'int(__thiscall*)(void*, void*)'),
        native_GetAttachmentIDX_3rdperson = utils_get_vfunc(469, 'int(__thiscall*)(void*)'),
        native_ShouldDrawViewmodel = utils_get_vfunc(27, 'bool(__thiscall*)(void*)'),

        get_muzzle_attachment = function(self, player, ret_wmodel)
            if player == nil then
                return
            end

            local weapon = player:get_player_weapon()

            if weapon == nil then
                return
            end

            local weapon_info = weapon:get_weapon_info()
            local model = ret_wmodel == true and
                weapon.m_hWeaponWorldModel or
                player.m_hViewModel[0]

            if model == nil or (not ret_wmodel and weapon_info.weapon_type == 0) then
                return
            end

            local position = ffi.new 'float[4]'
            local att_index = ret_wmodel and
                self.native_GetAttachmentIDX_3rdperson(weapon[0]) or
                self.native_GetAttachmentIDX_1stperson(weapon[0], model[0])

            if att_index > 0 and self.native_GetAttachment(model[0], att_index, position) then
                return vector(position[0], position[1], position[2])
            end
        end,
        contains = function(table, value)
            if table == nil or value == nil then
                error('There was an error while gettin the value')
                return
            end

            for k,v in pairs(table) do
                if v == value then
                    return true
                end
            end

            --return false
        end,
        set_gear = function(group, element, icon)
            local a = group:switch(element, false)
            local b = a:create()

            if icon ~= nil then
                a:name(
                    string_format('%s  %s', ui_get_icon(icon), a:name())
                )
            end

            return {a,b}
        end,
        set_icon = function(icon, name)
            return string_format('%s  %s', ui_get_icon(icon), name)
        end,
        extrapolate = function(ent , origin , ticks , air)
            local sv_gravity = cvar.sv_gravity:float() * globals.tickinterval*0.5
            local sv_jump_impulse = cvar.sv_jump_impulse:float() * globals.tickinterval*0.5
            local sv_air_acc = cvar.sv_airaccelerate:float()

            local velocity = vector(ent["m_vecVelocity[0]"], ent["m_vecVelocity[1]"], ent["m_vecVelocity[2]"])
            local extrapolated = origin

            local is_in_air = (bit.band(ent["m_fFlags"] , 1 ) == 0) and 1 or 0
            local up_velmod = velocity.z  + sv_jump_impulse*ticks*globals.tickinterval*is_in_air

            extrapolated = vector(origin.x + velocity.x*globals.tickinterval*ticks,origin.y + velocity.y*globals.tickinterval*ticks,origin.z + up_velmod*ticks*globals.tickinterval*air)
            return extrapolated

        end,
        dev_print = function(txt)
            print_dev(txt)
            print_raw("\a96B9FFEnvious\a5A5A5A >> \aF0F0F0" .. txt)
        end,
        play_sound = function(name , volume)
            local IEngineSoundClient = ffi_cast("void***" , utils_create_interface("engine.dll", "IEngineSoundClient003")) or error("Failed to find IEngineSoundClient003!")
            local play_sound_fn = ffi_cast("void(__thiscall*)(void*, const char*, float, int, int, float)",IEngineSoundClient[0][12])

            return play_sound_fn( IEngineSoundClient, name , volume , 100 ,0,0)
        end,
        get_userdata_list = function(item)
            local tbl = {  }

            for k,v in pairs(item:get()) do
                if v == nil then goto skip end
                table.insert(tbl, v:lower())
                ::skip::
            end

            return tbl
        end,
        get_velocity = function(zxc, player)
            if player == nil then
                return
            end

            local vel = player["m_vecVelocity"]
            if vel.x == nil then return end
            return math.sqrt(vel.x*vel.x + vel.y*vel.y + vel.z*vel.z)
        end,
        loc_default = function(name)
            return ui_loc_string('en', 'Double tap')
        end
    }

    :struct 'refs' {
        dormant_aimbot = ui_find("Aimbot", "Ragebot", "Main", "Enabled", "Dormant Aimbot"),
        fake_latency = ui_find("Miscellaneous", "Main", "Other", "Fake Latency"),
        scope_var = ui_find('Visuals', 'World', 'Main', 'Override Zoom', 'Scope Overlay'),
        head_scale = ui_find("Aimbot", "Ragebot", "Selection", "Multipoint", "Head Scale"),
        body_scale = ui_find("Aimbot", "Ragebot", "Selection", "Multipoint", "Body Scale"),
        def_auto_stop = ui_find("Aimbot", "Ragebot", "Accuracy", "Auto Stop", "Options"),
        dt_auto_stop = ui_find("Aimbot", "Ragebot", "Accuracy", "Auto Stop", "Double Tap"),
        enable_desync = ui_find("Aimbot", "Anti Aim", "Angles", "Body Yaw"),
        enable_fakelags = ui_find("Aimbot", "Anti Aim", "Fake Lag", "Enabled"),
        yaw_base = ui_find("Aimbot", "Anti Aim", "Angles", "Yaw"),
        pitch = ui_find("Aimbot", "Anti Aim", "Angles", "Pitch"),
        yaw = ui_find("Aimbot", "Anti Aim", "Angles", "Yaw", "Offset"),
        fake_op = ui_find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Options"),
        base_yaw = ui_find("Aimbot", "Anti Aim", "Angles", "Yaw", "Base"),
        freestand = ui_find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Freestanding"),
        slowwalk = ui_find("Aimbot", "Anti Aim", "Misc", "Slow Walk"),
        jyaw = ui_find("Aimbot", "Anti Aim", "Angles", "Yaw Modifier"),
        jyaw_slider = ui_find("Aimbot", "Anti Aim", "Angles", "Yaw Modifier", "Offset"),
        fake_duck = ui_find("Aimbot", "Anti Aim", "Misc", "Fake Duck"),
        left_limit = ui_find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Left Limit"),
        right_limit = ui_find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Right Limit"),
        dt = ui_find('Aimbot', 'Ragebot', 'Main', 'Double Tap'),
        hs = ui_find('Aimbot', 'Ragebot', 'Main', 'Hide shots'),
        hs_op = ui_find("Aimbot", "Ragebot", "Main", "Hide Shots", "Options"),
        dt_op = ui_find("Aimbot", "Ragebot", "Main", "Double Tap", "Lag Options"),
        dt_fl_limit = ui_find("Aimbot", "Ragebot", "Main", "Double Tap", "Fake Lag Limit"),
        body_aim = ui_find('Aimbot', 'Ragebot', 'Safety', 'Body Aim'),
        auto_peek = ui_find('Aimbot', 'Ragebot', 'Main', 'Peek Assist'),
        third_person = ui_find('Visuals', 'World', 'Main', 'Force Thirdperson'),
        e_roll = ui_find("Aimbot", "Anti Aim", "Angles", "Extended Angles", "Extended Roll"),
        e_pitch = ui_find("Aimbot", "Anti Aim", "Angles", "Extended Angles", "Extended Pitch"),
        e_ref = ui_find("Aimbot", "Anti Aim", "Angles", "Extended Angles"),
        freestanding_yaw = ui_find("Aimbot", "Anti Aim", "Angles", "Freestanding"),
        hitchance = ui_find("Aimbot", "Ragebot", "Selection", "Hit Chance"),
        min_dmg = ui_find("Aimbot", "Ragebot", "Selection", "Min. Damage"),
        safe_points = ui_find("Aimbot", "Ragebot", "Safety", "Safe Points"),
        hidden = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Hidden")
    }

    :struct 'menu' {
        var_update = {
            link_active = nil,
            link = nil,
        },

        show_recent_deletions = false,

        init = function(self)

            local info_group = ui_create(ui_get_icon 'house-chimney' ..' Global', 'Information')
            local configs_group = ui_create(ui_get_icon 'house-chimney' ..' Global', 'Configs')
            local settings_group = ui_create(ui_get_icon 'house-chimney' ..' Global', 'Settings', 2)
            local antiaim_group = ui_create(' Anti-aim', 'Anti-aim', 1)
            local antiaims_configs_group = ui_create(' Anti-aim','Anti-aim Presets', 1)
            local antiaims_builder_tab = ui_create(' Anti-aim',  'Envious - Global', 2)
            local visuals_group = ui_create(ui_get_icon 'user-gear' ..' Other',  'Visuals')
            local misc_group = ui_create(ui_get_icon 'user-gear' ..' Other', 'Misc')
            local ragebot_group = ui_create(ui_get_icon 'user-gear' ..' Other', 'Ragebot', 1)
            local sound_ambient_group = ui_create(ui_get_icon 'user-gear' ..' Other', 'Game Additions', 2)
            local cloudsystem_group = ui_create(ui_get_icon 'house-chimney' ..' Global', 'Cloud System', 1)

            events.pre_render:set(function()
                local current_colors = {
                    link_active = ui_get_style()["Link Active"],
                    link = ui_get_style()["Link"]
                }

                if current_colors.link ~= self.var_update.link or current_colors.link_active ~= self.var_update.link_active then
                    events.on_style_change:call()
                end

                self.var_update = current_colors
            end)

            local modify = {}

            events.render:set(function()
                if ui_get_alpha() < 0 then
                    return
                end

                modify.math_breathe = function(offset, multiplier) return math.abs(math.sin(globals.realtime * (multiplier or 1) % math.pi + (offset or 0))) end
                modify.typing_text = function(s, callback) num, length = 0, #s:gsub('[\128-\191]', '') result = '' for char in s:gmatch('.[\128-\191]*') do num = num + 1 factor = num / length result = string_format('%s\a%s%s', result, callback(num, length, char, factor):to_hex(), char) end return result end
                modify.gradient_text = function(s, a, b) return modify.typing_text(s, function(num, length, char, factor) return a:lerp(b, factor) end) end
                modify.gradient = function(s, a, b, t) return modify.typing_text(s, function(num, length, char, factor) interpolation = modify.math_breathe(factor, t) return a:lerp(b, interpolation) end) end
                modify.static_gradient = function(s, clr1, clr2) return modify.gradient_text(s, clr1, clr2) end

                local link_color = ui.get_style 'Link Active'

                ui.sidebar(modify.gradient('Envious Nightly', color(255, 135, 210), color(link_color.r, link_color.g, link_color.b), 1.775), modify.gradient('', color(255, 135, 210), color(link_color.r, link_color.g, link_color.b), -1.775))
            end)

            local global do
                global = {  }
                local config_data = fucking_configs

                if config_data == nil then
                    fucking_configs = {  }
                end

                local name_list = {  }
                for idx, data in pairs(config_data or {  }) do
                    table.insert(name_list, data.active and data.name ..' \a73BCEDFF- Active' or data.name)
                end

                local Cipher, deCipher do
                    local Xor = function(str)
                        local key = '72 65 6d 6f 76 65 64'
                        local strlen, keylen = #str, #key

                        local strbuf = ffi.new('char[?]', strlen+1)
                        local keybuf = ffi.new('char[?]', keylen+1)

                        local success,_ = pcall(function()
                            return string.dump(ffi.copy)
                        end)

                        if success then
                            print_error 'You are not allowed to edit FFI Struct.'
                            common.unload_script()

                            return
                        end

                        ffi.copy(strbuf, str)
                        ffi.copy(keybuf, key)

                        for i=0, strlen-1 do
                            strbuf[i] = bit.bxor(strbuf[i], keybuf[i % keylen])
                        end

                        return ffi.string(strbuf, strlen)
                    end

                    Cipher = function(a)
                        return tostring(base64.encode(Xor(a)))
                    end

                    deCipher = function(a)
                        return tostring(Xor(base64.decode(a)))
                    end

                    self.Cipher, self.deCipher = Cipher, deCipher
                end

                local md5 = require 'neverlose/md5'
                local generateAuthSignature = function(data)
                    local str = string.format('username%smethod%sinstance%skey%s', data.username, data.method, data.instance, data.key)
                    data.signature = md5.sumhexa(str .. 'removed')

                    return data
                end

                local errorLog = true
                local onlineUsers do
                    local ws = require 'neverlose/websockets'
                    local style = ui.get_style('Link Active')

                    local text
                    local point = -2

                    local ws_callbacks = {
                        open = function(this)
                            errorLog = true
                            point = -1
                        end,

                        message = function(this, message)
                            local parsed_msg = json.parse(deCipher(message))
                            if parsed_msg.type ~= 'heartbeat' then
                                return
                            end

                            if parsed_msg.method == 'authorizeResponse' and parsed_msg.success == true then
                                this:send(Cipher(json_stringify({
                                    username = self.cheat.username,
                                    tickcount = globals.tickcount,
                                    method = 'update',
                                    instance = 'envious',
                                    cloud = true,
                                })))
                            end

                            local success, message = pcall(function()
                                if parsed_msg.activeConnections > 0 and parsed_msg.method == 'updateOnlineUsers' then
                                    return parsed_msg.activeConnection
                                end

                                return false
                            end)

                            if success then
                                point = (message or -1)
                            end

                            if parsed_msg.method == 'cloudUpdate' then
                                local parsedConfigs = json.parse(parsed_msg.configs)

                                local newObject = {  }
                                local affiliation = false
                                local configNameCounts = {}

                                for n,v in pairs(parsedConfigs) do
                                    local object = {
                                        author = n,
                                        configData = v.configData,
                                        uploadTimestamp = v.uploadTimestamp
                                    }

                                    if n == self.cheat.username then
                                        affiliation = true
                                    end

                                    local configName = v.configName
                                    if configNameCounts[configName] ~= nil then
                                        configNameCounts[configName] = configNameCounts[configName] + 1
                                        configName = configName .. " #" .. configNameCounts[configName]
                                    else
                                        configNameCounts[configName] = 1
                                    end

                                    newObject[configName] = object
                                end

                                events['@cloudSystem']:call(this, newObject, affiliation)
                            end
                        end,

                        error = function(this, error)
                            point = 0
                        end,

                        close = function(this, error)
                            events['@onCloudClosed']:call(this)
                        end
                    }

                    --self.wss = ws.connect('wss://notpasted.fun', ws_callbacks)

                    events['@onCloudClosed']:set(function(this)
                        if errorLog and last_tick ~= globals.tickcount then
                            common.add_notify('Envious Cloud', 'No Way! I\'ve suddenly lost my connection to the server. Trying to reconnect.')

                            errorLog = false
                        end

                        events['@cloudSystem']:call(this, nil, nil, true)
                        self.wss = ws.connect('wss://notpasted.fun', ws_callbacks)
                    end)

                    info_group:label('  Welcome back, \a'..style:to_hex()..'' .. self.cheat.username)
                    info_group:label('  Branch: \a'..style:to_hex()..'' .. self.cheat.build)
                    local usersLabel = info_group:label(' Online Users')
                    local sm = smoothy.new({
                        updating = math.clamp(math_floor(math.sin(globals.realtime * 4.45) * (1*255/2-1) + 1*255/2) or 1*255, 25, 255),
                        real = 0
                    })

                    local next_attemt = globals.realtime + 10
                    local changeStatus = function()
                        if ui_get_alpha() < 0 then
                            return
                        end

                        local alpha = math.clamp(math_floor(math.sin(globals.realtime * 4.45) * (1*255/2-1) + 1*255/2) or 1*255, 25, 255)
                        local semi = color(243, 182, 182, sm.value.updating):to_hex()
                        local active = style:alpha_modulate(sm.value.real):to_hex()

                        sm(.045, {
                            updating = point < 0 and alpha or 0,
                            real = sm.value.updating == 0 and 255 or 0
                        })

                        if point == -2 then
                            text = '\a'..semi..'Connecting..'
                        elseif point == -1 or sm.value.updating > 0.01 then
                            text = '\a'..semi..'Retrieving users.'

                            if next_attemt < globals.realtime then
                                point = 0
                            end
                        elseif point == 0 then
                            text = '\a'..color(236, 71, 71, 255):to_hex()..'Unknown Error'
                        else
                            text = '\a'..active..''..point
                        end

                        usersLabel:name(
                            string.format(' Online Users: %s\n', text)
                        )
                    end

                    events.render:set(changeStatus)
                end

                info_group:button(ui.get_icon 'link' .. ' \aFFFFFFFF Join Discord ', function()
                    panorama.SteamOverlayAPI.OpenExternalBrowserURL("https://discord.gg/t4qrkYP98K")
                end, true)

                info_group:button(string.format(' %s  Obtain Verify Token ', ui.get_icon 'discord'), function()
                    local _LUABUILD = 'nightly'

                    network.get(string.format('http://notpasted.fun:10111/discord?username=%s&build=%s&signature=%s', common.get_username(), _LUABUILD, md5.sumhexa(common.get_username().._LUABUILD..'removed')), {  }, function(data)
                        local message = string.format(string.format('Your unique token for autorization in our discord -> \a7C88DF%s', data))

                        print_raw('\a4CEFB2[Envious] \aDEFAULT~ ', message)
                        print_dev(message)
                        clipboard.set(data)
                        cvar.play:call("ambient\\tones\\elev1")
                    end)
                end, true)

                --global_config
                global.global_export_preset = configs_group:button('Export', function() self.config_system:export() end, true)
                global.global_import_preset = configs_group:button('Import', function() self.config_system:import() end, true)
                global.load_defaults = configs_group:button('Default', function() self.config_system:import({ settings = true },
                    '[Envious]PhN8J3kQYQNlCBUWayljeQtQNSVZdAlVMz1FJyUADTQyExo0KEwiUQxoDVVjXRB2D2IBfxgQCRgAP1AlKAAXdTdDRTw9AAhVV2pzGjUMTDIvDGcVVWR6EHYKYg1nGBBDfXBQIiVZcXdVOCNFPRkAGCtXZWkCbixBLTxFZXN8ITB1ARcXC2RnDGQJaWEjHUw4amMwO1IxJFRhFkE+cQB0In9XQT46RX0WfD9hEGNaZQMOFn0NY2wLUDEjWWkSVSZyIF9UchBBJhQAanEAcVdGICZTIGUCCD8QcX8XDBNkYjgBchgTOVA9TQAJJFIhCE41ankkPgB0agBhbwBra0Y1bDZUDHAVVWEEEH0UYhdbGAUJGAQ5UDgzAAI6Ujs0TiAgHFBXcmkAcRQAanEAcVdUMz9FaWt8IXoQcXhmeBQWEDkDd8/G+gAVUUYvP1M6G0VhC2Fnc0Y1JlMkYwIVJBBkMHJ3ERd/ZGhyZqXFk3MpRScvTjYgVjFqYQBvAnM3QThzIB0CDjwQYQQXDGBlZSkZBwzP0foAEC9GJCFTICdFdEEEEQBwc0YwWFMvfQIPGBBxehcDeGViDhkHCc/d4gAQZSNUTiEgVjQUYQtxAHNPGicrTDYsDHYWVXF/EH4XERE2AQhmFKa04hRkLzdFPR5JNy8ABAgAdGoAYW0aPSNVMSxnbVVieRBmchEPZ2RqK2au3pNlDUUyL04yJlYscWEVIGURAHJpAHMORis9UzZBAh0/EHV5FxJ7ZXcLGQ8Xz8CzZXVFNCxOIl1WL3FhEk0AYWoAZWkAdGgaNT1VLH0CFm8hSAALKFdzDlQ4JEV/T2IuLlllEEEjagJ7O1I8NAx2QipVWXIQQSYUAGhrVCEYRW1oYiotWXQTQTZvAGlzGiByMFQMcAtPNU0AEzBXc00AYWoCfz1SIS8MYw1PLSgADWEyEQByaQBxFAJwJVImCAxjCE8hMAANK1dhbwBpcQB0IGUTGiY7VTQYAg8/QTEBRWEJTystSSAjTy9tGj0jVTEsZ3ROMytMNBRjJT9EOhlJLiQAZ3NUJj9FbW1lJzBCOGVlck88LUklXU8kcQBxV1QzP0Vpa2U6K0ItKgAKPk4waTFYTzxpAHEWGj4jVTZBAgQkQSclRXQJTy8rST04TzogZREAcmsaJUZVL30CFgNBIyZFZQpPOi5JNSZPJ3EAdCBlEQBwc1QjQUVmc2U9DEItLwAGJk4wI1QoIE5pcQB0IGURAHJrGiVGVS99AhUMSyRqbCwkSSBoGnd/Dnl9AhJhLlQAHiBNOEAAaGsSZkMQbWhmJCJFdAZJLCZUaXECbjZ1HxB+a2YwX0VqHUk+BFRhagBncxNnZBBtbWYoOkV0TCxcSSZpAHEUAGhrFWJDEG1oZiQiRXQGSSwmVGlxAHQgZREAcmsaZwQOen0CFQxLJGpsLCRJIGoDc20af2EOZCxnd0E5LAAdXU0jJQBwXwBjcBZ1ZxB4aGYgJEVpHUk5aTERA2BpAHMOFnp/EH9PZiAhRWUFSTkjVGFsEmlxAHY6cwEOYmUCF1VLL3FsOgBJNWoDd2kAdGoAY3UWeX8QeCIDUEs3aWw4WUk+cQNhTQBhagBlaQB0aBp3fw55fQISYS5UAB4gTThAAAY0RidPGnJyDnVlAhIrSyRvbCA8SSAgF1hHOj0CawYZZGEMcStBKi8ACjlUPSVOMm0aEgwMdkYkWkVyBlAlXU8kIgBxV3scZgIDKEsxam8xO0kmP1N0IGcLe3ADSSVARThzfX9PZiAhRWUGUCAjTy88AGlxAm5bZ3tJJj1FIxZ9ZnNmMgZFYQVQMSBPOjkAYW8AaXMaDyIPWFQmLFJzaQxoF0E4CAAOOlQsJk4nagBhbwBpcQJuW2d7SSY9RSMWfWZzZjIGRWEFUDEgTzo5AGFvAGlxAHQgZwt7D2UCF1VLL3F5MhoADCVEIGsadg5FJy5VJSUCeCIDUEs3aXkwQwAHPkQ2TQJ7aGQgL0EhJlRjYwIPMEsxIBxQV3IETzVRAGpzGnEpRScrVSk9AnhoZiAkRWkIQSMgCF5EN2kAcRYaaBVFNQxVLT4CaWtmNSFFYRZBPnFtO2QgEQByaQBzDgIONEYyGEw1aAxnD0E/LwAYLldpHE8wZWURAHJpAHEWGmgQQzACUiUjTiJpcz0uRWNjAg8wSzEgHFBXcgRPNVEAanEAc00AYWoCf2tkMSxBNCNUa30CEnIgVFMmKE41FGQvIg5xVwIOLEZnZQISOEUkPFQoP0R0RCBCDnJrGnN7RixzDHErUiQvUzEoTjBqZCQ8DmlxAm4iCldGcGUCF0ZFLyJUMgNEYQ5FNmcAdGoCe21vLzcCeCIDQ0U3OlQwWkRqFUUgQwBhagBlaxp2BUYnbQxrF1IxZTZFQTwtABVRU2RxAHNNAGFqAn9rbzIsAm1tZjs0RSd0JF9Ecg1FIhoAanEAc00AYWoCf2tvMiwCbW1qICVUMXJlfE82LAJrFnM+MFQ6DgJtaGosPVQxOAAMIEQscQJuIhZFQSYgQ3MYAgA4VCcIUmEHTyEsAHRoGmMcVCglSTciaRNqOz1UNEYABz5ENk0AYWgaZw1ZOitNKCwCZXNqPXQxVFJyBE81UQBqcQBzTxpjGVQkPUk3aAxjBUk9JUUmIAheRDdpAHEUAGpxAmlPczUrVCwqAnhoaig7VCwjABlvIVQAcmkAcRQAanECaU9kOCRBKCBDdmYCCyZUPTRSdE8jV1M3PQJrBA56fQIZBFQ1L1JlBkYyOUU1bwJzYQ5kLGd7SSY9RSMUbyw3UzYZAGFoGnVnEHhoaig7VCwjABtmI0JFJmkAcRYaZ2IUfV0MYwBJMT1FJmpvJylTLCUAdCBlEQJoeQ5hGAIAOFQnCFJhBUYjOkUgagBhbwBpcQJuMGsBDHADSSVARThxbzULUyQ+AGVpAHRqAGFvAnNiEXowaRNqOz1UNEYABTdGIAhUYWkSZ3MQenoMYwVJPSVFJiAKV0YhLFRxFxJqcxpjQxBtaGosPVQxOAAOKUY6NFR0I3cRAHBzEH8EDGgbSScZRTNqbyMvUzE+AGJ9AGlxAm41dB8QfmtqOEBULyMAHAtGMi9UZWoSdGoAYW8Cc2EOZCxne0kmPUUjFG8sN1M2GQBieABlaQB0agBjdRBnYQx2SixFVDc7AB5SRjk0VHNOEmFqAGVpAHRqAGN1FHx/EHgiCFBYfGlBPFtVJCUCaVgOcWYCCChYempBLCBVJyUAdjpwHxB+a20wTA5qME08GE41agBncxV6egxjAkExfwA1bSpETiZpAHEWGn9/EH9PbSAyDmUoTTs/TjVvAGlxAHY6cB8QfmttMEwOajBNPBhONWoAZWkAdGoCe3oOeX0CGWE9HwAzJE8kWlRqcQBzTQBhagBncxV6egxjAk8tOEY9ZTcRbzQvUzRAAnBhDmNBAgwlRCwvSTE4AA4pRjo0VHQifwEOYmUCHFtEIzdJNh8ADixGNixUdGoCe38OeX0CGW8hWEY7LFJxe0YsIkUnTQBhaBp1ZxB4aG0uK0kvOEUmIApXRiEsVHEUAGpxAmlfFG96DGcETzAjRigqUmkeRjJzIEUAcmkAcRQAaGsNZVsOcWYCCCZEPSxJJD0ABjdGJ2UxEQByaQBxFABqcxpkXA5xZgILZHc1MwAMIEQgN0kxcmcLE2J/FWIBFntnDmNBAg9ndyQwABklRCgpSSwjAHY6dAQSZ34UYQMWcn8Qf09ubB1BPGltOy5JJyZFO3EAdjp2ABBmcRBkBRJ6fxB/T25sHUE8aW07LkknJkU7cQB0In8CFmV9E2MFEXJlDmNBAg9ndyQwABklRCgpSSwjAHQgZRECaHsXYwUSe2YYa1UOcWYCC2R3NTMADCBEIDdJMXJlEQByaQBxFhp+YBdgVRF1exdzZxB4aG5sGEEwcW07ZCxXSTc7AHEUAGpxAHNNAnt7EnVxEmdzFXl7Dnl9AhtmI0JFJmkRcw4QZGEMcSJGJzlFMWkRdGgac38OeX0CG2YjQkUmaRFxFAJwZxF9XQxjBUYjOkUgahFhbwBraxB6MGkTbzQvUzRAAHtxAHNNAGNwE3RnEHhobycpUywlAGUgZREAcmkAcw4QZGEMcSJGJzlFMWkRdGoAYW8AaXEAdjp1HxB+a283UlMvJQBhTxpxZBBpa28yLFMkOwB7cQJuMGsBDHAGRjdHRT5xEnNNAnt6DnVlAhssRjIqVGljAHQgZwsQfHkMc3tGLCJFJ00SYWoAZWkCbngUb38Max5GMnMgRQBgaQBxFABqcQJpXQ5xZgIKL0YnL1RhfQBpcQB0IGURAHBzEH8EDGgBSScOSGNwAgEsRjU/TDVtDGsBSSBjLRECaGtkPkNOaH0CAwRUIiIAZWsadg5PNiECZXNwPXQmWQByaQJrFmQlJk5xQQIRI1QmIQB0agBhbRprFU8jbmcdAgIgVDJcAGpxAHNNAGNwAgEmVzpoDGMfST0ySHQgZREAcmkAcRYaaBVPJAMCbWh0PDlFdnACBSpGKCRMICJpE3QrOUVxFhpoBFA3DFQkaAxnHVkkLwBhbRprAlc9dCZZAn5rdChERWpxAHFXAgUvRiQ8TCBoDGMbWTk0AHQgZRECaGt1IVBBPjQCf090ODpFZWkAdGoAYW0aaxVFMmEwXVRwZQIFTVAvcQBzTQBhagBlaxp2DkUnLlUlJQJ4IhxQV3BzAhVRRiskTCdPDGMTQTJpAm5oYiAsSz4wUjAiaRN5Mz4AcRYaaBBUczlBMy1FMWsMdhNBNm8AaXMadkExEXQzO0c0QAJmc3kyGgBhagBlaxp2C1RhG0E7NkUgImkTeTM+AHEUAGpxAHFXAgMrQy4+QSYuAm1teSgmAHQgZREAcmkAcw4CCyUABwxSJi9UZ2UCDStXYQJPLThGPWU3ExpwDUkiVUImNERxQQIYK1dlBE8wI0YoKlJpcxp2TyNXUzc9An0WeSsmAB4CRCgsSSA7AHRoGmMMRSclRSYiaRN5Mz4AHFtEIzdJNh8AYWoCf2tueR1BOG0MawhBIyAIXkQ7L0k0RgBqcQBzTxpjGEErLU85aAxjFkE+cW07ZCxXSTc7AHEUAGpxAHFXAg4sRjYsVHZmAhguV2kcTzBpI1hFIGkAcRQAanEAc08aYwVGIzpFIGgMYxZBPnFvMmY2VFRyBQJrBA56fQIKDFdhBUYjOkUgamxhbRp9fxB4IhxQV3IGRjdHRT5xbHNNAnt8DnVlAg0rV2EARi8iRSAgCREAcmsaYRoQZnN5MhoADixGNixUdAYAYW8AaXMaZC51HQILKFdxe0YsIkUnTWxhagBlaQB0aBp1fw55fQINYTIRbzQvUzRAAAZxAHNNAGFqAGVrGmRkEG1teSgmABtmI0JFJmlycw4QZGEMcTRBNmpvIy9TMT4AE28Cc2AQejBpE3kzPgAeUkY5NFRzPwBhaBp3eA5kZgIYLldpHkYycyBFAABpAHEWGnp/EH9PeSA9AAovRicvVGEdAGlxAHQifwEOYmUCCFVXah5GNR5FNWpyZWkAdGoAYW0afWEOZCxnaEElaW83UlMvJQABTQBhagBlaQB0aBpsfhBnYQx2YSxcQj09fzZYTz04TjRPGnN/DnVlAjUjTSMgVBY9TzNnLF9HcHNUI0FFZnNBPQRNID5JKid/JzpFJCsCc2YVejBpE0E8J08kWkMvPEU9GVNjcEYkJVMxZgIgIU4mJE43ZShUTiY6fydbTD88RXFXGHFkEGlrQTo+SSAmTRY8TzBlZwsSfHkMc1VOPjhBOgBTHj5XIChLJ2gaGm1hJyVJeUEsXAA9JwAER0VofQIAGUE1I0NlJk50B0EvOkElc314IiRBUDcoUg5ASSc0AmlaDnFmAiQ7Ujs9Ux4sTyU+UnY6Z3dmE3wYZnJmaH0CMh9SLj1TGjpULSZFY3UCDThTNWIpVERwZQIwQVQlPFUnCFUvJ1UxLAJuPlI0KgxrM1U9bCFuQz0lTyMWGmgXZhJYGHYMZmdlAjcmQS87QS4OQzxhK1ZFIGsaN1VMOTQMcQ5PLy5JMSBPOmgaYwxSJiRDPCJpE0M9J0Q4QEklP38wAkwuOAJ/a2YSDGYHCWYPcwx2YypfUz0lRQ5XSCs/RzYfAns+UjAsDHYpTy88TyU0fzdvKV5ScHMCZXYUCGViEiwCbWhDMDpUOyd/MixPOTQCbnQ3REV+a0Q8U38nMFI4CFJjcFQ3PEV4aEQ1EEQgIkM8YTdWRXBzVCNBRWZzRCcyRCg5Qy0oUjMvfyUqTCgoAm4zawEMcC1UDlBJOTJIMh9HJBVXIChQOyRTY3V7awJDO3UxE31+a0UiW38jP0Q6DkE1JVI2axogOFUkYwIsKUM4dSFUfzomTD5rSyhzGggwDGMvWCYlVTAvfyghRCAyQSBvN0ICaBJ9fRZFMjJMJglFHiZJKyxTdnB7HGMCLClQOG8sRX8mPkUwX1Noa3txKU80KEwgaXQ1OgIcYwIvMFMgXylQRDYsUnMOVDgkRX9PRzMvTiQtRScVTS4rVSUwVD1vKxMaJjtVNBgCLSNFPQxEJDl/NyhEPT9TY3V7axhOMmU3X09wZQICWU8hNAIOQQIpI1QoKFI/L1IePFcgJUM8In9FUicsDHNcST4iTyYDRDJoGiMoTCcvDGMnST0iTyFuIUJ/JCZMJFlFaGsXZkMQbWhIKiVPCyNOJSZDKCVPJiJ/V0E+OkV9FkglPU8MBkIeKU8pJlJ2cAIADGMKZxgSRmcdAjstRTBYfz44QzhPGicrTDYsDHYjRCQuTBYlSTdrGlxJPC1NNhYafX8Qf09JJS9BKRZUPSlLHiJPLXMaD11pE0k8LUkyVVQjPk4MHlQ4JkVncwIQL0YgOkw9cwx2aStVSTEoVD5Gfyk+TDwfAntoGAEIZBIMZgdtDGs4TjBpJlBUPTt/JUNFKzpTcVd7YxlDKjlFdCtEKzpTPXMMdlAwXVMzPUk/UwJmc2QyAEEmLwAsJ0R6aH1tbUknN0UmbipuRTwsTSgWGmgXZhUrZgcMZmdlAj0kRiQ9TiYORiZpK1VMK2sac3JmDBdmFStmY2YCLixZNiNOJRBDJj1PJiJ/E2YUCBVpA2YMcwxxBkktJkQgKFQ8OU80IUQ6cxoyYSlCRX5rSzhYTC40QScFUy4/TiE6fyIlTDQiRWtrF2EudR0COSBMPUdBM3MaJx9VJGYCLiBMODlBOBBEICJBNmwgQ1Nwc3tze05qBkEhAFUxaH1pa0s9JkwyLlkWPFU4dCxBTDssUnMOEmRhDHEGSS0mUyQwfycvTCQsVGtre3ZPKxFrOyVMcxgCBT8AFwhBNSICaWtyMTxFLyhFawwMdmwqVn8xJlIjUUM+OE89MkMuJk83axp2DxV0eRV8F2Z2LGddTzUWRDRVVCIOQzwBTzNoGmd9EWN8ZHgJZmt9AjhvIm5FPC5JP1F/PihQNk8aYwRFMyxSOCVTJG0Maz1PM18tRFImFkM+WE84cxpxK2YHDGYDD2Z2ZgItIEcWPUMLYypdTyBrGnNxGAkVFmorZmNmAikmRwsnQS8uRywOQztsKkNTcHN7DBgCJj5HDABJMjpSIC1/NyVMLj0Cc3NlYTVzBBUUDwJ9FkwlNn8jH0UlL1I3FkM7Jk8zbRprZRFjNgEIZhRrDHNYTy0OUyMfRSAufyYmTDs4AnttZXESZGI5A3cCfmtNMFNJKQ5LNhQCeyxBKTpFeGhNIChJKg5LMXkaUFUmJlMlW1Boa3sOQQIsK0csKn8/L1keLU8tKFN2OnQBEHx5DHNZQS04QwwGRTgVSCZrGmZ5DnFjAiQwRz1jGlpFKxZINFVEOXMaYl0Qb3oMZyRBMyNDHiRFMA5NO2RnC3sPZQI8VU4/MEwMDEFjcAIBIFM1KEwkKwJlc001eCxcVT8WQz5BTj5zGmtDEG1oTio9SD0kR2N1Rig9UzEsZ15ODTpDI1FFJHMaJx9VJGYCNSxSJzpFMyxUICdFC2gqXU9wc3tzYEgjI0RzPUUzOU8ra314aFMiIFAsDkE6aSgTGmp5DmEYAjkyTyMIfyIlTCo7EXZwAgcJZg8XZhJGZx0CISpPIVF/KT5MPB8SY3ACAw9mEgxmcX8CZXNTN281VH81KFBzDhdkYQxxHkMuOkUaLkw7PUkvKAJzYBF6MGkTUzEmUDRrRyY+VzoDRx4pTDdrGnYMZgcJZg9iE3YsZ0JDPTlFDkdJMDQCaVwQdGQQaWtTNyVQJBBUMCFFdjpnY0UkLFIiUURofQIgCEwkKVQaJU8zaBoabWMmP1M7bCATDHAcUCFRUmc9RTUZAhxmAjYlTyMuTzYhfyo+TDtyZwsCGixBPUBIahNBIAhEY2YCNiRPPy9/IiBMJiMCbiIDd2YUD2YXcgJmc1M8AVUyFUcpJkI1Jn8gLEMsP1R2Omd3ZhQPZhdyZmh9AiACTDQ5fyI7QTAjRS87f3hzGnZGA3dmFA9mFxYMaCJPPxhTHi1SJC1JMSRUHn0Cc3NmEkYDd2YUDwJ9FlMlPVUgMkkiJU42axoyK0wyKgxrIk84dTZuUzclRTJAAnAKfX9PUy4mVTYWUzE6QTMuVCYjAm4iAVRGMzxMJRYMaCJPPxhTHjlIJC1PIxVDLT0Cc3MQZjEAdxRhegJ9FlMlPVUgMlMpK0QqPlN2cBF5YRBlc1M7bDBCfyEhTyZrQjgwTjAFAnssQSk6RXhoVCA8SyswUgtuKkVJNDACa0BSPzQMcRlIKDhEGjlFJjlPLxBQJiICbiIJVEYmawxzQkkvJk08CUUtFUE2OUU3PlIgO0kmcxpkLnUdAiQgRSZZTy40TAwOSCAkRyA7Am4+UjQqDGsnSTF3KF5ENyV/N1tWaGsWYV0OcWYCMyBFIydPJSpMFjpOPWYgExpwZAJ9FlYjNFc+AkQkJn89axpleQ5xYwI/OEUjbSpVRT4WWXMODXthDmNBAjcjRTIkTzAvTB41AnN8FXowaRNXMz1FI1lBODoCaQtBLTlFaWtXNT5FMyJBOzp/NWMmVE4maxpzcRJ9aRRrK2ZjZgIyKFQxOE0gPUsWNUEgYWcLEXx5DHNDSS47RSceAnssQSk6RXhoVy49TC0OSD10KFBSOSxSDldPJj5ScVcCBwxmAw9mEgwCbW1XJiNMMF8tWFQ/KFI6UVIVIkg8Gn8sI1M2LFN2cFQzOkVlc1c7cilVfzogVDxVUiE0UgweSTsvAn97DmRmAjYgUiU1fzxpMVxBICJFI2tUIzxFcVcUb3pd[/Envious]'
                ) end, true)
                global.random_label = configs_group:label ''
                global.automatic_cache_preset = configs_group:combo('Preset caching:', {'Disabled', '1 Hour', 'Shutdown'})
                global.load_cached_preset = configs_group:button('Load cached', function() self.config_system:import({ settings = true }, files.read('cache.data')) end, true)

                --antiaims_config
                global.preset_list = antiaims_configs_group:list('', #name_list ~= 0 and name_list or {'\aCBC9C9FFNothing there. Create preset or import it.'})

                for i=1, #fucking_configs do
                    if fucking_configs[i].active then
                        global.preset_name:set(fucking_configs[i].name)

                        break
                    end
                end
                global.save_preset = antiaims_configs_group:button('Save', function() self.config_system:save() end, true)
                global.delete_preset = antiaims_configs_group:button('Delete', function() self.config_system:delete() end, true)
                global.load_preset = antiaims_configs_group:button('Load', function() self.config_system:load() end, true)
                global.import_preset = antiaims_configs_group:button('Import', function() self.config_system:import_aa_tab() end, true)
                global.export_preset = antiaims_configs_group:button('Export', function() self.config_system:export_aa_tab() end, true)

                global.preset_name = antiaims_configs_group:input('') do
                    global.preset_list:set_callback(function(c)
                        local data = fucking_configs[c:get()]

                        if data ~= nil then
                            global.preset_name:set(
                                data.name
                            )
                        end
                    end, true)
                end

                local set_cache_file do
                    local state = global.automatic_cache_preset:get()
                    set_cache_file = cron.every(60, function()
                        if state ~= '1 Hour' then
                            return
                        end

                        files.write('cache.data', self.config_system:export(true, true))
                    end)

                    events.shutdown:set(function()
                        local state = global.automatic_cache_preset:get()

                        if state == 'Shutdown' then
                            files.write('cache.data', self.config_system:export(true, true))
                        end
                    end)
                end

                global.refresh_colors = function()
                    local active_color = ui_get_style('Link Active'):to_hex()
                    local color = ui_get_style('Link'):to_hex()

                    global.save_preset:name(
                        ' \a'..active_color..''..ui_get_icon 'floppy-disk'..' '
                    )
                    global.load_preset:name(
                        '\a'..active_color..'                Load              '
                    )
                    global.delete_preset:name(
                        '\a'..active_color..''..ui_get_icon 'trash-xmark'..' '
                    )
                    global.import_preset:name(
                        ' \a'..active_color..''..ui_get_icon('file-import')..'\a'..color..' '
                    )
                    global.export_preset:name(
                        ' \a'..active_color..''..ui_get_icon('file-export')..'\a'..color..' '
                    )
                    global.global_import_preset:name(
                        ' \a'..active_color..''..ui_get_icon('file-import')..'\a'..color..'  Import '
                    )
                    global.global_export_preset:name(
                        ' \a'..active_color..''..ui_get_icon('file-export')..'\a'..color..'  Export '
                    )
                    global.load_defaults:name(
                        ' \a'..active_color..''..ui_get_icon('leaf')..'\a'..color..'  Default '
                    )
                    global.automatic_cache_preset:name(
                        '\a'..active_color..'  '..ui_get_icon('file-invoice')..'\a'..color..'  Preset caching:'
                    )
                    global.load_cached_preset:name(
                        ' \a'..active_color..''..ui_get_icon('file-arrow-down')..'\a'..color..'  Load cached '
                    )

                    global.automatic_cache_preset:tooltip('Will localy cache your preset by your state!')
                end

                events.on_style_change:set(function() global:refresh_colors() end)
            end

            local elements do
                elements = {
                    antiaims = {  },
                    ragebot = {  },
                    visuals = {  },
                    misc = {  },
                    antiaims_builder = {  },
                    s_amb = {  },
                    settings = {  },
                }

                elements.visuals.on_screen = visuals_group:switch '  Centered Indicators' do
                    local settings = elements.visuals.on_screen:create()

                    elements.visuals.indicator_color = settings:color_picker(' Indicator color', color(141, 173, 255, 255))
                    elements.visuals.build_color = settings:color_picker(' Build color', color(255, 165, 135, 255))
                    elements.visuals.condition_color = settings:color_picker(' Condition color')
                    elements.visuals.keybind_color = settings:color_picker(' Keybind color', color(255, 165, 135, 255))
                    elements.visuals.arrows_color = settings:color_picker(' Arrows color', color(255, 165, 135, 255))
                    elements.visuals.indication_style = settings:combo('  Indication style', {'Disabled', 'Default', 'Alternative'})
                    elements.visuals.arrows_style = settings:combo('  Arrows style', 'Disabled', 'Alternative', 'Triangle')
                    elements.visuals.indicator_tweaks = settings:selectable('  Tweaks', 'Scope adjust', 'Glowing', 'Pulsating', 'Damage ind.')
                    elements.visuals.animation_speed = settings:slider('Anim. Speed', 0, 100, 75, nil, function(val) return val ~= 0 and val .. '%' or 'Off' end)
                end

                elements.visuals.eso_indicators = visuals_group:switch '  Left-Aligned Indicators' do
                    local settings = elements.visuals.eso_indicators:create()
                    elements.visuals.exclude_indicators = settings:selectable('Exclude ind.', 'Freestanding', 'Hide Shots', 'Dormant Aim', 'Double Tap', 'Fake Duck', 'Body Aim', 'Safe Points', 'Min. Damage', 'Aimbot Stats', 'Fake Latency')
                end

                elements.visuals.holo_indicator = visuals_group:switch '  Holo Keybinds' do
                    local settings = elements.visuals.holo_indicator:create()

                    elements.visuals.persperctive_holo = settings:selectable('  Perspective', {'First Person', 'Third Person'}) do
                        local self = elements.visuals.persperctive_holo
                        local is_first_last = self:get('First Person')

                        self:set_callback(function(self)
                            local is_first = self:get('First Person')
                            local is_third = self:get('Third Person')

                            if not is_first and not is_third then
                                self:set(is_first_last and 'First Person' or 'Third Person')
                            end
                        end, true)
                    end
                    elements.visuals.third_person_pos = settings:combo('  3rd Person Pos', {'Left', 'Right'}) do
                        elements.visuals.persperctive_holo:set_callback(function(self)
                            local state = self:get('Third Person')

                            elements.visuals.third_person_pos:visibility(state)
                        end)
                    end
                    elements.visuals.exclude_holo_kb = settings:selectable('  Exclude ind.', 'Freestanding', 'Hide Shots', 'Double Tap', 'Fake Duck', 'Body Aim', 'Safe Points', 'Min. Damage')
                    elements.visuals.holo_kb_color = settings:color_picker('Main Accent', color(172, 204, 104))
                end

                elements.visuals.hitmarker_switch = visuals_group:switch '  Hit Marker' do
                    local settings = elements.visuals.hitmarker_switch:create()

                    elements.visuals.world_hitmarker_size = settings:slider('  Size', 1, 10, 4)
                    elements.visuals.world_hitmarker_time = settings:slider('  Appear time', 1, 10, 3)
                    elements.visuals.world_hitmarker_color = settings:color_picker('  3D Marker Color')

                    elements.visuals.world_hitmarker_show_misses = settings:switch '  Show Misses'
                    elements.visuals.dmg_marker = settings:switch '  Damage Marker'
                    --elements.visuals.dmg_marker_color = elements.visuals.world_hitmarker:color_picker('Damage Marker Color')
                end

                elements.visuals.shared_logo = visuals_group:switch '  Shared Scoreboard Logo' do
                    local this = elements.visuals.shared_logo

                    local Cipher_code = 'removed'

                    local relayEnvoiusData = function()
                        local me = entity.get_local_player()

                        if me == nil then
                            return
                        end

                        events.voice_message:call(function(buffer)
                            buffer:write_bits(0x1114, 32)
                            buffer:crypt(Cipher_code)
                        end)
                    end

                    local relayEnvoiusShutdown = function()
                        local me = entity.get_local_player()

                        if me == nil then
                            return
                        end

                        me:set_icon()
                        events.voice_message:call(function(buffer)
                            buffer:write_bits(0x1110, 32)
                            buffer:crypt(Cipher_code)
                        end)

                        entity.get_players(true, true, function(ptr)
                            ptr:set_icon()
                        end)
                    end

                    local requestActive = function()
                        local me = entity.get_local_player()

                        if me == nil then
                            return
                        end
                        me:set_icon('https://i.ibb.co/23g5Jpk/tSqXhl3d.png')

                        utils.execute_after(1, function()
                            me:set_icon('https://i.ibb.co/PDJLJkq/telegram-cloud-document-2-5366328080325421984.png')
                        end)

                        events.voice_message:call(function(buffer)
                            buffer:write_bits(0x7787, 32)
                            buffer:crypt(Cipher_code)
                        end)
                    end

                    events.voice_message(function(ctx)
                        if not this:get() then
                            return
                        end

                        local buffer = ctx.buffer
                        local me = entity.get_local_player()

                        if ctx.entity == me or ctx.entity == nil then
                            return
                        end

                        buffer:crypt(Cipher_code)

                        local netmsg = buffer:read_bits(16)

                        if netmsg == 0x1114 then
                            ctx.entity:set_icon('https://i.ibb.co/Q9qrpTX/tSqXhl3.png')
                        elseif netmsg == 0x1110 then
                            ctx.entity:set_icon()
                        elseif netmsg == 0x7787 then
                            utils.execute_after(.3, relayEnvoiusData)

                            ctx.entity:set_icon('https://i.ibb.co/Q9qrpTX/tSqXhl3.png')
                        end
                    end)

                    events.level_init:set(requestActive)
                    events.shutdown:set(relayEnvoiusShutdown)

                    this:set_callback(function(th)
                        if th:get() then
                            utils.execute_after(.1, relayEnvoiusData)
                            utils.execute_after(.2, requestActive)
                        else
                            relayEnvoiusShutdown()
                        end
                    end, true)
                end

                elements.visuals.aimbot_logging = visuals_group:switch '  Log Aimbot Shots' do
                    local settings = elements.visuals.aimbot_logging:create()

                    elements.visuals.select_log = settings:selectable('  Output', {'Console', 'Upper-left', 'Under crosshair'})
                    elements.visuals.log_engine_type = settings:combo('  Event Logger', {'Neverlose', 'Game Built-in'})
                    elements.visuals.maximum_count = settings:slider('  Maximum Count', 1, 10, 8, nil, '@')
                    elements.visuals.appear_time = settings:slider('  Appear Time', 1, 10, 7, nil, 's')
                    elements.visuals.aimbot_glowing = settings:slider('  Glowing', 0, 30, 25, nil, function(val) return val == 0 and 'Off' or val .. 'px' end)
                    elements.visuals.log_manage_colors = settings:listable('  Manage Colors', {'Hurt', 'Misprediction', 'Spread', 'Lagcomp Failure', 'Correction', 'Death', 'Prediction Error'})
                    elements.visuals.log_hurt_color = settings:color_picker('  Hurt Color')
                    elements.visuals.log_mispred_color = settings:color_picker('  Misprediction Color', color(229, 86, 85))
                    elements.visuals.log_spread_color = settings:color_picker('  Spread Color', color(232, 205, 105))
                    elements.visuals.log_lc_color = settings:color_picker('  Spread Color', color(232, 205, 105))
                    elements.visuals.log_correction_color = settings:color_picker('  Correction Color', color(229, 86, 85))
                    elements.visuals.log_death_color = settings:color_picker('  Death Color', color(65, 118, 217))
                    elements.visuals.log_prederr_color = settings:color_picker('  Prediction Error Color', color(65, 118, 217))

                    elements.visuals.log_manage_colors:set_callback(function()
                        ui_handle(elements.visuals.log_manage_colors:get(1), elements.visuals.log_hurt_color)
                        ui_handle(elements.visuals.log_manage_colors:get(2), elements.visuals.log_mispred_color)
                        ui_handle(elements.visuals.log_manage_colors:get(3), elements.visuals.log_spread_color)
                        ui_handle(elements.visuals.log_manage_colors:get(4), elements.visuals.log_lc_color)
                        ui_handle(elements.visuals.log_manage_colors:get(5), elements.visuals.log_correction_color)
                        ui_handle(elements.visuals.log_manage_colors:get(6), elements.visuals.log_death_color)
                        ui_handle(elements.visuals.log_manage_colors:get(7), elements.visuals.log_prederr_color)
                    end, true)
                end

                elements.visuals.custom_scope = visuals_group:switch '  Scope Modulation' do
                    local settings = elements.visuals.custom_scope:create()

                    elements.visuals.scope_type = settings:combo('  Scope Type', {'Default', 'Reversed'})
                    elements.visuals.exclude_lines = settings:selectable('  Exclude Lines', {'Top', 'Bottom', 'Left', 'Right'})
                    elements.visuals.scope_gap = settings:slider("  Scope gap", 0, 500, 7)
                    elements.visuals.scope_size = settings:slider("  Scope size", 0, 1000, 105)
                    elements.visuals.scope_glowing = settings:slider('  Glowing', 0, 21, 1, nil, function(val) return val == 0 and 'Off' or (val == 21 and 'Over.' or val .. 'px') end)
                    elements.visuals.scope_anim = settings:slider("  Anim. Speed", 1, 100, 80, nil, function(val) return val ~= 0 and val .. '%' or 'Off' end)
                    elements.visuals.scope_glowing_clr = elements.visuals.scope_glowing:color_picker(ui_get_style 'Shadows')
                    elements.visuals.scope_color1 = settings:color_picker("Color", color(255, 255, 255))
                    elements.visuals.scope_color2 = settings:color_picker("Color 2", color(255, 255, 255, 0))

                    elements.visuals.scope_glowing:set_callback(function(c)
                        elements.visuals.scope_glowing_clr:visibility(c:get() > 0)
                    end,true)
                end

                elements.visuals.grenades_modulation = visuals_group:switch '  Grenades Modulation' do
                    local settings = elements.visuals.grenades_modulation:create()

                    elements.visuals.grenades_radius = settings:selectable('  Grenade Radius', {'Inferno', 'Smoke'})
                    elements.visuals.inferno_frindly = settings:color_picker('\a81D7B4FF  \aDEFAULTInferno Friendly Color')
                    elements.visuals.inferno_enemy = settings:color_picker('\aE24949FF  \aDEFAULTInferno Unsafe Color')
                    elements.visuals.smoke_color = settings:color_picker('  Smoke Color')

                    elements.visuals.grenades_radius:set_callback(function(self)
                        elements.visuals.inferno_frindly:visibility(self:get('Inferno'))
                        elements.visuals.inferno_enemy:visibility(self:get('Inferno'))
                        elements.visuals.smoke_color:visibility(self:get('Smoke'))
                    end, true)
                end

                --miscellneous
                elements.visuals.Widgets = misc_group:switch '  Widgets' do
                    --initialize db
                    local config_name = common.get_config_name()
                    local ym_watermark_data = db.ym_data

                    if ym_watermark_data == nil then
                        db.ym_data = {}
                    end

                    local my_data = db.ym_data[config_name]
                    local features = {'Nickname', 'Latency', 'Framerate', 'Tickrate', 'Time'}

                    local default_value = function()
                        local features_list = features
                        local not_selected = {}

                        for n,v in pairs(my_data or { }) do

                            for i=1, #features_list do
                                if features_list[i] == v then
                                    table.insert(not_selected, v)
                                    table.remove(features_list, i)
                                end
                            end
                        end

                        return features_list, not_selected
                    end

                    local contains = function(table, value)
                        if table == nil or value == nil then
                            error('⚠ There was an error while gettin the value')
                            return
                        end

                        for k,v in pairs(table) do
                            if v == value then
                                return true
                            end
                        end

                        --return false
                    end

                    local ft_all, data = default_value()
                    local settings = elements.visuals.Widgets:create()

                    elements.visuals.solus_select = settings:selectable('Items', {'Watermark','Hotkeys List', 'Velocity Warning', 'Spectators List'})

                    local add_item = settings:combo('Add Item', #ft_all > 0 and ft_all or {'-'})
                    local label = settings:label('Options')
                    local up_btn = settings:button(ui_get_icon 'arrow-up', nil, true)
                    local down_btn = settings:button(ui_get_icon 'arrow-down', nil, true)
                    local remove_btn = settings:button(ui_get_icon 'trash-xmark' .. '  Remove', nil, true)
                    local list = settings:list('\n', #data > 0 and data or {'Nothing there. Add any item to your taste!'})
                    elements.visuals.watermark_data = list
                    elements.visuals.solus_show_branch = settings:switch ('Show Branch', true)
                    elements.visuals.solus_icons = settings:switch ('Render Icons', true)
                    elements.visuals.solus_separator = settings:combo('Separator', {'Default', 'Dot', 'Mini Dot', 'Legacy'})
                    elements.visuals.solus_gradient_1 = settings:color_picker('Prefix Accent L')
                    elements.visuals.solus_gradient_2 = settings:color_picker('Prefix Accent R')
                    elements.visuals.solus_global_accent = settings:color_picker('Global Accent')
                    elements.visuals.solus_shadows = settings:slider('Shadows', 0, 20, 18, nil, function(val) return val == 0 and 'Off' or val .. 'px' end)
                    elements.visuals.solus_shadow_clr = elements.visuals.solus_shadows:color_picker(ui_get_style 'Shadows')

                    elements.visuals.slowdown_color = settings:color_picker('Velocity Warning', {
                        ['Gradient'] = {color(242, 137, 137, 255), color(202, 220, 137, 255)},
                        ['Health Based'] = {color(242, 137, 137, 255)}
                     })

                     elements.visuals.solus_select:set_callback(function(self)
                        elements.visuals.slowdown_color:visibility(self:get('Velocity Warning'))
                    end, true)

                    elements.visuals.solus_select:set_callback(function(self)
                        local tbl = {add_item, up_btn, down_btn, remove_btn, list, elements.visuals.solus_icons, elements.visuals.solus_show_branch, elements.visuals.solus_shadows, elements.visuals.solus_shadow_clr, elements.visuals.solus_gradient_1, label, elements.visuals.solus_gradient_2, elements.visuals.solus_global_accent, elements.visuals.solus_separator}

                        for _,var in pairs(tbl) do
                            var:visibility(self:get('Watermark'))
                        end
                    end, true)

                    add_item:set_callback(function(c)
                        local num = list:get()
                        local items = c:list()

                        for i=1, #items do
                            if items[i] == c:get() then
                                if items[i] == '-' then return end
                                table.insert(data, num+1, items[i])
                                table.remove(items, i)
                            end
                        end

                        list:update(data)
                        if #items == 0 then
                            add_item:visibility(false)
                            add_item:update({'-'})
                        else
                            add_item:update(items)
                        end
                    end, false)

                    remove_btn:set_callback(function(c)
                        local num = list:get()
                        local items = list:list()
                        local settings = add_item:list()

                        local _visibility = add_item:visibility()
                        if not _visibility then
                            add_item:update(items[num])
                            add_item:visibility(true)
                        else
                            if #items > 1 then
                                table.insert(settings, #settings-1, items[num])
                                add_item:update(settings)
                            end
                        end

                        table.remove(items, num)
                        if #items == 0 then
                            return end

                        list:update(items)
                        table.remove(data, num)
                    end, false)

                    up_btn:set_callback(function(c)
                        local num = list:get()
                        local items = list:list()
                        local my_item = items[num]

                        if num == 1 then
                            return end

                        table.remove(items, num)
                        table.insert(items, num-1, my_item)
                        data = items

                        list:update(data)
                        list:set(num-1)
                    end, false)

                    down_btn:set_callback(function(c)
                        local num = list:get()
                        local items = list:list()
                        local my_item = items[num]

                        if num == #items then
                            return end

                        table.remove(items, num)
                        table.insert(items, num+1, my_item)
                        data = items

                        list:update(data)
                        list:set(num+1)
                    end, false)

                    events.render:set(function()
                        if ui_get_alpha ~= 0 then
                            local num = list:get()
                            local items = add_item:list()
                            local my_item = items[num]

                            if #items > 1 and contains(items, '-') then
                                for i=1, #items do
                                    if items[i] == '-' then
                                        table.remove(items, i)
                                        add_item:update(items)
                                    end
                                end
                            end

                            add_item:visibility(not contains(items, '-') and elements.visuals.solus_select:get('Watermark'))
                        end
                    end)

                    events.config_state:set(function(e)
                        if e.type == 'save' then
                            local my_db = db.ym_data
                            local was_exist = false

                            for n,v in pairs(my_db) do
                                if n == config_name then
                                    was_exist = true
                                    my_db[config_name] = list:list()
                                end
                            end

                            if not was_exist then
                                my_db[config_name] = list:list()
                            end

                            db.ym_data = my_db
                        end
                    end)
                end

                elements.misc.killsay = misc_group:switch '  Trashtalk' do
                    local settings = elements.misc.killsay:create()

                    elements.misc.killsay_select = settings:selectable('Select', {'On Kill', 'On Death', 'Revenge'})
                    elements.misc.killsay_disablers = settings:selectable('Disablers', 'On Warmup')
                    elements.misc.killsay_multiplier = settings:slider('Delay Multiplier', 1, 4, 2)
                end

                elements.misc.taskbar_notify = misc_group:switch '  Taskbar Notify' do
                    local raw_hwnd 			= utils_opcode_scan("engine.dll", "8B 0D ?? ?? ?? ?? 85 C9 74 16 8B 01 8B") or error("invalid signature #1")
                    local raw_FlashWindow 	= utils_opcode_scan("gameoverlayrenderer.dll", "55 8B EC 83 EC 14 8B 45 0C F7") or error("invalid signature #2")
                    local raw_insn_jmp_ecx 	= utils_opcode_scan("gameoverlayrenderer.dll", "FF E1") or error("invalid signature #3")
                    local raw_GetForegroundWindow = utils_opcode_scan("gameoverlayrenderer.dll", "FF 15 ?? ?? ?? ?? 3B C6 74") or error("invalid signature #4")
                    local hwnd_ptr 		= ((ffi.cast("uintptr_t***", ffi.cast("uintptr_t", raw_hwnd) + 2)[0])[0] + 2)
                    local FlashWindow 	= ffi.cast("int(__stdcall*)(uintptr_t, int)", raw_FlashWindow)
                    local insn_jmp_ecx 	= ffi.cast("int(__thiscall*)(uintptr_t)", raw_insn_jmp_ecx)
                    local GetForegroundWindow = (ffi.cast("uintptr_t**", ffi.cast("uintptr_t", raw_GetForegroundWindow) + 2)[0])[0]

                    init = function(self)
                        local function get_csgo_hwnd()
                            return hwnd_ptr[0]
                        end

                        local function get_foreground_hwnd()
                            return insn_jmp_ecx(GetForegroundWindow)
                        end

                        local function notify_user()
                            local csgo_hwnd = get_csgo_hwnd()
                            if get_foreground_hwnd() ~= csgo_hwnd then
                                FlashWindow(csgo_hwnd, 1)
                                return true
                            end
                            return false
                        end

                        events.round_start:set(function()
                            if ctx.menu.elements.misc.taskbar_notify:get() then
                                notify_user()
                            end
                        end)
                    end
                end

                elements.misc.automuteunmute = misc_group:switch '  Unmute Silenced Players' do
                    elements.misc.automuteunmute:set_callback(function(self)
                        self:tooltip('Updates by the state/roundstart event')
                        entity.get_players(false, true, function(player_ptr)
                            local player = panorama.MatchStatsAPI.GetPlayerXuid(
                                player_ptr:get_index()
                            )

                            if not panorama.FriendsListAPI.IsSelectedPlayerMuted(player) then goto skip end

                            panorama.FriendsListAPI.ToggleMute(player)
                            ::skip::
                        end)
                    end)

                    events.round_start:set(function()
                        entity.get_players(false, true, function(player_ptr)
                            local player = panorama.MatchStatsAPI.GetPlayerXuid(
                                player_ptr:get_index()
                            )

                            if not panorama.FriendsListAPI.IsSelectedPlayerMuted(player) then goto skip end

                            panorama.FriendsListAPI.ToggleMute(player)
                            ::skip::
                        end)
                    end)
                end

                elements.misc.fast_ladder = misc_group:switch '  Fast Ladders' do
                    local self = elements.misc.fast_ladder

                    self:tooltip('Makes you faster climbing ladders but it causes pitch to be Up\n\n\aB0DE4BFFWon\'t work while holding grenade')
                end

                local clantagAnimation = function(text, indices)
                    if not globals.is_connected then
                        return
                    end

                    local text_anim = '               ' .. text .. '                      '
                    local tickinterval = globals.tickinterval
                    local tickcount = globals.tickcount + math.floor(utils.net_channel().avg_latency[0]+0.22 / globals.tickinterval + 0.5)
                    local i = tickcount / math.floor(0.3 / globals.tickinterval + 0.5) i = math.floor(i % #indices) i = indices[i+1]+1

                    return string.sub(text_anim, i, i+15)
                end

                local initializeClantag = function()
                    if not globals.is_connected then return end

                    local local_player = entity.get_local_player()
                    if local_player ~= nil and globals.is_connected and globals.choked_commands then
                        clan_tag = clantagAnimation('Envious.lua ', {0, 3, 3, 4, 5, 6, 7, 8, 9, 10, 12, 12, 12, 12, 12, 12, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25})
                        if entity.get_game_rules()['m_gamePhase'] == 5 or entity.get_game_rules()['m_gamePhase'] == 4 then
                            clan_tag = clantagAnimation('Envious.lua ', {12})
                            common.set_clan_tag(clan_tag, clan_tag)
                        elseif clan_tag ~= clan_tag_prev then
                            common.set_clan_tag(clan_tag, clan_tag)
                        end
                        clan_tag_prev = clan_tag
                    end

                    enabled_prev = false
                end

                elements.misc.clantag_changer = misc_group:switch '#  Clantag Spammer' do

                    elements.misc.clantag_changer:set_callback(function(th)
                        common.set_clan_tag('\0', '\0')

                        events.createmove(initializeClantag, th:get())
                    end)
                end
                elements.misc.console_changer = misc_group:switch '  Console Modulation' do
                    local settings = elements.misc.console_changer:create()

                    elements.misc.console_color = settings:color_picker('Console Accent', color(75, 75, 75, 170))
                end

                elements.visuals.viewmodel_changer = misc_group:switch '  Viewmodel Changer' do
                    local settings = elements.visuals.viewmodel_changer:create()

                    elements.visuals.viewmodel_knife= settings:combo('  Knife Position  ', { '-', 'Left hand', 'Right hand' })
                    elements.visuals.viewmodel_fov = settings:slider('  FOV', -1000, 1000, 620, 0.1)
                    elements.visuals.viewmodel_x = settings:slider('  Offset X', -150, 150, 13, 0.1)
                    elements.visuals.viewmodel_y = settings:slider('  Offset Y', -150, 150, -10, 0.1)
                    elements.visuals.viewmodel_z = settings:slider('  Offset Z', -150, 150, -5, 0.1)
                    elements.visuals.viewmodel_aspectratio = settings:slider('  Aspect Ratio', 0, 25, 0, 0.1, function(self)
                        if self == 0 then
                            return 'Off'
                        end
                    end)
                end

                --ragebot
                elements.ragebot.ideal_tick = ragebot_group:switch '  Ideal Tick' do
                    local settings = elements.ragebot.ideal_tick:create()

                    elements.ragebot.ideal_tick_mod = settings:selectable('  Modifiers', {'Min. Damage', 'Freestanding', 'Prefer Body', 'Prefer Safety'})
                    elements.ragebot.ideal_tick_mindmg = settings:slider('Min. Damage', 0, 100, 7)
                end
                elements.ragebot.magic_key = ragebot_group:switch '  Magic Key' do
                    local settings = elements.ragebot.magic_key:create()

                    elements.ragebot.magic_key_mod = settings:selectable('  Modifiers', {'Autostop', 'Hitchance', 'Pointscales'})
                    elements.ragebot.magic_key_autostop = settings:selectable('Autostop', {'Early', 'in Air', 'Full Stop', 'Move Btw. Shots'})
                    elements.ragebot.magic_key_hc = settings:slider('Hitchance', 0, 100, 23)
                    elements.ragebot.magic_key_heads = settings:slider('Head Scale', 0, 100, 100)
                    elements.ragebot.magic_key_bodys = settings:slider('Body Scale', 0, 100, 100)
                end
                elements.ragebot.dt_discharge = ragebot_group:switch '  Discharge Exploit' do
                    local settings = elements.ragebot.dt_discharge:create()

                    elements.ragebot.dt_discharge_weapons = settings:selectable('  Weapons', {"AWP" , "AutoSnipers" ,"Scout" ,"Heavy Pistols", "Taser", 'Knife'})
                    elements.ragebot.dt_discharge_delay = settings:slider('  Delay', 0, 6, 3, nil, 't.')
                end

                elements.ragebot.exploit_tweaks = ragebot_group:selectable('  Force Defensive', 'Hide Shots', 'Double Tap')

                events.createmove:set(function(c)
                    self.refs.dt_op:override((elements.ragebot.exploit_tweaks:get('Double Tap') and c.in_jump) and 'Always On' or 'On Peek')
                    self.refs.hs_op:override((elements.ragebot.exploit_tweaks:get('Hide Shots') and c.in_jump) and 'Break LC' or 'Favor Fire Rate')
                end)

                --settings
                elements.settings.animation_list = settings_group:selectable('  Animations', {'Animate Elements'})
                elements.settings.dragables_control = settings_group:selectable('  Dragables Control', {
                    'Scroll Resize',
                    'Center Magnitize'
                })

                --cloud system
                local isCloudInitialized = false
                local configsList = {  }

                elements.settings.cloudsystem_list = cloudsystem_group:list('Avaliable Configs:', {'Loading..'})
                elements.settings.cloudAuthor = cloudsystem_group:label('Author: Unknown')
                elements.settings.cloudLastEdit = cloudsystem_group:label('Last Update: Never')

                local cloudSystem_ListUpdate = function(this, configsData)
                    if not isCloudInitialized then
                        return
                    end

                    local success, error = pcall(function()
                        if configsData ~= nil then
                            local newObject = {  }
                            for n,v in pairs(configsData) do
                                table.insert(newObject, n)
                            end

                            this:update(newObject)
                        end

                        local list = this:list()
                        local color = ui_get_style 'Link Active'
                        local object = configsList[list[this:get()]]

                        elements.settings.cloudAuthor:name(string.format('Author: \a%s%s', color:to_hex(), object.author))
                        elements.settings.cloudLastEdit:name(string.format('Last Update: \a%s%s', color:to_hex(), common.get_date('%d/%m/%Y %H:%M %p', object.uploadTimestamp)))
                    end)
                end

                elements.settings.cloudLoad = cloudsystem_group:button('  Load Settings ', function()
                    local this = elements.settings.cloudsystem_list

                    local list = this:list()
                    local color = ui_get_style 'Link Active'
                    local object = configsList[list[this:get()]]

                    self.config_system:import({ settings = true }, object.configData, true)
                end, true):disabled(true)

                cloudsystem_group:label('\n\nPersonal Config Area')
                elements.settings.cloudsystem_name = cloudsystem_group:input('Name for Uploading:', 'Default')
                elements.settings.cloudUpload = cloudsystem_group:button('  Upload Config ', function(this)
                    self.wss:send(self.Cipher(json_stringify(
                        {
                            username = common.get_username(),
                            tickcount = globals.tickcount,
                            cloud = true,
                            instance = 'envious',
                            method = 'insert',
                            timestamp = common.get_unixtime(),
                            configName = elements.settings.cloudsystem_name:get(),
                            configData = self.config_system:export()
                        }
                    )))

                    cvar.play:call("ambient\\tones\\elev1")
                end, true):disabled(true)
                elements.settings.cloudRemove = cloudsystem_group:button('  Remove Config ', function(this)
                    self.wss:send(self.Cipher(json_stringify(
                        {
                            username = common.get_username(),
                            tickcount = globals.tickcount,
                            cloud = true,
                            instance = 'envious',
                            method = 'remove'
                        }
                    )))

                    cvar.play:call("ambient\\tones\\elev1")
                end, true):disabled(true)

                events['@cloudSystem']:set(function(ws, configsData, affiliation, isReconnecting)
                    configsList = configsData

                    if isReconnecting then
                        elements.settings.cloudRemove:disabled(true)
                        elements.settings.cloudUpload:disabled(true)
                        elements.settings.cloudLoad:disabled(true)

                        isCloudInitialized = false
                        configsList = {  }

                        elements.settings.cloudsystem_list:unset_callback(cloudSystem_ListUpdate)
                        return
                    end

                    elements.settings.cloudRemove:disabled(not affiliation)

                    if affiliation then
                        elements.settings.cloudUpload:name('  Modify Config '):tooltip('You are able to upload ONLY ONE config which means that config\'s name will change if its different.')
                    else
                        elements.settings.cloudUpload:name('  Upload Config ')
                    end

                    if isCloudInitialized then
                        cloudSystem_ListUpdate(elements.settings.cloudsystem_list, configsData)

                        return
                    end

                    elements.settings.cloudUpload:disabled(false)
                    elements.settings.cloudLoad:disabled(false)

                    isCloudInitialized = true

                    elements.settings.cloudsystem_list:set_callback(cloudSystem_ListUpdate, true)
                    common.add_notify('Envious Cloud', 'Connection to the server has been successfully established.')
                end)

                --anti-aims
                elements.antiaims.antiaim_mode = antiaim_group:list(ui_get_icon 'tags' ..'  Anti-aim Mode', {'Disabled', 'Antiaim Builder'})
                elements.antiaims.condition = antiaims_builder_tab:combo("Current Condition", {"Global", "Standing", "Moving", "Slow motion", "Air", "Air Crouch", "Crouch"}, 0)
                elements.antiaims.antiaims_tweaks = antiaim_group:selectable('  Antiaim Tweaks', {'Anti-Aim on Use', 'Bombsite E Fix', 'Disable on Warmup', 'Static on Manual'})
                --elements.antiaims.anim_breakers = antiaim_group:selectable('Anim. Breakers', {'Landing Pitch', 'Force Falling', 'Move Lean', 'Leg Breaker'})
                elements.antiaims.manual_aa = antiaim_group:combo('  Manual Anti-aim', {'Disabled', 'Left', 'Right', 'Forward'})

                --sound ambient
                elements.s_amb.announcements = sound_ambient_group:switch '  Announcements' do
                    local settings = elements.s_amb.announcements:create()

                    elements.s_amb.announcements_volume = settings:slider('  Volume', 0, 100, 80, nil, function(val) return val .. '%' end)
                end
                elements.s_amb.hitsounds = sound_ambient_group:switch '  Hit Sounds' do
                    local settings = elements.s_amb.hitsounds:create()

                    elements.s_amb.hitsounds_volume = settings:slider('  Volume', 0, 100, 75, nil, function(val) return val .. '%' end)
                end
                elements.s_amb.killdeathsounds = sound_ambient_group:switch '  Kill/Death Sounds' do
                    local settings = elements.s_amb.killdeathsounds:create()

                    elements.s_amb.killdeathsounds_volume = settings:slider('  Volume', 0, 100, 75, nil, function(val) return val .. '%' end)
                end
                elements.s_amb.nothing = sound_ambient_group:switch '\a222223C8Nothing'

                local menu_handle do
                    elements.visuals.select_log:set_callback(function(self)
                        local state = self:get('Under crosshair')

                        elements.visuals.log_engine_type:visibility(self:get('Upper-left'))
                        ui_handle(state, {
                            elements.visuals.maximum_count,
                            elements.visuals.appear_time,
                            elements.visuals.aimbot_glowing,
                            elements.visuals.log_manage_colors
                        })
                    end, true)

                    elements.misc.killsay_select:set_callback(function(self)
                        local state = #self:get()

                        elements.misc.killsay_disablers:visibility(state > 0)
                        elements.misc.killsay_multiplier:visibility(state > 0)
                    end)
                end
            end

            local keybinds_drag = misc_group:switch("hdfghdfghdfghf"):visibility(false)
            local speclist_drag = misc_group:switch("hfghfg12312312kg"):visibility(false)
            local slowdown_drag = misc_group:switch("sdfgsdgsdf2"):visibility(false)
            local damage_ind_drag = misc_group:switch("sdfdfsdfsdfgsdgsdf"):visibility(false)
            local watermark_drag = misc_group:switch('cnxkasidhe8123'):visibility(false)

            local antiaim_builder do
                antiaim_builder = {  }
                local the_most_lol_ever do
                    local spaces = {'', ' ', '  ', '   ', '     ', '         ', '       '}

                    for i=1, 7 do
                        elements.antiaims_builder[i] = {  }

                        elements.antiaims_builder[i].enabled = antiaims_builder_tab:switch( "Enable Condition".. spaces[i], false)
                        elements.antiaims_builder[i].pitch = antiaims_builder_tab:combo( "Pitch".. spaces[i], {"Disabled", "Down", "Fake Down", "Fake Up"})
                        elements.antiaims_builder[i].yaw = antiaims_builder_tab:combo('Yaw'.. spaces[i], {'Backward', 'At Target'}) do
                            local settings = elements.antiaims_builder[i].yaw:create()

                            elements.antiaims_builder[i].yaw_slider_main = settings:slider("Yaw Offset L".. spaces[i], -180, 180, 0, nil, function(val) return val .. '°' end)
                            elements.antiaims_builder[i].yaw_slider_next = settings:slider("Yaw Offset R".. spaces[i], -180, 180, 0, nil, function(val) return val .. '°' end)
                        end
                        elements.antiaims_builder[i].jyaw = antiaims_builder_tab:combo("Yaw Modifier".. spaces[i], {"Disabled", "Center", "Offset", "N-Way", "Random", "Spin"}, 0) do
                            local settings = elements.antiaims_builder[i].jyaw:create()

                            elements.antiaims_builder[i].jyaw_type = settings:combo('Type'.. spaces[i], 'Default', 'Update', 'Break', 'Switch', 'Random')
                            elements.antiaims_builder[i].jyaw_slider = settings:slider('Modifier Offset'.. spaces[i], -180, 180, 0)
                            elements.antiaims_builder[i]._offset = settings:slider('Offset 1'.. spaces[i], -180, 180, 0)
                            elements.antiaims_builder[i].__offset = settings:slider('Offset 2'.. spaces[i], -180, 180, 0)
                        end
                        elements.antiaims_builder[i].n_way_label = antiaims_builder_tab:label('N-Way Modifier'.. spaces[i]) do
                            local settings = elements.antiaims_builder[i].n_way_label:create()

                            elements.antiaims_builder[i].n_way_jitter_mode = settings:combo('Jitter Mode'.. spaces[i], {'Static', 'Dynamic'})
                            elements.antiaims_builder[i].n_way_jitter_main = settings:slider('Jitter Offset'.. spaces[i], -180, 180, 0, nil, function(val) return val .. '°' end)
                            elements.antiaims_builder[i].n_way_jitter_alternative = settings:slider('Jitter Offset #2'.. spaces[i], -180, 180, 0, nil, function(val) return val .. '°' end)
                            elements.antiaims_builder[i].n_way_amount = settings:slider('Max. amount'.. spaces[i], 3, 12, 5, nil, function(val) return val .. ' Way' end)
                            elements.antiaims_builder[i].apply_current_yaw = settings:switch('\aEBD68DC8Apply Current Yaw'.. spaces[i])
                        end
                        elements.antiaims_builder[i].bodyyaw = antiaims_builder_tab:switch('Body Yaw'.. spaces[i]) do
                            local settings = elements.antiaims_builder[i].bodyyaw:create()

                            elements.antiaims_builder[i].fake_op = settings:selectable("Fake Options".. spaces[i], {"Avoid Overlap", "Jitter", "Randomize Jitter", "Anti Bruteforce"}, 0)
                            elements.antiaims_builder[i].fake_mode = settings:combo("Fake Yaw Mode".. spaces[i], {"Default", "According Side", "Random"}, 0)
                            elements.antiaims_builder[i].fake_slider_main = settings:slider("Fake Limit".. spaces[i], 0, 60, 60, nil, function(val) return val .. '°' end)
                            elements.antiaims_builder[i].fake_slider_next = settings:slider("Fake Limit #2".. spaces[i], 0, 60, 60, nil, function(val) return val .. '°' end)
                            elements.antiaims_builder[i].freestand = settings:combo("Freestand Des.".. spaces[i], {"Off", "Peek Fake", "Peek Real"}, 0)
                        end

                        elements.antiaims_builder[i].defensive_aa = antiaims_builder_tab:switch ('Defensive AA'.. spaces[i]) do
                            local self_element = elements.antiaims_builder[i]

                            local settings = self_element.defensive_aa:create()
                            elements.antiaims_builder[i].defensive_pitch = settings:combo('Pitch', 'Default', 'Switch Down', 'Switch Up', 'Random', 'Up')
                            elements.antiaims_builder[i].defensive_yaw = settings:combo('Yaw', 'Default', 'Forward', 'Spin', 'Random', 'Free Sway', 'Switch Left', 'Switch Right')

                            self_element.defensive_aa:name(
                                string.format('\aF1E6D9FF%s %s', ui.get_icon 'helicopter', self_element.defensive_aa:name())
                            )
                        end
                    end
                end

                local custom_aa = elements.antiaims_builder

                for i=1, #custom_aa do
                    for n,v in pairs(custom_aa[i]) do
                        v:set_callback(function(ctx)

                            local has_active = self.cheat.active_this_frame.idx
                             --print(has_active)

                        end)
                    end
                end

                antiaim_builder.hide_all_custom = function()
                    for i = 1, 7 do
                        for _, k in pairs(custom_aa[i]) do
                            if not k:visibility() then goto skip end
                            k:visibility(false)
                            ::skip::
                        end
                    end
                end

                antiaim_builder.unhide_cur_custom = function(zxc, num)
                    if custom_aa[num].enabled:get() then
                        for _, k in pairs(custom_aa[num]) do
                            if k:visibility() then goto skip end
                            k:visibility(true)
                            ::skip::
                        end
                    else
                        for _, k in pairs(custom_aa[num]) do
                            if not k:visibility() then goto skip end
                            k:visibility(false)
                            ::skip::
                        end
                    end

                    custom_aa[num].enabled:visibility(true)
                end

                antiaim_builder.unhide_cur_enable_state = function(zxc, num)
                    custom_aa[num].enabled:visibility(true)
                end

                antiaim_builder.additions_hide = function(zxc, num)
                    if not custom_aa[num].enabled:get() then return end

                    custom_aa[num].fake_slider_next:visibility(custom_aa[num].fake_mode:get() ~= "Default")
                    custom_aa[num].n_way_label:visibility(custom_aa[num].jyaw:get() == 'N-Way')
                    custom_aa[num].n_way_jitter_alternative:visibility(custom_aa[num].n_way_jitter_mode:get() == 'Dynamic')

                    local c = custom_aa[num]
                    local state = custom_aa[num].jyaw:get() ~= 'N-Way'
                    local tbl = {c.jyaw_type, c.jyaw_slider, c.__offset, c._offset}

                    for _,var in pairs(tbl) do
                        var:visibility(state)

                        custom_aa[num]._offset:visibility(custom_aa[num].jyaw_type:get() ~= 'Default' and state)
                        custom_aa[num].__offset:visibility(custom_aa[num].jyaw_type:get() ~= 'Default' and state)
                        custom_aa[num].jyaw_slider:visibility(custom_aa[num].jyaw_type:get() == 'Default' and state)
                    end

                    custom_aa[num].fake_slider_main:name(
                        custom_aa[num].fake_mode:get() == "According Side" and 'Fake Limit Left' or 'Fake Limit'
                    )
                    custom_aa[num].fake_slider_next:name(
                        custom_aa[num].fake_mode:get() == "According Side" and 'Fake Limit Right' or 'Fake Limit #2'
                    )
                end

                antiaim_builder.strange = function(zxc, condition_tab)

                    if condition_tab == 'Global' then
                        return 0
                    elseif condition_tab == 'Standing' then
                        return 1
                    elseif condition_tab == 'Moving' then
                        return 2
                    elseif condition_tab == 'Slow motion' then
                        return 3
                    elseif condition_tab == 'Air' then
                        return 4
                    elseif condition_tab == 'Air Crouch' then
                        return 5
                    elseif condition_tab == 'Crouch' then
                        return 6
                    elseif condition_tab == 'Dormant' then
                        return 7
                    end
                end

                antiaim_builder.char_condition = function(_condition)
                    if _condition == 2 then
                        return '\aFFFFFFFF- \aDEFAULTstanding\aFFFFFFFF -'
                    elseif _condition == 3 then
                        return '\aFFFFFFFF- \aDEFAULTmoving\aFFFFFFFF -'
                    elseif _condition == 4 then
                        return '\aFFFFFFFF- \aDEFAULTwalking\aFFFFFFFF -'
                    elseif _condition == 5 then
                        return '\aFFFFFFFF- \aDEFAULTair\aFFFFFFFF -'
                    elseif _condition == 6 then
                        return '\aFFFFFFFF- \aDEFAULTair\aFFFFFFFF -'
                    elseif _condition == 7 then
                        return '\aFFFFFFFF- \aDEFAULTcrouch\aFFFFFFFF -'
                    end
                end

                antiaim_builder.state = function(asd, lp_vel, player, cmd)
                    local is_crouching = function()
                        local localplayer = entity_get_local_player()
                        local flags = localplayer['m_fFlags']

                        if bit.band(flags, 4) == 4 then
                            return true
                        end

                        return false
                    end

                    if lp_vel == nil then
                        return
                    end

                    player = 0
                    local get_player = nil
                    local is_dormant = false
                    local localplayer = entity_get_local_player()

                    if false then
                        cnds = 8
                    elseif lp_vel < 5 and not cmd.in_jump and not (is_crouching(localplayer) or self.refs.fake_duck:get()) then
                        cnds = 2
                    elseif cmd.in_jump and not is_crouching(localplayer) then
                        cnds = 5
                    elseif cmd.in_jump and is_crouching(localplayer) then
                        cnds = 6
                    elseif (is_crouching(localplayer) or self.refs.fake_duck:get()) then
                        cnds = 7
                    else
                        if self.refs.slowwalk:get() then
                        cnds = 4
                        else
                        cnds = 3
                        end
                    end

                    return cnds
                end

                antiaim_builder.flick_fake = function(b,c,d)local e=globals.tickcount%(b+1)local f=e==1;if flick_value_fake==nil then flick_value=c end;if f==true then flick_value_fake=flick_value==c and d or c end;return flick_value_fake end
                antiaim_builder.flick_yaw = function(b,c,d)local e=globals.tickcount%(b+1)local f=e==1;if flick_value_yaw==nil then flick_value_yaw=c end;if f==true then flick_value_yaw=flick_value_yaw==c and d or c end;return flick_value_yaw end

                local randomized_5yaw_offset = 0

                local mode_5yaw do
                    antiaim_builder.do_5way = function(zxc, c, base_offset, state, aa_tbl)
                        if c.choked_commands > 0 then
                            return
                        end


                        return '5-Way'
                    end
                end

                local Defensive_DT do
                    local g_origin = {  }
                    local g_lc = {  }

                    local function breaking_lc(ent)
                        local m_flOldSimulationTime = ent:get_simulation_time().old
                        local m_flSimulationTime = ent:get_simulation_time().current

                        if m_flSimulationTime - m_flOldSimulationTime == 0 then
                            return g_lc[ent]
                        end

                        local origin = ent:get_origin()

                        g_origin[ent] = g_origin[ent] or origin
                        if not ent:is_alive() then
                            return false
                        end

                        if m_flSimulationTime < m_flOldSimulationTime then
                            return true
                        end

                        if (origin - g_origin[ent]):lengthsqr() > 4096 then
                            g_origin[ent] = origin
                            return true
                        end

                        g_origin[ent] = origin
                        return false
                    end

                    events.round_start:set(function()
                        g_origin = {  }
                        g_lc = {  }
                    end)

                    events.net_update_end:set(function()
                        local ent = unpack(entity.get_players())

                        g_lc[ent:get_index()] = breaking_lc(ent)
                    end)

                    Defensive_DT = g_lc
                end

                local switchChoke = false

                local breaker_ticks = 0
                local aa_data = {
                    breaker = {
                        cmd = 0,
                        defensive = 0,
                        defensive_check = 0,
                    },
                }

                events.createmove:set(function(cmd)
                    aa_data.breaker.cmd = cmd.command_number
                end)

                events.createmove_run:set(function(cmd)
                    if cmd.command_number == aa_data.breaker.cmd then
                        local me = entity.get_local_player()

                        local tickbase = me.m_nTickBase
                        aa_data.breaker.defensive = math.abs(tickbase - aa_data.breaker.defensive_check)
                        aa_data.breaker.defensive_check = math.max(tickbase, aa_data.breaker.defensive_check)
                        aa_data.breaker.cmd = 0
                    end
                end)

                antiaim_builder.custom_preset = function()
                    local switch_side = false
                    local update_tick = 64
                    local update_mode = 0

                    events.createmove:set(function(cmd)
                        local side = rage.antiaim:inverter()

                        local lp = entity_get_local_player()
                        local lp_vel = self.tools:get_velocity(lp)
                        local state = antiaim_builder:state(lp_vel, nil, cmd)
                        self.local_condition = antiaim_builder.char_condition(state):upper()

                        local b, c = state, side
                        if custom_aa[b] == nil then
                            return
                        end

                        if elements.antiaims.antiaim_mode:get() ~= 2 then
                            return
                        end

                        local d = custom_aa[b].enabled:get() and b or 1
                        local yaw_offset = side and custom_aa[d].yaw_slider_main:get() or custom_aa[d].yaw_slider_next:get()

                        self.refs.pitch:override(custom_aa[d].pitch:get())
                        self.refs.yaw_base:override('Backward')
                        self.refs.enable_desync:override(custom_aa[d].bodyyaw:get())

                        if globals.tickcount % 3 == 0 then
                            switch_side = not switch_side
                        end

                        if globals.tickcount % update_tick == update_tick - 1 then
                            update_tick = math.random(8, 14)

                            update_mode =  math.random(
                                custom_aa[d]._offset:get(), custom_aa[d].__offset:get()
                            )*(math.random(0, 1) == 1 and 1 or -1)
                        end

                        local side_ref = side and self.refs.left_limit or self.refs.right_limit
                        local jyaw_switch_val = switch_side and custom_aa[d]._offset or custom_aa[d].__offset

                        if custom_aa[d].fake_mode:get() == 'Default' then
                            side_ref:override(custom_aa[d].fake_slider_main:get())
                        elseif custom_aa[d].fake_mode:get() == 'Random' then
                            side_ref:override(math_random(custom_aa[d].fake_slider_main:get(), custom_aa[d].fake_slider_next:get()))
                        elseif custom_aa[d].fake_mode:get() == 'According Side' then
                            self.refs.left_limit:override(custom_aa[d].fake_slider_main:get())
                            self.refs.right_limit:override(custom_aa[d].fake_slider_next:get())
                        end

                        yaw_offset = custom_aa[d].apply_current_yaw:get() and yaw_offset or 0

                        self.refs.jyaw:override(custom_aa[d].jyaw:get() == 'N-Way' and antiaim_builder:do_5way(cmd, yaw_offset, state, custom_aa[d]) or custom_aa[d].jyaw:get())

                        if custom_aa[d].jyaw_type:get() == 'Switch' then
                            self.refs.jyaw_slider:override(jyaw_switch_val:get())
                        elseif custom_aa[d].jyaw_type:get() == 'Random' then
                            self.refs.jyaw_slider:override(math.random(
                                custom_aa[d]._offset:get(), custom_aa[d].__offset:get()
                            ))
                        elseif custom_aa[d].jyaw_type:get() == 'Update' then
                            self.refs.jyaw_slider:override(update_mode)
                        elseif custom_aa[d].jyaw_type:get() == 'Break' then
                            self.refs.jyaw_slider:override(cmd.choked_commands == 0 and custom_aa[d]._offset:get() or custom_aa[d].__offset:get())
                        else
                            self.refs.jyaw_slider:override(custom_aa[d].jyaw_slider:get())
                        end

                        self.refs.fake_op:override(custom_aa[d].fake_op:get())
                        self.refs.freestand:override(custom_aa[d].freestand:get())

                        if custom_aa[d].jyaw:get() ~= 'N-Way' then
                            self.refs.yaw:override(side and custom_aa[d].yaw_slider_main:get() or custom_aa[d].yaw_slider_next:get())
                        end

                        local defensiveYawState = custom_aa[d].defensive_yaw:get()
                        local defensivePitchState = custom_aa[d].defensive_pitch:get()

                        local tickcountValidation do
                            tickcountValidation = globals.tickcount % 4 == 0

                            if tickcountValidation then
                                switchChoke = not switchChoke
                            end
                        end

                        local pitchModifier = function()
                            local outputValue

                            if defensivePitchState == 'Switch Down' then
                                outputValue = switchChoke and 0 or 89
                            elseif defensivePitchState == 'Switch Up' then
                                outputValue = switchChoke and 0 or -89
                            elseif defensivePitchState == 'Random' then
                                outputValue = utils.random_int(-89, 89)
                            elseif defensivePitchState == 'Up' then
                                outputValue = -89
                            end

                            return outputValue
                        end

                        local yawModifier = function()
                            local outputValue

                            if defensiveYawState == 'Forward' then
                                outputValue = utils.random_int(-180, -145)
                            elseif defensiveYawState == 'Switch Left' then
                                outputValue = switchChoke and 90 or 0
                            elseif defensiveYawState == 'Switch Right' then
                                outputValue = switchChoke and -90 or 0
                            elseif defensiveYawState == 'Random' then
                                outputValue = utils.random_int(-180, 180)
                            elseif defensiveYawState == 'Free Sway' then
                                outputValue = switchChoke and utils.random_int(0, 168) or utils.random_int(-168, -31)
                            end

                            return outputValue
                        end

                        if custom_aa[d].defensive_aa:get() then
                            if defensiveYawState ~= 'Default' and defensiveYawState ~= 'Spin' then
                                rage.antiaim:override_hidden_yaw_offset(yawModifier())
                            end

                            if defensivePitchState ~= 'Default' then
                                rage.antiaim:override_hidden_pitch(pitchModifier())
                            end
                        end

                        local f = elements.antiaims.manual_aa:get()

                        if (f == "Right" or f == "Left" or self.refs.freestanding_yaw:get()) and elements.antiaims.antiaims_tweaks:get("Static on Manual") then
                            self.refs.fake_op:override({  })
                            self.refs.jyaw:override("Disabled")
                        end

                        self.refs.base_yaw:override(f ~= 'Disabled' and 'Local view' or nil)
                        if f ~= 'Disabled' then
                            self.refs.yaw:override(f == 'Left' and -90 or (f == 'Right' and 90 or 180))
                        end

                        self.refs.hidden:override(custom_aa[d].defensive_aa:get())
                    end)
                end

                antiaim_builder.init_handle = function(self)
                    events.pre_render:set(function()
                        if ui_get_alpha() ~= 1 then return end

                        local state = elements.antiaims.antiaim_mode:get()
                        antiaim_builder:hide_all_custom()
                        elements.antiaims.condition:visibility(state == 2)

                        if state == 2 then
                            antiaim_builder:unhide_cur_custom(antiaim_builder:strange(elements.antiaims.condition:get()) + 1)
                            antiaim_builder:unhide_cur_enable_state(antiaim_builder:strange(elements.antiaims.condition:get()) + 1)
                            custom_aa[1].enabled:visibility(false)
                            custom_aa[1].enabled:set(true)
                            antiaim_builder:additions_hide(antiaim_builder:strange(elements.antiaims.condition:get()) + 1)
                            elements.antiaims.condition:visibility(true)
                            antiaims_builder_tab:name('Envious - ' .. elements.antiaims.condition:get())
                        end

                    end)
                end
            end

            --globalize variables
            self.global = global
            self.elements = elements
            self.slowdown_drag = slowdown_drag
            self.keybinds_drag = keybinds_drag
            self.speclist_drag = speclist_drag
            self.watermark_drag = watermark_drag
            self.damage_ind_drag = damage_ind_drag
            self.antiaim_builder = antiaim_builder

            --set callbacks
            antiaim_builder:init_handle()
            antiaim_builder:custom_preset()
        end
    }

    :struct 'config_system' {
        init = function(self)
            local Cipher do
                local Cipher_code = 'removed'

                local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
                function Xor(a,b)local c;local d=""for e=1,string.len(a),1 do c=e;if string.len(b)<c then c=c%string.len(b)end;d=d..string.char(bit.bxor(string.byte(string.sub(a,e,e)),string.byte(string.sub(b,c,c))))end;return d end

                Cipher = {
                    encode = function(a, b)
                        return '[Envious]' .. tostring(base64.encode(Xor(a,Cipher_code))) .. '[/Envious]'
                    end,

                    decode = function(a, b)
                        local prefix = '[Envious]'
                        local bypassed_prefix = '[/Envious]'

                        local q,e = a:find(prefix, 1, true)
                        local z,x = a:find(bypassed_prefix, 1, true)

                        a = a:sub(e + 1, z - 1):gsub(' ', '')

                        return tostring(Xor(base64.decode(a),Cipher_code))
                    end
                }
            end

            local config_system do
                config_system = {  }

                local update_list = function(list)
                    local name_list = {  }

                    for idx, data in pairs(list) do
                        table.insert(name_list, data.name) --data.active and data.name ..' \a73BCEDFF- Active' or data.name
                    end

                    fucking_configs = list
                    return #name_list ~= 0 and name_list or {'\aCBC9C9FFNothing there. Create preset or import it.'}
                end

                local update_deleted = function(list)
                    local name_list = {  }

                    for idx, data in pairs(list) do
                        table.insert(name_list, data.name)
                    end

                    db.ym_deleted_configs = list
                    return #name_list ~= 0 and name_list or {'\aCBC9C9FFNothing there.'}
                end

                config_system.export = function(self)
                    local entries_count = 0

                    local config = {  }
                    local ignore_list = { settings = true }

                    local export = function(tbl, name, value)
                        local value = value:get()

                        tbl[name] = get_type(value) == 'imcolor' and value:to_hex() or value
                        entries_count = entries_count + 1
                    end

                    for name, value in pairs(self.menu.elements) do
                        if ignore_list[name] == nil then
                            if get_type(value) == 'table' then
                                for n, v in pairs(value) do
                                    if get_type(v) ~= 'table' then
                                        export(config, n, v)
                                    else
                                        for n, v in pairs(v) do
                                            export(config, tostring(v:name()), v)
                                        end
                                    end
                                end
                            else
                                export(config, name, value)
                            end
                        end
                    end

                    common_add_notify(self.cheat.lua .. '.lua', ('Exported %i entries to clipboard'):format(entries_count))
                    cvar.play:call("ambient\\tones\\elev1")

                    config = Cipher.encode(json.stringify(config))
                    clipboard.set(config)

                    return Cipher.encode(config)
                end

                config_system.import = function(self, ignore, dti, t)
                    local ignore_list = ignore or { settings = true }
                    local data_to_import = dti or clipboard.get()

                    local success, preset = pcall(function()
                        local unhash = Cipher.decode(data_to_import)

                        return t and json.parse(Cipher.decode(unhash)) or json.parse(unhash)
                    end)

                    if not success then
                        self.tools.play_sound('error.wav', 0.12)
                        common_add_notify(self.cheat.lua .. '.lua', 'There was an error while importing your preset')
                        return
                    end

                    local entries_count = 0
                    local function import(el, value)
                        el:set(value)
                        entries_count = entries_count + 1
                    end

                    for tab, element in pairs(self.menu.elements) do
                        if ignore_list[tab] == nil then
                            for name, value in pairs(preset) do
                                local ref = element[name]

                                if tab == 'antiaims_builder' then
                                    ref = element

                                    for i=1, #ref do
                                        for k,v in pairs(ref[i]) do

                                            if name == v:name() then
                                                import(v, value)
                                            end
                                        end
                                    end
                                end

                                if get_type(ref) ~= 'table' then
                                    if ref ~= nil then
                                        if tostring(ref):find 'color_picker' then
                                            value = color(value)
                                        end

                                        import(ref, value)
                                    end
                                end
                            end
                        end
                    end
                    common_add_notify(self.cheat.lua .. '.lua', ('Imported %i entries from clipboard'):format(entries_count))
                    cvar.play:call("ambient\\tones\\elev1")
                    return true
                end

                config_system.save = function(self)
                    local preset_name = self.menu.global.preset_name:get():gsub(' ', '')
                    local was_exist = false
                    local list = fucking_configs or {'\aCBC9C9FFNothing there. Create preset or import it.'}

                    if #preset_name == 0 then
                        self.tools.play_sound('error.wav', 0.12)
                        common_add_notify(self.cheat.lua .. '.lua', '⚠ Enter a valid config name!')

                        return
                    end

                    for i=1, #list do
                        if list[i].name == preset_name then
                            list[i].code = config_system.export(self)

                            was_exist = true
                        end
                    end

                    if not was_exist then
                        table.insert(list, {
                            name = preset_name,
                            code = config_system.export(self),
                            active = false,
                            author = self.cheat.username
                        })
                    end

                    self.menu.global.preset_list:update(update_list(list))
                end

                config_system.delete = function(self)
                    local preset_name = self.menu.global.preset_name:get():gsub(' ', '')
                    local list = fucking_configs or {'\aCBC9C9FFNothing there. Create preset or import it.'}
                    local num = #list

                    if #list == 0 then
                        self.tools.play_sound('error.wav', 0.12)
                        common_add_notify(self.cheat.lua .. '.lua', '⚠ There is nothing to delete!\nCreate a new preset..') return
                    end

                    local found_preset = false
                    for i=1, #list do
                        if list[i].name == preset_name then
                            found_preset = true
                            table.remove(list, i)
                        end
                    end

                    if not found_preset then
                        self.tools.play_sound('error.wav', 0.12)
                        common_add_notify(self.cheat.lua .. '.lua', '⚠ Couldn\'t find the preset!\nCheck the correctness..') return
                    end

                    self.menu.global.preset_list:update(update_list(list))
                end

                config_system.load = function(self)
                    local num = self.menu.global.preset_list:get()
                    local preset_name = self.menu.global.preset_name:get():gsub(' ', '')
                    local list = fucking_configs

                    if #list == 0 then
                        self.tools.play_sound('error.wav', 0.12)
                        common_add_notify(self.cheat.lua .. '.lua', '⚠ There is nothing to load!\nCreate a new preset..') return
                    end
                    local is_exists = false

                    for i=1, #list do
                        if list[i].name == preset_name then
                            is_exists = true
                        end
                    end

                    if not is_exists then
                        self.tools.play_sound('error.wav', 0.12)
                        common_add_notify(self.cheat.lua .. '.lua', '⚠ Couldn\'t find the preset!\nCheck the correctness..') return
                    end

                    for i=1, #list do
                        list[i].active = false

                        if list[i].name == preset_name then
                            list[i].active = false

                            local success = config_system.import(self, {
                                ragebot = false,
                                visuals = false,
                                misc = false
                            }, Cipher.decode(list[i].code))

                            if success then
                                print_raw(("Config by %s was loaded successully!"):format(list[i].author))
                                self.menu.global.preset_list:update(update_list(list))
                            else
                                self.tools.play_sound('error.wav', 0.12)
                                common_add_notify(self.cheat.lua .. '.lua', '⚠ An unknown error. Please contact the administrator!') return
                            end
                        end
                    end
                end

                config_system.export_aa_tab = function(self)
                    local preset_name = self.menu.global.preset_name:get():gsub(' ', '')
                    local list = fucking_configs

                    if #list == 0 then
                        self.tools.play_sound('error.wav', 0.12)
                        common_add_notify(self.cheat.lua .. '.lua', '⚠ There is nothing to export! Create a new preset..') return
                    end

                    local data
                    for i=1, #list do
                        if list[i].name == preset_name then
                            data = {
                                name = preset_name,
                                code = list[i].code,
                                active = false,
                                author = list[i].author
                            }
                        end
                    end

                    if data ~= nil then
                        clipboard.set(Cipher.encode(json.stringify(data)))
                        cvar.play:call("ambient\\tones\\elev1")
                        common_add_notify(self.cheat.lua .. '.lua', 'Successully exported your preset!')
                    else
                        self.tools.play_sound('error.wav', 0.12)
                        common_add_notify(self.cheat.lua .. '.lua', '⚠ Couldn\'t find the preset!\nCheck the correctness..') return
                    end
                end

                config_system.import_aa_tab = function(self)
                    local list = fucking_configs
                    local success, preset = pcall(function()
                        return json.parse(Cipher.decode(clipboard.get()))
                    end)

                    if not success or preset.code == nil then
                        self.tools.play_sound('error.wav', 0.12)
                        common_add_notify(self.cheat.lua .. '.lua', 'There was an error while importing your preset!') return
                    end

                    local ignore_list = {
                        ragebot = true,
                        visuals = true,
                        misc = true,
                        settings = true,
                    }

                    local was_exist = false
                    for i=1, #list do
                        if preset.name == list[i].name then
                            was_exist = true
                            list[i].code = preset.code

                            break
                        end
                    end

                    if not was_exist then
                        table.insert(list, {
                            name = preset.name,
                            code = preset.code,
                            active = false,
                            author = preset.author
                        })
                    end

                    cvar.play:call("ambient\\tones\\elev1")
                    common_add_notify(self.cheat.lua .. '.lua', ("Config by %s was imported successully!"):format(preset.author))
                    self.menu.global.preset_list:update(update_list(list))
                end


            end

            self.save = config_system.save
            self.delete = config_system.delete
            self.import = config_system.import
            self.export = config_system.export
            self.export_aa_tab = config_system.export_aa_tab
            self.import_aa_tab = config_system.import_aa_tab
            self.load = config_system.load
            self.restore_preset = config_system.restore_preset
            self.finally_delete_preset = config_system.finally_delete_preset
            self.erase_all_deleted = config_system.erase_all_deleted
            self.Cipher = Cipher
        end
    }

    :struct 'tweaks' {
        anti_aim_on_use = false,
        start_curtime = globals.curtime,

        anti_aim_on_use_main = function(self, cmd)
            local local_player = entity_get_local_player()
            if local_player == nil then return end
            local m_iTeamNum = local_player.m_iTeamNum
            local use = bit.rshift(bit.lshift(cmd.buttons, 26), 31)
            local base = self.refs.base_yaw
            local mod = self.refs.jyaw
            if local_player:get_player_weapon() == nil then return end

            local anti_aim_on_use_work = true
            for i, entities in pairs({entity_get_entities("CPlantedC4"), entity_get_entities("CHostage")}) do
                for i, entity in pairs(entities) do
                    if local_player:get_origin():dist(entity:get_origin()) < 65 and local_player:get_origin():dist(entity:get_origin()) > 1 and m_iTeamNum == 3 then
                        anti_aim_on_use_work = false
                    end
                end
            end

            if m_iTeamNum == 2 and local_player.m_binBombZone and local_player:get_player_weapon():get_weapon_index() == 49 then
                anti_aim_on_use_work = false
            end

            if self.menu.elements.antiaims.antiaims_tweaks:get('Anti-Aim on Use') and use ~= 0 and anti_aim_on_use_work then
                if globals.curtime - self.start_curtime > 0.02 then
                    cmd.buttons = bit.band(cmd.buttons, bit.bnot(32))
                    self.anti_aim_on_use = true
                    self.refs.yaw:override(5)
                    self.refs.left_limit:override(60)
                    self.refs.right_limit:override(60)
                    self.refs.pitch:override('Disabled')
                    self.refs.yaw_base:override('Disabled')
                    mod:override('Disabled')
                    base:override('Local View')
                else
                    self.refs.yaw:override()
                    self.refs.left_limit:override()
                    self.refs.right_limit:override()
                    self.refs.pitch:override()
                    self.refs.yaw_base:override()
                    mod:override()
                    base:override()
                end
            else
                self.start_curtime = globals.curtime
                self.anti_aim_on_use = false
            end
        end,

        bombsitefix = function(self, c)
            if self.menu.elements.antiaims.antiaims_tweaks:get('Bombsite E Fix') then
            local me = entity_get_local_player()

            if entity_get_local_player() == nil then return end
            if me:get_player_weapon() == nil then return end
            local team_num, on_bombsite, defusing = me.m_iTeamNum, me.m_binBombZone, team_num == 3
            local trynna_plant = team_num == 2 and has_bomb
            local inbomb = on_bombsite ~= false

            local use = common_is_button_down(0x45)
            local base = self.refs.base_yaw
            local mod = self.refs.jyaw
            local offset = self.refs.yaw

            local freestand = ui_find("Aimbot", "Anti Aim", "Angles", "Freestanding")
            if not inbomb and self.menu.elements.antiaims.antiaims_tweaks:get('Anti-Aim on Use') then return end
            if inbomb and not trynna_plant and not defusing and use then
                self.refs.yaw:override(0)
                self.refs.left_limit:override(0)
                self.refs.right_limit:override(0)
                self.refs.pitch:override('Disabled')
                mod:override('Disabled')
                base:override('Local View')
            end

            if inbomb and not trynna_plant and not defusing then
                c.in_use = 0
            end

            end
        end,
    }

    :struct 'slowdown_indicator' {
        warning = render_load_image_from_file("materials\\panorama\\images\\icons\\ui\\warning.svg", vector(500, 500)),
        r_font = render_load_font('nl\\Envious\\sans700.ttf', 12, 'du'),
        interval = 0,

        rgb_health_based = function(percentage)
            local r = 124*2 - 124 * percentage
            local g = 195 * percentage
            local b = 13
            return r, g, b
        end,

        remap = function(val, newmin, newmax, min, max, clamp)
            min = min or 0
            max = max or 1

            local pct = (val-min)/(max-min)

            if clamp ~= false then
                pct = math_min(1, math_max(0, pct))
            end

            return newmin+(newmax-newmin)*pct
        end,

        init = function(self)
            local new_interp_fn = smoothy.new({
                global_alpha = 0,
                dpi_modifier = 100
            })

            local group = ui_create('Global', 'Dragging shit..')
            local x = group:slider("x", 0, self.cheat.screen_size.x, 300):visibility(false)
            local y = group:slider("y", 0, self.cheat.screen_size.y, 100):visibility(false)
            local DPI_Scale = group:slider('xixixixi', 75, 200, 100);DPI_Scale:visibility(false)
            local width, height

            local is_in_area = false
            local m_pos = ui_get_mouse_position()
            local x_sl, y_sl = x, y

            local area_box = function(dg)
                is_in_area = dg.list.in_drag_area

                new_interp_fn(0.1, {
                    size_y = dg.size.y,
                    size_x = dg.size.x
                })


                render_rect_outline(vector(dg.position.x, dg.position.y), vector(dg.position.x + (new_interp_fn.value.size_x), dg.position.y + (new_interp_fn.value.size_y)), color(85, 85, 85):alpha_modulate(ui_get_alpha()*255*new_interp_fn.value.global_alpha), 0, 4)
                --render_blur(vector(dg.position.x, dg.position.y), vector(dg.position.x + dg.size.x, dg.position.y + dg.size.y), 25, ui_get_alpha()*new_interp_fn.value.global_alpha, 4)
                render_rect(vector(dg.position.x, dg.position.y), vector(dg.position.x + (new_interp_fn.value.size_x), dg.position.y + (new_interp_fn.value.size_y)), color(85, 85, 85):alpha_modulate(ui_get_alpha()*75*new_interp_fn.value.global_alpha), 4)

                x,y = dg.position.x, dg.position.y
                width, height = new_interp_fn.value.size_x*new_interp_fn.value.dpi_modifier/100, new_interp_fn.value.size_y*new_interp_fn.value.dpi_modifier/100
            end

            local new_drag_object = dragging_fn().register({x, y}, vector(150*DPI_Scale:get()/100, 50*DPI_Scale:get()/100), "slowdown_indicator", area_box)

            events['mouse_input']:set(function(c)
                if not is_in_area or not self.menu.elements.settings.dragables_control:get('Scroll Resize') then
                    return
                end


                if c.wheel == -1 then DPI_Scale:set(DPI_Scale:get()-25) new_drag_object = dragging_fn().register({x_sl, y_sl}, vector(150*DPI_Scale:get()/100, 50*DPI_Scale:get()/100), "slowdown_indicator", function(self) area_box(self) end) elseif c.wheel == 1 then DPI_Scale:set(DPI_Scale:get()+25) new_drag_object = dragging_fn().register({x_sl, y_sl}, vector(150*DPI_Scale:get()/100, 50*DPI_Scale:get()/100), "slowdown_indicator", function(self) area_box(self) end) end
                --return false
            end)

            events.render:set(function()
                local new_interp = new_interp_fn.value
                new_interp_fn(0.1, {
                    global_alpha = (self.menu.elements.visuals.solus_select:get('Velocity Warning') and self.menu.elements.visuals.Widgets:get() ) and 1 or 0,
                    dpi_modifier = DPI_Scale:get(),
                })

                if new_interp.global_alpha == 0 then return end
                new_drag_object:update(
                    self.menu.elements.settings.dragables_control:get('Center Magnitize')
                )

                local lp = entity_get_local_player()
                local menu_alpha = ui_get_alpha()

                local modifier
                if not lp or not lp:is_alive() then
                    modifier = 1
                else
                    modifier = lp["m_flVelocityModifier"]
                end

                if modifier == 1 and menu_alpha == 0 then return end

                local style, clr = self.menu.elements.visuals.slowdown_color:get()
                local r,g,b

                if style == 'Health Based' then
                    r, g, b = self.rgb_health_based(modifier)
                end

                local a = ui_get_alpha() ~= 0 and ui_get_alpha() or self.remap(modifier, 1, 0, 0.85, 1)

                self.interval = self.interval + (1-modifier) * 0.7 + 0.3
                local warningAlpha = math_abs(self.interval*0.0175 % 2 - 1) * 255

                local text = "Slowed down"
                local text_width = 95
                local x,y = x,y
                local sw, sh = render_screen_size().x, render_screen_size().y
                local iw, ih = 35, 35

                if type(y) == 'userdata' then
                    return
                end

                y = y + 5
                x = x
                -- icon
                local mod = new_interp_fn.value.dpi_modifier/100
                if get_type(clr) == 'table' then
                    render_texture(self.warning, vector(x+ 2, y-3), vector(iw+(6/mod), ih+(6/mod))*mod, color(16, 16, 16, 175*a*new_interp.global_alpha))
                    render_texture(self.warning, vector(x + 5, y+1), vector(35, 35)*mod, color(clr[1].r,clr[1].g,clr[1].b, warningAlpha*a*new_interp.global_alpha))
                else
                    render_texture(self.warning, vector(x+ 2, y-3), vector(iw+(6/mod), ih+(6/mod))*mod, color(16, 16, 16, 175*a*new_interp.global_alpha))
                    render_texture(self.warning, vector(x + 5, y+1), vector(35, 35)*mod, color(r,g,b, warningAlpha*a*new_interp.global_alpha))
                end

                -- text
                self.r_font:set_size(12*DPI_Scale:get()/100)

                new_interp_fn(0.1, {
                    fw = render_measure_text(self.r_font, '', string_format("%s %d%%", text, modifier*100)).x,
                    fh = render_measure_text(self.r_font, '', string_format("%s %d%%", text, modifier*100)).y
                })

                local fw, fh = new_interp.fw, new_interp.fh
                render_text(self.r_font, vector(x+fw/2, y+3), color(255, 255, 255, 255*a*new_interp.global_alpha), nil, string_format("%s %d%%", text, modifier*100))

                -- bar
                local rx, ry, rw, rh = x+iw+8, y+3+17, text_width, 12
                render_rect(vector(x+fw/2, y + 3 + fh + 5*mod) - 1, vector(x+fw/2+(fw-2), y+3 + fh*1.9 + 5*mod) + 1,color(16, 16, 16, 180*a*new_interp.global_alpha), {4, 4, 2, 2})

                if style == 'Gradient' then
                    render_gradient(vector(x+fw/2, y + 3 + fh + 5*mod), vector(x+fw/2+(fw-2)*modifier, y+3 + fh*1.9 + 5*mod), color(clr[1].r, clr[1].g, clr[1].b, 180*a*new_interp.global_alpha), color(clr[2].r, clr[2].g, clr[2].b, 180*a*new_interp.global_alpha), color(clr[1].r, clr[1].g, clr[1].b, 180*a*new_interp.global_alpha), color(clr[2].r, clr[2].g, clr[2].b, 180*a*new_interp.global_alpha), {4, 4, 2, 2})
                    return
                end

                render_rect(vector(x+fw/2, y + 3 + fh + 5*mod), vector(x+fw/2+(fw-2)*modifier, y+3 + fh*1.9 + 5*mod), color(r,g,b, 180*a*new_interp.global_alpha), {4, 4, 2, 2})
            end)
        end,
    }

    :struct 'render_flags' {
        init = function(self)
            local smoothy_data = smoothy.new({
                global_alpha = 0
            })

            local warning_item = esp.enemy:new_item('Zeus Warning')
            local zeus_warning do
                local settings = warning_item:create()

                local active_color = settings : color_picker ('Active Color')
                local background_color = settings : color_picker ('Background Color', color('E2B56AFF'))

                -- UPDATE
                events['render']:set(function()
                    smoothy_data(.05, {
                        global_alpha = warning_item:get() and 1 or 0
                    })

                    entity.get_players(true, true, function(player_ptr)
                        local weap = player_ptr:get_player_weapon()
                        if not weap then return end

                        local global_alpha = smoothy_data.value.global_alpha
                        if global_alpha == 0 or weap:get_classname() ~= 'CWeaponTaser' then
                            return
                        end

                        local threat_bbox = player_ptr:get_bbox()
                        if threat_bbox.pos1 == nil then goto continue end
                        threat_bbox.pos1.x = threat_bbox.pos1.x + (threat_bbox.pos2.x - threat_bbox.pos1.x)/2
                        threat_bbox.pos1.y = threat_bbox.pos1.y - 30

                        threat_bbox.pos1:to_screen()

                        if threat_bbox == nil or threat_bbox.pos1 == nil or threat_bbox.pos1.x == nil then goto continue end
                        render_circle(threat_bbox.pos1, background_color:get():alpha_modulate(background_color:get().a*global_alpha), 15, 0, 1)
                        render_circle_outline(threat_bbox.pos1, active_color:get():alpha_modulate(active_color:get().a*global_alpha), 16, 0, 1)

                        render_rect(vector(threat_bbox.pos1.x, threat_bbox.pos1.y - 10), vector(threat_bbox.pos1.x - 2, threat_bbox.pos1.y + 5),
                            active_color:get():alpha_modulate(active_color:get().a*global_alpha)
                        )

                        render_rect(vector(threat_bbox.pos1.x, threat_bbox.pos1.y + 8), vector(threat_bbox.pos1.x - 2, threat_bbox.pos1.y + 10),
                            active_color:get():alpha_modulate(active_color:get().a*global_alpha)
                        )

                        ::continue::
                    end)
                end)
            end

            local occluded_flag do
                occluded_flag = {  }
                occluded_flag.icon = ''

                esp.enemy:new_text('Occluded', occluded_flag.icon, function(player_ptr)
                    if player_ptr:is_occluded() then
                        return occluded_flag.icon
                    end

                    return
                end)
            end

            local Defensive_DT do
                local g_origin = {  }
                local g_lc = {  }

                local function breaking_lc(ent)
                    local m_flOldSimulationTime = ent:get_simulation_time().old
                    local m_flSimulationTime = ent:get_simulation_time().current

                    if m_flSimulationTime - m_flOldSimulationTime == 0 then
                        return g_lc[ent]
                    end

                    local origin = ent:get_origin()

                    g_origin[ent] = g_origin[ent] or origin
                    if not ent:is_alive() then
                        return false
                    end

                    if m_flSimulationTime < m_flOldSimulationTime then
                        return true
                    end

                    if (origin - g_origin[ent]):lengthsqr() > 4096 then
                        g_origin[ent] = origin
                        return true
                    end

                    g_origin[ent] = origin
                    return false
                end

                events.round_start:set(function()
                    g_origin = {  }
                    g_lc = {  }
                end)

                local vec_add = function(a, b) return { a[1] + b.x, a[2] + b.y, a[3] + b.z } end
                local w2s = function(x, y, z)
                    if get_type(x) == 'vector' then
                        local w2s = x:to_screen()

                        if w2s == nil then
                            return 1, 1
                        end

                        return w2s.x, w2s.y
                    else
                        local w2s = vector(x, y, z):to_screen()

                        return w2s.x, w2s.y
                    end
                end
                local line = function(x, y, x2, y2, r, g, b, a) return render_line(vector(x,y), vector(x2, y2), color(r,g,b,a)) end

                Defensive_DT = esp.enemy:new_text('Lagcomp Debug', 'Debug Text', function(ptr)
                    local text = nil
                    local idx = ptr

                    local tickbase_ticks = ptr.m_nTickBase - globals.tickcount
                    local is_shifted = tickbase_ticks < 0

                    local defensive_lag = is_shifted and breaking_lc(ptr)
                    local predicted_pos = self.tools.extrapolate(ptr, ptr:get_origin(), 7, 1)

                    if is_shifted and math.abs(tickbase_ticks) <= 20 then
                        text = '\aFF3838FFShifting Tickbase'
                    end

                    if breaking_lc(ptr) then
                        text = '\aFF3838FFBreaking Lagcomp'
                    end

                    if defensive_lag then
                        text =  '\affb02eff⚠️ Defensive DT'
                    end

                    if text ~= nil then
                        local min = vec_add({ idx['m_vecMins'].x, idx['m_vecMins'].y, idx['m_vecMins'].z }, predicted_pos)
                        local max = vec_add({ idx['m_vecMaxs'].x, idx['m_vecMaxs'].y, idx['m_vecMaxs'].z }, predicted_pos)

                        local points = {
                            {min[1], min[2], min[3]}, {min[1], max[2], min[3]},
                            {max[1], max[2], min[3]}, {max[1], min[2], min[3]},
                            {min[1], min[2], max[3]}, {min[1], max[2], max[3]},
                            {max[1], max[2], max[3]}, {max[1], min[2], max[3]},
                        }

                        local edges = {
                            {0, 1}, {1, 2}, {2, 3}, {3, 0}, {5, 6}, {6, 7}, {1, 4}, {4, 8},
                            {0, 4}, {1, 5}, {2, 6}, {3, 7}, {5, 8}, {7, 8}, {3, 4}
                        }

                        for i = 1, #edges do
                            if i == 1 then
                                local origin = { idx:get_origin() }
                                local origin_w2s = { w2s(origin[1], origin[2], origin[3]) }
                                local min_w2s = { w2s(min[1], min[2], min[3]) }

                                if origin_w2s[1] ~= nil and min_w2s[1] ~= nil then
                                    line(origin_w2s[1], origin_w2s[2], min_w2s[1], min_w2s[2], 47, 117, 221, 255)
                                end
                            end

                            if points[edges[i][1]] ~= nil and points[edges[i][2]] ~= nil then
                                local p1 = { w2s(points[edges[i][1]][1], points[edges[i][1]][2], points[edges[i][1]][3]) }
                                local p2 = { w2s(points[edges[i][2]][1], points[edges[i][2]][2], points[edges[i][2]][3]) }

                                line(p1[1], p1[2], p2[1], p2[2], 245, 15, 15, 255)
                            end
                        end

                        return text
                    end
                end)
            end
        end
    }


local resource = new_class()

    :struct 'custom_miss_logger' {
        hitlogger =
        (function()
            local b = {callback_registered = false, maximum_count, 8, data = {  }}
            function b:register_callback()
            if self.callback_registered then
                return
            end
            events.render:set(
                function()
                    local c = {56, 56, 57}
                    local d = 10
                    local e = self.data
                    for f = #e, 1, -1 do
                        self.data[f].time = self.data[f].time - globals.frametime
                        local g, h = 255, 0
                        local i = e[f]
                        if i.time < 0 then
                            table.remove(self.data, f)
                        else
                            local j = i.def_time - i.time
                            local j = j > 1 and 1 or j
                            local k = 0.48
                            local l = 0
                            if i.time < 0.48 then
                                l = (j < 1 and j or i.time) / 0.48
                            end
                            if j < k then
                                l = (j < 1 and j or i.time) / 0.48
                            end
                            if i.time < 0.48 then
                                h = (j < 1 and j or i.time) / 0.48
                                g = h * 255
                                if h < 0.2 then
                                    d = d - 15 * (1.0 - h / 0.2)
                                end
                            end
                            local xui = i.time < 0.48 and -1 or 1
                            i.draw = tostring(i.draw):upper()
                            if i.draw == "" then
                                goto m
                            end

                            if i.shot_pos == nil or render_world_to_screen(i.shot_pos) == nil then
                                return
                            end

                            local sx, sy = render_world_to_screen(i.shot_pos).x, render_world_to_screen(i.shot_pos).y
                            local xyeta = 55 * (g*xui) / 255*xui

                            render_text(
                                2,
                                vector(sx, sy),
                                color(255, 145, 145, g),
                                "",
                                "\aFFFFFFFFx   \aDEFAULT" .. i.draw
                            )

                            d = d + 25
                            ::m::
                        end
                    end
                    self.callback_registered = true
                end
            )
        end
        function b:paint(p, q, userdata)
            local r = tonumber(p) + 1
            for f = 1, 2, -1 do
                self.data[f] = self.data[f - 1]
            end
                self.data[1] = {time = r, def_time = r, draw = q, shot_pos = userdata}
                self:register_callback()
            end
            return b
        end)()
        }

    :struct 'custom_event_logger' {
    hitlogger =
    (function()
        local b = {callback_registered = false, maximum_count, 8, data = {  }}
        function b:register_callback()
        if self.callback_registered then
            return
        end

        local render_font = render_load_font('Verdana', 12, 'adb')
        local crender = function(font, vec, clr, glowing_color, txt)
            local sx, sy = render_measure_text(font, '', txt).x, render_measure_text(font, '', txt).y
            local c = clr.a/255

            render.push_clip_rect(
                vector(vec.x - (15 + sx/2)*c, vec.y - 50), vector(vec.x + (15 + sx/2)*c, vec.y + sy + 50), true
            )
            render_shadow(
                vector(vec.x - sx/2*c, vec.y + sy/2), vector(vec.x + sx/2*c, vec.y + sy/2), glowing_color:alpha_modulate(clr.a), ctx.menu.elements.visuals.aimbot_glowing:get()*c, 0
            )

            render_text(font, vector(
                vec.x - sx/2, vec.y
            ), clr:alpha_modulate(255), nil, txt)

            render.pop_clip_rect()
        end

        events.render:set(
            function()
                local c = {56, 56, 57}
                local d = 10
                local e = self.data
                for f = #e, 1, -1 do
                    self.data[f].time = self.data[f].time - globals.frametime
                    local g, h = 255, 0
                    local i = e[f]
                    if i.time < 0 then
                        table.remove(self.data, f)
                    else
                        local j = i.def_time - i.time
                        local j = j > 1 and 1 or j
                        local k = 0.48
                        local l = 0
                        if i.time < 0.48 then
                            l = (j < 1 and j or i.time) / 0.48
                        end
                        if j < k then
                            l = (j < 1 and j or i.time) / 0.48
                        end
                        if i.time < 0.48 or j < k then
                            h = (j < 1 and j or i.time) / 0.48
                            g = math.clamp(h * 375, 0, 255)
                            if h < 0.2 then
                                d = d - 15 * (1.0 - h / 0.2)
                            end
                        end
                        local xui = i.time < 0.48 and -1 or 1
                        i.draw = tostring(i.draw)
                        if i.draw == "" then
                            goto m
                        end
                        local n, o = ctx.cheat.screen_size.x, ctx.cheat.screen_size.y
                        local xyeta = 55

                        local tx_size = render_measure_text(render_font, '', i.draw).x
                        local tx_y = render_measure_text(render_font, '', i.draw).y + 2

                        crender(
                            render_font,
                            vector(n/2, o/1.2 + d - 40),
                            color(255, 255, 255, g),
                            i.clr,
                            i.draw
                        )

                        --render_pop_clip_rect()
                        d = d + 16
                        ::m::
                    end
                end
                self.callback_registered = true
            end
        )
    end
    function b:paint(p, q, _clr)
        local r = tonumber(p) + 1
        for f = ctx.menu.elements.visuals.maximum_count:get(), 2, -1 do
            self.data[f] = self.data[f - 1]
        end
            self.data[1] = {time = r, def_time = r, draw = q, clr = _clr}
            self:register_callback()
        end
        return b
    end)()
    }

    :struct 'aimbot_logging' {
        hitgroup_str = {
            [0] = 'generic',
            'head', 'chest', 'stomach',
            'left arm', 'right arm',
            'left leg', 'right leg',
            'neck', 'generic', 'gear'
        },
        num_format = function(b) local c=b%10;if c==1 and b~=11 then return b..'st'elseif c==2 and b~=12 then return b..'nd'elseif c==3 and b~=13 then return b..'rd'else return b..'th'end end,
        reason_format=function(a)if a=='correction'then return 'resolver' elseif a=='spread'then return'spread'elseif a=='jitter correction'then return'player misprediction'end;return a end,

        init = function(self)
            events.player_hurt:set(function(e)
                local me = entity_get_local_player()
                local attacker = entity_get(e.attacker, true)

                if not ctx.menu.elements.visuals.aimbot_logging:get() then
                    return end

                if me == attacker then
                    local user = entity_get(e.userid, true)
                    local hitgroup = self.hitgroup_str[e.hitgroup]

                    local log = ('Hit %s in the %s for %d damage (%d health remaining)'):format(
                        user:get_name(), hitgroup,
                        e.dmg_health, e.health
                    )

                    if not ctx.menu.elements.visuals.aimbot_logging:get() then
                        return end

                    if ctx.menu.elements.visuals.select_log:get('Under crosshair') then
                        local _color = ctx.menu.elements.visuals.log_hurt_color:get()

                        self.custom_event_logger.hitlogger:paint(ctx.menu.elements.visuals.appear_time:get(), ('\aFFFFFFFFHit \a'.._color:to_hex()..'%s \aFFFFFFFFin the \a'.._color:to_hex()..'%s \aFFFFFFFFfor \a'.._color:to_hex()..'%d \aFFFFFFFFdamage (\a'.._color:to_hex()..'%d \aFFFFFFFFhealth remaining)'):format(
                            user:get_name(), hitgroup,
                            e.dmg_health, e.health
                        ), _color)
                    end

                    if ctx.menu.elements.visuals.select_log:get('Upper-left') then
                        if ctx.menu.elements.visuals.log_engine_type:get() == 'Neverlose' then
                            common_add_event(log, 'check')
                        else
                            print_dev(log)
                        end
                    end
                end
            end)

            events.aim_ack:set(function(e)
                if e.state == nil then
                    local function is_mismatched()
                        local a = e.damage ~= e.wanted_damage
                        local b = e.hitgroup ~= e.wanted_hitgroup

                        local hitbox = ""
                        if((e.wanted_hitgroup > -1 and e.wanted_hitgroup < 9) or e.wanted_hitgroup ~= 10) then
                            hitbox = self.hitgroup_str[e.wanted_hitgroup]
                        else
                            hitbox = "unknown"
                        end

                        if not a and not b then return '' end
                        local txt = " | mismatch: ["

                        if a then
                            txt = txt .. 'dmg: ' .. e.wanted_damage
                        end
                        if b then
                            txt = txt .. ' | hitbox: ' .. hitbox
                        end

                        return txt .. ']'
                    end

                    local hitbox = ""
                    if((e.hitgroup > -1 and e.hitgroup < 9) or e.hitgroup ~= 10) then
                        hitbox = self.hitgroup_str[e.hitgroup]
                    else
                        hitbox = "unknown"
                    end

                    local log = ("hurt [%s] for %s damage | [%s] hc [%i] bt [%i] c [%i] body [%s]%s"):format(e.target:get_name(), e.damage, hitbox, e.hitchance, e.backtrack, globals.choked_commands, string_format('%.1f', math_max(-60, math_min(60, (entity_get_local_player()["m_flPoseParameter"][11] or 0)*120-60+0.5))), is_mismatched() or '')
                    if not ctx.menu.elements.visuals.aimbot_logging:get() then
                        return end

                    if ctx.menu.elements.visuals.select_log:get('Console') then
                        print_raw("\a96B9FFEnvious \a5A5A5A>> \aB6B6B6" .. log)
                    end
                else
                    local wanted_hitbox = ""
                    if((e.wanted_hitgroup > -1 and e.wanted_hitgroup < 9) or e.wanted_hitgroup ~= 10) then
                        hitbox = self.hitgroup_str[e.wanted_hitgroup]
                    else
                        hitbox = "unknown"
                    end

                    if ctx.menu.elements.visuals.world_hitmarker_show_misses:get() then
                        self.custom_miss_logger.hitlogger:paint(2, e.state, e.aim)
                    end

                    if not ctx.menu.elements.visuals.aimbot_logging:get() then
                        return end

                    if ctx.menu.elements.visuals.select_log:get('Console') then
                        local log = ("\aB6B6B6missed [%s] [reason: \a86EAB8%s\aB6B6B6] | [%s] dmg [%s] hc [%i] bt [%i] c [%i] body [%s]"):format(e.target:get_name(), self.reason_format(e.state), hitbox, e.wanted_damage, e.hitchance, e.backtrack, globals.choked_commands, string_format('%.1f', math_max(-60, math_min(60, (entity_get_local_player()["m_flPoseParameter"][11] or 0)*120-60+0.5))))
                    end

                    if ctx.menu.elements.visuals.select_log:get('Upper-left') then
                        if ctx.menu.elements.visuals.log_engine_type:get() == 'Neverlose' then
                            common_add_event('Missed shot due to ' .. self.reason_format(e.state), 'xmark')
                        else
                            print_dev('Missed shot due to ' .. self.reason_format(e.state))
                        end
                    end

                    if ctx.menu.elements.visuals.select_log:get('Under crosshair') then
                        local get_color = function(n)
                            return ctx.menu.elements.visuals[n]:get()
                        end
                        local colors = {
                            ['correction'] = get_color('log_correction_color'),
                            ['spread'] = get_color('log_spread_color'),
                            ['prediction error'] = get_color('log_prederr_color'),
                            ['misprediction'] = get_color('log_mispred_color'),
                            ['death'] = get_color('log_death_color'),
                            ['player death'] = get_color('log_death_color'),
                            ['lagcomp failure'] = get_color('log_lc_color'),
                            ['unregistered shot'] = color(248, 117, 166),
                        }

                        local _clr = colors[e.state]
                        self.custom_event_logger.hitlogger:paint(ctx.menu.elements.visuals.appear_time:get(), ("\aFFFFFFFFMissed \a".._clr:to_hex().."%s\aFFFFFFFF's \a".._clr:to_hex().."%s \aFFFFFFFFdue to \a".._clr:to_hex().."%s\aFFFFFFFF (\a".._clr:to_hex().."%d%%\aFFFFFFFFHC)"):format(e.target:get_name(), hitbox, self.reason_format(e.state), e.hitchance), _clr)
                    end
                end
            end)
        end
    }

    :struct 'custom_scope' {
        new_interp = smoothy.new({
            global_alpha = 0,
            gap = 0,
            size = 0,
        }),
        ref = ctx.refs.scope_var:get(),

        init = function(self)
            local scope_line do
                scope_line = {  }

                scope_line.anim_num = 0
                scope_line.screen = ctx.cheat.screen_size

                scope_line.lerp = function(a, b, t)
                    return a + (b - a) * t
                end

                scope_line.on_destroy = function()
                    ctx.refs.scope_var:set(self.ref)
                end

                scope_line.on_draw = function()
                    local new_interp = self.new_interp.value
                    self.new_interp(0.1, {
                        global_alpha = ctx.menu.elements.visuals.custom_scope:get() and 1 or 0
                    })

                    if new_interp.global_alpha < 0.1 then
                        ctx.refs.scope_var:set('Remove overlay')
                        return
                    end

                    local ex = function(ind)
                        return not ctx.menu.elements.visuals.exclude_lines:get(ind)
                    end

                    ctx.refs.scope_var:set('Remove all')
                    local_player = entity_get_local_player()
                    scope_line.anim_speed = ctx.menu.elements.visuals.scope_anim:get()/4

                    if not local_player or not local_player:is_alive() or not local_player["m_bIsScoped"] then
                        scope_line.anim_num = scope_line.lerp(scope_line.anim_num, 0, scope_line.anim_speed * globals.frametime)
                    else
                        scope_line.anim_num = scope_line.lerp(scope_line.anim_num, 1, scope_line.anim_speed * globals.frametime)
                    end

                    self.new_interp(0.05, {
                        gap = ctx.menu.elements.visuals.scope_gap:get(),
                        size = ctx.menu.elements.visuals.scope_size:get()
                    })

                    scope_line.type1 = ctx.menu.elements.visuals.scope_type:get() == 'Default' and 1 or 0
                    scope_line.type2 = ctx.menu.elements.visuals.scope_type:get() == 'Default' and 0 or 1
                    scope_line.offset = new_interp.gap * scope_line.anim_num
                    scope_line.length = new_interp.size * scope_line.anim_num
                    scope_line.col_1 = ctx.menu.elements.visuals.scope_color1:get()
                    scope_line.col_2 = ctx.menu.elements.visuals.scope_color2:get()
                    scope_line.glowing = ctx.menu.elements.visuals.scope_glowing:get()
                    scope_line.glowing_color = ctx.menu.elements.visuals.scope_glowing_clr:get()
                    scope_line.width = 1

                    scope_line.col_1.a = 255* scope_line.anim_num * scope_line.type1*new_interp.global_alpha
                    scope_line.col_2.a = 255 * scope_line.anim_num * scope_line.type2*new_interp.global_alpha
                    scope_line.glowing_color.a = 255 * scope_line.anim_num*new_interp.global_alpha

                    scope_line.start_x = scope_line.screen.x / 2
                    scope_line.start_y = scope_line.screen.y / 2

                    if scope_line.glowing > 0 then
                        if ex('Left') then
                            render_shadow(
                                vector(scope_line.start_x - scope_line.offset - scope_line.length, scope_line.start_y + scope_line.width), vector(scope_line.start_x - scope_line.offset, scope_line.start_y), scope_line.glowing_color, scope_line.glowing, nil, 0
                            )
                        end

                        if ex('Right') then
                            render_shadow(
                                vector(scope_line.start_x + scope_line.offset, scope_line.start_y + 1), vector(scope_line.start_x + scope_line.offset + scope_line.length, scope_line.start_y - scope_line.width + 1), scope_line.glowing_color, scope_line.glowing, nil, 0
                            )
                        end

                        if ex('Bottom') then
                            render_shadow(
                                vector(scope_line.start_x + 1, scope_line.start_y + scope_line.offset), vector(scope_line.start_x - scope_line.width + 1, scope_line.start_y + scope_line.offset + scope_line.length), scope_line.glowing_color, scope_line.glowing, nil, 0
                            )
                        end

                        if ex('Top') then
                            render_shadow(
                                vector(scope_line.start_x + scope_line.width, scope_line.start_y - scope_line.offset - scope_line.length), vector(scope_line.start_x, scope_line.start_y - scope_line.offset), scope_line.glowing_color, scope_line.glowing, nil, 0
                            )
                        end
                    end


                    if scope_line.glowing == 21 then return end
                    --Left
                    if ex('Left') then
                        render_gradient(vector(scope_line.start_x - scope_line.offset, scope_line.start_y), vector(scope_line.start_x - scope_line.offset - scope_line.length, scope_line.start_y + scope_line.width), scope_line.col_1, scope_line.col_2, scope_line.col_1, scope_line.col_2)
                    end
                    if ex('Right') then
                        render_gradient(vector(scope_line.start_x + scope_line.offset, scope_line.start_y), vector(scope_line.start_x + scope_line.offset + scope_line.length, scope_line.start_y + scope_line.width), scope_line.col_1, scope_line.col_2, scope_line.col_1, scope_line.col_2)
                    end
                    if ex('Bottom') then
                        render_gradient(vector(scope_line.start_x, scope_line.start_y + scope_line.offset), vector(scope_line.start_x + scope_line.width, scope_line.start_y + scope_line.offset + scope_line.length), scope_line.col_1, scope_line.col_1, scope_line.col_2, scope_line.col_2)
                    end
                    if ex('Top') then
                        render_gradient(vector(scope_line.start_x, scope_line.start_y - scope_line.offset), vector(scope_line.start_x + scope_line.width, scope_line.start_y - scope_line.offset - scope_line.length), scope_line.col_1, scope_line.col_1, scope_line.col_2, scope_line.col_2)
                    end
                end

                events.render:set(scope_line.on_draw)
                events.shutdown:set(scope_line.on_destroy)
            end
        end
    }

    :struct 'TalkOnCondition' {
        killsay_pharases = {
            'ой / бро сорри за тапыч',
            'F[[F[FF[[F[F / получил по ебалу хуесос?',
            'умалишенный куда ты скачешь / мать, шлюху встречаешь?',
            'на нахуй тапыча ублюдок',
            'ну куда ты ахахах / че в себя поверил?',
            'фу блять / игроком еще себя наверное называешь?',
            'да блять шваль ебаная / опять под прицел попала',
            "как можно играть настолько плохо / ахахах это пиздец как ты вообще кого то убиваешь",
            "☜(˚▽˚)☞ Envious OWNS ME AND ALL ☜(˚▽˚)☞",
            'LIFEEEEHAAAACK BITCH!!! (◣_◢) / тоже смотришь шока?',
            'круто убогий / найс муваешься'
        },

        death_say = {
            'найс автопик+миндмг / ну глупый мочегон))',
            'это 100 dmg? / очередной подсос санчеза?',
            'блять / называется загрузил аксид теч на раунд попробывать',
            'да фуу / сука снова моча убила какая-то',
            'ну тиммейт федука давит / убогий',
            'ye xt ns ltkftim / daolbeb',
            'да господи опять долбаеб убил',
            'че блять',
            'ты еблан / у меня там десинк был если что',
            'опять по дезу сука / ебаный русский продукт',
            '1 / скули / чмо',
            'кнут и пряник',
            'ашалеть / как ты адмаг выбил? / армянин',
            '[acidtech] missed shot due to resolver / пахпхапахпхапха / ебаный аксид ресик ломает',
            'нихуя ты трекнул / у меня залагало / аж'
        },

        killer_data = {
            phrases = {
                '1 сын шавалавы',
                '1 УЕБИЩЕ',
                '1.',
                'iq?'
            },

            entity = nil
        },
        entities_list = {  },

        init = function(self)
            events.round_start:set(function()
                self.killer_data.entity = nil
                self.entities_list = {  }
            end)
            events.player_death:set(function(e)
                if not ctx.menu.elements.misc.killsay:get() then
                    return
                end

                local delay = ctx.menu.elements.misc.killsay_multiplier:get()

                local me = entity_get_local_player()
                local victim = entity_get(e.userid, true)
                local attacker = entity_get(e.attacker, true)

                self.entities_list[e.userid] = 0
                local deathsay_delay = 0

                if self.killer_data.entity ~= me and self.killer_data.entity == victim and ctx.menu.elements.misc.killsay_select:get('Revenge') then
                    utils_console_exec('say ' .. self.killer_data.phrases[math_random(1, #self.killer_data.phrases)])
                end

                if ctx.menu.elements.misc.killsay_select:get('On Kill') and (victim ~= attacker and attacker == me) then
                    local phase_block = ctx.tools.split(self.killsay_pharases[math_random(1, #self.killsay_pharases)], '/')

                    for i=1, #phase_block do
                        local phase = phase_block[i]
                        local interphrase_delay = #phase_block[i]/24*delay
                        self.entities_list[e.userid] = self.entities_list[e.userid] + interphrase_delay

                        ctx.tools.delayed_msg(self.entities_list[e.userid], phase)
                    end
                end
                if ctx.menu.elements.misc.killsay_select:get('On Death') and (victim == me and attacker ~= me) then
                    local phase_block = ctx.tools.split(self.death_say[math_random(1, #self.death_say)], '/')

                    for i=1, #phase_block do
                        local phase = phase_block[i]
                        local interphrase_delay = #phase_block[i]/20*delay
                        deathsay_delay = deathsay_delay + interphrase_delay

                        ctx.tools.delayed_msg(deathsay_delay, phase)
                    end

                    self.killer_data.entity = attacker
                end
            end)
        end
    }

    :struct 'tween' {
        func = (function()local a={  }local b,c,d,e,f,g,h=math.pow,math.sin,math.cos,math.pi,math.sqrt,math_abs,math.asin;local function i(j,k,l,m)return l*j/m+k end;local function n(j,k,l,m)return l*b(j/m,2)+k end;local function o(j,k,l,m)j=j/m;return-l*j*(j-2)+k end;local function p(j,k,l,m)j=j/m*2;if j<1 then return l/2*b(j,2)+k end;return-l/2*((j-1)*(j-3)-1)+k end;local function q(j,k,l,m)if j<m/2 then return o(j*2,k,l/2,m)end;return n(j*2-m,k+l/2,l/2,m)end;local function r(j,k,l,m)return l*b(j/m,3)+k end;local function s(j,k,l,m)return l*(b(j/m-1,3)+1)+k end;local function t(j,k,l,m)j=j/m*2;if j<1 then return l/2*j*j*j+k end;j=j-2;return l/2*(j*j*j+2)+k end;local function u(j,k,l,m)if j<m/2 then return s(j*2,k,l/2,m)end;return r(j*2-m,k+l/2,l/2,m)end;local function v(j,k,l,m)return l*b(j/m,4)+k end;local function w(j,k,l,m)return-l*(b(j/m-1,4)-1)+k end;local function x(j,k,l,m)j=j/m*2;if j<1 then return l/2*b(j,4)+k end;return-l/2*(b(j-2,4)-2)+k end;local function y(j,k,l,m)if j<m/2 then return w(j*2,k,l/2,m)end;return v(j*2-m,k+l/2,l/2,m)end;local function z(j,k,l,m)return l*b(j/m,5)+k end;local function A(j,k,l,m)return l*(b(j/m-1,5)+1)+k end;local function B(j,k,l,m)j=j/m*2;if j<1 then return l/2*b(j,5)+k end;return l/2*(b(j-2,5)+2)+k end;local function C(j,k,l,m)if j<m/2 then return A(j*2,k,l/2,m)end;return z(j*2-m,k+l/2,l/2,m)end;local function D(j,k,l,m)return-l*d(j/m*e/2)+l+k end;local function E(j,k,l,m)return l*c(j/m*e/2)+k end;local function F(j,k,l,m)return-l/2*(d(e*j/m)-1)+k end;local function G(j,k,l,m)if j<m/2 then return E(j*2,k,l/2,m)end;return D(j*2-m,k+l/2,l/2,m)end;local function H(j,k,l,m)if j==0 then return k end;return l*b(2,10*(j/m-1))+k-l*0.001 end;local function I(j,k,l,m)if j==m then return k+l end;return l*1.001*(-b(2,-10*j/m)+1)+k end;local function J(j,k,l,m)if j==0 then return k end;if j==m then return k+l end;j=j/m*2;if j<1 then return l/2*b(2,10*(j-1))+k-l*0.0005 end;return l/2*1.0005*(-b(2,-10*(j-1))+2)+k end;local function K(j,k,l,m)if j<m/2 then return I(j*2,k,l/2,m)end;return H(j*2-m,k+l/2,l/2,m)end;local function L(j,k,l,m)return-l*(f(1-b(j/m,2))-1)+k end;local function M(j,k,l,m)return l*f(1-b(j/m-1,2))+k end;local function N(j,k,l,m)j=j/m*2;if j<1 then return-l/2*(f(1-j*j)-1)+k end;j=j-2;return l/2*(f(1-j*j)+1)+k end;local function O(j,k,l,m)if j<m/2 then return M(j*2,k,l/2,m)end;return L(j*2-m,k+l/2,l/2,m)end;local function P(Q,R,l,m)Q,R=Q or m*0.3,R or 0;if R<g(l)then return Q,l,Q/4 end;return Q,R,Q/(2*e)*h(l/R)end;local function S(j,k,l,m,R,Q)local T;if j==0 then return k end;j=j/m;if j==1 then return k+l end;Q,R,T=P(Q,R,l,m)j=j-1;return-(R*b(2,10*j)*c((j*m-T)*2*e/Q))+k end;local function U(j,k,l,m,R,Q)local T;if j==0 then return k end;j=j/m;if j==1 then return k+l end;Q,R,T=P(Q,R,l,m)return R*b(2,-10*j)*c((j*m-T)*2*e/Q)+l+k end;local function V(j,k,l,m,R,Q)local T;if j==0 then return k end;j=j/m*2;if j==2 then return k+l end;Q,R,T=P(Q,R,l,m)j=j-1;if j<0 then return-0.5*R*b(2,10*j)*c((j*m-T)*2*e/Q)+k end;return R*b(2,-10*j)*c((j*m-T)*2*e/Q)*0.5+l+k end;local function W(j,k,l,m,R,Q)if j<m/2 then return U(j*2,k,l/2,m,R,Q)end;return S(j*2-m,k+l/2,l/2,m,R,Q)end;local function X(j,k,l,m,T)T=T or 1.70158;j=j/m;return l*j*j*((T+1)*j-T)+k end;local function Y(j,k,l,m,T)T=T or 1.70158;j=j/m-1;return l*(j*j*((T+1)*j+T)+1)+k end;local function Z(j,k,l,m,T)T=(T or 1.70158)*1.525;j=j/m*2;if j<1 then return l/2*j*j*((T+1)*j-T)+k end;j=j-2;return l/2*(j*j*((T+1)*j+T)+2)+k end;local function _(j,k,l,m,T)if j<m/2 then return Y(j*2,k,l/2,m,T)end;return X(j*2-m,k+l/2,l/2,m,T)end;local function a0(j,k,l,m)j=j/m;if j<1/2.75 then return l*7.5625*j*j+k end;if j<2/2.75 then j=j-1.5/2.75;return l*(7.5625*j*j+0.75)+k elseif j<2.5/2.75 then j=j-2.25/2.75;return l*(7.5625*j*j+0.9375)+k end;j=j-2.625/2.75;return l*(7.5625*j*j+0.984375)+k end;local function a1(j,k,l,m)return l-a0(m-j,0,l,m)+k end;local function a2(j,k,l,m)if j<m/2 then return a1(j*2,0,l,m)*0.5+k end;return a0(j*2-m,0,l,m)*0.5+l*.5+k end;local function a3(j,k,l,m)if j<m/2 then return a0(j*2,k,l/2,m)end;return a1(j*2-m,k+l/2,l/2,m)end;a.easing={linear=i,inQuad=n,outQuad=o,inOutQuad=p,outinQuad=q,inCubic=r,outCubic=s,inOutCubic=t,outinCubic=u,inQuart=v,outQuart=w,inOutQuart=x,outinQuart=y,inQuint=z,outQuint=A,inOutQuint=B,outinQuint=C,inSine=D,outSine=E,inOutSine=F,outinSine=G,inExpo=H,outExpo=I,inOutExpo=J,outinExpo=K,inCirc=L,outCirc=M,inOutCirc=N,outinCirc=O,inElastic=S,outElastic=U,inOutElastic=V,outinElastic=W,inBack=X,outBack=Y,inOutBack=Z,outinBack=_,inBounce=a1,outBounce=a0,inOutBounce=a2,outinBounce=a3}local function a4(a5,a6,a7)a7=a7 or a6;local a8=getmetatable(a6)if a8 and getmetatable(a5)==nil then setmetatable(a5,a8)end;for a9,aa in pairs(a6)do if type(aa)=="table"then a5[a9]=a4({  },aa,a7[a9])else a5[a9]=a7[a9]end end;return a5 end;local function ab(ac,ad,ae)ae=ae or{  }local af,ag;for a9,ah in pairs(ad)do af,ag=type(ah),a4({  },ae)table.insert(ag,tostring(a9))if af=="number"then assert(type(ac[a9])=="number","Parameter '"..table.concat(ag,"/").."' is missing from subject or isn't a number")elseif af=="table"then ab(ac[a9],ah,ag)else assert(af=="number","Parameter '"..table.concat(ag,"/").."' must be a number or table of numbers")end end end;local function ai(aj,ac,ad,ak)assert(type(aj)=="number"and aj>0,"duration must be a positive number. Was "..tostring(aj))local al=type(ac)assert(al=="table"or al=="userdata","subject must be a table or userdata. Was "..tostring(ac))assert(type(ad)=="table","target must be a table. Was "..tostring(ad))assert(type(ak)=="function","easing must be a function. Was "..tostring(ak))ab(ac,ad)end;local function am(ak)ak=ak or"linear"if type(ak)=="string"then local an=ak;ak=a.easing[an]if type(ak)~="function"then error("The easing function name '"..an.."' is invalid")end end;return ak end;local function ao(ac,ad,ap,aq,aj,ak)local j,k,l,m;for a9,aa in pairs(ad)do if type(aa)=="table"then ao(ac[a9],aa,ap[a9],aq,aj,ak)else j,k,l,m=aq,ap[a9],aa-ap[a9],aj;ac[a9]=ak(j,k,l,m)end end end;local ar={  }local as={__index=ar}function ar:set(aq)assert(type(aq)=="number","clock must be a positive number or 0")self.initial=self.initial or a4({  },self.target,self.subject)self.clock=aq;if self.clock<=0 then self.clock=0;a4(self.subject,self.initial)elseif self.clock>=self.duration then self.clock=self.duration;a4(self.subject,self.target)else ao(self.subject,self.target,self.initial,self.clock,self.duration,self.easing)end;return self.clock>=self.duration end;function ar:reset()return self:set(0)end;function ar:update(at)assert(type(at)=="number","dt must be a number")return self:set(self.clock+at)end;function a.new(aj,ac,ad,ak)ak=am(ak)ai(aj,ac,ad,ak)return setmetatable({duration=aj,subject=ac,target=ad,easing=ak,clock=0},as)end;return a end)(),

        table = {  },
        data = {
            drag_indicators = 0,
            eased_charge = 0,
        }
    }

    :struct 'indicators' {
        new_interp = smoothy.new({
            global_alpha = 0,
            glowing_alpha = 0,
            exp = 0,
            exp_x = 0,
            exp_y = 0,
            test = 0,
            down_frac = 0,
        }),

        renderer_text = function(r_vec, color, easing, text)
            render_text(2, vector(r_vec.x, math.clamp(r_vec.y*(easing/255), r_vec.y-20, r_vec.y)), color:alpha_modulate(easing), 'c', text:upper())
        end,

        init = function(self)
            local new_interp = self.new_interp.value

            local easing_table = smoothy.new({
                width = 0,
                appear = 0
            })

            local rgb_perc_based = function(percentage)
                local r = 160*2 - 160 * percentage
                local g = 210 * percentage
                local b = 13
                return color(r,g,b)
            end

            local start_planting = 0

            events.bomb_beginplant:set(function()
                local curtime = globals.curtime

                start_planting = curtime + 3.2
            end)

            events.bomb_abortplant:set(function()
                local curtime = globals.curtime

                start_planting = 0
            end)

            local fill_text_perc = function(position, font, text_color, background_color, flags, weight, ...)
                local text_size = render.measure_text(font, flags:find '+' and 's' or '', ...)

                local actual_position = flags:find('c') and vector(position.x - text_size.x/2, position.y - text_size.y/2) or position

                local render_flags do
                    render_flags = ''

                    if flags:find '+' then
                        render_flags = render_flags .. 's'
                    end
                end


                render.text(font, actual_position, background_color, render_flags, ...)
                render.push_clip_rect(actual_position, vector(actual_position.x + text_size.x * weight, actual_position.y + text_size.y), true)

                render.text(font, actual_position, text_color, render_flags, ...)

                render.pop_clip_rect()
            end

            local render_shadow_doubletap = function(position, font, text_color, background_color, flags, weight, consistency, variability, global_transform)
                easing_table(.04, {
                    width = render.measure_text(font, flags:find '+' and 's' or '', variability),
                    width2 = render.measure_text(font, flags:find '+' and 's' or '', consistency)
                })

                local const_size = easing_table.value.width2 - 2
                local text_size = easing_table.value.width
                local variable_size = easing_table.value.width

                local actual_position = flags:find('c') and vector(position.x - text_size.x/2, position.y - text_size.y/2) or position

                render.push_clip_rect(vector(position.x - variable_size.x/2*(global_transform) - const_size.x, actual_position.y),
                    vector(position.x - variable_size.x/2 + text_size.x*(global_transform), actual_position.y + text_size.y), true
                )
                --render.rect(vector(position.x - variable_size.x/2 + (text_size.x * 1) - (const_size.x * (2)), actual_position.y), vector(position.x - variable_size.x/2 + (text_size.x * global_transform) - (const_size.x * (1-global_transform)), actual_position.y + text_size.y), color())

                local render_flags do
                    render_flags = ''

                    if flags:find '+' then
                        render_flags = render_flags .. 's'
                    end
                end

                actual_position = vector(actual_position.x + (text_size.x)*(1-global_transform), actual_position.y)
                position = vector(position.x + (text_size.x)*(1-global_transform), position.y)

                render.text(font, actual_position, background_color:alpha_modulate(75), render_flags, variability)
                render.text(font, vector(position.x - const_size.x - variable_size.x/2, actual_position.y), color(), render_flags, consistency)

                render.push_clip_rect(actual_position, vector(actual_position.x + text_size.x * weight, actual_position.y + text_size.y), true)
                render.text(font, actual_position, text_color, render_flags, variability)

                render.pop_clip_rect()
            end

            local render_interpolate_string = function(position, font, text_color, flags, ...)
                local text = table.concat({...})
                local text_size = easing_table(.0725, {
                    allah = render.measure_text(font, 's', ...)
                }).allah

                local normal_size = render.measure_text(font, 's', ...)

                render.push_clip_rect(
                    vector(position.x - normal_size.x, position.y - text_size.y/2),
                    vector(position.x + text_size.x/2, position.y + text_size.y/2),
                    true
                )

                if text ~= '-PLANTING-' then
                    render.text(font, vector(position.x - text_size.x/2, position.y - text_size.y/2), text_color, flags, ...)
                else
                    local is_planting = start_planting - globals.curtime > 0 and 1-((start_planting - globals.curtime)/3.2) or 0
                    fill_text_perc(position, 2, text_color, color(200, 150), '+c', is_planting, '-PLANTING-')
                end

                render.pop_clip_rect()
            end

            local g_origin = {  }
            local g_lc = {  }

            local function breaking_lc(ent)
                if not ent then
                    return
                end

                local sim_time = ent:get_simulation_time()

                local m_flOldSimulationTime = sim_time.old
                local m_flSimulationTime = sim_time.current

                if m_flSimulationTime - m_flOldSimulationTime == 0 then
                    return g_lc[ent]
                end

                local origin = ent:get_origin()

                g_origin[ent] = g_origin[ent] or origin
                if ent:is_dormant() or not ent:is_alive() then
                    return false
                end

                if m_flSimulationTime < m_flOldSimulationTime then
                    return true
                end

                if (origin - g_origin[ent]):lengthsqr() > 4096 then
                    g_origin[ent] = origin
                    return true
                end

                g_origin[ent] = origin
                return false
            end

            events.net_update_end:set(function()
                local ent = entity.get_local_player()

                g_lc[ent:get_index()] = breaking_lc(ent)
            end)

            local player_condition = ''
            local last_state = false

            events.render:set(function()
                if entity_get_local_player() == nil then
                    return
                end

                for d,e in pairs(self.tween.table)do e:update(globals.frametime)end
                local IsScoped = entity_get_local_player()["m_bIsScoped"]
                self.tween.table.drag_indicators = self.tween.func.new(0.04, self.tween.data, {drag_indicators = (IsScoped and ctx.menu.elements.visuals.indicator_tweaks:get('Scope adjust')) and 1 or 0}, 'linear')
                local drag_offset = self.tween.data.drag_indicators

                local update_smoothy do
                    local state = ctx.menu.elements.visuals.on_screen:get() and entity_get_local_player():is_alive()

                    global_alpha = self.new_interp(ctx.menu.elements.visuals.animation_speed:get() ~= 0 and math.cos(ctx.menu.elements.visuals.animation_speed:get()/100)/8 or 0, {
                        global_alpha = state and 255 or 0,
                        glowing_alpha = (state and ctx.menu.elements.visuals.indicator_tweaks:get('Glowing')) and 255 or 0,
                        exp = (ctx.refs.dt:get() or ctx.refs.hs:get()) and 1 or 0,
                        down_frac = ctx.menu.elements.antiaims.manual_aa:get() ~= 'Disabled' and math.ceil(drag_offset*15) or 0,
                    })
                end

                if new_interp.global_alpha == 0 or (new_interp.global_alpha == 0 and ui_get_alpha() == 0) then
                    return
                end

                local prefix_pulsate = math.clamp(math_floor(math.sin(globals.realtime * 4.45) * (1*255/2-1) + 1*255/2) or 1*255, 30, 255)
                local render_indicators do
                    render_indicators = {  }

                    local state = ctx.menu.elements.visuals.indication_style:get()
                    local _color = ctx.menu.elements.visuals.indicator_color:get()
                    local _color2 = ctx.menu.elements.visuals.condition_color:get()
                    local down_frac = new_interp.down_frac

                    if state == 'Default' then
                        local sx, sy = ctx.cheat.screen_size.x, ctx.cheat.screen_size.y

                        local exp_state = ctx.refs.dt:get() or ctx.refs.hs:get()
                        local charge_frac = rage.exploit:get()
                        local dt_state = charge_frac == 0 and 'WAITING' or (
                            charge_frac == 1 and 'READY' or 'CHARGING'
                        )

                        local global_transform = easing_table(.115, {
                            appear = exp_state and 1 or 0
                        }).appear

                        local render_color = charge_frac == 0 and color(200, 0, 0) or (
                            charge_frac == 1 and color(160, 210, 120) or rgb_perc_based(charge_frac)
                        )
                        local background_color = charge_frac == 0 and color(200, 0, 0, 140) or (
                            charge_frac == 1 and color(160, 210, 120) or rgb_perc_based(charge_frac):alpha_modulate(75)
                        )

                        local me = entity.get_local_player()

                        local no_entry = g_lc[me:get_index()]
                        local is_planting = start_planting - globals.curtime > 0 and 1-((start_planting - globals.curtime)/3.2) or 0

                        local exploit_state = ctx.refs.dt:get() and 'DT ' or (ctx.refs.hs:get() and 'HIDE ') or ''
                        local exp_state_size = render.measure_text(2, '+', exploit_state)

                        local roflan_width = easing_table(.075, {
                            roflan_width = exp_state_size.x/2
                        }).roflan_width

                        if no_entry then
                            dt_state = 'ACTIVE'
                            render_color = color(123, 246, 246)
                        end

                        render_shadow(vector(sx/2 - 0 , math.clamp((sy/2 + 30)*(new_interp.global_alpha/255), (sy/2 + 30)- 40, (sy/2 + 30)) + down_frac), vector(sx/2 - 0 , math.clamp((sy/2 + 30)*(new_interp.global_alpha/255), (sy/2 + 30)- 40, (sy/2 + 30)) + down_frac), _color:alpha_modulate((new_interp.glowing_alpha*math.acos(drag_offset))/2), 90, nil, 10)

                        local naming do
                            local text = ctx.cheat.lua .. '\a'..ctx.menu.elements.visuals.build_color:get():alpha_modulate(ctx.menu.elements.visuals.indicator_tweaks:get('Pulsating') and prefix_pulsate or new_interp.global_alpha):to_hex()..' yaw'
                            local add_x = render_measure_text(2, 's', text).x/1.5 * drag_offset

                            self.renderer_text(vector(sx/2 + add_x, sy/2 + 25 + down_frac), _color, new_interp.global_alpha, text)
                        end

                        local condition do
                            local text = ctx.menu.local_condition or ''
                            local add_x = 28 * drag_offset

                            if is_planting > 0 then
                                text = '-PLANTING-'
                            end

                            render_interpolate_string(vector(sx/2 + add_x , sy/2 + 35 + down_frac), 2, _color2:alpha_modulate(new_interp.global_alpha), 's', text)
                        end

                        local exploits do
                            local add_x = 28 * drag_offset

                            render_shadow_doubletap(vector(sx/2 + add_x + roflan_width, sy/2 + 45 + down_frac), 2, render_color:alpha_modulate(new_interp.global_alpha), background_color:alpha_modulate(new_interp.global_alpha), '+c', charge_frac, exploit_state, dt_state, global_transform)
                        end

                        render.pop_clip_rect()
                    end
                end
            end)
        end
    }

    :struct 'vgui_color_changer' {
        new_interp = smoothy.new({
            global_alpha = 1,
            _color = color(0, 0, 0, 0)
        }),

        engine_client = ffi_cast(ffi_typeof('void***'), utils_create_interface('engine.dll', 'VEngineClient014')),
        console_is_visible = ffi_cast(ffi_typeof('bool(__thiscall*)(void*)'), ffi_cast(ffi_typeof('void***'), utils_create_interface('engine.dll', 'VEngineClient014'))[0][11]),
        materials_list = { 'vgui_white', 'vgui/hud/800corner1', 'vgui/hud/800corner2', 'vgui/hud/800corner3', 'vgui/hud/800corner4' },

        init = function(self)
            events.render:set(function()
                local new_interp = self.new_interp.value
                self.new_interp(0.15, {
                    global_alpha = ctx.menu.elements.misc.console_changer:get() and 0 or 1,
                    _color = ctx.menu.elements.misc.console_color:get()
                })

                if new_interp.global_alpha == 1 then
                    return
                end

                local find_material = materials.get_materials
                local _color = new_interp._color:lerp(color(), new_interp.global_alpha)

                    if not self.console_is_visible(self.engine_client) then
                        _color = color()
                    end

                    for i=1, #self.materials_list do
                        find_material(self.materials_list[i], false, function(mat)
                        mat:alpha_modulate(_color.a / 255)
                        mat:color_modulate(_color)
                    end)
                end
            end)

            events.shutdown:set(function()
                local find_material = materials.get_materials

                    for i=1, #self.materials_list do
                        find_material(self.materials_list[i], false, function(mat)
                        mat:alpha_modulate(1)
                        mat:color_modulate(color())
                    end)
                end
            end)
        end
    }

    :struct 'viewmodel_changer' {
        new_interp = smoothy.new({
            x = 0,
            y = 0,
            z = 0,
            fov = 0,
            aspect_ratio = 0
        }),

        get_original = function()
            return {
                rhand = cvar.cl_righthand:int(),
                fov = cvar.viewmodel_fov:float(),

                x = cvar.viewmodel_offset_x:float(),
                y = cvar.viewmodel_offset_y:float(),
                z = cvar.viewmodel_offset_z:float()
            }
        end,

        original_viewmodel = {
            rhand = cvar.cl_righthand:int(),
            fov = cvar.viewmodel_fov:float(),

            x = cvar.viewmodel_offset_x:float(),
            y = cvar.viewmodel_offset_y:float(),
            z = cvar.viewmodel_offset_z:float(),
            aspect = cvar.r_aspectratio:float()
        },

        init = function(self)
            -- viewmodel cvars
            local vo_hand, vfov, vo_x, vo_y, vo_z = cvar.cl_righthand, cvar.viewmodel_fov, cvar.viewmodel_offset_x, cvar.viewmodel_offset_y, cvar.viewmodel_offset_z

            events.pre_render:set(function()
                if not ctx.menu.elements.visuals.viewmodel_changer:get() then
                    return
                end

                local multiplier = 1
                local new_interp = self.new_interp.value
                local original, data = self.viewmodel_changer.get_original(),
                {
                    rhand = (ctx.menu.elements.visuals.viewmodel_knife):get(),
                    fov = (ctx.menu.elements.visuals.viewmodel_fov):get()/10,
                    x = (ctx.menu.elements.visuals.viewmodel_x):get()/10,
                    y = (ctx.menu.elements.visuals.viewmodel_y):get()/10,
                    z = (ctx.menu.elements.visuals.viewmodel_z):get()/10
                }

                self.new_interp(0.02, {
                    x = data.x,
                    y = data.y,
                    z = data.z,
                    fov = data.fov,
                    aspect_ratio = 0
                })

                vfov:float(new_interp.fov, true)
                vo_x:float(new_interp.x, true)
                vo_y:float(new_interp.y, true)
                vo_z:float(new_interp.z, true)
                cvar.r_aspectratio:float(ctx.menu.elements.visuals.viewmodel_aspectratio:get()*0.1)

                vo_hand:float(original.rhand, true)
                local dir, restore = { 'LUA', 'B', 4000, { '-', 'Left hand', 'Right hand' } }

                if not shutdown and data.rhand ~= dir[4][1] then
                    local is_holding_knife = false
                    local me = entity_get_local_player()

                    if me == nil then
                        return
                    end

                    local wpn = me:get_player_weapon()

                    if wpn == nil then
                        return
                    end

                    if me ~= nil and wpn ~= nil then
                        is_holding_knife = string.match((wpn:get_classname() or ''), 'Knife')
                    end

                    vo_hand:int((
                        {
                            [dir[4][2]] = is_holding_knife and 0 or 1,
                            [dir[4][3]] = is_holding_knife and 1 or 0,
                        }
                    )[data.rhand], true)
                end
            end)

            ctx.menu.elements.visuals.viewmodel_changer:set_callback(function(cee)
                local data = self.viewmodel_changer.original_viewmodel
                local state = cee:get()

                if state then return end

                vfov:float(data.fov, true)
                vo_x:float(data.x, true)
                vo_y:float(data.y, true)
                vo_z:float(data.z, true)
            end)

            events.shutdown:set(function()
                local data = self.viewmodel_changer.original_viewmodel

                vfov:float(data.fov, true)
                vo_x:float(data.x, true)
                vo_y:float(data.y, true)
                vo_z:float(data.z, true)
            end)
        end

    }

    :struct 'fast_ladder' {
        init = function(self, cmd)
            if not ctx.menu.elements.misc.fast_ladder:get() then
                return
            end

            local pitch, yaw = render_camera_angles().x
            local lp = entity_get_local_player()
            local wep = lp:get_player_weapon()
            if lp == nil or wep == nil then return end

            if lp.m_MoveType ~= 9 or wep:get_weapon_info().weapon_type == 9 then return end
            cmd.view_angles.y = math.floor(cmd.view_angles.y+0.5)
            cmd.view_angles.z = 0

            if cmd.forwardmove == 0 then
                cmd.view_angles.x = 89
                cmd.view_angles.y = cmd.view_angles.y + 180
                if cmd.sidemove < 0 then
                    cmd.in_moveleft = 0
                    cmd.in_moveright = 1
                end
                if cmd.sidemove > 0 then
                    cmd.in_moveleft = 1
                    cmd.in_moveright = 0
                end
            end

            if cmd.forwardmove > 0 then
                if pitch < 45 then
                    cmd.view_angles.x = 89
                    cmd.in_moveright = 1
                    cmd.in_moveleft = 0
                    cmd.in_forward = 0
                    cmd.in_back = 1
                    if cmd.sidemove == 0 then
                        cmd.view_angles.y = cmd.view_angles.y + 90
                    end
                    if cmd.sidemove < 0 then
                        cmd.view_angles.y = cmd.view_angles.y + 150
                    end
                    if cmd.sidemove > 0 then
                        cmd.view_angles.y = cmd.view_angles.y + 30
                    end
                end
            end

            if cmd.forwardmove < 0 then
                cmd.view_angles.x = 89
                cmd.in_moveleft = 1
                cmd.in_moveright = 0
                cmd.in_forward = 1
                cmd.in_back = 0
                if cmd.sidemove == 0 then
                    cmd.view_angles.y = cmd.view_angles.y + 90
                end
                if cmd.sidemove > 0 then
                    cmd.view_angles.y = cmd.view_angles.y + 150
                end
                if cmd.sidemove < 0 then
                    cmd.view_angles.y = cmd.view_angles.y + 30
                end
            end
        end
    }

    :struct 'damage_indicator' {
        r_font = render_load_font('Verdana', 12, 'ad'),

        init = function(self)
            local new_interp_fn = smoothy.new({
                damage_easing = 0,
                global_alpha = 1
            })

            local group = ui_create('Global', 'Dragging shit..')
            local x = group:slider("min_dmg ( аххаха x", 0, ctx.cheat.screen_size.x, ctx.cheat.screen_size.x/2 + 50):visibility(false)
            local y = group:slider("min_dmg ( аххаха y", 0, ctx.cheat.screen_size.y, ctx.cheat.screen_size.y/2):visibility(false)
            local DPI_Scale = group:slider('лмаооооо2о дпи', 75, 200, 100);DPI_Scale:visibility(false)

            local area_box = function(dg)
                is_in_area = dg.list.in_drag_area

                self.r_font:set_size(12*DPI_Scale:get()/100)
                local new_interp = new_interp_fn.value
                local min_dmg = math.floor(new_interp.damage_easing)

                new_interp_fn(0.02, {
                    damage_easing = ctx.refs.min_dmg:get(),
                    size_y = dg.size.y,
                    size_x = dg.size.x,
                    dpi_modifier = DPI_Scale:get()
                })

                render_rect_outline(vector(dg.position.x, dg.position.y), vector(dg.position.x + (new_interp_fn.value.size_x), dg.position.y + (new_interp_fn.value.size_y)), color(85, 85, 85):alpha_modulate(ui_get_alpha()*255*new_interp_fn.value.global_alpha), 0, 4)
                render_rect(vector(dg.position.x, dg.position.y), vector(dg.position.x + (new_interp_fn.value.size_x), dg.position.y + (new_interp_fn.value.size_y)), color(85, 85, 85):alpha_modulate(ui_get_alpha()*75*new_interp_fn.value.global_alpha), 4)

                render_text(self.r_font, vector(dg.position.x + new_interp_fn.value.size_x/2, dg.position.y + new_interp_fn.value.size_y/2), color(), 'c', min_dmg == 0 and 'DYN.' or min_dmg)
            end

            local new_drag_object = dragging_fn().register({x, y}, vector(35*DPI_Scale:get()/100, 35*DPI_Scale:get()/100), "min_damage", area_box)

            events['mouse_input']:set(function(c)
                if not is_in_area or not ctx.menu.elements.settings.dragables_control:get('Scroll Resize') then
                    return
                end


                if c.wheel == -1 then DPI_Scale:set(DPI_Scale:get()-25) new_drag_object = dragging_fn().register({x, y}, vector(35*DPI_Scale:get()/100, 35*DPI_Scale:get()/100), "min_damage", function(self) area_box(self) end) elseif c.wheel == 1 then DPI_Scale:set(DPI_Scale:get()+25) new_drag_object = dragging_fn().register({x, y}, vector(35*DPI_Scale:get()/100, 35*DPI_Scale:get()/100), "min_damage", function(self) area_box(self) end) end
               -- return false
            end)

            events.render:set(
                function()
                    if not entity_get_local_player() or (not entity_get_local_player():is_alive() and ui_get_alpha() == 0) or not ctx.menu.elements.visuals.indicator_tweaks:get('Damage ind.') or not ctx.menu.elements.visuals.on_screen:get() then
                        return
                    end

                    new_drag_object:update(
                        ctx.menu.elements.settings.dragables_control:get('Center Magnitize')
                    )
                end
            )

        end
    }

    :struct 'bottom_indicators' {
        new_interp = smoothy.new({
            global_alpha = 0,
        }),

        init = function(self)
            local total_hits = 0
            local total_misses = 0

            events.aim_ack:set(function(e)
                total_hits = total_hits + 1
                if e.state ~= nil then
                    total_misses = total_misses + 1
                end
            end)

            events.render:set(function()
                local ex = function(ind)
                    return not ctx.menu.elements.visuals.exclude_indicators:get(ind)
                end

                local global_alpha = self.new_interp.value.global_alpha
                local charge = rage_exploit:get()

                self.new_interp(0.075, {
                    global_alpha = (ctx.menu.elements.visuals.eso_indicators:get() and entity_get_local_player() ~= nil and entity_get_local_player():is_alive()) and 1 or 0
                })

                if global_alpha == 0 then return end

                local colorArray = {
                    Light_Gray = color(200, 255*global_alpha),
                    Normal_Blue = color(90, 126, 219, 255*global_alpha)
                }

                if ctx.refs.fake_latency:get() > 0 and ex('Fake Latency') then
                    render_indicator(color(220,200,150,255*global_alpha), 'PING')
                end

                if ex('Min. Damage') then
                    render_indicator(colorArray.Light_Gray, ctx.refs.min_dmg:get())
                end

                if ex('Aimbot Stats') then
                    local chance = (total_hits / (total_misses + total_hits))*100

                    if total_misses == 0 and total_hits == 0 then
                        return
                    end

                    render_indicator(colorArray.Light_Gray, total_hits .. " / " .. total_misses .. " (" .. string_format("%.1f", chance) .. ") ")
                end

                if ctx.refs.hs:get() and ex('Hide Shots') then
                    render_indicator(colorArray.Light_Gray, 'OS')
                end

                if ctx.refs.freestanding_yaw:get() and ex('Freestanding') then
                    render_indicator(colorArray.Light_Gray, 'FS')
                end

                if ctx.refs.dormant_aimbot:get() and ex('Dormant Aim') then
                    render_indicator(colorArray.Light_Gray, 'DA')
                end

                if ctx.refs.body_aim:get() == 'Force' and ex('Body Aim') then
                    render_indicator(colorArray.Normal_Blue, 'BODY')
                end

                if ctx.refs.safe_points:get() == 'Force' and ex('Safe Points') then
                    render_indicator(colorArray.Normal_Blue, 'SAFE')
                end

                if ctx.refs.fake_duck:get() and ex('Fake Duck') then
                    render_indicator(colorArray.Light_Gray, 'DUCK')
                end

                if ctx.refs.dt:get() and ex('Double Tap') then
                    render_indicator(color(255, 255*charge, 255*charge, 255*global_alpha), 'DT')
                end
            end)
        end
    }

    :struct 'manual_arrows' {
        new_interp = smoothy.new({
            global_alpha = 0,
            left_arrow = 0,
            right_arrow = 0,
        }),
        init = function(self)
            local font = render_load_font("Verdana", 16, 'a')

            events.render:set(function()
                if ctx.menu.elements.antiaims.antiaim_mode:get() ~= 2 then
                    return
                end

                local _color = ctx.menu.elements.visuals.arrows_color:get()
                local sx, sy = ctx.cheat.screen_size.x, ctx.cheat.screen_size.y

                local new_interp = self.new_interp.value
                local global_alpha = new_interp.global_alpha
                local drag_offset = math.ceil(self.tween.data.drag_indicators * 15)

                self.new_interp(0.1, {
                    global_alpha = (ctx.menu.elements.antiaims.manual_aa:get() ~= 'Disabled') and 1 or 0,
                    left_arrow = ctx.menu.elements.antiaims.manual_aa:get() == 'Left' and 1 or 0,
                    right_arrow = ctx.menu.elements.antiaims.manual_aa:get() == 'Right' and 1 or 0,
                })

                --inactive arrows
                render_text(font, vector(sx/2 - 51*global_alpha, sy/2 + drag_offset), color(74, 74, 74, 175*global_alpha), 'c', '<')
                render_text(font, vector(sx/2 + 50*global_alpha, sy/2 + drag_offset), color(74, 74, 74, 175*global_alpha), 'c', '>')

                --active arrows
                render_text(font, vector(sx/2 - 51*global_alpha, sy/2 + drag_offset), _color:alpha_modulate(255*new_interp.left_arrow*global_alpha), 'c', '<')
                render_text(font, vector(sx/2 + 50*global_alpha, sy/2 + drag_offset), _color:alpha_modulate(255*new_interp.right_arrow*global_alpha), 'c', '>')

                if ctx.menu.elements.antiaims.manual_aa:get() == 'Forward' then
                    local alpha = math.clamp(math_floor(math.sin(globals.realtime * 6) * (1*255/2-1) + 1*255/2) or 1*255, 30, 255)

                    render_text(font, vector(sx/2 - 51*global_alpha, sy/2 + drag_offset), _color:alpha_modulate(alpha*global_alpha), 'c', '<')
                    render_text(font, vector(sx/2 + 50*global_alpha, sy/2 + drag_offset), _color:alpha_modulate(alpha*global_alpha), 'c', '>')
                end
            end)
        end
    }

    :struct 'watermark' {
        new_interp = smoothy.new({
            global_alpha = 0
        }),

        init = function(self)
            --[[
            local drag_pos = drag.new(ctx.menu.watermark_drag:set_visible(false), vector(150, 50))

            events.mouse_input:set(
                function()
                    if not entity_get_local_player() or (ui_get_alpha() == 0) or not ctx.menu.elements.visuals.watermark:get() then
                        return
                    end

                    return not (drag_pos:update(100) == false)
                end
            )

            events.render:set(function()
                local new_interp = self.new_interp.value
                local vec = drag_pos:get()

                self.new_interp(0.1, {
                    global_alpha = ctx.menu.elements.visuals.watermark:get() and 1 or 0
                })

                if new_interp.global_alpha == 0 or (new_interp.global_alpha == 0 and ui_get_alpha() == 0) then
                    return
                end

                local text = '$ Envious premium'
                local _color = ctx.menu.elements.visuals.watermark_accent:get()
                local tx, ty = render_measure_text(1, '', text).x, render_measure_text(1, '', text).y

                local animated_text = gradient.text_animate(text, 3, {
                    ui_get_style('Link Active'),
                    _color

                });animated_text:animate()

                render_rect_outline(vector(vec.x - 5, vec.y + 80), vector(vec.x + 110, vec.y + 100), color(200, 200, 200):alpha_modulate(ui_get_alpha()*255*new_interp.global_alpha), 0,4.5)
                render_text(1, vector(vec.x, vec.y + 83), color():alpha_modulate(255*new_interp.global_alpha), '', animated_text:get_animated_text())
                render_shadow(vector(vec.x, vec.y + 83 + ty/2), vector(vec.x + tx, vec.y + 83 + ty/2), _color:alpha_modulate(_color.a*new_interp.global_alpha), 25, 0, 0)
            end)
            ]]
        end
    }

    :struct 'teleport_in_air' {
        extrapolated_pos = vector(0, 0, 0),
        discharge_pos = vector(0,0,0),
        is_teleported = false,

        should_teleport = false,
        get_closet_enemy = function()
            return entity_get_threat(true)
        end,

        ticks_to_work = 0,

        init = function(self, cmd)
            local me = entity_get_local_player()
            if me == nil then return end

            if ctx.refs.hs:get() and not ctx.refs.dt:get() then return end
            if not ctx.menu.elements.ragebot.dt_discharge:get() or not cmd.in_jump then return end

            local weap = me:get_player_weapon()
            if weap == nil then return end

            local weap_id = weap:get_classid()
            local weapons = ctx.menu.elements.ragebot.dt_discharge_weapons
            local correct_weapon = false

            if weap_id == 267 and weapons:get('Scout') then
                correct_weapon = true
            elseif weap_id == 46 and weapons:get('Heavy Pistols') then
                correct_weapon = true
            elseif weap_id == 107 and weapons:get('Knife') then
                correct_weapon = true
            elseif weap_id == 233 and weapons:get('AWP') then
                correct_weapon = true
            elseif (weap_id == 242 or weap_id == 261) and weapons:get('Auto Snipers') then
                correct_weapon = true
            elseif weap_id == 268 and weapons:get('Taser') then
                correct_weapon = true
            end

            if not correct_weapon then return end

            local local_next = me["m_vecVelocity"]
            local next_vector = vector(move_raw.x , move_raw.y , 0)
            local lp_pos = me:get_hitbox_position(0)

            self.extrapolated_pos = ctx.tools.extrapolate(me , lp_pos , 2 , 0)
            self.discharge_pos = self.extrapolated_pos + move*0.1

            local p = self.get_closet_enemy()
            if not p then return end

            local orig_damage = utils_trace_bullet(p ,p:get_eye_position(), self.extrapolated_pos)
            local discharge_damage = utils_trace_bullet(p ,p:get_eye_position(), self.discharge_pos)

            if rage_exploit:get() < 0.9 and self.is_teleported  then
                rage_exploit:force_charge()
            end

            if orig_damage > discharge_damage and (discharge_damage > 1) then
                self.should_teleport = true
            else
                self.is_teleported = false
            end

            if self.should_teleport then
                if self.ticks_to_work == ctx.menu.elements.ragebot.dt_discharge_delay:get() then
                    rage_exploit:force_teleport()

                    self.should_teleport = false
                    self.ticks_to_work = 0
                    self.is_teleported = true
                else
                    self.ticks_to_work = self.ticks_to_work+1
                    self.is_teleported = false
                end
            end

        end
    }

    :struct 'holo_keybinds' {
        init = function(self)
            local font = render_load_font('Verdana', 24, 'rab')

            local indicators = {  }
            local new_interp = smoothy.new({
                dt = 0,
                hitbox_pos = vector(0, 0, 0),
            })

            local function rendery(x,startingy,r,g,b,a,text)
                local fr = a/255
                local width, height = render_measure_text(1, '', text).x + 8, render_measure_text(1, '', text).y
                local offset =1 * (height + 8)
                local gradient_width = math.floor(width / 2)
                local y = startingy + offset

                x = x

                render_gradient(vector(x, y - 8), vector(x + width, y + height + 2), color(0, 0, 0, 100*fr) , color(0, 0, 0, 0), color(0, 0, 0, 100*fr), color(0, 0, 0, 0))
                render_gradient(vector(x, y - 8), vector(x - width, y + height + 2), color(0, 0, 0, 100*fr) , color(0, 0, 0, 0), color(0, 0, 0, 100*fr), color(0, 0, 0, 0))

                render_text(font, vector(x , y + 2), color(r,g,b,a), 'c', text:upper())
            end

            local draw_indicator = function(bind, name, clr)
                local _color = clr or ctx.menu.elements.visuals.holo_kb_color:get()

                if not name then
                    name = bind.name
                end

                local alpha = new_interp(0.045, {
                    [bind.name] = bind.active and 255 or 0
                })

                indicators[#indicators + 1] = {_color.r, _color.g, _color.b, new_interp.value[bind.name]*(new_interp.value.global_alpha or 0), name}
            end

            local x_mod = 0

            events.render:set(function( )
                new_interp(0.1, {
                    global_alpha = ctx.menu.elements.visuals.holo_indicator:get()
                })
                local lp = entity_get_local_player()

                if not lp or new_interp.value.global_alpha == 0 then
                    return
                end

                local binds = ui_get_binds()
                local ex = function(ind)
                    return not ctx.menu.elements.visuals.exclude_holo_kb:get(ind)
                end

                for i=1, #binds do

                    local charge = rage_exploit:get()
                    local _color = ctx.menu.elements.visuals.holo_kb_color:get();_color = color(_color.r, _color.g*charge, _color.b*charge, _color.a)
                    if binds[i].name:lower() == 'double tap' and ex('Double Tap') then
                        draw_indicator(binds[i], 'DT', _color)
                    end

                    if binds[i].name:lower() == 'hide shots' and ex('Hide Shots') then
                        draw_indicator(binds[i], 'HIDE')
                    end

                    if binds[i].name:lower() == 'min. damage' and ex('Min. Damage') then
                        draw_indicator(binds[i], 'DMG')
                    end

                    if binds[i].name:lower() == 'freestanding' and ex('Freestanding') then
                        draw_indicator(binds[i], 'FS')
                    end

                    if binds[i].name:lower() == 'fake duck' and ex('Fake Duck') then
                        draw_indicator(binds[i], 'DUCK')
                    end

                    if binds[i].name:lower() == 'body aim' and ex('Body Aim') and binds[i].value == 'Force' then
                        draw_indicator(binds[i], 'BODY')
                    end

                    if binds[i].name:lower() == 'safe points' and ex('Safe Points') and binds[i].value == 'Force' then
                        draw_indicator(binds[i], 'SAFE')
                    end
                end

                for i,v in ipairs(indicators) do
                    local render_origin = ctx.tools:get_muzzle_attachment(lp)
                    local thirdperson = common.is_in_thirdperson()

                    if thirdperson then
                        render_origin = lp:get_hitbox_position(2)
                    end

                    local easing = new_interp.value
                    if render_origin == nil or render_origin.x == nil then
                        return
                    end

                    local eyex, eyey, eyez = render_origin.x, render_origin.y, render_origin.z
                    local camp, camy = render_camera_angles().x, render_camera_angles().y
                    local rad = math.rad(camy - 90)
                    local px, py, pz = eyex + 25 * math.cos(rad), eyey + 25 * math.sin(rad), eyez + 20
                    if px == nil or py == nil or pz == nil or render_world_to_screen(vector(px, py, pz)) == nil then
                        return
                    end
                    local sx, sy = render_world_to_screen(vector(px, py, pz)).x, render_world_to_screen(vector(px, py, pz)).y

                    if not sx or not sy then return end
                    local me = lp
                    local scoped = me.m_bIsScoped
                    local frames = 2 * globals.frametime -- modify to change scoped Anim. Speed
                    if scoped == 1 then x_mod = x_mod + frames; if x_mod > 0.99 then x_mod = 1 end else x_mod = x_mod - frames; if x_mod < 0 then x_mod = 0 end end
                    local add_x = (-250) * x_mod

                    local fraction = v[4]/255
                    sx = (thirdperson and ctx.menu.elements.visuals.persperctive_holo:get('Third Person')) and sx/ (ctx.menu.elements.visuals.third_person_pos:get() == 'Left' and 1.5825 or 1.06) or ctx.tools:get_muzzle_attachment(lp):to_screen().x + 50
                    sy = (thirdperson and ctx.menu.elements.visuals.persperctive_holo:get('Third Person')) and sy or ctx.tools:get_muzzle_attachment(lp):to_screen().y - 275

                    new_interp(0.275, {
                        sx = sx,
                        sy = sy
                    });sx = easing.sx; sy = easing.sy

                    local force_viewmodel = ui_find("Visuals", "World", "Main", "Override Zoom", "Force Viewmodel"):get()
                    local render_fp = true
                    if scoped and not force_viewmodel then
                        render_fp = false
                    end

                    if (thirdperson and ctx.menu.elements.visuals.persperctive_holo:get('Third Person')) or (not thirdperson and ctx.menu.elements.visuals.persperctive_holo:get('First Person') and render_fp) then
                        rendery(sx+add_x,sy+200+(25*i),v[1],v[2],v[3],v[4],v[5])
                    end
                end

                indicators = {  }
            end)
        end
    }

    :struct 'Widgets' {
        keybinds = smoothy.new({
            global_alpha = 0,
            maximum_offset = 100,
        }),

        watermark = smoothy.new({
            global_alpha = 0,
            maximum_offset = 0
        }),

        speclist = smoothy.new({
            global_alpha = 0,
            maximum_offset = 100,
            active = 0
        }),

        init = function(self)
            --[[local spectator_list do
                local header_position = drag.new(ctx.menu.speclist_drag, vector(
                    1000,
                    250
                ))

                events.mouse_input:set(function()
                    if (ui_get_alpha() == 0) then
                        return
                    end

                    return not (header_position:update(150) == false)
                end)

                local kb_header_font = render_load_font('nl\\Envious\\sans700.ttf', 14, 'ad')
                local kb_text_font = render_load_font('nl\\Envious\\sans300.ttf', 12, 'ab')
                local background = render_load_image_from_file('nl\\Envious\\wave.png', vector(1000, 1000))

                events.render:set(function()
                    local maximum_offset = 100
                    local render_vec = header_position:get()
                    local new_interp = self.speclist.value

                    self.speclist(0.06, {
                        global_alpha = (ctx.menu.elements.visuals.Widgets:get() and ctx.menu.elements.visuals.solus_select:get('Spectators List')) and 1 or 0,
                    })

                    if new_interp.global_alpha == 0 or (new_interp.global_alpha == 0 and ui_get_alpha() == 0) then
                        return
                    end

                    local me = entity_get_local_player()

                    if me == nil then return end
                    if me.m_hObserverTarget and (me.m_iObserverMode == 4 or me.m_iObserverMode == 5) then
                        me = me.m_hObserverTarget
                    end

                    local speclist = me:get_spectators()
                    local is_speclist_shown = false
                    for idx,player_ptr in pairs(speclist) do
                        is_speclist_shown = true
                        local text_width = render_measure_text(kb_text_font, '', player_ptr:name()).x + 25
                        maximum_offset = text_width > maximum_offset and text_width or maximum_offset

                        self.speclist(0.1, {
                            maximum_offset = maximum_offset,
                        })

                        local sx, sy = ctx.cheat.screen_size.x, ctx.cheat.screen_size.y
                        local name = player_ptr:name()
                        local tx = render_measure_text(1, '', name).x

                        --self.speclist
                        local avatar = player_ptr:get_steam_avatar()
                        if player_ptr:is_bot() and not player_ptr:is_player() then goto skip end

                        self.speclist(0.1, {
                            [idx] = idx
                        })

                        render_texture(avatar, vector(render_vec.x + 4, render_vec.y + 14 + (20 *idx)), vector(12, 13), color():alpha_modulate(255*new_interp.global_alpha*new_interp.active), 'f', 20)
                        render_text(kb_text_font, vector(render_vec.x + 24, render_vec.y + 14 + (20 *idx)), color():alpha_modulate(255*new_interp.global_alpha*new_interp.active), 'u', name)
                        ::skip::
                    end

                    self.speclist(0.1, {
                        active = (is_speclist_shown or ui_get_alpha() > 0) and 1 or 0,
                        glowing_amount = ctx.menu.elements.visuals.solus_shadows:get()
                    })

                    local spectator_header do
                        local maximum_offset = new_interp.maximum_offset
                        local shadows_color = ui_get_style 'Shadows'
                        local keyboard_icon = string.format('\a%s%s  \aDEFAULT', ui_get_style('Link Active'):to_hex(), ui_get_icon 'eye')

                        local x,y = render_vec.x, render_vec.y
                        local w = new_interp.maximum_offset

                        render_shadow(render_vec, vector(render_vec.x + maximum_offset - 1, render_vec.y + 26), shadows_color:alpha_modulate(shadows_color.a*new_interp.global_alpha*new_interp.active), 20, 0, 10)
                        render_rect(render_vec, vector(render_vec.x + maximum_offset + 1, render_vec.y + 28), color(9, 14, 27, 255*new_interp.global_alpha*new_interp.active), 5)
                        render_texture(background, vector(render_vec.x+ 1, render_vec.y - 12), vector(maximum_offset, 40), color():alpha_modulate(255*new_interp.global_alpha*new_interp.active), 'f', 5)

                        render_text(kb_header_font, vector(render_vec.x + 7, render_vec.y + 6.5), color():alpha_modulate(255*new_interp.global_alpha*new_interp.active), '', keyboard_icon, 'Spectators' )
                    end
                end)
            end-]]

            local watermark do

                local background = render_load_image_from_file('nl\\Envious\\wave.png', vector(1000, 1000))
                local watermark_font_alt = render_load_font('nl\\Envious\\sans300.ttf', vector(12, 14), 'adbu')

                local frame_time = 0
                local latency = '0ms'
                local fps = 0

                local get_latency = function()
                    local netchannel = utils_net_channel()

                    if netchannel == nil then
                        return ''
                    end

                    local latency = math.floor(netchannel.latency[1] * 1000)
                    return latency ~= 0 and latency .. 'ms' or 'local'
                end

                local set_icon = function(icon)
                    local active_color = ui_get_style 'Link Active':to_hex()

                    return ctx.menu.elements.visuals.solus_icons:get() and string.format('\a%s%s\aDEFAULT  ', active_color, icon) or ''
                end

                local set_separator = function(sep_tbl)
                    local link = ui_get_style 'Link':to_hex()

                    return '\a'..link..sep_tbl[ctx.menu.elements.visuals.solus_separator:get()]..'\aDEFAULT'
                end

                events.createmove_run:set(function(c)
                    if c.tick_count % 65 == 64 then
                        local frame_time = 0.9 * frame_time + (1.0 - 0.9) * globals.absoluteframetime
                        fps = math.floor(1.0 / frame_time* 0.1)

                        latency = get_latency()
                    end
                end)

                events.render:set(function()
                    local sx, sy = ctx.cheat.screen_size.x, ctx.cheat.screen_size.y

                    local new_interp = self.watermark.value
                    self.watermark(0.06, {
                        global_alpha = (ctx.menu.elements.visuals.Widgets:get() and ctx.menu.elements.visuals.solus_select:get('Watermark')) and 1 or 0,
                        glowing_amount = ctx.menu.elements.visuals.solus_shadows:get()
                    })

                    if new_interp.global_alpha == 0 or (new_interp.global_alpha == 0 and ui_get_alpha() == 0) then
                        return
                    end

                    local date = common_get_date('%I:%M%p'):lower()
                    local global_accent = ctx.menu.elements.visuals.solus_global_accent:get()

                    local items_tbl = {
                        ['Nickname'] = ('%s%s'):format(set_icon(''), ctx.cheat.username),
                        ['Latency'] = ('%s%s'):format(set_icon(''), latency),
                        ['Framerate'] = ('%s%s'):format(set_icon(''), math.ceil(fps) .. 'fps'),
                        ['Tickrate'] = ('%s%s'):format(set_icon(''), '64tick'),
                        ['Time'] = ('%s%s'):format(set_icon(''), date)
                    }

                    local separators = {
                        ['Default'] = '  ',
                        ['Dot'] = ' • ',
                        ['Mini Dot'] = ' · ',
                        ['Legacy'] = ' | '
                    }

                    local watermark_text = ''
                    local prefix_text = '🫧'
                    local watermark_data = ctx.menu.elements.visuals.watermark_data:list()

                    for i=1, #watermark_data do
                        for n,v in pairs(items_tbl) do
                            if n == watermark_data[i] then
                                watermark_text = ('%s%s %s'):format(watermark_text, i ~= 1 and set_separator(separators) or '', v)
                            end
                        end
                    end

                    if ctx.menu.elements.visuals.solus_show_branch:get() then
                        prefix_text = ('%s\a2E2E2EC2%s\aDEFAULT %s'):format(prefix_text, set_separator(separators), ctx.cheat.build)
                    end

                    local text = string.format('%s', watermark_text)
                    local text_width, text_height = render_measure_text(watermark_font_alt, '', text).x, render_measure_text(1, '', text).y/2

                    local shadows_color = ctx.menu.elements.visuals.solus_shadow_clr:get()
                    if new_interp.glowing_amount > 0.75 then
                        render_shadow(vector(sx - text_width - 11, 5), vector(sx - 4, 28), shadows_color:alpha_modulate(shadows_color.a*new_interp.global_alpha), new_interp.glowing_amount, 0, 10)
                    end

                    render_rect(vector(sx - text_width - 11, 5), vector(sx - 4, 28), color(9, 14, 27, 255*new_interp.global_alpha), 5)
                    render_text(watermark_font_alt, vector(sx - 8 - text_width, 4 + text_height), global_accent:alpha_modulate(255*new_interp.global_alpha), '', text)

                    local prefix_width, prefix_height = render_measure_text(watermark_font_alt, '', prefix_text).x + 6, render_measure_text(watermark_font_alt, '', prefix_text).y

                    if new_interp.glowing_amount > 0.75 then
                        render_shadow(vector(sx - text_width - 14 - prefix_width, 5), vector(sx - text_width - 14, 28), shadows_color:alpha_modulate(shadows_color.a*new_interp.global_alpha), new_interp.glowing_amount, 0, 10)
                    end

                    render_rect(vector(sx - text_width - 14 - prefix_width, 5), vector(sx - text_width - 14, 28), color(9, 14, 27, 255*new_interp.global_alpha), 5)
                    render_text(watermark_font_alt, vector(sx - text_width - 11 - prefix_width, 4 + text_height), color():alpha_modulate(255*new_interp.global_alpha), '', prefix_text)
                end)
            end

            local renderer_keybinds do

                local max_width = {
                    name = '',
                    offset = 0
                }


                local kb_header_font = render_load_font('nl\\Envious\\sans700.ttf', 14, 'ad')
                local kb_text_font = render_load_font('nl\\Envious\\sans300.ttf', 12, 'ab')
                local background = render_load_image_from_file('nl\\Envious\\wave.png', vector(1000, 1000))

                local size_w = 160
                local group = ui_create('Global', 'Dragging shit..')
                local dx = group:slider("keybinds_x", 0, ctx.cheat.screen_size.x, ctx.cheat.screen_size.x/2):visibility(false)
                local dy = group:slider("keybinds_y", 0, ctx.cheat.screen_size.y, ctx.cheat.screen_size.y/1.5):visibility(false)

                local new_drag_object = dragging_fn().register({dx, dy}, vector(size_w, 30), "keybinds", function(self)
                    --render_rect_outline(vector(self.position.x, self.position.y), vector(self.position.x + self.size.x, self.position.y + self.size.y), color(85, 85, 85):alpha_modulate(ui_get_alpha()*255), 0, 4)
                    --render_rect(vector(self.position.x, self.position.y), vector(self.position.x + self.size.x, self.position.y + self.size.y), color(85, 85, 85):alpha_modulate(ui_get_alpha()*75), 4)

                    dx,dy = self.position.x, self.position.y
                end)

                events.render:set(function()
                    local show_keybinds = false

                    local render_vec = get_type(dx) == 'number' and vector(dx, dy) or vector(dx:get(), dy:get())
                    local new_interp = self.keybinds.value
                    local binds = ui_get_binds()

                    local maximum_offset = 40
                    local maximum_offset_var = 60
                    table.sort(binds, function(a,b)
                        local hash_old, length = fnv1a.hash(a.name)
                        local hash_new, length2 = fnv1a.hash(b.name)

                        return length > length2
                    end)

                    new_drag_object:update(
                        ctx.menu.elements.settings.dragables_control:get('Center Magnitize')
                    )

                    for i=1, #binds do
                        local name = binds[i].name
                        local text_width = render_measure_text(kb_text_font, '', name).x
                        maximum_offset = maximum_offset < text_width and text_width or maximum_offset

                        local key_var = ''..tostring(binds[i].value ~= true and binds[i].value or 'On')..''
                        local key_text_width = render_measure_text(kb_text_font, '', key_var).x*2
                        maximum_offset_var = maximum_offset_var < key_text_width and key_text_width or maximum_offset_var
                    end

                    self.keybinds(0.06, {
                        maximum_offset = maximum_offset + maximum_offset_var
                    })

                    for i=1, #binds do
                        if binds[i].active then
                            show_keybinds = true
                        end

                        local name = binds[i].name
                        local key_var = tostring(binds[i].value ~= true and '' .. binds[i].value .. '' or 'On')

                        self.keybinds(0.06, {
                            [name] = {
                                offset = 16*i,
                                alpha = binds[i].active and 255 or 0,
                            }
                        })

                        local x,y = render_vec.x, render_vec.y

                        render_text(kb_text_font, vector(x + 5, y + 18 + new_interp[name].offset), color(255, 255, 255, new_interp[name].alpha)*new_interp.global_alpha, '', name)
                        render_text(kb_text_font, vector(x + new_interp.maximum_offset - render_measure_text(kb_text_font, '', key_var).x- 3, y + 18 + new_interp[name].offset), color(255, 255, 255, new_interp[name].alpha*new_interp.global_alpha), '', key_var)

                        --render_text(kb_header_font, vector(render_vec.x, render_vec.y + 17 + new_interp[name].offset), color():alpha_modulate(new_interp[name].alpha), '', name)
                        --render_text(kb_header_font, vector(render_vec.x + maximum_offset-kx, render_vec.y + 17 + new_interp[name].offset), color():alpha_modulate(new_interp[name].alpha), '', key_var)
                    end

                    self.keybinds(0.06, {
                        global_alpha = ((show_keybinds or ui_get_alpha() > 0) and ctx.menu.elements.visuals.Widgets:get() and ctx.menu.elements.visuals.solus_select:get('Hotkeys List') ) and 1 or 0,
                        glowing_amount = ctx.menu.elements.visuals.solus_shadows:get()
                    })

                    if new_interp.global_alpha == 0 then
                        return end

                    local keybinds_header do
                        local maximum_offset = new_interp.maximum_offset
                        local shadows_color = ui_get_style 'Shadows'
                        local keyboard_icon = string.format('\a%s%s  \aDEFAULT', ui_get_style('Link Active'):to_hex(), ui_get_icon 'keyboard')

                        local x,y = render_vec.x, render_vec.y
                        local w = new_interp.maximum_offset

                        render_shadow(render_vec, vector(render_vec.x + maximum_offset - 1, render_vec.y + 27), shadows_color:alpha_modulate(shadows_color.a*new_interp.global_alpha), 20, 0, {20, 20, 0, 0})
                        render_rect(render_vec, vector(render_vec.x + maximum_offset + 1, render_vec.y + 28), color(9, 14, 27, 255*new_interp.global_alpha), {5, 5, 0, 0})
                        render_texture(background, vector(render_vec.x+ 1, render_vec.y - 12), vector(maximum_offset, 40), color():alpha_modulate(255*new_interp.global_alpha), 'f', 5)

                        render_text(kb_header_font, vector(render_vec.x + 7, render_vec.y + 6.5), color():alpha_modulate(255*new_interp.global_alpha), '', keyboard_icon, 'Hotkeys' )
                    end
                end)


            end

        end
    }

    :struct 'hitmarker' {
        new_interp = smoothy.new({
            global_alpha = 1,
        }),

        init = function(self)
            local hitgroups = {
                [1] = {0, 1},
                [2] = {4, 5, 6},
                [3] = {2, 3},
                [4] = {13, 15, 16},
                [5] = {14, 17, 18},
                [6] = {7, 9, 11},
                [7] = {8, 10, 12}
            }

            local shot_data = {  }
            local font = render_load_font('nl\\Envious\\sans500.ttf', 14, 'adb')

            events.render:set(function()
                self.new_interp(0.1, {
                    global_alpha = (not ctx.menu.elements.visuals.hitmarker_switch:get()) and 0 or 1
                })

                local new_interp = self.new_interp.value
                if new_interp.global_alpha == 0 or not entity_get_local_player() then
                    return
                end

                local size      = ctx.menu.elements.visuals.world_hitmarker_size:get()
                local r, g, b   = ctx.menu.elements.visuals.world_hitmarker_color:get().r, ctx.menu.elements.visuals.world_hitmarker_color:get().g, ctx.menu.elements.visuals.world_hitmarker_color:get().b

                for tick, data in pairs(shot_data) do
                    if data.draw then
                        if globals.curtime >= data.time then
                            data.alpha = data.alpha - 2
                        end

                        if data.alpha <= 0 then
                            data.alpha = 0
                            data.draw = false
                        end

                        if data == nil or data.x == nil or data.y == nil or data.z == nil or vector(data.x, data.y, data.z):to_screen() == nil then
                            return
                        end

                        local sx, sy = vector(data.x, data.y, data.z):to_screen().x, vector(data.x, data.y, data.z):to_screen().y
                        if sx ~= nil then
                            render_line(vector(sx + size, sy + size), vector(sx + (size * 2), sy + (size * 2)), color(r, g, b, data.alpha*new_interp.global_alpha))
                            render_line(vector(sx - size, sy + size), vector(sx - (size * 2), sy + (size * 2)), color(r, g, b, data.alpha*new_interp.global_alpha))
                            render_line(vector(sx + size, sy - size), vector(sx + (size * 2), sy - (size * 2)), color(r, g, b, data.alpha*new_interp.global_alpha))
                            render_line(vector(sx - size, sy - size), vector(sx - (size * 2), sy - (size * 2)), color(r, g, b, data.alpha*new_interp.global_alpha))

                            if ctx.menu.elements.visuals.dmg_marker:get() then
                                render_text(font, vector(sx, sy - (20 * data.alpha/255)), color(r, g, b, data.alpha*new_interp.global_alpha), '', data.dmg)
                            end
                        end
                    end
                end
            end)

            events.player_hurt:set(function(e)

                local me = entity_get_local_player()
                local victim_entindex = entity_get(e.userid, true)
                local attacker_entindex = entity_get(e.attacker, true)

                if attacker_entindex ~= me then
                    return
                end

                local tick = globals.tickcount
                local data = shot_data[tick]

                if shot_data[tick] == nil or data.impacts == nil then
                    return
                end

                local impacts = data.impacts
                local hitboxes = hitgroups[e.hitgroup]
                local hit = nil
                local closest = math.huge

                for i=1, #impacts do
                    local impact = impacts[i]

                    if hitboxes ~= nil then
                        for j=1, #hitboxes do
                            local x, y, z = victim_entindex:get_hitbox_position(hitboxes[j]).x, victim_entindex:get_hitbox_position(hitboxes[j]).y, victim_entindex:get_hitbox_position(hitboxes[j]).z
                            local distance = math.sqrt((impact.x - x) ^ 2 + (impact.y - y) ^ 2 + (impact.z - z) ^ 2)

                            if distance < closest then
                                hit = impact
                                closest = distance
                            end
                        end
                    end
                end

                if hit == nil then
                    return
                end

                shot_data[tick] = {
                    x = hit.x,
                    y = hit.y,
                    z = hit.z,
                    time = globals.curtime + ctx.menu.elements.visuals.world_hitmarker_time:get(),
                    alpha = 255,
                    draw = true,
                    dmg = e.hitgroup == 1 and '\aE92731FF' .. e.dmg_health or e.dmg_health,
                    entity = entity_get(e.userid, true),
                }
            end)

            events.bullet_impact:set(function(e)

                local me = entity_get_local_player()
                local victim_entindex = entity_get(e.userid, true)
                local attacker_entindex = entity_get(e.attacker, true)

                if victim_entindex ~= me then
                    return
                end

                local tick = globals.tickcount

                if shot_data[tick] == nil then
                    shot_data[tick] = {
                        impacts = {  }
                    }
                end

                local impacts = shot_data[tick].impacts

                if impacts == nil then
                    impacts = {  }
                end

                impacts[#impacts + 1] = {
                    x = e.x,
                    y = e.y,
                    z = e.z
                }
            end)

            events.round_start:set(function()
                shot_data = {  }
            end)
        end
    }

    :struct 'ideal_tick' {
        init = function()
            ctx.menu.elements.ragebot.ideal_tick_mod:set_callback(function(self)
                local state = self:get('Min. Damage')

                ctx.menu.elements.ragebot.ideal_tick_mindmg:visibility(state)
            end, true)

            events.createmove:set(function()
                local state = ctx.menu.elements.ragebot.ideal_tick:get()
                local self = ctx.menu.elements.ragebot.ideal_tick_mod

                ctx.refs.freestanding_yaw:override((self:get('Freestanding') and state ) or nil)
                ctx.refs.min_dmg:override((self:get('Min. Damage') and state ) and ctx.menu.elements.ragebot.ideal_tick_mindmg:get() or nil)
                ctx.refs.body_aim:override((self:get('Prefer Body') and state ) and 'Prefer' or nil)
                ctx.refs.safe_points:override((self:get('Prefer Safety') and state ) and 'Prefer' or nil)
            end)
        end
    }

    :struct 'magic_key' {
        init = function(self)
            ctx.menu.elements.ragebot.magic_key_mod:set_callback(function(self)

                ctx.menu.elements.ragebot.magic_key_hc:visibility(self:get('Hitchance'))
                ctx.menu.elements.ragebot.magic_key_autostop:visibility(self:get('Autostop'))
                ctx.menu.elements.ragebot.magic_key_heads:visibility(self:get('Pointscales'))
                ctx.menu.elements.ragebot.magic_key_bodys:visibility(self:get('Pointscales'))
            end, true)
            events.createmove:set(function(cmd)
                local a = ctx.menu.elements.ragebot.magic_key_mod

                ctx.refs.hitchance:override((ctx.menu.elements.ragebot.magic_key:get() and a:get('Hitchance')) and ctx.menu.elements.ragebot.magic_key_hc:get() or nil)
                ctx.refs.def_auto_stop:override((ctx.menu.elements.ragebot.magic_key:get() and a:get('Autostop')) and ctx.menu.elements.ragebot.magic_key_autostop:get() or nil)
                ctx.refs.dt_auto_stop:override((ctx.menu.elements.ragebot.magic_key:get() and a:get('Autostop')) and ctx.menu.elements.ragebot.magic_key_autostop:get() or nil)
                ctx.refs.head_scale:override((ctx.menu.elements.ragebot.magic_key:get() and a:get('Pointscales')) and ctx.menu.elements.ragebot.magic_key_heads:get() or nil)
                ctx.refs.body_scale:override((ctx.menu.elements.ragebot.magic_key:get() and a:get('Pointscales')) and ctx.menu.elements.ragebot.magic_key_bodys:get() or nil)
            end, true)
        end
    }

    :struct 'sound_ambient' {
        init = function(self)

            events.player_hurt:set(function(e)
                local me = entity_get_local_player()
                local user = entity.get(e.userid, true)
                local attacker = entity_get(e.attacker, true)

                if user == me then return end

                if me == attacker and e.health > 0 and ctx.menu.elements.s_amb.hitsounds:get() then
                    ctx.tools.play_sound('ym_announcer/enemy_body_hit.wav', ctx.menu.elements.s_amb.hitsounds_volume:get()/100)
                elseif me == attacker and e.health <= 0 and ctx.menu.elements.s_amb.killdeathsounds:get() then
                    ctx.tools.play_sound('ym_announcer/enemy_death.wav', ctx.menu.elements.s_amb.killdeathsounds_volume:get()/100)
                end
            end)

            events.player_death:set(function(e)
                local me = entity_get_local_player()
                local user = entity.get(e.userid, true)
                local attacker = entity.get(e.attacker, true)

                if attacker ~= me then return end

                if ctx.menu.elements.s_amb.announcements:get() then
                    if e.headshot then
                        ctx.tools.play_sound('ym_announcer/hs.wav', ctx.menu.elements.s_amb.announcements_volume:get()/100)
                    else
                        ctx.tools.play_sound('ym_announcer/'..(me.m_iNumRoundKills >= 6 and 6 or me.m_iNumRoundKills)..'.wav', ctx.menu.elements.s_amb.announcements_volume:get()/100)
                    end
                end

                if not ctx.menu.elements.s_amb.killdeathsounds:get() or me ~= user then return end
                ctx.tools.play_sound('ym_announcer/player_death.wav', ctx.menu.elements.s_amb.killdeathsounds_volume:get()/100)
            end)
        end
    }

--ctx class
ctx.menu:init()
ctx.render_flags:init()
ctx.config_system:init()
ctx.slowdown_indicator:init()

--resource class
resource.magic_key:init()
resource.ideal_tick:init()
resource.hitmarker:init()
resource.Widgets:init()
resource.watermark:init()
resource.indicators:init()
resource.custom_scope:init()
resource.holo_keybinds:init()
resource.manual_arrows:init()
resource.sound_ambient:init()
resource.aimbot_logging:init()
resource.TalkOnCondition:init()
resource.damage_indicator:init()
resource.bottom_indicators:init()
resource.viewmodel_changer:init()
resource.vgui_color_changer:init()

events.createmove:set(function(c)
    --legit aa
    ctx.tweaks:anti_aim_on_use_main(c)
    --bombsite e fix
    ctx.tweaks:bombsitefix(c)
    --teleport in air
    resource.teleport_in_air:init(c)
    --fast ladders
    resource.fast_ladder:init(c)
end)
events.shutdown:set(function()
    --unset refs' overrides
    for _,item in pairs(ctx.refs) do
        item:override()
    end

    files.write('configs_data.json', json.stringify(fucking_configs))
    --entity_get_local_player():set_icon('')
end)

local s = smoothy.new({
    alpha = 0
})

events['render']:set(function()
    local global_alpha = s(.075, {alpha = ctx.menu.elements.settings.dragables_control:get('Center Magnitize') and 1 or 0}).alpha

    if ui_get_alpha() > 0 then
        local x, y = ctx.cheat.screen_size.x, ctx.cheat.screen_size.y

        render_line(
            vector(x/2, 0), vector(x/2 - 1, y), color(170, 170, 170, 200*ui_get_alpha()*global_alpha)
        )

        render_line(
            vector(0, y/2), vector(x, y/2), color(170, 170, 170, 200*ui_get_alpha()*global_alpha)
        )
    end
end)

local font = render.load_font('Calibri Bold', vector(25, 22, -1), 'a,d')

events['render']:set(function()
    local screen_size = vector(render_screen_size().x/100 + 9, render_screen_size().y/1.47)

    table.foreach(buffer, function(i, element)
        local alpha = element.color.a/255
        local text_size = render_measure_text(font, 's', element.name)

        render_gradient(vector(8, screen_size.y/1.4 + ((text_size.y + 5) * i)), vector(8 + text_size.x/2, screen_size.y/1.4 + ((text_size.y + 10) * i) + text_size.y),
            color(0, 0, 0, 0),
            color(0, 0, 0, 60*alpha),
            color(0, 0, 0, 0),
            color(0, 0, 0, 60*alpha)
        )

        render_gradient(vector(8 + text_size.x/2, screen_size.y/1.4 + ((text_size.y + 5) * i)), vector(8 + text_size.x, screen_size.y/1.4 + ((text_size.y + 10) * i) + text_size.y),
            color(0, 0, 0, 60*alpha),
            color(0, 0, 0, 0),
            color(0, 0, 0, 60*alpha),
            color(0, 0, 0, 0)
        )

        render_text(font, vector(10, screen_size.y/1.4 + ((text_size.y + 10) * i)), element.color, 's', element.name)
    end)

    buffer = {}
end)

events.console_input:set(function(text)
    if text:find('name') then

        common.set_name(text:gsub('name ', ''))
    end
end)
