; PODPROGRAMY
; WYZNACZENIE WARTOSCI WYRAZENIA
DATA_SEG    SEGMENT
TEKST1  DB 'Podaj liczbe A: ', '$'
TEKST2  DB 'Podaj liczbe B: ', '$'
TEKST3  DB 'Podaj liczbe C: ', '$'
TEKST4  DB 'Wynik: ', '$'
LINIA   DB 10, 13, '$'
MAX     DB 6
DLU     DB ?
L       DB 5 DUP(?)
A       DB 5 DUP(?)
B       DB 5 DUP(?)
C       DB 5 DUP(?)
A_BIN   DW 0
B_BIN   DW 0
C_BIN   DW 0
WYNIK_BIN   DW 0
ZNAK_MINUS  DB 0
WYNIK   DB 6 DUP(' '), '$'
DATA_SEG    ENDS

S SEGMENT STACK
    DB 100H DUP(?)
S ENDS

CODE_SEG SEGMENT
    ASSUME CS: CODE_SEG, DS: DATA_SEG, SS: S
    
START:
    MOV AX, DATA_SEG
    MOV DS, AX
    MOV AX, S
    MOV SS, AX
    
    ; Wczytaj A
    MOV DX, OFFSET TEKST1
    CALL WRITE
    MOV DI, OFFSET A
    CALL READ
    MOV DX, OFFSET LINIA
    CALL WRITE
    
    ; Wczytaj B
    MOV DX, OFFSET TEKST2
    CALL WRITE
    MOV DI, OFFSET B
    CALL READ
    MOV DX, OFFSET LINIA
    CALL WRITE
    
    ; Wczytaj C
    MOV DX, OFFSET TEKST3
    CALL WRITE
    MOV DI, OFFSET C
    CALL READ
    MOV DX, OFFSET LINIA
    CALL WRITE
    
    ; Konwertuj liczby na binarne
    MOV DX, OFFSET A
    MOV DI, OFFSET A_BIN
    CALL KONW
    
    MOV DX, OFFSET B
    MOV DI, OFFSET B_BIN
    CALL KONW
    
    MOV DX, OFFSET C
    MOV DI, OFFSET C_BIN
    CALL KONW

    ; Sprawd? czy C nie jest zerem
    MOV BX, C_BIN
    CMP BX, 0
    JE DIVISION_BY_ZERO

    ; Obliczamy (A-B)
    MOV AX, A_BIN
    SUB AX, B_BIN
    JO OVERFLOW
    PUSH AX        ; Zachowaj (A-B)

    ; Obliczamy (A+B)
    MOV AX, A_BIN
    ADD AX, B_BIN
    JO OVERFLOW

    ; Dzielimy (A+B) przez C
    CWD            ; Rozszerz znak AX do DX:AX
    IDIV C_BIN
    ; AX zawiera wynik dzielenia



    ; Zapisz wynik
    MOV WYNIK_BIN, AX
    
    ; Wy?wietl wynik
    MOV DX, OFFSET TEKST4
    CALL WRITE
    CALL KONW_2
    MOV DX, OFFSET WYNIK
    CALL WRITE
    JMP KONIEC
    
OVERFLOW:
    MOV DX, OFFSET OVERFLOW_MSG
    CALL WRITE
    JMP KONIEC
    
DIVISION_BY_ZERO:
    MOV DX, OFFSET DIV_ZERO_MSG
    CALL WRITE
    
KONIEC:
    MOV AH, 4CH
    INT 21H

; Procedury pomocnicze
WRITE PROC
    MOV AH, 9
    INT 21H
    RET
WRITE ENDP

READ PROC
    PUSH CX
    PUSH SI
    
    MOV DX, OFFSET MAX
    MOV AH, 10
    INT 21H
    
    MOV SI, OFFSET L
    MOV CX, 5
COPY_LOOP:
    MOV AL, [SI]
    MOV [DI], AL
    INC SI
    INC DI
    LOOP COPY_LOOP
    
    POP SI
    POP CX
    RET
READ ENDP

KONW PROC
    PUSH CX
    PUSH BX
    
    MOV SI, DX
    MOV CX, 5
    XOR BX, BX     ; Flaga dla liczby ujemnej
    
    ; Sprawd? znak minus
    MOV AL, [SI]
    CMP AL, '-'
    JNE CONV_POSITIVE
    INC SI
    MOV BX, 1
    DEC CX
    
CONV_POSITIVE:
    ; Konwersja cyfr na warto?ci binarne
    MOV AX, 0      ; Wyczy?? akumulator
CONV_LOOP:
    MOV DL, [SI]
    CMP DL, 0DH    ; Sprawd? czy to koniec linii
    JE CONV_END
    SUB DL, '0'    ; Konwertuj ASCII na cyfr?
    PUSH DX
    MOV DX, 10
    MUL DX         ; AX *= 10
    POP DX
    ADD AX, DX     ; AX += cyfra
    INC SI
    LOOP CONV_LOOP
    
CONV_END:
    ; Zastosuj znak minus je?li potrzebny
    CMP BX, 1
    JNE STORE_NUM
    NEG AX
    
STORE_NUM:
    MOV [DI], AX
    
    POP BX
    POP CX
    RET
KONW ENDP

KONW_2 PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    MOV AX, WYNIK_BIN
    MOV SI, OFFSET WYNIK
    
    ; Sprawd? znak
    CMP AX, 0
    JGE CONV2_POSITIVE
    
    ; Liczba ujemna
    MOV BYTE PTR [SI], '-'
    INC SI
    NEG AX
    
CONV2_POSITIVE:
    ; Konwersja na ASCII
    MOV CX, 5      ; Licznik cyfr
    ADD SI, 4      ; Wska?nik na ostatni? pozycj?
    MOV BX, 10     ; Dzielnik
    
CONV2_LOOP:
    XOR DX, DX
    DIV BX         ; AX/10, reszta w DX
    ADD DL, '0'    ; Konwertuj na ASCII
    MOV [SI], DL   ; Zapisz cyfr?
    DEC SI         ; Przesu? wska?nik
    LOOP CONV2_LOOP
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
KONW_2 ENDP

OVERFLOW_MSG DB 'Blad: Przepelnienie!', 13, 10, '$'
DIV_ZERO_MSG DB 'Blad: Dzielenie przez zero!', 13, 10, '$'

CODE_SEG ENDS
END START