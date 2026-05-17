# Home & Documents Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apply the Direction B (vibrant hero) redesign from `docs/superpowers/specs/2026-05-17-home-and-documents-redesign-design.md` to the Home tab and the Documents tab, producing a single cohesive visual language across both screens.

**Architecture:** Add shared design tokens to `GColor`, build five reusable widgets (`GradientHero`, `SectionHeader`, `QuickActionTile`, `SegmentedTabs`, plus an updated `_StatusBadge` already in place), restyle the four existing single-callsite widgets (`DashCard`, `EventCard`, `NotificationCard`, `DocumentCard`) in place, then rewrite the two screen body widgets to use the new pieces. No new packages, no API changes, no routing changes.

**Tech Stack:** Flutter 3.x · Material widgets · existing `GColor` design system · existing `KhmerOSSiemreap` / `KhmerOSMoulLightRegular` fonts · `intl` for date formatting.

**Verification approach:** This project has no widget-test harness (only `test/models/`). Per task we run `flutter analyze` and commit. After Task 11 we run the app on a device/simulator and visually verify the acceptance criteria from the spec.

---

## File Structure

**New files:**
- `lib/widgets/gradient_hero.dart` — shared orange gradient hero container; one child slot.
- `lib/widgets/section_header.dart` — bold title + optional `seeAllOnTap` action row.
- `lib/widgets/quick_action_tile.dart` — icon-tile + label, used in the Home quick-actions grid.
- `lib/widgets/segmented_tabs.dart` — generic floating pill switcher used by Documents.

**Modified files:**
- `lib/config/color.dart` — five new design tokens.
- `lib/widgets/dashcard.dart` — restyle to white card + orange number.
- `lib/widgets/event_card.dart` — restyle to compact "time block + body" row.
- `lib/widgets/recent_notifications.dart` — restyle each tile with a tinted icon square.
- `lib/widgets/document_card.dart` — restyle to match the new card language.
- `lib/screens/home_screen/home.dart` — replace `AppBar` + body with hero + new sections; delete the bottom orange banner.
- `lib/screens/document_screen/document_screen.dart` — replace `AppBar` + `_SubTabBar` with hero + count chips + `SegmentedTabs`.

**Not touched (out of scope):**
- `lib/widgets/action_button.dart` — kept; no longer used by Home but referenced nowhere else, so leave it for now.
- All other screens (login, meetings, alerts, settings, profile, meeting details).
- `lib/screens/document_screen/document_detail.dart` — pre-existing local modification is preserved.

---

## Task 1: Add design tokens to `GColor`

**Files:**
- Modify: `lib/config/color.dart`

- [ ] **Step 1: Add the five tokens to `GColor`**

Replace the contents of `lib/config/color.dart` with:

```dart
import 'package:flutter/material.dart';

class GColor {
  static Color get primarycolor => const Color(0xffF55000);
  static Color get secondarycolor => const Color(0xffFC9400);
  static Color get backgroundcolor => const Color(0xffFFFDF1);

  static Color get gblue => const Color(0xffFFFDF1);
  static Color get ggreen => const Color(0xff1E70FF);
  static Color get gpurple => const Color(0xffA12AFE);

  static Color get primarytext => const Color(0xff4A4B4D);
  static Color get secondarytext => const Color(0xff7C7D7E);
  static Color get textfield => const Color(0xffF2F2F2);
  static Color get placeholder => const Color(0xffB6B7B7);
  static Color get white => const Color(0xffffffff);

  // Design tokens (2026-05-17 redesign)
  static Color get surfaceCard => const Color(0xffFFFFFF);
  static Color get surfaceTint => const Color(0xffFFF4EA);
  static Color get borderSubtle => const Color(0xffF1ECDB);
  static Color get textMuted => const Color(0xff8B8674);
  static Color get textBody => const Color(0xff1C1C1C);
}
```

- [ ] **Step 2: Run `flutter analyze`**

Run: `flutter analyze lib/config/color.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/config/color.dart
git commit -m "feat(theme): add surface/border/text tokens to GColor"
```

---

## Task 2: Create `GradientHero` widget

**Files:**
- Create: `lib/widgets/gradient_hero.dart`

- [ ] **Step 1: Create the file**

