%include "rw32.inc"

; Ukol 0: Spravne doplnte nazvy sekci podle toho, co se v nich nachazi.
; Pokud dale ve zdrojaku narazite na otazku, tak ji zodpovezte.

; ***DOPLNTE***
section .data
;Vyuzijte predpripravenych vypisu, klidne si vytvorte vlastni
print_even  db "Sude cislo!", 0
print_odd   db "Liche cislo! ", 0
print_week  db "Po, Ut, St, Ct, Pa, So, Ne, X: ", 0
print_decr  db "Po desifrovani (puvodni text): ", 0
print_encr  db "Po zasifrovani: ", 0
print_da    db "V d|a je 16b cislo: ",0
print_bc    db "V b|c je 16b cislo: ",0

weekmask    db 0 ; binarne - 0000 0000

text        db "Jsem tajna zprava. Pssst!", 0
length      equ  $ - text - 1  ; "equ" definuje konstantu. Znak "$" nam rika aktualni pozici, tj. adresa nasledujici instrukce, kter� bude zpracovana.
                               ; "- text" pouze od aktualni adresy odecte adresu, ktera ukazuje na promennou text.
key8        db 199
mem_abcd    db 21, 125, 31, 5

; ***DOPLNTE***
section .bss
    ; rezervace mista pro neinicializovane promenne
    ; OTAZKA - jaka direktiva se zde pouziva?

; ***DOPLNTE***
section .text
main:
    ; Muzete vyzkouset v debuggeru - rozdil mezi NOT a NEG
    xor eax, eax
    mov al, byte 5
    not al
    mov ah, byte 5
    neg ah

ukol1:
    ; 1) Pouzijte funkci ReadInt16 pro ziskani ciselneho vstupu z klavesnice 
    ; 2) Pouzijte instrukci TEST pro urceni, zda jde o liche nebo sude cislo
    ; Napoveda: Staci test jednoho bitu, kde se licha cisla jednoznacne lisi od sudych.
    
    ; ***** ZDE DOPLNTE SVUJ KOD *****

    xor eax, eax
    call ReadInt16
    test ax, 1

    ; TOTO PROSIM NEMENIT
    jz .even		         ; Instruknce TEST nam zmenila bity reg. EFLAGS. Pokud je ZF=0, skoc na lokalni navesti .even (sudy)
    mov esi, print_odd       ; Pokud se neskakalo, pokracuje se zde. 
    call WriteStringASCIIZ   ; Vypis retezce
    call WriteNewLine
    jmp .end                 ; Nepodmineny skok na lokalni navesti konec

.even:
   ; **** ZDE DOPLNTE SVUJ KOD ***** 
   ; 1) vypiste retezec v promenne print_even 
   ; 2) odradkujte



.end:



ukol2:
  or byte [weekmask], 160
  mov al, [weekmask]
; Pouzijte instrukce AND/OR k nastaveni priznaku v promenne weekmask. Promenna weekmask je 8 bitova a kazdy jeji bit predstavuje
; 1 den v tydnu s vyjimkou LSB, ktery nepredstavuje nic - (MSB)==Po, Ut, St, Ct, Pa, So, Ne, X(==LSB).
; Pomoci instrukce AND nastavte na jednicku ty bity, ktere odpovidaji dnum, kdy mate prednasku a cviceni z ISU.
; Druhym parametrem funkce AND/OR bude dekadicke cislo, napr. AND reg, byte 1.
; Hodnota promenne weekmask je nastavena na 0, rozhodnete se, ktera instrukce - AND nebo OR, bude pro vas vyhodnejsi.

; Napoveda: Uvazujme registr AL obsahujici slabiku tvaru XXXXAXXX. Pokud chci zachovat hodnotu A a ostatni bity X vynulovat, pouziji
; inst. AND (pr. AND AL, 8 (= 00001000)). Pokud chci hodnotu A zachovat a ostatni bity X nastavit na 1, pouziji inst. OR
; (pr. OR AL, 0xF7 (= 11110111)).

    ; ***** ZDE DOPLNTE SVUJ KOD ***** - asi tak dva radky.

	

    ; Vypis - vypisovana hodnota musi byt v registru AL.
    mov esi, print_week
    call WriteStringASCIIZ
    call WriteBin8
    call WriteNewLine

ukol3:
; Mame retezec ulozeny v promenne text. Tento text chceme zasifrovat pomoci jednoduche symetricke sifry.
; Pro sifrovani pouzijte 8 bit klic ulozeny v promenne key8.
; Inspirujte se schematem pro sifrovani/desifrovani z prezentace na cviceni.
; Sifrovani i desifrovani provadejte znak po znaku (bajt po bajtu).
; !! Toto cviceni jiz obsahuje jednoduchy cyklus s popisem. Doplnte zbyvajici kod dle instrukci a zodpovezte otazky.
; V tomto cviceni pracujte s debuggerem a sledujte pamet a priznaky.

