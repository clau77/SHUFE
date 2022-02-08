if (!require("pacman")) install.packages("pacman")
pacman::p_load(data.table, parallel, rgeolocate, tidyverse, caret, digest, neuralnet)


# Load the data
# -------------------------------------------------------------------------------------------
# I did not see improvement in performance with varying (cont...)
# the nThread argument with the fread() function. 
data <- fread("ProjectTrainingsample.csv")

# ETHAN NOTE: copy the data to guard against mistakes
testing <- data


# EXPLORATORY WORK - NOT USED IN MODEL
# -------------------------------------------------------------------------------------------
# Check frequency of class of categorical variable
# Creating vector of column names (cont ...)
# (without the Id column, which appears to be a unique identifier for each instance and the hour column, which will be feature engineered) (cont ...)
# to feed into a for loop that results in the frequency of each class of each categorical variable
columnNames <- colnames(testing)
columnNamesWithoutId <- columnNames[-1]
columnNamesVf <- columnNamesWithoutId[-2]

dfList <- list()
for (i in columnNamesVf){
  dfList[[match(i, columnNamesVf)]] <- testing[, .N, keyby = i]
}


# Find the minimum frequency for each categorical variable level
for (i in seq_along(dfList)){
  print(colnames(dfList[[i]])[1])
  print(min(dfList[[i]][,2]))
}

# FEATURE ENGINEERING
# -------------------------------------------------------------------------------------------
# finding location data from ip addresses
# Add periods between each "part" of the IP address. This is needed when converting (cont ...)
# the hexidecimal IP addresses into decimal IP addresses. The package that converts (cont ...)
# IP addresses to location data requires IP addresses in decimal form
testing$device_ip <- gsub("(.{2})(.{2})(.{2})(.*)", "\\1 \\2 \\3 \\4", testing$device_ip)

# Separate each "part" of the IP address into its own column
testing0 <- separate(testing, col = device_ip, into = c("hex1", "hex2", "hex3", "hex4"), sep = "([. :])")

# Convert hexidecimal IP addresses into decimal IP addresses and combine into (cont ...)
# a single column
testing1 <- testing0[, ip_decimal := paste(as.character(strtoi(hex1, base = 16)),
                                          as.character(strtoi(hex2, base = 16)),
                                          as.character(strtoi(hex3, base = 16)),
                                          as.character(strtoi(hex4, base = 16)))]

# Convert into standard IP format through replacing whitespace with periods
testing1$ip_decimal <- gsub(" ", ".", testing1$ip_decimal)

# Set the file which is used in translating IP's into location data
file <- system.file("extdata","GeoLite2-Country.mmdb", package = "rgeolocate")

# Create new column with the country of each IP addresss
testing2 <- testing1[, ip_location := maxmind(ip_decimal, file, c("continent_name"))]
testing2$ip_location[is.na(testing2$ip_location)] <- "unknown"

dropcols <- c("hex1", "hex2", "hex3", "hex4", "ip_decimal")
testing3 <- testing2[, !dropcols, with = FALSE]

# Create binary variable to indicate whether the ad was shown on a website or on an app
testing3[, website := ifelse(site_id == '85f751fd', 0, 1)]

dropcols2 <- c("site_id", "app_id")
testing4 <- testing3[, !dropcols2, with = FALSE]

# Convert time to seconds since midnight to prepare time data for incorporating cyclicality
testing4$seconds_since_midnight <- (as.numeric(substring(testing4$hour, 7,8))*60*60)

# Use sin and cosine to make cyclicality
seconds_in_day <- 24*60*60
testing4$sin_time <- sin(2*pi*testing4$seconds_since_midnight/seconds_in_day)
testing4$cos_time <- cos(2*pi*testing4$seconds_since_midnight/seconds_in_day)

# Conversely to encoding cycle patterns, I want to have a variable that can reflect overall trends over time
# Thus, I create a variable that tracks the number of days since the beginning of data collection. 
testing4$days_since_week <- (as.numeric(substring(testing4$hour, 5,6))-21)

# The anonymous variables of C15 and C16 seem to likely be the dimensions of the ad
# We encode the area of the ad because this is likely more representative of the "noticeability" of the ad
testing5 <- testing4[, dimension := C15*C16]
dropcols3 <- c("seconds_since_midnight", "hour", "id")

testing6 <- testing5[, !dropcols3, with = FALSE]

write.csv(testing6, 'ProjectTrainingSampleCleaned.csv')

# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------

# Do the same stuff on the test dataset

# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------

