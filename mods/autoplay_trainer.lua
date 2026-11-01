-- NOVA autoplay trainer for Techmino 0.17.21  (single file; the game files are NOT modified)
-- INSTALL (phone): copy this whole text, open the in-game console (tap the TECHMINO logo 4 times), then type:
--   su 7126
--   #return loadstring(love.system.getClipboardText())()
-- INSTALL (PC): put this file into the save folder (%appdata%\LOVE\Techmino), console: su 7126, then
--   #return love.filesystem.load('autoplay_trainer.lua')()
-- After the phone install it starts by itself every time you launch the game.
--   F6 on/off   ] faster   [ slower   \ cycle play style   (phone: buttons in the top-left corner)
local SHIM=[==[
-- CCloader.lua, written by the NOVA trainer: starts mod_manager.lua (which loads all mods; or the known mods directly when it is absent), then hands over
-- to the real Cold Clear loader if the game has one. Delete this file to turn auto-start off.
local name=...
NOVA_AUTOSTART=true
if not MODMANAGER_LOADED then
    local f=love.filesystem.load('mod_manager.lua')
    if f then pcall(f) end
end
if not MODMANAGER_LOADED then            -- no mod manager installed: start the known mods directly
    for _,m in ipairs{{'autoplay_trainer.lua','AUTOPLAY_TRAINER'},{'bg_switcher.lua','BGSWITCH_LOADED'},{'custom_music.lua','CUSTOMMUSIC_LOADED'}} do
        if not _G[m[2]] then
            local f=love.filesystem.load(m[1])
            if f then pcall(f) end
        end
    end
end
NOVA_AUTOSTART=nil
local loaders=package.loaders or package.searchers
for i=3,#loaders do
    local ok,ld=pcall(loaders[i],name)
    if ok and type(ld)=='function' then return ld(name) end
end
return false
]==]
if not NOVA_AUTOSTART then
    -- install only when this text was run from the clipboard (not when loaded from the saved file)
    local ok,src=pcall(function() return debug.getinfo(1,'S').source end)
    local c=ok and type(src)=='string' and src:sub(1,1) or '@'
    if c~='@' and c~='=' and #src>20000 and src:find('local FINESSE',1,true) then
        love.filesystem.write('autoplay_trainer.lua',src)
        love.filesystem.write('CCloader.lua',SHIM)
        if AUTOPLAY_TRAINER then return "NOVA installed/updated: restart the game to apply it" end
        NOVA_INSTALLED=true
    end
end
if AUTOPLAY_TRAINER then return "trainer already loaded" end
if love.filesystem.getInfo('parts/autoplay.lua') then
    return "this build already has built-in autoplay (F6); trainer not needed"
end
local FINESSE={[1]={[1]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=2,[8]=1},[2]={[1]=2,[2]=2,[3]=2,[4]=1,[5]=1,[6]=2,[7]=3,[8]=2,[9]=2},[3]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=2,[8]=1},[4]={[1]=2,[2]=2,[3]=2,[4]=1,[5]=1,[6]=2,[7]=3,[8]=2,[9]=2}},[10]={[1]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=2,[8]=1},[2]={[1]=2,[2]=2,[3]=3,[4]=2,[5]=1,[6]=2,[7]=3,[8]=3,[9]=2},[3]={[1]=3,[2]=4,[3]=3,[4]=2,[5]=3,[6]=4,[7]=4,[8]=3},[4]={[1]=2,[2]=3,[3]=2,[4]=1,[5]=2,[6]=3,[7]=3,[8]=2,[9]=2}},[11]={[1]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=2,[8]=1},[2]={[1]=2,[2]=2,[3]=3,[4]=2,[5]=1,[6]=2,[7]=3,[8]=3,[9]=2},[3]={[1]=3,[2]=4,[3]=3,[4]=2,[5]=3,[6]=4,[7]=4,[8]=3},[4]={[1]=2,[2]=3,[3]=2,[4]=1,[5]=2,[6]=3,[7]=3,[8]=2,[9]=2}},[12]={[1]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=2,[8]=1},[2]={[1]=2,[2]=3,[3]=2,[4]=1,[5]=2,[6]=3,[7]=3,[8]=2},[3]={[1]=3,[2]=4,[3]=3,[4]=2,[5]=3,[6]=4,[7]=4,[8]=3},[4]={[1]=2,[2]=3,[3]=2,[4]=1,[5]=2,[6]=3,[7]=3,[8]=2}},[13]={[1]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=2,[8]=1},[2]={[1]=2,[2]=3,[3]=2,[4]=1,[5]=2,[6]=3,[7]=3,[8]=2},[3]={[1]=3,[2]=4,[3]=3,[4]=2,[5]=3,[6]=4,[7]=4,[8]=3},[4]={[1]=2,[2]=3,[3]=2,[4]=1,[5]=2,[6]=3,[7]=3,[8]=2}},[14]={[1]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=2,[8]=1},[2]={[1]=2,[2]=3,[3]=2,[4]=1,[5]=2,[6]=3,[7]=3,[8]=2},[3]={[1]=3,[2]=4,[3]=3,[4]=2,[5]=3,[6]=4,[7]=4,[8]=3},[4]={[1]=2,[2]=3,[3]=2,[4]=1,[5]=2,[6]=3,[7]=3,[8]=2}},[15]={[1]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=2,[8]=1},[2]={[1]=2,[2]=2,[3]=3,[4]=2,[5]=1,[6]=2,[7]=3,[8]=3,[9]=2},[3]={[1]=3,[2]=4,[3]=3,[4]=2,[5]=3,[6]=4,[7]=4,[8]=3},[4]={[1]=2,[2]=3,[3]=2,[4]=1,[5]=2,[6]=3,[7]=3,[8]=2,[9]=2}},[16]={[1]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=2,[8]=1},[2]={[1]=2,[2]=3,[3]=3,[4]=2,[5]=1,[6]=2,[7]=3,[8]=2},[3]={[1]=3,[2]=4,[3]=4,[4]=3,[5]=2,[6]=3,[7]=4,[8]=3},[4]={[1]=2,[2]=3,[3]=2,[4]=1,[5]=2,[6]=3,[7]=3,[8]=2}},[17]={[1]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=2,[8]=1},[2]={[1]=2,[2]=3,[3]=2,[4]=1,[5]=2,[6]=3,[7]=3,[8]=2},[3]={[1]=3,[2]=4,[3]=3,[4]=2,[5]=3,[6]=4,[7]=4,[8]=3},[4]={[1]=2,[2]=3,[3]=2,[4]=1,[5]=2,[6]=3,[7]=3,[8]=2}},[18]={[1]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=2,[8]=1},[2]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=2,[8]=1},[3]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=2,[8]=1},[4]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=2,[8]=1}},[19]={[1]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=1},[2]={[1]=2,[2]=2,[3]=3,[4]=2,[5]=1,[6]=2,[7]=3,[8]=2,[9]=2},[3]={[1]=3,[2]=4,[3]=3,[4]=2,[5]=3,[6]=4,[7]=3},[4]={[1]=2,[2]=2,[3]=3,[4]=2,[5]=1,[6]=2,[7]=3,[8]=2,[9]=2}},[2]={[1]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=2,[8]=1},[2]={[1]=2,[2]=2,[3]=2,[4]=1,[5]=1,[6]=2,[7]=3,[8]=2,[9]=2},[3]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=2,[8]=1},[4]={[1]=2,[2]=2,[3]=2,[4]=1,[5]=1,[6]=2,[7]=3,[8]=2,[9]=2}},[20]={[1]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=1},[2]={[1]=2,[2]=2,[3]=3,[4]=2,[5]=1,[6]=2,[7]=3,[8]=2,[9]=2},[3]={[1]=3,[2]=4,[3]=3,[4]=2,[5]=3,[6]=4,[7]=3},[4]={[1]=2,[2]=2,[3]=3,[4]=2,[5]=1,[6]=2,[7]=3,[8]=2,[9]=2}},[21]={[1]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=1},[2]={[1]=2,[2]=2,[3]=3,[4]=2,[5]=1,[6]=2,[7]=3,[8]=2,[9]=2},[3]={[1]=3,[2]=4,[3]=3,[4]=2,[5]=3,[6]=4,[7]=3},[4]={[1]=2,[2]=2,[3]=3,[4]=2,[5]=1,[6]=2,[7]=3,[8]=2,[9]=2}},[22]={[1]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=1},[2]={[1]=2,[2]=2,[3]=3,[4]=2,[5]=1,[6]=2,[7]=3,[8]=2,[9]=2},[3]={[1]=3,[2]=4,[3]=3,[4]=2,[5]=3,[6]=4,[7]=3},[4]={[1]=2,[2]=2,[3]=3,[4]=2,[5]=1,[6]=2,[7]=3,[8]=2,[9]=2}},[23]={[1]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=1},[2]={[1]=2,[2]=2,[3]=3,[4]=2,[5]=1,[6]=2,[7]=3,[8]=2,[9]=2},[3]={[1]=3,[2]=4,[3]=3,[4]=2,[5]=3,[6]=4,[7]=3},[4]={[1]=2,[2]=2,[3]=3,[4]=2,[5]=1,[6]=2,[7]=3,[8]=2,[9]=2}},[24]={[1]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=1},[2]={[1]=2,[2]=2,[3]=3,[4]=2,[5]=1,[6]=2,[7]=3,[8]=2,[9]=2},[3]={[1]=3,[2]=4,[3]=3,[4]=2,[5]=3,[6]=4,[7]=3},[4]={[1]=2,[2]=2,[3]=3,[4]=2,[5]=1,[6]=2,[7]=3,[8]=2,[9]=2}},[25]={[1]={[1]=1,[2]=1,[3]=0,[4]=1,[5]=2,[6]=1},[2]={[1]=2,[10]=2,[2]=3,[3]=2,[4]=2,[5]=1,[6]=2,[7]=3,[8]=2,[9]=3},[3]={[1]=1,[2]=1,[3]=0,[4]=1,[5]=2,[6]=1},[4]={[1]=2,[10]=2,[2]=3,[3]=2,[4]=2,[5]=1,[6]=2,[7]=3,[8]=2,[9]=3}},[26]={[1]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=2,[8]=1},[2]={[1]=2,[10]=2,[2]=2,[3]=3,[4]=2,[5]=1,[6]=2,[7]=3,[8]=3,[9]=2},[3]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=2,[8]=1},[4]={[1]=2,[10]=2,[2]=2,[3]=3,[4]=2,[5]=1,[6]=2,[7]=3,[8]=3,[9]=2}},[27]={[1]={[1]=1,[2]=2,[3]=2,[4]=1,[5]=0,[6]=1,[7]=2,[8]=2,[9]=1},[2]={[1]=2,[2]=3,[3]=3,[4]=2,[5]=1,[6]=2,[7]=3,[8]=3,[9]=2},[3]={[1]=3,[2]=4,[3]=4,[4]=3,[5]=2,[6]=3,[7]=4,[8]=4,[9]=3},[4]={[1]=2,[2]=3,[3]=3,[4]=2,[5]=1,[6]=2,[7]=3,[8]=3,[9]=2}},[28]={[1]={[1]=1,[2]=2,[3]=2,[4]=1,[5]=0,[6]=1,[7]=2,[8]=2,[9]=1},[2]={[1]=2,[10]=2,[2]=2,[3]=3,[4]=2,[5]=1,[6]=1,[7]=2,[8]=3,[9]=2},[3]={[1]=1,[2]=2,[3]=2,[4]=1,[5]=0,[6]=1,[7]=2,[8]=2,[9]=1},[4]={[1]=2,[10]=2,[2]=2,[3]=3,[4]=2,[5]=1,[6]=1,[7]=2,[8]=3,[9]=2}},[29]={[1]={[1]=1,[10]=1,[2]=2,[3]=2,[4]=1,[5]=0,[6]=1,[7]=2,[8]=3,[9]=2},[2]={[1]=1,[10]=1,[2]=2,[3]=2,[4]=1,[5]=0,[6]=1,[7]=2,[8]=3,[9]=2},[3]={[1]=1,[10]=1,[2]=2,[3]=2,[4]=1,[5]=0,[6]=1,[7]=2,[8]=3,[9]=2},[4]={[1]=1,[10]=1,[2]=2,[3]=2,[4]=1,[5]=0,[6]=1,[7]=2,[8]=3,[9]=2}},[3]={[1]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=2,[8]=1},[2]={[1]=2,[2]=2,[3]=3,[4]=2,[5]=1,[6]=2,[7]=3,[8]=3,[9]=2},[3]={[1]=3,[2]=4,[3]=3,[4]=2,[5]=3,[6]=4,[7]=4,[8]=3},[4]={[1]=2,[2]=3,[3]=2,[4]=1,[5]=2,[6]=3,[7]=3,[8]=2,[9]=2}},[4]={[1]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=2,[8]=1},[2]={[1]=2,[2]=2,[3]=3,[4]=2,[5]=1,[6]=2,[7]=3,[8]=3,[9]=2},[3]={[1]=3,[2]=4,[3]=3,[4]=2,[5]=3,[6]=4,[7]=4,[8]=3},[4]={[1]=2,[2]=3,[3]=2,[4]=1,[5]=2,[6]=3,[7]=3,[8]=2,[9]=2}},[5]={[1]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=2,[8]=1},[2]={[1]=2,[2]=2,[3]=3,[4]=2,[5]=1,[6]=2,[7]=3,[8]=3,[9]=2},[3]={[1]=3,[2]=4,[3]=3,[4]=2,[5]=3,[6]=4,[7]=4,[8]=3},[4]={[1]=2,[2]=3,[3]=2,[4]=1,[5]=2,[6]=3,[7]=3,[8]=2,[9]=2}},[6]={[1]={[1]=1,[2]=2,[3]=2,[4]=1,[5]=0,[6]=1,[7]=2,[8]=2,[9]=1},[2]={[1]=1,[2]=2,[3]=2,[4]=1,[5]=0,[6]=1,[7]=2,[8]=2,[9]=1},[3]={[1]=1,[2]=2,[3]=2,[4]=1,[5]=0,[6]=1,[7]=2,[8]=2,[9]=1},[4]={[1]=1,[2]=2,[3]=2,[4]=1,[5]=0,[6]=1,[7]=2,[8]=2,[9]=1}},[7]={[1]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=1},[2]={[1]=2,[10]=2,[2]=2,[3]=2,[4]=2,[5]=1,[6]=1,[7]=2,[8]=2,[9]=2},[3]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=1},[4]={[1]=2,[10]=2,[2]=2,[3]=2,[4]=2,[5]=1,[6]=1,[7]=2,[8]=2,[9]=2}},[8]={[1]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=2,[8]=1},[2]={[1]=2,[2]=3,[3]=2,[4]=1,[5]=2,[6]=3,[7]=3,[8]=2},[3]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=2,[8]=1},[4]={[1]=2,[2]=3,[3]=2,[4]=1,[5]=2,[6]=3,[7]=3,[8]=2}},[9]={[1]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=2,[8]=1},[2]={[1]=2,[2]=3,[3]=2,[4]=1,[5]=2,[6]=3,[7]=3,[8]=2},[3]={[1]=1,[2]=2,[3]=1,[4]=0,[5]=1,[6]=2,[7]=2,[8]=1},[4]={[1]=2,[2]=3,[3]=2,[4]=1,[5]=2,[6]=3,[7]=3,[8]=2}}}

