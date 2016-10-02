# some collection of some painting plus support functions

"""
function ngray(base::Int64,digits::Int64,value::Int64)
Convert a value to a graycode with the given base and digits
"""
function ngray(base::Int64,digits::Int64,value::Int64)
	baseN = zeros(Int64,digits)
	gray = zeros(Int64,1,digits)

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

function hilbert_colored(cr,s,n1)
    zscale = 8;
    offset = 0;

    save(cr)
    c = Float64[]
    hilbert_curve(c,offset,offset,s,0,0)
    move_to(cr,offset*zscale,offset*zscale)
    scale(cr,zscale,zscale)
    set_line_cap(cr,Cairo.CAIRO_LINE_CAP_SQUARE)

    for k in zip(collect(1:2:(length(c)-2)),1:(length(1:2:(length(c)-2))))
        move_to(cr,c[k[1]],c[k[1]+1])
        line_to(cr,c[k[1]+2],c[k[1]+3])

        c1 = ngray(Int64(n1),3,k[2])
        set_source_rgb(cr,c1[1]/float(n1-1),c1[2]/float(n1-1),c1[3]/float(n1-1))

        stroke(cr)
        end
    
    restore(cr)
    end

function hilbert_main1(cr,s)
    zscale = 4;
    offset = 0;
    save(cr)
    c = Float64[]

    hilbert_curve(c,offset,offset,s,0,0)
    move_to(cr,0,0)
    scale(cr,zscale,zscale)

    for k=1:div(length(c),2)
        line_to(cr,c[(k*2)-1],c[(k*2)])
        end
    stroke(cr)
    restore(cr)
    end


function hdraw3()
    s = CairoImageSurface(512,512,Cairo.FORMAT_RGB24);

    cr = CairoContext(s);

    save(cr);
    set_source_rgb(cr,0.8,0.8,0.8)
    paint(cr);
    restore(cr);
    set_source_rgb(cr,0.4,0.0,0.8)
    set_line_width(cr,4.0)
    hilbert_colored(cr,64,12)

    write_to_png(s,"a.png")
end

function hdrawr()

    dim = 64
    zscale = 8

    s_length = dim * zscale
    s = CairoImageSurface(s_length,s_length,Cairo.FORMAT_ARGB32)
    cr = CairoContext(s)

    save(cr)
    set_source_rgb(cr,1.0,1.0,1.0)
    paint(cr)
    restore(cr)
    set_source_rgba(cr,0.0,0.0,1.0,0.5)

    set_line_width(cr,zscale)
    set_line_cap(cr,Cairo.CAIRO_LINE_CAP_SQUARE)
    translate(cr,zscale/2,zscale/2)
    
    save(cr)
    c = Float64[]

    hilbert_curve(c,0,0,dim,0,0)
    
    scale(cr,zscale,zscale)

    move_to(cr,0,0)
    for k=1:div(length(c),2)
        line_to(cr,c[(k*2)-1]+(0.1*rand(Float64)),c[(k*2)]+(0.1*rand(Float64)))
    end

    stroke(cr)
    restore(cr)
    
    write_to_png(s,"a.png")
end

""" function hdraw(s,dim,zscale)
draws a hilbert curve with dimension dim (power of 2) and scales the drawing with
zscale. Also the linewidth is set to zscale. So the area is filled exactly with color.
"""
function hdraw(s,dim,zscale)

    #dim = 64
    #zscale = 8

    #s_length = dim * zscale
    #s = CairoImageSurface(s_length,s_length,Cairo.FORMAT_ARGB32)
    cr = CairoContext(s)

    #save(cr)
    #set_source_rgb(cr,1.0,1.0,1.0)
    #paint(cr)
    #restore(cr)

    set_source_rgba(cr,0.0,0.0,1.0,0.5)

    set_line_width(cr,zscale)
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
    
    #write_to_png(s,"a.png")
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




    