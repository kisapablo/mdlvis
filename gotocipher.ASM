format MS COFF		     ;������ - ��������� ����
section '.text' code readable executable ;������ ����
public	    ExpGoToCipher

;����������������� ������� ��� ������ ��������� �����.
;ExpGoToCipher(StartAddr)
;���������� �������� ������� ������� �����
ExpGoToCipher:			  ;eax=StartAddr
 mov	ecx,eax 		  ;�����������
 @@:
  movzx edx,byte [eax]		  ;������ ����
  cmp	edx,'-' 		  ;���������� � �������
  je	EGTC_End
  inc	eax			  ;��������� �����
  cmp	edx,'0'
 jb	@b
  cmp	edx,'9'
 ja	@b
  dec	eax
EGTC_End:
  sub	eax,ecx 		  ;������� ��������
ret
