# CPIDataGT

Este paquete provee los datos del IPC de Guatemala. 

```julia-repl
julia> using CPIDataGT
[ Info: Precompiling CPIDataGT [39a16359-57f0-4aba-960c-77dbb3b4d29c]
[ Info: Cargando datos de Guatemala...
[ Info: Datos cargados en constantes exportadas `GT00`, `GT10` y `GTDATA`

julia> GTDATA
UniformCountryStructure{2, Float32, Float32} con 2 bases
|─> VarCPIBase{Float32, Float32}: 120 períodos × 218 gastos básicos Jan-01-Dec-10
|─> VarCPIBase{Float32, Float32}: 132 períodos × 279 gastos básicos Jan-11-Dec-21

julia> inflfn = InflationTotalCPI()
(::InflationTotalCPI) (generic function with 6 methods)

julia> first(inflfn(GTDATA), 10)
10-element Vector{Float32}:
 8.719707
 8.686531
 8.902168
 9.005642
 9.147143
 9.226537
 9.102476
 9.139263
 7.7949524
 7.1973443
```

*Nota: esta recopilación de datos proviene del sitio web del Instituto Nacional de Estadística.*
> https://www.ine.gob.gt/ine/estadisticas/bases-de-datos/indice-de-precios-al-consumidor/