import requests
from lxml import etree
import pandas as pd
import time

headers = {
	'User-Agent':'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.81 Safari/537.36'}
base_url='http://sh.lianjia.com/ershoufang/d'

qu=[]
weizhi=[]
xiaoqu=[]
mingcheng=[]
jiage=[]
danjia=[]
mianji=[]
mian=[]

for i in range(1000):
	url=base_url+str(i+1)
	r=requests.get(url).text
	s=etree.HTML(r)
	q=s.xpath('//*[@id="js-ershoufangList"]/div[2]/div[3]/div[1]/ul/li/div/div[2]/div[2]/span[1]/a[2]/text()')
	wei=s.xpath('//*[@id="js-ershoufangList"]/div[2]/div[3]/div[1]/ul/li/div/div[2]/div[2]/span[1]/a[3]/text()')
	xiao=s.xpath('//*[@id="js-ershoufangList"]/div[2]/div[3]/div[1]/ul/li/div/div[2]/div[2]/span[1]/a[1]/span/text()')
	ming=s.xpath('//*[@id="js-ershoufangList"]/div[2]/div[3]/div[1]/ul/li/div/div[1]/a/text()')
	dan=s.xpath('//*[@id="js-ershoufangList"]/div[2]/div[3]/div[1]/ul/li/div/div[2]/div[2]/span[2]/text()')	
	jia=s.xpath('//*[@id="js-ershoufangList"]/div[2]/div[3]/div[1]/ul/li/div/div[2]/div[1]/div/span[1]/text()')
	for x in (s.xpath('//*[@id="js-ershoufangList"]/div[2]/div[3]/div[1]/ul/li/div/div[2]/div[1]/span/text()')):
		if(len(x.split('|')) > 1):
			mianji.append(x.split('|')[1])
	qu=qu+q
	weizhi=weizhi+wei
	xiaoqu=xiaoqu+xiao
	mingcheng=mingcheng+ming
	danjia=danjia+dan
		
	jiage=jiage+jia
	mianji=mianji+mian
		
		
		
	print('正在爬取第%s页' % str(i+1))
		
		 
	time.sleep(1)
df=pd.DataFrame({"名称":mingcheng,"小区":xiaoqu,"区":qu,"位置":weizhi,"总价":jiage,"单价":danjia,"面积":mianji})
df.to_excel('ershoufang1.xlsx')
