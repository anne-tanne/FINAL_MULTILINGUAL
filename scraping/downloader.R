library(tidyverse)
library(httr)

# Function to transliterate special characters and download HTML files
download_html_files <- function(csv_file_path, target_dir) {
  # Read the CSV file
  df <- read_csv(csv_file_path, show_col_types = FALSE)
  
  # Iterate over each row in the dataframe
  for(i in 1:nrow(df)) {
    # Create filename from date and title
    date <- gsub("-", "", df$date[i])  # Remove hyphens from date
    title <- tolower(df$title[i])  # Convert title to lower case
    title <- gsub(" ", "-", title)  # Replace spaces with hyphens
    title <- iconv(title, to = "ASCII//TRANSLIT")  # Transliterate characters like ä, ö, ü to ae, oe, ue
    filename <- paste0(date, "_", title, ".html")
    
    # Specify the path for the file
    file_path <- file.path(target_dir, filename)
    
    # Print message to console
    message("Downloading: ", filename)
    
    # Download the file and handle errors silently
    try({
      GET(df$loc[i], write_disk(file_path, overwrite = TRUE))
      message("Downloaded: ", filename)
      Sys.sleep(2)  # Sleep for 2 seconds between downloads
    }, silent = TRUE)
  }
}

# Define base directory and subdirectories
base_dir <- getwd()
csv_final_dir <- file.path(base_dir, "csv_files", "final")
html_dir <- file.path(base_dir, "HTML")

# Create the 'html' directory and subdirectories for each publication if they don't exist
dir.create(html_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(file.path(html_dir, "20minuti"), showWarnings = FALSE)
dir.create(file.path(html_dir, "20minuten"), showWarnings = FALSE)
dir.create(file.path(html_dir, "20minutes"), showWarnings = FALSE)

# List of publication names
publications <- c("20minuti", "20minuten", "20minutes")

# Process each publication's CSV files
for (publication in publications) {
  # Define the path to the current publication's CSV file
  csv_file_path <- file.path(csv_final_dir, paste0("processed_", publication, ".csv"))
  
  # Define the target directory for the HTML files
  target_dir <- file.path(html_dir, publication)
  
  # Print message to console
  message("Starting downloads for ", publication)
  
  # Download the HTML files for the current publication
  download_html_files(csv_file_path, target_dir)
  
  # Print message to console
  message("Completed downloads for ", publication)
}
