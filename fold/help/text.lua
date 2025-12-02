return function(lnum, bufnr)
  if lnum > 1 then
    lnum = lnum + 1
  end
  return fold.highlights(lnum, bufnr)
end
