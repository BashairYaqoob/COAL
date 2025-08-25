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

----------------


.data (variables)(_name = variable, type = byte, terminates at 0 bcs of string), offset = address
_name BYTE "Hello World",0

mov edx,offset _name
call WriteString

writestring is defined in IrvineLib
edx is for strings


* EAX, EBX, ECX ARE  saved in processors
* variables are saved in RAM

* variableName DataType Value
* num1 byte 10
