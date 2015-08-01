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
pipe = Base64Pipe(buf)
write_to_png(c,pipe)
close(pipe)
# Catch short writes
@assert length(takebuf_array(buf)) > 200
