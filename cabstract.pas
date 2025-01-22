unit cabstract;
//������ �������� ����� �������, ��������������� ���
//������ � ��������� � �� ��������.
interface
uses classes,windows,SysUtils,mdlwork,OpenGL,math,crash;
const CLASS_ERROR='������ ��� ������ � ��������:'#13#10;
      FLG_GLOBAL=$80000000;
      FLG_ALLLINE=$FFFFFF;
Var
    AbsMinFrame,AbsMaxFrame:integer;
type

//�����: ������ �������� ������.
//������������ ��� ������������ ������� ���� ����� ������.
//������ ������ ������������ �� ����������� ������� ������
//� ������������� ������� � �� ���.
TKeyFramesList=class(TList)
 public
  //��������� �������� ���� (��� �����) �� ������� � ������
  function GetFrame(Index:integer):integer;
  //�������� ���������� (�� ��������� � ���������) ���� ��� 0
  function GetPrevFrame(Frame:integer):integer;
  //�������� ��������� (�� ��������� � ���������) ���� ��� $<...>
  function GetNextFrame(Frame:integer):integer;
  //���������� ������ �����, ���������� � Frame �� � ������ ������
  function GetNearestLEquFrameIndex(Frame:integer):integer;
  //��������� �� � ������. Frame ������ ���� ������ ����.
  procedure Add(Frame:integer);
end;//of type
//----------------------------------------------------------
//������������ ��� ��������/��������/��������������� ���� �����
TSceneView=class
 public
  Mat:TRotMatrix;             //������� ��������
  ax,ay,az:GLFloat;           //���� �������� �� ����
  tx,ty,tz:GLFloat;           //������ �� ����
  Zoom:GLFloat;               //�������
  Excentry:GLFloat;           //�������������� ������� ���������
  //�������� ��� �������� ������������ �������
  procedure Assign(Var src:TSceneView);
  //����� ���������� ������� (��������� ��������)
  procedure Reset;
  //������������� ��������� ��������� �����, �� �� �������������� �
  procedure ApplyView;
  //��������� ����������� �����
  procedure Translaton(DeltaX,DeltaY:GlFloat);
  //��������� ��������������� �����
  procedure Zooming(step:GLFloat);
  //��������� ������� �����
  procedure Rotation(StepX,StepY,StepZ:GLFloat);
end;//of type
//==========================================================
//������������ ��� ������� �������������� ������������ ��
TTan=class
 private
  ds:GLFloat;              //���������� (��� �������)
  qcur,logNNP,logNMN:TQuaternion;//��������� � ������� ���������� 
 public
  tang:TContItem;                 //��������� ���������
  bias,tension,continuity:GLFloat;//��������� �������
  prev,cur,next:TContItem;          //�������� � ��
  IsLogsReady:boolean;            //true, ���� ������ ���������
  //������ ����������� � ����� Cur (��� count �����)
  procedure CalcDerivativeXD(count:integer);
  //������ ���������� � ���������� Bias
  //� ������ ������� ��������, true->IsQuaternion
  procedure CalcWithConstBias(IsQuaternion:boolean;Count:integer);
  //������ ���������� ���������� (tension,continuity,bias)
  //�� ������ prev[1],cur[1],next[1]
  //� ������ ����������� ������������� ��� ������ cur,prev,next
  procedure CalcSplineParameters(IsQuaternion:boolean;count:integer);
  //������ ����������� � ����� Cur ��� �����������
  procedure CalcDerivative4D;
