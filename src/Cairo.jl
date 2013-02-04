include(joinpath(Pkg.dir(),"Cairo","deps","ext.jl"))
require("Color")

module Cairo
using Base
using Color

include("constants.jl")

export CairoSurface, finish, destroy, status,
    CairoRGBSurface, CairoPDFSurface, CairoEPSSurface, CairoXlibSurface,
    CairoQuartzSurface, CairoWin32Surface, CairoARGBSurface, CairoSVGSurface, 
	surface_create_similar, CairoPattern, get_source, pattern_set_filter,
    write_to_png, CairoContext, save, restore, show_page, clip, clip_preserve,
    fill, fill_preserve, new_path, new_sub_path, close_path, paint, stroke,
    stroke_preserve, set_fill_type, set_line_width, rotate, set_source_rgb,
    set_source_surface,
    move_to, line_to, rel_line_to, rel_move_to, set_source_rgba, rectangle,
    circle, arc, set_dash, set_clip_rect, set_font_from_string, set_markup,
    get_layout_size, update_layout, show_layout, image, read_from_png,
    RendererState, color_to_rgb, Renderer, CairoRenderer, PNGRenderer,
    PDFRenderer, EPSRenderer, save_state, restore_state, move, lineto,
    linetorel, line, rect, ellipse, symbol, symbols, set, get,
    open, close, curve, polygon, layout_text, text, textwidth, textheight,
    TeXLexer, tex2pango, SVGRenderer, stroke

import Base.get, Base.open, Base.fill, Base.close, Base.symbol

const _jl_libcairo = :libcairo
const _jl_libpango = "libpango-1.0"
const _jl_libpangocairo = "libpangocairo-1.0"
const _jl_libgobject = "libgobject-2.0"
const _jl_libglib = "libglib-2.0"

function cairo_write_to_ios_callback(s::Ptr{Void}, buf::Ptr{Uint8}, len::Uint32)
    n = ccall(:ios_write, Uint, (Ptr{Void}, Ptr{Void}, Uint), s, buf, len)
    ret::Int32 = (n == len) ? 0 : 11
end

function cairo_write_to_stream_callback(s::AsyncStream, buf::Ptr{Uint8}, len::Uint32)
    n = write(s,buf,len)
    ret::Int32 = (n == len) ? 0 : 11
end

type CairoSurface
    ptr::Ptr{Void}
    width::Float64
    height::Float64
    data::Array{Uint32,2}

    function CairoSurface(ptr::Ptr{Void}, w, h)
        self = new(ptr, w, h)
        finalizer(self, destroy)
        self
    end

    function CairoSurface(ptr::Ptr{Void}, w, h, data)
        self = new(ptr, w, h, data)
        finalizer(self, destroy)
        self
    end
end

width(surface::CairoSurface) = surface.width
height(surface::CairoSurface) = surface.height

for name in ("destroy","finish","flush","mark_dirty")
    @eval begin
        $(Base.symbol(name))(surface::CairoSurface) =
            ccall(($(string("cairo_surface_",name)),_jl_libcairo),
                Void, (Ptr{Void},), surface.ptr)
    end
end

function status(surface::CairoSurface)
    ccall((:cairo_surface_status,_jl_libcairo),
        Int32, (Ptr{Void},), surface.ptr)
end

function CairoRGBSurface(w::Real, h::Real)
    ptr = ccall((:cairo_image_surface_create,_jl_libcairo),
        Ptr{Void}, (Int32,Int32,Int32), CAIRO_FORMAT_RGB24, w, h)
    CairoSurface(ptr, w, h)
end

function CairoARGBSurface(w::Real, h::Real)
    ptr = ccall((:cairo_image_surface_create,_jl_libcairo),
        Ptr{Void}, (Int32,Int32,Int32), CAIRO_FORMAT_ARGB32, w, h)
    CairoSurface(ptr, w, h)
end

function CairoImageSurface(img::Array{Uint32,2}, format::Integer)
    data = img'
    w,h = size(data)
    stride = format_stride_for_width(format, w)
    @assert stride == 4w
    ptr = ccall((:cairo_image_surface_create_for_data,_jl_libcairo),
        Ptr{Void}, (Ptr{Void},Int32,Int32,Int32,Int32),
        data, format, w, h, stride)
    CairoSurface(ptr, w, h, data)
end
CairoARGBSurface(img) = CairoImageSurface(img, CAIRO_FORMAT_ARGB32)
CairoRGBSurface(img) = CairoImageSurface(img, CAIRO_FORMAT_RGB24)

