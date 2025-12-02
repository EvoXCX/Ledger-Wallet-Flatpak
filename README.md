# Ledger Wallet Desktop (Flatpak) — Unofficial Package

<p align="center">
  <img src="com.ledger.ledgerwallet.png" width="120" />
</p>

[![Flatpak Release](https://github.com/EvoXCX/Ledger-Wallet-Flatpak/actions/workflows/release.yml/badge.svg)](https://github.com/EvoXCX/Ledger-Wallet-Flatpak/actions/workflows/release.yml)
[![Flatpak Test Build](https://github.com/EvoXCX/Ledger-Wallet-Flatpak/actions/workflows/pr-build-test.yml/badge.svg)](https://github.com/EvoXCX/Ledger-Wallet-Flatpak/actions/workflows/pr-build-test.yml)

### Unofficial Flatpak packaging of **Ledger Live Desktop**  
This project provides a sandboxed Flatpak version of the Ledger Live/Wallet desktop application, making it easier to install, update, and run on any Linux distribution supporting Flatpak.



## Project Goal

Ledger does **not** provide an official Flatpak package.  
This repository aims to:

- Deliver a **reproducible, cross-distro Flatpak build** of Ledger Live/Wallet Desktop
- Run Ledger Live/Wallet inside a **secure Flatpak sandbox**
- Provide a clean, isolated installation that does not interfere with system packages

This project is **not affiliated with Ledger SAS**.


## Installation

### Install from local Flatpak bundle
Download the `.flatpak` file from the **Releases** tab, then:

```bash
flatpak install com.ledger.ledgerwallet.flatpak

Build manually from the manifest

flatpak-builder build-dir com.ledger.ledgerwallet.yml --force-clean
flatpak-builder --user --install build-dir com.ledger.ledgerwallet.yml
```

## Usage
Launch Ledger Live:

```bash
flatpak run com.ledger.ledgerwallet
```

The Flatpak version includes:
- Proper USB device access
- HID communication through ledger-wallet-wrapper.sh
- A sandboxed yet functional environment

## Internal Mechanics

### Sandbox configuration
The build uses:
- USB access via --device=all and udev rules (No choice to make it work)
- Minimal required permissions
- A wrapper script to launch the app

### CI (GitHub Actions)

Automatically:
- Generates test artifacts
- Runs validation checks (RobotFramework)
- Builds each commit and release a package

## FAQ

Is it safe?

>Yes in most cases, Flatpak sandboxing reduces risks.
>However, Ledger Live interacts with hardware wallets — use at your own risk. I decline all responsability for stolen fund or lost fund.

Why is this unofficial?

>Ledger does not currently maintain a Flatpak version for the moment.

Will this be on Flathub?

>No I don't think, I already contacted Ledger about that and they plan to release one day a Flatpak version, I don't want to interfere with their plan.

## Limitations
- This is an unofficial package; updates from Ledger may break compatibility.
- Ledger Live uses heavy Electron dependencies → builds may be slow.
- Not available on Flathub.

## Contributing

### Contributions are welcome!
1. Fork the repo
2. Create a feature branch
3. Submit clear commits
4. Open a Pull Request

### Especially helpful contributions:
- Manifest fixes
- Sandbox improvements
- Automated update scripts for new Ledger Live/Wallet versions

## Support

If you find this useful, consider starring the repository on GitHub!