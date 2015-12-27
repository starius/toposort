package = "toposort"
version = "dev-1"
source = {
    url = "git://github.com/starius/toposort.git"
}
description = {
    summary = "Topological sorting",
    license = "MIT",
    homepage = "https://github.com/starius/toposort",
}
dependencies = {
    "lua >= 5.1",
}
build = {
    type = "builtin",
    modules = {
        ['toposort'] = 'src/toposort/toposort.lua',
    },
}
