#!/bin/bash
# Maandrapport auditd
#
# Gebruik:  sudo bash maandrapport.sh [JJJJ-MM]
#           zonder argument: de vorige maand
# Uitvoer:  /mnt/volume_block_1/shared/auditd_rapporten/auditd_rapport_<JJJJ-MM>.txt
#
# Werkwijze: draai dit begin van de maand. Het rapport filtert zelf voor op
# verdachte gebeurtenissen (sectie 1) zodat je niet alles handmatig hoeft na
# te lopen. Afwijkingen -> incident volgens het incidentproces
#
# Lijst beheerders. Een auid die hier niet in staat wordt altijd gemeld in sectie 1
BEHEERDERS=(
  "renco"
  "devise"
  "root"
)

# Kantooruren waarbinnen beheeracties door mensen (dus niet auid=unset vanuit
# de apps) normaal worden geacht. Gebeurtenissen vanuit de apps zelf
# (auid=unset) worden hier niet tegen getoetst: de apps draaien 24/7.
KANTOOR_VAN=7
KANTOOR_TOT=24
WERKDAG_TOT=5   # 1=maandag .. 7=zondag; alles na deze dag valt buiten kantooruren

# Gebruikers die uitgezonderd zijn van de kantoorurencheck (1c), bijvoorbeeld
# een account waaronder 's nachts een cronjob draait. Ze blijven wel gewoon
# gecontroleerd op risicovolle keys (1a) en moeten in BEHEERDERS staan, anders
# verschijnen ze alsnog via 1b (onbekende gebruiker).
GEEN_KANTOORURENCHECK=(
  "devise"   # nachtelijke cronjob
)

# Bekende, onschadelijke ruis: gebeurtenissen waarvan de omschrijving matcht
# met een van deze patronen (shell-globs, * mag) worden helemaal genegeerd,
# ongeacht gebruiker, key of tijdstip. Alleen hier toevoegen als je hebt
# vastgesteld wat het is en waarom het geen risico vormt.
NEGEER_PATRONEN=(
  "dpkg -s droplet-agent*"          # eigen update-check van DigitalOcean's droplet-agent, geen installatie
  "*--print-foreign-architectures*" # interne dpkg/apt-query, geen installatie; komt veel voor bij (onbeheerde) upgrades
)

# Keys die altijd gemeld worden, ongeacht wie of wanneer: lage frequentie,
# hoge impact (zie eerdere afspraak over welke keys direct een alert
# verdienen). Wijzig deze lijst als audit.rules wijzigt.
ALTIJD_MELDEN_KEYS="auditconfig auditlog identity privileges rootkey modules libpath firewall install_manual"

# Korte uitleg per risicovolle key, getoond bij sectie 1a
declare -A KEY_UITLEG=(
  [auditconfig]="auditd-configuratie of -regels aangepast: kan logging verzwakken/uitschakelen"
  [auditlog]="het logbestand zelf aangepast: mogelijk sporen gewist (2.2.3)"
  [identity]="gebruiker/groep/wachtwoord aangemaakt of gewijzigd (/etc/passwd, /etc/shadow, ...)"
  [privileges]="sudo-rechten gewijzigd (/etc/sudoers)"
  [rootkey]="SSH-sleutel van root toegevoegd of gewijzigd"
  [modules]="kernelmodule geladen/verwijderd: veelgebruikte persistence-techniek"
  [libpath]="systeembrede library-paden/preloads aangepast: kan programma's omleiden"
  [firewall]="firewallconfiguratie aangepast"
  [install_manual]="software geinstalleerd buiten de package manager om"
)

set -uo pipefail
export LC_ALL=C   # vaste datumnotatie voor ausearch/aureport: MM/DD/YY

[ "$(id -u)" -eq 0 ] || { echo "Draai met sudo" >&2; exit 1; }

