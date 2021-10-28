local oTypes = {}; oTypes.__index = {};
local oRender = {}; oRender.__index = {};
local oMisc = {}; oMisc.__index = {};
local oWindows = {}; oWindows.__index = {};
local oIcons = {}; oIcons.__index = {};

--[[
    Types (For Unity Across API's)
--]]

function oVector(x, y, z)
    if (type(x) ~= "number") then x = 0; end
    if (type(y) ~= "number") then y = 0; end
    if (type(z) ~= "number") then z = 0; end

    return setmetatable({x = x, y = y, z = z}, oTypes);
end

function oVector2(x, y)
    if (type(x) ~= "number") then x = 0; end
    if (type(y) ~= "number") then y = 0; end

    return setmetatable({x = x, y = y}, oTypes);
end

function oColor(r, g, b, a)
    if (type(r) ~= "number") then r = 0; end
    if (type(g) ~= "number") then g = 0; end
    if (type(b) ~= "number") then b = 0; end
    if (type(a) ~= "number") then a = 255; end

    return setmetatable({r = r, g = g, b = b, a = a}, oTypes);
end

--[[
    Icons
--]]

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
function base64Decoder(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
    end))
end

local icons = {};
function oIcons.base64Compress(str)
    local newString = ""
    local currentChar = ""
    local currentAmount = 1

    for i = 1, #str do
        local curChar = str:sub(i, i)

        if (curChar ~= currentChar) then
            if (currentAmount <= 4) then
                newString = newString .. currentChar
            else
                newString = newString .. currentChar .. "^" .. currentAmount .. " "
            end
               
            currentChar = curChar
            currentAmount = 1
        else
            if (currentAmount == 1) then
                local stillTrue = true
                for f = 0, 3 do
                    if (#str >= i + f) then
                        local newChar = str:sub(i + f, i + f)
                        if (newChar ~= currentChar) then stillTrue = false end
                    else
                        stillTrue = false
                    end
                end

                if (stillTrue) then currentAmount = currentAmount + 1 else
                    newString = newString .. currentChar
                end
            else
                currentAmount = currentAmount + 1
            end
        end
    end

    if (currentAmount <= 4) then
        newString = newString .. currentChar
    else
        newString = newString .. currentChar .. "^" .. currentAmount .. " "
    end

    return newString
end

function oIcons.base64Decompress(str)
    local newString = ""
    local currentChar = ""
    local skipNext = 0

    for i = 1, #str do
        if (skipNext == 0) then
            local curChar = str:sub(i, i)
            local nextChar = str:sub(i + 1, i + 1)

            if (curChar == "^") then
                local charNumber = ""

                for f = 1, 1000 do
                        local curChar = str:sub(i + f,i + f)

                        if (curChar ~= " ") then
                            charNumber = charNumber .. curChar
                        else
                            goto breakLoop
                        end
                end

                ::breakLoop::

                skipNext = #charNumber + 1
                for f = 1, tonumber(charNumber) do
                    newString = newString .. currentChar
                end
            else
                if (nextChar ~= "^") then
                    newString = newString .. curChar
                end

                currentChar = curChar
            end
        else
            skipNext = skipNext - 1
        end
    end

    return newString
end

function oIcons.addIcon(size, compressedB64)
    table.insert(icons, Render.LoadImage(base64Decoder(oIcons.base64Decompress(compressedB64)), size));
    return #icons;
end

local playerIcon = oIcons.addIcon(Vector2.new(64, 64), "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAMAAACdt4HsAAAAolBMVEUAAAD/^211 8ELnaCAAAANXRSTlMApO769hry5b1PBtvKs6mZbjUJ6M+IVUZCItS3koFmOi8qJhMP3saOfGlhHgvWwq+WdUnFnmMoJgEAAAHFSURBVFjDrdbbdoIwEAXQBFBBVFAUrRe0Sr3f2/P/v9YnlkRgkqHdj7oyMq5DZkS1j7A7jOxoOnt8ihomHbxMPe7x0wyqb95TLCO8az4Z52MHJRLj830HZeyx4flGC+WstVmBHqq4Zg2gmlETM6LAVuilNggnfYEYlFBfIADlpi/QBaWjL9ABpaUv4IPS1BfYgvKlL3AD/haEHSg9fYEnKEd9gYEDwkboSeL8TBj4IF6GlVCw/0YpjAyGVSHYmN5pUXkKzW/2VQtF1kSYaxS78NeCYzBS42DfU8HUCKxX95L38+1swC2kO3TlaJx9MDBIUTK/NptBaWD60rbc3bFB/fQi6zxICy31sn7C6pl8yd1dsVo6sXIXY0Wix1D44Tn7ZrNXg+H0S3cKqxAdd36YjMPg6piEut0BQ7dYYAGWQyF6Flj89wIHMHmseaJfNpZgUxP5AFtMz2S9u1LAAttFeQlRwzm/WaOG/B2bQMFPwggk/cL1gxpG6nbLN1djwBfkCrioQf5nC3uQ9OuOhxryN+saNShzKgJJvzbze7DfZoPk51CVtsAybRfmMiuNsmxGe8YP4VesS+d40ZvaIDlDuffyj/8LmHDN9sGfb5YA^5 SUVORK5CYII=")
local fluidIcon = oIcons.addIcon(Vector2.new(180, 56), "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^5 ElFTkSuQmCC")

--[[
    Functions (API Translation Layer)
--]]

-- Callbacks
local callbacks = { "draw", "pre_prediction", "prediction", "createmove", "events", "destroy", "frame_stage", "console", "registered_shot", "ragebot_shot", "fire_bullet", "override_view" };

local fnTable = {};
function oMisc.registerCallback(callback, fn)
    table.insert(fnTable, { callback = callback, fn = fn });
end

for i = 1, #callbacks do
    Cheat.RegisterCallback(callbacks[i], function() -- Function Call
        for f = 1, #fnTable do
            if (fnTable[f].callback == callbacks[i]) then
                fnTable[f].fn();
            end
        end
    end);
end

-- Keys
local keyTable = {};
function oMisc.addKey(key)
    for i = 1, #keyTable do
        if (keyTable[i].key == key) then
            return keyTable[i];
        end
    end

    table.insert(keyTable, { key = key, down = false, pressed = false, released = false });
    return keyTable[#keyTable];
end

function oMisc.getKey(key)
    for i = 1, #keyTable do
        if (keyTable[i].key == key) then
            return keyTable[i];
        end
    end
end

function oMisc.keyDown(key)
    return Cheat.IsKeyDown(key.key); -- Function Call
end

function oMisc.keyPressed(key)
    return key.pressed;
end

function oMisc.keyReleased(key)
    return key.released;
end

function oMisc.mousePosition()
    local val = Cheat.GetMousePos();
    return oVector2(val.x, val.y);
end

function oMisc.pointInside(pos, size, point)
    if (point.x >= pos.x and point.x <= size.x ) then
        if (point.y >= pos.y and point.y <= size.y ) then
            return true;      
        end
    end

    return false;
end

function oMisc.getDPI()
    return Render.GetMenuSize().x / 800;
end

function oMisc.getMenuOpened()
    return Cheat.IsMenuVisible();
end

local mousePos;
oMisc.registerCallback("draw", function() -- Handle Added Keys
    if (#keyTable > 0) then
        mousePos = oMisc.mousePosition();

        for i = 1, #keyTable do
            if (oMisc.keyDown(keyTable[i])) then
                if (keyTable[i].pressed) then keyTable[i].pressed = false; else
                    if (not keyTable[i].down) then keyTable[i].pressed = true;end
                end

                keyTable[i].down = true;
            else
                if (keyTable[i].released) then
                    keyTable[i].released = false;
                end

                if (keyTable[i].pressed or keyTable[i].down) then
                    keyTable[i].released = true;
                    keyTable[i].pressed, keyTable[i].down = false, false;
                end
            end
        end
    end
end);

-- Rendering
function oRender.filledRectangle(pos, size, col, rounding)
    if (type(rounding) ~= "number") then rounding = 0; end
    col = Color.RGBA(col.r, col.g, col.b, col.a);
     -- Color Conversion

    pos, size = Vector2.new(pos.x, pos.y), Vector2.new(size.x, size.y);
    size = size + pos;
    -- Vector Conversion

    Render.BoxFilled(pos, size, col, rounding); -- Function Call
end

function oRender.rectangle(pos, size, col, rounding)
    if (type(rounding) ~= "number") then rounding = 0; end
    col = Color.RGBA(col.r, col.g, col.b, col.a);
     -- Color Conversion

    pos, size = Vector2.new(pos.x, pos.y), Vector2.new(size.x, size.y);
    size = size + pos;
    -- Vector Conversion

    Render.Box(pos, size, col, rounding); -- Function Call
end

--[[
    Windows
--]]

local mouseOne = oMisc.addKey(0x01);

local windowTable = {};
local oFlags = {
    noDraw = 1, noMove = 2,
    dpiCompliant = 3, tabBar = 4,
    outlined = 5, openedMenu = 6,
};

function window(name, pos, size, tabSize, tabOffset, ...)
    local winFlags = {...};

    local function contains(flag)
        for i = 1, #winFlags do
            if (winFlags[i] == flag) then
                return true;
            end
        end

        return false;
    end

    if (type(tabSize) ~= "number") then tabSize = 0; end

    table.insert(windowTable, { name = name, pos = pos, size = size, handle = { drag = false, dragPos = oVector2(0, 0) },
                                noDraw = contains(1), noMove = contains(2), dpiCompliant = contains(3), openedMenu = contains(6),
                                tabs = { tabs = {}, tabBar = contains(4), tabSize = tabSize, selected = 1, offset = tabOffset }, drawOutline = contains(5) });

    return windowTable[#windowTable];
end

function tab(win, name, icon)
    if (type(name) ~= "string") then name = "New Tab"; end
    table.insert(win.tabs.tabs, {name = name, hovered = false, icon = { hasIcon = (icon ~= nil), icon = icons[icon] }, controls = {} });
    return #win.tabs.tabs;
end

function checkbox(win, tab, name, description, default)
    if (win and tab and type(name) == "string") then
        if (not default) then default = false; end
        if (not description) then description = ""; end

        table.insert(win.tabs.tabs[tab].controls, { type = 1, name = name, description = description, value = default });
        return win.tabs.tabs[tab].controls[#win.tabs.tabs[tab].controls];
    end
end

function oMisc.Get(control)
    return control.value;
end

local function handleWindowMovement() -- Window Movement
    local pickup = false;

    for i = 1, #windowTable do
        if (not windowTable[i].noDraw) then
            if (mouseOne.down) then
                local dpi = oMisc.getDPI();
                if (not windowTable[i].dpiCompliant) then dpi = 1; end
                
                if (mouseOne.pressed) then
                    if (not pickup) then
                        local pos, size = Vector2.new(windowTable[i].pos.x, windowTable[i].pos.y), Vector2.new(windowTable[i].size.x, windowTable[i].size.y);
                        if (windowTable[i].tabs.tabSize > 0) then
                            size.x = windowTable[i].tabs.tabSize;
                        end
                        size = size * dpi;

                        if (oMisc.pointInside(pos, pos + size, mousePos)) then
                            pickup = true;
                            windowTable[i].handle = { drag = true, dragPos = oVector2(mousePos.x - pos.x, mousePos.y - pos.y) };
                        end
                    end
                else
                    if (windowTable[i].handle.drag) then
                        windowTable[i].pos = oVector2(mousePos.x - windowTable[i].handle.dragPos.x, mousePos.y - windowTable[i].handle.dragPos.y);
                    end
                end
            elseif (mouseOne.released) then
                windowTable[i].handle.drag = false;
            end
        end
    end
end

local function handleTabDrawing(w, dpi) -- Tab Control Drawing
    if (#w.tabs.tabs > 0) then
        local pos, size = w.pos, w.size;
        local wt = w.tabs.tabs[w.tabs.selected];
        local usedSize = oVector2(0, 0);

        if (#wt.controls > 0) then
            for i = 1, #wt.controls do
                local wtc = wt.controls[i];

                local function basicControl(control, w, dpi, highlighted, name, description)
                    local cPos, cSize = oVector2(pos.x + w.tabs.tabSize * dpi + 16 * dpi, pos.y + 12 * dpi), oVector2(size.x * dpi - 32 * dpi - w.tabs.tabSize * dpi, 45 * dpi);
                    oRender.filledRectangle(cPos, cSize, oColor(22, 19, 20), 4 * dpi)

                    local textSize, textSize2 = Render.CalcTextSize(name, math.floor(15 * dpi)), Render.CalcTextSize(description, math.floor(12 * dpi));
                    
                    if (w.drawOutline) then
                        local newHeight = cPos.y + (4 * dpi + textSize.y)

                        if (highlighted) then
                            oRender.rectangle(cPos, cSize, oColor(125, 125, 125), 4 * dpi)
                            Render.Text(name, Vector2.new(cPos.x + 8 * dpi, cPos.y + 4 * dpi), Color.new(1, 1, 1), math.floor(15 * dpi))
                            Render.Text(description, Vector2.new(cPos.x + 8 * dpi, newHeight + (cSize.y - (4 * dpi + textSize.y)) / 2 - textSize2.y / 2), Color.new(0.8, 0.8, 0.8), math.floor(12 * dpi))
                        else
                            oRender.rectangle(cPos, cSize, oColor(65, 65, 65), 4 * dpi)
                            Render.Text(name, Vector2.new(cPos.x + 8 * dpi, cPos.y + 4 * dpi), Color.RGBA(65, 65, 65), math.floor(15 * dpi))
                            Render.Text(description, Vector2.new(cPos.x + 8 * dpi, newHeight + (cSize.y - (4 * dpi + textSize.y)) / 2 - textSize2.y / 2), Color.RGBA(65, 65, 65), math.floor(12 * dpi))
                        end
                    end

                    if (oMisc.pointInside(cPos, Vector2.new(cPos.x + cSize.x, cPos.y + cSize.y), mousePos)) then
                        if (mouseOne.pressed) then
                            return { pos = cPos, size = cSize, pressed = true };
                        end
                    end

                    return { pos = cPos, size = cSize, pressed = false };
                end

                if (wtc.type == 1) then -- Checkbox
                    local control = basicControl(wtc, w, dpi, wtc.value, wtc.name, wtc.description);

                    if (control.pressed) then
                        wtc.value = not wtc.value;
                    end
                end
            end
        end
    end
end

local function handleWindowDrawing() -- Window Drawing
    for i = 1, #windowTable do
        local w = windowTable[i];

        if (not w.noDraw and not w.openedMenu or (w.openedMenu and oMisc.getMenuOpened())) then
            local pos, size, dpi = w.pos, w.size, 1;
            if (w.dpiCompliant) then
                dpi = oMisc.getDPI();
            end

            size = oVector2(size.x * dpi, size.y * dpi); 

            oRender.filledRectangle(pos, size, oColor(28, 25, 22), 8 * dpi)

            if (w.tabs.tabBar) then
                if (w.tabs.tabSize >= 8 * dpi) then
                    oRender.filledRectangle(pos, oVector2(w.tabs.tabSize * dpi, size.y), oColor(22, 19, 20), 8 * dpi)
                    oRender.filledRectangle(oVector2(pos.x + 8 * dpi, pos.y), oVector2(w.tabs.tabSize * dpi - 8 * dpi, size.y), oColor(22, 19, 20), 0)

                    Render.GradientBoxFilled(Vector2.new(pos.x + w.tabs.tabSize * dpi, pos.y), Vector2.new(pos.x + w.tabs.tabSize * dpi + 12, pos.y + size.y), Color.RGBA(11, 9, 10), Color.RGBA(28, 25, 22), Color.RGBA(11, 9, 10), Color.RGBA(28, 25, 22));
                end
            end

            if (w.drawOutline) then
                oRender.rectangle(pos, size, oColor(125, 125, 125), 8 * dpi)
            end

            if (w.tabs.tabBar) then
                local logoSize = oVector2(180, 56);
                logoSize.x = w.tabs.tabSize * dpi - 8 * dpi
                logoSize.y = (logoSize.x * (logoSize.y / logoSize.x)) * dpi

                Render.Image(icons[fluidIcon], Vector2.new(pos.x + 4 * dpi, pos.y + 4 * dpi), Vector2.new(logoSize.x, logoSize.y))
                oRender.filledRectangle(oVector2(pos.x + 4 * dpi, pos.y + 12 * dpi + logoSize.y), oVector2(logoSize.x, 2), oColor(125, 125, 125))

                local tabOffset = oVector2(0, 10 * dpi + logoSize.y);
                if (w.tabs.offset) then
                    tabOffset.y = tabOffset.y + w.tabs.offset;
                end

                if (#w.tabs.tabs > 0) then
                    for i = 1, #w.tabs.tabs do
                        local textSize = Render.CalcTextSize(w.tabs.tabs[i].name, 18 * dpi);
                        local xOffset = 0;

                        if (oMisc.pointInside(Vector2.new(pos.x + 8 * dpi, pos.y + 8 * dpi + tabOffset.y), Vector2.new(pos.x + w.tabs.tabSize * dpi - 8 * dpi, pos.y + 8 * dpi + tabOffset.y + textSize.y), mousePos)) then
                            w.tabs.tabs[i].hovered = true;

                            if (mouseOne.pressed) then
                                w.tabs.selected = i;
                            end
                        else
                            w.tabs.tabs[i].hovered = false;
                        end

                        if (w.tabs.tabs[i].icon.hasIcon) then
                            if (textSize.y + 12 * dpi > tabOffset.x) then
                                tabOffset.x = textSize.y + 12 * dpi;
                            end

                            Render.Image(w.tabs.tabs[i].icon.icon, Vector2.new(pos.x + 8 * dpi, pos.y + 8 * dpi + tabOffset.y), Vector2.new(textSize.y, textSize.y))
                        end

                        if (w.tabs.tabs[i].hovered or w.tabs.selected == i) then
                            local boxPos = oVector2(pos.x + 8 * dpi + tabOffset.x - 6 * dpi, pos.y + 8 * dpi + tabOffset.y)
                            oRender.filledRectangle(oVector2(pos.x + 2 * dpi + tabOffset.x, pos.y + 8 * dpi + tabOffset.y + textSize.y + 2), oVector2(textSize.x, 1 * dpi), oColor(255, 255, 255))
                            Render.Text(w.tabs.tabs[i].name, Vector2.new(pos.x + 2 * dpi + tabOffset.x, pos.y + 8 * dpi + tabOffset.y), Color.new(1, 1, 1), 18 * dpi)
                        else
                            Render.Text(w.tabs.tabs[i].name, Vector2.new(pos.x + 2 * dpi + tabOffset.x, pos.y + 8 * dpi + tabOffset.y), Color.new(0.8, 0.8, 0.8), 18 * dpi)
                        end

                        tabOffset.y = tabOffset.y + textSize.y + 8 * dpi;
                    end
                end
            end

            handleTabDrawing(w, dpi);
        end
    end
end

local newWindow = window("peepee", oVector2(10, 10), oVector2(800, 450), 800 / 4, 0, oFlags.dpiCompliant, oFlags.tabBar, oFlags.outlined, oFlags.openedMenu);
local tab1 = tab(newWindow, "Test", playerIcon);
local tab2 = tab(newWindow, "Peepee");

local checkbox1 = checkbox(newWindow, tab1, "Peepee", "Test Checkbox", true);

oMisc.registerCallback("draw", function()
    handleWindowMovement();
    handleWindowDrawing();
end);