; a) 1) Do registru ESI vlozte ukazatel na promennou text. (Otazka: Muzete pouzit i mensi registr nez 32b?)
;    Promennou text budeme neprimo modifikovat pomoci ESI. Promennou text tedy jiz dale nesmite pouzit!
;    2) Do ECX (Counter) - vlozte UKAZATEL na promennou length (delka retezce text).
;   --> PROC UKAZATEL? Podivejte se na definici promenne length - mate u ni vysvetleni, jak je vypoctena.
;       Dale doporucuji pouzit debugger a zobrazit si pamet v Unsigned Int a Traditional modu. Muzete videt, ze to, co potrebujeme
;       je prave hodnota adresy (ta je stejna jako delka retezce, nemuseli bychom pouzivat ani velky registr, jelikoz hodnota adresy je
;       mala). Tato adresa vsak neukazuje na zadne smysluplne misto, proto nemuzeme pouzit hodnotu, na kterou se odkazuje (ta nas nezajima).
;    3) Do vhodneho registru si ulozte hodnotu promenne key8.
 
   ; ***** ZDE DOPLNTE SVUJ KOD ***** bod a) 1-3

  mov esi, text
  mov ECX, length
  mov al, [key8]
   

.Encrypt:
; b) Zde doplnte 
;    1) kod provadejici sifrovani jednoho znaku,
;    2) spravne nastavte ukazatel, aby se v dalsi iteraci zpracovaval dalsi znak,
;    3) snizeni hodnotu counteru (ecx) o 1.
;    Cyklus je jiz napsany - doplnte jen jeho telo.
;    Napoveda - pouzijte: MOV, XOR, INC, DEC, ??(vhodne zvolena log. instrukce)
;    Pracujte pouze s registry, nepouzivejte primo promennou text (pristupujte k ni pres registr esi).

    ; ***** ZDE DOPLNTE SVUJ KOD ***** bod b) 1-3
	; Pouzijte vhodnou logickou instrukci, ktera otestuje hodnotu v ECX.

    xor [esi], al
    inc esi
    dec ECX
    test ECX, ECX

	
   
   ; TOTO PROSIM NEMENIT
   jnz .Encrypt    ; "jump if not zero" - pokud neni 0, tak skoc na lokalni navesti .Encrypt
                   ; Otazka: Podle ktereho priznaku v EFLAGS se instrukce jnz rozhoduje? ZF

   mov esi, print_encr
   call WriteStringASCIIZ
   mov esi, text           ; Ukazatel na zacatek retezce
   call WriteStringASCIIZ  ; Tisk zasifrovaneho retezce - dobry smeti, ze?
   call WriteNewLine

   mov ecx, length ; Reset ECX

.Decrypt:
; d) Zde doplnte kod provadejici desifrovani jednoho znaku (tento kus kodu jste jiz napsali, tak ho zkopirujte).
;    Easy Peasy! Vy vsak pozorujte registry a pamet v debuggeru - budu to chtit ukazat.
  
  ; ***** ZDE DOPLNTE SVUJ KOD ***** uz jsme to tu meli... bod b?

  xor [esi], al
  inc esi
  dec ECX
  test ECX, ECX
  
  
  ; TOTO PROSIM NEMENIT
  jnz .Decrypt   ; "jump if not zero" to .Decrypt

  mov esi, print_decr
  call WriteStringASCIIZ
  mov esi, text           ; Ukazatel na zacatek retezce
  call WriteStringASCIIZ  ; Tisk desifrovaneho retezce - stejny jako puvodni
  call WriteNewLine

ukol4:
; Vyuzijte instrukce posuvu pro nasobeni a deleni
; 1) Nahrajte do 32b registru konstantu 100
; 2) Nactene cislo vydelte 2 pomoci logicke instrukce posuvu (100/2)
; 3) Vysledek vypiste a odradkujte
; 4) Ziskane cislo vynasobte 8 pomoci logicke instrukce
; 5) Vysledek opet vypiste
; 6) Ziskane cislo znegujte a vydelte cislem 4 - pozor na zachovani znamenka!
; 7) Spravne vypiste.

  ; ***** ZDE DOPLNTE SVUJ KOD ****

  mov eax, 100
  shr eax, 1
  mov esi, eax     ; Pokud se neskakalo, pokracuje se zde. 
  call WriteUInt32
  call WriteNewLine
  shl eax, 3
  call WriteUInt32
  call WriteNewLine
  neg eax
  sar eax, 2
  call WriteInt32
  call WriteNewLine
  

  
  
ukol5:
; Presunte si vsechny 4 hodnoty do registru EAX (treba) - jednou instrukci mov z promenne mem_abcd
; Pracujte pouze s timto registrem! Neni dovoleno pouzivat zadny jiny (ne-Ackovy) registr pro mezivypocty.
; Hodnoty v registru po nacteni z pameti oznacime nasledovne: (MSB) A | B | C | D (LSB)(rozdeleno po 8b)
; Vasim ukolem je docilit toho, abyste v registru meli ulozeny tyto vysledky: neg(C)+B | D*A  (rozdeleno po 16b)
; Muzete pouzit pouze arimeticke a logicke instrukce.
; Vysledky ulozene v BC a DA pote vypiste. Vyuzijte i vyse definovanych retezcu print_da a print_bc. 

; ***** ZDE DOPLNTE SVUJ KOD *****
  
mov eax, [mem_abcd] 
call WriteBin32
rol eax, 8
call WriteNewLine
call WriteBin32


  


ret