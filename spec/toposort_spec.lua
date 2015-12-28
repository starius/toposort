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

    it("return false,a,b if unrelated a,b are ordered",
    function()
        --[[
        k -> l
        m -> n
        ]]
        local toposort = require 'toposort'
        local ok, a, b = toposort.areUnrelatedSwapped(
            {
                {'k', 'l', 'm', 'n'},
                {'m', 'k', 'n', 'l'},
            },
            {
                l = {'k'},
                n = {'m'},
            }
        )
        assert.same({false, 'k', 'n'}, {ok, a, b})
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

end)
