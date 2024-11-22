local M = {}

M.default_opts = {
   pdf_engine = "pdflatex",
   yaml_template_path = nil
}

--- Handle user config
---@param opts table -- User config options
---@return table -- Final config to utilize by the plugin
function M.handle_user_config(opts)
   local final_config = M.default_opts

   -- if opts is empty, then use default_opts
   if not opts or not next(opts) then
      return M.default_opts
   end

   -- update the default values of final_config with user opts
   for index, _ in pairs(opts) do
      final_config[index] = opts[index]
   end

   return final_config
end

return M
