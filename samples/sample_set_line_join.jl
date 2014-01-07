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
set_line_width (cr, 40.96);
move_to (cr, 76.8, 84.48);
rel_line_to (cr, 51.2, -51.2);
rel_line_to (cr, 51.2, 51.2);
set_line_join (cr, Cairo.CAIRO_LINE_JOIN_MITER); # default 
stroke (cr);

move_to (cr, 76.8, 161.28);
rel_line_to (cr, 51.2, -51.2);
rel_line_to (cr, 51.2, 51.2);
set_line_join (cr, Cairo.CAIRO_LINE_JOIN_BEVEL);
stroke (cr);

move_to (cr, 76.8, 238.08);
rel_line_to (cr, 51.2, -51.2);
rel_line_to (cr, 51.2, 51.2);
set_line_join (cr, Cairo.CAIRO_LINE_JOIN_ROUND);
stroke (cr);

## mark picture with current date
restore(cr);
move_to(cr,0.0,12.0);
set_source_rgb (cr, 0,0,0);
show_text(cr,strftime(time()));
write_to_png(c,"sample_set_line_join.png");
