# NOVA Mods for Techmino (unofficial)


A set of mods for [**Techmino**](https://github.com/26F-Studio/Techmino) **0.17.21**: a mod manager, an autoplay bot, background / music / skin / sound customisation and an in-game sound editor. Everything is plain Lua files. **No game files are modified.**

> ## ⚠️ READ THIS FIRST: BACK UP YOUR DATA
> Mods run code inside the game and **write into your Techmino save folder** (settings, custom background, custom game settings, new files and folders). A bug, a conflict with another mod or a game update could damage or lose data.
> **Before you install anything, close Techmino and make a full copy of your save folder** (records, ranks and unlocks, statistics, settings, replays). See [Back up your data](#back-up-your-data-do-this-before-anything-else).

---

## Contents

1. [What is included](#what-is-included)
2. [Back up your data (do this before anything else)](#back-up-your-data-do-this-before-anything-else)
3. [Install](#install)
4. [Uninstall and recovery](#uninstall-and-recovery)
5. [How each mod works](#how-each-mod-works)
6. [Important warnings](#important-warnings)
7. [Files and folders the mods create or change](#files-and-folders-the-mods-create-or-change)
8. [Troubleshooting](#troubleshooting)
9. [License and credits](#license-and-credits)

---

## What is included

|File|Mod|What it does|
|-|-|-|
|`CCloader.lua`|Loader|Makes the game start the mods automatically. Required.|
|`mod_manager.lua`|Mod manager|**Mods** button in the main menu; switch mods on and off; install a mod from the clipboard.|
|`autoplay_trainer.lua`|NOVA Autoplay|Autoplay bots (NOVA, the game's own Cold Clear, 9S), a choice of bot opponents in Custom Game, **fair-play protection**.|
|`bg_switcher.lua`|Background Switcher|Pictures, GIFs and videos as backgrounds, slideshow.|
|`custom_music.lua`|Custom Music|Your own tracks in the Music Room and in Custom Game.|
|`custom_assets.lua`|Custom Skins and SFX|Your own block skins (also animated) and sound packs.|
|`sfx_lab.lua`|SFX Lab|Per-sound pitch, random pitch, volume, round robin and an equalizer, edited live in the game.|

You can install only the mods you want. `CCloader.lua` and `mod_manager.lua` are the base.

---

## Back up your data (do this before anything else)

**What can go wrong.** These mods are unofficial code. They have been tested on Techmino **0.17.21** only, and they change files in the save folder. Problems that can happen: a mod crashes the game at start, a mod overwrites a setting or your own custom background, another mod or a game update conflicts with these ones, a bug corrupts a settings file. **Your records and progress live in the same folder.** A backup takes a minute and removes the risk.

**Windows (official `Techmino.exe`)**

1. **Close Techmino completely.**
2. Press `Win+R`, type `%appdata%` and press Enter.
3. Right-click the **`Techmino`** folder → *Send to* → *Compressed (zipped) folder*. (If you start the game through LÖVE, the folder is `LOVE\Techmino`.)
4. Move the `.zip` to **another place**: another drive, a USB stick or cloud storage. Name it with the date.
5. Optional but recommended: unzip it once somewhere else to check that the archive opens.

**What the folder contains** (the exact file names differ, copy the whole folder): records, ranks and unlocked modes, statistics, settings, key bindings, replays, custom game settings, custom background.

**Phone (Android).** The save folder is private and normally cannot be opened without root. Use the game's own **Data Management** screen (in Statistics) to export or copy your data if it offers that, and check that the export worked before installing mods. If you cannot back up your data, **do not install the mods on that device.**

**Restore.** Close the game, delete the `Techmino` folder in `%appdata%`, unzip your backup so the folder is back at the same place, start the game.

**A safe order:** back up — install **one** mod — start the game and check — install the next one.

---

## Install

### Where is the save folder?

|Case|Folder|
|-|-|
|Windows, official `Techmino.exe`|`%appdata%\Techmino`|
|Windows, game started through LÖVE|`%appdata%\LOVE\Techmino`|

(Press `Win+R`, paste the path, Enter. In the game, *Mods → Open mods folder* opens the `mods` folder for you.)

### Quick Installation (PC) — in 2 clicks

1. Download the archive from the [latest release](../../releases/latest) (it already contains all files and the `mods` folder pre-packed).
2. Copy **all contents** of the archive (`CCloader.lua`, `mod_manager.lua`, and the `mods` folder) directly into your Techmino save folder.
3. Start the game. You should see the message **"NOVA autoplay loaded"** and a **Mods** button in the main menu (top right).

*(If you downloaded individual files: put `CCloader.lua` and `mod_manager.lua` in the root of your save folder, and place secondary mods inside the `mods` folder. If the `mods` folder doesn't exist yet, the mod manager will create it automatically on the first launch).*

### Recommended layout (PC)

```
%appdata%\Techmino\
├── CCloader.lua          <- loader (must be in the root)
├── mod_manager.lua       <- mod manager (must be in the root)
└── mods\                 <- put every other mod here
    ├── autoplay_trainer.lua
    ├── bg_switcher.lua
    ├── custom_music.lua
    ├── custom_assets.lua
    └── sfx_lab.lua
```

### Install on a phone (autoplay mod only)

1. Open `autoplay_trainer.lua` in a text viewer, **select all** and **copy** the whole text.
2. In Techmino tap the **TECHMINO logo 4 times** to open the console and type, line by line:

```
   su 7126
   #return loadstring(love.system.getClipboardText())()
```

(`su 7126` is the game's public developer-console code. It is only needed for this step.)

3. You should see "NOVA installed...". It writes `autoplay_trainer.lua`, `CCloader.lua` and `mod_manager.lua` into the save folder. **Restart the game.**
4. Other mods can be installed from the **Mods** window (*Install from clipboard*), but media folders (backgrounds, music, skins, sounds) cannot be filled on a phone, so those mods are of little use there.

### Manual start without the loader (only if auto-start does not work)

Put `autoplay_trainer.lua` in the save folder and, **every time you start the game**, type in the console:

```
su 7126
#return love.filesystem.load('autoplay_trainer.lua')()
```

### Update

Replace the files with the new version and restart the game. On a phone repeat the clipboard install.

---

## Uninstall and recovery

**If the game does not start or crashes at start:**

1. Delete **`CCloader.lua`** from the save folder: this stops all mods from loading, and the game starts as usual.
2. Then remove or move out the mod that caused the problem and put `CCloader.lua` back.
3. If you still have problems, restore your backup.

**Remove one mod:** delete its file (or switch it off in *Mods*, then restart).
**Remove everything:** delete `CCloader.lua`, `mod_manager.lua` and the `mods` folder (and any mod files in the save folder root). The folders `backgrounds`, `music`, `skins`, `sfx` and the files `conf/nova_*` are yours/the mods' data: delete them if you do not need them.
**Return the background to normal:** in *Settings → Video* press **Normal BG** (or *No BG*). If you had your own custom background before, restore it from your backup (see the warnings below: the background mod overwrites `conf/customBG`).

---

## How each mod works

### Mod manager (`mod_manager.lua`)

* **Mods** button in the main menu (top right). The window lists every mod with a switch, a description and a status (`loaded`, `disabled`, or the error text in red).
* Switching a mod on or off takes effect **after restarting the game**.
* **Install from clipboard**: copy the code of a mod, press the button, **press it again within 8 seconds** to confirm. The code is checked for valid Lua and saved to `mods/`. Only install code you trust.
* **Open mods folder** opens the folder (PC).
* A mod can give itself a name and a description in the first two lines of its file: `-- NOVA mod: Name` and `-- description`.

### NOVA Autoplay (`autoplay_trainer.lua`)

A panel appears on the right side of a game (mouse or touch):

|Control|What it does|
|-|-|
|**AI ON/OFF**|Turns the bot on or off (**F6**)|
|**− / +**|Bot speed, 30 levels (**[** and **]**)|
|**NOVA / CC / 9S**|Bot engine (**F7** cycles them)|
|NOVA styles / CC levels 1-10|NOVA play style (adaptive, balanced, defender, attacker, spinner, combo, rusher) or the Cold Clear search size from 5k to 2.56M nodes (**\** cycles)|
|**HIDE CC TARGET**|Hides the cells where Cold Clear plans to put the piece|
|**UI −/+**, **HIDE ALL UI**|Collapse / completely hide the panel (**F8** or the top-right corner shows it again)|

* **CC** is the Cold Clear bot that is **built into the game** (it needs nothing to be installed). If the game has no Cold Clear library, the mod says so and uses NOVA.
* **Bot opponent in Custom Game:** the *Opponent* selector is replaced by *Opponent / Speed / Power or Style* (X, NOVA, Cold Clear, 9S).
* **Fair play (built in, see warnings):** a game in which the bot played, even for a moment, saves **no record, rank, unlock or statistics**. A red banner says so on the screen.

### Background Switcher (`bg_switcher.lua`)

Put files into the folder **`backgrounds`** in the save folder: pictures (png, jpg, bmp, tga), animated **GIF** and videos **`.ogv`** (Ogg Theora only; the game cannot play mp4 or webm). Controls are in **Settings → Video**, between the background slider and "Disable theme":

|Button|What it does|
|-|-|
|**<** / **Next BG**|Previous / next background|
|**Auto**|Slideshow: off, 10 s, 30 s, 1 min, 5 min|
|**Order**|A-Z or random|
|**Fit**|Fill / Fit / Stretch|

Convert a video: `ffmpeg -i input.mp4 -an -c:v libtheora -q:v 7 -pix_fmt yuv420p output.ogv`. The brightness slider of the game still sets how bright the background is. The "Normal BG / No BG / Custom BG" buttons of the game switch the mod off.

### Custom Music (`custom_music.lua`)

Put tracks (ogg, mp3, wav, flac) into the folder **`music`**. The **Music Room** has two buttons, **Custom Music** and **Vanilla Music**; **Custom Game** has one button left of the Music selector that switches between them. In *Custom Music* mode the game plays your tracks wherever it would play its own music (which track depends on the game's own track name). Press the button again after adding files; no restart is needed.

### Custom Skins and SFX (`custom_assets.lua`)

**Skins (Settings → Style).** Put PNG files into the folder **`skins`**. The picture must be exactly **240×90 pixels, RGBA, 8×3 blocks of 30×30**. Press **Reload**; the new skins appear at the end of the *Block Skin* list. **Template** exports the current skin as a starting point (files starting with `_` are ignored). **Folder** opens the folder.

**Animated skins (two layers).** Layer 1 (below) is an animation, layer 2 (above) is your skin picture. Next to `name.png` you can put `name.gif` (animation) and/or `name.txt` (settings):

```
anim=rainbow      # rainbow, ocean, fire, aurora (built in) or gif
fps=20            # 1..60
speed=1
blend=tint        # over: skin above the animation | mask: animation only where the skin is not transparent | tint: animation x skin colours
mode=auto         # for a GIF: atlas (8x3 layout) / cell (whole gif in every block) / auto
```

For "shimmering outline lines": make the skin with a light outline and a transparent inside and use `blend=mask`. **Reload** also re-reads changed `.txt` and `.gif` files. Only the selected skin is animated. It needs a graphics card that can compile the (small) shader; if it cannot, the mod shows "Skin animation off" and the static skin keeps working.

**Sound packs (SFX Room).** A pack is a folder in **`sfx`**, for example `sfx/retro/`, with `.ogg` files named like the game's sounds (`clear_1.ogg`, `button.ogg`, ...). Only the sounds you provide are replaced. The **Custom SFX** selector in the SFX Room picks the pack, **Template** copies all the game's sounds to `sfx/_template` so you can edit them, **Reload** rescans, **Folder** opens the folder. Folders whose names start with `_` and a folder called `variants` are never shown as packs.

### SFX Lab (`sfx_lab.lua`)

Open it from the **SFX Room** (button **SFX Lab**). A table of all sounds on the left, an editor on the right. Changes work immediately; a short preview plays when you stop moving a control.

* **Pitch** (-12..+12 semitones), **Random Pitch** (0..±6), **Volume** (0..200 %; above 100 % the sound is played twice at once so the levels add up).
* **Round Robin:** several files for one sound play in turn. Put them into **`sfx/<pack>/variants/<sound name>/`** (for the game's own sounds: `sfx/_default/variants/<sound name>/`). Formats: ogg, wav, mp3, flac. The **Variants** button creates and opens the folder.
* **Equalizer:** 5 bands (80 Hz, 250 Hz, 1 kHz, 3.5 kHz, 10 kHz), ±12 dB, drag the faders (mouse wheel: 1 dB, right click: reset) and watch the response curve. If the sound cannot be processed on your system, a 4-band fallback is used and the screen says so.
* **Active** switches the changes of one sound off to compare with the original; **Reset** / **Reset all** restore defaults.
* Settings are saved in `conf/nova_sfxlab`. If processing fails, the error is written to `conf/nova_sfxlab_error.txt`.

---

## Important warnings

1. **Unofficial and at your own risk.** This project is not affiliated with 26F Studio. "TECHMINO" is their trademark. The software is provided **as is, without any warranty**.
2. **Back up your data first.** See [above](#back-up-your-data-do-this-before-anything-else). The authors are not responsible for lost records, progress or settings.
3. **Mods are code with full access to the game.** A mod can read and write files in the save folder and do anything the game can do. Install mods **only from this repository's releases or from authors you trust**, read the code if you can, and never paste code from an unknown source into *Install from clipboard* or into the console. The released files are plain, readable Lua (some have their comments removed to keep them small; the sources are in `src/` if provided).
4. **Fair play is part of the autoplay mod:**

   * A game in which the bot played, even for a moment, saves **no record, rank, unlock or statistics**. A red banner says so on the screen.
   * **Bots cannot be turned on in online games** (the button and F6 refuse).
   * The game itself does **not** mark bot runs as unranked, so this protection exists **only while `autoplay_trainer.lua` is installed**. If you remove or disable it, bot runs can save normal records.
   * Do not present bot results as your own play and respect the rules of any competition or event. Using mods there may be forbidden.
5. **Only Techmino 0.17.21 has been targeted.** Other versions can behave differently or crash. After a game update, mods may stop working or break: remove `CCloader.lua` and update the mods.
6. **The background mod changes your game settings.** To show your picture it writes it as the game's custom background (**`conf/customBG`**, overwriting your own custom background if you had one), switches the background setting to "custom" and saves the settings. Restore from your backup or choose another background in *Settings → Video* if you do not want that.
7. **Custom Game settings are changed** by the bot mod: the stored opponent value becomes `9S Lv.1`, `CC Lv.5` or `9S Lv.5` depending on your choice (the mod keeps the game's own checks working). The music mod and the sound mods also store choices in the game's settings.
8. **The loader file name is fixed.** The game asks for a module called `CCloader` at start, so the loader must have this exact name. If you already use your own `CCloader.lua` (for example a custom Cold Clear loader), **back it up**: the mod loader passes the request on to the real loader, but a custom Lua loader in the save folder would be hidden.
9. **Performance.** High bot speed levels (25-30), Cold Clear power 9-10 (1.3-2.6 million nodes), big GIFs or 4K videos as backgrounds, animated skins and equalizer processing use more CPU, memory and graphics power. Lower the settings if the game stutters.
10. **Not everything works on phones.** You cannot put files into the media folders on a phone (the save folder is private), the autoplay mod needs a console install, and *Open mods folder* does nothing.
11. **Voices are not changed** by the sound mods (only sound effects). Video backgrounds work only as `.ogv`. Sound packs work only with `.ogg` files.
12. **Known limits:** the skin shader and the equalizer depend on your system; the mods say so on screen when they fall back or fail. The GIF decoder is written in Lua and slower than a normal player.
13. **Tested only in a simulation and in part by the author on PC.** Some problems may not have been found. Please report them with a screenshot and the text of any error message.

---

## Files and folders the mods create or change

All paths are inside the Techmino save folder.

|Path|Created / changed by|What it is|
|-|-|-|
|`CCloader.lua`, `mod_manager.lua`, `autoplay_trainer.lua`, ...|you (or the clipboard install)|mod files|
|`mods/`|manager|extra mod files|
|`backgrounds/`|Background Switcher|your backgrounds|
|`music/`|Custom Music|your tracks|
|`skins/`|Custom Skins and SFX|your skins (+ `.gif`, `.txt`)|
|`sfx/<pack>/`, `sfx/<pack>/variants/`, `sfx/_default/variants/`, `sfx/_template/`|Custom Skins and SFX, SFX Lab|sound packs, variants, template|
|`conf/customBG`|Background Switcher|**overwritten** with the chosen picture|
|game settings and Custom Game settings|several mods|background, skin, sound pack, opponent, music choice|
|`conf/nova_mods`, `conf/nova_bg`, `conf/nova_music`, `conf/nova_opp`, `conf/nova_assets`, `conf/nova_sfxlab`, `conf/nova_sfxlab_error.txt`|each mod|the mods' own settings|

Your records, ranks and statistics are **not** changed by the mods, except that games where the bot played are **not saved** (see warning 4).

---

## Troubleshooting

|Problem|What to try|
|-|-|
|No **Mods** button, no "NOVA autoplay loaded" message|`CCloader.lua` or `mod_manager.lua` is in the wrong folder (see [Install](#install)), or the game version is not 0.17.21. Try the manual start.|
|The game crashes at start after installing|Delete `CCloader.lua`, then find the mod that causes it. Restore the backup if needed.|
|A mod shows `error: ...` in red in the Mods window|Copy the text and report it. Switch the mod off meanwhile.|
|Custom skin is missing or shows `[no skin]`|The PNG is not exactly 240×90, or it was not reloaded: press **Reload** in *Style Settings*.|
|Animated skin does not move|Check the file names (`name.png`, `name.txt`, `name.gif`) and that the animated skin is the selected one. A message "Skin animation off: shader error" means your graphics card could not compile the shader.|
|Custom sounds keep playing after switching the pack off|Update to the latest `sfx_lab.lua` and `custom_assets.lua`.|
|`variants` shows up as a sound pack|Update to the latest versions: variants now live inside the pack folder.|
|The equalizer says "fallback (4 bands)"|Your system could not process the sound. A text with the reason is shown in red and saved to `conf/nova_sfxlab_error.txt`.|
|Bot panel not shown|It is shown only inside a running game; press **F8** (or click the top-right corner) if you hid the UI.|
|"BOTS ARE DISABLED IN ONLINE GAMES"|This is intended.|

---

## License and credits

* Techmino © 26F Studio, licensed under **LGPL-3.0**. These mods reuse data and rules derived from the game (finesse table, attack rules, rotation tables), so this project is also published under **LGPL-3.0**. See `LICENSE`.
* Cold Clear is a separate project; the mods only use the copy that is built into the game.
* Pictures, music and sounds you add belong to their authors.
* "Tetris" is a trademark of The Tetris Holding, LLC.