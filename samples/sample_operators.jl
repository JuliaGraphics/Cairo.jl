## header to provide surface and context
using Cairo
c = CairoARGBSurface(512,512);
cr = CairoContext(c);

save(cr);
set_source_rgb(cr,0.8,0.8,0.8);    # light gray
rectangle(cr,0.0,0.0,512.0,512.0); # background
fill(cr);
restore(cr);

save(cr);

function operator_demo(operator_index)
    c = CairoARGBSurface(126,98);
    cr = CairoContext(c);
    operators = [
        (Cairo.OPERATOR_CLEAR,"OPERATOR_CLEAR"),
        (Cairo.OPERATOR_SOURCE,"OPERATOR_SOURCE"),
        (Cairo.OPERATOR_OVER,"OPERATOR_OVER"),
        (Cairo.OPERATOR_IN,"OPERATOR_IN"),
        (Cairo.OPERATOR_OUT,"OPERATOR_OUT"),
        (Cairo.OPERATOR_ATOP,"OPERATOR_ATOP"),
        (Cairo.OPERATOR_DEST,"OPERATOR_DEST"),
        (Cairo.OPERATOR_DEST_OVER,"OPERATOR_DEST_OVER"),
        (Cairo.OPERATOR_DEST_IN,"OPERATOR_DEST_IN"),
        (Cairo.OPERATOR_DEST_OUT,"OPERATOR_DEST_OUT"),
        (Cairo.OPERATOR_DEST_ATOP,"OPERATOR_DEST_ATOP"),
        (Cairo.OPERATOR_XOR,"OPERATOR_XOR"),
        (Cairo.OPERATOR_ADD,"OPERATOR_ADD"),
        (Cairo.OPERATOR_SATURATE,"OPERATOR_SATURATE"),
        (Cairo.OPERATOR_MULTIPLY,"OPERATOR_MULTIPLY"),
        (Cairo.OPERATOR_SCREEN,"OPERATOR_SCREEN"),
        (Cairo.OPERATOR_OVERLAY,"OPERATOR_OVERLAY"),
        (Cairo.OPERATOR_DARKEN,"OPERATOR_DARKEN"),
        (Cairo.OPERATOR_LIGHTEN,"OPERATOR_LIGHTEN")]

    save(cr)
    set_source_rgb(cr, 0.9, 0.9, 0.9)
    paint(cr);

    save(cr)
    scale(cr,6,6)
    rectangle(cr, 0, 5, 12, 9)
    set_source_rgba(cr, 0.7, 0, 0, 0.8)
    fill(cr)

    set_operator(cr, operators[operator_index][1])

    rectangle(cr, 4, 2, 12, 9)
    set_source_rgba(cr, 0, 0, 0.9, 0.4)
    fill(cr)

    local_operator = get_operator(cr)
    restore(cr)

    move_to(cr,0,10)
    set_source_rgb(cr, 0,0,0)
    show_text(cr,operators[local_operator+1][2])

    restore(cr)
    c
end

for k=1:19
    save(cr)
    translate(cr,6+(128*mod(k-1,4)),24+(100*div(k-1,4)))
    set_source(cr,operator_demo(k))
    paint(cr)
    restore(cr)
end

## mark picture with current date
restore(cr);
move_to(cr,0.0,12.0);
set_source_rgb(cr, 0,0,0);
show_text(cr,Libc.strftime(time()));
write_to_png(c,"sample_operators.png");
