setwd("C:/Users/aduro/Desktop/Coding/Data Science Coursera/Data Science Specialization/8 Practical Machine Learning")


#The goal of your project is to predict the manner in which they did the exercise. This is the "classe" variable in the training set. 
#You may use any of the other variables to predict with. You should create a report describing how you built your model, 
#how you used cross validation, what you think the expected out of sample error is, and why you made the choices you did. 
#You will also use your prediction model to predict 20 different test cases.

#Load data and libraries
library(caret)
library(dplyr)
library(rattle)
set.seed(123)

pml_training <- read.csv("pml-training.csv", header=TRUE) 
pml_testing <- read.csv("pml-testing.csv") 
dim(pml_training)
dim(pml_testing)
#training data has 19,622 obsrvations and 160 variables.
#testing data has 20 observations and 160 variables.

#Clean dataset
#remove variables with more than 90% NA
pml_training <- pml_training[, which(colMeans(!is.na(pml_training)) > 0.9)]
#remove irrelavant variables to the outcome
pml_training <- pml_training[,-c(1:7)]
#remove near zero variance predictors 
near_ZeroPredictors <- nearZeroVar(pml_training)
pml_training <- pml_training[,-near_ZeroPredictors]
dim(pml_training)

#Data partition
#Use cross validation on training sample 
inTrain <- createDataPartition(y=pml_training$classe, p=0.7, list=FALSE)
training <- pml_training[inTrain,]
validation <- pml_training[-inTrain,]

#Model Building
#Use the following models: Classification tree, Random Forests, 
#and gradient boosting trees.

#Set trControl parameter to do 5 fold cross valdiation
control <- trainControl(method="cv", number=5, verboseIter=FALSE)

#Decision Tree
##Model
tree_fit <- train(classe~., method="rpart", data=training, trControl=control)
tree_fit$finalModel
fancyRpartPlot(tree_fit$finalModel)
#Prediction, estimate performance of model on validation data set
predict_tree <- predict(tree_fit, newdata=validation)
confusion_tree <- confusionMatrix(predict_tree, factor(validation$classe))
confusion_tree

#Gradient Boosted Trees
##Model
gbm_fit <- train(classe~., method="gbm", data=training, trControl=control, verbose=FALSE)
#Prediction, estimate performance of model on validation data set
predict_gbm <- predict(gbm_fit, newdata=validation)
confusion_gbm <- confusionMatrix(predict_gbm, factor(validation$classe))
confusion_gbm

#Random Forest
##Model
random_fit <- train(classe~., method="rf", data=training, trControl=control)
#Prediction, estimate performance of model on validation data set
predict_rf <- predict(random_fit, newdata=validation)
confusion_rf <- confusionMatrix(predict_rf, factor(validation$classe))
confusion_rf

#Results, Model Assessment
#Accuracy and Out of Sample Error
model_names <- c("Decision Tree", "Gradient Boost Trees", "Random Forest")
model_accuracy <- round(c(confusion_tree$overall[1],confusion_gbm$overall[1],confusion_rf$overall[1]),3)
model_oos_error <- 1 - model_accuracy
model_info <- data.frame(Models = model_names, Accuracy = model_accuracy, oos_error = model_oos_error)
model_info

#Predictions on Test dataset
test_results <- predict(random_fit, pml_testing)