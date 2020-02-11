TITLE tictactoe.asm
; Program Description: This is the final project simulating a game of tic-tac-toe,
; either between 2 players, player vs computer, or computer vs computer.

; ***THINGS TO NOTE*** : 

; - Computer vs. Computer option works as intended other than including a 1 second delay. Due to how
; certain procs were coded, the option instead requires 2 subsequent key presses to see the next turn (which could be done in 1 second, I guess).

; - When exiting the program through pressing 'n' when asked to play again, the stats displayed for amount of games played will display the wrong amount
; by a large amount. However, when going to the actual statistics option (option4), the stats are all displayed correctly.

; Author: Alen Handukic
; Creation Date: 12/2/19

Include Irvine32.inc

DisplayMenu PROTO ; protos for invoking
errorMsg PROTO

option1 PROTO

printBoard PROTO
choosePlayer PROTO
switchPlayer PROTO
compChooseSquare PROTO
userChooseSquare PROTO
checkWinner PROTO
checkDraw PROTO
playAgain PROTO
clearBoard PROTO

option2 PROTO

option3 PROTO

option4 PROTO

.data
userOption BYTE 0h

gamesPlayed BYTE 0h
gamesWonPlayer1 BYTE 0h
gamesWonPlayer2 BYTE 0h
gamesWonComp BYTE 0h
gameDraws BYTE 0h

gameOverMsg BYTE "****** GAME OVER! ******", 0Ah, 0Dh, 0h

.code
main PROC
call Randomize ; seeding

startHere:

mov ebx, offset userOption
invoke DisplayMenu

opt1:
cmp userOption, 1 ; options 1-5
jne opt2
call clrscr
mov esi, offset gamesPlayed ; pass stat counters into proc
mov ebx, offset gamesWonPlayer1
mov ecx, offset gamesWonComp
mov edi, offset gameDraws
invoke option1
cmp bl, 1 ; using the value from the playAgain proc to check if we're still playing the game
jne quitit
jmp startHere

opt2:
cmp userOption, 2
jne opt3
call clrscr
mov esi, offset gamesPlayed
mov ecx, offset gamesWonComp ; only computers are playing here
mov edi, offset gameDraws
invoke option2
cmp bl, 1 ; using the value from the playAgain proc to check if we're still playing the game
jne quitit
jmp startHere

opt3:
cmp userOption, 3
jne opt4
call clrscr
mov esi, offset gamesPlayed
mov ebx, offset gamesWonPlayer1
mov ecx, offset gamesWonPlayer2
mov edi, offset gameDraws
invoke option3 
cmp bl, 1
jne quitit
jmp startHere

opt4:
cmp userOption, 4
jne opt5
call clrscr
mov esi, offset gamesPlayed
mov ebx, offset gamesWonPlayer1
mov ecx, offset gamesWonPlayer2
mov edx, offset gamesWonComp
mov edi, offset gameDraws
invoke option4
jmp startHere

opt5:
cmp userOption, 5
jne oops ; invalid entry
jmp quitit

oops:
invoke errorMsg ; displays error message and returns to menu
jmp startHere

quitit:
call crlf
mov edx, offset gameOverMsg
call writestring

mov esi, offset gamesPlayed ; when the user decides to quit, display the stats
mov ebx, offset gamesWonPlayer1
mov ecx, offset gamesWonPlayer2
mov edx, offset gamesWonComp
mov edi, offset gameDraws
invoke option4

exit
main ENDP



DisplayMenu Proc
;// Description:  Displays the Main Menu to the screen and gets user input
;// Receives:  Offset of UserOption variable in ebx
;// Returns:  User input will be saved to UserOption variable

.data
MainMenu byte 'Welcome to Tic-Tac-Toe!', 0Ah, 0Dh,
              '========================', 0Ah, 0Dh,
              '1. Player vs. Computer ',0Ah, 0Dh,
              '2. Computer vs. Computer ',0Ah, 0Dh,
			  '3. Player vs. Player ',0Ah, 0Dh,
			  '4. Stats ',0Ah, 0Dh,
              '5. Exit ',0Ah, 0Dh, 0Ah, 0Dh,
              'Please enter a number between 1 and 5 -->  ', 0h

.code
push edx  				      ;// preserves current value of edx - the strings offset
call clrscr
mov edx, offset MainMenu   ;// required by WriteString
call WriteString
call readhex			      ;// get user input
mov byte ptr [ebx], al	   ;// save user input to UserOption
pop edx    				      ;// restores current value of edx

ret
DisplayMenu ENDP



errorMsg PROC ;------------------------------------------
;Description:  Displays Error Message on invalid entry
;Receives :    Nothing
;Returns :     Nothing
;--------------------------------------------------------
.data
errormessage byte 'You have entered an invalid option. Please try again.', 0Ah, 0Dh, 0h

.code
push edx                      ;// Save value in edx
mov edx, offset errormessage
call writestring
call waitmsg
pop edx                       ;// restore value in edx

ret
errorMsg ENDP



option1 PROC ;-----------------------------------------------------
;Description: Allows user to play the game against another the
; computer.
;Receives: stat counters in registers -- gamesPlayed in esi,
; gamesWonPlayer1 in ebx, gamesWonComp in ecx, gameDraws
; in edi.
;Returns: updated stat counters after game(s) over.
;------------------------------------------------------------------
.data
gameBoard BYTE  '- | - | -', 0Ah, 0Dh,
				'- | - | -', 0Ah, 0Dh,
				'- | - | -', 0Ah, 0Dh, 0h

userStartMsg BYTE "You are player 1! (X)", 0Ah, 0Dh, 0h
compStartMsg BYTE "You are player 2! (O)", 0Ah, 0Dh, 0h

userPlayerNum BYTE ?

userChar BYTE ?
compChar BYTE ?

chooseMsg BYTE "Player ", 0h
chooseMsg2 BYTE " choose a sqaure!", 0Ah, 0Dh, 0h

winMsg BYTE "Player ", 0h
winMsg2 BYTE " wins!", 0Ah, 0Dh, 0h

drawMsg BYTE "It's a Draw! No winners.", 0Ah, 0Dh, 0h


.code
push edi
push esi
push ecx
push ebx

mov edx, offset userPlayerNum

invoke choosePlayer ; choose who goes first randomly
mov byte ptr [edx], al ; save user player number
cmp al, 1 ; 1 = user begins, 2 = computer begins
jne compStarts
mov edx, offset userChar
mov byte ptr [edx], 'X' ; assign user's character to X if they're player 1
mov edx, offset compChar
mov byte ptr [edx], 'O' ; and assign comp's character to O
jmp userStarts

userStarts:
mov edx, offset userStartMsg ; display message that user is player 1
call writestring
mov eax, 1 ; we always start with player 1
call waitmsg
call clrscr
jmp playGame


compStarts:
mov edx, offset compChar
mov byte ptr [edx], 'X' ; assign computer's character to X if they're player 1
mov edx, offset userChar
mov byte ptr [edx], 'O' ; and assign user's character to O
mov edx, offset compStartMsg ; display message that user is player 2
call writestring
mov eax, 1 ; we always start with player 1
call waitmsg
call clrscr
jmp playGame


