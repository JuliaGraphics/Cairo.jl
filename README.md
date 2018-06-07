[![Build Status](https://travis-ci.org/JuliaGraphics/Cairo.jl.svg)](https://travis-ci.org/JuliaGraphics/Cairo.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/l3ega4q8o49edcn1?svg=true)](https://ci.appveyor.com/project/lobingera/cairo-jl-f7sfx)
[![Coverage Status](https://coveralls.io/repos/JuliaGraphics/Cairo.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/JuliaGraphics/Cairo.jl?branch=master)

[![Cairo](http://pkg.julialang.org/badges/Cairo_0.5.svg)](http://pkg.julialang.org/?pkg=Cairo)
[![Cairo](http://pkg.julialang.org/badges/Cairo_0.6.svg)](http://pkg.julialang.org/?pkg=Cairo)
[![Cairo](http://pkg.julialang.org/badges/Cairo_0.7.svg)](http://pkg.julialang.org/?pkg=Cairo)


## Bindings to the Cairo graphics library ##

Adaptation to [Cairo](https://www.cairographics.org/), a 2D graphics library with support for multiple output devices. 

(version of library assumed to be 1.12 or newer, installation assumes at least 1.8)

Some of the functions implemented by this wrapper may be documented in [Base.Graphics](http://docs.julialang.org/en/release-0.3/stdlib/graphics/).

There is an extensive set of [examples](samples/Samples.md).

On install, libraries will be compiled from source if not present.  [Diagnostics from BinDeps](https://github.com/JuliaLang/BinDeps.jl#diagnostics) may help avoid a lengthy compilation.