## PDF ##

function CairoPDFSurface(stream::IOStream, w::Real, h::Real)
    callback = cfunction(cairo_write_to_ios_callback, Int32, (Ptr{Void},Ptr{Uint8},Uint32))
    ptr = ccall((:cairo_pdf_surface_create_for_stream,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Ptr{Void}, Float64, Float64), callback, stream, w, h)
    CairoSurface(ptr, w, h)
end

function CairoPDFSurface{T<:AsyncStream}(stream::T, w::Real, h::Real)
    callback = cfunction(cairo_write_to_stream_callback, Int32, (T,Ptr{Uint8},Uint32))
    ptr = ccall((:cairo_pdf_surface_create_for_stream,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Any, Float64, Float64), callback, stream, w, h)
    CairoSurface(ptr, w, h)
end

function CairoPDFSurface(filename::String, w_pts::Real, h_pts::Real)
    ptr = ccall((:cairo_pdf_surface_create,_jl_libcairo), Ptr{Void},
        (Ptr{Uint8},Float64,Float64), bytestring(filename), w_pts, h_pts)
    CairoSurface(ptr, w_pts, h_pts)
end

## EPS ##

function CairoEPSSurface(stream::IOStream, w::Real, h::Real)
    callback = cfunction(cairo_write_to_ios_callback, Int32, (Ptr{Void},Ptr{Uint8},Uint32))
    ptr = ccall((:cairo_ps_surface_create_for_stream,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Ptr{Void}, Float64, Float64), callback, stream, w, h)
    ccall((:cairo_ps_surface_set_eps,_jl_libcairo), Void,
        (Ptr{Void},Int32), ptr, 1)
    CairoSurface(ptr, w, h)
end

function CairoEPSSurface{T<:AsyncStream}(stream::T, w::Real, h::Real)
    callback = cfunction(cairo_write_to_stream_callback, Int32, (T,Ptr{Uint8},Uint32))
    ptr = ccall((:cairo_ps_surface_create_for_stream,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Any, Float64, Float64), callback, stream, w, h)
    ccall((:cairo_ps_surface_set_eps,_jl_libcairo), Void,
        (Ptr{Void},Int32), ptr, 1)
    CairoSurface(ptr, w, h)
end

function CairoEPSSurface(filename::String, w_pts::Real, h_pts::Real)
    ptr = ccall((:cairo_ps_surface_create,_jl_libcairo), Ptr{Void},
        (Ptr{Uint8},Float64,Float64), bytestring(filename), w_pts, h_pts)
    ccall((:cairo_ps_surface_set_eps,_jl_libcairo), Void,
        (Ptr{Void},Int32), ptr, 1)
    CairoSurface(ptr, w_pts, h_pts)
end

## Xlib ##

function CairoXlibSurface(display, drawable, visual, w, h)
    ptr = ccall((:cairo_xlib_surface_create,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Int32, Ptr{Void}, Int32, Int32),
                display, drawable, visual, w, h)
    CairoSurface(ptr, w, h)
end

## Quartz ##

function CairoQuartzSurface(context, w, h)
    ptr = ccall((:cairo_quartz_surface_create_for_cg_context,_jl_libcairo),
                Ptr{Void}, (Ptr{Void}, Uint32, Uint32),
                context, w, h)

    CairoSurface(ptr,w,h)
end

## Win32 ##

function CairoWin32Surface(hdc,w,h)
	ptr = ccall((:cairo_win32_surface_create, _jl_libcairo), Ptr{Void}, (Ptr{Void},), hdc)
	CairoSurface(ptr,w,h)
end

## SVG ##

function CairoSVGSurface(stream::IOStream, w, h)
    callback = cfunction(cairo_write_to_ios_callback, Int32, (Ptr{Void},Ptr{Uint8},Uint32))
    ptr = ccall((:cairo_svg_surface_create_for_stream,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Ptr{Void}, Float64, Float64), callback, stream, w, h)
    CairoSurface(ptr, w, h)
end

function CairoSVGSurface{T<:AsyncStream}(stream::T, w::Real, h::Real)
    callback = cfunction(cairo_write_to_stream_callback, Int32, (T,Ptr{Uint8},Uint32))
    ptr = ccall((:cairo_svg_surface_create_for_stream,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Any, Float64, Float64), callback, stream, w, h)
    CairoSurface(ptr, w, h)
end

