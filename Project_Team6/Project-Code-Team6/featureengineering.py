# -*- coding: utf-8 -*-
"""
Created on Sat Dec 18 18:08:53 2021

@author: ethan
"""

import numpy as np
import pandas as pd
import os
from sklearn.model_selection import train_test_split
from category_encoders import CountEncoder, TargetEncoder

os.chdir('c:/Users/ethan/Downloads')
traindf = pd.read_csv("ProjectTrainingSampleCleaned.csv")

pred = pd.read_csv('preds.csv')
traindf = traindf.iloc[:,1:]

# Split X and Y
x=traindf.iloc[:,1:]
y=traindf.iloc[:,0]

# Split into train and test data
x_train, x_test, y_train, y_test = train_test_split(
x, y, test_size=0.25, random_state=1, stratify=y)

# Categorical variable encoding
enc = CountEncoder(cols=['banner_pos', 'site_domain', 'app_domain'], min_group_size=(50)).fit(x_train)

x_train_count_transform = enc.transform(x_train)
x_test_count_transform = enc.transform(x_test)

enc1 = TargetEncoder(cols=['C1', 'site_category', 'app_category', 'device_type', 'device_model', 'device_id', 'device_conn_type', 'C14', 'C17', 'C18', 'C19', 'C20', 'C21', 'ip_location'], min_samples_leaf = 50)
x_train_trans = enc1.fit_transform(x_train_count_transform, y_train)
x_test_trans = enc1.transform(x_train_count_transform)

from sklearn.preprocessing import StandardScaler 

sc = StandardScaler()
sc.fit(x_train_trans) 

X_train_std = sc.transform(x_train_trans)
df_x_train = pd.DataFrame(X_train_std)
df_y_train = pd.DataFrame(y_train)
train = pd.concat([df_y_train, df_x_train], axis=1)
x_test_std = sc.transform(x_test_trans)
df_x_test = pd.DataFrame(x_test_std)
df_y_test = pd.DataFrame(y_train)
test = pd.concat([df_y_test, df_x_test], axis=1)

train.to_csv("TRAIN.csv", index = False)
test.to_csv("TEST.csv", index = False)

