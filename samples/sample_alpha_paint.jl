## header to provide surface and context
using Cairo
using Colors

c = CairoRGBSurface(256,256)
cr = CairoContext(c)

save(cr)

z = Array{RGB24}(undef, 2, 2)
c1 = convert(RGB24,colorant"grey20")
c2 = convert(RGB24,colorant"grey80")
z[1,1] = c1
z[1,2] = c2
z[2,1] = c2
z[2,2] = c1

img = CairoImageSurface(z)
pattern = CairoPattern(img)
pattern_set_extend(pattern, Cairo.EXTEND_REPEAT)
pattern_set_filter(pattern, Cairo.FILTER_BILINEAR)

m = CairoMatrix(1/8.0,0,0,1/8.0,0,0)

set_matrix(pattern, m)
set_source(cr, pattern)
paint(cr)
restore(cr)

save(cr)

# 5 uses of set_source

# color
save(cr)
rectangle(cr,16,32,224,32)
set_source(cr, colorant"red4")
fill(cr)
restore(cr)

# color with alpha
save(cr)
rectangle(cr,16,72,224,32)
set_source(cr, alphacolor(colorant"blue",0.5))
fill(cr)
restore(cr)

# image from surface
save(cr)
rectangle(cr,16,112,224,32)
clip(cr)
new_path(cr)
s = read_from_png("data/mulberry.png")
set_source(cr,s)
paint_with_alpha(cr,0.6)
restore(cr)

# image from context (from surface)
save(cr)
rectangle(cr,16,152,224,32)
clip(cr)
new_path(cr)
set_source(cr,creategc(s))
paint(cr)
restore(cr)

# image for surface with offset
save(cr)
rectangle(cr,16,192,224,32)
clip(cr)
set_source(cr,s,0.0,40.0)
paint(cr)
restore(cr)



## mark picture with current date
restore(cr)
move_to(cr,0.0,12.0)
set_source_rgb(cr, 0,0,0)
show_text(cr,Libc.strftime(time()))
write_to_png(c,"sample_alpha_paint.png")
