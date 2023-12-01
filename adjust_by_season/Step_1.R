### this script is intended for generic use with a summy dataset, last updated Decemer 1st, 2023. 
### by Victorine Muse
##source/ directory read-in info hidden for privacy/security concerns 
##for data cleaning process see lab_data_cleaning folder

library(ggplot2)
library(data.table)
library(stringr)
library(dplyr)


setwd("~/Desktop/Lab_data_processing/data_cleaning/output_data")
labData= fread('dummy_cleaned_simple_version.tsv', colClasses = 'character')
labData$test= paste0(labData$component_simple_lookup, '-', labData$system_clean)
labData$age= (as.Date(labData$date)- as.Date(labData$DOB))/365
labData$age= as.numeric(labData$age)

labData= subset(labData, select = c('pid', 'sex', 'age', 'DOB', 'test', 'date', 'lab_id', 'unit_clean', 'value_clean', 'ref_lower_clean', 'ref_upper_clean'))
colnames(labData)=  c('pid', 'sex', 'age', 'DOB', 'test', 'date', 'lab_id', 'unit', 'value', 'ref_lower', 'ref_upper')

## pull all laboratory tests from cleaned data set
##labData= dataframe of all complete quantitative laboratory data for input, including the following columns:
##please note column labels were simplified now for ease of use

#pid: unique patient identifier
#sex: patient's sex
#age: age calculated in years
#DOB: patient's date of birth
#test: unique test (component_simple_lookup - system_clean from data processing step)
#date: date test was drawn from patient (time not needed for this protocol)
#lab_id: lab where test was processed
#unit: unit test was measured in 
#value: test value reported
#ref_lower: lower reported reference interval, if available
#ref_upper: upper reported reference interval, if available

#define age groups- split patients into age groups for strata specification, you can choose any interval but 10 year groups was chosen here

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
labData= subset(labData, labData$age_group != 11) ##remove people over 100, likely not enough data 

#### if pid has more than one of the same test per day, take mean value (this can be altered for max/ min, etc)
labData$group= paste(labData$pid, labData$test,labData$date, labData$unit)
labData$value= as.numeric(labData$value)
labData=subset(labData, !(is.na(labData$value)))### remove non numeric data as we cannot do seasonality assessment on this
labData_means= subset(labData, select= c('group','value'))
labData_means= aggregate(labData_means, by= list(labData_means$group), FUN= mean, drop = TRUE)

colnames(labData_means)= c('group','remove','value')
labData_means= subset(labData_means, select = c('group','value')) ##retain value for each unique pid/test/date/unit combo

#depending on cohort size this step can be too big, and therefore merging using a loop may be needed
labData= inner_join(labData,labData_means, by = 'group')
labData=subset(labData, select = c('pid', 'test','date', 'group', 'lab_id','unit', 'sex', 'age_group', 'value.y'))
colnames(labData) = c('pid', 'test','date', 'group', 'lab_id','unit', 'sex', 'age_group', 'value')##copy over daily mean value for each patient
labData= unique.data.frame(labData) #remove any duplicate entries

##rm large df from memory (no longer needed)
rm(labData_means)

##find median component value by age/sex/unit/lab_id, reuse group label
labData$group= paste(labData$test, labData$lab_id, labData$sex, labData$unit_clean, labData$age_group)
labData_sub= subset(labData, select= c('group','value'))
labData_median= aggregate(labData_sub, by= list(labData_sub$group), FUN= median, drop = TRUE)

#find numbers of tests available per unique group
labData_length= aggregate(labData_sub, by= list(labData_sub$group), FUN= length, drop = TRUE)
setwd("~/Desktop/Lab_data_processing/adjust_by_season/interim_files")
write.table(labData_length, file='lengths_of_stratas_test.tsv', quote=FALSE, sep='\t', row.names=FALSE)

# min 100 patients per strata, this can be changed based on your cohort size
labData_minStrats= subset(labData_length, labData_length$group >=100) 
labData= subset(labData, labData$group %in% labData_minStrats$Group.1)

##join data back to full dataframe
colnames(labData_median)= c('group','remove','median')
labData_median= subset(labData_median, select = c('group','median'))

labData= left_join(labData, labData_median, by = 'group')

##calculate value normalized to the median, centered to 0 here to allow for better wave functions (can be changed)
labData$normal= (labData$value -labData$median)/labData$median

counts= as.data.frame(table(labData$test))
counts= counts[order(-counts$Freq),]

write.table(counts, file='counts.tsv', quote=FALSE, sep='\t', row.names=FALSE) ## save numbers of each test for later steps

#make sure theres at least 1000 unique pid/date combinations- this can be changed base on cohort size, this just helps speed up fitting and limiting protocol to robust dataset sizes
counts= subset(counts, counts$Freq >=1000)
labData= subset(labData, labData$test %in% counts$Var1)

write.table(labData, file='all_tests_data.tsv', quote=FALSE, sep='\t', row.names=FALSE) ###this file is used as input for Step 2
