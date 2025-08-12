#!/usr/bin/env python3

import pandas as pd
import numpy as np
import sys

if __name__ == "__main__":
    clusters = sys.argv[1]
    ref_list = sys.argv[2]
    pyocin_input = sys.argv[3]
    output = sys.argv[4]

table = pd.read_table(clusters, sep=",")

# Read in cluster reference table
ref_table = pd.read_table(ref_list, sep=",")

# Merge with pyocin blast output
meta = pd.read_table(pyocin_input, sep="\t", header=None)

meta.rename(columns = {0:'Header'}, inplace = True)

merge = ref_table.merge(meta, how='inner', on='Header')

merge_sub = merge[["Cluster"]]

merge_all = table.merge(merge_sub, how='inner', on='Cluster')

drop = merge_all[["Header"]]

drop.to_csv(f"{output}_list.txt", sep="\t", index=False, header=False)
