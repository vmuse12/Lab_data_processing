##### step 1 of lab cleaning script for the dummy data set
#### by Victorine Muse, last updated December 1st, 2023

library(data.table)
library(dplyr)

##load relevant lookup tables (NPU lookup, shown value lookup, unit fix lookup)
# set directory (hidden) 

setwd("~/Desktop/Lab_data_processing/data_cleaning/raw_data")
NPUlookup= fread('dummy_test_lookup.tsv', colClasses= 'character') #example of tests that could exist
shownValueTable= fread('dummy_shown_list.tsv', colClasses= 'character') #this a list of text responses and actions
UnitFix= fread('dummy_unit_lookup.tsv', colClasses= 'character') #this table is exhaustive of possible options seen in the real data
pidLookup= fread('dummy_tpers_data.tsv', colClasses = 'character') #this table is an example of what the person registry information could look up, including DOB, DOD and other last known status information

##load dummy lab data
setwd("~/Desktop/Lab_data_processing/data_cleaning/interim_data")
measurements= fread('filtered_dummy_data.tsv', colClasses= 'character')
measurements= subset(measurements, measurements$pid %in% pidLookup$pid) #### remove temp PIDs

##set output directory for temporary cleaning files

####the following are various step implemented to clean data, likely specific to our data but can inspire steps needed for other research projects
measurements= subset(measurements, measurements$quantity_id!='' ) #remove empty quantity_id fields

measurements= subset(measurements, !(measurements$value=='')) #remove if value columns empty
measurements= inner_join(measurements, NPUlookup, by = 'quantity_id' ) #merge NPU lookup information and remove nonusable tests (research codes or other irrelevant tests based on labterm.dk)

measurements= left_join(measurements, UnitFix, by = 'unit' ) #fix units 
measurements$value_clean=measurements$value #copy over values for cleaning
measurements$ref_upper_clean=measurements$ref_upper #copy over upper limit for cleaning
measurements$ref_lower_clean=measurements$ref_lower #copy over lower limit for cleaning
###note: cleaned shown, upper, and lower limits were created to allow users to check 'dirty' data when 'clean' data seems to have mistakes

##clean 'value_clean' column data to allow for numeric processing, these arent present in the dummy data but can exist
measurements$value_clean= gsub('=','',measurements$value_clean)
measurements$value_clean= gsub('<','',measurements$value_clean)
measurements$value_clean= gsub('>','',measurements$value_clean)
measurements$value_clean= gsub(',','.',measurements$value_clean)

#save subset of data with numeric responses
QuantData= subset(measurements, !(measurements$value %in% shownValueTable$shown_value))
write.table(QuantData, file='dummy_quantData.tsv', quote=FALSE, sep='\t', row.names=FALSE)

#save subset of data with non-numeric responses
nonQuantData= subset(measurements, (measurements$value %in% shownValueTable$shown_value))
write.table(nonQuantData, file='dummy_nonquantData.tsv', quote=FALSE, sep='\t', row.names=FALSE)

