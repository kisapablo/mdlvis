unit guic;
//�������� ����� GUI-������ (������������ ��� �����������
//����������, ������� ��������������� � �������).
interface
uses classes,cabstract,windows,mdlwork,crash;
const ADD_RESTRICT=true;
      REMOVE_RESTRICT=false;
      CIRCLE_SECTORS=40;         //���-�� �������� ������� �� ���������� ������

//�����: ������ ������� �����������.
//������������ ��� ��������� � ����������� ������������.
type TContrProps=class
 public
  id:integer;                     //id ��������� �����������
  IsVisible:boolean;              //true, ����� ������ ������ ���� ������
  OnlyOnOff:boolean;              //������� ����������� ���������
  //������������� ����� ���������� � ��������� ID,
  //������ ��������� ������ ������������� �������,
  //� ����� ������ ��� ������ �������
  procedure SetCaptionAndId(sObj,sKind:string;ContId:integer);
  //��������� �������� ������ ������� �����������
  procedure Hide;
  //������������� ����� ��� ��������� �����������
  procedure SetFilter;
  //������� ������� ���������� (������ �� ���� � ��������
  //����� ������� ��������!)
  procedure DeleteController;
{  //���������� ����� ���� ����������� (� ���������� ��)
  procedure ChangeType(NewType:integer);}
end;
//----------------------------------------------------------
//������������ ��� �������� ��������
TObjAnimate=class
 private
  av:array of TVertex;            //��� ���������� �������� ��������
  am:array of TRotMatrix;         //��� ���������� ������ ��������
  az:array of TVertex;            //��� ���������� ���������� ����������
  RotRestrict,ScRestrict,MoveRestrict:TList; //������ �������� � �������������
  Tan:TTan;                       //��� ������� ������. ������������
  //����������: ��������� ������� ��������
  //� ������������� �� ��������
  procedure MemorizeObjVectors;
  //��������� ������� �������� � ������������� �� ��������
  procedure MemorizeObjMatrices;
  //��������� ���������� ��������� �������� � ������������� �� ���������������
  procedure MemorizeObjScales;
  //���������� ��������� ��� ����������� ������������� �������
  //� ���������� ������� (x,y,z)
  procedure InternalMove(id:integer;x,y,z:single);
  //���������� �������� ������������� ������� � �������,
  //�������� ������������ q
  procedure InternalRotate(id:integer;q:TQuaternion);
  //��������� ����������� �������� ��� ���������� �������
  procedure InternalScale(id:integer;sx,sy,sz:single);
  //���������� ������� ��� �������� ���. �������
  //� �������� ������
  function AbsVectorToTranslation(b:TBone;v:TVertex):TVertex;
  //��������� ���. ���������� �������� ������� �
  //�������� �������� (rotation-����������).
  function AbsQToRotation(b:TBone;q:TQuaternion):TQuaternion;
  //�������������� �-�� ���� ��������
  procedure CalcObjCoords;
 public
  SplineUsed:boolean;             //���� true - ������ �������. ������������
                                  //��� ��������� �� 
  constructor Create;             //����������� �������
  //������������� t,c � b ��� ������� �������������� ������������
  procedure SetTCB(t,c,b:single);
  procedure ClearRestricts;       //�������� ������ �����������
  procedure SaveUndo;             //���������� ������ ��������+���������� 
  //�������, �����������, ���� �� � ������� ID
  //��������� �����������
  function IsRotRestrict(id:integer):boolean;
  function IsMoveRestrict(id:integer):boolean;
  function IsScRestrict(id:integer):boolean;
  //��������/������� ��������������� ����������� �������
  procedure SetRotRestrict(id:integer;IsAdd:boolean);
  procedure SetMoveRestrict(id:integer;IsAdd:boolean);
  procedure SetScRestrict(id:integer;IsAdd:boolean);
  //������� ������� ������ �� ��������� ��������,
  //�������� ����� �� ��� ������� ������.
  //��� ������� � ������������ �� �������� �� ���������
  procedure Move(dx,dy,dz:single);
  //������������ ������� ������ �� ��������� ���-�� ��������.
  //������� �������������� �� ��. ��������� ��������.
  //��������� ���� ������ ���� �������� (��� �������� � 0).
  procedure Rotate(dax,day,daz:single);
  //������������ ������� ������
  //(��������� ��������� ���������� ���������)
  procedure Scale(sx,sy,sz:single);
  //���������� ������������� ���������� ���������� ���������
  //��� ������� (� ������ ���� ������������)
  procedure GetAbsScale(id:integer;var sx,sy,sz:single);
end;//of TObjAnimate
//----------------------------------------------------------
//�����, ��������������� ��� ��������� ������ ������� �������
TSpline=class
 private
  ID:integer;                     //id �������� �����������
  Der:TTan;                       //������ ������� ���������
  cdc:hDC;                        //����� ������ � ������
 public
  IsVisible:boolean;              //true, ����� ������ ������ ���� ������
  //����������� �������
  constructor Create;
  //�������������� ������ �� �� ���������� �����������
  //�� ������ �� CurFrame.
  //���� ������ 1-� ��� ��������� ����, �� ������ ��������.
  procedure InitFromKF(contID:integer);
  //������ ������
  procedure Hide;
  //�������� ������
  procedure Render;
  //����������� ������� ��������
  procedure Repaint;
  //���������� TCB
  procedure GetTCB(var t,c,b:single);
  //��������� TCB ��������������� � ���������� (� ����)
  procedure SetTCB(t,c,b:single);
end;//of TSpline
//----------------------------------------------------------
TWorkPlane=class                  //������������/��������� ������� ���������.
 private
  SumXY,SumXZ,SumYZ:single;
  IndStartXY,IndStartXZ,IndStartYZ:integer; //��������� ������� ��������� �����
  CircleXY,CircleXZ,CircleYZ:array [0..CIRCLE_SECTORS] of TVertex;
  AbsXY,AbsXZ,AbsYZ:array [0..CIRCLE_SECTORS,1..3] of Double;
  //���������� ������� � ������������ ���. ��������
  //�����, ��������� � (x,y)
  procedure FindNearestPoint(x,y:integer;var indXY,indXZ,indYZ:integer);
  procedure RenderQuad;           //��������� �������� ���������
  procedure BeginRender;          //������ ����������
  procedure EndRender;            //��������� ����������
  //�� ������ ������������� ������ � ������������� �-� ������
  //������������ ���������� �����
  procedure CalcAbsCircles;
 public
  constructor Create;
  procedure Find(x,y:integer;Shift:TShiftState); //���������� �����
  //����� ���. ��������� ��� ����������� "��������".
  //������������ �������� ���������� �����
  procedure FindRot(x,y:integer);
  //�������������� ������ � ��������� ��������.
  //������ ���������� ����� ������� ������������ ��������,
  //���-������ � BeginRot
  procedure PrepareForRotation(x,y:integer);
  //���������� ���� �������� ������ �����. ��� (+/-)
  procedure FindAngles(x,y,OldMouseX,OldMouseY:integer;var dax,day,daz:single);
end;//of TWorkPlane
//----------------------------------------------------------
//�����, ������������ ��� �������� ��������
TNInstrum=class
 private
  VList:TList;
 public
  constructor Create;
  procedure SetRotInstrum;       //������������ ��� ��������� �����������
  //������������ ������� ��������.
  //������� ��� ������ ������ ����� �� ���� -
  //� ����������� �� ����, ����� ���� �� ����� 0
  procedure Rotate(dax,day,daz:single);
end;//of TNInstrum
//----------------------------------------------------------
//����������� ������������ ������������ ������
//TGAnimPanel=class
//----------------------------------------------------------
implementation
uses frmmain,graphics,sysutils,mdldraw,controls,objedut,opengl;

//�������������� �-�� ���� ��������
procedure TObjAnimate.CalcObjCoords;
Var i:integer;
Begin
 PushFunction(202);
 //1. �������� ������ ���������� ��� ����� �������
 //�. ���������� ��� �������� �������
 for i:=0 to CountOfHelpers-1 do InterpTBone(CurFrame,Helpers[i]);
 for i:=0 to CountOfBones-1 do InterpTBone(CurFrame,Bones[i]);
 for i:=0 to CountOfAttachments-1 do InterpTBone(CurFrame,Attachments[i].Skel);
 for i:=0 to CountOfParticleEmitters-1 do InterpTBone(CurFrame,pre2[i].Skel);
 //�. ������ ��������� ��������
 for i:=0 to CountOfHelpers-1 do CalcTBone(CurFrame,Helpers[i]);
 for i:=0 to CountOfBones-1 do CalcTBone(CurFrame,Bones[i]);
 for i:=0 to CountOfAttachments-1 do CalcTBone(CurFrame,Attachments[i].Skel);
 for i:=0 to CountOfParticleEmitters-1 do CalcTBone(CurFrame,pre2[i].Skel);
 PopFunction;