playGame:
	mov edx, offset chooseMsg
	call writestring
	call writeDec
	mov edx, offset chooseMsg2
	call writestring
	mov edx, offset gameBoard

	invoke printBoard ; always show the board after each turn
	
	mov edx, offset userPlayerNum 
	cmp byte ptr[edx], al ; use the user's player number to see if it's their turn based on what is in eax
	jne compPlay
	mov edx, offset gameBoard ; gameBoard will be in edx
	mov ebx, offset userChar ; user's character will be in ebx if it's their turn
	invoke userChooseSquare ; allow user to play their turn
	invoke checkWinner ; check for a winner
	cmp bl, 1 ; if bl returns with 1, user wins
	je winnerFound
	invoke checkDraw ; check if the board indicates a draw
	cmp bl, 1 ; if bl returns with 1, there is a draw
	je drawFound
	invoke switchPlayer ; if no winner or draw, switch players for the next turn
	jmp playGame

	compPlay:
		mov edx, offset gameBoard ; same process for computer player
		mov ebx, offset compChar
		invoke compChooseSquare
		invoke checkWinner
		cmp bl, 1
		je winnerFound
		invoke checkDraw
		cmp bl, 1
		je drawFound
		invoke switchPlayer
		jmp playGame

winnerFound:
	push eax
	mov eax, 7 + (0*16) ; reset color to light gray on black
	call settextcolor
	pop eax

	push edx
	mov dh, 3 ; reset cursor to correct position under the board
	mov dl, 0
	call gotoxy
	pop edx

	cmp al, 'X' ; check to see which player won
	jne ply2Win
	mov al, 1
	mov edx, offset winMsg ; display winning messages
	call writestring
	call writeDec
	mov edx, offset winMsg2
	call writestring
	pop ebx
	mov edx, offset userPlayerNum
	cmp byte ptr [edx], 1
	jne compWin1 ; check if the winner was the computer first
	inc byte ptr [ebx] ; increment amount of player 1 wins if not computer
	pop ecx
	pop esi
	inc byte ptr [esi] ; increment amount of games played
	pop edi
	jmp donePlaying

	compWin1:
		pop ecx
		inc byte ptr [ecx] ; increment amount of computer wins
		pop esi
		inc byte ptr [esi] ; increment amount of games played
		pop edi
		jmp donePlaying
	
	ply2Win: ; same process for player 2 winning
		mov al, 2
		mov edx, offset winMsg
		call writestring
		call writeDec
		mov edx, offset winMsg2
		call writestring
		pop ebx
		mov edx, offset userPlayerNum
		cmp byte ptr [edx], 2
		jne CompWin2
		mov edx, offset gamesWonPlayer2 ; increment amount of player 2 wins if not computer
		inc byte ptr [edx]
		pop ecx
		pop esi
		inc byte ptr [esi] ; increment amount of games played
		pop edi
		jmp donePlaying

		compWin2:
		pop ecx
		inc byte ptr [ecx] ; increment amount of computer wins
		pop esi
		inc byte ptr [esi] ; increment amount of games played
		pop edi
		jmp donePlaying
	

drawFound:
	call clrscr
	mov edx, offset gameBoard ; if a draw was found, just display the board and inform of a draw, and end game
	invoke printBoard
	mov edx, offset drawMsg
	call writestring
	pop ebx
	pop ecx
	pop esi
	inc byte ptr [esi] ; increment amount of games played
	pop edi
	inc byte ptr [edi] ; increment the amount of draws
	jmp donePlaying

donePlaying:
call waitmsg
mov edx, offset gameBoard
call crlf
invoke playAgain

ret
option1 ENDP



printBoard PROC ;-----------------------------------
;Description: Prints the current tic-tac-toe board.
;Receives: offset of board in edx
;Returns: display
;---------------------------------------------------
call writestring
ret
printBoard ENDP



choosePlayer PROC ;------------------------------
;Description: randomly chooses who goes first if
; player vs. computer.
;Receives: N/A
;Returns: value of 1 or 2 in eax
;------------------------------------------------
mov eax, 2
call randomRange ; get either 1 or 2 in eax
inc eax

ret
choosePlayer ENDP



switchPlayer PROC ;----
;Description: Switches between players when a turn has
; finished.
;Receives: eax with last character (X/O) played which
; indicates which player it was. (X=1, O=2)
;Returns: 1 or 2 in eax
;-----------------------
cmp al, 'X'
jne switchToPlayer1
mov al, 2 ; if player 1 has just played, it's player 2's turn
jmp doneSwitching

switchToPlayer1:
	mov al, 1 ; if player 2 has just played, it's player 1's turn

doneSwitching:

ret
switchPlayer ENDP



playAgain PROC ;------------------------------------------
;Description: asks user if they want to play again
;Recieves: edx for gameboard offset
;Returns: 0 or 1 in bl as a bool, and potentially cleared
; game board.
;---------------------------------------------------------
.data
playAgainMsg BYTE "Do you wish to continue playing? (y/n)", 0Ah, 0Dh, 0h
playAgainErrorMsg BYTE "Please enter y/n as a response.", 0Ah, 0Dh, 0h

.code
mov eax, 0 ; eax used for reading y/n
push edx
mov edx, offset playAgainMsg
call writestring
pop edx

startAgain:
call readChar

cmp al, 'y'
jne noPlay
invoke clearBoard ; if user wants to play some more, clear the board and move 1 to bl
mov bl, 1 
jmp allDone

noPlay:
	cmp al, 'n'
	jne badInput
	mov bl, 0 ; if not, move 0 to bl
	jmp allDone

badInput:
	push edx
	mov edx, offset playAgainErrorMsg
	call writestring
	pop edx
	jmp startAgain

allDone:
ret
playAgain ENDP



clearBoard PROC ;-----------
;Description: Clears the game board in the event that
; the player wants to continue playing.
;Receives: edx for gameBoard offset
;Returns: a clear board
;--------------------------
mov byte ptr [edx], '-' ; remove all Xs and Os from the board by replacing them with the original dashes
mov byte ptr [edx + 4], '-'
mov byte ptr [edx + 8], '-'

mov byte ptr [edx + 11], '-'
mov byte ptr [edx + 15], '-'
mov byte ptr [edx + 19], '-'

mov byte ptr [edx + 22], '-'
mov byte ptr [edx + 26], '-'
mov byte ptr [edx + 30], '-'

ret
clearBoard ENDP

userChooseSquare PROC ;---------------------------------
;Description: if it's the user's turn, then
; this allows them to choose an empty square
; and fill it with their appropriate character.
;Receives: offset of board in edx, user character (X/O)
; in ebx
;Returns: updated board
;-------------------------------------------------------
.data
notEmptyMsg BYTE "That square is already filled! Please choose an empty square.", 0Ah, 0Dh, 0h
outBoundsMsg BYTE "Input is out of bounds! Please choose an empty square.", 0Ah, 0Dh, 0h

invalidEntryMsg BYTE "Invalid input! Please choose an empty square (1-9).", 0Ah, 0Dh, 0h

.code
mov al, byte ptr [ebx] ; move character to eax


continueUserChoose:
push eax
call readDec ; user input

cmp al, 9 ; first check if input is out of bounds of 1-9 and display error if so
ja outOfBounds
cmp al, 1
jl outOfBounds

