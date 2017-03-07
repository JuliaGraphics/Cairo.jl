using Cairo
using Compat, Colors
using Base.Test: @test, @test_throws
@compat import Base.show

surf = CairoImageSurface(100, 200, Cairo.FORMAT_ARGB32)
@test width(surf) == 100
@test height(surf) == 200
ctx = CairoContext(surf)
@test width(ctx) == 100
@test height(ctx) == 200

surf = CairoImageSurface(fill(RGB24(0), 10, 10))
@test Cairo.format(surf) == RGB24
io = IOBuffer()
@compat show(io, MIME("image/png"), surf)
str = takebuf_string(io)
@test length(str.data) > 8 && str.data[1:8] == [0x89,0x50,0x4e,0x47,0x0d,0x0a,0x1a,0x0a]
surf = CairoImageSurface(fill(ARGB32(0), 10, 10))
@test Cairo.format(surf) == ARGB32

include("shape_functions.jl")
include("test_stream.jl")
include("tex.jl")

function test_pattern_get_surface()
    # test getting a surface from a surface pattern
    surf = CairoImageSurface(100, 200, Cairo.FORMAT_ARGB32)
    ctx = CairoContext(surf)
    Cairo.push_group(ctx)
    pattern = Cairo.pop_group(ctx)
    group_surf = Cairo.pattern_get_surface(pattern)
    @test group_surf.width == 100
    @test group_surf.height == 200

    # test that surfaces can't be gotten from non-surface patterns
    pattern = Cairo.pattern_create_linear(0, 0, 100, 200)
    @test_throws ErrorException Cairo.pattern_get_surface(pattern)
end

test_pattern_get_surface()

# Run all the samples
pth = joinpath(dirname(dirname(@__FILE__)), "samples")
fls = filter(str->endswith(str,".jl"), readdir(pth))

# filter known >= 1.12 -> sample_meshpattern.jl
if Cairo.libcairo_version < v"1.12.0"
    fls = filter(str->~isequal(str,"sample_meshpattern.jl"),fls)
end
display(fls)
for fl in fls
    include(joinpath(pth, fl))
end
pngfiles = filter(str->endswith(str,".png"), readdir())
for fl in pngfiles
    rm(fl)
end

# Test creating a CairoContext from a cairo_t pointer
surf = CairoImageSurface(fill(ARGB32(0), 10, 10))
ctx_ptr = ccall(
    (:cairo_create, Cairo._jl_libcairo),
    Ptr{Void}, (Ptr{Void}, ), surf.ptr)
ctx = CairoContext(ctx_ptr)
ccall(
    (:cairo_destroy,Cairo._jl_libcairo),
    Void, (Ptr{Void}, ), ctx_ptr)

@test isa(ctx, CairoContext)

nothing
