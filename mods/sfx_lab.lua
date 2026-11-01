-- NOVA mod: SFX Lab
-- An in-game sound editor: per sound pitch, random pitch, volume, round robin and a 5-band equalizer.
-- Open it from the SFX Room (button "SFX Lab", left of the "label" switch). Changes work in real time.
-- Round robin: put several files for one sound into  sfx/variants/<sound name>/  (ogg, wav, mp3, flac).
-- Start: with CCloader.lua + mod_manager.lua it loads by itself; manually:  su 7126  then
--   #return love.filesystem.load('sfx_lab.lua')()
if SFXLAB_LOADED then return "sfx lab already loaded" end
if not (love and love.filesystem and love.audio and love.sound and SFX and SETTING and SCN and SCN.scenes
    and WIDGET and FONT and COLOR and MES and BG) then
    return "sfx lab: unsupported game version"
end
local fs=love.filesystem
local STATE='conf/nova_sfxlab'
local VARIANTS='sfx/variants'
local floor,min,max,sin,cos,sqrt,log10,pi=math.floor,math.min,math.max,math.sin,math.cos,math.sqrt,math.log10 or function(x) return math.log(x)/math.log(10) end,math.pi
local function say(t) pcall(function() MES.new('info',t) end) end

----------------------------------------------------------------- equalizer maths (RBJ biquads)
local BANDS={{f=80,kind='low',Q=0.7},{f=250,kind='peak',Q=1},{f=1000,kind='peak',Q=1},{f=3500,kind='peak',Q=1},{f=10000,kind='high',Q=0.7}}
local BAND_LABEL={"80","250","1k","3.5k","10k"}

local function coefficients(band,dB,rate)
    local A=10^(dB/40)
    local w0=2*pi*min(band.f,rate*0.45)/rate
    local c,s=cos(w0),sin(w0)
    local alpha=s/(2*band.Q)
    local b0,b1,b2,a0,a1,a2
    if band.kind=='peak' then
        b0,b1,b2=1+alpha*A,-2*c,1-alpha*A
        a0,a1,a2=1+alpha/A,-2*c,1-alpha/A
    else
        local sA=2*sqrt(A)*alpha
        if band.kind=='low' then
            b0=A*((A+1)-(A-1)*c+sA)
            b1=2*A*((A-1)-(A+1)*c)
            b2=A*((A+1)-(A-1)*c-sA)
            a0=(A+1)+(A-1)*c+sA
            a1=-2*((A-1)+(A+1)*c)
            a2=(A+1)+(A-1)*c-sA
        else
            b0=A*((A+1)+(A-1)*c+sA)
            b1=-2*A*((A-1)+(A+1)*c)
            b2=A*((A+1)+(A-1)*c-sA)
            a0=(A+1)-(A-1)*c+sA
            a1=2*((A-1)-(A+1)*c)
            a2=(A+1)-(A-1)*c-sA
        end
    end
    return b0/a0,b1/a0,b2/a0,a1/a0,a2/a0
end

-- magnitude (dB) of the whole equalizer at frequency f
local function responseDB(eq,f,rate)
    local w=2*pi*f/rate
    local c1,s1,c2,s2=cos(w),sin(w),cos(2*w),sin(2*w)
    local total=0
    for i,band in ipairs(BANDS) do
        local g=eq[i] or 0
        if g~=0 then
            local b0,b1,b2,a1,a2=coefficients(band,g,rate)
            local nr=b0+b1*c1+b2*c2
            local ni=-(b1*s1+b2*s2)
            local dr=1+a1*c1+a2*c2
            local di=-(a1*s1+a2*s2)
            total=total+10*log10((nr*nr+ni*ni)/(dr*dr+di*di))
        end
    end
    return total
end

