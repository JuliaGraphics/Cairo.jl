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

## api example, use set_line_type

dashes_by_name = [
    "solid",
    "dot",
    "dotdashed",
    "longdashed",
    "dash",
    "dotdotdashed",
    "dotdotdotdashed"]

set_line_width(cr, 3.0);

for k=1:7
    save(cr)
    set_line_type(cr, dashes_by_name[k])
    move_to(cr,16.0,16.0+(k*32.0))
    line_to(cr,240.0,16.0+(k*32.0))
    stroke(cr)
    restore(cr)
end

## mark picture with current date
restore(cr);
move_to(cr,0.0,12.0);
set_source_rgb(cr, 0,0,0);
show_text(cr,Libc.strftime(time()));
write_to_png(c,"sample_set_dash.png");
