# Remo

> A fork of [ani-es](https://github.com/Zhuchii/ani-es) with built-in download support for **Jellyfin** libraries.

Anime downloader with two ways to use it:

| | Who it is for | What it does |
|---|---|---|
| 🖥️ **[Desktop app](#desktop-app-windows-and-linux)** | Most people: install and use | Search, download with a queue, pause and retries, and browse your library. Windows and Linux |
| ⌨️ **[Terminal script](#terminal-script)** | People who live in the terminal | The original player + downloader (ani-es), with `fzf` and `mpv` |

Both save downloads with the same Jellyfin-compatible folder structure, so you can use either one over the same library.

---

## Desktop app (Windows and Linux)

### Download

Download the installer from the **[latest release](https://github.com/chrisdjobs/remo/releases/latest)**:

| System | File |
|---|---|
| **Windows 10/11** | `Remo_X.Y.Z_x64-setup.exe` (recommended) or `.msi` |
| **Linux** (any distro) | `Remo_X.Y.Z_amd64.AppImage` |
| **Debian / Ubuntu** | `.deb` |
| **Fedora / openSUSE** | `.rpm` |

The `.sig` files that accompany each installer are signatures for automatic updates: you do not need to download them.

- **Windows:** the installer is not signed with a paid certificate, so SmartScreen may warn that *"Windows protected your PC"*. Click **More info → Run anyway**. It installs for your user, without asking for administrator permissions.
- **AppImage:** give it execute permission (`chmod +x Remo_*.AppImage`) and open it.

### What it does

- **Search** for an anime and see its page: episodes, type, quality and which ones you already have downloaded.
- **Download** single episodes or the whole season, with a **queue** that can be **paused and resumed** and that picks up again by itself when you reopen the app.
- **Automatic retries** (after 1, 5 and 15 minutes) when the site fails, and a **notification** when it finishes.
- **Tray icon**: if you close the window with downloads in progress, they keep going in the background.
- **Library**: everything you have downloaded (including what was downloaded with the script), with covers, episodes, size and warnings about half-finished downloads.
- **Optional Jellyfin layout** (`Season 01/<Anime> - S01E01.mp4`) and season detection from the title (*"Overlord II"* → series *Overlord*, season 2).
- **Multiple sources**: jkanime and HentaiJK (+18 content, **disabled by default**), each with its own library folder.
- Light / dark theme with Fluent accent colors.

### First launch

The app does not bundle the download tools in the installer. The first time it offers to download them from their official repositories:

- **yt-dlp** (Windows and Linux) and **ffmpeg** (Windows only; on Linux the one from your package manager is used).
- If you already have them installed on your system, the app uses those.

### Updates

On startup the app checks whether a new version is available and offers it with a notice: one click downloads it, installs it and restarts. Updates are signed and the app rejects any that are not.

### If something goes wrong

In **Ajustes → Registro → Copiar registro** (Settings → Log → Copy log) the version, the system, the tools and the last thing the app did are copied. Paste it when [opening an issue](https://github.com/chrisdjobs/remo/issues).

### Where it stores its data

| | Windows | Linux |
|---|---|---|
| Settings | `%APPDATA%\io.github.chrisdjobs.remo\` | `~/.config/io.github.chrisdjobs.remo/` |
| Queue, library index, bundled yt-dlp/ffmpeg | `%APPDATA%\io.github.chrisdjobs.remo\` | `~/.local/share/io.github.chrisdjobs.remo/` |
| Log | `%LOCALAPPDATA%\io.github.chrisdjobs.remo\logs\` | `~/.local/share/io.github.chrisdjobs.remo/logs/` |

Your library folder only contains the videos: the app stores nothing else there.

### Build from source

Requires [Rust](https://rustup.rs/), Node.js and [pnpm](https://pnpm.io/), plus the [Tauri dependencies](https://tauri.app/start/prerequisites/) for your system.

```bash
cd app
pnpm install
pnpm tauri dev      # development mode
pnpm tauri build    # installers in app/src-tauri/target/release/bundle/
```

Design and project phases: [`docs/app-tauri.md`](docs/app-tauri.md).

---

## Terminal script

**Player + downloader** for anime in Spanish from the terminal. Keeping the original ani-es scraper intact, it adds the ability to download episodes and complete seasons directly into a Jellyfin-compatible folder structure.

---

## ⚠️ Important note

**Tested environments (script):**

- **Windows 11** with Git Bash / MINGW64 (not WSL) in Windows Terminal
- **Linux:** CachyOS (Arch) with bash; downloads go straight to a Jellyfin library

It has not been tested on macOS or WSL.

Remo (script and app) depends on the jkanime.net site: if the site changes its HTML, search or video extraction may stop working until the scraper is updated. In that case the script says so and suggests `remo -u`, and the app warns that *"the site seems to have changed"*.

---

## ✨ What's new

The original ani-es was only a player. Remo adds an integrated download system without rewriting the scraper:

### Downloading individual episodes

After selecting an episode, instead of playing it automatically, a menu appears:

```
Reproducir
Descargar episodio
Descargar temporada
Atrás
```

Selecting **Descargar episodio** (Download episode) gets a fresh stream URL (`.m3u8`) and downloads it with `yt-dlp`, producing a Jellyfin-compatible MP4.

### Downloading complete seasons

**Descargar temporada** (Download season) iterates over all available episodes. Each episode gets its own fresh URL right before being downloaded — **URLs are never cached** because the `st` and `e` parameters of the `.m3u8` are temporary.

When finished it shows a summary:

```
====================================
      DESCARGA COMPLETADA
====================================

Anime: Elfen Lied
Temporada: 1

Descargados: 11
Ya existentes: 2
Fallidos: 0
Total: 13
```

### Jellyfin structure

Downloads are saved in the format Jellyfin expects:

```
<ANIME_DOWNLOAD_DIR>/
  Elfen Lied/
    Season 01/
      Elfen Lied - S01E01.mp4
      Elfen Lied - S01E02.mp4
      ...
```

The default path is `<Videos folder>/Anime` (on Linux, `~/Videos/Anime` or whatever `xdg-user-dir VIDEOS` reports). It can be changed with `ANIME_DOWNLOAD_DIR` (see "Configuration").

### Download mode (`-d` / `--download`)

```bash
remo -d
remo --download
```

Hides the "Reproducir" (Play) option from the menu, leaving only the download options. Useful if you use Remo mainly as a downloader.

### Detection of already-downloaded episodes

Before downloading an episode, Remo checks whether the MP4 file already exists and is valid (with `ffprobe`). If it is, it skips it. If a partial file (`.part`) exists, it downloads it again. Complete downloads are never overwritten.

### No re-encoding

The server delivers H.264 1920x1080 video + AAC audio. `yt-dlp` with `--merge-output-format mp4` only remuxes (changes the container) without re-encoding, so the download is fast and lossless.

---

## 🔧 What was NOT modified

To minimize the risk of breaking something that already worked:

- **Scraper:** the scraping block of `videocap()` was extracted into a `scrape_episode()` function but the code is **identical** (same 48 lines, empty diff). The providers and URL-fetching logic were not touched.
- **Anime search:** unchanged.
- **Anime and episode selection:** unchanged.
- **mpv playback:** unchanged. History (`history.json`) still works the same and downloads do not modify it.
- **Existing commands:** `-h`, `-v`, `-c` still work the same.
- **Self-update:** rewritten in 1.4.2 (see "Updates" under Configuration).

---

## 📦 Installing the script on Linux

```bash
git clone https://github.com/chrisdjobs/remo.git
cd remo
./install.sh          # installs dependencies and copies remo to ~/.local/bin
# ./install.sh --link # or: link to the clone, and update with git pull
```

It does not copy anything as root: it only uses `sudo` to install dependencies with the package manager (pacman, apt, dnf or zypper). To remove it: `./uninstall.sh` (add `--purge` to also delete the history).

## 📦 Installing the script (Windows 11 + Git Bash)

> This installation guide follows the same approach as [ani-cli](https://github.com/pystardust/ani-cli) for Windows, since both scripts run on Git Bash / MINGW64.

### 1. Install Scoop

Open **PowerShell** and follow the instructions at [scoop.sh](https://scoop.sh/) (quickstart).

### 2. Install Windows Terminal

It comes preinstalled on Windows 11. If you don't have it:

```powershell
scoop bucket add extras
scoop install extras/windows-terminal
```

### 3. Install Git

If you already have it, update it. If not:

```powershell
scoop install git
```

### 4. Set up the Git Bash profile in Windows Terminal

Make sure **Git Bash** appears in the Windows Terminal profile menu (new tab button).

If it does not appear, add it manually:

1. Go to **Settings → Profiles → Add a new profile → + New empty profile**
2. **Name:** `Git Bash`
3. **Command line:**
   - If you installed git with scoop: `%GIT_INSTALL_ROOT%\bin\bash.exe -i -l`
   - If you installed git another way: `C:\Program Files\Git\bin\bash.exe -i -l`
4. **Icon:** `%GIT_INSTALL_ROOT%\mingw64\share\git\git-for-windows.ico` (or the equivalent path)
5. **Starting directory:** `%USERPROFILE%`
6. **Hide profile from dropdown:** Off
7. Save the changes

You can set this profile as the default under **Startup** so you don't have to switch every time.

Restart Windows Terminal.

### 5. Install dependencies

In the **Git Bash** profile of Windows Terminal:

```bash
scoop bucket add extras
scoop install fzf ffmpeg mpv yt-dlp jq wget curl python
```

> `yt-dlp` and `ffmpeg` are **required** for downloads. Without them, Remo will show an error when trying to download and will not continue.

### 6. Install Remo

```bash
cd ~/
git clone https://github.com/chrisdjobs/remo.git
cd remo
chmod +x remo
```

To be able to run it from anywhere, create an alias or add the directory to PATH. The simplest option is a symlink:

```bash
ln -s "$(pwd)/remo" /usr/local/bin/remo
```

> Note: `install.sh` is for Linux and **does not work on Git Bash**. On Windows use the manual installation above.

---

## ⌨️ Script usage

### Play (original ani-es behavior)

```bash
remo
```

Or searching directly:

```bash
remo elfen lied
```

Select the anime → select the episode → choose **Reproducir** (Play).

### Download

```bash
remo
```

Select the anime → select the episode → choose **Descargar episodio** (Download episode) or **Descargar temporada** (Download season).

### Download mode

```bash
remo -d
remo --download
```

### Continue where you left off

```bash
remo -c
```

### Help and version

```bash
remo --help
remo --version
remo -u        # check for updates now
```

---

## 🔧 Dependencies

| Command | Play | Download | How to install (scoop) |
|---------|:----:|:--------:|------------------------|
| `wget` | ✅ | ✅ | `scoop install wget` |
| `curl` | ✅ | ✅ | `scoop install curl` |
| `jq` | ✅ | ✅ | `scoop install jq` |
| `fzf` | ✅ | ✅ | `scoop install fzf` |
| `grep` | ✅ | ✅ | comes with Git Bash |
| `sed` | ✅ | ✅ | comes with Git Bash |
| `python3` | ✅ | ✅ | `scoop install python` |
| `mpv` | ✅ | — | `scoop install mpv` |
| `yt-dlp` | — | ✅ | `scoop install yt-dlp` |
| `ffmpeg` | — | ✅ | `scoop install ffmpeg` |
| `ffprobe` | — | ✅ | comes with ffmpeg |

---

## ⚙️ Script configuration

### Download path

By default downloads go to `<Videos folder>/Anime`. To use your Jellyfin library:

```bash
# bash / Git Bash (add it to ~/.bashrc to make it persist)
export ANIME_DOWNLOAD_DIR="/path/to/your/library/Anime"   # Windows: "D:/Multimedia/Anime"

# fish
set -Ux ANIME_DOWNLOAD_DIR /path/to/your/library/Anime
```

### Updates

- Remo looks for a new version **at most once a day** and only offers it if its version number is **greater** than the installed one (it never downgrades).
- Before installing it checks that the downloaded file is a valid script.
- `remo -u` forces the check; `REMO_NO_UPDATE=1` disables it.
- If you installed it as a link to a git clone, it is not overwritten: update with `git pull`.

### Temporary files

The pages downloaded by the scraper are saved in a temporary folder that is deleted on exit, so you can run `remo` from any folder without it filling up with files.

### Jellyfin folder structure

```
<ANIME_DOWNLOAD_DIR>/
  <Anime>/
    Season 01/
      <Anime> - S01E01.mp4
      <Anime> - S01E02.mp4
```

File names are sanitized with Windows rules (also on Linux, so the library works on both) (`< > : " / \ | ? *` are removed). Unicode characters (accents, etc.) are preserved.

---

## 💾 History

Remo keeps the ani-es history system (`history.json`) to remember the last watched episode and playback progress.

**Downloads do not modify the history.** If you download an episode, your playback status is not affected.

---

## 🧠 How downloading works

```
User selects "Download episode"
  ↓
scrape_episode() gets a fresh .m3u8 URL (same scraper as ani-es)
  ↓
download_episode() calls yt-dlp with the URL
  ↓
yt-dlp downloads the HLS fragments (about 364 fragments)
  ↓
FFmpeg remuxes to MP4 (no re-encoding: H.264 + AAC → MP4 container)
  ↓
Final file: <Anime> - S01E01.mp4
```

For **Download season**, this process is repeated for each episode, getting a new URL every time:

```
episode 1 → scrape_episode() → fresh URL → yt-dlp
episode 2 → scrape_episode() → fresh URL → yt-dlp
episode 3 → scrape_episode() → fresh URL → yt-dlp
...
```

URLs are not cached because the `st` (start) and `e` (expire) parameters of the `.m3u8` expire.

---

## ❌ Uninstall

**Desktop app:** from *Settings → Apps* on Windows, or with your package manager on Linux (`.deb` / `.rpm`). For the AppImage you just delete the file. Your videos are not touched.

**Script on Linux:**

```bash
./uninstall.sh          # from the clone; add --purge to also delete the history
```

**Script on Windows (Git Bash):**

```bash
rm /usr/local/bin/remo
rm -rf ~/remo
```

---

## 📜 Credits

- **[Zhuchii/ani-es](https://github.com/Zhuchii/ani-es)** — the original project. Remo is a fork that respects and reuses the whole original scraper.
- **[ani-cli](https://github.com/pystardust/ani-cli)** — the Windows installation guide (Git Bash + Windows Terminal + Scoop) is based on its documentation.
- **[yt-dlp](https://github.com/yt-dlp/yt-dlp)** — HLS download engine.
- **[FFmpeg](https://ffmpeg.org/)** — remuxing to MP4.
- **[Tauri](https://tauri.app/)** and **[Fluent UI](https://react.fluentui.dev/)** — desktop app foundation.

---

## ⚠️ Disclaimer

Downloading copyrighted **content** may be illegal in your country. This tool is for educational purposes only and was created only to show how **it works**. Please support the **creators** by buying their **official releases**.

---

## ❤️ Contributing

Contributions are welcome.

**App:** before sending changes, run the tests and the linter (CI runs them on Linux and Windows):

```bash
cd app/src-tauri && cargo test && cargo clippy --all-targets
cd .. && pnpm exec tsc --noEmit
```

**Script:** the main test environment is Windows 11 + Git Bash, and CI runs ShellCheck. If you add features, please test that:

1. Playback with mpv still works.
2. The original scraper is not broken.
3. `history.json` is not corrupted.
4. Downloads produce valid MP4 files (verifiable with `ffprobe`).
