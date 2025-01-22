unit un_obj;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ImgList, StdCtrls, mdlwork,frmmain,mdldraw,objedut;

type
  Tfrm_obj = class(TForm)
    lv_obj: TListView;
    il_spec: TImageList;
    cb_tree: TCheckBox;
    b_ok: TButton;
    procedure FormShow(Sender: TObject);
    procedure lv_objChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure FormActivate(Sender: TObject);
    procedure cb_treeClick(Sender: TObject);
    procedure lv_objDblClick(Sender: TObject);
    procedure lv_objMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure b_okClick(Sender: TObject);
    procedure lv_objKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lv_objEdited(Sender: TObject; Item: TListItem;
      var S: String);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    //���������������: ���� � ������ ���� ����� ������, ���
    //��� caption=s, �� ����������.
    procedure SelectLObject(s:string);
    //���������������: ���� � ������ ���� ������ � object=id,
    //�� �� ����������
    procedure SelectObjectByID(id:integer);
  public
    { Public declarations }
    //������ ������ ������������
    //TypeToAdd - ����� �������� ��� ����������:
    //-1 - �������� ������;
    //��������� - ID �������� (�������� ������)
    //���� ������ �������� ����, �������� ������������
    procedure MakeGeosetsList(TypeToAdd:integer);
    //�������� ���������� ������������
    procedure DeleteGeosets(Sender:TObject);
    //����������� ������ �������������������
    procedure MakeSequencesList;
    //�������� ���������� ������
    procedure DeleteSequences(Sender:TObject);
    //����� ����� �������� � ��������� �������
    //�� Sequences (��� ����� ������ � ������ ������)
    procedure ChangeSeqName(id:integer);
    //����� ����� ������� � ��������� ID
    //(���� ������� ���� � ������)
    procedure ChangeObjName(id:integer;NewName:string);
    //������ ������ �������� (�������) ��������,
    //���� ������� ����.
    //-1 - ��� �������,
    //��������� - �������� �������.
    //��� ������ ������ "��������" �������� ������������.
    //���� SelID>=0, �� ��������� �������� �������� ��������� ������
    procedure MakeObjectsList(id:integer;SelID:integer);
  end;

var
  frm_obj: Tfrm_obj;
  //���� ��������, ������������ � ������
  TypesOfObjects:integer;
  //���������� ������� ���� � ������
  LMouseX,LMouseY:integer;
  IsMayChange,                  //����� true, ����� ����������� �������������
  IsENTER:boolean;              //true, ����� ������ ENTER
const
  //��������� ���� ��������
  toSeqs=-1;
  toGeosets=0;
{  toBones=1;
  toAttachments=2;}
  toSkelObjs=1;
  //��������� ������
  LVM_ENSUREVISIBLE=$1000+19;
implementation

{$R *.DFM}
//���������������;
//���������� ��� �������� �� � ID
function GetNameByID(id:integer):string;
Begin
 if id<=-10 then begin            //WMO-������
  id:=-id-10;
  if id>=1000 then begin
   id:=id-1000;
   Result:='DOODADS'+inttostr(id);
  end else Result:='WMO'+inttostr(id);
  exit;
 end;//
 case id of
 -2:Result:='�����������';
  0:Result:='����';
  1:Result:='������';
  2:Result:='��������-A';
  3:Result:='��������-B';
  4:Result:='��������-C';
  5:Result:='��������-D';
  6:Result:='��������-E';
  7:Result:='��������-F';
  8:Result:='��������-G';
  9:Result:='��������-H';
  10..20:Result:='��������'+inttostr(id-10);
  101:Result:='����������';
  102..112:Result:='������'+inttostr(id-102);
  201:Result:='ٸ��';
  202:Result:='��������-1';
  203:Result:='��������-2';
  204:Result:='��������-3';
  205:Result:='��������-4';
  206:Result:='��������-5';
  207:Result:='��������-6';
  208:Result:='�������';
  301:Result:='������ ����';
  302:Result:='��������-A';
  303:Result:='��������-B';
  304:Result:='��������-C';
  305:Result:='��������-D';
  306:Result:='��������-E';
  307:Result:='��������-F';
  308:Result:='��������-G';
  309:Result:='��������-H';
  310:Result:='���';
  401:Result:='����������';
  402:Result:='��������1';
  403:Result:='��������2';
  404:Result:='��������3';
  501:Result:='������';
  502:Result:='������1';
  503:Result:='������2';
  504:Result:='������3';
  701:Result:='[�� �����]';
  702:Result:='���';
  802:Result:='������1';
  803:Result:='������2';
  902:Result:='����� ������1';
  903:Result:='����� ������2';
  1002:Result:='������ ���� ������';
  1102:Result:='�������� �����';
  1202:Result:='�������';
  1301:Result:='�����';
  1302:Result:='������� �����';
  1501:Result:='�����';
  1502:Result:='����� ������� ����';
  1503:Result:='������� ����';
  1504:Result:='������� ����';
  1505:Result:='�������� ����';
  1506:Result:='����� �������� ����';
  else Result:=inttostr(id);
 end; //of case
