"""
Extract data from GDX file and save as CSV files. This will also create a JSON
file with information about the sets and parameters in the GDX file. 

The script uses the `gamsapi` Python package to read the GDX file and extract the 
data. The extracted data is saved in a structured format, with sets and parameters 
stored in separate folders. Each set and parameter is saved as a CSV file, and 
the JSON file contains metadata such as domain and descriptions.

Created by: Mitch Phillipson
"""
#%%
from gdx_extract import extract_data

input_name = "national.gdx"
input_data_path = "gdx_data"
output_data_path = "national_data"

extract_data(input_name, input_data_path, output_data_path)



input_name = "household.gdx"

input_data_path = "gdx_data"
output_data_path = "hh_data"


extract_data(input_name, input_data_path, output_data_path)



# %%