Write `lib/widgets/gradient_hero.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';

/// Short orange→amber gradient hero used at the top of main tabs.
///
/// Extends under the status bar; child receives the top safe-area inset
/// as additional top padding. [bottomPadding] is how far below the child
/// the gradient continues — pick larger values when content below the hero
/// (stat cards, segmented tabs) should overlap the hero edge.
class GradientHero extends StatelessWidget {
  final Widget child;
  final double bottomPadding;
  final EdgeInsets contentPadding;

  const GradientHero({
    super.key,
    required this.child,
    this.bottomPadding = 28,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topInset + 12,
        left: contentPadding.left,
        right: contentPadding.right,
        bottom: bottomPadding,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [GColor.primarycolor, GColor.secondarycolor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}
```

- [ ] **Step 2: Run `flutter analyze`**

Run: `flutter analyze lib/widgets/gradient_hero.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/gradient_hero.dart
git commit -m "feat(widgets): add GradientHero shared container"
```

---

## Task 3: Create `SectionHeader` widget

**Files:**
- Create: `lib/widgets/section_header.dart`

- [ ] **Step 1: Create the file**

Write `lib/widgets/section_header.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';

/// Row used above each home/documents section: bold title on the left,
/// optional "មើលទាំងអស់ →" affordance on the right.
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final String seeAllLabel;

  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.seeAllLabel = 'មើលទាំងអស់ →',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: GColor.textBody,
              fontFamily: 'KhmerOSSiemreap',
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Text(
                  seeAllLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: GColor.primarycolor,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'KhmerOSSiemreap',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Run `flutter analyze`**

Run: `flutter analyze lib/widgets/section_header.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/section_header.dart
git commit -m "feat(widgets): add SectionHeader"
```

---

## Task 4: Create `QuickActionTile` widget

**Files:**
- Create: `lib/widgets/quick_action_tile.dart`

- [ ] **Step 1: Create the file**

Write `lib/widgets/quick_action_tile.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';

/// Single tile used in the Home quick-actions grid.
/// White card · 1px subtle border · tinted icon square · Khmer label below.
class QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: GColor.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: GColor.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: GColor.surfaceTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: GColor.primarycolor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: GColor.textBody,
                fontFamily: 'KhmerOSSiemreap',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run `flutter analyze`**

Run: `flutter analyze lib/widgets/quick_action_tile.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/quick_action_tile.dart
git commit -m "feat(widgets): add QuickActionTile"
```

---

## Task 5: Create `SegmentedTabs` widget

**Files:**
- Create: `lib/widgets/segmented_tabs.dart`

- [ ] **Step 1: Create the file**

Write `lib/widgets/segmented_tabs.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';

/// Floating pill switcher. Sits over the gradient hero edge in the
/// Documents tab. Caller controls the active index; this is a stateless
/// segmented control.
class SegmentedTabs extends StatelessWidget {
  final List<String> labels;
  final int activeIndex;
  final ValueChanged<int> onChanged;

  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.activeIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GColor.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GColor.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(labels.length, (i) {
          final isActive = i == activeIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isActive ? GColor.primarycolor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? Colors.white : GColor.textMuted,
                    fontFamily: 'KhmerOSSiemreap',
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
```

- [ ] **Step 2: Run `flutter analyze`**

Run: `flutter analyze lib/widgets/segmented_tabs.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/segmented_tabs.dart
git commit -m "feat(widgets): add SegmentedTabs pill switcher"
```

---

## Task 6: Restyle `DashCard`

**Files:**
- Modify: `lib/widgets/dashcard.dart`

- [ ] **Step 1: Replace the file**

Overwrite `lib/widgets/dashcard.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';

class DashCard extends StatelessWidget {
  final String number;
  final String label;
  final VoidCallback? onTap;
  final Color? cardbg;
  final double width;

  const DashCard({
    super.key,
    required this.number,
    required this.label,
    required this.width,
    this.onTap,
    this.cardbg,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: cardbg ?? GColor.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: GColor.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              number,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: GColor.primarycolor,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: GColor.textMuted,
                fontFamily: 'KhmerOSSiemreap',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run `flutter analyze`**

Run: `flutter analyze lib/widgets/dashcard.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/dashcard.dart
git commit -m "refactor(widgets): restyle DashCard - white card + orange number"
```

---

## Task 7: Restyle `EventCard` as compact meet card

**Files:**
- Modify: `lib/widgets/event_card.dart`

- [ ] **Step 1: Replace the file**

Overwrite `lib/widgets/event_card.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ginbec_mobile_app/config/color.dart';

