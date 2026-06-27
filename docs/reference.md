# Project Reference

## Local

| Item | Value |
|------|-------|
| Path | `C:\Users\dance\Documents\MEGA\yose-gaki` |
| Source dir | `C:\Users\dance\Documents\MEGA\yose-gaki\src` |
| Entry point | `src/yosegaki.html` |
| Active branch | `main` |
| Stack | Vanilla JS + Firebase Firestore |
| Firestore | ✅ Native mode, `asia-northeast1` |
| Firestore rules | `src/firestore.rules` (test mode: full open) |

## Repositories

| Repo | URL | Stack | Status |
|------|-----|-------|--------|
| **yosegaki-web** (V2) | https://github.com/bonsai/yosegaki-web.git | Vanilla JS + Firestore | 🟢 Active |
| **shikishi** (V3) | https://github.com/bonsai/shikishi.git | Nuxt 3 + Vue + Supabase | 🚧 Scaffold |
| Issues | https://github.com/bonsai/yosegaki-web/issues | — | 🟢 |
| Priority Board | #31 | auto-generated | 🟢 |

## Firebase

| Item | Value |
|------|-------|
| Project ID | `yosegaki-web` |
| Display Name | `yosegaki` |
| Project Number | `611683418640` |
| Billing | ✅ Blaze (linked to `010C94-BD0400-C615BD`) |
| Console | https://console.firebase.google.com/project/yosegaki-web/overview |

### Hosting Sites

| Site ID | URL | Status |
|---------|-----|--------|
| **`yose-gaki`** | **https://yose-gaki.web.app** | 🟢 **Active (main target)** |
| `yosegaki-web` | https://yosegaki-web.web.app | ⚪ Default (cannot delete) |

8 legacy sites deleted (2026-06-20): `bonsai-yosegaki`, `dance-yosegaki`, `iro-gami`, `irogami-board`, `shikishi`, `shikishi-board`, `yose-board`, `yosegakiboard`.

### Firebase Config (src/config.js)

```js
const FIREBASE_CONFIG = {
  apiKey: 'AIzaSyAUgL9kgERU2BCyLl1MbcxLU3KKyWrodLg',
  authDomain: 'yose-gaki.web.app',
  projectId: 'yosegaki-web',
  storageBucket: 'yosegaki-web.firebasestorage.app',
  messagingSenderId: '611683418640',
  appId: '1:611683418640:web:87b4e8359a97481926c095',
}
```

### Multi-Site Target Mapping (src/.firebaserc)

```json
{
  "projects": { "default": "yosegaki-web" },
  "targets": {
    "yosegaki-web": {
      "hosting": {
        "main": ["yose-gaki"]
      }
    }
  }
}
```

### Deploy Commands

| Action | Command |
|--------|---------|
| Full deploy | `cd src && firebase deploy` |
| Hosting only | `cd src && firebase deploy --only hosting` |
| Firestore rules | `cd src && firebase deploy --only firestore:rules` |
| Emulator | `cd src && firebase emulators:start` |
| Preview channel | `cd src && firebase hosting:channel:deploy <name>` |

## Branches

| Branch | Status | Note |
|--------|--------|------|
| `main` | 🟢 Active | Current work. Reset to `master` HEAD. |
| `master` | 🟢 Active | Upstream. Same as `main`. |
| `depuroi` | ❌ Deleted | Merged into `master` (commit `956ea61`). |
| `v2` | ❌ Deleted | Docs-only, not needed. |

## Open Issues

| # | Title | Priority | Status |
|---|-------|----------|--------|
| 27 | [Test] Verify iOS Safari focus after review fix | P0 | Open |
| 30 | [Test] Smoke test checklist | P0 | Open |
| 31 | Sprint Priority Board (auto) | P0 | Open |
| 33 | [Setup] Supabase secrets for CI/CD | - | Open |

## V3 Plan

See `docs/V3_PLAN.md` — Nuxt 3 + Vue + Vite + Supabase + Cloudflare Pages

## Cost

| Service | Plan | Limit |
|---------|------|-------|
| Firebase Hosting | Blaze (Spark free tier) | 10GB storage, 360MB/day bandwidth |
| Cloud Firestore | Blaze | 1GB stored, 50K reads/day, 20K writes/day |
| Billing Account | `010C94-BD0400-C615BD` (Firebase Payment) |

