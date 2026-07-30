# BEACON: Adapting Tactical Heads-Up Display Paradigms to Multifamily Leasing on Consumer AR Glasses

**Ace Venenciano**
Independent Researcher · Los Angeles, CA
July 30, 2026 · Working paper v1.0

---

## Abstract

Leasing agents in multifamily housing lose the opening minutes of every prospect interaction to inventory search: translating a stated preference ("two bedroom, top floor, we have a dog") into concrete available units requires consulting a property-management system (PMS) mid-conversation. We present **BEACON**, a spatial leasing-intelligence system that renders a building's live vacancy state as a heads-up display in the agent's field of view, borrowing interface paradigms from military mission-command headsets — most directly Anduril's EagleEye — and re-targeting them at a civilian, revenue-critical workflow. BEACON comprises (1) a natural-language unit-matching engine over a live building model with a built-in Fair Housing guard, (2) an operations console organized around a stacking plan and dollar-denominated vacancy exposure, and (3) **BEACON GLASS**, a working in-lens application for the Meta Ray-Ban Display built on Meta's Wearables Device Access Toolkit web-app runtime (opened to third parties May 14, 2026). We instantiate the system on a real 299-unit Hollywood high-rise using its published floor plans and pricing, describe the design constraints of a 600×600 monocular additive display driven by an EMG wristband, and specify a motion-design system derived from a comparative study of the subject property's own marketing site and tactical FUI conventions. We argue that the leasing tour is an unusually good early workload for consumer AR glasses — hands-busy, eyes-busy, spatially anchored, and economically measurable — and that as of this writing the niche is commercially unoccupied.

**Keywords:** augmented reality, heads-up display, smart glasses, proptech, multifamily leasing, natural-language interfaces, fair housing, FUI

---

## 1. Introduction

An in-person apartment tour runs 30–45 minutes, and a leasing agent sustains at most 8–10 quality tours per day [7]. Industry platform data put agent administrative load at 30–60 hours per month [8], and RealPage market analytics measured the average U.S. unit at 34.4 vacant days between leases at the end of 2024 — roughly 4 days worse than pre-pandemic norms [5]. At Los Angeles Class-A rents, each vacant day carries $110–170 of unrecoverable loss per unit; concessions, present on ~40% of U.S. Zillow rental listings in 2025–26 [6], compound the cost of slow leasing. The tour itself contains a structural inefficiency: the moment a prospect states preferences, the agent must break engagement to search the PMS. The information exists; it is simply not where the agent's eyes are.

Military mixed-reality programs have converged on an answer to the analogous problem. Anduril's EagleEye headset renders a persistent compass, a minimap, color-coded tracked entities that survive occlusion, teammate ("blue force") positions resolved to specific floors of specific buildings, and mission context — all sourced from a unified sensor network (Lattice) and presented without demanding the operator's hands or focal attention [9, 10]. Our thesis is that this interface grammar — *acquire, lock, route* — transfers cleanly to leasing: units are tracked entities, the stacking plan is the minimap, teammates are co-agents on tour, and the "mission" is a prospect's stated need.

Two 2025–26 platform shifts make the transfer practical rather than speculative. First, Meta shipped Ray-Ban Display ($799 including the EMG-based Neural Band; monocular 600×600 waveguide, ~20° FOV, up to 5,000 nits) [1]. Second, on May 14, 2026, Meta opened the in-lens display to third-party developers, including a **web-app runtime**: standard HTML/CSS/JS served from any public HTTPS URL executes directly on the glasses, with Neural Band gestures delivered as keyboard events [2, 3]. Distribution remains a developer preview (≤100 testers per release channel; public publishing expected later in 2026), and third-party apps cannot yet access the camera, microphone, voice, or Meta AI [3]. BEACON is designed inside exactly these constraints.

**Contributions.** (i) A task analysis mapping mission-command HUD idioms onto the leasing tour; (ii) a working three-surface system — web HUD, ops console, and a real in-lens app — instantiated on a real 299-unit building's public floor-plan and pricing data; (iii) a compliance-by-construction *Fair Housing guard* for preference-based matching; (iv) a specified, implemented motion system derived from a teardown of the subject property's marketing site and validated against color-vision-deficiency constraints; (v) a market analysis indicating the smart-glasses leasing niche is unoccupied as of July 2026.

## 2. Background and Related Work

