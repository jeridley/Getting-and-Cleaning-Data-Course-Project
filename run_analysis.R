library(plyr)
library(data.table)


fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipfile <- "getdata-projectfiles-UCI HAR Dataset.zip"
destDir <- "UCI HAR Dataset"

if (!file.exists(destDir)) {
  if(!file.exists(zipfile)) {
    download.file(fileURL, destfile=zipfile)
  }
  unzip(zipfile)
}

setwd("./UCI HAR Dataset")

#merge the data
sub_Train = read.table('./train/subject_train.txt',header=FALSE)
x_Train = read.table('./train/x_train.txt',header=FALSE)
y_Train = read.table('./train/y_train.txt',header=FALSE)

sub_Test = read.table('./test/subject_test.txt',header=FALSE)
x_Test = read.table('./test/x_test.txt',header=FALSE)
y_Test = read.table('./test/y_test.txt',header=FALSE)

x_Data <- rbind(x_Train, x_Test)
y_Data <- rbind(y_Train, y_Test)
sub_Data <- rbind(sub_Train, sub_Test)

#extract mean and std deviation
x_Data_mean_std <- x_Data[, grep("-(mean|std)\\(\\)", read.table("features.txt")[, 2])]
names(x_Data_mean_std) <- read.table("features.txt")[grep("-(mean|std)\\(\\)", read.table("features.txt")[, 2]), 2] 
View(x_Data_mean_std)

#Set the activy names
y_Data[, 1] <- read.table("activity_labels.txt")[y_Data[, 1], 2]
names(y_Data) <- "Activity"
View(y_Data)

#label the variables
names(sub_Data) <- "Subject"
summary(sub_Data)

# Organizing and combining all data sets into single one.

combined_Data <- cbind(x_Data_mean_std, y_Data, sub_Data)

# Defining descriptive names for all variables.

names(combined_Data) <- make.names(names(combined_Data))
names(combined_Data) <- gsub('Acc',"Acceleration",names(combined_Data))
names(combined_Data) <- gsub('GyroJerk',"AngularAcceleration",names(combined_Data))
names(combined_Data) <- gsub('Gyro',"AngularSpeed",names(combined_Data))
names(combined_Data) <- gsub('Mag',"Magnitude",names(combined_Data))
names(combined_Data) <- gsub('^t',"TimeDomain.",names(combined_Data))
names(combined_Data) <- gsub('^f',"FrequencyDomain.",names(combined_Data))
names(combined_Data) <- gsub('\\.mean',".Mean",names(combined_Data))
names(combined_Data) <- gsub('\\.std',".StandardDeviation",names(combined_Data))
names(combined_Data) <- gsub('Freq\\.',"Frequency.",names(combined_Data))
names(combined_Data) <- gsub('Freq$',"Frequency",names(combined_Data))

View(combined_Data)

#create the tidy data and save
tidy_Data<-aggregate(. ~Subject + Activity, combined_Data, mean)
tidy_Data<-tidy_Data[order(tidy_Data$Subject,tidy_Data$Activity),]
write.table(tidy_Data, file = "CourseProjectTidyData.txt",row.name=FALSE)
