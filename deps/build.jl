using CSV, DataFrames
using CPIDataBase
using JLD2

datadir(file) = joinpath("..", "data", file)
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

# Country data container structure
gtdata_32 = UniformCountryStructure(var_gt00_32, var_gt10_32)
gtdata_64 = UniformCountryStructure(var_gt00_64, var_gt10_64)

# Experimental new data container
gtdata_32_exp = UniformCountryStructure(var_gt00_32, var_gt10_32, var_gt23_32)
gtdata_64_exp = UniformCountryStructure(var_gt00_64, var_gt10_64, var_gt23_64)

@info "Successful construction of data structures" gtdata_32 gtdata_64

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

jldsave(datadir("gtdata32.jld2"); 
    # FullCPIBase    
    fgt00 = full_gt00_32, 
    fgt10 = full_gt10_32, 
    fgt23 = full_gt23_32, 
    # VarCPIBase
    gt00 = var_gt00_32, 
    gt10 = var_gt10_32, 
    gt23 = var_gt23_32, 
    # UniformCountryStructure
    gtdata = gtdata_32, 
    gtdata_exp = gtdata_32_exp,
    # Hierarchical trees
    cpi_00_tree = cpi_00_tree_32, 
    cpi_10_tree = cpi_10_tree_32
)

jldsave(datadir("gtdata64.jld2"); 
    # FullCPIBase    
    fgt00 = full_gt00_64, 
    fgt10 = full_gt10_64, 
    fgt23 = full_gt23_64, 
    # VarCPIBase
    gt00 = var_gt00_64, 
    gt10 = var_gt10_64, 
    gt23 = var_gt23_64, 
    # UniformCountryStructure
    gtdata = gtdata_64, 
    gtdata_exp = gtdata_64_exp,
    # Hierarchical trees
    cpi_00_tree = cpi_00_tree_64, 
    cpi_10_tree = cpi_10_tree_64
)

# Original DataFrames
jldsave(datadir("gtdataframes.jld2"); 
    # CPI base 2000
    gt_base00, gt00gb, 
    # IPC base 2010
    gt_base10, gt10gb,
    # IPC base 2023
    gt_base23, gt23gb,
)

@info "Data structures successfully saved"