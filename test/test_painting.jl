# some collection of some painting plus support functions

"""
function ngray(base::Int,digits::Int,value::Int)
Convert a value to a graycode with the given base and digits
"""
function ngray(base::Int,digits::Int,value::Int)
    baseN = zeros(Int,digits)
    gray = zeros(Int,1,digits)

	for i=1:digits
		baseN[i] = value % base
		value = div(value,base)
	end

	shift = 0
	for i=digits:-1:1
		gray[i] = (baseN[i] + shift) % base
		shift = shift + base - gray[i]
	end
	gray
end

"""
function hilbert_curve(c,x,y,lg,i1,i2)
recursive hilbert curve (2D), appends pairs of x,y to c, lg = dimension/length
"""
function hilbert_curve(c,x,y,lg,i1,i2)
    if lg == 1
        append!(c,[x,y])
    else
        lg = lg / 2;
        hilbert_curve(c,x+i1*lg,y+i1*lg,lg,i1,1-i2);
        hilbert_curve(c,x+i2*lg,y+(1-i2)*lg,lg,i1,i2);
        hilbert_curve(c,x+(1-i1)*lg,y+(1-i1)*lg,lg,i1,i2);
        hilbert_curve(c,x+(1-i2)*lg,y+i2*lg,lg,1-i1,i2);
    end
end


function hilbert_colored(surf)

    zscale = 8;
    n1 = 8;
    cr = CairoContext(surf)

    c = Float64[]
    hilbert_curve(c,0,0,64,0,0)

    move_to(cr,0,0)

    translate(cr,zscale/2,zscale/2)
    scale(cr,zscale,zscale)
    set_line_width(cr,zscale/2)
    set_line_cap(cr,Cairo.CAIRO_LINE_CAP_SQUARE)

    for k in zip(collect(1:2:(length(c)-2)),1:(length(1:2:(length(c)-2))))
        move_to(cr,c[k[1]],c[k[1]+1])
        line_to(cr,c[k[1]+2],c[k[1]+3])

        c1 = ngray(n1,3,k[2])
        set_source_rgb(cr,c1[1]/float(n1-1),c1[2]/float(n1-1),c1[3]/float(n1-1))
        stroke(cr)

    end
end


""" function hdraw(s,dim,zscale,linewidth)
draws a hilbert curve with dimension dim (power of 2) and scales the drawing with
zscale.
"""
function hdraw(s,dim,zscale,linewidth)

    cr = CairoContext(s)

    set_source_rgba(cr,0.0,0.0,1.0,0.5)

    set_line_width(cr,linewidth)
    set_line_cap(cr,Cairo.CAIRO_LINE_CAP_SQUARE)
    translate(cr,zscale/2,zscale/2)

    save(cr)
    c = Float64[]

    hilbert_curve(c,0,0,dim,0,0)

    scale(cr,zscale,zscale)

    move_to(cr,0,0)
    for k=1:div(length(c),2)
        line_to(cr,c[(k*2)-1],c[(k*2)])
    end

    stroke(cr)
    restore(cr)
end

"""
function simple_hist(data)
    simple histogram by population count in a Dict
"""
function simple_hist(data)
    # poor man's hist -> pop count in Dict

    pc = Dict()

    for d in data
        if d in keys(pc)
            pc[d] += 1
        else
            pc[d] = 1
        end
    end
    pc
end

"""
function matrix_read(surface)
	paint the input surface into a matrix image of the same size to access
	the pixels.
"""
function matrix_read(surface)
	w = Int(surface.width)
	h = Int(surface.height)
	z = zeros(UInt32,w,h)
	surf = CairoImageSurface(z, Cairo.FORMAT_ARGB32)

    cr = CairoContext(surf)
    set_source_surface(cr,surface,0,0)
    paint(cr)

    surf.data
end
