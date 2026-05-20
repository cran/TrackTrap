#' Calculate cumulative degree-days for a pest using Daymet API or CIMIS CSV FILE
#'
#' @param trap_data A data frame containing `date` and `trap_counts`.
#' @param pest A string representing the pest code (e.g., "OLFF", "NOW"). See `pest_thresholds` dataset.
#' @param lat Latitude of the trap location (numeric).
#' @param lon Longitude of the trap location (numeric).
#' @param custom_lower Optional. Override the database with a custom lower threshold.
#' @param custom_upper Optional. Override the database with a custom upper threshold.
#' @param cimis_csv Optional. File path to a manually downloaded CIMIS daily CSV file.
#'
#' @return A data frame joining the trap data with daily temperatures and cumulative degree-days.
#' @examplesIf interactive()
#'   # Create mock trap data for testing
#'   trap_df <- data.frame(date = as.Date(c("2024-05-01", "2024-05-08")),
#'                         trap_counts = c(2, 14))
#'
#'   # Calculate phenology using Daymet API
#'   results <- calc_pest_phenology(trap_df, pest = "OLFF", lat = 38.5, lon = -121.8)
#'
#' @export
#' @importFrom rlang .data
#' @importFrom magrittr %>%
calc_pest_phenology <- function(trap_data, pest = NULL, lat = NULL, lon = NULL,
                                custom_lower = NULL, custom_upper = NULL, cimis_csv = NULL) {

  # --- 1. PEST THRESHOLD ---
  if (!is.null(pest)) {
    # Look up the pest in the built-in database
    pest_info <- TrackTrap::pest_thresholds[TrackTrap::pest_thresholds$pest_code == toupper(pest), ]

    if (nrow(pest_info) == 0) {
      stop("Pest code not found in database. Use custom_lower and custom_upper, or check available pests by typing: TrackTrap::pest_thresholds")
    }

    lower_thresh <- if(is.null(custom_lower)) pest_info$lower_thresh else custom_lower
    upper_thresh <- if(is.null(custom_upper)) pest_info$upper_thresh else custom_upper

    message(sprintf("Using thresholds for %s: Lower = %s F, Upper = %s F", pest_info$pest_name, lower_thresh, upper_thresh))
  } else {
    if (is.null(custom_lower) || is.null(custom_upper)) {
      stop("You must provide either a 'pest' code (e.g., 'OLFF') OR both 'custom_lower' and 'custom_upper' thresholds.")
    }
    lower_thresh <- custom_lower
    upper_thresh <- custom_upper
  }

  # --- 2. DATE FORMATTING ---
  trap_data$date <- as.Date(trap_data$date)
  start_year <- as.numeric(format(min(trap_data$date, na.rm = TRUE), "%Y"))
  end_year <- as.numeric(format(max(trap_data$date, na.rm = TRUE), "%Y"))

  # --- 3. WEATHER DATA FETCHING --- (Initial parsing to CIMIS, otherwise redirect to NASA DayMet)
  if (!is.null(cimis_csv)) {
    if (!file.exists(cimis_csv)) stop("CIMIS CSV file not found.")
    weather_raw <- utils::read.csv(cimis_csv, stringsAsFactors = FALSE)

    clean_weather <- weather_raw %>%
      dplyr::mutate(
        Date = as.Date(.data$Date, format = "%m/%d/%Y"),
        Tmin = as.numeric(.data$DayAirTmpMin),
        Tmax = as.numeric(.data$DayAirTmpMax)
      ) %>%
      dplyr::select(.data$Date, .data$Tmin, .data$Tmax) %>%
      dplyr::arrange(.data$Date)
  } else {
    if (is.null(lat) || is.null(lon)) stop("lat and lon must be provided if cimis_csv is NULL.")

    message("Downloading weather data from NASA Daymet API...")
    weather_raw <- daymetr::download_daymet(
      site = "TrapLocation", lat = lat, lon = lon, start = start_year, end = end_year, internal = TRUE, silent = TRUE
    )

    clean_weather <- weather_raw$data %>%
      dplyr::mutate(
        Date = as.Date(paste(.data$year, .data$yday, sep = "-"), "%Y-%j"),
        Tmin = (.data$tmin..deg.c. * 9/5) + 32,
        Tmax = (.data$tmax..deg.c. * 9/5) + 32
      ) %>%
      dplyr::select(.data$Date, .data$Tmin, .data$Tmax) %>%
      dplyr::arrange(.data$Date)
  }

  # --- 4. DEGREE DAY CALCULATION ---
  processed_weather <- clean_weather %>%
    dplyr::mutate(
      Daily_DD = degday::dd_sng_sine(daily_min = .data$Tmin, daily_max = .data$Tmax,
                                     thresh_low = lower_thresh, thresh_up = upper_thresh),
      Cum_DD = cumsum(.data$Daily_DD)
    )

  # --- 5. MERGE AND RETURN DATAFRAME ---
  final_df <- dplyr::left_join(trap_data, processed_weather, by = c("date" = "Date"))
  return(final_df)
}

#' Plot Cumulative Degree-Days against Trap Counts
#'
#' @param df The data frame outputted by `calc_pest_phenology`.
#' @param save_plot Logical. If TRUE, saves the plot to your working directory.
#'
#' @return A ggplot object.
#' @export
#' @importFrom rlang .data
plot_phenology_trend <- function(df, save_plot = FALSE) {

  p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$Cum_DD, y = .data$trap_counts)) +
    ggplot2::geom_line(color = "forestgreen", linewidth = 1.2) +
    ggplot2::geom_point(size = 3, color = "darkred") +
    ggplot2::theme_minimal() +
    ggplot2::labs(
      title = "Pest Trap Counts by Cumulative Degree-Days",
      subtitle = "Tracking pest emergence against heat accumulation",
      x = "Cumulative Degree-Days",
      y = "Trap Count (Pest Catches)"
    )

  if (save_plot) {
    ggplot2::ggsave(filename = "Phenology_Trend (Pest emergence and development).png", plot = p, width = 8, height = 6, dpi = 300)
  }

  return(p)
}
