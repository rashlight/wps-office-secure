#!/bin/bash
# wps-office-secure: Run WPS Office for Linux with Firejail for enhanced security.
# Copyright 2024 An Van Quoc (rashlight)

PROFILES=("wps.profile" "et.profile" "wpp.profile" "wpspdf.profile")
WRAPPERS=("wps" "et" "wpp" "wpspdf")
DESKTOP_ENTRIES=("wps-office-wps" "wps-office-et" "wps-office-wpp" "wps-office-pdf" "wps-office-prometheus" )
ERROR_COUNT=0
ERROR_MSG=""
STATUS="complete."

fail() {
	echo "$1 failed to $2!"
}

panic() {
	echo "ERROR: $1, cannot continue."
	if ! [ -z "$2" ]; then
		echo "HINT: $2"
	fi
	exit 1
}

check_sudo() {
	if ! command -v sudo &> /dev/null; then
		panic "Cannot elevate privileges (sudo not found)" "Install and configuration of sudo is required."
	fi

	echo "sudo found at $(command -v sudo)"
}

check_firejail() {
	if ! command -v firejail &> /dev/null; then
		if ! command -v apt-get &> /dev/null; then
			panic "Cannot install firejail (apt-get not found)" "Consult your distribution's documentation for installation."
		else
			echo "firejail not found, attempting installation..."
			sudo apt-get install firejail
			RESULT=$?
			if [ $RESULT != 0 ]; then
        		panic "firejail installation failed" "Check above messages for more information. Maybe you declined?"
			elif ! command -v firejail &> /dev/null; then
				panic "firejail installation failed (not found in PATH)" "Consult your distribution's documentation for help."
			fi
		fi
	fi

	echo "firejail found at $(command -v firejail)"
}

