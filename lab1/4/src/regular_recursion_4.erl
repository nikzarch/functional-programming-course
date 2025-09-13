%%%-------------------------------------------------------------------
%%% @author nikzarch
%%%
%%% @doc
%%% Module for finding the largest palindrome made from the product of two 3-digits numbers.
%%% @end
%%%-------------------------------------------------------------------
-module(regular_recursion_4).
-author("nikzarch").
-export([largest_palindrome_product_start/0]).

is_palindrome(Number) ->
  NumberList = integer_to_list(Number),
  is_palindrome_list(NumberList).
is_palindrome_list(List) ->
  List == lists:reverse(List).

%% Finds the largest palindrome made from the product of two 3-digits numbers
largest_palindrome_product_start() -> largest_palindrome_product(999, 999).
largest_palindrome_product(A, B) when A == 99 ->
  largest_palindrome_product(999, B - 1);
largest_palindrome_product(_, B) when B == 99 ->
  0;
largest_palindrome_product(A, B) ->
  Number = A * B,
  case is_palindrome(Number) of
    true -> max(largest_palindrome_product(A - 1, B), Number);
    false -> largest_palindrome_product(A - 1, B)
  end.
