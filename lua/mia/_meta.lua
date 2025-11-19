---@meta _
error('Cannot require a meta file')

---@alias cmd.callback fun(cmd: cmd.callback.arg)
---@alias cmd.complete fun(ArgLead: string, CmdLine: string, CursorPos: integer): string[]
---@alias cmd.preview fun(opts: cmd.callback.arg, ns: integer, buf: integer): 0|1|2

---@class cmd.callback.arg
---@field name string Command name
---@field args string The args passed to the command, if any <args>
---@field fargs string[] The args split by unescaped whitespace (when more than one argument is allowed), if any <f-args>
---@field nargs string Number of arguments |:command-nargs|
---@field bang boolean "true" if the command was executed with a ! modifier <bang>
---@field line1 integer The starting line of the command range <line1>
---@field line2 integer The final line of the command range <line2>
---@field range integer The number of items in the command range: 0, 1, or 2 <range>
---@field count integer Any count supplied <count>
---@field reg string The optional register, if specified <reg>
---@field mods string Command modifiers, if any <mods>
---@field smods vim.api.keyset.parse_cmd.mods Command modifiers in a structured format. Has the same structure as the "mods" key of |nvim_parse_cmd()|.

---@class cmd.opts.create
---@field callback string|cmd.callback
---@field complete? cmd.complete|cmd.opts.complete|table
---@field preview? cmd.preview
---@field bang? cmd.callback|boolean
---@field desc? string
---@field nargs? 0 | 1 | '0' | '1' | '*' | '+' | '?'
---@field range? boolean | integer | '%'
---@field count? boolean | integer
---@field addr? cmd.opts.addr
---@field register? boolean
---@field buffer? boolean|integer
---@field keepscript? boolean
---@field force? boolean default true

---@alias cmd.opts.addr
---|'lines' Range of lines (this is the default for -range)
---|'arguments' Range for arguments
---|'arg' (arguments) - Range for arguments
---|'buffers' Range for buffers (also not loaded buffers)
---|'buf' (buffers) - Range for buffers (also not loaded buffers)
---|'loaded_buffers' Range for loaded buffers
---|'load' (loaded_buffers) - Range for loaded buffers
---|'windows' Range for windows
---|'win' (windows) - Range for windows
---|'tabs' Range for tab pages
---|'tab' (tabs) - Range for tab pages
---|'quickfix' Range for quickfix entries
---|'qf' (quickfix) - Range for quickfix entries
---|'other' Other kind of range; can use ".", "$" and "%" as with "lines" (this is the default for -count)
---|'?' (other) - Other kind of range; can use ".", "$" and "%" as with "lines" (this is the default for -count)

---@alias cmd.opts.complete
---|'arglist' file names in argument list
---|'augroup' autocmd groups
---|'buffer' buffer names
---|'behave' :behave suboptions
---|'color' color schemes
---|'command' Ex command (and arguments)
---|'compiler' compilers
---|'dir' directory names
---|'environment' environment variable names
---|'event' autocommand events
---|'expression' Vim expression
---|'file' file and directory names
---|'file_in_path' file and directory names in |'path'|
---|'filetype' filetype names |'filetype'|
---|'function' function name
---|'help' help subjects
---|'highlight' highlight groups
---|'history' :history suboptions
---|'keymap' keyboard mappings
---|'locale' locale names (as output of locale -a)
---|'lua' Lua expression |:lua|
---|'mapclear' buffer argument
---|'mapping' mapping name
---|'menu' menus
---|'messages' |:messages| suboptions
---|'option' options
---|'packadd' optional package |pack-add| names
---|'shellcmd' Shell command
---|'sign' |:sign| suboptions
---|'syntax' syntax file names |'syntax'|
---|'syntime' |:syntime| suboptions
---|'tag' tags
---|'tag_listfiles' tags, file names are shown when CTRL-D is hit
---|'user' user names
---|'var' user variables

---@alias aucmd.callback fun(cmd: aucmd.callback.arg): boolean?

---@class aucmd.opts
---@field buffer? integer
---@field desc? string
---@field group? integer|string
---@field nested? boolean
---@field once? boolean
---@field pattern? string|string[]

---@class aucmd.opts.create: aucmd.opts
---@field callback? aucmd.callback
---@field command? string

---@class aucmd.callback.arg
---@field id integer autocommand id
---@field event aucmd.event name of the triggered event |autocmd-events|
---@field group? integer autocommand group id, if any
---@field match string expanded value of <amatch>
---@field buf integer expanded value of <abuf>
---@field file string expanded value of <afile>
---@field data any arbitrary data passed from |nvim_exec_autocmds()|


---@class mia.autocmd.spec: aucmd.opts.create
---@field [1]? aucmd.event|aucmd.event[]
---@field [2]? string|aucmd.callback
---@field event? aucmd.event|aucmd.event[]


---@alias mia.commands table<string, mia.command|cmd.opts.create|cmd.callback|string>


---@class mia.command.def: cmd.opts.create
---@field [1]? string|cmd.callback
---@field callback? cmd.callback
---@field command? string
---@field bang? cmd.callback|boolean
---@field subcommands? table<string, mia.command.create>

---@alias mia.command.create mia.command|cmd.opts.create|cmd.callback|string

---@class mia.command:

---@class mia.cmd.callback.arg
---@field cmdline? boolean Whether or not it was called as a :command
