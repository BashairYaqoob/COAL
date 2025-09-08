movzx, movsx
INCLUDE Irvine32.inc

.data

.code
main PROC

mov bx, 0A69Bh ; hexa number starting with alphabets needs 0 at start
;mov eax,bx is error
movzx eax, bx ;eax-0000A69Bh
call DumpRegs
movzx edx, bl ;edx=0000009Bh
call DumpRegs
movzx cx, bl ; cx=009Bh

movsx eax, bx ;eax-FFFFA69Bh


call DumpRegs
exit 
main ENDP
END main 
