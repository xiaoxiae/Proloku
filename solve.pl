?- use_module(library(clpfd)).

% ------------------------------ PARSING ------------------------------ %
% reads all lines of input
read_lines([H|T]) :- read_line_to_codes(user_input, H), H \= end_of_file, read_lines(T).
read_lines([]).

% parses a list of sudokus in the format of sudoku.txt into lists of integers
toIndividual([_,B,C,D,E,F,G,H,I,J|K], [[B,C,D,E,F,G,H,I,J] | L]) :- toIndividual(K, L).
toIndividual([], []).

% if zero is provided, a temporary value is added, else just return back whatever the number was
ifZeroThenBlank(0, _).
ifZeroThenBlank(X, X).

% [48,48,51,48,50,48,54,48,48] -> [_,_,5,_,1,_,3,_,_]
rowToNumbers([A|B], [C|D]) :- char_code(E, A), atom_number(E, F), ifZeroThenBlank(F, C), rowToNumbers(B, D).
rowToNumbers([], []).

% list of ^
toNumsHelper([A|B], [C|D]) :- rowToNumbers(A, C), toNumsHelper(B, D).
toNumsHelper([], []).

% list of lists of ^
toNums([A|B], [C|D]) :- toNumsHelper(A, C), toNums(B, D), !.
toNums([], []).

% --- %

% [48,48,51,48,50,48,54,48,48] -> [0,0,5,0,1,0,3,0,0]
rowToNumbers2([A|B], [C|D]) :- char_code(E, A), atom_number(E, C), rowToNumbers2(B, D).
rowToNumbers2([], []).

% list of ^
toNumsHelper2([A|B], [C|D]) :- rowToNumbers2(A, C), toNumsHelper2(B, D).
toNumsHelper2([], []).

% list of lists of ^
toNums2([A|B], [C|D]) :- toNumsHelper2(A, C), toNums2(B, D), !.
toNums2([], []).


% ------------------------------ PRINTING ------------------------------ %
printRow([A|X]) :- write(A), printRow(X).
printRow([]) :- nl.

printSolutions(I, [A|X]) :- write("Grid "), write(I), nl, maplist(printRow, A), J #= I + 1, printSolutions(J, X).
printSolutions(_, []).


% ------------------------------ UTILITIES ------------------------------ %
% checking for values in 3x3 squares
squares([A, B, C | L1], [D, E, F | L2], [G, H, I | L3]) :- all_distinct([A, B, C, D, E, F, G, H, I]), squares(L1, L2, L3).
squares([], [], []).

% all_distinct, but zeros are allowed
all_distinct_or_zero([X|XS]) :- ((X #= 0) ; not(member(X, XS))), all_distinct_or_zero(XS).
all_distinct_or_zero([]).

valid([R1, R2, R3, R4, R5, R6, R7, R8, R9]) :-
            A = [R1, R2, R3, R4, R5, R6, R7, R8, R9],
            append(A, All), All ins 1..9,  % digits are 1 though 9
            maplist(all_distinct, A), transpose(A, B), maplist(all_distinct, B), % rows and columns are distinct
            squares(R1, R2, R3), squares(R4, R5, R6), squares(R7, R8, R9).       % also constrain squares

% --- %

partial_squares([A, B, C | L1], [D, E, F | L2], [G, H, I | L3]) :- all_distinct_or_zero([A, B, C, D, E, F, G, H, I]), partial_squares(L1, L2, L3).
partial_squares([], [], []).

partial_valid([R1, R2, R3, R4, R5, R6, R7, R8, R9]) :-
            A = [R1, R2, R3, R4, R5, R6, R7, R8, R9],
            maplist(all_distinct_or_zero, A), transpose(A, B), maplist(all_distinct_or_zero, B),
            partial_squares(R1, R2, R3), partial_squares(R4, R5, R6), partial_squares(R7, R8, R9), !.


% ------------------------------ NAIVE SOLVING ------------------------------ %

% replace first zero in a list with a valid sudoku digit
replaceFirstZero([0|A], [X|A]) :- X in 1..9, label([X]).
replaceFirstZero([X|A], [X|B]) :- not(X #= 0), replaceFirstZero(A, B).
replaceFirstZero([], []).

% inverse of append() for a sudoku
split([A, B, C, D, E, F, G, H, I | X], [[A, B, C, D, E, F, G, H, I] | Y]) :- split(X, Y).
split([], []).

% add a next valid digit, instead of the first zero
addValid(A, B) :- append(A, All), replaceFirstZero(All, C), split(C, B), partial_valid(B).

% solve naively by adding valid digit after valid digit
% stop when adding next one doesn't do anything
solveNaive(A, B) :- (valid(A), A = B); (addValid(A, C), solveNaive(C, B)).

solveAllNaive([A | X], [B | Y]) :- solveNaive(A, B), solveAllNaive(X, Y).
solveAllNaive([], []).


% ------------------------------ SOLVING ------------------------------ %
solve(A) :- valid(A), append(A, All), labeling([], All). % force them to be valid and label them

solveAll([A | X]) :- solve(A), solveAll(X).
solveAll([]).


% ------------------------------ MAIN ------------------------------
main :- read_lines(X), toIndividual(X, K), toNums(K, L), solveAll(L), !, printSolutions(1, L).

% ------------------------------ NAIVE MAIN ------------------------------
main_naive :- read_lines(X), toIndividual(X, K), toNums2(K, L), solveAllNaive(L, M), !, printSolutions(1, M).
