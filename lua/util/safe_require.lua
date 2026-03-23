local M = {}

function M.require(module, opts)
  opts = opts or {}
  local ok, result = pcall(require, module)
  if not ok then
    if not opts.silent then
      vim.notify("Failed to load module: " .. module, vim.log.levels.WARN)
    end
    return nil
  end
  return result
end

function M.call(func, opts)
  opts = opts or {}
  local ok, result = pcall(func)
  if not ok then
    if not opts.silent then
      vim.notify("Function call failed: " .. tostring(result), vim.log.levels.ERROR)
    end
    return nil, result
  end
  return result
end

return M