End;
//----------------------------------------------------------

//���������� ������� ��� �������� ���. �������
//� �������� ������
function TObjAnimate.AbsVectorToTranslation(b:TBone;v:TVertex):TVertex;
Var Parent:TBone;
    m:TRotMatrix;
    Det,DetX,DetY,DetZ:single;
Begin
 Result:=v;
 PushFunction(203);

 //0. �������� ��������
 if b.Parent>=0 then begin
  Parent:=GetSkelObjectByID(b.Parent);

  //1. ������� ������������ ������ ��������
  Result[1]:=v[1]-Parent.AbsVector[1];
  Result[2]:=v[2]-Parent.AbsVector[2];
  Result[3]:=v[3]-Parent.AbsVector[3];

  //2. ��������� �������� �������������� � �������
  //������������ ������� ��������
  m:=Parent.AbsMatrix;
  Det:=GetDeterminant(m);          //������������ �������
  m[0,0]:=Result[1];
  m[0,1]:=Result[2];
  m[0,2]:=Result[3];               //��������� �������
  DetX:=GetDeterminant(m);
  m:=Parent.AbsMatrix;
  m[1,0]:=Result[1];
  m[1,1]:=Result[2];
  m[1,2]:=Result[3];
  DetY:=GetDeterminant(m);
  m:=Parent.AbsMatrix;
  m[2,0]:=Result[1];
  m[2,1]:=Result[2];
  m[2,2]:=Result[3];
  DetZ:=GetDeterminant(m);
  if Det=0 then Det:=1;           //������
  Result[1]:=DetX/Det;
  Result[2]:=DetY/Det;
  Result[3]:=DetZ/Det;

  //3. ��������� �-�� ������������� ����. ������ (PivotPoint)
  Result[1]:=Result[1]+PivotPoints[Parent.ObjectID,1];
  Result[2]:=Result[2]+PivotPoints[Parent.ObjectID,2];
  Result[3]:=Result[3]+PivotPoints[Parent.ObjectID,3];
 end;//of if

 //3. ������ �-�� ������������ ��������������� ������ (PivotPoint)
 Result[1]:=Result[1]-PivotPoints[b.ObjectID,1];
 Result[2]:=Result[2]-PivotPoints[b.ObjectID,2];
 Result[3]:=Result[3]-PivotPoints[b.ObjectID,3];
 PopFunction;
End;
//----------------------------------------------------------
//��������� ���. ���������� �������� ������� �
//�������� �������� (rotation-����������).
function TObjAnimate.AbsQToRotation(b:TBone;q:TQuaternion):TQuaternion;
Var bp:TBone; //qt:TQuaternion; sn,n:GLFloat;
Begin
 PushFunction(204);
 //Parent^-1*Parent*Child=Parent^-1*N=child
 if b.Parent<0 then begin
  Result.x:=0;
  Result.y:=0;
  Result.z:=0;
  Result.w:=1;
 end else begin
  bp:=GetSkelObjectById(b.Parent);
  MatrixToQuaternion(bp.AbsMatrix,Result);
 end;//of if
 GetInverseQuaternion(Result,Result);
 MulQuaternions(Result,q,Result);
 PopFunction;
End;
//----------------------------------------------------------
//����������: ��������� ������� ��������
//� ������������� �� ��������
procedure TObjAnimate.MemorizeObjVectors;
Var i:integer; b:TBone;
Begin
 PushFunction(205);
 SetLength(av,MoveRestrict.Count);
 for i:=0 to MoveRestrict.Count-1 do begin
  b:=GetSkelObjectById(integer(MoveRestrict.Items[i]));
  av[i]:=b.AbsVector;
 end;//of for i
 PopFunction;
End;
//----------------------------------------------------------
//��������� ������� �������� � ������������� �� ��������
procedure TObjAnimate.MemorizeObjMatrices;
Var i:integer; b:TBone;
Begin
 PushFunction(206);
 SetLength(am,RotRestrict.Count);
 for i:=0 to RotRestrict.Count-1 do begin
  b:=GetSkelObjectById(integer(RotRestrict.Items[i]));
  am[i]:=b.AbsMatrix;
 end;//of for i
 PopFunction;
End;
//----------------------------------------------------------
//��������� ���������� ��������� �������� � ������������� �� ���������������
procedure TObjAnimate.MemorizeObjScales;
Var i:integer;
Begin
 PushFunction(207);
 SetLength(az,ScRestrict.Count);
 for i:=0 to ScRestrict.Count-1 do begin
  GetAbsScale(integer(ScRestrict.Items[i]),az[i,1],az[i,2],az[i,3]);
 end;//of for i
 PopFunction;
End;
//----------------------------------------------------------
//���������� ��������� ��� ����������� ������������� �������
//� ���������� ������� x,y,z
//���, ���� �����, ������ ���������� Transtation
//��� ������������� ������� � ��������� ���� ��������� ��
procedure TObjAnimate.InternalMove(id:integer;x,y,z:single);
Var b:TBone; len:integer; it:TContItem; v:TVertex;
Begin
 PushFunction(208);
 b:=GetSkelObjectById(id);
 v[1]:=x; v[2]:=y; v[3]:=z;

 it.Frame:=CurFrame;
 v:=AbsVectorToTranslation(b,v);
 it.Data[1]:=v[1];  it.InTan[1]:=v[1]; it.OutTan[1]:=v[1];
 it.Data[2]:=v[2];  it.InTan[2]:=v[2]; it.OutTan[2]:=v[2];
 it.Data[3]:=v[3];  it.InTan[3]:=v[3]; it.OutTan[3]:=v[3];

 // ���� �����, ������� ����������
 if b.Translation<0 then begin
  len:=length(Controllers);
  SetLength(Controllers,len+1);
  b.Translation:=CreateController(id,it,ctTranslation);
  Controllers[b.Translation].ContType:=Linear;
  Controllers[b.Translation].GlobalSeqId:=UsingGlobalSeq;
  SetObjSkelPart(b);
 end else begin
  len:=length(Controllers[b.Translation].Items);
  if (Controllers[b.Translation].ContType=Hermite) and SplineUsed then begin
   Tan.Prev:=LookBack(Controllers[b.Translation],CurFrame,
                      MinFrame,MaxFrame,len);
   Tan.cur:=it;
   Tan.next:=LookForward(Controllers[b.Translation],CurFrame,
                         MinFrame,MaxFrame,len);
   if (Tan.Prev.Frame>=0) and (Tan.Next.Frame>=0) then begin
    Tan.CalcDerivativeXD(3);
    it.InTan[1]:=Tan.tang.InTan[1];
    it.InTan[2]:=Tan.tang.InTan[2];
    it.InTan[3]:=Tan.tang.InTan[3];
    it.OutTan[1]:=Tan.tang.OutTan[1];
    it.OutTan[2]:=Tan.tang.OutTan[2];
    it.OutTan[3]:=Tan.tang.OutTan[3];
   end;//of if
  end;//of if
  AddKeyFrame(b.Translation,it);
 end;//of if/else
 PopFunction;
End;
//----------------------------------------------------------
//���������� �������� ������������� ������� � �������,
//�������� ������������ q
procedure TObjAnimate.InternalRotate(id:integer;q:TQuaternion);
Var b:TBone; len:integer; it:TContItem; qr:TQuaternion;
Begin
 PushFunction(209);
 b:=GetSkelObjectById(id);

 it.Frame:=CurFrame;
 qr:=AbsQToRotation(b,q);
 it.Data[1]:=qr.x;  it.InTan[1]:=qr.x; it.OutTan[1]:=qr.x;
 it.Data[2]:=qr.y;  it.InTan[2]:=qr.y; it.OutTan[2]:=qr.y;
 it.Data[3]:=qr.z;  it.InTan[3]:=qr.z; it.OutTan[3]:=qr.z;
 it.Data[4]:=qr.w;  it.InTan[4]:=qr.w; it.OutTan[4]:=qr.w;

 // ���� �����, ������� ����������
 if b.Rotation<0 then begin
  len:=length(Controllers);
  SetLength(Controllers,len+1);
  b.Rotation:=CreateController(id,it,ctRotation);
  Controllers[b.Rotation].ContType:=Linear;
  Controllers[b.Rotation].GlobalSeqId:=UsingGlobalSeq;
  SetObjSkelPart(b);
 end else begin
  len:=length(Controllers[b.Rotation].Items);
  if (Controllers[b.Rotation].ContType=Hermite) and SplineUsed then begin
   Tan.Prev:=LookBack(Controllers[b.Rotation],CurFrame,
                      MinFrame,MaxFrame,len);
   Tan.cur:=it;
   Tan.next:=LookForward(Controllers[b.Rotation],CurFrame,
                         MinFrame,MaxFrame,len);
   if (Tan.Prev.Frame>=0) and (Tan.Next.Frame>=0) then begin
    Tan.CalcDerivative4D;
    it.InTan[1]:=Tan.tang.InTan[1];
    it.InTan[2]:=Tan.tang.InTan[2];
    it.InTan[3]:=Tan.tang.InTan[3];
    it.InTan[4]:=Tan.tang.InTan[4];
    it.OutTan[1]:=Tan.tang.OutTan[1];
    it.OutTan[2]:=Tan.tang.OutTan[2];
    it.OutTan[3]:=Tan.tang.OutTan[3];
    it.OutTan[4]:=Tan.tang.OutTan[4];
   end;//of if
  end;//of if
  AddKeyFrame(b.Rotation,it);
 end;//of if/else
 PopFunction;
