-- NOVA mod: Custom Skins and SFX
-- Block skins from the folder  skins  and sound packs from the folder  sfx  (inside the Techmino save folder).
-- Style Settings gets  Reload / Template / Folder  buttons next to the Block Skin selector;
-- the SFX Room gets a "Custom SFX" selector with the same three buttons.  Written for Techmino 0.17.21.
-- Start: with CCloader.lua + mod_manager.lua it loads by itself; manually:  su 7126  then
--   #return love.filesystem.load('custom_assets.lua')()
if CUSTOMASSETS_LOADED then return "custom skins/sfx already loaded" end
if not (love and love.filesystem and SKIN and SFX and SETTING and SCN and SCN.scenes and WIDGET and FONT and MES and BG) then
    return "custom skins/sfx: unsupported game version"
end
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
local STATE='conf/nova_assets'
local SKIN_DIR,SFX_DIR='skins','sfx'

local function say(t) pcall(function() MES.new('info',t) end) end
local function saveDir() return fs.getSaveDirectory() end
local function openFolder(dir)
    pcall(fs.createDirectory,dir)
    local full=saveDir().."/"..dir
    local ok=pcall(function() love.system.openURL("file:///"..full:gsub('\\','/'):gsub('^/','')) end)
    say((ok and "Opened: " or "Folder: ")..full)
end
local function stem(f) return (f:gsub('%.[^%.]+$','')) end

----------------------------------------------------------------- block skins
local skinFiles={}             -- file -> registered name
local registerAnimation

-- The game builds the picture of the selected skin the moment it is first used (the main menu does that
-- before mods are loaded). A skin that was not registered yet is then built EMPTY ("[no skin]") and stays so.
-- Here the already existing empty cells are filled with the real picture, in place.
local function refillSkin(name,path)
    local lib,mini=rawget(SKIN.lib,name),rawget(SKIN.libMini,name)
    if not lib then return false end
    local gc=love.graphics
    local ok=pcall(function()
        gc.push()
        gc.origin()
        gc.setDefaultFilter('nearest','nearest')
        local I=gc.newImage(path)
        for y=0,2 do
            for x=1,8 do
                local i=8*y+x
                if lib[i] then
                    gc.setCanvas(lib[i])
                    gc.clear(0,0,0,0)
                    gc.setColor(1,1,1)
                    gc.draw(I,30-30*x,-30*y)
                end
                if mini and mini[i] then
                    gc.setCanvas(mini[i])
                    gc.clear(0,0,0,0)
                    gc.setColor(1,1,1)
                    gc.draw(I,6-6*x,-6*y,nil,.2)
                end
            end
        end
        gc.setDefaultFilter('linear','linear')
        gc.setCanvas()
        gc.pop()
    end)
    if not ok then pcall(love.graphics.setCanvas) end
    return ok
