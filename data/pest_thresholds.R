pest_thresholds <- data.frame(
  pest_code = c(
    "OLFF", "NOW", "CM", "SWD", "BMSB", "ACP", "PTB", "WHF", "CRS", "SJS", "CT", "CLM",
    "CMB", "AW", "BCW", "CL", "CMG", "CPB", "CEW", "CRW", "ECB", "FB", "ICW", "JB", "LB",
    "OM", "SM", "SVB", "SB", "VCW", "WBCW", "WFT", "GWSS", "VMB", "LBAM", "EGVM", "CFF",
    "PL", "BLB", "CSB", "SCA", "WSAW", "WCM", "SHW", "PWB", "AM", "BA", "CB", "CFB", "CBB",
    "DPB", "EAB", "FAW", "GPA", "HC", "MB", "OFM", "PB", "RB", "SCA", "TSSM", "WA", "WFF",
    "YSA", "BCA", "CA", "CFA", "CP", "DBM", "FMB", "GA", "GSS", "HWA", "LPT", "MBB", "NP",
    "OBLR", "PBW", "PLH", "RS", "SLF", "TMB", "WAA", "WPB", "YAA", "AB", "BWA", "CNA",
    "CW", "ESB", "GWB", "HCT", "LAW", "MRB", "PA", "PBA", "RWA", "SPW", "TA", "VPB", "WFA",
    "WSB", "YMA", "ZMA"
  ),

  pest_name = c(
    "Olive Fruit Fly", "Navel Orangeworm", "Codling Moth", "Spotted Wing Drosophila",
    "Brown Marmorated Stink Bug", "Asian Citrus Psyllid", "Peach Twig Borer",
    "Walnut Husk Fly", "California Red Scale", "San Jose Scale", "Citrus Thrips",
    "Citrus Leafminer", "Citrus Mealybug", "Alfalfa Weevil", "Black Cutworm",
    "Cabbage Looper", "Cabbage Maggot", "Colorado Potato Beetle", "Corn Earworm",
    "Corn Rootworm", "European Corn Borer", "Flea Beetle", "Imported Cabbageworm",
    "Japanese Beetle", "Lygus Bug", "Onion Maggot", "Seedcorn Maggot", "Squash Vine Borer",
    "Stalk Borer", "Variegated Cutworm", "Western Bean Cutworm", "Western Flower Thrips",
    "Glassy-winged Sharpshooter", "Vine Mealybug", "Light Brown Apple Moth",
    "European Grapevine Moth", "Caribbean Fruit Fly", "Purple Loosestrife",
    "Bean Leaf Beetle", "Common Stalk Borer", "Soybean Aphid", "Wheat Stem Sawfly",
    "Wheat Curl Mite", "Sunflower Headclipping Weevil", "Pale Western Cutworm",
    "Apple Maggot", "Banded Ash Borer", "Cabbage Butterfly", "Citrus Flat Mite",
    "Coffee Bean Borer", "Diamondback Moth", "Emerald Ash Borer", "Fall Armyworm",
    "Green Peach Aphid", "Hessian Fly", "Mexican Bean Beetle", "Oriental Fruit Moth",
    "Pink Bollworm", "Redbanded Stink Bug", "Sugarcane Aphid", "Two-Spotted Spider Mite",
    "Woolly Apple Aphid", "Western Flower Thrips", "Yellow Sugarcane Aphid",
    "Brown Citrus Aphid", "Cotton Aphid", "Citrus Flat Mite", "Codling Moth",
    "Diamondback Moth", "Filbertworm", "Green Apple Aphid", "Green Stink Bug",
    "Hemlock Woolly Adelgid", "Lesser Peachtree Borer", "Mexican Bean Beetle",
    "Navel Orangeworm", "Obliquebanded Leafroller", "Pink Bollworm", "Potato Leafhopper",
    "Red Scale", "Spotted Lanternfly", "Tarnished Plant Bug", "Woolly Apple Aphid",
    "Western Pine Beetle", "Yellow Apple Aphid", "Apple Blotch", "Balsam Woolly Adelgid",
    "Citrus Nematode", "Corn Rootworm", "European Chafer", "Grape Root Borer",
    "Hickory Tussock Moth", "Lesser Appleworm", "Mint Root Borer", "Pea Aphid",
    "Pecan Nut Casebearer", "Russian Wheat Aphid", "Sweetpotato Whitefly", "Turnip Aphid",
    "Velvetbean Caterpillar", "Western Flower Thrips", "Wheat Stem Borer", "Yellow Mite",
    "Zimmerman Pine Moth"
  ),

  lower_thresh = c(
    46.4, 55, 50, 50, 57.2, 60.8, 50, 41, 52.7, 51, 58.3, 51.3, 46.8, 44.2, 43.6, 43.7,
    46.1, 50.5, 48.6, 45.8, 52.2, 42.8, 45.8, 47.3, 49.1, 55.7, 44, 50.3, 51.8, 40.9, 52.2,
    43.4, 41.3, 59, 59.3, 56.2, 46.1, 42, 53.7, 48.8, 42.4, 49.9, 40.7, 58.2, 45.2, 53.3,
    46.2, 50.4, 50.9, 43.7, 59.4, 55.5, 58.8, 57.9, 52, 58.4, 41.8, 43.9, 40.9, 46.5, 47.8,
    45.4, 56.6, 47.1, 45.6, 50.9, 42.8, 56, 41.5, 59.7, 55.4, 44, 40.1, 56.3, 54.1, 54.6,
    55.4, 41.5, 47.2, 42.3, 57.3, 52.5, 46.6, 41.3, 46.2, 46.5, 54.6, 52.8, 57.7, 49.4,
    42.4, 54.3, 55.2, 51.2, 55.4, 49.9, 50.5, 48.6, 40.5, 42.2, 40.6, 52.7, 46.3, 50.2
  ),

  upper_thresh = c(
    96, 93.9, 88, 86, 91.4, 106.9, 88, 130, 86, 90, 95, 93.2, 94.1, 87.8, 98.4, 93.1, 97.1,
    98.4, 89.8, 86.7, 88.4, 91.4, 97.3, 97.9, 85.1, 92.7, 91.3, 88.3, 86.8, 90.1, 99.1,
    89.8, 92.8, 95.5, 90.5, 99.6, 99.4, 88.8, 92.5, 89.5, 89.3, 85.6, 94.1, 92.5, 85.8,
    89.2, 98.6, 88.6, 87.2, 92.3, 99.8, 88.6, 95.1, 96.4, 88.6, 95.9, 90.5, 94.5, 94.5, 93,
    86.4, 97.5, 89.8, 87.8, 85.6, 93.9, 95.2, 85.2, 92.7, 88.4, 94.7, 87.6, 95.4, 90.8,
    99.1, 87.1, 90.1, 86.7, 98.9, 98.2, 88.9, 94.9, 97.3, 93.3, 92.9, 88.6, 86.4, 98.5,
    98.5, 94.5, 90.1, 90.2, 95.9, 98.5, 98.3, 96.7, 94.6, 86.3, 87.4, 98.5, 94.1, 85.1,
    86.5, 95
  ),

  predictive_biofix_dd = c(
    NA, NA, 175, NA, NA, NA, NA, NA, 180, 275, NA, NA, NA, 150, 200, 275, 300, 180, NA, NA,
    275, 180, 180, 150, 300, 150, 150, 150, 150, 150, 200, 180, 150, 180, 180, 175, 200,
    150, NA, 275, 300, NA, 200, 275, 200, 180, 275, 180, NA, NA, 275, 275, 150, 200, 150,
    200, 150, 180, 275, NA, 200, 200, NA, 150, 200, 300, 180, 275, NA, 275, 300, 200, 200,
    300, NA, 180, 175, NA, 175, 300, 150, 175, 180, 150, 175, 300, 150, 300, 175, 300, 180,
    175, 175, 175, NA, NA, NA, 180, 150, 300, 200, 175, 300, 175
  ),

  flight_interval_dd = c(
    720, 1056, 1000, 450, 968, 320, 740, NA, 1100, 1050, 275, 350, 600, 799, 284, 692, 766,
    522, 811, 279, 285, 1031, 592, 371, 746, 981, 455, 842, 331, 299, 755, 764, 856, 940,
    1177, 740, 557, 1005, 507, 667, 325, 274, 1165, 1044, 911, 639, 415, 399, 488, 772,
    929, 877, 516, 1157, 951, 777, 831, 649, 485, 588, 970, 264, 360, 294, 289, 1063, 918,
    700, 343, 717, 700, 415, 662, 629, 835, 853, 293, 606, 845, 728, 1064, 876, 405, 317,
    860, 275, 806, 1143, 797, 619, 861, 685, 768, 1144, 617, 1163, 1110, 436, 316, 346,
    267, 340, 899, 318
  ),

  stringsAsFactors = FALSE
)

pest_thresholds$start_date <- rep("01-01", nrow(pest_thresholds))
pest_thresholds$start_date[pest_thresholds$pest_code == "CRS"] <- "03-01"

