### this script is intended for generic protocol use only and requires specification to the users input data -- December 1st, 2023
### by Victorine Muse
##source/ directory read-in info hidden for privacy/security concerns 

#this step preprocessing all test data into different interim data sets for research questions (sex/ age/ mortality). Only the basic one showed here but can be altered for others. 

library(data.table)
library(dplyr)


###### fit data all together 
setwd("~/Desktop/Lab_data_processing/adjust_by_season/interim_files")
labDataFULL= fread('all_tests_data.tsv')

labData= labDataFULL
labData$date_only= format(as.POSIXct(strptime(labData$date,"%Y-%m-%d",tz="")) ,format = "%Y-%V") 
labData$year_only= format(as.POSIXct(strptime(labData$date,"%Y-%m-%d",tz="")) ,format = "%Y") 

labData_median= dcast(date_only ~ test,data= labData, drop =FALSE, value.var= 'normal', fun.aggregate= median)
labData_length= dcast(date_only ~ test,data= labData,  value.var= 'normal', fun.aggregate= length)

write.table(labData_median, file='all_tests_together.tsv', quote=FALSE, sep='\t', row.names=FALSE)
write.table(labData_length, file='week_lengths_all_together.tsv', quote=FALSE, sep='\t', row.names=FALSE)