function CairoSVGSurface(filename::String, w::Real, h::Real)
    ptr = ccall((:cairo_svg_surface_create,_jl_libcairo), Ptr{Void},
        (Ptr{Uint8},Float64,Float64), bytestring(filename), w, h)
    CairoSurface(ptr, w, h)
end

## PNG ##

function read_from_png(filename::String)
    ptr = ccall((:cairo_image_surface_create_from_png,_jl_libcairo),
        Ptr{Void}, (Ptr{Uint8},), bytestring(filename))
    w = ccall((:cairo_image_surface_get_width,_jl_libcairo),
        Int32, (Ptr{Void},), ptr)
    h = ccall((:cairo_image_surface_get_height,_jl_libcairo),
        Int32, (Ptr{Void},), ptr)
    CairoSurface(ptr, w, h)
end

function write_to_png(surface::CairoSurface, filename::String)
    ccall((:cairo_surface_write_to_png,_jl_libcairo), Void,
        (Ptr{Uint8},Ptr{Uint8}), surface.ptr, bytestring(filename))
end

function surface_create_similar(s::CairoSurface, w, h)
    ptr = ccall((:cairo_surface_create_similar,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Int32, Int32, Int32),
                s.ptr, CAIRO_CONTENT_COLOR_ALPHA, w, h)
    CairoSurface(ptr, w, h)
end

function format_stride_for_width(format::Integer, width::Integer)
    ccall((:cairo_format_stride_for_width,_jl_libcairo), Int32,
        (Int32,Int32), format, width)
end

# -----------------------------------------------------------------------------

type CairoContext
    ptr::Ptr{Void}
    surface::CairoSurface
    layout::Ptr{Void} # cache PangoLayout

    function CairoContext(surface::CairoSurface)
        ptr = ccall((:cairo_create,_jl_libcairo),
            Ptr{Void}, (Ptr{Void},), surface.ptr)
        layout = ccall((:pango_cairo_create_layout,_jl_libpangocairo),
            Ptr{Void}, (Ptr{Void},), ptr)
        self = new(ptr, surface, layout)
        finalizer(self, destroy)
        self
    end
end

function destroy(ctx::CairoContext)
    ccall((:g_object_unref,_jl_libgobject), Void, (Ptr{Void},), ctx.layout)
    _destroy(ctx)
end

macro _CTX_FUNC_V(NAME, FUNCTION)
    quote
        $(esc(NAME))(ctx::CairoContext) =
            ccall(($(string(FUNCTION)),_jl_libcairo),
                Void, (Ptr{Void},), ctx.ptr)
    end
end

@_CTX_FUNC_V _destroy cairo_destroy
@_CTX_FUNC_V save cairo_save
@_CTX_FUNC_V restore cairo_restore
@_CTX_FUNC_V show_page cairo_show_page
@_CTX_FUNC_V clip cairo_clip
@_CTX_FUNC_V clip_preserve cairo_clip_preserve
@_CTX_FUNC_V fill cairo_fill
@_CTX_FUNC_V fill_preserve cairo_fill_preserve
@_CTX_FUNC_V new_path cairo_new_path
@_CTX_FUNC_V new_sub_path cairo_new_sub_path
@_CTX_FUNC_V close_path cairo_close_path
@_CTX_FUNC_V paint cairo_paint
@_CTX_FUNC_V stroke cairo_stroke
@_CTX_FUNC_V stroke_preserve cairo_stroke_preserve

macro _CTX_FUNC_I(NAME, FUNCTION)
    quote
        $(esc(NAME))(ctx::CairoContext, i0::Integer) =
            ccall(($(string(FUNCTION)),_jl_libcairo),
                Void, (Ptr{Void},Int32), ctx.ptr, i0)
    end
end

@_CTX_FUNC_I set_fill_type cairo_set_fill_rule

macro _CTX_FUNC_D(NAME, FUNCTION)
    quote
        $(esc(NAME))(ctx::CairoContext, d0::Real) =
            ccall(($(string(FUNCTION),_jl_libcairo)),
                Void, (Ptr{Void},Float64), ctx.ptr, d0)
    end
end

@_CTX_FUNC_D set_line_width cairo_set_line_width
@_CTX_FUNC_D rotate cairo_rotate
@_CTX_FUNC_D set_font_size cairo_set_font_size

macro _CTX_FUNC_DD(NAME, FUNCTION)
    quote
        $(esc(NAME))(ctx::CairoContext, d0::Real, d1::Real) =
            ccall(($(string(FUNCTION)),_jl_libcairo),
                Void, (Ptr{Void},Float64,Float64), ctx.ptr, d0, d1)
    end
end

