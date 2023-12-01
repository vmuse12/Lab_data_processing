##### step 7 of lab cleaning script for the dummy data set
#### by Victorine Muse, last updated November 24th, 2023 for public use

### combine qualitative data (fertility, genotyping, etc)

library( data.table)
#load shown value look up table
setwd("~/Desktop/Protocol_work/data_cleaning/raw_data")
shownValueTable= fread('dummy_shown_list.tsv', colClasses= 'character')

#load and filter non quantitative data
setwd("~/Desktop/Protocol_work/interim_data")
measurements= fread('dummy_nonquantData.tsv', colClasses= 'character')

#not shown in dummy data but can exist 
qualList= subset(shownValueTable, shownValueTable$action=='qualitative')
qualTests= subset(measurements, measurements$shown_value %in% qualList$shown_value)

qualTests = subset(qualTests, select = c("pid","quantity_id", "lab_id", "system", "component","unit", "ref_lower", "ref_upper", "value", "date","time",
                                         "database", "component_db", "component_simple_lookup", "clean_quantity_id", "unit_clean", "system_clean", "value_clean", "ref_lower_clean", "ref_upper_clean", "rule" ))

quant_data= fread('dummy_QuantitativeData_noInterval.tsv', colClasses= 'character')##pull qualitative data from other dataset
quant_data= subset(quant_data, quant_data$rule== 'qual')

flagged_data= fread('dummy_flagged_data.tsv', colClasses= 'character')
flagged_data= subset(flagged_data, flagged_data$rule== 'qual') ##pull qualitative data from other dataset

#add empty columns for easy merging with other files
qualTests$interval_type='NA'
qualTests$FLAG= 'NA'

qualTests= rbind(qualTests, quant_data)
qualTests= rbind(qualTests, flagged_data)

qualTests = subset(qualTests, select = c("pid","quantity_id", "lab_id", "system", "component","unit", "ref_lower", "ref_upper", "value", "date","time",
                                         "database", "component_db", "component_simple_lookup", "clean_quantity_id", "unit_clean", "system_clean", "value_clean", "ref_lower_clean", "ref_upper_clean", "interval_type", "FLAG" ))

setwd("~/Desktop/Protocol_work/data_cleaning/output_data")
write.table(qualTests, file='dummy_cleaned_allQualitativeData.tsv', quote=FALSE, sep='\t', row.names=FALSE)

