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

testSentence BYTE "THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG",0
yourInputMsg BYTE "Type the sentence and press ENTER:",13,10,0
inputBuffer BYTE 300 DUP(0)

resultMsg BYTE "Results:",13,10,0
resElapsed BYTE "Elapsed (ms): ",0
resCorrect BYTE "Correct chars: ",0
resMistake BYTE "Mistakes: ",0
resAcc BYTE "Accuracy (%): ",0
resWPM BYTE "WPM: ",0

prevResultsMsg BYTE "Previous Results:",13,10,0
noResults BYTE "No previous results yet.",13,10,0

correctCnt DWORD 0
mistakesCnt DWORD 0
elapsedMs DWORD 0
accuracyPct DWORD 0
computedWPM DWORD 0
startTick DWORD 0
endTick DWORD 0

.CODE

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

StartTest:
    ; Show prompt
    mov edx, OFFSET yourInputMsg
    call WriteString
    call Crlf
    mov edx, OFFSET testSentence
    call WriteString
    call Crlf

    ; Start timer
    call GetTickCount
    mov startTick, eax

    ; Clear input buffer
    lea edi, inputBuffer
    mov ecx, SIZEOF inputBuffer
    xor eax, eax
    rep stosb

    ; Read user input
    mov edx, OFFSET inputBuffer
    mov ecx, SIZEOF inputBuffer-1
    call ReadString

    ; Null-terminate input
    movzx eax, al
    mov byte ptr [inputBuffer + eax], 0

 
    ;CONVERT INPUT TO UPPERCASE
    lea esi, inputBuffer
up_input:
    mov al, [esi]
    cmp al, 0
    je done_up_input
    cmp al, 'a'
    jb skip1
    cmp al, 'z'
    ja skip1
    sub al, 32
skip1:
    mov [esi], al
    inc esi
    jmp up_input
done_up_input:

    ; Convert sentence to uppercase
    lea esi, testSentence
up_sentence:
    mov al, [esi]
    cmp al, 0
    je done_up_sentence
    cmp al, 'a'
    jb skip2
    cmp al, 'z'
    ja skip2
    sub al, 32
skip2:
    mov [esi], al
    inc esi
    jmp up_sentence
done_up_sentence:

    ; COMPARE STRINGS FOR MISTAKES
    xor eax, eax
    xor ebx, ebx
    lea esi, inputBuffer
    lea edi, testSentence
compare_loop:
    mov al, [esi]
    mov bl, [edi]
    cmp al, 0
    je compare_done
    cmp bl, 0
    je compare_done
    cmp al, bl
    jne mistake
    inc correctCnt
    jmp next_char
mistake:
    inc mistakesCnt
next_char:
    inc esi
    inc edi
    jmp compare_loop
compare_done:

    ; Stop timer
    call GetTickCount
    mov endTick, eax
    mov eax, endTick
    sub eax, startTick
    mov elapsedMs, eax

    ; COMPUTE ACCURACY %
    mov eax, correctCnt
    imul eax, 100
    mov ebx, LENGTHOF testSentence - 1
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

    ; STORE WPM IN CIRCULAR STACK
    lea edi, resultsStack
    mov eax, stackTop
    cmp eax, 10
    jl store_normal
    ; Shift left if full
    mov ecx, 1
shift_loop:
    mov edx, [edi + ecx*4]
    mov ebx, ecx
    dec ebx
    shl ebx, 2
    mov [edi + ebx], edx
    inc ecx
    cmp ecx, 10
    jl shift_loop
    ; Store new value at last
    mov eax, computedWPM
    mov ecx, 9
    shl ecx, 2
    mov [edi + ecx], eax
    jmp after_store
store_normal:
    mov eax, computedWPM
    mov ebx, stackTop
    shl ebx, 2
    mov [edi + ebx], eax
    inc stackTop
after_store:

    ; DISPLAY RESULTS
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
    mov elapsedMs, 0
    mov accuracyPct, 0
    mov computedWPM, 0

    jmp menu_loop

;menu option 2
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
;menu option 3
ExitProgram:
    exit
main ENDP

END main
