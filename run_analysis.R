install.packages("reshape2")
library("reshape2")

#Download base dataset, place in working directory and unzip files
working_dir <- getwd()
basedata_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if (!file.exists(file.path(working_dir, "basedata.zip"))) {
  download.file(basedata_url, file.path(working_dir, "basedata.zip"))
  unzip("basedata.zip")
}

#Load test datasets
#Create a data frame for the subjects
testdatadt_subjects <- read.table(file.path(working_dir, "UCI HAR Dataset\\test\\subject_test.txt") , header = TRUE)
colnames(testdatadt_subjects)[1] <- "Subject_ID"

#Create a data frame for the activities
testdatadt_activities <- read.table(file.path(working_dir, "UCI HAR Dataset\\test\\y_test.txt"), header = TRUE)
colnames(testdatadt_activities)[1] <- "Activity"
activity_list <- read.table(file.path(working_dir, "UCI HAR Dataset\\activity_labels.txt"), header = FALSE)

#Assign the activity labels
for (i in 1 : nrow(activity_list)) {
  testdatadt_activities[testdatadt_activities[, 1] == as.numeric(activity_list[[i,1]]), ] <- as.character(activity_list[[i,2]])
}

#Create a data frame for the test measurements
testdatadt_measurements <- read.table(file.path(working_dir, "UCI HAR Dataset\\test\\x_test.txt"), header = TRUE)
features_list <- read.table(file.path(working_dir, "UCI HAR Dataset\\features.txt"), header = FALSE)

#Extract only mean and std values
features_list <- cbind(grep("(mean|std)\\(\\)",features_list[,2]),grep("(mean|std)\\(\\)",features_list[,2], value = TRUE))
features_list[,2] <- sub("\\(\\)", "", as.character(features_list[,2]))

#Assign the measurement labels
testdatadt_measurements <- testdatadt_measurements[, as.numeric(features_list[, 1])]
colnames(testdatadt_measurements) <- features_list[,2]

#Create dataset for the test data
testdatatbl <- cbind(testdatadt_subjects, testdatadt_activities, testdatadt_measurements)

#Load train datasets
#Create a data frame for the subjects
traindatadt_subjects <- read.table(file.path(working_dir, "UCI HAR Dataset\\train\\subject_train.txt"), header = TRUE)
colnames(traindatadt_subjects)[1] <- "Subject_ID"

#Create a data frame for the activities
traindatadt_activities <- read.table(file.path(working_dir, "UCI HAR Dataset\\train\\y_train.txt"), header = TRUE)
colnames(traindatadt_activities)[1] <- "Activity"
activity_list <- read.table(file.path(working_dir, "UCI HAR Dataset\\activity_labels.txt"), header = FALSE)

#Assign the activity labels
for (i in 1 : nrow(activity_list)) {
  traindatadt_activities[traindatadt_activities[, 1] == as.numeric(activity_list[[i,1]]), ] <- as.character(activity_list[[i,2]])
}

#Create a data frame for the train measurements
traindatadt_measurements <- read.table(file.path(working_dir, "UCI HAR Dataset\\train\\x_train.txt"), header = TRUE)
features_list <- read.table(file.path(working_dir, "UCI HAR Dataset\\features.txt"), header = FALSE)

#Extract only mean and std values
features_list <- cbind(grep("(mean|std)\\(\\)",features_list[,2]),grep("(mean|std)\\(\\)",features_list[,2], value = TRUE))
features_list[,2] <- sub("\\(\\)", "", as.character(features_list[,2]))

#Assign the measurement labels
traindatadt_measurements <- traindatadt_measurements[, as.numeric(features_list[, 1])]
colnames(traindatadt_measurements) <- features_list[,2]

#Create dataset for the train data
traindatatbl <- cbind(traindatadt_subjects, traindatadt_activities, traindatadt_measurements)

#Merge the test and train datasets
alldatatbl <- rbind(testdatatbl, traindatatbl)

#Calculate measurement averages
allData_melted <- melt(alldatatbl, id = c("Subject_ID", "Activity"))
allData_mean <- dcast(allData_melted, Subject_ID + Activity ~ variable, mean)

#Create the tidy dataset
write.table(allData_mean, "tidy_dataset.txt", row.names = FALSE)