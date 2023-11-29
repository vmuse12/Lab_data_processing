##### step 8 of lab cleaning script for the dummy data set
#### by Victorine Muse, last updated November 24th, 2023 for public use


### combine flagged and quantitative files, add DOB, sex
###also save "light" version of cleaned dataset


setwd("~/Desktop/Protocol_work/interim_data")

library(data.table)
library(plyr)
library(lubridate)

quant_only= fread('dummy_QuantitativeData_noInterval.tsv', colClasses= 'character')
flagged_only= fread('dummy_flagged_data.tsv', colClasses= 'character')

measurements = rbind(flagged_only, quant_only)
rm(flagged_only)
rm(quant_only)

measurements= subset(measurements, measurements$rule== 'quant')###remove qualitative tests (moved to qualitative dataset)

###add DOB and Sex
setwd("~/Desktop/Protocol_work/raw_data")
ID_lookup= fread('dummy_tpers_data.tsv', colClasses = 'character')

cleaned_data  = merge (measurements , ID_lookup, by = 'pid', all.x= TRUE, all.y= FALSE)

####fix time zones (so all are in local time)
cleaned_data$date_time= paste(cleaned_data$date, cleaned_data$time)
cleaned_data$date_time= as.POSIXct(cleaned_data$date_time, tz = "UTC")
cleaned_data$date_time= with_tz(cleaned_data$date_time, tzone = "Europe/Copenhagen")
cleaned_data$time= format(as.POSIXct(strptime(cleaned_data$date_time,"%Y-%m-%d %H:%M:%S",tz="")) ,format = "%H:%M:%S") 
cleaned_data$date= format(as.POSIXct(strptime(cleaned_data$date_time,"%Y-%m-%d %H:%M:%S",tz="")) ,format = "%Y-%m-%d") 
cleaned_data= subset(cleaned_data, select = -c(length(colnames(cleaned_data))))
cleaned_data= subset(cleaned_data, cleaned_data$date< '2016-07-01')

###save file
setwd("~/Desktop/Protocol_work/output_data")
write.table(cleaned_data, file='dummy_cleaned_allQuantitative_and_Binary.tsv', quote=FALSE, sep='\t', row.names=FALSE)

##make a small more user friendly database for more functionality when desired
cleaned_data = subset(cleaned_data, select = c('pid', 'sex','DOB', 'lab_id','date', 'time', 'database', 
                                               'component_simple_lookup','clean_quantity_id','unit_clean','system_clean', 'value_clean', 'ref_lower_clean',
                                               'ref_upper_clean','interval_type','FLAG'))

write.table(cleaned_data , file='dummy_cleaned_simple_version.tsv', quote=FALSE, sep='\t', row.names=FALSE)


