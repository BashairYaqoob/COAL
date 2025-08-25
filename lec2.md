sample code for hello world:

INCLUDE Irvine32.inc

.data
_name BYTE "Hello World",0

.code
main proc

mov edx,offset _name
call WriteString

exit
main endp
end main
