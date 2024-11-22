local config = require("Md2Pdf.config")
local plugin_opts = {}
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
   -- check if md_file is markdown
   if not md_file:match("%.md$") then
      return notify("Not a markdown file", "WARN")
   end

   if not plugin_opts.pdf_engine or plugin_opts.pdf_engine == "" then
      return notify("Specify 'pdf_engine' in the config file", "WARN")
   end

   local pdf_file = md_file:gsub("%.md$", ".pdf")
   local command = {
      "pandoc",
      md_file,
      "--pdf-engine=" .. plugin_opts.pdf_engine,
      "-o",
      pdf_file
   }

   if plugin_opts.yaml_template_path and plugin_opts.yaml_template_path ~= "" then
      table.insert(command, "--metadata-file=" .. plugin_opts.yaml_template_path)
   end

   -- create a specific job for each buffer with the markdown filename as the key
   -- each buffer has job_id
   if not buffer_jobs[md_file] or not buffer_jobs[md_file].job_id  then
      buffer_jobs[md_file] = { job_id = nil }
      notify("Converting...")
   end

   -- kill the previous buffer job to finish its latest job
   if buffer_jobs[md_file].job_id then
      vim.fn.jobstop(buffer_jobs[md_file].job_id)
      buffer_jobs[md_file].job_id = nil
      notify("Re-converting...")
   end

   --- Handle job on error
   local function on_stderr(_, data)
      local err_msg = table.concat(data, "\n")
      if err_msg ~= "" then
         buffer_jobs[md_file].job_id = nil -- delete buffer job id if failed
         notify(err_msg, "WARN")
      end
   end

   --- Handle job on exit
   local function on_exit(_, code)
      if code == 0 then
         local success_message = {
            "Pdf Engine: ", plugin_opts.pdf_engine, "\n",
            "md        : ", md_file, "\n",
            "pdf       : ", pdf_file
         }
         notify(table.concat(success_message))
         buffer_jobs[md_file].job_id = nil -- delete buffer job id if failed
      end
   end

   -- start conversion job
   buffer_jobs[md_file].job_id = vim.fn.jobstart(command, {
      detach = true, -- keep converting even if nvim is closed
      stderr_buffered = true,
      on_stderr = on_stderr,
      on_exit = on_exit,
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
---@param usr_opts table Configuration options
function M.setup(usr_opts)
   vim.api.nvim_create_user_command("Md2Pdf", function(args)
      local arg = args.fargs[1] or ""

      plugin_opts = config.handle_user_config(usr_opts)

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
