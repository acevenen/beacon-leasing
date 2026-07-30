# ANIMATION STUDY — Beating luminahollywood.com

Motion-design dossier for the BEACON demo (`index.html`, `glass.html`).
Goal: a full production tier above the Lumina Hollywood marketing site while staying
tactical-HUD — precision instrument, not luxury lifestyle. Everything below is
vanilla CSS/JS/SVG, single-file, CSP-safe (no CDNs, no libraries).

---

## 1. Their site — luminahollywood.com

### Stack (verified from live assets, July 2026)

| Layer | What they use |
|---|---|
| Platform | Jonah Digital agency template ("JDS" design system, `theme-4`), jQuery-era `scripts.min.js` (~120 KB) |
| Fonts | Adobe Typekit — **proxima-nova only** (all weights) |
| Brand color | `--jds-brand-color: #ff5335` (coral) on white/light neutrals; footer overlay `#555` |
| Hero | Mux-streamed 720p `.mp4` video loop |
| Scroll animation | **WOW.js + animate.css** — stock `fadeIn`/`fadeInUp`/`bounceIn` keyframes, default durations .75s–1s |
| Image motion | **Ken Burns** slow zoom on banners (60–100s animation-duration), `simpleParallax` fixed-background sections with `opacity 1s ease` crossfade |
| Carousels | Swiper + Owl Carousel (both shipped) |
| Floor plans | Grid of 16 `jd-fp-floorplan-card` cards with skeleton `pulse` loaders + bed-count filter buttons, plus an **Engrain SightMap iframe embed** (`sightmap-calculator-wrap`) for the interactive unit map |
| Transitions | Overwhelmingly generic: `all .1s ease`, `.2s`, `.3s`. Easings are animate.css stock (`cubic-bezier(.215,.61,.355,1)`, `(.175,.885,.32,1)`) — nothing custom |
| Copy tone | "Where the Aesthetic Live", "Made for Main Characters" |

### Animation inventory
1. WOW.js viewport-triggered `fadeIn` on header, callout items, footer socials (single generic effect reused everywhere).
2. Ken Burns 60–100s zoom on hero/banner photography.
3. Fixed-position parallax section images with 1s opacity crossfade.
4. Autoplay hero video (Mux).
5. Carousel slides (Swiper/Owl defaults).
6. Floorplan card skeleton `pulse` while images load.
7. `transition: all .1s ease` hovers on buttons/links.
8. The only genuinely interactive piece — the SightMap unit map — is **someone else's product in an iframe**.

### Verdict
Competent 2020-era template production. Strengths: professional photography, video
hero, skeleton loaders, a real interactive unit map (outsourced). Weaknesses: zero
motion identity — every reveal is the same stock fadeIn; no orchestration (elements
pop in whenever WOW.js fires); no custom easing; `transition: all` everywhere; the
signature interaction is an embed they don't control; jQuery + two carousel
libraries shipped to every page. **There is no craft in the motion — that is the
opening.** We beat them not with more effects but with one orchestrated, physical,
consistent motion system.

---

## 2. What the market's best do

Named techniques from award-tier property sites (Awwwards GSAP/ScrollTrigger
winners), luxury lease-up flagships, and tactical/FUI motion language
(Anduril-style kinetic brand work, EagleEye HUD). All reproducible in vanilla CSS/JS.

### Techniques

1. **Orchestrated load sequence** — page chrome, hero, and content enter in a
   deliberate order, 80–120ms between groups, everything settled < 1.5s. Nothing
   "pops"; the page assembles.
2. **Staggered card entrance** — `translateY(10–14px)` + `opacity 0→1`,
   350–450ms, `cubic-bezier(0.16, 1, 0.3, 1)` (expo-out), **50–70ms stagger** per
   card. Six cards resolve across ~420ms total.
3. **Number count-up** — stats tick from 0 (or scramble) to final over 600–900ms
   with expo-out sampling, `font-variant-numeric: tabular-nums` so digits don't
   jitter layout.
4. **Sliding shared indicator** — one underline element that *travels* between
   nav tabs, 240–300ms `cubic-bezier(0.65, 0, 0.35, 1)`, instead of per-tab
   border swaps.
5. **SVG draw-on lines** — `stroke-dasharray`/`stroke-dashoffset` (or
   `pathLength="1"`) animated 240–600ms; the FUI signature — leader lines,
   diagrams, and brackets *draw* rather than appear.
6. **Lock-on reticle** — four corner brackets converge onto a target from ~8px
   out, 200–300ms expo-out, then hold. (Anduril EagleEye: bounding boxes +
   tracked-asset markers; reticle-lock is the core tactical acquisition verb.)
