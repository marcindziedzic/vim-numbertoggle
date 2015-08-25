" Prevent multi loads and disable in compatible mode
" check if vim version is at least 7.3
" (relativenumber is not supported below)
if exists('g:loaded_numbertoggle') || &cp || v:version < 703
  finish
endif

let g:loaded_numbertoggle = 1
let g:insertmode = 0
let g:focus = 1
let g:relativemode = 1

" Enables relative numbers.
function! EnableNumbers()
  set number
  set relativenumber
endfunc

" Disables relative numbers.
function! DisableNumbers()
  set nonumber
  set norelativenumber
endfunc

" NumberToggle toggles between relative and absolute line numbers
function! NumberToggle()
  if(&relativenumber == 1)
    call DisableNumbers()
    let g:relativemode = 0
  else
    call EnableNumbers()
    let g:relativemode = 1
  endif
endfunc

function! UpdateMode()
  if(&number == 0 && &relativenumber == 0)
    return
  end

  if(g:focus == 0)
    call DisableNumbers()
  elseif(g:insertmode == 0 && g:relativemode == 1)
    call EnableNumbers()
  else
    call DisableNumbers()
  end

  if !exists("&numberwidth") || &numberwidth <= 4
    " Avoid changing actual width of the number column with each jump between
    " number and relativenumber:
    let &numberwidth = max([4, 1+len(line('$'))])
  else
    " Explanation of the calculation:
    " - Add 1 to the calculated maximal width to make room for the space
    " - Assume 4 as the minimum desired width if &numberwidth is not set or is
    "   smaller than 4
    let &numberwidth = max([&numberwidth, 1+len(line('$'))])
  endif
endfunc

" Automatically set relative line numbers when opening a new document
autocmd BufNewFile * :call UpdateMode()
autocmd BufReadPost * :call UpdateMode()
autocmd FilterReadPost * :call UpdateMode()
autocmd FileReadPost * :call UpdateMode()

" ensures default behavior / backward compatibility
if ! exists ( 'g:UseNumberToggleTrigger' )
  let g:UseNumberToggleTrigger = 1
endif

if exists('g:NumberToggleTrigger')
  exec "nnoremap <silent> " . g:NumberToggleTrigger . " :call NumberToggle()<cr>"
elseif g:UseNumberToggleTrigger
  nnoremap <F2> :call NumberToggle()<cr>
endif
