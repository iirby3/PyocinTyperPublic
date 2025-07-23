#!/usr/bin/env python3

import pandas as pd
import numpy as np
import glob, os
import sys

if __name__ == "__main__":
    list_input = sys.argv[1]
    blast_input = sys.argv[2]
    R_pyocin_PID = sys.argv[3]
    R_pyocin_NID = sys.argv[4]
    F_pyocin_PID = sys.argv[5]
    F_pyocin_NID = sys.argv[6]

header = pd.read_table(f"{list_input}", sep="\t", header=None)
header.rename(columns = {0:'Header'}, inplace = True)

header_no_dup = header.drop_duplicates()

blast_all = pd.read_table(f'{blast_input}', names = ['qseqid', 'Header', 'sacc', 'pident', 'nident', 'qlen', 'length', 'evalue', 'slen', 'qstart', 'qend', 'sstart', 'send'])

R_pyocins = blast_all[blast_all['qseqid'] == "PAO1_R_Pyocin"]
R_pyocins.reset_index(inplace=True)

F_pyocins = blast_all[blast_all['qseqid'] == "PAO1_F_Pyocin"]
F_pyocins.reset_index(inplace=True)

# Reformat blast
def reformat_blast(df, PID, NID):

    length = df.loc[0, 'qlen']

    table_sort = df[~(df['pident'] <= float(PID))]
    sum = table_sort.groupby('Header').sum('length')
    
    sum.reset_index(inplace=True)
    
    sum['Pyocin_Length'] = length
    
    sum['Query_Cov'] = ((sum['length']/sum['Pyocin_Length'])*100)
    
    sum = sum[(sum['Query_Cov'] >= float(NID))]
    
    table_drop = sum[["Header"]]
    
    return table_drop
    
R_table_drop = reformat_blast(R_pyocins, R_pyocin_PID, R_pyocin_NID)

F_table_drop = reformat_blast(F_pyocins, F_pyocin_PID, F_pyocin_NID)

R_and_F = R_table_drop.merge(F_table_drop, how="inner")

def missing_rows(df1, df2):
    df =  pd.merge(df1, df2, indicator=True, how='outer').query('_merge == "left_only"').drop(columns=['_merge'])
    return df

R_no_both = missing_rows(R_table_drop, R_and_F)
F_no_both = missing_rows(F_table_drop, R_and_F)

all_confirmed = pd.concat([R_no_both, F_no_both, R_and_F])

unconfirmed = missing_rows(all_confirmed, header)

R_no_both['Type'] = "Confirmed R"
F_no_both['Type'] = "Confirmed F"
R_and_F['Type'] = "Confirmed RF"
unconfirmed['Type'] = "Unconfirmed"

all_pyocins = pd.concat([R_no_both, F_no_both, R_and_F, unconfirmed])

all_pyocins.to_csv("Pyocin_typed.csv", index=False)

R_no_both_drop = R_no_both[["Header"]]
R_no_both_drop.to_csv("Confirmed_R_Pyocins.txt", index=False, header=False)

F_no_both_drop = F_no_both[["Header"]]
F_no_both_drop.to_csv("Confirmed_F_Pyocins.txt", index=False, header=False)

R_and_F_drop = R_and_F[["Header"]]
R_and_F_drop.to_csv("Confirmed_RF_Pyocins.txt", index=False, header=False)

unconfirmed_drop = unconfirmed[["Header"]]
unconfirmed_drop.to_csv("Confirmed_unconfirmed_Pyocins.txt", index=False, header=False)