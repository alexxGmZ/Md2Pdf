local M = {}

function M.check()
   local exec_req = {
      "pandoc",
      "pdflatex",
      "xelatex",
      "lualatex"
   }
   vim.health.start("Md2Pdf Dependencies:")

   for _, req in pairs(exec_req) do
      if vim.fn.executable(req) == 0 then
         vim.health.warn(req .. " not found or not inside $PATH")
      else
         vim.health.ok(req .. " is installed")
      end
   end
end

return M
