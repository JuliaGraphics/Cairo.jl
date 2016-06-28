[![Build Status](https://travis-ci.org/JuliaGraphics/Cairo.jl.svg)](https://travis-ci.org/JuliaGraphics/Cairo.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/mpuhyoy9ew187f08/branch/master?svg=true)](https://ci.appveyor.com/project/tkelman/cairo-jl/branch/master)

[![Cairo](http://pkg.julialang.org/badges/Cairo_0.3.svg)](http://pkg.julialang.org/?pkg=Cairo&ver=0.3)
[![Cairo](http://pkg.julialang.org/badges/Cairo_0.4.svg)](http://pkg.julialang.org/?pkg=Cairo&ver=0.4)

Bindings to the Cairo graphics library.

Some of the functions implemented by this wrapper may be documented in [Base.Graphics](http://docs.julialang.org/en/release-0.3/stdlib/graphics/).

There is an extensive set of [examples](samples/Samples.md).

On install, libraries will be compiled from source if not present.  [Diagnostics from BinDeps](https://github.com/JuliaLang/BinDeps.jl#diagnostics) may help avoid a lengthy compilation.

**Note** : If you already have Cairo installed on your system, `Pkg.test("Cairo")` might fail. Uninstall your system's Cairo, or unlink it from your path (On Mac OSX, the command to do that with Homebrew is `brew unlink cairo`). That way, `Pkg.build("Cairo")` would download the binaries to your `deps/usr`, and `Pkg.build("Cairo")` and `Pkg.test("Cairo")` would work again. 
