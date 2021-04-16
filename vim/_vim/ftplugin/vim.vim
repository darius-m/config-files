" Get color of a group
function! GetHighlightColor(group, what)
	let l:highlight = execute('hi ' . a:group)

	for item in split(l:highlight, '\s\+')
		if match(item, a:what . '=') != -1
			return split(item, '=')[1]
		endif
	endfor

	return ''
endfunction

" Set highlight color to group for 'what' parameter
function! SetColor(group, color, what)
	if (a:color != '')
		exec 'hi ' . a:group . ' ' . a:what . '=' . a:color
		echo a:what . '=' . a:color . ' set for color group ' . a:group
	endif
endfunction

" Restore colors to their initial values - called when changing color groups
function! RestoreColors()
	let l:highlightGroup = s:highlightGroups[s:highlightIdx]
	call SetColor(l:highlightGroup, s:groupColorBG, 'ctermbg')
	call SetColor(l:highlightGroup, s:groupColorFG, 'ctermfg')
endfunction

" Initialize highlightGroups array if not yet defined
if !exists('s:highlightGroups')
	let highlights = execute('highlight')
	let hlGroups = substitute(highlights, '\s\+[^\n]*', '', 'g')
	let s:highlightGroups = split(hlGroups)
endif

" Initialize current cycle color if not defined
if !exists('s:crtcol')
	let s:crtcol = 0
endif

" Initialize index of color in highlightGroups array
if !exists('s:highlightIdx')
	let s:highlightIdx = 0
	let highlightGroup = s:highlightGroups[s:highlightIdx]
	let s:groupColorBG = GetHighlightColor(highlightGroup, 'ctermbg')
	let s:groupColorFG = GetHighlightColor(highlightGroup, 'ctermfg')
endif

" Highlight background of 'highlightIdx'th group using the next color relative
" to 'crtcol'
function! TryNextColor()
	if (s:crtcol < 255)
		let s:crtcol = s:crtcol + 1
	endif

	call SetColor(s:highlightGroups[s:highlightIdx], s:crtcol, 'ctermbg')
endfunction

" Highlight background of 'highlightIdx'th group using the previous color
" relative to 'crtcol'
function! TryPrevColor()
	if (s:crtcol > 0)
		let s:crtcol = s:crtcol - 1
	endif

	call SetColor(s:highlightGroups[s:highlightIdx], s:crtcol, 'ctermbg')
endfunction

" Select next color group relative to 'highlightIdx'. Reset colors for
" previously selected group first, set color to 0 for the new group
function! TryNextColorGroup()
	" Restore colors for current group
	call RestoreColors()

	if (s:highlightIdx < len(s:highlightGroups) - 1)
		let s:highlightIdx = s:highlightIdx + 1
	endif

	" Save colors for next group
	let l:highlightGroup = s:highlightGroups[s:highlightIdx]
	let s:groupColorBG = GetHighlightColor(l:highlightGroup, 'ctermbg')
	let s:groupColorFG = GetHighlightColor(l:highlightGroup, 'ctermfg')

	let s:crtcol = 0
	call SetColor(s:highlightGroups[s:highlightIdx], s:crtcol, 'ctermbg')
	echo 'Current color group: ' . l:highlightGroup
endfunc

" Select previous color group relative to 'highlightIdx'. Reset colors for
" previously selected group first, set color to 0 for the new group
function! TryPrevColorGroup()
	" Restore colors for current group
	call RestoreColors()

	if (s:highlightIdx > 0)
		let s:highlightIdx = s:highlightIdx - 1
	endif

	" Save colors for next group
	let l:highlightGroup = s:highlightGroups[s:highlightIdx]
	let s:groupColorBG = GetHighlightColor(l:highlightGroup, 'ctermbg')
	let s:groupColorFG = GetHighlightColor(l:highlightGroup, 'ctermfg')

	let s:crtcol = 0
	call SetColor(s:highlightGroups[s:highlightIdx], s:crtcol, 'ctermbg')
	echo 'Current color group: ' . l:highlightGroup
endfunc

" Convenience mappings for functions to cycle through colors
nnoremap <silent><F7> :call TryPrevColor()<CR>
nnoremap <silent><F8> :call TryNextColor()<CR>
nnoremap <silent><F5> :call TryPrevColorGroup()<CR>
nnoremap <silent><F6> :call TryNextColorGroup()<CR>

setlocal noexpandtab
setlocal ts=4
setlocal sts=4
setlocal sw=4
