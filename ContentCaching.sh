#!/bin/zsh
# ===========================================================
# ContentCaching.sh v1
# Inhaltscaching aktivieren und Cache-Limit setzen
# Läuft als root (z.B. MacAdmin-Script-Payload) - keine Elevation
# NUR FÜR TESTSYSTEME
# ===========================================================

# ###############################
# #  KONFIGURATION              #
# ###############################

# Cache-Limit in GB (dezimal, 1 GB = 1000^3 Bytes - so zeigt es macOS an)
# 50 -> 50000000000 Bytes; System Settings / "AssetCacheManagerUtil settings"
# zeigen dann exakt "50 GB"
_CacheLimitGB=50

_Domain="/Library/Preferences/com.apple.AssetCache"
_AssetUtil="/usr/bin/AssetCacheManagerUtil"
_Defaults="/usr/bin/defaults"


# ###############################
# #  HAUPTPROGRAMM              #
# ###############################

# Root-Check: alle Schritte brauchen root
if [[ $(id -u) -ne 0 ]]
then
    echo "FEHLER: Muss als root laufen (MacAdmin fuehrt Scripts als root aus)." >&2
    exit 1
fi

_CacheLimitBytes=$(( _CacheLimitGB * 1000 * 1000 * 1000 ))
echo "Setze Inhaltscaching: Limit ${_CacheLimitGB} GB (${_CacheLimitBytes} Bytes)"

# 1. Dienst aktivieren
"${_AssetUtil}" activate

# 2. Cache-Limit in der plist setzen
"${_Defaults}" write "${_Domain}" CacheLimit -int "${_CacheLimitBytes}"

# 3. Aktivierungs-Status in der plist absichern (UI-Konsistenz)
"${_Defaults}" write "${_Domain}" Activated -bool YES

# 4. Settings neu einlesen, damit das neue Limit ohne Reboot greift
#    (gibt zugleich die aktive Konfiguration inkl. CacheLimit aus)
"${_AssetUtil}" reloadSettings

# 5. Verifikation der Aktivierung
echo "--- Status ---"
"${_AssetUtil}" status

exit 0
