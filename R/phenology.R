#' Fetch Open-Meteo Data
#'
#' @description Retrieves weather data from the Open-Meteo API.
#' @param lat Latitude
#' @param lon Longitude
#' @param start_date Start date format (YYYY-MM-DD)
#' @param end_date End date format (YYYY-MM-DD)
#' @return A dataframe with Date, tmax (F), and tmin (F)
#' @export
fetch_open_meteo <- function(lat, lon, start_date,
                             end_date = as.character(Sys.Date())) {

  base_url <- "https://archive-api.open-meteo.com/v1/archive"

  query_params <- list(
    latitude = lat,
    longitude = lon,
    start_date = start_date,
    end_date = end_date,
    daily = "temperature_2m_max,temperature_2m_min",
    temperature_unit = "fahrenheit",
    timezone = "America/Los_Angeles"
  )

  response <- httr::GET(base_url, query = query_params)
  if (httr::http_error(response)) stop("Failed to fetch data from Open-Meteo.")

  parsed_data <- httr::content(response, as = "parsed", type = "application/json")

  safe_extract <- function(x) {
    sapply(x, function(val) if (is.null(val)) NA_real_ else as.numeric(val))
  }

  data.frame(
    Date = as.Date(unlist(parsed_data$daily$time)),
    tmax = safe_extract(parsed_data$daily$temperature_2m_max),
    tmin = safe_extract(parsed_data$daily$temperature_2m_min)
  )
}

#' Calculate Pest Phenology
#' @param trap_data A data frame containing trap counts
#' @param pest Name of the pest
#' @param lat Latitude
#' @param lon Longitude
#' @param weather_source Weather data source
#' @param cimis_csv_path Path to the CIMIS csv file
#' @param custom_lower Lower developmental threshold
#' @param custom_upper Upper developmental threshold
#' @import dplyr
#' @import rlang
#' @import degday
#' @export
calc_pest_phenology <- function(trap_data, pest = NULL, lat = NULL, lon = NULL,
                                weather_source = "open_meteo", cimis_csv_path = NULL,
                                custom_lower = NULL, custom_upper = NULL) {

  if (!is.null(pest)) {
    pest_info <- TrackTrap::pest_thresholds[
      TrackTrap::pest_thresholds$pest_code == toupper(pest), ]

    if (nrow(pest_info) == 0) {
      stop("Pest code not found in database. Use custom_lower and custom_upper.")
    }

    lower_thresh <- if (is.null(custom_lower)) pest_info$lower_thresh else custom_lower
    upper_thresh <- if (is.null(custom_upper)) pest_info$upper_thresh else custom_upper

    message(sprintf(
      "Using thresholds for %s: Lower = %s F, Upper = %s F",
      pest_info$pest_name, lower_thresh, upper_thresh
    ))
  } else {
    if (is.null(custom_lower) || is.null(custom_upper)) {
      stop("You must provide either a 'pest' code (e.g., 'OLFF', 'NOW', 'CD') OR both 'custom_lower' and 'custom_upper'.")
    }
    lower_thresh <- custom_lower
    upper_thresh <- custom_upper
    message(sprintf(
      "Using custom thresholds: Lower = %s F, Upper = %s F",
      lower_thresh, upper_thresh
    ))
  }

  trap_data$date <- as.Date(trap_data$date)
  start_date <- as.character(min(trap_data$date, na.rm = TRUE))
  end_date   <- as.character(max(trap_data$date, na.rm = TRUE))

  if (weather_source == "open_meteo") {
    if (is.null(lat) || is.null(lon)) {
      stop("Latitude and longitude are required for 'open_meteo'.")
    }
    message("Fetching historical and live weather from Open-Meteo...")
    weather_data <- fetch_open_meteo(lat, lon, start_date, end_date)

  } else if (weather_source == "daymet") {

    if (is.null(lat) || is.null(lon)) {
      stop("Latitude and longitude are required for 'daymet'.")
    }
    message("Fetching historical weather from NASA Daymet...")
    if (as.numeric(substr(end_date, 1, 4)) >= as.numeric(format(Sys.Date(), "%Y"))) {
      stop("Daymet only supports data up to the previous calendar year (For instance; data until Dec 31, 2025 is available as of now). Use 'open_meteo' for current year.")
    }

    raw_daymet <- daymetr::download_daymet(
      lat = lat,
      lon = lon,
      start = as.numeric(substr(start_date, 1, 4)),
      end = as.numeric(substr(end_date, 1, 4)),
      internal = TRUE
    )

    weather_data <- data.frame(
      Date = as.Date(paste(raw_daymet$data$year,
                           raw_daymet$data$yday, sep = "-"), "%Y-%j"),
      tmax = (raw_daymet$data$tmax..deg.c. * 9 / 5) + 32,
      tmin = (raw_daymet$data$tmin..deg.c. * 9 / 5) + 32
    )

  } else if (weather_source == "cimis_csv") {

    message("Loading local CIMIS CSV data...")
    if (is.null(cimis_csv_path)) {
      stop("Must provide cimis_csv_path when using 'cimis_csv'.")
    }

    raw_cimis <- utils::read.csv(cimis_csv_path)

    weather_data <- data.frame(
      Date = as.Date(raw_cimis$Date, format = "%m/%d/%Y"),
      tmax = as.numeric(raw_cimis$Max.Air.Temp..F.),
      tmin = as.numeric(raw_cimis$Min.Air.Temp..F.)
    )

  } else {
    stop("Invalid weather_source. Use 'open_meteo', 'daymet', or 'cimis_csv'.")
  }

  weather_data$avg_temp <- (weather_data$tmax + weather_data$tmin) / 2
  weather_data$avg_temp <- ifelse(weather_data$avg_temp > upper_thresh,
                                  upper_thresh,
                                  weather_data$avg_temp)
  weather_data$DD <- weather_data$avg_temp - lower_thresh
  weather_data$DD <- ifelse(weather_data$DD < 0, 0, weather_data$DD)
  weather_data$DD[is.na(weather_data$DD)] <- 0
  weather_data$cumulative_dd <- cumsum(weather_data$DD)

  final_df <- merge(trap_data, weather_data,
                    by.x = "date", by.y = "Date", all.x = TRUE)

  biofix_date <- min(final_df$date[final_df$trap_counts > 0], na.rm = TRUE)
  if (is.infinite(biofix_date)) {
    stop("No positive trap counts found; cannot set biofix.")
  }

  biofix_dd <- final_df$cumulative_dd[final_df$date == biofix_date][1]
  final_df$cumulative_dd_from_biofix <- final_df$cumulative_dd - biofix_dd

  final_df
}

