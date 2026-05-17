# Home & Documents Redesign — Direction B (Vibrant Hero)

**Date:** 2026-05-17
**Scope:** `lib/screens/home_screen/home.dart` and `lib/screens/document_screen/document_screen.dart`
**Status:** Approved (visual direction)

## Goal

Replace the current visually-inconsistent Home screen and the bare Documents header with a single cohesive visual language: a short orange gradient hero at the top of each main tab, content cards floating over the hero edge, and a consistent neutral card style below. Icons everywhere (no emoji); use existing `GColor` brand colors.

## What changes

### 1. Home tab (`home.dart`)

**Header (hero):**
- Replace the current white `AppBar` (avatar + welcome text + settings icon, white background) with a custom gradient hero painted on the `Scaffold` body.
- Gradient: `LinearGradient([GColor.primarycolor, GColor.secondarycolor])` (orange → amber), `begin: topLeft`, `end: bottomRight`.
- Hero contents, left-to-right:
  - `AvatarWidget` (40×40) inside a 2px white translucent ring (`Colors.white.withValues(alpha: 0.45)`).
  - Column: "សូមស្វាគមន៍មកវិញ" small (size 11, white 85% opacity), name bold (size 16, white).
  - Settings `IconButton(Icons.settings)` (white) on the far right, tappable, calls `widget.onNavigateToTab?.call(4)`.
- Below the avatar row, a "today status pill":
  - Rounded container (radius 10), `Colors.white.withValues(alpha: 0.15)` background, 1px translucent white border.
  - `Icons.circle` (6px white) + text "មាន $_todayMeetings កិច្ចប្រជុំសម្រាប់ថ្ងៃនេះ" (or "គ្មានកិច្ចប្រជុំសម្រាប់ថ្ងៃនេះ" when zero).
- Hero bottom padding ~56px so stat cards visually overlap the gradient edge.

**Stats row (overlapping hero):**
- Wrap the existing three `DashCard`s in a `Transform.translate(offset: Offset(0, -28))` so they sit on top of the gradient/body seam.
- Update `DashCard` style (or build inline): white background, 12px radius, `boxShadow` `(blur 8, offset 0,2, Colors.black.withOpacity(0.05))`, 1px `#F1ECDB` border. Number in `GColor.primarycolor` size 18 bold, label size 9, color `#6B6657`.
- Same three values: today / upcoming / unread.

**Quick actions:**
- Section header row: bold "សកម្មភាពរហ័ស" (size 12) — no trailing "see all".
- `GridView.count(crossAxisCount: 4, shrinkWrap: true)` of `_QuickAction` tiles. Each tile:
  - White background, 12px radius, 1px `#F1ECDB` border.
  - Inside: a 28×28 rounded square (radius 10) tinted `#FFF4EA` containing a `GColor.primarycolor` `Icon` (size 13). Same tint for all four — drop the random blue/green/purple/orange.
  - Label below, size 8, black.
- Icons: `Icons.calendar_month` (កក់), `Icons.description` (ឯកសារ), `Icons.group` (ប្រជុំ), `Icons.settings` (ការកំណត់). "កក់" tile still hidden when `!_canManage`.

**Upcoming meetings:**
- Section header row: "កិច្ចប្រជុំខាងមុខ" (size 12 bold) + right-aligned "មើលទាំងអស់ →" (size 9, `GColor.primarycolor`, tappable → meetings tab).
- Replace the existing `EventCard` usage with a new compact `_MeetCard` style (or update `EventCard`):
  - Row layout: 44px left "time block" (HH:mm in primary color size 12 bold + weekday label in `#8B8674` size 7) separated from the right side by a 1px dashed `#E5E2D6` vertical divider, then meeting title (size 10 bold) and a subtitle line "បន្ទប់ X · N នាក់" (size 8, `#8B8674`).
  - White background, 12px radius, 1px `#F1ECDB` border, subtle shadow.
- Show up to 2 entries; empty state text unchanged.

**Book new meeting button:**
- Keep `TranspButton` as-is (still under `_canManage`).

**Notifications:**
- Section header row identical pattern: "ការជូនដំណឹងថ្មីៗ" + "មើលទាំងអស់ →" (tappable → alerts tab).
- Notification card: 26×26 rounded square (radius 8) tinted `#FFF4EA` with `Icons.notifications` in primary color, title size 9 bold, subtitle "$name · $relativeTime" size 8 `#8B8674`. Keep current `NotificationCard` data flow.

**Removed:**
- The bottom `Container` with the orange `LinearGradient` "កាលវិភាគថ្ងៃនេះ" banner is **deleted**. Its information is now in the hero status pill.

**Scaffolding:**
- Set `appBar: null`. Page becomes `Scaffold(body: RefreshIndicator(child: CustomScrollView( … )))` or keep `SingleChildScrollView` with the hero as the first child (no `SliverAppBar` is needed — hero is non-collapsing).
- Use `MediaQuery.of(context).padding.top` for top inset of the hero so it respects the status bar.

### 2. Documents tab (`document_screen.dart`)

**Header (hero):**
- Replace the bare `AppBar(title: Text('ឯកសារ'))` with the same gradient hero pattern as Home.
- Hero contents:
  - Title "ឯកសារ" size 16 bold white (font `KhmerOSMoulLightRegular`).
  - Subtitle "គ្រប់គ្រងឯកសារនិងការអនុម័ត" size 10 white 85%.
  - Three count chips in a row:
    - Translucent white background (`Colors.white.withValues(alpha: 0.18)`), 1px translucent border, 10px radius.
    - `b` count (size 14 bold) above label (size 9): pending / recent / expiring.
    - Counts come from each `_TabState.items.length` for already-loaded tabs; show `—` until loaded. (No new API call — use what we already have. Triggering loads of inactive tabs is **out of scope** for this redesign.)