@_CTX_FUNC_DD line_to cairo_line_to
@_CTX_FUNC_DD move_to cairo_move_to
@_CTX_FUNC_DD rel_line_to cairo_rel_line_to
@_CTX_FUNC_DD rel_move_to cairo_rel_move_to
@_CTX_FUNC_DD scale cairo_scale
@_CTX_FUNC_DD translate cairo_translate

macro _CTX_FUNC_DDD(NAME, FUNCTION)
    quote
        $(esc(NAME))(ctx::CairoContext, d0::Real, d1::Real, d2::Real) =
            ccall(($(string(FUNCTION)),_jl_libcairo),
                Void, (Ptr{Void},Float64,Float64,Float64), ctx.ptr, d0, d1, d2)
    end
end

@_CTX_FUNC_DDD set_source_rgb cairo_set_source_rgb

macro _CTX_FUNC_DDDD(NAME, FUNCTION)
    quote
        $(esc(NAME))(ctx::CairoContext, d0::Real, d1::Real, d2::Real, d3::Real) =
            ccall(($(string(FUNCTION)),_jl_libcairo), Void,
                (Ptr{Void},Float64,Float64,Float64,Float64),
                ctx.ptr, d0, d1, d2, d3)
    end
end

@_CTX_FUNC_DDDD set_source_rgba cairo_set_source_rgba
@_CTX_FUNC_DDDD rectangle cairo_rectangle

macro _CTX_FUNC_DDDDD(NAME, FUNCTION)
    quote
        $(esc(NAME))(ctx::CairoContext, d0::Real, d1::Real, d2::Real, d3::Real, d4::Real) =
            ccall(($(string(FUNCTION)),_jl_libcairo), Void,
                (Ptr{Void},Float64,Float64,Float64,Float64,Float64),
                ctx.ptr, d0, d1, d2, d3, d4)
    end
end

@_CTX_FUNC_DDDDD arc cairo_arc

function set_dash(ctx::CairoContext, dashes::Vector{Float64})
    ccall((:cairo_set_dash,_jl_libcairo), Void,
        (Ptr{Void},Ptr{Float64},Int32,Float64), ctx.ptr, dashes, length(dashes), 0.)
end

function set_source_surface(ctx::CairoContext, s::CairoSurface, x::Real, y::Real)
    ccall((:cairo_set_source_surface,_jl_libcairo), Void,
        (Ptr{Void},Ptr{Void},Float64,Float64), ctx.ptr, s.ptr, x, y)
end

function set_font_from_string(ctx::CairoContext, str::String)
    fontdesc = ccall((:pango_font_description_from_string,_jl_libpango),
        Ptr{Void}, (Ptr{Uint8},), bytestring(str))
    ccall((:pango_layout_set_font_description,_jl_libpango), Void,
        (Ptr{Void},Ptr{Void}), ctx.layout, fontdesc)
    ccall((:pango_font_description_free,_jl_libpango), Void,
        (Ptr{Void},), fontdesc)
end

function set_markup(ctx::CairoContext, markup::String)
    ccall((:pango_layout_set_markup,_jl_libpango), Void,
        (Ptr{Void},Ptr{Uint8},Int32), ctx.layout, bytestring(markup), -1)
end

function get_layout_size(ctx::CairoContext)
    w = Array(Int32,2)
    ccall((:pango_layout_get_pixel_size,_jl_libpango), Void,
        (Ptr{Void},Ptr{Int32},Ptr{Int32}), ctx.layout, pointer(w,1), pointer(w,2))
    w
end

function update_layout(ctx::CairoContext)
    ccall((:pango_cairo_update_layout,_jl_libpangocairo), Void,
        (Ptr{Void},Ptr{Void}), ctx.ptr, ctx.layout)
end

function show_layout(ctx::CairoContext)
    ccall((:pango_cairo_show_layout,_jl_libpangocairo), Void,
        (Ptr{Void},Ptr{Void}), ctx.ptr, ctx.layout)
end

# -----------------------------------------------------------------------------

type CairoPattern
    ptr::Ptr{Void}
end

function get_source(ctx::CairoContext)
    CairoPattern(ccall((:cairo_get_source,_jl_libcairo),
                       Ptr{Void}, (Ptr{Void},), ctx.ptr))
end

function pattern_set_filter(p::CairoPattern, f)
    ccall((:cairo_pattern_set_filter,_jl_libcairo), Void,
          (Ptr{Void},Int32), p.ptr, f)
end

# -----------------------------------------------------------------------------

