;******komarovev@info.sgu.ru   - отправлять ссылку на репозиторий


.MODEL small
.STACK 100h
.DATA

adr_Lpt1 dw 0  	; Переменная для хранения базового адреса LPT1
wait_5 dw 90 	;90=5/0.055 ожидание 5 секунд
a db 0
Space db 0

no_ready db 'Printer is not ready', 10, 13,'$'
no_printerPaper db 'no paper', 10, 13,'$'
printer_off_line db 'printer off-line', 10, 13,'$'
no_portLpt1 db 'No port Lpt1', 10, 13, '$'
msg db '',10,13,'$'


.CODE
start:

 	mov ax, @data 
 	mov ds, ax
	call init_Lpt1		;вызов процедуры инициализации LPT1

print_Loop:         	 ; цикл ввода-вывода символа		
	call analiz_Lpt1	;вызов процедуры анализа регистра состояния	

	mov ah, 0ch			;очищаем буфер клавиатуры
	mov al, 01			;выбираем функцию ввода символа
	int 21h				;чистим буфер, ждем ввода

	;push ax
	
	cmp al, 1bh     	 ;нажата клавиша ESC
 	je  exit        	; да, выход
	
	cmp al, 0dh
	je m_Enter
	call out_Bite
	jmp print_Loop
	
m_Enter:	
	call out_Bite
	
	mov ah, 09h			;перевод строки на экране
	mov dx, offset msg
	int 21h
	
	jmp print_Loop       ; повторяем, пока не будет нажата клавиша ESC

exit: 
	mov ax,4C00h ; завершить с кодом возврата 0
	int 21h	
	



init_Lpt1 proc		;процедура инициализации LPT1
	mov ax, 40h
 	mov es, ax   		; в es - сегмент = 0040h
 	mov  dx, es:[08] 	; dx = базовый адрес порта lpt1
 	mov adr_Lpt1, dx 	; запомнили адрес порта lpt1 в переменной adr_Lpt1
	cmp adr_Lpt1, 0
	je no_Lpt1

	inc  dx 	        ;прибавляем 2 к базовому адресу
    inc  dx           
    mov  al, 8       	;значение для инициализации
    out  dx, al        	;начинаем инициализацию
 	mov  ax, 1000      	;начало пустого цикла
m1:	dec  ax  	        ;уменьшаем счетчик
	jnz  m1           	;повторяем 1000 раз
	mov  al, 12         ;обычное значение для регистра
    out  dx, al        	;конец инициализации
	ret
	
no_Lpt1:
	mov ah, 09h
	mov dx, offset no_portLpt1
	int 21h
	jmp exit
	;ret
init_Lpt1 endp	


analiz_Lpt1 proc		;процедура анализа регистра состояния 
	mov ah, 00
	int 1ah
	add wait_5, dx
	
loop2:
	int 1ah
	cmp dx, wait_5
	je no_readyPrint
	
	mov dx, adr_Lpt1
  	inc dx  	; адрес регистра состояния (adr_Lpt1+1)
  	in  al, dx 	; Читаем регистр состояния
  	test al, 10000000b 	; Проверяем готовность принтера "1 - принтер готов"
  	jz  loop2   	; если нет, то повторим опрос
  	
	test al, 00100000b	;проверяем наличие бумаги
	jnz no_paper		;нет, сообщение об ошибки
	
	test al, 00010000b	;принтер on-line
	jz off_line			;нет, сообщение об ошибки
	ret

no_readyPrint:
	mov ah, 09h
	mov dx, offset no_ready
	int 21h
	;RET	
	jmp exit

no_paper:
	mov ah, 09h
	mov dx, offset no_printerPaper
	int 21h
	;RET	
	jmp exit
	
off_line:
	mov ah, 09h
	mov dx, offset printer_off_line
	int 21h
	;RET
 	jmp exit

analiz_Lpt1 endp



out_Bite proc			;процедура вывода символа на принтер
	mov dx, adr_Lpt1     	; адрес регистра данных (adr_Lpt1)
	;pop ax
	out dx, al  	; Запись байта в регистр данных
  	inc dx
  	inc dx      	; адрес регистра управления (adr_Lpt1+2)
  	in  al, dx  	; Читаем регистр управления
	

; Формируем стробирующий сигнал
	and al, 11111110b 	; Бит 0 (Strobe):=0
  	out dx, al  	 	; Запись в регистр управления
  	or  al, 00000001b 	; Бит 0 (Strobe):=1
  	out dx, al   		; Запись в регистр управления
  	and al, 11111110b 	; Бит 0 (Strobe):=0
  	out dx, al   		; Запись в регистр управления
  	;pop dx
	ret
out_Bite endp


end start