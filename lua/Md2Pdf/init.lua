local default_config = require("Md2Pdf.config").default_config
local autocmd_id
local M = {}

--- vim.notify with nvim-notify support
---@param message string|table
---@param log_level string|nil
---@return function vim.notify
local function notify(message, log_level)
   return vim.notify(message, log_level, { title = "Md2Pdf" })
end

--- check if the pdf engine process is running
---@param pdf_engine string
---@return boolean
local function is_pdf_engine_running(pdf_engine)
   local command = { "pgrep", pdf_engine }
   local obj = vim.system(command, { text = true }):wait()

   if obj.stdout ~= "" then
      return true
   end

   return false
end

--- Start the auto command
---@param config table
local function start(config)
   if autocmd_id then return end

   autocmd_id = vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.md",
      group = vim.api.nvim_create_augroup("Md2Pdf", {}),
      callback = function()
         local md_file = vim.api.nvim_buf_get_name(0)
         local pdf_file = string.gsub(md_file, ".md", ".pdf")
         local command = { "pandoc", md_file, "--pdf-engine=" .. config.pdf_engine, "-o", pdf_file }
         local notify_table_data = {
            "Pdf Engine: ", config.pdf_engine, "\n",
            "md        : ", md_file, "\n",
            "pdf       : ", pdf_file
         }

         -- NOTE: This implementation is open for change because it's not the best
         -- implementation. I think the better implementation is to kill the previous
         -- running pdf engine process and finish the latest process, so that the latest
         -- file change will be applied to the converted pdf file.

         -- prevent the conversion if the pdf engine is running
         if is_pdf_engine_running(config.pdf_engine) then
            notify("On-going conversion", "WARN")
            return
         end

         vim.system(command, { text = true }, function(obj)
            if obj.stderr ~= "" then
               return notify(obj.stderr, "WARN")
            end

            notify(table.concat(notify_table_data))
         end)
      end
   })
end

--- Stop the auto command
local function stop()
   if not autocmd_id then return end
   vim.api.nvim_del_autocmd(autocmd_id)
   autocmd_id = nil
end

--- Setup the plugin.
---@param opts table Configuration options
function M.setup(opts)
   vim.api.nvim_create_user_command("Md2Pdf", function(args)
      local arg = args.fargs[1] or ""

      if arg == "stop" then
         return stop()
      end

      local config = default_config
      if opts and next(opts) then
         config = opts
      end

      start(config)
   end, {
      nargs = "*",
      complete = function()
         return { "start", "stop" }
      end
   })
end

return M
