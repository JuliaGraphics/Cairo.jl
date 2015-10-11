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

move_to(cr, 50.0, 75.0);
line_to(cr, 200.0, 75.0);

move_to(cr, 50.0, 125.0);
line_to(cr, 200.0, 125.0);

move_to(cr, 50.0, 175.0);
line_to(cr, 200.0, 175.0);

set_line_width(cr, 30.0);
set_line_cap(cr, Cairo.CAIRO_LINE_CAP_ROUND);
stroke(cr);

## mark picture with current date
restore(cr);
move_to(cr,0.0,12.0);
set_source_rgb(cr, 0,0,0);
show_text(cr,Libc.strftime(time()));
write_to_png(c,"sample_multi_segment_caps.png");
