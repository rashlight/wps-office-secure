# wps-office-secure

Run WPS Office for Linux with Firejail for enhanced security.

## Demo

![wps-office-secure demo](.github/demo-mini.gif)

## Features

 - Disable internet connection
 - Limit access to memory execution
 - Integration with AppArmor

## Prerequisites

Required: WPS Office (.deb or .rpm), linux kernel >=3.5, sudo, firejail

Optional: apt-get

## Quick Start

```bash
git clone https://github.com/rashlight/wps-office-secure
cd wps-office-secure
./run.sh install
```

## Usage

```bash
./run.sh OPTION
OPTION can be one of the following:
	install: perform installation
	uninstall: perform uninstallation
	help: display this help message
```

## Troubleshooting

Installation/Uninstallation incomplete, X errors occurred.
 - Look at the error messages above for insights.
 - If you don't know how to fix those issues, try running ```./run.sh uninstall``` to revert to normal.

Some formula symbols might not be displayed correctly due to missing fonts.
 - System and user fonts are still loaded. However, additional special fonts needed might not be installed.
 - [dv-anomaly/ttf-wps-fonts](https://github.com/dv-anomaly/ttf-wps-fonts) is a simple way to install these.

Desktop shortcuts does not launch wrapper when window manage mode is changed.
 - Run ```./run.sh install``` again for each time.

WPS Office crashes when opening a file.
 - Relaunch app or open the file again. This should only happen once per computer startup.