End;
//----------------------------------------------------------
//��������� ����������� �������� ��� ���������� �������
procedure TObjAnimate.InternalScale(id:integer;sx,sy,sz:single);
Var b,bs:TBone; len:integer; it:TContItem; v:TVertex;
Begin
 PushFunction(210);
 //����� "������������" �������� ��������
 v[1]:=1; v[2]:=1; v[3]:=1;
 b:=GetSkelObjectById(id);
 bs:=b;
 while b.Parent>=0 do begin
  b:=GetSkelObjectById(b.Parent);
  v[1]:=v[1]*b.AbsScaling[1];
  v[2]:=v[2]*b.AbsScaling[2];
  v[3]:=v[3]*b.AbsScaling[3];
 end;//of while

 //2. ����� ��������� �������� ���������������
 b:=bs;
 v[1]:=sx/v[1]; v[2]:=sy/v[2]; v[3]:=sz/v[3];

 //3. ��������� � ��
 it.Frame:=CurFrame;
 it.Data[1]:=v[1];  it.InTan[1]:=v[1]; it.OutTan[1]:=v[1];
 it.Data[2]:=v[2];  it.InTan[2]:=v[2]; it.OutTan[2]:=v[2];
 it.Data[3]:=v[3];  it.InTan[3]:=v[3]; it.OutTan[3]:=v[3];

 // ���� �����, ������� ����������
 if b.Scaling<0 then begin
  len:=length(Controllers);
  SetLength(Controllers,len+1);
  b.Scaling:=CreateController(id,it,ctScaling);
  Controllers[b.Scaling].ContType:=Linear;
  Controllers[b.Scaling].GlobalSeqId:=UsingGlobalSeq;
  SetObjSkelPart(b);
 end else begin
  len:=length(Controllers[b.Scaling].Items);
  if (Controllers[b.Scaling].ContType=Hermite) and SplineUsed then begin
   Tan.Prev:=LookBack(Controllers[b.Scaling],CurFrame,
                      MinFrame,MaxFrame,len);
   Tan.cur:=it;
   Tan.next:=LookForward(Controllers[b.Scaling],CurFrame,
                         MinFrame,MaxFrame,len);
   if (Tan.Prev.Frame>=0) and (Tan.Next.Frame>=0) then begin
    Tan.CalcDerivativeXD(3);
    it.InTan[1]:=Tan.tang.InTan[1];
    it.InTan[2]:=Tan.tang.InTan[2];
    it.InTan[3]:=Tan.tang.InTan[3];
    it.OutTan[1]:=Tan.tang.OutTan[1];
    it.OutTan[2]:=Tan.tang.OutTan[2];
    it.OutTan[3]:=Tan.tang.OutTan[3];
   end;//of if
  end;//of if
  AddKeyFrame(b.Scaling,it);
 end;//of if/else
 PopFunction;
End;
//----------------------------------------------------------

constructor TObjAnimate.Create;
Begin;
 inherited Create;
 SplineUsed:=false;
 RotRestrict:=TList.Create;
 ScRestrict:=TList.Create;
 MoveRestrict:=TList.Create;
 Tan:=TTan.Create;
End;
//----------------------------------------------------------
//������������� t,c � b ��� ������� �������������� ������������
procedure TObjAnimate.SetTCB(t,c,b:single);
Begin
 Tan.tension:=t;
 Tan.continuity:=c;
 Tan.bias:=b;
End;
//----------------------------------------------------------
procedure TObjAnimate.ClearRestricts;//�������� ������ �����������
Begin
 RotRestrict.Clear;
 ScRestrict.Clear;
 MoveRestrict.Clear;
End;
//----------------------------------------------------------
procedure TObjAnimate.SaveUndo;   //���������� ������ ��������+����������
Var i:integer;
    lst:TKeyFramesList; skf:TChangeObjKFUndo;
Begin
 PushFunction(211);
 //1. ��������� ����������
 AnimSaveUndo(uTransBone,0);
 skf:=TChangeObjKFUndo(NewUndo[CountOfNewUndo-1]);
 //2. �������� ������ ��������
 lst:=TKeyFramesList.Create;
 lst.Clear;
 lst.Add(SelObj.b.ObjectID);
 for i:=0 to RotRestrict.Count-1 do lst.Add(integer(RotRestrict.Items[i]));
 for i:=0 to MoveRestrict.Count-1 do lst.Add(integer(MoveRestrict.Items[i]));
 for i:=0 to ScRestrict.Count-1 do lst.Add(integer(ScRestrict.Items[i]));

 //3. �������� ��� ������� ����� ������
 skf.CountOfObjs:=lst.Count;
 SetLength(skf.Objs,skf.CountOfObjs);
 for i:=0 to skf.CountOfObjs-1
 do skf.objs[i]:=GetSkelObjectById(lst.GetFrame(i));

 //3. ��������� �� ���������
 skf.Save;
 PopFunction;
End;
//----------------------------------------------------------
//�������, �����������, ���� �� � ������� ID
//��������� �����������
function TObjAnimate.IsRotRestrict(id:integer):boolean;
Begin
 Result:=RotRestrict.IndexOf(pointer(id))>=0;
End;

function TObjAnimate.IsMoveRestrict(id:integer):boolean;
Begin
 Result:=MoveRestrict.IndexOf(pointer(id))>=0;
End;

function TObjAnimate.IsScRestrict(id:integer):boolean;
Begin
 Result:=ScRestrict.IndexOf(pointer(id))>=0;
End;
//----------------------------------------------------------

//��������/������� ��������������� ����������� �������
procedure TObjAnimate.SetRotRestrict(id:integer;IsAdd:boolean);
Begin
 PushFunction(212);
 if IsRotRestrict(id) then begin
  RotRestrict.Remove(pointer(id));
  frm1.sb_bonerot.enabled:=true;
 end else begin
  RotRestrict.Add(pointer(id));
  frm1.sb_bonerot.enabled:=false;
  frm1.sb_selbone.down:=true;
  frm1.sb_selectClick(Self); 
 end;
 PopFunction;
End;

procedure TObjAnimate.SetMoveRestrict(id:integer;IsAdd:boolean);
Begin
 PushFunction(213);
 if IsMoveRestrict(id) then begin
  MoveRestrict.Remove(pointer(id));
  frm1.sb_bonemove.Enabled:=true;
 end else begin
  MoveRestrict.Add(pointer(id));
  frm1.sb_bonemove.enabled:=false;
  frm1.sb_selbone.down:=true;
  frm1.sb_selectClick(Self);
 end;
 PopFunction;
End;

procedure TObjAnimate.SetScRestrict(id:integer;IsAdd:boolean);
Begin
 PushFunction(214);
 if IsScRestrict(id) then begin
  ScRestrict.Remove(pointer(id));
  frm1.sb_bonescale.enabled:=true;
 end else begin
  ScRestrict.Add(pointer(id));
  frm1.sb_bonescale.enabled:=false;
  frm1.sb_selbone.down:=true;
  frm1.sb_selectClick(Self);
 end;
 PopFunction;
End;

//----------------------------------------------------------
//������� ������� ������ �� ��������� ��������,
//�������� ����� �� ��� ������� ������.
//��� ������� � ������������ �� �������� �� ���������
procedure TObjAnimate.Move(dx,dy,dz:single);
Var i,j:integer; IsChange:boolean;
    b:TBone;
Begin
 PushFunction(215);
 //1. �������� ���������� ������� ��������
 //� ������������� �� ��������
 MemorizeObjVectors;

 //2. ���������� �������� �������
 //�������� ������
 InternalMove(SelObj.b.ObjectID,SelObj.b.AbsVector[1]+dx,
              SelObj.b.AbsVector[2]+dy,SelObj.b.AbsVector[3]+dz);
 CalcObjCoords;                   //����������� ����������

 //3. ����� ������� ��� "������������" �������, �-�� �������
 //���������� �� �����������. � ����� �������������
 //�-�� �������� ������� �� ��� ���, ���� ��� ����� �������
 //�� ������ ������������ [..�� 200 ��������].
 for j:=0 to 200 do begin
  IsChange:=false;                //���� ��� ���������
  for i:=0 to MoveRestrict.Count-1 do begin
   b:=GetSkelObjectById(integer(MoveRestrict.Items[i]));
   if (abs(b.AbsVector[1]-av[i,1])+abs(b.AbsVector[2]-av[i,2])+
      abs(b.AbsVector[3]-av[i,3]))>1e-4 then begin
    InternalMove(b.ObjectID,av[i,1],av[i,2],av[i,3]);
    IsChange:=true;
   end;//of if
  end;//of for i
  if not IsChange then begin PopFunction;exit;end;//���������!
  CalcObjCoords;                  //����������� �-�� ��������
 end;//of for j
 PopFunction;
