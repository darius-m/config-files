setlocal ts=2
setlocal sw=2
setlocal sts=2

setlocal foldlevel=99
setlocal foldmethod=expr
setlocal foldexpr=YamlFoldLevel()

function! YamlFoldLevel()
	let previous_level = indent(prevnonblank(v:lnum - 1)) / &shiftwidth
	let current_level = indent(v:lnum) / &shiftwidth
	let next_level = indent(nextnonblank(v:lnum + 1)) / &shiftwidth

	if getline(v:lnum + 1) =~ '^\s*$'
		return "="

	elseif current_level < next_level
		return next_level

	elseif current_level > next_level
		return ('s' . (current_level - next_level))

	elseif current_level == previous_level
		return "="

	endif

	return next_level
endfunction
