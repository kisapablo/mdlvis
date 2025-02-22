format MS COFF		     ;������ - ��������� ����
section '.text' code readable executable ;������ ����
public	    GetIntVal

;������� ��� ��������� ������� � INT:
;GetIntVal(StartAddr,var Data)
;���������� ��������������� integer-����� (delta-��������),
;� DATA ��������� ��������� ������
;���.:
;eax - StartAddr
;esi - ������ ����� �������
;edi - ���������
;edx - @data
;ecx - ��������� �������
;ebp - ��������� ������
GetIntVal:			    ;eax=StartAddr, edx=@data
 push	esi edi ebp
 mov	esi,eax 		    ;�������� ����� �������
 xor	ebp,ebp
 inc	ebp			    ;ebp=1
 xor	edi,edi 		    ;edi=0

 ;1. ��������� ������ ������, �������� ��� �� �����
 movzx	ecx,byte [esi]
 cmp	ecx,'-'
 jne	@f
  dec	ebp
  dec	ebp
  inc	esi
  movzx ecx,byte [esi]
 @@:

 ;2. ecx=������ (������ �� �����!), eax - ��� �����
@@:
 cmp	ecx,'0'
 jb	GIV_Exit
 cmp	ecx,'9'
 ja	GIV_Exit
 ;��� �����.
 sub	ecx,30h
 lea	edi,[edi*4+edi]
 lea	edi,[edi*2+ecx] 	    ;*10+�����
 inc	esi			    ;� ����. �������
 movzx	ecx,byte [esi]		    ;������
jmp	@b

GIV_Exit:			    ;������� �������� (���� �����) � �����
 imul	edi,ebp
 mov	[edx],edi		    ;������� ������ �����
 sub	esi,eax
 mov	eax,esi
 pop	ebp edi esi
ret