7. **Skeleton shimmer during async work** — 1.2s pulse/sweep loop replaces stale
   content while loading; never show the old answer during a new query.
8. **Masked text reveal** — per-line or per-char rise from an `overflow:hidden`
   mask, 20–30ms/char stagger (Awwwards SplitText staple). Our typewriter is the
   tactical cousin — keep it, refine cadence.
9. **Hover micro-interactions, asymmetric timing** — enter ~120ms, leave ~200ms
   (leave slower reads as "settling"); animate specific properties, never `all`.
10. **Scroll/visibility-triggered reveals** — IntersectionObserver, threshold
    ~0.15, fire once; content earns its entrance when seen.
11. **Ken Burns ambient drift** — 60–100s scale 1→1.06 keeps photography alive
    (Lumina does this; the tactical analog is an ambient scan/sweep loop, not zoom).
12. **Slow-lerp cursor followers** — tooltips/cursors ease toward the pointer at
    ~0.2 lerp per frame instead of snapping.

### Standard numbers (motion-system baseline)

| Class | Duration | Easing |
|---|---|---|
| Micro-interaction (hover, press, toggle) | 100–200ms (enter ~120, leave ~200) | `cubic-bezier(0.2, 0, 0, 1)` |
| Element entrance | 250–400ms | ease-out family — `cubic-bezier(0, 0, 0.2, 1)`; hero moves `cubic-bezier(0.16, 1, 0.3, 1)` |
| Element exit | 150–250ms (20–30% faster than entrance, simpler curve) | ease-in `cubic-bezier(0.4, 0, 1, 1)` |
| On-screen movement (indicator slides, panel shifts) | 200–300ms | ease-in-out `cubic-bezier(0.65, 0, 0.35, 1)` |
| Overshoot/spring accent (use sparingly, small elements only) | 300–500ms | `cubic-bezier(0.34, 1.56, 0.64, 1)` |
| Count-ups | 600–900ms | expo-out sampled in rAF: `1 - Math.pow(2, -10 * t)` |
| Stagger step | 30–80ms (55ms sweet spot); whole cascade ≤ 700ms | — |
| Full load orchestration | ≤ 1.5s to settled | — |
| Ambient loops | ≥ 8s period, ≤ 8% opacity delta | linear or sine |

**Rules:** larger travel/scale = longer duration (IBM Carbon's dynamic-duration
principle). Never `transition: all`. Animate only `transform`, `opacity`,
`stroke-dashoffset`, `filter` (compositor-friendly). Productive UI (data updating)
runs 70–150ms; expressive moments (acquisition, reveal) 300–700ms — BEACON needs
both registers. `prefers-reduced-motion: reduce` must collapse every entrance to
its end state, kill all loops, and keep only opacity fades ≤ 150ms.

---

## 3. BEACON upgrade spec

Prioritized. Each item names the target file(s) and exact values. Add these two
shared foundations first:

```css
:root{
  --e-out: cubic-bezier(0, 0, 0.2, 1);
  --e-expo: cubic-bezier(0.16, 1, 0.3, 1);
  --e-inout: cubic-bezier(0.65, 0, 0.35, 1);
  --e-in: cubic-bezier(0.4, 0, 1, 1);
}
```
```js
const REDUCED = matchMedia('(prefers-reduced-motion: reduce)').matches;
// gate every JS-driven animation on this; CSS uses the media query.
```

---

### P0 — the acquisition spine (do these first)

**U1. Boot orchestration on page load** — `index.html`. Replace the bare 900ms
auto-demo delay with a staged power-on:

| t (ms) | Element | Animation |
|---|---|---|
| 0 | `.topbar` | opacity 0→1, 240ms `--e-out` |
| 80 | `.tabs` | same |
| 160 | `.hud-frame` | opacity 0→1 + `clip-path: inset(0 0 100% 0)` → `inset(0)`, 420ms `--e-inout` (frame "unshutters" top-down) |
| 300 | tower cells | floor cascade (U2) |
| 640 | `.hud-side` | opacity 0→1 + translateY(6px)→0, 300ms `--e-expo` |
| 700 | `.querybar` + `.chips` | same, 60ms apart |
| 900 | typewriter | `'Standing by. Ask for what the prospect wants.'` |
| 1400 | auto-demo | `ask(CHIPS[0])` |

Implement with a single `body.boot` class removed after load; each element gets
`animation` with the delays above via explicit CSS (no library needed).
**Reduced-motion: skip entirely — everything visible immediately, auto-demo at 400ms.**

