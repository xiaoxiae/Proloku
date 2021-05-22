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


% ------------------------------ PRINTING ------------------------------ %
printRow([A|X]) :- write(A), printRow(X).
printRow([]) :- nl.

printSolutions(I, [A|X]) :- write("Grid "), write(I), nl, maplist(printRow, A), J #= I + 1, printSolutions(J, X).
printSolutions(_, []).


% ------------------------------ UTILITIES ------------------------------ %
% checking for values in 3x3 squares
squares([A, B, C | L1], [D, E, F | L2], [G, H, I | L3]) :- all_distinct([A, B, C, D, E, F, G, H, I]), squares(L1, L2, L3).
squares([], [], []).

valid([R1, R2, R3, R4, R5, R6, R7, R8, R9]) :-
            A = [R1, R2, R3, R4, R5, R6, R7, R8, R9],
            maplist(all_distinct, A), transpose(A, B), maplist(all_distinct, B), % rows and columns are distinct
            squares(R1, R2, R3), squares(R4, R5, R6), squares(R7, R8, R9).       % also constrain squares


% ------------------------------ SOLVING ------------------------------ %
% solve a sudoku
solve(A) :- append(A, All), All ins 1..9,  % digits are 1 though 9
            valid(A), labeling([], All).   % force them to be valid and label them

% solve all sudokus
solveAll([A | X]) :- solve(A), solveAll(X).
solveAll([]).


% ------------------------------ MAIN ------------------------------
main :- read_lines(X), toIndividual(X, K), toNums(K, L), solveAll(L), !, printSolutions(1, L).
