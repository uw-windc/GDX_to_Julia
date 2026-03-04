module ConvertGDX
    using JSON, DataFrames, CSV, NamedArrays, JLD2

    """
        set_df_to_array(df::DataFrame, info::JSON.Object)

    Convert a Dataframe representing a Set into an array.

    ## Arguments

    - `df::DataFrame`: The DataFrame containing the set data. It is expected to 
        have a single column with the set elements.
    - `info::JSON.Object`: The JSON object containing the set information. It is 
        expected to have a key "domain" which specifies the name of the column 
        in the DataFrame that contains the set elements. If the value of "domain" is "*", it will
        default to "uni".
    """
    function set_df_to_array(df::DataFrame, info::JSON.Object)
        data_col = only(info["domain"])
        data_col = data_col == "*" ? "uni" : data_col
        df = df[!, data_col]

    end

    """
        parameter_df_to_array(df::DataFrame, info::JSON.Object, sets::Dict{Symbol, Any})
    
    Convert a DataFrame representing a Parameter into an array. If the parameter is scalar, 
    return the value directly.

    ## Arguments

    - `df::DataFrame`: The DataFrame containing the parameter data. It is expected to 
        have a column named "value" containing the parameter values, and additional 
        columns for each dimension of the parameter.
    - `info::JSON.Object`: The JSON object containing the parameter information. 
        It is expected to have a key "domain" which specifies the names of the 
        columns in the DataFrame that contain the dimensions of the parameter.
    - `sets::Dict{Symbol, Any}`: A dictionary containing the sets that may be 
        used to define the dimensions of the parameter. The keys are the names of 
        the sets and the values are the arrays representing the sets. If a set is 
        not found in this dictionary, the unique values from the corresponding 
        column in the DataFrame will be used as the elements of that dimension.
    """
    function parameter_df_to_array(df::DataFrame, info::JSON.Object, sets::Dict{Symbol, Any})

        # If the parameter is scalar, return the value directly
        if length(names(df)) == 1
            return df[!, :value][1]
        end


        domain = []
        for (d, col) in zip(info["domain"], names(df))    
            set_elements = haskey(sets, Symbol(d)) ? sets[Symbol(d)] : nothing
            if isnothing(set_elements)
                @warn "Parameter: $Set $d not found for parameter with domain $d. Using unique column values as elements"
                set_elements = unique(df[!, col])
            end
            push!(domain,  set_elements)
        end

        out = NamedArray(zeros(length.(domain)...), Tuple(domain))
        idx = names(df)[begin:end-1]
        for row in eachrow(df)
            out[[Name(row[i]) for i in idx]...] = row[:value]
        end
        return out
    end


    """
        convert_to_julia(
            input_data_path::String,
            output_name::String,
            output_directory::String;
            set_conversion = (df, info) -> df,
            parameter_conversion = (df, info, sets) -> df
        )

    Convert the data extracted from a GDX file into a Julia data structure and save it as a JLD2 file.

    ## Arguments

    - `input_data_path::String`: The path to the directory containing the extracted data from the GDX file. 
        It is expected to have a "data_information.json" file and subdirectories "set" and "parameter" containing the corresponding CSV files.
    - `output_name::String`: The name of the output JLD2 file (without the .jld2 extension).
    - `output_directory::String`: The directory where the output JLD2 file will be saved. If the directory does not exist, it will be created.

    ## Keyword Arguments

    - `set_conversion`: A function that takes a DataFrame and the corresponding 
        set information from the JSON file, and returns a Julia data structure 
        representing the set. The default function simply returns the DataFrame as is.
    - `parameter_conversion`: A function that takes a DataFrame, the corresponding 
        parameter information from the JSON file, and the dictionary of sets, and returns a Julia data structure
        representing the parameter. The default function simply returns the DataFrame as is.
    """
    function convert_to_julia(
        input_data_path::String,
        output_name::String,
        output_directory::String;
        set_conversion = (df, info) -> df,
        parameter_conversion = (df, info, sets) -> df
    )


        if !isdir(output_directory)
            mkdir(output_directory)
        end

        out_data = Dict{Symbol, Any}()

        data_information = JSON.parsefile(joinpath(input_data_path, "data_information.json"))

        out_data[:sets] = Dict{Symbol, Any}()
        for (set_name, S) in data_information["sets"]
            df = CSV.read(joinpath(input_data_path, "set", "$set_name.csv"), DataFrame)# |> df -> NamedArray(df, (S,))
            out_data[:sets][Symbol(set_name)] = set_conversion(df, S)
        end


        out_data[:parameters] = Dict{Symbol, Any}()
        for (parm_name, parm_info) in data_information["parameters"]
            println(parm_name)

            df = CSV.read(joinpath(input_data_path, "parameter", "$parm_name.csv"), DataFrame)
            out_data[:parameters][Symbol(parm_name)] = parameter_conversion(df, parm_info, out_data[:sets])
        end

        @save joinpath(output_directory, "$output_name.jld2") data=out_data

        return out_data
    end

    export convert_to_julia, set_df_to_array, parameter_df_to_array

end