_circle(ctx::CairoContext, x::Real, y::Real, r::Real) =
    arc(ctx, x, ctx.surface.height-y, r, 0., 2pi)
_move_to(ctx::CairoContext, x, y) = move_to(ctx, x, ctx.surface.height-y)
_line_to(ctx::CairoContext, x, y) = line_to(ctx, x, ctx.surface.height-y)
_rectangle(ctx::CairoContext, x::Real, y::Real, w::Real, h::Real) =
    rectangle(ctx, x, ctx.surface.height-y-h, w, h)
_rel_line_to(ctx::CairoContext, x, y) = rel_line_to(ctx, x, -y)
_rel_move_to(ctx::CairoContext, x, y) = rel_move_to(ctx, x, -y)
_translate(ctx::CairoContext, x, y) = translate(ctx, x, ctx.surface.height-y)

function set_clip_rect(ctx::CairoContext, cr)
    x = cr[1]
    y = cr[3]
    width = cr[2] - cr[1]
    height = cr[4] - cr[3]
    _rectangle(ctx, x, y, width, height)
    clip(ctx)
    new_path(ctx)
end

type RendererState
    current::Dict
    saved::Vector{Dict}

    RendererState() = new(Dict(),Dict[])
end

function set( self::RendererState, name, value )
    self.current[name] = value
end

get(self::RendererState, name) = get(self, name, nothing)
function get( self::RendererState, name, notfound )
    if has(self.current, name)
        return self.current[name]
    end
    for d = self.saved
        if has(d,name)
            return d[name]
        end
    end
    return notfound
end

function save( self::RendererState )
    unshift!(self.saved, self.current)
    self.current = Dict()
end

function restore( self::RendererState )
    self.current = self.saved[1]
    delete!(self.saved, 1)
end

color_to_rgb(i::Integer) = hex2rgb(i)
color_to_rgb(s::String) = name2rgb(s)

function _set_color( ctx::CairoContext, color )
    (r,g,b) = color_to_rgb( color )
    set_source_rgb( ctx, r, g, b )
end

function _set_line_type(ctx::CairoContext, nick::String)
    const nick2name = [
       "dot"       => "dotted",
       "dash"      => "shortdashed",
       "dashed"    => "shortdashed",
    ]
    # XXX:should be scaled by linewidth
    const name2dashes = [
        "solid"           => Float64[],
        "dotted"          => [1.,3.],
        "dotdashed"       => [1.,3.,4.,4.],
        "longdashed"      => [6.,6.],
        "shortdashed"     => [4.,4.],
        "dotdotdashed"    => [1.,3.,1.,3.,4.,4.],
        "dotdotdotdashed" => [1.,3.,1.,3.,1.,3.,4.,4.],
    ]
    name = get(nick2name, nick, nick)
    if has(name2dashes, name)
        set_dash(ctx, name2dashes[name])
    end
end

abstract Renderer

type CairoRenderer <: Renderer
    ctx::CairoContext
    state::RendererState
    on_open::Function
    on_close::Function
    lowerleft
    upperright
    bbox

    function CairoRenderer(surface)
        ctx = CairoContext(surface)
        self = new(ctx)
        self.on_open = () -> nothing
        self.on_close = () -> nothing
        self.lowerleft = (0,0)
        self.bbox = nothing
        self
    end
end

function PNGRenderer(filename::String, width::Integer, height::Integer)
    surface = CairoRGBSurface(width, height)
    r = CairoRenderer(surface)
    r.upperright = (width,height)
    r.on_close = () -> write_to_png(surface, filename)
    set_source_rgb(r.ctx, 1.,1.,1.)
    paint(r.ctx)
    set_source_rgb(r.ctx, 0.,0.,0.)
    r
end

function _str_size_to_pts( str )
    m = match(r"([\d.]+)([^\s]+)", str)
    num_xx = float64(m.captures[1])
    units = m.captures[2]
    # convert to postscipt pt = in/72
    const xx2pt = [ "in"=>72., "pt"=>1., "mm"=>2.835, "cm"=>28.35 ]
    num_pt = num_xx*xx2pt[units]
    return num_pt
end

PDFRenderer(filename::String, w_str::String, h_str::String) =
    PDFRenderer(filename, _str_size_to_pts(w_str), _str_size_to_pts(h_str))

function PDFRenderer(filename::String, w_pts::Float64, h_pts::Float64)
    surface = CairoPDFSurface(filename, w_pts, h_pts)
    r = CairoRenderer(surface)
    r.upperright = (w_pts,h_pts)
    r.on_close = () -> show_page(r.ctx)
    r
