require('telescope').setup{
  defaults = {
    file_ignore_patterns = {
      "^data/", "^local_runs/", "%.mp4$", "%.npz$", "%.png$", "%.rels$", "%.xml$", "%.svg$", "$ignore" },
  },
}
