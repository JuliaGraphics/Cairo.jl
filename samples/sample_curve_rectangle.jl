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

# custom shape wrapped in a function
function shape_curve_rectangle(cr::CairoContext,x0::Real,y0::Real,
    rect_width::Real, rect_height::Real, radius::Real)
    
    save(cr);
    
    x1=x0+rect_width;
    y1=y0+rect_height;
    
    if (rect_width == 0 || rect_height == 0)
        return;
        end
    if (rect_width/2 < radius) 
        if (rect_height/2 < radius) 
            move_to(cr, x0, (y0 + y1)/2);
            curve_to(cr, x0 ,y0, x0, y0, (x0 + x1)/2, y0);
            curve_to(cr, x1, y0, x1, y0, x1, (y0 + y1)/2);
            curve_to(cr, x1, y1, x1, y1, (x1 + x0)/2, y1);
            curve_to(cr, x0, y1, x0, y1, x0, (y0 + y1)/2);
        else 
            move_to(cr, x0, y0 + radius);
            curve_to(cr, x0 ,y0, x0, y0, (x0 + x1)/2, y0);
            curve_to(cr, x1, y0, x1, y0, x1, y0 + radius);
            line_to(cr, x1 , y1 - radius);
            curve_to(cr, x1, y1, x1, y1, (x1 + x0)/2, y1);
            curve_to(cr, x0, y1, x0, y1, x0, y1- radius);
        end
    
    else
        if (rect_height/2 < radius) 
            move_to(cr, x0, (y0 + y1)/2);
            curve_to(cr, x0 , y0, x0 , y0, x0 + radius, y0);
            line_to(cr, x1 - radius, y0);
            curve_to(cr, x1, y0, x1, y0, x1, (y0 + y1)/2);
            curve_to(cr, x1, y1, x1, y1, x1 - radius, y1);
            line_to(cr, x0 + radius, y1);
            curve_to(cr, x0, y1, x0, y1, x0, (y0 + y1)/2);
        else 
            move_to(cr, x0, y0 + radius);
            curve_to(cr, x0 , y0, x0 , y0, x0 + radius, y0);
            line_to(cr, x1 - radius, y0);
            curve_to(cr, x1, y0, x1, y0, x1, y0 + radius);
            line_to(cr, x1 , y1 - radius);
            curve_to(cr, x1, y1, x1, y1, x1 - radius, y1);
            line_to(cr, x0 + radius, y1);
            curve_to(cr, x0, y1, x0, y1, x0, y1- radius);
        end
    end
    close_path(cr);

    set_source_rgb(cr, 0.5, 0.5, 1);
    fill_preserve(cr);
    set_source_rgba(cr, 0.5, 0, 0, 0.5);
    set_line_width(cr, 10.0);
    stroke(cr);
    restore(cr);
    return;
    end

shape_curve_rectangle(cr,25.6,25.6,204.8,204.8,102.4);    

## mark picture with current date
restore(cr);
move_to(cr,0.0,12.0);
set_source_rgb(cr, 0,0,0);
show_text(cr,Libc.strftime(time()));
write_to_png(c,"sample_curve_rectangle.png");
