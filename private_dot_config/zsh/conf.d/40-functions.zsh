sysup() { sudo timeshift --create --comments "pre-upgrade $(date +%F)" && paru -Syu; }
