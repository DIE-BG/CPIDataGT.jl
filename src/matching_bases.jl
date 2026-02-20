## mathcing_bases.jl - Types and methods to operate matchings
"""
    const DESCTYPE = Union{Vector{String}, Nothing}
Possible types for names in the `names` field of a [`FullCPIMatch`](@ref).
"""
const DESCTYPE = Union{Vector{String}, Nothing}

"""
    const CODETYPE = Union{Vector{String}, Nothing}
Possible types for codes in the `codes` field of a [`FullCPIMatch`](@ref).
"""
const CODETYPE = Union{Vector{String}, Nothing}

# Type to represent matching between two FullCPIBase's
Base.@kwdef struct CodeMatchCell{V, W}
    inputs::V
    outputs::W
    method::Symbol = :auto
end


# Convenience constructor for automatic method
CodeMatchCell(inputs, outputs) = CodeMatchCell(inputs, outputs, :auto)

# Helper to return the matching object from source and destination codes
function getcpimatch(image, departure)
    methods = ["mean", "median", "zero"]
    if image[1] in methods
        matchobj = CodeMatchCell(inputs = departure, outputs = nothing, method = Symbol(image[1]))
    else
        matchobj = CodeMatchCell(inputs = departure, outputs = image)
    end
    return matchobj
end


##  ----------------------------------------------------------------------------
#   Every IPC base has many products. Base 2000 has 218 items, Base 2010 has 279
#   items, Base 2023 has 437 items, and Base 2024 has 436. The following objects
#   links Bases acording with a procedure explained in "B-TIMA extension".
#   ----------------------------------------------------------------------------

"""
    matchcell_list(df::DataFrame, domain::Symbol, codomain::Symbol)

Parse a many-to-many correspondence table stored in `df` and build a list of
match objects between a `domain` and a `codomain`.

# Arguments
- `df::DataFrame`: A DataFrame containing the correspondence table.
- `domain::Symbol`: Column name representing the source (domain) codes.
- `codomain::Symbol`: Column name representing the target (codomain) codes.

# Returns
- `Vector`: A vector of match objects produced by `getcpimatch`.

# Assumptions
- The DataFrame is pre-sorted so that codomain rows belonging to a given
  domain appear consecutively.
- `getcpimatch(codom, dom)` is defined elsewhere and returns a match object.
- `domain` values signal the beginning of a new group when non-missing.

# Example
```julia
matches = matchcell_list(df, :Code2010, :Code2023)
```
"""

function matchcell_list(df::DataFrame, domain::Symbol, codomain::Symbol)
    codom = String[]
    dom = String[]
    matchobjs = []
    for r in eachrow(df)
        domcode = r[domain]
        codomcode = r[codomain]

        (!ismissing(domcode) && startswith(domcode, ".")) && continue
        new = !ismissing(domcode)

        if new
            if !isempty(codom)
                a = getcpimatch(codom, dom)
                push!(matchobjs, a)
            end
            dom = String[]
            codom = String[]
            push!(dom, domcode)
        end
        push!(codom, codomcode)
    end
    return matchobjs
end

function matchcell_list_inverse(df::DataFrame, domain::Symbol, codomain::Symbol)
    original = matchcell_list(df, domain, codomain)
    filter!(m -> m.method == :auto, original)
    return inverted = [CodeMatchCell(inputs = m.outputs, outputs = m.inputs, method = m.method) for m in original]

end
"""
    abstract type AbstractCPIMatch

Abstract type to represent matching from one base with other.
"""
abstract type AbstractCPIMatch end

"""

    FullCPIMatch{V,W}

Container type representing a collection of `CodeMatchCell{V,W}` objects
describing correspondences between two `FullCPIBase` objects.

# Type Parameters
- `V`: Type of the input (domain) codes.
- `W`: Type of the output (codomain) collections stored in each `CodeMatchCell`.

# Fields
- `matches::Vector{CodeMatchCell{V,W}}`:
  Vector of match cells defining the mapping relationships.
- `domain::FullCPIBase`:
  The CPI base from which codes originate.
- `codomain::FullCPIBase`:
  The CPI base to which codes are mapped.

# Description
`CodeMatchList` represents a structured many-to-many (or one-to-many)
mapping between two CPI bases. Each element in `matches` defines the
correspondence between a single domain code and one or more codomain
codes.

The type parameters `V` and `W` ensure type stability across all stored
match cells.

# Example
```julia
matchlist = FullCPIMatch(
    matches = matches_vector,
    domain = CPITREE00,
    codomain = CPITREE23,
)
```
"""
Base.@kwdef struct FullCPIMatch <: AbstractCPIMatch
    matches::Vector{Any}
    domain::CPITree
    codomain::CPITree
