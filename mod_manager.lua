-- NOVA mod manager for Techmino 0.17.21  (single file; the game files are NOT modified)
-- Loads the mods from the save folder (autoplay_trainer.lua, bg_switcher.lua, custom_music.lua and every
-- file in the folder  mods ), adds a "Mods" button to the main menu and a window to switch mods on and off
-- or install a mod from the clipboard.  Changes take effect after restarting the game.
-- Start: with CCloader.lua in the save folder it loads by itself; manually:  su 7126  then
--   #return love.filesystem.load('mod_manager.lua')()
if MODMANAGER_LOADED then return "mod manager already loaded" end
if not (love and love.filesystem and SCN and SCN.scenes and WIDGET and FONT and COLOR) then
    return "mod manager: unsupported game version"
end
local fs=love.filesystem
local STATE='conf/nova_mods'
local DIR='mods'
local BUILTIN={
    {file='autoplay_trainer.lua',name="NOVA Autoplay",desc="Bots: play for you and as an opponent (NOVA, Cold Clear, 9S)"},
    {file='bg_switcher.lua',name="Background Switcher",desc="Pictures, GIFs and videos as backgrounds"},
    {file='custom_music.lua',name="Custom Music",desc="Your own tracks in the Music Room and Custom Game"},
    {file='custom_assets.lua',name="Custom Skins and SFX",desc="Block skins from the skins folder, sound packs from the sfx folder"},
    {file='sfx_lab.lua',name="SFX Lab",desc="Per-sound pitch, random pitch, volume, round robin and equalizer"},
}
local mods={}                      -- {file,name,desc,enabled,status,builtin}
local disabled={}
local load_=loadstring or load

local function say(t) pcall(function() MES.new('info',t) end) end

----------------------------------------------------------------- state and scanning
do
    local txt=fs.getInfo(STATE) and fs.read(STATE)
    if type(txt)=='string' then
        for v in txt:gmatch('off=([^\r\n]+)') do disabled[v]=true end
    end