End;

//���������� �����������
procedure Tfrm_obj.FormShow(Sender: TObject);
begin
 if lv_obj.CanFocus then lv_obj.SetFocus;
 if lv_obj.tag>=0 then begin
  lv_obj.ItemFocused:=lv_obj.Items.Item[lv_obj.tag];
  SendMessage(lv_obj.Handle,LVM_ENSUREVISIBLE,lv_obj.tag,1);
 end else lv_obj.ItemFocused:=lv_obj.Selected;

 //��������: ����� �� �������� ������ "��������"
 if (EditorMode=emVertex) or (frm1.tc_mode.TabIndex<>1)
 then cb_tree.visible:=true
 else cb_tree.visible:=false;
end;

//���������������: ���� � ������ ���� ����� ������, ���
//��� caption=s, �� ����������.
procedure TFrm_obj.SelectLObject(s:string);
Var i:integer;
Begin
 for i:=0 to lv_obj.Items.Count-1 do if lv_obj.Items.Item[i].Caption=s
  then begin
   lv_obj.tag:=i;
   if lv_obj.CanFocus and frm_obj.visible then lv_obj.SetFocus;
   application.processmessages;
   lv_obj.ItemFocused:=lv_obj.Items.Item[i];
   lv_obj.Selected:=lv_obj.ItemFocused;
   SendMessage(lv_obj.Handle,LVM_ENSUREVISIBLE,lv_obj.tag,1);
   break;
 end;//of if/for i
End;

//���������������: ���� � ������ ���� ������ � object=id,
//�� �� ����������
procedure Tfrm_obj.SelectObjectByID(id:integer);
Var i:integer;
Begin
 for i:=0 to lv_obj.Items.Count-1 do if integer(lv_obj.Items.Item[i].Data)=id
  then begin
   lv_obj.tag:=i;
   if lv_obj.CanFocus and frm_obj.visible then lv_obj.SetFocus;
   application.processmessages;
   lv_obj.ItemFocused:=lv_obj.Items.Item[i];
   lv_obj.Selected:=lv_obj.ItemFocused;
   SendMessage(lv_obj.Handle,LVM_ENSUREVISIBLE,lv_obj.tag,1);
   break;
 end;//of if/for i
End;

//������ ������ ������������
//TypeToAdd - ����� �������� ��� ����������:
//-1 - �������� ������;
//��������� - ID �������� (�������� ������)
//���� ������ �������� ����, �������� ������������
procedure TFrm_obj.MakeGeosetsList(TypeToAdd:integer);
Var it:TListItem;len,i,ii:integer;
    lst:array of integer;
    IsPresent:boolean;
    s:string;
