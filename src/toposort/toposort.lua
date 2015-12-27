-- toposort,  Topological sorting
-- Copyright (c) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local toposort = {}

function toposort.transpose(item2deps)
    local transposed = {}
    for item, destinations in pairs(item2deps) do
        for _, dest in ipairs(destinations) do
            if not transposed[dest] then
                transposed[dest] = {}
            end
            table.insert(transposed[dest], item)
        end
    end
    return transposed
end

function toposort.reverse(list)
    local n = #list
    local reversed = {}
    for i = 1, n do
        reversed[i] = list[n - i + 1]
    end
    return reversed
end

function toposort.dfs(item1, graph, visited, in_stack, on_leave)
    assert(not in_stack[item1], 'not a DAG')
    if not visited[item1] then
        in_stack[item1] = true
        local followers = graph[item1] or {}
        for _, item2 in ipairs(followers) do
            toposort.dfs(item2, graph, visited, in_stack, on_leave)
        end
        visited[item1] = true
        in_stack[item1] = nil
        on_leave(item1)
    end
end

-- return items ordered in build order
-- this means, if item depends on item2, then
-- item2 preceeds item1 in the list
function toposort.toposort(items, item2deps)
    local n = #items
    local item2followers = toposort.transpose(item2deps)
    -- Tarjan's algorithm
    -- https://en.wikipedia.org/wiki/Topological_sorting
    local build_list_reversed = {}
    local marked_permanently = {}
    local function visit(item)
        local marked_temporarily = {}
        toposort.dfs(item, item2followers,
            marked_permanently, marked_temporarily,
            function(item2)
                table.insert(build_list_reversed, item2)
            end
        )
    end
    for _, item in ipairs(items) do
        visit(item)
    end
    assert(#build_list_reversed == n)
    local build_list = toposort.reverse(build_list_reversed)
    assert(#build_list == n)
    return build_list
end

-- return a map from iteem to its index in the list
function toposort.findIndices(list)
    local item2index = {}
    for index, item in ipairs(list) do
        assert(not item2index[item],
            'Duplicate item: ' .. item)
        item2index[item] = index
    end
    return item2index
end

-- return if build_list is ordered topologically
-- if the list is not ordered, return two items, which
-- should go in another order (item and its dependency)
function toposort.checkToposorted(build_list, item2deps)
    local item2index = toposort.findIndices(build_list)
    for item, deps in pairs(item2deps) do
        for _, dep in ipairs(deps) do
            if item2index[item] < item2index[dep] then
                return false, item, dep
            end
        end
    end
    return true
end

return toposort
