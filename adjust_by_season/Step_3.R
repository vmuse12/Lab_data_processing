### this script is intended for generic protocol use only and makes use of a dummy data set -- last updated December 1st, 2023
### by Victorine Muse

##this step takes in one of the interim data sets from step 2 and fits the data seasonally by week-year (can be changed to month-year) 

library(minpack.lm)
library(data.table)
library(ggplot2)
#library(nlstools)

setwd("~/Desktop/Lab_data_processing/adjust_by_season/interim_files")

##this is an example of one of the research questions, can be modified for mortality tests or other

data= fread('all_tests_together.tsv')

#use if subsetting to 2012-2015 inclusive
data= subset(data, data$date_only >= '2012-01')
data=subset(data, data$date_only <'2016-01')

labData= data ###save full version for reference

labData$week= substr(labData$date_only, nchar(labData$date_only)-1, nchar(labData$date_only))
labData$week= as.numeric(labData$week)
labData= subset(labData, labData$week <53) #remove random 53 week years, not conistent 

labLengths= fread('week_lengths_all_together.tsv')
labLengths$week= substr(labLengths$date_only, nchar(labLengths$date_only)-1, nchar(labLengths$date_only))
labLengths$week= as.numeric(labLengths$week)
labLengths= subset(labLengths, labLengths$week < 53) #remove incomplete week 53

#use if subsetting to 2012-2015 inclusive
labLengths = subset(labLengths, labLengths$date_only >= '2012-01')
labLengths =subset(labLengths, labLengths$date_only <'2016-01')

labLengths_check= labLengths[,2:length(colnames(labLengths))]

lab_cts= labLengths

for (i in 2:length(colnames(labData))-1){
  for (j in 1:length(rownames(labData))){
    
    if (labLengths[j, ..i]<50){ ###this is a choice of threhold based on your data set, ie at least 50 unique tests per week required to be included
      labData[j, i]= NA
    }
  }
}

labLengths= melt(labLengths_check, id= 'week')

labLengths$value[which(labLengths$value <50)]=0
#labLengths$value= as.numeric(labLengths$value)
require(reshape2)

#### a weight function was defined that distributes weight based on # of tests. This is important to remove bias from holidays or summer where only really sick patients are examined
lab_len_wts= as.data.frame(xtabs(value ~ week + variable, data= labLengths))

lab_len_wts= dcast(lab_len_wts, week~variable, value.var= 'Freq')
labLengths = dcast(labLengths, week~variable, value.variable= 'value', fun= mean)

sums= colSums(lab_len_wts[2:length(colnames(lab_len_wts))])

for (i in 2:length(colnames(lab_len_wts))){
  
  labLengths_check[,i-1]=labLengths_check[,..i-1]/sums[[i-1]]
}

labData_check= labData[,2:length(colnames(labData))]

subcheck= melt(labData_check, id= 'week')
subcheck= subcheck[complete.cases(subcheck),]
subcheck = dcast(subcheck, week~variable, drop = F, value.variable= 'value', fun= mean)

pdf("Print_boxes_together_2012_2015.pdf") #open a pdf document for predicted value printing, if desired 

time= seq(1,52)

labData= labData

##here we define the chosen low parameter cosine function, you can try others or change "52" to "12" to model by month instead
f= function(A,x,offset, height){
  A*cos(2*pi*(x-offset)/52) + height
}


length=length(colnames(subcheck))

plot_stats= data.frame(matrix(ncol = 7, nrow = length(colnames(labData))-2))
colnames(plot_stats)= c('test','Amplitude','A_pval', 'offset', 'offset_pval', "height", 'h_pval')

for (i in 2:length){
  
  
  if (sum(is.na(labData[,..i]))<100){ ###make sure ~50% of weeks have data to avoid possible convergence 
    value= labData[,..i]
    
    j = length(colnames(labData))
    
    l= labLengths[,i]
    y= labData[,..i]
    x= labData$week
    
    test_name= colnames(y)
    
    df <- data.frame(x,y)
    
    y=as.data.frame(y)
    
    idx=!(is.na(y[,1]))
    
    if(sd(y[idx,1])!= 0){
      df <- data.frame(x,y)
      colnames(df)= c('x','y')
            
      wts= labLengths_check[,..i-1]

      ##here we use the nonlinear least squares model for optimizing the funtion to fit the data. Other optimization models could be used but this was chosen as we could control the limits of the parameter fits to feasible values. 
      # access the fitted series (for plotting)
      fit_all = nls(y ~f(A, x, offset, height), data= df, start = list(A=.01, offset= 23, height= .01), control = list(maxiter = 50000, minFactor=1/2000, warnOnly=T), algorithm = "port", weights= unlist(wts), lower= c(-1,0,-1), upper= c(1,52,1))
            
      # find predictions for original time series
      pred_all <- predict(fit_all, newdata=data.frame(Time=time)) ##this data can be saved iteratively if desired, or else calculated again with fitted parameters
            
      fits= coef(summary(fit_all))

      #selected paramters saved, additional statistical parameters can be retrieved at this step as needed/ desired 
      plot_stats$test[i-1]= colnames(labData)[i]
      plot_stats$Amplitude[i-1]= fits[1,1]
      plot_stats$A_pval[i-1]= fits[1,4]
      plot_stats$offset[i-1]= fits[2,1]
      plot_stats$offset_pval[i-1]= fits[2,4] 
      plot_stats$height[i-1]= fits[3,1]
      plot_stats$h_pval[i-1]= fits[3,4]
  
  value= subcheck[,i]
  week= as.numeric(as.character(subcheck$week))
  df <- data.frame(week,value,l)
  
  colnames(df)= c('week', 'value', 'l')
  test_name= colnames(subcheck)[i]
    
  p= ggplot(data= df, aes(x= week, y = value)) + geom_bar(stat='identity',aes(fill=df$l)) + ggtitle(test_name) +geom_line(aes(x=c(1:52), y = pred_all[1:52]), col = 'blue')
  print(p) #print predicted values for later data exploration
  
}}}

dev.off()

plot_stats= plot_stats[complete.cases(plot_stats),]

plot_stats$A_pval= p.adjust(plot_stats$A_pval, method= 'fdr') #if multiple test correcting, method can be altered
plot_stats$offset_pval= p.adjust(plot_stats$offset_pval, method= 'fdr')
plot_stats$h_pval= p.adjust(plot_stats$h_pval, method= 'fdr')

plot_stats$sig= 'no' #give easy label for filtering for seasonality later , here just looking at Amplitude and offset as a starting point
plot_stats$sig[which(plot_stats$A_pval<0.05)]='yes' #can vary on what parameter(s) you care about 
plot_stats$sig[which(plot_stats$offset_pval<0.05)]='yes' #can vary on what parameter(s) you care about 

#save full data table of  parameter fits for further analysis
write.table(plot_stats, file='all_stats_together_2012_2015.tsv', quote=FALSE, sep='\t', row.names=FALSE)

