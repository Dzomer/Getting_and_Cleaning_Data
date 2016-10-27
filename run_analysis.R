if (!getwd() == "./accelerometers_data") {
  dir.create("./accelerometers_data")
}

setwd("./accelerometers_data")

library(plyr) 
library(data.table) 
library(dplyr)

## Task #1: Merges the training and the test sets to create one data set

##get the zip file
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip","accelorometer_data.zip")

##Unzip and save as table the test and train data
y_test <- read.table(unzip("accelorometer_data.zip", "UCI HAR Dataset/test/y_test.txt"))
x_test <- read.table(unzip("accelorometer_data.zip", "UCI HAR Dataset/test/X_test.txt"))
subject_test <- read.table(unzip("accelorometer_data.zip", "UCI HAR Dataset/test/subject_test.txt"))
y_train <- read.table(unzip("accelorometer_data.zip", "UCI HAR Dataset/train/y_train.txt"))
x_train <- read.table(unzip("accelorometer_data.zip", "UCI HAR Dataset/train/X_train.txt"))
subject_train <- read.table(unzip("accelorometer_data.zip", "UCI HAR Dataset/train/subject_train.txt"))

##column names
features <- read.table(unzip("accelorometer_data.zip", "UCI HAR Dataset/features.txt"))

##activity descriptions
activities <- read.table(unzip("accelorometer_data.zip", "UCI HAR Dataset/activity_labels.txt"))

##add column names to test and train data
colnames(x_train) <- t(features[2])
colnames(x_test) <- t(features[2])

## add training and test activity to X_train and x_test from y_train and y_test
x_train$activity<-y_train[, 1]
x_test$activity<-y_test[, 1]

## add subject who performed the activity
x_train$subject<-subject_train[, 1]
x_test$subject<-subject_test[, 1]

##Merges the training and the test sets to create one data set.
merged<-rbind(x_train,x_test)

## Task #2: Extracts only the measurements on the mean and standard deviation for each measurement.
mean<-grep("mean()",names(merged))
mean_measurements<-merged[mean]

std<-grep("std()",names(merged))
std_measurements<-merged[std]

##Task #3: Uses descriptive activity names to name the activities in the data set
##  check activity names
activities

##  Replace activity with activity names
merged$activity[merged$activity == 1] <- "WALKING"
merged$activity[merged$activity == 2] <- "WALKING_UPSTAIRS"
merged$activity[merged$activity == 3] <- "WALKING_DOWNSTAIRS"
merged$activity[merged$activity == 4] <- "SITTING"
merged$activity[merged$activity == 5] <- "STANDING"
merged$activity[merged$activity == 6] <- "LAYING"

##Task #4:Appropriately activity the data set with descriptive variable names
names(merged)<-gsub("^t","time",names(merged))
names(merged)<-gsub("^f","frequency",names(merged))
names(merged)<-gsub("Acc","Accelerometer",names(merged))
names(merged)<-gsub("Gyro","Gyroscope",names(merged))
names(merged)<-gsub("Mag","Magnitude",names(merged))

##Task #5: From the data set in step 4, creates a second, independent tidy data set with the average of each variable
##for each activity and each subject.
datatable_merged <- data.table(merged)
tidy_data<-datatable_merged[, lapply(.SD, mean), by = 'subject,activity']
write.table(tidy_data,file="tidy_data.txt", row.names = FALSE)