prog_install() {
	echo "Checking requirements..."
	check_sudo
	check_firejail

	echo
	echo "This script action will: "
	echo " - Install firejail profiles '${PROFILES[@]}' for WPS Office in /etc/firejail"
	echo " - Install wrappers '${WRAPPERS[@]}' for WPS Office in /usr/local/bin"
	echo " - Attempt to configure desktop files and desktop menu entries '${DESKTOP_ENTRIES[@]}' for WPS Office in /usr/share/applications and $HOME/Desktop"
	echo
	echo -n "Do you want to continue? [y/N] "

	read CONFIRM

	if [ -z "$CONFIRM" ] || [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
   		panic "User aborted installation"
	fi

	echo "Installing profiles..."
	for _PROFILE in "${PROFILES[@]}"; do
        sudo bash -c "cp \"profiles/$_PROFILE\" \"/etc/firejail/\" && chmod 644 \"/etc/firejail/$_PROFILE\""
        RESULT=$?
        if [ $RESULT != 0 ]; then
        	fail "profiles/$_PROFILE" "install"
        	ERROR_COUNT=$(($ERROR_COUNT + 1))
        fi
	done

	echo "Installing wrappers..."
	for _WRAPPER in "${WRAPPERS[@]}"; do
        sudo bash -c "cp \"wrappers/$_WRAPPER\" \"/usr/local/bin/\" && chmod 755 \"/usr/local/bin/$_WRAPPER\""
        RESULT=$?
        if [ $RESULT != 0 ]; then
        	fail "wrappers/$_WRAPPER" "install"
        	ERROR_COUNT=$(($ERROR_COUNT + 1))
        fi
	done

	echo "Configuring desktop menu entries..."
	for _ENTRY in "${DESKTOP_ENTRIES[@]}"; do
		if [ -e "/usr/share/applications/$_ENTRY.desktop" ]; then
			sudo sed -i 's|/usr/bin|/usr/local/bin|' "/usr/share/applications/$_ENTRY.desktop"
			RESULT=$?
        	if [ $RESULT != 0 ]; then
        		fail "$_ENTRY" "configure"
        		ERROR_COUNT=$(($ERROR_COUNT + 1))
        	fi
		fi
	done

	echo "Configuring desktop files..."
	for _ENTRY in "${DESKTOP_ENTRIES[@]}"; do
		if [ -e "$HOME/Desktop/$_ENTRY.desktop" ]; then
        	sudo sed -i 's|/usr/bin|/usr/local/bin|' "$HOME/Desktop/$_ENTRY.desktop"
        	RESULT=$?
        	if [ $RESULT != 0 ]; then
        		fail "$_ENTRY" "configure"
        		ERROR_COUNT=$(($ERROR_COUNT + 1))
        	fi
        fi
	done

	if [ $ERROR_COUNT != 0 ]; then
		STATUS="incomplete, $ERROR_COUNT errors found. Please check the above messages and fix/clean any remaining files."
	fi

	echo "Installation $STATUS"
}

prog_uninstall() {
	echo "Checking requirements..."
	check_sudo

	echo
	echo "This script action will: "
	echo " - REMOVE firejail profiles '${PROFILES[@]}' for WPS Office in /etc/firejail"
	echo " - REMOVE wrappers '${WRAPPERS[@]}' for WPS Office in /usr/local/bin"
	echo " - Attempt to revert desktop files and desktop menu entries '${DESKTOP_ENTRIES[@]}' for WPS Office in /usr/share/applications and $HOME/Desktop to factory defaults"
	echo
	echo -n "Do you want to continue? [y/N] "

	read CONFIRM

	if [ -z "$CONFIRM" ] || [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
   		panic "User aborted uninstallation"
	fi

	echo "Reverting desktop files..."
	for _ENTRY in "${DESKTOP_ENTRIES[@]}"; do
		if [ -e "$HOME/Desktop/$_ENTRY.desktop" ]; then
        	sudo sed -i 's|/usr/local/bin|/usr/bin|' "$HOME/Desktop/$_ENTRY.desktop"
        	RESULT=$?
        	if [ $RESULT != 0 ]; then
        		fail "$_ENTRY" "revert"
        		ERROR_COUNT=$(($ERROR_COUNT + 1))
        	fi
        fi
	done

	echo "Reverting desktop menu entries..."
	for _ENTRY in "${DESKTOP_ENTRIES[@]}"; do
		if [ -e "/usr/share/applications/$_ENTRY.desktop" ]; then
        	sudo sed -i 's|/usr/local/bin|/usr/bin|' "/usr/share/applications/$_ENTRY.desktop"
        	RESULT=$?
        	if [ $RESULT != 0 ]; then
        		fail "$_ENTRY" "revert"
        		ERROR_COUNT=$(($ERROR_COUNT + 1))
        	fi
        fi

	done

	echo "Removing wrappers..."
	for _WRAPPER in "${WRAPPERS[@]}"; do
		if [ -e "/usr/local/bin/$_WRAPPER" ]; then
        	sudo rm "/usr/local/bin/$_WRAPPER"
        	RESULT=$?
        	if [ $RESULT != 0 ]; then
        		fail "wrappers/$_WRAPPER" "remove"
        		ERROR_COUNT=$(($ERROR_COUNT + 1))
        	fi
        fi
	done

	echo "Removing profiles..."
	for _PROFILE in "${PROFILES[@]}"; do
		if [ -e "/etc/firejail/$_PROFILE" ]; then
        	sudo rm "/etc/firejail/$_PROFILE"
       		RESULT=$?
        	if [ $RESULT != 0 ]; then
        		fail "profiles/$_PROFILE" "remove"
        		ERROR_COUNT=$(($ERROR_COUNT + 1))
        	fi
        fi
	done

	if [ $ERROR_COUNT != 0 ]; then
		STATUS="incomplete, $ERROR_COUNT errors found. Please check the above messages and fix/clean any remaining files."
	fi

	echo "Uninstallation $STATUS"
}

prog_help() {
	echo $1
	echo "Usage: ./run.sh OPTION"
	echo "OPTION can be one of the following:"
	echo "	install: perform installation"
	echo "	uninstall: perform uninstallation"
	echo "	help: display this help message"
	exit $2
}

# Entry point
if [ -z "$1" ]; then
	prog_help "run.sh: No arguments found" 1
fi

case "$1" in
	"install") prog_install;;
	"uninstall") prog_uninstall;;
	"help") prog_help "wps-office-secure: Run WPS Office for Linux with Firejail for enhanced security." 0;;
	*) prog_help "run.sh: Unknown argument";;
esac

if [ $ERROR_COUNT != 0 ]; then
	exit 1
fi
