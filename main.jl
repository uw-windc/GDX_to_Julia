include("src/ConvertGDX.jl")

using .ConvertGDX

using JLD2

# National 

## Export as DataFrame

input_data_path = "national_data"
output_name = "national"
output_directory = "output"

out_data = convert_to_julia(
    input_data_path, 
    output_name, 
    output_directory;
    )


@load joinpath(output_directory, "$output_name.jld2") data

## Export as NamedArray

output_name = "national_array"

out_data = convert_to_julia(
    input_data_path, 
    output_name, 
    output_directory;
    set_conversion = set_df_to_array,
    parameter_conversion = parameter_df_to_array
    )

# Household

## Export as DataFrame
input_data_path = "hh_data"
output_name = "household"
output_directory = "output"

out_data = convert_to_julia(
    input_data_path, 
    output_name, 
    output_directory;
    )


## Export as NamedArray

output_name = "household_array"

out_data = convert_to_julia(
    input_data_path, 
    output_name, 
    output_directory;
    set_conversion = set_df_to_array,
    parameter_conversion = parameter_df_to_array
    )

