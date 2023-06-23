local inspect = require 'neverlose/inspect'

local images do
     local M = {}

    --
    -- dependencies
    --

    local ffi = require "ffi"
    local csgo_weapons = require "neverlose/csgo_weapons"

    local string_gsub = string.gsub
    local math_floor = math.floor
    local cast = ffi.cast

    local function vtable_entry(instance, index, type)
        return cast(type, (cast("void***", instance)[0])[index])
    end

    local function vtable_thunk(index, typestring)
        local t = ffi.typeof(typestring)
        return function(instance, ...)
            assert(instance ~= nil)
            if instance then
                return vtable_entry(instance, index, t)(instance, ...)
            end
        end
    end

    local function vtable_bind(module, interface, index, typestring)
        local instance = utils.create_interface(module, interface) or error("invalid interface")
        local fnptr = vtable_entry(instance, index, ffi.typeof(typestring)) or error("invalid vtable")
        return function(...)
            return fnptr(instance, ...)
        end
    end

    --
    -- ffi structs
    -- (mostly for image parsing)
    --

    local png_ihdr_t = ffi.typeof([[
    struct {
        char type[4];
        uint32_t width;
        uint32_t height;
        char bitDepth;
        char colorType;
        char compression;
        char filter;
        char interlace;
    } *
    ]])

    local jpg_segment_t = ffi.typeof([[
    struct {
        char type[2];
        uint16_t size;
    } *
    ]])

    local jpg_segment_sof0_t = ffi.typeof([[
    struct {
        uint16_t size;
        char precision;
        uint16_t height;
        uint16_t width;
    } __attribute__((packed)) *
    ]])

    local uint16_t_ptr = ffi.typeof("uint16_t*")
    local charbuffer = ffi.typeof("char[?]")
    local uintbuffer = ffi.typeof("unsigned int[?]")

    --
    -- constants
    --

    local INVALID_TEXTURE = -1
    local PNG_MAGIC = "\x89\x50\x4E\x47\x0D\x0A\x1A\x0A"

    local JPG_MAGIC_1 = "\xFF\xD8\xFF\xDB"
    local JPG_MAGIC_2 = "\xFF\xD8\xFF\xE0\x00\x10\x4A\x46\x49\x46\x00\x01"

    local JPG_SEGMENT_SOI = "\xFF\xD8"
    local JPG_SEGMENT_SOF0 = "\xFF\xC0"
    local JPG_SEGMENT_SOS = "\xFF\xDA"
    local JPG_SEGMENT_EOI = "\xFF\xD9"

    local RENDERER_LOAD_FUNCS = {
        png = render.load_image,
        svg = render.load_image,
        jpg = render.load_image,
        rgba = render.load_image_rgba
    }

    --
    -- utility functions
    --

    local function bswap_16(x)
        return bit.rshift(bit.bswap(x), 16)
    end

    local function hexdump(str)
        local out = {}
        str:gsub(".", function(chr)
            table.insert(out, string.format("%02x", string.byte(chr)))
        end)
        return table.concat(out, " ")
    end

    --
    -- small filesystem implementation
    --

    local native_ReadFile = vtable_bind("filesystem_stdio.dll", "VBaseFileSystem011", 0, "int(__thiscall*)(void*, void*, int, void*)")
    local native_OpenFile = vtable_bind("filesystem_stdio.dll", "VBaseFileSystem011", 2, "void*(__thiscall*)(void*, const char*, const char*, const char*)")
    local native_CloseFile = vtable_bind("filesystem_stdio.dll", "VBaseFileSystem011", 3, "void(__thiscall*)(void*, void*)")
    local native_GetFileSize = vtable_bind("filesystem_stdio.dll", "VBaseFileSystem011", 7, "unsigned int(__thiscall*)(void*, void*)")

    local function engine_read_file(filename)
        local handle = native_OpenFile(filename, "r", "MOD")
        if handle == nil then return end

        local filesize = native_GetFileSize(handle)
        if filesize == nil or filesize < 0 then return end

        local buffer = charbuffer(filesize + 1)
        if buffer == nil then return end

        local read_success = native_ReadFile(buffer, filesize, handle)
        if not read_success then return end

        return ffi.string(buffer, filesize)
    end

    --
    -- ISteamFriends / ISteamUtils
    --

    -- That shit now use ingame context of steamapi instead of connecting to global user
    -- enjoy, by w7rus

    ffi.cdef([[
        typedef struct
        {
            void* steam_client;
            void* steam_user;
            void* steam_friends;
            void* steam_utils;
            void* steam_matchmaking;
            void* steam_user_stats;
            void* steam_apps;
            void* steam_matchmakingservers;
            void* steam_networking;
            void* steam_remotestorage;
            void* steam_screenshots;
            void* steam_http;
            void* steam_unidentifiedmessages;
            void* steam_controller;
            void* steam_ugc;
            void* steam_applist;
            void* steam_music;
            void* steam_musicremote;
            void* steam_htmlsurface;
            void* steam_inventory;
            void* steam_video;
        } S_steamApiCtx_t;
    ]])

    local pS_SteamApiCtx = ffi.cast(
        "S_steamApiCtx_t**", ffi.cast(
            "char*",
            utils.opcode_scan("client.dll", "FF 15 ? ? ? ? B9 ? ? ? ? E8 ? ? ? ? 6A")
        ) + 7
    )[0] or error("invalid interface", 2)

    local native_ISteamFriends = ffi.cast("void***", pS_SteamApiCtx.steam_friends)
    local native_ISteamUtils = ffi.cast("void***", pS_SteamApiCtx.steam_utils)

    local native_ISteamFriends_GetSmallFriendAvatar = vtable_thunk(34, "int(__thiscall*)(void*, uint64_t)")
    local native_ISteamFriends_GetMediumFriendAvatar = vtable_thunk(35, "int(__thiscall*)(void*, uint64_t)")
    local native_ISteamFriends_GetLargeFriendAvatar = vtable_thunk(36, "int(__thiscall*)(void*, uint64_t)")

    local native_ISteamUtils_GetImageSize = vtable_thunk(5, "bool(__thiscall*)(void*, int, uint32_t*, uint32_t*)")
    local native_ISteamUtils_GetImageRGBA = vtable_thunk(6, "bool(__thiscall*)(void*, int, unsigned char*, int)")

    --
    -- image object implementation
    --

    local function image_measure(self, width, height)
        if width ~= nil and height ~= nil then
            return width, height
        else
            if self.width == nil or self.height == nil then
                error("Image dimensions not known, full size is required")
            elseif width == nil then
                height = height or self.height
                local width = math_floor(self.width * (height/self.height))
                return width, height
            elseif height == nil then
                width = width or self.width
                local height = math_floor(self.height * (width/self.width))
                return width, height
            else
                return self.width, self.height
            end
        end
    end

    local function image_draw(self, x, y, width, height, r, g, b, a, force_same_res_render, flags)
        width, height = image_measure(self, width, height)

        local id = string.format("%f_%f", width, height)
        local texture = self.textures[id]

        -- no texture with same width and height has been loaded
        if texture == nil then
            if ({next(self.textures)})[2] == nil or force_same_res_render or force_same_res_render == nil then
                -- try and load the texture
                local func = RENDERER_LOAD_FUNCS[self.type]
                if func then
                    if self.type == "rgba" then
                        width, height = self.width, self.height
                    end
                    texture = func(self.contents, vector(width, height))
                end

                if texture == nil then
                    self.textures[id] = INVALID_TEXTURE
                    error("failed to load texture for " .. width .. "x" .. height, 2)
                else
                    -- client.log("loaded svg ", self.name, " for ", width, "x", height)
                    self.textures[id] = texture
                end
            else
                --right now we just choose a random texture (determined by the pairs order aka unordered)
                --todo: select the texture with the highest or closest resolution?
                texture = ({next(self.textures)})[2]
            end
        end

        if texture == nil or texture == INVALID_TEXTURE then
            return
        elseif a == nil or a > 0 then
            render.texture(texture, vector(x, y), vector(width, height), color(r or 255, g or 255, b or 255, a or 255), flags or "f")
        end

        return width, height
    end

    local image_mt = {
        __index = {
            measure = image_measure,
            draw = image_draw
        }
    }

    --
    -- functions for loading images
    --

    local function load_png(contents)
        if contents:sub(1, 8) ~= PNG_MAGIC then
            error("Invalid magic", 2)
            return
        end

        local ihdr_raw = contents:sub(13, 30)
        if ihdr_raw:len() < 17 then
            error("Incomplete data", 2)
            return
        end

        local ihdr = cast(png_ihdr_t, cast("const uint8_t *", cast("const char*", ihdr_raw)))

        if ffi.string(ihdr.type, 4) ~= "IHDR" then
            error("Invalid chunk type, expected IHDR", 2)
            return
        end

        local width = bit.bswap(ihdr.width)
        local height = bit.bswap(ihdr.height)

        if width <= 0 or height <= 0 then
            error("Invalid width or height", 2)
            return
        end

        return setmetatable({
            type = "png",
            width = width,
            height = height,
            contents = contents,
            textures = {}
        }, image_mt)
    end

    local function load_jpg(contents)
        local buffer = ffi.cast("const uint8_t *", ffi.cast("const char *", contents))
        local len_remaining = contents:len()

        local width, height

        if contents:sub(1, 4) == JPG_MAGIC_1 or contents:sub(1, 12) == JPG_MAGIC_2 then
            local got_soi, got_sos = false, false

            -- read segments until we find a SOF0 header (containing width/height)
            while len_remaining > 0 do
                local segment = ffi.cast(jpg_segment_t, buffer)
                local typ = ffi.string(segment.type, 2)

                buffer = buffer + 2
                len_remaining = len_remaining - 2

                if typ == JPG_SEGMENT_SOI then
                    got_soi = true
                elseif not got_soi then
                    error("expected SOI segment", 2)
                elseif typ == JPG_SEGMENT_SOS or typ == JPG_SEGMENT_EOI then
                    if typ == JPG_SEGMENT_SOS then
                        got_sos = true
                    end
                    break
                else
                    -- endian convert of the size (be -> le)
                    local size = bswap_16(segment.size)

                    if typ == JPG_SEGMENT_SOF0 then
                        local sof0 = cast(jpg_segment_sof0_t, buffer)

                        height = bswap_16(sof0.height)
                        width = bswap_16(sof0.width)

                        if width <= 0 or height <= 0 then
                            error("Invalid width or height")
                            return
                        end
                    end

                    buffer = buffer + size
                    len_remaining = len_remaining - size
                end
            end

            if not got_soi then
                error("Incomplete image, missing SOI segment", 2)
                return
            elseif not got_sos then
                error("Incomplete image, missing SOS segment", 2)
                return
            elseif width == nil then
                error("Incomplete image, missing SOF0 segment", 2)
                return
            end
        else
            error("Invalid magic", 2)
            return
        end

        return setmetatable({
            type = "jpg",
            width = width,
            height = height,
            contents = contents,
            textures = {}
        }, image_mt)
    end

    local function load_svg(contents)
        -- try and find <svg> tag

        local match = contents:match("<svg(.*)>.*</svg>")
        if match == nil then
            error("Invalid svg, missing <svg> tag", 2)
            return
        end

        match = match:gsub("\r\n", ""):gsub("\n", "")

        -- parse tag contents
        local in_quote = false
        local key, value = "", ""

        local attributes = {}

        local offset = 1
        while true do
            local chr = match:sub(offset, offset)

            if chr == "" then
                break
            end

            if in_quote then
                -- text inside quotation marks
                if chr == "\"" then
                    in_quote = false
                    attributes[key:gsub("\t", ""):lower()] = value
                    key, value = "", ""
                else
                    value = value .. chr
                end
            else
                -- normal text, not inside quotes
                if chr == ">" then
                    break
                elseif chr == "=" then
                    if match:sub(offset, offset+1) == "=\"" then
                        in_quote = true
                        offset = offset + 1
                    end
                elseif chr == " " then
                    key = ""
                else
                    key = key .. chr
                end
            end

            offset = offset + 1
        end

        -- heuristics to find valid image width and height
        local width, height

        if attributes["width"] ~= nil then
            width = tonumber((attributes["width"]:gsub("px$", ""):gsub("pt$", ""):gsub("mm$", "")))

            if width ~= nil and 0 >= width then
                width = nil
            end
        end

        if attributes["height"] ~= nil then
            height = tonumber((attributes["height"]:gsub("px$", ""):gsub("pt$", ""):gsub("mm$", "")))

            if height ~= nil and 0 >= height then
                height = nil
            end
        end

        if width == nil or height == nil and attributes["viewbox"] ~= nil then
            local x, y, w, h = attributes["viewbox"]:match("^%s*([%d.]*) ([%d.]*) ([%d.]*) ([%d.]*)%s*$")

            width, height = tonumber(width), tonumber(height)

            if width ~= nil and height ~= nil and (0 >= width or 0 >= height) then
                width, height = nil, nil
            end
        end

        local self = setmetatable({
            type = "svg",
            contents = contents,
            textures = {}
        }, image_mt)

        if width ~= nil and height ~= nil and width > 0 and height > 0 then
            self.width, self.height = width, height
        end

        return self
    end

    local function load_rgba(contents, width, height)
        if width == nil or height == nil or width <= 0 or height <= 0 then
            error("Invalid size: width and height are required and have to be greater than zero.")
            return
        end

        local size = width*height*4
        if contents:len() ~= size then
            error("invalid buffer length, expected width*height*4", 2)
            return
        end

        -- load texture
        local texture = render.load_rgba(contents, vector(width, height))
        if texture == nil then
            return
        end

        return setmetatable({
            type = "rgba",
            width = width,
            height = height,
            contents = contents,
            textures = {[string.format("%f_%f", width, height)] = texture}
        }, image_mt)
    end

    local function load_image(contents)
        if type(contents) == "table" then
            if getmetatable(contents) == image_mt then
                return error("trying to load an existing image")
            else
                local result = {}
                for key, value in pairs(contents) do
                    result[key] = load_image(value)
                end
                return result
            end
        else
            -- try and determine type etc by looking for magic value
            if type(contents) == "string" then
                if contents:sub(1, 8) == PNG_MAGIC then
                    return load_png(contents)
                elseif contents:sub(1, 4) == JPG_MAGIC_1 or contents:sub(1, 12) == JPG_MAGIC_2 then
                    return load_jpg(contents)
                elseif contents:match("^%s*%<%?xml") ~= nil then
                    return load_svg(contents)
                else
                    return error("Failed to determine image type")
                end
            end
        end
    end

    local panorama_images = setmetatable({},  {__mode = "k"})
    local function get_panorama_image(path)
        if panorama_images[path] == nil then
            local path_cleaned = string_gsub(string_gsub(string_gsub(string_gsub(string_gsub(path, "%z", ""), "%c", ""), "\\", "/"), "%.%./", ""), "^/+", "")
            local contents = engine_read_file("materials/panorama/images/" .. path_cleaned)

            if contents then
                local image = load_image(contents)

                panorama_images[path] = image
            else
                panorama_images[path] = false
            end
        end

        if panorama_images[path] then
            return panorama_images[path]
        end
    end

    local weapon_icons = setmetatable({}, {__mode = "k"})
    local function get_weapon_icon(weapon_name)
        if weapon_icons[weapon_name] == nil then
            local weapon_name_cleaned
            local typ = type(weapon_name)

            if typ == "table" and weapon_name.console_name ~= nil then
                weapon_name_cleaned = weapon_name.console_name
            elseif typ == "number" then
                local weapon = csgo_weapons[weapon_name]
                if weapon == nil then
                    weapon_icons[weapon_name] = false
                    return
                end
                weapon_name_cleaned = weapon.console_name
            elseif typ == "string" then
                weapon_name_cleaned = tostring(weapon_name)
            elseif weapon_name ~= nil then
                weapon_icons[weapon_name] = nil
                return
            else
                return
            end

            weapon_name_cleaned = string_gsub(string_gsub(weapon_name_cleaned, "^weapon_", ""), "^item_", "")

            local image = get_panorama_image("icons/equipment/" .. weapon_name_cleaned .. ".svg")
            weapon_icons[weapon_name] = image or false
        end

        if weapon_icons[weapon_name] then
            return weapon_icons[weapon_name]
        end
    end

    images = {
        load = load_image,
        load_png = load_png,
        load_jpg = load_jpg,
        load_svg = load_svg,
        load_rgba = load_rgba,
        get_weapon_icon = get_weapon_icon,
        get_panorama_image = get_panorama_image,
    }
