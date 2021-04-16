setlocal tw=72
setlocal sw=2
setlocal sts=2
setlocal ai
setlocal et
setlocal noexpandtab
setlocal spell
setlocal spelllang=en_gb
syntax spell toplevel

nnoremap <leader>nf lB"nyEi\noten{<esc>Ea}{""}<esc>h"nPhz=
nnoremap <leader>nn lBi\noten{<esc>Ea}{}<esc>i
vnoremap <leader>nf <esc>`<ms`>me`s<esc>:s/\%'s\_.*\%'e\S\?/\\noten{&}{"&∞"}/<cr>B/∞<cr>"_xhz=
vnoremap <leader>nn <esc>`<ms`>me`s<esc>:s/\%'s\_.*\%'e\S\?/\\noten{&}{∞}/<cr>B/∞<cr>"_s
