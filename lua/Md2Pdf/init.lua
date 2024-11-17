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

--- Start the auto command
---@param config table
local function start(config)
   print("start()")
   if autocmd_id then return end

   local pandoc_var = { "-V", config.variables }

   autocmd_id = vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.md",
      group = vim.api.nvim_create_augroup("Md2Pdf", {}),
      callback = function()
         local md_file = vim.api.nvim_buf_get_name(0)
         local pdf_file = string.gsub(md_file, ".md", ".pdf")
         local command = { "pandoc", md_file, "-o", pdf_file }

         for _, value in ipairs(pandoc_var) do
            table.insert(command, value)
         end

         notify(command)
         vim.system(command, { text = true }, function(obj)
            if obj.stderr ~= "" then
               notify(obj.stderr, "WARN")
            end
         end)
      end
   })
   print(autocmd_id)
end

--- Stop the auto command
local function stop()
   print("stop()")
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

   -- vim.cmd("Md2Pdf start")
end

return M
