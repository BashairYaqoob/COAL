INCLUDE Irvine32.inc

.data

.code
main PROC

mov eax, 5
call WriteInt ;5
neg eax
call WriteInt ;-5
call DumpRegs



call DumpRegs
exit 
main ENDP
END main  
---------------------------
INCLUDE Irvine32.inc

.data

.code
main PROC

count=5
mov eax, count
call DumpRegs
call Crlf
count equ 10
mov eax, count



call DumpRegs
exit 
main ENDP
END main  
----------------

