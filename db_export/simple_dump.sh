#!/bin/bash
cd "$(dirname "$0")"
#data_statistics? customer?
#tables that are unused for all clients
EXCLUDED_TABLES=(dashboard data_statistics data_summary email_queue guide flag input_state insight message message_user metadata_calculate metadata_variable
user_dashboard usergroup user_group user_group_insight user_guide user_info user_insight user_message user_metadata_calculate user_metadata_variable user_statistics user_user_group)

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
dump_db mmt_gr                          bag_woonplaats_mei_23
dump_db platform                        bag customer driving_time lexicon location_zipcode4 shape_point
dump_db rav_groningen                   logistic_backup
dump_db rav_brabant_midden_west_noord   
dump_db mmt_ams                         bag_woonplaats_mei_23
dump_db mknn
dump_db rav_oost
dump_db mk_limburg                      data_statistics
dump_db rav_limburg_noord               message_user
dump_db geography
dump_db rav_twente
dump_db rav_ijsselland
dump_db rav_drenthe
dump_db rav_fryslan
dump_db rav_brabant_zuidoost
dump_db rav_gelderland_zuid
dump_db rav_utrecht
dump_db rav_hollands_midden
dump_db lazk
dump_db roaz_aznn
dump_db rav_limburg_zuid