format MS COFF		     ;������ - ��������� ����
section '.text' code readable executable ;������ ����
public	    FindSym

;������� ��� ������ �������:
;FindSym(StartAddr,sym_code)
;���������� �������� ����� ������� ������������ ���. ������
FindSym:			  ;eax=StartAddr, edx=sym_code
 push	edi
 mov	edi,eax 		  ;StartAddr
 mov	eax,edx 		  ;sym_code � eax
 mov	edx,edi 		  ;��� ��� ���������
 mov	ecx,-1			  ;�������� ���-�� �������� ��� ������
 repne	scasb			  ;����
 sub	edi,edx 		  ;������� ��������
 mov	eax,edi 		  ;����� ���
 dec	eax			  ;��������� ������� �����������
 pop	edi
ret
