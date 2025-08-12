#!/usr/bin/env python3

import pandas as pd
import numpy as np
import glob, os
import sys

if __name__ == "__main__":
    vclust_output = sys.argv[1]
    
table = pd.read_csv(vclust_output, sep = "\t")

table.rename(columns = {'object':'Header', 'cluster':'Cluster'}, inplace = True)

table.to_csv("vclust_summary_table.csv", index = None)

refs = table.drop_duplicates(subset='Cluster', keep='first')

refs.to_csv("vclust_representitives_per_cluster.csv", index = None)

refs_headers = refs[["Header"]]

refs_headers.to_csv("vclust_representitives_per_cluster_list.txt", sep = "\t", index = None, header = None)