end

local native_GetTimescale = utils.get_vfunc('engine.dll', 'VEngineClient014', 91, 'float(__thiscall*)(void*)')

local to_pairs = {
    vector = { 'x', 'y', 'z' },
    imcolor =  { 'r', 'g', 'b', 'a' }
}

local function get_type(value)
    local val_type = type(value)

    if val_type == 'userdata' and value.__type then
        return string.lower(value.__type.name)
    end

    if val_type == 'boolean' then
        value = value and 1 or 0
    end

    return val_type
end

local function copy_tables(destination, keysTable, valuesTable)
    valuesTable = valuesTable or keysTable
    local mt = getmetatable(keysTable)

    if mt and getmetatable(destination) == nil then
        setmetatable(destination, mt)
    end

    for k,v in pairs(keysTable) do
        if type(v) == 'table' then
            destination[k] = copy_tables({}, v, valuesTable[k])
        else
            local value = valuesTable[k]

            if type(value) == 'boolean' then
                value = value and 1 or 0
            end

            destination[k] = value
        end
    end

    return destination
end

local function resolve(easing_fn, previous, new, clock, duration)
    if type(new) == 'boolean' then new = new and 1 or 0 end
    if type(previous) == 'boolean' then previous = previous and 1 or 0 end

    local previous = easing_fn(clock, previous, new - previous, duration)

    if type(new) == 'number' then
        if math.abs(new-previous) <= .001 then
            previous = new
        end

        if previous % 1 < .0001 then
            previous = math.floor(previous)
        elseif previous % 1 > .9999 then
            previous = math.ceil(previous)
        end
    end

    return previous