/// Compact meeting card.
/// Left: 48px time block (HH:mm in primary color, weekday abbrev below).
/// Divider: 1px dashed [GColor.borderSubtle].
/// Right: title (bold) + subtitle ("បន្ទប់ X · N នាក់" — caller passes [room]).
class EventCard extends StatelessWidget {
  final String tittle;
  final DateTime datetime;
  final int attendee;
  final String? room;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.tittle,
    required this.attendee,
    required this.datetime,
    this.room,
    this.onTap,
  });

  static const List<String> _weekdayKh = [
    'ច័ន្ទ', 'អង្គារ', 'ពុធ', 'ព្រហ', 'សុក្រ', 'សៅរ៍', 'អាទិត្យ',
  ];

  @override
  Widget build(BuildContext context) {
    final weekday = _weekdayKh[(datetime.weekday - 1).clamp(0, 6)];
    final subtitleParts = <String>[];
    if (room != null && room!.isNotEmpty) subtitleParts.add('បន្ទប់ $room');
    subtitleParts.add('$attendee នាក់');
    final subtitle = subtitleParts.join(' · ');

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: GColor.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: GColor.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 56,
              child: Column(
                children: [
                  Text(
                    DateFormat('HH:mm').format(datetime),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: GColor.primarycolor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    weekday,
                    style: TextStyle(
                      fontSize: 10,
                      color: GColor.textMuted,
                      fontFamily: 'KhmerOSSiemreap',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 1,
              height: 36,
              color: GColor.borderSubtle,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tittle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: GColor.textBody,
                      fontFamily: 'KhmerOSSiemreap',
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: GColor.textMuted,
                      fontFamily: 'KhmerOSSiemreap',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: GColor.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run `flutter analyze`**

Run: `flutter analyze lib/widgets/event_card.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/event_card.dart
git commit -m "refactor(widgets): restyle EventCard as compact time-block card"
```

---

## Task 8: Restyle `NotificationTile`

**Files:**
- Modify: `lib/widgets/recent_notifications.dart`

- [ ] **Step 1: Replace the `NotificationTile` build method and the `NotificationCard` container**

Overwrite `lib/widgets/recent_notifications.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';

class NotificationModel {
  final String id;
  final String title;
  final String subtitle;
  final DateTime createdAt;
  final String type;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    required this.type,
    this.isRead = false,
  });
}

class NotificationCard extends StatelessWidget {
  final List<NotificationModel> notifications;
  final void Function(NotificationModel)? onTap;

  const NotificationCard({
    super.key,
    required this.notifications,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GColor.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GColor.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            for (int i = 0; i < notifications.length; i++) ...[
              NotificationTile(
                notification: notifications[i],
                onTap: onTap == null ? null : () => onTap!(notifications[i]),
              ),
              if (i != notifications.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: GColor.borderSubtle,
                  indent: 14,
                  endIndent: 14,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  IconData _iconForType(String type) {
    switch (type) {
      case 'meeting':
        return Icons.event;
      case 'booking':
        return Icons.calendar_month;
      case 'document':
        return Icons.description;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'ទើបតែឥឡូវ';
    if (diff.inMinutes < 60) return '${diff.inMinutes} នាទីមុន';
    if (diff.inHours < 24) return '${diff.inHours} ម៉ោងមុន';
    return '${diff.inDays} ថ្ងៃមុន';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: GColor.surfaceTint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _iconForType(notification.type),
                color: GColor.primarycolor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: GColor.textBody,
                      fontFamily: 'KhmerOSSiemreap',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(notification.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: GColor.textMuted,
                      fontFamily: 'KhmerOSSiemreap',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: GColor.textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run `flutter analyze`**

Run: `flutter analyze lib/widgets/recent_notifications.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/recent_notifications.dart
git commit -m "refactor(widgets): restyle NotificationTile with tinted icon square"
```

---

## Task 9: Rewrite Home screen layout

**Files:**
- Modify: `lib/screens/home_screen/home.dart`

- [ ] **Step 1: Replace the build method and remove `ActionButton`/`TranspButton`/gradient-banner usages**

The data-loading code (`_loadData`, `_openBookMeeting`, `_meetingDateTime`, state vars) stays unchanged. Only the `build` method and its imports change.

In the file's import block at the top, **remove** these (they will be unused after the rewrite):

```dart
import 'package:ginbec_mobile_app/widgets/transp_button.dart';
import '../../widgets/action_button.dart';
```

In their place, **add**:

```dart
import 'package:ginbec_mobile_app/widgets/gradient_hero.dart';
import 'package:ginbec_mobile_app/widgets/quick_action_tile.dart';
import 'package:ginbec_mobile_app/widgets/section_header.dart';
```

Then replace the entire `build` method (the `return Scaffold(...)` starting around line 246) with:

```dart
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: GColor.backgroundcolor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final statCardWidth = (width - 32 - 16) / 3; // 32 horizontal padding, 16 gap

    return Scaffold(
      backgroundColor: GColor.backgroundcolor,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GradientHero(
                bottomPadding: 56,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.45),
                                width: 2,
                              ),
                            ),
                            child: const AvatarWidget(
                              imageUrl: 'lib/assets/user_icon.png',
                              size: 44,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'សូមស្វាគមន៍មកវិញ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontFamily: 'KhmerOSSiemreap',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _userName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontFamily: 'KhmerOSSiemreap',
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => widget.onNavigateToTab?.call(4),
                          icon: const Icon(Icons.settings, color: Colors.white),
                          tooltip: 'ការកំណត់',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _todayMeetings == 0
                                  ? 'គ្មានកិច្ចប្រជុំសម្រាប់ថ្ងៃនេះ'
                                  : 'មាន $_todayMeetings កិច្ចប្រជុំសម្រាប់ថ្ងៃនេះ',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontFamily: 'KhmerOSSiemreap',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -28),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DashCard(
                            number: '$_todayMeetings',
                            label: 'ប្រជុំ\nថ្ងៃនេះ',
                            width: statCardWidth,
                          ),
                          DashCard(
                            number: '$_upcomingCount',
                            label: 'នឹងមកដល់',
                            width: statCardWidth,
                          ),
                          DashCard(
                            number: '$_unreadCount',
                            label: 'មិនទាន់អាន',
                            width: statCardWidth,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const SectionHeader(title: 'សកម្មភាពរហ័ស'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (_canManage) ...[
                            Expanded(
                              child: QuickActionTile(
                                icon: Icons.calendar_month,
                                label: 'កក់',
                                onTap: _openBookMeeting,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Expanded(
                            child: QuickActionTile(
                              icon: Icons.description,
                              label: 'ឯកសារ',
                              onTap: () =>
                                  widget.onNavigateToTab?.call(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: QuickActionTile(
                              icon: Icons.group,
                              label: 'កាលវិភាគ',
                              onTap: () =>
                                  widget.onNavigateToTab?.call(1),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: QuickActionTile(
                              icon: Icons.settings,
                              label: 'ការកំណត់',
                              onTap: () =>
                                  widget.onNavigateToTab?.call(4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SectionHeader(
                        title: 'កិច្ចប្រជុំខាងមុខ',
                        onSeeAll: () => widget.onNavigateToTab?.call(1),
                      ),
                      if (_upcomingMeetings.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'គ្មានកិច្ចប្រជុំខាងមុខ',
                            style: TextStyle(
                              color: GColor.textMuted,
                              fontFamily: 'KhmerOSSiemreap',
                            ),
                          ),
                        )
                      else
                        ..._upcomingMeetings.take(2).map((m) {
                          final id = (m['meetingId'] as num?)?.toInt();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: EventCard(
                              tittle: m['title'] as String? ?? '',
                              attendee: 0,
                              datetime: _meetingDateTime(m),
                              room: m['roomName'] as String?,
                              onTap: id == null
                                  ? null
                                  : () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => MeetingDetailsScreen(
                                            meetingId: id,
                                          ),
                                        ),
                                      ),
                            ),
                          );
                        }),
                      const SizedBox(height: 8),
                      SectionHeader(
                        title: 'ការជូនដំណឹងថ្មីៗ',
                        onSeeAll: () => widget.onNavigateToTab?.call(3),
                      ),
                      NotificationCard(
                        notifications: _notifications.isEmpty
                            ? [
                                NotificationModel(
                                  id: '0',
                                  title: 'មិនទាន់មានការជូនដំណឹងថ្មី',
                                  subtitle: '',
                                  createdAt: DateTime.now(),
                                  type: 'system',
                                )
                              ]
                            : _notifications,
                        onTap: (_) => widget.onNavigateToTab?.call(3),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
```

Note that the bottom orange `Container` ("កាលវិភាគថ្ងៃនេះ") and the `TranspButton` ("កក់កិច្ចប្រជុំថ្មី") are **deleted** — the booking action is now in the quick-action grid (when `_canManage`), and the today-status text now lives in the hero pill.

- [ ] **Step 2: Run `flutter analyze`**

Run: `flutter analyze lib/screens/home_screen/home.dart`
Expected: `No issues found!`

If there are warnings about unused imports, remove them.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/home_screen/home.dart
git commit -m "feat(home): apply vibrant-hero redesign"
```

---

## Task 10: Restyle `DocumentCard`

**Files:**
- Modify: `lib/widgets/document_card.dart`

- [ ] **Step 1: Replace the file**

Overwrite `lib/widgets/document_card.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:ginbec_mobile_app/models/document.dart';
import 'package:ginbec_mobile_app/models/document_status.dart';

class DocumentCard extends StatelessWidget {
  final Document document;
  final VoidCallback onTap;
  const DocumentCard({super.key, required this.document, required this.onTap});

  String _metaLine() {
    final parts = <String>[];
    if (document.officerName != null && document.officerName!.isNotEmpty) {
      parts.add('មន្ត្រី ${document.officerName}');
    }
    final d = document.expiryDate;
    if (d != null) {
      final days = d.difference(DateTime.now()).inDays;
      if (days < 0) {
        parts.add('ផុតកំណត់ហើយ');
      } else {
        parts.add('នៅសល់ $days ថ្ងៃ');
      }
    }
    if (parts.isEmpty) return document.documentTypeName ?? '';
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = DocumentStatus.colorFor(document.statusCode);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: GColor.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: GColor.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: GColor.surfaceTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.description,
                  color: GColor.primarycolor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.documentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'KhmerOSSiemreap',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: GColor.textBody,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _metaLine(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'KhmerOSSiemreap',
                        fontSize: 11,
                        color: GColor.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  document.statusLabel,
                  style: TextStyle(
                    fontFamily: 'KhmerOSSiemreap',
                    color: badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run `flutter analyze`**

Run: `flutter analyze lib/widgets/document_card.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/document_card.dart
git commit -m "refactor(widgets): restyle DocumentCard with tinted icon + status badge"
```

---

## Task 11: Rewrite Documents screen (hero + segmented tabs)

**Files:**
- Modify: `lib/screens/document_screen/document_screen.dart`

- [ ] **Step 1: Replace the file**

Overwrite `lib/screens/document_screen/document_screen.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:ginbec_mobile_app/models/document.dart';
import 'package:ginbec_mobile_app/services/document_service.dart';
import 'package:ginbec_mobile_app/widgets/document_card.dart';
import 'package:ginbec_mobile_app/widgets/gradient_hero.dart';
import 'package:ginbec_mobile_app/widgets/segmented_tabs.dart';
import 'package:ginbec_mobile_app/screens/document_screen/document_detail.dart';

enum _SubTab { pending, recent, expiring }

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  _SubTab _active = _SubTab.pending;

  final _state = {
    _SubTab.pending:  _TabState(),
    _SubTab.recent:   _TabState(),
    _SubTab.expiring: _TabState(),
  };

  @override
  void initState() {
    super.initState();
    _loadInitial(_active);
  }

  Future<void> _loadInitial(_SubTab tab) async {
    final s = _state[tab]!;
    if (s.items.isNotEmpty || s.isLoading) return;
    setState(() => s.isLoading = true);
    try {
      final page = await _fetch(tab, 0);
      setState(() {
        s.items.addAll(page.items);
        s.currentPage = 0;
        s.hasMore = !page.last;
        s.isLoading = false;
        s.error = null;
      });
    } catch (e) {
      setState(() {
        s.isLoading = false;
        s.error = 'មិនអាចទាញយកបាន';
      });
    }
  }

  Future<void> _loadMore(_SubTab tab) async {
    final s = _state[tab]!;
    if (s.isLoading || !s.hasMore) return;
    setState(() => s.isLoading = true);
    try {
      final next = s.currentPage + 1;
      final page = await _fetch(tab, next);
      setState(() {
        s.items.addAll(page.items);
        s.currentPage = next;
        s.hasMore = !page.last;
        s.isLoading = false;
      });
    } catch (_) {
      setState(() => s.isLoading = false);
    }
  }

  Future<void> _refresh(_SubTab tab) async {
    final s = _state[tab]!;
    setState(() {
      s.items.clear();
      s.currentPage = 0;
      s.hasMore = true;
      s.error = null;
    });
    await _loadInitial(tab);
  }

  Future<DocumentPage> _fetch(_SubTab tab, int page) {
    switch (tab) {
      case _SubTab.pending:
        return DocumentService.instance.list(page: page, status: 'PENDING');
      case _SubTab.recent:
        return DocumentService.instance.list(page: page);
      case _SubTab.expiring:
        return DocumentService.instance.list(page: page, expiringWithin: 30);
    }
  }

  String _emptyMessage(_SubTab tab) {
    switch (tab) {
      case _SubTab.pending:  return 'មិនមានឯកសារកំពុងរង់ចាំ';
      case _SubTab.recent:   return 'មិនមានឯកសារថ្មីៗ';
      case _SubTab.expiring: return 'មិនមានឯកសារផុតកំណត់ក្នុង ៣០ ថ្ងៃ';
    }
  }

  String? _countLabel(_SubTab tab) {
    final s = _state[tab]!;
    if (s.items.isEmpty && s.isLoading) return null;
    if (s.items.isEmpty && s.error != null) return null;
    if (s.items.isEmpty) return null;
    return '${s.items.length}${s.hasMore ? '+' : ''}';
  }

  void _openDetail(Document doc) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => DocumentDetail(document: doc)),
    );
    if (changed == true) await _refresh(_active);
  }

  static const _tabLabels = ['កំពុងរង់ចាំ', 'ថ្មីៗ', 'ផុតកំណត់'];
  static const _tabs = [_SubTab.pending, _SubTab.recent, _SubTab.expiring];

  @override
  Widget build(BuildContext context) {
    final s = _state[_active]!;
    return Scaffold(
      backgroundColor: GColor.backgroundcolor,
      body: Column(
        children: [
          GradientHero(
            bottomPadding: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ឯកសារ',
                  style: TextStyle(
                    fontFamily: 'KhmerOSMoulLightRegular',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'គ្រប់គ្រងឯកសារនិងការអនុម័ត',
                  style: TextStyle(
                    fontFamily: 'KhmerOSSiemreap',
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _CountChip(
                      count: _countLabel(_SubTab.pending),
                      label: 'កំពុងរង់ចាំ',
                    ),
                    const SizedBox(width: 8),
                    _CountChip(
                      count: _countLabel(_SubTab.recent),
                      label: 'ថ្មីៗ',
                    ),
                    const SizedBox(width: 8),
                    _CountChip(
                      count: _countLabel(_SubTab.expiring),
                      label: 'នឹងផុត',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: SegmentedTabs(
                labels: _tabLabels,
                activeIndex: _tabs.indexOf(_active),
                onChanged: (i) {
                  setState(() => _active = _tabs[i]);
                  _loadInitial(_tabs[i]);
                },
              ),
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -10),
              child: RefreshIndicator(
                onRefresh: () => _refresh(_active),
                child: _buildList(s),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(_TabState s) {
    if (s.isLoading && s.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (s.error != null && s.items.isEmpty) {
      return ListView(children: [
        const SizedBox(height: 80),
        Center(child: Text(s.error!,
          style: const TextStyle(fontFamily: 'KhmerOSSiemreap'))),
        const SizedBox(height: 16),
        Center(child: TextButton(
          onPressed: () => _refresh(_active),
          child: const Text('ព្យាយាមម្តងទៀត',
            style: TextStyle(fontFamily: 'KhmerOSSiemreap')))),
      ]);
    }
    if (s.items.isEmpty) {
      return ListView(children: [
        const SizedBox(height: 100),
        Center(child: Text(_emptyMessage(_active),
          style: TextStyle(
            fontFamily: 'KhmerOSSiemreap',
            color: GColor.textMuted))),
      ]);
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 100) {
          _loadMore(_active);
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 6, bottom: 16),
        itemCount: s.items.length + (s.hasMore ? 1 : 0),
        itemBuilder: (ctx, i) {
          if (i >= s.items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final doc = s.items[i];
          return DocumentCard(document: doc, onTap: () => _openDetail(doc));
        },
      ),
    );
  }
}

class _TabState {
  final List<Document> items = [];
  int currentPage = 0;
  bool hasMore = true;
  bool isLoading = false;
  String? error;
}

class _CountChip extends StatelessWidget {
  final String? count;
  final String label;

  const _CountChip({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count ?? '—',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.9),
                fontFamily: 'KhmerOSSiemreap',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run `flutter analyze`**

Run: `flutter analyze lib/screens/document_screen/document_screen.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/screens/document_screen/document_screen.dart
git commit -m "feat(documents): apply vibrant-hero redesign with segmented tabs"
```

---

## Task 12: Full analyze + visual QA

**Files:**
- No code changes; verification only.

- [ ] **Step 1: Run full analyzer**

Run: `flutter analyze`
Expected: `No issues found!` (or pre-existing warnings only — none introduced).

If new warnings appeared, fix them and amend the relevant commit's follow-up commit. Do **not** use `--no-verify` or `git commit --amend` on a published commit.

- [ ] **Step 2: Run the app**

Run: `flutter run` (on a connected device or simulator).

- [ ] **Step 3: Walk through the acceptance checklist from the spec**

For each item below, observe on-device and mark ✓ or fix:

1. Home tab loads without changing API call counts — open `lib/services/api_client.dart` interceptor logs if needed; the three calls in `_loadData` are unchanged.
2. Hero gradient extends under the status bar; status-bar icons remain readable on the orange.
3. The "today" status pill matches `_todayMeetings` (try with 0 and >0 by tapping refresh after toggling backend data).
4. All four quick-action tiles share the same orange icon-tile tint.
5. "កក់" tile is hidden when the signed-in role has `_canManage == false`.
6. Tapping each quick-action navigates to the right tab (verify by watching the bottom-nav highlight change).
7. Upcoming meeting cards show time / weekday / title / room — tap one and confirm `MeetingDetailsScreen` opens.
8. Notification card shows the new icon-square tile and routes to the alerts tab when tapped.
9. The bottom orange "កាលវិភាគថ្ងៃនេះ" banner no longer exists on the Home tab.
10. Documents tab shows the gradient header with title + subtitle + three count chips.
11. Switching between កំពុងរង់ចាំ / ថ្មីៗ / ផុតកំណត់ animates the active pill and triggers `_loadInitial` for unloaded tabs.
12. Document rows show the tinted icon, title, meta line, status badge.
13. Pull-to-refresh works on both tabs.

If any item fails, fix in the smallest possible commit and run `flutter analyze` again before committing.

- [ ] **Step 4: Final commit for any QA fixes**

If fixes were needed:

```bash
git add <files>
git commit -m "fix(redesign): visual QA touch-ups"
```

If no fixes were needed, this task ends here — no empty commit.

---

## Spec Coverage Self-Check

| Spec section | Implemented in |
|---|---|
| Home hero (avatar/name/settings/today pill) | Task 9 |
| Home stat cards floating over hero | Task 6 + Task 9 |
| Home quick actions (4-up, single tint, hide booking when !canManage) | Task 4 + Task 9 |
| Home upcoming meetings (compact time-block card) | Task 7 + Task 9 |
| Home notifications (tinted icon tile) | Task 8 + Task 9 |
| Home bottom gradient banner removed | Task 9 |
| Documents hero (title/subtitle/3 count chips) | Task 11 |
| Documents floating segmented tabs | Task 5 + Task 11 |
| Documents row restyle (tinted icon + status badge) | Task 10 |
| Design tokens in `GColor` | Task 1 |
| Shared widgets (`GradientHero`, `SectionHeader`, `QuickActionTile`, `SegmentedTabs`) | Tasks 2–5 |
| No emoji in source | Tasks 4, 8, 9, 10, 11 (all use `Icons.*`) |
| No raw hex in screen files | Tasks 9 and 11 use `GColor.*` only |
| Acceptance criteria walkthrough | Task 12 |