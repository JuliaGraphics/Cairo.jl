@windows_only begin
	ccall(:add_library_mapping,Int32,(Ptr{Uint8},Ptr{Uint8}),"libcairo",dlopen(joinpath(Pkg.dir(),"Cairo","deps","usr","lib","libcairo-2")))
	ccall(:add_library_mapping,Int32,(Ptr{Uint8},Ptr{Uint8}),"libpango-1.0",dlopen(joinpath(Pkg.dir(),"Cairo","deps","usr","lib","libpango-1.0-0")))
	ccall(:add_library_mapping,Int32,(Ptr{Uint8},Ptr{Uint8}),"libpangocairo-1.0",dlopen(joinpath(Pkg.dir(),"Cairo","deps","usr","lib","libpangocairo-1.0-0")))
	ccall(:add_library_mapping,Int32,(Ptr{Uint8},Ptr{Uint8}),"libgobject-2.0",dlopen(joinpath(Pkg.dir(),"Cairo","deps","usr","lib","libgobject-2.0-0")))
end