end

local function perform_easing(ntype, easing_fn, previous, new, clock, duration)
    if to_pairs[ntype] then
        for _, key in ipairs(to_pairs[ntype]) do
            previous[key] = perform_easing(
                type(v), easing_fn,
                previous[key], new[key],
                clock, duration
            )
        end

        return previous
    end

    if ntype == 'table' then
        for k, v in pairs(new) do
            previous[k] = previous[k] or v
            previous[k] = perform_easing(
                type(v), easing_fn,
                previous[k], v,
                clock, duration
            )
        end

        return previous
    end

    return resolve(easing_fn, previous, new, clock, duration)
end

-- Make Smoothy
local adjusted_speed

local new = function(default, easing_fn)
    if type(default) == 'boolean' then
        default = default and 1 or 0
    end

    local mt = { }
    local mt_data = {
        value = default or 0,
        easing = easing_fn or function(t, b, c, d)
            return c * t / d + b
        end
    }

    function mt.update(self, duration, value, easing, ignore_adj_speed)
        if type(value) == 'boolean' then
            value = value and 1 or 0
        end

        local clock = globals.frametime / native_GetTimescale()
        local duration = duration or .15
        local value_type = get_type(value)
        local target_type = get_type(self.value)

        assert(value_type == target_type, string.format('type mismatch. expected %s (received %s)', target_type, value_type))

        if self.value == value then
            return value
        end

        if adjusted_speed and ignore_adj_speed ~= true then
            duration = duration * adjusted_speed
        end

        if clock <= 0 or clock >= duration then
            if target_type == 'imcolor' or target_type == 'vector' then
                self.value = value:clone()
            elseif target_type == 'table' then
                copy_tables(self.value, value)
            else
                self.value = value
            end
        else
            local easing = easing or self.easing

            self.value = perform_easing(
                target_type, easing,
                self.value, value,
                clock, duration
            )
        end

        return self.value
    end

    return setmetatable(mt, {
        __metatable = false,
        __call = mt.update,
        __index = mt_data
    })
end

