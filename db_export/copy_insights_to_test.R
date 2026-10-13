# Kopieert /home/devise/insights/production/[klant] naar /home/devise/insights/test/[klant]
# voor elke klant hieronder. Bestaande bestanden in test worden overschreven, extra
# bestanden in test blijven staan. Zet dry_run op FALSE om echt te kopiëren.
src_root <- "/home/devise/insights/production"
dest_root <- "/home/devise/insights/test"
dry_run <- F

#18 clients
clients <- c(
  "hap_hcdo",
  "mmt_gr",
  "rav_groningen",
  "rav_brabant_midden_west_noord",
  "mmt_ams",
  "mknn",
  "mk_limburg",
  "rav_limburg",
  "rav_twente",
  "rav_ijsselland",
  "rav_drenthe",
  "rav_fryslan",
  "rav_brabant_zuidoost",
  "rav_gelderland_zuid",
  "rav_utrecht",
  "rav_hollands_midden",
  "roaz_aznn",
  "rav_kennemerland"
)

for (client in clients) {
  src <- file.path(src_root, client)
  dest <- file.path(dest_root, client)

  if (!dir.exists(src)) {
    message("Overgeslagen (geen map): ", src)
    next
  }

  if (dry_run) {
    message("[dry run] ", src, " -> ", dest, " (bestaande dest wordt eerst verwijderd)")
  } else {
    message(src, " -> ", dest)
    # Verwijdert een bestaande dest eerst, zodat alleen de bestanden uit src overblijven
    if (dir.exists(dest)) unlink(dest, recursive = TRUE)
    dir.create(dest_root, recursive = TRUE, showWarnings = FALSE)
    ok <- file.copy(src, dest_root, recursive = TRUE, copy.date = TRUE)
    if (!ok) warning("Kopiëren mislukt: ", src)
  }
}
