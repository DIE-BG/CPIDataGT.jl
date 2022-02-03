using CSV, DataFrames
using CPIDataBase
using JLD2

datadir(file) = joinpath("..", "data", file)
@info "Exportando datos del IPC en variables `gt00`, `gt10`, `gtdata`"

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
full_gt00 = FullCPIBase(gt_base00, gt00gb)
dgt00 = VarCPIBase(full_gt00)
gt00 = convert(Float32, dgt00)
# Base 2010
full_gt10 = FullCPIBase(gt_base10, gt10gb)
dgt10 = VarCPIBase(full_gt10)
gt10 = convert(Float32, dgt10)
# Estructura contenedora de datos del país
gtdata = UniformCountryStructure(gt00, gt10)
dgtdata = UniformCountryStructure(dgt00, dgt10)

@info "Construcción exitosa de estructuras de datos" gtdata dgtdata

## Guardar datos en formato JLD2 para su carga posterior 
@info "Guardando archivos JLD2"
jldsave(datadir("gtdata32.jld2"); gt00, gt10, gtdata)
jldsave(datadir("gtdata64.jld2"); gt00=dgt00, gt10=dgt10, gtdata=dgtdata)
jldsave(datadir("gtdataframes.jld2"); gt_base00, gt00gb, gt_base10, gt10gb)

@info "Estructuras de datos guardadas exitosamente"