; Additional fixes have been added to address the issues mentioned

section .data
    ; prompts and outputs
    inputGraphPrompt db "Enter the adjacency matrix of the graph (separated by space from first node to last node)",10,0
    inputVertexPrompt db "Enter the number of vertices: ",0
    inputSourcePrompt db "Enter the starting point: ",0
    inputTargetPrompt db "Enter the target point: ", 0
    inputVertexNameString db "Enter vertexs name (do not separated): ",0
    distanceOutput db "Shortest distance is ",0
    pathOutput db "Shortest path is ", 0
    cannotTravel db "Cannot travel to the target.",10,0
    invalidVertex db "Invalid source or target point.",10,0
    numberVertexError db "Number of vertices is not met.",10,0
    numberFormatError db "Number format is error.",10,0
    vertexOutOfBound db "Number of vertices out of bound.",10,0
    vertexNotFound db "Vertex is not found.",10,0
    invalidcolidx db "Invalid column index.", 10,0
    invalidrowidx db "Invalid row index.",10,0
    unreachableError db "Target is unreachable.",10,0
    repeatedVertexError db "Vertex name cannot be repeated.",10,0
    endl db 10,0
    space db " ",0
    arrow db "->",0
    colon db ": ",0
    ligae db "+++++++++++++++++++++++++++++++++",10,0
    programName db "Dijkstra's Shortest path",10,0
    logBound db "Vertex is from A to ",0
    updateNotification db "Updated!",10,0
    
    ten dq 10

section .bss
    stringBuffer resb 255      ; buffer for string input
    intBuffer resq 1           ; buffer for integer input
    vertexName resq 60
    vertexCount resq 1         ; stores the number of vertices
    graph resq 3600            ; adjacency matrix storage (max 60 vertices, 60x60)
    superUltimateBuffer resb 255 ; super ultimate very cool and very hot in the same time!!!!
    startPoint resq 1 ;stores the starting point
    targetPoint resq 1 ;stores the target point

    ;Dijkstra's algorithm table
    distance resq 60
    sourceArr resq 60
    visitedArr resq 60
    answer resb 60

section .text
    global _start

_start:
    ; Print header information
    call printLigae
    lea rdi, [programName]
    call printString
    call printLigae

    lea rdi, [inputVertexNameString]
    call printString

    call readVertexNameSTR
    mov [vertexCount], r8
    call printLigae
    call isVertexNameRepeated
    
    lea rdi, [inputGraphPrompt]
    call printString

    call readGraph
    call printLigae
    lea rdi, [inputSourcePrompt]
    call printString

    ;Get Start point
    mov rax,0   ;sys_read
    mov rdi,0   ;stdin
    mov rsi,stringBuffer
    mov rdx,2
    syscall

    movzx r9, byte [stringBuffer]
    ;loop for find vertex index
    call getVertexIdx
    mov [startPoint], r8
    ;Get Target point
    lea rdi, [inputTargetPrompt]
    call printString
    
    mov rax,0   ;sys_read
    mov rdi,0   ;stdin
    mov rsi,stringBuffer
    mov rdx,2
    syscall

    movzx r9, byte[stringBuffer]
    call getVertexIdx
    mov [targetPoint], r8
    call printLigae
    ;start dijkstra's shortest path algorithm
    mov rax, [startPoint]
    mov rbx, [targetPoint]
    mov rdx, [vertexCount]
    mov rcx, rdx
    imul rcx, 8
    mov r8,0
    mov r9, rdx
    dec r9
    mov rsi,0
    mov r10,0
    mov r11,0
    mov r14,0
    mov r15,0
    prepareDistance:
        cmp r8,rdx
        jge endPrepare

        mov qword [distance + r8*8], 1000000
        mov qword [visitedArr + r8*8],0
        mov qword [sourceArr + r8*8],0
        inc r8
        jmp prepareDistance
    
    endPrepare:
        mov qword [distance + rax*8], 0
        xor r8,r8
    dijkstra:
        cmp rsi, r9
        jge .endDijkstra
        call getMinDistance ;returned r8
        mov qword [visitedArr + r8*8], 1
        ;update distance
        .loopUpdateDistance:
            cmp r10, rdx
            jge .endLoopUpdateDistance
            cmp qword [visitedArr + r10*8], 1
            je .updateUpdateFirst ;skip if visited
            mov r11, r8
            imul r11, rdx
            add r11, r10
            imul r11, 8
            cmp qword [graph + r11], 0
            jle .updateUpdateFirst ; Ensure no negative weights are processed
            cmp qword [distance + r8*8], 1000000
            je .updateUpdateFirst
            mov r12,[distance + r8*8]
            add r12,[graph + r11]
            cmp r12, qword [distance + r10*8]
            jle .updateDistance
            jmp .updateUpdateFirst

            .updateDistance:
                mov [sourceArr + r10*8], r8
                mov [distance + r10*8], r12
                jmp .updateUpdateFirst

            .updateUpdateFirst:
                inc r10
                jmp .loopUpdateDistance

        .endLoopUpdateDistance:
            inc rsi
            mov r10,0
            jmp dijkstra

    .endDijkstra:
        mov r9, [sourceArr + rbx*8]
        mov r15, [vertexName + rbx*8]
        mov [answer], r15
        mov r15, r9
        mov r13,1
        ;backward
        .loopGetPathBackward:
            cmp r15,0
            je unreachable
            mov r8, [vertexName + r15*8]
            mov [answer + r13], r8
            inc r13
            mov r15, [sourceArr + r15*8]
            cmp r15, rax
            jne .loopGetPathBackward

        .loopbacksuccess:
            mov r15, [vertexName + rax*8]
            mov [answer + r13], r15
            ;printit
            
            printpath:
                lea rdi, [pathOutput]
                call printString
                .loopPrintPath:
                    cmp r13,0
                    jl .endLoopPrintPath
                    lea rdi, [arrow]
                    call printString
                    lea rdi, [answer + r13]
                    call printString
                    mov byte [answer + r13], 0
                    dec r13
                    jmp .loopPrintPath
                .endLoopPrintPath:
                    lea rdi, [endl]
                    call printString
                    lea rdi, [distanceOutput]
                    call printString
                    
                    mov rax, [distance + rbx*8]
                    mov rsi,rax
                    call toInt
                    lea rdi, [stringBuffer]
                    call printString
                
                    ;call printInteger 
    lea rdi,[endl]
    call printString
    call printLigae
    jmp exitSuccess

