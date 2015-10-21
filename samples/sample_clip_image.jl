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

arc(cr, 128.0, 128.0, 76.8, 0, 2*pi);
clip(cr);
new_path(cr); # path not consumed by clip

image = read_from_png("data/mulberry.png"); # should be create_from_png
w = image.width;
h = image.height;

scale(cr, 256.0/w, 256.0/h);

set_source_surface(cr, image, 0, 0);
paint(cr);

#cairo_surface_destroy not used here

## mark picture with current date
restore(cr); 
move_to(cr,0.0,12.0);
set_source_rgb(cr, 0,0,0);
show_text(cr,Libc.strftime(time()));
write_to_png(c,"sample_clip_image.png");
