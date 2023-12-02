library(readr)
library(dplyr)
library(stringr)
library(purrr)

# Define the path to the directory containing the HTML files
directory_path <- "HTML/20minutes/"

# List all HTML files in the directory
file_paths <- list.files(directory_path, pattern = "\\.html$", full.names = TRUE)

# Define a function to process each HTML file
process_file <- function(file_path) {
  # Provide feedback that the file is being processed
  message("Processing file: ", basename(file_path))
  
  # Use tryCatch to handle errors and continue processing other files
  tryCatch({
    html_content <- read_html(file_path)
    
    # Extract the genre from the <span> within the <h2> tag and remove the colon
    genre <- html_content %>%
      html_nodes(xpath = '//h2[not(@class)]/span[not(@class)]') %>%
      html_text(trim = TRUE) %>%
      str_squish() %>%
      str_remove(":") # Remove the colon
    genre <- ifelse(length(genre) > 0, genre, NA)
    
    # Extract the title from the <h2> tag, excluding any nested <span> tags
    title <- html_content %>%
      html_nodes(xpath = '//h2[not(@class)]/text()') %>%
      html_text(trim = TRUE) %>%
      str_squish()
    title <- ifelse(length(title) > 0, title, NA)
    
    # Extract the main content from the <p> tags within the class 'Article_elementTextblockarray__1gb_B'
    main_content <- html_content %>%
      html_nodes('.Article_elementTextblockarray__1gb_B p') %>%
      html_text(trim = TRUE) %>%
      str_squish()
    main_content_combined <- ifelse(length(main_content) > 0, paste(main_content, collapse=" "), NA)
    
    # Check if the content is "NA" or "Page non trouvée" and filter it out
    if (main_content_combined == "NA" || main_content_combined == "Page non trouvée") {
      return(NULL) # Skip this entry
    }
    
    # Create a dataframe with the extracted information
    tibble(Genre = genre, Title = title, Content = main_content_combined)
  }, error = function(e) {
    # If an error occurs, print a message and return NULL to skip this entry
    message("Error processing file: ", basename(file_path), "\nError: ", e)
    return(NULL)
  })
}



# Process all files and combine the results into a single dataframe
all_articles_df <- map_df(file_paths, process_file)
view(all_articles_df)

# Write the dataframe to a CSV file in the same directory as the script
csv_path <- "data/extractor_all_articles_20minutes.csv"
write.csv(all_articles_df, csv_path, row.names = FALSE)

# Return the path to the CSV file as output
csv_path
