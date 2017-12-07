using Compat

using Cairo

# So that this test can be run independently -> ?
#if !isdefined(:ddots4)
#    include("shape_functions.jl")
#end

# Test that writing images to a Julia IO object works
c = CairoRGBSurface(256,256);
cr = CairoContext(c);
ddots4(cr,256,246,1.0,3000)
buf = IOBuffer()
pipe = Compat.Base64.Base64EncodePipe(buf)
write_to_png(c,pipe)
close(pipe)

# Catch short writes

str = String(take!(buf))
str_data = Vector{UInt8}(str)

@assert length(str_data) > 200
