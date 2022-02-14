# CPIDataGT

Este paquete provee los datos desagregados a nivel de gasto básico y la estructura jerárquica del Índice de Precios al Consumidor de Guatemala. 

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

julia> CPITREE00
CPITree{Group{Group{Item{Float32}, Float32}, Float32}} con datos
└─→ FullCPIBase{Float32, Float32}: 120 períodos × 218 gastos básicos Jan-01-Dec-10
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
CPITree{Group{Group{Group{Group{Group{Item{Float32}, Float32}, Float32}, Float32}, Float32}, Float32}} con datos
└─→ FullCPIBase{Float32, Float32}: 133 períodos × 279 gastos básicos Jan-11-Jan-22
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
CPITree{Group{Item{Float32}, Float32}} con datos
└─→ FullCPIBase{Float32, Float32}: 133 períodos × 279 gastos básicos Jan-11-Jan-22
_01111: Arroz de todos los tipos [0.63244]
└─ _0111101: Arroz [0.63244]

julia> compute_index(CPITREE00["_0"]) # Computa el IPC de la base 2000 del IPC
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

### Operaciones con subgrupos, grupos, agrupaciones y divisiones
```julia-repl
julia> CPITREE10["_04"] # División de vivienda, servicios y combustibles
CPITree{Group{Group{Group{Group{Item{Float32}, Float32}, Float32}, Float32}, Float32}} con datos
└─→ FullCPIBase{Float32, Float32}: 133 períodos × 279 gastos básicos Jan-11-Jan-22       
_04: Vivienda, agua, electricidad, gas y otros combustibles [12.614479]
├─ _041: Alquiler de vivienda [3.05838]
│  └─ _0411: Alquiler de vivienda [3.05838] 
│     └─ _04111: Alquiler de vivienda [3.05838]
│        └─ _0411101: Alquiler de vivienda [3.05838]
├─ _042: Conservación y reparación de la vivienda [1.91549]
│  ├─ _0421: Materiales para la conservación y reparación de la vivienda [1.13589]       
│  │  └─ _04211: Materiales diversos para reparación de vivienda [1.13589]
│  │     ├─ _0421101: Materiales diversos para reparación  de vivienda [0.95035]
│  │     ├─ _0421102: Trabajos para vivienda [0.1302]
│  │     └─ _0421103: Artículos para electricidad y grifería [0.05534]
│  └─ _0422: Servicios para la conservación y reparación de la vivienda [0.7796]
│     └─ _04221: Servicios de mantenimiento de vivienda [0.7796]
│        └─ _0422101: Servicio de mantenimiento de vivienda [0.7796]
├─ _043: Suministros de agua y servicios diversos de la vivienda [0.99164]
│  ├─ _0431: Suministro de agua y alcantarillado [0.75775]
│  │  └─ _04311: Agua potable [0.75775]
│  │     └─ _0431101: Agua potable [0.75775]
│  └─ _0432: Retiro de basuras [0.23389]
│     └─ _04321: Servicio de retiro de basura [0.23389]
│        └─ _0432101: Servicio de retiro de basura [0.23389]
└─ _044: Electricidad, gas y otros combustibles [6.6489697]
   ├─ _0441: Electricidad [3.29469]
   │  └─ _04411: Servicio de electricidad [3.29469]
   │     └─ _0441101: Servicio de electricidad [3.29469]
   ├─ _0442: Gas [1.19963]
   │  └─ _04421: Gas licuado [1.19963]
   │     └─ _0442101: Gas propano [1.19963]
   └─ _0443: Otros combustibles de uso doméstico [2.15465]
      └─ _04431: Otros combustibles de uso doméstico [2.15465]
         ├─ _0443101: Carbón [0.02683]
         └─ _0443102: Leña [2.12782]

julia> CPITREE10["_04"] |> compute_index
133-element Vector{Float32}:
 101.64841
 101.98954
 103.103966
 103.987465
 105.21368
 104.259155
 104.41899
   ⋮
 118.79173
 119.33157
 119.96757
 121.18594
 120.07671
 120.590294

julia> CPITREE10["_01171"] # Subgrupo de hortalizas del IPC
CPITree{Group{Item{Float32}, Float32}} con datos
└─→ FullCPIBase{Float32, Float32}: 133 períodos × 279 gastos básicos Jan-11-Jan-22       
_01171: Hortalizas frescas, refrigeradas o congeladas [4.0656104]
├─ _0117101: Tomate [0.92386]
├─ _0117102: Güisquil [0.1709]
├─ _0117103: Chile pimiento [0.05247]
├─ _0117104: Pepino [0.04363]
├─ _0117105: Güicoy [0.03236]
├─ _0117106: Repollo [0.06225]
├─ _0117107: Lechuga [0.03506]
├─ _0117108: Frijol [1.43142]
├─ _0117109: Ejotes [0.06273]
├─ _0117110: Elote [0.0469]
├─ _0117111: Cebolla [0.33668]
├─ _0117112: Papa [0.50577]
├─ _0117113: Zanahoria [0.11521]
├─ _0117114: Rábano [0.02637]
├─ _0117115: Remolacha [0.01255]
├─ _0117116: Yuca [0.02138]
├─ _0117117: Brócoli [0.02672]
├─ _0117118: Culantro [0.03903]
├─ _0117119: Hierbabuena [0.00774]
└─ _0117120: Otras legumbres y hortalizas [0.11258]

julia> CPITREE10["_01171"] |> compute_index |> varinteran
122-element Vector{Float32}:
  3.3400536
  4.0291905
 12.218655
 16.565704
 20.546616
 20.72475
 17.811954
  ⋮
 -0.7431388
  2.0720959
  0.10347366
 -1.5552223
  0.8624315
 -0.60409904
```