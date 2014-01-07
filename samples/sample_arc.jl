## header to provide surface and context
using Cairo
c = CairoRGBSurface(256,256);
cr = CairoContext(c);

save(cr);
set_source_rgb(cr,0.8,0.8,0.8);    # light gray
rectangle(cr,0.0,0.0,256.0,256.0); # background
fill(cr);
restore(cr);

## original example, following here
xc = 128.0;
yc = 128.0;
radius = 100.0;
angle1 = 45.0  * (pi/180.0);  # angles are specified 
angle2 = 180.0 * (pi/180.0);  # in radians           

set_line_width(cr, 10.0);
arc(cr, xc, yc, radius, angle1, angle2);
stroke(cr);

# draw helping lines 
set_source_rgba(cr, 1, 0.2, 0.2, 0.6);
set_line_width(cr, 6.0);

arc(cr, xc, yc, 10.0, 0, 2*pi);
fill(cr);

arc(cr, xc, yc, radius, angle1, angle1);
line_to(cr, xc, yc);
arc(cr, xc, yc, radius, angle2, angle2);
line_to(cr, xc, yc);
stroke(cr);

## mark picture with current date
move_to(cr,0.0,12.0);
set_source_rgb (cr, 0,0,0);
show_text(cr,strftime(time()));
write_to_png(c,"sample_arc.png");
