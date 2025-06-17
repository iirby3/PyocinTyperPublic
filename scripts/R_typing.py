import pandas as pd
import numpy as np
import sys

if __name__ == "__main__":
    R1_input = sys.argv[1]
    R2_input = sys.argv[2]
    R5_input = sys.argv[3]
    output_name = sys.argv[4]
    PID = sys.argv[5]
    NID = sys.argv[6]


def type_pyocins(df, type):
    blast_results = pd.read_table(df, names = ['qseqid', 'sseqid', 'Header', 'pident', 'nident', 'qlen', 'length', 'evalue', 'slen', 'qstart', 'qend', 'sstart', 'send'])
    blast_results['Query_Cov'] = ((blast_results['length']/blast_results['qlen'])*100)
    pyocin_nident = blast_results[~(blast_results['Query_Cov'] <= float(NID))]
    pyocin_pident = pyocin_nident[~(pyocin_nident['pident'] <= float(PID))]
    pyocin_pident['Pyocin_Type'] = type
    
    pyocin_list = pyocin_pident[["Header", "Pyocin_Type"]]
    return pyocin_list

R1_list = type_pyocins(f"{R1_input}", "R1")
R1_list_sub = R1_list[["Header"]]
R1_list_sub.to_csv(f"{output_name}_R1_list.txt", header=None, index=None)

R2_list = type_pyocins(f"{R2_input}", "R2")
R2_list_sub = R2_list[["Header"]]
R2_list_sub.to_csv(f"{output_name}_R2_list.txt", header=None, index=None)

R5_list = type_pyocins(f"{R5_input}", "R5")
R5_list_sub = R5_list[['Header']]
R5_list_sub.to_csv(f"{output_name}_R5_list.txt", header=None, index=None)

All_R = pd.concat([R1_list, R2_list, R5_list])

All_R.to_csv(f"{output_name}_pyocin_summary_table.csv", index=False)

