module CPIDataGT
    using Reexport
    using CSV, DataFrames
    using JLD2
    using Scratch
    @reexport using Dates
    @reexport using CPIDataBase

    # This package provides a function to load Guatemala's CPI dataset using the
    # infrastructure from CPIDataBase.

    ##  ------------------------------------------------------------------------
    #   Load and export IPC data
    #   ------------------------------------------------------------------------

    ## CPIDataBase objects
    export GT00, GT10               # VarCPIBase with month-to-month IPC variations
    export FGT00, FGT10             # FullCPIBase with complete IPC data (codes, names)
    export GTDATA                   # CountryStructure wrapper
    export CPITREE00, CPITREE10, CPITREE23, CPITREE24   # CPI hierarchical tree structures

    # Experimental
    export FGT23, GT23, GTDATA23
    export FGT24, GT24, GTDATA24

    ## DataFrames objects
    export DF_ITEMS_00, DF_ITEMS_10, DF_ITEMS_23, DF_ITEMS_24
    export DF_CPI_00, DF_CPI_10, DF_CPI_23, DF_CPI_24

    ## Functions to build and load data 
    export load_data, load_tree_data, load_dataframes

    ## Paths 
    PROJECT_ROOT = pkgdir(@__MODULE__)
    # JLD files directory (filled by Scratch)
    JLD_DIRECTORY = ""
    # URLs to download 2024 data
    include("current_CPI_urls.jl")

    # Access non-changing CSV files
    datadir(file) = joinpath(PROJECT_ROOT, "data", file)
    # Access CPI 2024 changing CSV files
    newdatadir(file) = joinpath(JLD_DIRECTORY, file)

    # Initialization
    function __init__()
        # Fill directory path for JLD files
        global JLD_DIRECTORY = @get_scratch!("data")
        global MAIN_DATAFILE = newdatadir("gtdata32.jld2")
        global DOUBLE_DATAFILE = newdatadir("gtdata64.jld2")
        global DATAFRAMES_FILE = newdatadir("gtdataframes.jld2")
        @info "Use load functions `CPIDataGT.load_data()`, `.load_tree_data()` or `.load_dataframes()`."
        @info "Use `CPIDataGT.update_data()` to get the most recent data."

    end

    """
        load_data(; full_precision = false)

    Load the data from the current CPI data file defined in `MAIN_DATAFILE` 
    with 32-bit precision. 
    - The option `full_precision` allows loading the data with 64-bit precision.
    """
    function load_data(; full_precision::Bool = false) 
        datafile = full_precision ? DOUBLE_DATAFILE : MAIN_DATAFILE 

        # Perform expensive data reading and saving if file does not exist
        isfile(datafile) || build_data() 

        # Load data
        @info "Loading Guatemalan CPI data..."
        global FGT00, FGT10, GT00, GT10, GTDATA = load(datafile, "fgt00", "fgt10", "gt00", "gt10", "gtdata")
        @info "Data loaded in exported structures `FGT00`, `FGT10`, `GT00`, `GT10` and `GTDATA`"
        global FGT23, GT23, GTDATA23 = load(datafile, "fgt23", "gt23", "gtdata_23")
        @info "CPI 2023 data on `FGT23`, `GT23`, and `GTDATA23`"
        global FGT24, GT24, GTDATA24 = load(datafile, "fgt24", "gt24", "gtdata_24")
        @info "CPI 2024 data on `FGT24`, `GT24`, and `GTDATA24`"
    end

    """
        load_dataframes(; full_precision = false)

    Load the DataFrames from the building process: 
    - DataFrames with information from the CPI items: 
        - `DF_ITEMS_00`, 
        - `DF_ITEMS_10`, 
        - `DF_ITEMS_23`, 
        - `DF_ITEMS_24`, 

    - DataFrames with index numbers: 
        - `DF_CPI_00`, 
        - `DF_CPI_10`, 
        - `DF_CPI_23`.
    """
    function load_dataframes() 
        datafile = DATAFRAMES_FILE

        # Perform expensive data reading and saving if file does not exist
        isfile(datafile) || build_data() 

        # Load data
        @info "Loading Guatemalan CPI DataFrames..."
        global DF_ITEMS_00, DF_ITEMS_10, DF_ITEMS_23, DF_ITEMS_24 = load(datafile, "gt00gb", "gt10gb", "gt23gb", "gt24gb")
        global DF_CPI_00, DF_CPI_10, DF_CPI_23, DF_CPI_24 = load(datafile, "gt_base00", "gt_base10", "gt_base23", "gt_base24")
        @info "Items DataFrames loaded: `DF_ITEMS_00`, `DF_ITEMS_10`, `DF_ITEMS_23` and `DF_ITEMS_24`" 
        @info "Index numbers DataFrames loaded: `DF_CPI_00`, `DF_CPI_10`, `DF_CPI_23` and `DF_CPI_24`"
    end

    """
        load_tree_data(; full_precision = false)

    Load the hierarchical CPI trees into the variables: 
    - `CPITREE00`,
    - `CPITREE10`,
    - `CPITREE23`,
    - `CPITREE24`,

    The option `full_precision` allows loading the data with
    64-bit precision.
    """
    function load_tree_data(; full_precision::Bool = false) 
        datafile = full_precision ? DOUBLE_DATAFILE : MAIN_DATAFILE 

        # Perform expensive data reading and saving if file does not exist
        isfile(datafile) || build_data() 

        # Load data
        @info "Loading the Guatemalan CPI hierarchical tree data..."
        global CPITREE00, CPITREE10, CPITREE23, CPITREE24 = load(datafile, "cpi_00_tree", "cpi_10_tree", "cpi_23_tree", "cpi_24_tree")
        @info "Data loaded in exported consts `CPITREE00`, `CPITREE10`, `CPITREE23` and `CPITREE24`"
    end


    """ 
        update_data()

    Downloads CSV files from Google Drive and updates the 2024 CPI data files.
    """ 
    function update_data() 
        @info "Downloading 2024 CPI data..."
        download(CPI2024_ITEMS_URL, newdatadir("Guatemala_GB_2024.csv"))
        download(CPI2024_GROUPS_URL, newdatadir("Guatemala_IPC_2024_Groups.csv"))
        download(CPI2024_INDEX_URL, newdatadir("Guatemala_IPC_2024.csv"))
        @info "Download complete."
        build_data()
    end

    """
        build_data()

    Builds the binary files from the CSV files.
    """
    function build_data()
        @info "Loading CPI data from CSV files..."

        ## Loading data from CSV files
        # 2000 Base
        gt_base00 = CSV.read(datadir("Guatemala_IPC_2000.csv"), DataFrame, normalizenames=true)
        gt00gb = CSV.read(datadir("Guatemala_GB_2000.csv"), DataFrame, types=[String, String, Float64])
        # 2010 Base
        gt_base10 = CSV.read(datadir("Guatemala_IPC_2010.csv"), DataFrame, normalizenames=true)
        gt10gb = CSV.read(datadir("Guatemala_GB_2010.csv"), DataFrame, types=[String, String, Float64])
        # 2023 Base
        gt_base23 = CSV.read(datadir("Guatemala_IPC_2023.csv"), DataFrame, normalizenames=true)
        gt23gb = CSV.read(datadir("Guatemala_GB_2023.csv"), DataFrame, types=[String, String, Float64])

        # Current 2024 Base
        newdatafile = newdatadir("Guatemala_IPC_2024.csv")
        isfile(newdatafile) || update_data()
        gt_base24 = CSV.read(newdatafile, DataFrame, normalizenames=true)
        gt24gb = CSV.read(newdatadir("Guatemala_GB_2024.csv"), DataFrame, types=[String, String, Float64])
        @info "Data successfully loaded from CSV files"

        ## Building data structures
        # 2000 Base
        full_gt00_64 = FullCPIBase(gt_base00, gt00gb)
        full_gt00_32 = convert(Float32, full_gt00_64)
        var_gt00_64 = VarCPIBase(full_gt00_64)
        var_gt00_32 = VarCPIBase(full_gt00_32)

        # 2010 Base
        full_gt10_64 = FullCPIBase(gt_base10, gt10gb)
        full_gt10_32 = convert(Float32, full_gt10_64)
        var_gt10_64 = VarCPIBase(full_gt10_64)
        var_gt10_32 = VarCPIBase(full_gt10_32)

        # 2023 Base
        full_gt23_64 = FullCPIBase(gt_base23, gt23gb)
        full_gt23_32 = convert(Float32, full_gt23_64)
        var_gt23_64 = VarCPIBase(full_gt23_64)
        var_gt23_32 = VarCPIBase(full_gt23_32)

        # 2024 Base
        full_gt24_64 = FullCPIBase(gt_base24, gt24gb)
        full_gt24_32 = convert(Float32, full_gt24_64)
        var_gt24_64 = VarCPIBase(full_gt24_64)
        var_gt24_32 = VarCPIBase(full_gt24_32)

        # Country data container structure 2000-2010 CPI bases
        gtdata_32 = UniformCountryStructure(var_gt00_32, var_gt10_32)
        gtdata_64 = UniformCountryStructure(var_gt00_64, var_gt10_64)

        # Container for data including 2023 CPI base
        gtdata23_32 = UniformCountryStructure(var_gt00_32, var_gt10_32, var_gt23_32)
        gtdata23_64 = UniformCountryStructure(var_gt00_64, var_gt10_64, var_gt23_64)

        # Experimental new data container including 2024 new CPI base
        gtdata24_32 = MixedCountryStructure(var_gt00_32, var_gt10_32, var_gt23_32, var_gt24_32)
        gtdata24_64 = MixedCountryStructure(var_gt00_64, var_gt10_64, var_gt23_64, var_gt24_64)

        @info "Successful building of data structures" GTDATA=gtdata_32 GTDATA23=gtdata23_32 GTDATA24=gtdata24_32

        ## Build the hierarchical IPC tree Base 2023
        groups24 = CSV.read(newdatadir("Guatemala_IPC_2024_Groups.csv"), DataFrame)

        cpi_24_tree_32 = CPITree(
            base = full_gt24_32, 
            groupsdf = groups24,
            characters = (3, 4, 5, 6, 8),
        )

        cpi_24_tree_64 = CPITree(
            base = full_gt24_64, 
            groupsdf = groups24,
            characters = (3, 4, 5, 6, 8),
        )

        ## Build the hierarchical IPC tree Base 2023
        groups23 = CSV.read(newdatadir("Guatemala_IPC_2023_Groups.csv"), DataFrame)

        cpi_23_tree_32 = CPITree(
            base = full_gt23_32, 
            groupsdf = groups23,
            characters = (3, 4, 5, 6, 8),
        )

        cpi_23_tree_64 = CPITree(
            base = full_gt23_64, 
            groupsdf = groups23,
            characters = (3, 4, 5, 6, 8),
        )

        ## Build the hierarchical IPC tree Base 2010
        groups10 = CSV.read(datadir("Guatemala_IPC_2010_Groups.csv"), DataFrame)

        cpi_10_tree_32 = CPITree(
            base = full_gt10_32, 
            groupsdf = groups10,
            characters = (3, 4, 5, 6, 8),
        )

        cpi_10_tree_64 = CPITree(
            base = full_gt10_64, 
            groupsdf = groups10,
            characters = (3, 4, 5, 6, 8),
        )


        ## Build the hierarchical CPI tree Base 2000
        groups00 = CSV.read(datadir("Guatemala_IPC_2000_Groups.csv"), DataFrame)

        cpi_00_tree_32 = CPITree(
            base = full_gt00_32, 
            groupsdf = groups00,
            characters = (3, 7),
        )

        cpi_00_tree_64 = CPITree(
            base = full_gt00_64, 
            groupsdf = groups00,
            characters = (3, 7),
        )

        ## Save data in JLD2 format for later loading 
        @info "Saving JLD2 data files"

        jldsave(MAIN_DATAFILE; 
            # FullCPIBase    
            fgt00 = full_gt00_32, 
            fgt10 = full_gt10_32, 
            fgt23 = full_gt23_32, 
            fgt24 = full_gt24_32, 
            # VarCPIBase
            gt00 = var_gt00_32, 
            gt10 = var_gt10_32, 
            gt23 = var_gt23_32, 
            gt24 = var_gt24_32, 
            # UniformCountryStructure
            gtdata = gtdata_32, 
            gtdata_23 = gtdata23_32,
            gtdata_24 = gtdata24_32,
            # Hierarchical trees
            cpi_00_tree = cpi_00_tree_32, 
            cpi_10_tree = cpi_10_tree_32,
            cpi_23_tree = cpi_23_tree_32,
            cpi_24_tree = cpi_24_tree_32,
        )

        jldsave(DOUBLE_DATAFILE; 
            # FullCPIBase    
            fgt00 = full_gt00_64, 
            fgt10 = full_gt10_64, 
            fgt23 = full_gt23_64, 
            fgt24 = full_gt24_64, 
            # VarCPIBase
            gt00 = var_gt00_64, 
            gt10 = var_gt10_64, 
            gt23 = var_gt23_64, 
            gt24 = var_gt24_64, 
            # UniformCountryStructure
            gtdata = gtdata_64, 
            gtdata_23 = gtdata23_64,
            gtdata_24 = gtdata24_64,
            # Hierarchical trees
            cpi_00_tree = cpi_00_tree_64, 
            cpi_10_tree = cpi_10_tree_64,
            cpi_23_tree = cpi_23_tree_64,
            cpi_24_tree = cpi_24_tree_64,
        )

        # Original DataFrames
        jldsave(DATAFRAMES_FILE; 
            # CPI base 2000
            gt_base00, gt00gb, 
            # IPC base 2010
            gt_base10, gt10gb,
            # IPC base 2023
            gt_base23, gt23gb,
            # IPC base 2024
            gt_base24, gt24gb,
        )

        @info "Data structures successfully saved"
    end
end