Begin
 //1. ����������, �� �������� �� ����
 s:='';
 if (TypesOfObjects=toGeosets) and (lv_obj.tag>=0) then begin
  s:=lv_obj.Items.Item[lv_obj.tag].Caption;
 end;//of if

 TypesOfObjects:=toGeosets;       //��������� ����
 lv_obj.Items.Clear;              //������� ������
 lv_obj.tag:=-1;
 //��������� ������ ��� ������ � �������������
 lv_obj.MultiSelect:=true;
 lv_obj.ReadOnly:=true;
 lv_obj.SortType:=stNone;

 //������� ����������� � ���� �������� ������
 if (not IsWoW) or (not cb_tree.checked) then begin
  for i:=0 to CountOfGeosets-1 do begin
   it:=lv_obj.Items.Add;
   it.Caption:='Geoset'+inttostr(i+1);
   it.Data:=pointer(i);           //GeosetID
   it.ImageIndex:=0;
   it.StateIndex:=0;
  end;//of for i
  //����� ������� ��� ���������
  SelectLObject(s);
  exit;
 end;//of if

//---------------------------------------------
 //������� ������������ � ���� ������ (��������)
 //A. �������� ������ (-1):
 if TypeToAdd=-1 then begin
  //1. ���������� ������ ��������
  SetLength(lst,CountOfGeosets);
  len:=0;
  for i:=0 to CountOfGeosets-1 do with Geosets[i] do begin
   //����: ��� �� ��� ����� ������
   IsPresent:=false;
   for ii:=0 to len-1 do if lst[ii]=HierID then begin
    IsPresent:=true;
    break;
   end;//of for ii

   if not IsPresent then begin
    inc(len);
    lst[len-1]:=HierID;
   end;//of if
  end;//of for i

  //2. �������� ��������� ������
  for i:=0 to len-1 do begin
   it:=lv_obj.Items.Add;
   it.Caption:=GetNameByID(lst[i]);
   it.Data:=pointer(lst[i]);      //ID ��������
   it.ImageIndex:=0;
   it.StateIndex:=2;
  end;//of for i
  lv_obj.tag:=-1;
  //���������� ��������� ������
  lv_obj.AlphaSort;
  
 end else begin                   //��������� ����� ������
  //1. ������� "��������" �������
  it:=lv_obj.Items.Add;           //������� 1-�� ��������
  it.Caption:=GetNameByID(TypeToAdd);//���
  it.Data:=pointer(TypeToAdd);    //ID ��������
  it.ImageIndex:=0;
  it.StateIndex:=3;

  //2. �������� ������ ������������
  for i:=0 to CountOfGeosets-1 do if Geosets[i].HierID=TypeToAdd then begin
   it:=lv_obj.Items.Add;
   it.Caption:='Geoset'+inttostr(i+1);
   it.Data:=pointer(i);           //GeosetID
   it.ImageIndex:=0;
   it.StateIndex:=0;
  end;//of if/for i
 end;//of if

 //����� ������� ��� ���������
 SelectLObject(s);
End;

//����������� ������ �������������������
procedure TFrm_obj.MakeSequencesList;
Var i:integer;it:TListItem;s:string;
Begin
 cb_tree.visible:=false;
 //0. ����������, �� �������� �� ����
 s:='';
 if (TypesOfObjects=toSeqs) and (lv_obj.tag>=0) then begin
  s:=lv_obj.Items.Item[lv_obj.tag].Caption;
 end;//of if

 TypesOfObjects:=toSeqs;          //��������� ���� ��������
 //1. ��������� ������ ��� ������ � ��������������������
 lv_obj.Items.Clear;
 lv_obj.MultiSelect:=true;
 lv_obj.ReadOnly:=false;          //����� �������������
 lv_obj.tag:=-1;
  
 //2. �������� ������ ������� �������������������
 //���������� ������������������ �� �����������
 for i:=0 to CountOfSequences-1 do with Sequences[i] do begin
  it:=lv_obj.Items.Add;           //�������� ����� �������
  it.Caption:=Name;
  it.Data:=pointer(i);            //ID ������������������
 end;//of with/for i

 //3. ���������� ������
 lv_obj.SortType:=stText;

 //4. ����� ������� ��� ���������
 SelectLObject(s);
End;

