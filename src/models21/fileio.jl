using FileIO
import Knet

# How to save/load weights in a way that is robust to code change (except the order of weights ;)

function getweights(model; atype=Knet.atype())
    # Can't just to Params: there are non-Param weights in BatchNorm, should we call these Const?
    # On the other hand we don't want to save param.opt variables, or do it optionally
    # We could make bn mean/var Params with lr=0, but an optimizer may change that. Add a freeze flag to Param?
    w = []
    deepmap(atype, model) do a
        push!(w, convert(Array,a))
    end
    return w
end


function setweights!(model, weights; atype=Knet.atype())
    # The trouble is a newly initialized model does not have weights until first input
    n = 0
    deepmap(atype, model) do w
        n += 1
        @assert size(w) == size(weights[n]) "$(size(w)) != $(size(weights[n]))"
        copyto!(w, weights[n])
    end
    @assert n == length(weights)  "The number of weights do not match: $n != $(length(weights))"
    return model
end


function setweights!(model, file::String; atype=Knet.atype())
    setweights!(model, load(file, "weights"); atype)
end


function saveweights(file::String, model; atype=Knet.atype())
    save(file, "weights", getweights(model; atype))
end


