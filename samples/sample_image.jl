## header to provide surface and context
using Cairo
c = CairoRGBSurface(256,256);
cr = CairoContext(c);

save(cr);
set_source_rgb(cr,0.8,0.8,0.8);    # light gray
rectangle(cr,0.0,0.0,256.0,256.0); # background
fill(cr);
restore(cr);

save(cr);
## original example, following here

image = read_from_png("data/mulberry.png");
w = image.width; 
h = image.height;

translate(cr, 128.0, 128.0);
rotate(cr, 45* pi/180);
scale(cr, 256.0/w, 256.0/h);
translate(cr, -0.5*w, -0.5*h);

set_source_surface(cr, image, 0, 0);
paint(cr);
#surface_destroy (image);

## mark picture with current date
restore(cr);
move_to(cr,0.0,12.0);
set_source_rgb(cr, 0,0,0);
show_text(cr,Libc.strftime(time()));
write_to_png(c,"sample_image.png");
