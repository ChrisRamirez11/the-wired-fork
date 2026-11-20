# AGENTS.md — Tauri (v2) + web frontend

Project spec: `docs/spec.md` (what the project is). Read it before planning or coding.

## Verify (run all, in order, before calling any step done)
Rust (from `src-tauri/`):
1. `cargo fmt --check`
2. `cargo clippy --all-targets -- -D warnings`
3. `cargo test`

Frontend (from `app/`; package manager is `pnpm` per `pnpm-lock.yaml`):
4. `pnpm exec tsc --noEmit`
5. `pnpm build`
(Note: `lint` and `vitest` scripts are not configured in `package.json` yet; check `package.json` before running `pnpm lint` or `pnpm vitest run`.)

Run only the half that the step touched, but run both if the step changes the IPC boundary (commands, events, shared types).
Do not run `tauri dev` or `tauri build` (long-running / slow). Ask the user.
Check `package.json` scripts and `Cargo.toml` before assuming a tool exists.

## Project-specific
- Frontend framework: React 19.1 + TypeScript (~6.0, strict) + Vite 8 + Fluent UI React v9 (`@fluentui/react-components`, `@fluentui/react-icons`), managed with `pnpm`.
- Tauri plugins in use: `opener`, `dialog`, `process`, `notification`, `log`, `clipboard-manager`, `updater` (desktop targets only), plus Tauri `tray-icon` (`image-png`).
- State/persistence:
  - Rust (`tauri::State`): `JkClient` (shared `reqwest` client with cookie jar), `SettingsState` (`Mutex<Settings>` persisted to `<app_config_dir>/settings.json`), `DownloadManager` (persistent queue in `<app_data_dir>/downloads.json`), `Arc<catalog::Index>` (library metadata cache in `<app_data_dir>/library.json`), and `HasTray(bool)`.
  - Frontend: React state in `src/App.tsx` synced via Tauri commands and `"download-updated"` events; theme mode and Fluent accent preferences in `localStorage` (`remo.theme`).
- Target OS: Windows 10/11 (x64: NSIS `.exe` currentUser, `.msi`) and Linux (amd64: AppImage, `.deb`, `.rpm`). macOS is out of scope for now.

## Conventions
- Rust side: `#[tauri::command]` functions in `src-tauri/src/lib.rs` stay thin. Business logic lives in plain modules (`jkanime/`, `download.rs`, `library.rs`, `catalog.rs`, `settings.rs`, `tools.rs`, `tray.rs`) that can be tested without Tauri.
- Errors: scraper errors use `jkanime::JkError` (`thiserror` + `Serialize` with `Unavailable`, `NotFound`, `SiteChanged`); other commands return `Result<T, String>`. Avoid `unwrap()` / `expect()` in new production code outside tests.
- Shared state through `tauri::State` (with `Mutex`/atomics as needed). Async commands use Tauri's Tokio async runtime (`tokio`).
- IPC contract: every command and event in `src-tauri/src/lib.rs` / `download.rs` / `tools.rs` has a matching TypeScript type and wrapper in `src/api.ts`. Change both sides in the same step.
- Security: capabilities/permissions in `src-tauri/capabilities/` (`default.json`, `desktop.json`) stay minimal. Never grant broad fs or shell scopes. The frontend reaches the OS only through commands or scoped plugins.
- Frontend rules: strict TypeScript (`strict`, `noUnusedLocals`, `noUnusedParameters`), validate inputs, no `any`. UI copy is in Spanish.
- No new crates or npm packages unless the plan says so.

## Tests
- Rust: unit tests next to the code (`#[cfg(test)]`) and integration tests in `src-tauri/tests/` (`scraper.rs`, `library.rs`, `downloads.rs`, `tools.rs`) using offline HTML/JSON fixtures in `src-tauri/tests/fixtures/`.
- Frontend: if Vitest is added, mock the IPC layer at the single boundary (`src/api.ts`), not everywhere.

## Lessons (add a rule here every time the agent fails the same way twice)
- (empty)