# kodi-compiled

This repository automates building Kodi (xbmc/xbmc) and producing binary artifacts (.deb) for Linux Mint 22.2 (based on Ubuntu 22.04).

What this repo contains
- GitHub Actions workflow to clone xbmc/xbmc, build Kodi, create a .deb package and upload it as a release artifact.
- Packaging scripts that assemble the Debian package under /opt/kodi so it can be installed on Mint 22.2 without conflicting with distro packages.

How to use
- To run in GitHub Actions: push to this repository. The workflow will run on the default branch and create a GitHub Release with the .deb attached.
- To run locally:
  1. Clone xbmc/xbmc:
     git clone --depth 1 https://github.com/xbmc/xbmc.git
  2. Run the packaging script (example):
     packaging/create-deb.sh /path/to/xbmc <commit-or-tag> build-dir out-dir
  3. Install the produced .deb:
     sudo dpkg -i out-dir/kodi-<version>_amd64.deb
     sudo apt-get -f install

Notes
- The workflow uses ubuntu-22.04 runners (equivalent base to Linux Mint 22.2).
- This produces a single package that installs into /opt/kodi and leaves system packages alone. You may change packaging to integrate with system package policy.
- You will likely need to extend the apt dependencies for optional Kodi features (Wayland, PipeWire, Kodi PVR, hardware acceleration).

Where to go next
- If you want: I can create the repository and push these files, and then we can iterate on build flags and dependency lists to match your preferred Kodi variants (e.g., X11 vs Wayland, PulseAudio vs PipeWire, hardware acceleration backends).
