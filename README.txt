I: HOW TO RUN THIS GAME

Open 'GDstep.exe'.

	

II: HOW TO MAKE YOUR OWN CHARTS

Charts are stored as JSON files under /Charts/. JSON files can be created by making a new text file and renaming the file extension to '.json'.
All charts need an accompanying song file in .ogg format. The song file should be stored under /Assets/music/.
The BPM of the accompanying song must also be known and written into the JSON file.
The notes in the chart are stored as a string of characters:
    - Single notes are denoted by numbers 1-5.
    - 2 or more notes occurring at the same time (referred to as Brackets) are denoted by letters A-Z.
    - An empty space (a beat without a note) is denoted by a *.

* = Empty space

1, 2, 3, 4, 5 = Single notes for keys Q, W, SPACE, O, P
6, 7, 8, 9 = Keys Q, W, O, P (Shifted) (3 aka key SPACE does not shift)

A-J = 2-Brackets:
A = 1,2		B = 1,3		C = 1,4		D = 1,5
E = 2,3		F = 2,4		G = 2,5
H = 3,4		I = 3,5
J = 4,5

K-T = 3-Brackets:
K = 1,2,3	L = 1,2,4	M = 1,2,5	N = 1,3,4	O = 1,3,5	P = 1,4,5
Q = 2,3,4	R = 2,3,5	S = 2,4,5
T = 3,4,5

U-Y = 4-Brackets:
U = 1,2,3,4		V = 1,2,3,5		W = 1,2,4,5		X = 1,3,4,5
Y = 2,3,4,5

Z = 5-Bracket:
Z = 1,2,3,4,5

The Shifted versions of a bracket are represented by the same letter, but in lowercase.



III: TROUBLESHOOTING

If the /Charts/ folder appears empty in-game, try refreshing by using the curly arrow button at the top of the window.

Please direct any questions/comments/problems/bugs to: tianbrown@gmail.com. Thank you!