end;//of type
//==========================================================
//������������ ��� ������ � ��������������������
//(����� �������� ������)
TAnimPanel=class
 public
  SeqList:TStringList;            //������ ���� �������� (� �.�. ����������)
  Seq:TSequence;                  //��������� ������������������
  ids:cardinal;                   //� id
  MinF,MaxF:integer;              //������� �������� ��������
  ActSeqID:integer;               //ID "��������" ��������
  constructor Create;             //����������� �������
  procedure MakeAnimList;         //������� ������ ��������
  //���������� true, ���� id ����������� ����. ��������.
  //����������, ������������ ����� ������������ AND,
  //�.�. � ����. id ���������� ������� ���.
  function IsAnimGlob(id:cardinal):boolean;overload;
  function IsAnimGlob(id:pointer):boolean;overload;
  //�����. true, ���� ������ ����� "��� �������".
  //��������� - �� �����. id=$FFFF FFFF
  function IsAllLine(id:cardinal):boolean;overload;
  function IsAllLine(id:pointer):boolean;overload;
  //�������� � �������� ������� ������������������ id
  //��� ���� ����������� ������ ���� id, seq �
  //���������� UsingGlobalSeq
  procedure SelSeq(id:cardinal);overload;
  procedure SelSeq(id:pointer);overload;
  //���������� ������ ���������� ������ � ������ SeqList
  function GSelSeqIndex:integer;
  //���������� ����. �������� ����� (���. ��� ���������� AbsMaxFrame)
  //��� ����� ������������� IntervalEnd ��� ���� ������.
  function GAbsMaxFrame:integer;
  //���������� � ������� (���������) ������������������
  //������ �� Seq
  procedure SSeq;
  //��������� ����� �������� � ������ (������ �������������� ��������,
  //����� ����� ��������� ������ ���� �������� ��������).
  //���� IsGlobal=true, �������� ���������� ������.
  //ind - �������, � ������� ���������� �������.
  //����� ������ ����������� �� Seq.
  //���� ����������� ����. ��������, ��� ����� GlobalSeqId
  //� ������������
  procedure InsertSeq(IsGlobal:boolean;ind:integer);
  //�������� ���� �������, ���� (���� ������ id)
  //������ ��������� ������������������.
  //������� ��� ������� ������ (������ �� ������.)
  //��� �������� ����. �������� ��� ����� � ������������
  //(GlobalSeqId)
  procedure DelSeq(id:cardinal);overload;
  procedure DelSeq;overload;
  //���������� ID �������� �������� (�.�. �����, � �������
  //��������� ������� ����). �������� ��������� ��������
  //����� ������������� ������. ����������� ����� �������
  //��������
  function FindActSeq(Frame:integer):integer;
end;//of TAnimPanel

//==========================================================
implementation
uses MdlDraw;
//����� TKeyFramesList
//��������� �������� ���� (��� �����) �� ������� � ������
function TKeyFramesList.GetFrame(Index:integer):integer;
Begin
 Result:=0;
 if (index<0) or (index>=count)
 then Error(CLASS_ERROR+'TKeyFramesList.GetItem(%d)',index)
 else Result:=integer(items[index]);
End;

//----------------------------------------------------------

//���������� ������ �����, ���������� � Frame �� � ������ ������
function TKeyFramesList.GetNearestLEquFrameIndex(Frame:integer):integer;
Var i,ssStart,ssEnd,ssDelta,ssMid:integer;
Begin
 //���� ������ ������ � "��������" ��������.
 if Frame<0
 then Error(CLASS_ERROR+'TKeyFramesList.GetNearestLEquFrameIndex(%d)',Frame);

 //����� �������
 Result:=0;
 if count=0 then exit;
 PushFunction(191);

 ssStart:=0;            ssEnd:=count-1;
 ssDelta:=ssEnd-ssStart;ssMid:=(ssDelta shr 1)+ssStart;
 while ssDelta>5 do begin
    if Frame=integer(items[ssMid]) then begin
     Result:=ssMid;
     PopFunction;
     exit;
    end;
    if Frame<integer(items[ssMid]) then ssEnd:=ssMid else ssStart:=ssMid;
    ssDelta:=ssEnd-ssStart;
    ssMid:=(ssDelta shr 1)+ssStart;
 end;//of while

 for i:=ssEnd downto ssStart do begin
    if integer(items[i])<=Frame then begin
     Result:=i;
     PopFunction;
     exit;
    end;//of if
 end;//of for

 Result:=ssStart;
 PopFunction;
End;

//---------------------------------------------------------

//��������� �� � ������. Frame ������ ���� ������ ����.
procedure TKeyFramesList.Add(Frame:integer);
Var index:integer;
Begin
 //���� ������ ������ � "��������" ��������.
 if Frame<0 then Error(CLASS_ERROR+'TKeyFramesList.Add(%d)',Frame);
 if Frame<0 then exit;            //����� ����� ���������� �� ��������

 PushFunction(192);
 //������ �������� � AbsMaxFrame (���� ������� �� ����. ��������)
 if UsingGlobalSeq<0 then AbsMaxFrame:=Max(AbsMaxFrame,Frame);

 //���������� �������
 index:=GetNearestLEquFrameIndex(Frame);
 if index=count then inherited Add(pointer(Frame))
 else if GetFrame(index)>Frame
 then Insert(GetNearestLEquFrameIndex(Frame),pointer(Frame))
 else if GetFrame(index)<>Frame
 then Insert(GetNearestLEquFrameIndex(Frame)+1,pointer(Frame));
 PopFunction;
