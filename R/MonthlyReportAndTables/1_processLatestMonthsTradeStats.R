#### Preparation ####

# Clear the environment
rm(list = ls())

# Load the required libraries
library(dplyr) # Manipulating data
library(openxlsx) # Reading and editing excel formatted files

# Note where VNSO code/data is on current computer
repository <- file.path(dirname(rstudioapi::getSourceEditorContext()$path), "..", "..")

# Load the general R functions
source(file.path(repository, "R", "functions.R"))

# Note the secure data path
secureDataFolder <- file.path(repository, "data", "secure")

# Note the open data path
openDataFolder <- file.path(repository, "data", "open")

# Read in the raw trade data from secure folder of the repository 
# Note that spaces in column names have been automatically replaced with "."s
tradeStatsFile <- file.path(secureDataFolder, "SEC_PROC_ASY_RawDataAndReferenceTables_31-12-19.xlsx")
tradeStats <- read.xlsx(tradeStatsFile, sheet=1, skipEmptyRows=TRUE)

#### Clean and process the latest month's data ####

## Initial re-formatting of the data

# Remove the repeated header row from the trade statistics data
tradeStats <- tradeStats[tradeStats$Office != "Office", ]

# Remove duplicated rows from the trade statistics data
duplicatedRows <- duplicated(tradeStats) 
tradeStatsNoDup <- tradeStats[duplicatedRows == FALSE, ]

# Convert the CP4 to a factor
tradeStatsNoDup$CP4 <- as.factor(tradeStats$CP4)

# Convert the statistical value to numeric
tradeStatsNoDup$Stat..Value <- as.numeric(tradeStats$Stat..Value)

# Convert excel figures to dates
tradeStatsNoDup$Reg..Date <- as.Date(as.numeric(tradeStats$Reg..Date), origin="1899-12-30") # For numeric dates excel sets origin to December 30, 1899 (https://stackoverflow.com/questions/43230470/how-to-convert-excel-date-format-to-proper-date-in-r)

# Exclude banknotes from exports
tradeStatsNoBanknotes <- tradeStatsNoDup[tradeStatsNoDup$HS.Code != "49070010", ]

# Create subset for Export and Import commodities 
tradeStatsSubset <- tradeStatsNoBanknotes[tradeStatsNoBanknotes$Type %in% c("EX / 1","EX / 3", "IM / 4", "IM / 7", "PC / 4"), ]
tradeStatsCommodities <- tradeStatsSubset[tradeStatsSubset$CP4 %in% c(1000, 3071, 4000, 4071, 7100), ]

# Print progress
cat("Finished initial cleaning and processing of data.\n")

#### Explore the extent of missing data ####

# Count the number of missing values in each column
numberMissing <- apply(tradeStatsCommodities, MARGIN=2,
                       FUN=function(columnValues){
                         return(sum(is.na(columnValues)))
                       })

# Convert the counts to a proportion
proportionMissing <- numberMissing / nrow(tradeStatsCommodities)

# Set the plotting margins
par(mar=c(10, 4, 4, 1))

# Plot the proportion missing in each column
barplot(proportionMissing[order(proportionMissing)], las=2, ylim=c(0,1),
        main="Amount missing values in each column",
        ylab="Proportion")

# Print progress
cat("Finished exploring extent of missing data.\n")

#### Extract the SITC and HS sub-codes ####

# Extract the 6, 4, and 2 digit HS codes into separate columns
tradeStatsCommodities$HS.Code_6 <- extractCodeSubset(tradeStatsCommodities$HS.Code, nDigits=6)
tradeStatsCommodities$HS.Code_4 <- extractCodeSubset(tradeStatsCommodities$HS.Code, nDigits=4)
tradeStatsCommodities$HS.Code_2 <- extractCodeSubset(tradeStatsCommodities$HS.Code, nDigits=2)

# Extract the 3 and 1 digit SITC codes into separate columns
tradeStatsCommodities$SITC_3 <- extractCodeSubset(tradeStatsCommodities$SITC, nDigits=3)
tradeStatsCommodities$SITC_1 <- extractCodeSubset(tradeStatsCommodities$SITC, nDigits=1)

# Print progress
cat("Added SITC and HS sub-codes into table.\n")

#### Extract the Year, Month, and Day as separate columns ####

# Create new columns for dates
tradeStatsCommodities$Year <- format(tradeStatsCommodities$Reg..Date, format= "%Y")
tradeStatsCommodities$Month <- format(tradeStatsCommodities$Reg..Date, format= "%B")
tradeStatsCommodities$Day <- format(tradeStatsCommodities$Reg..Date, format= "%d")

# Print progress
cat("Added separate date elements.\n")

#### Merge in classification tables ####

## MODE OF TRANSPORT ##

# Merge Mode of Transport classifications with cleaned data
tradeStatsFileMergeTransport <- file.path(openDataFolder, "OPN_FINAL_ASY_ModeOfTransportClassifications_31-01-20.xlsx") 
modeOfTransport <- read.xlsx(tradeStatsFileMergeTransport, sheet=1, skipEmptyRows=TRUE)
tradeStatsCommoditiesMergedWithClassifications <- merge(tradeStatsCommodities, modeOfTransport, by="Office", all.x=TRUE)

## HARMONISED SYSTEM (HS) CODES ##

# Merge Harmonised System (HS) Code classifications with cleaned data
tradeStatsFileMergeHSCode <- file.path(openDataFolder, "OPN_FINAL_ASY_HSCodeClassifications_31-01-20.xlsx") 
hsDescription <- read.xlsx(tradeStatsFileMergeHSCode, sheet=1, skipEmptyRows=TRUE)
tradeStatsCommoditiesMergedWithClassifications <- merge(tradeStatsCommoditiesMergedWithClassifications, hsDescription, by="HS.Code_2", all.x=TRUE)

