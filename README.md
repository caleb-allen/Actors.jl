# Actors.jl

Concurrent computing in Julia based on the Actor Model

[![stable docs](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaActors.github.io/Actors.jl/stable/)
[![dev docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaActors.github.io/Actors.jl/dev)
![CI](https://github.com/JuliaActors/Actors.jl/workflows/CI/badge.svg)
[![Coverage](https://codecov.io/gh/JuliaActors/Actors.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaActors/Actors.jl)

This is an ongoing rewrite of the old Actors.jl in order to provide

- an implementation of the **classical [Actor Model](https://en.wikipedia.org/wiki/Actor_model)** based on Julia's primitives `Task` and `Channel`,
- a **minimal interface** through which actors implemented in different Julia libraries can communicate,
- a **standard and common API** for actors for building a modern actor infrastructure.

`Actors` is part of the Julia GitHub group [`JuliaActors`](https://github.com/JuliaActors).

## Authors

- Oliver Schulz (until v0.1, Oct 2017)
- Paul Bayer (rewrite since v0.1.1, Nov 2020)

## License

MIT