**Prospect-facing proptech.** The multifamily tooling market points overwhelmingly at the *prospect*: interactive availability maps embedded in marketing sites (Engrain SightMap, the de facto standard, priced $29–99/property/month and resold by Yardi RentCafe [4]); 3D and video touring (Matterport, Peek, Realync); self-guided touring (Tour24, Rently); and AI leasing assistants that answer inquiries before the visit (EliseAI). CRMs (Funnel, Knock/RealPage) organize the funnel. None of these operates *during* the guided tour, in the agent's field of view. The nearest adjacent system is SparX, which performs tablet-based AR staging during tours and reports a 56% lift in lease conversion [11] — evidence that in-tour AR affects outcomes, delivered on the wrong (hands-occupied) form factor.

**PMS data access.** Availability truth lives in four systems of record (Yardi, RealPage, Entrata, AppFolio), all gated behind partner programs of varying openness; Entrata's 2024 developer program is the most accessible, while Yardi interface licenses run ~$25K/year [4]. BEACON therefore treats PMS sync as read-only and supports a nightly-export fallback requiring no integration approval.

**Tactical HUDs and FUI.** EagleEye's published interface work [9, 10] and the broader fictional-UI (FUI) literature establish conventions we adopt: persistent orientation instruments (compass tape), reticle lock-on as the acquisition verb, draw-on leader lines, restrained ambient motion signaling liveness, and color as a strict semantic channel. We also adopt what those systems refuse: no decorative motion on the interaction path, no perpetual animation on non-signal elements.

**Consumer AR platform.** The Wearables Device Access Toolkit initially (Dec 2025) exposed only camera/audio streaming to paired phone apps; the May 2026 release added in-lens rendering via native templated components or the web runtime [2, 3]. The web runtime's properties — fixed 600×600 viewport, no scrolling, black-renders-transparent additive display, gesture events as arrow/Enter keys, no camera/mic/voice — constitute, to our knowledge, the first commodity path for third parties to ship custom HUD content on mass-market glasses.

## 3. System Design

### 3.1 Building model

BEACON maintains a live model of one property. Our reference deployment models **Lumina Hollywood** (1522 Gordon St; 22 stories; 299 residential units above ground-floor retail and three creative-office levels; built 2015; Morguard-managed [12]) using the property's sixteen published floor plans (studio 0x1A, 576 ft², from $2,358, through 2x2E, 1,506 ft²) and published pet policy (no pet deposits, no weight limits). Units are arranged in 15 vertical stacks over 20 residential floors; each stack carries a plan and a facade orientation that grounds view semantics (N: Hollywood Sign/Hills; E: Griffith; S: downtown skyline; W: sunset). Unit *statuses* — occupied, vacant-ready, in-turn, on-notice, model — are simulated in the demo at a 96.0% occupancy that mirrors the metro's measured 95.9% stabilized occupancy [6]. In production these statuses stream read-only from the PMS.

### 3.2 Match engine and Fair Housing guard

Prospect requests are parsed from free text into a typed preference structure: bedroom count, floor disposition (top/high/low/specific), budget ceiling, view axis, pet ownership, den/office need, urgency. Hard constraints (bedrooms, budget, move-in feasibility) filter; soft preferences score, with per-factor contributions retained so every match carries a human-readable *why* ("top of tower · corner residence · dog run 1 floor away"). Availability tiers weight the score (ready > in-turn > on-notice), and on-notice units surface separately as "coming available," converting the 60-day notice pipeline into sellable inventory.

Two design decisions matter more than the scoring itself. First, *explainability is the product*: an agent repeating a reason chip aloud performs expertise; an opaque ranking would be unusable mid-conversation. Second, the **Fair Housing guard**: the parser detects references to protected classes (familial status in "no kids around," etc.), refuses to convert them into preferences, and displays a visible notice that the criterion was ignored, with an audit log. Matching is thereby constrained *by construction* to unit attributes — floor, plan, price, dates, amenity distance — a materially stronger compliance posture than policy training layered on discretionary human search, and, in our pitch testing, the single feature most valued by management-side stakeholders.

### 3.3 Surfaces

**Agent HUD (web).** The hero surface renders the tower as a schematic elevation — the minimap idiom — with a compass tape whose heading slides to the best match's facade bearing. A query triggers a scanline sweep; matched units are *acquired*: four corner brackets converge (260 ms, 70 ms rank stagger), a double-ring radar ping fires (continuous only on rank 1; three cycles then hold on lower ranks), leader lines draw outward to rank-tagged callouts, and match cards enter with a 55 ms stagger. Routing renders as waypoint text with derived cost: "23 FLOORS UP · EST ~2 MIN · N FACE."