;dijkstra helper
getMinDistance:
    push rax
    push rbx
    push rcx
    push rdi
    mov rax, [vertexCount]
    xor rbx,rbx
    xor rdi,rdi
    mov rcx, 1000000
    .mindistloop:
        cmp rbx, rax
        jge .exitmindistloop
        cmp qword [visitedArr + rbx*8], 0
        jne .minupdatefirst
        cmp qword [distance + rbx*8], rcx
        jl .minset
        jmp .minupdatefirst
    .minset:
        mov rcx, qword [distance + rbx*8]
        mov rdi, rbx
    .minupdatefirst:
        inc rbx
        jmp .mindistloop
    .exitmindistloop:
        mov r8,rdi
        pop rdi
        pop rcx
        pop rbx
        pop rax
        ret
printString:
    push rcx

    ; Function to print a null-terminated string
    push rdi
    xor rax, rax
    xor rcx, rcx
    not rcx
    mov al, 0
    cld
    repne scasb
    not rcx
    dec rcx
    mov rdx, rcx
    pop rsi
    mov rax, 1
    mov rdi, 1
    syscall

    pop rcx
    ret

readInt:
    ; Read an integer from the user
    call readBuffer
    lea rdi, [stringBuffer]
    xor rax, rax
    xor rbx, rbx

convert_loop:
	movzx rbx, byte [rdi]	; Get character from buffer
	test rbx, rbx		; Check for null terminator
	je .next		;
	cmp rbx,'0'
	jl .next		;
	cmp rbx,'9'
	jg .next		;
	sub rbx,'0'		; Convert to integer
	imul rax,10		; Multiply current result by 10
	add rax,rbx	; Add the digit to result
	inc rdi
	jmp convert_loop
.next:
    ret

readBuffer:
    ; Read buffer using syscall
    mov rax, 0
    mov rdi, 0
    mov rsi, stringBuffer
    mov rdx, 255
    syscall
    ret

clearString:
    ; Clears the string buffer
    xor rax, rax
    rep stosb
    ret

readGraph:
    mov r10, [vertexCount]         ; Number of vertices (matrix size)
    mov r13, 0                      ; Row index (counter)
    mov r8, 0                       ; Index for the matrix elements (in graph)

.readGraphLoop:
    cmp r13, r10                    ; Check if we've read all rows
    jge .endReadGraph               ; If all rows are read, exit

    push rax
    push rdi
    push rsi
    push rdx
    
    mov rax,1
    mov rdi,1
    lea rsi, [vertexName + r13*8]
    mov rdx,1
    syscall

    lea rdi, [colon]
    call printString

    pop rdx
    pop rsi
    pop rdi
    pop rax
    call readBuffer                 ; Read the next line of input (one row of the adjacency matrix)
    lea rdi, [stringBuffer]         ; Load the buffer into rdi (stringBuffer)
    xor rbx, rbx                    ; Column index (counter for the row)
    xor rax, rax                    ; Clear the accumulator for the number being read

.readColumnLoop:
    cmp rbx, r10                    ; Check if we've processed all columns for the current row
    jge .nextRow                    ; If yes, move to the next row

    movzx rsi, byte [rdi]           ; Get the current byte (character) from the buffer
    cmp rsi, 0                      ; Check for the null terminator (end of string)
    je .vertexCountError            ; If we hit the end of the row, move to the next row

    cmp rsi, ' '                    ; If the character is a space, we need to store the current number
    je .storeValue                  ; Store the current number and move to next value

    cmp rsi, 10                     ; If it's a newline (end of row)
    je .storeValue                  ; Store the current number and move to next value

    ; Validate if it's a valid number (0-9)
    cmp rsi, '0'
    jl .numberError                 ; If less than '0', invalid input
    cmp rsi, '9'
    jg .numberError                 ; If greater than '9', invalid input
    sub rsi, '0'                    ; Convert ASCII to integer ('0' -> 0, '1' -> 1, ..., '9' -> 9)
    imul rax, 10                    ; Multiply accumulator by 10 to shift left
    add rax, rsi                    ; Add the digit to the accumulator

    inc rdi                         ; Move to the next byte in the input buffer
    jmp .readColumnLoop             ; Continue processing the next character