end

EPSRenderer(filename::String, w_str::String, h_str::String) =
    EPSRenderer(filename, _str_size_to_pts(w_str), _str_size_to_pts(h_str))

function EPSRenderer(filename::String, w_pts::Float64, h_pts::Float64)
    surface = CairoEPSSurface(filename, w_pts, h_pts)
    r = CairoRenderer(surface)
    r.upperright = (w_pts,h_pts)
    r.on_close = () -> show_page(r.ctx)
    r
end

function SVGRenderer(stream::IOStream, w::Real, h::Real)
    surface = CairoSVGSurface(stream, w, h)
    r = CairoRenderer(surface)
    r.upperright = (w,h)
    #r.on_close = () -> show_page(r.ctx)
    r
end

function open( self::CairoRenderer )
    self.state = RendererState()
    self.on_open()
end

function close( self::CairoRenderer )
    self.on_close()
    finish(self.ctx.surface)
end

## state commands

const __pl_style_func = [
    "color"     => _set_color,
    "linecolor" => _set_color,
    "fillcolor" => _set_color,
    "linestyle" => _set_line_type,
    "linetype"  => _set_line_type,
    "linewidth" => set_line_width,
    "filltype"  => set_fill_type,
    "cliprect"  => set_clip_rect,
]

function set( self::CairoRenderer, key::String, value )
    set(self.state, key, value )
    if key == "fontface"
        fontsize = get(self, "fontsize", 12)
        set_font_from_string(self.ctx, "$value $(fontsize)px")
    elseif key == "fontsize"
        fontface = get(self, "fontface", "sans-serif")
        set_font_from_string(self.ctx, "$fontface $(value)px")
    elseif has(__pl_style_func, key)
        __pl_style_func[key](self.ctx, value)
    end
end

function get(self::CairoRenderer, parameter::String, notfound)
    return get(self.state, parameter, notfound)
end

function get(self::CairoRenderer, parameter::String)
    get(self, parameter, nothing)
end

function save_state( self::CairoRenderer )
    save(self.state)
    save(self.ctx)
end

function restore_state( self::CairoRenderer )
    restore(self.state)
    restore(self.ctx)
end

## drawing commands

stroke(cr::CairoRenderer) = stroke(cr.ctx)

function move(self::CairoRenderer, p)
    _move_to( self.ctx, p[1], p[2] )
end

function lineto( self::CairoRenderer, p )
    _line_to( self.ctx, p[1], p[2] )
end

function linetorel( self::CairoRenderer, p )
    _rel_line_to( self.ctx, p[1], p[2] )
end

function line( self::CairoRenderer, p, q )
    _move_to(self.ctx, p[1], p[2])
    _line_to(self.ctx, q[1], q[2])
    stroke(self.ctx)
end

function rect( self::CairoRenderer, p, q )
    _rectangle( self.ctx, p[1], p[2], q[1]-p[1], q[2]-p[2] )
end

function circle( self::CairoRenderer, p, r )
    _circle( self.ctx, p[1], p[2], r )
end

function ellipse( self::CairoRenderer, p, rx, ry, angle )
    ellipse( self.ctx, p[1], p[2], rx, ry, angle )
end

function arc( self::CairoRenderer, c, p, q )
    arc( self.ctx, c[1], c[2], p[1], p[2], q[1], q[2] )
end

function symbol(self::CairoRenderer, x::Real, y::Real)
    symbols(self, [x], [y] )
end

