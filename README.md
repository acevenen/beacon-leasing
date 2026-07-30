# BEACON — Spatial Leasing Intelligence
Demo build for **Lumina Hollywood** — 1522 Gordon St, Hollywood: 22 stories, 299 units, Morguard-managed. The tower, floor plans (0x1A–2x2E), rents, and pet policy come from their public listings; unit statuses are simulated.

HUD design language modeled on Anduril's **EagleEye** (compass tape, lock-on reticles, blue-force team rail, waypoint routing with ETA), rebuilt for leasing and embedded into the Meta Ray-Ban Display + Neural Band.

## What's in this folder

| File | What it is |
|---|---|
| [index.html](index.html) | The main demo — 01 Agent HUD (natural-language matching, scan sweep, reticle lock-on, compass heading, team rail, routing with ETA, Fair Housing Guard) · 02 Ops Console (299-unit stacking plan, KPIs with count-ups, $41.7K exposure, live feed, send-to-HUD) · 03 Vision. Self-contained, phone-friendly. |
| [glass.html](glass.html) | **BEACON GLASS** — the actual in-lens app for Meta Ray-Ban Display: 600×600, black = transparent, compass tape, digit-scramble readouts, self-drawing routes. Neural Band gestures arrive as key events (◀▶ requests · ▲▼ units · ⏎ route). Host at any HTTPS URL, load in developer mode (Meta Wearables Device Access Toolkit web-apps preview, open since May 14, 2026). |
| [SALES-SCRIPT.md](SALES-SCRIPT.md) | Word-for-word 15-minute pitch with demo beats, objection handling, pilot close, sourced stat card, follow-up email. |
| [GTM-ACTION-PLAN.md](GTM-ACTION-PLAN.md) | Positioning, competitive map, pricing, ICP, PMS sequencing, 30/60/90 plan, pilot KPIs, risks. |
| [ANIMATION-STUDY.md](ANIMATION-STUDY.md) | The motion-design dossier: teardown of luminahollywood.com (jQuery template, stock fades — beatable), market study, and the 18-item upgrade spec this demo implements. |
| [RESEARCH-PAPER.md](RESEARCH-PAPER.md) | Working paper: adapting tactical HUD paradigms (Anduril EagleEye) to multifamily leasing on consumer AR glasses — system design, evaluation, limitations, ethics, references. |

## Demo in 60 seconds
1. Open `index.html` → boot sequence runs, then auto-demos "Two bedroom, top floor" → **2402** locks on.
2. Click the chips — especially **"Penthouse with a den, no kids around"** (Fair Housing Guard) and **"One bed — we have a dog"** (611, one floor from the L5 dog run, "no pet deposit" called out).
3. Ops Console → KPIs count up → click **2402** → **Send to agent HUD**.
4. Open `glass.html` at 600×600 (or on the glasses): arrows cycle requests/units, Enter draws the route step by step, compass tracks the unit's building face.

## Honest platform status (July 2026)
In-lens third-party web apps: **real, today, developer preview** (≤100 testers per release channel). Public distribution: expected later in 2026. Voice/Meta AI/camera in third-party display apps: not yet — gestures only. Ray-Ban Display: $799 incl. Neural Band, US-only.
