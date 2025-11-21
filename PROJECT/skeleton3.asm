INCLUDE Irvine32.inc

.DATA
menuMsg BYTE "---- TYPING SPEED TESTER ----",13,10,
         "1. Start Typing Test",13,10,
         "2. See Previous Results",13,10,
         "3. Exit",13,10,0
enterChoice BYTE "Enter choice: ",0
invalidChoice BYTE "Invalid choice!",13,10,0

resultsStack DWORD 10 DUP(0)
stackTop DWORD 0

testSentence BYTE "The quick brown fox jumps over the lazy dog",0
yourInputMsg BYTE "Type the sentence and press ENTER:",13,10,0
inputBuffer BYTE 300 DUP(0)
userInputNormalized BYTE 300 DUP(0)
sentenceNormalized BYTE 300 DUP(0)

resultMsg BYTE "Results:",13,10,0
resElapsed BYTE "Elapsed (ms): ",0
resCorrect BYTE "Correct chars: ",0
resMistake BYTE "Mistakes: ",0
resAcc BYTE "Accuracy (%): ",0
resWPM BYTE "WPM: ",0

prevResultsMsg BYTE "Previous Results:",13,10,0
noResults BYTE "No previous results yet.",13,10,0

; Temporaries
sentenceLen DWORD 0
inputLen DWORD 0
correctCnt DWORD 0
mistakesCnt DWORD 0
elapsedMs DWORD 0
computedWPM DWORD 0
accuracyPct DWORD 0
startTick DWORD 0
endTick DWORD 0

.CODE

; Procedure prototypes
TrimString PROTO
ToUpperStringInPlace PROTO
CopyString PROTO
StringLength PROTO
CompareStrings PROTO

main PROC
menu_loop:
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
    call Crlf
    jmp menu_loop

; ------------------------------
StartTest:
    mov edx, OFFSET yourInputMsg
    call WriteString
    call Crlf
    mov edx, OFFSET testSentence
    call WriteString
    call Crlf

    call GetTickCount
    mov startTick, eax

    ; Read user input
    mov edx, OFFSET inputBuffer
    mov ecx, SIZEOF inputBuffer - 1
    call ReadString

    ; Trim input into userInputNormalized
    lea esi, inputBuffer
    lea edi, userInputNormalized
    call TrimString

    ; Compute length of trimmed input
    lea esi, userInputNormalized
    call StringLength
    mov inputLen, eax

    ; Uppercase user input
    lea esi, userInputNormalized
    call ToUpperStringInPlace

    ; Copy test sentence into sentenceNormalized
    lea esi, testSentence
    lea edi, sentenceNormalized
    call CopyString

    ; Uppercase sentence
    lea esi, sentenceNormalized
    call ToUpperStringInPlace

    ; Compute sentence length
    lea esi, sentenceNormalized
    call StringLength
    mov sentenceLen, eax

    ; Compare normalized buffers
    lea esi, userInputNormalized
    lea edi, sentenceNormalized
    call CompareStrings

    call GetTickCount
    mov endTick, eax
    mov eax, endTick
    sub eax, startTick
    mov elapsedMs, eax

    ; Compute accuracy %
    mov eax, correctCnt
    imul eax, 100
    mov ebx, sentenceLen
    cmp ebx, 0
    je acc_zero
    cdq
    idiv ebx
    mov accuracyPct, eax
    jmp acc_after
acc_zero:
    mov accuracyPct, 0
acc_after:

    ; Compute WPM = (correct * 12000) / elapsedMs
    mov eax, correctCnt
    imul eax, 12000
    mov ebx, elapsedMs
    cmp ebx, 0
    je wpm_zero
    cdq
    idiv ebx
    mov computedWPM, eax
    jmp wpm_after
wpm_zero:
    mov computedWPM, 0
wpm_after:

    ; Store WPM to stack
    mov eax, stackTop
    cmp eax, 10
    jae skip_store
    mov ebx, computedWPM
    mov resultsStack[eax*4], ebx
    inc stackTop
