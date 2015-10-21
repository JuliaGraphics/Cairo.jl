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

dashes = [50.0,  # ink 
          10.0,  # skip
          10.0,  # ink 
          10.0   # skip
          ];
#ndash = length(dashes); not implemented as ndash on set_dash
offset = -50.0;

set_dash(cr, dashes, offset); 
set_line_width(cr, 10.0);

move_to(cr, 128.0, 25.6);
line_to(cr, 230.4, 230.4);
rel_line_to(cr, -102.4, 0.0);
curve_to(cr, 51.2, 230.4, 51.2, 128.0, 128.0, 128.0);

stroke(cr);


## mark picture with current date
restore(cr);
move_to(cr,0.0,12.0);
set_source_rgb(cr, 0,0,0);
show_text(cr,Libc.strftime(time()));
write_to_png(c,"sample_dash.png");
