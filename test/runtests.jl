using Cairo
using Compat, Colors

@compat import Base.show

if VERSION >= v"0.5.0-dev+7720"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end


# Image Surface
@testset "Image Surface  " begin

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

end


@testset "Conversions    " begin

    include("shape_functions.jl")
    include("test_stream.jl")

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


end

@testset "TexLexer       " begin
    include("tex.jl")
end


# Run all the samples -> success, if output file exits
@testset "Samples        " begin

    samples_dir_path = joinpath(dirname(dirname(@__FILE__)), "samples")
    samples_files = filter(str->endswith(str,".jl"), readdir(samples_dir_path))

    for test_file_name in samples_files
        include(joinpath(samples_dir_path, test_file_name))
        output_png_name = replace(test_file_name,".jl",".png")
        @test isfile(output_png_name)
        rm(output_png_name)
    end

end 


# Run some painting, check the colored pixels by counting them
@testset "Bitmap Painting" begin

    include("test_painting.jl")

    # fill all
    z = zeros(UInt32,512,512);
    surf = CairoImageSurface(z, Cairo.FORMAT_ARGB32)
    # fills a 512x512 pixel area with blue,0.5 by using a hilbert curve of 
    # dimension 64 (scaled by 8 -> 512) and a linewidth of 8
    hdraw(surf,64,8,8) 

    d = simple_hist(surf.data)

    @test length(d) == 1 
    @test collect(keys(d))[1] == 0x80000080

    # fill 1/4 (upper quarter)
    z = zeros(UInt32,512,512);
    surf = CairoImageSurface(z, Cairo.FORMAT_ARGB32)
    # fills a 256x256 pixel area with blue,0.5 by using a hilbert curve of 
    # dimension 32 (scaled by 8 -> 256) and a linewidth of 8
    hdraw(surf,32,8,8) 

    d = simple_hist(surf.data)

    @test length(d) == 2 
    @test d[0x80000080] == 256*256

    # fill ~1/2 full, 
    z = zeros(UInt32,512,512);
    surf = CairoImageSurface(z, Cairo.FORMAT_ARGB32)
    # fills a 512x512 pixel area with blue,0.5 by using a hilbert curve of 
    # dimension 64 (scaled by 8 -> 512) and a linewidth of 4 -> 1/4 of pixels -16
    hdraw(surf,64,8,4) 

    d = simple_hist(surf.data)

    @test length(d) == 2 
    @test d[0x80000080] == ((512*256)-16)

end

# vector surfaces
@testset "Vector Surfaces" begin

    output_file_name = "a.svg"
    surf = CairoSVGSurface(output_file_name,512,512)
    hdraw(surf,64,8,4) 
    finish(surf)

    @test isfile(output_file_name)
    rm(output_file_name)

    io = IOBuffer()
    surf = CairoSVGSurface(io,512,512)
    hdraw(surf,64,8,4) 
    finish(surf)
    str = takebuf_string(io)
    @test length(str.data) > 31000 && str.data[1:13] == [0x3c,0x3f,0x78,0x6d,0x6c,0x20,0x76,0x65,0x72,0x73,0x69,0x6f,0x6e]

    output_file_name = "a.pdf"
    surf = CairoPDFSurface(output_file_name,512,512)
    hdraw(surf,64,8,4) 
    finish(surf)

    @test isfile(output_file_name)
    rm(output_file_name)

    io = IOBuffer()
    surf = CairoPDFSurface(io,512,512)
    hdraw(surf,64,8,4) 
    finish(surf)
    str = takebuf_string(io)
    @test length(str.data) > 3000 && str.data[1:7] == [0x25,0x50,0x44,0x46,0x2d,0x31,0x2e]

    output_file_name = "a.eps"
    surf = CairoEPSSurface(output_file_name,512,512)
    hdraw(surf,64,8,4) 
    finish(surf)

    @test isfile(output_file_name)
    rm(output_file_name)

    io = IOBuffer()
    surf = CairoEPSSurface(io,512,512)
    hdraw(surf,64,8,4) 
    finish(surf)
    str = takebuf_string(io)
    @test length(str.data) > 3000 && str.data[1:10] == [0x25,0x21,0x50,0x53,0x2d,0x41,0x64,0x6f,0x62,0x65]

end


# pixel/bitmap surfaces
@testset "Bitmap Surfaces" begin

    z = zeros(UInt32,512,512);
    surf = CairoImageSurface(z, Cairo.FORMAT_ARGB32)

    hilbert_colored(surf)
    d1 = matrix_read(surf)
    d = simple_hist(d1)

    @test length(d) == 513 # 512 colors and empty background

    surf = CairoARGBSurface(z)

    hilbert_colored(surf)
    d1 = matrix_read(surf)
    d = simple_hist(d1)

    @test length(d) == 513

    surf = CairoRGBSurface(z)

    hilbert_colored(surf)
    d1 = matrix_read(surf)
    d = simple_hist(d1)

    @test length(d) == 512 # black is included

end


nothing

