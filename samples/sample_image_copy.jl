## header to provide surface and context
using Cairo
using Graphics

c = CairoRGBSurface(256,256);
cr = CairoContext(c);

save(cr);
set_source_rgb(cr,0.8,0.8,0.8);    # light gray
rectangle(cr,0.0,0.0,256.0,256.0); # background
fill(cr);
restore(cr);

save(cr);

# put image top left
s = read_from_png("data/mulberry.png"); 
Cairo.image(cr,s,0,0,128,128)

# copy inplace, so to apply copy as source, need coordinate translate
c1 = copy(cr)

save(cr)
translate(cr,128,0)
rectangle(cr,0,0,256,256)
set_source_surface(cr,c1.surface)
paint(cr)
restore(cr)

# copy centered part 
c2 = copy(cr,Graphics.BoundingBox(64,192,0,128))

save(cr)

rectangle(cr,0,0,256,256)
set_source_surface(cr,c2.surface,64,128)
paint(cr)
restore(cr)

## mark picture with current date
restore(cr); 
move_to(cr,0.0,12.0);
set_source_rgb(cr, 0,0,0);
show_text(cr,Libc.strftime(time()));
write_to_png(c,"sample_image_copy.png");
