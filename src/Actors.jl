#
# This file is part of the Actors.jl Julia package, 
# MIT license, part of https://github.com/JuliaActors
#
"""
    Actors

A Julia library implementing the classical Actor Model.

The current stable, registered version is installed with
```julia
pkg> add Actors
```

The development version is installed with:
```julia
pkg> add("https://github.com/JuliaActors/Actors.jl")
```
"""
module Actors

"Gives the package version."
const version = v"0.1.1"

using Distributed, .Threads

include("interface.jl")
include("messages.jl")
include("links.jl")
include("com.jl")
include("actor.jl")

export  Msg, Response, Link, Func, 
        spawn, send!, become!, become, self, onmessage 

end