//��� ����� �������
procedure Tfrm_obj.lv_objChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
 if item.Selected then lv_obj.tag:=lv_obj.Items.IndexOf(item);
 if (TypesOfObjects=toSeqs) and
    (frm1.sb_stop.visible)  then frm1.sb_stopClick(Sender);
 if (TypesOfObjects=toSkelObjs) and
    (Change=ctState) and (integer(item.Data)>=0) and lv_obj.visible
    and item.Selected and IsMayChange
 then frm1.GraphSelectObject(integer(item.Data));
end;

//��� ���� ����������
procedure Tfrm_obj.FormActivate(Sender: TObject);
begin
 FormShow(Sender);
end;

//������� ������ "��������"
procedure Tfrm_obj.cb_treeClick(Sender: TObject);
begin
 //� ����������� �� ���� �������������� ��������
 //� �� ��������� �������
 if TypesOfObjects=toGeosets then begin //�����������
  //��������, ����� ��� ������ ����� �������
  if not cb_tree.checked then begin     //������� ������
   MakeGeosetsList(-1);
   exit;
  end;//of if

  //��������� ������
  if lv_obj.tag>=0 then begin     //���� ����������
   MakeGeosetsList(Geosets[integer(lv_obj.Items.Item[lv_obj.tag].Data)].HierID);
  end else begin
   MakeGeosetsList(-1);
  end;
  exit;
 end;//of if(toGeosets)
//----------------------------------------------
 if TypesOfObjects=toSkelObjs then begin //������� �������
  //��������, ����� ��� ������ ����� �������
  if not cb_tree.checked then begin     //������� ������
   MakeObjectsList(-1,-1);
   exit;
  end;//of if

  //��������� ������
  if lv_obj.tag>=0 then begin     //���� ����������
   MakeObjectsList(integer(lv_obj.Items.Item[lv_obj.tag].Data),-1);
  end else begin
   MakeObjectsList(-1,-1);
  end;
  exit;
 end;//of if
end;

//������� ���� �� �������
procedure Tfrm_obj.lv_objDblClick(Sender: TObject);
Var pt:TPoint;b:TBone;
begin
 //�������� ������ �������
 if not IsEnter then begin
  pt.x:=LMouseX;pt.y:=LMouseY;
  lv_obj.ItemFocused:=lv_obj.GetItemAt(LMouseX,LMouseY);
  lv_obj.Selected:=lv_obj.ItemFocused;
 end;//of if

 //� ��� ������ ���������
 case TypesOfObjects of
  toGeosets:begin
   //������ ���������
   if not cb_tree.checked then begin b_okClick(Sender);exit;end;
   //������������ ���� �� ������
   //1. ��������, �� "����� �����" �� ���
   if lv_obj.ItemFocused.StateIndex=3 then begin
    //�������� �������� ������
    MakeGeosetsList(-1);
    exit;
   end;//of if

   //2. ��� ����� ���� ������� ����� (���� � ������ ������������)
   if lv_obj.ItemFocused.StateIndex=2 then begin
    MakeGeosetsList(integer(lv_obj.ItemFocused.Data));
    exit;
   end;//of if

   if lv_obj.ItemFocused.StateIndex=0 then b_okClick(Sender);
  end;//of toGeosets
//--------------------------------------------------
  toSeqs:if lv_obj.SelCount=1 then b_okClick(Sender);
//--------------------------------------------------
  toSkelObjs:begin
   //���� ������ ��������� - �����
   if not cb_tree.checked then exit;

   //���� ��� - ����� "�����", ��������� �� �����. �������
   if lv_obj.ItemFocused.StateIndex=3 then begin
    //�������� �������� ������
    b:=GetSkelObjectByID(integer(lv_obj.ItemFocused.Data));
    MakeObjectsList(b.Parent,-1);
    exit;
   end;//of if

   //���� ��� - ������ � ���������, ���������� ���� (�� �������)
   if lv_obj.ItemFocused.StateIndex=2 then begin
    MakeObjectsList(integer(lv_obj.ItemFocused.Data),-1);
    exit;
   end;//of if

  end;//of toSkelObjs
 end;//of case
end;

//������������ ��������� ������� ����
procedure Tfrm_obj.lv_objMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 LMouseX:=x;LMouseY:=y;
end;