cmp al, 1 ; check squares 1-9 now													 SQUARE 1
jne sq2
pop eax
cmp byte ptr [edx], "-" ; check if empty first
je fillSq1
jmp filledSquare ; if not empty, display error and choose again

fillSq1: ; if empty, then highlight the square and fill it in
	cmp al, 'X'
	jne setYellow1
	push eax
	mov eax, 0 + (4 * 16) ; black on red (if X)
	call settextcolor
	pop eax

	push edx
	mov edx, 0
	mov dh, 1 ; square 1 is in row 1, column 0
	mov dl, 0
	call gotoxy
	pop edx

	mov ecx, 0
	mov ecx, 2
	mov esi, 0
	push eax
	highlightSq1Red:
		mov al, byte ptr[edx + esi]
		call writeChar
		inc esi
		loop highlightSq1Red
	pop eax
	jmp continueFillSq1

	setYellow1:
	push eax
	mov eax, 0 + (14 * 16) ; black on yellow (if O)
	call settextcolor
	pop eax

	push edx
	mov edx, 0
	mov dh, 1 ; square 1 is in row 1, column 0
	mov dl, 0
	call gotoxy
	pop edx

	mov ecx, 0
	mov ecx, 2
	mov esi, 0
	push eax
	highlightSq1Yellow:
		mov al, byte ptr[edx + esi]
		call writeChar
		inc esi
		loop highlightSq1Yellow
	pop eax
	jmp continueFillSq1

	continueFillSq1:
	mov byte ptr[edx], al
	jmp finishedChoosing

sq2:	;																			SQUARE 2
cmp al, 2 
jne sq3
pop eax
cmp byte ptr [edx + 4], "-" ; check if empty first
je fillSq2
jmp filledSquare ; if not empty, display error and choose again

fillSq2: ; if empty, then highlight the square and fill it in
	cmp al, 'X'
	jne setYellow2
	push eax
	mov eax, 0 + (4 * 16) ; black on red (if X)
	call settextcolor
	pop eax

	push edx
	mov edx, 0
	mov dh, 1 ; square 2 is in row 1, column 4
	mov dl, 3
	call gotoxy
	pop edx

	mov ecx, 0
	mov ecx, 3
	mov esi, 0
	push eax
	highlightSq2Red:
		mov al, byte ptr[edx + 3 + esi]
		call writeChar
		inc esi
		loop highlightSq2Red
	pop eax
	jmp continueFillSq2

	setYellow2:
	push eax
	mov eax, 0 + (14 * 16) ; black on yellow (if O)
	call settextcolor
	pop eax

	push edx
	mov edx, 0
	mov dh, 1 ; square 2 is in row 1, column 3
	mov dl, 3
	call gotoxy
	pop edx

	mov ecx, 0
	mov ecx, 3
	mov esi, 0
	push eax
	highlightSq2Yellow:
		mov al, byte ptr[edx + 3 + esi]
		call writeChar
		inc esi
		loop highlightSq2Yellow
	pop eax
	jmp continueFillSq2

	continueFillSq2:
	mov byte ptr[edx + 4], al
	jmp finishedChoosing

sq3: ;																			    SQUARE 3
cmp al, 3 
jne sq4
pop eax
cmp byte ptr [edx + 8], "-" ; check if empty first
je fillSq3
jmp filledSquare ; if not empty, display error and choose again

fillSq3: ; if empty, then highlight the square and fill it in
	cmp al, 'X'
	jne setYellow3
	push eax
	mov eax, 0 + (4 * 16) ; black on red (if X)
	call settextcolor
	pop eax

	push edx
	mov edx, 0
	mov dh, 1 ; square 3 is in row 1, column 7
	mov dl, 7
	call gotoxy
	pop edx

	mov ecx, 0
	mov ecx, 3
	mov esi, 0
	push eax
	highlightSq3Red:
		mov al, byte ptr[edx + 7 + esi]
		call writeChar
		inc esi
		loop highlightSq3Red
	pop eax
	jmp continueFillSq3

	setYellow3:
	push eax
	mov eax, 0 + (14 * 16) ; black on yellow (if O)
	call settextcolor
	pop eax

	push edx
	mov edx, 0
	mov dh, 1 ; square 3 is in row 1, column 7
	mov dl, 7
	call gotoxy
	pop edx

	mov ecx, 0
	mov ecx, 3
	mov esi, 0
	push eax
	highlightSq3Yellow:
		mov al, byte ptr[edx + 7 + esi]
		call writeChar
		inc esi
		loop highlightSq3Yellow
	pop eax
	jmp continueFillSq3

	continueFillSq3:
	mov byte ptr[edx + 8], al
	jmp finishedChoosing

sq4: ;																						SQUARE 4
cmp al, 4 
jne sq5
pop eax
cmp byte ptr [edx + 11], "-" ; check if empty first
je fillSq4
jmp filledSquare ; if not empty, display error and choose again

fillSq4: ; if empty, then highlight the square and fill it in
	cmp al, 'X'
	jne setYellow4
	push eax
	mov eax, 0 + (4 * 16) ; black on red (if X)
	call settextcolor
	pop eax

	push edx
	mov edx, 0
	mov dh, 2 ; square 4 is in row 2, column 0
	mov dl, 0
	call gotoxy
	pop edx

	mov ecx, 0
	mov ecx, 2
	mov esi, 0
	push eax
	highlightSq4Red:
		mov al, byte ptr[edx + 11 + esi]
		call writeChar
		inc esi
		loop highlightSq4Red
	pop eax
	jmp continueFillSq4

	setYellow4:
	push eax
	mov eax, 0 + (14 * 16) ; black on yellow (if O)
	call settextcolor
	pop eax

	push edx
	mov edx, 0
	mov dh, 2 ; square 4 is in row 2, column 0
	mov dl, 0
	call gotoxy
	pop edx

	mov ecx, 0
	mov ecx, 2
	mov esi, 0
	push eax
	highlightSq4Yellow:
		mov al, byte ptr[edx + 11 + esi]
		call writeChar
		inc esi
		loop highlightSq4Yellow
	pop eax
	jmp continueFillSq4

	continueFillSq4:
	mov byte ptr[edx + 11], al
	jmp finishedChoosing

sq5: ;																							SQUARE 5
cmp al, 5 
jne sq6
pop eax
cmp byte ptr [edx + 15], "-" ; check if empty first
je fillSq5
jmp filledSquare ; if not empty, display error and choose again

fillSq5: ; if empty, then highlight the square and fill it in
	cmp al, 'X'
	jne setYellow5
	push eax
	mov eax, 0 + (4 * 16) ; black on red (if X)
	call settextcolor
	pop eax

	push edx
	mov edx, 0
	mov dh, 2 ; square 5 is in row 2, column 3
	mov dl, 3
	call gotoxy
	pop edx

	mov ecx, 0
	mov ecx, 3
	mov esi, 0
	push eax
	highlightSq5Red:
		mov al, byte ptr[edx + 14 + esi]
		call writeChar
		inc esi
		loop highlightSq5Red
	pop eax
	jmp continueFillSq5

	setYellow5:
	push eax
	mov eax, 0 + (14 * 16) ; black on yellow (if O)
	call settextcolor
	pop eax

	push edx
	mov edx, 0
	mov dh, 2 ; square 5 is in row 2, column 3
	mov dl, 3
	call gotoxy
	pop edx

	mov ecx, 0
	mov ecx, 3
	mov esi, 0
	push eax
	highlightSq5Yellow:
		mov al, byte ptr[edx + 14 + esi]
		call writeChar
		inc esi
		loop highlightSq5Yellow
	pop eax
	jmp continueFillSq5

	continueFillSq5:
	mov byte ptr[edx + 15], al
	jmp finishedChoosing

