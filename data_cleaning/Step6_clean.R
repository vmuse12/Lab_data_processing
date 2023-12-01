##### step 6 of lab cleaning script for the dummy data set
#### by Victorine Muse, last updated December 1st, 2023 for public use

### combine data with no reference intervals

setwd("~/Desktop/Lab_data_processing/data_cleaning/interim_data")
library(data.table)

quantData = fread('dummy_quantData_noInt.tsv', colClasses = 'character')
quantData = subset(quantData, select = c("pid","quantity_id", "lab_id", "system", "component","unit", "ref_lower", "ref_upper", "value", "date","time", 
                                         "database", "component_db", "component_simple_lookup", "clean_quantity_id", "unit_clean", "system_clean", "value_clean", "ref_lower_clean", "ref_upper_clean", "interval_type", "rule" ))

##empty in dummy dataset but can exist 
quantKeepData =fread('dummy_KeepData_noInterval.tsv', colClasses = 'character')
quantKeepData= subset(quantKeepData, select = c("pid","quantity_id", "lab_id", "system", "component","unit", "ref_lower", "ref_upper", "value", "date","time", 
                                                "database", "component_db", "component_simple_lookup", "clean_quantity_id", "unit_clean", "system_clean", "value_clean", "ref_lower_clean", "ref_upper_clean", "interval_type", "rule" ))

allQuantNoFlagData =rbind(quantData, quantKeepData)

allQuantNoFlagData= subset(allQuantNoFlagData, allQuantNoFlagData$rule == 'quant') ###remove qualitative tests (moved to qualitative dataset)

#add an empty flagged column to allow for easy merging with the other data
allQuantNoFlagData$FLAG= 'NA'

write.table(allQuantNoFlagData, file='dummy_quantitativeData_noInterval.tsv', quote=FALSE, sep='\t', row.names=FALSE)

