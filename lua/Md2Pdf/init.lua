local default_config = require("Md2Pdf.config").default_config
local config = {}
local autocmd_id
local M = {}
local buffer_jobs = {}

--- vim.notify with nvim-notify support
---@param message string|table
---@param log_level string|nil
---@return function vim.notify
local function notify(message, log_level)
   return vim.notify(message, log_level, { title = "Md2Pdf" })
end

--- Convert markdown to pdf job
---@param md_file string
local function convert_md(md_file)
   local pdf_file = md_file:gsub("%.md$", ".pdf")
   local command = { "pandoc", md_file, "--pdf-engine=" .. config.pdf_engine, "-o", pdf_file }

   -- create a specific job for each buffer with the markdown filename as the key
   -- each buffer has job_id
   if not buffer_jobs[md_file] then
      buffer_jobs[md_file] = { job_id = nil }
   end

   if not buffer_jobs[md_file].job_id then
      notify("Converting...")
   end

   -- kill the previous buffer job to finish its latest job
   if buffer_jobs[md_file].job_id then
      vim.fn.jobstop(buffer_jobs[md_file].job_id)
      buffer_jobs[md_file].job_id = nil
      notify("Re-converting...")
   end

   -- start conversion job
   buffer_jobs[md_file].job_id = vim.fn.jobstart(command, {
      detach = true,       -- keep converting even if nvim is closed
      stderr_buffered = true,
      on_stderr = function(_, data)
         local err_msg = table.concat(data, "\n")
         if err_msg ~= "" then
            buffer_jobs[md_file].job_id = nil       -- delete buffer job id if failed
            notify(err_msg, "WARN")
         end
      end,
      on_exit = function(_, code)
         if code == 0 then
            buffer_jobs[md_file].job_id = nil       -- delete buffer job id if failed

            local success_message = {
               "Pdf Engine: ", config.pdf_engine, "\n",
               "md        : ", md_file, "\n",
               "pdf       : ", pdf_file
            }
            notify(table.concat(success_message))
         end
      end
   })
end

--- Start the auto command
local function start()
   if autocmd_id then return end

   autocmd_id = vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.md",
      group = vim.api.nvim_create_augroup("Md2Pdf", {}),
      callback = function()
         local md_file = vim.api.nvim_buf_get_name(0)
         convert_md(md_file)
         -- vim.print(vim.inspect(buffer_job))
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

      config = default_config
      if opts and next(opts) then
         config = opts
      end

      if arg == "stop" then
         return stop()
      elseif arg == "convert" then
         local md_file = vim.api.nvim_buf_get_name(0)
         return convert_md(md_file)
      end

      start()
   end, {
      nargs = "*",
      complete = function()
         return { "start", "stop", "convert" }
      end
   })
end

return M