sq6: ;																							SQUARE 6
cmp al, 6 
jne sq7
pop eax
cmp byte ptr [edx + 19], "-" ; check if empty first
je fillSq6
jmp filledSquare ; if not empty, display error and choose again

fillSq6: ; if empty, then highlight the square and fill it in
	cmp al, 'X'
	jne setYellow6
	push eax
	mov eax, 0 + (4 * 16) ; black on red (if X)
	call settextcolor
	pop eax

	push edx
	mov edx, 0
	mov dh, 2 ; square 6 is in row 2, column 7
	mov dl, 7
	call gotoxy
	pop edx

	mov ecx, 0
	mov ecx, 3
	mov esi, 0
	push eax
	highlightSq6Red:
		mov al, byte ptr[edx + 18 + esi]
		call writeChar
		inc esi
		loop highlightSq6Red
	pop eax
	jmp continueFillSq6

	setYellow6:
	push eax
	mov eax, 0 + (14 * 16) ; black on yellow (if O)
	call settextcolor
	pop eax

	push edx
	mov edx, 0
	mov dh, 2 ; square 6 is in row 2, column 7
	mov dl, 7
	call gotoxy
	pop edx

	mov ecx, 0
	mov ecx, 3
	mov esi, 0
	push eax
	highlightSq6Yellow:
		mov al, byte ptr[edx + 18 + esi]
		call writeChar
		inc esi
		loop highlightSq6Yellow
	pop eax
	jmp continueFillSq6

	continueFillSq6:
	mov byte ptr[edx + 19], al
	jmp finishedChoosing

sq7: ;																						SQUARE 7
cmp al, 7 
jne sq8
pop eax
cmp byte ptr [edx + 22], "-" ; check if empty first
je fillSq7
jmp filledSquare ; if not empty, display error and choose again

fillSq7: ; if empty, then highlight the square and fill it in
	cmp al, 'X'
	jne setYellow7
	push eax
	mov eax, 0 + (4 * 16) ; black on red (if X)
	call settextcolor
	pop eax

	push edx
	mov edx, 0
	mov dh, 3 ; square 7 is in row 3, column 0
	mov dl, 0
	call gotoxy
	pop edx

	mov ecx, 0
	mov ecx, 2
	mov esi, 0
	push eax
	highlightSq7Red:
		mov al, byte ptr[edx + 22 + esi]
		call writeChar
		inc esi
		loop highlightSq7Red
	pop eax
	jmp continueFillSq7

	setYellow7:
	push eax
	mov eax, 0 + (14 * 16) ; black on yellow (if O)
	call settextcolor
	pop eax

	push edx
	mov edx, 0
	mov dh, 3 ; square 7 is in row 3, column 0
	mov dl, 0
	call gotoxy
	pop edx

	mov ecx, 0
	mov ecx, 2
	mov esi, 0
	push eax
	highlightSq7Yellow:
		mov al, byte ptr[edx + 22 + esi]
		call writeChar
		inc esi
		loop highlightSq7Yellow
	pop eax
	jmp continueFillSq7

	continueFillSq7:
	mov byte ptr[edx + 22], al
	jmp finishedChoosing

sq8: ;																							SQUARE 8
cmp al, 8 
jne sq9
pop eax
cmp byte ptr [edx + 26], "-" ; check if empty first
je fillSq8
jmp filledSquare ; if not empty, display error and choose again

fillSq8: ; if empty, then highlight the square and fill it in
	cmp al, 'X'
	jne setYellow8
	push eax
	mov eax, 0 + (4 * 16) ; black on red (if X)
	call settextcolor
	pop eax

	push edx
	mov edx, 0
	mov dh, 3 ; square 8 is in row 3, column 3
	mov dl, 3
	call gotoxy
	pop edx

	mov ecx, 0
	mov ecx, 3
	mov esi, 0
	push eax
	highlightSq8Red:
		mov al, byte ptr[edx + 25 + esi]
		call writeChar
		inc esi
		loop highlightSq8Red
	pop eax
	jmp continueFillSq8

	setYellow8:
	push eax
	mov eax, 0 + (14 * 16) ; black on yellow (if O)
	call settextcolor
	pop eax

	push edx
	mov edx, 0
	mov dh, 3 ; square 8 is in row 3, column 3
	mov dl, 3
	call gotoxy
	pop edx

	mov ecx, 0
	mov ecx, 3
	mov esi, 0
	push eax
	highlightSq8Yellow:
		mov al, byte ptr[edx + 25 + esi]
		call writeChar
		inc esi
		loop highlightSq8Yellow
	pop eax
	jmp continueFillSq8

	continueFillSq8:
	mov byte ptr[edx + 26], al
	jmp finishedChoosing

sq9: ;																						SQUARE 9
cmp al, 9 
jne invalidEntry
pop eax
cmp byte ptr [edx + 30], "-" ; check if empty first
je fillSq9
jmp filledSquare ; if not empty, display error and choose again

fillSq9: ; if empty, then highlight the square and fill it in
	cmp al, 'X'
	jne setYellow9
	push eax
	mov eax, 0 + (4 * 16) ; black on red (if X)
	call settextcolor
	pop eax

	push edx
	mov edx, 0
	mov dh, 3 ; square 9 is in row 3, column 7
	mov dl, 7
	call gotoxy
	pop edx

	mov ecx, 0
	mov ecx, 3
	mov esi, 0
	push eax
	highlightSq9Red:
		mov al, byte ptr[edx + 29 + esi]
		call writeChar
		inc esi
		loop highlightSq9Red
	pop eax
	jmp continueFillSq9

	setYellow9:
	push eax
	mov eax, 0 + (14 * 16) ; black on yellow (if O)
	call settextcolor
	pop eax

	push edx
	mov edx, 0
	mov dh, 3 ; square 9 is in row 3, column 7
	mov dl, 7
	call gotoxy
	pop edx

	mov ecx, 0
	mov ecx, 3
	mov esi, 0
	push eax
	highlightSq9Yellow:
		mov al, byte ptr[edx + 29 + esi]
		call writeChar
		inc esi
		loop highlightSq9Yellow
	pop eax
	jmp continueFillSq9

	continueFillSq9:
	mov byte ptr[edx + 30], al
	jmp finishedChoosing

invalidEntry:
	push edx
	mov edx, offset invalidEntryMsg
	call writestring
	pop edx
	jmp continueUserChoose

outOfBounds:
push edx
mov edx, offset outBoundsMsg
call writestring
pop edx
jmp continueUserChoose

filledSquare:
push edx
mov edx, offset notEmptyMsg
call writestring
pop edx
jmp continueUserChoose

finishedChoosing:
push eax
mov eax, 7 + (0*16) ; reset color to light gray on black
call settextcolor
pop eax