**U2. Tower cell cascade (bottom-up power-on)** — `index.html` `towerSVG()`.
Give every `.t-cell` `opacity:0` inside `body.boot`, then per-floor
`animation: cellOn 180ms var(--e-out) forwards` with
`animation-delay: calc(300ms + (22 - var(--row)) * 14ms)` (`--row` = row index,
floor 2 lights first, floor 23 last; 22 floors × 14ms ≈ 310ms sweep). `cellOn`:
`from{opacity:0}to{opacity:1}`. Floor labels and the L1/roof lines fade in at
the same delay + 60ms. The building reads as *powering on floor by floor*.

**U3. Scanline v2 — edge + trail + wake** — both files' scan treatment.
Replace the single translucent rect with a 3-layer group:
- Leading edge: 1.5px `<rect>` at full `--ready-glow`, `filter: drop-shadow(0 0 4px rgba(83,230,196,.9))`.
- Trail: 26px-tall `<rect>` filled with `linearGradient` teal `.14` → `0` above the edge.
- Wake: as the line passes, cells flash — every non-occupied `.t-cell` gets
  `animation: wake 320ms var(--e-out)` (`0%{filter:brightness(2.1)} 100%{filter:brightness(1)}`)
  with `animation-delay` proportional to its row so the flash tracks the line.

Timing: 900ms `var(--e-inout)` (was 1.1s ease-in-out) — slightly faster, decisive.
Results render at scan end: change the `ask()` timeout from 420ms to **880ms** so
the sweep *finds* the answers (see U6 skeleton to cover the gap).
**Reduced-motion: no scanline, results render immediately (existing behavior kept).**

**U4. Lock-on reticle on matched units** — `index.html` `drawCallouts()`, and
`glass.html` for the active hit. On each matched cell, before the ping starts,
draw four corner brackets (L-shaped `<path>`s, 4×4px arms, stroke 1.2) that start
8px outside the cell corners at opacity 0 and converge to the corners over
**260ms `var(--e-expo)`**, staggered 70ms per match in rank order. Implement with
CSS `transform: translate(±8px, ±8px)` → `translate(0,0)` + opacity 0→.9 on each
bracket (`transform-box: fill-box`). Brackets persist at opacity .9; ping (U5)
starts only after its bracket lands. This is the single highest-value tactical
signature — matches are *acquired*, not highlighted.
**Reduced-motion: brackets appear instantly, no converge.**

**U5. Ping refinement — double ring, capped, rank-gated** — both files.
Current: infinite 1.8s single ring at opacity .9 on every match forever (noisy).
New:
```css
.ping{animation: ping 1.6s cubic-bezier(0, .55, .45, 1) infinite;
      stroke-width:1.2; opacity:0}
.ping.r2{animation-delay:.5s}
@keyframes ping{0%{transform:scale(.35);opacity:.75;stroke-width:1.6}
  70%{opacity:0}100%{transform:scale(2.1);opacity:0;stroke-width:.4}}
```
Two circles per target, second delayed 500ms; stroke thins as it expands (radar
physics). Only the **#1 match** pings continuously; ranks 2+ ping **3 cycles then
stop** (`animation-iteration-count:3`), leaving bracket + fill. Cuts noise,
directs the eye. **Reduced-motion: no pings, brackets only (upgrade from current
"opacity:0 everything").**

**U6. Skeleton "ACQUIRING" state during scan** — `index.html`. During the 880ms
between `ask()` and render, replace `#results` with 3 skeleton cards: panel-bg
rectangles with a left-to-right sweep —
`background: linear-gradient(100deg, transparent 30%, rgba(83,230,196,.07) 50%, transparent 70%); background-size: 200% 100%; animation: shimmer 900ms linear infinite`
(`@keyframes shimmer{from{background-position:150% 0}to{background-position:-50% 0}}`)
— plus a mono caption `SCANNING 132 UNITS…`. Steals Lumina's one good loading
idea and makes it diegetic. Old results must never linger during a new query.
**Reduced-motion: skip skeleton (results are instant anyway).**

### P1 — cards, numbers, tabs

**U7. Result card entrance stagger** — `index.html` `renderResults()`. On every
render, cards get `animation: cardIn 360ms var(--e-expo) both` with inline
`animation-delay: ${i * 55}ms`:
`@keyframes cardIn{from{opacity:0;transform:translateY(9px)}to{opacity:1;transform:none}}`.
The `.top` card's glow arrives *after* landing: split the current box-shadow into
a `::after` overlay animating opacity 0→1 over 450ms starting at 200ms — the
best match "charges up". The "Coming available" eyebrow + SOON cards continue the
same stagger sequence (delays keep incrementing). **Reduced-motion: `animation: none`.**