#' Plot Trap Phenology with Flight Markers
#' @param pheno_data Phenology data frame
#' @param pest Name of the pest
#' @export
plot_trap_phenology <- function(pheno_data, pest = NULL) {

  pheno_data$cumulative_dd_from_biofix <-
    as.numeric(pheno_data$cumulative_dd_from_biofix)

  p <- ggplot2::ggplot(
    data = pheno_data,
    ggplot2::aes(x = cumulative_dd_from_biofix, y = trap_counts)
  ) +
    ggplot2::geom_line(color = "darkred", linewidth = 1.2) +
    ggplot2::geom_point(color = "red", size = 3) +
    ggplot2::theme_minimal() +
    ggplot2::labs(
      title = paste(ifelse(is.null(pest), "Pest", toupper(pest)), "Phenology"),
      subtitle = "Trap Catch vs. Accumulated Degree-Days",
      x = "Accumulated Degree-Days from Biofix",
      y = "Trap Catch Count"
    ) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", size = 14),
      axis.title = ggplot2::element_text(face = "bold")
    )

  if (!is.null(pest)) {
    pest_info <- TrackTrap::pest_thresholds[
      TrackTrap::pest_thresholds$pest_code == toupper(pest), ]

    if (nrow(pest_info) == 1 &&
        "flight_interval_dd" %in% names(pest_info) &&
        !is.na(pest_info$flight_interval_dd)) {

      interval <- pest_info$flight_interval_dd

      flights <- c(0, interval, interval * 2, interval * 3)
      labels  <- c("1st Flight\n(Biofix)", "2nd Flight",
                   "3rd Flight", "4th Flight")

      for (i in seq_along(flights)) {
        p <- p +
          ggplot2::geom_vline(
            xintercept = flights[i],
            linetype = "dashed",
            color = "blue",
            linewidth = 0.8
          ) +
          ggplot2::annotate(
            "text",
            x = flights[i] + interval * 0.03,
            y = max(pheno_data$trap_counts, na.rm = TRUE) * 0.9,
            label = labels[i],
            hjust = 0,
            color = "blue",
            size = 3.5
          )
      }
    } else {
      message("Note: No generation interval defined in database for this pest. Flight lines skipped.")
    }
  }

  p
}
