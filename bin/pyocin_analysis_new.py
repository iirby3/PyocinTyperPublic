#!/usr/bin/env python3

import pandas as pd
import numpy as np
import sys

if __name__ == "__main__":
    pyocin_input = sys.argv[1]
    output = sys.argv[2]
    PID = sys.argv[3]
    NID = sys.argv[4]

#Read in blast result as table
pyocin_table = pd.read_table(pyocin_input, names = ['qseqid', 'sseqid', 'sacc', 'pident', 'nident', 'qlen', 'length', 'evalue', 'slen', 'qstart', 'qend', 'sstart', 'send'])

# Get pyocin length
length = pyocin_table.loc[0, 'qlen']

#Drop extra columns
pyocin_drop = pyocin_table.drop(pyocin_table.columns[[0, 1, 4, 5, 7, 8, 9, 10, 11, 12]],axis = 1)

#Only include results with over a 70% percent identity
pyocin_sort = pyocin_drop[~(pyocin_drop['pident'] <= float(PID))]

#Drop extra column
pyocin_drop_2 = pyocin_sort.drop(pyocin_sort.columns[[1]], axis = 1)

#Sum blast results by nucleotide idnentity (large blasts will align in chunks)
pyocin_sum = pyocin_drop_2.groupby('sacc').sum('length')

#Reset index
pyocin_sum.reset_index(inplace=True)

#Add a column where every entry is the length of the reference pyocin
pyocin_sum['Pyocin_Length'] = length

#Get the percentage match of the alignment to the reference pyocin
pyocin_sum['Percent_Pyocin'] = ((pyocin_sum['length']/pyocin_sum['Pyocin_Length'])*100)

#Drop any rows that have less than a 70% match to the reference
pyocin_comp = pyocin_sum[~(pyocin_sum['Percent_Pyocin'] <= float(NID))]

#Drop extra columns
pyocin_fasta = pyocin_comp.drop(pyocin_comp.columns[[1, 2, 3]],axis = 1)

#Write out to a list
pyocin_fasta.to_csv(f'{output}_fasta.txt', header=None, index=None, sep=' ', mode='a')
