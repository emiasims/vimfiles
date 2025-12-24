return {
  s('forline', {
    t('local f = io.open('),
    c(1, { i(1, 'file'), sn(nil, { t('"'), i(1, 'filename'), t('"') }) }),
    t(')'),
  }),
}
