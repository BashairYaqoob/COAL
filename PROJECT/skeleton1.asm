; Typing Speed Tester (Simple Version)
; Using MASM + Irvine32 Library
; -------------------------------------------------------
; This program:
; 1. Shows a sentence
; 2. Starts a timer
; 3. Takes user input
; 4. Ends timer
; 5. Calculates elapsed time, accuracy, and WPM
; -------------------------------------------------------

INCLUDE Irvine32.inc

.data
sentence   BYTE "The quick brown fox jumps over the lazy dog and then runs across the field to chase another rabbit",0
prompt     BYTE "Type the above sentence and press ENTER:",0
buffer     BYTE 100 DUP(0)
newline    BYTE 13,10,0

; Labels for output
msgTime    BYTE "Time (ms): ",0
msgCorrect BYTE "Correct characters: ",0
msgAcc     BYTE "Accuracy (%): ",0
msgSpeed   BYTE "Typing speed (WPM): ",0

startTime  DWORD ?
endTime    DWORD ?
elapsed    DWORD ?
correct    DWORD ?
acc        DWORD ?
wpm        DWORD ?

.code
main PROC
    call Clrscr
    ; Display sentence
    mov edx, OFFSET sentence
    call WriteString
    call Crlf
    call Crlf
    mov edx, OFFSET prompt
    call WriteString
    call Crlf

    ; Start timer
    call GetTickCount
    mov startTime, eax

    ; Read input
    mov edx, OFFSET buffer
    mov ecx, LENGTHOF buffer
    call ReadString

    ; End timer
    call GetTickCount
    mov endTime, eax

    ; Calculate elapsed time
    mov eax, endTime
    sub eax, startTime
    mov elapsed, eax

    ; Compare sentence and input
    mov esi, OFFSET sentence
    mov edi, OFFSET buffer
    xor ecx, ecx
    xor ebx, ebx        ; correct count = EBX

compareLoop:
    mov al, [esi]
    mov dl, [edi]
    cmp al, 0
    je doneCompare
    cmp dl, 0
    je doneCompare
    cmp al, dl
    jne skipInc
    inc ebx
skipInc:
    inc esi
    inc edi
    jmp compareLoop

doneCompare:
    mov correct, ebx

    ; Calculate accuracy = (correct * 100) / length(sentence)
    mov ecx, LENGTHOF sentence
    mov eax, correct
    imul eax, 100
    cdq
    idiv ecx
    mov acc, eax

    ; Calculate WPM = (correct * 12000) / elapsed
    mov eax, correct
    imul eax, 12000
    mov ebx, elapsed
    cmp ebx, 0
    je zeroTime
    cdq
    idiv ebx
    mov wpm, eax
    jmp afterCalc

zeroTime:
    mov wpm, 0

afterCalc:
    call Crlf

    ; Display results
    mov edx, OFFSET msgTime
    call WriteString
    mov eax, elapsed
    call WriteDec
    call Crlf

    mov edx, OFFSET msgCorrect
    call WriteString
    mov eax, correct
    call WriteDec
    call Crlf

    mov edx, OFFSET msgAcc
    call WriteString
    mov eax, acc
    call WriteDec
    call Crlf

    mov edx, OFFSET msgSpeed
    call WriteString
    mov eax, wpm
    call WriteDec
    call Crlf

    exit
main ENDP
END main
