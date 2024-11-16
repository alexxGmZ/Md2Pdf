local autocmd_id
local M = {}

local function start()
   print("start()")
   if autocmd_id then return end

   autocmd_id = vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.md",
      callback = function()
         local md_file = vim.api.nvim_buf_get_name(0)
         local pdf_file = string.gsub(md_file, ".md", ".pdf")
         local pandoc_var = "geometry:margin=1in"
         local command = { "pandoc", md_file, "-o", pdf_file, "-V", pandoc_var }

         vim.notify(md_file)
         vim.notify(pdf_file)
         vim.notify(pandoc_var)
         vim.notify(command)

         vim.system(command, { text = true }, function(obj)
            if obj.stderr ~= "" then
               vim.notify(obj.stderr, "WARN")
            end
         end)
      end
   })
   print(autocmd_id)
end

local function stop()
   print("stop()")
   if not autocmd_id then return end
   vim.api.nvim_del_autocmd(autocmd_id)
   autocmd_id = nil
end

function M.setup()
   vim.api.nvim_create_user_command("M2PDF", function(args)
      local arg = args.fargs[1] or ""

      if arg == "stop" then
         return stop()
      end

      start()
   end, {
      nargs = "*",
      complete = function()
         return { "start", "stop" }
      end
   })
end

return M
