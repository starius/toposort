-- toposort,  Topological sorting
-- Copyright (c) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("Topological sorting module", function()

    it("loads 'toposort' module", function()
        require 'toposort'
    end)

end)

describe("Function toposort.transpose", function()

    it("transposes a graph", function()
        local toposort = require 'toposort'
        assert.same(
            {
                b = {'a'},
                c = {'a'},
            },
            toposort.transpose({
                a = {'b', 'c'},
            })
        )
    end)

end)

describe("Function toposort.reverse", function()

    it("reverses a list", function()
        local toposort = require 'toposort'
        assert.same({'a', 'b'}, toposort.reverse({'b', 'a'}))
    end)

end)

describe("Function toposort.copy_list", function()

    it("copies a list", function()
        local toposort = require 'toposort'
        assert.same({'a', 'b'}, toposort.copy_list({'a', 'b'}))
    end)

    it("doesn't return the argument", function()
        local toposort = require 'toposort'
        local list = {'a', 'b'}
        assert.not_equal(list, toposort.copy_list(list))
    end)

end)

describe("Function toposort.shuffled", function()

    it("return a shuffled copy of a list", function()
        local toposort = require 'toposort'
        math.randomseed(0)
        local list = {'a', 'b', 'c'}
        local seen = {}
        for _ = 1, 1000 do
            local shuffled = toposort.shuffled(list)
            local str = table.concat(shuffled)
            seen[str] = true
        end
        assert.equal(true, seen['abc'])
        assert.equal(true, seen['acb'])
        assert.equal(true, seen['bac'])
        assert.equal(true, seen['bca'])
        assert.equal(true, seen['cab'])
        assert.equal(true, seen['cba'])
    end)

    it("gets random number generator argument", function()
        local toposort = require 'toposort'
        local list = {'a', 'b', 'c'}
        local function random(x, _)
            return x
        end
        local ref = toposort.shuffled(list, random)
        for _ = 1, 1000 do
            local shuffled = toposort.shuffled(list, random)
            assert.same(ref, shuffled)
        end
    end)

end)

describe("Function toposort.dfs", function()

    it("depth-first search", function()
        local toposort = require 'toposort'
        local graph = {
            a = {'b', 'c'},
            b = {'c'},
            c = {'d'},
        }
        local visited = {}
        local in_stack = {}
        local left = {}
        local function on_leave(item)
            table.insert(left, item)
        end
        toposort.dfs('a', graph, visited, in_stack, on_leave)
        assert.same(
            {
                a = true,
                b = true,
                c = true,
                d = true,
            },
            visited
        )
        assert.same({}, in_stack)
        assert.same({'d', 'c', 'b', 'a'}, left)
    end)

end)

describe("Function toposort.toposort", function()

    it("makes topological ordering", function()
        local toposort = require 'toposort'
        assert.same(
            {
                'a', 'b', 'c',
            },
            toposort.toposort(
                {'a', 'b', 'c'},
                {
                    b = {'a'},
                    c = {'b'},
                }
            )
        )
    end)

end)

describe("Function toposort.findIndices", function()

    it("return a map from iteem to its index in the list",
    function()
        local toposort = require 'toposort'
        assert.same(
            {
                a = 1,
                b = 2,
                c = 3,
            },
            toposort.findIndices({'a', 'b', 'c'})
        )
    end)

end)

describe("Function toposort.checkToposorted", function()

    it("return true for ordered list", function()
        local toposort = require 'toposort'
        assert.same(
            true,
            toposort.checkToposorted(
                {'a', 'b', 'c'},
                {
                    b = {'a'},
                    c = {'a'},
                }
            )
        )
        assert.same(
            true,
            toposort.checkToposorted(
                {'a', 'c', 'b'},
                {
                    b = {'a'},
                    c = {'a'},
                }
            )
        )
    end)

    it("return false and conflicting pair for disordered list",
    function()
        local toposort = require 'toposort'
        local ok, item, dep = toposort.checkToposorted(
            {'b', 'a'},
            {
                b = {'a'},
            }
        )
        assert.same(
            {false, 'b', 'a'},
            {ok, item, dep}
        )
    end)

end)

describe("Function toposort.findRelated", function()

    it("return set of related nodes", function()
        local toposort = require 'toposort'
        local item = 'b'
        local item2followers = {
            a = {'b', 'd'},
            b = {'c'},
            d = {'e'},
        }
        local item2deps = toposort.transpose(item2followers)
        assert.same(
            {
                a = true,
                c = true,
            },
            toposort.findRelated(
                item,
                item2deps,
                item2followers
            )
        )
    end)

end)

describe("Function toposort.findUnrelated", function()

    it("return ordered list of unrelated nodes", function()
        --[[
        a --> b --> c
        |
        v
        d --> e
        ]]
        local toposort = require 'toposort'
        local item2followers = {
            a = {'b', 'd'},
            b = {'c'},
            d = {'e'},
        }
        local items = {'a', 'b', 'c', 'd', 'e'}
        local item2deps = toposort.transpose(item2followers)
        assert.same(
            {
                {'b', 'd'},
                {'b', 'e'},
                {'c', 'd'},
                {'c', 'e'},
                {'d', 'b'},
                {'d', 'c'},
                {'e', 'b'},
                {'e', 'c'},
            },
            toposort.findUnrelated(
                items,
                item2deps
            )
        )
    end)

end)