-- apply the equalizer and a software gain to interleaved samples (table, 1-based), in place
local function processBuffer(buf,n,channels,rate,eq,gain)
    for i,band in ipairs(BANDS) do
        local g=eq[i] or 0
        if g~=0 then
            local b0,b1,b2,a1,a2=coefficients(band,g,rate)
            for ch=1,channels do
                local x1,x2,y1,y2=0,0,0,0
                for k=ch,n,channels do
                    local x=buf[k]
                    local y=b0*x+b1*x1+b2*x2-a1*y1-a2*y2
                    x2,x1,y2,y1=x1,x,y1,y
                    buf[k]=y
                end
            end
        end
    end
    for k=1,n do
        local v=buf[k]*gain
        if v>1 then v=1 elseif v<-1 then v=-1 end
        buf[k]=v
    end
end

local function processSound(sd,eq,gain)
    local n=sd:getSampleCount()*sd:getChannelCount()
    local buf={}
    for i=0,n-1 do buf[i+1]=sd:getSample(i) end
    processBuffer(buf,n,sd:getChannelCount(),sd:getSamplingRate(),eq,gain)
    local out=love.sound.newSoundData(sd:getSampleCount(),sd:getSamplingRate(),sd:getBitDepth(),sd:getChannelCount())
    for i=0,n-1 do out:setSample(i,buf[i+1]) end
    return out
end

----------------------------------------------------------------- settings of every sound
local DEFAULT_EQ={0,0,0,0,0}
local S={}                           -- name -> {on,pitch,rand,vol,rr,eq}
local function newRec() return {on=true,pitch=0,rand=0,vol=1,rr=false,eq={0,0,0,0,0},rrIdx=0} end
local function isEdited(r)
    if not r then return false end
    if r.pitch~=0 or r.rand~=0 or r.vol~=1 or r.rr then return true end
    for i=1,5 do if r.eq[i]~=0 then return true end end
    return false
end
local function eqActive(r) for i=1,5 do if r.eq[i]~=0 then return true end end return false end
local function ensure(name) local r=S[name] if not r then r=newRec() S[name]=r end return r end

