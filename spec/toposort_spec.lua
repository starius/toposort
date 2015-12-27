-- toposort,  Topological sorting
-- Copyright (c) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("Topological sorting", function()

    it("loads 'toposort' module", function()
        require 'toposort'
    end)

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

    it("return if build_list is ordered topologically",
    function()
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
