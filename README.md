# GDX to Julia

This example demonstrates how to extract data from a GDX file using the `gamsapi` package in Python and then load that data into Julia for further analysis. The process involves two main steps: extracting the data from the GDX file and then loading it into Julia.

## Python Side

Create virtual environment with conda. I believe Conda is required to use
the `gamsapi` package. The `gamsapi` package requires an installation of GAMS, download a [trial version of GAMS](https://www.gams.com/download/) if you do not have it installed. 

```bash
conda create -n gdx_to_julia python=3.13
```

Activate the environment

```bash
conda activate gdx_to_julia
```

Install the required packages

```bash
pip install -r requirements.txt
```

Update the `extract_data.py` script with the input path, name of your GDX file, and the output path where you want to save the extracted data. Two examples are provided in the script, one for national level data and one for household level data.


## Julia Side

Activate and instantiate the Julia environment. All code is located in the `main.jl` script. Four examples are provided, two for national level data and two for household level data. Each example has a section for exporting the data as a DataFrame and a section for exporting the data as a `NamedArray`. Update the input path and output name as needed. 

To load the data in a Julia script, add the `JLD2` package to the environment and use the `@load` macro to load the data.

```julia
@load "path/to/data.jld2" data
```

This will create the variable `data` containing the data that was saved in the JLD2 file. You can then access the sets and parameters using `data[:sets]` and `data[:parameters]` respectively.