End;

//----------------------------------------------------------

//�������� ���������� (�� ��������� � ���������) ����
function TKeyFramesList.GetPrevFrame(Frame:integer):integer;
Var index:integer;
Begin
 Result:=0;
 if count=0 then exit;
 index:=GetNearestLEquFrameIndex(Frame);
 if GetFrame(index)=Frame then dec(index);
 if index<0 then exit else Result:=GetFrame(index);
End;

//�������� ��������� (�� ��������� � ���������) ����
function TKeyFramesList.GetNextFrame(Frame:integer):integer;
Var index:integer;
Begin
 //1. �������� �� �������������� ����� � ������
 Result:=$7000FFFF;               //���������� ������� �����
 if count=0 then exit;
 if integer(items[0])>Frame then begin
  Result:=GetFrame(0);
  exit;
 end;//of if
 index:=GetNearestLEquFrameIndex(Frame)+1;
 if index>=count then exit else Result:=GetFrame(index);
End;

//==========================================================

//�������� ��� �������� ������������ �������
procedure TSceneView.Assign(Var src:TSceneView);
Begin
 Mat:=src.Mat;
 ax:=src.ax;    ay:=src.ay;     az:=src.az;
 tx:=src.tx;    ty:=src.ty;     tz:=src.tz;
 Zoom:=src.Zoom;
 Excentry:=src.Excentry;
End;

//----------------------------------------------------------

//����� ���������� ������� (��������� ��������)
procedure TSceneView.Reset;
Begin
 PushFunction(193);
 Mat[0,0]:=1;Mat[0,1]:=0;Mat[0,2]:=0;
 Mat[1,0]:=0;Mat[1,1]:=1;Mat[1,2]:=0;
 Mat[2,0]:=0;Mat[2,1]:=0;Mat[2,2]:=1;
 ax:=180;    ay:=0;      az:=0;
 tx:=0;      ty:=0;      tz:=0;
 Zoom:=0.99;
 ApplyView;
 PopFunction;
End;

//----------------------------------------------------------

//������������� ��������� ��������� �����, �� �� �������������� �
procedure TSceneView.ApplyView;
Begin
  PushFunction(194);
  glMatrixMode(gl_projection);    //������� ������
  glLoadIdentity;                //��������� ���������
  //���������� �������
  if Zoom<1 then glScalef(Zoom*1/200/Excentry,Zoom*1/200,Zoom*1/500)
  else glScalef(Zoom*1/200/Excentry,Zoom*1/200,1/4000);
  glTranslatef(tx,ty,tz);         //�������
  glRotatef(ax,1.0,0,0);          //�������
  glMatrixMode(gl_modelview);     //������� ����
  glLoadIdentity;
  glRotatef(ay,0,1.0,0);
  glRotatef(az,0,0,1.0);
  PopFunction;
End;

//----------------------------------------------------------

//��������� ����������� �����
procedure TSceneView.Translaton(DeltaX,DeltaY:GlFloat);
Begin
 PushFunction(195);
 tx:=tx+DeltaX/Zoom;
 ty:=ty+DeltaY/Zoom;
 if tx<-20000 then tx:=-20000;
 if tx>20000 then tx:=20000;
 if ty<-20000 then ty:=-20000;
 if ty>20000 then ty:=20000;
 ApplyView;
 PopFunction;
End;

//----------------------------------------------------------

//��������� ��������������� �����
procedure TSceneView.Zooming(step:GLFloat);
Begin
 PushFunction(196);
 Zoom:=Zoom+0.01*Zoom*step;//����� �������
 if Zoom<0.001 then Zoom:=0.001; //��������
 if Zoom>1000 then Zoom:=1000;   //��������
 ApplyView;
 PopFunction;
End;

//----------------------------------------------------------

//��������� ������� �����
procedure TSceneView.Rotation(StepX,StepY,StepZ:GLFloat);
Begin
 PushFunction(197);
 az:=az+StepZ;
 ay:=ay+StepY; //���������� ����
 ax:=ax+StepX; //���������� ����
 if ay<0 then ay:=ay+360;  //��������
 if ay>360 then ay:=ay-360;
 if ax<0 then ax:=ax+360;  //��������
 if ax>360 then ax:=ax-360;
 if az<0 then az:=az+360;  //��������
 if az>360 then az:=az-360;
 ApplyView;
 PopFunction;
