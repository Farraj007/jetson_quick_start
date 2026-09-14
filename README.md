# Jetson Quick Start

Utility scripts and configuration tweaks from the JetsonHacks project (https://github.com/jetsonhacks) to get NVIDIA Jetson developer kits up and running without wading through long setup guides. Each directory is self-contained; dip into the tooling you need and follow the detailed notes provided inside.

## Repository layout
- `installVSCode/` — Shell scripts for installing Visual Studio Code on arm64 Ubuntu, plus an option that also provisions Python tooling (pip, pylint, black, VS Code Python extension). Original repository: https://github.com/jetsonhacks/installVSCode
- `jetson-orin-gpio-patch/` — Device tree overlay, kernel patch, and examples that fix GPIO direction handling on JetPack 6.2 for Jetson Orin-based kits. Original repository: https://github.com/jetsonhacks/jetson-orin-gpio-patch
- `migrate-to-ssd/` — Steps to migrate a working SD-card install to an NVMe SSD and make the SSD the primary boot device, entirely from the Jetson itself. Based on: https://github.com/jetsonhacks/migrate-jetson-to-ssd

## Quick start
1. Clone or download this repository on the Jetson you are configuring.
2. Enter the directory that matches the task you are tackling.
3. Read the local `README.md` for step-by-step instructions, prerequisites, and testing notes.

## Highlights
- **VS Code on Jetson**: Run `installVSCode/installVSCode.sh` for a plain install, or `installVSCode/installVSCodeWithPython.sh` to add Python developer tooling automatically. Both scripts fetch the official Microsoft arm64 build.
- **GPIO fixes for JetPack 6.2**: Compile `jetson-orin-gpio-patch/pin7_as_gpio.dts` when you only need Pin 7 (GPIO9) bidirectional, or `jetson-orin-gpio-patch/pins_as_gpio.dts` when you want multiple pins unlocked together. If kernel-level handling needs the sfsel state preserved, apply `jetson-orin-gpio-patch/pinctrl-tegra-sfsel.patch` using `patch-for-pinctrl-sfsel.sh`.

To build and deploy the multi-pin overlay:
```bash
cd jetson-orin-gpio-patch
dtc -O dtb -o pins_as_gpio.dtbo pins_as_gpio.dts
sudo cp pins_as_gpio.dtbo /boot
sudo /opt/nvidia/jetson-io/jetson-io.py
```

- **Boot from SSD**: Already running from an SD card and adding an NVMe SSD? Run `migrate-to-ssd/migrate-to-ssd.sh` (or the three vendored step scripts individually) to clone the install onto the SSD and make it the primary boot device — no host PC needed.

## Requirements
- NVIDIA Jetson hardware running Ubuntu for Jetson (JetPack). The GPIO patch currently targets JetPack 6.2 on kernel 5.15.
- Sufficient disk space and sudo access for installing packages or patching kernel sources.
- `dtc` (device tree compiler) if you plan to build overlays, and the JetsonHacks kernel build tooling if you intend to rebuild the kernel with the supplied patch.

## Notes
- Each directory includes its own MIT-licensed content; review the individual `LICENSE` files for details.
- Commands that modify system packages or kernel sources may prompt for your password—ensure you understand the implications before running them.
