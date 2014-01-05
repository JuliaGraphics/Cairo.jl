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

arc(cr, 128.0, 128.0, 76.8, 0, 2 * pi);
clip(cr);

new_path(cr); # current path is not consumed by cairo_clip()
rectangle(cr, 0, 0, 256, 256);
fill(cr);
set_source_rgb(cr, 0, 1, 0);
move_to(cr, 0, 0);
line_to(cr, 256, 256);
move_to(cr, 256, 0);
line_to(cr, 0, 256);
set_line_width(cr, 10.0);
stroke(cr);

## mark picture with current date
restore(cr);
move_to(cr,0.0,12.0);
set_source_rgb (cr, 0,0,0);
show_text(cr,strftime(time()));
write_to_png(c,"sample_clip.png");
