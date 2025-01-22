unit crash;
//� ���� ������ ��������� �� ����������� ��� ��������
//����-������ (�.�. �������� ���������� � ������ ������).
interface
uses windows;
//������������ (���� ��������) ���������� ���������� VEH
procedure RegisterExceptionHandler;
//������� ����������� �����������
procedure UnregisterExceptionHandler;

//���� ������� (����������)
procedure PushFunction(id:integer);
procedure PopFunction;

//function ExcFunc(ExceptionInfo:pointer):integer;stdcall;

Var sModelName:string;            //��� ����������� ������
    iAnimEdMode,iEditorMode:integer; //������ ���������
implementation
const
 FUNC_STACK_SIZE=20;
 EXCEPTION_CONTINUE_SEARCH=0;
 //��������� ��� MINIDUMP_TYPE
 MiniDumpNormal           =0;
 MiniDumpWithDataSegs     =1;
 MiniDumpWithFullMemory   =2;
 MiniDumpWithHandleData   =4;
 MiniDumpFilterMemory     =8;
 MiniDumpScanMemory       =$10;
 //true/false ��� �������� �����
 DUMP_TRUE                =1;
 DUMP_FALSE               =0;
 StreamUserStream         =$10000;

type TMINIDUMP_EXCEPTION_INFORMATION=packed record
 ThreadId:integer;                //Id ������, ����. ����������
 ExceptionPointers:pointer;       //��������� ����������
 ClientPointers:integer;          //DUMP_TRUE/DUMP_FALSE
end;//of TMINIDUMP_EXCEPTON_INFORMATION
PMINIDUMP_EXCEPTION_INFORMATON=^TMINIDUMP_EXCEPTION_INFORMATION;

//���������������� ����������
MINIDUMP_USER_STREAM_INFORMATION=packed record
 UserStreamCount:integer;
 UserStreamArray:pointer;
end;//of MINIDUMP_USER_STREAM_INFORMATION
PMINIDUMP_USER_STREAM_INFORMATION=^MINIDUMP_USER_STREAM_INFORMATION;

//����� ����������������� ������
MINIDUMP_USER_STREAM=packed record
 typ:integer;
 BufferSize:integer;
 Buffer:pointer;
end;//of MINIDUMP_USER_STREAM
PMINIDUMP_USER_STREAM=^MINIDUMP_USER_STREAM;

EXCEPTION_RECORD=packed record
 ExceptionCode:cardinal;
 ExceptionFlags:cardinal;
 //��������� ���� ���� ��� �� �����
end;//of EXCEPTION_RECORD
PEXCEPTION_RECORD=^EXCEPTION_RECORD;

EXCEPTON_POINTERS=packed record
 ExceptionRecord:PEXCEPTION_RECORD;
 Context:pointer;
end;//of EXCEPTION_POINTERS
PEXCEPTION_POINTERS=^EXCEPTION_POINTERS;

Var pAddVectoredExceptionHandler:function(FirstHandler:integer;
                                          VectoredHandler:pointer):pointer;stdcall;
    pRemoveVectoredExceptionHandler:function(VectoredHHandle:pointer):integer;stdcall;
    pMiniDumpWriteDump:function(hProcess,ProcessId,hFile,DumpType:integer;
                                ExceptionParam,UserStreamParam,
                                CallbackParam:pointer):boolean;stdcall;
    pVec:pointer;                 //����� ������ �����������
    IsAlwaysExc:boolean;          //true, ���� ��� ���� ����������

    //���� �������
    FuncStack:array[1..FUNC_STACK_SIZE] of integer;
    FuncSP:integer;               //��������� �����
//���������� callback-�������, ����� ���������� ����������
function ExcFunc(ExceptionInfo:PEXCEPTION_POINTERS):integer;stdcall;
Var hFile,len,i,tmp:integer;pBuf,pOut:PChar;
    ExcInfo:TMINIDUMP_EXCEPTION_INFORMATION;
    UserStream:MINIDUMP_USER_STREAM;
    UserInfo:MINIDUMP_USER_STREAM_INFORMATION;
Const sCrash='Crash0.dmp'#0;
      sMode='AnimEdMode,EditorMode= %ld,%ld'#13#10#0;
      sSP='FuncSP=%ld'#13#10#0;
      sStack='Function stack:'#13#10#0;
      sITS='%ld'#13#10#0;
      sRet=#13#10#0;
