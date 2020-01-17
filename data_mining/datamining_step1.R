install.packages("corrplot")
install.packages('DMwR')

setwd("E:/data_format1")
library(ggplot2)
library(DMwR)
library(randomForest)
library(data.table)
library(caret)
library(dplyr)
library(xgboost)
library(ROCR)
library(e1071)
library(pROC)
user_info <- fread("user_info_format1.csv", header=T)
user_log <- fread("user_log_format1.csv",header = T)
train <- fread("train_format1.csv", header = T)
ytrain=train$label
#delete all the NA value in user_info and user_log

user_info_clean = na.omit(user_info)
#delete data where age = 0 or gender = 2 
user_log_clean = na.omit(user_log)
user_info_clean = user_info_clean[-which(user_info_clean$gender ==2),]
user_info_clean = user_info_clean[-which(user_info_clean$age_range == 0),]
user_log_clean=user_log_clean[which(user_log_clean$user_id%in%user_info_clean$user_id),]
index2=sample(nrow(train),10000)
test_subset=train[index2,]
train=train[-index2,]
#divide them according to different labels
train_label_0 = train[which(train$label == 0),]
train_label_1 = train[which(train$label == 1),]
#set labels with the same size
nrow(train_label_0)
nrow(train_label_1)
index = sample(nrow(train_label_0),5000)
train_sample_0 = train_label_0[index,]
index1 = sample(nrow(train_label_1),5000)
train_sample_1 = train_label_1[index1,]
train_sample = merge(train_sample_0, train_sample_1,all = T)  
nrow(train_sample)

user_1<-user_log_clean
colnames(user_1)=c("user_id","item_id","cat_id","merchant_id","brand_id","time_stamp","action_type")

?merge
user_merge_test = merge(train_sample,user_1 ,by = c("user_id","merchant_id"),sort=TRUE)

user_merge_sample = merge(user_merge_test, user_info_clean,by = c("user_id"), sort =T)
summary(user_merge_sample)

valid=merge(test_subset,user_1,by = c("user_id","merchant_id"),sort=TRUE)
valid=merge(valid,user_info_clean,by = c("user_id"), sort =T)
#total_merge=merge(user_1,user_info_clean,by=c("user_id"),sort=T)
#total_merge=merge(total_merge,train,by=c("user_id","merchant_id"),sort=T)

int1=intersect(user_merge_sample[,1:2],train_label_0[,1:2])
int2=intersect(user_merge_sample[,1:2],train_label_1[,1:2])
which(int1$merchant_id%in%int2$merchant_id&int1$user_id%in%int2$user_id)
train_label_0[19,]
train0=merge(user_merge_sample,train_label_0,by=c("user_id","merchant_id"))
train1=merge(user_merge_sample,train_label_1,by=c("user_id","merchant_id"))
train=rbind(train0,train1)
train$label.y=factor(train$label.y)

summary(train$label.y)
set.seed(233)
timestart=Sys.time()
model.rf1 <- randomForest(label~.,data=train_test,ntree=200,mtry=8,importance=T,proximity=F,oob.prox=T,class=c(1,100))
timeend=Sys.time()
run=timeend-timestart
print(model.rf1)
summary(model.rf1)

train=train[,-3]
set.seed(233)
timestart=Sys.time()
model.rf1 <- randomForest(label.y~.,data=train,ntree=100,mtry=2,importance=T,proximity=F,class=c(0.1,0.9))
timeend=Sys.time()
run=timeend-timestart
print(model.rf1)
summary(model.rf1)


folds<-createFolds(y=train$label.y,k=10)
re<-{}
for(i in 1:10){
  traindata<-train[-folds[[i]],]
  testdata<-train[folds[[i]],]
  rf <- randomForest(label.y ~ ., data=traindata, ntree=100,mtry=2, proximity=FALSE)
  re=c(re,length(train$label.y[which(predict(rf,testdata)==testdata$label.y)])/length(testdata$label.y))
  
}
mean(re)
summary(predict(rf,testdata))

folds<-createFolds(y=train_test$label,k=10)
re<-{}
auc={}
for(i in 1:10){
  traindata<-train_test[-folds[[i]],]
  testdata<-train_test[folds[[i]],]
trainy=as.numeric(traindata$label)-1
trainx= model.matrix(~.,data=traindata[,-8])[,-1] 
timestart=Sys.time()
param <- list(seed=23,objective="binary:logistic",max_depth=15,min_child_weight=0.9,eval_metric ="auc")
model.xgb <- xgboost(data=trainx,label=trainy,params=param,nrounds=10)
timeend=Sys.time()
run=timeend-timestart
print(run)
testx=model.matrix(~.,data=testdata[,-8])[,-1]
pred2=round(predict(model.xgb,testx),0)
pred=prediction(pred2,testdata$label)
perf<-performance(pred,"tpr","fpr")
auc=c(auc,auc(testdata$label,pred2))
re=c(re,length(train_test$label[which(pred2==testdata$label)])/length(testdata$label))
}
mean(re)
mean(auc)
#ROC begins
train1=train[,-c(1,2)]
traindata<-train1[-folds[[1]],]
testdata<-train1[folds[[1]],]
rf <- randomForest(label.y ~ ., data=traindata, ntree=100,mtry=2, proximity=FALSE)
prediction=predict(rf,newdata=testdata,type="prob")
pred=prediction(prediction[,2],testdata$label.y)
perf<-performance(pred,"tpr","fpr")
plot(perf,colorize=F)
re=c(length(train$label.y[which(predict(rf,testdata)==testdata$label.y)])/length(testdata$label.y))
varImpPlot(rf)
#ROC ends

traindata<-train_test[-folds[[1]],]
testdata<-train_test[folds[[1]],]
trainy=as.numeric(traindata$label)-1
trainx= model.matrix(~.,data=traindata[,-8])[,-1] 
timestart=Sys.time()
param <- list(seed=23,objective="binary:logistic",weight=c(1,9),max_depth=15,min_child_weight=0.9,eval_metric ="auc")
model.xgb <- xgboost(data=trainx,label=trainy,params=param,nrounds=10)
timeend=Sys.time()
run=timeend-timestart
print(run)
testx=model.matrix(~.,data=testdata[,-8])[,-1]
pred2=round(predict(model.xgb,testx),0)
pred=prediction(pred2,testdata$label)
perf<-performance(pred,"tpr","fpr")
plot(perf,colorize=F)
re=c(re,length(train$label.y[which(pred2==testdata$label.y)])/length(testdata$label.y))

folds<-createFolds(y=train$label.y,k=10)
re<-{}
for(i in 1:10){
  traindata<-train[-folds[[i]],]
  testdata<-train[folds[[i]],]
  rf <- randomForest(label.y ~ ., data=traindata, ntree=100,mtry=2, proximity=FALSE)
  prediction=predict(rf,newdata分别呈草=testdata,type="prob")
  pred=prediction(prediction[,2],testdata$label.y)
  perf<-performance(pred,"tpr","fpr")
  plot(perf,colorize=F)
  re=c(re,length(train$label.y[which(predict(rf,testdata)==testdata$label.y)])/length(testdata$label.y))
}
mean(re)
summary(predict(rf,testdata))

fitsvm=svm(label~.,train,type='C',kernel='radial')
summary(fit_svm)
pred_svm=predict(fit_svm,test)
cm_svm=table(test$label,pred_svm)