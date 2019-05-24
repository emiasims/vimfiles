function! s:clear_kitty_clipboard()
  call s:send_text('\!')  " Invalid base64 wipes kitty clipboard, otherwise it appends.
endfunction

function! s:encode_text(text) abort
  " TODO: Can we simplify this?
  " let l:yanktext=system('base64 -w0', @")
  " let l:yanktext=substitute(l:yanktext, "\n$", "", "")
  " let l:yanktext='\e]52;c;'.l:yanktext.'\x07'
  " silent exe "!echo -ne ".shellescape(l:yanktext)." > $SSH_TTY"
  let l:encoded_text=""
  if $TMUX != ""
    let l:encoded_text=substitute(a:text, '\', '\\', "g")
  else
    let l:encoded_text=substitute(a:text, '\', '\\\\', "g")
  endif
  let l:encoded_text=substitute(l:encoded_text, "\'", "'\\\\''", "g")
  let executeCmd="echo -n '".l:encoded_text."' | base64 | tr -d '\\n'"
  return system(executeCmd)
endfunction

function! s:send_text(text) abort
  if !empty($TMUX)
    let l:osc52 = '\033Ptmux;\033\033]52;;' . a:text . '\033\033\\\\\033\\'
  elseif $TERM == "screen"
    let l:osc52 = '\033P\033]52;;' . a:text . '\007\033\\'
  else
    let l:osc52 = '\033]52;;' . a:text . '\033\\'
  endif
  if has('nvim')  " see https://github.com/neovim/neovim/issues/8450
    call system('echo -en "' . l:osc52 . '" > $(tty < /proc/$PPID/fd/0)')
  else
    call system('echo -en "' . l:osc52 . '" > /dev/tty')
  endif
endfunction

function! osc52#yank(register_contents)
  call s:clear_kitty_clipboard()
  let l:encoded_text = s:encode_text(join(a:register_contents, "\n"))
  call s:send_text(l:encoded_text)
  redraw!
endfunction