## STANDARD INTERNATIONAL TRADE CLASSIFICATION (SITC) CODES ##

# Merge Standard International Trade Classification (SITC) Code classifications with cleaned data
tradeStatsFileMergeSITCCode <- file.path(openDataFolder, "OPN_FINAL_ASY_SITCCodeClassifications_31-01-20.xlsx") 
sitcDescription <- read.xlsx(tradeStatsFileMergeSITCCode, sheet=1, skipEmptyRows=TRUE)
colnames(sitcDescription)[2] <- "SITC_description"
tradeStatsCommoditiesMergedWithClassifications <- merge(tradeStatsCommoditiesMergedWithClassifications, sitcDescription, by="SITC_1", all.x=TRUE)

## COUNTRY DESCRIPTIONS OF IMPORTS ##

# Merge Standard International Trade Classification (SITC) Code classifications with cleaned data
tradeStatsFileMergeCountryDesImports <- file.path(openDataFolder, "OPN_FINAL_ASY_CountryDescriptionImportClassifications_31-01-20.xlsx")
countryDescriptionImports <- read.xlsx(tradeStatsFileMergeCountryDesImports, sheet=1, skipEmptyRows=TRUE)
tradeStatsCommoditiesMergedWithClassifications <- merge(tradeStatsCommoditiesMergedWithClassifications, countryDescriptionImports, by="CO", all.x=TRUE)

## COUNTRY DESCRIPTIONS OF EXPORTS ##

# Merge Standard International Trade Classification (SITC) Code classifications with cleaned data
tradeStatsFileMergeCountryDesExports <- file.path(openDataFolder, "OPN_FINAL_ASY_CountryDescriptionExportClassifications_31-01-20.xlsx") 
countryDescriptionExports <- read.xlsx(tradeStatsFileMergeCountryDesExports, sheet=1, skipEmptyRows=TRUE)
tradeStatsCommoditiesMergedWithClassifications <- merge(tradeStatsCommoditiesMergedWithClassifications, countryDescriptionExports, by="CE/CD", all.x=TRUE)

## PRINCIPLE COMMODITIES ##

# Merge Principle Commodity Classifications of Exports and Imports with cleaned data
tradeStatsFileMergePrincipleCommdityClass <- file.path(openDataFolder, "OPN_FINAL_ASY_PrincipleCommoditiesClassifications_31-01-20.xlsx") 
principleCommodityClassification <- read.xlsx(tradeStatsFileMergePrincipleCommdityClass, sheet=1, skipEmptyRows=TRUE)
tradeStatsCommoditiesMergedWithClassifications <- merge(tradeStatsCommoditiesMergedWithClassifications, principleCommodityClassification, by="HS.Code", all.x=TRUE)

## BROAD ECONOMIC CATEGORIES (BEC) ##

# Merge Broad Economic Categories (BEC) classifications with cleaned data
tradeStatsFileMergeBECDescriptions <- file.path(openDataFolder, "OPN_FINAL_ASY_BECClassifications_31-01-20.xlsx")
becDescriptions <- read.xlsx(tradeStatsFileMergeBECDescriptions, sheet=1, skipEmptyRows=TRUE)
tradeStatsCommoditiesMergedWithClassifications <- merge(tradeStatsCommoditiesMergedWithClassifications, becDescriptions, by="HS.Code_6", all.x=TRUE)

# Print progress
cat("Finished merging in classification tables.\n")

#### Check for missing observations after merging ####

# Check each of the columns introduced by merging
# Note that by is a vector of common columns that were used to join the tables during merging
# and column is a vector of columns that were imported during the merging (one for each merge only)
infoAboutMissingObservations <- searchForMissingObservations(
  tradeStatsCommoditiesMergedWithClassifications, 
  by=c("Office", "HS.Code_2", "SITC_1", "CO", "CE/CD", "HS.Code", "HS.Code_6"), 
  column=c("Mode.of.Transport", "HS.Section", "SITC_description", "IMPORT.REG#", "EXPORT.REG#", "TAR_ALL", "BEC.Descriptions"),
  printWarnings=FALSE)

# Check whether missing observations were present after merging
if(is.null(infoAboutMissingObservations) == FALSE){
  warning(paste0(nrow(infoAboutMissingObservations), " observations were missing following the merging. Examine the \"infoAboutMissingObservations\" variable for more information."))
}

# Print progress
cat("Finished checking for missing observations after merging.\n")

#### Check if any statistical values fall outside of expected boundaries ####

# Load the summary statistics for the historic IMPORTS and EXPORTS data
historicImportsSummaryStats <- read.csv(file.path(secureDataFolder, "imports_HS_summaryStats_02-10-20.csv"))
historicExportsSummaryStats <- read.csv(file.path(secureDataFolder, "exports_HS_summaryStats_02-10-20.csv"))

# Check the commodity values against expected values based on historic data
commoditiesWithExpectations <- checkCommodityValues(tradeStatsCommoditiesMergedWithClassifications,  
                                                    historicImportsSummaryStats, historicExportsSummaryStats,
                                                    importCP4s=c(4000, 4071, 7100), exportCP4s=c(1000), useUnitValue=FALSE)

# Print progress
cat("Finished checking whether commodity values fall outside of expectations based on historic data.\n")

#### Finish ####

# Make copy of latest month's processed data
processedTradeStats <- tradeStatsCommoditiesMergedWithClassifications

# Save a local copy of the process data
saveRDS(processedTradeStats, file.path(repository, "data", "secure", "processed_trade_stats.rds"))

# Note progress
cat("Finished processing and cleaning latest month's data.\n")