local Nova=(function()
local Nova={}

local floor,ceil,max,min=math.floor,math.ceil,math.max,math.min
local unpack=table.unpack or unpack

local function overlap(field,bk,x,y)
    local C=#bk[1]
    if x<1 or x+C>11 or y<1 then return true end
    if y>#field then return false end
    for i=1,#bk do
        local row=field[y+i-1]
        if row then
            local b=bk[i]
            for j=1,C do
                if b[j] and row[x+j-1]>0 then return true end
            end
        end
    end
    return false
end
Nova.overlap=overlap

local function solid(field,x,y)
    if x<1 or x>10 or y<1 then return true end
    local row=field[y]
    if not row then return false end
    return row[x]>0
end

local function landY(field,bk,x,y)
    while not overlap(field,bk,x,y-1) do y=y-1 end
    return y
end

local function trunc(v) return v>=0 and floor(v) or ceil(v) end

function Nova.spawnPos(env,id)
    local bk=env.BLOCKS[id][0]
    local sc=env.RS.centerPos[id][0]
    return floor(6-#bk[1]*.5),floor(env.fieldH+1-trunc(sc[1]))
end

local function rotate(env,field,id,dir,x,y,d)
    local kt=env.RS.kickTable[id]
    if type(kt)~='table' then return nil end
    local idir=(dir+d)%4
    local kd=kt[dir*10+idir]
    if not kd then return nil end
    local BL=env.BLOCKS[id]
    local cp=env.RS.centerPos[id]
    local sc,isc=cp[dir],cp[idir]
    local icb=BL[idir]
    local bx,by=x+sc[2]-isc[2],y+sc[1]-isc[1]
    for t=1,#kd do
        local ix,iy=bx+kd[t][1],by+kd[t][2]
        if not overlap(field,icb,ix,iy) then
            return idir,ix,iy,(t==2) and 0 or 1
        end
    end
    return nil
end

local sigCache={}
local function dirSignature(bk)
    local t={}
    for i=1,#bk do
        for j=1,#bk[1] do t[#t+1]=bk[i][j] and '1' or '0' end
        t[#t+1]='/'
    end
    return table.concat(t)
end
local function distinctDirs(env,id)
    local c=sigCache[env.BLOCKS]
    if not c then c={} sigCache[env.BLOCKS]=c end
    if c[id] then return c[id] end
    local out,seen={},{}
    for dir=0,3 do
        local s=dirSignature(env.BLOCKS[id][dir])
        if not seen[s] then seen[s]=true out[#out+1]=dir end
    end
    c[id]=out
    return out
end

local function skey(x,y,dir,f) return ((y*12+x)*4+dir)*3+f end

local function heapPush(H,c,k)
    local n=#H.c+1
    H.c[n],H.k[n]=c,k
    while n>1 do
        local p=floor(n/2)
        if H.c[p]>H.c[n] then
            H.c[p],H.c[n]=H.c[n],H.c[p]
            H.k[p],H.k[n]=H.k[n],H.k[p]
            n=p
        else break end
    end
end
local function heapPop(H)
    local n=#H.c
    if n==0 then return nil end
    local c,k=H.c[1],H.k[1]
    H.c[1],H.k[1]=H.c[n],H.k[n]
    H.c[n],H.k[n]=nil,nil
    n=n-1
    local i=1
    while true do
        local l,r,m=i*2,i*2+1,i
        if l<=n and H.c[l]<H.c[m] then m=l end
        if r<=n and H.c[r]<H.c[m] then m=r end
        if m==i then break end
        H.c[m],H.c[i]=H.c[i],H.c[m]
        H.k[m],H.k[i]=H.k[i],H.k[m]
        i=m
    end
    return c,k
end

local function decode(k)
    local f=k%3; k=(k-f)/3
    local dir=k%4; k=(k-dir)/4
    local x=k%12; local y=(k-x)/12
    return x,y,dir,f
end

function Nova.reach(env,field,id,dir0,x0,y0,f0)
    local BL=env.BLOCKS[id]
    local g20=env.g20
    local keyIns=env.keyIns
    local dist,prev,pkey={},{},{}
    local H={c={},k={}}
    local start
    do
        local y=y0
        if g20 then y=landY(field,BL[dir0],x0,y0) end
        start=skey(x0,y,dir0,f0 or 0)
    end
    dist[start]=0
    heapPush(H,0,start)
    local finals,finalBy={},{}
    local rot180=type(env.RS.kickTable[id])=='table' and not env.no180

    local yCap=max(env.fieldH+6,y0+2)
    local function relax(nk,nc,from,key)
        if nc>1400 then return end                 -- at most ~14 control presses
        if floor(floor(nk/3)/48)>yCap then return end  -- piece flew above the field
        local d=dist[nk]
        if not d or nc<d then
            dist[nk]=nc
            prev[nk]=from
            pkey[nk]=key
            heapPush(H,nc,nk)
        end
    end

    while true do
        local c,k=heapPop(H)
        if not c then break end
        if c==dist[k] then
            local x,y,dir,f=decode(k)
            local bk=BL[dir]
            do
                local ly=landY(field,bk,x,y)
                local sp=(ly==y) and f or 0
                local fk=skey(x,ly,dir,sp)
                local cur=finalBy[fk]
                if not cur or c<cur.cost then
                    local rec={x=x,y=ly,dir=dir,spin=sp,ctrl=floor(c/100),cost=c,from=k}
                    finalBy[fk]=rec
                end
            end
            if not overlap(field,bk,x-1,y) then
                local ny=g20 and landY(field,bk,x-1,y) or y
                relax(skey(x-1,ny,dir,0),c+101,k,1)
            end
            if not overlap(field,bk,x+1,y) then
                local ny=g20 and landY(field,bk,x+1,y) or y
                relax(skey(x+1,ny,dir,0),c+101,k,2)
            end
            if keyIns then
                local nx=x
                while not overlap(field,bk,nx-1,y) do nx=nx-1 end
                if nx~=x then relax(skey(nx,y,dir,0),c+101,k,11) end
                nx=x
                while not overlap(field,bk,nx+1,y) do nx=nx+1 end
                if nx~=x then relax(skey(nx,y,dir,0),c+101,k,12) end
            end
            do
                local nd,nx,ny,sl=rotate(env,field,id,dir,x,y,1)
                if nd then
                    if g20 then local ly=landY(field,BL[nd],nx,ny) if ly~=ny then ny=ly sl=nil end end
                    relax(skey(nx,ny,nd,sl and (sl==0 and 1 or 2) or 0),c+101,k,3)
                end
                nd,nx,ny,sl=rotate(env,field,id,dir,x,y,3)
                if nd then
                    if g20 then local ly=landY(field,BL[nd],nx,ny) if ly~=ny then ny=ly sl=nil end end
                    relax(skey(nx,ny,nd,sl and (sl==0 and 1 or 2) or 0),c+101,k,4)
                end
                if rot180 then
                    nd,nx,ny,sl=rotate(env,field,id,dir,x,y,2)
                    if nd then
                        if g20 then local ly=landY(field,BL[nd],nx,ny) if ly~=ny then ny=ly sl=nil end end
                        relax(skey(nx,ny,nd,sl and (sl==0 and 1 or 2) or 0),c+201,k,5)
                    end
                end
            end
            if not g20 and not env.noSoft then
                local ly=landY(field,bk,x,y)
                if ly<y then
                    relax(skey(x,ly,dir,0),c+1,k,13)
                    if y-1>ly then relax(skey(x,y-1,dir,0),c+1,k,14) end
                end
            end
        end
    end
    return {dist=dist,prev=prev,pkey=pkey,finals=finalBy,start=start,env=env,id=id}
end

function Nova.pathKeys(S,rec)
    local keys={6}
    local k=rec.from
    while k~=S.start do
        table.insert(keys,1,S.pkey[k])
        k=S.prev[k]
    end
    return keys
end

local function placeAndClear(env,field,id,dir,x,y,spinCode)
    local bk=env.BLOCKS[id][dir]
    local sl=(spinCode==1 and 0) or (spinCode==2 and 1) or nil
    local sc=env.RS.centerPos[id][dir]
    local dospin=0
    if sl then
        if id<6 then
            local cx,cy=x+sc[2],y+sc[1]
            local c=0
            if solid(field,cx-1,cy+1) then c=c+1 end
            if solid(field,cx+1,cy+1) then c=c+1 end
            if c~=0 then
                if solid(field,cx-1,cy-1) then c=c+1 end
                if solid(field,cx+1,cy-1) then c=c+1 end
                if c>2 then dospin=dospin+2 end
            end
        end
    end
    if overlap(field,bk,x,y+1) and overlap(field,bk,x-1,y) and overlap(field,bk,x+1,y) then
        dospin=dospin+2
    end
    local roofed=false
    if y>env.fieldH-2 then roofed=true
    else
        for i=1,#bk[1] do
            local top=#bk
            while not bk[top][i] do top=top-1 end
            local tx=x+i-1
            for ty=y+top,#field do
                if solid(field,tx,ty) then roofed=true break end
            end
            if roofed then break end
        end
    end
    local n=max(#field,y+#bk-1)
    local nf={}
    for r=1,n do
        local row=field[r]
        if row then nf[r]={unpack(row)} else nf[r]={0,0,0,0,0,0,0,0,0,0} end
    end
    local cells=0
    local lowRow,highRow=y,y+#bk-1
    for i=1,#bk do
        for j=1,#bk[1] do
            if bk[i][j] then nf[y+i-1][x+j-1]=id cells=cells+1 end
        end
    end
    local cleared=0
    local erodedCells=0
    local r=highRow
    while r>=lowRow do
        local row=nf[r]
        local full=true
        for j=1,10 do if row[j]<=0 then full=false break end end
        if full then
            local i=r-y+1
            if i>=1 and i<=#bk then
                for j=1,#bk[1] do if bk[i][j] then erodedCells=erodedCells+1 end end
            end
            table.remove(nf,r)
            cleared=cleared+1
        end
        r=r-1
    end
    while #nf>0 do
        local row=nf[#nf]
        local empty=true
        for j=1,10 do if row[j]>0 then empty=false break end end
        if empty then nf[#nf]=nil else break end
    end
    local spinKind=0
    if dospin>0 then
        if cleared>0 then
            local ds=dospin+(sl or 0)
            spinKind=2
            if ds<3 and id<6 and cleared<#bk then spinKind=1 end
        else
            spinKind=0
        end
    end
    return {field=nf,cleared=cleared,spin=spinKind,roofed=roofed,eroded=erodedCells,
            landing=y+(#bk-1)/2,spinFlag=dospin>0}
end
Nova.placeAndClear=placeAndClear

local B2B_ATK={3,5,8,12,18,26}
local B2B_PT={50,100,180,800,1000,9999}
local function attackExact(cc,spinKind,b2b,cmb,pc,pcCount)
    if cc<=0 then return 0,b2b end
    local atk,special,nb=0,false,b2b
    if spinKind>0 then
        special=true
        local k=min(cc,6)
        if b2b>800 then atk=B2B_ATK[k]+cc*.5
        elseif b2b>=50 then atk=B2B_ATK[k]
        else atk=2*cc end
        local pt=B2B_PT[k]
        if spinKind==1 then atk=atk*.25 nb=nb+pt*.5 else nb=nb+pt end
    elseif cc>=4 then
        special=true
        if b2b>800 then atk=4*cc-10
        elseif b2b>=50 then atk=3*cc-7
        else atk=2*cc-4 end
        nb=nb+cc*50-50
    else
        atk=cc-.5
    end
    if cmb>1 then
        atk=atk*(1+(cc==1 and .15 or .25)*min(cmb-1,12))
        if cmb>=3 then atk=atk+1 end
    end
    if pc then
        atk=max(atk,min(8+(pcCount or 0)*2,16))
        nb=nb+800
        special=true
    end
    if not special then nb=max(nb-250,0) end
    if nb>1000 then nb=1000 end
    return floor(atk),nb
end
Nova.attackExact=attackExact

local function features(nf)
    local rows=#nf
    local h={}
    for x=1,10 do
        local top=0
        for y=rows,1,-1 do
            if nf[y][x]>0 then top=y break end
        end
        h[x]=top
    end
    local maxh=0
    for x=1,10 do if h[x]>maxh then maxh=h[x] end end
    local holes,holeDepth=0,0
    local colTrans=0
    for x=1,10 do
        local prev=true
        local hx=h[x]
        local filledAbove=0
        for y=1,hx do
            local cur=nf[y][x]>0
            if cur~=prev then colTrans=colTrans+1 end
            if not cur then holes=holes+1 end
            prev=cur
        end
        if hx>0 and prev then colTrans=colTrans+1 end
        if hx==0 then colTrans=colTrans+0 end
    end
    for x=1,10 do
        local seenHole=false
        for y=1,h[x] do
            if nf[y][x]<=0 then seenHole=true end
        end
        if seenHole then
            local cnt=0
            local lowestHole
            for y=1,h[x] do if nf[y][x]<=0 then lowestHole=y break end end
            for y=lowestHole,h[x] do if nf[y][x]>0 then cnt=cnt+1 end end
            holeDepth=holeDepth+cnt
        end
    end
    local rowTrans=0
    for y=1,maxh do
        local prev=true
        local row=nf[y]
        for x=1,10 do
            local cur=row[x]>0
            if cur~=prev then rowTrans=rowTrans+1 end
            prev=cur
        end
        if not prev then rowTrans=rowTrans+1 end
    end
    local wells=0
    for x=1,10 do
        local l=(x==1) and 99 or h[x-1]
        local r=(x==10) and 99 or h[x+1]
        local d=min(l,r)-h[x]
        if d>0 then wells=wells+d*(d+1)/2 end
    end
    local bump=0
    for x=1,9 do bump=bump+math.abs(h[x]-h[x+1]) end
    local aggH=0
    for x=1,10 do aggH=aggH+h[x] end
    return {h=h,aggH=aggH,maxh=maxh,holes=holes,holeDepth=holeDepth,colTrans=colTrans,
            rowTrans=rowTrans,wells=wells,bump=bump,rows=rows}
end
Nova.features=features

local function newStyle(t)
    local base={
        landing=-4.5, eroded=3.4, rowTrans=-3.2, colTrans=-9.3, holes=-7.9, wells=-3.4,
        holeDepth=-0.8, bump=-0.1, aggH=0,
        danger=-14,      -- per row above the danger line
        atk=1.0,         -- per attack line
        spin=0,          -- bonus for a spin clear (scaled by lines)
        b2bVal=1.5,      -- value of 100 b2b points
        combo=0.6, comboBreak=0.3,
        cancel=1.5,      -- per incoming garbage line cancelled
        incoming=-1.0,   -- per incoming garbage line when we don't clear
        pc=30,
        spinPot=1.0,     -- bonus for setups that let an upcoming piece spin-clear
        slot=0,          -- bonus for a T-spin-ready stack (0..1 scan)
        well=0,          -- bonus per row ready for an I-piece clear (tetromino sets)
        smallClear=0,    -- penalty per line of a small (<4 lines, no spin) clear: saves rows for big clears
        deep=false,      -- use the deep beam search
        fine=-14,        -- per predicted finesse fault
        dangerLine=0.55, -- fraction of fieldH
    }
    for k,v in pairs(t or {}) do base[k]=v end
    return base
end

Nova.STYLES={
    balanced=newStyle{spinPot=1.2,atk=2.5,spin=2,b2bVal=2.0,combo=1.0},
    defender=newStyle{spinPot=0.2,holes=-10,colTrans=-10,landing=-5,danger=-20,dangerLine=.45,
        atk=1.5,cancel=3.0,incoming=-2.0,spin=0.5,b2bVal=0.8,combo=0.6},
    attacker=newStyle{deep=true,slot=3,well=12,spinPot=1.0,eroded=0,landing=-1,wells=0,
        atk=6.0,spin=4,b2bVal=4.0,combo=0.5,comboBreak=0.5,smallClear=4,cancel=1.5,
        dangerLine=.62},
    spinner=newStyle{deep=true,slot=25,well=8,spin=8,atk=6.0,b2bVal=5.0,combo=0.5,comboBreak=0.5,
        smallClear=4,cancel=2.0,eroded=0,landing=-1,holes=-3,holeDepth=-0.4,colTrans=-3.5,
        rowTrans=-1.8,wells=0,dangerLine=.6,spinPot=1.0},
    combo=newStyle{spinPot=0.4,holes=-6,landing=-3,eroded=4.2,combo=4.0,comboBreak=2.0,atk=3.0,
        spin=1,b2bVal=1.0,dangerLine=.55},
    rusher=newStyle{spinPot=0.2,eroded=5.0,landing=-5.5,holes=-8,danger=-18,dangerLine=.5,
        atk=1.5,spin=0.5,combo=0.8,b2bVal=0.5},
}
Nova.STYLE_LIST={'balanced','defender','attacker','spinner','combo','rusher'}

local function cellCount(env,id)
    local bk=env.BLOCKS[id][0]
    local n=0
    for i=1,#bk do for j=1,#bk[1] do if bk[i][j] then n=n+1 end end end
    return n
end
function Nova.scaledWeights(env,W,ids)
    local tot,cnt=0,0
    for _,id in ipairs(ids) do tot=tot+cellCount(env,id) cnt=cnt+1 end
    local avg=cnt>0 and tot/cnt or 4
    if avg<=4.2 then return W end
    local k=min(1,avg-4)
    local V={}
    for key,v in pairs(W) do V[key]=v end
    V.holes=W.holes*(1-.5*k)
    V.holeDepth=W.holeDepth*(1-.6*k)
    V.colTrans=W.colTrans*(1-.25*k)
    return V
end

function Nova.adaptiveStyle(ctx,env)
    if Nova.adaptOld then
        local danger=ctx.maxh/env.fieldH
        if ctx.incoming>=4 or danger>0.55 then return 'defender' end
        if ctx.incoming>=2 or danger>0.42 then return 'rusher' end
        if ctx.combo>=3 then return 'combo' end
        return 'spinner'
    end
    local P=Nova.adaptP or {}
    local pressure=(ctx.maxh+(P.inc or 0.5)*ctx.incoming)/env.fieldH
    if pressure>(P.def or 0.66) then return 'defender' end
    if pressure>(P.rush or 0.5) then return 'rusher' end
    if ctx.combo>=5 then return 'combo' end
    return 'spinner'
end

local function slotScore(nf)
    local rows=#nf
    if rows<2 then return 0 end
    local function sol(x,y)
        if x<1 or x>10 or y<1 then return true end
        local r=nf[y]
        return r~=nil and r[x]>0
    end
    local emp={}
    for y=1,rows+2 do
        local r=nf[y]
        local e=10
        if r then e=0 for x=1,10 do if r[x]<=0 then e=e+1 end end end
        emp[y]=e
    end
    local score=0
    for y=2,rows do
        for x=1,10 do
            if not sol(x,y) then
                local dg=(sol(x-1,y-1) and 1 or 0)+(sol(x+1,y-1) and 1 or 0)
                        +(sol(x-1,y+1) and 1 or 0)+(sol(x+1,y+1) and 1 or 0)
                if dg>=3 then
                    local oe=(sol(x-1,y) and 0 or 1)+(sol(x+1,y) and 0 or 1)
                            +(sol(x,y-1) and 0 or 1)+(sol(x,y+1) and 0 or 1)
                    if oe>=3 then
                        local ec,ed,eu=emp[y],emp[y-1],emp[y+1]
                        local sc=0.25
                        if ec==3 and (ed==1 or eu==1) then sc=1
                        elseif ec==2 and ed==1 and eu==1 then sc=1
                        elseif ec<=4 then sc=0.55 end
                        if sc>score then score=sc end
                    end
                end
            end
        end
    end
    return score
end
Nova.slotScore=slotScore

local function wellRun(nf)
    local rows=#nf
    local best=0
    for x=1,10 do
        local run=0
        for y=1,rows do
            local row=nf[y]
            local ready=row[x]<=0
            if ready then
                for j=1,10 do
                    if j~=x and row[j]<=0 then ready=false break end
                end
            end
            if ready then run=run+1 if run>best then best=run end else run=0 end
        end
    end
    return best
end

local function fieldValue(env,nf,W)
    local f=features(nf)
    local s=W.rowTrans*f.rowTrans+W.colTrans*f.colTrans+W.holes*f.holes
        +W.holeDepth*f.holeDepth+W.wells*f.wells+W.bump*f.bump+W.aggH*f.aggH
    local dl=env.fieldH*W.dangerLine
    if f.maxh>dl then s=s+W.danger*(f.maxh-dl) end
    if W.slot>0 then s=s+W.slot*slotScore(nf) end
    if W.well>0 then local k=min(wellRun(nf),4) s=s+W.well*(k+(k>=4 and 2 or 0)) end
    return s,f
end

local function stepReward(env,res,W,ctx,ctrlFault)
    local s=W.landing*res.landing+W.eroded*(res.cleared*res.eroded)
    local b2b=ctx.b2b or 0
    local pc=(res.cleared>0 and #res.field==0)
    local newCombo=res.cleared>0 and (ctx.combo+1) or 0
    local atk,nb=0,b2b
    if res.cleared>0 then
        atk,nb=attackExact(res.cleared,res.spin,b2b,newCombo,pc,ctx.pcCount)
        s=s+W.atk*atk+W.combo*min(newCombo,10)
        if res.spin>0 then s=s+W.spin*res.cleared*(res.spin==2 and 1 or .4) end
        s=s+W.b2bVal*(nb-b2b)/100
        if ctx.incoming>0 then s=s+W.cancel*min(atk,ctx.incoming) end
        if pc then s=s+W.pc end
        if W.smallClear>0 and res.spin==0 and res.cleared<4 and ctx.incoming==0 and not pc then
            s=s-W.smallClear*res.cleared
        end
    else
        if ctx.combo>0 then s=s-W.comboBreak*min(ctx.combo,8) end
        if ctx.incoming>0 then s=s+W.incoming*ctx.incoming end
    end
    s=s+W.fine*(ctrlFault or 0)
    return s,atk,newCombo,nb
end

local function scorePlacement(env,res,W,ctx,ctrlFault)
    local fv,f=fieldValue(env,res.field,W)
    local rw,atk,newCombo,nb=stepReward(env,res,W,ctx,ctrlFault)
    return fv+rw,f,atk,newCombo,nb,rw
end

local function finesseOpt(env,id,dir,x)
    local fl=env.finesseList
    if not fl then return nil end
    local t=fl[id] and fl[id][dir+1]
    return t and t[x]
end

local function quickPlacements(env,field,id)
    local out={}
    local BL=env.BLOCKS[id]
    for _,dir in ipairs(distinctDirs(env,id)) do
        local bk=BL[dir]
        local C=#bk[1]
        for x=1,11-C do
            local y=#field+#bk+1
            if not overlap(field,bk,x,y) then
                y=landY(field,bk,x,y)
                out[#out+1]={x=x,y=y,dir=dir}
            end
        end
    end
    return out
end

local function spinPotential(env,nf,id,W,nctx)
    local sx,sy=Nova.spawnPos(env,id)
    if overlap(nf,env.BLOCKS[id][0],sx,sy) then return 0 end
    local S=Nova.reach(env,nf,id,0,sx,sy,0)
    local best=0
    for _,rec in pairs(S.finals) do
        if rec.spin~=0 then
            local r=placeAndClear(env,nf,id,rec.dir,rec.x,rec.y,rec.spin)
            if r.spin>0 and r.cleared>0 then
                local a=attackExact(r.cleared,r.spin,nctx.b2b or 0,(nctx.combo or 0)+1,false)
                if a>best then best=a end
            end
        end
    end
    return best
end

local function genPlacements(env,nf,id,W)
    local out={}
    if W.slot>0 and type(env.RS.kickTable[id])=='table' and slotScore(nf)>0 then
        local sx,sy=Nova.spawnPos(env,id)
        if not overlap(nf,env.BLOCKS[id][0],sx,sy) then
            local S=Nova.reach(env,nf,id,0,sx,sy,0)
            for _,rec in pairs(S.finals) do out[#out+1]=rec end
            return out
        end
    end
    for _,q in ipairs(quickPlacements(env,nf,id)) do
        out[#out+1]={x=q.x,y=q.y,dir=q.dir,spin=0}
    end
    return out
end

local function deepSearch(env,cands,ctx,W,curId,hold,opts)
    local width=opts.width or 6
    local depth=opts.depth or 3
    local yield=opts.yield
    local disc=0.9
    local nodes={}
    for i=1,min(width,#cands) do
        local c=cands[i]
        nodes[#nodes+1]={field=c.res.field,b2b=c.nb,combo=c.combo,
            incoming=max(0,ctx.incoming-(c.atk or 0)),hold=c.opt.hold and curId or hold,
            rest=c.opt.rest,ri=1,cum=c.reward,first=c,value=c.score}
    end
    for ply=2,depth do
        local children={}
        for _,n in ipairs(nodes) do
            local piece=n.rest[n.ri]
            if piece then
                local opts2={{id=piece,ri=n.ri+1,hold=n.hold}}
                if n.hold then
                    opts2[2]={id=n.hold,ri=n.ri+1,hold=piece}
                elseif n.rest[n.ri+1] then
                    opts2[2]={id=n.rest[n.ri+1],ri=n.ri+2,hold=piece}
                end
                for _,o in ipairs(opts2) do
                    local nctx={b2b=n.b2b,combo=n.combo,incoming=n.incoming,fieldH=env.fieldH,
                        pcCount=ctx.pcCount}
                    for _,pl in ipairs(genPlacements(env,n.field,o.id,W)) do
                        local res=placeAndClear(env,n.field,o.id,pl.dir,pl.x,pl.y,pl.spin)
                        if pl.y<=env.fieldH then
                            local rw,atk,newCombo,nb=stepReward(env,res,W,nctx,0)
                            local cum=n.cum+rw*(disc^(ply-1))
                            local fv=fieldValue(env,res.field,W)
                            children[#children+1]={field=res.field,b2b=nb,combo=newCombo,
                                incoming=max(0,n.incoming-atk),hold=o.hold,rest=n.rest,ri=o.ri,
                                cum=cum,first=n.first,value=cum+fv}
                        end
                    end
                end
            end
            if yield then yield() end
        end
        if #children==0 then break end
        table.sort(children,function(a,b) return a.value>b.value end)
        local nn={}
        for i=1,min(width,#children) do nn[i]=children[i] end
        nodes=nn
    end
    local best=nodes[1]
    for _,n in ipairs(nodes) do if n.value>best.value then best=n end end
    return best.first,best.value
end

function Nova.decide(env,field,cur,queue,hold,canHold,ctx,styleName,opts)
    opts=opts or {}
    local yield=opts.yield
    ctx.maxh=ctx.maxh or features(field).maxh
    local sname=styleName
    if sname=='adaptive' or not Nova.STYLES[sname] then sname=Nova.adaptiveStyle(ctx,env) end
    local W=Nova.STYLES[sname]
    do
        local ids={cur.id}
        for i=1,#queue do ids[#ids+1]=queue[i] end
        W=Nova.scaledWeights(env,W,ids)
        if W.well>0 or W.slot>0 then
            local hasI,hasT=(hold==7),(hold==5)
            for _,id in ipairs(ids) do
                if id==7 then hasI=true elseif id==5 then hasT=true end
            end
            if (W.well>0 and not hasI) or (W.slot>0 and not hasT) then
                local V={} for k,v in pairs(W) do V[k]=v end
                if not hasI then V.well=0 end
                if not hasT then V.slot=0 end
                W=V
            end
        end
    end
    local K=opts.beam or 5
    local depth2=opts.lookahead~=false

    local options={}
    options[1]={hold=false,id=cur.id,start={cur.dir,cur.x,cur.y,cur.spin},rest=queue}
    if canHold then
        local hid=hold
        local rest=queue
        if not hid then
            hid=queue[1]
            rest={}
            for i=2,#queue do rest[#rest+1]=queue[i] end
        end
        if hid then
            local x,y=Nova.spawnPos(env,hid)
            options[2]={hold=true,id=hid,start={0,x,y,0},rest=rest,
                after=(hold and cur.id or nil)}
        end
    end

    local cands={}
    for oi,opt in ipairs(options) do
        local S=Nova.reach(env,field,opt.id,opt.start[1],opt.start[2],opt.start[3],opt.start[4])
        for _,rec in pairs(S.finals) do
            local res=placeAndClear(env,field,opt.id,rec.dir,rec.x,rec.y,rec.spin)
            local fault=0
            if not res.roofed then
                local optc=finesseOpt(env,opt.id,rec.dir,rec.x)
                if optc then
                    local ctrl=rec.ctrl
                    if res.spinFlag then ctrl=ctrl-2 end
                    fault=max(0,ctrl-optc)
                end
            end
            local s,f,atk,newCombo,nb,rw=scorePlacement(env,res,W,ctx,fault)
            cands[#cands+1]={opt=opt,S=S,rec=rec,res=res,score=s,atk=atk,combo=newCombo,fault=fault,nb=nb,reward=rw}
        end
        if yield then yield() end
    end
    if #cands==0 then return nil end
    table.sort(cands,function(a,b) return a.score>b.score end)

    if (W.deep or opts.deep) and not opts.shallow then
        local c,val=deepSearch(env,cands,ctx,W,cur.id,hold,opts)
        local rec=c.rec
        return {hold=c.opt.hold,id=c.opt.id,x=rec.x,y=rec.y,dir=rec.dir,spin=rec.spin,
                keys=Nova.pathKeys(c.S,rec),ctrl=rec.ctrl,fault=c.fault,score=val,style=sname,
                cleared=c.res.cleared,spinKind=c.res.spin,atk=c.atk}
    end

    local best,bestTotal
    local top=min(K,#cands)
    for i=1,top do
        local c=cands[i]
        local total=c.score
        if depth2 then
            local nextId=c.opt.rest[1]
            if nextId then
                local nctx={b2b=c.nb,combo=c.combo,incoming=max(0,ctx.incoming-(c.atk or 0)),
                    fieldH=env.fieldH,maxh=nil,pcCount=ctx.pcCount}
                local bestN=-1e9
                local nf=c.res.field
                if opts.fast then
                    for _,q in ipairs(quickPlacements(env,nf,nextId)) do
                        local r2=placeAndClear(env,nf,nextId,q.dir,q.x,q.y,0)
                        local s2=scorePlacement(env,r2,W,nctx,0)
                        if s2>bestN then bestN=s2 end
                    end
                else
                    local sx,sy=Nova.spawnPos(env,nextId)
                    if not overlap(nf,env.BLOCKS[nextId][0],sx,sy) then
                        local S2=Nova.reach(env,nf,nextId,0,sx,sy,0)
                        for _,rec2 in pairs(S2.finals) do
                            local r2=placeAndClear(env,nf,nextId,rec2.dir,rec2.x,rec2.y,rec2.spin)
                            local s2=scorePlacement(env,r2,W,nctx,0)
                            if s2>bestN then bestN=s2 end
                        end
                    end
                end
                if bestN>-1e9 then total=total+0.85*bestN else total=total-200 end
                if W.spinPot>0 and opts.spinSearch and c.res.field and #c.res.field<env.fieldH*0.6 then
                    local best=0
                    local seen={}
                    local function consider(id,decay)
                        if id and not seen[id] then
                            seen[id]=true
                            local a=spinPotential(env,nf,id,W,nctx)*decay
                            if a>best then best=a end
                        end
                    end
                    consider(c.opt.rest[2],.6)
                    consider(c.opt.rest[3],.45)
                    consider(c.opt.rest[4],.35)
                    consider(c.opt.after or hold,.5)
                    local hasTetro=cur.id<=7
                    for i=1,#queue do if queue[i]<=7 then hasTetro=true end end
                    if hasTetro then consider(5,.5) end
                    total=total+W.spinPot*best
                end
            end
        end
        if not bestTotal or total>bestTotal then bestTotal=total best=c end
        if yield then yield() end
    end
    local rec=best.rec
    local keys=Nova.pathKeys(best.S,rec)
    return {hold=best.opt.hold,id=best.opt.id,x=rec.x,y=rec.y,dir=rec.dir,spin=rec.spin,
            keys=keys,ctrl=rec.ctrl,fault=best.fault,score=bestTotal,style=sname,
            cleared=best.res.cleared,spinKind=best.res.spin,atk=best.atk}
end

function Nova.pathTo(env,field,id,dir,x,y,f,target)
    local S=Nova.reach(env,field,id,dir,x,y,f)
    local fk=skey(target.x,target.y,target.dir,target.spin)
    local rec=S.finals[fk]
    if not rec then return nil end
    return Nova.pathKeys(S,rec),rec
end

Nova.skey=skey
Nova.rotate=rotate
Nova.landY=landY
Nova.features=features
Nova.quickPlacements=quickPlacements
return Nova

end)()

local DELAY,UPF={},{}
for n=1,30 do
    local r=(1/60)*(300^((n-1)/29))        -- bot actions per frame
    if r>=0.5 then DELAY[n]=1 UPF[n]=r else DELAY[n]=math.floor(1/r+0.5) UPF[n]=1 end
end
local STYLE_ORDER={'adaptive','balanced','defender','attacker','spinner','combo','rusher'}
local cfg={speedLV=13,style='adaptive',engine='nova',ccLV=5,hideFX=true,panel=true,hidden=false}
local CC_NODES={5000,10000,20000,40000,80000,160000,320000,640000,1280000,2560000}

local function say(s) TEXT.show(s,640,200,40,'appear',.6) end
local function noop() end

local function copyField(f)
    local out={}
    for y=1,#f do
        local r=f[y]
        out[y]={r[1],r[2],r[3],r[4],r[5],r[6],r[7],r[8],r[9],r[10]}
    end
    return out
end

local function newNovaBot(P)
    local bot={P=P,data={type='NOVA',delay=DELAY[cfg.speedLV]},delay=1,delay0=DELAY[cfg.speedLV],
               style=cfg.style,presses=0}
    local env={BLOCKS=BLOCKS,finesseList=FINESSE,fieldH=P.gameEnv.fieldH,g20=false,keyIns=true}
    bot.env=env
    bot.pushNewNext,bot.updateField,bot.updateB2B,bot.updateCombo,bot.checkDest=noop,noop,noop,noop,noop

    local function refreshEnv()
        local C=P.cur
        env.RS=C.RS
        env.fieldH=P.gameEnv.fieldH
        env.g20=(P._20G and true) or (P.gameEnv.drop*env.fieldH<=30)
        env.keyIns=(P.keyAvailable[11] and P.keyAvailable[12]) and true or false
        env.no180=not P.keyAvailable[5]
        env.noSoft=not (P.keyAvailable[13] and P.keyAvailable[14])
    end
    local function spinCode()
        local sl=P.spinLast
        if sl==nil or sl==false then return 0 end
        return sl==0 and 1 or 2
    end
    local function press(k)
        P:pressKey(k)
        P:releaseKey(k)
        bot.presses=bot.presses+1
        bot.delay=(env.g20 and math.min(bot.delay0,3)) or bot.delay0
    end

    function bot:revive() self.plan=nil self.thread=nil end
    function bot:lockWrongPlace() self.plan=nil self.thread=nil end
    function bot:switch20G() self.plan=nil self.thread=nil end

    local function startThinking()
        refreshEnv()
        local C=P.cur
        local queue={}
        for i=1,5 do
            local B=P.nextQueue[i]
            if B then queue[#queue+1]=B.id end
        end
        local ENV=P.gameEnv
        local canHold=(not bot.noHold) and ENV.holdMode=='hold' and ENV.holdCount>0 and P.holdTime>0
            and P.keyAvailable[8] and not ENV.phyHold and true or false
        local hold
        if #P.holdQueue>=ENV.holdCount and P.holdQueue[1] then hold=P.holdQueue[1].id end
        local field=copyField(P.field)
        local ctx={b2b=(P.b2b or 0)>=50 and 1 or 0,combo=P.combo or 0,incoming=P.atkBufferSum or 0,fieldH=env.fieldH}
        local cur={id=C.id,dir=C.dir,x=P.curX,y=P.curY,spin=spinCode()}
        local ref=C
        bot.thinkRef=ref
        bot.thread=coroutine.create(function()
            bot.result=Nova.decide(env,field,cur,queue,hold,canHold,ctx,bot.style,{yield=coroutine.yield,beam=MOBILE and 3 or 5,width=MOBILE and 4 or 6})
        end)
    end

    function bot:update(dt)
        if not (P.control and P.cur) then
            self.plan,self.thread,self.curRef=nil,nil,nil
            return
        end
        if self.curRef~=P.cur then
            if not self.holdSwapped then
                self.plan,self.thread=nil,nil
                self.holdPressed=false
                self.noHold=false
                self.presses=0
            end
            self.curRef=P.cur
            if self.holdSwapped then
                self.holdSwapped=false
                if self.plan and P.cur.id~=self.plan.id then
                    self.plan,self.thread=nil,nil
                    self.noHold=true
                end
            end
        end
        if not self.plan then
            if not self.thread then startThinking() end
            local ok,err=true,nil
            local t0=love.timer.getTime()
            local budget=MOBILE and .004 or .008
            repeat
                ok,err=coroutine.resume(self.thread)
            until (not ok) or coroutine.status(self.thread)=='dead' or love.timer.getTime()-t0>budget
            if not ok then
                self.thread=nil
                self.errCount=(self.errCount or 0)+1
                if self.errCount<=3 then
                    print("NOVA error: "..tostring(err))
                    if MES then pcall(MES.new,'error',"NOVA: "..tostring(err),6) end
                end
                if self.errCount>=3 then press(6) end
                return
            end
            if coroutine.status(self.thread)=='dead' then
                self.thread=nil
                if self.thinkRef==P.cur then self.plan=self.result end
                self.result=nil
                if not self.plan then press(6) end
            end
            return
        end
        if self.delay>0 then self.delay=self.delay-1 return end

        local plan=self.plan
        if plan.hold and not self.holdPressed then
            self.holdPressed=true
            self.holdSwapped=true
            local before=P.cur
            press(8)
            if P.cur==before then-- hold was refused: think again without it
                self.holdSwapped=false
                self.noHold=true
                self.plan,self.thread=nil,nil
            end
            return
        end
        refreshEnv()
        if self.presses>30 then press(6) return end
        local C=P.cur
        local keys=Nova.pathTo(env,P.field,C.id,C.dir,P.curX,P.curY,spinCode(),plan)
        if not keys then
            self.plan,self.thread=nil,nil
            return
        end
        press(keys[1])
    end
    return bot
end

local BR_DIR='bridge/'
local LETTER={'Z','S','J','L','T','O','I'}
local LETTER_ID={Z=1,S=2,J=3,L=4,T=5,O=6,I=7}
local SPINCODE={none=0,mini=1,full=2}

local function newBridgeBot(P)
    local bot={P=P,data={type='CC2',delay=DELAY[cfg.speedLV]},delay=1,delay0=DELAY[cfg.speedLV],presses=0,age=0}
    local env={BLOCKS=BLOCKS,finesseList=FINESSE,fieldH=P.gameEnv.fieldH,g20=false,keyIns=true}
    bot.env=env
    bot.pushNewNext,bot.updateField,bot.updateB2B,bot.updateCombo,bot.checkDest=noop,noop,noop,noop,noop
    pcall(love.filesystem.createDirectory,'bridge')
    local sid=tostring(os.time())..tostring(math.random(100000,999999))
    local seq=0
    cfg.bridgeStatus='waiting for the bridge program'

    local function refreshEnv()
        local C=P.cur
        env.RS=C.RS
        env.fieldH=P.gameEnv.fieldH
        env.g20=(P._20G and true) or (P.gameEnv.drop*env.fieldH<=30)
        env.keyIns=(P.keyAvailable[11] and P.keyAvailable[12]) and true or false
        env.no180=not P.keyAvailable[5]
        env.noSoft=not (P.keyAvailable[13] and P.keyAvailable[14])
    end
    local function spinCode()
        local sl=P.spinLast
        if sl==nil or sl==false then return 0 end
        return sl==0 and 1 or 2
    end
    local function press(k)
        P:pressKey(k)
        P:releaseKey(k)
        bot.presses=bot.presses+1
        bot.delay=(env.g20 and math.min(bot.delay0,3)) or bot.delay0
    end
    function bot:revive() self.plan,self.waiting=nil,nil end
    function bot:lockWrongPlace() self.plan,self.waiting=nil,nil end
    function bot:switch20G() self.plan,self.waiting=nil,nil end

    local function fallbackPlan(reason)
        cfg.bridgeFallbacks=(cfg.bridgeFallbacks or 0)+1
        cfg.bridgeStatus=reason
        refreshEnv()
        local C=P.cur
        local queue={}
        for i=1,5 do local B=P.nextQueue[i] if B then queue[#queue+1]=B.id end end
        local hold
        if #P.holdQueue>=P.gameEnv.holdCount and P.holdQueue[1] then hold=P.holdQueue[1].id end
        local ctx={b2b=(P.b2b or 0)>=50 and 1 or 0,combo=P.combo or 0,incoming=P.atkBufferSum or 0,fieldH=env.fieldH}
        local cur={id=C.id,dir=C.dir,x=P.curX,y=P.curY,spin=spinCode()}
        return Nova.decide(env,copyField(P.field),cur,queue,hold,false,ctx,'balanced',{beam=1,width=2})
    end

    local function request()
        refreshEnv()
        local C=P.cur
        local supported=LETTER[C.id]~=nil
        local q={}
        for i=1,6 do
            local B=P.nextQueue[i]
            if B then
                if not LETTER[B.id] then supported=false break end
                q[#q+1]='"'..LETTER[B.id]..'"'
            end
        end
        local h=P.holdQueue[1]
        if h and not LETTER[h.id] then supported=false end
        if not supported then
            bot.plan=fallbackPlan("CC2 supports 7-piece sets only")
            return
        end
        seq=seq+1
        cfg.bridgeMoves=(cfg.bridgeMoves or 0)+1
        local f=P.field
        local rows={}
        for y=1,math.min(#f,40) do
            local r,s=f[y],{}
            for x=1,10 do s[x]=(r[x] and r[x]>0) and 'G' or '.' end
            rows[y]='"'..table.concat(s)..'"'
        end
        local js=('{"sid":"%s","seq":%d,"cur":"%s","hold":%s,"queue":[%s],"combo":%d,"b2b":%s,"placed":%d,"rnd":"%s","rows":[%s]}'):format(
            sid,seq,LETTER[C.id],h and ('"'..LETTER[h.id]..'"') or 'null',table.concat(q,','),
            P.combo or 0,((P.b2b or 0)>=50) and 'true' or 'false',
            (P.stat and tonumber(P.stat.piece)) or -1,
            type(P.gameEnv.sequence)=='string' and P.gameEnv.sequence or 'other',table.concat(rows,','))
        love.filesystem.write(BR_DIR..'state.json',js)
        bot.waiting=true
        bot.age=0
    end

    local function poll()
        if not love.filesystem.getInfo(BR_DIR..'move.json') then return nil end
        local s=love.filesystem.read(BR_DIR..'move.json')
        if type(s)~='string' then return nil end
        if s:match('"sid"%s*:%s*"(%w+)"')~=sid or tonumber(s:match('"seq"%s*:%s*(%d+)'))~=seq then return nil end
        local err=s:match('"error"%s*:%s*"([^"]*)"')
        if err then return {error=err} end
        local cells={}
        for x,y in s:gmatch('%[(%d+)%s*,%s*(%d+)%]') do cells[#cells+1]={tonumber(x)+1,tonumber(y)+1} end
        local piece=s:match('"piece"%s*:%s*"(%a)"')
        if #cells~=4 or not LETTER_ID[piece or ''] then return nil end
        return {piece=piece,hold=(s:match('"hold"%s*:%s*(%a+)')=='true'),
                spin=s:match('"spin"%s*:%s*"(%a+)"') or 'none',cells=cells}
    end

    local function resolve(plan)
        refreshEnv()
        local C=P.cur
        if C.id~=plan.id then return nil end
        local S=Nova.reach(env,P.field,C.id,C.dir,P.curX,P.curY,spinCode())
        local t={}
        for i=1,4 do t[i]=math.floor(plan.cells[i][2]*100+plan.cells[i][1]) end
        table.sort(t)
        local want=table.concat(t,',')
        local BL=env.BLOCKS[C.id]
        local best,bestScore
        for _,rec in pairs(S.finals) do
            local bk=BL[rec.dir]
            local u={}
            for i=1,#bk do
                for j=1,#bk[1] do
                    if bk[i][j] then u[#u+1]=math.floor((rec.y+i-1)*100+(rec.x+j-1)) end
                end
            end
            table.sort(u)
            if table.concat(u,',')==want then
                local res=Nova.placeAndClear(env,P.field,C.id,rec.dir,rec.x,rec.y,rec.spin)
                local sc=((res.spin or 0)==plan.want and 0 or 1000)+(S.dist[rec.from] or 0)
                if not bestScore or sc<bestScore then best,bestScore=rec,sc end
            end
        end
        return best
    end

    function bot:update(dt)
        if not (P.control and P.cur) then
            self.plan,self.waiting,self.curRef=nil,nil,nil
            return
        end
        if self.curRef~=P.cur then
            if not self.holdSwapped then
                self.plan,self.waiting=nil,nil
                self.holdPressed=false
                self.presses=0
            end
            self.curRef=P.cur
            if self.holdSwapped then
                self.holdSwapped=false
                if self.plan and P.cur.id~=self.plan.id then self.plan=fallbackPlan("unexpected piece after hold") end
            end
        end
        if not self.plan then
            if not self.waiting then request() return end
            self.age=self.age+1
            if self.age%2==0 then
                local mv=poll()
                if mv then
                    self.waiting=nil
                    if mv.error then
                        self.plan=fallbackPlan("bridge: "..mv.error:sub(1,40))
                    else
                        cfg.bridgeStatus='connected'
                        self.plan={hold=mv.hold,id=LETTER_ID[mv.piece],cells=mv.cells,want=SPINCODE[mv.spin] or 0}
                    end
                end
            end
            if self.age==150 then
                cfg.bridgeStatus='NO ANSWER: is the bridge program running?'
                say("CC2: no answer from the bridge program")
            end
            return
        end
        if self.delay>0 then self.delay=self.delay-1 return end
        local plan=self.plan
        if plan.hold and not self.holdPressed then
            self.holdPressed=true
            self.holdSwapped=true
            local before=P.cur
            press(8)
            if P.cur==before then
                self.holdSwapped=false
                self.plan=fallbackPlan("hold refused")
            end
            return
        end
        refreshEnv()
        if self.presses>40 then press(6) return end
        if not plan.dir then
            local rec=resolve(plan)
            if not rec then
                self.plan=fallbackPlan("move not reachable / not found")
                return
            end
            plan.x,plan.y,plan.dir,plan.spin=rec.x,rec.y,rec.dir,rec.spin
        end
        local C=P.cur
        local keys=Nova.pathTo(env,P.field,C.id,C.dir,P.curX,P.curY,spinCode(),plan)
        if not keys then
            self.plan=nil
            self.waiting=nil
            return
        end
        press(keys[1])
    end
    return bot
end

local okOpp,errOpp=pcall(function()
    local OPP_FILE='conf/nova_opp'
    local OPP={engine='Cold Clear',speed=13,power=5,style=1}
    local ENGINES={'X','NOVA','Cold Clear','9S'}
    local VANILLA={NOVA='9S Lv.1',['Cold Clear']='CC Lv.5',['9S']='9S Lv.5'}   -- values the game's own checks understand
    local STYLE_SHORT={'adapt','balance','defend','attack','spin','combo','rush'}
    local NUM30,NUM10={},{}
    for i=1,30 do NUM30[i]=i end
    for i=1,10 do NUM10[i]=i end

    local function save()
        pcall(love.filesystem.write,OPP_FILE,("engine=%s\nspeed=%d\npower=%d\nstyle=%d\n"):format(OPP.engine,OPP.speed,OPP.power,OPP.style))
    end
    do
        local ok,txt=pcall(function() return love.filesystem.getInfo(OPP_FILE) and love.filesystem.read(OPP_FILE) end)
        if ok and type(txt)=='string' then
            for k,v in txt:gmatch('(%w+)=([^\r\n]*)') do
                if k=='engine' and VANILLA[v] then OPP.engine=v
                elseif k=='speed' then OPP.speed=math.max(1,math.min(30,tonumber(v) or 13))
                elseif k=='power' then OPP.power=math.max(1,math.min(10,tonumber(v) or 5))
                elseif k=='style' then OPP.style=math.max(1,math.min(#STYLE_ORDER,tonumber(v) or 1)) end
            end
        end
    end
    local function env() return CUSTOMGAME_LOCAL and CUSTOMGAME_LOCAL.customenv end
    local function none() local e=env() return not e or e.opponent=='X' end

    local scene=SCN and SCN.scenes and SCN.scenes.customGame
    if scene and scene.widgetList and WIDGET and WIDGET.newSelector then
        local created={}
        local function add(name,x,y,w,label,list,disp,code,hideF)
            local W=WIDGET.newSelector{name=name,x=x,y=y,w=w,color='R',fText=label,list=list,disp=disp,code=code,hideF=hideF}
            W.obj=love.graphics.newText(FONT.get(W.font or 30),label)
            W:reset()
            created[#created+1]=W
        end
        add('novaOppEngine',170,275,260,"Opponent",ENGINES,
            function()
                local e=env()
                if not e or e.opponent=='X' then return 'X' end
                local want=VANILLA[OPP.engine]
                if e.opponent~=want then e.opponent=want end    -- keep the game's own checks in step with our choice
                return OPP.engine
            end,
            function(v)
                local e=env()
                if not e then return end
                if v=='X' then e.opponent='X'
                else OPP.engine=v e.opponent=VANILLA[v] end
                save()
            end)
        add('novaOppSpeed',105,345,124,"Speed",NUM30,
            function() return OPP.speed end,
            function(v) OPP.speed=v save() end,
            none)
        add('novaOppPower',235,345,124,"Power",NUM10,
            function() return OPP.power end,
            function(v) OPP.power=v save() end,
            function() return none() or OPP.engine~='Cold Clear' end)
        add('novaOppStyle',235,345,124,"Style",STYLE_SHORT,
            function() return STYLE_SHORT[OPP.style] end,
            function(v) for i,n in ipairs(STYLE_SHORT) do if n==v then OPP.style=i end end save() end,
            function() return none() or OPP.engine~='NOVA' end)
        for _,W in ipairs(created) do scene.widgetList[#scene.widgetList+1]=W end
        for _,W in ipairs(scene.widgetList) do
            if W.name=='opponent' then
                W.hideF=function() return true end              -- our selector takes its place
            elseif W.name=='life' then
                W.y=W.y+5                                       -- keeps an even gap under the new row
                if W.resCtr then for i=2,#W.resCtr,2 do W.resCtr[i]=W.resCtr[i]+5 end end
            end
        end
    end

    if PLY and PLY.newAIPlayer then
        local orig=PLY.newAIPlayer
        function PLY.newAIPlayer(id,data,...)
            local mode=GAME and GAME.curModeName
            if not (id==2 and type(mode)=='string' and mode:sub(1,7)=='custom_'
                and GAME.modeEnv and GAME.modeEnv.opponent and GAME.modeEnv.opponent~='X') then
                return orig(id,data,...)
            end
            local eng=OPP.engine
            if eng=='Cold Clear' then
                local ok,d=pcall(BOT.template,{type='CC',speedLV=9,next=5,hold=GAME.modeEnv.holdCount,node=CC_NODES[OPP.power]})
                if ok and d then data=d end
            elseif eng=='9S' then
                local ok,d=pcall(BOT.template,{type='9S',speedLV=9,hold=GAME.modeEnv.holdCount})
                if ok and d then data=d end
            end
            local r=orig(id,data,...)
            local P=PLAYERS[id]
            if not (P and P.bot) then return r end
            if eng=='NOVA' then
                local ok,b=pcall(newNovaBot,P)
                if ok and b then
                    b.style=STYLE_ORDER[OPP.style]
                    P.bot=b
                end
            end
            local bot=P.bot
            bot.delay0=DELAY[OPP.speed]
            bot.delay=bot.delay0
            if bot.data then bot.data.delay=bot.delay0 end
            local rate=UPF[OPP.speed]
            if rate~=1 then
                local update,acc=bot.update,0
                bot.update=function(b,dt)
                    acc=acc+rate
                    local n=math.floor(acc)
                    acc=acc-n
                    for _=1,n do update(b,dt) end
                end
            end
            return r
        end
    end
end)
if not okOpp then
    pcall(function() MES.new('error',"Opponent selector failed: "..tostring(errOpp):gsub("%s+"," "):sub(1,90)) end)
end

local Player=require'parts.player.player'
local oldUpdate=Player.update
assert(type(oldUpdate)=='function',"Player.update not found: unsupported game version?")

local function nodeLabel(n) return n>=1000000 and (("%.2fM"):format(n/1000000)) or (("%dk"):format(n/1000)) end
local function curBot() local P=PLAYERS[1] return P and P.bot end

local function applySpeed()
    local bot=curBot()
    if not bot or not bot.data or (bot.data.type~='NOVA' and bot.data.type~='CC' and bot.data.type~='9S' and bot.data.type~='CC2') then return end
    bot.delay0=DELAY[cfg.speedLV]
    bot.data.delay=bot.delay0
    if bot.delay>bot.delay0 then bot.delay=bot.delay0 end
end
local function setSpeed(step)
    cfg.speedLV=math.max(1,math.min(#DELAY,cfg.speedLV+step))
    applySpeed()
    say("BOT SPEED "..cfg.speedLV.."/"..#DELAY)
end

local function releaseAll(P)
    for i=1,13 do if P.keyPressing and P.keyPressing[i] then pcall(P.releaseKey,P,i) end end
end
local function newCCBot(P)
    local ok,data=pcall(function()
        return BOT.template{type='CC',speedLV=math.min(cfg.speedLV,10),next=5,
            hold=P.gameEnv.holdCount>0,node=CC_NODES[cfg.ccLV],
            randomizer=P.gameEnv.sequence=='bag' and 'bag' or 'other',_20G=P._20G}
    end)
    if not ok or not data then return nil end
    if P.holdQueue then while P.holdQueue[1] do table.remove(P.holdQueue) end end
    local ok2=pcall(function() P:loadAI(data) end)
    if not ok2 or not P.bot or data.type~='CC' then P.bot=nil return nil end
    P.bot.delay0=DELAY[cfg.speedLV]; P.bot.data.delay=P.bot.delay0; P.bot.delay=P.bot.delay0
    local okm,ccl=pcall(require,'parts.bot.bot_cc')
    local orig=okm and type(ccl)=='table' and ccl.checkDest
    if orig then
        P.bot.checkDest=function(self,...)
            local pl=self.P
            if not pl.nextQueue[1] then pl.destFX=nil return end
            if not pcall(orig,self,...) then pl.destFX=nil end
        end
    end
    return P.bot
end
local function new9S(P)
    local ok,data=pcall(function()
        return BOT.template{type='9S',speedLV=math.min(cfg.speedLV,10),hold=P.gameEnv.holdCount>0}
    end)
    if not ok or not data then return nil end
    local ok2=pcall(function() P:loadAI(data) end)
    if not ok2 or not P.bot then P.bot=nil return nil end
    P.bot.delay0=DELAY[cfg.speedLV]; P.bot.data.delay=P.bot.delay0; P.bot.delay=P.bot.delay0
    return P.bot
end
local function startBot(P)
    releaseAll(P)
    if cfg.engine=='cc2' then
        P.bot=newBridgeBot(P)
        return "COLD CLEAR 2 (bridge)"
    end
    if cfg.engine=='9s' then
        if new9S(P) then return "9S (built-in bot)" end
        cfg.engine='nova'
    end
    if cfg.engine=='cc' then
        if newCCBot(P) then return "COLD CLEAR "..cfg.ccLV.." ("..nodeLabel(CC_NODES[cfg.ccLV]).." nodes)" end
        cfg.engine='nova'
        P.bot=newNovaBot(P)
        return "COLD CLEAR UNAVAILABLE -> NOVA "..cfg.style:upper()
    end
    P.bot=newNovaBot(P)
    return "NOVA "..cfg.style:upper()
end
local function restartBot()
    local P=PLAYERS[1]
    if P and P.bot and P.type=='human' and P.alive then
        P.bot=nil
        say(startBot(P))
    end
end
local function setEngine(e) cfg.engine=e restartBot() end
local function setStyle(name)
    cfg.engine='nova' cfg.style=name
    local bot=curBot()
    if bot and bot.data and bot.data.type=='NOVA' then bot.style=name say("BOT STYLE: "..name:upper())
    else restartBot() end
end
local function setCC(i) cfg.engine='cc' cfg.ccLV=i restartBot() end
local function cycleStyle()
    if cfg.engine=='cc' then setCC(cfg.ccLV%10+1) return end
    local i=1
    for k,n in ipairs(STYLE_ORDER) do if n==cfg.style then i=k end end
    setStyle(STYLE_ORDER[i%#STYLE_ORDER+1])
end
local function toggle()
    local P=PLAYERS[1]
    if not P or P.type~='human' or GAME.replaying or not P.alive then return end
    if P.bot then P.bot=nil say("AUTOPLAY OFF") return end
    say("AUTOPLAY ON ("..startBot(P)..")  SPEED "..cfg.speedLV)
end

local function wrapDraw(P)
    if P._novaDraw then return end
    P._novaDraw=true
    local old=P.draw
    P.draw=function(self,...)
        if cfg.hideFX and self.bot and self.destFX then
            local d=self.destFX
            self.destFX=nil
            local ok,err=pcall(old,self,...)
            self.destFX=d
            if not ok then error(err,0) end
        else
            return old(self,...)
        end
    end
end

local function newUpdate(self,dt)
    oldUpdate(self,dt)
    if self.bot and self.type=='human' and self.alive then
        self._novaAcc=(self._novaAcc or 0)+(UPF[cfg.speedLV] or 1)
        local n=math.floor(self._novaAcc)
        self._novaAcc=self._novaAcc-n
        for _=1,n do
            if self.bot then
                local ok,err=pcall(self.bot.update,self.bot,dt)
                if not ok then
                    self.bot=nil
                    releaseAll(self)
                    say("AI STOPPED: "..tostring(err):gsub("%s+"," "):sub(1,70))
                    break
                end
            end
        end
        wrapDraw(self)
    end
end
Player.update=newUpdate
for _,P in ipairs(PLAYERS) do
    if P.update==oldUpdate then P.update=newUpdate end
end

local oldKey=love.keypressed
function love.keypressed(key,sc,isRep)
    if SCN.cur=='game' and not isRep then
        if key=='f6' then toggle() return end
        if key==']' then setSpeed(1) return end
        if key=='[' then setSpeed(-1) return end
        if key=='\\' then cycleStyle() return end
        if key=='f7' then setEngine(cfg.engine=='nova' and 'cc' or cfg.engine=='cc' and 'cc2' or cfg.engine=='cc2' and '9s' or 'nova') return end
        if key=='f8' then cfg.hidden=not cfg.hidden return end
    end
    return oldKey(key,sc,isRep)
end

local PX,PY,PW=956,84,310
local function layout()
    local L={}
    local function add(x,y,w,h,label,act,on) L[#L+1]={x=x,y=y,w=w,h=h,label=label,act=act,on=on} end
    if cfg.hidden then
        add(PX+PW-84,PY-46,84,36,nil,function() cfg.hidden=false end)   -- invisible hotspot: click here to show the UI again
        return L
    end
    add(PX+PW-84,PY-46,84,36,cfg.panel and "UI  -" or "UI  +",function() cfg.panel=not cfg.panel end)
    if not cfg.panel then return L end
    local y=PY
    add(PX,y,PW,56,curBot() and "AI  ON" or "AI  OFF",toggle,curBot()~=nil); y=y+64
    add(PX,y,70,48,"-",function() setSpeed(-1) end)
    add(PX+80,y,150,48,"SPEED "..cfg.speedLV.."/"..#DELAY,nil)
    add(PX+240,y,70,48,"+",function() setSpeed(1) end); y=y+58
    add(PX,y,72,44,"NOVA",function() setEngine('nova') end,cfg.engine=='nova')
    add(PX+79,y,72,44,"CC",function() setEngine('cc') end,cfg.engine=='cc')
    add(PX+158,y,72,44,"CC2",function() setEngine('cc2') end,cfg.engine=='cc2')
    add(PX+237,y,73,44,"9S",function() setEngine('9s') end,cfg.engine=='9s'); y=y+52
    if cfg.engine=='nova' then
        for i,name in ipairs(STYLE_ORDER) do
            add(PX+((i-1)%2)*158,y+math.floor((i-1)/2)*46,152,40,name,function() setStyle(name) end,cfg.style==name)
        end
        y=y+math.ceil(#STYLE_ORDER/2)*46
    elseif cfg.engine=='cc2' then
        add(PX,y,PW,40,"Cold Clear 2 (external, PC)",nil); y=y+46
        add(PX,y,PW,40,(cfg.bridgeStatus or "bridge not started"):sub(1,28),nil); y=y+46
        add(PX,y,PW,34,("NOVA took over: %d of %d"):format(cfg.bridgeFallbacks or 0,cfg.bridgeMoves or 0),nil); y=y+42
    elseif cfg.engine=='9s' then
        add(PX,y,PW,44,"9S  (the game's own Lua bot)",nil); y=y+52
    else
        for i=1,10 do
            add(PX+((i-1)%5)*63,y+math.floor((i-1)/5)*50,58,44,tostring(i),function() setCC(i) end,cfg.ccLV==i)
        end
        y=y+102
        add(PX,y,PW,34,"CC "..cfg.ccLV.."   "..nodeLabel(CC_NODES[cfg.ccLV]).." nodes",nil); y=y+42
    end
    add(PX,y,PW,44,"HIDE CC TARGET: "..(cfg.hideFX and "ON" or "OFF"),function() cfg.hideFX=not cfg.hideFX end,cfg.hideFX); y=y+52
    add(PX,y,PW,40,"HIDE ALL UI   (F8 / top-right corner shows it)",function() cfg.hidden=true end)
    return L
end
local function panelVisible() return SCN.cur=='game' and not GAME.replaying end
local function hitButton(x,y)
    for _,b in ipairs(layout()) do
        if x>=b.x and x<=b.x+b.w and y>=b.y and y<=b.y+b.h then return b end
    end
end
local function drawPanel()
    local gc=love.graphics
    FONT.set(24)
    for _,b in ipairs(layout()) do
        if b.label==nil then goto continue end
        if b.on then gc.setColor(.1,.45,.2,.8) else gc.setColor(0,0,0,.6) end
        gc.rectangle('fill',b.x,b.y,b.w,b.h,8,8)
        gc.setColor(1,1,1,b.act and .9 or .5)
        gc.rectangle('line',b.x,b.y,b.w,b.h,8,8)
        gc.printf(b.label,b.x,b.y+b.h/2-14,b.w,'center')
        ::continue::
    end
    gc.setColor(1,1,1)
end
if getmetatable(SCN)==nil then
    local sceneDraw=SCN.draw
    local broken=false
    rawset(SCN,'draw',nil)
    setmetatable(SCN,{
        __index=function(_,k)
            if k=='draw' then
                return function()
                    if sceneDraw then sceneDraw() end
                    if panelVisible() and not broken then
                        local ok=pcall(drawPanel)
                        if not ok then broken=true end
                    end
                end
            end
        end,
        __newindex=function(t,k,v)
            if k=='draw' then sceneDraw=v else rawset(t,k,v) end
        end,
    })
end
local function click(x,y)
    if not panelVisible() then return false end
    local vx,vy=SCR.xOy:inverseTransformPoint(x,y)
    local b=hitButton(vx,vy)
    if b then if b.act then b.act() end return true end
    return false
end
local oldTouch=love.touchpressed
function love.touchpressed(id,x,y,...)
    if click(x,y) then return end
    return oldTouch(id,x,y,...)
end
local oldMouse=love.mousepressed
function love.mousepressed(x,y,k,touch,...)
    if not touch and k==1 and click(x,y) then return end
    return oldMouse(x,y,k,touch,...)
end

AUTOPLAY_TRAINER=true
NOVA_CFG=cfg
if NOVA_AUTOSTART then pcall(function() MES.new('info','NOVA autoplay loaded') end) end
return NOVA_INSTALLED and "NOVA installed: it will start automatically from now on. Use the panel on the right side of a game." or "NOVA trainer loaded: use the panel on the right side of a game (F6 AI, [ ] speed, \\ style, F7 engine, F8 hide UI)"
