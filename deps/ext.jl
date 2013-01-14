ccall(:add_library_mapping,Int32,(Ptr{Uint8},Ptr{Uint8}),"libcairo",dlopen(joinpath(julia_pkgdir(),"Cairo","deps","usr","lib","libcairo"))
ccall(:add_library_mapping,Int32,(Ptr{Uint8},Ptr{Uint8}),"libpango-1.0",dlopen(joinpath(julia_pkgdir(),"Cairo","deps","usr","lib","libpango-1.0"))
ccall(:add_library_mapping,Int32,(Ptr{Uint8},Ptr{Uint8}),"libpangocairo-1.0",dlopen(joinpath(julia_pkgdir(),"Cairo","deps","usr","lib","libpangocairo-1.0"))
ccall(:add_library_mapping,Int32,(Ptr{Uint8},Ptr{Uint8}),"libgobject-2.0",dlopen(joinpath(julia_pkgdir(),"Cairo","deps","usr","lib","libgobject-2.0"))
