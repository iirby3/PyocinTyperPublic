import pandas as pd
import numpy as np
import glob, os

data=[]

for file in glob.glob("x*"):
	if os.path.getsize(file) == 0:
		print(file)
	else:
		f=open(file, 'r')
		results = pd.read_table(f, header=None)
		results['Cluster']=file
		acc = results['Cluster'].str.split("x", expand = True)
		results['Cluster']= acc[2]
		data.append(results)

table = pd.concat([dfi.rename({old: new for new, old in enumerate(dfi.columns)}, axis=1) for dfi in data], ignore_index=True)
table.rename(columns = {0:'Number', 1:'Header',2:'Cluster'}, inplace = True)

drop = table.drop(table.columns[[0]], axis = 1)

ident = drop['Header'].str.split(" ", expand = True)

drop['Header'] = ident[1]
drop['Length'] = ident[0]
drop['Status'] = ident[2]
drop['Percent_similar'] = ident[3]

drop['Header'] = drop['Header'].str.replace('>','')
drop['Length'] = drop['Length'].str.replace('aa,','')
drop['Status'] = drop['Status'].str.replace('*','ref')
drop['Status'] = drop['Status'].str.replace('at','clustered')

split = drop['Header'].str.split(".", expand = True)

drop['Header'] = split[0] +"."+ split[1] +"." + split[2]

drop['Header'] = drop['Header'].str.replace('..','')

comp = drop['Percent_similar'].str.split("/", expand = True)

drop['Percent_similar'] = comp[2]

drop.to_csv("Clusters_overview_table.csv", index=False)

drop_1 = drop[drop['Status'].str.contains("ref")]
drop_2 = drop_1.drop(drop_1.columns[[1, 2, 3, 4]], axis = 1)

drop_2.to_csv("ref_list.txt", index=False, header=False)

drop_3 = drop_1.drop(drop_1.columns[[2, 3, 4]], axis = 1)

drop_3.to_csv("ref_list_cluster.txt", sep="\t", index=False, header=False)