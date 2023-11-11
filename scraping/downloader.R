library(tidyverse)
library(httr)

# Define the function to download HTML files
download_html <- function(df, target_dir) {
  df %>%
    mutate(
      # Convert date to character and replace special characters in the title
      date = as.character(date),
      title = gsub(" ", "-", title),
      title = iconv(title, from = "UTF-8", to = "ASCII//TRANSLIT") # transliterate ä, ö, ü to ae, oe, ue
    ) %>%
    rowwise() %>%
    do({
      try({
        # Construct the filename
        filename <- paste0(.$date, "_", .$title, ".html")
        
        # Create the complete path for the file
        file_path <- file.path(target_dir, filename)
        
        # Download the file
        GET(.$loc, write_disk(file_path, overwrite = TRUE))
        Sys.sleep(2) # Sleep for 2 seconds to throttle the download speed
      }, silent = TRUE) # If an error occurs (like a 404), it will skip to the next file
    })
}

# Create a new 'HTML' directory and subdirectories for each publication
base_dir <- getwd() # Replace this with the path to the base directory if not running from the base directory
html_dir <- file.path(base_dir, "HTML")
dir.create(html_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(file.path(html_dir, "20minuti"), showWarnings = FALSE)
dir.create(file.path(html_dir, "20minuten"), showWarnings = FALSE)
dir.create(file.path(html_dir, "20minutes"), showWarnings = FALSE)

# Define the path to the 'final' directory where the CSVs are located
csv_final_dir <- file.path(base_dir, "csv_files", "final")

# Get the list of CSV files
csv_files <- list.files(csv_final_dir, pattern = "processed_.*\\.csv$", full.names = TRUE)

# Download the HTML files for each CSV file
for (csv_file in csv_files) {
  file_info <- str_match(basename(csv_file), "processed_(.*?)\\.csv")
  publication_name <- file_info[2]
  target_dir <- file.path(html_dir, publication_name)
  
  # Read the CSV file
  df <- read_csv(csv_file, show_col_types = FALSE)
  
  # Download the HTML content using the function
  download_html(df, target_dir)
}