End;
//----------------------------------------------------------
//������������ ������� ������ �� ��������� ���-�� ��������.
//������� �������������� �� ��. ��������� ��������.
//��������� ���� ������ ���� �������� (��� �������� � 0).
procedure TObjAnimate.Rotate(dax,day,daz:single);
Var qa,q:TQuaternion; j,i:integer; IsChange:boolean;
    b:TBone;
Begin
 PushFunction(216);
 //1. �������� ���. ������� �������� � ������������� �� ��������
 //� (� ��������� �������) �� ��������
 MemorizeObjVectors;
 MemorizeObjMatrices;

 //2. ���������� ������� ������� (� �����. ����������� �����������)
 MatrixToQuaternion(SelObj.b.AbsMatrix,q);
 qa.x:=0; qa.y:=0; qa.z:=0; qa.w:=0;
 if abs(daz)>0.0001 then begin
  qa.z:=sin(-0.5*daz);
  qa.w:=cos(-0.5*daz);
 end else if abs(day)>0.0001 then begin
  qa.y:=sin(0.5*day);
  qa.w:=cos(0.5*day);
 end else begin
  qa.x:=sin(-0.5*dax);
  qa.w:=cos(-0.5*dax);
 end;//of if

 MulQuaternions(qa,q,q);
 InternalRotate(SelObj.b.ObjectID,q);
 CalcObjCoords;

 //3. ����� ������� ��� "������������" �������, �-�� �������
 //���������� �� �����������. ����� ������� ��� ���. �������,
 //������� ������� ���������� �� �����������.
 //� ����� �������������
 //�-�� �������� ������� �� ��� ���, ���� ��� ����� �������
 //�� ������ ������������/�������������� [..�� 200 ��������]
 for j:=0 to 200 do begin
  IsChange:=false;                //���� ��� ���������
  for i:=0 to RotRestrict.Count-1 do begin
   b:=GetSkelObjectById(integer(RotRestrict.Items[i]));
   if not IsMatrixEqual(b.AbsMatrix,am[i]) then begin
    MatrixToQuaternion(am[i],q);
    InternalRotate(b.ObjectID,q);
    IsChange:=true;
   end;//of if
  end;//of for i
  for i:=0 to MoveRestrict.Count-1 do begin
   b:=GetSkelObjectById(integer(MoveRestrict.Items[i]));
   if (abs(b.AbsVector[1]-av[i,1])+abs(b.AbsVector[2]-av[i,2])+
      abs(b.AbsVector[3]-av[i,3]))>1e-6 then begin
    InternalMove(b.ObjectID,av[i,1],av[i,2],av[i,3]);
    IsChange:=true;
   end;//of if
  end;//of for i
  if not IsChange then begin PopFunction;exit;end;//���������!
  CalcObjCoords;                  //����������� �-�� ��������
 end;//of for j
 PopFunction;
End;
//----------------------------------------------------------
//������������ ������� ������
//(��������� ��������� ���������� ���������)
procedure TObjAnimate.Scale(sx,sy,sz:single);
Var i,j:integer; IsChange:boolean; b:TBone; sc:TVertex;
Begin
 PushFunction(217);
 //1. �������� ���. ������� �������� � ������������� �� ��������
 //� (� ��������� �������) �� ���������������
 MemorizeObjVectors;
 MemorizeObjScales;

 //2. ���������� ��������������� �������
 InternalScale(SelObj.b.ObjectID,sx,sy,sz);
 CalcObjCoords;

 //3. ����� ������� ��� "������������" �������, �-�� �������
 //���������� �� �����������. ����� �������������� ��� ���. �������,
 //��������� ������� ���������� �� �����������.
 //� ����� �������������
 //�-�� �������� ������� �� ��� ���, ���� ��� ����� �������
 //�� ������ ������������/����������������� [..�� 200 ��������]
 for j:=0 to 200 do begin
  IsChange:=false;                //���� ��� ���������
  for i:=0 to ScRestrict.Count-1 do begin
   b:=GetSkelObjectByID(integer(ScRestrict.Items[i]));
   GetAbsScale(b.ObjectID,sc[1],sc[2],sc[3]);
   if abs(sc[1]-az[i,1])+abs(sc[2]-az[i,2])+
      abs(sc[3]-az[i,3])>1e-8 then begin
    InternalScale(b.ObjectID,az[i,1],az[i,2],az[i,3]);
    IsChange:=true;
   end;//of if
  end;//of for i
  for i:=0 to MoveRestrict.Count-1 do begin
   b:=GetSkelObjectById(integer(MoveRestrict.Items[i]));
   if (abs(b.AbsVector[1]-av[i,1])+abs(b.AbsVector[2]-av[i,2])+
      abs(b.AbsVector[2]-av[i,2]))>1e-4 then begin
    InternalMove(b.ObjectID,av[i,1],av[i,2],av[i,3]);
    IsChange:=true;
   end;//of if
  end;//of for i
  if not IsChange then begin PopFunction;exit;end;//���������!
  CalcObjCoords;                  //����������� �-�� ��������
 end;//of for j
 PopFunction;
End;
//----------------------------------------------------------
//���������� ������������� ���������� ���������� ���������
//��� ������� (� ������ ���� ������������)
procedure TObjAnimate.GetAbsScale(id:integer;var sx,sy,sz:single);
Var b:TBone;
Begin
 PushFunction(218);
 b:=GetSkelObjectByID(id);
 sx:=b.AbsScaling[1];
 sy:=b.AbsScaling[2];
 sz:=b.AbsScaling[3];
 while b.Parent>=0 do begin
  b:=GetSkelObjectByID(b.Parent);
  sx:=sx*b.AbsScaling[1];
  sy:=sy*b.AbsScaling[2];
  sz:=sz*b.AbsScaling[3];
 end;//of while
 PopFunction;
End;
//==========================================================
//������������� ����� ���������� � ��������� ID,
//������ ��������� ������ ������������� �������,
//� ����� ������ ��� ������ �������
procedure TContrProps.SetCaptionAndId(sObj,sKind:string;ContId:integer);
Begin
 PushFunction(219);
 //�� ������� ��������� �� ������
 if (ContID<0) or (ContID>High(Controllers)) then begin
  frm1.label46.font.color:=clRed;
  frm1.label46.caption:='������: ContID='+inttostr(ContID);
  PopFunction;
  exit;
 end;//of if

 //������ �������� �� ������������ GlobalID
 if Controllers[ContID].GlobalSeqId<>UsingGlobalSeq then begin
  Hide;
  PopFunction;
  exit;
 end;//of if

 frm1.l_object.caption:=sObj;
 frm1.l_conttype.caption:=sKind;
 id:=ContId;

 frm1.label46.tag:=1;             //�������� ���������� ��������
  //��� �����������
  case Controllers[id].ContType of
   DontInterp:frm1.rg_conttype.ItemIndex:=0;
   Linear:    frm1.rg_conttype.ItemIndex:=1;
   Bezier:    frm1.rg_conttype.ItemIndex:=2;
   Hermite:   frm1.rg_conttype.ItemIndex:=3;
  end;//of case

  //����������� ��������� ����
  frm1.rg_conttype.enabled:=not OnlyOnOff;
  //���� �����, ������� ������
  if frm1.cb_showkey.checked then SetFilter;

 frm1.label46.tag:=0;             //�������� ����������
 IsVisible:=true;
 frm1.pn_contrprops.visible:=true;//�������� ������
 frm1.BuildPanels;
 PopFunction;
End;

//----------------------------------------------------------
//��������� �������� ������ ������� �����������
procedure TContrProps.Hide;
Begin
 PushFunction(220);
 IsVisible:=false;
 frm1.pn_contrprops.visible:=false;

 //������ ������� ��
 if not frm1.cb_multiselect.checked then IsContrFilter:=false;
 if not frm1.pn_anim.visible then begin PopFunction;exit;end;
 frm1.ReFormStamps;
 frm1.pb_animMouseUp(Self,mbMiddle,[],0,0);
 frm1.pb_animpaint(Self);
 frm1.BuildPanels;
 PopFunction;
End;

//----------------------------------------------------------
//������������� ����� ��� ��������� �����������
procedure TContrProps.SetFilter;
Begin
 PushFunction(221);
 ContrFilter.Clear;
 ContrFilter.Add(pointer(id));
 IsContrFilter:=true;
 frm1.ReFormStamps;
 frm1.pb_animMouseUp(Self,mbMiddle,[],0,0);
 frm1.pb_animPaint(self);
 PopFunction;
