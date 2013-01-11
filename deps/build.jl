depsdir = joinpath(julia_pkgdir(),"Cairo","deps")
require("BinDeps")
cd(depsdir) do
    ENV["PKG_CONFIG_LIBDIR"]=ENV["PKG_CONFIG_PATH"]=joinpath(prefix(),"lib","pkgconfig")
    autotools_install("ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-1.5.13.tar.gz","libpng-1.5.13.tar.gz",[],"libpng-1.5.13",".libs/libpng15.la","libpng15.la")
    autotools_install("http://www.cairographics.org/releases/pixman-0.28.2.tar.gz","pixman-0.28.2.tar.gz",[],"pixman-0.28.2","pixman/libpixman-1.la","libpixman-1.la")
    autotools_install("http://download.savannah.gnu.org/releases/freetype/freetype-2.4.11.tar.gz","freetype-2.4.11.tar.gz",[],"freetype-2.4.11","libfreetype.la")
    autotools_install("http://www.freedesktop.org/software/fontconfig/release/fontconfig-2.10.2.tar.gz","fontconfig-2.10.2.tar.gz",[],"fontconfig-2.10.2","src/libfontconfig.la","libfontconfig.la")
    autotools_install("http://www.cairographics.org/releases/cairo-1.12.8.tar.xz","cairo-1.12.8.tar.xz",[],"cairo-1.12.8","src/libcairo.la","libcairo.la")
    autotools_install("http://ftp.gnu.org/pub/gnu/gettext/gettext-0.18.2.tar.gz","gettext-0.18.2.tar.gz",[],"gettext-0.18.2","gettext-tools/gnulib-lib/.libs/libgettextlib.la","libgettextlib.la")
    autotools_install("ftp://sourceware.org/pub/libffi/libffi-3.0.11.tar.gz","libffi-3.0.11.tar.gz",[],"libffi-3.0.11",".libs/libffi.la","libffi.la")
    ENV["LDFLAGS"]="-L$(prefix())/lib"
    ENV["CPPFLAGS"]="-I$(prefix())/include"
    ENV["PATH"]=joinpath(prefix(),"bin")*":"*ENV["PATH"]
    autotools_install("http://ftp.gnome.org/pub/gnome/sources/glib/2.34/glib-2.34.3.tar.xz","glib-2.34.3.tar.xz",["--with-sysroot=$(prefix())/lib"],"glib-2.34.3","glib/libglib-2.0.la","libglib-2.0.la")
    autotools_install("http://ftp.gnome.org/pub/GNOME/sources/pango/1.32/pango-1.32.6.tar.xz","pango-1.32.6.tar.xz",[],"pango-1.32.6","pango/libpango-1.0.la","libpango-1.0.la")
end
