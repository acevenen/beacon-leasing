# BEACON — Go-To-Market Action Plan
### From the Lumina Hollywood demo to paying buildings. Written July 30, 2026.

---

## 1. What BEACON is, in market terms

**Category:** agent-facing spatial leasing intelligence.
**Wedge:** every incumbent points at the *prospect* (website maps, virtual tours, AI chat). Nobody points at the *agent mid-tour*. The moment a prospect says "two bed, high floor, we have a dog," today's agent turns their back and searches a PMS. BEACON answers in under a second, in the agent's field of view, with a route.

**The competitive map (verified July 2026):**

| Player | What they own | What they don't |
|---|---|---|
| Engrain SightMap | Prospect-facing unit maps on websites ($29–99/property/mo); Greystar, Bozzuto, Essex; Yardi resells it | The agent's eyes during the tour |
| Funnel / Knock (RealPage) | Leasing CRM, centralized ops | In-tour unit matching |
| Peek / Realync / Matterport | Virtual tours of floor-plan types | Live availability + matching |
| Tour24 / Rently | Self-guided (agentless) tours | The guided tour, which still closes best |
| EliseAI | AI answering leads before the tour | Everything after "hello" in person |
| SparX | Tablet AR staging on tours (claims 56% conversion lift — proof AR-on-tour sells) | Availability intelligence, glasses |

**Key finding:** searched from every angle — **no company is shipping smart-glasses / heads-up software for leasing agents as of July 2026.** Industry press speculates about it; no product exists. The white space is real, and Meta's May 2026 opening of the Ray-Ban Display to third-party apps started the clock. First credible mover gets the story, the case study, and the partner slot.

## 2. The Meta hardware reality (never overclaim this)

| True today | Not true yet |
|---|---|
| Ray-Ban Display: $799 incl. Neural Band, monocular 600×600 lens display, US-only, supply-constrained | International availability (paused indefinitely) |
| Third-party **web apps run in-lens today** (dev preview since May 14, 2026): HTML/JS from any HTTPS URL, 600×600, Neural Band gestures as key events | Public app distribution (Meta says later in 2026; "select partners" until then) |
| Distribution to a pilot team via developer release channels (**up to 100 testers**) | App store, monetization, consumer install |
| BEACON GLASS (`glass.html`) is such an app — deployable to a developer-mode device now | Third-party access to voice, Meta AI, camera, or mic in display apps (first-party only) |

**Pitch guardrail:** say *"in-lens app, running on the glasses today in developer mode; public distribution when Meta opens it later this year."* Never say "ships to consumers today," never promise voice-in-lens on a date.

## 3. Positioning & pricing

**Tagline:** *Spatial leasing intelligence. Every vacancy becomes a beacon.*
**Posture:** defense-grade software discipline applied to apartments (the Anduril lens: live common operating picture, one source of truth, interfaces that travel with the operator). Say "common operating picture for your building" to owners — it lands.

**Pricing (anchored to verified market norms — PMS $1–5/unit/mo; point solutions $29–500/property/mo):**
- **Pilot:** free, 60 days, one building, measured on 3 KPIs (below).
- **BEACON Core (web HUD + ops console): $199/property/mo + $1/unit/mo.** A 299-unit tower like Lumina Hollywood = $498/mo — under SightMap+EliseAI combined, over toy territory, and ~1% of one month of its vacancy exposure (~$41.7K).
- **BEACON GLASS add-on: $99/property/mo** once glasses distribution is public (pilot teams get it free forever — early-believer reward).
- Setup: $500, waived for the first five LA buildings. Annual billing optional at 2 months free. No long-term lock-in — confidence signal.

**ICP, in order:**
1. **Lease-ups and Class-A high-rises in LA, 130–400 units** — highest carry cost (~$130/day/unit), heaviest concession pressure (DTLA: ~5,100 units delivering 2026, "occupancy over rent"), most tours/day. Lumina Hollywood (22 stories, 299 units, Morguard) is the archetype — and the demo building.
2. Owner-operators with 2–10 buildings — one decision-maker, fast yes.
3. Third-party managers (Greystar/Bozzuto tier) — slow, but one regional VP unlocks dozens of buildings. Enter via the pilot case study, not cold.

**PMS integration sequencing (this decides who you can sell to):**
1. **Ship now, no integration:** nightly availability CSV/export upload — every PMS can do this; pilot-grade.
2. **Entrata first** — most open API program (2024 developer portal, sandbox, webhooks).
3. **AppFolio Stack** next (open marketplace, 1.2M+ connected units).
4. **RealPage RPX** when a customer demands it (certification process).
5. **Yardi last** — ~$25K/yr interface license + 3-mutual-client prerequisite. Do it when revenue justifies; until then the export path covers Yardi shops.

## 4. The 30 / 60 / 90-day plan

