### this script is intended for generic protocol use only and requires specification to the users input data -- last updated October 9th, 2023
### by Victorine Muse
##source/ directory read-in info hidden for privacy/security concerns 
### this step calculates new reference intervals and new flagging data 

library(ggplot2)
library(data.table)
library(dplyr)

labData= fread('sig_tests_w_stats.tsv')

labData$date_only= format(as.POSIXct(strptime(labData$date,"%Y-%m-%d",tz="")) ,format = "%Y-%V") 

labData$week= substr(labData$date_only, nchar(labData$date_only)-1, nchar(labData$date_only))
labData$week= as.numeric(labData$week)
labData= subset(labData, labData$week < 53)

#reference formula for this case
#A*cos(2*pi*(x-offset)/52) + height

###calculate new reference intervals using parameter input from forula (+1 to reset base value from 0 to 1)
labData$new_upper= labData$ref_upper*(labData$Amplitude*cos(2*pi*(labData$week-labData$offset)/52)+labData$height+1)
labData$new_lower= labData$ref_lower*(labData$Amplitude*cos(2*pi*(labData$week-labData$offset)/52)+labData$height+1)

#save a version of new reference data
write.table(labData, file='labData_new_refs.tsv', quote=FALSE, sep='\t', row.names=FALSE)

useDATA= labData 

rm(labData)
#take a subset of data for faster interval computation
miniData= subset(useDATA,select= c('value','new_lower','new_upper'))
miniData$value=as.numeric(miniData$value)
len=length(miniData$value)
FLAG2=array() #column for indicating normal/ abnormal data

#flag columns  according to reference ranges
for (i in 1:len){
  if(!is.na(miniData$value[i])){
    if ( miniData$value[i]>= miniData$new_lower[i] & miniData$value[i]<= miniData$new_upper[i]){
      FLAG2[i] = 0}
    if ( miniData$value[i]<miniData$new_lower[i]){
      FLAG2[i] =-1}
    if ( miniData$value[i]>miniData$new_upper[i]){
      FLAG2[i] =1}
    else{}
  }
  else{FLAG2[i]=NaN}
}

rm(miniData)

#save flag column to full dataframe
useDATA$FLAG2=FLAG2

#save new flagging data 
write.table(useDATA, file='labData_new_flags.tsv', quote=FALSE, sep='\t', row.names=FALSE)

