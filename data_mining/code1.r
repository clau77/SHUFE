
data.frame(user_train_merge1)
agerange<-aggregate(list(agerange = user_train_merge1$age_range),by=list(userid = user_train_merge1$user_id), mean)
head(agerange,20)
gender<-aggregate(list(gender = user_train_merge1$gender),by=list(userid = user_train_merge1$user_id), mean)
usertime<-aggregate(list(usertime = user_train_merge1$time_stamp),by = list(userid = user_train_merge1$user_id),length)
nrow(usertime)
summary(agerange)

summary()
sellitem <- aggregate(list(sellitem= user_train_merge1$item_id),by = list(merchantid = user_train_merge1$merchant_id), length)

sellcat <- aggregate(list(sellcat = user_train_merge1$cat_id),by = list(merchantid = user_train_merge1$merchant_id), length) 
sellbrand <- aggregate(list(sellbrand = user_train_merge1$brand_id),by = list(merchantid = user_train_merge1$merchant_id), length)
selluser <- aggregate(list(selluser = user_train_merge1$user_id),by = list(merchantid = user_train_merge1$merchant_id), length)
user_click<-aggregate(list(user_click = user_train_merge1[which(user_train_merge1$action_type==0),]$action_type),by=list(userid = user_train_merge1[which(user_train_merge1$action_type==0),1]),length)

user_cart<-aggregate(list(user_cart = user_train_merge1[which(user_train_merge1$action_type==1),]$action_type),by=list(userid = user_train_merge1[which(user_train_merge1$action_type==1),1]),length)
head(user_cart)
user_buy<-aggregate(list(user_buy = user_train_merge1[which(user_train_merge1$action_type==2),]$action_type),by=list(userid = user_train_merge1[which(user_train_merge1$action_type==2),1]),length)
head(user_buy)
user_like<-aggregate(list(user_like = user_train_merge1[which(user_train_merge1$action_type==3),]$action_type),by=list(userid = user_train_merge1[which(user_train_merge1$action_type==3),1]),length)

merclick <- aggregate(list(merclick = user_train_merge1[which(user_train_merge1$action_type==0),]$action_type),by=list(merchantid = user_train_merge1[which(user_train_merge1$action_type==0),2]),length)
#mercart <- aggregate(list(mercart = user_train_merge1[which(user_train_merge1$action_type==1),]$action_type),by=list(merchantid = user_train_merge1[which(user_train_merge1$action_type==1),2]),length)
merbuy <- aggregate(list(merbuy = user_train_merge1[which(user_train_merge1$action_type==2),]$action_type),by=list(merchantid = user_train_merge1[which(user_train_merge1$action_type==2),2]),length)
merlike <- aggregate(list(merlike = user_train_merge1[which(user_train_merge1$action_type==3),]$action_type),by=list(merchantid = user_train_merge1[which(user_train_merge1$action_type==3),2]),length)
colnames(trainsample1) = c("userid","merchantid","label")
ds = merge(trainsample1,gender, by = c("userid"))
ds<-data.frame(ds)
head(ds)
ds1 = merge(ds, agerange, by = "userid")

ds2 = merge(ds1, sellitem, by = "merchantid")
ds3 = merge(ds2, sellcat, by = 'merchantid')
ds4 = merge(ds3, sellbrand, by = "merchantid")
ds5 = merge(ds4, selluser, by = "merchantid")
ds6 = merge(ds5, user_click,by = "userid",all=T)
ds7 = merge(ds6, usertime,by = "userid",all=T)
ds8 = merge(ds7, user_buy,by = "userid",all=T)
ds9 = merge(ds8, user_like,by = "userid",all=T)
ds10 = merge(ds9, merclick,by = "merchantid",all=T)
# = merge(ds10, mercart)
ds12 = merge(ds10, merbuy,by = "merchantid",all=T)
ds13 = merge(ds12, merlike,by = "merchantid",all=T)
summary(ds13)
ds13[is.na(ds13)] <- 0

nrow(ds13)
ds13=ds13[,-c(1,2)]
ds13$agerange=factor(ds13$agerange)
ds13$gender=factor(ds13$gender)

for(i in 6:16){
  ds13[,i]=scale(ds13[,i])
}
summary(ds13)

write.csv(ds13, file = "train2.csv")
ds13$label=factor(ds13$label)
train=ds13