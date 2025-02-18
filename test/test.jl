using CPIDataGT
using CSV, DataFrames

newdatadir(file) = joinpath(CPIDataGT.JLD_DIRECTORY, file)

# 2024 Base
newdatafile = newdatadir("Guatemala_IPC_2024.csv")
isfile(newdatafile) || update_data()
gt_base23 = CSV.read(newdatafile, DataFrame, normalizenames=true)
gt23gb = CSV.read(newdatadir("Guatemala_GB_2024.csv"), DataFrame, types=[String, String, Float64])
@info "Data successfully loaded from CSV files"

matdata = gt_base23[:, 2:end] |> Matrix
newdata = 100 * matdata ./ reshape(matdata[1, :], 1, :)
gt_base_23_copy = copy(gt_base23)
gt_base_23_copy[:, 2:end] .= newdata
gt_base_23_copy[1, 2:end] .= 100.
gt_base_23_copy

full_gt23_64 = FullCPIBase(gt_base_23_copy, gt23gb)
full_gt23_32 = convert(Float32, full_gt23_64)
var_gt23_64 = VarCPIBase(full_gt23_64)
var_gt23_32 = VarCPIBase(full_gt23_32)