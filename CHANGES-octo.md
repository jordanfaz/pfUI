# Changes on top of brues-code/pfUI

Everything on the `octo` branch that is not in
[brues-code/pfUI](https://github.com/brues-code/pfUI) — **38 files, +627 / −160**,
measured against upstream `6e1f8095`.

The delta shrank rather than grew: most of section 1 has been merged upstream (PRs
[#39](https://github.com/brues-code/pfUI/pull/39) and
[#40](https://github.com/brues-code/pfUI/pull/40)), so those files no longer differ.

Section 1 is **bugs in the upstream tree**: they affect every user of that fork, not just
OctoWoW, and are the part worth pulling upstream. Sections 2–4 are local preferences and
restorations that are only interesting if you want them.

Each fix was verified against the upstream implementation before being written — several
July fixes from our older fork turned out to be unnecessary here because the upstream
rewrite already solved them, or solved them *better*, and were dropped rather than ported.

---

## 1. Bugs found in the upstream tree

### Breaks every install, including the release zips
| | |
|---|---|
| `init/skins.xml:44-45` | Included `custom_merchant.lua` and `arena_score.lua`, **neither of which is tracked in git**. Two `Error loading` lines at every login, and both skins absent from every release — the release workflow packages the repo. (`b338b4a1`) |

### Crashes and errors
| | |
|---|---|
| `modules/map.lua` | Ctrl+scroll re-anchored the world map using the frame `GetPoint()` returned. Once anything else is anchored to `WorldMapFrame` that throws `<unnamed> is dependent on this` — and the error **aborts the rest of the handler, so `SetScale` never runs** and zoom silently does nothing. (`bf055d87`) |
| `modules/cooldown.lua` | `if not parent then this:Hide() end` — no `return`, so it fell straight through to `parent:GetName()` on the nil it had just tested for. (`c5bc9599`) |
| `modules/roll.lua` | An uncached item indexed `pfUI.roll.cache[nil]` → *table index is nil*. (`0f8406ff`) |
| `modules/unitxp.lua` | The logout handler stops three indicators to avoid crash 132, but free-frame distance mode polls from **its own scanner frame**, which was never exposed or stopped. (`ed161fe3`) |

### Silently wrong behaviour
| | |
|---|---|
| `api/unitframes.lua` | ~~Unit frames set no `OnEnter`, so hovering one no longer published the native mouseover unit and `@mouseover` macros did nothing over the frames.~~ **Not a bug — withdrawn 2026-08-10.** It was real when found, and was independently reported as [issue #37](https://github.com/brues-code/pfUI/issues/37), but ClassicAPI **1.9.5** fixed it at the DLL layer: the engine mouseover is now driven by the frame's `unit` attribute. Re-tested on 1.9.6 with our handler removed at runtime (`handler=false`) — hovering the player frame still reports `MO=Sinofpride`. Our Lua handler was duplicating the engine, so it has been deleted, and upstream removing the now-unreadable `showtooltip` option was correct. |
| `modules/chat.lua` | Whisper detection tests for the colour code at position 1, but the timestamp is prepended **first** — so with timestamps enabled *every* whisper failed detection, losing both the recolour and the correct history entry. (`4b69d597`) |
| `modules/macrotweak.lua:16` | `if ChatFrameEditBox._AddHistoryLine then` — that field is the backup slot **this block creates**, so it is nil until the block runs. The chat-history filter therefore never installed at all. (`4068110d`) |
| `modules/mapreveal.lua` | `explorecaches` is keyed by the plain area name, but the hover frame carried only a decorated `"map (area)"` string, so every lookup missed and the hover highlight never fired. (`5e6fe969`) |
| `modules/socialmod.lua` | The friend-**offline** match was assigned unconditionally over the friend-**online** match, so coming online never recorded `lastseen`. (`ad927806`) |
| `modules/roll.lua` | `strfind(LOOT_ROLL_ALL_PASSED, LOOT_ROLL_PASSED)` has no captures, so `everyone` was always nil and never reached the blacklist — "Everyone has passed on: X" was counted as a real roller. (`0f8406ff`) |
| `modules/swingtimer.lua` | Off-hand detection accepted inventory type **21** (`INVTYPE_WEAPONMAINHAND`), which can never occupy the off-hand slot. Should be 22. (`9ab7f5f7`) |
| `modules/buffwatch.lua` | `fcache` is built once per config table and never invalidated, so ctrl/shift-clicking a skill onto the whitelist or blacklist did nothing until reload. (`f65f897c`) |
| `modules/firstrun.lua` | Three chat-setup steps printed "Chat module is disabled" and then carried on into the nil `pfUI.chat` they had just tested for. (`1af427e3`) |
| `libs/libpredict.lua` | ~~`UKNOWNBEING` / `UNKOWNBEING` — misspelled, so both resolve to nil.~~ **Wrong — reverted 2026-08-10.** `UKNOWNBEING` is Blizzard's own misspelling and *is* the real 1.12 global; `UNKNOWNBEING` does not exist. "Correcting" it turned two working guards into dead ones. `UNKOWNBEING` alone was the genuine typo. BigWigs' RosterLib and StatCompare both use `UKNOWNBEING` — the check I should have made. Merged upstream, then fixed by brues in `b6931359`. |
| `modules/superwow.lua` | `SUPERWOW_VERSION == "1.5"` exact string compare. **Not hypothetical — SuperWoW here is 2.2** (`SUPERWOW_VERSION="2.2"` is embedded in `SuperWoWhook.dll`), so the test was already false and the GUID-to-name combat-text hook was dead. (`82a37752`) |
| `api/api.lua` + `init/modules.xml` | ~~`GetPerfectPixel` measured against the `uiScale` CVar, which caps at 1.0 while the Huge/Large presets push `UIParent` past it.~~ **Wrong — reverted 2026-08-10**, merged upstream then reverted by brues in `9cabdf29`. The `gxResolution` nil guard in the same function was sound and stays. **Two postscripts from later the same day.** *One:* the revert was silently undone for ~11 hours — the upstream sync `60dd2ad5` auto-merged both files with no conflict (change-plus-revert nets to zero on upstream's side, so three-way merge kept ours), and this entry claimed the opposite of what the tree shipped until the evening audit diffed the files. Restored to upstream's version now. *Two:* an in-game probe then falsified the premise **both** commit messages assert: on the OctoWoW client `SetCVar("uiScale", 1.4222)` **sticks** — `cvar=1.4222222222222, eff=1.4222222566605` at the Huge preset — there is no 1.0 clamp here, so the two scale sources agree and neither the original fix nor the border-vanish failure mode can occur on this client. The cap story holds only for clients that do clamp (stock 1.12 registers `uiScale` as 0.64–1.0). Matching upstream is therefore a probe-proven behavioral no-op here, kept for zero drift. |
| `modules/pixelperfect.lua` | The preset-off restore path tested `if use == 1`, but `GetCVar` returns **strings**, so the branch could never be true and leaving a preset always landed on the hardcoded `0.9` fallback — and had the branch ever run, it would have restored the wrong variable (`tonumber(use)`, the flag, not the scale). Found 2026-08-10 while verifying the entry above; still live upstream. |
| `modules/unitxp.lua`, `modules/raid.lua` | `pfUI.env` has `__index` but no `__newindex`, so a bare global assignment inside a `RegisterModule` closure never reaches `_G`. Cost the `BattlefieldFrame_Show` override and `GROUP_REPLACE_PARTY`. (`617c8320`) |
| `modules/bags.lua` | Two byte-identical `frame.search` `OnHide` handlers installed back to back; the second overwrote the first. (`e7765044`) |

---

## 2. Performance

| | |
|---|---|
| `UnitHasAggro` | Concatenated `<u>target` / `<u>targettarget` per call per unit though `pfValidUnits` never changes after load, and cached only *positive* results — so the common case (nothing has aggro) rescanned the whole unit table on every call. Static triple list + a 0.3s negative cache. (`6645b031`) |
| `GetStatusValue` | Ran `GetUnitStats` and the whole formatting path for text slots set to `none`, then returned `""`. 40 raid frames × 6 slots per refresh. (`ad5353e4`) |
| `cooldown` | `GetParent` + `GetName` + a concat + two `_G` lookups **before** the 0.1s throttle could bail — every frame, per cooldown frame. (`c5bc9599`) |
| `loot` autoresize | The hook sat inside the per-slot creation loop, so **every slot frame** got an `OnUpdate` rebuilding the entire loot frame. N rebuilds per frame. (`5210b122`) |
| `nampower` reactive | `C_Spell.IsSpellUsable` + `SetShown` per icon, every frame, unthrottled. (`a90740fe`) |
| `player` | `UpdateConfig` → `EnableScripts` → `SetScript("OnUpdate", …)` discards the throttle wrapper installed at load, so any config change left the frame running unthrottled until reload. (`6b83208b`) |

---

## 3. Options restored from our older fork

- **Class-colour accent** — `pfUI.cr/cg/cb/chex` drive the signature mint, swapped for the
  player's class colour via a *Use Class Color* toggle. ~100 literals converted across both
  mint shades, including the `pf` logo, which is drawn pixel by pixel.
  (`c64b3593`, `9c047555`, `5aedfffe`, `161f48dd`)
  *Note: literals inside `T[...]` translation keys are deliberately left alone — rewriting
  the key at runtime makes the lookup miss and breaks localised clients.*
  - *Follow-up 2026-08-10:* the literal sweep could not catch signature colours living in
    **config defaults**, which materialise into SavedVariables and then colour text at
    runtime — found as cyan `73m` cooldown text on buff icons. Two existed:
    `appearance.cd.minutecolor` (`.2,1,1`, the palette's cyan sibling) and
    `bars.count_color` (true mint, action-bar stack counts). Both now follow the accent —
    but **only while the option still holds its stock default** and the toggle is on; a
    user-picked colour always wins, and the hour/day blues stay untouched because those
    are semantic unit-at-a-glance colours, not palette.
- **Hide Nameplates Out Of Combat** (`8bbae7d8`)
- **Per-unit portrait / buff / debuff X-Y offsets** — six keys, anchors were hardcoded to 0 (`9e54fd11`)
- **Hide Total Timer** for player, target and focus castbars (`f09003f7`)
- **Hide Gold Amount** in bags (`6e499d10`)
- Dropped the *Experimental* marker from three options that were audited and fixed (`ee482178`)

## 4. New

- **Target nameplate symbols**, rebuilt as **textures** rather than FontStrings. Nameplate
  FontStrings stop growing at roughly 32px and ignore `SetScale` because plates are
  `WorldFrame` children — both measured. A texture takes an explicit width/height and has
  no ceiling, so the size multiplier finally does something. Art, size, gap and colour are
  configurable. (`ec8ce272` and follow-ups)
- **BoE / BoU labels on bag and bank items**, tinted with the item's quality colour.
  Reads `bindType` from the `C_Item.GetItemInfo` call the slot update already makes for
  its quality scan, so it costs no extra lookup — and checks `C_Item.IsBound` for the
  per-instance soulbound bit, since `bindType` describes the item *template* and would
  otherwise keep saying BoE after the item had bound. Pre-ClassicAPI this needed a
  scan-tooltip compare against the localised `ITEM_SOULBOUND` string on every slot.
  Toggle: *Bags & Bank → Show BoE / BoU On Items*.
- **Castbar drawn above the unit frame stack** — it sat at frame level 8 against buff icons
  at 12, cooldown spirals at 14 and unit texts at 16, so a castbar placed over the aura rows
  was drawn underneath them. Now 20. (`9551cf3c`)
- **Custom Action Bar Background** — an *Appearance* checkbox + colour picker that recolours
  the action-bar button backdrops only, leaving the global *Background Color* in charge of
  every other frame. Off by default; applied after `CreateBackdrop` so slot-state border
  colouring is untouched.
- **The update-notify broadcast advertises the upstream base, not the fork version.**
  Giving the toc a real version (needed so the addon list and GUI stop saying "dev")
  re-armed `updatenotify.lua`, which broadcasts on the shared `pfUI-brues` prefix — and a
  stock build turns any higher number it hears into an update notice pointing at a release
  that would not exist. The advertised number is now pinned to the merged upstream release
  (`90018` = v9.0.18) independently of the toc, the same shielding OWThreat's `compatVer`
  does. **Maintenance rule: bump the constant when an upstream sync lands.**