//��������� ��������
procedure Tfrm_obj.b_okClick(Sender: TObject);
Var i,ii:integer;
begin
 case TypesOfObjects of
  toGeosets:begin
   //1. ����� ��������� �� ���� ������������
   for i:=0 to CountOfGeosets-1 do frm1.clb_geolist.Checked[i]:=false;

   //2. ��������� ������������ � ������ ��������� ������
   if lv_obj.Items.Item[0].StateIndex=2 then begin
    for i:=0 to lv_obj.Items.Count-1 do if lv_obj.Items.Item[i].Selected
    then begin
     for ii:=0 to CountOfGeosets-1 do
      if Geosets[ii].HierID=integer(lv_obj.Items.Item[i].Data)
     then frm1.clb_geolist.Checked[ii]:=true;
    end;//of for i
    frm1.cb_showallClick(Sender);
    application.processmessages;
    if frm_obj.CanFocus then frm_obj.SetFocus;
    exit;
   end;//of if

   //3. ��������� ������������ � ������ � ��� ����� :)
   for i:=0 to lv_obj.Items.Count-1 do if (lv_obj.Items.Item[i].Selected)
   and (lv_obj.Items.Item[i].StateIndex=0) then begin
    frm1.clb_geolist.checked[integer(lv_obj.Items.Item[i].Data)]:=true;
   end;//of for i
   frm1.cb_showallClick(Sender);
   application.processmessages;
   if frm_obj.CanFocus then frm_obj.SetFocus;
  end;//of toGeoset
//---------------------------------------------------------
  toSeqs:begin                    //�������� ������������������
   if lv_obj.SelCount<>1 then exit;//������ ������� ����� ��������� ������
   //1. ������� ��� ������������������
   IsListDown:=true;
   //frm1.cb_animlist.tag:=integer(lv_obj.Selected.Data)+1;
   frm1.cb_animlist.ItemIndex:=AnimPanel.SeqList.IndexOfObject(lv_obj.Selected.Data);
   frm1.cb_animlistChange(Sender);
   //2. ���������� ����� ��������
   application.processmessages;
   if frm_obj.CanFocus then frm_obj.SetFocus;
   //3. ��������/��������� ��������
   if frm1.sb_play.visible then frm1.sb_playClick(Sender)
                           else frm1.sb_stopClick(Sender);
  end;//of toSeqs
//---------------------------------------------------------
  toSkelObjs:lv_objDblClick(Sender);
 end;//of case
end;

//�������� ������������
procedure Tfrm_obj.DeleteGeosets(Sender:TObject);
Var vt:integer;
Begin
 //1. ������� �����������
 b_okClick(Sender);
 //2. ������� ��� ����� ������������
 vt:=ViewType;
 frm1.CtrlA1Click(Sender);
 ViewType:=vt;
 //3. �������
 frm1.sb_delClick(Sender);
 //����������
 application.processmessages;
 if frm_obj.CanFocus then frm_obj.SetFocus;
End;

function SeqsSortProc(Item1, Item2: TListItem;
                       ParamSort: integer): integer; stdcall;
Begin
 Result:=integer(Item1.data)-integer(item2.Data);
End;

procedure Tfrm_obj.DeleteSequences(Sender:TObject);
Var i,j,jj,FStart,FEnd,cnt:integer;
    it:TListItem;nu:TUndoContainer;
    IsFirstUndo:boolean;
Begin
 cnt:=0;
 lv_obj.CustomSort(@SeqsSortProc,0);    //����������
