module CPIDataGT
    using Reexport
    using CSV, DataFrames
    using JLD2
    @reexport using Dates
    @reexport using CPIDataBase

    # This package provides a function to load Guatemala's CPI dataset using the
    # infrastructure from CPIDataBase.

    ##  ------------------------------------------------------------------------
    #   Cargar y exportar datos del IPC
    #   ------------------------------------------------------------------------

    export GT00, GT10 # VarCPIBase con variaciones intermensuales del IPC
    export FGT00, FGT10 # FullCPIBase con datos completos del IPC (códigos, nombres)
    export GTDATA # CountryStructure wrapper
    export CPITREE00, CPITREE10 # Estructuras de árboles jerárquicos del IPC

    # Funciones para cargar datos 
    export load_data, load_tree_data

    PROJECT_ROOT = pkgdir(@__MODULE__)
    datadir(file) = joinpath(PROJECT_ROOT, "data", file)
    const MAIN_DATAFILE = datadir("gtdata32.jld2")
    const DOUBLE_DATAFILE = datadir("gtdata64.jld2")
    const DATAFRAMES_FILE = datadir("gtdataframes.jld2")

    function __init__()
        if !isfile(MAIN_DATAFILE)
            @warn "Archivo principal de datos no encontrado. Construya el paquete para generar los archivos de datos necesarios. Puede utilizar `import Pkg; Pkg.build(\"CPIDataGT\")`"
        else
            @info "Loading Guatemalan data using `CPIDataGT.load_data()`"
            load_data()
        end
    end

    """
        load_data(; full_precision = false)

    Carga los datos del archivo principal de datos del IPC definido en `MAIN_DATAFILE` 
    con precisión de 32 bits. 
    - La opción `full_precision` permite cargar los datos con precisión de 64 bits.
    - Archivo principal: `MAIN_DATAFILE = joinpath(pkgdir(@__MODULE__), "data", "gtdata32.jld2")`.
    """
    function load_data(; full_precision::Bool = false) 
        datafile = full_precision ? DOUBLE_DATAFILE : MAIN_DATAFILE 

        @info "Cargando datos de Guatemala..."
        global FGT00, FGT10, GT00, GT10, GTDATA = load(datafile, "fgt00", "fgt10", "gt00", "gt10", "gtdata")
        @info "Datos cargados en constantes exportadas `FGT00`, `FGT10`, `GT00`, `GT10` y `GTDATA`"
    end

    """
        load_tree_data(; full_precision = false)

    Carga los árboles jerárquicos del IPC en las variables `CPITREE00` y
    `CPITREE10`. La opción `full_precision` permite cargar los datos con
    precisión de 64 bits.
    """
    function load_tree_data(; full_precision::Bool = false) 
        datafile = full_precision ? DOUBLE_DATAFILE : MAIN_DATAFILE 

        @info "Cargando árboles jerárquicos del IPC de Guatemala..."
        global CPITREE00, CPITREE10 = load(datafile, "cpi_00_tree", "cpi_10_tree")
        @info "Datos cargados en constantes exportadas `CPITREE00` y `CPITREE10`"
    end
end