End;

//==========================================================
//������ ����������� � ����� Cur (��� count �����)
procedure TTan.CalcDerivativeXD(count:integer);
Var g1,g2,g3,g4:GLFloat;i:integer;
Begin
 PushFunction(198);
 for i:=1 to Count do begin
  g1:=(1-tension)*(1-continuity)*(1+bias)*0.5;
  g2:=(1-tension)*(1+continuity)*(1-bias)*0.5;
  g3:=(1-tension)*(1+continuity)*(1+bias)*0.5;
  g4:=(1-tension)*(1-continuity)*(1-bias)*0.5;
  tang.InTan[i]:=g1*(cur.Data[i]-prev.Data[i])+g2*(next.Data[i]-cur.Data[i]);
  tang.OutTan[i]:=g3*(cur.Data[i]-prev.Data[i])+g4*(next.Data[i]-cur.Data[i]);
 end;//of for i
 PopFunction;
End;
//----------------------------------------------------------
//������ ���������� � ���������� Bias
//� ������ ������� ��������, true->IsQuaternion
procedure TTan.CalcWithConstBias(IsQuaternion:boolean;Count:integer);
Var cMin,tMin,cCur,tCur,Delta,
    cCurBeg,cCurEnd,tCurBeg,tCurEnd,step:GLFloat;
    tang2:TContItem;
    i:integer;
Begin
 PushFunction(199);
 //�������� ���������
 tang2:=tang;
 cMin:=0; tMin:=0;
 ds:=1e6;

 //�������� �������� ������� 1-�� �������
 step:=0.1;
 tCurBeg:=-1; tCurEnd:=1;
 cCurBeg:=-1; cCurEnd:=1;
 while step>0.001 do begin
  cCur:=cCurBeg;
  repeat
   tCur:=tCurBeg;
   repeat
    continuity:=cCur;
    tension:=tCur;
    if IsQuaternion then begin
     CalcDerivative4D;
     Delta:=abs(tang.OutTan[1]-tang2.OutTan[1])+
            abs(tang.OutTan[2]-tang2.OutTan[2])+
            abs(tang.OutTan[3]-tang2.OutTan[3])+
            abs(tang.OutTan[4]-tang2.OutTan[4])+
            abs(tang.InTan[1]-tang2.InTan[1])+
            abs(tang.InTan[2]-tang2.InTan[2])+
            abs(tang.InTan[3]-tang2.InTan[3])+
            abs(tang.InTan[4]-tang2.InTan[4]);
    end else begin
     CalcDerivativeXD(Count);
     Delta:=0;
     for i:=1 to count do begin
     Delta:=Delta+abs(tang.OutTan[i]-tang2.OutTan[i])+
            abs(tang.InTan[i]-tang2.InTan[i]);
     end;//of for i
    end;//of else
    if Delta<ds then begin
     ds:=Delta;
     cMin:=cCur;
     tMin:=tCur;
    end;//of if
    tCur:=tCur+step;
   until tCur>tCurEnd;
   cCur:=cCur+step;
  until cCur>cCurEnd;
  cCurBeg:=cMin-step; if cCurBeg<-1 then cCurBeg:=-1;
  cCurEnd:=cMin+step; if cCurEnd>1 then cCurEnd:=1;
  tCurBeg:=tMin-step; if tCurBeg<-1 then tCurBeg:=-1;
  tCurEnd:=tMin+step; if tCurEnd>1 then tCurEnd:=1;
  step:=step*0.1;
 end;//of while

 //�������!
 continuity:=cMin;
 tension:=tMin;
 tang:=tang2;
 PopFunction;
End;
//----------------------------------------------------------
//������ ���������� ���������� �� �����������.
procedure TTan.CalcSplineParameters(IsQuaternion:boolean;count:integer);
Var bMid,bStart,bEnd,vStart,vEnd,Delta:GLFloat;
Begin
 PushFunction(200);
 bStart:=-1;
 bEnd:=1;
 IsLogsReady:=false;
 repeat
  bMid:=(bEnd-bStart)*0.5+bStart;

  bias:=bStart;
  CalcWithConstBias(IsQuaternion,count);
  vStart:=ds;

  bias:=bEnd;
  CalcWithConstBias(IsQuaternion,count);
  vEnd:=ds;

  if vStart<vEnd then bEnd:=bMid else bStart:=bMid;
  Delta:=abs(bStart-bEnd);
 until Delta<0.0001;
 bias:=bMid;
 PopFunction;