skip_store:

    ; Display results
    mov edx, OFFSET resultMsg
    call WriteString
    call Crlf

    mov edx, OFFSET resElapsed
    call WriteString
    mov eax, elapsedMs
    call WriteDec
    call Crlf

    mov edx, OFFSET resCorrect
    call WriteString
    mov eax, correctCnt
    call WriteDec
    call Crlf

    mov edx, OFFSET resMistake
    call WriteString
    mov eax, mistakesCnt
    call WriteDec
    call Crlf

    mov edx, OFFSET resAcc
    call WriteString
    mov eax, accuracyPct
    call WriteDec
    call Crlf

    mov edx, OFFSET resWPM
    call WriteString
    mov eax, computedWPM
    call WriteDec
    call Crlf
    call Crlf

    ; Reset counters
    mov correctCnt, 0
    mov mistakesCnt, 0
    mov sentenceLen, 0
    mov inputLen, 0
    mov elapsedMs, 0

    jmp menu_loop

; ------------------------------
ShowResults:
    mov eax, stackTop
    cmp eax, 0
    je NoStoredResults
    mov edx, OFFSET prevResultsMsg
    call WriteString
    call Crlf
    xor esi, esi
show_loop:
    cmp esi, stackTop
    jge done_show
    mov eax, resultsStack[esi*4]
    call WriteDec
    call Crlf
    inc esi
    jmp show_loop
done_show:
    call Crlf
    jmp menu_loop

NoStoredResults:
    mov edx, OFFSET noResults
    call WriteString
    call Crlf
    jmp menu_loop

ExitProgram:
    exit
main ENDP

; ------------------------------
; Trim leading/trailing spaces, output to EDI
TrimString PROC
    cld
skipLeading:
    mov al, [esi]
    cmp al, 0
    je doneTrim
    cmp al, ' '
    jne copyRest
    inc esi
    jmp skipLeading
copyRest:
copyLoop:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    cmp al, 0
    jne copyLoop
    dec edi
trimTrailing:
    lea ebx, userInputNormalized
    cmp edi, ebx
    jb doneTrim
    mov al, [edi]
    cmp al, ' '
    jne doneTrim
    mov [edi], 0
    dec edi
    jmp trimTrailing
doneTrim:
    ret
TrimString ENDP

; ------------------------------
; Convert string to uppercase in-place
ToUpperStringInPlace PROC
nextChar:
    mov al, [esi]
    cmp al, 0
    je done
    cmp al, 'a'
    jb skip
    cmp al, 'z'
    ja skip
    sub al, 32
skip:
    mov [esi], al
    inc esi
    jmp nextChar
done:
    ret
ToUpperStringInPlace ENDP

; ------------------------------
; Copy null-terminated string
CopyString PROC
copy_loop:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    cmp al, 0
    jne copy_loop
    ret
CopyString ENDP

; ------------------------------
; Compute string length
StringLength PROC
    mov ecx, 0FFFFFFFFh
    mov al, 0
    cld
    repne scasb
    not ecx
    dec ecx
    mov eax, ecx
    ret
StringLength ENDP

; ------------------------------
; Compare strings, count correct and mistakes
CompareStrings PROC
    xor ecx, ecx
    mov eax, sentenceLen
    cmp eax, inputLen
    jb use_input
    mov ecx, inputLen
    jmp start_cmp
use_input:
    mov ecx, sentenceLen
start_cmp:
    xor edx, edx
    mov esi, OFFSET userInputNormalized
    mov edi, OFFSET sentenceNormalized
cmp_loop:
    cmp ecx, 0
    je done
    mov al, [esi]
    mov bl, [edi]
    cmp al, bl
    jne incMistake
    inc correctCnt
incBoth:
    inc esi
    inc edi
    dec ecx
    jmp cmp_loop
incMistake:
    inc mistakesCnt
    jmp incBoth
done:
    ret
CompareStrings ENDP

END main
