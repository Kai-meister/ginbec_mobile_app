
# Document Tracking Tab — Design Spec

**Date:** 2026-05-17
**Status:** Design approved, ready for implementation planning
**Owner:** chingtainchung@gmail.com

## Goal

Add a 5th bottom-nav tab ("ឯកសារ" / Documents) to the GINBEC mobile app, allowing officers and admins to track documents through their approval workflow, monitor expiry dates, and view recently submitted documents.

The tab is read-and-act focused on mobile — no document creation or editing. Heavy management remains on the web admin panel.

## Scope

### In scope
- New bottom-nav tab labelled `ឯកសារ` between Meetings and Alerts.
- Three sub-tabs on the screen: Pending (កំពុងរង់ចាំ), Recent (ថ្មីៗ), Expiring (ផុតកំណត់).
- Server-side filtered list per sub-tab (Approach A from brainstorming).
- Role-aware scope: non-admin users only see their own documents (client-side filter inject); admins see all.
- Document detail screen with view-only fields.
- Download/view attached file via `url_launcher` (opens system default).
- Approve / Reject actions on the detail screen, visible only to users with the `DOC_APPROVE` permission. Reject prompts for a free-text reason.

### Out of scope
- Creating, editing, or deleting documents on mobile.
- In-app PDF viewer (deferred — system default viewer is sufficient for MVP).
- Bulk approve / reject.
- Document type management (admin web only).
- Search / advanced filtering UI (deferred — only the 3 sub-tabs for now).
- Offline caching.

## Architecture

### Backend dependencies

Production backend: `https://ginbecc-backend.onrender.com/api/v1`

Endpoints consumed:

| Verb | Path | Purpose |
|---|---|---|
| `GET` | `/documents` | List documents with filters (`status`, `officer_id`, `expiring_within`, `page`, `size`) |
| `GET` | `/documents/{id}` | Refresh single document on detail screen pull-to-refresh |
| `GET` | `/lookups/document-statuses` | Fetch status codes + Khmer labels for badges |
| `GET` | `/attachments/{id}/download` | Get presigned R2 URL for the attached file |
| `POST` | `/approvals` | Approve or reject a document (exact payload shape to verify during implementation) |

Auth: existing `ApiClient` bearer-token interceptor handles all requests. No new infra needed.

### File layout

```
lib/
  screens/
    document_screen/
      document_screen.dart        # 5th nav target, owns 3 sub-tabs
      document_detail.dart        # detail page, pushed via Navigator
  services/
    document_service.dart         # wraps /documents endpoints
    attachment_service.dart       # wraps /attachments/{id}/download
    approval_service.dart         # wraps /approvals (approve/reject)
  models/
    document.dart                 # Document model + fromJson
    document_status.dart          # status code → label/color mapping (loaded from /lookups)
  widgets/
    document_card.dart            # list row: name, type, officer, status badge, expiry
```

### Navigation changes

`lib/screens/mainscreen.dart`:
- Add `DocumentScreen()` to `_page` at index 2 (between Meetings and Alerts).
- Indices shift: Alerts becomes 3, Settings becomes 4.
- Add 5th `TabButton`: title `ឯកសារ`, icon `Icons.description`.
- Audit any hardcoded tab indices in `Home`'s `onNavigateToTab` callback and update if needed.

## UI Design

### Document screen (main tab)

```
┌─────────────────────────────────────────┐
│  ឯកសារ                                   │   AppBar
├─────────────────────────────────────────┤
│  [កំពុងរង់ចាំ] [ថ្មីៗ] [ផុតកំណត់]      │   TabSwitch
├─────────────────────────────────────────┤
│  ┌────────────────────────────────┐    │
│  │ 📄 RECEIPT.pdf     [PENDING]   │    │   document_card
│  │ Type: Receipt                   │    │
│  │ Officer: Mr. Sok                │    │
│  │ Expires: 2026-12-31 (in 228d) │    │
│  └────────────────────────────────┘    │
│  ...                                    │
└─────────────────────────────────────────┘
```

#### Sub-tabs

