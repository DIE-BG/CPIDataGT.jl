module CPIDataGT
    using Reexport
    using CSV, DataFrames
    using JLD2
    @reexport using Dates
    @reexport using CPIDataBase

    # This package provides a function to load Guatemala's CPI dataset using the
    # infrastructure from CPIDataBase.

    ##  ------------------------------------------------------------------------
    #   Load and export IPC data
    #   ------------------------------------------------------------------------

    export GT00, GT10               # CPIBaseVar with month-to-month IPC variations
    export FGT00, FGT10             # FullCPIBase with complete IPC data (codes, names)
    export GTDATA                   # CountryStructure wrapper
    export CPITREE00, CPITREE10, CPITREE23     # CPI hierarchical tree structures

    # Experimental
    export FGT23, GT23, GTDATA23

    # Functions to load data 
    export load_data, load_tree_data

    PROJECT_ROOT = pkgdir(@__MODULE__)
    datadir(file) = joinpath(PROJECT_ROOT, "data", file)
    const MAIN_DATAFILE = datadir("gtdata32.jld2")
    const DOUBLE_DATAFILE = datadir("gtdata64.jld2")
    const DATAFRAMES_FILE = datadir("gtdataframes.jld2")

    function __init__()
        if !isfile(MAIN_DATAFILE)
            @warn "Main data file not found. Rebuild the package to generate the necessary files. Use `import Pkg; Pkg.build(\"CPIDataGT\")`"
        else
            @info "Loading Guatemalan data using `CPIDataGT.load_data()`"
            load_data()
        end
    end

    """
        load_data(; full_precision = false)

    Load the data from the main CPI data file defined in `MAIN_DATAFILE` 
    with 32-bit precision. 
    - The option `full_precision` allows loading the data with 64-bit precision.
    - Main file: `MAIN_DATAFILE = joinpath(pkgdir(@__MODULE__), "data", "gtdata32.jld2")`.
    """
    function load_data(; full_precision::Bool = false) 
        datafile = full_precision ? DOUBLE_DATAFILE : MAIN_DATAFILE 

        @info "Loading Guatemalan CPI data..."
        global FGT00, FGT10, GT00, GT10, GTDATA = load(datafile, "fgt00", "fgt10", "gt00", "gt10", "gtdata")
        @info "Data loaded in exported structures `FGT00`, `FGT10`, `GT00`, `GT10` y `GTDATA`"
        global FGT23, GT23, GTDATA23 = load(datafile, "fgt23", "gt23", "gtdata_exp")
        @info "Experimental new data on `FGT23`, `GT23`, `GTDATA23`"
    end

    """
        load_tree_data(; full_precision = false)

    Load the hierarchical CPI trees into the variables `CPITREE00` and
    `CPITREE10`. The option `full_precision` allows loading the data with
    64-bit precision.
    """
    function load_tree_data(; full_precision::Bool = false) 
        datafile = full_precision ? DOUBLE_DATAFILE : MAIN_DATAFILE 

        @info "Loading the Guatemalan CPI hierarchical tree data..."
        global CPITREE00, CPITREE10, CPITREE23 = load(datafile, "cpi_00_tree", "cpi_10_tree", "cpi_23_tree")
        @info "Data loaded in exported consts `CPITREE00`, `CPITREE10` and `CPITREE23`"
    end
end