function symbols( self::CairoRenderer, x, y )
    fullname = get(self.state, "symboltype", "square")
    size = get(self.state, "symbolsize", 0.01)

    splitname = split(fullname)
    name = pop!(splitname)
    filled = contains(splitname, "solid") || contains(splitname, "filled")

    const symbol_funcs = [
        "asterisk" => (c, x, y, r) -> (
            _move_to(c, x, y+r);
            _line_to(c, x, y-r);
            _move_to(c, x+0.866r, y-0.5r);
            _line_to(c, x-0.866r, y+0.5r);
            _move_to(c, x+0.866r, y+0.5r);
            _line_to(c, x-0.866r, y-0.5r)
        ),
        "cross" => (c, x, y, r) -> (
            _move_to(c, x+r, y+r);
            _line_to(c, x-r, y-r);
            _move_to(c, x+r, y-r);
            _line_to(c, x-r, y+r)
        ),
        "diamond" => (c, x, y, r) -> (
            _move_to(c, x, y+r);
            _line_to(c, x+r, y);
            _line_to(c, x, y-r);
            _line_to(c, x-r, y);
            close_path(c)
        ),
        "dot" => (c, x, y, r) -> (
            new_sub_path(c);
            _rectangle(c, x, y, 1., 1.)
        ),
        "plus" => (c, x, y, r) -> (
            _move_to(c, x+r, y);
            _line_to(c, x-r, y);
            _move_to(c, x, y+r);
            _line_to(c, x, y-r)
        ),
        "square" => (c, x, y, r) -> (
            new_sub_path(c);
            _rectangle(c, x-0.866r, y-0.866r, 1.732r, 1.732r)
        ),
        "triangle" => (c, x, y, r) -> (
            _move_to(c, x, y+r);
            _line_to(c, x+0.866r, y-0.5r);
            _line_to(c, x-0.866r, y-0.5r);
            close_path(c)
        ),
        "down-triangle" => (c, x, y, r) -> (
            _move_to(c, x, y-r);
            _line_to(c, x+0.866r, y+0.5r);
            _line_to(c, x-0.866r, y+0.5r);
            close_path(c)
        ),
        "right-triangle" => (c, x, y, r) -> (
            _move_to(c, x+r, y);
            _line_to(c, x-0.5r, y+0.866r);
            _line_to(c, x-0.5r, y-0.866r);
            close_path(c)
        ),
        "left-triangle" => (c, x, y, r) -> (
            _move_to(c, x-r, y);
            _line_to(c, x+0.5r, y+0.866r);
            _line_to(c, x+0.5r, y-0.866r);
            close_path(c)
        ),
    ]
    default_symbol_func = (ctx,x,y,r) -> (
        new_sub_path(ctx);
        _circle(ctx,x,y,r)
    )
    symbol_func = get(symbol_funcs, name, default_symbol_func)

    save(self.ctx)
    set_dash(self.ctx, Float64[])
    new_path(self.ctx)
    for i = 1:min(length(x),length(y))
        symbol_func(self.ctx, x[i], y[i], 0.5*size)
    end
    if filled
        fill_preserve(self.ctx)
    end
    stroke(self.ctx)
    restore(self.ctx)
end

function curve( self::CairoRenderer, x::AbstractVector, y::AbstractVector )
    n = min(length(x), length(y))
    if n <= 0
        return
    end
    new_path(self.ctx)
    _move_to(self.ctx, x[1], y[1])
    for i = 2:n
        _line_to( self.ctx, x[i], y[i] )
    end
    stroke(self.ctx)
end

function image(r::CairoRenderer, s::CairoSurface, x, y, w, h)
    _rectangle(r.ctx, x, y, w, h)
    save(r.ctx)
    _translate(r.ctx, x, y+h)
    scale(r.ctx, w/s.width, h/s.height)
    set_source_surface(r.ctx, s, 0, 0)
    if w > s.width && h > s.height
        # use NEAREST filter when stretching an image
        # it's usually better to see pixels than a blurry mess when viewing
        # a small image
        p = get_source(r.ctx)
        pattern_set_filter(p, CAIRO_FILTER_NEAREST)
    end
    fill(r.ctx)
    restore(r.ctx)
end

image(r::CairoRenderer, img::Array{Uint32,2}, x, y, w, h) =
    image(r, CairoRGBSurface(img), x, y, w, h)

function polygon( self::CairoRenderer, points::Vector )
    move(self, points[1])
    for i in 2:length(points)
        lineto(self, points[i])
    end
    close_path(self.ctx)
    fill(self.ctx)
end

# text commands

function text_extents(ctx::CairoContext,value::String,extents)
    ccall((:cairo_text_extents, _jl_libcairo),
              Void, (Ptr{Void}, Ptr{Uint8}, Ptr{Float64}),
              ctx.ptr, bytestring(value), extents)
end

function show_text(ctx::CairoContext,value::String)
    ccall((:cairo_text_extents, _jl_libcairo),
          Void, (Ptr{Void}, Ptr{Uint8}),
          ctx.ptr, bytestring(value))
end

function select_font_face(ctx::CairoContext,family::String,slant,weight)
    ccall((:cairo_select_font_face, _jl_libcairo),
          Void, (Ptr{Void}, Ptr{Uint8},
                 cairo_font_slant_t, cairo_font_weight_t),
          ctx.ptr, bytestring(property.family),
          slant, weight)
end

function layout_text(self::CairoRenderer, text::String)
    markup = tex2pango(text, get(self,"fontsize"))
    set_markup(self.ctx, markup)
