-module(task_26_tests).
-include_lib("eunit/include/eunit.hrl").

test_modules_test() ->
  Mods = [tail_recursion_26, regular_recursion_26, module_26, map_26, list_comprehension_26],
  Expected = 983,

  TestFun = fun
              Test([Mod | Rest]) ->
                Result = Mod:find_longest_recurring_cycle(),
                ?assertEqual(Expected, Result),
                Test(Rest);
              Test([]) ->
                ok
            end,
  TestFun(Mods).