End;

//----------------------------------------------------------
//������� ������� ����������
procedure TContrProps.DeleteController;
Begin
 Controllers[id].Items:=nil;
 Hide;
{ frm1.ReFormStamps;
 frm1.pb_animMouseUp(Self,mbMiddle,[],0,0);
 frm1.pb_animPaint(self);}
End;

//----------------------------------------------------------
//���������� ����� ���� ����������� (� ���������� ��)
{procedure TContrProps.ChangeType(NewType:integer);
Begin
 case NewType of
  Linear:
 end;//of case
 Controllers[id].ContType:=NewType;
End;}
//----------------------------------------------------------
//����������� �������
constructor TSpline.Create;
Var hbitmap:integer;
Begin
 PushFunction(222);
 inherited;                       //������� ��������� ������
 Der:=TTan.Create;                //������� ������ TTan

 //������� ����������� ��������
 cdc:=CreateCompatibleDC(frm1.pb_spline.Canvas.Handle);
 hbitmap:=CreateCompatibleBitmap(frm1.pb_spline.canvas.handle,
                                 frm1.pb_spline.width,
                                 frm1.pb_spline.height);
 SelectObject(cdc,hBitmap);
 PopFunction;
End;
//----------------------------------------------------------

//������ ������
procedure TSpline.Hide;
Begin
 PushFunction(223);
 frm1.label47.tag:=1;
 frm1.pn_view.SetFocus;
 frm1.pn_spline.visible:=false;
 frm1.label47.tag:=0;
 IsVisible:=false;
 PopFunction;
End;
//----------------------------------------------------------
//�������������� ������ �� �� ���������� �����������
//�� ������ �� CurFrame.
//���� ������ 1-� ��� ��������� ����, �� ������ ��������.
procedure TSpline.InitFromKF(contID:integer);
Var len,num:integer;
Begin
 PushFunction(224);
 len:=length(Controllers[ContID].Items);
 num:=GetFramePos(Controllers[ContID],CurFrame,len);
 //��������: �� ����� �� ������ ������
 if (num=0) or (num>=len-1) or
    ({(Controllers[ContID].ContType<>Bezier) and}
    (Controllers[ContID].ContType<>hermite)) then begin
  Hide;
  PopFunction;
  Exit;
 end;//of if
 if Controllers[ContID].Items[num].Frame<>CurFrame then begin
  Hide;
  PopFunction;
  exit;
 end;//of if

 id:=ContID;                      //��������� ContID
 //���������� t,c,b
 Der.tang:=Controllers[id].Items[num];
 Der.cur:=Controllers[id].Items[num];
 Der.prev:=Controllers[id].Items[num-1];
 Der.next:=Controllers[id].Items[num+1];
 Der.CalcSplineParameters(Controllers[id].SizeOfElement=4,4);

 //��������� ������������ ���������
 with frm1 do begin
  label47.tag:=1;
  ed_t.text:=inttostr(round(Der.tension*100));
  ed_c.text:=inttostr(round(Der.continuity*100));
  ed_bias.text:=inttostr(round(Der.bias*100));
  label47.tag:=0;
 end;//of with

 //�������� ������
 frm1.pn_spline.visible:=true;
 IsVisible:=true;
 //���������� ������
 Render;
 frm1.BuildPanels;
 PopFunction;
End;
//----------------------------------------------------------
//����������� ������� ��������
procedure TSpline.Repaint;
Begin with frm1 do begin
  BitBlt(pb_spline.Canvas.Handle,0,0,
         pb_spline.width,pb_spline.height,cdc,0,0,SRCCOPY);
end;End;
//----------------------------------------------------------
//�������� ������
procedure TSpline.Render;
Var i:integer;itd,its:TContItem;
    rect:TRect;
    PixPerUnitX,PixPerUnitY:single;
Begin with frm1 do begin
 PushFunction(225);
 //������ ���������� ��� ���������
 PixPerUnitX:=0.005*pb_spline.width;
 PixPerUnitY:=pb_spline.height/130;
 //������������� ���������
 pb_spline.Canvas.Pen.Width:=1;
 //����� - �������������
 pb_spline.Canvas.Brush.Color:=$FFFFFF; //���� - �����
 pb_spline.canvas.Pen.Color:=$EE8888;
 rect.Left:=0;rect.Top:=0;rect.right:=pb_spline.width;
 rect.Bottom:=pb_spline.height;
 pb_spline.Canvas.FillRect(rect);
 pb_spline.canvas.Rectangle(rect);
 pb_spline.Canvas.MoveTo(0,rect.bottom);

 //������ �����. ���������
 Der.prev.Data[1]:=0;
 Der.cur.Data[1]:=100;
 Der.next.Data[1]:=0;
 Der.CalcDerivativeXD(1);
 pb_spline.Canvas.Pen.Color:=0;
 i:=0;
 repeat
  itd:=Der.tang; itd.Data[1]:=100; itd.Frame:=100;
  its.Frame:=0; its.Data[1]:=0; its.InTan[1]:=0; its.OutTan[1]:=0;
  case Controllers[id].ContType of
   Hermite:Spline(i,its,itd);
   Bezier:BezInterp(i,its,itd);
  end;//of case
  pb_spline.Canvas.LineTo(round(PixPerUnitX*i),-round(PixPerUnitY*itd.Data[1])
                          +pb_spline.height);
  i:=i+2;
 until i>100;

 //������ �������� ������
 i:=100;
 repeat
  itd.Data[1]:=0; itd.Frame:=200; itd.InTan[1]:=0; itd.OutTan[1]:=0;
  its:=Der.tang; its.Frame:=100; its.Data[1]:=100;
  case Controllers[id].ContType of
   Hermite:Spline(i,its,itd);
   Bezier:BezInterp(i,its,itd);
  end;//of case
  pb_spline.Canvas.LineTo(round(PixPerUnitX*i),-round(PixPerUnitY*itd.Data[1])
                          +pb_spline.height);
  i:=i+2;
 until i>200;

 //����������� �����
 pb_spline.Canvas.Pen.Color:=clRed;
 pb_spline.Canvas.MoveTo(round(PixPerUnitX*100),pb_spline.height);
 pb_spline.Canvas.LineTo(round(PixPerUnitX*100),-round(PixPerUnitY*100)
                         +pb_spline.height);


 //���������� �� ��������� ��������
 BitBlt(cdc,0,0,pb_spline.width,pb_spline.height,
        pb_spline.canvas.handle,0,0,SRCCOPY);
 Self.Repaint;
 PopFunction;
end;End;

//----------------------------------------------------------
//���������� TCB
procedure TSpline.GetTCB(var t,c,b:single);
Begin
 t:=Der.tension;
 c:=Der.continuity;
 b:=Der.bias;
End;
//----------------------------------------------------------

//��������� TCB ��������������� � ���������� (� ����)
procedure TSpline.SetTCB(t,c,b:single);
Var it:TContItem; i:integer;
Begin
 PushFunction(226);
 //�������� �������� � ���������� �����������
 Der.tension:=t;
 Der.continuity:=c;
 Der.bias:=b;

 //������ �����, ��� �����
 i:=GetFramePos(Controllers[id],CurFrame,length(Controllers[id].items));
 Der.cur:=Controllers[id].Items[i];
 Der.prev:=Controllers[id].Items[i-1];
 Der.next:=Controllers[id].Items[i+1];

 Der.IsLogsReady:=false;
 if Controllers[id].SizeOfElement=4 then Der.CalcDerivative4D
 else Der.CalcDerivativeXD(Controllers[id].SizeOfElement);

 //��������� ��� ������
 AnimSaveUndo(uChangeFrame,0);//��������� ��� ������
 frm1.sb_animundo.enabled:=true;
 frm1.CtrlZ1.enabled:=true;
 frm1.StrlS1.enabled:=true;
 frm1.sb_save.enabled:=true;

 //���������� ��������� ��
 it:=Controllers[id].Items[i];
 it.InTan[1]:=Der.tang.InTan[1];
 it.InTan[2]:=Der.tang.InTan[2];
 it.InTan[3]:=Der.tang.InTan[3];
 it.InTan[4]:=Der.tang.InTan[4];
 it.OutTan[1]:=Der.tang.OutTan[1];
 it.OutTan[2]:=Der.tang.OutTan[2];
 it.OutTan[3]:=Der.tang.OutTan[3];
 it.OutTan[4]:=Der.tang.OutTan[4];
 SaveContFrame(id,it.Frame);
 AddKeyFrame(id,it);
 Render;
 PopFunction;
End;
//==========================================================
procedure TWorkPlane.BeginRender;
Begin
  if not IsSlowHighlight then begin //������� ������� ���������
   SwapBuffers(dc);
   glFinish;
   glDrawBuffer(GL_FRONT);          //�������� ����� �����
   glFinish;
  end;//of if
