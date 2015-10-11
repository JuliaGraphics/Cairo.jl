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

x=25.6;  y=128.0;
x1=102.4; y1=230.4;
x2=153.6; y2=25.6;
x3=230.4; y3=128.0;

move_to(cr, x, y);
curve_to(cr, x1, y1, x2, y2, x3, y3);

set_line_width(cr, 10.0);
stroke(cr);

set_source_rgba(cr, 1, 0.2, 0.2, 0.6);
set_line_width(cr, 6.0);
move_to(cr,x,y);   line_to(cr,x1,y1);
move_to(cr,x2,y2); line_to(cr,x3,y3);
stroke(cr);

## mark picture with current date
restore(cr);
move_to(cr,0.0,12.0);
set_source_rgb(cr, 0,0,0);
show_text(cr,Libc.strftime(time()));
write_to_png(c,"sample_curve_to.png");
