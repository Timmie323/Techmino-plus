-- NOVA background switcher for Techmino 0.17.21  (single file; the game files are NOT modified)
-- Put pictures (png, jpg, bmp, tga), animated GIFs and videos (.ogv) into the folder  backgrounds
-- inside the Techmino save folder. Controls are in Settings > Video, between the background slider
-- and "Disable theme":  [<] [Next BG]   [Auto] [Order] [Fit]
-- Start: with CCloader.lua in the save folder it loads by itself; manually:  su 7126  then
--   #return love.filesystem.load('bg_switcher.lua')()
if BGSWITCH_LOADED then return "background switcher already loaded" end
if not (love and love.filesystem and love.graphics and BG and SETTING and SCN and SCN.scenes and WIDGET and GC and SCR) then
    return "background switcher: unsupported game version"
end
local scene=SCN.scenes.setting_video
if not (scene and scene.widgetList) then return "background switcher: video settings scene not found" end

local GIF=(function()
-- Minimal GIF decoder in plain Lua (no bit library): GIF.open(data) -> next() returning
-- {rgba=string(4*w*h), delay=seconds} frame by frame (already composed on the full canvas), nil at the end.
local GIF={}
local floor,byte,char,concat=math.floor,string.byte,string.char,table.concat
local pow2={} for i=0,16 do pow2[i]=2^i end
local TRANSP=char(0,0,0,0)

local function readPalette(data,pos,n)
    local pal={}
    for i=0,n-1 do
        local p=pos+i*3
        pal[i+1]=char(byte(data,p),byte(data,p+1),byte(data,p+2),255)
    end
    return pal
end

function GIF.open(data)
    if type(data)~='string' or data:sub(1,3)~='GIF' then return nil,"not a GIF file" end
    local w=byte(data,7)+byte(data,8)*256
    local h=byte(data,9)+byte(data,10)*256
    if w<1 or h<1 then return nil,"bad GIF size" end
    local flags=byte(data,11)
    local pos=14
    local gct
    if flags>=128 then
        local n=pow2[flags%8+1]
        gct=readPalette(data,pos,n)
        pos=pos+n*3
    end
    local canvas={}
    for i=1,w*h do canvas[i]=TRANSP end
    local gce={disposal=0,trans=nil,delay=0.1}
    local prevDisp,prevRect,snapshot=0,nil,nil
    local stack={}

    local function nextFrame()
        while true do
            local b=byte(data,pos)
            if not b or b==0x3B then return nil end
            if b==0x21 then
                local label=byte(data,pos+1)
                if label==0xF9 then
                    local pf=byte(data,pos+3)
                    gce.disposal=floor(pf/4)%8
                    gce.trans=(pf%2==1) and byte(data,pos+6) or nil
                    local d=byte(data,pos+4)+byte(data,pos+5)*256
                    gce.delay=(d<2 and 10 or d)/100
                end
                pos=pos+2
                local n=byte(data,pos)
                while n and n>0 do pos=pos+n+1 n=byte(data,pos) end
                pos=pos+1
            elseif b==0x2C then
                local ix=byte(data,pos+1)+byte(data,pos+2)*256
                local iy=byte(data,pos+3)+byte(data,pos+4)*256
                local iw=byte(data,pos+5)+byte(data,pos+6)*256
                local ih=byte(data,pos+7)+byte(data,pos+8)*256
                local f=byte(data,pos+9)
                pos=pos+10
                local pal=gct
                if f>=128 then
                    local n=pow2[f%8+1]
                    pal=readPalette(data,pos,n)
                    pos=pos+n*3
                end
                pal=pal or {}
                local interlaced=(floor(f/64)%2==1)
                local minCode=byte(data,pos)
                pos=pos+1
                local parts={}
                local n=byte(data,pos)
                while n and n>0 do
                    parts[#parts+1]=data:sub(pos+1,pos+n)
                    pos=pos+n+1
                    n=byte(data,pos)
                end
                pos=pos+1
                local stream=concat(parts)

                -- dispose the previous frame
                if prevDisp==2 and prevRect then
                    for yy=prevRect[2],prevRect[2]+prevRect[4]-1 do
                        if yy<h then
                            for xx=prevRect[1],prevRect[1]+prevRect[3]-1 do
                                if xx<w then canvas[yy*w+xx+1]=TRANSP end
                            end
                        end
                    end
                elseif prevDisp==3 and snapshot then
                    canvas=snapshot
                end
                snapshot=nil
                if gce.disposal==3 then
                    snapshot={}
                    for i=1,w*h do snapshot[i]=canvas[i] end
                end

                -- row order
                local rows={}
                if interlaced then
                    for _,p in ipairs{{0,8},{4,8},{2,4},{1,2}} do
                        local yy=p[1]
                        while yy<ih do rows[#rows+1]=yy yy=yy+p[2] end
                    end
                else
                    for yy=0,ih-1 do rows[yy+1]=yy end
                end

                -- LZW
                local clear=pow2[minCode]
                local eoi=clear+1
                local codeSize=minCode+1
                local limit=pow2[codeSize]
                local nextCode=eoi+1
                local prefix,suffix={}, {}
                local bitbuf,bitcnt,spos=0,0,1
                local slen=#stream
                local prev,firstChar=nil,0
                local trans=gce.trans
                local col,row=0,1
                local base=(iy+(rows[1] or 0))*w+ix+1
                local finished=(ih==0 or iw==0)
                while not finished do
                    while bitcnt<codeSize do
                        local sb=byte(stream,spos)
                        if not sb then finished=true break end
                        spos=spos+1
                        bitbuf=bitbuf+sb*pow2[bitcnt]
                        bitcnt=bitcnt+8
                    end
                    if finished then break end
                    local code=bitbuf%limit
                    bitbuf=(bitbuf-code)/limit
                    bitcnt=bitcnt-codeSize
                    if code==clear then
                        codeSize=minCode+1
                        limit=pow2[codeSize]
                        nextCode=eoi+1
                        prev=nil
                    elseif code==eoi then
                        break
                    else
                        local incode=code
                        local sp=0
                        if prev==nil then
                            sp=1 stack[1]=code firstChar=code
                        else
                            if code>=nextCode then
                                sp=1 stack[1]=firstChar
                                code=prev
                            end
                            while code>=clear do
                                sp=sp+1 stack[sp]=suffix[code]
                                code=prefix[code]
                            end
                            sp=sp+1 stack[sp]=code
                            firstChar=code
                            if nextCode<4096 then
                                prefix[nextCode]=prev
                                suffix[nextCode]=firstChar
                                nextCode=nextCode+1
                                if nextCode>=limit and codeSize<12 then
                                    codeSize=codeSize+1
                                    limit=pow2[codeSize]
                                end
                            end
                        end
                        prev=incode
                        for i=sp,1,-1 do
                            if row>ih then finished=true break end
                            local idx=stack[i]
                            if idx~=trans then
                                canvas[base+col]=pal[idx+1] or TRANSP
                            end
                            col=col+1
                            if col==iw then
                                col=0
                                row=row+1
                                if row<=ih then base=(iy+rows[row])*w+ix+1 end
                            end
                        end
                    end
                end
                prevDisp=gce.disposal
                prevRect={ix,iy,iw,ih}
                local delay=gce.delay
                gce.trans=nil
                gce.disposal=0
                gce.delay=0.1
                return {rgba=concat(canvas),delay=delay}
            else
                return nil
            end
        end
    end
    return nextFrame,w,h
end
return GIF

end)()

local fs=love.filesystem
local gc=love.graphics
local DIR='backgrounds'
local STATE='conf/nova_bg'
local KIND={png='image',jpg='image',jpeg='image',bmp='image',tga='image',ogv='video',gif='gif'}
local AUTO_SEC={0,10,30,60,300}
local AUTO_NAME={'off','10 s','30 s','1 min','5 min'}
local FIT_NAME={'Fill','Fit','Stretch'}
local FADE=.6
local GIF_PIXEL_CAP=150000000            -- total pixels kept for one GIF (about 600 MB of video memory)

local S={on=false,name=false,auto=1,random=false,fit=1}      -- saved between launches
local list,idx={},0
local cur,old,fade,elapsed=false,false,1,0

local function say(t) pcall(function() MES.new('info',t) end) end

----------------------------------------------------------------- saved state
local function saveState()
    fs.write(STATE,("on=%d\nname=%s\nauto=%d\nrandom=%d\nfit=%d\n"):format(S.on and 1 or 0,S.name or '',S.auto,S.random and 1 or 0,S.fit))
end
do
    local txt=fs.getInfo(STATE) and fs.read(STATE)
    if type(txt)=='string' then
        if not txt:find('=',1,true) then txt="name="..txt.."\n" end      -- the first version stored only the name
        for k,v in txt:gmatch('(%w+)=([^\r\n]*)') do
            if k=='on' then S.on=(v=='1')
            elseif k=='name' then S.name=(v~='' and v)
            elseif k=='auto' then S.auto=math.max(1,math.min(#AUTO_SEC,tonumber(v) or 1))
            elseif k=='random' then S.random=(v=='1')
            elseif k=='fit' then S.fit=math.max(1,math.min(#FIT_NAME,tonumber(v) or 1)) end
        end
    end
end

----------------------------------------------------------------- the picture folder
local function scan()
    list={}
    for _,name in ipairs(fs.getDirectoryItems(DIR)) do
        local ext=name:match('%.(%w+)$')
        if ext and KIND[ext:lower()] then
            local info=fs.getInfo(DIR..'/'..name)
            if info and info.type~='directory' then list[#list+1]=name end
        end
    end
    table.sort(list,function(a,b) return a:lower()<b:lower() end)
end
local function indexOf(name)
    for i,n in ipairs(list) do if n==name then return i end end
end

----------------------------------------------------------------- media objects
local function newImageFrom(data)
    gc.setDefaultFilter('linear','linear')
    local ok,img=pcall(GC.newImage,data)
    gc.setDefaultFilter('nearest','nearest')
    return ok and img or nil
end

local function loadMedia(name)
    local path=DIR..'/'..name
    local kind=KIND[(name:match('%.(%w+)$') or ''):lower()]
    if kind=='image' then
        local ok,data=pcall(fs.newFileData,path)
        if not ok or not data then return nil,"Cannot read "..name end
        local img=newImageFrom(data)
        if not img then return nil,"Cannot load "..name end
        return {kind='image',obj=img,w=img:getWidth(),h=img:getHeight()}
    elseif kind=='video' then
        local ok,v=pcall(gc.newVideo,path,{audio=false})
        if not ok then ok,v=pcall(gc.newVideo,path,false) end
        if not ok or not v then return nil,"Cannot open the video "..name.." (needs Ogg Theora .ogv)" end
        v:play()
        return {kind='video',obj=v,w=v:getWidth(),h=v:getHeight(),
            update=function(m) if not v:isPlaying() then v:rewind() v:play() end end,
            close=function(m) pcall(function() v:pause() end) pcall(function() v:release() end) end}
    elseif kind=='gif' then
        local data=fs.read(path)
        local nextFrame,w,h=GIF.open(data)
        if not nextFrame then return nil,"Cannot read the GIF "..name end
        if w*h>4096*4096 then return nil,name.." is too large" end
        local m={kind='gif',w=w,h=h,frames={},delays={},fi=1,t=0,done=false}
        local limit=math.max(2,math.floor(GIF_PIXEL_CAP/(w*h)))
        local function decode(budget)
            local t0=love.timer.getTime()
            repeat
                local f=nextFrame()
                if not f then m.done=true return end
                local okd,imgd=pcall(love.image.newImageData,w,h,'rgba8',f.rgba)
                local img=okd and newImageFrom(imgd)
                if img then m.frames[#m.frames+1]=img m.delays[#m.delays+1]=f.delay end
                if #m.frames>=limit then m.done=true return end
            until love.timer.getTime()-t0>budget
        end
        decode(0.05)
        if #m.frames==0 then return nil,"Cannot decode the GIF "..name end
        function m.update(m,dt)
            if not m.done then decode(0.004) end
            if #m.frames>1 then
                m.t=m.t+dt
                while m.t>=m.delays[m.fi] do
                    m.t=m.t-m.delays[m.fi]
                    m.fi=m.fi%#m.frames+1
                end
            end
        end
        return m
    end
    return nil,"Unsupported file "..name
end

local function closeMedia(m)
    if m and m.close then m:close() end
end

local function drawMedia(m,alpha)
    if alpha<=0.001 then return end
    local obj=(m.kind=='gif') and m.frames[m.fi] or m.obj
    if not obj then return end
    local W,H=SCR.w,SCR.h
    local kx,ky
    if S.fit==3 then kx,ky=W/m.w,H/m.h
    elseif S.fit==2 then kx=math.min(W/m.w,H/m.h) ky=kx
    else kx=math.max(W/m.w,H/m.h) ky=kx end
    gc.setColor(1,1,1,alpha)
    gc.draw(obj,W*.5,H*.5,0,kx,ky,m.w*.5,m.h*.5)
end

----------------------------------------------------------------- the background itself
local nbg={}
local show,advance
function nbg.init() end
function nbg.resize() end
function nbg.update(dt)
    if cur and cur.update then cur:update(dt) end
    if old then
        if old.update then old:update(dt) end
        fade=math.min(1,fade+dt/FADE)
        if fade>=1 then closeMedia(old) old=false end
    end
    if AUTO_SEC[S.auto]>0 and #list>1 then
        elapsed=elapsed+dt
        if elapsed>=AUTO_SEC[S.auto] then advance(1) end
    end
end
function nbg.draw()
    gc.clear(.1,.1,.1)
    local a=SETTING.bgAlpha or .26
    if old then drawMedia(old,a*(1-fade)) end
    if cur then drawMedia(cur,a*(old and fade or 1)) end
end
function nbg.discard()          -- the game switched to another background (e.g. "Normal BG")
    closeMedia(cur) closeMedia(old)
    cur,old=false,false
end
BG.add('novaLive',nbg)

local function activate()
    BG.unlock()
    BG.set('novaLive')
    BG.lock()
end

----------------------------------------------------------------- interface (Settings > Video)
local widgets=scene.widgetList
local btn={}
local function label(k)
    if k=='next' then
        if #list==0 then return "Next BG  (folder is empty)" end
        if idx==0 or not S.on then return ("Next BG   (%d files)"):format(#list) end
        return ("Next BG   %d / %d"):format(idx,#list)
    elseif k=='auto' then return "Auto: "..AUTO_NAME[S.auto]
    elseif k=='order' then return "Order: "..(S.random and "Random" or "A-Z")
    elseif k=='fit' then return "Fit: "..FIT_NAME[S.fit] end
    return "<"
end
local function refresh()
    for k,W in pairs(btn) do
        W.fText=label(k)
        W:setObject(W.fText)
    end
end

function show(i,instant)
    local name=list[i]
    local m,err=loadMedia(name)
    if not m then say(err) return false end
    if old then closeMedia(old) old=false end
    if cur and not instant then old=cur fade=0 else closeMedia(cur) fade=1 end
    cur=m
    idx=i
    S.on,S.name=true,name
    elapsed=0
    activate()
    saveState()
    refresh()
    return true
end

function advance(d)
    pcall(fs.createDirectory,DIR)
    scan()
    if #list==0 then
        idx=0
        refresh()
        say("Put pictures, GIFs or .ogv videos into: "..fs.getSaveDirectory().."/"..DIR)
        return
    end
    local i=indexOf(S.name) or idx
    if d>0 and S.random and #list>1 then
        local j
        repeat j=math.random(#list) until j~=i
        i=j
    elseif i==0 or i>#list then
        i=(d>0) and 1 or #list
    else
        i=(i-1+d)%#list+1
    end
    if show(i) then say(("%s  (%d/%d)"):format(list[i],i,#list)) end
end

pcall(fs.createDirectory,DIR)
scan()
if S.name then idx=indexOf(S.name) or 0 end

-- the native "Normal BG / No BG / Custom BG" buttons switch our background off
for _,W in ipairs(widgets) do
    if W.name=='bg_on' or W.name=='bg_off' or W.name=='bg_custom' then
        local orig=W.code
        if orig then
            W.code=function(...)
                S.on=false
                saveState()
                refresh()
                return orig(...)
            end
        end
    elseif W.name=='noTheme' then
        W.y=W.y+110                         -- room for two rows of buttons above it
        if W.resCtr then for i=2,#W.resCtr,2 do W.resCtr[i]=W.resCtr[i]+110 end end
    end
end

local function key(k,x,y,w,h,font,code)
    local W=WIDGET.newKey{name='novaBg_'..k,x=x,y=y,w=w,h=h,font=font,fText=label(k),code=code}
    W:setObject(W.fText)
    widgets[#widgets+1]=W
    btn[k]=W
end
local Y1,Y2,H=1413,1463,42
key('prev',835,Y1,70,H,26,function() advance(-1) end)
key('next',1050,Y1,340,H,24,function() advance(1) end)
key('auto',868,Y2,136,H,20,function() S.auto=S.auto%#AUTO_SEC+1 elapsed=0 saveState() refresh() end)
key('order',1010,Y2,136,H,20,function() S.random=not S.random saveState() refresh() end)
key('fit',1152,Y2,136,H,20,function() S.fit=S.fit%#FIT_NAME+1 saveState() refresh() end)
btn.prev.fText="<"

-- applySettings (called by the game on many events) would put its own background back: put ours on top again
do
    local orig=applySettings
    if type(orig)=='function' then
        function applySettings(reason,...)
            local r=orig(reason,...)
            if S.on and reason~='fullscreen' and BG.cur~='novaLive' then
                local i=S.name and indexOf(S.name)
                if i then show(i,true) end
            end
            return r
        end
    end
end

-- bring back the last background at start
if S.on and S.name then
    local i=indexOf(S.name)
    if i then pcall(show,i,true) else S.on=false end
end

BGSWITCH_LOADED=true
say("Background switcher loaded (Settings > Video)")
return "Background switcher loaded: Settings > Video has the BG buttons. Put files into the 'backgrounds' folder."