End;
//----------------------------------------------------------
procedure TWorkPlane.EndRender;
Begin
  if IsSlowHighlight then begin   //��������� ������� ���������
   SwapBuffers(dc);
   glCallList(CurrentListNum);
  end else begin                  //������� ������� ���������
   glFinish;
   wglMakeCurrent(dc,hrc);
   glDrawBuffer(GL_BACK);
   glFinish;
  end;//of if
End;
//----------------------------------------------------------
//���������� ������� � ������������ ���. ��������
//�����, ��������� � (x,y)
procedure TWorkPlane.FindNearestPoint(x,y:integer;var indXY,indXZ,indYZ:integer);
Var i:integer; MinXY,MinXZ,MinYZ, DeltaXY,DeltaXZ,DeltaYZ,
               MinDXY,MinDXZ,MinDYZ,
               MaxDXY,MaxDXZ,MaxDYZ,
               MulXY,MulXZ,MulYZ:GLFloat;
Begin
 PushFunction(227);
 MinDXY:=1e6; MinDXZ:=1e6; MinDYZ:=1e6;
 MaxDXY:=-1e6;MaxDXZ:=-1e6;MaxDYZ:=-1e6;

 //1. ���� �����: ���� ������� � ������� �����
 for i:=0 to CIRCLE_SECTORS do begin
  if AbsXY[i,3]<MinDXY then MinDXY:=AbsXY[i,3];
  if AbsXZ[i,3]<MinDXZ then MinDXZ:=AbsXZ[i,3];
  if AbsYZ[i,3]<MinDYZ then MinDYZ:=AbsYZ[i,3];

  if AbsXY[i,3]>MaxDXY then MaxDXY:=AbsXY[i,3];
  if AbsXZ[i,3]>MaxDXZ then MaxDXZ:=AbsXZ[i,3];
  if AbsYZ[i,3]>MaxDYZ then MaxDYZ:=AbsYZ[i,3];
 end;//of for i

 if abs(MinDXY-MaxDXY)<1e-10 then MulXY:=0
 else MulXY:=20/abs(MinDXY-MaxDXY);
 if abs(MinDXZ-MaxDXZ)<1e-10 then MulXZ:=0
 else MulXZ:=20/abs(MinDXZ-MaxDXZ);
 if abs(MinDYZ-MaxDYZ)<1e-10 then MulYZ:=0
 else MulYZ:=20/abs(MinDYZ-MaxDYZ);

 MinXY:=1e6; MinXZ:=1e6; MinYZ:=1e6;
 for i:=0 to CIRCLE_SECTORS do begin
  DeltaXY:=abs(AbsXY[i,1]-x)+abs(AbsXY[i,2]-y)+MulXY*abs(AbsXY[i,3]-MinDXY);
  DeltaXZ:=abs(AbsXZ[i,1]-x)+abs(AbsXZ[i,2]-y)+MulXZ*abs(AbsXZ[i,3]-MinDXZ);
  DeltaYZ:=abs(AbsYZ[i,1]-x)+abs(AbsYZ[i,2]-y)+MulYZ*abs(AbsYZ[i,3]-MinDYZ);
  if DeltaXY<MinXY then begin
   MinXY:=DeltaXY;
   indXY:=i;
  end;//of if
  if DeltaXZ<MinXZ then begin
   MinXZ:=DeltaXZ;
   indXZ:=i;
  end;//of if
  if DeltaYZ<MinYZ then begin
   MinYZ:=DeltaYZ;
   indYZ:=i;
  end;//of if
 end;//of for i
 PopFunction;
End;
//----------------------------------------------------------
procedure TWorkPlane.RenderQuad;           //��������� �������� ���������
Begin
  PushFunction(228);
  glLineWidth(2);                  //�������
  glColor3f(1,1,0);
  if (SumXY<=SumXZ) and (SumXY<=SumYZ) then begin
   frm1.rb_xy.checked:=true;
   frm1.rb_bxy.checked:=true;
   glBegin(GL_LINES);
    glVertex3f(ccX,-ccY,ccZ);
    glVertex3f(ccX+50/CurView.Zoom,-ccY,ccZ);
   glEnd;
  end;//of if
  if (SumXZ<=SumXY) and (SumXZ<=SumYZ) then begin
   frm1.rb_xz.checked:=true;
   frm1.rb_bxz.checked:=true;
   glBegin(GL_LINES);
    glVertex3f(ccX,-ccY,ccZ);
    glVertex3f(ccX,-ccY,ccZ+50/CurView.Zoom);
   glEnd;
  end;//of if
  if ((SumYZ<SumXZ) and (SumYZ<=SumXY)) or
     ((SumYZ=SumXZ) and (SumYZ<=SumXY) and
      ((CurView.ax+CurView.ay)<>270)) then begin
   frm1.rb_yz.checked:=true;
   frm1.rb_byz.checked:=true;
   glBegin(GL_LINES);
    glVertex3f(ccX,-ccY,ccZ);
    glVertex3f(ccX,-ccY-50/CurView.Zoom,ccZ);
   glEnd;
  end;//of if
  PopFunction;
End;
//----------------------------------------------------------
//�� ������ ������������� ������ � ������������� �-� ������
//������������ ���������� �����
procedure TWorkPlane.CalcAbsCircles;
Var i:integer;
    Viewport:array[0..3] of GLfloat;
    mvMatrix,ProjMatrix:array[0..15] of GLdouble;
    zm:GLFloat;
Begin
 PushFunction(229);
 //1. ������ ������
 glGetIntegerv(GL_VIEWPORT,@Viewport);
 glGetDoublev(GL_MODELVIEW_MATRIX,@mvMatrix);
 glGetDoublev(GL_PROJECTION_MATRIX,@ProjMatrix);
 zm:=1/CurView.Zoom;

 //2. ���������� ������ ��������
 for i:=0 to CIRCLE_SECTORS do begin
  gluProject(zm*CircleXY[i,1]+ccX,-(zm*CircleXY[i,2]+ccY),zm*CircleXY[i,3]+ccZ,
             @mvMatrix,@ProjMatrix,@ViewPort,
             AbsXY[i,1],AbsXY[i,2],AbsXY[i,3]);
  AbsXY[i,2]:=frm1.GLWorkArea.ClientHeight-AbsXY[i,2];//��������

  gluProject(zm*CircleXZ[i,1]+ccX,-(zm*CircleXZ[i,2]+ccY),zm*CircleXZ[i,3]+ccZ,
             @mvMatrix,@ProjMatrix,@ViewPort,
             AbsXZ[i,1],AbsXZ[i,2],AbsXZ[i,3]);
  AbsXZ[i,2]:=frm1.GLWorkArea.ClientHeight-AbsXZ[i,2];//��������

  gluProject(zm*CircleYZ[i,1]+ccX,-(zm*CircleYZ[i,2]+ccY),zm*CircleYZ[i,3]+ccZ,
             @mvMatrix,@ProjMatrix,@ViewPort,
             AbsYZ[i,1],AbsYZ[i,2],AbsYZ[i,3]);
  AbsYZ[i,2]:=frm1.GLWorkArea.ClientHeight-AbsYZ[i,2];//��������

 end;//of for i
 PopFunction;
End;
//----------------------------------------------------------
constructor TWorkPlane.Create;
Var i:integer;
const Step=2*Pi/CIRCLE_SECTORS;
      r=40;
Begin
 PushFunction(230);
 for i:=0 to CIRCLE_SECTORS do begin
  //XY
  CircleXY[i,1]:=cos(i*step)*r;
  CircleXY[i,2]:=sin(i*step)*r;
  CircleXY[i,3]:=0;
  //XZ
  CircleXZ[i,1]:=cos(i*step)*r;
  CircleXZ[i,2]:=0;
  CircleXZ[i,3]:=sin(i*step)*r;
  //YZ
  CircleYZ[i,1]:=0;
  CircleYZ[i,2]:=cos(i*step)*r;
  CircleYZ[i,3]:=sin(i*step)*r;
 end;//of for i
 PopFunction;
End;
//----------------------------------------------------------
procedure TWorkPlane.Find(x,y:integer;Shift:TShiftState); //���������� �����
Var Viewport:array[0..3] of GLfloat;
    mvMatrix,ProjMatrix:array[0..15] of GLdouble;
    w0x,w0y,w0z,wxx,wxy,wxz,wyx,wyy,wyz,wzx,wzy,wzz,
    fiX,fiY,fiZ,fiM,dx,dy,
    DeltaMX,DeltaMY,DeltaMZ,
    DeltaXM,DeltaYM,DeltaZM:Double;
    IsX,IsY,IsZ:boolean;    
