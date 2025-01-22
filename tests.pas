unit tests;
//������ �������� ������������ ����� ��� ��������
//����������������� ��������� ������ ����.
//� ��������� ������ ������ �����������, ����� �� �������
//�����.
interface
uses windows,SysUtils,classes,cabstract;

//0. ������ � ���-������.
procedure WriteError(s:string);
procedure CreateLogFile;
//1. ������������ ������ TKeyFramesList. ��� ������ - ���������.
function Test_TKeyFramesList:boolean;
//2. ������������ ������ TTan
function Test_TTan:boolean;
//=============================================
implementation
//0. ������ � ���-������
procedure CreateLogFile;
Var f:text;
Begin
 Assign(f,'errors.log');
 rewrite(f);
 close(f);
End;

procedure WriteError(s:string);
Var t:text;
Begin
 assign(t,'errors.log');
 append(t);
 writeln(t,s);
 CloseFile(t);
End;

//1. ������������ ������ TKeyFramesList. ��� ������ - ���������.
function Test_TKeyFramesList:boolean;
Var FramesList:TKeyFramesList;i:integer;
Begin
 WriteError(#09'������������ ������ TKeyFramesList...');
 Result:=false;
 FramesList:=TKeyFramesList.Create;  //������� ������ ������������ ������

 //�������� ���� ������ (��)
 for i:=0 to 100 do FramesList.Add(random(100000));
 for i:=0 to 10 do FramesList.Add(5);//��� �������� �������� ������������� ������

 //1. �������� ����������������� ������ ADD:
 //a. ������������ ������� - ������ ��������� ���� ������ �����������
 for i:=1 to FramesList.count-1
 do if FramesList.GetFrame(i-1)>=FramesList.GetFrame(i) then begin
  WriteError('������ � TKeyFramesList.Add: ������ �� ������������.');
  exit;
 end;//of if

 //b. ���� �� ������ (�� ������ ���� ���������� ������)
 if FramesList.count<100 then begin
  WriteError('������ � TKeyFramesList.Add: �� ��� ����� ����������.');
 end;//of if

 //2. 

 FramesList.Free;                 //���������� ������
End;
//----------------------------------------------------------
function Test_TTan:boolean;
Var Der:TTan;Delta:single;
Begin
 Der:=TTan.Create;
 Der.tang.InTan[1]:=-0.247255; Der.tang.InTan[2]:=0.239796; Der.tang.InTan[3]:=-0.653596; Der.tang.InTan[4]:=0.673925;
 Der.tang.OutTan[1]:=0.157356; Der.tang.OutTan[2]:=-0.0887205; Der.tang.OutTan[3]:=0.241819; Der.tang.OutTan[4]:=0.953358;
{// Der.bias:=0.8;
 Der.prev.Data[1]:=-4.19584; Der.prev.Data[2]:=-0.273535; Der.Prev.Data[3]:=-0.112648;
 Der.cur.Data[1]:=-3.42673; Der.cur.Data[2]:=-0.164121; Der.Cur.Data[3]:=-1.30025;
 Der.next.Data[1]:=0; Der.next.Data[2]:=0; Der.Next.Data[3]:=-6.28675;}
 Der.prev.Data[1]:=-0.3444380; Der.Prev.Data[2]:=0; Der.Prev.Data[3]:=0; Der.Prev.Data[4]:=0.938809;
 Der.cur.Data[1]:=-0.300034;Der.Cur.Data[2]:=0.169165;Der.Cur.Data[3]:=-0.461081;Der.cur.Data[4]:=0.817782;
 Der.next.Data[1]:=0;Der.next.Data[2]:=0;Der.next.Data[3]:=0;Der.next.data[4]:=1;
 Der.CalcSplineParameters(true,4);
// Der.CalcDerivativeXD(1);
 der.IsLogsReady:=false;
 Der.CalcDerivative4D;
 Delta:=abs(Der.tang.InTan[1]+0.247255)+
        abs(Der.tang.OutTan[1]-0.157356);
// MessageBox(0,PChar(floattostr(Delta)),'sdf',0);
 Der.Free;
 Result:=Delta<0.001;
End;
end.