**Ops console.** The manager surface is a 299-cell stacking plan with CVD-validated status colors (§3.4), KPI tiles that lead with *dollar-denominated exposure* (the reference deployment carries ≈$41.7K/month of vacant rent) rather than unit counts, per-unit daily carry cost, and a one-tap *send-to-HUD* handoff that demonstrates cross-surface continuity: the agent's query bar visibly receives the unit and the acquisition sequence runs.

**BEACON GLASS (in-lens).** The glasses app accepts the display's real constraints rather than miniaturizing the web HUD. With no voice or free-text input available to third-party apps, the interaction model is *cycle-and-commit* over Neural Band gestures: horizontal swipes cycle preset prospect requests, vertical swipes cycle ranked matches, pinch toggles a route view whose steps draw sequentially (the only sanctioned overshoot animation in the system), and the compass tape tracks the active unit's facade. Type is set large (unit numbers at 62 px) for a 600×600 monocular field; the background is pure black, which the additive waveguide renders as transparency, so the interface reads as sparse luminous annotation over the real lobby rather than a floating rectangle. A blue-force team rail (co-agents' floors) and tour-count mission context complete the EagleEye mapping.

### 3.4 Motion and color system

Because the deployment property's own marketing site defines the incumbent visual bar, we performed a teardown: luminahollywood.com is a jQuery-era agency template animated entirely with stock viewport-triggered fades, 60–100 s Ken Burns zooms, and `transition: all` hovers — professional photography with no motion identity [13]. BEACON's counter-position is a single orchestrated system specified numerically (full dossier in `ANIMATION-STUDY.md`): a four-easing token set; a ≤1.5 s boot sequence in which the tower powers on floor-by-floor (14 ms/floor); entrance/exit asymmetry (enter ~120 ms, settle ~200 ms); expo-out count-ups on all numerics via a shared rAF ticker; ambient liveness limited to a ≥30 s, ≤8%-opacity sustain sweep; and a consolidated `prefers-reduced-motion` collapse. Status colors were not chosen but *computed*: candidate palettes were iterated through a six-check validator (OKLCH lightness band, chroma floor, pairwise color-vision-deficiency ΔE, normal-vision separation floor, surface contrast) until the vacant/turn/notice triad (#17A281/#4A90D9/#BC8428) passed all checks on the dark surface, with texture as the secondary encoding for the model-unit class.

## 4. Evaluation

Formal field evaluation awaits a pilot deployment; we report three preliminary forms of evidence.

**Latency of the core loop.** The engine resolves a parsed request over 299 units in well under a millisecond in-browser; the presented time-to-first-match is deliberately theatrical (an 880 ms acquisition sweep) and still two orders of magnitude below the minutes-long PMS console workflow it replaces. The pilot protocol (§5) measures the human loop, not the software loop.

**Correctness of the demo corpus.** Headless tests verify the model reproduces exactly 299 units, 96.0% occupancy, and story-consistent top matches for the five scripted prospect requests (top-floor two-bed → the 1,440 ft² 24th-floor corner; dog owner → the unit one floor above the amenity-deck dog run, annotated with the property's real no-deposit pet policy; protected-class phrasing → guard fires, matching proceeds on unit criteria only).

**Market whitespace.** Multi-angle search in July 2026 found no shipping smart-glasses or heads-up product for leasing agents; the nearest neighbors are prospect-facing maps (Engrain), tablet AR staging (SparX), and sales-gallery Vision Pro deployments in the for-sale segment [4, 11]. Concurrently, Meta/EssilorLuxottica smart-glasses volume exceeded 7M units in 2025 [4]. Hardware supply and software whitespace rarely align this cleanly.

## 5. Pilot protocol and business framing

A 60-day single-building pilot measures: (1) seconds from stated need to first unit shown (baseline: minutes); (2) tours per agent per day against the 8–10 ceiling; (3) days-vacant on pilot-period leases versus the trailing-90 average, valued at the measured $110–170/day carry. Pricing is anchored to category norms ($1–5/unit/month PMS band; $29–500/property/month point solutions [4]) at $199/property + $1/unit/month — for the 299-unit reference tower, ≈1% of one month's vacancy exposure. A −3 day movement in days-vacant on ten turns per year repays the subscription several times over.

## 6. Limitations and Ethical Considerations

*Platform.* BEACON GLASS runs today only in developer preview on a US-only, supply-constrained device, without third-party voice; the natural spoken interaction ("she said two-bed, top floor" → lens updates) awaits Meta exposing speech or Meta AI to third-party display apps. All in-lens claims in our materials are scoped to this reality. *Data.* The demo's floor plans and pricing are real but scraped from public listings at a point in time; statuses are fabricated, and the demo labels them as such — presenting fabricated availability as live data to a prospect would be deceptive and is contractually excluded from the pilot design. *Fairness.* The guard prevents *encoding* protected-class preferences, but steering can also arise from facially neutral proxies (e.g., systematic amenity weightings correlating with familial status); production deployment requires periodic disparate-impact review of score distributions, and our GTM plan requires fair-housing counsel sign-off before first paid contract. *Privacy.* Glasses in a lobby carry surveillance optics; it is materially relevant — and worth stating on a lobby placard — that third-party display apps *cannot access the camera or microphone* on this platform [3]. *Attention.* Monocular HUDs can capture attention at the expense of the interpersonal task they serve; the sparse-annotation design (black-transparent ground, one looping ping maximum) is a mitigation, not a solution, and pilot observation should watch for agents "reading the lens" at prospects.

## 7. Conclusion and Future Work

BEACON demonstrates that the mission-command HUD grammar — persistent orientation, entity acquisition, blue-force context, waypoint routing — maps onto multifamily leasing with almost no translation loss, and that the May 2026 opening of Meta's in-lens web runtime makes the mapping shippable by a single developer today. Future work proceeds on three axes: PMS-live deployment through the Entrata API path; voice-driven matching when the platform exposes it; and the spatial roadmap already framed in the product's Vision surface — a command-table volumetric building model for the leasing office, and Quest walkthroughs of the prospect's *specific* unit, including units still occupied at tour time. The economic argument is unusually legible for an AR application: vacancy is a per-day, per-unit dollar figure, and every day the interface saves is directly priced.

---

## References

[1] Meta. *Meta Ray-Ban Display* (announcement and specifications), Sept 2025; UploadVR, "Meta Ray-Ban Display Glasses Officially Announced," 2025.
[2] Meta Developers. "Build for display glasses starting today," May 14, 2026. https://developers.meta.com/blog/build-for-display-glasses/
[3] Meta. *Wearables Device Access Toolkit* documentation — Web Apps runtime and FAQ. https://wearables.developer.meta.com/docs/develop/webapps/
[4] Engrain. *SightMap pricing*, https://www.engrain.com/sightmap/pricing; Yardi press release, "RentCafe Partners with Engrain," Oct 2024; category pricing per vendor-published rates (Tour24, Rently, Realync, EliseAI), retrieved July 2026.
[5] RealPage Market Analytics. Vacant-days-between-leases analysis, January 2025.
[6] Zillow Research, rental concessions tracking, 2025–2026; Yardi Matrix, Los Angeles multifamily report (data through Dec 2025); Kidder Mathews, LA multifamily Q1 2026.
[7] Leasey.AI and property-management industry guides on tour duration and daily showing capacity, retrieved July 2026.
[8] Rently, *2026 Renter Touring Expectations Report* and agent-workload analyses.
[9] UploadVR. "Anduril Reveals EagleEye Military XR Headset Design & Interface Clips," 2026. https://www.uploadvr.com/anduril-eagleye-headset-design-reveal-interface-mockups/
[10] Road to VR. "Anduril Shows First Look at Capabilities of 'EagleEye' Military XR Headset," 2026; VR & AR Wiki, "Anduril EagleEye."
[11] SparX published case data on AR-staged tour conversion, retrieved July 2026.
[12] The Real Deal LA. "Canadian REIT Takes Full Ownership of Controversial Hollywood Tower," Feb 2022; Apartments.com listing, *Lumina Hollywood*, retrieved July 2026.
[13] Direct asset analysis of luminahollywood.com (theme CSS, script bundles, floor-plan module), July 2026; full teardown in `ANIMATION-STUDY.md`.

---

*Demo artifacts: main HUD and BEACON GLASS source in this repository (`index.html`, `glass.html`). All unit statuses in the demo corpus are simulated; floor plans and pricing reflect public listings as of July 2026.*