// lv_obj.SortType:=stData;
 //�������� �� ���-�� �����������
 IsFirstUndo:=true;
 //���� �� ���� ���������� ��������� ������
 for i:=lv_obj.Items.Count-1 downto 0 do begin
  //���������, �� �������� �� ������ ������� ������
  //����������. ���� ���, ���������� ����
  if lv_obj.items.Item[i].Selected then it:=lv_obj.items.Item[i]
  else continue;
  //����, ���������� �������� �������. ������� � ��������:
  //1. ������� ��� �� (��������� � NewUndo ��� ������)
  FStart:=Sequences[integer(it.data)].IntervalStart;
  FEnd:=Sequences[integer(it.Data)].IntervalEnd;
  DeleteKeyFrames(FStart,FEnd);
  nu:=TUndoContainer.Create;      //������� ����� ������
  nu.TypeOfUndo:=uNDeleteSeqs;    //��� ������
  inc(cnt);
  if IsFirstUndo then begin
   IsFirstUndo:=false;
   nu.Prev:=-1;
  end else nu.Prev:=CountOfNewUndo-1;
  ReplaceTUndo(Undo[CountOfUndo],nu.Undo);
  inc(CountOfNewUndo);
  SetLength(NewUndo,CountOfNewUndo);
  NewUndo[CountOfNewUndo-1]:=nu;  //���������� � ������
  dec(CountOfUndo);               //��� ����������� �����������

  //2. ������� ���������� ��������
  SaveNewUndo(uDeleteSeq,integer(it.Data)); //����. ��� ������
  NewUndo[CountOfNewUndo-1].Prev:=0;
  AnimPanel.DelSeq(integer(it.Data));
{  AnimSaveUndo(uDeleteSeq,integer(it.data)+1);//��� ������
  nu:=TUndoContainer.Create;      //������� ���������
  inc(cnt);
  nu.TypeOfUndo:=uNDeleteSeqs;    //��� ������
  nu.Prev:=CountOfNewUndo-1;      //��������� �� ����������
  ReplaceTUndo(Undo[CountOfUndo],nu.Undo);//�������
  SetLength(nu.GeoU,CountOfGeosets);
  for j:=0 to CountOfGeosets-1 do
   ReplaceTUndo(Geoobjs[j].Undo[CountOfUndo],nu.GeoU[j]);
  dec(CountOfUndo);
  inc(CountOfNewUndo);
  SetLength(NewUndo,CountOfNewUndo);
  NewUndo[CountOfNewUndo-1]:=nu;    //������ ������ �������

//  num:=cb_animlist.tag-1;
  //��������
  for j:=integer(it.Data) to CountOfSequences-2 do Sequences[j]:=Sequences[j+1];
  dec(CountOfSequences);
  frm1.cb_animlist.items.Delete(integer(it.Data)+1);
  //�������� Anim �� ������������
  for j:=0 to CountOfGeosets-1 do with Geosets[j] do begin
   if CountOfAnims=0 then continue;
   for jj:=integer(it.Data) to CountOfAnims-2 do Anims[jj]:=Anims[jj+1];
   dec(CountOfAnims);
   SetLength(Anims,CountOfAnims);
  end;//of for j   }

 end;//of for i

 //������������� Undo
 inc(CountOfUndo);
 Undo[CountOfUndo].Status1:=uUseNewUndo;
 Undo[CountOfUndo].Status2:=cnt;  //���-�� ��������� ������
 //������ ��������� ������ ������
 MakeSequencesList;

 frm1.GraphSaveUndo;
{ frm1.sb_animundo.enabled:=true;
 frm1.CtrlZ1.enabled:=true;
 frm1.StrlS1.enabled:=true;
 frm1.sb_save.enabled:=true;}
 AnimPanel.MakeAnimList;
 frm1.cb_animlist.items.Assign(AnimPanel.SeqList);
// frm1.cb_animlist.text:='��� �������';
 frm1.cb_animlist.ItemIndex:=0;
 IsListDown:=true;
 frm1.cb_animlistChange(Sender);
End;

//����� ����� �������� � ��������� �������
//�� Sequences (��� ����� ������ � ������ ������)
procedure Tfrm_obj.ChangeSeqName(id:integer);
Var i:integer;
Begin
 for i:=0 to lv_obj.Items.Count-1 do
     if integer(lv_obj.Items.Item[i].Data)=id then begin
      lv_obj.Items.Item[i].Caption:=Sequences[id].Name;
      exit;
 end;//of if/for i
End;

//����� ����� ������� � ��������� ID
//(���� ������� ���� � ������)
procedure Tfrm_obj.ChangeObjName(id:integer;NewName:string);
Var i:integer;
Begin
 for i:=0 to lv_obj.Items.Count-1 do
     if integer(lv_obj.Items.Item[i].Data)=id then begin
      lv_obj.Items.Item[i].Caption:=NewName;
      exit;
 end;//of if/for i
End;

//������ ������ �������� (�������) ��������,
//���� ������� ����.
//-1 - ��� �������,
//��������� - �������� �������.
//��� ������ ������ "��������" �������� ������������.
//���� SelID>=0, �� ��������� �������� �������� ��������� ������
procedure Tfrm_obj.MakeObjectsList(id:integer;SelID:integer);
Var i:integer;it:TListItem;b:TBone;
Begin
 IsMayChange:=false;
 if SelID<0 then begin
  if lv_obj.tag>=0 then SelID:=integer(lv_obj.Items.Item[lv_obj.tag].data)
  else SelID:=-1;
 end;//of if
 lv_obj.Items.Clear;              //������� ������
 lv_obj.SortType:=stNone;         //���������� �� �����
 cb_tree.visible:=true;           //�������� ���� ��������
 lv_obj.MultiSelect:=false;       //������� �.�. ������ 1 ������
 lv_obj.ReadOnly:=false;          //����� �������� ����� ������
 TypesOfObjects:=toSkelObjs;      //������� �������
 if not cb_tree.checked then begin //��� ������ "��������"
  //�������� ������� ����� �� �� ������ (����������������)
  if frm1.cb_bonelist.Items.count=0 then begin //��� ��������
   frm_obj.Hide;
   exit;
  end;//of if
  for i:=0 to frm1.cb_bonelist.Items.count-1 do begin
   it:=lv_obj.Items.Add;
   it.Caption:=frm1.cb_bonelist.Items.Strings[i];
   it.Data:=pointer(frm1.cb_bonelist.Items.Objects[i]);
   //�������� ��� �������
   case GetTypeObjByID(integer(it.Data)) of
    typBONE,typHELP:it.ImageIndex:=4;
    typATCH:it.ImageIndex:=5;
    typPRE2:it.ImageIndex:=6;
    else it.ImageIndex:=0;
   end;//of case
   it.StateIndex:=0;
  end;//of for i
//---------------------------------------------------------
 end else begin                    //"�������� ��������"
  //1. ������ ������ �������� � ��������� ���������
  if id>=0 then begin             //���� ������� ����
   b.Parent:=id;
   repeat                         //���� ���������� (�������)
    it:=lv_obj.Items.Insert(0);   //�������� � ����� ������
    b:=GetSkelObjectByID(b.Parent);
    it.Caption:=b.Name;
    it.Data:=pointer(b.ObjectID);
    it.StateIndex:=3;
    case GetTypeObjByID(b.ObjectID) of
     typBONE,typHELP:it.ImageIndex:=4;
     typATCH:it.ImageIndex:=5;
     typPRE2:it.ImageIndex:=6;
     else it.ImageIndex:=0;
    end;//of case
   until b.Parent<0;
  end;//of if (id>=0)

  //������ ��������� ��� �������� (���� ����) �� ������.
  //� ������ (-1) ��������� ������ ���
  for i:=0 to frm1.cb_bonelist.Items.Count-1 do begin
   b:=GetSkelObjectByID(integer(frm1.cb_bonelist.Items.Objects[i]));
   //����������� ������ ������������ ������� (���� id<0 - ��� �������)
   if (id<0) or (b.Parent=id) then begin
    it:=lv_obj.Items.Add;
    it.Caption:=b.Name;
    it.Data:=pointer(b.ObjectID);
    if b.Parent<0 then it.StateIndex:=0 else it.StateIndex:=2;
    case GetTypeObjByID(b.ObjectID) of
     typBONE,typHELP:it.ImageIndex:=4;
     typATCH:it.ImageIndex:=5;
     typPRE2:it.ImageIndex:=6;
     else it.ImageIndex:=0;
    end;//of case
   end;//of if
  end;//of for i
 end;//of if

 //�, �������, �������� ������ (���� ����)
 SelectObjectByID(SelID);
 application.processmessages;
 IsMayChange:=true;
End;


//��������� ������� ENTER
procedure Tfrm_obj.lv_objKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if (key<>VK_RETURN) and (key<>VK_DELETE) then begin
  frm1.FormKeyDown(Sender,Key,Shift);
  exit;
 end;
 if key=VK_DELETE then begin
  if TypesOfObjects=toGeosets then DeleteGeosets(Sender);
  if TypesOfObjects=toSeqs then DeleteSequences(Sender);
  if TypesOfObjects=toSkelObjs then frm1.sb_objdelClick(Sender);
  exit;
 end;//of if

 case TypesOfObjects of
  toGeosets:begin
   //����������
   if not cb_tree.checked then b_okClick(Sender)//���������
   else begin
    //1. ������� ��������� - ��������
    if lv_obj.SelCount>1 then begin b_okClick(Sender);exit;end;
    //������ 1 �������. ��������, ��� ���
    if (lv_obj.Selected.StateIndex=3)
    or (lv_obj.Selected.StateIndex=2) then begin
     IsENTER:=true;
     lv_objDblClick(Sender);
     IsENTER:=false;
     exit;
    end;
    //������� �����������. ��������.
    b_okClick(Sender);
   end;//of else
  end;//of toGeosets
//--------------------------------
  toSeqs:b_okClick(Sender);
//--------------------------------
  toSkelObjs:if (lv_obj.Selected<>nil)
   and ((lv_obj.Selected.StateIndex=3)
   or (lv_obj.Selected.StateIndex=2)) then begin
    IsENTER:=true;
    lv_objDblClick(Sender);
    IsENTER:=false;
    exit;
  end;//of toSkelObjs
 end;//of case
end;

//�������� ��� �������
procedure Tfrm_obj.lv_objEdited(Sender: TObject; Item: TListItem;
  var S: String);
begin
 case TypesOfObjects of
  toSeqs:begin
   //0. �������� ��� ������
   AnimSaveUndo(uSeqPropChange,AnimPanel.ids);
   frm1.GraphSaveUndo;

   //1. ������� ��� ������������������ � �������� ���
   AnimPanel.SelSeq(item.Data);
   AnimPanel.Seq.Name:=s;
   AnimPanel.SSeq;                //����� �����

   //2. ���������� ������ ������
   AnimPanel.MakeAnimList;
   frm1.cb_animlist.items.Assign(AnimPanel.SeqList);
   frm1.cb_animlist.ItemIndex:=AnimPanel.GSelSeqIndex;
   frm1.cb_animlistChange(Sender);
{   IsListDown:=true;
   frm1.cb_animlist.tag:=integer(Item.Data)+1;
   frm1.cb_animlist.ItemIndex:=integer(Item.Data)+1;
   frm1.cb_animlistChange(Sender);
   //2. ������ � ���
   frm1.cb_animlist.text:=s;
   frm1.cb_animlistExit(Sender);
   lv_obj.tag:=-1;
   //3. ����� ���������� ���� �������
   application.processmessages;
   if frm_obj.CanFocus then frm_obj.SetFocus;}
  end;//of toSeqs

  toSkelObjs:begin                //����� ����� ���������� �������
   frm1.cb_bonelist.text:=s;      //������ �����
   frm1.time_lvChng.enabled:=true;     //���...
  end;//of toSkelObjs
 end;//of case
end;

//��������� �������� (��� ����������)
procedure Tfrm_obj.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Shift=[ssCtrl] then begin
{  if ((key=ord('z')) or (key=ord('Z')) or (key=ord('�')) or (key=ord('�')))
     and  frm1.CtrlZ1.enabled then frm1.CtrlZ1Click(Sender);}
  if AnimEdMode=0 then begin      //�������� �������
   frm1.FormKeyDown(Sender,Key,Shift);
  end;//of if
 end;//of if
end;

initialization
 IsMayChange:=true;
 TypesOfObjects:=toGeosets;
 IsENTER:=false;
 LMouseX:=0;LMouseY:=0;
end.