describe("Function toposort.coverPairs", function()

    it("Filter out pairs {a, b} if index(a) < index(b)",
    function()
        local toposort = require 'toposort'
        assert.same(
            {
                {'c', 'b'},
            },
            toposort.coverPairs(
                {'a', 'b', 'c'},
                {
                    {'a', 'b'},
                    {'a', 'c'},
                    {'c', 'b'},
                }
            )
        )
    end)

end)

describe("Function toposort.areUnrelatedSwapped", function()

    it("return true if all unrelated items are disordered",
    function()
        --[[
        k -> l
        m -> n
        ]]
        local toposort = require 'toposort'
        assert.same(
            true,
            toposort.areUnrelatedSwapped(
                {
                    {'k', 'l', 'm', 'n'},
                    {'m', 'n', 'k', 'l'},
                },
                {
                    l = {'k'},
                    n = {'m'},
                }
            )
        )
    end)

    it("return false if unrelated a,b are ordered",
    function()
        --[[
        k -> l
        m -> n
        ]]
        local toposort = require 'toposort'
        local ok = toposort.areUnrelatedSwapped(
            {
                {'k', 'l', 'm', 'n'},
                {'m', 'k', 'n', 'l'},
            },
            {
                l = {'k'},
                n = {'m'},
            }
        )
        assert.equal(false, ok)
    end)

    it("case of 5 items", function()
        --[[
                 a -> b
                 |
                 v
            c -> d
            |
            v
            e
        ]]
        local toposort = require 'toposort'
        assert.same(
            true,
            toposort.areUnrelatedSwapped(
                {
                    {'c', 'e', 'a', 'd', 'b'},
                    {'a', 'b', 'c', 'd', 'e'},
                },
                {
                    b = {'a'},
                    d = {'a', 'c'},
                    e = {'c'},
                }
            )
        )
    end)

    it("case of 3 lists", function()
        --[[
        k -> l
        m -> n
        ]]
        local toposort = require 'toposort'
        assert.same(
            true,
            toposort.areUnrelatedSwapped(
                {
                    {'k', 'l', 'm', 'n'},
                    {'m', 'k', 'n', 'l'},
                    {'m', 'n', 'k', 'l'},
                },
                {
                    l = {'k'},
                    n = {'m'},
                }
            )
        )
    end)

    local function generateLists(list)
        return coroutine.wrap(function()
            if #list == 1 then
                coroutine.yield(list)
            else
                for excl = 1, #list do
                    local list2 = {}
                    for i = 1, #list do
                        if i ~= excl then
                            table.insert(list2, list[i])
                        end
                    end
                    for list3 in generateLists(list2) do
                        table.insert(list3, list[excl])
                        coroutine.yield(list3)
                    end
                end
            end
        end)
    end

    it("prove that 'heart' can't be solved with 2 lists",
    function()
        --[[
                 a -> b
                 |    |
                 v    |
            c -> d    |
            |         |
            v         v
            e ------> f
        ]]
        local toposort = require 'toposort'
        local items = {'a', 'b', 'c', 'd', 'e', 'f'}
        local item2deps = {
            b = {'a'},
            d = {'a', 'c'},
            e = {'c'},
            f = {'b', 'e'},
        }
        local lists = {}
        for ll in generateLists(items) do
            if toposort.checkToposorted(ll, item2deps) then
                table.insert(lists, ll)
            end
        end
        for i = 1, #lists do
            for j = i + 1, #lists do
                assert.falsy(
                    toposort.areUnrelatedSwapped(
                        {lists[i], lists[j]}, item2deps
                    )
                )
            end
        end
    end)

end)

describe("Function toposort.coverUnrelated", function()

    it("Return a list of toposorted lists suitable for areUnrelatedSwapped",
    function()
        local toposort = require 'toposort'
        local lists = toposort.coverUnrelated({'a', 'b'}, {})
        -- convert lists to strings to compare them
        local strings = {}
        for _, list in ipairs(lists) do
            table.insert(strings, table.concat(list))
        end
        table.sort(strings)
        assert.same({'ab', 'ba'}, strings)
    end)

    it("solve 'heart'", function()
        --[[
                 a -> b
                 |    |
                 v    |
            c -> d    |
            |         |
            v         v
            e ------> f
        ]]
        local toposort = require 'toposort'
        local items = {'a', 'b', 'c', 'd', 'e', 'f'}
        local item2deps = {
            b = {'a'},
            d = {'a', 'c'},
            e = {'c'},
            f = {'b', 'e'},
        }
        math.randomseed(0)
        local lists = toposort.coverUnrelated(items, item2deps)
        for _, list in ipairs(lists) do
            assert.truthy(toposort.checkToposorted(list, item2deps))
        end
        assert.truthy(toposort.areUnrelatedSwapped(lists, item2deps))
        assert.truthy(#lists > 2)
    end)

end)

describe("Function toposort.collectItems", function()

    it("collect all mentioned items in item2deps",
    function()
        local toposort = require 'toposort'
        local items = toposort.collectItems({
            a = {'b', 'c'},
            c = {'d'},
            e = {'f'},
            g = {},
        })
        table.sort(items)
        assert.same('abcdefg', table.concat(items))
    end)

end)

describe("Function toposort.removeDeps", function()

    it("filter out items which are deps of other items from list",
    function()
        local toposort = require 'toposort'
        local list = {'d', 'c', 'a', 'b'}
        local item2deps = {
            b = {'a'},
            d = {'c'},
        }
        local without_deps = toposort.removeDeps(list, item2deps)
        table.sort(without_deps)
        assert.same({'b', 'd'}, without_deps)
    end)

end)
