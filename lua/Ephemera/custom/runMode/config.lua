        local compile = require("Ephemera.custom.runMode")

        compile.setup({
            -- Give your terminal a custom name.
            term_win_name = "Compilation",

            ---@type vim.api.keyset.win_config
            term_win_opts = {
                -- The split direction for the terminal window. "below" places it at the bottom.
                split = "below",
                -- The height of the terminal window as a percentage (0.4 = 40%).
                height = 0.4,
                -- Any number >= 1 will use that amount of lines as height
                -- Or you can make it float, adding borders, etc. check :h win_config
            },

            ---@type vim.api.keyset.win_config
            normal_win_opts = {
                -- The split direction for the normal window. "above" places it at the top.
                split = "above",
                -- similar to term_win_opts
                height = 0.6,
            },

            ---@type boolean
            -- Set this to `true` if you want to jump into the terminal when you run compile command
            enter = true,

            highlight_under_cursor = {
                -- Enable highlighting / purple visual blink on error navigation (v, n, p, f, l)
                enabled = true,
                -- The timeout in milliseconds for the highlight to appear in the terminal.
                timeout_term = 300,
                -- The timeout in milliseconds for the highlight in a normal buffer.
                timeout_normal = 250,
            },

            patterns = {
                -- patterns = { lua_pattern, capture_order }
                -- capture_order: "123" = file,col,row ; "12" = file,row ; "21" = row,file

                -- Ripgrep / Ag / Ack / Git Grep with Column (file:line:col:)
                rg = { "(%S+):(%d+):(%d+):", "123" },

                -- Ripgrep / Grep -n / Git Grep -n / Standard Line Match (file:line:)
                grep = { "(%S+):(%d+):", "12" },

                -- ctags -x output (name kind line file def)
                ctags_x = { "^%S+%s+[%w_]+%s+(%d+)%s+(%S+)", "21" },

                -- ctags tags file (name \t file \t line;" \t kind)
                ctags_tags = { "^%S+%s+(%S+)%s+(%d+);\"", "12" },

                -- ShellCheck (bash / sh linter)
                shellcheck = { "In (%S+) line (%d+):", "12" },

                -- GDB / LLDB backtrace (#0 main () at main.c:14)
                gdb = { "at (%S+%.%a+):(%d+)", "12" },

                -- Valgrind / Memcheck (==12345== at 0x4005B6: main (src/main.c:12))
                valgrind_at = { "at 0x%x+: %S+ %((%S+):(%d+)%)", "12" },
                valgrind_by = { "by 0x%x+: %S+ %((%S+):(%d+)%)", "12" },
                valgrind_direct = { "at 0x%x+: (%S+):(%d+)", "12" },

                -- Cppcheck ([src/main.cpp:12]: (error) ...)
                cppcheck = { "%[(%S+):(%d+)%]:", "12" },

                -- Python pytest / traceback
                pytest = { "(%S+%.py):(%d+): in ", "12" },
                python = { 'File "(%S+%.%a+)", line (%d+)', "12" },

                -- Node.js / V8 / Jest / Vitest stacktraces
                v8_stack = { "at .-%((%S+):(%d+):(%d+)%)", "123" },
                v8_direct = { "at (%S+):(%d+):(%d+)", "123" },

                -- Rust Backtrace (RUST_BACKTRACE=1) / Cargo
                rust_backtrace = { "at (%S+%.rs):(%d+):(%d+)", "123" },
                rust = { "%-%-> (%S+):(%d+):(%d+)", "123" },

                -- Go Panic / Test Stacktrace
                go_panic = { "(%S+%.go):(%d+) %+0x", "12" },
                go = { "(%S+%.%a+):(%d+):(%d+):", "123" },

                -- Ruby / RuboCop stacktrace
                ruby_stack = { "from (%S+%.rb):(%d+):in", "12" },

                -- PHP / PHPStan
                phpstan = { "(%S+%.php):(%d+)", "12" },
                php_fatal = { "in (%S+%.php) on line (%d+)", "12" },

                -- GCC / Clang / arm-none-eabi-gcc / Android NDK (file:line:col:)
                gcc = { "(%S+):(%d+):(%d+)", "123" },

                -- Rust: error[E0423] --> src/main.rs:4:5
                rust = { "%-%-> (%S+):(%d+):(%d+)", "123" },

                -- C# / MSVC / Roslyn: src/Program.cs(10,5): error CS1002
                csharp = { "(%S+%.%a+)%((%d+),(%d+)%)", "123" },

                -- TypeScript (tsc): src/index.ts(12,5): error TS2304: Cannot find name
                typescript = { "(%S+%.%a+)%((%d+),(%d+)%)", "123" },

                -- TypeScript eslint-tsc line format: src/index.ts:12:5 - error TS2304:
                typescript_line = { "(%S+%.%a+):(%d+):(%d+)%s+%-%s+error%s+TS", "123" },

                -- Python: File "src/main.py", line 12
                python = { 'File "(%S+%.%a+)", line (%d+)', "12" },

                -- Go: ./main.go:12:5: undefined: foo
                go = { "(%S+%.%a+):(%d+):(%d+):", "123" },

                -- Java (javac / Gradle): src/Main.java:12: error: cannot find symbol
                java = { "(%S+%.%a+):(%d+):", "12" },

                -- Makefile: [Makefile:12: *** missing separator.  Stop.
                Makefile = { "%[(%S+):(%d+):.+%]", "12" },

                -- Perl: at foo.pl line 12.
                perl = { "at (%S+%.%a+) line (%d+)", "12" },

                -- Nim: Error: undeclared identifier ... /tmp/main.nim(10, 5)
                nim = { "(%S+%.%a+)%((%d+), (%d+)%)", "123" },

                -- Lua: lua: main.lua:12: attempt to index nil value
                lua = { "(%S+%.%a+):(%d+):", "12" },

                -- CMake: CMake Error at CMakeLists.txt:12 (message):
                cmake = { "(%S+%.%a+):(%d+)", "12" },

                -- Dart: Error: lib/main.dart:12:5: Undefined name 'foo'
                dart = { "(%S+%.%a+):(%d+):(%d+):", "123" },

                -- VHDL (Xilinx Vivado): **ERROR** src/top.vhd:10(5): ...
                vhdl = { "(%S+%.%a+):(%d+)%((%d+)%)", "123" },

                -- Verilator: %Error: src/top.sv:12:5: syntax error
                verilator = { "(%S+%.%a+):(%d+):(%d+):", "123" },

                -- Elixir (Mix): ** (UndefinedFunctionError) lib/app.ex:12
                elixir = { "(%S+%.%a+):(%d+):", "12" },

                -- Erlang: src/app.erl:12:5: function foo/0 undefined
                erlang = { "(%S+%.%a+):(%d+):(%d+):", "123" },

                -- Julia: ERROR: LoadError at main.jl:12:5
                julia = { "(%S+%.%a+):(%d+):(%d+)", "123" },

                -- Swift: src/main.swift:12:5: error: cannot find 'foo' in scope
                swift = { "(%S+%.%a+):(%d+):(%d+):", "123" },

                -- Clojure: CompilerException src/core.clj:12, compiling:(core.clj:5:1)
                clojure = { "(%S+%.%a+):(%d+):", "12" },

                -- Crystal: Error in src/main.cr:12
                crystal = { "(%S+%.%a+):(%d+):", "12" },

                -- Haskell (GHC): src/Main.hs:12:5: error: Variable not in scope
                haskell = { "(%S+%.%a+):(%d+):(%d+):", "123" },

                -- Delphi / Free Pascal: src/main.pas(12,5) Error: undeclared identifier
                pascal = { "(%S+%.%a+)%((%d+),(%d+)%)", "123" },

                -- Ada / GNAT: src/main.adb:12:5: error: ...
                ada = { "(%S+%.%a+):(%d+):(%d+):", "123" },

                -- SystemVerilog (Questa/VCS): ** Error: src/top.sv(12)
                systemverilog = { "(%S+%.%a+)%((%d+)%)", "12" },

                -- Octave / MATLAB: error: src/main.m:12
                matlab = { "(%S+%.%a+):(%d+):", "12" },

                -- Groovy (Gradle): src/main.groovy:12:5: error: ...
                groovy = { "(%S+%.%a+):(%d+):(%d+):", "123" },

                -- Scala: src/main.scala:12:5: error: not found: value foo
                scala = { "(%S+%.%a+):(%d+):(%d+):", "123" },

                -- Flix: src/main.flix:12:5 -- error ...
                flix = { "(%S+%.%a+):(%d+):(%d+)", "123" },

                -- Android aapt2: error: resource not found in src/main/res/values/styles.xml:12
                android = { "(%S+%.%a+):(%d+):", "12" },

                -- Processing: classic console "sketch.pde:5:2: Syntax error"
                -- (also covered by the gcc pattern), plus Processing 4 friendly:
                -- (On line 48 in sketch_230710a.pde)
                processing_classic = { "(%S+%.%a+):(%d+):(%d+):", "123" },
                processing = { "On line (%d+) in (%S+%.%a+)", "21" },
            },

            colors = {
                -- Customize the highlight colors for different parts of the error message.
                -- These correspond to Neovim highlight groups.
                file = "WarningMsg",
                row = "CursorLineNr",
                col = "CursorLineNr",
            },

            keys = {
                -- Here's where you define all the handy keybindings!
                global = {
                    -- Normal mode keybindings, you can group modes by writing them next to each other
                    -- eg: ["nvi"] for normal, select and insert mode keybinding
                    ["n"] = {
                        -- toggle compilation window (show+focus or hide+unfocus)
                        ["<localleader>c"] = "require('Ephemera.custom.runMode').term.toggle()",
                        -- toggle watch mode (auto-compile on save)
                        ["<localleader>cw"] = "require('Ephemera.custom.runMode').toggle_watch()",
                        -- kill and close the compilation buffer
                        ["<localleader>cx"] = "require('Ephemera.custom.runMode').destroy()",
                        -- Emacs-style compile: F5 reruns last command (prompts if none), F6 always prompts
                        ["<F5>"] = "require('Ephemera.custom.runMode').recompile()",
                        ["<F6>"] = "require('Ephemera.custom.runMode').compile_prompt()",
                        -- Shift-F5 / Shift-F6: compile in directory of currently open file
                        ["<S-F5>"] = "require('Ephemera.custom.runMode').recompile_file_dir()",
                        ["<F17>"] = "require('Ephemera.custom.runMode').recompile_file_dir()",
                        ["<S-F6>"] = "require('Ephemera.custom.runMode').compile_prompt_file_dir()",
                        ["<F18>"] = "require('Ephemera.custom.runMode').compile_prompt_file_dir()",
                        -- Alt-F6: compile prompt directly launching in watch mode
                        ["<A-F6>"] = "require('Ephemera.custom.runMode').compile_watch_prompt()",
                        ["<M-F6>"] = "require('Ephemera.custom.runMode').compile_watch_prompt()",
                    },
                },
                term = {
                    -- Keybindings specific to the terminal buffer.
                    -- Global keybinding for terminal will work everywhere but will be removed
                    -- when you close the terminal buffer
                    global = {
                        ["n"] = {
                            -- clears the terminal
                            ["<localleader>cr"] = "require('Ephemera.custom.runMode').clear()",
                            -- quits the terminal buffer.
                            ["<localleader>cq"] = "require('Ephemera.custom.runMode').destroy()",
                        },
                    },
                    -- This one will only work INSIDE the terminal buffer
                    buffer = {
                        ["n"] = {
                            ["r"] = "require('Ephemera.custom.runMode').clear()",
                            -- quit the terminal.
                            ["q"] = "require('Ephemera.custom.runMode').destroy()",
                            ["w"] = "require('Ephemera.custom.runMode').toggle_watch()",
                            ["s"] = "require('Ephemera.custom.runMode').term.cycle_split()",
                            ["Q"] = "require('Ephemera.custom.runMode').export_to_qf()",
                            ["n"] = "require('Ephemera.custom.runMode').next_error()",
                            ["p"] = "require('Ephemera.custom.runMode').prev_error()",
                            ["f"] = "require('Ephemera.custom.runMode').first_error()",
                            ["l"] = "require('Ephemera.custom.runMode').last_error()",
                            ["v"] = "require('Ephemera.custom.runMode').preview_nearest_error()",
                            -- Jump to the nearest error under or before your cursor and close term
                            ["<Cr>"] = "require('Ephemera.custom.runMode').nearest_error()",
                        },
                        -- Tricks to clear warning/error list
                        ["t"] = {
                            -- Press `<CR>` in terminal mode to send a command and clear highlights.
                            ["<CR>"] = "require('Ephemera.custom.runMode').clear_hl()",
                            -- This sends the command to the terminal without clearing the error list!
                            ["<C-j>"] = "require('Ephemera.custom.runMode.term').send_cmd('')",
                        },
                    },
                },
            },
        })