**U8. Match-bar fill + percent count-up** — `index.html` `cardHTML()`. Bar
`<i>` starts `transform: scaleX(0); transform-origin: left` and transitions to
`scaleX(score/100)` over **600ms `var(--e-expo)`**, delayed `i*55 + 120`ms (after
its card lands). Percent text counts 0→score in the same window via one shared
rAF loop with expo-out sampling (`v = target * (1 - Math.pow(2, -10 * t))`),
rendering `Math.round`. Use `scaleX`, not width — compositor-only.

**U9. KPI count-up on Ops open** — `index.html` `renderKPIs()` /
`switchScreen()`. First time `screen-ops` activates, each `.kpi .v` counts from 0
to final over **700ms**, staggered 60ms per KPI, expo-out; `$` and `%` formatting
preserved each frame (`fmt$`/`toFixed` inside the rAF). Numbers already use
`tabular-nums` — no layout jitter. Fire once (flag), re-fire only on data change.
**Reduced-motion: set final text immediately.**

**U10. Tab transition + sliding indicator** — `index.html`. Two parts:
- *Indicator:* drop per-tab `border-bottom`; add one absolutely-positioned 2px
  `#tabIndicator` div inside `.tabs`, teal, `box-shadow: 0 0 8px rgba(83,230,196,.5)`,
  moved on switch with `left/width` set from `tab.offsetLeft/offsetWidth` and
  `transition: left 260ms var(--e-inout), width 260ms var(--e-inout)`.
- *Screens:* incoming `.screen.active` gets
  `animation: screenIn 240ms var(--e-out)` —
  `from{opacity:0;transform:translateY(5px)}`. Outgoing just hides (exit cost 0,
  correct for tabs). **Reduced-motion: indicator jumps (`transition:none`), no screenIn.**

**U11. Hover micro-interactions (asymmetric, property-scoped)** — `index.html`.
- `.r-card`: `transition: border-color 120ms var(--e-out), transform 150ms var(--e-out), box-shadow 200ms var(--e-out)`;
  hover → `transform: translateX(2px)`, `border-color: var(--ink-3)`,
  `box-shadow: inset 2px 0 0 rgba(83,230,196,.4)` (left accent rail, not a lift —
  tactical, not lifestyle). Leave inherits the 200ms shadow fade → settles slower.
- `.sp-cell`: `transition: transform 100ms var(--e-out), filter 100ms var(--e-out)`;
  hover `scale(1.08)` + `filter: brightness(1.35)`.
- `.chip`, `.r-guide`: keep color/border swap but at 120ms and add
  `background: rgba(83,230,196,.06)` on hover.
- `.qgo`, `.d-send`: replace `filter:brightness(1.1)` with
  `box-shadow: 0 0 14px -4px rgba(83,230,196,.7)` + `transform: translateY(-1px)`,
  120ms; active state `translateY(0)` 80ms.
Never `transition: all` anywhere (their tell).

### P2 — texture and continuity

**U12. Callout leader-line draw** — `index.html` `drawCallouts()`. Add
`pathLength="1"` (works on `<line>` in all modern engines — else use `<path>`),
`stroke-dasharray:1; stroke-dashoffset:1`, animate to 0 over **240ms
`var(--e-inout)`**, staggered 70ms matching U4's bracket order; the
`.t-callout-text` label fades in (140ms) 160ms after its line starts. Lines
*draw outward* from unit to label — pure FUI. **Reduced-motion: static.**

**U13. Typewriter cadence + glow** — `index.html` `typeLine()`. Keep the
mechanism; refine: base interval **10ms/char**, but after `.`, `,`, `—` insert a
**45ms hold** (accumulate a pause counter instead of a fixed setInterval — switch
to setTimeout chaining). Prefix `BEACON › ` renders instantly, only the payload
types. On completion, flash the caret 2 quick blinks (150ms each) before settling
to the 1s blink. Add `text-shadow: 0 0 8px rgba(83,230,196,.35)` to `.ai-line`
(static — phosphor bloom, costs nothing). Existing reduced-motion path (instant
text) stays.

**U14. Live-feed cascade + arrival pulse** — `index.html`. On Ops first open,
`.f-item`s enter with 240ms `var(--e-out)` fade/translateY(6px), 50ms stagger.
Then a `setInterval` (~40s, skip when `document.hidden` or `REDUCED`) prepends a
simulated event: new item animates `grid-template-rows`-free via
`max-height 0→48px` 280ms `var(--e-inout)` + `background: rgba(83,230,196,.08)`
decaying to transparent over 1.2s; its `.f-dot` does one 2-scale ping. The ops
console reads *live*, which is BEACON's whole pitch.

