format MS COFF		     ;формат - линкуемый файл
section '.text' code readable executable ;секция кода
public	    GetIntVal

;функция для конверсии символа в INT:
;GetIntVal(StartAddr,var Data)
;Возвращает непосредственно integer-число (delta-смещение),
;в DATA заносятся требуемые данные
;АЛГ.:
;eax - StartAddr
;esi - текщий адрес символа
;edi - результат
;edx - @data
;ecx - хранилище символа
;ebp - хранилище минуса
GetIntVal:			    ;eax=StartAddr, edx=@data
 push	esi edi ebp
 mov	esi,eax 		    ;копируем адрес символа
 xor	ebp,ebp
 inc	ebp			    ;ebp=1
 xor	edi,edi 		    ;edi=0

 ;1. Считываем первый символ, проверив его на минус
 movzx	ecx,byte [esi]
 cmp	ecx,'-'
 jne	@f
  dec	ebp
  dec	ebp
  inc	esi
  movzx ecx,byte [esi]
 @@:

 ;2. ecx=символ (причём НЕ минус!), eax - его адрес
@@:
 cmp	ecx,'0'
 jb	GIV_Exit
 cmp	ecx,'9'
 ja	GIV_Exit
 ;это цифра.
 sub	ecx,30h
 lea	edi,[edi*4+edi]
 lea	edi,[edi*2+ecx] 	    ;*10+цифра
 inc	esi			    ;к след. символу
 movzx	ecx,byte [esi]		    ;читаем
jmp	@b

GIV_Exit:			    ;вернуть значение (учтя минус) и выйти
 imul	edi,ebp
 mov	[edx],edi		    ;возврат целого числа
 sub	esi,eax
 mov	eax,esi
 pop	ebp edi esi
ret
