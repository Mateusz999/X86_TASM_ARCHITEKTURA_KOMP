DATA_SEG    SEGMENT
   TEKST  DB 'Wpisz tekst:  ','$'
   LINIA  DB 10, 13, '$'

   MAX   DB 51
   DLU   DB ?
   T     DB 50 DUP(?),'$'

   TEKST2 DB 'Tekst po modyfikacji','$'
   T_M   DB 50 DUP(?),'$'

DATA_SEG    ENDS

CODE_SEG    SEGMENT
   ASSUME CS: CODE_SEG, DS:DATA_SEG

    START:
        MOV   AX, DATA_SEG
        MOV   DS, AX

; Tekst wielkimi literami
        MOV AH,9
        MOV DX, OFFSET TEKST
        INT 21H

        MOV AH, 9 
        MOV DX, OFFSET LINIA
        INT 21H

        MOV AH, 10
        MOV DX, OFFSET MAX
        INT 21H

        MOV AH, 9
        MOV DX, OFFSET LINIA
        INT 21H

        MOV BX, OFFSET T
        MOV SI, OFFSET T_M
        MOV CH, 0
        MOV CL, DLU
    PETLA:
        MOV AL, [BX]
        CMP AL, 97
        JL E2
        CMP AL, 122
        JG E1
        SUB AL, 32
    E5: MOV [SI], AL
        INC SI
    E1: 
        INC BX
        LOOP PETLA
        JMP E3
    E2:
        CMP AL, 65
        JL E6
        CMP AL, 90
        JG E1
        JMP E5
    E6: CMP AL, 30H
        JL E4
        CMP AL, 39H
        JG E1
        JMP E5
    E4: CMP AL, 20H
        JE E5
        JMP E1

; WYSWIETLANIE WYNIKU
    E3: MOV AH, 9
        MOV DX, OFFSET LINIA
        INT 21H

        MOV AH, 9
        MOV DX, OFFSET TEKST2
        INT 21H

        MOV AH, 9
        MOV DX, OFFSET LINIA
        INT 21H

        MOV AH, 9
        MOV DX, OFFSET T_M
        INT 21H

        MOV AH, 4CH
        INT 21H
CODE_SEG ENDS
    END START