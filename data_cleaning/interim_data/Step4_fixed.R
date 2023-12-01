##### step 4 of lab cleaning script for the dummy data set
#######last edited December 1st, 2023 for Protocol paper
##by Victorine Muse

####this is the 4th script to run for cleaning lab data
####this is mainly used to flag normal vs abnormal data using a 0/1 system (for keep data only)

library( data.table)

#load reference tables for use
setwd("~/Desktop/Protocol_work/data_cleaning/raw_data")
shownValueTable= fread('dummy_shown_list.tsv', colClasses= 'character')

#set working directory to save intermediate files
setwd("~/Desktop/Protocol_work/data_cleaning/interim_data")
measurements= fread('dummy_nonquantData.tsv', colClasses= 'character')

#look at only data in the 'keep' category, not in the dummy data but structure for cleaning is here
keepList= subset(shownValueTable, shownValueTable$action=='keep')
keepTests= subset(measurements, measurements$value %in% keepList$shown_value)

#manual fixes to clean data
keepTests$value_clean = gsub ('8..3','8.3',keepTests$value_clean)
keepTests$value_clean = gsub ('6..48','6.48',keepTests$value_clean)
keepTests$value_clean = gsub ('8..14','8.14',keepTests$value_clean)


keepTests$value_clean= as.numeric(keepTests$value_clean)

useDATA=keepTests
rm(keepTests)

#clean reference intervals
useDATA$ref_upper_clean[which(useDATA$ref_upper_clean=='')]=NA
useDATA$ref_lower_clean[which(useDATA$ref_lower_clean=='')]=NA
useDATA$ref_lower_clean[which(useDATA$ref_lower_clean==0 & useDATA$ref_upper_clean==0)]=NA
useDATA$ref_upper_clean[which(useDATA$ref_upper_clean==0)]=NA

reviewData=subset(useDATA, (is.na(useDATA$ref_lower_clean)) & (is.na(useDATA$ref_upper_clean)))
reviewData$interval_type= 'none'

#seperate data that doesn't have a reference interval
write.table(reviewData, file='dummy_KeepData_noInterval.tsv', quote=FALSE, sep='\t', row.names=FALSE)

useDATA= subset(useDATA, !(is.na(useDATA$ref_lower_clean))| !(is.na(useDATA$ref_upper_clean)))

#clean upper and lower reference columns
useDATA$ref_upper_clean= gsub('<','',useDATA$ref_upper_clean)
useDATA$ref_lower_clean= gsub('>','',useDATA$ref_lower_clean)
useDATA$ref_upper_clean= gsub('=','',useDATA$ref_upper_clean)

######## copy flagging from quant data script

useDATA$ref_lower_clean=as.numeric(useDATA$ref_lower_clean)
useDATA$ref_upper_clean=as.numeric(useDATA$ref_upper_clean)


useDATA$interval_type='interval'

useDATA$interval_type[which(is.na(useDATA$ref_lower_clean))]='Upper_Limit'
useDATA$ref_lower_clean[which(is.na(useDATA$ref_lower_clean))]=0

useDATA$interval_type[which(is.na(useDATA$ref_upper_clean))]='Lower_Limit'
useDATA$ref_upper_clean[which(is.na(useDATA$ref_upper_clean))]=100000

miniData= subset(useDATA,select= c('value_clean','ref_lower_clean','ref_upper_clean'))


miniData$value_clean=as.numeric(miniData$value_clean)

len=length(miniData$value_clean)

FLAG=array()

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

useDATA$FLAG=FLAG

#write flagged keep data column
write.table(useDATA, file='dummy_KeepData_flagged.tsv', quote=FALSE, sep='\t', row.names=FALSE)

#check data that wasnt processed
idxkeep=which(is.na(useDATA$FLAG))
useDATA=subset(useDATA[idxkeep])

#should be empty if script work 
write.table(useDATA, file='dummy_Keepdata_flaggedNANonQuant_check.tsv', quote=FALSE, sep='\t', row.names=FALSE)

rm(useDATA)

