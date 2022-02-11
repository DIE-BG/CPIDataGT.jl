# CPIDataGT

Este paquete provee los datos desagregados a nivel de gasto básico y la estructura jerárquica del IPC de Guatemala. 

*Nota: esta recopilación de datos proviene del sitio web del Instituto Nacional de Estadística.*
> https://www.ine.gob.gt/ine/estadisticas/bases-de-datos/indice-de-precios-al-consumidor/

## Utilizando los datos desagregados para computar la inflación

```julia-repl
julia> using CPIDataGT
[ Info: Cargando datos de Guatemala...
[ Info: Datos cargados en constantes exportadas `FGT00`, `FGT10`, `GT00`, `GT10` y `GTDATA`

julia> load_data()
[ Info: Cargando datos de Guatemala...
[ Info: Datos cargados en constantes exportadas `FGT00`, `FGT10`, `GT00`, `GT10` y `GTDATA`

julia> GTDATA
UniformCountryStructure{2, Float32, Float32} con 2 bases
└─→ VarCPIBase{Float32, Float32}: 120 períodos × 218 gastos básicos Jan-01-Dec-10
└─→ VarCPIBase{Float32, Float32}: 133 períodos × 279 gastos básicos Jan-11-Jan-22

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

## Estructura jerárquica del IPC

```julia-repl
julia> load_tree_data()
[ Info: Cargando árboles jerárquicos del IPC de Guatemala...
[ Info: Datos cargados en constantes exportadas `CPITREE00` y `CPITREE10`

julia> print_tree(CPITREE00)
_0: IPC [100.0]
├─ _01: Alimentos, bebidas no alcoholicas y comidas fuera del hogar [38.746143]
│  ├─ _011111: Arroz [0.483952]
│  ├─ _011121: Pan [2.826376]
│  ├─ _011131: Pastas frescas y secas [0.341395]
│  ├─ _011141: Productos de tortillería [1.691334]
│  ├─ _011142: Productos de pastelería y repostería [0.307019]
⋮     ⋮
└─ _09: Bienes y servicios diversos [6.524273]
   ├─ _091111: Corte de cabello [0.570456]
   ├─ _091121: Aparatos y accesorios para el cuidado personal [0.358383]
   ├─ _091131: Champú para el cabello [0.524601]
   ├─ _091132: Pasta dental [0.455329]
   ├─ _091133: Jabón de tocador en pastilla [0.365983]

julia> CPITREE10
Group{Group{Group{Group{Group{Item{Float32}, Float32}, Float32}, Float32}, Float32}, Float32}
_0: IPC [100.00001]
├─ _01: Alimentos y bebidas no alcohólicas [28.74909]
│  ├─ _011: Alimentos [26.57028] 
│  │  ├─ _0111: Pan y cereales [9.384171] 
│  │  │  ├─ _01111: Arroz de todos los tipos [0.63244] 
│  │  │  │  └─ _0111101: Arroz [0.63244]
│  │  │  ├─ _01112: Harinas y cereales [2.44551]
│  │  │  │  ├─ _0111201: Harina [0.17119]
│  │  │  │  ├─ _0111202: Maíz [1.33671]
│  │  │  │  └─ _0111203: Cereales [0.93761]
│  │  │  ├─ _01113: Pan y otros productos de panadería [2.8143198]
│  │  │  │  ├─ _0111301: Pan [2.61053]
│  │  │  │  ├─ _0111302: Galletas [0.08589]
│  │  │  │  └─ _0111303: Productos de repostería [0.1179]
⋮  ⋮  ⋮  ⋮     ⋮
└─ _12: Bienes y servicios diversos [7.1557097]
   ├─ _121: Cuidado personal [6.16713]
   │  ├─ _1211: Salones de peluquería y establecimientos de cuidados personales [0.99517]
   │  │  └─ _12111: Servicios de peluquería y cuidado personal [0.99517]
   │  │     ├─ _1211101: Servicio de peluquería [0.4915]
   │  │     └─ _1211102: Servicio de salón de belleza [0.50367]
   │  └─ _1212: Artículos para el cuidado personal [5.17196]
   │     ├─ _12121: Artículos para el cuidado personal [0.51829]
   │     │  ├─ _1212101: Artículos eléctricos para el cabello [0.02865]
   │     │  ├─ _1212102: Máquina de afeitar desechable [0.23341]
   │     │  └─ _1212103: Artículos diversos para el cuidado personal [0.25623]
⋮  ⋮  ⋮  ⋮

julia> CPITREE10["_01111"]
Group{Item{Float32}, Float32}
_01111: Arroz de todos los tipos [0.63244]
└─ _0111101: Arroz [0.63244]

julia> compute_index(CPITREE00["_0"], FGT00) # Computa el IPC de la base 2000 del IPC
120-element Vector{Float32}:
 101.34644
 102.07122
 102.5996
 103.018234
 103.31075
 104.02985
 104.86372
 106.151276
 106.48332
   ⋮
 187.33594
 188.2692
 188.98076
 189.05357
 189.6034
 190.61581
 192.0812
 192.24396
```