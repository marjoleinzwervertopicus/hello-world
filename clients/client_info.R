... <- (function() {
  list(
    rav_drenthe = list(
      customer_id = 1,
      client = "rav_drenthe",
      client_name = "UMCG Ambulancezorg",
      client_name_short = "UMCGA",
      filters_file = "Library/clients/rav_drenthe/ambulance_logistics_edaz/filters.R",
      resources_file = "Library/clients/rav_drenthe/resources/resource_table_2021.csv",
      logistics_db = "db rav_drenthe ambulance_task_edaz",
      reach_limit = c(11*60*1.2, 13*60*1.2),
      rav_region = "RAV Drenthe (3)",
      rav_region_code = "03",
      url = "https://dashboard.rav.nl/",
      shinyproxy_url = "https://drenthe.test.devise.cloud"
    ),
    rav_fryslan = list(
      customer_id = 4,
      client = "rav_fryslan",
      client_name = "RAV Fryslân",
      client_name_short = "Fryslân",
      filters_file = "Library/clients/rav_fryslan/ambulance_logistics_edaz/filters.R",
      resources_file = "Library/clients/rav_fryslan/resources/resource_table_2021.csv",
      logistics_db = "db rav_fryslan ambulance_task_edaz",
      reach_limit = c(11*60*1.2, 13*60*1.2),
      rav_region = "RAV Friesland (2)",
      rav_region_code = "02",
      url = "https://dashboard.rav-fryslan.nl/",
      shinyproxy_url = "https://fryslan.test.devise.cloud"
    ),
    rav_ijsselland = list(
      customer_id = 20,
      client = "rav_ijsselland",
      client_name = "Ambulance IJsselland",
      client_name_short = "AmbuIJ",
      filters_file = "Library/clients/rav_ijsselland/ambulance_logistics_edaz/filters.R",
      resources_file = "Library/clients/rav_ijsselland/resources/resources_2020_04.csv",
      logistics_db = "db rav_ijsselland ambulance_task_edaz",
      reach_limit = c(11*60*1.2, 13*60*1.2),
      rav_region = "RAV IJsselland (4)",
      rav_region_code = "04",
      url = "https://dashboard.ambulanceijsselland.nl",
      shinyproxy_url = "https://ijsselland.test.devise.cloud"
    ),
    rav_limburg_noord = list(
      customer_id = 2,
      client = "rav_limburg_noord",
      client_name = "AmbulanceZorg Limburg-Noord",
      client_name_short = "AZLN",
      filters_file = "Library/clients/rav_limburg_noord/ambulance_logistics_edaz/filters.R",
      resources_file = "Library/clients/rav_limburg_noord/resources/resource_table_2020.csv",
      logistics_db = "db rav_limburg_noord ambulance_task_edaz",
      reach_limit = c(11*60*1.2, 13*60*1.2),
      rav_region = "RAV Noord- en Midden Limburg (23)",
      rav_region_code = "23",
      url = "https://dashboard.ambulancezorgln.nl/",
      shinyproxy_url = "https://limburgnoord.test.devise.cloud"
    ),
    rav_oost = list(
      customer_id = NA,
      client = "rav_oost",
      client_name = "Ambulance Oost",
      client_name_short = "AO",
      filters_file = "Library/clients/rav_drenthe/ambulance_logistics_edaz/filters.R",
      resources_file = "modules/afschaalplannen_2021/resources_rav_oost.csv",
      logistics_db = "db shared rav_oost_ambulance_task",
      reach_limit = c(11*60*1.2, 13*60*1.2),
      rav_region = "RAV Twente (5)",
      rav_region_code = "05",
      url = NA
    ),
    rav_utrecht = list(
      customer_id = NA,
      client = "rav_utrecht",
      client_name = "RAV Utrecht",
      client_name_short = "RAVU",
      filters_file = paste0("Library/clients/rav_utrecht/ambulance_logistics/filters.R"),
      resources_file = "/home/shared/data/clients/rav_utrecht/resources/resources.csv",
      logistics_db = "db rav_utrecht logistic_new_2",
      reach_limit = c(700, 900), 
      rav_region = "RAV Utrecht (9)",
      rav_region_code = "09",
      url = NA
    ),
    rav_limburg_zuid = list(
      customer_id = 25,
      client = "rav_limburg_zuid",
      client_name = "GGD Zuid Limburg",
      client_name_short = "GGDZL",
      filters_file = "Library/clients/rav_drenthe/ambulance_logistics_edaz/filters.R",
      resources_file = "Library/clients/rav_limburg_zuid/resources.csv",
      logistics_db = "db rav_limburg_zuid ambulance_task_edaz",
      reach_limit = c(60*11 * 1.2, 60 * 13 * 1.2),
      rav_region = "RAV Zuid Limburg (24)",
      rav_region_code = "24",
      url = "https://dashboardaz.ggdzl.nl/",
      shinyproxy_url = "https://limburgzuid.test.devise.cloud"
    ),
    lazk = list(
      customer_id = 5,
      client = "lazk",
      client_name = "Landelijk Netwerk Acute Zorg",
      client_name_short = "LNAZ",
      url = "https://www.lazk.nl/",
      shinyproxy_url = "https://lazk.test.devise.cloud"
    ),
    mmt_umcg = list(
      customer_id = 6,
      client = "mmt_umcg",
      client_name = "Mobiel Medisch Team UMCG",
      client_name_short = "MMT UMCG",
      url = "https://ll4-dashboard.nl/",
      shinyproxy_url = "https://ll4-dashboard.nl/"
    ),
    upload = list(
      customer_id = 16,
      client = "upload",
      client_name = "upload",
      url = "https://devise.cloud/upload/",
      shinyproxy_url = "https://devise.cloud/upload/"
    ),
    kwaliteitskaderapp = list(
      customer_id = 17,
      client = "kwaliteitskaderapp",
      client_name = "Kwaliteitskaderapp",
      client_name_short = "KKapp",
      url = "https://www.kwaliteitskaderspoedzorgketen.nl",
      shinyproxy_url = "https://kwaliteitskader.test.devise.cloud"
    ),
    azn = list(
      customer_id = 19,
      client = "azn",
      client_name = "Ambulancezorg Nederland",
      client_name_short = "AZN",
      url = NA
    ),
    chd = list(
      customer_id = 22,
      client = "chd",
      client_name = "Centrale Huisartsendienst Drenthe",
      client_name_short = "CHD",
      url = NA
    ),
    mk_limburg =  list(
      customer_id = 26,
      client = "mk_limburg",
      client_name = "Meldkamer Limburg",
      client_name_short = "MK limburg",
      url = "https://dashboardmka.gmkl.nl/",
      shinyproxy_url = "https://gmkl.test.devise.cloud"
    ),
    devise = list(
      customer_id = 27,
      client = "devise",
      client_name = "Devise",
      url = "https://devise.cloud/devise/",
      shinyproxy_url = "https://devise.cloud/devise/"
    ),
    jb_lorenz = list(
      customer_id = 28,
      client = "jb_lorenz",
      client_name = "JB Lorenz",
      url = "https://devise.cloud/jb_lorenz",
      shinyproxy_url = "https://jblorenz.test.devise.cloud"
    ),
    inzicht = list(
      customer_id = 29,
      client = "inzicht",
      client_name = "Devise inzichten",
      url = "https://devise.cloud/inzicht/"
    ),
    mknn = list(
      customer_id = 30,
      client = "mknn",
      client_name = "Meldkamer Noord Nederland",
      url = "https://devise.cloud/mknn/",
      shinyproxy_url = "https://mknn.test.devise.cloud"
    )
  )
})()

