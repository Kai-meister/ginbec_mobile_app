# Backend Integration Log

Tracks every change made while connecting the Flutter frontend to the Spring Boot backend (`http://localhost:8080/api/v1`).

---

## Step 1 — Fix pubspec.yaml + flutter pub get

**File modified:** `pubspec.yaml`

**Problems fixed:**
- Line 50 was malformed: `^2.3.13jwt_decoder: ^2.0.1` (two packages smashed together)
- `custom_lint: ^0.6.7` conflicted with the current Dart SDK

**Changes:**
```yaml
# Before (broken)
^2.3.13jwt_decoder: ^2.0.1
custom_lint: ^0.6.7

# After (fixed)
riverpod_annotation: ^2.3.13
jwt_decoder: ^2.0.1
custom_lint: ^0.7.3
```

**Result:** `flutter pub get` resolved all 90 dependencies cleanly.

---

## Step 2 — Storage Service

**File created:** `lib/services/storage_service.dart`

**Purpose:** Wraps `flutter_secure_storage` to persist JWT tokens and user info on-device. Used by the API client and all screens that need auth.

**What it stores:**

| Key | Value |
|---|---|
| `access_token` | JWT access token (24h lifetime) |
| `refresh_token` | JWT refresh token (7d lifetime) |
| `user_id` | Logged-in user's integer ID |
| `user_email` | Logged-in user's email |
| `user_name` | Logged-in user's display name (EN preferred, KH fallback) |

**Key methods:**
- `saveTokens(accessToken, refreshToken)` — saves both tokens in parallel
- `saveUserId(int)` / `getUserId()` — user ID for API calls that need `?userId=`
- `saveUserName(String)` / `getUserName()` — display name for the Home screen header
- `clearAll()` — wipes everything on logout

---

## Step 3 — API Client

**File created:** `lib/services/api_client.dart`

**Purpose:** Singleton Dio HTTP client used by every screen to make API calls.

**Configuration:**
- Base URL: `http://localhost:8080/api/v1` (change this one line when deploying to a real server)
- Connect timeout: 10s
- Receive timeout: 15s

**`_AuthInterceptor` behaviour:**
- **Before every request** — reads access token from `StorageService` and injects `Authorization: Bearer <token>`. Skips the login endpoint so it doesn't loop.
- **On 401 response** — calls `POST /auth/refresh-token` with the stored refresh token, saves the new tokens, then retries the original request transparently. If refresh fails, calls `clearAll()` to force the user back to the login screen.

**Also included:** `LogInterceptor` prints full request/response bodies to the console during development.

---

## Step 4 — Login Screen wired to API

**File modified:** `lib/screens/login_screen/login.dart`  
**File modified:** `lib/services/storage_service.dart` (added `saveUserName` / `getUserName`)

**What changed in login.dart:**
- Controllers renamed from `txtEmail`/`txtPassword` to `_txtEmail`/`_txtPassword` (private)
- Added `_isLoading` state bool
- Added `_login()` async method:
  - Validates fields are not empty before hitting the network
  - Calls `POST /api/v1/auth/login` with `{email, password}`
  - On success: saves `accessToken`, `refreshToken`, `userId`, `email`, `userNameEn` (falls back to `userNameKh`, then email) to `StorageService`
  - Navigates to `MainScreen` using `pushReplacement` (can't go back to login)
  - On `DioException`: shows backend's `message` field in a red floating snackbar
  - On any other error: shows generic Khmer error message
- Button shows "កំពុង Login..." and turns grey while request is in-flight
- `dispose()` added to clean up both controllers

**What changed in storage_service.dart:**
- Added `_keyUserName` constant
- Added `saveUserName(String)` and `getUserName()` methods

---

## Step 5 — Home Screen wired to API

**File modified:** `lib/screens/home_screen/home.dart`

**What changed:**
- Converted from `StatelessWidget` → `StatefulWidget`
- `_loadData()` fetches 3 APIs in parallel on `initState`:
  - `GET /dashboard/summary?userId=<id>` → today's meetings count + unread notifications count
  - `GET /meetings?status=SCHEDULED&size=3` → upcoming meetings list + total count
  - `GET /notifications/my?userId=<id>&isRead=false&size=3` → recent unread notifications
- DashCards show real numbers: today's meetings / upcoming count / unread count
- Username pulled from `StorageService` (saved at login)
- Upcoming Meetings shows real EventCards (max 2), or "No upcoming meetings" if empty
- Recent Notifications shows real unread items, or "No new notifications" if empty
- Today's Schedule banner shows real count
- Pull-to-refresh via `RefreshIndicator`
- Loading spinner while data is fetching

---

## Step 6 — Meeting Screen wired to API

**File modified:** `lib/screens/meeting_screen/meetingscreen.dart`

**What changed:**
- `_loadData()` fetches 2 APIs in parallel on `initState`:
  - `GET /meeting-rooms?status=AVAILABLE` → room list (returns plain List, not paginated)
  - `GET /meetings?page=0&size=50` → all meetings for "My Bookings" tab
- Room mapping: `roomCode` → name, `location` → floor, `capacity`, `AVAILABLE/UNAVAILABLE` → `RoomStatus`
- Booking mapping: `title` → roomName, `meetingDate`/`startTime`/`endTime` parsed, backend status codes mapped to `BookingStatus` (CONFIRMED/IN_PROGRESS/COMPLETED → confirmed, CANCELLED/POSTPONED → cancelled, rest → pending)
- Search filters both lists client-side in real time
- Empty states shown for both tabs
- Pull-to-refresh reloads both lists

---

## Step 7 — Alerts Screen wired to API

**File modified:** `lib/screens/alert_screen/alert.dart`

**What changed:**
- Converted from `StatelessWidget` → `StatefulWidget`
- Fetches `GET /api/v1/notifications/my?userId=<id>&size=50` on load
- Tap a notification → `PUT /notifications/{id}/read`, updates card state locally (no full reload)
- "Mark all read" → `PUT /notifications/read-all?userId=<id>`, flips all cards to read locally
- "Mark all read" button only visible when there are unread notifications
- Unread count updates live as cards are tapped
- Empty state: "No notifications yet"
- Pull-to-refresh reloads from API

---

## Step 8 — Settings Logout wired to API

**File modified:** `lib/screens/setting_screen/setting.dart`

**What changed:**
- Added imports for `ApiClient` and `StorageService`
- Added `_isSigningOut` bool to prevent double-taps
- `_signOut()` method:
  1. Calls `POST /api/v1/auth/logout` (interceptor auto-sends Bearer token for backend blacklisting)
  2. Falls through even if API fails (Redis down = still logs out locally)
  3. Calls `StorageService.clearAll()` to wipe all tokens/user info from device
  4. Uses `pushAndRemoveUntil` → user cannot press Back to return to app
- Sign Out button shows small red spinner while signing out

---

## Summary — Files Created/Modified

| File | Action |
|---|---|
| `pubspec.yaml` | Fixed malformed line, upgraded `custom_lint` |
| `lib/services/storage_service.dart` | Created |
| `lib/services/api_client.dart` | Created |
| `lib/screens/login_screen/login.dart` | Modified |
| `lib/screens/home_screen/home.dart` | Modified |
| `lib/screens/meeting_screen/meetingscreen.dart` | Modified |
| `lib/screens/alert_screen/alert.dart` | Modified |
| `lib/screens/setting_screen/setting.dart` | Modified |
| `lib/main.dart` | Removed unused import |