-module(task_4_tests).
-include_lib("eunit/include/eunit.hrl").

test_modules_test() ->
    Mods = [tail_recursion_4, regular_recursion_4, module_4, map_4, list_comprehension_4],
    Expected = 906609,

    TestFun = fun
        Test([Mod | Rest]) ->
            Result = Mod:largest_palindrome_product(),
            ?assertEqual(Expected, Result),
            Test(Rest);
        Test([]) ->
            ok
    end,
    TestFun(Mods).