push edx
mov dh, 5
mov dl, 0 ; reset cursor position
call gotoxy
pop edx
call waitmsg
call clrscr



ret
userChooseSquare ENDP


compChooseSquare PROC ;-----------------------------------
;Description: if it's the computer's turn, then 
; this allows it to randomly choose an empty square 
; (and center if empty)
;Receives: offset of board in edx, character (X/O) in ebx
;Returns: updated board
;---------------------------------------------------------
mov al, byte ptr [ebx] ; move character to eax

cmp byte ptr [edx+15], "-" ; first check to see if the center is filled (offset of 15 from beginning)
jne continueChoosing
mov byte ptr [edx + 15], al ; if not, computer will make its move there.
jmp doneChoosing

continueChoosing:
	push eax
	mov eax, 10
	call randomRange ; randomly get a number between 1-9 (correspond to squares in row-major)
	inc eax

	cmp al, 1 ; compare random number in eax in order to fill corresponding square
	jne square2
	pop eax
	cmp byte ptr[edx], "-" ; first check if the square is empty, indicated by a dash
	je fillSquare1
	jmp continueChoosing ; if not, get a new random number until one works

	fillSquare1:
	mov byte ptr[edx], al ; if so, fill the square with X or O
	jmp doneChoosing

	square2:			; same process for all other squares as comparison continues
	cmp al, 2
	jne square3
	pop eax
	cmp byte ptr[edx+4], "-"
	je fillSquare2
	jmp continueChoosing

	fillSquare2:
	mov byte ptr[edx+4], al
	jmp doneChoosing

	square3:
	cmp al, 3
	jne square4
	pop eax
	cmp byte ptr[edx+8], "-"
	je fillSquare3
	jmp continueChoosing

	fillSquare3:
	mov byte ptr[edx+8], al
	jmp doneChoosing

	square4:
	cmp al, 4
	jne square5
	pop eax
	cmp byte ptr[edx+11], "-"
	je fillSquare4
	jmp continueChoosing

	fillSquare4:
	mov byte ptr[edx+11], al
	jmp doneChoosing

	square5:
	cmp al, 5
	jne square6
	pop eax
	cmp byte ptr[edx+15], "-"
	je fillSquare5
	jmp continueChoosing

	fillSquare5:
	mov byte ptr[edx+15], al
	jmp doneChoosing

	square6:
	cmp al, 6
	jne square7
	pop eax
	cmp byte ptr[edx+19], "-"
	je fillSquare6
	jmp continueChoosing

	fillSquare6:
	mov byte ptr[edx+19], al
	jmp doneChoosing

	square7:
	cmp al, 7
	jne square8
	pop eax
	cmp byte ptr[edx+22], "-"
	je fillSquare7
	jmp continueChoosing

	fillSquare7:
	mov byte ptr[edx+22], al
	jmp doneChoosing

	square8:
	cmp al, 8
	jne square9
	pop eax
	cmp byte ptr[edx+26], "-"
	je fillSquare8
	jmp continueChoosing

	fillSquare8:
	mov byte ptr[edx+26], al
	jmp doneChoosing

	square9:
	pop eax
	cmp byte ptr[edx+30], "-"
	je fillSquare9
	jmp continueChoosing

	fillSquare9:
	mov byte ptr[edx+30], al
	jmp doneChoosing


	doneChoosing:
		call waitmsg
		call clrscr


ret
compChooseSquare ENDP



checkWinner PROC ;---------------------------------------
;Description: checks to see if either player is a winner
;Receives: eax with character, edx with gameboard
;Returns: either 1 or 0 in bl as a bool value, prints
; board with winning path highlighted.
;--------------------------------------------------------
cmp byte ptr [edx], al ; first check the first row
jne checkRow2
jmp checkRowSq2

	checkRowSq2:
		cmp byte ptr [edx+4], al
		jne checkRow2
		jmp checkRowSq3

	checkRowSq3:
		cmp byte ptr [edx+8], al
		jne checkRow2
		jmp isRow1Winner ; if all 3 squares are the same character we have a winner


checkRow2: ; next check row 2
	cmp byte ptr [edx+11], al
	jne checkRow3
	jmp checkRowSq5

	checkRowSq5:
		cmp byte ptr [edx+15], al
		jne checkRow3
		jmp checkRowSq6

	checkRowSq6:
		cmp byte ptr [edx+19], al
		jne checkRow3
		jmp isRow2Winner

checkRow3: ; next check row 3
	cmp byte ptr [edx+22], al
	jne checkCol1
	jmp checkRowSq8

	checkRowSq8:
		cmp byte ptr [edx+26], al
		jne checkCol1
		jmp checkRowSq9

	checkRowSq9:
		cmp byte ptr [edx+30], al
		jne checkCol1
		jmp isRow3Winner

checkCol1: ; next start checking column wins from the first square
	cmp byte ptr [edx], al
	jne checkCol2
	jmp checkColSq2

	checkColSq2:
		cmp byte ptr [edx+11], al
		jne checkCol2
		jmp checkColSq3

	checkColSq3:
		cmp byte ptr [edx+22], al
		jne checkCol2
		jmp isCol1Winner

checkCol2: ; check the second column
	cmp byte ptr [edx+4], al
	jne checkCol3
	jmp checkColSq5

	checkColSq5:
		cmp byte ptr [edx+15], al
		jne checkCol3
		jmp checkColSq8

	checkColSq8:
		cmp byte ptr [edx+26], al
		jne checkCol3
		jmp isCol2Winner

checkCol3: ; checking the third column
	cmp byte ptr [edx+8], al
	jne checkDiag1
	jmp checkColSq6

	checkColSq6:
		cmp byte ptr [edx+19], al
		jne checkDiag1
		jmp checkColSq9

	checkColSq9:
		cmp byte ptr [edx+30], al
		jne checkDiag1
		jmp isCol3Winner

checkDiag1: ; finally check the diagonals starting from the first square
	cmp byte ptr [edx], al
	jne checkDiag2
	jmp checkDiagSq5

	checkDiagSq5:
		cmp byte ptr [edx+15], al
		jne checkDiag2
		jmp checkDiagSq9

	checkDiagSq9:
		cmp byte ptr [edx + 30], al
		jne checkDiag2
		jmp isDiag1Winner

checkDiag2: ; and check the forward diagonal starting from square 3
	cmp byte ptr [edx+8], al
	jne noWinner
	jmp checkDiag2Sq5

	checkDiag2Sq5:
		cmp byte ptr [edx+15], al
		jne noWinner
		jmp checkDiagSq7

	checkDiagSq7:
		cmp byte ptr [edx+22], al
		jne noWinner
		jmp isDiag2Winner

											; NOW PRINT THE BOARD WITH THE HIGHLIGHTED PATH BASED ON WHAT KIND OF WIN IT IS

isRow1Winner:
	call clrscr
	invoke printBoard ; clear the screen and print the board so the game is the only thing on the screen intially
	push eax
	mov eax, 1 + (15 * 16) ; set text to print blue on white
	call settextcolor
	pop eax

	push edx
	mov dh, 0 ; move cursor to begin at row 1
	mov dl, 0
	call gotoxy
	pop edx

	mov ecx, 0
	mov edi, 0 ; use edi to increment
	mov ecx, 9 ; there are 9 characters in total to highlight in any one row of the board

	highlightRow1:
		mov al, byte ptr [edx + edi]
		call writeChar
		inc edi
		loop highlightRow1
	
	mov bl, 1 ; after highlighting the row, move 1 to bl to indicate that a winner was found
	jmp doneCheckingWinner

