-- NOVA custom music for Techmino 0.17.21  (single file; the game files are NOT modified)
-- Put your tracks (ogg, mp3, wav, flac) into the folder  music  inside the Techmino save folder.
--   Music Room:   two buttons, "Custom Music" and "Vanilla Music", choose which tracks are listed.
--   Custom Game:  one button (left of the Music selector) switches between the same two modes.
-- In "Custom Music" mode the game plays your tracks wherever it would play its own music.
-- Start: with CCloader.lua in the save folder it loads by itself; manually:  su 7126  then
--   #return love.filesystem.load('custom_music.lua')()
if CUSTOMMUSIC_LOADED then return "custom music already loaded" end
if not (love and love.filesystem and BGM and SETTING and SCN and SCN.scenes and WIDGET and COLOR) then
    return "custom music: unsupported game version"
end
local musicRoom=SCN.scenes.music
local customGame=SCN.scenes.customGame
if not (musicRoom and musicRoom.widgetList) then return "custom music: Music Room scene not found" end

local fs=love.filesystem
local DIR='music'
local STATE='conf/nova_music'
local EXT={ogg=true,mp3=true,wav=true,flac=true}
local mode='vanilla'
local vanilla,custom,customPath={}, {}, {}

local function say(t) pcall(function() MES.new('info',t) end) end

-- vanilla tracks = what the game registered before us (the list table is shared with the scenes)
local shared=BGM.getList()
for i,n in ipairs(shared) do vanilla[i]=n end
local isVanilla={}
for _,n in ipairs(vanilla) do isVanilla[n]=true end

local function scan()
    pcall(fs.createDirectory,DIR)               -- the folder is created automatically
    custom={}
    for _,file in ipairs(fs.getDirectoryItems(DIR)) do
        local ext=file:match('%.(%w+)$')
        if ext and EXT[ext:lower()] then
            local info=fs.getInfo(DIR..'/'..file)
            if info and info.type~='directory' then
                local name=file:sub(1,-#ext-2)
                if isVanilla[name] then name=name.." (custom)" end
                if not customPath[name] then
                    customPath[name]=DIR..'/'..file
                    pcall(BGM.init,name,customPath[name])        -- registers the track in the game's sound library
                end
                custom[#custom+1]=name
            end
        end
    end
    table.sort(custom,function(a,b) return a:lower()<b:lower() end)
end

local function fillList(names)
    for i=#shared,1,-1 do shared[i]=nil end
    for i,n in ipairs(names) do shared[i]=n end
end

----------------------------------------------------------------- user interface
local buttons={}
local function paint()
    for _,B in ipairs(buttons) do
        local on=(B.mode==mode) or (B.mode=='all' and mode=='custom')
        B.W.color=on and COLOR.G or COLOR.Z
        B.W.fText=B.label()
        B.W:setObject(B.W.fText)
    end
end

local function inList(L,v) for _,x in ipairs(L) do if x==v then return true end end end

local function setMode(m,quiet)
    scan()
    if m=='custom' and #custom==0 then
        say("Put music files into: "..fs.getSaveDirectory().."/"..DIR)
        m='vanilla'
    end
    mode=m
    fillList(m=='custom' and custom or vanilla)
    if not quiet then fs.write(STATE,"mode="..mode.."\n") end
    -- the Custom Game selector must point at a track of the active list
    local env=CUSTOMGAME_LOCAL and CUSTOMGAME_LOCAL.customenv
    if env and not inList(shared,env.bgm) then env.bgm=shared[1] end
    if not quiet then
        pcall(BGM.stop)
        if SCN.cur=='music' and musicRoom.enter then pcall(musicRoom.enter) end
        if SCN.cur=='customGame' and env and env.bgm then pcall(BGM.play,env.bgm) end
        say(m=='custom' and ("Custom Music  ("..#custom.." tracks)") or "Vanilla Music")
    end
    paint()
end

local function newButton(scene,name,x,y,w,h,font,modeOf,label,code,hideF)
    local W=WIDGET.newButton{name=name,x=x,y=y,w=w,h=h,font=font,fText=label(),code=code,hideF=hideF}
    W:setObject(W.fText)
    scene.widgetList[#scene.widgetList+1]=W
    buttons[#buttons+1]={W=W,mode=modeOf,label=label}
end

-- Music Room: two buttons in the bottom-left corner
newButton(musicRoom,'novaMusCustom',203,632,290,40,26,'custom',function() return "Custom Music" end,function() setMode('custom') end)
newButton(musicRoom,'novaMusVanilla',203,680,290,40,26,'vanilla',function() return "Vanilla Music" end,function() setMode('vanilla') end)

-- Custom Game: one button left of the Music selector (it takes the place of the background selector,
-- which is only shown when "lock background" is off, so the button is hidden in that case)
if customGame and customGame.widgetList then
    newButton(customGame,'novaMusMode',868,1100,210,60,24,'all',
        function() return mode=='custom' and "Custom Music" or "Vanilla Music" end,
        function() setMode(mode=='custom' and 'vanilla' or 'custom') end,
        function() return not SETTING.lockBG end)
end

----------------------------------------------------------------- custom mode replaces the game's own music
local function pickCustom(name)
    if inList(custom,name) then return name end
    local h=0
    for i=1,#name do h=h+name:byte(i) end
    return custom[h%#custom+1]
end
do
    local orig=BGM.play
    function BGM.play(bgms,args)
        if mode=='custom' and #custom>0 then
            if bgms==nil or bgms==false then
                bgms=custom[1]
            elseif type(bgms)=='string' then
                bgms=pickCustom(bgms)
            elseif type(bgms)=='table' then
                local t={}
                for i,n in ipairs(bgms) do t[i]=pickCustom(n) end
                bgms=t
            end
        end
        return orig(bgms,args)
    end
end

----------------------------------------------------------------- start
do
    local txt=fs.getInfo(STATE) and fs.read(STATE)
    scan()
    if type(txt)=='string' and txt:find('mode=custom',1,true) then setMode('custom',true)
    else fillList(vanilla) paint() end        -- scan() registered the custom tracks in the shared list: undo that
end

CUSTOMMUSIC_LOADED=true
return "Custom music loaded: Music Room and Custom Game have the Custom Music / Vanilla Music buttons. Tracks go into the 'music' folder."
