#!/bin/bash
# Maandrapport auditd voor baseline 2.2.1 (activiteit 2: maandelijkse beoordeling).
#
# Gebruik:  sudo bash maandrapport.sh [JJJJ-MM]
#           zonder argument: de vorige maand
# Uitvoer:  auditd_rapport_<JJJJ-MM>.txt in de huidige map
#
# Werkwijze: draai dit begin van de maand, lees het rapport door, vul onderaan
# de beoordeling in en voeg het toe aan het maandelijkse Jira-ticket.
# Afwijkingen -> incident volgens het incidentproces (1.9.3).

set -uo pipefail
export LC_ALL=C   # vaste datumnotatie voor ausearch/aureport: MM/DD/YY

[ "$(id -u)" -eq 0 ] || { echo "Draai met sudo" >&2; exit 1; }

MAAND=${1:-$(date -d "$(date +%Y-%m-01) -1 month" +%Y-%m)}
START_ISO="$MAAND-01"
EIND_ISO=$(date -d "$START_ISO +1 month" +%Y-%m-%d)
START=(--start "$(date -d "$START_ISO" +%m/%d/%y)" 00:00:00)
EIND=(--end "$(date -d "$EIND_ISO" +%m/%d/%y)" 00:00:00)
UIT="auditd_rapport_$MAAND.txt"

# Keys uit de actieve regelset, zodat het rapport meegroeit met audit.rules
KEYS=$(grep -o -- '-k [a-z_]*' /etc/audit/audit.rules | awk '{print $2}' | sort -u)
# Keys waarbij een commando wordt uitgevoerd: toon het volledige commando
EXEC_KEYS="install install_pkg service_ctl docker_ctl auditconfig"

kop() { printf '\n%s\n%s\n' "$1" "$(printf '%.0s=' $(seq ${#1}))"; }

# Eén regel per uitgevoerd commando: tijd, gebruiker (auid), commando met argumenten
commandos() {
  ausearch -k "$1" "${START[@]}" "${EIND[@]}" -i 2>/dev/null | awk 'BEGIN { RS = "----" } {
    tijd = ""; wie = ""; cmd = ""
    n = split($0, r, "\n")
    for (i = 1; i <= n; i++) {
      if (r[i] ~ /^type=PROCTITLE/) {
        cmd = r[i];  sub(/.*proctitle=/, "", cmd)
        tijd = r[i]; sub(/.*msg=audit\(/, "", tijd); sub(/\..*/, "", tijd)
      }
      if (r[i] ~ /^type=SYSCALL/) { wie = r[i]; sub(/.* auid=/, "", wie); sub(/ .*/, "", wie) }
    }
    if (cmd != "") printf "%s  %-25s %s\n", tijd, wie, cmd
  }'
}

{
  echo "Auditd maandrapport - baseline 2.2.1"
  echo "Server:     $(hostname)"
  echo "Periode:    $START_ISO t/m $(date -d "$EIND_ISO -1 day" +%Y-%m-%d)"
  echo "Gemaakt op: $(date '+%Y-%m-%d %H:%M')"

  kop "1. Aantal gebeurtenissen per key"
  aureport -k --summary -i "${START[@]}" "${EIND[@]}" 2>/dev/null || echo "(geen)"

  kop "2. Logins (wie was er ingelogd, vanaf welk IP)"
  aureport -l -i "${START[@]}" "${EIND[@]}" 2>/dev/null || echo "(geen)"

  kop "3. Uitgevoerde beheercommando's"
  for k in $EXEC_KEYS; do
    echo; echo "--- $k"
    uit=$(commandos "$k"); echo "${uit:-(geen)}"
  done

  kop "4. Gewijzigde bestanden en overige gebeurtenissen per key"
  for k in $KEYS; do
    case " $EXEC_KEYS " in *" $k "*) continue ;; esac
    uit=$(ausearch -k "$k" "${START[@]}" "${EIND[@]}" --format text 2>/dev/null)
    [ -n "$uit" ] && { echo; echo "--- $k"; echo "$uit"; }
  done

  kop "5. Beoordeling"
  cat <<'EOF'
Controleer per gebeurtenis in 2 t/m 4:
  [ ] Is de gebruiker (auid) iemand die beheer mag doen?
  [ ] Hoort er een changeticket bij (installaties, services, configuratie, rechten)?
  [ ] Vond het plaats op een verwacht tijdstip?
  [ ] app_config met auid=unset (vanuit de app): is er een bijbehorende regel
      in user_management_logs?
  [ ] Zijn er wijzigingen aan de logging zelf (auditconfig, auditlog)?

Afwijkingen gevonden:  ja / nee
Zo ja, incidentnummer(s):
Beoordeeld door:
Datum:
EOF
} > "$UIT"

echo "Rapport geschreven naar $UIT"
