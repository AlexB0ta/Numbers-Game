.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern sprintf: proc
extern printf: proc
extern rand: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Proiect Numbers",0
area_width EQU 640
area_height EQU 480
area DD 0

counter DD 0 ; numara evenimentele de tip timer
cOK DD 0

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc

buton_x equ 80
buton_y equ 40
buton_size equ 420
 
n equ 3
m DD 0
aux dd 0
str1 db 10 dup(0)
format db "%d ",0
formats db "%s",0
var1 dd 0
doi dd 2
m_x dd 0
m_y dd 0
m_x_i dd 0
m_y_i dd 0
j dd 0
v dd 100 dup(0)
i dd 0
prev dd 1
ok dd 0
c_x dd 0
c_y dd 0

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha

	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

linie_horizontal macro x,y,len,color; ----
local bucla_linie
	mov eax, y
	mov ebx,area_width
	mul ebx
	add eax, x
	shl eax,2
	add eax,area
	mov ecx,len	
bucla_linie:
	mov dword ptr[eax],color
	add eax,4
	loop bucla_linie
endm

linie_verticala macro x,y,len,color
local bucla_linie
	mov eax, y
	mov ebx,area_width
	mul ebx
	add eax, x
	shl eax,2
	add eax,area
	mov ecx,len
bucla_linie:
	mov dword ptr[eax],color
	add eax,area_width*4
	loop bucla_linie
endm
	

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
et_start:
	mov ok,0
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax,ok
	je afisare_litere
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic


	
evt_click:
	; verificam daca clickul este in interiorul tabelei
	mov eax,[ebp+arg2]
	cmp eax,buton_x
	jl final_draw
	cmp eax,buton_x+buton_size
	jg final_draw
	mov eax,[ebp+arg3]
	cmp eax,buton_y
	jl final_draw
	cmp eax,buton_y+buton_size
	jg final_draw
	
	;calculam dimensiunea unei celule
	mov edx,0
	mov eax,var1
	div doi
	mov ebx,eax
	push ebx
	push offset format
	call printf
	add esp,8
	
	mov edx,0
	mov eax,[ebp+arg3]
	sub eax,buton_y; scadem din coord clickul coord lui y pt a putea afla casuta
	div var1
	mov i,eax ;rand in care am dat click


	push i
	push offset format
	call printf
	add esp,8
	
	mov edx,0
	mov eax,[ebp+arg2]
	sub eax,buton_x
	div var1
	mov j,eax;col in care am dat click
	
	
	push j
	push offset format
	call printf
	add esp,8
	
	mov esi,i
	mov edi,j
	; dec esi
	; mov eax,esi
	; mov ecx,n
	; mul ecx
	; mov esi,eax
	
	mov eax,n
	mul esi
	mov esi,eax
	
	add edi,esi
	mov eax,edi
	mov edx,0
	mov esi,4
	mul esi
	
	mov edi,eax ; indexul casutei in care am dat click
	
	
	
	;mov esi,i
	;mov edi,j
	mov ebx,prev
	
	
	cmp v[edi],ebx
	jne afisare_litere
	;sunt egale--------------------------------------------------------
	inc cOK
	mov ebx,v[edi]
	inc ebx
	mov prev,ebx
	
	mov edx,0
	mov eax,var1
	div doi
	add eax,buton_x
	mov ebx,eax
	mov eax,var1
	mul j
	add eax,ebx
	mov c_x,eax
	

	
	mov edx,0
	mov eax,var1
	div doi
	add eax,buton_y
	mov ebx,eax
	mov eax,var1
	mul i
	add eax,ebx
	mov c_y,eax
	
	
	make_text_macro ' ', area, c_x,c_y
	
	mov eax,c_x
	sub eax,10
	mov c_x,eax
	
	make_text_macro ' ', area, c_x,c_y
	jmp final_draw
	

	
	
evt_timer:
	inc counter
	jmp final_draw