isRow2Winner: ; repeat the same process for each row and column, making sure to modify where the cursor is printing using gotoxy
	call clrscr
	invoke printBoard
	push eax
	mov eax, 1 + (15 * 16) ; set text to print blue on white
	call settextcolor
	pop eax

	push edx
	mov dh, 1 ; move cursor to begin at row 2
	mov dl, 0
	call gotoxy
	pop edx

	mov ecx, 0
	mov edi, 0
	mov ecx, 9

	highlightRow2:
		mov al, byte ptr [edx + 11 + edi]
		call writeChar
		inc edi
		loop highlightRow2
	
	mov bl, 1 ; after highlighting the row, move 1 to bl to indicate that a winner was found
	jmp doneCheckingWinner

isRow3Winner:
	call clrscr
	invoke printBoard
	push eax
	mov eax, 1 + (15 * 16) ; set text to print blue on white
	call settextcolor
	pop eax

	push edx
	mov dh, 2 ; move cursor to begin at row 3
	mov dl, 0
	call gotoxy
	pop edx

	mov ecx, 0
	mov edi, 0
	mov ecx, 9

	highlightRow3:
		mov al, byte ptr [edx + 22 + edi]
		call writeChar
		inc edi
		loop highlightRow3
	
	mov bl, 1 ; after highlighting the row, move 1 to bl to indicate that a winner was found
	jmp doneCheckingWinner

isCol1Winner:
	call clrscr
	invoke printBoard
	push eax
	mov eax, 1 + (15 * 16) ; set text to print blue on white
	call settextcolor
	pop eax

	push edx
	mov dh, 0 ; move cursor to begin at column 1
	mov dl, 0
	call gotoxy
	pop edx

	mov ecx, 0
	mov edi, 0 ; used to locate the squares
	mov esi, 0 ; used for gotoxy
	mov ecx, 3 ; only need to highlight 3 squares

	highlightCol1:
		push edx
		mov edx, 0
		mov eax, esi
		mov dh, al
		mov dl, 0
		call gotoxy
		pop edx
		mov al, byte ptr [edx + edi]
		call writeChar
		add edi, 11 ; squares underneath each other are always 11 characters apart
		inc esi
		loop highlightCol1
	
	mov bl, 1 ; after highlighting the col, move 1 to bl to indicate that a winner was found
	jmp doneCheckingWinner

isCol2Winner:
	call clrscr
	invoke printBoard
	push eax
	mov eax, 1 + (15 * 16) ; set text to print blue on white
	call settextcolor
	pop eax

	push edx
	mov dh, 0 ; move cursor to begin at column 2
	mov dl, 4
	call gotoxy
	pop edx

	mov ecx, 0
	mov edi, 0
	mov esi, 0
	mov ecx, 3 ; only need to highlight 3 squares

	highlightCol2:
		push edx
		mov edx, 0
		mov eax, esi
		mov dh, al
		mov dl, 4
		call gotoxy
		pop edx
		mov al, byte ptr [edx + 4 + edi]
		call writeChar
		add edi, 11 ; squares underneath each other are always 11 characters apart
		inc esi
		loop highlightCol2
	
	mov bl, 1 ; after highlighting the col, move 1 to bl to indicate that a winner was found
	jmp doneCheckingWinner

isCol3Winner:
	call clrscr
	invoke printBoard
	push eax
	mov eax, 1 + (15 * 16) ; set text to print blue on white
	call settextcolor
	pop eax

	push edx
	mov dh, 0 ; move cursor to begin at column 3
	mov dl, 8
	call gotoxy
	pop edx

	mov ecx, 0
	mov edi, 0
	mov esi, 0
	mov ecx, 3 ; only need to highlight 3 squares

	highlightCol3:
		push edx
		mov edx, 0
		mov eax, esi
		mov dh, al
		mov dl, 8
		call gotoxy
		pop edx
		mov al, byte ptr [edx + 8 + edi]
		call writeChar
		add edi, 11 ; squares underneath each other are always 11 characters apart
		inc esi
		loop highlightCol3
	
	mov bl, 1 ; after highlighting the col, move 1 to bl to indicate that a winner was found
	jmp doneCheckingWinner

isDiag1Winner:
	call clrscr
	invoke printBoard
	push eax
	mov eax, 1 + (15 * 16) ; set text to print blue on white
	call settextcolor
	pop eax

	push edx
	mov dh, 0 ; move cursor to begin at backward diagonal
	mov dl, 0
	call gotoxy
	pop edx

	mov ecx, 0
	mov edi, 0 ; used to locate the squares
	mov esi, 0 ; used to direct gotoxy coordinates
	mov ecx, 3 ; only need to highlight 3 squares

	highlightDiag1:
		push edx
		mov edx, 0
		mov eax, esi
		mov dh, al
		cmp dh, 0
		je getCoord1 ; checking which row we're on and making sure that the correct coordinate for the column is placed in dl
		cmp dh, 1
		je getCoord2
		cmp dh, 2
		je getCoord3
		jmp continue

		getCoord1:
			mov dl, 0
			jmp continue
		getCoord2:
			mov dl, 4
			jmp continue
		getCoord3:
			mov dl, 8

		continue:
		call gotoxy
		pop edx
		mov al, byte ptr [edx + edi]
		call writeChar
		add edi, 15 ; squares in the backward diagonal form are always 15 characters apart
		inc esi
		loop highlightDiag1
	
	mov bl, 1 ; after highlighting the col, move 1 to bl to indicate that a winner was found
	jmp doneCheckingWinner

isDiag2Winner:
	call clrscr
	invoke printBoard
	push eax
	mov eax, 1 + (15 * 16) ; set text to print blue on white
	call settextcolor
	pop eax

	push edx
	mov dh, 0 ; move cursor to begin at forward diagonal
	mov dl, 8 
	call gotoxy
	pop edx

	mov ecx, 0
	mov edi, 0
	mov esi, 0
	mov ecx, 3 ; only need to highlight 3 squares

	highlightDiag2:
		push edx
		mov edx, 0
		mov eax, esi
		mov dh, al
		cmp dh, 0
		je getDiag2Coord1 ; checking which row we're on and making sure that the correct coordinate for the column is placed in dl
		cmp dh, 1
		je getDiag2Coord2
		cmp dh, 2
		je getDiag2Coord3
		jmp continue2

		getDiag2Coord1:
			mov dl, 8
			jmp continue2
		getDiag2Coord2:
			mov dl, 4
			jmp continue2
		getDiag2Coord3:
			mov dl, 0

		continue2:
		call gotoxy
		pop edx
		mov al, byte ptr [edx + 8 + edi]
		call writeChar
		add edi, 7 ; squares in the backward diagonal form are always 7 characters apart
		inc esi
		loop highlightDiag2
	
	mov bl, 1 ; after highlighting the col, move 1 to bl to indicate that a winner was found
	jmp doneCheckingWinner

noWinner:
mov bl, 0

doneCheckingWinner:
ret
checkWinner ENDP



