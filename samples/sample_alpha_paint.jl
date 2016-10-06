## header to provide surface and context
using Cairo
using Colors

c = CairoRGBSurface(256,256);
cr = CairoContext(c);

save(cr);

z = zeros(UInt32,2,2)
c1 = convert(RGB24,colorant"grey20")
c2 = convert(RGB24,colorant"grey80")
z[1,1] = c1
z[1,2] = c2
z[2,1] = c2
z[2,2] = c1

img = CairoRGBSurface(z)
pattern = CairoPattern(img);
pattern_set_extend(pattern, Cairo.EXTEND_REPEAT);

m = CairoMatrix(1/8.0,0,0,1/8.0,0,0);

set_matrix(pattern, m);
set_source(cr, pattern);
paint(cr);
restore(cr);

save(cr);

## original example, following here

save(cr)
rectangle(cr,16,16,224,32)
set_source(cr, colorant"red4")
fill(cr)
restore(cr)

save(cr)
rectangle(cr,16,64,224,32)
set_source(cr, alphacolor(colorant"blue",0.5))
fill(cr)
restore(cr)




## mark picture with current date
restore(cr);
move_to(cr,0.0,12.0);
set_source_rgb(cr, 0,0,0);
show_text(cr,Libc.strftime(time()));
write_to_png(c,"sample_alpha_paint.png");
