> ### This repository was `pfUI-classicAPI` until 2026-09-01
>
> **If pfUI stopped loading after an update, you are on the wrong build for your client.**
> The name `roby-brok/pfUI` used to hold the pre-ClassicAPI build; the two swapped names.
> GitHub drops a rename redirect once the freed name is reused, so an existing
> `roby-brok/pfUI` remote now pulls *this* build rather than the old one.
>
> This build **requires `ClassicAPI.dll`** and disables itself with a popup without it. If
> you cannot run the DLL, the old build is
> **[roby-brok/pfUI-legacy](https://github.com/roby-brok/pfUI-legacy)** — point your remote
> there and it will keep working as before.

> ### Attribution
>
> **This is a downstream fork. Almost none of the work here is mine.**
>
> | | |
> |---|---|
> | **[Shagu](https://github.com/shagu/pfUI)** | created pfUI. Everything below rests on it. |
> | **[brues-code / Railgun](https://github.com/brues-code/pfUI)** | wrote the ClassicAPI Edition this fork tracks — the `C_NamePlate` / `C_UnitAuras` / `C_Spell` conversion, event-driven nameplates, real castbars, focus, equipment manager. **Also the author of [ClassicAPI](https://github.com/brues-code/ClassicAPI) itself**, the DLL that makes all of it possible. |
> | **me0wg4ming** | earlier fork lineage. |
> | **Roby_Brok** | this repo: a handful of local patches for OctoWoW on top of Railgun's tree. |
>
> Upstream is **https://github.com/brues-code/pfUI** — go there for the real project,
> issues and releases. Local changes live on the `octo` branch and exist only because they
> had not been reported upstream yet. GPLv3, same as upstream; see `LICENSE`.
>
> 📋 **[CHANGES-octo.md](CHANGES-octo.md) — full changelog of everything added on top of
> upstream.** Section 1 lists **bugs found in the upstream tree**, which affect every user
> of that fork and are the part worth pulling back upstream.

# pfUI - ClassicAPI Edition

[![Octo WoW](https://img.shields.io/badge/Octo%20WoW-1.18.1-brightgreen.svg)](https://octowow.st/)
[![ClassicAPI](https://img.shields.io/badge/ClassicAPI-Required-purple.svg)](https://github.com/brues-code/ClassicAPI)
[![Nampower](https://img.shields.io/badge/Nampower-Required-purple.svg)](https://github.com/brues-code/nampower)
[![SuperWoW](https://img.shields.io/badge/SuperWoW-Optional-yellow.svg)](https://github.com/balakethelock/SuperWoW)
[![UnitXP](https://img.shields.io/badge/UnitXP__SP3-Optional-yellow.svg)](https://github.com/brues-code/UnitXP_SP3)

**A pfUI fork specifically optimized for ClassicAPI on [Octo WoW](https://octowow.st/)**

This version includes significant performance improvements and DLL-enhanced features.

## What this fork changes, briefly

*(as of 2026-08-11 — details and reasoning in [CHANGES-octo.md](CHANGES-octo.md))*

- **Use Class Color** — one toggle swaps pfUI's signature mint for your class colour,
  everywhere: logo, GUI, borders, highlights, cooldown text, stack counts
- **Target nameplate symbols** — texture-based arrows/triangles beside the target's plate,
  sizeable past the nameplate font ceiling, with colour and gap options
- **BoE / BoU labels** on bag and bank items, tinted by item quality; *Hide Gold* option
- **Custom Action Bar Background** — recolour the action-bar button backdrops without
  touching any other frame's background
- **Per-unit offsets** for portraits, buffs and debuffs; castbar *Hide Total Timer*;
  castbars drawn above the aura rows; sizeable distance panel
- **Hide Nameplates Out Of Combat** option
- **Performance** — throttled cooldown/reactive updates, loot-frame autoresize done once
  instead of per-slot, empty text slots skipped in raid refreshes (the aggro-check cache
  was cherry-picked upstream on 2026-08-11 — the delta keeps shrinking, which is the goal)
- **Safety for everyone else** — the version broadcast is pinned to the upstream release,
  so this fork can never announce a version that doesn't exist to nearby pfUI users
- Nearly all **bug fixes found here have already been merged upstream** (PRs #39/#40) —
  what remains above is preference and polish. The changelog's claims are audited against
  upstream, and the ones that turned out wrong stay visible, struck through.

## Installation

> ### ⚠️ The folder **must** be named `pfUI`
>
> Not `pfUI-classicAPI`, not `pfUI-classicAPI-octo`. This is the easiest way to install it
> wrong, and it fails without telling you why. Two separate things break:
>
> 1. **WoW skips the addon entirely.** It only loads a folder whose name matches the `.toc`
>    inside it. A folder called `pfUI-classicAPI` containing `pfUI.toc` simply never runs —
>    no error, no entry in the addon list.
> 2. **Renaming the `.toc` instead will not save you.** pfUI finds its own media directory
>    by probing a fixed list of folder names:
>    ```lua
>    local tocs = { "", "-master", "-tbc", "-wotlk" }
>    ```
>    Anything outside that list leaves `pfUI.path` unset, and every icon, border and font
>    path breaks.
>
> This also means launchers with an "add custom git addon" feature **cannot install this
> correctly** — they name the folder after the repository. Install it by hand.

**Download**

1. Grab the [latest code](https://github.com/roby-brok/pfUI/archive/refs/heads/octo.zip) (branch `octo`)
2. Unpack the zip — you get a folder called `pfUI-classicAPI-octo`
3. **Rename it to `pfUI`**
4. Move it into `Wow-Directory\Interface\AddOns`
5. Restart WoW

**Or with git**, which makes updates a `git pull`:

```sh
cd Wow-Directory/Interface/AddOns
git clone -b octo https://github.com/roby-brok/pfUI.git pfUI
```

That trailing `pfUI` is what names the folder correctly.

**[ClassicAPI](https://github.com/brues-code/ClassicAPI) is required** — without the DLL
this build does not work. Keep a non-ClassicAPI pfUI around if that matters to you.

## DLL Enhancements

Since pfUI 6.0.0 includes integrations with client-side DLLs for enhanced functionality. These DLLs are permitted on Octo WoW:

### [ClassicAPI](https://github.com/brues-code/ClassicAPI)

Provides:
- C_NamePlate - Event-driven nameplates (no more per-frame WorldFrame scanning) with real per-plate unit tokens and GUIDs
- C_UnitAuras - Replaces over 3k lines of hand-rolled aura tracking
- C_Spell - Replaces thousands of hardcoded spell names for each locale and powers castbar
- Real cast bars - Actual cast/channel timing, spellID and interrupt state for any unit (C_Spell.UnitCastingInfo)
- Focus - A genuine `focus` unit plus `/focus` and `/clearfocus` (FocusUnit / ClearFocus)
- C_EquipmentSet - Full Equipment Manager with GUID-tracked gear sets (tells apart duplicate/enchanted items)
- Instant Bag Sorting - C_Container.MoveItem / SwapItems instead of cursor pickup/drop
- Sell junk in one call - C_MerchantFrame.GetNumJunkItems / SellAllJunkItems
- Real item data - C_Item counts, quality, sell price and item info by ID
- GUID-based targeting - Nameplates, mouseover and focus resolve by GUID, not by name text
- Faster, safer profile sharing - Engine-side serialize/compress/base64 via C_EncodingUtil
- C_Timer - After / NewTicker replacing hand-rolled OnUpdate throttles
- Feign death, shapeshift and quest-item detection via real API calls
- Mouseover Unit Frames
- Click-casting
- Loot Roll History (/loothistory)
- New item highlighting
- Plenty other functions

### [Nampower](https://github.com/brues-code/nampower)

Provides:
- Spell queue indicator
- GCD indicator

### [SuperWoW](https://github.com/balakethelock/SuperWoW)

Provides:
- Tracks party/raid units on the minimap

### [UnitXP_SP3](https://github.com/brues-code/UnitXP_SP3)

Provides:
- Line of Sight detection
- Behind detection
- Accurate distance calculations
- OS notifications

Use `/pfdll` in-game to check which DLLs are detected.

## Commands

    /pfui         Open the configuration GUI
    /pfdll        Show DLL detection status (SuperWoW, Nampower, UnitXP)
    /pfbehind     Test Behind/LOS detection on current target
    /clickthrough Toggle clickthrough mode (or /ct)
    /share        Open the configuration import/export dialog
    /gm           Open the ticket Dialog
    /rl           Reload the whole UI
    /farm         Toggles the Farm-Mode
    /pfcast       Same as /cast but for mouseover units
    /focus        Creates a Focus-Frame for the current target
    /castfocus    Same as /cast but for focus frame
    /clearfocus   Clears the Focus-Frame
    /swapfocus    Toggle Focus and Target-Frame
    /pftest       Toggle pfUI Unitframe Test Mode
    /abp          Addon Button Panel
    /loothistory  Show Loot Roll History

## Languages
pfUI supports and contains language specific code for the following gameclients.
* English (enUS)
* Korean (koKR)
* French (frFR)
* German (deDE)
* Chinese (zhCN)
* Spanish (esES)
* Russian (ruRU)

## Recommended Addons
* [pfQuest](https://github.com/brues-code/pfQuest) A simple database and quest helper
* [SuperCleveRoidMacros](https://github.com/brues-code/SuperCleveRoidMacros) Supports modern macro formats

## Plugins
* [pfUI-eliteoverlay](https://shagu.org/pfUI-eliteoverlay) Add elite dragons to unitframes
* [pfUI-fonts](https://shagu.org/pfUI-fonts) Additional fonts for pfUI
* [pfUI-CustomMedia](https://github.com/mrrosh/pfUI-CustomMedia) Additional textures for pfUI
* [pfUI-Gryphons](https://github.com/mrrosh/pfUI-Gryphons) Add back the gryphons to your actionbars

## FAQ
**What does "pfUI" stand for?**  
The term "*pfui!*" is german and simply stands for "*pooh!*", because I'm not a
big fan of creating configuration UI's, especially not via the Wow-API
(you might have noticed that in ShaguUI).

**How can I donate?**  
The people who wrote this come first — [Shagu](https://github.com/sponsors/shagu) for pfUI
itself, and [brues-code](https://buymeacoffee.com/brues) for the ClassicAPI Edition and the
ClassicAPI DLL. If the OctoWoW patches in *this* fork have been useful to you, mine is
[here](https://buymeacoffee.com/robybrok) — but please do the other two first.

**How do I report a Bug?**  
**Check whether it happens on [upstream](https://github.com/brues-code/pfUI) first.** This
fork is a thin layer on top; almost every bug belongs in
[brues-code's tracker](https://github.com/brues-code/pfUI/issues), and reporting it there
gets it fixed for everyone rather than just for OctoWoW. Only open an issue
[here](https://github.com/roby-brok/pfUI/issues) if it is specific to something
listed in [CHANGES-octo.md](CHANGES-octo.md).

Either way — please provide as much information as possible.
If there is an error message, provide the full content of it. Just telling that "there is an error" won't help any of us.
Please consider adding additional information such as: since when did you got the error,
does it still happen using a clean configuration, what other addons are loaded and which version you're running.
When playing with a non-english client, the language might be relevant too. If possible, explain how people can reproduce the issue.

**Where is the happiness indicator for pets?**  
The pet happiness is shown as the color of your pet's frame. Depending on your skin, this can either be the text or the background color of your pet's healthbar:

- Green = Happy
- Yellow = Content
- Red = Unhappy

Since version 4.0.7 there is also an additional icon that can be enabled from the pet unit frame options.

**Can I use Clique with pfUI?**  
This addon already includes support for clickcasting. If you still want to make use of clique, all pfUI's unitframes are already compatible to Clique-TBC. For Vanilla, a pfUI compatible version can be found [Here](https://github.com/shagu/Clique/archive/master.zip). If you want to keep your current version of Clique, you'll have to apply this [Patch](https://github.com/shagu/Clique/commit/a5ee56c3f803afbdda07bae9cd330e0d4a75d75a).

**Where is the Experience Bar?**  
The experience bar shows up on mouseover and whenever you gain experience, next to left chatframe by default. There's also an option to make it stay visible all the time.

**How do I show the Damage- and Threatmeter Dock?**  
If you enabled the "dock"-feature for your external (third-party) meters such as DPSMate or KTM, then you'll be able to toggle between them and the Right Chat by clicking on the ">" symbol on the bottom-right panel.

**Why is my chat always resetting to only 3 lines of text?**  
This happens if "Simple Chat" is enabled in blizzards interface settings (Advanced Options).
Paste the following command into your chat to disable that option: `/run SIMPLE_CHAT="0"; pfUI.chat.SetupPositions(); ReloadUI()`

**How can I enable mouseover cast?**  
On Vanilla, create a macro with "/pfcast SPELLNAME". If you also want to see the cooldown, You might want to add "/run if nil then CastSpellByName("SPELLNAME") end" on top of the macro.

**Everything from scratch?! Are you insane?**  
Most probably, yes.

---

## 🤝 Credits & Acknowledgments

- **Shagu** - Original pfUI creator ([https://github.com/shagu/pfUI](https://github.com/shagu/pfUI))
- **me0wg4ming** - pfUI fork maintainer and Turtle WoW enhancements
- **jrc13245** - Nampower, UnitXP, and BGScore module integration ([https://github.com/jrc13245/](https://github.com/jrc13245/))
- **SuperWoW Team** - SuperWoW framework development
- **avitasia** - Nampower DLL development
- **konaka** - UnitXP_SP3 DLL development
- **Turtle WoW Team** - For the amazing Vanilla+ experience
- **Community** - Bug reports, feature suggestions, and testing

---

## 📄 License

Same as original pfUI - free to use and modify.

---
