local M = {}

local scratch_buf = nil
local scratch_prev_buf = nil

local note_buf = nil
local note_prev_buf = nil
local notes_dir = vim.fn.stdpath("config") .. "/lua/Ephemera/notes"

local ref_buf = nil
local ref_prev_buf = nil

local function ensure_notes_dir()
    local dir = vim.fn.expand(notes_dir)
    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, "p")
    end
    return dir
end

local function get_note_path()
    return ensure_notes_dir() .. "/global.gnote"
end

local function scratchpad_open()
    if scratch_buf and vim.api.nvim_buf_is_valid(scratch_buf) then
        if vim.api.nvim_get_current_buf() == scratch_buf then
            if scratch_prev_buf and vim.api.nvim_buf_is_valid(scratch_prev_buf) then
                vim.api.nvim_set_current_buf(scratch_prev_buf)
            else
                vim.cmd("b#")
            end
            return
        end
        vim.api.nvim_set_current_buf(scratch_buf)
        return
    end

    scratch_prev_buf = vim.api.nvim_get_current_buf()
    vim.cmd("enew")
    scratch_buf = vim.api.nvim_get_current_buf()
    vim.bo.filetype = "scratch"
    vim.bo.buflisted = false
    vim.bo.modifiable = true
    vim.bo.swapfile = false
    vim.bo.buftype = "nofile"
end

local function scratchpad_delete()
    if scratch_buf and vim.api.nvim_buf_is_valid(scratch_buf) then
        vim.cmd("bwipeout! " .. scratch_buf)
        scratch_buf = nil
    end
end

local function scratchpad_copy()
    if vim.api.nvim_get_current_buf() == scratch_buf then
        return
    end

    local current_buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)

    if not scratch_buf or not vim.api.nvim_buf_is_valid(scratch_buf) then
        scratch_prev_buf = vim.api.nvim_get_current_buf()
        vim.cmd("enew")
        scratch_buf = vim.api.nvim_get_current_buf()
        vim.bo.filetype = "scratch"
        vim.bo.buflisted = false
        vim.bo.modifiable = true
        vim.bo.swapfile = false
        vim.bo.buftype = "nofile"
    end

    vim.api.nvim_buf_set_lines(scratch_buf, 0, -1, false, lines)
    vim.api.nvim_set_current_buf(scratch_buf)
end

local function notepad_open()
    local note_path = get_note_path()

    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
            if vim.api.nvim_buf_get_name(bufnr) == note_path then
                if vim.api.nvim_get_current_buf() == bufnr then
                    if note_prev_buf and vim.api.nvim_buf_is_valid(note_prev_buf) then
                        vim.api.nvim_set_current_buf(note_prev_buf)
                    else
                        vim.cmd("b#")
                    end
                else
                    vim.api.nvim_set_current_buf(bufnr)
                end
                return
            end
        end
    end

    note_prev_buf = vim.api.nvim_get_current_buf()
    vim.cmd("edit " .. vim.fn.fnameescape(note_path))
    note_buf = vim.api.nvim_get_current_buf()
    vim.bo.filetype = "gnote"
    vim.bo.buflisted = true
end

local function notepad_toggle()
    local current_buf = vim.api.nvim_get_current_buf()
    if note_buf and vim.api.nvim_buf_is_valid(note_buf) then
        if current_buf == note_buf then
            if note_prev_buf and vim.api.nvim_buf_is_valid(note_prev_buf) then
                vim.api.nvim_set_current_buf(note_prev_buf)
            else
                vim.cmd("b#")
            end
        else
            note_prev_buf = current_buf
            vim.api.nvim_set_current_buf(note_buf)
        end
    else
        notepad_open()
    end
end

local function notepad_close()
    if note_buf and vim.api.nvim_buf_is_valid(note_buf) then
        vim.cmd("bwipeout! " .. note_buf)
        note_buf = nil
    end
end

local function ref_open()
    vim.ui.input({ prompt = "Refer: " }, function(cmd)
        if not cmd or cmd == "" then return end

        local output = vim.fn.system(cmd)

        if ref_buf and vim.api.nvim_buf_is_valid(ref_buf) then
            if vim.api.nvim_get_current_buf() == ref_buf then
                vim.api.nvim_buf_set_lines(ref_buf, 0, -1, false, vim.split(output, "\n", { plain = true }))
            else
                ref_prev_buf = vim.api.nvim_get_current_buf()
                vim.api.nvim_buf_set_lines(ref_buf, 0, -1, false, vim.split(output, "\n", { plain = true }))
                vim.api.nvim_set_current_buf(ref_buf)
            end
        else
            ref_prev_buf = vim.api.nvim_get_current_buf()
            vim.cmd("enew")
            ref_buf = vim.api.nvim_get_current_buf()
            vim.api.nvim_buf_set_lines(ref_buf, 0, -1, false, vim.split(output, "\n", { plain = true }))
            vim.bo.filetype = "Reference"
            vim.bo.buflisted = false
            vim.bo.modifiable = true
            vim.bo.swapfile = false
            vim.bo.buftype = "nofile"
        end
    end)
end

local function ref_toggle()
    local current_buf = vim.api.nvim_get_current_buf()
    if ref_buf and vim.api.nvim_buf_is_valid(ref_buf) then
        if current_buf == ref_buf then
            if ref_prev_buf and vim.api.nvim_buf_is_valid(ref_prev_buf) then
                vim.api.nvim_set_current_buf(ref_prev_buf)
            else
                vim.cmd("b#")
            end
        else
            ref_prev_buf = current_buf
            vim.api.nvim_set_current_buf(ref_buf)
        end
    else
        ref_open()
    end
end

local function ref_close()
    if ref_buf and vim.api.nvim_buf_is_valid(ref_buf) then
        vim.cmd("bwipeout! " .. ref_buf)
        ref_buf = nil
    end
end

M.scratchpad = {
    open = scratchpad_open,
    delete = scratchpad_delete,
    copy = scratchpad_copy,
}

M.notepad = {
    open = notepad_open,
    toggle = notepad_toggle,
    close = notepad_close,
}

M.reference = {
    open = ref_open,
    toggle = ref_toggle,
    close = ref_close,
}

function M.setup()
    vim.keymap.set("n", "<leader>ss", function() M.scratchpad.open() end)
    vim.keymap.set("n", "<leader>sx", function() M.scratchpad.delete() end)
    vim.keymap.set("n", "<leader>sp", function() M.scratchpad.copy() end)

    vim.keymap.set("n", "<leader>gn", function() M.notepad.open() end)
    vim.keymap.set("n", "<leader>nn", function() M.notepad.toggle() end)
    vim.keymap.set("n", "<leader>nx", function() M.notepad.close() end)

    vim.keymap.set("n", "<leader>mn", function() M.reference.open() end)
    vim.keymap.set("n", "<leader>mm", function() M.reference.toggle() end)
    vim.keymap.set("n", "<leader>mx", function() M.reference.close() end)
end

return M
