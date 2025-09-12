%%%-------------------------------------------------------------------
%%% @author nikzarch
%%%
%%% @doc
%%% Module for finding the largest palindrome made from two 3-digits numbers.
%%% @end
%%%-------------------------------------------------------------------
-module(tail_recursion_4).
-author("nikzarch").
-export([largest_palindrome_product_start/0]).

is_palindrome(Number) ->
  NumberList = integer_to_list(Number),
  is_palindrome_list(NumberList).
is_palindrome_list([]) -> true;
is_palindrome_list(List) ->
  List == lists:reverse(List).

%%% Finds the largest palindrome made from two 3-digits numbers
largest_palindrome_product_start() -> largest_palindrome_product(999, 999, 0).
largest_palindrome_product(A, B, Max) when A == 99 ->
  largest_palindrome_product(999, B - 1, Max);
largest_palindrome_product(_, B, Max) when B == 99 ->
  Max;
largest_palindrome_product(A, B, Max) ->
  Number = A * B,
  case is_palindrome(Number) of
    true -> if Number > Max -> largest_palindrome_product(A - 1, B, Number); true ->
      largest_palindrome_product(A - 1, B, Max) end;
    false -> largest_palindrome_product(A - 1, B, Max)
  end.

