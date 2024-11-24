; MNO?ENIE LICZB 2-CYFROWYCH

DATA_SEG    SEGMENT
   TEKST  DB 'PODAJ LICZBE:  ','$'
   LINIA  DB 10, 13, '$'
   
   MAX1   DB 3
   DLU1   DB ?
   L1     DB 2 DUP(?)
   L1BIN  DB ?
   
   MAX2   DB 3
   DLU2   DB ?
   L2     DB 2 DUP(?)
   L2BIN  DB ?
   
   WYNIK_BIN DB ?
   
   MNO?ENIE   DB 'MNO?ENIE : ','$'
   
   WYNIK  DB  '000','$'
DATA_SEG    ENDS

CODE_SEG    SEGMENT
   ASSUME CS: CODE_SEG, DS:DATA_SEG

    START:
        MOV   AX, DATA_SEG
        MOV   DS, AX
        
        MOV DX, OFFSET TEKST
        MOV AH, 9
        INT 21H
        
        MOV AH, 10              ;READ(L1)
        MOV DX, OFFSET MAX1
        INT 21H

        MOV DX, OFFSET LINIA
        MOV AH, 9
        INT 21H

        MOV DX, OFFSET TEKST    
        MOV AH, 9
        INT 21H
        
        MOV AH, 10              ;READ(L2)
        MOV DX, OFFSET MAX2
        INT 21H
        
        MOV DX, OFFSET LINIA
        MOV AH, 9
        INT 21H        

; ZAMIANA ZNAK?W NA CYFRY DZIESI?TNE (ODJ?CIE OD KOD?W ZNAK?W LICZBY 30H)       
        MOV AL, L1
        SUB AL, 30H
        MOV L1, AL
        
        MOV AL, L1+1
        SUB AL, 30H
        MOV L1+1, AL
        
        MOV AL, L2
        SUB AL, 30H
        MOV L2, AL
        
        MOV AL, L2+1
        SUB AL, 30H
        MOV L2+1, AL

; WYZNACZENIE BINARNYCH ARGUMENT?W (C1*10+C0)        
        MOV BL, 10
        MOV AL, L1
        MUL BL
        ADD AL, BYTE PTR L1+1
        MOV L1BIN, AL
        
        MOV BL, 10
        MOV AL, L2
        MUL BL
        ADD AL, BYTE PTR L2+1
        MOV L2BIN, AL

; WYKONANIE MNO?ENIA BINARNEGO        
        MOV AL, L1BIN
        MOV BL, L2BIN
        MUL BL
        MOV WYNIK_BIN, AL

; ZAMIANA WYNIKU BINARNEGO NA CYFRY DZIESI?TNE ORAZ WYZNACZENIE KOD?W ASCII: 
; WYNIK_BIN DIV 100 - CYFRA SETEK, (WYNIK_BIN MOD 100) DIV 10 - CYFRA DZIESI?TEK
; (WYNIK_BIN MOD 100) MOD 10 - CYFRA JEDNOSTEK
        MOV AL, WYNIK_BIN
        MOV AH,0
        MOV BL, 100
        DIV BL
        ADD AL, 30H
        MOV WYNIK, AL
        
        MOV AL, AH
        MOV AH, 0
        MOV BL, 10
        DIV BL
        ADD AL, 30H
        MOV WYNIK+1, AL
        
        ADD AH, 30H
        MOV WYNIK+2, AH
        
; WY?WIETLENIE WYNIKU       
        MOV AH, 9
        MOV DX, OFFSET MNO?ENIE
        INT 21H
        
        MOV AH, 9
        MOV DX, OFFSET WYNIK
        INT 21H

        MOV AH, 4CH
        MOV AL, 0
        INT 21H
CODE_SEG    ENDS
   END  START
