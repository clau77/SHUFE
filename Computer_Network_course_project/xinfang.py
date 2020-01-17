import requests
from lxml import etree
import pandas as pd
import time

headers = {
	'User-Agent':'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.81 Safari/537.36'}

urls=['http://sh.fang.lianjia.com/loupan/sta1sta3pg{}/'.format(str(i)) for i in range(1,16)]

dizhi=[]
mingcheng=[]
jiage=[]
danwei=[]
mianji=[]
leixing=[]
zhuangtai=[]

for url in urls:
        
	r=requests.get(url).text
	s=etree.HTML(r)
	di=s.xpath('//*[@id="list-box"]/div[2]/ul/li/div[2]/div[1]/div[2]/a/text()')
	ming=s.xpath('//*[@id="nameShow"]/text()')
	lei=s.xpath('//*[@id="list-box"]/div[2]/ul/li/div[2]/div[1]/div[1]/span[1]/text()')
	zhuang=s.xpath('//*[@id="list-box"]/div[2]/ul/li/div[2]/div[1]/div[1]/span[2]/text()')
	jia=s.xpath('//*[@id="list-box"]/div[2]/ul/li/div[2]/div[2]/div/div/span/text()')
	dan=s.xpath('//*[@id="list-box"]/div[2]/ul/li/div[2]/div[2]/div/div/text()[2]')
	mian=s.xpath('//*[@id="list-box"]/div[2]/ul/li/div[2]/div[1]/div[3]/a/text()')
	dizhi=dizhi+di
	
	mingcheng=mingcheng+ming
	leixing=leixing+lei
	zhuangtai=zhuangtai+zhuang
	jiage=jiage+jia
	danwei=danwei+dan
	mianji=mianji+mian
	

	time.sleep(1)

df=pd.DataFrame({"名称":mingcheng,"类型":leixing,"状态":zhuangtai,"地址":dizhi,"价格":jiage,"单位":danwei,"面积":mianji})
df.to_excel('lianjia.xlsx')

