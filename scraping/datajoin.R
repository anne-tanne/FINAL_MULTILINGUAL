library(tidyverse)
library(lubridate)

# Define directory path
csv_dir <- "csv_files"
final_dir <- file.path(csv_dir, "final")

# Create the 'final' subdirectory if it doesn't exist
dir.create(final_dir, showWarnings = FALSE, recursive = TRUE)

# Function to join CSV files by publication name and process them
join_csv_by_publication <- function(publication_name, csv_dir, final_dir) {
  # List all CSV files
  all_csv_files <- list.files(csv_dir, pattern = "\\.csv$", full.names = TRUE)
  
  # Filter files for the specific publication
  publication_files <- all_csv_files[grepl(publication_name, all_csv_files)]
  
  # Read and combine all filtered files
  combined_df <- map_df(publication_files, read_csv) |>
    # Remove placeholder columns like ...1, ...2 etc.
    select(-matches("^\\.\\.\\.\\d+$")) |>
    mutate(publication_date = ymd_hms(publication_date),
           date = as.Date(publication_date),
           time = format(publication_date, "%H:%M:%S")) |>
    select(-publication_date) |>
    select(-publication_name) |>
    mutate(language = ifelse(publication_name == "20minuten", "de",
                             ifelse(publication_name == "20minutes", "fr", language))) |>
    {
      if (publication_name %in% c("20minuten", "20minutes")) {
        select(., -keywords)
      } else {
        .
      }
    } |>
    {
      if (publication_name == "20minuti") {
        select(., -image_loc)
      } else {
        .
      }
    } |>
    arrange(date, time) # Sort by date and time
  
  # Write the processed dataframe to a new CSV file in the 'final' directory
  combined_file_path <- file.path(final_dir, paste0("processed_", publication_name, ".csv"))
  write_csv(combined_df, combined_file_path)
  
  return(combined_df)
}

# Join CSV files for each publication and store in the 'final' folder
processed_20minuti <- join_csv_by_publication("20minuti", csv_dir, final_dir)
processed_20minuten <- join_csv_by_publication("20minuten", csv_dir, final_dir)
processed_20minutes <- join_csv_by_publication("20minutes", csv_dir, final_dir)
