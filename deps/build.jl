require("BinDeps")
s = @build_steps begin
	c=Choices(Choice[])
end

## Homebrew
@osx_only push!(c,Choice(:brew,"Install depdendency using brew",@build_steps begin
		HomebrewInstall("pango",ASCIIString[])
		`brew link cairo`
		end))

## Prebuilt Binaries
depsdir = joinpath(Pkg.dir(),"Cairo","deps")
@windows_only begin	
	local_file = joinpath(joinpath(depsdir,"downloads"),"Cairo.tar.gz")
	push!(c,Choice(:binary,"Download prebuilt binary",@build_steps begin
				ChangeDirectory(depsdir)
				FileDownloader("http://julialang.googlecode.com/files/Cairo.tar.gz",local_file)
				FileUnpacker(local_file,joinpath(depsdir,"usr"))
			end))
end

println(depsdir)

## Install from source
let 
	prefix=joinpath(depsdir,"usr")
	uprefix = replace(replace(prefix,"\\","/"),"C:/","/c/")
	pngsrcdir = joinpath(depsdir,"src","libpng-1.5.13")
	pngbuilddir = joinpath(depsdir,"builds","libpng-1.5.13")
	steps = @build_steps begin ChangeDirectory(depsdir) end

	ENV["PKG_CONFIG_LIBDIR"]=ENV["PKG_CONFIG_PATH"]=joinpath(depsdir,"usr","lib","pkgconfig")
	@unix_only ENV["PATH"]=joinpath(prefix,"bin")*":"*ENV["PATH"]
	@windows_only ENV["PATH"]=joinpath(prefix,"bin")*";"*ENV["PATH"]
	## Windows Specific dependencies
	@windows_only begin
		steps |= prepare_src("http://zlib.net/zlib-1.2.7.tar.gz","zlib-1.2.7.tar.gz","zlib-1.2.7")
		steps |= @build_steps begin
					ChangeDirectory(joinpath(depsdir,"src","zlib-1.2.7"))
					MakeTargets(["-fwin32/Makefile.gcc"])
					#MakeTargets(["-fwin32/Makefile.gcc","DESTDIR=../../usr/","INCLUDE_PATH=include","LIBRARY_PATH=lib","SHARED_MODE=1","install"])
				end
		steps |= prepare_src("ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-1.5.13.tar.gz","libpng-1.5.13.tar.gz","libpng-1.5.13")
		steps |= @build_steps begin
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
	end

	## Unix Specific dependencies
	@unix_only  steps |= @build_steps begin
		autotools_install("ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-1.5.14.tar.gz","libpng-1.5.14.tar.gz",String[],"libpng-1.5.14","libpng-1.5.14",".libs/libpng15.la","libpng15.la")
		autotools_install("http://ftp.gnu.org/pub/gnu/gettext/gettext-0.18.2.tar.gz","gettext-0.18.2.tar.gz",String[],"gettext-0.18.2","gettext-0.18.2","gettext-tools/gnulib-lib/.libs/libgettextlib.la","libgettextlib.la")
	end

	## Common dependencies
	steps |= @build_steps begin
		autotools_install("http://www.cairographics.org/releases/pixman-0.28.2.tar.gz","pixman-0.28.2.tar.gz",String[],"pixman-0.28.2","pixman-0.28.2","pixman/libpixman-1.la",OS_NAME == :Windows ? "libpixman-1-0.$shlib_ext" : "libpixman-1.0.$shlib_ext")
		autotools_install("http://download.savannah.gnu.org/releases/freetype/freetype-2.4.11.tar.gz","freetype-2.4.11.tar.gz",String[],"freetype-2.4.11","freetype-2.4.11",OS_NAME == :Windows ? "objs/.libs/libfreetype.la" : ".libs/libfreetype.$shlib_ext","libfreetype.la",OS_NAME == :Windows ? "builds/unix" : "")
		autotools_install("http://www.freedesktop.org/software/fontconfig/release/fontconfig-2.10.2.tar.gz","fontconfig-2.10.2.tar.gz",String[],"fontconfig-2.10.2","fontconfig-2.10.2","src/libfontconfig.la","libfontconfig.la")
		autotools_install("http://www.cairographics.org/releases/cairo-1.12.8.tar.xz","cairo-1.12.8.tar.xz",String["LDFLAGS=-L$uprefix/lib","CPPFLAGS=-I$uprefix/include -D_SSIZE_T_DEFINED=1"],"cairo-1.12.8","cairo-1.12.8","src/libcairo.la","libcairo.la")
		autotools_install("ftp://sourceware.org/pub/libffi/libffi-3.0.11.tar.gz","libffi-3.0.11.tar.gz",String[],"libffi-3.0.11","libffi-3.0.11",OS_NAME == :Windows ? "i686-pc-mingw32/.libs/libffi.la" : ".libs/libffi.la","libffi.la",OS_NAME == :Windows ? "i686-pc-mingw32" : "")
		autotools_install("http://ftp.gnome.org/pub/gnome/sources/glib/2.34/glib-2.34.3.tar.xz","glib-2.34.3.tar.xz",String["LDFLAGS=-L$uprefix/lib","CPPFLAGS=-I$uprefix/include",OS_NAME == :Windows?"CFLAGS=-march=i686":""],"glib-2.34.3","glib-2.34.3","glib/libglib-2.0.la","libglib-2.0.la")
		autotools_install("http://ftp.gnome.org/pub/GNOME/sources/pango/1.32/pango-1.32.6.tar.xz","pango-1.32.6.tar.xz",String["LDFLAGS=-L$uprefix/lib","CPPFLAGS=-I$uprefix/include","--with-included-modules=yes"],"pango-1.32.6","pango-1.32.6","pango/libpango-1.0.la","libpango-1.0.la")
	end
	push!(c,Choice(:source,"Install depdendency from source",steps))
end
run(s)
