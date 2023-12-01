##### step 5 of lab cleaning script for the dummy data set
#### by Victorine Muse, last updated December 1st, 2023 for public use

### combine final flagged data files (quantitative, keep, and binary subgroups)

library(data.table)
setwd("~/Desktop/Protocol_work/data_cleaning/interim_data")
#load and combine all 3 sub-files with flagged observations for normal/ abnormal
KeepData_flagged = fread('dummy_KeepData_flagged.tsv', colClasses = 'character')
KeepData_flagged= subset(KeepData_flagged, select = c("pid","quantity_id", "lab_id", "system", "component","unit", "ref_lower", "ref_upper", "value", "date","time", 
                              "database", "component_db", "component_simple_lookup", "clean_quantity_id", "unit_clean", "system_clean", "value_clean", "ref_lower_clean", "ref_upper_clean", "interval_type", "FLAG", "rule" ))

BinaryData_flagged = fread('dummy_BinaryData_flagged.tsv', colClasses = 'character')
BinaryData_flagged= subset(BinaryData_flagged, select = c("pid","quantity_id", "lab_id", "system", "component","unit",  "ref_lower", "ref_upper", "value", "date","time", 
                              "database", "component_db", "component_simple_lookup", "clean_quantity_id", "unit_clean", "system_clean", "value_clean", "ref_lower_clean", "ref_upper_clean", "interval_type", "FLAG", "rule" ))

QuantitativeData_flagged = fread('dummy_QuantData_flagged.tsv', colClasses = 'character')
QuantitativeData_flagged= subset(QuantitativeData_flagged, select = c("pid","quantity_id", "lab_id", "system", "component","unit",  "ref_lower", "ref_upper", "value", "date","time", 
                                "database", "component_db", "component_simple_lookup", "clean_quantity_id", "unit_clean", "system_clean", "value_clean", "ref_lower_clean", "ref_upper_clean", "interval_type", "FLAG", "rule" ))


allFlaggedData=rbind(KeepData_flagged, BinaryData_flagged, QuantitativeData_flagged)

write.table(allFlaggedData, file='dummy_flagged_data.tsv', quote=FALSE, sep='\t', row.names=FALSE)

