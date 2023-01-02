EXTRN SUBPROG1:FAR
EXTRN Main:FAR
EXTRN MAINC:FAR

PUBLIC MSG1, MSG2, INPUT_NAME
include mymacros.inc 
.286
.MODEL MEDIUM
.STACK 64
.DATA

initalF DB 0
MSG1  DB  "Please Enter Your Name: $"
MSG2  DB  13,"Invalid! Re-Enter your Name: $"
INPUT_NAME DB  30
INPUT_SIZE DB ?
CURR_NAME DB 30 DUP('$')
INCOME_SIZE DB 0
INCOME_NAME DB  30 DUP('$')

F1outputmsg  DB  "To start  chating  press F1 $"
F2outputmsg  DB  "To start the game  press F2 $"
escoutputmsg DB  "To end the program press Esc $"
sendchat     DB  "You send a Chat invitation to $"
sendgame     DB  "You send a Game invitation to $"
test3        DB  "Exit $" 
recievedinv1 DB "You Send and invitation to$"
OTHER_NAME DB "Omar$"
waitUntill DB ",The Other User is disconnedted, Please Connect$"
disp db 150 dup('$')
disp1 db 150 dup('$')
disp2 db 150 dup('$')
disp3 db 150 dup('$')
prevR db 7
prevS db 0
.CODE
SUBPROG2 PROC FAR
mov ax,@DATA
mov ds,ax

CALL SUBPROG1

GotoTextmode
clearscreen
;/**********initalize the connection**********/
    mov dx,3fbh 			; Line Control Register
    mov al,10000000b		;Set Divisor Latch Access Bit
    out dx,al				;Out it
    ;/********************/
    mov dx,3f8h			
    mov al,0ch			
    out dx,al
    ;/********************/
    mov dx,3f9h
    mov al,00h
    out dx,al
    ;/********************/
    mov dx,3fbh
    mov al,00011011b
    ;0:Access to Receiver buffer, Transmitter buffer
    ;0:Set Break disabled
    ;011:Even Parity
    ;0:One Stop Bit
    ;11:8bits
    out dx,al

    
    ;/*********initalize the connection***********/

clearscreen
mov ch, 1
mov ah, 1
int 10h ;remove the display of cursor
concatStr CURR_NAME,waitUntill,disp
loopconnectOther:
movecursorlocation 19h,7h,0h    ;moves cursor to the middle of the page 

DisplayString F1outputmsg       ;prints the f1 message

movecursorlocation 19h,0Ah,0h    ;moves cursor to the middle of the page bellow the f1 message

DisplayString F2outputmsg       ;prints the f2 message

movecursorlocation 19h,0Dh,0h    ;moves cursor to the middle of the page bellow the f2 message

DisplayString escoutputmsg       ;prints the esc message

drawhorizontallineinetextmode 22d  ;prints a line at row 22
;/**************send handshaking*********/
; cmp initalF,0
; JNE cont
; AGAIN2:  	
;         mov dx , 3FDH
;         In al , dx 			;Read Line Status
;   		AND al , 00100000b
; JZ AGAIN2
          
; mov dx , 3F8H		; Transmit data register
; mov  AX,0
; out dx , AX 
;/**************************************/
cont:
movecursorlocation 0,23d,0
DisplayString INCOME_NAME
;mov dx , 3FDH		; Line Status Register
;in al , dx 
;AND al , 1
;JNZ chckfirst
DisplayString disp
;jmp loopconnectOther
;---------check if first time to connect
chckfirst:
cmp initalF,0
je firstTime
jmp looptillesc
firstTime:
mov initalF,1
mov AH,06h
mov al,2
mov ch,23
mov dh,24
mov cl,0
mov dl,79
INT 10h 

;size of current name
AGAIN3: 
    mov dx , 3FDH
        In al , dx 			;Read Line Status
  		AND al , 00100000b
JZ AGAIN3
mov dx , 3F8H		; Transmit data register
mov  al,INPUT_SIZE
out dx , al 

AGAIN34: 
    mov dx , 3FDH
        In al , dx 			;Read Line Status
  		AND al , 00100000b
JZ AGAIN34

;size of other name
recieveSz:

  mov dx , 3FDH		; Line Status Register
	CHK4:	in al , dx 
  		AND al , 1
  	JNZ recieved
    jmp firstTime
    recieved:
 mov dx , 03F8H
 in al , dx 
 
   mov dx , 3FDH
 

; cmp al,0
; JE recieveSz
 mov INCOME_SIZE, al

mov si,0
mov bx,0

mov dx , 3FDH		; Line Status Register
in al , dx 
AND al , 1
JZ Again
jmp recieveName
AGAIN: 

        mov ax,0
        mov al,INPUT_SIZE
        
        cmp si,ax
        JNE AGAIN23
        jmp recieveName
     
        AGAIN23:  	
        mov dx , 3FDH
        In al , dx 			;Read Line Status
  		AND al , 00100000b
        JZ AGAIN23

  		;JZ recieveName

  		mov dx , 3F8H		; Transmit data register
  		mov  al,CURR_NAME[si]
  		out dx , al 
        inc si
    jmp again

recieveName:

    mov ax,0
    mov al,INCOME_SIZE
    cmp bx,ax
    JNE contRec
    jmp chkexit
	contRec:
    mov dx , 3FDH		; Line Status Register
	CHK1:	in al , dx 
  		AND al , 1
  	JZ CHK1
    mov dx , 03F8H
    in al , dx 
    mov INCOME_NAME[bx],al
    inc bx
    jmp recieveName
    
chkexit: 
mov ax,0
mov al,INPUT_SIZE
cmp si,ax
je  looptillesc
jmp again


;---------
looptillesc:;to keep lopping until the user press esc
movecursorlocation 0,0d,0
DisplayString INCOME_NAME
movecursorlocation 1,1d,0
DisplayString CURR_NAME
;mov dx , 03F8H
;in al , dx 
;cmp al,2

mov ch, 1
mov ah, 1
int 10h ;remove the display of cursor


movecursorlocation 19h,7h,0h    ;moves cursor to the middle of the page 

DisplayString F1outputmsg       ;prints the f1 message

movecursorlocation 19h,0Ah,0h    ;moves cursor to the middle of the page bellow the f1 message

DisplayString F2outputmsg       ;prints the f2 message

movecursorlocation 19h,0Dh,0h    ;moves cursor to the middle of the page bellow the f2 message

DisplayString escoutputmsg       ;prints the esc message

drawhorizontallineinetextmode 22d  ;prints a line at row 22


MOV AH,0h
INT 16H
CMP AH,3BH                     ; Check if user pressed F1 to go to chatting mode
jnz GAME
DisplayString sendchat         ;CALL Chatscreen
DisplayString INPUT_NAME+2
CALL mainc
clearscreen
jmp loopconnectOther

GAME: 
CMP AH,3CH
jnz EXIT
DisplayString sendgame         ;CALL Game
DisplayString INPUT_NAME+2
Call MAIN
GotoTextmode
clearscreen
jmp loopconnectOther

EXIT:
CMP Ah,1
Jnz goout
DisplayString test3       ;returntoconsole  ;Close Program
clearscreen
returntoconsole

goout:
;returntoconsole
mov ax,1
add ax,1
jz eeee
jmp far ptr loopconnectOther
eeee:
SUBPROG2 ENDP    
END SUBPROG2