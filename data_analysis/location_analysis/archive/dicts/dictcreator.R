allCountries <- read.delim("~/Downloads/allCountries.txt", header=FALSE)

allCountries <- allCountries[, c("V2", "V18")]
colnames(allCountries) <- c("LocationName", "CountryName")

# Now, you can export it to a CSV file
write.csv(allCountries, file = "~/Downloads/allCountries.csv", row.names = FALSE)

