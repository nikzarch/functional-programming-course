Solutions for Project Euler's Problem № 4:
> A palindromic number reads the same both ways. The largest palindrome made from the product of two
> 2-digit numbers is 9009 = 91 * 99.
>
>Find the largest palindrome made from the product of two 3-digit numbers.

## is_palindrome(Number) util function
```erlang
is_palindrome(Number) when is_integer(Number) ->
    NumberList = integer_to_list(Number),
    is_palindrome_list(NumberList).
is_palindrome_list(List) ->
    List == lists:reverse(List).
```
## Simple tail recursive solution

```erlang
%% Finds the largest palindrome made from the product of two 3-digits numbers
largest_palindrome_product() -> largest_palindrome_product(999, 999, 0).
largest_palindrome_product(A, B, Max) when A == 99 ->
  largest_palindrome_product(999, B - 1, Max);
largest_palindrome_product(_, B, Max) when B == 99 ->
  Max;
largest_palindrome_product(A, B, Max) ->
  Number = A * B,
  case is_palindrome(Number) of
    true ->
      if
        Number > Max ->
          largest_palindrome_product(A - 1, B, Number);
        true ->
          largest_palindrome_product(A - 1, B, Max)
      end;
    false ->
      largest_palindrome_product(A - 1, B, Max)
  end.
```

## Simple regular recursive solution

```erlang
%% Finds the largest palindrome made from the product of two 3-digits numbers
largest_palindrome_product() -> largest_palindrome_product(999, 999).
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
```

## Module solution
```erlang
generate_list_of_products() ->
  [X * Y || X <- lists:seq(100, 999), Y <- lists:seq(100, 999)].
filter_palindromes(Products) ->
  lists:filter(fun(X) -> is_palindrome(X) end, Products).
fold_into_max_product(Palindromes) ->
  [H | T] = Palindromes,
  lists:foldl(fun(A, B) when A > B -> A; (_, B) -> B end, H, T).

%% Finds the largest palindrome made from the product of two 3-digits numbers
largest_palindrome_product() ->
  Products = generate_list_of_products(),
  ProductsFiltered = filter_palindromes(Products),
  fold_into_max_product(ProductsFiltered).

```

## Module solution
```erlang
generate_list_of_products() ->
    [X * Y || X <- lists:seq(100, 999), Y <- lists:seq(100, 999)].
filter_palindromes(Products) ->
    lists:filter(fun(X) -> is_palindrome(X) end, Products).
fold_into_max_product(Palindromes) ->
    [H | T] = Palindromes,
    lists:foldl(
        fun
            (A, B) when A > B -> A;
            (_, B) -> B
        end,
        H,
        T
    ).

%% Finds the largest palindrome made from the product of two 3-digits numbers
largest_palindrome_product() ->
    Products = generate_list_of_products(),
    ProductsFiltered = filter_palindromes(Products),
    fold_into_max_product(ProductsFiltered).
```

## List comprehension solution
```erlang
%% Finds the largest palindrome made from the product of two 3-digits numbers
largest_palindrome_product() ->
    lists:max([X * Y || X <- lists:seq(100, 999), Y <- lists:seq(100, 999), is_palindrome(X * Y)]).
```

## Map (function) solution
```erlang
largest_palindrome_product() ->
    MappedList = lists:map(fun({X, Y}) -> X * Y end, [
        {X, Y}
     || X <- lists:seq(100, 999), Y <- lists:seq(100, 999)
    ]),
    FilteredList = lists:filter(fun(X) -> is_palindrome(X) end, MappedList),
    lists:max(FilteredList).
```
## Go solution
```go
func main() {
	maxProduct := 0
	for i := 100; i < 1000; i++ {
		for j := 100; j < 1000; j++ {
			product := i * j
			if isPalindrome(product) && product > maxProduct {
				maxProduct = product
			}
		}
	}
	fmt.Println(maxProduct)
}

func isPalindrome(x int) bool {
	s := strconv.Itoa(x)
	for i := 0; i < len(s)/2; i++ {
		if s[i] != s[len(s)-1-i] {
			return false
		}
	}
	return true
}
```
# Answer is 906609