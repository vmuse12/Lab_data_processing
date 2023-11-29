##### step ZERO of lab data cleaning script pulling original data files
##### this step is not always needed depending on starting data frame and therefore not integral to cleaning (ie step 0)
#### by Victorine Muse, last updated November 22nd, 2023 (edits to  make it publicly available)
## process generalized for wider applicability, and patient sensitive information hidden

library(data.table)

setwd("~/Desktop/Protocol_work/raw_data")

#load in dummy data  
measurements= fread('dummy_lab_data.tsv', colClasses= 'character')
measurements$database= 'dummy' #retain information of where data came from

###here check that all columns and date times are in correct format
##take this time to merge datasets if you have data from multiple data sources as well 

# filter data for study approved times 
measurements= subset(measurements, measurements$date > '2011-12-31')
measurements= subset(measurements, measurements$date < '2016-01-01')

#conform text format to help processing
measurements$component=toupper(measurements$component)
measurements$value=tolower(measurements$value)
measurements= unique.data.frame(measurements) #remove duplicates found at this stage, some tests can be included twice

setwd("~/Desktop/Protocol_work/interim_data")
#write combined table to combined file for general use- note this file is NOT CLEANED AT ALL, simply filtered for correct dates and unique observations
write.table(measurements, file='filtered_dummy_data.tsv', quote=FALSE, sep='\t', row.names=FALSE)