Begin
 if (not IsXYZ) or (CountOfGeosets=0) then exit; //�� �������� ���������
 PushFunction(231);
 //1. ������� �-�� �������� ����� ���� � ��������� �����
 glGetIntegerv(GL_VIEWPORT,@Viewport);
 glGetDoublev(GL_MODELVIEW_MATRIX,@mvMatrix);
 glGetDoublev(GL_PROJECTION_MATRIX,@ProjMatrix);
 gluProject(ccX,-ccY,ccZ,@mvMatrix,@ProjMatrix,@Viewport,w0x,w0y,w0z);
 gluProject(ccX+50,-ccY,ccZ,@mvMatrix,@ProjMatrix,@Viewport,wxx,wxy,wxz);
 gluProject(ccX,-ccY-50,ccZ,@mvMatrix,@ProjMatrix,@Viewport,wyx,wyy,wyz);
 gluProject(ccX,-ccY,ccZ+50,@mvMatrix,@ProjMatrix,@Viewport,wzx,wzy,wzz);
 w0y:=frm1.GLWorkArea.ClientHeight-w0y;
 wxy:=frm1.GLWorkArea.ClientHeight-wxy;
 wyy:=frm1.GLWorkArea.ClientHeight-wyy;
 wzy:=frm1.GLWorkArea.ClientHeight-wzy;
 dy:=y;
 BeginRender;                     //������ ����������
 //��������� ���, � �� ���������
 if ssShift in Shift then begin
  //2. �������, � ����� �� ���� ����� �����.
  SumXY:=GetDistance(x,y,w0x,w0y,wxx,wxy);
  SumXZ:=GetDistance(x,y,w0x,w0y,wzx,wzy);
  SumYZ:=GetDistance(x,y,w0x,w0y,wyx,wyy);
  RenderQuad;
 end else begin                   //������������ ���������
  //2. ����������, � ����� ����� ��������� ������ ����
  wxx:=wxx-w0x;wxy:=wxy-w0y;
  wyx:=wyx-w0x;wyy:=wyy-w0y;
  wzx:=wzx-w0x;wzy:=wzy-w0y;
  dx:=x-w0x;dy:=dy-w0y;
  fiX:=AngleOfVector(wxx,wxy);
  fiY:=AngleOfVector(wyx,wyy);
  fiZ:=AngleOfVector(wzx,wzy);
  fiM:=AngleOfVector(dx,dy);
  if abs((abs(fiY+fiZ)-3*Pi))<1e-4 then begin
   fiY:=1.57;
  end;//of if

  //��������: ����� ������� ��������� �������?
  DeltaMX:=fiM-fiX;DeltaMY:=fiM-fiY;DeltaMZ:=fiM-fiZ;
  DeltaXM:=fiX-fiM;DeltaYM:=fiY-fiM;DeltaZM:=fiZ-fiM;

  //"�����������" � ������������� ��������
  if DeltaMX<0 then DeltaMX:=abs(DeltaMX+2*Pi) else DeltaMX:=abs(DeltaMX);
  if DeltaMY<0 then DeltaMY:=abs(DeltaMY+2*Pi) else DeltaMY:=abs(DeltaMY);
  if DeltaMZ<0 then DeltaMZ:=abs(DeltaMZ+2*Pi) else DeltaMZ:=abs(DeltaMZ);

  if DeltaXM<0 then DeltaXM:=abs(DeltaXM+2*Pi) else DeltaXM:=abs(DeltaXM);
  if DeltaYM<0 then DeltaYM:=abs(DeltaYM+2*Pi) else DeltaYM:=abs(DeltaYM);
  if DeltaZM<0 then DeltaZM:=abs(DeltaZM+2*Pi) else DeltaZM:=abs(DeltaZM);

  //����� ������� ���������
  IsX:=false;IsY:=false;IsZ:=false;
  if (DeltaMX<DeltaMY) and (DeltaMX<DeltaMZ) then IsX:=true;
  if (DeltaMY<DeltaMX) and (DeltaMY<DeltaMZ) then IsY:=true;
  if (DeltaMZ<DeltaMX) and (DeltaMZ<DeltaMY) then IsZ:=true;

  if (DeltaXM<DeltaYM) and (DeltaXM<DeltaZM) then IsX:=true;
  if (DeltaYM<DeltaXM) and (DeltaYM<DeltaZM) then IsY:=true;
  if (DeltaZM<DeltaXM) and (DeltaZM<DeltaYM) then IsZ:=true;

  SumXY:=1e7;SumXZ:=1e7;SumYZ:=1e7;
  if IsX and IsY then SumXY:=0;
  if IsX and IsZ then SumXZ:=0;
  if IsY and IsZ then SumYZ:=0;
  glLineWidth(2);                  //�������
  if (SumXY<SumXZ) and (SumXY<SumYZ) then begin
   frm1.rb_xy.checked:=true;
   frm1.rb_bxy.checked:=true;
   glColor3f(1,1,0);
   glBegin(GL_LINE_LOOP);
    glVertex3f(ccX,-ccY,ccZ);
    glVertex3f(ccX+10/CurView.Zoom,-ccY,ccZ);
    glVertex3f(ccX+10/CurView.Zoom,-ccY-10/CurView.Zoom,ccZ);
    glVertex3f(ccX,-ccY-10/CurView.Zoom,ccZ);
   glEnd;
  end else begin
   if (SumYZ<SumXZ) and (SumYZ<SumXY) then begin
    frm1.rb_yz.checked:=true;
    frm1.rb_byz.checked:=true;
    glColor3f(1,1,0);
    glBegin(GL_LINE_LOOP);
     glVertex3f(ccX,-ccY,ccZ);
     glVertex3f(ccX,-ccY-10/CurView.Zoom,ccZ);
     glVertex3f(ccX,-ccY-10/CurView.Zoom,ccZ+10/CurView.Zoom);
     glVertex3f(ccX,-ccY,ccZ+10/CurView.Zoom);
    glEnd;
   end else begin
    frm1.rb_xz.checked:=true;
    frm1.rb_bxz.checked:=true;
    glColor3f(1,1,0);
    glBegin(GL_LINE_LOOP);
     glVertex3f(ccX,-ccY,ccZ);
     glVertex3f(ccX+10/CurView.Zoom,-ccY,ccZ);
     glVertex3f(ccX+10/CurView.Zoom,-ccY,ccZ+10/CurView.Zoom);
     glVertex3f(ccX,-ccY,ccZ+10/CurView.Zoom);
    glEnd;
   end;//of subif
  end;//of if
 end;//of if
 EndRender;                       //��������� ����������
 PopFunction;
End;
//----------------------------------------------------------
//����� ���. ��������� ��� ����������� "��������".
//������������ �������� ���������� �����
procedure TWorkPlane.FindRot(x,y:integer);
Var i,indXY,indXZ,indYZ:integer; zm,MinXY,MinXZ,MinYZ:GLFloat;
Begin
 if (not IsXYZ) or (CountOfGeosets=0) then exit; //�� �������� ���������
 PushFunction(232);
 //����������� ������� ���������
 CalcAbsCircles;
 FindNearestPoint(x,y,indXY,indXZ,indYZ);
 MinXY:=abs(AbsXY[indXY,1]-x)+abs(AbsXY[indXY,2]-y);
 MinXZ:=abs(AbsXZ[indXZ,1]-x)+abs(AbsXZ[indXZ,2]-y);
 MinYZ:=abs(AbsYZ[indYZ,1]-x)+abs(AbsYZ[indYZ,2]-y);
 if (MinXY<MinXZ) and (MinXY<MinYZ) then begin
  frm1.rb_xy.checked:=true;
  frm1.rb_bxy.checked:=true;
 end else if (MinXZ<MinXY) and (MinXZ<MinYZ) then begin
  frm1.rb_xz.checked:=true;
  frm1.rb_bxz.checked:=true;
 end else begin
  frm1.rb_yz.checked:=true;
  frm1.rb_byz.checked:=true;
 end;

 //����� ����������
 zm:=1/CurView.Zoom;
 BeginRender;                     //������ ���������
 if frm1.rb_xy.checked then glColor3f(1,1,0)
 else glColor3f(0,0,1);
 glLineWidth(1);
 glBegin(GL_LINE_LOOP);
  for i:=0 to CIRCLE_SECTORS
  do glVertex3f(zm*CircleXY[i,1]+ccX,-(zm*CircleXY[i,2]+ccY),
                zm*CircleXY[i,3]+ccZ);
 glEnd;

 if frm1.rb_xz.checked then glColor3f(1,1,0)
 else glColor3f(0,1,0);
 glBegin(GL_LINE_LOOP);
  for i:=0 to CIRCLE_SECTORS
  do glVertex3f(zm*CircleXZ[i,1]+ccX,-(zm*CircleXZ[i,2]+ccY),
                zm*CircleXZ[i,3]+ccZ);
 glEnd;

 if frm1.rb_yz.checked then glColor3f(1,1,0)
 else glColor3f(1,0,0);
 glBegin(GL_LINE_LOOP);
  for i:=0 to CIRCLE_SECTORS
  do glVertex3f(zm*CircleYZ[i,1]+ccX,-(zm*CircleYZ[i,2]+ccY),
                zm*CircleYZ[i,3]+ccZ);
 glEnd;
 EndRender;                       //���������� ���������
 PopFunction;