MAAND=${1:-$(date -d "$(date +%Y-%m-01) -1 month" +%Y-%m)}
START_ISO="$MAAND-01"
EIND_ISO=$(date -d "$START_ISO +1 month" +%Y-%m-%d)
START=(--start "$(date -d "$START_ISO" +%m/%d/%y)" 00:00:00)
EIND=(--end "$(date -d "$EIND_ISO" +%m/%d/%y)" 00:00:00)
RAPPORT_DIR=/mnt/volume_block_1/shared/auditd_rapporten
mkdir -p "$RAPPORT_DIR" || { echo "Kan $RAPPORT_DIR niet aanmaken" >&2; exit 1; }
UIT="$RAPPORT_DIR/auditd_rapport_$MAAND.txt"

# Keys uit de actieve regelset, zodat het rapport meegroeit met audit.rules
KEYS=$(grep -o -- '-k [a-z_]*' /etc/audit/audit.rules | awk '{print $2}' | sort -u)

kop() { printf '\n%s\n%s\n' "$1" "$(printf '%.0s=' $(seq ${#1}))"; }

# Eén regel per gebeurtenis voor een key: tijd|auid|omschrijving
gebeurtenissen() {
  ausearch -k "$1" "${START[@]}" "${EIND[@]}" -i 2>/dev/null | awk 'BEGIN { RS = "----" } {
    tijd = ""; wie = ""; wat = ""
    n = split($0, r, "\n")
    for (i = 1; i <= n; i++) {
      if (r[i] ~ /^type=SYSCALL/) {
        line = r[i]
        w = line; sub(/.* auid=/, "", w); sub(/ .*/, "", w); if (wie == "") wie = w
        t = line; sub(/.*msg=audit\(/, "", t); sub(/\..*/, "", t); if (tijd == "") tijd = t
      }
      if (r[i] ~ /^type=PROCTITLE/) { c = r[i]; sub(/.*proctitle=/, "", c); wat = c }
      if (wat == "" && r[i] ~ /^type=PATH/) { p = r[i]; sub(/.*name=/, "", p); sub(/ .*/, "", p); wat = p }
    }
    if (tijd != "") printf "%s|%s|%s\n", tijd, wie, wat
  }'
}

