# Completed by
Зонов Николай
 - - -
# Lab 3

Запуск

```bash
./lab3.escript --linear --lagrange --newton --gauss --step 0.1 
```
--linear, --lagrange, --newton, --gauss — включение соответствующих методов.

--step S — шаг генерации промежуточных точек (по умолчанию 0.5).

# Ключевые моменты реализации

## Точка входа
```erlang
-record(state, {
  methods = [],   % [linear,lagrange,newton,gauss]
  step    = 0.5,
  n       = 4
}).

main(Args) ->
  State0 = parse_args(Args, #state{}),
  Methods =
    case State0#state.methods of
      [] -> [linear];
      Ms -> lists:usort(Ms)
    end,
  State = State0#state{methods = Methods},

  PrinterPid   = spawn(fun() -> printer_loop() end),
  GeneratorPid = spawn(fun() -> generator_loop(State#state.step) end),
  MethodPids   = start_methods(State, GeneratorPid, PrinterPid),

  GeneratorPid ! {methods, MethodPids},
  input_loop(State, MethodPids, GeneratorPid, []),

  GeneratorPid ! eof,
  lists:foreach(fun(P) -> P ! eof end, MethodPids),
  PrinterPid ! eof,
  ok.
```
## Цикл для ввода
```erlang
input_loop(State, MethodPids, GenPid, Points) ->
  case io:get_line("") of
    eof -> ok;
    Line ->
      case parse_point(Line) of
        {ok, {X, Y}} ->
          NewPoints0 = Points ++ [{X, Y}],
          NewPoints = lists:sort(fun({A,_},{B,_}) -> A =< B end, NewPoints0),
          lists:foreach(fun(Pid) -> Pid ! {window, NewPoints} end, MethodPids),
          input_loop(State, MethodPids, GenPid, NewPoints);
        error -> input_loop(State, MethodPids, GenPid, Points)
      end
  end.

```
## Интерполяции всякие
```erlang
compute_linear(_X, [])  -> undefined;
compute_linear(_X, [_]) -> undefined;
compute_linear(X, Points) ->
  case find_segment(X, Points) of
    none -> undefined;
    {{X1,Y1},{X2,Y2}} ->
      case X2 =:= X1 of
        true  -> Y1;
        false ->
          T = (X - X1) / (X2 - X1),
          Y1 + T * (Y2 - Y1)
      end
  end.

compute_lagrange(_X, [])  -> undefined;
compute_lagrange(_X, [{_,Y}]) -> Y;
compute_lagrange(X, Points) ->
  Indexed = index_points(Points, 1),
  lists:sum(
    [ Yi * lagrange_basis(I, X, Points, Indexed)
      || {I,{_Xi,Yi}} <- Indexed ]).

compute_newton(_X, [])      -> undefined;
compute_newton(_X, [{_,Y}]) -> Y;
compute_newton(X, Points) ->
  Coefs = newton_divided_diffs(Points),
  newton_eval(X, Points, Coefs).

```