end
local function scanSkins()
    pcall(fs.createDirectory,SKIN_DIR)
    local list=SKIN.getList()
    local taken={}
    for _,n in ipairs(list) do taken[n]=true end
    local added,rejected=0,{}
    local files=fs.getDirectoryItems(SKIN_DIR)
    table.sort(files,function(a,b) return a:lower()<b:lower() end)
    for _,f in ipairs(files) do
        local ext=f:match('%.(%w+)$')
        if ext and ext:lower()=='png' and f:sub(1,1)~='_' and not skinFiles[f] then
            local ok,img=pcall(love.image.newImageData,SKIN_DIR..'/'..f)
            if ok and img and img:getWidth()==240 and img:getHeight()==90 then
                local name=stem(f)
                if taken[name] then name=name.." (custom)" end
                SKIN.load{{name=name,path=SKIN_DIR..'/'..f}}
                refillSkin(name,SKIN_DIR..'/'..f)
                if registerAnimation then
                    local gc=love.graphics
                    gc.setDefaultFilter('nearest','nearest')
                    local okA,atlas=pcall(gc.newImage,SKIN_DIR..'/'..f)
                    gc.setDefaultFilter('linear','linear')
                    if okA then registerAnimation(name,SKIN_DIR..'/'..f,atlas) end
                end
                taken[name]=true
                skinFiles[f]=name
                added=added+1
            else
                rejected[#rejected+1]=f..(ok and img and (" ("..img:getWidth().."x"..img:getHeight()..")") or "")
            end
        end
    end
    return added,rejected
end

local function exportSkinTemplate()
    pcall(fs.createDirectory,SKIN_DIR)
    local cur=SETTING.skinSet
    local src
    for _,f in ipairs(fs.getDirectoryItems('media/image/skin')) do
        local s=stem(f)
        if s==cur or s:sub(1,#cur+1)==cur..'_' then src='media/image/skin/'..f break end
    end
    src=src or 'media/image/skin/'..stem((fs.getDirectoryItems('media/image/skin'))[1] or '')..'.png'
    local data=fs.read(src)
    if not data then say("No template skin found") return end
    local out=SKIN_DIR..'/_template_'..cur..'.png'
    fs.write(out,data)
    fs.write(SKIN_DIR..'/_animation_example.txt',
        "# Put this file next to your skin as skins/<name>.txt (same name as the png) to animate it.\n"..
        "# The animation is the layer BELOW the skin; a GIF named skins/<name>.gif is used when anim is not set.\n"..
        "anim=rainbow      # rainbow, ocean, fire, aurora (built-in gradients) or gif\n"..
        "fps=20            # redraw rate, 1..60\n"..
        "speed=1           # animation speed\n"..
        "blend=tint        # over: skin on top | mask: animation only where the skin is not transparent | tint: animation x skin colours\n"..
        "mode=auto         # gif only. atlas: the gif has the skin layout (8x3 blocks), cell: the whole gif in every block, auto: by its proportions\n")
    say("Template saved: "..saveDir().."/"..out.."  (240x90: 8x3 blocks of 30x30). Edit it, save as skins/<name>.png and press Reload. See skins/_animation_example.txt for animations.")
end


----------------------------------------------------------------- animated skins (two layers)
-- layer 1 (below): an animation - a GIF with the same name as the skin, or a built-in gradient
-- layer 2 (above): the skin picture itself (its transparent parts show the animation)
-- settings in skins/<name>.txt (all optional):  anim=rainbow|ocean|fire|aurora|gif   fps=20   speed=1
--   blend=over|mask|tint   mode=auto|atlas|cell
--   over: the skin lies on top of the animation   mask: the animation shows only where the skin is not transparent
--   tint: the animation is multiplied by the skin colours (lines of the skin shimmer)
--   atlas: the GIF has the layout of the skin (8x3 cells), cell: the whole GIF is shown in every block
local PRESET={rainbow=1,ocean=2,fire=3,aurora=4}
local BLEND={over=0,mask=1,tint=2}
local SHADER_SRC=[[
uniform Image anim;
uniform float time;
uniform float preset;
uniform float blendMode;
uniform float atlasMode;
vec3 hsv2rgb(vec3 c){
    vec4 K=vec4(1.0,2.0/3.0,1.0/3.0,3.0);
    vec3 p=abs(fract(c.xxx+K.xyz)*6.0-K.www);
    return c.z*mix(K.xxx,clamp(p-K.xxx,0.0,1.0),c.y);
}
vec3 procedural(vec2 l,float t){
    float d=(l.x+l.y)*0.5;
    if(preset<1.5){
        return hsv2rgb(vec3(fract(d+t*0.25),0.75,1.0));
    }
    if(preset<2.5){
        float w=0.5+0.5*sin(6.2831*(d*1.2+t*0.3));
        return mix(vec3(0.0,0.25,0.8),vec3(0.2,0.95,0.95),w);
    }
    if(preset<3.5){
        float w=0.5+0.5*sin(6.2831*(l.y*0.8+d*0.6-t*0.5));
        return mix(vec3(0.8,0.05,0.0),vec3(1.0,0.85,0.2),w);
    }
    float w2=0.5+0.5*sin(6.2831*(l.x*0.7-l.y*0.5+t*0.2));
    return mix(vec3(0.1,0.9,0.5),vec3(0.6,0.2,0.95),w2);
}
vec4 effect(vec4 color,Image tex,vec2 uv,vec2 sc){
    vec4 s=Texel(tex,uv);
    vec2 l=fract(uv*vec2(8.0,3.0));
    float cellIdx=floor(uv.x*8.0)+8.0*floor(uv.y*3.0);
    vec4 a;
    if(preset>0.5){
        a=vec4(procedural(l,time+cellIdx*0.083),1.0);
    }else if(atlasMode>0.5){
        a=Texel(anim,uv);
    }else{
        a=Texel(anim,l);
    }
    if(blendMode<0.5){
        float al=s.a+a.a*(1.0-s.a);
        vec3 rgb=(s.rgb*s.a+a.rgb*a.a*(1.0-s.a))/max(al,0.0001);
        return vec4(rgb,al);
    }
    if(blendMode<1.5){
        return vec4(a.rgb,a.a*s.a);
    }
    return vec4(a.rgb*s.rgb,s.a);
}
]]
local anims={}                 -- skin name -> animation record
local shader,shaderFailed
local function getShader()
    if shader or shaderFailed then return shader end
    local ok,res=pcall(love.graphics.newShader,SHADER_SRC)
    if ok then shader=res
    else
        shaderFailed=true
        say("Skin animation off: shader error "..tostring(res):gsub("%s+"," "):sub(1,70))
    end
    return shader
end

local function readConfig(base)
    local cfg={fps=20,speed=1,blend='over',mode='auto'}
    local txt=fs.getInfo(base..'.txt') and fs.read(base..'.txt')
    if type(txt)=='string' then
        for k,v in (txt.."\n"):gmatch('(%w+)%s*=%s*([^\r\n]*)') do
            v=v:gsub('^%s+',''):gsub('%s+$',''):lower()
            if k=='anim' then cfg.anim=v
            elseif k=='fps' then cfg.fps=math.max(1,math.min(60,tonumber(v) or 20))
            elseif k=='speed' then cfg.speed=tonumber(v) or 1
            elseif k=='blend' and BLEND[v] then cfg.blend=v
            elseif k=='mode' then cfg.mode=v end
        end
    end
    return cfg
end

function registerAnimation(name,pngPath,atlasImage)
    local base=pngPath:gsub('%.%w+$','')
    local cfg=readConfig(base)
    local hasGif=fs.getInfo(base..'.gif')
    local preset=PRESET[cfg.anim or '']
    if not preset and not hasGif then anims[name]=nil return end
    local A={atlas=atlasImage,preset=preset or 0,blend=BLEND[cfg.blend],fps=cfg.fps,speed=cfg.speed,time=0,acc=0}
    if not preset and hasGif then
        local nextFrame,w,h=GIF.open(fs.read(base..'.gif'))
        if not nextFrame then say("Cannot read "..stem(base)..".gif") anims[name]=nil return end
        A.gif={next=nextFrame,w=w,h=h,frames={},delays={},fi=1,t=0,done=false,limit=math.max(2,math.floor(30000000/(w*h)))}
        A.atlasMode=(cfg.mode=='atlas') or (cfg.mode~='cell' and math.abs(w/h-8/3)<0.06)
    end
    anims[name]=A
    return A
end

local function decodeGif(G,budget)
    if G.done then return end
    local t0=os.clock()
    repeat
        local f=G.next()
        if not f then G.done=true return end
        local okd,idata=pcall(love.image.newImageData,G.w,G.h,'rgba8',f.rgba)
        if okd then
            local gc=love.graphics
            gc.setDefaultFilter('linear','linear')
            local oki,img=pcall(gc.newImage,idata)
            gc.setDefaultFilter('nearest','nearest')
            if oki then G.frames[#G.frames+1]=img G.delays[#G.delays+1]=f.delay end
        end
        if #G.frames>=G.limit then G.done=true return end
    until os.clock()-t0>budget
end

local function renderAnimation(A,name)
    local sh=getShader()
    if not sh then return end
    local lib,mini=SKIN.lib[name],SKIN.libMini[name]
    if not (lib and mini) then return end
    local gc=love.graphics
    local function send(k,v) pcall(sh.send,sh,k,v) end
    send('time',A.time)
    send('preset',A.preset)
    send('blendMode',A.blend)
    send('atlasMode',A.atlasMode and 1 or 0)
    if A.gif then
        local img=A.gif.frames[A.gif.fi]
        if not img then return end
        send('anim',img)
    end
    local ok=pcall(function()
        gc.push()
        gc.origin()
        gc.setShader(sh)
        gc.setBlendMode('replace')
        gc.setColor(1,1,1)
        for y=0,2 do
            for x=1,8 do
                local i=8*y+x
                if lib[i] then gc.setCanvas(lib[i]) gc.clear(0,0,0,0) gc.draw(A.atlas,30-30*x,-30*y) end
                if mini[i] then gc.setCanvas(mini[i]) gc.clear(0,0,0,0) gc.draw(A.atlas,6-6*x,-6*y,nil,.2) end
            end
        end
    end)
    pcall(gc.setCanvas)
    pcall(gc.setShader)
    pcall(gc.setBlendMode,'alpha')
    pcall(gc.pop)
    if not ok then A.failed=(A.failed or 0)+1 if A.failed>3 then anims[name]=nil say("Skin animation stopped") end end
end

local function tickAnimation(dt)
    local name=SETTING.skinSet
    local A=name and anims[name]
    if not A then return end
    A.time=A.time+dt*A.speed
    if A.gif then
        local G=A.gif
        decodeGif(G,0.004)
        if #G.frames>1 then
            G.t=G.t+dt*A.speed
            while G.t>=G.delays[G.fi] do
                G.t=G.t-G.delays[G.fi]
                G.fi=G.fi%#G.frames+1
            end
        end
    end
    A.acc=A.acc+dt
    if A.acc<1/A.fps-0.0005 then return end
    A.acc=0
    renderAnimation(A,name)
end
-- The game removes love.update and runs its own loop; BG.update(dt) is called there every frame.
do
    local oldBG=BG and BG.update
    if oldBG then
        function BG.update(dt,...)
            oldBG(dt,...)
            local ok,err=pcall(tickAnimation,dt)
            if not ok then anims[SETTING.skinSet]=nil say("Skin animation error: "..tostring(err):gsub("%s+"," "):sub(1,70)) end
        end
    else
        say("Skin animation unavailable in this game version")
    end
end

----------------------------------------------------------------- sound packs
local packs={'Off'}
local current=false
local applying=false
local origLoad=SFX.load

local function vanillaNames()
    local t={}
    for _,f in ipairs(fs.getDirectoryItems('media/effect/'..SETTING.sfxPack..'/')) do
        if f:match('%.ogg$') then t[#t+1]=f end
    end
    return t
end

local function quiet(f)
    local m,l=MES.new,LOG
    MES.new=function(t,s,...) if type(s)=='string' and s:find('SFX files missing',1,true) then return end return m(t,s,...) end
    if l then LOG=function() end end
    local ok,err=pcall(f)
    MES.new,LOG=m,l
    if not ok then error(err,0) end
end

local function scanPacks()
    pcall(fs.createDirectory,SFX_DIR)
    for i=#packs,1,-1 do packs[i]=nil end
    packs[1]='Off'
    local dirs=fs.getDirectoryItems(SFX_DIR)
    table.sort(dirs,function(a,b) return a:lower()<b:lower() end)
    for _,d in ipairs(dirs) do
        local info=fs.getInfo(SFX_DIR..'/'..d)
        if info and info.type=='directory' and d:sub(1,1)~='_' then packs[#packs+1]=d end
    end
    local found=false
    for _,p in ipairs(packs) do if p==current then found=true end end
    if not found then current=false end
end

local function applyPack(name,silent)
    current=(name and name~='Off') and name or false
    NOVA_SFX_PACK=current or nil                  -- the SFX Lab looks here for the file a sound really uses
    applying=true
    local ok,err=pcall(function()
        origLoad('media/effect/'..SETTING.sfxPack..'/')              -- the game's own sounds first (undoes an older pack)
        if current then quiet(function() origLoad(SFX_DIR..'/'..current..'/') end) end
    end)
    applying=false
    fs.write(STATE,"sfx="..(current or 'Off').."\n")
    if not ok then say("Sound pack failed: "..tostring(err):gsub("%s+"," "):sub(1,60)) return end
    if not silent then
        if current then
            local mine,n={},0
            for _,f in ipairs(fs.getDirectoryItems(SFX_DIR..'/'..current)) do mine[f]=true end
            for _,f in ipairs(vanillaNames()) do if mine[f] then n=n+1 end end
            say(("Custom SFX: %s  (%d sounds replaced)"):format(current,n))
        else
            say("Custom SFX off: the game's own sounds")
        end
    end
end

-- the game reloads its sounds when the sound pack is changed in the settings: put ours back on top
function SFX.load(path,...)
    local r=origLoad(path,...)
    if not applying and current and type(path)=='string' and path:sub(1,13)=='media/effect/' then
        applying=true
        pcall(quiet,function() origLoad(SFX_DIR..'/'..current..'/') end)
        applying=false
    end
    return r
end

local function exportSfxTemplate()
    pcall(fs.createDirectory,SFX_DIR..'/_template')
    local n=0
    for _,f in ipairs(vanillaNames()) do
        local data=fs.read('media/effect/'..SETTING.sfxPack..'/'..f)
        if data then fs.write(SFX_DIR..'/_template/'..f,data) n=n+1 end
    end
    say(("%d sounds saved to %s/%s/_template. Copy the folder, rename it, replace the sounds you like, then press Reload."):format(n,saveDir(),SFX_DIR))
end

----------------------------------------------------------------- interface
local function button(scene,name,x,y,w,h,font,text,code)
    local W=WIDGET.newButton{name=name,x=x,y=y,w=w,h=h,font=font,fText=text,code=code}
    W:setObject(W.fText)
    scene.widgetList[#scene.widgetList+1]=W
    return W
end

local skinScene=SCN.scenes.setting_skin
if skinScene and skinScene.widgetList then
    local function reloadSkins()
        -- skins that are already registered: take their picture, animation settings and GIF again
        for f,name in pairs(skinFiles) do
            local path=SKIN_DIR..'/'..f
            if fs.getInfo(path) then
                refillSkin(name,path)
                local gc=love.graphics
                gc.setDefaultFilter('nearest','nearest')
                local okA,atlas=pcall(gc.newImage,path)
                gc.setDefaultFilter('linear','linear')
                if okA then pcall(registerAnimation,name,path,atlas) end
            end
        end
        local added,rejected=scanSkins()
        local msg=("Custom skins: %d new (%d in the folder)"):format(added,(function() local c=0 for _ in pairs(skinFiles) do c=c+1 end return c end)())
        if #rejected>0 then msg=msg.."; skipped (need 240x90 PNG): "..table.concat(rejected,", "):sub(1,70) end
        say(msg)
        local sel=skinScene.widgetList.skinSet
        if sel and sel.reset then pcall(sel.reset,sel) end
    end
    button(skinScene,'novaSkinReload',1009,100,94,60,22,"Reload",reloadSkins)
    button(skinScene,'novaSkinTemplate',1111,100,94,60,22,"Template",exportSkinTemplate)
    button(skinScene,'novaSkinFolder',1213,100,94,60,22,"Folder",function() openFolder(SKIN_DIR) end)
end

local roomScene=SCN.scenes.launchpad
if roomScene and roomScene.widgetList then
    local sel=WIDGET.newSelector{name='novaSfxPack',x=1075,y=370,w=340,fText="Custom SFX",list=packs,
        disp=function() return current or 'Off' end,
        code=function(v) applyPack(v) end}
    sel.obj=love.graphics.newText(FONT.get(sel.font or 30),"Custom SFX")
    sel:reset()
    roomScene.widgetList[#roomScene.widgetList+1]=sel
    local function reloadPacks()
        scanPacks()
        pcall(sel.reset,sel)
        say(("Sound packs: %d found"):format(#packs-1))
    end
    button(roomScene,'novaSfxReload',959,450,108,44,22,"Reload",reloadPacks)
    button(roomScene,'novaSfxTemplate',1075,450,108,44,22,"Template",exportSfxTemplate)
    button(roomScene,'novaSfxFolder',1191,450,108,44,22,"Folder",function() openFolder(SFX_DIR) end)
end

----------------------------------------------------------------- start
do
    local txt=fs.getInfo(STATE) and fs.read(STATE)
    if type(txt)=='string' then
        local p=txt:match('sfx=([^\r\n]+)')
        if p and p~='Off' then current=p end
    end
    scanSkins()
    scanPacks()
    if current then applyPack(current,true) end
end

CUSTOMASSETS_LOADED=true
return "Custom skins/sfx loaded: Style Settings and SFX Room have the new buttons"
