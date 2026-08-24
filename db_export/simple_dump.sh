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
dump_db rav_groningen                   logistic logistic_backup
dump_db rav_brabant_midden_west_noord   raw_ortec
dump_db mmt_ams                         bag_woonplaats_mei_23
dump_db mknn                            gms_rit_raw
dump_db rav_oost
dump_db mk_limburg                      data_statistics gms_task_2022_01_01_2022_01_31
dump_db rav_limburg_noord               message_user ambulance_task_edaz_2022_01_01_2022_01_31 ambulance_task_edaz_backup ambulance_task_edaz_bk edaz_task_raw_backup logistic_backup logistic_temp_1 logistic_test personnel_contract_backup personnel_contract_temp personnel_hours_backup personnel_hours_temp personnel_in_out_backup personnel_in_out_temp test test_dropme
dump_db geography                       testtest
dump_db rav_twente
dump_db rav_ijsselland                  ambulance_task_edaz_2022_01_01_2022_01_31 edaz_task_raw_old logistic_backup test1
dump_db rav_drenthe                     backup_afas_raw edaz_form_raw_2022_01_01_2022_01_31 edaz_task_raw_2022_01_01_2022_01_31 hist_account_raw_2022_01_01_2022_01_31 hist_roster_raw_2022_01_01_2022_01_31 hist_timeinterval_raw_2022_01_01_2022_01_31 logistic2 logistic2_backup logistic2_temp personnel_contract_bk_2024 personnel_contract_old personnel_contract_temp personnel_in_out_backup personnel_in_out_temp psycholance_backup psycholance_backup_12_3 psycholance_backup_18_2 synergy_task_inbox_backup test_tz
dump_db rav_fryslan                     ambulance_task_edaz_2022_01_01_2022_01_31 ambulance_task_edaz_backup_20260422 ambulance_task_edaz_temp downtime2 json_test logistic_backup qa_backup
dump_db rav_brabant_zuidoost
dump_db rav_gelderland_zuid
dump_db rav_utrecht                     sb_ambulance_task_2025_q4
dump_db rav_hollands_midden
dump_db lazk
dump_db roaz_aznn                       roaz_ggz_old roaz_hap_old roaz_ketenzorg_old roaz_rav_old roaz_seh_old
dump_db rav_limburg_zuid                ambulance_task_edaz_2022_01_01_2022_01_31 ambulance_task_edaz_bk edaz_task_raw_old