End;
//----------------------------------------------------------
//������ ����������� � ����� Cur ��� �����������
//���� ��������� ��� ������, ��� �� �����������������
procedure TTan.CalcDerivative4D;
Var qprev,qnext,q:TQuaternion;
    g1,g2,g3,g4:GLFloat;
Begin
 PushFunction(201);
 //1. ���������� ��������� (���� �����)
 if not IsLogsReady then begin
  //���������� ������������
  qcur.x:=cur.Data[1];
  qcur.y:=cur.Data[2];
  qcur.z:=cur.Data[3];
  qcur.w:=cur.Data[4];

  qprev.x:=prev.Data[1];
  qprev.y:=prev.Data[2];
  qprev.z:=prev.Data[3];
  qprev.w:=prev.Data[4];

  qnext.x:=next.Data[1];
  qnext.y:=next.Data[2];
  qnext.z:=next.Data[3];
  qnext.w:=next.Data[4];

  //������
  GetInverseQuaternion(qcur,logNNP);
  MulQuaternions(logNNP,qnext,logNNP);
  CalcLogQ(logNNP);
  GetInverseQuaternion(qprev,logNMN);
  MulQuaternions(logNMN,qcur,logNMN);
  CalcLogQ(logNMN);
  IsLogsReady:=true;              //������!
 end;//of if

 g1:=(1-tension)*(1+continuity)*(1-bias)*0.5;
 g2:=(1-tension)*(1-continuity)*(1+bias)*0.5;
 g3:=(1-tension)*(1-continuity)*(1-bias)*0.5;
 g4:=(1-tension)*(1+continuity)*(1+bias)*0.5;
 tang.InTan[1]:=g1*LogNNP.x+g2*LogNMN.x;
 tang.OutTan[1]:=g3*LogNNP.x+g4*LogNMN.x;
 tang.InTan[2]:=g1*LogNNP.y+g2*LogNMN.y;
 tang.OutTan[2]:=g3*LogNNP.y+g4*LogNMN.y;
 tang.InTan[3]:=g1*LogNNP.z+g2*LogNMN.z;
 tang.OutTan[3]:=g3*LogNNP.z+g4*LogNMN.z;

 //������ a-���������
 q.x:=0.5*(tang.OutTan[1]-logNNP.x);
 q.y:=0.5*(tang.OutTan[2]-logNNP.y);
 q.z:=0.5*(tang.OutTan[3]-logNNP.z);
 CalcExpQ(q);
 MulQuaternions(qcur,q,q);
 tang.OutTan[1]:=q.x;     //??????????
 tang.OutTan[2]:=q.y;
 tang.OutTan[3]:=q.z;
 tang.OutTan[4]:=q.w;

 //������ b-���������
 q.x:=0.5*(logNMN.x-tang.InTan[1]);
 q.y:=0.5*(logNMN.y-tang.InTan[2]);
 q.z:=0.5*(logNMN.z-tang.InTan[3]);
 CalcExpQ(q);
 MulQuaternions(qcur,q,q);
 tang.InTan[1]:=q.x;     //??????????
 tang.InTan[2]:=q.y;
 tang.InTan[3]:=q.z;
 tang.InTan[4]:=q.w;

 //2-� ������� ������� (gemo.design)
{ g1:=prev;Slerp(-(1+bias)/3.0,cur,g1);
 g2:=next;Slerp(1-bias)/3.0,cur,g2);
 g3:=g2;Slerp(0.5+0.5*continuity,g1,g3);
 g4:=g2;Slerp(0.5-0.5*continuity,g1,g4);
 tang.InTan:=g3;Slerp((tension-1),}
 PopFunction;
End;
//==========================================================
//������������� ������� (��� ����. ��������)
function GlobAnSort(List:TStringList;Index1,Index2:Integer):Integer;
Begin
 Result:=strtoint(List[index1])-strtoint(List[index2]);
End;
//----------------------------------------------------------
constructor TAnimPanel.Create;             //����������� �������
Begin
 SeqList:=TStringList.Create;
 ids:=FLG_ALLLINE;                          //��� �������
End;
//----------------------------------------------------------
//������� ������ �������� (� SeqList)
procedure TAnimPanel.MakeAnimList;
Var i:integer; lst:TStringList;
Begin
 SeqList.Clear;
 lst:=TStringList.Create;
 lst.Clear;

 for i:=0 to CountOfGlobalSequences-1
 do lst.AddObject(inttostr(GlobalSequences[i]),pointer(i+$80000000));
 lst.CustomSort(GlobAnSort);

 for i:=0 to CountOfSequences-1
 do SeqList.AddObject(Sequences[i].Name,pointer(i));
// SeqList.Sort;
 SeqList.AddStrings(lst);
 SeqList.InsertObject(0,'��� �������',pointer(FLG_ALLLINE));

 lst.Free;
End;
//----------------------------------------------------------

//���������� true, ���� id ����������� ����. ��������.
//����������, ������������ ����� ������������ AND,
//�.�. � ����. id ���������� ������� ���.
function TAnimPanel.IsAnimGlob(id:cardinal):boolean;
Begin
 Result:=(id and $80000000)<>0;
End;
function TAnimPanel.IsAnimGlob(id:pointer):boolean;
Begin
 Result:=IsAnimGlob(cardinal(id));
End;
//----------------------------------------------------------

//�����. true, ���� ������ ����� "��� �������".
//��������� - �� �����. id=$FFFF FFFF
function TAnimPanel.IsAllLine(id:cardinal):boolean;
Begin
 Result:=id=FLG_ALLLINE;
End;
function TAnimPanel.IsAllLine(id:pointer):boolean;
Begin
 Result:=IsAllLine(cardinal(id));
End;
//----------------------------------------------------------

//�������� � �������� ������� ������������������ id
//��� ���� ����������� ������ ���� id, seq
procedure TAnimPanel.SelSeq(id:cardinal);
Begin
 ids:=id;
 UsingGlobalSeq:=-1;
 if IsAllLine(id) then begin
  Seq.Name:='��� �������';
  Seq.IntervalStart:=0;
  exit;
 end;
 if IsAnimGlob(id) then begin
  Seq.IntervalStart:=0;
  Seq.IntervalEnd:=GlobalSequences[id and $FFFFFF];
  Seq.Name:=inttostr(Seq.IntervalEnd);
  UsingGlobalSeq:=id and $FFFFFF;
 end else Seq:=Sequences[id];
End;
procedure TAnimPanel.SelSeq(id:pointer);
Begin
 SelSeq(cardinal(id));
End;
//----------------------------------------------------------

//���������� ������ ���������� ������ � ������ SeqList
function TAnimPanel.GSelSeqIndex:integer;
Begin
 Result:=SeqList.IndexOfObject(pointer(ids));
End;
//----------------------------------------------------------

//���������� � ������� (���������) ������������������
//������ �� Seq
procedure TAnimPanel.SSeq;
Begin
 if IsAllLine(ids) then exit;
 if IsAnimGlob(ids) then GlobalSequences[ids and $FFFFFF]:=Seq.IntervalEnd
 else Sequences[ids]:=Seq;
End;
//----------------------------------------------------------

