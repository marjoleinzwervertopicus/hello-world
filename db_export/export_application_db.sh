while read -r db; do
  tables_file="tables_${db}.txt"
  outdir="/mnt/volume_postgres_application/data/${db}"
  mkdir -p "$outdir"
  while read -r tbl; do
    pg_dump -h postgres_application_server -U postgres -F c -b -v -d "$db" -t "$tbl" -f "$outdir/${tbl}.dump"
  done < "$tables_file"
done < dbs.txt