Begin
 //����� RTL ������� � "������" ������ � AccessViolation
 //����� ��, ��� ������ ���� ������� ����������
 Result:=EXCEPTION_CONTINUE_SEARCH;

 if IsAlwaysExc then exit else IsAlwaysExc:=true;
 if ExceptionInfo^.ExceptionRecord^.ExceptionCode<$FFFF then exit;

 //1. �������� ���� ��� ����-���� (���� �� ��� ������ 10)
 //a. �������� ������ � ������ ��� �����
 pBuf:=VirtualAlloc(nil,16000,MEM_COMMIT or MEM_TOP_DOWN,PAGE_READWRITE);
 pOut:=pointer(integer(pBuf)+15000);
 if pBuf=nil then exit;          //������ ��������� ������
 GetModuleFileName(0,pBuf,16000);
 len:=lstrlen(pBuf);
 pBuf[len-4]:=#0;
 lstrcat(pBuf,sCrash);
 len:=lstrlen(pBuf);
 //b. �������� ������� ����
 for i:=0 to 9 do begin
  pBuf[len-5]:=char(ord(pBuf[len-5])+1);
  hFile:=CreateFile(pBuf,GENERIC_READ or GENERIC_WRITE,0,nil,CREATE_NEW,
                    FILE_ATTRIBUTE_NORMAL,0);
  if (hFile>=0) and (hFile<>-1) then break;
 end;//of for i

 //c. ��������, ������ �� ������ ��������
 if (hFile<0) or (hFile=-1) then begin
  VirtualFree(pBuf,16000,MEM_DECOMMIT);
  exit;
 end;//of if

 //2. ���� ������. ������� ��������� ��������/������
 ExcInfo.ThreadId:=GetCurrentThreadID;
 ExcInfo.ClientPointers:=DUMP_FALSE;
 ExcInfo.ExceptionPointers:=ExceptionInfo;

 //3. ������� ���������������� �����
 pBuf[0]:=#0;                     //������������ ������� ������
 lstrcat(pBuf,PChar(sModelName)); //��� ������
 lstrcat(pBuf,sRet);              //Enter
 asm
  push dword [iEditorMode]
  push dword [iAnimEdMode]
 end;
 wsprintf(pOut,sMode);
 asm
  add esp,4*4
 end;
 lstrcat(pBuf,pOut);

 asm
  push dword [FuncSP]
 end;
 wsprintf(pOut,sSP);
 asm
  add esp,3*4
 end;
 lstrcat(pBuf,pOut);
 lstrcat(pBuf,PChar(sStack));

 if FuncSP<FUNC_STACK_SIZE then len:=FuncSP
 else len:=FUNC_STACK_SIZE;
 for i:=1 to len do begin
  tmp:=FuncStack[i];
  asm
   push dword [tmp]
  end;
  wsprintf(pOut,sITS);
  asm
   add esp,4*3
  end;
  lstrcat(pBuf,pOut);
 end;//of for   

 UserStream.typ:=StreamUserStream;
 UserStream.BufferSize:=lstrlen(pBuf);
 UserStream.Buffer:=pBuf;
 UserInfo.UserStreamCount:=1;
 UserInfo.UserStreamArray:=@UserStream;

 //������ ����-�����
 pMiniDumpWriteDump(GetCurrentProcess,GetCurrentProcessId,hFile,
                    MiniDumpNormal,@ExcInfo,@UserInfo,nil);

 //������������ ���������� ��������
 CloseHandle(hFile);
 VirtualFree(pBuf,16000,MEM_DECOMMIT);
End;

procedure RegisterExceptionHandler;
var hL,hDbgLib:integer;
Begin
 pAddVectoredExceptionHandler:=nil;
 pRemoveVectoredExceptionHandler:=nil;
 pVec:=nil;
 //1. ���������� ��������� ������ ���������� � ��������
 //��������� �� ��������� �������
 hL:=GetModuleHandle('kernel32.dll');
 hDbgLib:=LoadLibrary('dbghelp.dll');
 pAddVectoredExceptionHandler:=GetProcAddress(hL,'AddVectoredExceptionHandler');
 pRemoveVectoredExceptionHandler:=GetProcAddress(hL,'RemoveVectoredExceptionHandler');
 pMiniDumpWriteDump:=GetProcAddress(hDbgLib,'MiniDumpWriteDump');
 if (@pRemoveVectoredExceptionHandler=nil) or
    (@pAddVectoredExceptionHandler=nil) or
    (@pMiniDumpWriteDump=nil) then exit;

 //2. ���, ������� ����. ����� ����� �� ������������!
 pVec:=pAddVectoredExceptionHandler(0,@ExcFunc);
End;

procedure UnregisterExceptionHandler;
Begin
 if (@pRemoveVectoredExceptionHandler<>nil) and (pVec<>nil)
 then pRemoveVectoredExceptionHandler(pVec);
End;

//���� �������
procedure PushFunction(id:integer);
Begin
 inc(FuncSP);
 if FuncSP<FUNC_STACK_SIZE then FuncStack[FuncSP]:=id;
End;

procedure PopFunction;
Begin
 if FuncSP>0 then dec(FuncSP);
End;

initialization
 sModelName:='';
 iAnimEdMode:=-1;
 iEditorMode:=-1;
 IsAlwaysExc:=false;
 FuncSP:=0;
end.
