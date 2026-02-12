## mathcing_bases.jl - Types and methods to operate matchings
"""
    const DESCTYPE = Union{Vector{String}, Nothing}
Tipos posibles para los nombres en el campo `names` de un [`FullCPIBase`](@ref).
"""
const DESCTYPE = Union{Vector{String}, Nothing}

"""
    const CODETYPE = Union{Vector{String}, Nothing}
Tipos posibles para los códigos en el campo `codes` de un [`FullCPIBase`](@ref).
"""
const CODETYPE = Union{Vector{String}, Nothing}
##  ----------------------------------------------------------------------------
#   Every IPC base has many products. Base 2000 has 218 items, Base 2010 has 279
#   items, Base 2023 has 437 items, and Base 2024 has 436. The following objects
#   links Bases acording with a procedure explained in "B-TIMA extension".
#   ----------------------------------------------------------------------------

"""
    abstract type AbstractCPIMatch{T <: AbstractFloat}

Abstract type to represent matching from one base with other.
"""
abstract type AbstractCPIMatch{T <: AbstractFloat} end

"""
   FullCPIMatch

Contenedor genérico para 
El tipo `T` representa el tipo de datos para representar los valores de punto
flotante. El tipo `B` representa el tipo del campo `baseindex`; por ejemplo,
`Float32` o `Vector{Float32}`.

"""
Base.@kwdef struct FullCPIMatch
    code_source::CODETYPE
    code_destination::CODETYPE
    name_source::DESCTYPE
    name_destination::DESCTYPE
    w_source
    w_destination
end

"""
    FullCPIMatch(df::DataFrame)

Este método constructor devuelve una estructura `FullCPIMatch` a partir del
DataFrame de matching entre la Base fuente y la Base destino.`

- El DataFrame `df` posee la siguiente estructura: 
    - La primera columna contiene los códigos de la base destino. 
    - La segunda columna contiene el nombre o la descripción de cada una de las
      categorías de la base destino. 
    - La tercer columna, debe contener las ponderaciones asociadas a la base destino.
    - La cuarta columna contiene los códigos de la base fuente. 
    - La quinta columna contiene el nombre o la descripción de cada una de las
      categorías de la base fuente. 
    - La quinta columna, debe contener las ponderaciones asociadas a la base fuente.  
    - Un ejemplo de cómo puede verse este DataFrame es el siguiente: 
```
437×6 DataFrame
 Row │ code_b00  name_b00                           w_b00      code_b23  name_b23                           w_b23     
     │ String7   String                             Float64    String15  String                             Float64
─────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │ _011111   Arroz                              0.483952   _0111101  Arroz                              0.522367
   2 │ _011151   Maíz                               0.828818   _0111102  Maíz                               0.711087
   3 │ _011153   Harina de maíz                     0.0936981  _0111201  Harina de trigo                    0.0559046
   4 │ _011153   Harina de maíz                     0.0936981  _0111202  Harina de maíz                     0.170136
  ⋮  │    ⋮                      ⋮                      ⋮         ⋮                      ⋮                      ⋮
 434 │ _093121   Gastos por servicios funerarios    0.289885   _1390902  Servicios funerarios               0.154298
 435 │ _094111   Gastos por servicios diversos pa…  0.151793   _1390903  Servicios de registro civil        0.0459723
 436 │ _061121   Adquisición de otros vehí…         0.155166   _1390904  Pago de impuestos de circulació…   0.139208
 437 │ _075131   Gastos por servicios sociales, f…  0.818188   _1390905  Fiestas y celebraciones            0.871514
```


```
"""


function FullCPIMatch(df::DataFrame)
    return FullCPIMatch(
        code_source = df[!, 4],
        code_destination = df[!, 1],
        name_source = df[!, 5],
        name_destination = df[!, 2],
        w_source = df[!, 3],
        w_destination = df[!, 6]
    )
end


function show(io::IO, m::FullCPIMatch)
    table = hcat(
        m.code_source,
        m.name_source,
        m.w_source,
        m.code_destination,
        m.name_destination,
        m.w_destination
    )

    header = [
        "code_dest",
        "name_dest",
        "w_dest",
        "code_source",
        "name_source",
        "w_source",
    ]
    println(io)
    return PrettyTables.pretty_table(
        io, table;
        column_labels = header,
        vertical_crop_mode = :middle,
        show_row_number_column = true,
        backend = :text,
        column_label_width_based_on_first_line_only = true,
    )
end


function Base.show(io::IO, m::FullCPIMatch)
    return show(io, m)
end