End;
//----------------------------------------------------------
//�������������� ������ � ��������� ��������.
//������ ���������� ����� ������� ������������ ��������,
//���-������ � BeginRot
procedure TWorkPlane.PrepareForRotation(x,y:integer);
Begin
 PushFunction(233);
 CalcAbsCircles;
 FindNearestPoint(x,y,IndStartXY,IndStartXZ,IndStartYZ);
 PopFunction;
End;
//----------------------------------------------------------
//���������� ���� �������� ������ �����. ��� (+/-)
procedure TWorkPlane.FindAngles(x,y,OldMouseX,OldMouseY:integer;
                                var dax,day,daz:single);
Var Viewport:array[0..3] of GLfloat;
    mvMatrix,ProjMatrix:array[0..15] of GLdouble;
    wx,wy,wz,wx0,wy0,wz0:GlDouble;
    min,Delta:GLFloat;
    v,vend:TVertex;
    i,IMin:integer;
Begin
 PushFunction(234);
 if not IsXYZ then begin          //���������� ������
  dax:=0; day:=0; daz:=0;
  if frm1.rb_xy.checked then daz:=OldMouseX-x;
  if frm1.rb_xz.checked then day:=OldMouseX-x;
  if frm1.rb_yz.checked then dax:=OldMouseX-x;
  PopFunction;
  exit;
 end;//of if
 //1. ��������� �������� ���������� ������� ��
 //������� ���������
 glGetIntegerv(GL_VIEWPORT,@Viewport);
 glGetDoublev(GL_MODELVIEW_MATRIX,@mvMatrix);
 glGetDoublev(GL_PROJECTION_MATRIX,@ProjMatrix);
 gluUnProject(x,frm1.GLWorkArea.ClientHeight-y,-1,
              @mvMatrix,@ProjMatrix,@Viewport,wx,wy,wz);
 gluUnProject(OldMouseX,frm1.GLWorkArea.ClientHeight-OldMouseY,-1,
              @mvMatrix,@ProjMatrix,@Viewport,wx0,wy0,wz0);

 v[1]:=10*(wx-wx0);
 v[2]:=-10*(wy-wy0);
 v[3]:=10*(wz-wz0);
 if frm1.rb_xy.checked then v[3]:=0;
 if frm1.rb_xz.checked then v[2]:=0;
 if frm1.rb_yz.checked then v[1]:=0;

 //2. �������� ���� ������ �� ��������� (���������) �����.
 if frm1.rb_xy.checked then vend:=CircleXY[IndStartXY];
 if frm1.rb_xz.checked then vend:=CircleXZ[IndStartXZ];
 if frm1.rb_yz.checked then vend:=CircleYZ[IndStartYZ];
 vend[1]:=vend[1]+v[1];
 vend[2]:=vend[2]+v[2];
 vend[3]:=vend[3]+v[3];

 //3. ����� ����� ����������, ��������� � ����� �������.
 if frm1.rb_xy.checked then begin
  Min:=1e6; IMin:=0;
  for i:=0 to CIRCLE_SECTORS do begin
   Delta:=abs(CircleXY[i,1]-vend[1])+abs(CircleXY[i,2]-vend[2]);
   if Delta<Min then begin
    Min:=Delta;
    IMin:=i;
   end;//of if
  end;//of for i
 end else if frm1.rb_xz.checked then begin
  Min:=1e6; IMin:=0;
  for i:=0 to CIRCLE_SECTORS do begin
   Delta:=abs(CircleXZ[i,1]-vend[1])+abs(CircleXZ[i,3]-vend[3]);
   if Delta<Min then begin
    Min:=Delta;
    IMin:=i;
   end;//of if
  end;//of for i
 end else begin
  Min:=1e6; IMin:=0;
  for i:=0 to CIRCLE_SECTORS do begin
   Delta:=abs(CircleYZ[i,2]-vend[2])+abs(CircleYZ[i,3]-vend[3]);
   if Delta<Min then begin
    Min:=Delta;
    IMin:=i;
   end;//of if
  end;//of for i
 end;//of if

 //4. �������� ������� ����� (����� ������� ��������
 //���. ���� � ����� ����� �������).
 dax:=0;
 day:=0;
 daz:=0;
 if frm1.rb_xy.checked then daz:=-(IMin-IndStartXY)
 else if frm1.rb_xz.checked then day:=-(IMin-IndStartXZ)
 else dax:=-(IMin-IndStartYZ);
 if abs(dax)>20 then dax:=0;
 if abs(day)>20 then day:=0;
 if abs(daz)>20 then daz:=0;
 PopFunction;
End;
//==========================================================

//�������� �������
constructor TNInstrum.Create;
Begin
 inherited;
 VList:=TList.Create;
End;
//----------------------------------------------------------

//��������� ����������� "��������"
procedure TNInstrum.SetRotInstrum;
Var i,j,id:integer; n:TConstNormal;
    nrm:TMidNormal;
Begin
 PushFunction(379);
 VList.Clear;

 //1. ����� ������� � ConstNormals.
 //��� ���� � ������ VList ������ ID �����. ������� ConstNormals
 //���� ������� ��� � ������ - ������� � �� ����� �����������
 //�������� � ConstNormals � ������� � VList � ID.
 for j:=0 to CountOfGeosets-1 do if GeoObjs[j].IsSelected then begin
  for i:=0 to GeoObjs[j].VertexCount-1 do begin
   id:=FindConstNormal(j,GeoObjs[j].VertexList[i]-1);
   if id<0 then begin
    nrm.VertID:=GeoObjs[j].VertexList[i]-1;
    nrm.GeoID:=j;
    DeleteRecFromSmoothGroups(nrm);
    inc(COConstNormals);
    SetLength(ConstNormals,COConstNormals);
    id:=COConstNormals-1;
    n.GeoId:=j;
    n.VertID:=nrm.VertID;
    n.n:=Geosets[n.GeoID].Normals[n.VertID];
    ConstNormals[id]:=n;
   end;
   VList.Add(pointer(id));
  end;//of for i
 end;//of if/for j

 PopFunction;
End;

//----------------------------------------------------------
//������������ ������� ��������.
//[?������ VList ������ ���� �������� �������.]
//������� ��� ������ ������ ����� �� ���� -
//� ����������� �� ����, ����� ���� �� ����� 0
procedure TNInstrum.Rotate(dax,day,daz:single);
Var i:integer; n,nd:TNormal; nq:GLFloat;
Begin
 PushFunction(378);
 SetRotInstrum;                   //��������� ����������� ��������

 //����������� ���� ��������
 dax:=dax*0.01745;
 day:=day*0.01745;
 daz:=daz*0.01745;

 //� ����������� �� ����, ����� ���� �� ����� 0,
 //�������� ������� ��������, ��� ID ������� � ������
 if abs(dax)>=1e-3 then for i:=0 to VList.Count-1 do begin
  n:=ConstNormals[integer(VList.Items[i])].n;
  nd[2]:=n[2]*cos(dax)+n[3]*sin(dax);
  nd[3]:=n[3]*cos(dax)-n[2]*sin(dax);
  n[2]:=nd[2];
  n[3]:=nd[3];
  ConstNormals[integer(VList.Items[i])].n:=n;
 end else if abs(day)>=1e-3 then for i:=0 to VList.Count-1 do begin
  n:=ConstNormals[integer(VList.Items[i])].n;
  nd[1]:=n[1]*cos(day)+n[3]*sin(day);
  nd[3]:=n[3]*cos(day)-n[1]*sin(day);
  n[1]:=nd[1];
  n[3]:=nd[3];
  ConstNormals[integer(VList.Items[i])].n:=n;
 end else for i:=0 to VList.Count-1 do begin
  n:=ConstNormals[integer(VList.Items[i])].n;
  nd[1]:=n[1]*cos(daz)+n[2]*sin(daz);
  nd[2]:=n[2]*cos(daz)-n[1]*sin(daz);
  n[1]:=nd[1];
  n[2]:=nd[2];
  ConstNormals[integer(VList.Items[i])].n:=n;
 end;//of if

 //������������� ������� ������
 for i:=0 to VList.Count-1 do begin
  n:=ConstNormals[integer(VList.Items[i])].n;
  if abs(n[1])+abs(n[2])+abs(n[3])<1e-6 then n[1]:=1
  else begin
   nq:=1/sqrt(n[1]*n[1]+n[2]*n[2]+n[3]*n[3]);
   n[1]:=n[1]*nq;
   n[2]:=n[2]*nq;
   n[3]:=n[3]*nq;
  end;//of if
  ConstNormals[integer(VList.Items[i])].n:=n;
 end;//of for i

 PopFunction;
End;
end.