local new_interp = function(initial_value)
    return setmetatable({
        previous = initial_value or 0
    }, {
        __call = function(self, new_value, mul)
            local mul = mul or 1
            local tickinterval = globals.tickinterval * mul
            local difference = math.abs(new_value - self.previous)

            if difference > 0 then
                local clock = globals.frametime / native_GetTimescale()
                local time = math.min(tickinterval, clock) / tickinterval

                self.previous = self.previous + time * (new_value - self.previous)
            else
                self.previous = new_value
            end

            self.previous = (self.previous % 1 < .0001) and 0 or self.previous

            return self.previous
        end
    })
end

local set_speed = function(new_speed)
    if new_speed == true then return adjusted_speed or 1 end
    if new_speed == nil then adjusted_speed = nil end

    if type(new_speed) == 'number' and new_speed >= 0 then
        adjusted_speed = new_speed
    end

    return adjusted_speed
end

local smoothy = {
    new = new,
    new_interp = new_interp,
    set_speed = set_speed
}

local skull = render.load_font('nl/yamisame/skull.ttf', 24, 'ao')
local bomb_icon = render.load_image_from_file('nl/yamisame/bomb_icon.png')

local js = panorama.loadstring([[
    let _GetSpeakingPlayers = function() {
        let children = $.GetContextPanel().FindChildTraverse("VoicePanel").Children()
        let result = []
        children.forEach((panel) => {
            if(!panel.BHasClass("Hidden")) {
                try {
                    let avatar = panel.GetChild(1).GetChild(1)
                    result.push(avatar.steamid)
                } catch (err) {
                    // ignored
                }
            }
        })
        if(result.length > 0) {
            let lookup = {}
            for(let i=1; i <= 64; i++) {
                let xuid = GameStateAPI.GetPlayerXuidStringFromEntIndex(i)
                if(xuid && xuid != "0")
                    lookup[xuid] = i
            }
            for(let i=0; i < result.length; i++)
                result[i] = lookup[ result[i] ]
        }
        return result
    }
    return {
        get_speaking_players: _GetSpeakingPlayers
    }
]], "CSGOHud")()

local function get_speaking_players()
    return json.parse(tostring(js.get_speaking_players()))
end

local function get_weapons(player)
    local all_weapons = {}

    for i = 0, 16 do
        local weapon = player.m_hMyWeapons[i]
        if weapon ~= nil then
			table.insert(all_weapons, weapon)
        end
    end

    return all_weapons
end

