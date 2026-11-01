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
