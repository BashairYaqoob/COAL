;working on menu framework
INCLUDE Irvine32.inc

.data
menuMsg BYTE "---- TYPING SPEED TESTER ----",13,10,
         "1. Start Typing Test",13,10,
         "2. See Previous Results",13,10,
         "3. Exit",13,10,0

enterChoice BYTE "Enter choice: ",0
invalidChoice BYTE "Invalid choice!",13,10,0

; Stack to store previous results
resultsStack DWORD 10 DUP(0)     ; store last 10 WPM values
stackTop DWORD 0                 ; stack pointer

; Messages
testSentence BYTE "The quick brown fox jumps over the lazy dog",0
yourInputMsg BYTE "Type the sentence:",13,10,0
inputBuffer BYTE 200 DUP(0)
resultMsg BYTE "Your WPM: ",0
prevResultsMsg BYTE "Previous Results:",13,10,0
noResults BYTE "No previous results yet.",13,10,0

newline BYTE 13,10,0

.code
main PROC
menuLoop:
    mov edx, OFFSET menuMsg
    call WriteString

    mov edx, OFFSET enterChoice
    call WriteString

    call ReadInt

    cmp eax, 1
    je StartTest

    cmp eax, 2
    je ShowResults

    cmp eax, 3
    je ExitProgram

    mov edx, OFFSET invalidChoice
    call WriteString
    jmp menuLoop

; ------------------------------
StartTest:
    ; Will add full typing logic later
    mov edx, OFFSET yourInputMsg
    call WriteString

    mov edx, OFFSET testSentence
    call WriteString
    call Crlf

    mov edx, OFFSET inputBuffer
    mov ecx, 200
    call ReadString

    ; fake WPM as 50 for now
    mov eax, 50

    ; push result to stack
    mov ebx, stackTop
    cmp ebx, 10
    je skipStore
    mov resultsStack[ebx*4], eax
    inc ebx
    mov stackTop, ebx
skipStore:

    mov edx, OFFSET resultMsg
    call WriteString
    call WriteDec
    call Crlf
    jmp menuLoop

; ------------------------------
ShowResults:
    mov ebx, stackTop
    cmp ebx, 0
    je NoStoredResults

    mov edx, OFFSET prevResultsMsg
    call WriteString

    mov esi, 0
showLoop:
    mov eax, resultsStack[esi*4]
    call WriteDec
    call Crlf

    inc esi
    cmp esi, ebx
    jl showLoop

    jmp menuLoop

NoStoredResults:
    mov edx, OFFSET noResults
    call WriteString
    jmp menuLoop

; ------------------------------
ExitProgram:
    exit
main ENDP
END main
