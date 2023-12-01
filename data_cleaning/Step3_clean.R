##### step 3 of lab cleaning script for the dummy data set
#######last edited December 1st, 2023 for Protocol paper
##by Victorine Muse

####this is the third script to run for cleaning lab data
####this is mainly used to flag normal vs abnormal data using a 0/1 system (for binary data only)

library(data.table)
library(dplyr)

#load reference tables for use
setwd("~/Desktop/Lab_data_processing/data_cleaning/raw_data")
shownValueTable= fread('dummy_shown_list.tsv', colClasses= 'character')
binary_lookup= fread('dummy_binary_lookup.tsv',colClasses= 'character') #value_clean translation to binary system

#set working directory to save intermediate files
setwd("~/Desktop/Lab_data_processing/data_cleaning/interim_data")
measurements= fread('dummy_nonquantData.tsv', colClasses= 'character')

binaryList= subset(shownValueTable, shownValueTable$action=='binary')
binaryTests= subset(measurements, measurements$value %in% binaryList$shown_value)

useDATA=binaryTests

#merge data with binary lookup table
useDATA= left_join(useDATA, binary_lookup, by = 'value')

#write binary flagged subset
write.table(useDATA, file='dummy_BinaryData_flagged.tsv', quote=FALSE, sep='\t', row.names=FALSE)

#check the data that wasn't processed
useDATA=subset(useDATA, is.na(useDATA$FLAG))

#should be empty if this script worked
write.table(useDATA, file='dummy_data_flaggedNAbinary.tsv', quote=FALSE, sep='\t', row.names=FALSE)