{
  echo "Auditd maandrapport"
  echo "Server:     $(hostname)"
  echo "Periode:    $(date -d "$START_ISO" +%d-%m-%Y) t/m $(date -d "$EIND_ISO -1 day" +%d-%m-%Y)"
  echo "Gemaakt op: $(date '+%d-%m-%Y %H:%M')"

  kop "1. Direct nakijken"
  echo "Automatisch gefilterd en onderverdeeld naar reden. Staat hier niets,"
  echo "dan is er verder niets om handmatig na te lopen."
  
  nl_datum() { date -d "$1" +'%d-%m-%Y %H:%M:%S' 2>/dev/null || echo "$1"; }

  regel() { printf '%s  %-25s %-20s %s\n' "$(nl_datum "$1")" "$2" "$3" "$4"; }

  risico=""; onbekend=""; buitenuren=""

  for k in $KEYS; do
    regels=$(gebeurtenissen "$k")
    [ -z "$regels" ] && continue
    while IFS='|' read -r tijd auid wat; do
      [ -z "$tijd" ] && continue

      genegeerd=0
      for p in "${NEGEER_PATRONEN[@]}"; do
        case "$wat" in $p) genegeerd=1; break ;; esac
      done
      [ "$genegeerd" -eq 1 ] && continue

      case " $ALTIJD_MELDEN_KEYS " in
        *" $k "*) risico+=$(regel "$tijd" "$auid" "$k" "$wat")$'\n'; continue ;;
      esac

      [ "$auid" = "unset" ] && continue

      bekend=0
      for b in "${BEHEERDERS[@]}"; do [ "$auid" = "$b" ] && bekend=1 && break; done
      [ "$bekend" -eq 0 ] && onbekend+=$(regel "$tijd" "$auid" "$k" "$wat")$'\n'
      # Let op: geen 'continue' hier. Een onbekende gebruiker wordt dus ook nog
      # tegen de kantoorurencheck hieronder gehouden en kan zo in zowel 1b als
      # 1c verschijnen - dat is een extra signaal, geen dubbele telling.

      uitgezonderd=0
      for u in "${GEEN_KANTOORURENCHECK[@]}"; do [ "$auid" = "$u" ] && uitgezonderd=1 && break; done
      [ "$uitgezonderd" -eq 1 ] && continue

      wkdag=$(date -d "$tijd" +%u 2>/dev/null)
      uur=$(date -d "$tijd" +%H 2>/dev/null)
      if [ -n "$wkdag" ] && [ -n "$uur" ]; then
        if [ "$wkdag" -gt "$WERKDAG_TOT" ] || [ "$uur" -lt "$KANTOOR_VAN" ] || [ "$uur" -ge "$KANTOOR_TOT" ]; then
          buitenuren+=$(regel "$tijd" "$auid" "$k" "$wat")$'\n'
        fi
      fi
    done <<< "$regels"
  done

  kolomkop=$(regel "TIJD" "AUID" "KEY" "OMSCHRIJVING")

  echo
  echo "1a. Risicovolle keys (altijd gemeld, key staat in ALTIJD_MELDEN_KEYS)"
  echo "----------------------------------------------------------------------"
  for k in $ALTIJD_MELDEN_KEYS; do
    printf '  %-16s %s\n' "$k" "${KEY_UITLEG[$k]:-}"
  done
  echo
  if [ -n "$risico" ]; then echo "$kolomkop"; printf '%s' "$risico" | sort; else echo "(niets gevonden)"; fi

  echo
  echo "1b. Onbekende gebruiker (auid staat niet in BEHEERDERS)"
  echo "--------------------------------------------------------"
  if [ -n "$onbekend" ]; then echo "$kolomkop"; printf '%s' "$onbekend" | sort; else echo "(niets gevonden)"; fi

  echo
  echo "1c. Buiten kantooruren (ma-vr $KANTOOR_VAN:00-$KANTOOR_TOT:00; niet voor auid=unset of GEEN_KANTOORURENCHECK)"
  echo "-----------------------------------------------------------------------------------"
  if [ -n "$buitenuren" ]; then echo "$kolomkop"; printf '%s' "$buitenuren" | sort; else echo "(niets gevonden)"; fi

  kop "3. Beoordeling"
  cat <<EOF
Loop sectie 1 na. Voor elke regel:
  [ ] Is dit een legitieme beheeractie? Zo nee -> incident (1.9.3).
  [ ] Hoort er een changeticket bij (installaties, services, configuratie, rechten)?

Een melding verder uitzoeken: vervang hieronder <key>, <tijd> en <auid> door
de waarden uit de melding die je wilt natrekken en draai het commando op de
server.

Volledige details van die ene gebeurtenis (alle auditd-velden, inclusief
bijbehorende PATH/PROCTITLE-records):
  sudo ausearch -k <key> --start "<tijd> -1 minute" --end "<tijd> +1 minute" -i

Alle gebeurtenissen van die key in deze maand (kan lang zijn):
  sudo ausearch -k <key> ${START[@]} ${EIND[@]} -i

Wat die gebruiker verder nog gedaan heeft in deze maand (ausearch kent geen
filter op auid-naam, vandaar grep):
  sudo ausearch ${START[@]} ${EIND[@]} -i | grep -B5 -A2 "auid=<auid>"

Blijkt de melding terecht een afwijking, maak dan een incident aan volgens
het incidentproces en noteer het incidentnummer hieronder.

Afwijkingen gevonden:  ja / nee
Zo ja, incidentnummer(s):
Beoordeeld door:
Datum:
EOF
} > "$UIT"

echo "Rapport geschreven naar $UIT"