- Hero bottom padding ~28px.

**Sub-tab bar (floating segmented control):**
- Replace `_SubTabBar` underline chips with a "pill switcher" that sits over the hero edge (margin -16 top, horizontal 14):
  - White container, radius 14, 1px `#F1ECDB` border, soft shadow.
  - Three equal `Expanded` chips. Active chip background `GColor.primarycolor`, white text size 9 bold, radius 10. Inactive: transparent background, `#8B8674` text.
- Keep the existing tab labels (`កំពុងរង់ចាំ` / `ថ្មីៗ` / `ផុតកំណត់`) and the existing `_active` switching logic.

**Document list rows:**
- Update `DocumentCard` (or in-place styling) to match:
  - White, 12px radius, 1px `#F1ECDB` border, 8px vertical margin, 10px padding.
  - 30×30 `#FFF4EA` tile (radius 8) with `Icons.description` in primary color.
  - Name size 10 bold, meta line "មន្ត្រី X · N ថ្ងៃមុន" size 8 `#8B8674`.
  - Trailing status badge pill (existing `DocumentStatus.colorFor`-tinted background at 15% alpha, same color text, size 7 bold, 10px radius).
- Empty state and pagination behaviour unchanged.

### 3. Shared design tokens

Introduce in `lib/config/color.dart` (or a new `lib/config/tokens.dart`) so we don't sprinkle hex literals:

| Token | Value | Use |
|---|---|---|
| `GColor.surfaceCard` | `#FFFFFF` | white cards |
| `GColor.surfaceTint` | `#FFF4EA` | icon tile background |
| `GColor.borderSubtle` | `#F1ECDB` | 1px card borders |
| `GColor.textMuted` | `#8B8674` | subtitles, weekday labels |
| `GColor.textBody` | `#1C1C1C` | primary text |

Existing `GColor.primarycolor` (`#F55000`) and `GColor.secondarycolor` (`#FC9400`) stay; they're the hero gradient.

## What stays the same

- All API endpoints, data flow, refresh logic, pagination, role gating (`_canManage`, admin doc-approve flow).
- All Khmer fonts.
- `MainScreen` bottom-nav structure and the five tabs.
- `LoginScreen`, `MeetingScreen`, `AlertScreen`, `SettingScreen` (out of scope this round).
- `Booking`, `Document`, notification models.

## Out of scope

- Meetings, Alerts, Settings, and Profile screens — different spec.
- Backend changes.
- Khmer-language copy changes.
- Loading new data to power the document count chips (uses existing list state only).

## Reusable widgets to add or update

| Widget | Path | Purpose |
|---|---|---|
| `GradientHero` | `lib/widgets/gradient_hero.dart` *(new)* | Shared hero container — accepts `child`, configurable bottom padding. Used by Home and Documents (and reusable later for Meetings/Alerts). |
| `StatCard` | replace inline `DashCard` style | White card with bold orange number + small label. |
| `QuickActionTile` | `lib/widgets/quick_action_tile.dart` *(new)* | Icon-tile + label, used in Home grid. |
| `MeetCard` | extend `EventCard` *or* new `lib/widgets/meet_card.dart` | Time block + dashed divider + meeting body. Decide during plan; if `EventCard` is only used here, extend it. |
| `SectionHeader` | `lib/widgets/section_header.dart` *(new)* | Title + optional "see all →" affordance. |
| `SegmentedTabs` | `lib/widgets/segmented_tabs.dart` *(new)* | The floating pill switcher used by Documents. |

`DocumentCard` is updated in place rather than replaced.

## Risks / things to confirm during planning

1. **Hero status bar handling.** The gradient must extend under the status bar but content must respect the top inset. Use `MediaQuery.padding.top` and `SystemUiOverlayStyle.light` for status-bar icons over the hero.
2. **Stat-card overlap and tap targets.** The `Transform.translate(-28)` must not shrink the scroll content's overall hit area. Use a `Stack` inside the body if the negative offset clips taps.
3. **Document count chips.** Showing real counts requires either loading all three tabs eagerly or showing only the active tab's count. Decision: show `—` for tabs whose state hasn't loaded yet; do not pre-load.
4. **`AvatarWidget` on a colored background.** Confirm `lib/assets/user_icon.png` reads acceptably over orange. If not, add a thin white ring (already in spec).
5. **Khmer font line-height.** Khmer characters with subscripts can clip with tight `fontSize: 8` labels. Verify on device; bump to 9 if clipping occurs.

## Acceptance criteria

- Home tab boots into the new layout without changing API call counts or behaviour.
- Removing the bottom gradient banner does not regress the "today's meeting count" info — it is now in the hero pill.
- All four quick-action icons share the same tint; their existing `onTap` behaviours are preserved.
- Document tab has a visible gradient header with title + subtitle + three count chips.
- Document sub-tab switching still works; status badges still come from `DocumentStatus.colorFor`.
- `flutter analyze` is clean.
- No raw hex literals in the two screen files — colors come from `GColor`.
- No emoji characters in source code.

## Implementation order (high level)

1. Add design tokens to `GColor`.
2. Build shared widgets (`GradientHero`, `SectionHeader`, `QuickActionTile`, `SegmentedTabs`) with no callers yet.
3. Rewrite `home.dart` body using them; delete bottom gradient banner.
4. Rewrite `document_screen.dart` header and sub-tab bar using them.
5. Polish `DocumentCard` and the in-Home `EventCard`/`NotificationCard` rendering.
6. Visual QA on device.

Detailed task breakdown will live in the implementation plan.