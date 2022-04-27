setlocal tw=80
setlocal cindent
setlocal noexpandtab

" Ripped off from Cosmin Ratiu, on SO list; 30 Jun 2009
if has("cscope")
	" Look for a 'cscope.out' file starting from the current directory,
	" going up to the root directory.
	let s:dirs = split(getcwd(), "/")
	let s:cscope = 0
	let s:ctags = 0
	while s:dirs != []
		let s:path = "/" . join(s:dirs, "/")
		if (s:cscope == 0 && filereadable(s:path . "/cscope.out"))
			set nocscopeverbose
			execute "cs add " . s:path . "/cscope.out " . s:path . " -v"
			set cscopeverbose
			let s:cscope = 1
		endif

		if (s:ctags == 0 && filereadable(s:path . "/tags"))
			execute "set tags=" . s:path . "/tags"
			let s:ctags = 1
		endif

		if (s:cscope == 1 && s:ctags == 1)
			break
		endif

		let s:dirs = s:dirs[:-2]
	endwhile

	set csto=1	" use cscope first, then ctags
	set cst		" Use cstag instead of tag (search both cscope and tags)
	set csverb	" Make cs verbose

	nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
	nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
	nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
	nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
	nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
	nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
	nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
	nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>
	nmap <C-\>a :cs find a <C-R>=expand("<cword>")<CR><CR>

	nmap <C-\|>s :vert scs find s <C-R>=expand("<cword>")<CR><CR>
	nmap <C-\|>g :vert scs find g <C-R>=expand("<cword>")<CR><CR>
	nmap <C-\|>c :vert scs find c <C-R>=expand("<cword>")<CR><CR>
	nmap <C-\|>t :vert scs find t <C-R>=expand("<cword>")<CR><CR>
	nmap <C-\|>e :vert scs find e <C-R>=expand("<cword>")<CR><CR>
	nmap <C-\|>f :vert scs find f <C-R>=expand("<cfile>")<CR><CR>
	nmap <C-\|>i :vert scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
	nmap <C-\|>d :vert scs find d <C-R>=expand("<cword>")<CR><CR>
	nmap <C-\|>a :vert scs find a <C-R>=expand("<cword>")<CR><CR>

	" Open a quickfix window for the following queries.
	"set cscopequickfix=s-,c-,d-,i-,t-,e-,g-
endif

" Align subsequent lines to open parantheses in C sources.  Via andradaq.
" Values:
" (0 -> align next line with the last unclosed parentheses
" W4 -> if the open parentheses is the last charater on the line, indent next
"     > line 4 characters to the right
" :0 -> align cases in switch clauses with the 'switch'
" l1 -> align subsequent lines with the case statement, not what follows it
set cinoptions=(0,W4,:0,l1

" Helper function to figure values of macros in enums
" If an 'enum' is not found at the start of the line, will display the current
" line number
function! EnumValue() range
	let l:enumStart = search('^enum.\+{', 'bnW') + 1
	let l:lastEndBracket = search('}', 'bnW') + 1

	if (l:lastEndBracket >= l:enumStart)
		echo "Not in an enum"
		return
	endif

	for l:line in range(a:firstline, a:lastline)
		let l:lineStr = getline(l:line)
		let l:trimmedLine = matchstr(l:lineStr, '[a-zA-Z0-9_]\+')
		echo l:trimmedLine . ' -> ' . (l:line - l:enumStart)
	endfor
endfunction