| Sub-tab | Khmer | API params | Empty state |
|---|---|---|---|
| Pending | `កំពុងរង់ចាំ` | `status=PENDING&page=0&size=20` | `មិនមានឯកសារកំពុងរង់ចាំ` |
| Recent | `ថ្មីៗ` | `page=0&size=20` (sort fallback: client-side desc by `createdAt`) | `មិនមានឯកសារថ្មីៗ` |
| Expiring | `ផុតកំណត់` | `expiring_within=30&page=0&size=20` | `មិនមានឯកសារផុតកំណត់ក្នុង ៣០ ថ្ងៃ` |

Note: The exact pending status code (`PENDING` vs the backend's actual code) is verified from `/lookups/document-statuses` at first screen load.

#### Role scoping

```dart
final isAdmin = permissions.contains('DOC_APPROVE');
final params = {
  'page': currentPage,
  'size': 20,
  if (!isAdmin) 'officer_id': currentOfficerId,
  ...subTabParams,
};
```

Officer-scoped filter is injected client-side. The backend ultimately enforces row-level access — the client filter is for UX (no point fetching what won't render).

#### Status badge colors

| `statusCode` | Color |
|---|---|
| `PENDING` (or equivalent) | `GColor.secondarycolor` (`#FC9400`) |
| `APPROVED` | `#22A06B` |
| `REJECTED` | `#E5484D` |
| Other / unknown | Neutral grey |

Labels come from `statusLabel` in the API response, falling back to the lookup table.

#### Per-tab state

Each sub-tab maintains its own state:
- `items: List<Document>`
- `currentPage: int`
- `hasMore: bool`
- `isLoading: bool`
- `error: String?`

Pull-to-refresh resets to page 0. Scroll near bottom fetches next page.

### Document detail screen

```
┌─────────────────────────────────────────┐
│  ← ឯកសារ                                 │   AppBar
├─────────────────────────────────────────┤
│   📄                                     │
│   RECEIPT.pdf                            │
│   #DOC-2024-001                          │
│                                          │
│   [● PENDING]                            │   status badge
├─────────────────────────────────────────┤
│  ប្រភេទ            Receipt               │
│  មន្ត្រី            Mr. Sok               │
│  ថ្ងៃផុតកំណត់       2026-12-31 (in 228d) │
│  បានបង្កើត         2026-05-17            │
│                                          │
│  ចំណាំ                                    │
│  ┌────────────────────────────────┐    │
│  │ Submitted for monthly review.  │    │
│  └────────────────────────────────┘    │
├─────────────────────────────────────────┤
│  [  📥 ទាញយកឯកសារ                 ]    │   primary action
│                                          │
│  ┌─ admin-only ──────────────────┐    │
│  │ [ ✓ យល់ព្រម ]   [ ✗ បដិសេធ ] │    │   approve / reject
│  └───────────────────────────────┘    │
└─────────────────────────────────────────┘
```

#### Behavior

- **Source**: `Document` passed in via constructor from the list. No additional fetch on initial render. Pull-to-refresh hits `GET /documents/{id}` for a fresh copy.
- **Download** (`ទាញយកឯកសារ`): Tap → resolve attachment URL → `url_launcher.launchUrl(...)`. Show loading spinner during URL fetch; snackbar on error.
- **Approve** (admin only): Tap → confirmation dialog → `POST /approvals` with `documentId` and `decision: APPROVED` → snackbar + pop back to list + invalidate Pending tab cache.
- **Reject** (admin only): Tap → dialog with `TextField` for reason (required, free-text) → `POST /approvals` with `documentId`, `decision: REJECTED`, `reason` → same post-action flow.

#### Edge cases

| Condition | Handling |
|---|---|
| `fileUrl` / `attachmentId` null or empty | Hide download button |
| `expiryDate` null | Show `—` in the row |
| `note` empty | Hide the note section entirely |
| API error on approve/reject | Snackbar using backend `message` field |
| Network error on download URL | Snackbar `មិនអាចទាញយកបាន` (cannot download) |

### Khmer labels reference

| English | Khmer |
|---|---|
| Documents (tab) | ឯកសារ |
| Pending | កំពុងរង់ចាំ |
| Recent | ថ្មីៗ |
| Expiring | ផុតកំណត់ |
| Type | ប្រភេទ |
| Officer | មន្ត្រី |
| Expiry date | ថ្ងៃផុតកំណត់ |
| Created | បានបង្កើត |
| Note | ចំណាំ |
| Download file | ទាញយកឯកសារ |
| Approve | យល់ព្រម |
| Reject | បដិសេធ |
| Reject reason | មូលហេតុបដិសេធ |

## Data Models

### `Document` (lib/models/document.dart)

```dart
class Document {
  final int documentId;
  final String? officerName;
  final String? documentTypeName;
  final String documentName;
  final String? documentNumber;
  final String? note;
  final String statusCode;
  final String statusLabel;
  final DateTime? expiryDate;
  final String? fileUrl;          // may be presigned URL or relative
  final int? attachmentId;         // if backend exposes it; otherwise parse from fileUrl
  final DateTime createdAt;

  factory Document.fromJson(Map<String, dynamic> json) { ... }
}
```

Note: The OpenAPI spec shows `fileUrl` on `DocumentResponse` but not `attachmentId`. During implementation, verify with one live API call whether `fileUrl` is directly usable (presigned R2) or whether we need a separate attachment ID lookup. If only `fileUrl` is present and it's presigned, we can skip `AttachmentService` for the download path.

### `DocumentStatus` lookup

Loaded once on first screen entry, cached in memory (or in `StorageService` if it should survive cold starts).

```dart
class DocumentStatus {
  final String code;
  final String labelKh;
  final Color badgeColor;
}
```

## Permissions

| Permission | Affects |
|---|---|
| `DOC_VIEW_OWN` | Required to access the tab at all (all logged-in users have it) |
| `DOC_APPROVE` | Reveals Approve/Reject buttons + unlocks admin-wide list view |

If `DOC_APPROVE` is absent, the user gets the officer-scoped view (`officer_id` filter injected) and no approval buttons.

## Error Handling

| Scenario | UX |
|---|---|
| 401 on any call | Existing `ApiClient` interceptor refreshes token or redirects to login |
| 403 on `/documents` | Snackbar: `មិនមានសិទ្ធិមើល` (no permission) |
| Network failure | Inline error state with retry button |
| Empty list | Sub-tab-specific empty-state message (table above) |
| Approve/reject 4xx/5xx | Snackbar with backend `message` |

## Testing

Manual UAT against staging:
1. Log in as `admin@system.kh` → tab shows all documents across officers; Approve/Reject visible.
2. Log in as a non-admin officer → tab shows only that officer's documents; no Approve/Reject.
3. Each sub-tab loads its correct slice; switching is fast.
4. Pull-to-refresh resets to page 0 on each sub-tab.
5. Scrolling near the bottom triggers next page fetch.
6. Tap document → detail screen renders all fields.
7. Tap download → file opens in device's default PDF viewer.
8. As admin, approve a pending doc → it disappears from Pending and appears in Recent.
9. As admin, reject with a free-text reason → status updates accordingly.
10. Khmer labels render with correct font (`KhmerOSSiemreap`).

No automated test suite for now; this matches the current state of the project (no tests in `test/` for screens).

## Open implementation questions (to resolve during plan-writing)

1. Exact `POST /approvals` payload — verify shape via `/v3/api-docs` lookup before implementation.
2. Whether `DocumentResponse.fileUrl` is a presigned R2 URL (then no separate attachment call needed) or a stable internal path (then we need attachment ID).
3. Whether `currentOfficerId` is on the existing login response — yes per the login response (`userId: 1`), but confirm that maps to `officer_id` filter, or whether officers have a separate ID.

## References

- OpenAPI spec: `https://ginbecc-backend.onrender.com/v3/api-docs`
- Swagger UI: `https://ginbecc-backend.onrender.com/swagger-ui/index.html`
- Existing nav source: `lib/screens/mainscreen.dart`
- Existing API client: `lib/services/api_client.dart`
- Existing storage / auth: `lib/services/storage_service.dart`
- Color tokens: `lib/config/color.dart`