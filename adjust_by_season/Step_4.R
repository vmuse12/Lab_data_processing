### this script is intended for generic protocol use only and requires specification to the users input data -- last updated October 9th, 2023
### by Victorine Muse
##source/ directory read-in info hidden for privacy/security concerns 

##this step takes the original lab test data and merges it with seasonality results (only for those with significant amplitude seasonality detected) 


### this script prints out several forecast models for lab test data
library(ggplot2)
library(data.table)
library(dplyr)

## pull all laboratory tests and select for pids with known DOD info
##labData= dataframe of all complete quantitative laboratory data for input:
setwd("~/Desktop/Protocol_work/data_cleaning/output_data")
labData= fread('dummy_cleaned_simple_version.tsv', colClasses = 'character')
labData$test= paste0(labData$component_simple_lookup, '-', labData$system_clean)
labData$age= (as.Date(labData$date)- as.Date(labData$DOB))/365
labData$age= as.numeric(labData$age)

labData= subset(labData, select = c('pid', 'sex', 'age', 'DOB', 'test', 'date', 'lab_id', 'unit_clean', 'value_clean', 'ref_lower_clean', 'ref_upper_clean', 'FLAG'))
colnames(labData)=  c('pid', 'sex', 'age', 'DOB', 'test', 'date', 'lab_id', 'unit', 'value', 'ref_lower', 'ref_upper', 'FLAG')

labData$age_group= 1

labData$age_group[which(labData$age>=10 & labData$age<20)]=2
labData$age_group[which(labData$age>=20 & labData$age<30)]=3
labData$age_group[which(labData$age>=30 & labData$age<40)]=4
labData$age_group[which(labData$age>=40 & labData$age<50)]=5
labData$age_group[which(labData$age>=50 & labData$age<60)]=6
labData$age_group[which(labData$age>=60 & labData$age<70)]=7
labData$age_group[which(labData$age>=70 & labData$age<80)]=8
labData$age_group[which(labData$age>=80 & labData$age<90)]=9
labData$age_group[which(labData$age>=90 & labData$age<100)]=10

labData$age_group[which(labData$age>=100)]=11
labData= subset(labData, labData$age_group != 11) ##remove people over 100, not enough data
labData= subset(labData, labData$age_group > 2) ##Here focusing on patients over 20, to avoid puberty influence

labData= subset(labData, select= c('pid', 'value', 'test','ref_lower', 'ref_upper','FLAG', 'sex', 'age_group', 'date', 'unit'))

labData= subset(labData, labData$date >= '2012-01-01') #filter for relevant data to this study
labData=subset( labData, labData$date < '2016-01-01')

setwd("~/Desktop/Protocol_work/adjust_by_season/interim_files")
stats= fread('all_stats_together_2012_2015.tsv') ##here for the all strats research question 
stats= subset(stats, stats$sig== 'yes')

labData= subset(labData, labData$test %in% stats$test)
labData= inner_join(labData, stats, by=c('test'))

#print data set with predicted values for the respective strata
write.table(labData, file='sig_tests_w_stats.tsv', quote=FALSE, sep='\t', row.names=FALSE)

