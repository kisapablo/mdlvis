format MS COFF		     ;������ - ��������� ����
section '.text' code readable executable ;������ ����
public	    ExpGetFloat

;������� ��� ��������� �������� �� float-�����:
;ExpGetFloat(StartAddr,var Data)
;���������� ��������������� integer-����� (delta-��������),
;� DATA ��������� ��������� ������
;���.:
;eax - StartAddr
;esi - ������� �����
;edi - ������ ������� (exp-�����)
;edx - @data
;ecx - ��������� �������
;ebp - ��������� ������ (<>0 - ���� �����)
;[esp] - ������ ��� ������ �������
;[esp+4] - 10 (���������)
ExpGetFloat:			    ;eax=StartAddr, edx=@data
 push	esi edi ebp
 push	dword 10		    ;���������
 push	eax			    ;������
 xor	ebp,ebp
 mov	esi,eax 		    ;esi=�����
 fldz				    ;0 - � ���� ����.
 ;0. ������ ������ (���� �����)
  movzx ecx,byte [esi]
  cmp	ecx,'-'
  jne	@f

  dec	ebp			    ;ebp=-1
  inc	esi
 ;1. ������ ����� �����
 @@:
  movzx ecx,byte [esi]		    ;������ ��������� ������
  cmp	ecx,'0'
  jb	EGF_Fract
  cmp	ecx,'9'
  ja	EGF_Fract

  sub	ecx,30h 		    ;��������� � �����
  fimul dword [esp+4]		    ;*10
  mov	[esp],ecx		    ;� ����
  fiadd dword [esp]		    ;+�����
  inc	esi			    ;� ����. �������
 jmp	@b			    ;����� �����

 EGF_Fract:

 ;2. ������ ������� �����
 movzx	ecx,byte [esi]
 cmp	ecx,'.' 		    ;����� ������� ������ ������ ���� ����� (.)
 jne	EGF_Exp

 inc	esi			    ;� ������� ������� �����
 mov	dword [esp+4],0.1	    ;��������� ��� ������� �����
 fldz				    ;�������� ���� � ������� �����
 fld	dword [esp+4]		    ;� ���� (��������)
 fld	st0			    ;0.1
 @@:
  movzx ecx,byte [esi]		    ;������ ��������� ������
  cmp	ecx,'0'
  jb	EGF_Compose
  cmp	ecx,'9'
  ja	EGF_Compose

  sub	ecx,30h
  mov	[esp],ecx
  fild	dword [esp]		    ;�������� �����
  fmul	st0,st2
  faddp st3,st0 		    ;����� ��������
  fmul	st1,st0 		    ;��������� �������� �� 0.1
  inc	esi			    ;� ����. �������
 jmp	@b			    ;����� �����

 ;3. �� ����������
 EGF_Compose:
 ffree	st0			    ;��������� �� 0.1 � ��������
 fincstp
 ffree	st0
 fincstp

 faddp	st1,st0 		    ;���������� ����� � ������� ������. ���� ����.

 ;4. ������ ������� (�������� ��� �����. ���� ����� ebp)
 EGF_Exp:
 ;���� ������ (������� � ���� - ������ �����, � �� ����������)
 test	ebp,ebp
 jz	@f
  fchs				    ;����� �����
 @@:

 movzx	ecx,byte [esi]		    ;��������� ������ (��� ������� - 'e')
 cmp	ecx,'e'
 jne	EGF_Ret 		    ;��� ���������������� �����

 inc	esi			    ;� 1 ������� (��� �.�. ���� ������� - +/-)
 xor	ebp,ebp
 movzx	ecx,byte [esi]		    ;������ ������ (��������, ����)
 cmp	ecx,'+' 		    ;����. ����������
 jne	@f
  inc	esi
 @@:
 cmp	ecx,'-'
 jne	@f
  dec	ebp
  inc	esi
 @@:

 xor	edi,edi 		    ;edi=0 (���� ��� �������)
 @@:
  movzx ecx,byte [esi]
  cmp	ecx,'0'
  jb	EGF_ApplyExp
  cmp	ecx,'9'
  ja	EGF_ApplyExp
				    ;����� �������
  lea	edi,[edi*4+edi]
  sub	ecx,30h
  lea	edi,[edi*2+ecx] 	    ;edi=edi*10+ecx
  inc	esi
 jmp	@b			    ;����� �����

 ;5. �������
 EGF_ApplyExp:
 cmp	edi,38			    ;�������� �� ����� �� ������ ����.
 jna	@f
  mov	edi,38
 @@:

 mov	edi,[Fr_Tbl+edi*4]	    ;�������� �-�� �������
 mov	[esp],edi

 test	ebp,ebp 		    ;� ������ �����. ����� - ����������
 fld   dword [esp]
 jz	@f
  fdivp st1,st0
;  fidiv dword [esp]
;  fmulp st1,st0                    ;*1/exp
  jmp	EGF_Ret
 @@:
 fmul  st1,st0			    ;*exp

 EGF_Ret:
 fstp	dword [edx]		    ;������� �����
 add	esp,8			    ;������� �����
 sub	esi,eax
 mov	eax,esi
 pop	ebp edi esi
ret
;======================================================
section '.data' data readable writeable  ;������ ������
 ;����� ���������������� ����������
 Fr_Tbl dd 1e0, 1e1, 1e2, 1e3, 1e4, 1e5, 1e6, 1e7, 1e8, 1e9,\
	   1e10,1e11,1e12,1e13,1e14,1e15,1e16,1e17,1e18,1e19,\
	   1e20,1e21,1e22,1e23,1e24,1e25,1e26,1e27,1e28,1e29,\
	   1e30,1e31,1e32,1e33,1e34,1e35,1e36,1e37,1e38