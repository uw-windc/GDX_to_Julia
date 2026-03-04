"""
Extract data from GDX file and save as CSV files. This will also create a JSON
file with information about the sets and parameters in the GDX file. 

The script uses the `gamsapi` Python package to read the GDX file and extract the 
data. The extracted data is saved in a structured format, with sets and parameters 
stored in separate folders. Each set and parameter is saved as a CSV file, and 
the JSON file contains metadata such as domain and descriptions.

Created by: Mitch Phillipson
"""

import json
import os
import pandas as pd

import gams.transfer as gt


def set_name(S):
    if isinstance(S, str):
        return S
    return S.name


def extract_data(input_name, input_data_path, output_data_path):

    os.makedirs(output_data_path, exist_ok=True)
    os.makedirs(os.path.join(output_data_path, "set"), exist_ok=True)
    os.makedirs(os.path.join(output_data_path, "parameter"), exist_ok=True)


    W = gt.Container(os.path.join(input_data_path, input_name))


    data_information = {
        "sets": {},
        "parameters": {}
    }

    for S in W.getSets():

        data_information["sets"][S.name] = {
            "description": S.description,
            "domain": S.domain,
        }

        S.records.to_csv(os.path.join(output_data_path, "set", f"{S.name}.csv"), index=False)


    for P in W.getParameters():
        data_information["parameters"][P.name] = {
            "description": P.description,
            "domain": [set_name(S) for S in P.domain]
        }

        df = P.records

        if df is None:
            df = pd.DataFrame(columns=[set_name(S) for S in P.domain] + ["value"]) 

        df.to_csv(os.path.join(output_data_path, "parameter", f"{P.name}.csv"), index=False)

    with open(os.path.join(output_data_path, "data_information.json"), "w") as f:
        json.dump(data_information, f, indent=2)

    return data_information