using Cairo: tex2pango
using Compat.Test

fsize = 1.618034
@test tex2pango("ƒ_{Nyquist} [\\mu K]",fsize) == "ƒ<sub><span font=\"1.0\">Nyquist</span></sub> [μK]"
