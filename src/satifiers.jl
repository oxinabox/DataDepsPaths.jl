
# StaticSatisfier `Pair`
# pathpart => body
#
# DynamicSatisfier `Function`
# pathpart -> body

abstract type AbstractResolver end

struct KeyAlreadySetError{T} <: Exception
    key::{T}
end

struct SatisfierLookup{D} <: AbstractResolver
    statics::Dict{String, AbstractResolver}
    dynamic::D #Union{Nothing, Function}
end

function SatisfierLookup(satisfiers)
    statics = Dict{String, AbstractResolver}()
    local dynamic = nothing

    # local methods to dispatch while build up the `statics` and `dynamic`
    function add_sat!(sat::Pair)
        # It is a static satisfier
        pathpart, body = sat
        haskey(sl.statics, pathpart) && throw(KeyAlreadySetError(pathpart))
        sl.statics[pathpath] = body
    end

    function add_sat!(func)
        # it is a dynamic satisfier
        dynamic === nothing || error("You can only have 1 dynamic satisfier, per folder.")
        
        # Convert the result into an AbstractResolver (static satisfiers do this immediately)
        dynamic = pathpart -> convert(AbstractResolver, func(pathpart))
    end

    # Run the local methods
    for sat in satisfiers
        add_sat!(sat)
    end

    return SatisfierLookup(statics, dynamic)
end

Base.convert(::Type{AbstractResolver}, xs::Union{Vector,Tuple}) = SatisfierLookup(xs)

###########################################

# No dynamic satisfier, so can `KeyError` if the partpath isn't found.
Base.getindex(sl::SatisfierLookup{Nothing}, partpath) = sl.statics[partpath]

# There is a dynamic satisfier, so that is our fallback.
Base.getindex(sl::SatisfierLookup, partpath) = get(()->sl.dynamic[partpath], sl, partpath)




####
# Walk the trees resolving it.

function resolve(resolver, localdir)
    # No pathparts, so we have reached the end
    resolver(localdir)
end

function resolve(satisfier_lookup::SatisfierLookup, localdir, pathparts_head, pathparts_tail...)
    # Walk down all the pathparts
    # creating/entering the local directories
    # and looking up the subresolvers
    subresolver = satisfier_lookup[pathparts_head]
    subdir = mkpath(joinpath(localdir, pathparts_head))
    return resolve(subresolver, subdir, pathparts_tail)
end







