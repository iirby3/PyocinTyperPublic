#!/usr/bin/env python3

import pandas as pd
import numpy as np
import sys

if __name__ == "__main__":
    all_typed = sys.argv[1]
    R_RF_subtyped = sys.argv[2]

all_typed_df = pd.read_csv(all_typed, sep = ",")

R_RF_subtyped_df = pd.read_csv(R_RF_subtyped, sep = ",")

merged = all_typed_df.merge(R_RF_subtyped_df, on = "Header", how = "left")

merged['Genome'] = merged['Header'].str.extract(r'_([^_]+)$')

merged.to_csv("final_summary_types_subtypes.csv", index = None)