%#!/usr/bin/env escript
%% -*- erlang -*-
%%! -smp enable

%%   --linear
%%   --lagrange
%%   --newton
%%   --gauss
%%   --step S
%%   -n N
-module(lab3).
-export([
  main/1,
  printer_loop/0,
  generator_loop/1,
  method_loop/5,
  compute_gauss/2,
  compute_lagrange/2,
  compute_linear/2,
  compute_newton/2
]).

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

  receive after 1000  -> ok end,

  %% EOF всем
  GeneratorPid ! eof,
  lists:foreach(fun(P) -> P ! eof end, MethodPids),
  PrinterPid ! eof,
  ok.

parse_args([], S) ->
  S;
parse_args(["--linear" | T], S) ->
  parse_args(T, S#state{methods = [linear | S#state.methods]});
parse_args(["--lagrange" | T], S) ->
  parse_args(T, S#state{methods = [lagrange | S#state.methods]});
parse_args(["--newton" | T], S) ->
  parse_args(T, S#state{methods = [newton | S#state.methods]});
parse_args(["--gauss" | T], S) ->
  parse_args(T, S#state{methods = [gauss | S#state.methods]});
parse_args(["--step", StepStr | T], S) ->
  {Step, _} = string:to_float(StepStr),
  parse_args(T, S#state{step = Step});
parse_args(["-n", NStr | T], S) ->
  {N, _} = string:to_integer(NStr),
  parse_args(T, S#state{n = N});
parse_args([_Unknown | T], S) ->
  parse_args(T, S).


start_methods(State, GenPid, PrinterPid) ->
  [ spawn(fun() ->
    method_loop(Method, State#state.n, GenPid, PrinterPid, [])
          end)
    || Method <- State#state.methods ].

input_loop(State, MethodPids, GenPid, Points) ->
  case io:get_line("") of
    eof -> ok;
    Line ->
      case parse_point(Line) of
        {ok, {X, Y}} ->
          NewPoints0 = Points ++ [{X, Y}],
          NewPoints = lists:sort(fun({A,_},{B,_}) -> A =< B end, NewPoints0),
          %io:format("DEBUG POINTS ~p~n", [NewPoints]),

          lists:foreach(fun(Pid) -> Pid ! {window, NewPoints} end, MethodPids),
          case NewPoints of
            [_,_|_] ->
              {Xmin, _} = hd(NewPoints),
              {Xmax, _} = lists:last(NewPoints),
              %io:format("SEND HAVE_POINTS ~p..~p~n", [Xmin, Xmax]),
              GenPid ! {have_points, Xmin, Xmax};
            _ -> ok
          end,
          input_loop(State, MethodPids, GenPid, NewPoints);
        error ->
          input_loop(State, MethodPids, GenPid, Points)
      end
  end.



parse_point(Line) ->
  Trim = string:trim(Line),
  case Trim of
    "" ->
      error;
    _ ->
      Tokens = string:tokens(Trim," "),
      case Tokens of
        [Xs, Ys] ->
          case {to_num(Xs), to_num(Ys)} of
            {{ok, X}, {ok, Y}} ->
              {ok, {X, Y}};
            _ ->
              error
          end;
        _ ->
          error
      end
  end.

to_num(S) ->
  case string:to_float(S) of
    {error,_Reason} ->
      case string:to_integer(S) of
        {error,_Reason2} ->
          error;
        {I, _Rest} ->
          {ok, float(I)}
      end;
    {F, _Rest} ->
      {ok, F}
  end.





generator_loop(Step) ->
  %io:format("GEN START, step=~p~n", [Step]),
  generator_loop(Step, -1.0e9, []).

generator_loop(Step, CoveredTo, Methods) ->
  receive
    {methods, Ms} ->
      generator_loop(Step, CoveredTo, Ms);
    {have_points, Xmin, Xmax} when Xmin =< Xmax ->
      StartX = max(CoveredTo, Xmin),
      NewCoveredTo = generate_xs_loop(StartX, Xmax, Step, Methods),
      generator_loop(Step, NewCoveredTo, Methods);
    {have_points, _, _} ->
      %io:format("SKIP INVALID RANGE ~p..~p~n", [Xmin, Xmax]),
      generator_loop(Step, CoveredTo, Methods);
    eof ->
      %io:format("GEN EOF~n"),
      ok;
    _ -> generator_loop(Step, CoveredTo, Methods)
  end.

generate_xs_loop(X, Xmax, Step, Methods) when X =< Xmax + 1.0e-12 ->
  %io:format("GEN XQ=~p send to ~p~n", [X, Methods]),
  lists:foreach(fun(Pid) -> Pid ! {xq, X} end, Methods),
  generate_xs_loop(X + Step, Xmax, Step, Methods);
generate_xs_loop(X, _Xmax, _Step, _Methods) ->
  X.



enough_points(linear,   Window) -> length(Window) >= 2;
enough_points(lagrange, Window) -> length(Window) >= 2;
enough_points(newton,   Window) -> length(Window) >= 2;
enough_points(gauss,    Window) -> length(Window) >= 3.
method_loop(Method, N, _GenPid, PrinterPid, Window) ->
  receive
    {window, Points} ->
      NewWindow = shrink_window(N, Points),
      %io:format("METHOD ~p NEW WINDOW ~p~n", [Method, NewWindow]),
      method_loop(Method, N, _GenPid, PrinterPid, NewWindow);

    {xq, Xq} ->
      %io:format("METHOD ~p GOT Xq=~p len=~p~n", [Method, Xq, length(Window)]),
      case enough_points(Method, Window) of
        false -> io:format("METHOD ~p SKIP (~p pts)~n", [Method, length(Window)]),
          method_loop(Method, N, _GenPid, PrinterPid, Window);
        true  ->
          Yq = compute(Method, Xq, Window),
          %io:format("METHOD ~p COMPUTE(~p)=~p~n", [Method, Xq, Yq]),
          case Yq of
            undefined -> method_loop(Method, N, _GenPid, PrinterPid, Window);
            _ -> PrinterPid ! {result, Method, Xq, Yq},
              method_loop(Method, N, _GenPid, PrinterPid, Window)
          end
      end;

    eof ->
      %io:format("METHOD ~p EOF~n", [Method]),
      ok;

    _Other ->
      %io:format("METHOD ~p OTHER ~p~n", [Method, Other]),
      method_loop(Method, N, _GenPid, PrinterPid, Window)
  end.



shrink_window(N, Points) ->
  Len = length(Points),
  Window0 =
    if
      Len =< N -> Points;
      true     -> lists:sublist(Points, Len - N + 1, N)
    end,
  lists:sort(fun({X1,_},{X2,_}) -> X1 =< X2 end, Window0).



compute(linear,   X, Points) -> compute_linear(X, Points);
compute(lagrange, X, Points) -> compute_lagrange(X, Points);
compute(newton,   X, Points) -> compute_newton(X, Points);
compute(gauss,    X, Points) -> compute_gauss(X, Points).

compute_linear(_X, [])  -> undefined;
compute_linear(_X, [_]) -> undefined;
compute_linear(X, Points) ->
  case find_segment(X, Points) of
    none ->
      undefined;
    {{X1,Y1},{X2,Y2}} ->
      case X2 =:= X1 of
        true  -> Y1;
        false ->
          T = (X - X1) / (X2 - X1),
          Y1 + T * (Y2 - Y1)
      end
  end.

find_segment(_X, [])        -> none;
find_segment(_X, [_])       -> none;
find_segment(X, [{X1,Y1},{X2,Y2}|T]) ->
  if
    X1 =< X, X =< X2 -> {{X1,Y1},{X2,Y2}};
    true             -> find_segment(X, [{X2,Y2}|T])
  end.

compute_lagrange(_X, [])  -> undefined;
compute_lagrange(_X, [{_,Y}]) -> Y;
compute_lagrange(X, Points) ->
  lagrange_eval(X, Points).

lagrange_eval(X, Points) ->
  Indexed = index_points(Points, 1),
  lists:sum(
    [ Yi * lagrange_basis(I, X, Points, Indexed)
      || {I,{_Xi,Yi}} <- Indexed ]).

index_points([], _I) -> [];
index_points([P|T], I) ->
  [{I,P} | index_points(T, I+1)].

lagrange_basis(I, X, Points, Indexed) ->
  {Xi,_} = lists:nth(I, Points),
  lists:foldl(
    fun({J,{Xj,_}}, Acc) ->
      if J =:= I -> Acc;
        true ->
          Acc * (X - Xj) / (Xi - Xj)
      end
    end,
    1.0,
    Indexed).

compute_newton(_X, [])         -> undefined;
compute_newton(_X, [{_,Y}])    -> Y;
compute_newton(X, Points) ->
  Coefs = newton_divided_diffs(Points),
  newton_eval(X, Points, Coefs).

newton_divided_diffs(Points) ->
  Xs = [X || {X,_} <- Points],
  Ys = [Y || {_,Y} <- Points],
  newton_dd(Xs, [Ys]).

newton_dd(_Xs, [Row]) ->
  [hd(Row)];
newton_dd(Xs, [Row | _]=AllRows) ->
  K = length(AllRows) - 1,
  NewRow =
    [ (lists:nth(I+1, Row) - lists:nth(I, Row))
      / (lists:nth(I+K+1, Xs) - lists:nth(I, Xs))
      || I <- lists:seq(1, length(Row)-1)],
  [hd(Row) | newton_dd(Xs, [NewRow | AllRows])].

newton_eval(X, Points, Coefs) ->
  Xs = [X0 || {X0,_} <- Points],
  Deg = length(Coefs) - 1,
  newton_eval_horner(X, Xs, lists:reverse(Coefs), Deg).

newton_eval_horner(X, Xs, [A0|Rest], Deg) ->
  lists:foldl(
    fun({A,K}, Acc) ->
      Acc * (X - lists:nth(K, Xs)) + A
    end,
    A0,
    lists:zip(Rest, lists:seq(1, Deg))).

compute_gauss(_X, [])         -> undefined;
compute_gauss(_X, [{_,Y}])    -> Y;
compute_gauss(X, Points) ->
  case equally_spaced(Points) of
    false -> undefined;
    {true, H} ->
      gauss_central_eval(X, Points, H)
  end.

equally_spaced(Points) ->
  Xs = [X || {X,_} <- Points],
  case Xs of
    []  -> false;
    [_] -> false;
    [X1,X2|Rest] ->
      H = X2 - X1,
      Pairs = pairs([X1,X2|Rest]),
      case lists:all(fun({A,B}) -> abs((B-A)-H) < 1.0e-9 end, Pairs) of
        true  -> {true, H};
        false -> false
      end
  end.

pairs([A,B|T]) -> [{A,B} | pairs([B|T])];
pairs(_)       -> [].

forward_diff_table(Ys) ->
  forward_diff_table(Ys, []).

forward_diff_table([Row], Acc) ->
  lists:reverse([Row | Acc]);
forward_diff_table(Row, Acc) ->
  Next =
    [ lists:nth(I+1, Row) - lists:nth(I, Row)
      || I <- lists:seq(1, length(Row)-1)],
  forward_diff_table(Next, [Row | Acc]).

gauss_central_eval(X, Points, H) ->
  Ys = [Y || {_,Y} <- Points],
  DiffTable = forward_diff_table(Ys),
  N = length(Points),
  C = (N + 1) div 2,
  {Xc,_} = lists:nth(C, Points),
  P = (X - Xc) / H,
  gauss_series(P, DiffTable, C).

gauss_series(P, DiffTable, C) ->
  Y0 = lists:nth(C, hd(DiffTable)),
  gauss_series_terms(P, DiffTable, C, 1, Y0).

gauss_series_terms(_P, _DiffTable, _C, K, Acc) when K >= 20 ->
  Acc;
gauss_series_terms(P, DiffTable, C, K, Acc) ->
  case get_central_delta(DiffTable, C, K) of
    undefined ->
      Acc;
    Dk ->
      Term = (central_p_product(P, K) / fact(K)) * Dk,
      gauss_series_terms(P, DiffTable, C, K+1, Acc + Term)
  end.


central_p_product(P, 1) -> P;
central_p_product(P, K) ->
  central_p_product_seq(P, K, P, 1).

central_p_product_seq(_P, K, Acc, K) ->
  Acc;
central_p_product_seq(P, K, Acc, M) ->
  Offset =
    case M rem 2 of
      1 -> (M+1) div 2;
      0 -> - (M div 2)
    end,
  central_p_product_seq(P, K, Acc * (P + Offset), M+1).

fact(N) when N =< 1 -> 1.0;
fact(N)             -> lists:product(lists:seq(1,N)) * 1.0.

get_central_delta(DiffTable, C, K) ->
  try
    case lists:nthtail(K, DiffTable) of
      [] -> undefined;
      [Row | _] ->
        Index = C - (K div 2),
        if
          Index < 1 orelse Index > length(Row) ->
            undefined;
          true ->
            lists:nth(Index, Row)
        end
    end
  catch
    _:_ -> undefined
  end.

printer_loop() ->
  receive
    {result, Method, X, Y} ->
      %io:format("DEBUG PRINTER GOT ~p ~p ~p~n", [Method, X, Y]),
      io:format("~s: ~.10g ~.10g~n", [method_prefix(Method), X, Y]),
      printer_loop();
    eof ->
      %io:format("DEBUG PRINTER EOF~n", []),
      ok;
    _Other ->
      %io:format("DEBUG PRINTER OTHER ~p~n", [Other]),
      printer_loop()
  end.


method_prefix(linear)   -> "linear";
method_prefix(lagrange) -> "lagrange";
method_prefix(newton)   -> "newton";
method_prefix(gauss)    -> "gauss".