checkDraw PROC ;-----------------------------------------
;Description: Checks the board to see if there's a draw,
; in that all squares are filled, but there is no winner.
;Receives: edx with gameBoard
;Returns: 0 or 1 in bl as a bool value
;--------------------------------------------------------
cmp byte ptr [edx], "-"
je notDraw
jmp drawSq2

drawSq2:
	cmp byte ptr [edx + 4], "-"
	je notDraw
	jmp drawSq3

drawSq3:
	cmp byte ptr [edx + 8], "-"
	je notDraw
	jmp drawSq4

drawSq4:
	cmp byte ptr [edx + 11], "-"
	je notDraw
	jmp drawSq5

drawSq5:
	cmp byte ptr [edx + 15], "-"
	je notDraw
	jmp drawSq6

drawSq6:
	cmp byte ptr [edx + 19], "-"
	je notDraw
	jmp drawSq7

drawSq7:
	cmp byte ptr [edx + 22], "-"
	je notDraw
	jmp drawSq8

drawSq8:
	cmp byte ptr [edx + 26], "-"
	je notDraw
	jmp drawSq9

drawSq9:
	cmp byte ptr [edx + 30], "-"
	je notDraw
	mov bl, 1 ; there is a draw if all squares are filled
	jmp doneDrawCheck


notDraw:
mov bl, 0 ; if there is no draw, return 0 in bl

doneDrawCheck:
ret
checkDraw ENDP



option2 PROC ;----------------------------------------
;Description: Allows user to watch a game between
; two computer players.
;Receives: esi for gamesPlayed, ecx for gamesWonComp,
; and edi for gameDraws
;Returns: updated stats
;-----------------------------------------------------
.data
gameBoard2 BYTE  '- | - | -', 0Ah, 0Dh,
				'- | - | -', 0Ah, 0Dh,
				'- | - | -', 0Ah, 0Dh, 0h

comp1PlayerNum BYTE ?

comp1Char BYTE ?
comp2Char BYTE ?

winMsgOpt2 BYTE "Player ", 0h
winMsg2Opt2 BYTE " wins!", 0Ah, 0Dh, 0h

drawMsgOpt2 BYTE "It's a Draw! No winners.", 0Ah, 0Dh, 0h

.code
push esi
push ecx
push edi

mov edx, offset comp1PlayerNum

invoke choosePlayer ; choose who goes first randomly
mov byte ptr [edx], al ; save comp1 player number
cmp al, 1 ; 1 = comp1 begins, 2 = comp2 begins
jne comp2Starts
mov edx, offset comp1Char
mov byte ptr [edx], 'X' ; assign comp1's character to X if player 1
mov edx, offset comp2Char
mov byte ptr [edx], 'O' ; and assign comp2's character to O
jmp comp1Starts

comp1Starts:
mov eax, 1 ; we always start with player 1
call clrscr
jmp playGameOpt2


comp2Starts:
mov edx, offset compChar
mov byte ptr [edx], 'X' ; assign computer's character to X if they're player 1
mov edx, offset userChar
mov byte ptr [edx], 'O' ; and assign user's character to O
mov eax, 1 ; we always start with player 1
call clrscr
jmp playGameOpt2


playGameOpt2:
	
	mov edx, offset gameBoard2

	invoke printBoard ; always show the board after each turn
	call waitmsg
	
	mov edx, offset comp1PlayerNum 
	cmp byte ptr[edx], al ; use the comp1's player number to see if it's their turn based on what is in eax
	jne comp2Play
	mov edx, offset gameBoard2 ; gameBoard will be in edx
	mov ebx, offset comp1Char ; comp1's character will be in ebx if it's their turn
	invoke compChooseSquare ; allow comp1 to play their turn
	invoke checkWinner ; check for a winner
	cmp bl, 1 ; if bl returns with 1, user wins
	je winnerFoundOpt2
	invoke checkDraw ; check if the board indicates a draw
	cmp bl, 1 ; if bl returns with 1, there is a draw
	je drawFoundOpt2
	invoke switchPlayer ; if no winner or draw, switch players for the next turn
	jmp playGameOpt2

	comp2Play:
		mov edx, offset gameBoard2 ; same process for computer player
		mov ebx, offset comp2Char
		invoke compChooseSquare
		invoke checkWinner
		cmp bl, 1
		je winnerFoundOpt2
		invoke checkDraw
		cmp bl, 1
		je drawFoundOpt2
		invoke switchPlayer
		jmp playGameOpt2

winnerFoundOpt2:
	push eax
	mov eax, 7 + (0*16) ; reset color to light gray on black
	call settextcolor
	pop eax

	push edx
	mov dh, 3 ; reset cursor to correct position under the board
	mov dl, 0
	call gotoxy
	pop edx

	cmp al, 'X' ; check to see which comp won
	jne ply2WinOpt2
	mov al, 1
	mov edx, offset winMsgOpt2 ; display winning messages
	call writestring
	call writeDec
	mov edx, offset winMsg2Opt2
	call writestring
	mov edx, offset comp1PlayerNum
	cmp byte ptr [edx], 1
	jne comp2Win1 ; check if the winner was comp2 first
	pop edi
	pop ecx
	inc byte ptr [ecx] ; increment amount of computer wins
	pop esi
	inc byte ptr [esi] ; increment amount of games played
	jmp donePlaying2

	comp2Win1:
		pop edi
		pop ecx
		inc byte ptr [ecx] ; increment amount of computer wins
		pop esi
		inc byte ptr [esi] ; increment amount of games played
		jmp donePlaying2
	
	ply2WinOpt2: ; same process for player 2 winning
		mov al, 2
		mov edx, offset winMsg
		call writestring
		call writeDec
		mov edx, offset winMsg2
		call writestring
		mov edx, offset comp1PlayerNum
		cmp byte ptr [edx], 2
		jne comp2Win2
		pop edi
		pop ecx
		inc byte ptr [ecx] ; increment amount of computer wins
		pop esi
		inc byte ptr [esi] ; increment amount of games played
		jmp donePlaying2
		
		comp2Win2:
		pop edi
		pop ecx
		inc byte ptr [ecx] ; increment amount of computer wins
		pop esi
		inc byte ptr [esi] ; increment amount of games played
		jmp donePlaying2
	

drawFoundOpt2:
	call clrscr
	mov edx, offset gameBoard2 ; if a draw was found, just display the board and inform of a draw, and end game
	invoke printBoard
	mov edx, offset drawMsgOpt2
	call writestring
	pop edi
	inc byte ptr [edi] ; increment the amount of draws
	pop ecx
	pop esi
	inc byte ptr [esi] ; increment amount of games played
	jmp donePlaying2

donePlaying2:
call waitmsg
mov edx, offset gameBoard2
call crlf
invoke playAgain

ret
option2 ENDP



option3 PROC ;-------------------------------
;Description: Allows player vs. player mode.
;Receives: esi for gamesPlayed, ebx for
; gamesWonPlayer1, ecx for gamesWonPlayer2,
; edi for gameDraws
;Returns: updated statistics
;--------------------------------------------
.data
gameBoard3 BYTE  '- | - | -', 0Ah, 0Dh,
				'- | - | -', 0Ah, 0Dh,
				'- | - | -', 0Ah, 0Dh, 0h