local function saveState()
    local t={}
    for name,r in pairs(S) do
        if isEdited(r) or not r.on then
            t[#t+1]=("%s|%d|%g|%g|%g|%d|%s"):format(name,r.on and 1 or 0,r.pitch,r.rand,r.vol,r.rr and 1 or 0,table.concat(r.eq,','))
        end
    end
    table.sort(t)
    fs.write(STATE,table.concat(t,"\n").."\n")
end
local function loadState()
    S={}
    local txt=fs.getInfo(STATE) and fs.read(STATE)
    if type(txt)~='string' then return end
    for line in txt:gmatch('[^\r\n]+') do
        local name,on,p,rd,v,rr,eq=line:match('^([^|]+)|(%d)|([^|]+)|([^|]+)|([^|]+)|(%d)|([^|]*)$')
        if name then
            local r=newRec()
            r.on=(on=='1') r.pitch=tonumber(p) or 0 r.rand=tonumber(rd) or 0 r.vol=tonumber(v) or 1 r.rr=(rr=='1')
            local i=0
            for g in (eq or ''):gmatch('[^,]+') do i=i+1 if i<=5 then r.eq[i]=tonumber(g) or 0 end end
            S[name]=r
        end
    end
end
loadState()

----------------------------------------------------------------- files, variants and cached sources
local function basePath(name)
    local pack=NOVA_SFX_PACK
    if pack then
        local p='sfx/'..pack..'/'..name..'.ogg'
        if fs.getInfo(p) then return p end
    end
    return 'media/effect/'..SETTING.sfxPack..'/'..name..'.ogg'
end
local AUDIO_EXT={ogg=true,wav=true,mp3=true,flac=true}
local variantCache={}
local function variantsOf(name,fresh)
    local v=variantCache[name]
    if v and not fresh then return v end
    v={basePath(name)}
    local dir=VARIANTS..'/'..name
    if fs.getInfo(dir) then
        local files=fs.getDirectoryItems(dir)
        table.sort(files,function(a,b) return a:lower()<b:lower() end)
        for _,f in ipairs(files) do
            local ext=f:match('%.(%w+)$')
            if ext and AUDIO_EXT[ext:lower()] then v[#v+1]=dir..'/'..f end
        end
    end
    variantCache[name]=v
    return v
end

local cache={}                       -- path -> {sig,pool,err}
local lastError={}                   -- sound name -> text of the last processing error
local function logError(name,err)
    err=tostring(err):gsub("%s+"," ")
    lastError[name]=err:sub(1,200)
    pcall(fs.write,'conf/nova_sfxlab_error.txt',name..": "..err.."\n")
end
local function entryFor(path,r,name)
    local sig=table.concat(r.eq,',')
    local e=cache[path]
    if e and e.sig==sig then return e end
    if e then for _,src in ipairs(e.pool) do pcall(src.release,src) end end
    local ok,res=pcall(function()
        if eqActive(r) then
            local sd=love.sound.newSoundData(path)
            return love.audio.newSource(processSound(sd,r.eq,1))
        end
        return love.audio.newSource(path,'static')
    end)
    if ok then
        e={sig=sig,pool={res}}
        if name then lastError[name]=nil end
    else
        -- processing failed: keep pitch / volume / round robin working with the plain sound,
        -- the equalizer then uses the sound-effect fallback (see playEdited)
        if name then logError(name,res) end
        local ok2,plain=pcall(love.audio.newSource,path,'static')
        if not ok2 then cache[path]=nil return nil end
        e={sig=sig,pool={plain},fallbackEQ=true}
    end
    cache[path]=e
    return e
end

-- fallback equalizer: the OpenAL equalizer effect (4 bands: low / low-mid / high-mid / high)
local function dbLin(db) return max(0.126,min(7.943,10^(db/20))) end
local function applyEffect(name,src,eq)
    local ok=pcall(function()
        if not (love.audio.setEffect and love.audio.isEffectsSupported and love.audio.isEffectsSupported()) then error("effects not supported") end
        local en='novaeq_'..name
        love.audio.setEffect(en,{type='equalizer',
            lowgain=dbLin(eq[1]),lowcut=150,
            lowmidgain=dbLin(eq[2]),lowmidfrequency=250,lowmidbandwidth=0.6,
            highmidgain=dbLin((eq[3]+eq[4])/2),highmidfrequency=2000,highmidbandwidth=0.8,
            highgain=dbLin(eq[5]),highcut=8000})
        src:setEffect(en)
    end)
    return ok
end

----------------------------------------------------------------- playback
local gameVol=SETTING.sfx or 1
local gameStereo=SETTING.stereo or 1
local origPlay,origFplay,origSetVol,origSetStereo=SFX.play,SFX.fplay,SFX.setVol,SFX.setStereo
function SFX.setVol(v) gameVol=v return origSetVol(v) end
if origSetStereo then function SFX.setStereo(v) gameStereo=v return origSetStereo(v) end end

local function idleSource(e,skip)
    for _,s in ipairs(e.pool) do
        if s~=skip and not s:isPlaying() then return s end
    end
    if #e.pool>=10 then
        local s=e.pool[1]
        if s==skip then s=e.pool[2] end
        s:stop()
        return s
    end
    local c=e.pool[1]:clone()
    e.pool[#e.pool+1]=c
    return c
end

local function playEdited(name,r,vol,pos,pitch,useModuleVolume)
    local v=(vol or 1)*(useModuleVolume and gameVol or 1)
    if v==0 then return true end
    local list=variantsOf(name)
    local idx=1
    if r.rr and #list>1 then
        r.rrIdx=(r.rrIdx or 0)%#list+1
        idx=r.rrIdx
    end
    local e=entryFor(list[idx],r,name)
    if not e then return false end
    local st=(pitch or 0)+r.pitch
    if r.rand>0 then st=st+(math.random()*2-1)*r.rand end
    local base=(v*min(1,r.vol))^1.626
    local pitchRatio=2^(st/12)
    local function start(src,volume)
        if src:getChannelCount()==1 then
            if pos then
                local p=max(-1,min(1,pos))*gameStereo
                src:setPosition(p,1-p*p,0)
            else
                src:setPosition(0,0,0)
            end
        end
        if e.fallbackEQ and eqActive(r) then applyEffect(name,src,r.eq) end
        src:setVolume(volume)
        src:setPitch(pitchRatio)
        src:seek(0)
        src:play()
    end
    local first=idleSource(e)
    start(first,min(1,base))
    if r.vol>1 then
        -- above 100%: the same sound once more, started at the same moment: the two add up
        local second=idleSource(e,first)
        start(second,min(1,base*(r.vol-1)))
    end
    return true
end

function SFX.play(name,vol,pos,pitch)
    local r=S[name]
    if r and r.on and isEdited(r) and playEdited(name,r,vol,pos,pitch,true) then return end
    return origPlay(name,vol,pos,pitch)
end
if origFplay then
    function SFX.fplay(name,vol,pos,pitch)
        local r=S[name]
        if r and r.on and isEdited(r) and playEdited(name,r,vol,pos,pitch,false) then return end
        return origFplay(name,vol,pos,pitch)
    end
end

-- make edited sounds ready one by one so the first play in a game does not stutter
local warmQueue={}
local function queueWarm(name)
    for _,n in ipairs(warmQueue) do if n==name then return end end
    warmQueue[#warmQueue+1]=name
end
local function warm(name)
    local r=S[name]
    if r and r.on and isEdited(r) then
        for _,path in ipairs(variantsOf(name,true)) do entryFor(path,r,name) end
    end
end
for name in pairs(S) do queueWarm(name) end

----------------------------------------------------------------- the list of sounds and their groups
local GROUPS={"All","Clears","Combo","Spawn","Spins","Moves","Alerts","Menu"}
local function groupOf(n)
    if n:find('^clear_') or n=='pc' then return 2 end
    if n:find('^ren_') then return 3 end
    if n:find('^spawn_') then return 4 end
    if n:find('^spin_') then return 5 end
    if n:find('^rotate') or n:find('^prerotate') or n=='hold' or n=='prehold' or n=='lock' or n:find('^drop')
        or n=='fall' or n=='swipe' or n=='touch' or n=='virtualKey' then return 6 end
    if n:find('^warn') or n=='fail' or n=='error' or n:find('^finesse') or n=='reach' then return 7 end
    return 8
end
local names,view={}, {}
local groupIdx,editedOnly=1,false
local sel,scrollRow=nil,0
local TX,TY,TW,TH,ROW_H,ROWS=30,135,580,480,32,15
local clock,dirtyAt,saveAt=0,nil,nil

local function rebuildView()
    view={}
    for _,n in ipairs(names) do
        if (groupIdx==1 or groupOf(n)==groupIdx) and (not editedOnly or isEdited(S[n]) or (S[n] and not S[n].on)) then view[#view+1]=n end
    end
    local found=false
    for _,n in ipairs(view) do if n==sel then found=true end end
    if not found then sel=view[1] end
    scrollRow=max(0,min(scrollRow,max(0,#view-ROWS)))
end
local function rebuildNames()
    names={}
    for _,f in ipairs(fs.getDirectoryItems('media/effect/'..SETTING.sfxPack..'/')) do
        local n=f:match('^(.+)%.ogg$')
        if n then names[#names+1]=n end
    end
    table.sort(names,function(a,b) return a:lower()<b:lower() end)
    rebuildView()
end
local function selIndex() for i,n in ipairs(view) do if n==sel then return i end end end
local function showRow(i)
    if i<=scrollRow then scrollRow=i-1 elseif i>scrollRow+ROWS then scrollRow=i-ROWS end
    scrollRow=max(0,min(scrollRow,max(0,#view-ROWS)))
end
local function countEdited() local c=0 for _,r in pairs(S) do if isEdited(r) then c=c+1 end end return c end

local function touched()
    dirtyAt=clock
    saveAt=clock
end
local function edit(f)
    if not sel then return end
    f(ensure(sel))
    touched()
end
local function preview(name)
    if name then pcall(SFX.play,name) end
end

----------------------------------------------------------------- widgets
local gc0=love.graphics
local function text(font,label) return gc0.newText(FONT.get(font),label) end
local scene={}
local W={}
local function reg(w) scene.widgetList[#scene.widgetList+1]=w return w end
scene.widgetList={}

W.title=WIDGET.newText{name='title',x=40,y=15,font=70,align='L',fText="SFX Lab"}
W.title.obj=text(70,"SFX Lab")
reg(W.title)
W.group=WIDGET.newSelector{name='sfxGroup',x=560,y=55,w=300,fText="Group",list=GROUPS,
    disp=function() return GROUPS[groupIdx] end,
    code=function(v) for i,g in ipairs(GROUPS) do if g==v then groupIdx=i end end scrollRow=0 rebuildView() end}
W.group.obj=text(W.group.font or 30,"Group")
reg(W.group)
W.only=WIDGET.newSwitch{name='sfxOnly',x=985,y=55,lim=200,fText="Edited only",
    disp=function() return editedOnly end,
    code=function() editedOnly=not editedOnly scrollRow=0 rebuildView() end}
W.only.obj=text(W.only.font or 30,"Edited only")
reg(W.only)

local function slider(name,y,label,axis,get,set,show)
    local w=WIDGET.newSlider{name=name,x=850,y=y,w=270,lim=200,fText=label,axis=axis,disp=get,code=set,show=show or false}
    w.obj=text(w.font or 30,label)
    return reg(w)
end
local function cur() return S[sel] end
W.pitch=slider('sfxPitch',175,"Pitch",{-12,12,0.5},function() local r=cur() return r and r.pitch or 0 end,function(v) edit(function(r) r.pitch=v end) end)
W.rand=slider('sfxRand',225,"Random Pitch",{0,6,0.25},function() local r=cur() return r and r.rand or 0 end,function(v) edit(function(r) r.rand=v end) end)
W.vol=slider('sfxVol',275,"Volume",{0,2,0.05},function() local r=cur() return r and r.vol or 1 end,function(v) edit(function(r) r.vol=floor(v*100+0.5)/100 end) end)
W.rr=WIDGET.newSwitch{name='sfxRR',x=850,y=330,lim=200,fText="Round Robin",
    disp=function() local r=cur() return r and r.rr or false end,
    code=function() edit(function(r) r.rr=not r.rr end) end}
W.rr.obj=text(W.rr.font or 30,"Round Robin")
reg(W.rr)
W.active=WIDGET.newSwitch{name='sfxActive',x=1200,y=122,lim=130,fText="Active",
    disp=function() local r=cur() return not r or r.on end,
    code=function() edit(function(r) r.on=not r.on end) end}
W.active.obj=text(W.active.font or 30,"Active")
reg(W.active)

local function button(name,x,y,w,h,font,label,code,color)
    local b=WIDGET.newButton{name=name,x=x,y=y,w=w,h=h,font=font,fText=label,code=code,color=color}
    b:setObject(b.fText)
    return reg(b)
end
button('sfxTest',715,640,130,56,34,"Test",function() preview(sel) end,'lG')
button('sfxReset',855,640,130,56,30,"Reset",function()
    if sel then S[sel]=nil touched() preview(sel) end
end)
button('sfxVariants',995,640,110,56,22,"Variants",function()
    if not sel then return end
    pcall(fs.createDirectory,VARIANTS)
    pcall(fs.createDirectory,VARIANTS..'/'..sel)
    local full=fs.getSaveDirectory().."/"..VARIANTS.."/"..sel
    pcall(function() love.system.openURL("file:///"..full:gsub('\\','/'):gsub('^/','')) end)
    variantCache[sel]=nil
    say("Variants folder: "..full)
end)
local resetAllArmed
W.resetAll=button('sfxResetAll',120,655,180,50,24,"Reset all",function()
    if not resetAllArmed or clock-resetAllArmed>4 then
        resetAllArmed=clock
        W.resetAll.fText="Sure? press again"
        W.resetAll:setObject(W.resetAll.fText)
        return
    end
    resetAllArmed=nil
    S={}
    saveState()
    W.resetAll.fText="Reset all"
    W.resetAll:setObject(W.resetAll.fText)
    rebuildView()
    say("All sound settings reset")
end)
button('back',1140,640,170,80,60,CHAR and CHAR.icon and CHAR.icon.back or "<",function() SCN.back() end)

----------------------------------------------------------------- drawing
local FX={718,834,950,1066,1182}
local FY0,FY1=478,566
local CX,CY,CW,CH=660,358,580,92
local function faderValue(y)
    local mid=(FY0+FY1)/2
    local v=(mid-y)/((FY1-FY0)/2)*12
    return max(-12,min(12,floor(v*2+0.5)/2))
end
local function faderY(db) return (FY0+FY1)/2-db/12*((FY1-FY0)/2) end
local function inTable(x,y) return x>=TX and x<=TX+TW and y>=TY and y<TY+ROWS*ROW_H end
local function faderAt(x,y)
    if y<FY0-14 or y>FY1+14 then return nil end
    for i,fx in ipairs(FX) do if math.abs(x-fx)<=38 then return i end end
end
local function maxScroll() return max(0,#view-ROWS) end

local function panel(x,y,w,h,a)
    local gc=love.graphics
    gc.setColor(0,0,0,a or .45)
    gc.rectangle('fill',x,y,w,h,8,8)
    gc.setColor(1,1,1,.55)
    gc.setLineWidth(2)
    gc.rectangle('line',x,y,w,h,8,8)
end
local function fmtSt(v) return ("%+.1f st"):format(v) end

function scene.draw()
    local gc=love.graphics
    -- table ------------------------------------------------------------------------------------
    panel(TX-8,TY-34,TW+16,ROWS*ROW_H+46)
    FONT.set(18)
    gc.setColor(.75,.75,.75)
    gc.print("SOUND",TX+8,TY-28)
    for i,h in ipairs{"PITCH","RAND","VOL","RR","EQ"} do gc.printf(h,TX+250+(i-1)*60-30,TY-28,60,'center') end
    for k=1,ROWS do
        local i=scrollRow+k
        local n=view[i]
        if not n then break end
        local y=TY+(k-1)*ROW_H
        local r=S[n]
        if n==sel then
            gc.setColor(.25,.55,.95,.35)
            gc.rectangle('fill',TX,y,TW-14,ROW_H-2,5,5)
            gc.setColor(.5,.8,1,.9)
            gc.setLineWidth(2)
            gc.rectangle('line',TX,y,TW-14,ROW_H-2,5,5)
        elseif k%2==0 then
            gc.setColor(1,1,1,.05)
            gc.rectangle('fill',TX,y,TW-14,ROW_H-2,5,5)
        end
        local edited=isEdited(r)
        FONT.set(22)
        if r and not r.on then gc.setColor(.9,.6,.4)
        elseif edited then gc.setColor(.6,1,.7)
        else gc.setColor(1,1,1,.9) end
        gc.print(n,TX+10,y+3)
        FONT.set(18)
        gc.setColor(.8,.9,1,.9)
        local cells={
            r and r.pitch~=0 and ("%+g"):format(r.pitch) or "·",
            r and r.rand~=0 and ("%g"):format(r.rand) or "·",
            r and r.vol~=1 and ("%d%%"):format(floor(r.vol*100+.5)) or "·",
            r and r.rr and "ON" or "·",
            r and eqActive(r) and "EQ" or "·",
        }
        for c=1,5 do gc.printf(cells[c],TX+250+(c-1)*60-30,y+5,60,'center') end
    end
    -- scrollbar
    if maxScroll()>0 then
        local sx,sh=TX+TW-8,ROWS*ROW_H
        gc.setColor(1,1,1,.15)
        gc.rectangle('fill',sx,TY,6,sh,3,3)
        local th=max(30,sh*ROWS/#view)
        local ty=TY+(sh-th)*scrollRow/maxScroll()
        gc.setColor(1,1,1,.6)
        gc.rectangle('fill',sx,ty,6,th,3,3)
    end
    FONT.set(20)
    gc.setColor(.8,.8,.8)
    gc.print(("%d sounds, %d edited"):format(#view,countEdited()),TX+210,TY+ROWS*ROW_H+16)

    -- editor -----------------------------------------------------------------------------------
    panel(640,95,610,505)
    local r=cur()
    FONT.set(44)
    gc.setColor(1,1,1)
    gc.print(sel or "-",655,102)
    FONT.set(20)
    gc.setColor(.75,.75,.75)
    local status=(r and not r.on) and "bypassed (original sound)" or (isEdited(r) and "edited" or "default")
    if r and r.on and sel and eqActive(r) then
        local e=cache[(variantsOf(sel))[1]]
        if e then status=status.."   |   EQ: "..(e.fallbackEQ and "fallback (4 bands)" or "software (5 bands)") end
    end
    gc.print(status,657,150-12)
    local err=sel and lastError[sel]
    if err then
        FONT.set(16)
        gc.setColor(1,.5,.45)
        gc.printf("EQ processing failed, fallback equalizer is used: "..err:sub(1,90),735,102,500,'left')
        FONT.set(20)
    end
    FONT.set(24)
    gc.setColor(1,1,1)
    gc.print(fmtSt(r and r.pitch or 0),1135,175-14)
    gc.print(("±%.2f st"):format(r and r.rand or 0),1135,225-14)
    gc.print(("%d%%"):format(floor((r and r.vol or 1)*100+.5)),1135,275-14)
    FONT.set(22)
    gc.setColor(.8,.9,1)
    local list=sel and variantsOf(sel) or {}
    gc.print(#list>1 and (#list.." variants") or "1 sound: add files via Variants",915,330-13)

    -- equalizer
    gc.setColor(0,0,0,.35)
    gc.rectangle('fill',CX,CY,CW,CH,6,6)
    gc.setLineWidth(1)
    gc.setColor(1,1,1,.18)
    local midY=CY+CH/2
    gc.line(CX,midY,CX+CW,midY)
    for _,f in ipairs{100,1000,10000} do
        local x=CX+CW*(math.log(f/20)/math.log(1000))
        gc.line(x,CY,x,CY+CH)
    end
    FONT.set(14)
    gc.setColor(1,1,1,.4)
    gc.print("+12 dB",CX+4,CY+1)
    gc.print("-12 dB",CX+4,CY+CH-16)
    local eq=r and r.eq or DEFAULT_EQ
    local pts={}
    for k=0,95 do
        local f=20*10^(3*k/95)
        local db=responseDB(eq,f,44100)
        pts[#pts+1]=CX+CW*k/95
        pts[#pts+1]=midY-max(-12,min(12,db))/12*(CH/2-4)
    end
    gc.setLineWidth(3)
    gc.setColor(.4,.9,.7,.95)
    gc.line(pts)
    -- faders
    for i,fx in ipairs(FX) do
        gc.setColor(1,1,1,.3)
        gc.setLineWidth(4)
        gc.line(fx,FY0,fx,FY1)
        gc.setLineWidth(2)
        gc.line(fx-14,faderY(0),fx+14,faderY(0))
        local g=eq[i] or 0
        local ky=faderY(g)
        gc.setColor(g==0 and .8 or .4,g==0 and .8 or .9,g==0 and .8 or .7)
        gc.rectangle('fill',fx-18,ky-8,36,16,4,4)
        FONT.set(16)
        gc.setColor(1,1,1,.9)
        gc.printf(("%+g"):format(g),fx-30,FY0-30,60,'center')
        gc.setColor(.8,.8,.8)
        gc.printf(BAND_LABEL[i].." Hz",fx-40,FY1+10,80,'center')
    end
    gc.setColor(1,1,1)
end

----------------------------------------------------------------- mouse, wheel, keys
local mouseX,mouseY=0,0
local drag
local function pickRow(x,y)
    local i=scrollRow+floor((y-TY)/ROW_H)+1
    local n=view[i]
    if n then sel=n preview(n) end
end
function scene.mouseDown(x,y,k)
    mouseX,mouseY=x,y
    if x>=TX+TW-14 and x<=TX+TW+4 and y>=TY and y<=TY+ROWS*ROW_H and maxScroll()>0 then
        drag={kind='scroll'}
        scrollRow=floor((y-TY)/(ROWS*ROW_H)*maxScroll()+.5)
        scrollRow=max(0,min(scrollRow,maxScroll()))
    elseif inTable(x,y) then
        pickRow(x,y)
    else
        local f=faderAt(x,y)
        if f and sel then
            if k==2 then edit(function(r) r.eq[f]=0 end)
            else
                drag={kind='fader',i=f}
                edit(function(r) r.eq[f]=faderValue(y) end)
            end
        end
    end
end
function scene.mouseMove(x,y)
    mouseX,mouseY=x,y
    if not drag then return end
    if drag.kind=='fader' and sel then
        edit(function(r) r.eq[drag.i]=faderValue(y) end)
    elseif drag.kind=='scroll' then
        scrollRow=floor((y-TY)/(ROWS*ROW_H)*maxScroll()+.5)
        scrollRow=max(0,min(scrollRow,maxScroll()))
    end
end
function scene.mouseUp() drag=nil end
function scene.wheelMoved(dx,dy)
    if inTable(mouseX,mouseY) then
        scrollRow=max(0,min(scrollRow-dy*2,maxScroll()))
    else
        local f=faderAt(mouseX,mouseY)
        if f and sel then edit(function(r) r.eq[f]=max(-12,min(12,r.eq[f]+dy)) end) end
    end
end
function scene.touchDown(id,x,y) scene.mouseDown(x,y,1) end
function scene.touchMove(id,x,y) scene.mouseMove(x,y) end
function scene.touchUp() scene.mouseUp() end
function scene.keyDown(key,isRep)
    local i=selIndex() or 1
    if key=='up' or key=='down' then
        i=max(1,min(#view,i+(key=='down' and 1 or -1)))
        sel=view[i] showRow(i) preview(sel)
    elseif key=='pageup' or key=='pagedown' then
        i=max(1,min(#view,i+(key=='pagedown' and ROWS or -ROWS)))
        sel=view[i] showRow(i) preview(sel)
    elseif key=='space' or key=='return' then
        preview(sel)
    elseif key=='delete' and sel then
        S[sel]=nil touched()
    elseif key=='escape' then
        SCN.back()
    else
        return true
    end
end
function scene.enter()
    rebuildNames()
    loadState()
    rebuildView()
    local i=selIndex()
    if i then showRow(i) end
    drag=nil
end
function scene.leave() saveState() end
SCN.add('sfxlab',scene)

----------------------------------------------------------------- button in the SFX Room
local room=SCN.scenes.launchpad
if room and room.widgetList then
    local b=WIDGET.newButton{name='novaSfxLab',x=990,y=290,w=200,h=50,font=30,color='lB',fText="SFX Lab",code=function() SCN.go('sfxlab') end}
    b:setObject(b.fText)
    room.widgetList[#room.widgetList+1]=b
end

----------------------------------------------------------------- every frame: delayed preview, saving, warming
do
    local oldBG=BG.update
    function BG.update(dt,...)
        oldBG(dt,...)
        clock=clock+dt
        local ok,err=pcall(function()
            if dirtyAt and clock-dirtyAt>0.2 then
                dirtyAt=nil
                if sel then warm(sel) preview(sel) end
            end
            if saveAt and clock-saveAt>1 then saveAt=nil saveState() end
            local n=table.remove(warmQueue,1)
            if n then warm(n) end
        end)
        if not ok then say("SFX Lab error: "..tostring(err):gsub("%s+"," "):sub(1,70)) end
    end
end

rebuildNames()
SFXLAB_LOADED=true
return "SFX Lab loaded: SFX Room has the SFX Lab button"
