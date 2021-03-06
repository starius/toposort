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

function toposort.copy_list(list)
    local n = #list
    local copy = {}
    for i = 1, n do
        copy[i] = list[i]
    end
    return copy
end

function toposort.shuffled(list, random)
    random = random or math.random
    local copy = toposort.copy_list(list)
    local n = #list
    for i = 1, n do
        local j = random(i, n)
        local tmp = copy[i]
        copy[i] = copy[j]
        copy[j] = tmp
    end
    return copy
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

function toposort.findRelated(item, item2deps, item2followers)
    local function noop()
    end
    local related_set = {}
    toposort.dfs(item, item2deps, related_set, {}, noop)
    related_set[item] = nil
    toposort.dfs(item, item2followers, related_set, {}, noop)
    related_set[item] = nil
    return related_set
end

-- Return a list of all unrelated pairs {a, b}, irdered by index
function toposort.findUnrelated(items, item2deps)
    local item2followers = toposort.transpose(item2deps)
    local unrelated = {}
    for _, a in ipairs(items) do
        local bs = toposort.findRelated(a, item2deps, item2followers)
        for _, b in ipairs(items) do
            if not bs[b] and a ~= b then
                table.insert(unrelated, {a, b})
            end
        end
    end
    return unrelated
end

-- Filter out pairs {a, b} if index(a) < index(b)
function toposort.coverPairs(build_list, pairs_list)
    local item2index = toposort.findIndices(build_list)
    local unrelated = {}
    for _, pair in ipairs(pairs_list) do
        local a = pair[1]
        local b = pair[2]
        if item2index[b] < item2index[a] then
            table.insert(unrelated, pair)
        end
    end
    return unrelated
end

-- Return if unrelated items are ordered differently in some of lists
function toposort.areUnrelatedSwapped(lists, item2deps)
    local items = assert(lists[1])
    local unrelated = toposort.findUnrelated(items, item2deps)
    for _, list in ipairs(lists) do
        unrelated = toposort.coverPairs(list, unrelated)
    end
    return #unrelated == 0
end

-- Return a list of toposorted lists suitable for areUnrelatedSwapped
function toposort.coverUnrelated(items, item2deps, tries, random)
    tries = tries or 1000
    local function shuffle()
        items = toposort.shuffled(items, random)
        local new_item2deps = {}
        for item, deps in pairs(item2deps) do
            new_item2deps[item] = toposort.shuffled(deps, random)
        end
        item2deps = new_item2deps
    end
    local lists = {}
    local unrelated = toposort.findUnrelated(items, item2deps)
    while #unrelated > 0 do
        local best_list
        local best_unrelated
        for _ = 1, tries do
            shuffle()
            -- toposort
            local list = toposort.toposort(items, item2deps)
            -- filter out some unrelated pairs
            local new_unrelated = toposort.coverPairs(list, unrelated)
            if #new_unrelated < #unrelated then
                if not best_list or #new_unrelated < #best_unrelated then
                    best_list = list
                    best_unrelated = new_unrelated
                end
            end
        end
        if best_list then
            table.insert(lists, best_list)
            unrelated = best_unrelated
        end
    end
    return lists
end

-- collect all mentioned items in item2deps
function toposort.collectItems(item2deps)
    local items_set = {}
    for item, destinations in pairs(item2deps) do
        items_set[item] = true
        for _, dest in ipairs(destinations) do
            items_set[dest] = true
        end
    end
    local items = {}
    for item, _ in pairs(items_set) do
        table.insert(items, item)
    end
    return items
end

-- filter out items which are deps of other items from list
function toposort.removeDeps(list, item2deps)
    list = toposort.toposort(list, item2deps)
    local items_set = {}
    for _, item in ipairs(list) do
        items_set[item] = true
    end
    for _, item in ipairs(list) do
        if items_set[item] then
            toposort.dfs(item, item2deps, {}, {}, function(dep)
                if dep ~= item then
                    items_set[dep] = nil
                end
            end)
        end
    end
    local new_items = {}
    for item, _ in pairs(items_set) do
        table.insert(new_items, item)
    end
    return new_items
end

return toposort
