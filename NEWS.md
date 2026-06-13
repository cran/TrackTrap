# TrackTrap 1.0.0
* Added Open-Meteo API support for real-time, current-year weather forecasting.
* Restructured 'calc_pest_phenology()' to allow users to select between "open_meteo", "daymet", or "cimis_csv" via the weather_source argument.
* Remodeled pest database to include predictive biofix for certain pests (codling moth, California red scale, San Jose Scale etc.)
* Plots biofix of a given pest against different flight generations. Biofix from date of first non-zero trap count.
*Incorporated 104 different agricultural pests across USA; predictive biofix assigned to certain pests