//��������� ����� �������� � ������ (������ �������������� ��������,
//����� ����� ��������� ������ ���� �������� ��������).
//���� IsGlobal=true, �������� ���������� ������.
//ind - �������, � ������� ���������� �������.
//����� ������ ����������� �� Seq.
procedure TAnimPanel.InsertSeq(IsGlobal:boolean;ind:integer);
Var i,j:integer;
Begin
 if IsGlobal then begin
  inc(CountOfGlobalSequences);
  SetLength(GlobalSequences,CountOfGlobalSequences);
  for i:=CountOfGlobalSequences-2 downto ind
  do GlobalSequences[i+1]:=GlobalSequences[i];
  GlobalSequences[ind]:=Seq.IntervalEnd;

  //����� GlobalSeqId � ������������
  for i:=0 to High(Controllers) do if Controllers[i].GlobalSeqId>=ind
  then inc(Controllers[i].GlobalSeqId);
 end else begin
  //������� ������ Anim �� ��� ����������� (���� �����)
  for j:=0 to CountOfGeosets-1 do with Geosets[j]
  do if CountOfAnims=CountOfSequences then begin
   inc(CountOfAnims);
   SetLength(Anims,CountOfAnims);
   for i:=CountOfAnims-2 downto ind do Anims[i+1]:=Anims[i];
   CalcBounds(j,Anims[ind]);

   if Seq.Bounds.MinimumExtent[1]>Anims[ind].MinimumExtent[1]
   then Seq.Bounds.MinimumExtent[1]:=Anims[ind].MinimumExtent[1];
   if Seq.Bounds.MinimumExtent[2]>Anims[ind].MinimumExtent[2]
   then Seq.Bounds.MinimumExtent[2]:=Anims[ind].MinimumExtent[2];
   if Seq.Bounds.MinimumExtent[3]>Anims[ind].MinimumExtent[3]
   then Seq.Bounds.MinimumExtent[3]:=Anims[ind].MinimumExtent[3];

   if Seq.Bounds.MaximumExtent[1]<Anims[ind].MaximumExtent[1]
   then Seq.Bounds.MaximumExtent[1]:=Anims[ind].MaximumExtent[1];
   if Seq.Bounds.MaximumExtent[2]<Anims[ind].MaximumExtent[2]
   then Seq.Bounds.MaximumExtent[2]:=Anims[ind].MaximumExtent[2];
   if Seq.Bounds.MaximumExtent[3]<Anims[ind].MaximumExtent[3]
   then Seq.Bounds.MaximumExtent[3]:=Anims[ind].MaximumExtent[3];
  end;//of for j

  //��������� ���� ������������������
  inc(CountOfSequences);
  SetLength(Sequences,CountOfSequences);
  for i:=CountOfSequences-2 downto ind do Sequences[i+1]:=Sequences[i];
  Sequences[ind]:=Seq;
 end;//of if
End;
//----------------------------------------------------------

//�������� ���� �������, ���� (���� ������ id)
//������ ��������� ������������������.
//������� ��� ������� ������ (������ �� ������.)
procedure TAnimPanel.DelSeq(id:cardinal);
Var i,j:integer;ind:cardinal;
Begin
 if IsAllLine(id) then exit;
 if IsAnimGlob(id) then begin
  ind:=id and $FFFFFF;
  for i:=ind to CountOfGlobalSequences-2
  do GlobalSequences[i]:=GlobalSequences[i+1];
  dec(CountOfGlobalSequences);
  SetLength(GlobalSequences,CountOfGlobalSequences);

  //����� ID � ������������
  for i:=0 to High(Controllers) do begin
   if Controllers[i].GlobalSeqId=ind then Controllers[i].GlobalSeqId:=-1;
   if Controllers[i].GlobalSeqId>ind then dec(Controllers[i].GlobalSeqId);
  end;//of for i
 end else begin
  for i:=id to CountOfSequences-2 do Sequences[i]:=Sequences[i+1];
  dec(CountOfSequences);
  SetLength(Sequences,CountOfSequences);

  //������� Anim-������
  for j:=0 to CountOfGeosets-1 do with Geosets[j]
  do if id<CountOfAnims then begin
   for i:=id to CountOfAnims-2 do Anims[i]:=Anims[i+1];
   dec(CountOfAnims);
   SetLength(Anims,CountOfAnims);
  end;//of if/with/for j
 end;//of if
End;

procedure TAnimPanel.DelSeq;
Begin
 DelSeq(ids);
End;
//----------------------------------------------------------

//���������� ����. �������� ����� (���. ��� ���������� AbsMaxFrame)
//��� ����� ������������� IntervalEnd ��� ���� ������.
function TAnimPanel.GAbsMaxFrame:integer;
Var i:integer;
Begin
 Result:=0;
 for i:=0 to CountOfSequences-1 do if Sequences[i].IntervalEnd>Result
 then Result:=Sequences[i].IntervalEnd;
End;
//----------------------------------------------------------

//���������� ID �������� �������� (�.�. �����, � �������
//��������� ������� ����). �������� ��������� ��������
//����� ������������� ������. ����������� ����� �������
//��������
function TAnimPanel.FindActSeq(Frame:integer):integer;
Var i:integer;
Begin
 Result:=-1;
 for i:=0 to CountOfSequences-1
 do if (Sequences[i].IntervalStart<=Frame) and (Sequences[i].IntervalEnd>=Frame)
 then begin
  Result:=i;
  MinF:=Sequences[i].IntervalStart;
  MaxF:=Sequences[i].IntervalEnd;
  ActSeqID:=i;
  exit;
 end;//of if/for
End;
end.
