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
    abstract type AbstractCPIMatch

Abstract type to represent matching from one base with other.
"""
abstract type AbstractCPIMatch end

"""
   FullCPIMatch

Structure representing a complete match between two CPI bases
(source and target)


`FullCPIMatch` stores a full correspondence between two CPI classifications,
including codes, descriptions, and optional weights on both sides of the mapping.

"""
Base.@kwdef struct FullCPIMatch <: AbstractCPIMatch
    codes_source::CODETYPE
    codes_target::CODETYPE
    descriptions_source::DESCTYPE
    descriptions_target::DESCTYPE
    ws_source::Vector{Float64}
    ws_target::Vector{Float64}
end

"""
    FullCPIMatch(df::DataFrame)

This constructor method returns a `FullCPIMatch` structure 
from the matching DataFrame between the source and target databases.

The `df` DataFrame has the following structure:
    - The first column contains the codes from the target database.
    - The second column contains the name or description of each of
     the categories in the target database.
    - The third column must contain the weights associated with the target database.
    - The fourth column contains the codes from the source database.
    - The fifth column contains the name or description of each 
        of the categories in the source database.
    - The sixth column must contain the weights associated with the source database.
    - An example of what this DataFrame might look like is shown below:
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
"""


function FullCPIMatch(df::DataFrame)
    return FullCPIMatch(
        codes_source = df[!, 4],
        codes_target = df[!, 1],
        descriptions_source = df[!, 5],
        descriptions_target = df[!, 2],
        ws_source = df[!, 3],
        ws_target = df[!, 6]
    )
end

"""
```
    target_code(match::AbstractCPIMatch, code::String)
Function to find a code from source base  in target base
```
"""
function target_code(match::AbstractCPIMatch, code_source::String)
    idx = findfirst(==(code_source), match.codes_source)
    if isnothing(idx)
        error("Code $code_source not found")
    end
    return match.codes_target[idx]
end


"""
```
    target_description(match::FullCPIMatch, code::String)
Function to find a name from source base in target base
```
"""
function target_description(match::FullCPIMatch, code_source::String)
    index = findfirst(==(code_source), match.codes_source)
    if isnothing(idx)
        error("Code $code_source not found")
    end
    return match.descriptions_target[index]

end

"""
```
    source_code(match::AbstractCPIMatch, code_target::String)
Function to find  codes in source base from target base. Matching is not
a biyective relation. 
```
"""
function source_code(match::AbstractCPIMatch, code_target::String)
    indxs = findall(==(code_target), match.codes_target)
    if isnothing(idxs)
        error("Code $code_target not found")
    end
    return [match.codes_source[index] for index in indxs]

end

"""
```
    source_description(match::FullCPIMatch, code_target::String)
Function to find  names in source base from target base. Matching is not
a biyective relation. 
```
"""
function source_description(match::FullCPIMatch, code_target::String)
    indxs = findall(==(code_target), match.codes_target)
    if isnothing(idxs)
        error("Code $code_target not found")
    end
    return [match.descriptions_source[index] for index in indxs]
end


function Base.show(io::IO, m::FullCPIMatch)
    table = hcat(
        m.codes_source,
        m.descriptions_source,
        m.ws_source,
        m.codes_target,
        m.descriptions_target,
        m.ws_target
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


"""
   CPIMatch

Structure representing a  match between two CPI bases
(source and target).

Contains only codes of items in bases
"""
Base.@kwdef struct CPIMatch <: AbstractCPIMatch
    codes_source::CODETYPE
    codes_target::CODETYPE
end

function CPIMatch(m::FullCPIMatch)
    return CPIMatch(
        codes_source = m.codes_source,
        codes_target = m.codes_target,
    )
end

function CPIMatch(df::DataFrame)
    return CPIMatch(
        codes_source = df[!, 4],
        codes_target = df[!, 1],
    )
end


function Base.show(io::IO, m::CPIMatch)
    table = hcat(
        m.codes_source,
        m.codes_target,
    )

    header = [
        "code_dest",
        "code_source",
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
