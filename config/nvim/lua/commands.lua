vim.api.nvim_create_user_command("PackAdd", function(opts)
    vim.pack.add(opts.fargs)
end, { nargs = "+", desc = "Add plugins (:PackAdd user/repo1 user/repo2)" })

vim.api.nvim_create_user_command("PackDel", function(opts)
    vim.pack.del(opts.fargs)
end, { nargs = "+", desc = "Delete plugins (:PackDel plugin1 plugin2)" })

vim.api.nvim_create_user_command("PackUpdate", function(opts)
    -- Check if any argument is passed
    if opts.args:match("%S") then
        -- Update specific plugins
        local plugins = vim.split(opts.args, "%s+", { trimempty = true })
        -- Update only specified plugins
        vim.pack.update(plugins)
    else
        -- Update all
        vim.pack.update()
    end
end, { nargs = "*", desc = "Update all plugins or specific ones" })