**U15. Ambient sustain layer (restrained)** — `index.html`. Two idle-state items:
- Every **30s**, a 6%-opacity scanline pass over the tower (same geometry as U3,
  no wake flashes, 1.4s linear) — the system is still watching.
- Topbar `PMS SYNC LIVE` dot: on each pass, 1 quick brighten
  (`filter: brightness(1.6)` 120ms) + clock flashes teal for 300ms.
Hard rules: period ≥ 30s, opacity delta ≤ 8%, zero layout movement, suspended
when `document.hidden`. **Reduced-motion: off entirely.**

**U16. Send-to-HUD handoff continuity** — `index.html` `selectUnit()` send
button. On click: switch to HUD, populate `#qinput` with a
`background-color: rgba(83,230,196,.18)` flash decaying 400ms (input visibly
*receives* the query), then run the full U3 scan → U4 lock-on onto that unit.
Cross-screen cause-and-effect — the one thing template sites never have.

**U17. Tooltip entrance** — `index.html`. `opacity 0→1` + `scale(.97)→1`,
**120ms `var(--e-out)`**, `transform-origin` toward cursor side; leave 80ms
ease-in. Show after 40ms hover intent delay to avoid flicker while sweeping the
stackplan.

**U18. GLASS in-lens motion kit** — `glass.html`. In-lens is an additive display
(black = transparent) — motion must be sparse and legible:
- Request switch (◀▶): old `.req .text` fades out + translateY(-6px) 100ms
  `var(--e-in)`; new fades in + translateY(6px)→0 140ms `var(--e-out)`.
- Unit switch (▲▼): `.unit` number does a 3-frame digit scramble (random digits
  120ms) then resolves; `.fitbar i` re-fills scaleX 0→score 450ms `var(--e-expo)`.
- Route view (⏎): steps cascade — each `.n` circle pops (scale .6→1, 180ms
  `cubic-bezier(0.34,1.56,0.64,1)` — the one sanctioned overshoot, tiny element),
  each `.stem` grows `scaleY 0→1` 140ms `var(--e-inout)`, strictly sequential
  (step n at `n*160ms`). A route that *draws itself* floor by floor.
- Ping: adopt U5 double-ring; keep only on the active hit (already the case).
All gated on the existing reduced-motion pattern.

### Implementation notes
- One shared rAF ticker for all count-ups (U8/U9/U18); push {el, from, to, start,
  dur, fmt} jobs, stop the loop when empty.
- All entrance keyframes use `animation-fill-mode: both` so pre-delay state is
  the hidden state — no flash of unstyled content.
- Re-trigger pattern already in the codebase (`void el.getBoundingClientRect()`)
  is correct; reuse it for U3/U6/U7.
- Everything above animates only `transform`, `opacity`, `stroke-dashoffset`,
  `clip-path`, `filter`, `background-position` — no layout properties except the
  U14 max-height (one small element, acceptable).
- Add one consolidated `@media (prefers-reduced-motion: reduce)` block that zeroes
  every new animation; JS side gates on the single `REDUCED` const.

---

## 4. Do not do

- **No `transition: all`** — the definitive template tell (their site is full of it).
- **No animate.css vocabulary** — no bounceIn, no fadeInUpBig, no rubber-band.
  Overshoot is allowed once (U18 route circles), small elements only.
- **No Ken Burns / slow photo zoom, no parallax sections** — that is their
  language (luxury-lifestyle softness). BEACON has no photography; keep it that way.
- **No glitch/RGB-split/CRT-flicker loops** — cyberpunk cosplay reads as a
  toy, not an instrument. One-shot precision beats looping distortion.
- **No infinite pings on everything** (current bug, fixed by U5) — perpetual
  motion on every object means nothing is signal.
- **No text scramble on prose** — scramble is reserved for numeric readouts
  (U18); scrambling sentences is 2014 hacker-movie.
- **No hover lifts with drop shadows / card float** — lifestyle-site grammar;
  BEACON cards slide 2px and rail-glow instead.
- **No smooth-scroll hijacking or scroll-jacking** — single-viewport app; also
  universally hated in tools.
- **No motion longer than 700ms on the interaction path** — expressive timing is
  for the load boot and acquisition sweep only; everything the user *causes*
  answers in ≤ 400ms.
- **No autoplaying audio, no cursor replacement, no preloader screens** — the
  boot sequence (U1) is the loader; it runs on real content in 1.4s.