user1PlayerNum BYTE ?

user1Char BYTE ?
user2Char BYTE ?

winMsgOpt3 BYTE "Player ", 0h
winMsg2Opt3 BYTE " wins!", 0Ah, 0Dh, 0h

chooseMsgOpt3 BYTE "Player ", 0h
chooseMsg2Opt3 BYTE " choose a sqaure!", 0Ah, 0Dh, 0h

drawMsgOpt3 BYTE "It's a Draw! No winners.", 0Ah, 0Dh, 0h

.code
push esi
push ebx
push ecx
push edi

mov edx, offset user1PlayerNum

invoke choosePlayer ; choose who goes first randomly
mov byte ptr [edx], al ; save user1 player number
cmp al, 1 ; 1 = user1 begins, 2 = user2 begins
jne user2Starts
mov edx, offset user1Char
mov byte ptr [edx], 'X' ; assign user1's character to X if player 1
mov edx, offset user2Char
mov byte ptr [edx], 'O' ; and assign user2's character to O
jmp user1Starts

user1Starts:
mov eax, 1 ; we always start with player 1
call clrscr
jmp playGameOpt3


user2Starts:
mov edx, offset user2Char
mov byte ptr [edx], 'X' ; assign computer's character to X if they're player 1
mov edx, offset user1Char
mov byte ptr [edx], 'O' ; and assign user's character to O
mov eax, 1 ; we always start with player 1
call clrscr
jmp playGameOpt3


playGameOpt3:
	
	mov edx, offset chooseMsgOpt3 ; display what player goes next
	call writestring
	call writeDec
	mov edx, offset chooseMsg2Opt3
	call writestring
	mov edx, offset gameBoard3

	invoke printBoard ; always show the board after each turn
	
	mov edx, offset user1PlayerNum 
	cmp byte ptr[edx], al ; use the user1's player number to see if it's their turn based on what is in eax
	jne user2Play
	mov edx, offset gameBoard3 ; gameBoard will be in edx
	mov ebx, offset user1Char ; user1's character will be in ebx if it's their turn
	invoke userChooseSquare ; allow user1 to play their turn
	invoke checkWinner ; check for a winner
	cmp bl, 1 ; if bl returns with 1, user wins
	je winnerFoundOpt3
	invoke checkDraw ; check if the board indicates a draw
	cmp bl, 1 ; if bl returns with 1, there is a draw
	je drawFoundOpt3
	invoke switchPlayer ; if no winner or draw, switch players for the next turn
	jmp playGameOpt3

	user2Play:
		mov edx, offset gameBoard3 ; same process for other user
		mov ebx, offset user2Char
		invoke userChooseSquare
		invoke checkWinner
		cmp bl, 1
		je winnerFoundOpt3
		invoke checkDraw
		cmp bl, 1
		je drawFoundOpt3
		invoke switchPlayer
		jmp playGameOpt3

winnerFoundOpt3:
	push eax
	mov eax, 7 + (0*16) ; reset color to light gray on black
	call settextcolor
	pop eax

	push edx
	mov dh, 3 ; reset cursor to correct position under the board
	mov dl, 0
	call gotoxy
	pop edx

	cmp al, 'X' ; check to see which user won
	jne ply2WinOpt3
	mov al, 1
	mov edx, offset winMsgOpt3 ; display winning messages
	call writestring
	call writeDec
	mov edx, offset winMsg2Opt3
	call writestring
	mov edx, offset user1PlayerNum
	cmp byte ptr [edx], 1
	jne user2Win1 ; check if the winner was user2 first
	pop edi
	pop ecx
	pop ebx
	inc byte ptr [ebx] ; increment amount of player 1 wins
	pop esi
	inc byte ptr [esi] ; increment amount of games played
	jmp donePlaying3

	user2Win1:
		pop edi
		pop ecx
		inc byte ptr [ecx] ; increment amount of player 2 wins
		pop ebx
		pop esi
		inc byte ptr [esi] ; increment amount of games played
		jmp donePlaying3
	
	ply2WinOpt3: ; same process for player 2 winning
		mov al, 2
		mov edx, offset winMsgOpt3
		call writestring
		call writeDec
		mov edx, offset winMsg2Opt3
		call writestring
		mov edx, offset user1PlayerNum
		cmp byte ptr [edx], 2
		jne user2Win2
		pop edi
		pop ecx
		inc byte ptr [ecx] ; increment amount of player 2 wins
		pop ebx
		pop esi
		inc byte ptr [esi] ; increment amount of games played
		jmp donePlaying3
		
		user2Win2:
		pop edi
		pop ecx
		pop ebx
		inc byte ptr [ebx] ; increment amount of player 1 wins
		pop esi
		inc byte ptr [esi] ; increment amount of games played
		jmp donePlaying3
	

drawFoundOpt3:
	call clrscr
	mov edx, offset gameBoard3 ; if a draw was found, just display the board and inform of a draw, and end game
	invoke printBoard
	mov edx, offset drawMsgOpt3
	call writestring
	pop edi
	inc byte ptr [edi] ; increment the amount of draws
	pop ebx
	pop ecx
	pop esi
	inc byte ptr [esi] ; increment amount of games played
	jmp donePlaying3

donePlaying3:
call waitmsg
mov edx, offset gameBoard3
call crlf
invoke playAgain

ret
option3 ENDP

option4 PROC ;--------------------------------------------------
;Description: Displays the specified statistics for the user.
;Receives: gamesPlayed in ESI, gamesWonPlayer1 in EBX,
; gamesWonPlayer2 in ECX, gamesWonComp in EDX, gameDraws in EDI
;Returns: display to user
;---------------------------------------------------------------
.data
opt4msg1 BYTE "====== STATISTICS ======", 0Ah, 0Dh, 0h
gamesPlayedMessage BYTE "Games played: ", 0h
gamesWonPlayer1Message BYTE "Games won by Player 1: ", 0h
gamesWonPlayer2Message BYTE "Games won by Player 2: ", 0h
gamesWonCompMessage BYTE "Games won by Computer: ", 0h
gameDrawsMessage BYTE "Games ended in a Draw: ", 0h

.code
push edx
mov edx, offset opt4msg1
call writeString
call crlf

mov edx, offset gamesPlayedMessage
call writestring
pop edx
mov al, byte ptr [esi]
call writeDec ; display the amount of games played
mov eax, 0
call crlf

push edx
mov edx, offset gamesWonPlayer1Message
call writestring
pop edx
mov al, byte ptr [ebx]
call writeDec ; display amount of games player 1 won
mov eax, 0
call crlf

push edx
mov edx, offset gamesWonPlayer2Message
call writestring
pop edx
mov al, byte ptr [ecx]
call writeDec ; display amount of games player 2 won
mov eax, 0
call crlf

push edx
mov edx, offset gamesWonCompMessage
call writestring
pop edx
mov al, byte ptr [edx]
call writeDec ; display amount of games the computer won
mov eax, 0
call crlf

push edx
mov edx, offset gameDrawsMessage
call writestring
pop edx
mov al, byte ptr [edi]
call writeDec ; display amount of games that have ended in a draw
mov eax, 0
call crlf

call waitMsg ; user must press key to continue
ret
option4 ENDP

END main