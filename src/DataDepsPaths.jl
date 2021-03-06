module DataDepsPaths
using DataDeps: register, AbstractDataDep

using FilePathsBase


struct DataDependency <: AbstractDataDep
    name::String
    message::String
    satisfiers::Vector{Satisfier}
end

struct Satisfier
    satisfies # DataDepPath → Bool
    resolve # () → AbstractPath
end

struct DataDepPath # Should we actually subtype AbstractPath here?
    name::String
    parts::Vector{String}
end

function satisfy(datadep::DataDependency, dd_path::DataDepPath)
    @assert(datadep.name == dd_path.name)

    for satisfier in datadep.satisfiers
        # We resolve all satifier's that work
        # because we also need to do things like
        # if we request `A/
    end
end
include("multistage_resolution.jl")

end # module