local ctx = new_class()
    :struct 'events' {
        add =
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
                            if i.time < 0.48 or j < k then
                                h = (j < 1 and j or i.time) / 0.48
                                g = h * 255
                                if h < 0.2 then
                                    d = d - 15 * (1.0 - h / 0.2)
                                end
                            end
                            local xui = i.time < 0.48 and -1 or 1
                            i.draw = tostring(i.draw)
                            if i.draw == "" then
                                goto m
                            end
                            local n, o = render.screen_size().x, render.screen_size().y
                            local xyeta = 55


                            local tx_size = render.measure_text(i.render_font, '', i.draw).x
                            local tx_y = render.measure_text(i.render_font, '', i.draw).y + 2

                            g = g/255

                            render.gradient(
                                vector(0, o - 130 - d),
                                vector(tx_size/2, o - 130 + 30 - d),
                                color(0, 0, 0, 255*g),
                                color(0, 0, 0, 160*g),
                                color(0, 0, 0, 255*g),
                                color(0, 0, 0, 160*g)
                            )
                            render.gradient(
                                vector(tx_size/2, o - 130 - d),
                                vector(tx_size*1.4, o - 130 + 30 - d),
                                color(0, 0, 0, 160*g),
                                color(0, 0, 0, 0),
                                color(0, 0, 0, 160*g),
                                color(0, 0, 0, 0)
                            )
                            render.text(
                                i.render_font,
                                vector(0, o - 130 + 7 - d),
                                i.clr:alpha_modulate(i.clr.a*g),
                                "d",
                                i.draw
                            )
                            d = d + 30
                            ::m::
                        end
                    end
                    self.callback_registered = true
                end
            )
        end
        function b:paint(p, q, _clr, font)
            local r = tonumber(p) + 1
            for f = 10, 2, -1 do
                self.data[f] = self.data[f - 1]
            end
                self.data[1] = {time = r, def_time = r, draw = q, clr = _clr, render_font = font}
                self:register_callback()
            end
            return b
        end)(),

        killed =
        (function()
            local b = {callback_registered = false, maximum_count, 8, data = {  }}
            function b:register_callback()
            if self.callback_registered then
                return
            end

            events.round_start:set(function()
                self.data = {}
            end)

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
                                g = h * 255
                            end
                            local xui = i.time < 0.48 and -1 or 1
                            i.draw = tostring(i.draw)
                            if i.draw == "" then
                                goto m
                            end
                            local x, y = render.screen_size().x - 7, render.screen_size().y
                            g = g/255

                            local font = i.font

                            local userid_m = render.measure_text(font, '', i.userid) + 8
                            local attacker_m = render.measure_text(font, '', i.attacker) + 8

                            local icon = i.icon
                            if icon == nil then
                                return
                            end

                            local icon_width, icon_height = icon.width/1.4, icon.height/1.4

                            -- BACKGROUND
                            local userid_name do
                                local NAME = ''
                                local kek = i.userid
                                local num = math.floor(#kek*g*2.4)

                                for i = 1, num do
                                    local c = kek:sub(i,i)

                                    NAME = NAME .. c
                                end

                                userid_name = NAME
                            end

                            local attacker_name do
                                local NAME = ''
                                local kek = i.attacker
                                local num = math.floor(#kek*g*2.4)

                                for i = 1, num do
                                    local c = kek:sub(i,i)

                                    NAME = NAME .. c
                                end

                                attacker_name = NAME
                            end

                            local skull_m = render.measure_text(skull, '', '4') + 7
                            local add_x = i.is_headshot and skull_m.x or 0

                            local clr = i.clr; clr.a = 255*g

                            -- PLAYERS
                            --render.text(font, vector(x/2 - 40, y/10), i.clr, '', i.info.en) -- Terrorists

                            -- NAMES
                            render.text(font, vector(x - 2, 27 + d), clr, 'r', userid_name)
                            render.text(font, vector(x - 22 - add_x - userid_m.x - icon_width, 27 + d), clr:grayscale(.7), 'r', attacker_name)

                            if i.is_headshot then
                                render.text(skull, vector(x + 14 - add_x - userid_m.x, 24 + d), clr:grayscale(.35), 'r', '4')
                            end

                            if not icon then
                                return
                            end

                            -- WEAPON ICON
                            icon:draw(x - 9 - add_x - userid_m.x - icon_width, 25 + d, icon_width, icon_height, clr:grayscale(.5).r, clr:grayscale(.5).g, clr:grayscale(.5).b, clr:grayscale(.5).a)

                            d = d + 30
                            ::m::
                        end
                    end
                    self.callback_registered = true
                end
            )
        end
        function b:paint(p, userid, attacker, weapon, is_headshot, _clr, font, players_info)
            local r = tonumber(p) + 1
            for f = 50, 2, -1 do
                self.data[f] = self.data[f - 1]
            end
                self.data[1] = {time = r, def_time = r, clr = _clr, userid = userid, attacker = attacker, icon = weapon, is_headshot = is_headshot, font = font, info = players_info}
                self:register_callback()
            end
            return b
        end)()
    }

    :struct 'global' {
        initialize = function(self)
            --animate sidebar
            ui.sidebar('Advanced HUD')

            local color_array = smoothy.new({
                color = color()
            })

            local animate_transition = function(color1, color2, color3, delta)
                local new_color = color2:lerp(color1, 1-delta)

                return new_color
            end

            local general do
                general = {}

                local main_group = ui.create('Global', 'Features')
                local resource_group = ui.create('Global', 'Resource Manager')

                --main
                general.animate_transition = main_group:switch 'Animate Transition'
                general.preserve_killfeed = main_group:switch 'Preserve Kill Feed'
                general.render_scope_overlay = main_group:switch 'Render Scope Overlay'
                general.steal_setup = main_group:switch 'Steal Setup'

                --resource
                general.accent_color = resource_group:color_picker('[Global] Accent Color', color('F3ABBAFF'))
                general.alt_color = resource_group:color_picker('[Global] Alternative Accent Color', color(240, 222, 180, 255))
                general.t_color = resource_group:color_picker('[Chat] Terrorists Color', color('E05252FF'))
                general.ct_color = resource_group:color_picker('[Chat] Counter-Terrorists Color', color('546EDEFF'))
                general.active_weapon = resource_group:color_picker('[Weapons] Active Color')
                general.animation_speed = resource_group:slider('Animation Speed', 0, 200, 100, nil, function(val)
                    return val == 0 and 'Off' or val .. '%'
                end)

                -- toggle off original hud
                cvar.cl_drawhud:int(0)

                --steal setup
                events['level_init']:set(function()
                    cvar.cl_drawhud:int(0)

                    if not general.steal_setup:get() then
                        return end
                    utils.console_exec('sm_10man')
                end)

                events['player_say']:set(function(e)
                    if not general.steal_setup:get() then
                        return end

                    local victim = entity.get(e.userid, true)
                    local msg = e.text

                    if msg:find('forceend') or msg:find('.fe') or msg:find('!fe') then
                        utils.console_exec('sm_10man')
                    end
                end)
            end

            local EASING do
                local new_interp_fn = smoothy.new({
                    global_alpha = 0,
                    dpi_modifier = 100
                })

                EASING = {
                    ['on'] = function(c) new_interp_fn((201-general.animation_speed:get())*.1, {
                            global_alpha = c
                        })
                    end,

                    ['get'] = function() return new_interp_fn.value.global_alpha end
                }
            end

            local RENDER do
                local skull = render.load_font('nl/yamisame/skull.ttf', 35, 'ao')
                local font = render.load_font('nl/yamisame/sans700.ttf', 42, 'ao')
                local tooltip_font = render.load_font('nl/yamisame/sans500.ttf', 14, 'abo')
                local chat_font = render.load_font('nl/yamisame/sans-chat.ttf', vector(15, 14), 'ad')
                local light_font = render.load_font('nl/yamisame/sans500.ttf', 16, 'a')
                local random_font = render.load_font('Verdana', 22, 'ad')

                local player_data = smoothy.new({
                    health = 0,
                    armor = 0,
                    money_alpha = 0,
                    money = 0
                })

                local weapon_resource = smoothy.new({
                    clip = 0,
                    max_clip = 0,
                    reloading = 0,
                    is_held = 0
                })

                local start_time = 0
                local end_time = 0
                local frame_time = 0
                local fps = 0
                local duration = (general.animation_speed:get() / 100) * 1.125

                local latency = '0ms'

                local get_latency = function()
                    local netchannel = utils.net_channel()

                    if netchannel == nil then
                        return ''
                    end

                    local latency = math.floor(netchannel.latency[1] * 1000)
                    return latency ~= 0 and latency .. 'ms' or 'local'
                end

                local function start_anim()
                    start_time = globals.curtime
                    end_time = start_time + duration
                end

                events['player_say']:set(function(e)
                    local msg = e.text
                    local user_id = entity.get(e.userid, true)

                    local is_terrorist = user_id.m_iTeamNum % 2 == 0

                    local render_y = 152
                    local render_color = is_terrorist and general.t_color:get() or general.ct_color:get()

                    self.events.add:paint(10, ('\a%s%s  \aDEFAULT%s'):format(render_color:to_hex(), user_id:get_name(), msg), color(), chat_font)
                end)

                events['player_hurt']:set(function(e)
                    local lp = entity.get_local_player()
                    local user_id = entity.get(e.userid, true)

                    if user_id == lp then
                        start_anim()
                    end
                end)

                local rainbowCounter = 0
                local colorCounter = 0

                local function get_c4_time(ent)
                    local c4_time = ent["m_flC4Blow"] - globals.curtime
                    return c4_time ~= nil and c4_time > 0 and c4_time or 0
                end

                local function SecondsToClock(seconds)
                    local seconds = tonumber(seconds)

                    if seconds <= 0 then
                      return "00:00:00";
                    else
                    hours = string.format("%02.f", math.floor(seconds/3600))
                      mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
                      secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
                      return mins..":"..secs
                    end
                end

                events['player_death']:set(function(e)
                    -- userid, attacker, weapon, is_headshot, _clr
                    local me = entity.get_local_player()
                    local userid = entity.get(e.userid, true)
                    local attacker = entity.get(e.attacker, true)
                    local weapon = attacker:get_player_weapon()
                    local is_headshot = e.headshot

                    local total_enemies = 0
                    local total_team8s = 0

                    local players = entity.get_players(false, true, function(player_ptr)
                        if player_ptr == entity.get_local_player() or not player_ptr:is_alive() then
                            goto continue end

                        if player_ptr:is_enemy() then
                            total_enemies = total_enemies + 1
                        else
                            total_team8s = total_team8s + 1
                        end

                        ::continue::
                    end)

                    local render_time = 7
                    local _clr = attacker ~= me and general.alt_color:get() or general.accent_color:get()

                    if attacker == me then
                        render_time = general.preserve_killfeed:get() and 1000 or 7
                    end

                    self.events.killed:paint(render_time, userid:get_name(), attacker:get_name(), images.get_weapon_icon(e.weapon), is_headshot, _clr, light_font, {
                        en = total_enemies,
                        tm = total_team8s
                    })
                end)

                local money_alpha = 0
                local fade_time = 0

                local prev_frac = 0
                local weap_reloading = smoothy.new({
                    a = 0
                })

                events['round_start']:set(function()
                    money_alpha = 1
                    fade_time = 1
                end)
                events['round_freeze_end']:set(function()
                    money_alpha = 0
                    fade_time = 0
                end)

                local players_info = smoothy.new({
                    fade_time = 0
                })

                local spec_font = render.load_font('Calibri Bold', 22, 'a')

                events['render']:set(function()

                    local lp = entity.get_local_player()
                    local is_spectating = false

                    if lp == nil then return end
                    if lp.m_hObserverTarget and (lp.m_iObserverMode == 4 or lp.m_iObserverMode == 5) then
                        lp = lp.m_hObserverTarget
                        is_spectating = true
                    end

                    player_data(0.1, {
                        money_alpha = money_alpha
                    })

                    if not lp then
                        return
                    end

                    EASING.on(lp:is_alive() and 1 or 0)
                    local x,y = render.screen_size().x, render.screen_size().y

                    player_data(0.03, {
                        money = lp.m_iAccount
                    })

                    -- HEALTH/ARMOR BAR RENDERING
                    do
                        local curtime = globals.curtime

                        local diff = curtime - start_time
                        local percentage = math.clamp(diff / duration, 0, 1)

                        local health_color = general.accent_color:get():lerp(color(general.alt_color:get().r, general.alt_color:get().g, general.alt_color:get().b, general.accent_color:get().a*EASING:get()), 1-percentage):alpha_modulate(general.accent_color:get().a*EASING:get())
                        local armor_color = general.accent_color:get():alpha_modulate(general.accent_color:get().a*EASING:get())

                        player_data((201-general.animation_speed:get())*.1*2, {
                            health = lp.m_iHealth,
                            armor = lp.m_ArmorValue
                        });

                        local health = math.clamp(math.ceil(player_data.value.health), 0, 100)
                        local font_m = render.measure_text(font, '', health)

                        -- GO BABY BACKGROUND
                        render.gradient(
                            vector(30, y), vector(145 + 82, y - 52),
                            color(0, 0, 0, 0), color(0, 0, 0, 185*EASING:get()), color(0, 0, 0, 0), color(0, 0, 0, 185*EASING:get())
                        )

                        render.gradient(
                            vector(145 + 82, y), vector(345 + 82, y - 52),
                            color(0, 0, 0, 185*EASING:get()), color(0, 0, 0, 0), color(0, 0, 0, 185*EASING:get()), color(0, 0, 0, 0)
                        )

                        -- HEALTH Relaited
                        render.text(tooltip_font, vector(35, y - font_m.y + render.measure_text(tooltip_font, '', 'HP').y + 5), health_color, nil, 'HP')
                        render.text(font, vector(60, y - font_m.y), health_color, nil, health)
                        render.shadow(vector(130, y - font_m.y/2), vector(130 + 82*(health/100), y - font_m.y/2 + 5), health_color, 15, nil, 2)
                        render.rect(vector(130, y - font_m.y/2), vector(130 + 82*(health/100), y - font_m.y/2 + 5), color(25, 25, 25, 200*EASING:get()))
                        render.rect(vector(130, y - font_m.y/2), vector(130 + 82*(health/100), y - font_m.y/2 + 5), health_color)

                        -- ARMOR Relaited
                        local armor = math.clamp(math.ceil(player_data.value.armor), 1, 100)
                        local font_m = render.measure_text(font, '', armor)

                        if armor > 1 then
                            render.text(tooltip_font, vector(240, y - font_m.y + render.measure_text(tooltip_font, '', 'AP').y + 5), armor_color, nil, 'AP')
                            render.text(font, vector(265, y - font_m.y), armor_color, nil, armor)
                            render.shadow(vector(335, y - font_m.y/2), vector(335 + 82*(armor/100), y - font_m.y/2 + 5), armor_color, 15, nil, 2)
                            render.rect(vector(335, y - font_m.y/2), vector(335 + 82*(armor/100), y - font_m.y/2 + 5), color(25, 25, 25, 200))
                            render.rect(vector(335, y - font_m.y/2), vector(335 + 82*(armor/100), y - font_m.y/2 + 5), armor_color)
                        end
                    end

                    do
                        -- render icon warnings
                        local frame_time = 0.9 * frame_time + (1.0 - 0.9) * globals.absoluteframetime
                        fps = math.floor(1.0 / frame_time* 0.1)

                        local render_count = 0

                        if fps < 100 then
                            render_count = render_count + 1

                            local icon = ui.get_icon 'gauge-high'
                            render.text(random_font, vector(4, 4), color('F26464FF'):lerp(color('E72323FF'), globals.tickcount % 40 / 40), '', icon)

                            latency = get_latency()
                        end

                        latency = tonumber(latency) or 0

                        if latency > 40 then
                            local icon = ui.get_icon 'cloud-exclamation'
                            render.text(random_font, vector(4, 4 + (24*render_count)), color('F26464FF'):lerp(color('E72323FF'), globals.tickcount % 70 / 69), '', icon)

                            render_count = render_count + 1
                        end
                    end

                    -- FEATURING AMMO SHIT
                    do
                        local size = x/5.5

                        -- GO BABY BACKGROUND
                        render.gradient(
                            vector(x-size, y), vector(x-size/2, y - 52),
                            color(0, 0, 0, 0), color(0, 0, 0, 185), color(0, 0, 0, 0), color(0, 0, 0, 185)
                        )

                        render.gradient(
                            vector(x-size/2, y), vector(x, y - 52),
                            color(0, 0, 0, 185), color(0, 0, 0, 0), color(0, 0, 0, 185), color(0, 0, 0, 0)
                        )

                        local render_x = size*.325
                        local lp = entity.get_local_player()

                        if lp == nil then return end
                        if lp.m_hObserverTarget and (lp.m_iObserverMode == 4 or lp.m_iObserverMode == 5) then
                            lp = lp.m_hObserverTarget
                        end

                        local active_weapon = lp:get_player_weapon();if not active_weapon then return end
                        local weapon_info = active_weapon:get_weapon_info()
                        local active_weapon_icon = active_weapon:get_weapon_icon()

                        weapon_resource(.625, {
                            reloading = active_weapon:get_weapon_reload() <= 0 and 0 or 1
                        })
                        weapon_resource(.075, {
                            clip = active_weapon:get_weapon_reload() > 0.95 and 0 or (active_weapon:get_weapon_reload() <= 0 and 0 or 1)
                        })

                        local reloading = weapon_resource.value.reloading
                        local clip_alpha = weapon_resource.value.clip
                        local weap_clip = active_weapon.m_iClip1 >= 0 and active_weapon.m_iClip1 or ''
                        local max_weap_clip = active_weapon.m_iClip1 >= 0 and active_weapon.m_iPrimaryReserveAmmoCount or ''

                        local font_a = render.measure_text(tooltip_font, '', max_weap_clip) + 8
                        local render_color = general.accent_color:get()

                        if active_weapon:get_weapon_reload() > 0 then
                            render_color = general.accent_color:get():lerp(general.alt_color:get(), 1-reloading)
                        end;render_color.a = render_color.a*EASING:get()

                        -- CLIP TEXT
                        render.text(font, vector(x - render_x - 22 - font_a.x, y - 37), render_color:alpha_modulate(render_color.a*(1-reloading)), 'r', weap_clip)
                        render.text(tooltip_font, vector(x - render_x - 22, y - 20), render_color:alpha_modulate(render_color.a*(1-reloading)), 'r', max_weap_clip)

                        local switch_fraction = math.clamp(active_weapon.m_flNextPrimaryAttack-globals.curtime < 0 and 0 or active_weapon.m_flNextPrimaryAttack-globals.curtime, 0, 1)

                        -- RELOADING BAR
                        render.rect(vector(x - render_x - 130 + render.measure_text(tooltip_font, '', max_weap_clip).x/2, y - 20), vector(x - render_x - 28 + render.measure_text(tooltip_font, '', max_weap_clip).x/2, y - 15),
                        color(25, 25, 25, 200):alpha_modulate(200*clip_alpha), 2)
                        render.rect(vector(x - render_x - 130 + render.measure_text(tooltip_font, '', max_weap_clip).x/2, y - 20), vector(x - render_x - (102*(1-reloading)) - 28 + render.measure_text(tooltip_font, '', max_weap_clip).x/2, y - 15),
                        render_color:alpha_modulate(render_color.a*clip_alpha), 2)
                        render.shadow(vector(x - render_x - 130 + render.measure_text(tooltip_font, '', max_weap_clip).x/2, y - 20), vector(x - render_x - (102*(1-reloading)) - 28 + render.measure_text(tooltip_font, '', max_weap_clip).x/2, y - 15),
                        render_color:alpha_modulate(render_color.a*clip_alpha), 20, nil, 2)

                        -- ACTIVE WEAPON ICON
                        local function properly_reloading()
                            frac = active_weapon:get_weapon_reload() <= 0 and 0 or active_weapon:get_weapon_reload()

                            if prev_frac > frac and frac ~= 0 then
                                frac = prev_frac
                            end

                            prev_frac = frac

                            weap_reloading(.25, {
                                a = frac + 0.085
                            })

                            return frac == 0 and 0 or 1-(frac > .99 and 0 or weap_reloading.value.a)
                        end

                        local weap_reloading = properly_reloading()

                        render.texture(active_weapon_icon, vector(x - render_x, y - active_weapon_icon.height - 2), vector(active_weapon_icon.width, active_weapon_icon.height), render_color)

                        render.push_clip_rect(vector(x - render_x + (active_weapon_icon.width*(1-weap_reloading)), y - active_weapon_icon.height - 2), vector(x - render_x + active_weapon_icon.width*(1), y + active_weapon_icon.height))
                        render.texture(active_weapon_icon, vector(x - render_x, y - active_weapon_icon.height - 2), vector(active_weapon_icon.width, active_weapon_icon.height), color(15, 15, 15, render_color.a))
                        render.pop_clip_rect()

                        -- ALL WEAPONS
                        local all_carried_weapons = lp:get_player_weapon(true)
                        local killstreak = lp.m_iNumRoundKills

                        if killstreak > 0 then
                            render.text(tooltip_font, vector(x - render_x*2 - 40, y - 25), render_color, 'r', killstreak)
                            render.text(skull, vector(x - render_x*2 - 15, y - 35), render_color, 'r', 4)
                        end

                        table.sort(all_carried_weapons, function(a, b)

                            local a = a:get_weapon_info().weapon_type
                            local b = b:get_weapon_info().weapon_type

                            return a < b
                        end)

                        for i, ptr in pairs(all_carried_weapons) do
                            local ptr = all_carried_weapons[i]
                            local name = ptr:get_name():upper()
                            local active_name = name == active_weapon:get_name():upper()

                            local swap_delta = active_name and math.clamp((active_weapon.m_flTimeWeaponIdle-globals.curtime)/1.25, 0, 1) or 0
                            local alt_color = general.alt_color:get()
                            local blick_color = general.active_weapon:get()

                            local active_color = active_name and alt_color or color(0, 0, 0, 225)

                            render.gradient(
                                vector(x - render_x - 10, (y - 50) - 60*i),
                                vector(x - 10, (y - 0) - 60*i),

                                animate_transition(active_color, blick_color, general.active_weapon, swap_delta),
                                animate_transition(active_color, blick_color, general.active_weapon, swap_delta):alpha_modulate(0),
                                animate_transition(active_color, blick_color, general.active_weapon, swap_delta),
                                animate_transition(active_color, blick_color, general.active_weapon, swap_delta):alpha_modulate(0)
                            )

                            render.rect(
                                vector(x - render_x - 10, (y - 50) - 60*i),
                                vector(x - 10, (y - 48) - 60*i),

                                active_color:lerp(blick_color, swap_delta):alpha_modulate(15)
                            )

                            render.rect(
                                vector(x - render_x, (y - 2) - 60*i),
                                vector(x, (y) - 60*i),

                                active_color:lerp(blick_color, swap_delta):alpha_modulate(15)
                            )

                            local icon = ptr:get_weapon_icon()

                            render.texture(icon, vector(x - render_x/1.2 - 20, (y - 37) - 60*i), vector(icon.width, icon.height), render_color)
                            render.text(tooltip_font, vector(x - render_x/1.2 - 28 - 10, (y - 32) - 60*i), render_color:grayscale(.4), 'r', active_name and name or '')

                            local types_tbl = {
                                [5] = 1,
                                [0] = 3,
                                [1] = 2,
                                [9] = 4,
                                [7] = 5
                            }


                            local type = types_tbl[ptr:get_weapon_info().weapon_type] or '*'
                            local type_m = render.measure_text(tooltip_font, '', type)

                            render.rect(
                                vector(x - 18 - type_m.x, (y - 32) - 60*i), vector(x - 20 + type_m.x, (y - 15) - 60*i),
                                color(180, 180, 180, 255)
                            )
                            render.text(light_font, vector(x - 23, (y - 32) - 60*i), color(40, 40, 40 , 255), '', type)
                        end
                    end

                    do
                        -- render scope overlay
                        local lp = entity.get_local_player()
                        if lp and general.render_scope_overlay:get() and lp.m_bIsScoped then

                            render.line(vector(x/2, 0), vector(x/2, y), color(0, 0, 0, 255))
                            render.line(vector(0, y/2), vector(x, y/2), color(0, 0, 0, 255))
                        end
                    end

                    -- SPECTAING SHIT
                    if is_spectating then

                        local steam_avatar do
                            steam_avatar = lp:get_steam_avatar()

                            local w = 100
                            render.texture(steam_avatar, vector(x/2.5 - w, y/1.25 - 20), vector(w, w))
                        end

                        local name do
                            name = lp:get_name()

                            local player_info = lp:get_player_info()

                            if player_info.is_fake_player then
                                name = 'BOT ' .. name
                            end
                        end

                        render.gradient(vector(x/2.5, y/1.25), vector(x/1.6, y/1.25 + 80), color(0, 255), color(0, 0), color(0, 255), color(0, 0))
                        render.rect(vector(x/2.5, y/1.25 + 40), vector(x/1.6, y/1.25 + 42), color(13, 230, 217) )

                        render.text(spec_font, vector(x/2.44, y/1.25 + 10), color(), '', name)

                        local additional_info do
                            local rs = lp:get_resource()

                            additional_info = {
                                kills = rs.m_iKills,
                                assists = rs.m_iAssists,
                                deaths = rs.m_iDeaths,
                                hs = rs.m_iMatchStats_HeadShotKills_Total
                            }

                            -- kills
                            render.text(4, vector(x/2.44, y/1.25 + 44), color(), '', 'K')
                            render.text(spec_font, vector(x/2.44 - 2, y/1.25 + 58), color(), '', additional_info.kills)

                            --assists
                            render.text(4, vector(x/2.34, y/1.25 + 44), color(), '', 'A')
                            render.text(spec_font, vector(x/2.34 - 2, y/1.25 + 58), color(), '', additional_info.assists)

                            --deaths
                            render.text(4, vector(x/2.24, y/1.25 + 44), color(), '', 'D')
                            render.text(spec_font, vector(x/2.24 - 2, y/1.25 + 58), color(), '', additional_info.deaths)

                            -- k/d
                            render.text(4, vector(x/2.1, y/1.25 + 44), color(), '', 'K/D')
                            render.text(spec_font, vector(x/2.08 - 2, y/1.25 + 68), color(), 'c', math.clamp(additional_info.kills / additional_info.deaths, 0, additional_info.kills))

                            -- AVG
                            render.text(4, vector(x/2, y/1.25 + 44), color(), '', 'TOTAL DMG')
                            render.text(spec_font, vector(x/1.95, y/1.25 + 68), color(), 'c', m_iMatchStats_Damage_Total or 0)

                            -- HS RATE
                            render.text(4, vector(x/1.85, y/1.25 + 44), color(), '', 'HS')
                            render.text(spec_font, vector(x/1.84, y/1.25 + 68), color(), 'c', string.format('%s%%', math.abs(math.ceil(math.clamp(additional_info.hs/additional_info.kills*100, 0, 100)))))
                        end
                    end

                    -- ROUND Relaited SHIT
                    do
                        local game_rule = entity.get_game_rules()

                        local add_y = 0
                        local x = x - 44
                        local alt_color = general.alt_color:get()

                        local total_time = game_rule.m_iRoundTime
                        local time_left = game_rule.m_fRoundStartTime

                        local c4 = entity.get_entities("CPlantedC4")[1]
                        local ass = 0

                        if c4 ~= nil then
                            ass = math.ceil(get_c4_time(c4) * 10 ^ 1 - 0.5)/10 ^ 1 - 0.5
                            add_y = 20
                        else
                            ass = (total_time + time_left) - globals.curtime
                        end

                        local round_time = SecondsToClock(tonumber(string.format("%.2f", ass)))

                        render.gradient(vector(x/2 - 22, 0), vector(x/2 + render.measure_text(light_font, '', round_time).x/2, 22 + add_y),
                            color(0, 0, 0, 0),
                            color(0, 0, 0, 255),
                            color(0, 0, 0, 0),
                            color(0, 0, 0, 255)
                        )
                        render.gradient(vector(x/2 + render.measure_text(light_font, '', round_time).x/2, 0), vector(x/2 + render.measure_text(light_font, '', round_time).x + 22, 22 + add_y),
                            color(0, 0, 0, 255),
                            color(0, 0, 0, 0),
                            color(0, 0, 0, 255),
                            color(0, 0, 0, 0)
                        )

                        render.text(light_font, vector(x/2 + 18, 7), alt_color, 'c', round_time)

                        if add_y > 0 then
                            render.text(light_font, vector(x/2 + 18, 10 + add_y), alt_color, 'c', 'BOMB')
                        end

                        local cash = math.floor(player_data.value.money)
                        local money_alpha = player_data.value.money_alpha

                        local mx, my = render.measure_text(random_font, '', cash .. '$').x, render.measure_text(random_font, '', cash .. '$').y

                        render.gradient(
                            vector(0, y/5 + my), vector(40 + mx, y/5 - my/2),
                            color(0, 0, 0, 200*money_alpha),
                            color(0, 0, 0, 0*money_alpha),
                            color(0, 0, 0, 200*money_alpha),
                            color(0, 0, 0, 0*money_alpha)
                        )
                        render.text(random_font, vector(15, y/5 - 7), general.accent_color:get():alpha_modulate(255*money_alpha), '', cash .. '$')

                        local fade_time = players_info(.75, {
                            fade_time = fade_time
                        }).fade_time

                        render.rect(vector(x/2 + 82, 66), vector(x/2 + 119, 109), color(103, 121, 166, 200*fade_time))
                        render.rect(vector(x/2 - 92, 66), vector(x/2 - 56, 109), color(166, 100, 100, 200*fade_time))

                        local teams = panorama.GameStateAPI.GetScoreDataJSO()

                        local t_side  = teams.teamdata.TERRORIST
                        local ct_side = teams.teamdata.CT

                        render.text(random_font, vector(x/2 - 74, 85), color(200, 200, 200):alpha_modulate(255*fade_time), 'c', t_side.score)
                        render.text(random_font, vector(x/2 + 101.5, 85), color(200, 200, 200):alpha_modulate(255*fade_time), 'c', ct_side.score)
                    end
                end)
            end
        end
    }