# Load the data
# -------------------------------------------------------------------------------------------
# I did not see improvement in performance with varying (cont...)
# the nThread argument with the fread() function. 
data_t <- fread("ProjectTestData.csv")

# ETHAN NOTE: copy the data to guard against mistakes
testing_t <- data_t

# FEATURE ENGINEERING
# -------------------------------------------------------------------------------------------
# finding location data from ip addresses
# Add periods between each "part" of the IP address. This is needed when converting (cont ...)
# the hexidecimal IP addresses into decimal IP addresses. The package that converts (cont ...)
# IP addresses to location data requires IP addresses in decimal form
testing_t$device_ip <- gsub("(.{2})(.{2})(.{2})(.*)", "\\1 \\2 \\3 \\4", testing_t$device_ip)

# Separate each "part" of the IP address into its own column
testing_t0 <- separate(testing_t, col = device_ip, into = c("hex1", "hex2", "hex3", "hex4"), sep = "([. :])")

# Convert hexidecimal IP addresses into decimal IP addresses and combine into (cont ...)
# a single column
testing_t1 <- testing_t0[, ip_decimal := paste(as.character(strtoi(hex1, base = 16)),
                                           as.character(strtoi(hex2, base = 16)),
                                           as.character(strtoi(hex3, base = 16)),
                                           as.character(strtoi(hex4, base = 16)))]

# Convert into standard IP format through replacing whitespace with periods
testing_t1$ip_decimal <- gsub(" ", ".", testing_t1$ip_decimal)

# Set the file which is used in translating IP's into location data
file <- system.file("extdata","GeoLite2-Country.mmdb", package = "rgeolocate")

# Create new column with the country of each IP addresss
testing_t2 <- testing_t1[, ip_location := maxmind(ip_decimal, file, c("continent_name"))]
testing_t2$ip_location[is.na(testing_t2$ip_location)] <- "unknown"

dropcols <- c("hex1", "hex2", "hex3", "hex4", "ip_decimal")
testing_t3 <- testing_t2[, !dropcols, with = FALSE]

# Create binary variable to indicate whether the ad was shown on a website or on an app
testing_t3[, website := ifelse(site_id == '85f751fd', 0, 1)]

dropcols2 <- c("site_id", "app_id")
testing_t4 <- testing_t3[, !dropcols2, with = FALSE]

# Convert time to seconds since midnight to prepare time data for incorporating cyclicality
testing_t4$seconds_since_midnight <- (as.numeric(substring(testing_t4$hour, 7,8))*60*60)

# Use sin and cosine to make cyclicality
seconds_in_day <- 24*60*60
testing_t4$sin_time <- sin(2*pi*testing_t4$seconds_since_midnight/seconds_in_day)
testing_t4$cos_time <- cos(2*pi*testing_t4$seconds_since_midnight/seconds_in_day)

# Conversely to encoding cycle patterns, I want to have a variable that can reflect overall trends over time
# Thus, I create a variable that tracks the number of days since the beginning of data collection. 
testing_t4$days_since_week <- (as.numeric(substring(testing_t4$hour, 5,6))-21)

# The anonymous variables of C15 and C16 seem to likely be the dimensions of the ad
# We encode the area of the ad because this is likely more representative of the "noticeability" of the ad
testing_t5 <- testing_t4[, dimension := C15*C16]
dropcols3 <- c("seconds_since_midnight", "hour", "id")

testing_t6 <- testing_t5[, !dropcols3, with = FALSE]

write.csv(testing_t6, 'ProjectTestSampleCleaned.csv')

train = fread('TRAIN.csv')
test = fread('TEST.csv')

head(test)

train$click <- ifelse(is.na(train$click), 1, train$click)
test$click <- ifelse(is.na(test$click), 1, test$click)

library(nnet)

neural <- nnet(click ~ ., data=train, size=5, decay=5e-4, maxit=200)

test1 <- test
test1$click <- as.factor(test$click)

preds <- predict(neural, test1, type = "class")

is.factor(test$click)

LogLoss <- function(PHat,Click) {
  Y <- as.integer(Click)
  eps <- 1e-15
  out <- -mean(Y*log(pmax(PHat,eps))+(1-Y)*log(pmax(1-PHat,eps)))
  return(out)
}


pred123 <- preds[1:7000,]
test123 <- test[1:7000, "click"]

LogLoss(pred123, test321)

is.list(pred123)
is.list(test123)
is.vector(test123)

test321 <- as.numeric(unlist(test123))

write.csv(preds, 'preds.csv')
write.csv(test, 'testfinalvt.csv')

