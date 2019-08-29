# So that this test can be run independently
using Cairo
using Base64

include("shape_functions.jl")

@testset "Test that writing images to a Julia IO object works" begin
    c = CairoRGBSurface(256,256)
    cr = CairoContext(c)
    ddots4(cr,256,246,1.0,3000)
    buf = IOBuffer()
    pipe = Base64EncodePipe(buf)
    write_to_png(c,pipe)
    close(pipe)

    # Catch short writes

    str = String(take!(buf))
    str_data = codeunits(str)

    @test length(str_data) > 200
end