end
local function saveState()
    local t={}
    for _,m in ipairs(mods) do
        if not m.enabled then t[#t+1]="off="..m.file end
    end
    fs.write(STATE,table.concat(t,"\n").."\n")
end

local function header(file)
    local txt=fs.read(file)
    if type(txt)~='string' then return end
    local name=txt:match('^%s*%-%-%s*NOVA mod:%s*([^\r\n]+)')
    local desc=txt:match('^[^\r\n]*[\r\n]+%s*%-%-%s*([^\r\n]+)')
    return name,desc
end

local function scan()
    local old={}
    for _,m in ipairs(mods) do old[m.file]=m end
    mods={}
    local builtinFile={}
    pcall(fs.createDirectory,DIR)
    for _,b in ipairs(BUILTIN) do
        -- the known mods may sit in the save folder (older layout) or in the mods folder (recommended)
        local path=fs.getInfo(DIR..'/'..b.file) and (DIR..'/'..b.file) or (fs.getInfo(b.file) and b.file)
        if path then
            mods[#mods+1]={file=path,name=b.name,desc=b.desc,builtin=true}
            builtinFile[b.file]=true
        end
    end
    local extra={}
    for _,f in ipairs(fs.getDirectoryItems(DIR)) do
        if f:lower():match('%.lua$') and fs.getInfo(DIR..'/'..f) and not builtinFile[f] then extra[#extra+1]=f end
    end
    table.sort(extra,function(a,b) return a:lower()<b:lower() end)
    for _,f in ipairs(extra) do
        local file=DIR..'/'..f
        local name,desc=header(file)
        mods[#mods+1]={file=file,name=name or f:gsub('%.lua$',''),desc=desc or "(no description)"}
    end
    for _,m in ipairs(mods) do
        m.enabled=not disabled[m.file]
        local o=old[m.file]
        m.status=o and o.status or (m.enabled and "will load after restart" or "disabled")
    end
end

local function loadAll()
    scan()
    for _,m in ipairs(mods) do
        if not m.enabled then
            m.status="disabled"
        else
            local chunk,err=fs.load(m.file)
            if not chunk then
                m.status="error: "..tostring(err):gsub("%s+"," "):sub(1,60)
            else
                local ok,res=pcall(chunk)
                m.status=ok and "loaded" or ("error: "..tostring(res):gsub("%s+"," "):sub(1,60))
            end
        end
    end
end
loadAll()

----------------------------------------------------------------- the Mods window
local ROWS=8
local scene={}
local rowSwitch={}
local btnInstall,btnFolder
local pending                      -- {slug,code,time} waiting for a second click

local function setTitle(W,label)
    W.fText=label
    W.obj=love.graphics.newText(FONT.get(W.font or 30),label)
end

local function refresh()
    scan()
    for i=1,ROWS do
        local m=mods[i]
        setTitle(rowSwitch[i],m and m.name or "-")
    end
end

local function slugOf(name)
    local s=name:lower():gsub('[^%w_%-]+','_'):gsub('^_+',''):gsub('_+$','')
    if s=='' then s='mod' end
    return s:sub(1,40)
end

local function installClipboard()
    local ok,txt=pcall(love.system.getClipboardText)
    txt=ok and txt or ''
    if type(txt)~='string' or #txt<30 then say("The clipboard has no mod code") pending=nil return end
    local f,err=load_(txt)
    if not f then say("Not valid Lua: "..tostring(err):gsub("%s+"," "):sub(1,60)) pending=nil return end
    local name=txt:match('^%s*%-%-%s*NOVA mod:%s*([^\r\n]+)') or ("mod_"..os.date('%H%M%S'))
    local slug=slugOf(name)
    if not (pending and pending.slug==slug and pending.code==txt and os.time()-pending.time<=8) then
        pending={slug=slug,code=txt,time=os.time()}
        local _,n=txt:gsub('\n','')
        say(("Install '%s' (%d lines)? It runs with full access to the game. Press again within 8 s to confirm."):format(name,n+1))
        btnInstall.fText="Press again to install"
        btnInstall:setObject(btnInstall.fText)
        return
    end
    pending=nil
    pcall(fs.createDirectory,DIR)
    fs.write(DIR..'/'..slug..'.lua',txt)
    btnInstall.fText="Install from clipboard"
    btnInstall:setObject(btnInstall.fText)
    refresh()
    say("Installed "..slug..".lua - restart the game to load it")
end

local function openFolder()
    pcall(fs.createDirectory,DIR)
    local dir=fs.getSaveDirectory().."/"..DIR
    local ok=pcall(function() love.system.openURL("file:///"..dir:gsub('\\','/'):gsub('^/','')) end)
    say((ok and "Opened: " or "Folder: ")..dir)
end

for i=1,ROWS do
    local y=150+(i-1)*58
    rowSwitch[i]=WIDGET.newSwitch{name='novaMod'..i,x=430,y=y,lim=360,fText="-",
        disp=function() return mods[i] and mods[i].enabled end,
        code=function()
            local m=mods[i]
            if not m then return end
            m.enabled=not m.enabled
            if m.enabled then disabled[m.file]=nil else disabled[m.file]=true end
            m.status=m.enabled and "will load after restart" or "disabled after restart"
            saveState()
        end,
        hideF=function() return not mods[i] end}
end
btnInstall=WIDGET.newButton{name='novaModInstall',x=270,y=640,w=440,h=70,font=34,color='lV',fText="Install from clipboard",code=installClipboard}
btnFolder=WIDGET.newButton{name='novaModFolder',x=720,y=640,w=300,h=70,font=34,color='lN',fText="Open mods folder",code=openFolder}
local title=WIDGET.newText{name='title',x=40,y=15,font=70,align='L',fText="Mods"}
setTitle(title,"Mods")
local backBtn=WIDGET.newButton{name='back',x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR and CHAR.icon and CHAR.icon.back or "<",code=function() SCN.back() end}
backBtn:setObject(backBtn.fText)
btnInstall:setObject(btnInstall.fText)
btnFolder:setObject(btnFolder.fText)
for _,W in ipairs(rowSwitch) do setTitle(W,"-") end
scene.widgetList={title,backBtn,btnInstall,btnFolder}
for _,W in ipairs(rowSwitch) do scene.widgetList[#scene.widgetList+1]=W end

function scene.enter() pending=nil btnInstall.fText="Install from clipboard" btnInstall:setObject(btnInstall.fText) refresh() end
function scene.keyDown(key,isRep)
    if key=='escape' then SCN.back() else return true end
end
function scene.draw()
    local gc=love.graphics
    for i=1,ROWS do
        local m=mods[i]
        if m then
            local y=150+(i-1)*58
            gc.setColor(COLOR.Z)
            FONT.set(22)
            gc.print(m.desc,500,y-26)
            local st=m.status or ""
            if st:find('^error') then gc.setColor(1,.45,.45)
            elseif st=="loaded" then gc.setColor(.6,1,.6)
            else gc.setColor(.75,.75,.75) end
            FONT.set(18)
            gc.print(st,500,y+2)
        end
    end
    if #mods>ROWS then
        gc.setColor(COLOR.Z) FONT.set(20)
        gc.print(("(+%d more in the mods folder, not shown)"):format(#mods-ROWS),430,150+ROWS*58-20)
    end
    gc.setColor(1,.85,.4)
    FONT.set(22)
    gc.printf("Mods are code that runs with full access to the game: install only code you trust.\nChanges apply after restarting the game.",40,560,1200,'left')
    gc.setColor(1,1,1)
end
SCN.add('novamods',scene)

----------------------------------------------------------------- the "Mods" button in the main menu
local main=SCN.scenes.main
if main and main.widgetList then
    local W=WIDGET.newButton{name='novaMods',x=1190,y=80,w=100,font=30,color='lV',fText="Mods",
        code=function() SCN.go('novamods') end}
    W:setObject(W.fText)
    main.widgetList[#main.widgetList+1]=W
end

MODMANAGER_LOADED=true
return "Mod manager loaded: Mods button in the main menu"
