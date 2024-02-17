# wps-office-secure

Run WPS Office for Linux with Firejail for enhanced security.

## Prerequisites

Required: linux kernel >=3.5, sudo, firejail

Optional: apt-get

## Quick Start

Make sure WPS Office for Linux is installed first.

```bash
git clone https://github.com/rashlight/wps-office-secure
cd wps-office-secure
./run.sh install
```

## Usage

```
./run.sh OPTION
OPTION can be one of the following:
	install: perform installation
	uninstall: perform uninstallation
	help: display this help message
```

## Troubleshooting

Some formula symbols might not be displayed correctly due to missing fonts [...]
 - System and user fonts are still loaded. However, additional special fonts needed might not be installed.
 - [dv-anomaly/ttf-wps-fonts](https://github.com/dv-anomaly/ttf-wps-fonts) is a simple way to install these.

Installation/Uninstallation incomplete, <x> errors occurred.
 - Look at the printed messages above for more information.
