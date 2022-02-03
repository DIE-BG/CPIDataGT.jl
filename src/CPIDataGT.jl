module CPIDataGT
    using Reexport
    @reexport using CPIDataBase
    using CSV, DataFrames
    using JLD2

    # This package provides a function to load Guatemala's CPI dataset using the
    # infrastructure from CPIDataBase.

    ##  ------------------------------------------------------------------------
    #   Cargar y exportar datos del IPC
    #   ------------------------------------------------------------------------

    export GT00, GT10 # Datos del IPC con precisión de 32 bits
    export GTDATA # CountryStructure wrapper
    export load_data

    PROJECT_ROOT = pkgdir(@__MODULE__)
    datadir(file) = joinpath(PROJECT_ROOT, "data", file)
    const MAIN_DATAFILE = datadir("gtdata32.jld2")
    const DOUBLE_DATAFILE = datadir("gtdata64.jld2")
    const DATAFRAMES_FILE = datadir("gtdataframes.jld2")

    function __init__()
        if !isfile(MAIN_DATAFILE)
            @warn "Archivo principal de datos no encontrado. Construya el paquete para generar los archivos de datos necesarios. Puede utilizar `import Pkg; Pkg.build(\"CPIDataGT\")`"
        else
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
        global GT00, GT10, GTDATA = load(datafile, "gt00", "gt10", "gtdata")
        @info "Datos cargados en constantes exportadas `GT00`, `GT10` y `GTDATA`"
        # Exportar datos del módulo 
        # @info "Archivo de datos cargado" gtdata
    end
end
