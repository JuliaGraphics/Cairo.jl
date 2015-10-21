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
set_line_width(cr, 30.0);
set_line_cap(cr, Cairo.CAIRO_LINE_CAP_BUTT); # default 
move_to(cr, 64.0, 50.0); line_to(cr, 64.0, 200.0);
stroke(cr);
set_line_cap(cr, Cairo.CAIRO_LINE_CAP_ROUND);
move_to(cr, 128.0, 50.0); line_to(cr, 128.0, 200.0);
stroke(cr);
set_line_cap(cr, Cairo.CAIRO_LINE_CAP_SQUARE);
move_to(cr, 192.0, 50.0); line_to(cr, 192.0, 200.0);
stroke(cr);

# draw helping lines 
set_source_rgb(cr, 1, 0.2, 0.2);
set_line_width(cr, 2.56);
move_to(cr, 64.0, 50.0);  line_to(cr, 64.0, 200.0);
move_to(cr, 128.0, 50.0); line_to(cr, 128.0, 200.0);
move_to(cr, 192.0, 50.0); line_to(cr, 192.0, 200.0);
stroke(cr);

## mark picture with current date
restore(cr);
move_to(cr,0.0,12.0);
set_source_rgb(cr, 0,0,0);
show_text(cr,Libc.strftime(time()));
write_to_png(c,"sample_set_line_cap.png");
