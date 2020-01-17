import pandas as pd
import numpy as np
import matplotlib.mlab as mlab
import matplotlib.pyplot as plt
import matplotlib


data=pd.read_excel('C:\\Users\\clau\\Desktop\\ershoufang1.xlsx')


a=data.groupby('区').size().reset_index(name='数量')
print(a)


X=['jiading','fengxian','baoshan','xuhui','putuo','yangpu','songjiang','pudong','hongkou','changning','minhang','zhabei','qingpu','jingan','huangpu'] 
Y=[1203,520,3147,2196,2439,2706,1064,696,1364,1575,3356,1368,463,575,1068]
fig = plt.figure()
plt.bar(X,Y,0.4,color="green")
plt.xlabel("qu")
plt.ylabel("num")
plt.title("bar chart")


plt.show()







