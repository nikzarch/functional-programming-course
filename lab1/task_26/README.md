# Completed by
Зонов Николай
 - - -
# Solutions for Project Euler's Problem № 26:
> Find the value of d < 1000  for which 1/d contains the longest recurring cycle in its decimal fraction part.

## cycle_length(D) util function
```erlang
cycle_length(D) ->
    check_cycle(1, [], 0, D).

check_cycle(R, Seen, Step, D) ->
    case lists:keyfind(R, 1, Seen) of
        {_, FirstStep} ->
            Step - FirstStep;
        false when R =:= 0 -> 0;
        false ->
            NewR = (R * 10) rem D,
            check_cycle(NewR, [{R, Step} | Seen], Step + 1, D)
    end.
```

## Tail recursive solution
```erlang
find_longest_recurring_cycle() ->
    {Answer,_ } = find_longest_recurring_cycle(2, 999, 0, 0),
    Answer.

find_longest_recurring_cycle(D, MaxD, BestD, BestLen) when D > MaxD ->
    {BestD, BestLen};
find_longest_recurring_cycle(D, MaxD, BestD, BestLen) ->
    Len = cycle_length(D),
    if
        Len > BestLen ->
            find_longest_recurring_cycle(D + 1, MaxD, D, Len);
        true ->
            find_longest_recurring_cycle(D + 1, MaxD, BestD, BestLen)
    end.
```

## Regular recursive solution
```erlang
find_longest_recurring_cycle() ->
    {Answer,_ } = find_longest_recurring_cycle(2, 999),
    Answer.

find_longest_recurring_cycle(D, MaxD) when D > MaxD ->
    {0, 0};
find_longest_recurring_cycle(D, MaxD) ->
    Len = cycle_length(D),
    {BestDNext, BestLenNext} = find_longest_recurring_cycle(D + 1, MaxD),
    if
        Len > BestLenNext -> {D, Len};
        true -> {BestDNext, BestLenNext}
    end.
```

## Module solution
```erlang
generate_list_of_numbers() ->
    [X || X <- lists:seq(1, 999)].

filter_numbers_with_recurring_cycle(NumberList) ->
    lists:filter(
        fun(A) ->
            case cycle_length(A) of
                Len when Len > 0 -> true;
                0 -> false
            end
        end,
        NumberList
    ).
fold_into_max_one([H | T]) ->
    lists:foldl(
        fun(A, B) ->
            case cycle_length(A) > cycle_length(B) of
                true -> A;
                false -> B
            end
        end,
        H,
        T
    ).

find_longest_recurring_cycle() ->
    List = generate_list_of_numbers(),
    FilteredList = filter_numbers_with_recurring_cycle(List),
    fold_into_max_one(FilteredList).
```
## List comprehension solution
```erlang
find_longest_recurring_cycle() ->
    {_, Answer} = lists:max([{cycle_length(D), D} || D <- lists:seq(2, 999)]),
    Answer.
```
## Map (function) solution
```erlang
find_longest_recurring_cycle() ->
    NumberList = lists:seq(2, 999),
    Pairs = lists:map(fun(D) -> {cycle_length(D), D} end, NumberList),
    NonZero = lists:filter(fun({Len, _}) -> Len > 0 end, Pairs),
    {_, Ans} = lists:max(NonZero),
    Ans.
```

## Go solution
```go
func cycleLength(d int) int {
	seen := make(map[int]int) // remainder, step
	remainder := 1
	step := 0

	for remainder != 0 {
		if firstStep, ok := seen[remainder]; ok {
			return step - firstStep
		}
		seen[remainder] = step
		remainder = (remainder * 10) % d
		step++
	}

	return 0
}

func findLongestRecurring(limit int) int {
	maxLen := 0
	bestD := 0

	for d := 2; d < limit; d++ {
		length := cycleLength(d)
		if length > maxLen {
			maxLen = length
			bestD = d
		}
	}

	return bestD
}

func main() {
	d := findLongestRecurring(1000)
	fmt.Println(d)
}
```
# Answer is 983