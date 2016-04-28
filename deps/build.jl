using BinDeps

@BinDeps.setup

using Compat

group1 = library_group("cairo1")
group2 = library_group("cairo2")

ignore_system_font_libs(n, h) = !(haskey(ENV, "JULIA_BINDEPS_IGNORE_SYSTEM_FONT_LIBS") && ismatch(r"^/usr/lib", n))

deps = [
    libffi = library_dependency("ffi", aliases = ["libffi"], group = group1)
    gobject = library_dependency("gobject", aliases = ["libgobject-2.0.so.0", "libgobject-2.0-0", "libgobject-2.0", "libgobject-2_0-0"], depends=[libffi], group = group1)
    zlib = library_dependency("zlib", aliases = ["libzlib","zlib1"], os = :Windows, group = group1)
    libpng = library_dependency("png", aliases = ["libpng","libpng-1.5.14","libpng15","libpng12.so.0"], group = group1)
    pixman = library_dependency("pixman", aliases = ["libpixman","libpixman-1","libpixman-1-0","libpixman-1.0"], depends = [libpng], group = group1)

    freetype = library_dependency("freetype", aliases = ["libfreetype"], group = group2, validate = ignore_system_font_libs)
    fontconfig = library_dependency("fontconfig", aliases = ["libfontconfig-1", "libfontconfig", "libfontconfig.so.1"], depends = [freetype], group = group2, validate = ignore_system_font_libs)
    cairo = library_dependency("cairo", aliases = ["libcairo-2", "libcairo","libcairo.so.2"], depends = [gobject,fontconfig,libpng], group = group2)
    harfbuzz = library_dependency("harfbuzz", aliases = ["libharfbuzz", "libharfbuzz.so.0"], depends = [cairo,freetype], os = :Unix, group = group2, validate = ignore_system_font_libs)
    pango = library_dependency("pango", aliases = ["libpango-1.0-0", "libpango-1.0","libpango-1.0.so.0", "libpango-1_0-0"], depends = [harfbuzz], group = group2)
    pangocairo = library_dependency("pangocairo", aliases = ["libpangocairo-1.0-0", "libpangocairo-1.0", "libpangocairo-1.0.so.0"], depends = [cairo], group = group2)
]


@windows_only begin
    using WinRPM
    provides(WinRPM.RPM,"libpango-1_0-0",[pango,pangocairo],os = :Windows)
    provides(WinRPM.RPM,["glib2", "libgobject-2_0-0"],gobject,os = :Windows)
    provides(WinRPM.RPM,"zlib-devel",zlib,os = :Windows)
    provides(WinRPM.RPM,["libcairo2","libharfbuzz0"],cairo,os = :Windows)
end

@osx_only begin
    if Pkg.installed("Homebrew") === nothing
        error("Homebrew package not installed, please run Pkg.add(\"Homebrew\")")
    end
    using Homebrew
    provides( Homebrew.HB, "cairo", cairo, os = :Darwin )
    provides( Homebrew.HB, "pango", [pango, pangocairo], os = :Darwin, onload =
    """
    function __init__()
        ENV["PANGO_SYSCONFDIR"] = joinpath("$(Homebrew.prefix())", "etc")
    end
    """ )
    provides( Homebrew.HB, "fontconfig", fontconfig, os = :Darwin )
    provides( Homebrew.HB, "glib", gobject, os = :Darwin )
    provides( Homebrew.HB, "libpng", libpng, os = :Darwin )
    provides( Homebrew.HB, "freetype", freetype, os = :Darwin )
    provides( Homebrew.HB, "libffi", libffi, os = :Darwin )
    provides( Homebrew.HB, "pixman", pixman, os = :Darwin )
end

if !haskey(ENV, "JULIA_BINDEPS_DISABLE_SYSTEM_PACKAGE_MANAGERS")

# System Package Managers
provides(AptGet,
    @compat Dict(
        "libcairo2" => cairo,
        "libfontconfig1" => fontconfig,
        "libpango1.0-0" => [pango,pangocairo],
        "libglib2.0-0" => gobject,
        "libpng12-0" => libpng,
        "libpixman-1-0" => pixman
    ))

# TODO: check whether these are accurate
provides(Yum,
    @compat Dict(
        "cairo" => cairo,
        "fontconfig" => fontconfig,
        "pango" => [pango,pangocairo],
        "glib2" => gobject,
        "libpng" => libpng
    ))

end

const png_version = "1.5.14"

