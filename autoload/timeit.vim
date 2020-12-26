function! timeit#command(cmd, ...)
  " a:1: ntimes
  " a:2: timeout
  " a:3: pre-function
  " a:4: post-function
  let nits = get(a:, 1, 100)
  let timeout = get(a:, 2, 3)
  let time = 0.0
  for i in range(1, nits)
    if exists('a:3')
      call a:3()
    endif
    let t = reltime()
    execute a:cmd
    let time += reltimefloat(reltime(t))
    if exists('a:4')
      call a:4()
    endif
    redraw
    if time > timeout
      break
    endif
  endfor
  " echo 'Average time: '.string(nits / i)
  " return time / nits
  echo 'Average time:' string(time / i) . "s\t(" . i . " runs)"
endfunction
