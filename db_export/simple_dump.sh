#!/bin/bash
cd "$(dirname "$0")"

#tables that are unused for all clients
EXCLUDED_TABLES=(dashboard data_summary guide input_state insight message user_dashboard user_group user_group_insight user_guide user_info user_insight user_message user_user_group)

dump_db() {
    local db="$1"
    shift
    local excludes=()
    for table in "${EXCLUDED_TABLES[@]}" "$@"; do
        excludes+=(--exclude-table="$table")
    done
    
    #client_info is old for every client except LAZK and kwkapp
    if [[ "$db" != "kwaliteitskaderapp" && "$db" != "lazk" ]]; then
        excludes+=(--exclude-table=client_info)
    fi
    pg_dump "${excludes[@]}" -d "$db" -f "dumps/${db}.dump" -Fc -U postgres
}

dump_db hap_hcdo
dump_db kwaliteitskaderapp 
dump_db mmt_gr
dump_db platform bag customer driving_time lexicon location_zipcode4 shape_point
dump_db rav_groningen logistic_backup
dump_db rav_brabant_midden_west_noord
dump_db mknn





dump_db lazk