ctx.global:initialize()

local function vtable_entry(instance, index, type)
    return ffi.cast(type, (ffi.cast("void***", instance)[0])[index])
end

local function vtable_thunk(index, typestring)
    local t = ffi.typeof(typestring)
    return function(instance, ...)
        assert(instance ~= nil)
        if instance then
            return vtable_entry(instance, index, t)(instance, ...)
        end
    end
end

local function vtable_bind(module, interface, index, typestring)
    local instance = utils.create_interface(module, interface) or error("invalid interface")
    local fnptr = vtable_entry(instance, index, ffi.typeof(typestring)) or error("invalid vtable")
    return function(...)
        return fnptr(instance, ...)
    end
end

local native_Key_LookupBinding = vtable_bind("engine.dll", "VEngineClient014", 21, "const char* (__thiscall*)(void*, const char*)")
local function get_key_binding(cmd)
    return ffi.string(native_Key_LookupBinding(cmd))
end

local chat_input_global = 'y'
local chat_input_team = 'u'

utils.console_exec(string.format('unbind %s', chat_input_global))
utils.console_exec(string.format('unbind %s', chat_input_team))

events['shutdown']:set(function()
    -- toggle back original hud
    cvar.cl_drawhud:int(1)

    utils.console_exec(string.format('bind %s messagemode', chat_input_global))
    utils.console_exec(string.format('bind %s messagemode2', chat_input_team))
end)
