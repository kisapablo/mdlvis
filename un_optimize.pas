unit un_optimize;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CheckLst;

type
  Tfrm_optimize = class(TForm)
    clb_actions: TCheckListBox;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    ed_action: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure clb_actionsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frm_optimize: Tfrm_optimize;

implementation
const descr:array[0..6] of string=(
'MdlVis ����� ������� � ����� ������ �������������� ���������� - ��������, '+
'� ������� ����������� ��� ��������. ��� �������� ������� ����� '+
'����������. ��� ���� ������ ���������� ���� ������ � ������ '+
'��������� (��������, ����������) ����� � ���������.',

'��������� ���������� ������� "�����������->��������������". ��� �������� '+
'��������� ������ � WoW-�������. ��� ������� ����� ������������ ������.',

'����� �������� ������/������������� ����� �������� ��������� ������� - '+
'�.�. �������, �� �������� �� � ���� �����������. ��������� ��� �� ����� �� '+
'������������ � Warcraft''e, �� ����� ���������������� �������.',

'����� �������� ����� ��������� ����� �������� �����, � ������� �� �������� '+
'�� ����� ������� � �� ������ �������. ����� ����� ������ �������� ������ '+
'�����, � ��� �������� ������� �� ������ � ���������������� ��.',

'����� ������ ��� ������������ �������� ����� �������� ��, ������� �� '+
'�������� �� � ���� ��������. ��� �������� ������� ����� �� (� ������ ������� '+
'WoW, ���������� ��������� ��������, ������� ����� ������ 7-10 ������).',

'��������� ��� �������� ������ � �������� �����. ����������� � ������� WoW. '+
'��������� ����������� (������ ���� � 2 ����) ��������� ������ ������ '+
'(��� �������, ��� ��� �������� ��������� ���������� ������������) �� ���� '+
'���������� �������� �������� ��������.',

'����� ����� ���������� ����� �������� ������ ���������� ��������� ��� MDX, '+
'����� ���� ������ ����������. ����� ����� ������ ������ ����������� ��������� '+
'��� ��������� (��� ������ �� ����� �������� - zip, rar, MPQ � ��.)'
);
{$R *.DFM}

procedure Tfrm_optimize.FormCreate(Sender: TObject);
begin
 clb_actions.State[0]:=cbChecked;
 clb_actions.State[1]:=cbChecked;
 clb_actions.State[2]:=cbChecked;
 clb_actions.State[3]:=cbChecked;
 clb_actions.State[4]:=cbChecked;
end;

procedure Tfrm_optimize.Button1Click(Sender: TObject);
begin
 frm_Optimize.ModalResult:=mrOK;
 frm_optimize.Hide;
end;

procedure Tfrm_optimize.Button2Click(Sender: TObject);
begin
 frm_optimize.ModalResult:=mrCancel;
 frm_optimize.Hide;
end;

//����� �����. ������ (�������� ��������)
procedure Tfrm_optimize.clb_actionsClick(Sender: TObject);
begin
 ed_action.Lines.text:=descr[clb_actions.ItemIndex];
end;

end.
