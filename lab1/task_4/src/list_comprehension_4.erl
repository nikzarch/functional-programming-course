%%%-------------------------------------------------------------------
%%% @author nikzarch
%%%
%%% @doc
%%% Module for finding the largest palindrome made from the product of two 3-digits numbers.
%%% @end
%%%-------------------------------------------------------------------
-module(list_comprehension_4).
-author("nikzarch").
-export([largest_palindrome_product/0]).
-import(palindrome_utils, [is_palindrome/1]).
-spec largest_palindrome_product() -> integer().

%% Finds the largest palindrome made from the product of two 3-digits numbers
largest_palindrome_product() ->
    lists:max([X * Y || X <- lists:seq(100, 999), Y <- lists:seq(100, 999), is_palindrome(X * Y)]).
