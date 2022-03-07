if exists('b:current_syntax')
    finish
endif

syn match hrQuestionDelim /%\~\?question%/
syn match hrFeedbackDelim /%\~\?feedback%/
syn match hrTagsDelim     /%\~\?tags%/
syn match hrGoodAnswer    /^+ .*/
syn match hrBadAnswer     /^- .*/

highlight hrQuestionDelim ctermfg=cyan
highlight hrFeedbackDelim ctermfg=yellow
highlight hrTagsDelim     ctermfg=green
highlight hrGoodAnswer    ctermfg=lightgreen cterm=bold
highlight hrBadAnswer     ctermfg=red

let b:current_syntax='moodle-hr'