### Days 1–30 — weaponize the demo
- [ ] Film the 3-minute demo video: HUD queries → fair-housing guard → ops console → BEACON GLASS on the actual glasses. Phone-shot through the lens if possible; that clip *is* the outbound engine.
- [ ] Put the demo behind a clean URL (beacon-demo site) + a one-page site: the one-liner, the video, a pilot-request form.
- [ ] Enroll in **Meta's Wearables Developer program**, get BEACON GLASS on your own Ray-Ban Display in developer mode, and apply/inquire for the select-partner publishing track — being in that queue early is the moat.
- [ ] Build the LA target list: 40 buildings — every 2024–2026 DTLA/KTown/Culver lease-up, plus stabilized Class-A with visible concessions on Zillow (they're bleeding; 39.7% of listings offer concessions). Sources: Yardi Matrix new-delivery lists, Apartments.com "brand new" filter, CoStar if accessible.
- [ ] Warm outreach first: every PM, regional, and leasing director you know from your leasing-agent years. Script: "I built the thing we always wished we had — 15 minutes, I'll bring the glasses."

### Days 31–60 — land the flagship pilot
- [ ] Goal: **one signed pilot** (target: Lumina Hollywood itself — the demo is literally their tower, built from their public floor plans and pricing; walking in with their building mapped is the whole show. Buyer: the Morguard property/regional manager).
- [ ] Run the pilot on the export path (no PMS integration risk). Train the team in 20 minutes.
- [ ] Instrument everything. The three pilot KPIs: **(1) seconds from stated need → first unit shown** (baseline: minutes), **(2) tours/agent/day**, **(3) days-vacant on units leased during pilot vs trailing-90 average.**
- [ ] Weekly 15-min check-in with the PM; capture quotes for the case study.
- [ ] Meanwhile: 10 discovery meetings from the target list using SALES-SCRIPT.md. Even "no's" produce feature intel and referrals.

### Days 61–90 — the case study flywheel
- [ ] Publish the pilot case study: three numbers, agent quotes, 90-second video. Gate nothing.
- [ ] Convert the pilot to paid; ask for 2 referral intros as part of the deal ("reference building" status).
- [ ] Take the case study to industry surface area: **NMHC OpTech (Nov) and NAA Apartmentalize** booths/floor, AAGLA (LA apartment association) events, LinkedIn posts from your ex-agent POV ("I gave 2,000 tours; here's what I built").
- [ ] Start Entrata developer-program onboarding — first real integration.
- [ ] Begin the Greystar/Bozzuto conversation only now, with proof in hand. (Both already buy adjacent tech — Engrain's enterprise deal is Greystar; Bozzuto runs SparX AR.)

## 5. Metrics that decide everything

| Metric | Target | Why it sells |
|---|---|---|
| Need → first unit shown | < 15 seconds | The demo moment, quantified |
| Tours per agent per day | +1–2 over baseline (8–10 ceiling today) | More at-bats, same payroll |
| Days-vacant on pilot leases | −3 days vs trailing avg | −3 days × $130/day × 10 turns/yr ≈ **$3,900/yr per 10 units** — pays for BEACON 1× over per building |
| Agent adoption | > 80% of tours use BEACON by week 4 | Proves it's not shelfware |
| Fair-housing guard triggers | logged & reported | The compliance story writes itself |

## 6. Risks and pre-answers

- **Meta slips public distribution.** → Revenue never depends on it: Core is web-first; GLASS pilots run on the 100-tester channel. The glasses are the story, not the dependency.
- **Engrain wakes up.** → They're prospect-facing DNA, Yardi-channel-bound, and enterprise-slow. Speed + agent obsession + glasses partnership queue is the moat. If they call, that's an acquisition conversation, not a death sentence.
- **Fair-housing scrutiny of "AI matching."** → Lean in: BEACON's guard is the *feature*. Matching uses unit attributes only; protected-class inputs are detected, discarded, and logged. Get a fair-housing attorney to bless the matching-criteria doc before the first paid contract; put the letter in the sales deck.
- **PMS data access gets gated.** → The nightly-export path needs no one's permission and is the permanent fallback.
- **"AI glasses" privacy optics on-site.** → BEACON GLASS displays; it never records. Third-party display apps *can't even access the camera* — quote Meta's own platform rules. Add a lobby placard for pilots anyway.

## 7. The sequence, in one breath

Demo film → 40-building LA list → warm outreach → **one flagship pilot on the export path** → three KPIs → case study → paid + referrals → OpTech/AAGLA + LinkedIn → Entrata integration → regional operators → Meta public distribution flips on → BEACON GLASS goes from demo-closer to product line → holo table & Quest walkthroughs as the Phase-3 upsell for lease-up marketing budgets.

**North star:** every leasing agent in LA should feel naked giving a tour without BEACON — the way a pilot feels naked without a HUD.
