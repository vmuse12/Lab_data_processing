##### step 2 of lab cleaning script for the dummy data set
#######last edited December 1st, 2023 for Protocol paper
##by Victorine Muse

library(data.table)

setwd("~/Desktop/Lab_data_processing/data_cleaning/interim_data")
useDATA= fread('dummy_quantData.tsv', colClasses= 'character')

###edit clean columns for numeric manipulation
useDATA$ref_upper_clean= gsub('<','',useDATA$ref_upper_clean)
useDATA$ref_lower_clean= gsub('>','',useDATA$ref_lower_clean)
useDATA$ref_upper_clean= gsub('=','',useDATA$ref_upper_clean)
useDATA$ref_upper_clean[which(useDATA$ref_upper_clean=='')]=NA
useDATA$ref_lower_clean[which(useDATA$ref_lower_clean=='')]=NA
useDATA$ref_lower_clean=as.numeric(useDATA$ref_lower_clean)
useDATA$ref_upper_clean=as.numeric(useDATA$ref_upper_clean)

#separate data between interval and non_interval data
reviewData=useDATA
reviewData=subset(reviewData, (is.na(useDATA$ref_lower_clean)) & (is.na(useDATA$ref_upper_clean)))
reviewData$interval_type='none' #define data as having no reference values
write.table(reviewData, file='dummy_quantData_noInt.tsv', quote=FALSE, sep='\t', row.names=FALSE)

useDATA= subset(useDATA, !(is.na(useDATA$ref_lower_clean))| !(is.na(useDATA$ref_upper_clean)))
rm(reviewData)

useDATA$interval_type='interval' #define data as having a refence range

#modify interval type for those with only upper or lower limits
useDATA$interval_type[which(is.na(useDATA$ref_lower_clean))]='Upper_Limit'
useDATA$ref_lower_clean[which(is.na(useDATA$ref_lower_clean))]=0
useDATA$interval_type[which(is.na(useDATA$ref_upper_clean))]='Lower_Limit'
useDATA$ref_upper_clean[which(is.na(useDATA$ref_upper_clean))]=100000
useDATA$value_clean= as.numeric(useDATA$value_clean)
useDATA$value_clean= abs(useDATA$value_clean) #correct for negative values

####define some text responses that were not caught in earlier phases
#####these are abnormal, qualified by being abnormal or normal lab results
abListAbove=c('positive','##','hhh', 'dilute')
normList=c('norm','neg','negativ','target not detected' )

#take a subset of data for faster interval computation
miniData= subset(useDATA,select= c('value_clean','ref_lower_clean','ref_upper_clean'))
miniData$value_clean=as.numeric(miniData$value_clean)
len=length(miniData$value_clean)
FLAG=array() #column for indicating normal/ abnormal data

#flag columns  according to reference ranges
for (i in 1:len){
  if(!is.na(miniData$value_clean[i])){
    if ( miniData$value_clean[i]>= miniData$ref_lower_clean[i] & miniData$value_clean[i]<= miniData$ref_upper_clean[i]){
      FLAG[i] = 0}
    if ( miniData$value_clean[i]<miniData$ref_lower_clean[i]){
      FLAG[i] =-1}
    if ( miniData$value_clean[i]>miniData$ref_upper_clean[i]){
      FLAG[i] =1}
    else{}
  }
  else{FLAG[i]=NaN}
  }

rm(miniData)

#save flag column to full dataframe
useDATA$FLAG=FLAG

#save the flagged quantitative data
write.table(useDATA, file='dummy_QuantData_flagged.tsv', quote=FALSE, sep='\t', row.names=FALSE)

#check to see if all data accounted for, file should be empty if it worked
idxkeep=which(is.na(useDATA$FLAG))
useDATA=subset(useDATA[idxkeep])
write.table(useDATA, file='dummy_data_flaggedNA.tsv', quote=FALSE, sep='\t', row.names=FALSE)