afisare_litere:

	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	
	;in cazul in care am apasat gresit resetam valorile
	mov prev,1
	mov cOK,0

	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	; mov ebx, 10
	; mov eax, counter
	;cifra unitatilor
	; mov edx, 0
	; div ebx
	; add edx, '0'
	; make_text_macro edx, area, 30, 10
	;cifra zecilor
	; mov edx, 0
	; div ebx
	; add edx, '0'
	; make_text_macro edx, area, 20, 10
	;cifra sutelor
	; mov edx, 0
	; div ebx
	; add edx, '0'
	; make_text_macro edx, area, 10, 10
	
	;desenam tabla-margini
	linie_horizontal buton_x,buton_y,buton_size,0h
	linie_verticala buton_x,buton_y,buton_size,0h
	linie_horizontal buton_x,buton_y + buton_size,buton_size,0h
	linie_verticala buton_x+buton_size,buton_y,buton_size,0h
	
	;compar n cu 1 ca sa mearga in cazul in care tabla e 1x1
	mov eax,1
	cmp eax,n
	jne et_nu_e_1
	make_text_macro '1',area,210+80,210+40
	mov v[0],1
	mov var1,420
	jmp final_draw
	
et_nu_e_1:
	
	;desenam grid
	mov ebp,n-1
	
	mov eax,0
	mov ecx,n
	mov eax,buton_size
	div ecx
	mov var1,eax
	
	
bucla_linii:
	mov edx,0
	mov eax,var1

	mul ebp
	dec ebp
	
	add eax,buton_y

	linie_horizontal buton_x,eax,buton_size,0h
	cmp ebp,0
	jne bucla_linii
	
	
	mov ebp,n
	mov eax,0
	
	
bucla_col:
	mov eax,var1

	dec ebp
	mul ebp
	
	add eax,buton_x

	mov m,eax
	
	
	linie_verticala m,buton_y,buton_size,0h
	cmp ebp,1
	jne bucla_col	
	
	
	;calculam locul in patrat pt cifra
	mov eax,var1
	div doi
	add eax,buton_x
	mov m_x,eax
	mov m_x_i,eax
	sub eax,buton_x
	add eax,buton_y
	mov m_y,eax
	mov m_y_i,eax
	
	mov ebp,0
	mov esi,n*n
et_loop1:
	mov v[ebp*4],esi
	
	inc ebp
	dec esi
	cmp ebp,n*n
	jne et_loop1
	

	
	mov ebx,n
	mov eax,n
	mul ebx
	mov ebx,eax
	div doi
	mov esi,eax
	
	mov ebp,esi
et_loop:
	push eax
	call rand
	add esp,4
	
	div ebx
	mov i,edx
	
	push eax
	call rand
	add esp,4
	
	div ebx
	mov j,edx
	
	mov esi,i
	mov eax,v[esi*4]
	mov ecx,v[edx*4]
	mov v[esi*4],ecx
	mov v[edx*4],eax
	
	dec ebp
	cmp ebp,0
	jne et_loop
		
	
	
	mov ebp,0
	
	mov aux,n
	mov j,0
	mov i,0
	mov edx,0
	mov edi,0
	
loop_pune_nr:

	
	mov eax,v[ebp*4]
	mov m,eax
	
	
	push m
	push offset format
	push offset str1
	call sprintf 
	add esp,12 
	 

	
	mov ecx,m_x_i ; salvam vechea val
	
	mov al,str1[1]
	;mov m_x_i,esp
	make_text_macro eax,area,m_x_i,m_y_i ;afisam cifra unit
	
	mov al,str1[0]
	mov ebx,m_x_i
	sub ebx,10
	mov m_x_i,ebx
	
	make_text_macro eax,area,m_x_i,m_y_i ;afisam cifra zeci
	inc j
	inc ebp
	mov m_x_i,ecx ;repun vechea val
	
	
	cmp j,n
	jne et_1
	cmp j,n
	je et_2
	
	
et_2:
		mov ebx,m_y_i
		add ebx,var1
		mov m_y_i,ebx
		mov j,0
		mov ebx,m_x
		sub ebx,var1
		mov m_x_i,ebx
		inc esi
	

	
et_1:
		mov ebx,m_x_i
		add ebx,var1
		mov m_x_i,ebx
		inc edi
	
	
	cmp ebp,n*n
	jne loop_pune_nr
	
	
	mov ok,3
		

final_draw:
	cmp cOK,n*n
	jne et_f
	make_text_macro 'A',area,550,150
	make_text_macro 'I',area,560,150
	make_text_macro 'C',area,520,180
	make_text_macro 'A',area,530,180
	make_text_macro 'S',area,540,180
	make_text_macro 'T',area,550,180
	make_text_macro 'I',area,560,180
	make_text_macro 'G',area,570,180
	make_text_macro 'A',area,580,180
	make_text_macro 'T',area,590,180
	make_text_macro 'Z',area,550,200
	make_text_macro 'Z',area,560,200
	
	
	
et_f:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp
Finished:

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	
	;terminarea programului
	push 0
	call exit
end start
