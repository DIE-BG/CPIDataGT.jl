using CSV, DataFrames
using CPIDataBase
using JLD2

datadir(file) = joinpath("..", "data", file)
@info "Exportando datos del IPC en variables `FGT00`, `FGT10`, `GT00`, `GT10`, `GTDATA`"

## Carga de datos de archivos CSV
# Base 2000
gt_base00 = CSV.read(datadir("Guatemala_IPC_2000.csv"), DataFrame, normalizenames=true)
gt00gb = CSV.read(datadir("Guatemala_GB_2000.csv"), DataFrame, types=[String, String, Float64])
# Base 2010
gt_base10 = CSV.read(datadir("Guatemala_IPC_2010.csv"), DataFrame, normalizenames=true)
gt10gb = CSV.read(datadir("Guatemala_GB_2010.csv"), DataFrame, types=[String, String, Float64])

@info "Datos cargados exitosamente de archivos CSV"

## Construcción de estructuras de datos
# Base 2000
full_gt00_64 = FullCPIBase(gt_base00, gt00gb)
full_gt00_32 = convert(Float32, full_gt00_64)
var_gt00_64 = VarCPIBase(full_gt00_64)
var_gt00_32 = VarCPIBase(full_gt00_32)

# Base 2010
full_gt10_64 = FullCPIBase(gt_base10, gt10gb)
full_gt10_32 = convert(Float32, full_gt10_64)
var_gt10_64 = VarCPIBase(full_gt10_64)
var_gt10_32 = VarCPIBase(full_gt10_32)

# Estructura contenedora de datos del país
gtdata_32 = UniformCountryStructure(var_gt00_32, var_gt10_32)
gtdata_64 = UniformCountryStructure(var_gt00_64, var_gt10_64)

@info "Construcción exitosa de estructuras de datos" gtdata_32 gtdata_64

## Construir el árbol jerárquico del IPC Base 2010

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


## Construir el árbol jerárquico del IPC Base 2000
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

## Guardar datos en formato JLD2 para su carga posterior 
@info "Guardando archivos de datos JLD2"

jldsave(datadir("gtdata32.jld2"); 
    # FullCPIBase    
    fgt00 = full_gt00_32, 
    fgt10 = full_gt10_32, 
    # VarCPIBase
    gt00 = var_gt00_32, 
    gt10 = var_gt10_32, 
    # UniformCountryStructure
    gtdata = gtdata_32, 
    # Árboles jerárquicos
    cpi_00_tree = cpi_00_tree_32, 
    cpi_10_tree = cpi_10_tree_32
)

jldsave(datadir("gtdata64.jld2"); 
    # FullCPIBase    
    fgt00 = full_gt00_64, 
    fgt10 = full_gt10_64, 
    # VarCPIBase
    gt00 = var_gt00_64, 
    gt10 = var_gt10_64, 
    # UniformCountryStructure
    gtdata = gtdata_64, 
    # Árboles jerárquicos
    cpi_00_tree = cpi_00_tree_64, 
    cpi_10_tree = cpi_10_tree_64
)

# DataFrames originales
jldsave(datadir("gtdataframes.jld2"); 
    # IPC base 2000
    gt_base00, gt00gb, 
    # IPC base 2010
    gt_base10, gt10gb
)

@info "Estructuras de datos guardadas exitosamente"