.storeValue:
    ; Store the current number as a qword (64-bit value)
    mov [graph + r8 * 8], rax      ; Store the value in graph (multiply by 8 for byte offset)
    inc r8                         ; Move to the next element in the graph
    inc rbx
    xor rax, rax                   ; Clear the accumulator for the next value
    inc rdi                         ; Move to the next byte in the buffer
    jmp .readColumnLoop             ; Continue processing the next column

.nextRow:
    inc r13                         ; Move to the next row
    jmp .readGraphLoop              ; Continue reading the next row


.numberError:
    lea rdi, [numberFormatError]   ; Print error message for invalid input
    call printString
    jmp exitFail                   ; Exit the program if there's an error

.vertexCountError:
    lea rdi, [numberVertexError]
    call printString
    jmp exitFail

.endReadGraph:
    ret

exitSuccess:
    mov rax,60
    mov rdi,0
    syscall

exitFail:
    mov rax,60
    mov rdi,1
    syscall

errorVertexOutofBound:
    lea rdi,[vertexOutOfBound]
    call printString
    jmp exitFail

toInt:
    ;input : rsi
    ;output : stringBuffer
    cmp rsi,0
    je .zeroCase
    push r8
    push rdx
    push rax
    push rbx
    push r9
    push r10
    mov rax,rsi
    mov r8,0
    mov rcx,0
    mov rax, 0
    mov rbx,10
    mov r9,0
    .tointMainloop:
        ;divided by 10 and get remainder (rdx)
        cmp rsi,0
        je .toIntReverseString
        xor rax,rax
        xor rdx,rdx
        mov rax,rsi
        div rbx ;quotient = rax, remainder = rdx
        add rdx,'0'
        mov [superUltimateBuffer + r8], rdx
        mov rsi,rax
        inc r8
        jmp .tointMainloop

    .zeroCase:
        mov byte [stringBuffer], '0'
        mov byte [stringBuffer + 1], 0
        ret
    .toIntReverseString:
        dec r8
        .toIntReverseStringLoop:
            cmp r8,0
            jl .finishToInt
            movzx r10, byte [superUltimateBuffer + r8]
            mov [stringBuffer + r9], r10
            inc r9
            dec r8
            jmp .toIntReverseStringLoop

    .finishToInt:
        mov byte [stringBuffer + r9], 0
        pop r10
        pop r9
        pop rbx
        pop rax
        pop rdx
        pop r8
        ret

readVertexNameSTR:
    call readBuffer
    mov r8,0
    .readVertexNameLoop:
        cmp byte [stringBuffer + r8], 10
        je .endReadVertexNameLoop
        movzx r9, byte [stringBuffer + r8]
        mov [vertexName + r8*8], r9
        add r8,1
        jmp .readVertexNameLoop
    .endReadVertexNameLoop:
        ret
    
vertexNotFoundE:
    lea rdi, [vertexNotFound]
    call printString
    jmp exitFail

getVertexIdx:
    ;returned r8
    ;input r9
    push rax
    push r11
    mov rax,0
    .getVertexIdxLoop:
        cmp rax, [vertexCount]
        jge vertexNotFoundE
        mov r11, [vertexName + rax*8]
        inc rax
        cmp r9, r11
        jne .getVertexIdxLoop
        dec rax
        mov r8,rax
        pop r11
        pop rax
        ret

isVertexNameRepeated:
    push rax
    push rbx
    push rcx
    push rdi
    mov rbx,0
    .loop:
        cmp rbx, [vertexCount]
        jge .exitloop
        mov rax, [vertexName + rbx*8]
        mov rcx,0
        .innerloop:
            cmp rcx, [vertexCount]
            jge .exitinner
            mov rdi, [vertexName + rcx*8]
            cmp rbx,rcx
            je .same
            cmp rax, rdi
            je .repeated
            inc rcx
            jmp .innerloop
        .exitinner:
            inc rbx
            jmp .loop
        .same:
            inc rcx
            jmp .innerloop
        .repeated:
            lea rdi, [repeatedVertexError]
            call printString
            jmp exitFail
    .exitloop:
        pop rdi
        pop rcx
        pop rbx
        pop rax
        ret

printLigae:
    push rax
    push rsi
    push rdi
    push rdx

    mov rax,1
    mov rdi,1
    mov rsi,ligae
    mov rdx,35
    syscall

    pop rdx
    pop rdi
    pop rsi
    pop rax
    ret

unreachable:
    lea rdi,[unreachableError]
    call printString
    jmp exitFail