# So that this test can be run independently
using Cairo
if !isdefined(:ddots4)
    include("shape_functions.jl")
end

# Test that writing images to a Julia IO object works
c = CairoRGBSurface(256,256);
cr = CairoContext(c);
ddots4(cr,256,246,1.0,3000)
buf = IOBuffer()
pipe = Base64EncodePipe(buf)
write_to_png(c,pipe)
close(pipe)
# Catch short writes

    if VERSION >= v"0.6.0-dev.1954"
        str = String(take!(buf))
        str_data = Vector{UInt8}(str)
    else
        str = takebuf_string(buf)    
        str_data = str.data
    end        

@assert length(str_data) > 200