provides(Sources,
    @compat Dict(
        URI("http://www.cairographics.org/releases/pixman-0.28.2.tar.gz") => pixman,
        URI("http://www.cairographics.org/releases/cairo-1.12.16.tar.xz") => cairo,
        URI("http://download.savannah.gnu.org/releases/freetype/freetype-2.4.11.tar.gz") => freetype,
        URI("https://www.freedesktop.org/software/harfbuzz/release/harfbuzz-1.2.6.tar.bz2") => harfbuzz,
        URI("http://www.freedesktop.org/software/fontconfig/release/fontconfig-2.11.1.tar.gz") => fontconfig,
        URI("ftp://ftp.simplesystems.org/pub/libpng/png/src/history/libpng15/libpng-$(png_version).tar.gz") => libpng,
        URI("ftp://sourceware.org/pub/libffi/libffi-3.0.11.tar.gz") => libffi,
        URI("http://ftp.gnome.org/pub/gnome/sources/glib/2.34/glib-2.34.3.tar.xz") => gobject,
        URI("http://ftp.gnome.org/pub/GNOME/sources/pango/1.32/pango-1.32.6.tar.xz") => [pango,pangocairo],
        URI("http://zlib.net/zlib-1.2.7.tar.gz") => zlib
    ))

xx(t...) = (OS_NAME == :Windows ? t[1] : (OS_NAME == :Linux || length(t) == 2) ? t[2] : t[3])

provides(BuildProcess,
    @compat Dict(
        Autotools(libtarget = "pixman/libpixman-1.la", installed_libname = xx("libpixman-1-0.","libpixman-1.","libpixman-1.0.")*BinDeps.shlib_ext) => pixman,
        Autotools(libtarget = xx("objs/.libs/libfreetype.la","libfreetype.la")) => freetype,
        Autotools(libtarget = "src/libharfbuzz.la") => harfbuzz,
        Autotools(libtarget = "src/libfontconfig.la", configure_options = ["--enable-libxml2"]) => fontconfig,
        Autotools(libtarget = "src/libcairo.la", configure_options = append!(append!(
                AbstractString[],
                OS_NAME != :Linux ? AbstractString["--without-x","--disable-xlib","--disable-xcb"] : AbstractString[]),
                OS_NAME == :Darwin ? AbstractString["--enable-quartz","--enable-quartz-font","--enable-quartz-image","--disable-gl"] : AbstractString[])) => cairo,
        Autotools(libtarget = "libffi.la") => libffi,
        Autotools(libtarget = "gobject/libgobject-2.0.la") => gobject,
        Autotools(libtarget = "pango/libpango-1.0.la") => [pango,pangocairo]
    ))

provides(BuildProcess,Autotools(libtarget = "libpng15.la"),libpng,os = :Unix)

provides(SimpleBuild,
    (@build_steps begin
        GetSources(zlib)
        @build_steps begin
            ChangeDirectory(joinpath(BinDeps.depsdir(zlib),"src","zlib-1.2.7"))
            MakeTargets(["-fwin32/Makefile.gcc"])
            #MakeTargets(["-fwin32/Makefile.gcc","DESTDIR=../../usr/","INCLUDE_PATH=include","LIBRARY_PATH=lib","SHARED_MODE=1","install"])
        end
    end),zlib, os = :Windows)

prefix=joinpath(BinDeps.depsdir(libpng),"usr")
uprefix = replace(replace(prefix,"\\","/"),"C:/","/c/")
pngsrcdir = joinpath(BinDeps.depsdir(libpng),"src","libpng-$png_version")
pngbuilddir = joinpath(BinDeps.depsdir(libpng),"builds","libpng-$png_version")
provides(BuildProcess,
    (@build_steps begin
        GetSources(libpng)
        CreateDirectory(pngbuilddir)
        @build_steps begin
            ChangeDirectory(pngbuilddir)
            FileRule(joinpath(prefix,"lib","libpng15.dll"),@build_steps begin
                `cmake -DCMAKE_INSTALL_PREFIX="$prefix" -G"MSYS Makefiles" $pngsrcdir`
                `make`
                `cp libpng*.dll $prefix/lib`
                `cp libpng*.a $prefix/lib`
                `cp libpng*.pc $prefix/lib/pkgconfig`
                `cp pnglibconf.h $prefix/include`
                `cp $pngsrcdir/png.h $prefix/include`
                `cp $pngsrcdir/pngconf.h $prefix/include`
            end)
        end
    end),libpng, os = :Windows)

@BinDeps.install Dict([(:gobject, :_jl_libgobject),
                       (:cairo, :_jl_libcairo),
                       (:pango, :_jl_libpango),
                       (:pangocairo, :_jl_libpangocairo)])
