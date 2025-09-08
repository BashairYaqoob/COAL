INCLUDE Irvine32.inc

.data
onebyte BYTE 73h
oneword WORD 1234h
onedword DWORD 12345678h

.code
main PROC

mov eax,0 
call DumpRegs
mov al , onebyte ;eax=00000073h
call DumpRegs
mov ax, oneword ; eax=00001234h
call Dumpregs
mov eax, onedword ;eax=1235678h
call DumpRegs
mov ax, 0 ;eax=12340000h
call DumpRegs


call DumpRegs
exit 
main ENDP
END main  