end

function text(self::CairoRenderer, x::Real, y::Real, text::String)
    halign = get( self.state, "texthalign", "center" )
    valign = get( self.state, "textvalign", "center" )
    angle = get( self.state, "textangle", 0. )

    _move_to(self.ctx, x, y)
    save(self.ctx)
    rotate(self.ctx, -angle*pi/180.)

    layout_text(self, text)
    update_layout(self.ctx)

    const _xxx = [
        "center"    => 0.5,
        "left"      => 0.,
        "right"     => 1.,
        "top"       => 0.,
        "bottom"    => 1.,
    ]
    extents = get_layout_size(self.ctx)
    dx = -_xxx[halign]*extents[1]
    dy = _xxx[valign]*extents[2]
    _rel_move_to(self.ctx, dx, dy)

    show_layout(self.ctx)
    restore(self.ctx)
end

function textwidth( self::CairoRenderer, str )
    layout_text(self, str)
    extents = get_layout_size(self.ctx)
    extents[1]
end

function textheight( self::CairoRenderer, str )
    get( self.state, "fontsize" ) ## XXX: kludge?
end

type TeXLexer
    str::String
    len::Int
    pos::Int
    token_stack::Array{String,1}
    re_control_sequence::Regex

    function TeXLexer( str::String )
        self = new()
        self.str = str
        self.len = length(str)
        self.pos = 1
        self.token_stack = String[]
        self.re_control_sequence = r"^\\[a-zA-Z]+[ ]?|^\\[^a-zA-Z][ ]?"
        self
    end
end

function get_token( self::TeXLexer )
    if self.pos == self.len+1
        return nothing
    end

    if length(self.token_stack) > 0
        return pop!(self.token_stack)
    end

    str = self.str[self.pos:end]
    m = match(self.re_control_sequence, str)
    if m != nothing
        token = m.match
        self.pos = self.pos + length(token)
        # consume trailing space
        if length(token) > 2 && token[end] == ' '
            token = token[1:end-1]
        end
    else
        token = str[1:1]
        self.pos = self.pos + 1
    end

    return token
end

function put_token( self::TeXLexer, token )
    push!(self.token_stack, token)
end

function peek( self::TeXLexer )
    token = get_token(self)
    put_token( self, token )
    return token
end

function map_text_token(token::String)
    if has(_text_token_dict, token)
        return _text_token_dict[token]
    else
        return get(_common_token_dict, token, token )
    end
end

function map_math_token(token::String)
    if has(_math_token_dict, token)
        return _math_token_dict[token]
    else
        return get(_common_token_dict, token, token )
    end
end

function math_group(lexer::TeXLexer)
    output = ""
    bracketmode = false
    while true
        token = get_token(lexer)
        if token == nothing
            break
        end

        if token == L"{"
            bracketmode = true
        elseif token == L"}"
            break
        else
            output = string(output, map_math_token(token))
            if !bracketmode
                break
            end
        end
    end
    return output
end

#font_code = [ L"\f0", L"\f1", L"\f2", L"\f3" ]

function tex2pango( str::String, fontsize::Real )
    output = ""
    mathmode = true
    font_stack = {}
    font = 1
    script_size = fontsize/1.618034

    lexer = TeXLexer(str)
    while true
        token = get_token(lexer)
        if token == nothing
            break
        end

        more_output = ""

        if token == L"$"
#            mathmode = !mathmode
            more_output = L"$"
        elseif token == L"{"
            push!(font_stack, font)
        elseif token == L"}"
            old_font = pop!(font_stack)
            if old_font != font
                font = old_font
#                more_output = font_code[font]
            end
        elseif token == L"\rm"
            font = 1
#            more_output = font_code[font]
        elseif token == L"\it"
            font = 2
#            more_output = font_code[font]
        elseif token == L"\bf"
            font = 3
#            more_output = font_code[font]
        elseif !mathmode
            more_output = map_text_token(token)
        elseif token == L"_"
            more_output = string("<sub><span font=\"$script_size\">", math_group(lexer), L"</span></sub>")
            #if peek(lexer) == L"^"
            #    more_output = string(L"\mk", more_output, L"\rt")
            #end
        elseif token == L"^"
            more_output = string("<sup><span font=\"$script_size\">", math_group(lexer), L"</span></sup>")
            #if peek(lexer) == L"_"
            #    more_output = string(L"\mk", more_output, L"\rt")
            #end
        else
            more_output = map_math_token(token)
        end

        output = string(output, more_output)
    end

    return output
end

end  # module