end

"""
    FullCPIMatch(df::DataFrame)

This constructor method returns a `FullCPIMatch` structure 
from the matching DataFrame between the domain and codomain databases.
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


function FullCPIMatch(
        df::DataFrame,
        domain::CPITree,
        codomain::CPITree,
        codes_dom::Symbol,
        codes_codom::Symbol
    )
    matches = matchcell_list(df, codes_dom, codes_codom)
    return FullCPIMatch(matches, domain, codomain)

end

"""
     find_descriptions(m::FullCPIMatch, code::Vector{String}, domain::CPITree)
"""
function find_descriptions(m, code::Vector{String}, domain::CPITree)
    indxs = findall(x -> x in code, domain.group_codes)
    return reverse(domain.group_names[indxs])
end

function find_codes(m::FullCPIMatch, description::String, domain::CPITree)
    indxs = findfirst(x -> x == description, domain.group_names)
    return indxs, domain.group_codes[indxs]
end

"""
    find_codes_images(m::FullCPIMatch, codes::Vector{String})

Find all codomain codes that correspond to a given domain code in a `FullCPIMatch`.

# Arguments
- `m::FullCPIMatch`: The matching object containing the correspondence.
- `codes::Vector{String}`: The domain codes to search for.

# Returns
- A collection of output codes (images) for the given domain codes.

# Errors
Throws an error if the code is not found in the domain.
"""
function find_codes_images(m::FullCPIMatch, code::String)
    match_cells = m.matches
    all_inputs = vcat([match_cells[i].inputs for i in eachindex(match_cells)]...)
    indx = findall(==(code), all_inputs)
    isempty(indx) && error("Code $code not found")
    cells = match_cells[indx]
    images = vcat(getproperty.(cells, :outputs)...)

    if isnothing(first(images))
        method = first(cells).method
        @warn "Code $code has no corresponding images (method: $method)"
        images = method
    end
    return images
end


function find_codes_images(m::FullCPIMatch, codes::AbstractVector{<:String})
    return find_codes_images.(Ref(m), codes)
end

"""
    find_descriptions_images(m::FullCPIMatch, code::Vector{String})

Find the descriptions (names) of all codes in the codomain that correspond to a given domain code.

# Arguments
- `m::FullCPIMatch`: The matching object containing the correspondence.
- `code::AbstractString`: The domain code to search for.

# Returns
- A vector of description strings for the corresponding codomain codes.

# See Also
- [`find_codes_images`](@ref): Returns the codes instead of descriptions.
"""
function find_descriptions_images(m::FullCPIMatch, code::String)
    images = find_codes_images(m, code)
    if images isa Symbol
        @warn "No images found for code $code, returning method name instead: $images"
        indxs = nothing
        descriptions = string(images)
    else
        indxs = findall(x -> x in images, m.codomain.group_codes)
        isempty(indxs) && error("No matching codes found in codomain for code $code")
        descriptions = m.codomain.group_names[indxs]
    end
    return indxs, images, descriptions
end


function find_descriptions_images(m::FullCPIMatch, code::String)
    return find_descriptions_images.(Ref(m), code)
end
# TO DO: change show method for FullCPIMatch to print the matches in a nice way
function Base.show(io::IO, m::FullCPIMatch)
    for i in eachindex(m.matches)
        code = m.matches[i].inputs[1]
        indxs, images, descriptions = find_descriptions_images(m, code)
        table = hcat(indxs, images, descriptions)
        println(io, "↳ Domain: $code")
        println(io, "↳ Codomain: ")

        header = ["Item ", "Code", "Name"]
        #alignment = [:c, :l, :l, :r]
        PrettyTables.pretty_table(
            io, table;
            column_labels = header,
        )
    end
    return
end
