//�������� ��������� ��� ������� ������ ������
//� ������ ������ �������
unit Real3D;

interface
uses windows,messages,OpenGL,mdlWork,mdlDraw,objedut,math,crash;
type TSortPrimitive=record        //���: ��������
 GeoNum:integer;                   //����� �����������
 Z:GLfloat;                        //������� ���������
 num:array [1..3] of integer;      //������ ������
end;//of type
TSPArray=array of TSortPrimitive; //���: ������ ��� ����������
//�������������� ���� �����/������������/���������
//� ���������� � ������������.
//������������ ��� ���������� � ��������� ������
procedure InitMatTransp;
//������� ������ ���� ������, ������� �������� �����.
//procedure Make3DListFill(dc:hdc;hrc:hglrc;flags:integer);
//��������� ������ ���������� ��� ����������� ����������
//procedure FormPrimitives({dc:hdc;hrc:hglrc;}ClientHeight:integer);
//������������� Z-���������� ���������� ������ ����������
//procedure ReFormPrimitives({dc:hdc;hrc:hglrc;}ClientHeight:integer);
//��������� ��������� ������ ���������� �� Z-����������
procedure SortPrimitives(var PrSorted:TSPArray;PrLength:integer);
//��������� ������ ���������� ��� �������� - �.�. �� �����,
//� �� �� ����������.
procedure AFormPrimitives(ClientHeight:integer);
//�� �� �����, ������ ��������������
procedure AReFormPrimitives(ClientHeight:integer);
//��������� ������ 3D �� �����.
//�������� ������ ����� ���, �������� � ������ �����������
//����� ��������� "�������" Make3DListFill
procedure AMake3DListFill;

Var PrSorted1,PrSorted2:TSPArray;//������������� ���������
    //1 - ��� ��������� (Blend), 2-��� �������(Additive)
    PrLength1,PrLength2:integer;  //����� �������� � ����
    pts1,pts2:cardinal;           //���������������
implementation
//�������������� ���� �����/������������/���������
//� ���������� � ������������.
//������������ ��� ���������� � ��������� ������
procedure InitMatTransp;
Var i,ii:integer;
Begin
 for i:=0 to CountOfGeosets-1 do begin
  Geosets[i].Color4f[1]:=1;
  Geosets[i].Color4f[2]:=1;
  Geosets[i].Color4f[3]:=1;
  Geosets[i].Color4f[4]:=1;
 end;//of for i

 for i:=0 to CountOfMaterials-1 do for ii:=0 to Materials[i].CountOfLayers-1
 do with Materials[i].Layers[ii] do begin
  AAlpha:=1;
  ATextureID:=TextureID;
 end;//of with/for ii/i
End;
//----------------------------------------------------------

//Var i:integer;
//���������������: ������������ ���������� ������ �� �������
procedure Draw3DPartFromArray(var PrSorted:TSPArray;PrLength:integer);
Var StIndex,gn,PrN:integer;//ts1,ts2:cardinal;
Begin
  if PrLength=0 then exit;        //������ ��������
  PushFunction(360);
  //������!!!
  StIndex:=0;                     //��������� ������ �����
  repeat                          //�������� ���� (PrSorted)
   PrN:=StIndex;                  //�� �� ������
   Gn:=PrSorted[PrN].GeoNum;      //����������� ���������
   //���������� �������� ���������
   glBindTexture(GL_TEXTURE_2D,Materials[Geosets[Gn].MaterialID].ListNum);
   //����� �����������������
   glColor4f(Geosets[gn].Color4f[1],Geosets[gn].Color4f[2],
             Geosets[gn].Color4f[3],Geosets[gn].Color4f[4]);
   if Geosets[gn].Color4f[4]<0.01 then glColor4f(0,0,0,0);

   //��������� �������� ������
   glVertexPointer(3,GL_FLOAT,0,@Geosets[Gn].Vertices[0]);
   glNormalPointer(GL_FLOAT,0,@Geosets[Gn].Normals[0]);
   glTexCoordPointer(2,GL_FLOAT,0,@Geosets[Gn].Crds[0].TVertices[0]);

   glBegin(GL_TRIANGLES);           //���������
   repeat                           //���� ������ �������������
    with PrSorted[PrN] do begin//�����������
     glArrayElement(num[1]);
     glArrayElement(num[2]);
     glArrayElement(num[3]);
    end;//of with
    inc(PrN);
   until (PrSorted[PrN].GeoNum<>gn) or (PrN>PrLength-1);//�� ����� �����
   glEnd;
   StIndex:=PrN;                  //��������� �����
  until PrN>PrLength-1;             //�������� ����
  PopFunction;
End;

//���������������: ������������ ���������� ������ �� �������
//������������ ��� ��������
procedure ADraw3DPartFromArray(var PrSorted:TSPArray;PrLength:integer;
                               IsMultAlpha:boolean);
Var StIndex,{j,}gn,PrN,lrNum,CurCrdID,MatrixID:integer;
    a:GLFloat;
    IsAddAlpha:boolean;           //true, ���� ���������� ����� AddAlpha
Begin
  IsAddAlpha:=false;              //���� ����� ����� �� ���.
  if PrLength=0 then exit;        //������ ��������
  PushFunction(361);
  //������!!!
  StIndex:=0;                     //��������� ������ �����
  MatrixID:=-1;                   //���� ��� ���������� �������
  repeat                          //�������� ���� (PrSorted)
   PrN:=StIndex;                  //�� �� ������
   Gn:=PrSorted[PrN].GeoNum and $FFFF;//����������� ���������
   lrNum:=PrSorted[PrN].GeoNum shr 16;//����� ����
   with Materials[Geosets[Gn].MaterialID].Layers[lrNum] do begin
    //���������� �������� ���� ���������
    glBindTexture(GL_TEXTURE_2D,Textures[ATextureID].ListNum);
    //����� �����������������
    if IsMultAlpha then begin
     a:={0.5*}AAlpha;
     //!dbg: "�������" �����
     if Materials[Geosets[Gn].MaterialID].CountOfLayers>1 then a:=0.1*a;
    end else a:={0.5}1;//of if
    glColor4f(Geosets[gn].Color4f[1]*a,Geosets[gn].Color4f[2]*a,
              Geosets[gn].Color4f[3]*a,
              AAlpha*Geosets[gn].Color4f[4]);
    //��������� �� ���������:
    if IsLight then
    if IsUnshaded then glDisable(GL_LIGHTING)
                  else begin glEnable(GL_LIGHTING);glEnable(GL_LIGHT0);end;
    //��������� ��������� ������ �������������
    if IsTwoSided then glDisable(GL_CULL_FACE)
                  else glEnable(GL_CULL_FACE);
    //��������� ������ ��������
    if (IsAddAlpha xor (FilterMode=AddAlpha)) then begin
     IsAddAlpha:=not IsAddAlpha;
     if IsAddAlpha then glBlendFunc(GL_SRC_ALPHA,GL_ONE)
                   else glBlendFunc(GL_ONE,GL_ONE);
    end;//of if
    //��������� ������ CoordID
    if CoordID>=0 then CurCrdID:=CoordID else CurCrdID:=0;
    //��������� ���������� ������� (���� �����)
    if (TVertexAnimID>=0) and (TVertexAnimID<>MatrixID) then begin
     glLoadMatrixd(@TexMatrix);
     MatrixID:=TVertexAnimID;
    end;//of if
    if (TVertexAnimID<0) and (MatrixID<>-1) then begin
     glLoadIdentity;
     MatrixID:=-1;
    end;//of if
   end;//of with

   //��������� �������� ������
   glVertexPointer(3,GL_FLOAT,0,@Geosets[Gn].Vertices[0]);
   glNormalPointer(GL_FLOAT,0,@Geosets[Gn].Normals[0]);
   glTexCoordPointer(2,GL_FLOAT,0,@Geosets[Gn].Crds[CurCrdID].TVertices[0]);

   glBegin(GL_TRIANGLES);           //���������
   repeat                           //���� ������ �������������
    //�����������
    with PrSorted[PrN] do begin
     glArrayElement(num[1]);
     glArrayElement(num[2]);
     glArrayElement(num[3]);
    end;//of with
    inc(PrN);
   until (PrSorted[PrN].GeoNum<>gn) or (PrN>PrLength-1);//�� ����� �����
   glEnd;
   StIndex:=PrN;                  //��������� �����
  until PrN>PrLength-1;             //�������� ����
  PopFunction;
End;

//���������������: ������ ����� ��� 3D-����
//����� �� �������� ������ � ����������� ���� ������
procedure Draw3DGrid;
Var i:integer;ccX,ccY,ccZ:GLFloat;
Begin
 PushFunction(362);
 glEnable(GL_LIGHTING);           //������������
 glEnable(GL_LIGHT0);
 glEnable(GL_LIGHT1);

 //0. ����������� ������
 if CurrentListNum<>-1 then glDeleteLists(CurrentListNum,1);
 CurrentListNum:=glGenLists(1);
 //������ ������
 glNewList(CurrentListNum,gl_compile);
//  glClearColor(0.5,0.5,0.5,1);
  glClearColor(0.8,0.8,0.8,1.0);//���� ����
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);//�������
  glDisable(GL_LIGHTING);
 //0.1. ������� ��� ���������
 glLineWidth(2.5);           //������� �����
 if IsAxes then begin
  glBegin(GL_LINES);          //�����
   glColor3f(1.0,0,0);        //������� ����
   glVertex3f(-200,0,0);
   glVertex3f(200,0,0);
   glColor3f(0,1,0);          //��� y
   glVertex3f(0,-200,0);
   glVertex3f(0,200,0);
   glColor3f(0,0,1);
   glVertex3f(0,0,-200);
   glVertex3f(0,0,200);
  glEnd;
  glLineWidth(5);
  glBegin(GL_LINES);
   glVertex3f(0,0,200);
   glVertex3f(0,0,210);
   glColor3f(1,0,0);
   glVertex3f(200,0,0);
   glVertex3f(210,0,0);
   glColor3f(0,1,0);
   glVertex3f(0,200,0);
   glVertex3f(0,210,0);
  glEnd;
 end;//of if (��� ���������)
 //������ �����
 glLineWidth(1);
 if IsLowGrid then begin
  glColor3f(0.5,0.5,0.5);//glLineWidth(1);
  glBegin(GL_LINES);
   if IsXYGrid then for i:=-32 to 32 do begin
    glVertex3f(i*8,-256,0);
    glVertex3f(i*8,256,0);
    glVertex3f(-256,i*8,0);
    glVertex3f(256,i*8,0);
   end;//of for
   if IsXZGrid then for i:=-32 to 32 do begin //��� ���� �����
    glVertex3f(i*8,0,-256);
    glVertex3f(i*8,0,256);
    glVertex3f(-256,0,i*8);
    glVertex3f(256,0,i*8);
   end;//of for/if
  if IsYZGrid then for i:=-32 to 32 do begin //��� ���� �����
   glVertex3f(0,i*8,-256);
   glVertex3f(0,i*8,256);
   glVertex3f(0,-256,i*8);
   glVertex3f(0,256,i*8);
  end;//of for/if
  glEnd;
 end;//of if
 //0.2. ������� ����� XY
 glColor3f(0,0,0);glLineWidth(1);
 glBegin(GL_LINES);
  if IsXYGrid then for i:=-4 to 4 do begin
   glVertex3f(i*64,-256,0);
   glVertex3f(i*64,256,0);
   glVertex3f(-256,i*64,0);
   glVertex3f(256,i*64,0);
  end;//of for/if
  if IsXZGrid then for i:=-4 to 4 do begin //��� ���� �����
   glVertex3f(i*64,0,-256);
   glVertex3f(i*64,0,256);
   glVertex3f(-256,0,i*64);
   glVertex3f(256,0,i*64);
  end;//of for/if
  if IsYZGrid then for i:=-4 to 4 do begin //��� ���� �����
   glVertex3f(0,i*64,-256);
   glVertex3f(0,i*64,256);
   glVertex3f(0,-256,i*64);
   glVertex3f(0,256,i*64);
  end;//of for/if
 glEnd;
 //����� ��������� ���� �-�
 if IsXYZ then DrawXYZ;
 if IsNormals then begin
  glScalef(1.0,-1.0,1.0);
  DrawNormals;
  glScalef(1.0,-1.0,1.0);
 end;//of if
 PopFunction;
End;

//������� ������ ���� ������, ������� �������� �����.
(*procedure Make3DListFill(dc:hdc;hrc:hglrc;flags:integer);
Var i,ii{,j},gn,len:integer;
Begin
 PushFunction(363);
 Draw3DGrid;
 glScalef(1.0,-1.0,1.0);          //��������� ������� ���������
 glEnableClientState(GL_VERTEX_ARRAY);
 glEnableClientState(GL_NORMAL_ARRAY);
 //1. ������� ���������/������������
 if IsLight then glEnable(GL_LIGHTING);//������������
 glEnable(GL_LIGHT0);
 glEnable(GL_COLOR_MATERIAL);
// glEnable(GL_POLYGON_SMOOTH);//����������� �������������
 glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);//� ��������
 if (flags and 1)<>0 then begin   //���� ��� - ������ ���
  glDepthFunc(GL_LEQUAL);
  glEnable(GL_TEXTURE_2D);        //��������
 end;//of if

 if (flags and 1)<>0 then begin  //���� ��� - ������ ���
  //1. ����� �������� ������������
  glAlphaFunc(GL_GEQUAL,0.75);
  glEnable(GL_DEPTH_TEST);        //���������� ����� �������
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);//���������� ������
  //���������� ���� ������
  for gn:=0 to CountOfGeosets-1 do begin
   //���������� ���������, ������ ���� ��������
   if VisGeosets[gn]=false then continue;
   if (Materials[Geosets[Gn].MaterialID].TypeOfDraw<>Opaque) and
      (Materials[Geosets[Gn].MaterialID].TypeOfDraw<>ColorAlpha) then continue;
//   RecalcNormals(gn+1);           //������ ��������
   glColor4f(Geosets[gn].Color4f[1],Geosets[gn].Color4f[2],
             Geosets[gn].Color4f[3],Geosets[gn].Color4f[4]);
   if Geosets[gn].Color4f[4]<0.01 then continue;
   //���������� �������� ���������
   glBindTexture(GL_TEXTURE_2D,Materials[Geosets[Gn].MaterialID].ListNum);
   //���������� ������ ��������� - � ��������� ����� ��� ���
   if Materials[Geosets[Gn].MaterialID].TypeOfDraw=ColorAlpha then
    glEnable(GL_ALPHA_TEST)
   else glDisable(GL_ALPHA_TEST);

   //���������� ��������� �� ������ ������
   glVertexPointer(3,GL_FLOAT,0,@Geosets[Gn].Vertices[0]);
   glNormalPointer(GL_FLOAT,0,@Geosets[Gn].Normals[0]);
   glTexCoordPointer(2,GL_FLOAT,0,@Geosets[gn].Crds[0].TVertices[0]);
   glBegin(GL_TRIANGLES);         //���������
    for i:=0 to Geosets[Gn].CountOfFaces-1 do begin
     len:=length(Geosets[Gn].Faces[i])-1;
     for ii:=0 to len do glArrayElement(Geosets[Gn].Faces[i,ii]);
    end;//of for i
   glEnd;
  end;//of for (gn)

  //2. ����� ����������� ������������
  glDisable(GL_ALPHA_TEST);
  glEnable(GL_BLEND);             //�������� ��������
  glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);//��������
  glDepthMask(false);
  Draw3DPartFromArray(PrSorted1,PrLength1);//����� �������

  //3. ����� ���������� ��������
  glBlendFunc(GL_ONE,GL_ONE);
  Draw3DPartFromArray(PrSorted2,PrLength2);//����� �������
  glDepthMask(true);

  //4. ����� ������ (���� �����):
  glDisable(GL_LIGHTING);
  glDisable(GL_BLEND);
  glDisable(GL_TEXTURE_2D);
  if (flags and 4)<>0 then InternalDrawVertices;
  glScalef(1.0,-1.0,1.0);
  glDisableClientState(GL_NORMAL_ARRAY);
  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
//--------------------------------
 end else begin//of if
  glCullFace(GL_BACK);
  if (flags and 2)=0 then for gn:=0 to CountOfGeosets-1 do begin
   RecalcNormals(gn+1);           //������ ��������
   SmoothWithNormals(gn);
   ApplySmoothGroups;
  end;//of if
  for gn:=CountOfGeosets downto 1 do begin
   if VisGeosets[gn-1]=false then continue;
{   if (flags and 2)=0 then begin
    RecalcNormals(gn);              //������ ��������
    SmoothWithNormals(gn-1);
    ApplySmoothGroups;
   end;}
   if Materials[Geosets[gn-1].MaterialID].Layers[0].IsTwoSided
   then glDisable(GL_CULL_FACE)
   else glEnable(GL_CULL_FACE);
   glColor3f(1.0,0.6,0.6);          //����

   glVertexPointer(3,GL_FLOAT,0,@Geosets[Gn-1].Vertices[0]);
   glNormalPointer(GL_FLOAT,0,@Geosets[Gn-1].Normals[0]);
   glBegin(GL_TRIANGLES);           //���������
   for i:=0 to Geosets[Gn-1].CountOfFaces-1 do
   for ii:=0 to length(Geosets[Gn-1].Faces[i])-1 do begin
    glArrayElement(Geosets[Gn-1].Faces[i,ii]); //����� �������
   end;//of for ii/i
   glEnd;
  end;//of for gn
  glDisable(GL_CULL_FACE);
  //����� ������ (���� �����):
  glDisable(GL_LIGHTING);
  glDisable(GL_BLEND);
  glDisable(GL_TEXTURE_2D);
  if (flags and 4)<>0 then InternalDrawVertices;
  glScalef(1.0,-1.0,1.0);
  glDisableClientState(GL_NORMAL_ARRAY);
  if AnimEdMode<>1 then begin
   glDisable(GL_LIGHTING);        //����� ������������
   glDisable(GL_DEPTH_TEST);      //��������� ���� �������
   glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);
   glLineStipple(1,$1C47);
   DrawObjects(false);            //����� �������� (��������)
   glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
   glEnable(GL_DEPTH_TEST);
   DrawObjects(true);             //����� �������� (��������)
  end;//of if
 end;//of if

 if (flags and 1)<>0 then begin   //���� ��� - ������ ���
  glDisable(GL_BLEND);             //����� ��������
  glDisable(GL_TEXTURE_2D);        //��������
 end;//of if
 glEndList;                       //����� ������
// pts2:=GetTSC-pts1;
  PopFunction;
End;             *)
//---------------------------------------------------------
//����� �����������
procedure RenderSurface;
Var gn,i,ii:integer;
Begin
  glCullFace(GL_BACK);
  {if (flags and 2)=0 then} for gn:=0 to CountOfGeosets-1 do begin
   RecalcNormals(gn+1);           //������ ��������
   SmoothWithNormals(gn);
   ApplySmoothGroups;
  end;//of for gn/if
  for gn:=CountOfGeosets downto 1 do begin
   if VisGeosets[gn-1]=false then continue;
   if Materials[Geosets[gn-1].MaterialID].Layers[0].IsTwoSided
   then glDisable(GL_CULL_FACE)
   else glEnable(GL_CULL_FACE);
   glColor3f(1.0,0.6,0.6);          //����

   glVertexPointer(3,GL_FLOAT,0,@Geosets[Gn-1].Vertices[0]);
   glNormalPointer(GL_FLOAT,0,@Geosets[Gn-1].Normals[0]);
   glBegin(GL_TRIANGLES);           //���������
   for i:=0 to Geosets[Gn-1].CountOfFaces-1 do
   for ii:=0 to length(Geosets[Gn-1].Faces[i])-1 do begin
    glArrayElement(Geosets[Gn-1].Faces[i,ii]); //����� �������
   end;//of for ii/i
   glEnd;
  end;//of for gn
  glDisable(GL_CULL_FACE);
  //����� ������ (���� �����):
  glDisable(GL_LIGHTING);
  glDisable(GL_BLEND);
  glDisable(GL_TEXTURE_2D);
  glDisableClientState(GL_NORMAL_ARRAY);
  if IsVertices then InternalDrawVertices;
  glScalef(1.0,-1.0,1.0);
  glDisableClientState(GL_NORMAL_ARRAY);
End;

//����� "���������" �����
procedure DrawObjPart;
Begin
 glDisable(GL_DEPTH_TEST);
 glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);
 glLineStipple(1,$1C47);
 DrawObjects(false);             //����� �������� (��������)
 glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
 glEnable(GL_DEPTH_TEST);
 DrawObjects(true);              //����� �������� (��������)
End;

//��������� ������ 3D �� �����.
//�������� ������ ����� ���, �������� � ������ �����������
//����� ��������� "�������" Make3DListFill
procedure AMake3DListFill;
Var i,ii{,j},gn,len,lrNum,CurCrdID:integer;
    IsMatChange:boolean;
Begin
 PushFunction(364);
 Draw3DGrid;
 glScalef(1.0,-1.0,1.0);          //��������� ������� ���������
 glEnableClientState(GL_VERTEX_ARRAY);//������� ������
 glEnableClientState(GL_NORMAL_ARRAY);
 glEnableClientState(GL_TEXTURE_COORD_ARRAY);
 //1. ������� ���������/������������
 if IsLight then glEnable(GL_LIGHTING);//������������
 glEnable(GL_LIGHT0);
 glEnable(GL_COLOR_MATERIAL);
// glEnable(GL_POLYGON_SMOOTH);//����������� �������������
 glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);//� ��������
 if ViewType=1 then begin
  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  RenderSurface;
  if AnimEdMode<>1 then DrawObjPart;
  glEndList;                      //����� ������
  PopFunction;
  exit;
 end;//of if

 glDepthFunc(GL_LEQUAL);
 glEnable(GL_TEXTURE_2D);        //��������
 glCullFace(GL_BACK);
 glMatrixMode(GL_TEXTURE);      //����� ���������� �������
 IsMatChange:=false;

 //1. ����� �������� ������������
 glAlphaFunc(GL_GEQUAL,0.75);
 glEnable(GL_DEPTH_TEST);        //���������� ����� �������
 //���������� ���� ������
 for gn:=0 to CountOfGeosets-1 do begin
  //���������� ���������, ������ ���� �������� �����������
  if (VisGeosets[gn]=false) or (Geosets[gn].Color4f[4]<=0.01) then continue;
  for lrNum:=0 to Materials[Geosets[Gn].MaterialID].CountOfLayers-1 do
  with Materials[Geosets[Gn].MaterialID].Layers[lrNum] do begin
   if ((FilterMode<>Opaque) and (FilterMode<>ColorAlpha)) then continue;
   if (FilterMode=ColorAlpha) and (AAlpha<0.75) then continue;
   if (FilterMode=Opaque) and (AAlpha<0.01) then continue;
   //���������� ������� ��������� CoordID
   if CoordID>=0 then CurCrdID:=CoordID else CurCrdID:=0;
   //���������� ��������� �� ������� ������
   glVertexPointer(3,GL_FLOAT,0,@Geosets[Gn].Vertices[0]);
   glNormalPointer(GL_FLOAT,0,@Geosets[Gn].Normals[0]);
   glTexCoordPointer(2,GL_FLOAT,0,@Geosets[Gn].Crds[CurCrdID].TVertices[0]);
   glColor4f(Geosets[gn].Color4f[1],Geosets[gn].Color4f[2],
             Geosets[gn].Color4f[3],AAlpha*Geosets[gn].Color4f[4]);
   //���������� �������� ����
   glBindTexture(GL_TEXTURE_2D,Textures[ATextureID].ListNum);
   //���������� ���������
   if IsLight then
   if IsUnshaded then glDisable(GL_LIGHTING)
                 else begin glEnable(GL_LIGHTING);glEnable(GL_LIGHT0);end;
   //��������� ��������� ������ �������������
   if IsTwoSided then glDisable(GL_CULL_FACE)
                 else glEnable(GL_CULL_FACE);
   //���������� ������ ��������� - � ��������� ����� ��� ���
   if FilterMode=ColorAlpha then
    glEnable(GL_ALPHA_TEST)
   else glDisable(GL_ALPHA_TEST);
   //���������� ���������� ������� (���� �����)
   if TVertexAnimID>=0 then begin
    glLoadMatrixd(@TexMatrix);
    IsMatChange:=true;
   end else if IsMatChange then begin
    IsMatChange:=false;
    glLoadIdentity;
   end;//of if

   glBegin(GL_TRIANGLES);         //���������
   for i:=0 to Geosets[Gn].CountOfFaces-1 do begin
    len:=length(Geosets[Gn].Faces[i])-1;
    for ii:=0 to len do glArrayElement(Geosets[Gn].Faces[i,ii]);
   end;//of for i
   glEnd;
  end;//of for lrNum
 end;//of for (gn)

 //2. ����� ����������� ������������
 glLoadIdentity;                 //����� ���������� �������
 glDisable(GL_ALPHA_TEST);
 glEnable(GL_BLEND);             //�������� ��������
 glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);//��������
 glDepthMask(false);
 glDepthFunc(GL_LEQUAL);
 ADraw3DPartFromArray(PrSorted1,PrLength1,false);//����� �������

 //3. ����� ���������� ��������
 glBlendFunc(GL_ONE,GL_ONE);
// glBlendFunc(GL_ONE,GL_DST_ALPHA);
 ADraw3DPartFromArray(PrSorted2,PrLength2,true);//����� �������
 glDepthMask(true);
 glDisable(GL_BLEND);             //����� ��������
 glDisable(GL_TEXTURE_2D);        //��������
 glDisable(GL_CULL_FACE);
 glLoadIdentity;                  //����� ���������� �������
 glMatrixMode(GL_MODELVIEW);      //������� �� ������� ������
 glScalef(1.0,-1.0,1.0);          //��������� ������� ���������
 glDisableClientState(GL_NORMAL_ARRAY);
 glDisableClientState(GL_TEXTURE_COORD_ARRAY);

 glDisable(GL_LIGHTING);         //����� ������������
 glDisable(GL_DEPTH_TEST);       //��������� ���� �������
 if IsVertices and ((AnimEdMode<>1) or (EditorMode=1)) then begin
  glScalef(1.0,-1.0,1.0);         //��������� ������� ���������
  if IsVertices then InternalDrawVertices;
  glScalef(1.0,-1.0,1.0);         //��������� ������� ���������
 end;//of if

 if AnimEdMode<>1 then DrawObjPart;
 glEndList;                       //����� ������
 PopFunction;
End;
//=========================================================
//��������� ������� ���������� ��� ����������� ����������
(*procedure FormPrimitives(ClientHeight:integer);
Var i,ii,j,len,slen:integer;Triangle:TSortPrimitive;
Begin
 PushFunction(365);
 PrLength1:=0;PrSorted1:=nil;       //�������������
 PrLength2:=0;PrSorted2:=nil;       //��� �������������
 //������ ���� ��������
 for i:=0 to CountOfGeosets-1 do begin
  RecalcNormals(i+1);
  SmoothWithNormals(i);
 end;//of for i
 ApplySmoothGroups;

 CalcVertex2D(ClientHeight);   //���������� ������� ������
 //���� �� ���� ������������
 for i:=0 to CountOfGeosets-1 do with geoobjs[i] do begin
  //���������� ��������� � ������������ �����������
  //(��������� �� ��������, ������������ �������� ��� ����������)
  if VisGeosets[i]=false then continue;
  if (Materials[Geosets[i].MaterialID].TypeOfDraw=Opaque) or
     (Materials[Geosets[i].MaterialID].TypeOfDraw=ColorAlpha) then continue;

  Triangle.GeoNum:=i;               //����� �����������
  //���� �� ���� �������������
  slen:=length(Geosets[i].Faces)-1;
  for ii:=0 to slen do begin
   j:=0;len:=length(Geosets[i].Faces[ii]);//�������������
   repeat
    Triangle.num[1]:=Geosets[i].Faces[ii,j];//������ ������ ������
    Triangle.num[2]:=Geosets[i].Faces[ii,j+1];
    Triangle.num[3]:=Geosets[i].Faces[ii,j+2];
    j:=j+3;
    //������ �������
    Triangle.Z:=(Vertices2D[Triangle.num[1]].z+
                Vertices2D[Triangle.num[2]].z+
                Vertices2D[Triangle.num[3]].z)*0.3333333{-j*1e-6-0.005*Triangle.GeoNum};
    //��������: � ����� ������ ��������
    if Materials[Geosets[i].MaterialID].TypeOfDraw=FullAlpha then begin
     inc(PrLength1);SetLength(PrSorted1,PrLength1);
     PrSorted1[PrLength1-1]:=Triangle;//�������� � ������
    end else begin                //Additive, ������ ������
     inc(PrLength2);SetLength(PrSorted2,PrLength2);
     PrSorted2[PrLength2-1]:=Triangle;//�������� � ������
    end;//of if (TypeOfDraw)
   until j>=len;
  end;//of for ii
 end;//of for i
// CurrentGeosetNum:=CurNum;
 PopFunction;
End;     *)
//---------------------------------------------------------
//��������� ��������� ������ ���������� �� Z-����������
procedure SortPrimitives(var PrSorted:TSPArray;PrLength:integer);
Var d,i,j:integer;Tr:TSortPrimitive;
Begin
 if PrLength=0 then exit;
 PushFunction(366);
 d:=round(log2(PrLength));
 asm
  fninit
 end;
{ fl:=Power(2,d);
 d:=round(fl)-1;}
 d:=trunc(Power(2,d))-1;
 repeat                           //���� ����������
 for i:=1 to PrLength-d do begin
  j:=i;                           //���� � �����
  repeat
   if PrSorted[j-1].z>=PrSorted[j+d-1].z then break;
   Tr:=PrSorted[j-1];
   PrSorted[j-1]:=PrSorted[j+d-1];
   PrSorted[j+d-1]:=Tr;
   j:=j-d;
  until j<1;
 end;//of for i
 d:=d shr 1;
 until d<=0;
 PopFunction;
End;
//--------------------------------------------------------
//������������� Z-���������� ���������� ������ ����������
(*procedure ReFormPrimitives({dc:hdc;hrc:hglrc;}ClientHeight:integer);
Var i,ii,j,len:integer;Triangle:TSortPrimitive;
//    PrLength:integer;
Begin
 PushFunction(367);
 PrLength1:=0;PrLength2:=0;
 CalcVertex2D(ClientHeight);   //���������� ������� ������
 //���� �� ���� ������������
 for i:=0 to CountOfGeosets-1 do with geoobjs[i] do begin
  //���������� ��������� � ������������ �����������
  //(��������� �� ��������, ������������ �������� ��� ����������)
  if VisGeosets[i]=false then continue;
  if (Materials[Geosets[i].MaterialID].TypeOfDraw=Opaque) or
     (Materials[Geosets[i].MaterialID].TypeOfDraw=ColorAlpha)then continue;

  Triangle.GeoNum:=i;               //����� �����������
  //���� �� ���� �������������
  for ii:=0 to length(Geosets[i].Faces)-1 do begin
   j:=0;len:=length(Geosets[i].Faces[ii]);//�������������
   repeat
    Triangle.num[1]:=Geosets[i].Faces[ii,j];//������ ������ ������
    Triangle.num[2]:=Geosets[i].Faces[ii,j+1];
    Triangle.num[3]:=Geosets[i].Faces[ii,j+2];
    j:=j+3;
    //������ �������
    Triangle.Z:=(Vertices2D[Triangle.num[1]].z+
                Vertices2D[Triangle.num[2]].z+
                Vertices2D[Triangle.num[3]].z)*0.3333333{-j*1e-6-
                0.005*(Triangle.GeoNum and $FFFF)};
    if Materials[Geosets[i].MaterialID].TypeOfDraw=FullAlpha then begin
     inc(PrLength1);
     PrSorted1[PrLength1-1]:=Triangle;        //�������� � ������
    end else begin
     inc(PrLength2);
     PrSorted2[PrLength2-1]:=Triangle;        //�������� � ������
    end;//of if (TypeOfDraw)
   until j>=len;
  end;//of for ii
 end;//of for i
 PopFunction;
End;        *)
//---------------------------------------------------------
//��������� ������ ���������� ��� �������� - �� �����.
procedure AFormPrimitives(ClientHeight:integer);
Var i,ii,j,jj,len,slen:integer;Triangle:TSortPrimitive;
Const lrType=$10000;
Begin
 PushFunction(368);
 PrLength1:=0;PrSorted1:=nil;       //�������������
 PrLength2:=0;PrSorted2:=nil;       //��� �������������
 //������ ���� ��������
 for i:=0 to CountOfGeosets-1 do begin
  RecalcNormals(i+1);
  SmoothWithNormals(i);
 end;//of for i
 ApplySmoothGroups;

 CalcVertex2D(ClientHeight);   //���������� ������� ������
 //���� �� ���� ������������
 for i:=0 to CountOfGeosets-1 do with geoobjs[i] do begin
  //���������� ��������� � ������������ �����������
  //(��������� �� ��������, ������������ �������� ��� ����������)
  if (VisGeosets[i]=false) or (Geosets[i].Color4f[4]<1e-5) then continue;
  for jj:=0 to Materials[Geosets[i].MaterialID].CountOfLayers-1 do begin
  if (Materials[Geosets[i].MaterialID].Layers[jj].FilterMode=Opaque) or
     (Materials[Geosets[i].MaterialID].Layers[jj].FilterMode=ColorAlpha) or
     (Materials[Geosets[i].MaterialID].Layers[jj].AAlpha<1e-2)
      then continue;
   Triangle.GeoNum:=i+jj*lrType;  //����� �����������+����� ����
   //���� �� ���� �������������
   slen:=length(Geosets[i].Faces)-1;
   for ii:=0 to slen do begin
    j:=0;len:=length(Geosets[i].Faces[ii]);//�������������
    repeat
     Triangle.num[1]:=Geosets[i].Faces[ii,j];//������ ������ ������
     Triangle.num[2]:=Geosets[i].Faces[ii,j+1];
     Triangle.num[3]:=Geosets[i].Faces[ii,j+2];
     j:=j+3;
     //������ �������
     Triangle.Z:=(Vertices2D[Triangle.num[1]].z+
                 Vertices2D[Triangle.num[2]].z+
                 Vertices2D[Triangle.num[3]].z)*0.3333333-j*1e-6-0.005*Triangle.GeoNum;
     //��������: � ����� ������ ��������
     if Materials[Geosets[i].MaterialID].Layers[jj].FilterMode=FullAlpha then begin
      inc(PrLength1);SetLength(PrSorted1,PrLength1);
      PrSorted1[PrLength1-1]:=Triangle;//�������� � ������
     end else begin                //Additive, ������ ������
      inc(PrLength2);SetLength(PrSorted2,PrLength2);
      PrSorted2[PrLength2-1]:=Triangle;//�������� � ������
     end;//of if (TypeOfDraw)
    until j>=len;
   end;//of for ii
  end;//of for jj
 end;//of for i
 PopFunction;
End;
//---------------------------------------------------------
//�� �� �����, ������ ��������������
procedure AReFormPrimitives(ClientHeight:integer);
Var i,ii,j,jj,len:integer;Triangle:TSortPrimitive;
Const lrType=$10000;
Begin
 PushFunction(369);
 PrLength1:=0;PrSorted1:=nil;       //�������������
 PrLength2:=0;PrSorted2:=nil;       //��� �������������
 CalcVertex2D(ClientHeight);   //���������� ������� ������
 //���� �� ���� ������������
 for i:=0 to CountOfGeosets-1 do with geoobjs[i] do begin
  //���������� ��������� � ������������ �����������
  //(��������� �� ��������, ������������ �������� ��� ����������)
  if (VisGeosets[i]=false) or (Geosets[i].Color4f[4]<1e-5) then continue;
  for jj:=0 to Materials[Geosets[i].MaterialID].CountOfLayers-1 do begin
  if (Materials[Geosets[i].MaterialID].Layers[jj].FilterMode=Opaque) or
     (Materials[Geosets[i].MaterialID].Layers[jj].FilterMode=ColorAlpha) or
     (Materials[Geosets[i].MaterialID].Layers[jj].AAlpha<1e-2)
      then continue;
   Triangle.GeoNum:=i+jj*lrType;  //����� �����������+����� ����
   //���� �� ���� �������������
   for ii:=0 to length(Geosets[i].Faces)-1 do begin
    j:=0;len:=length(Geosets[i].Faces[ii]);//�������������
    repeat
     Triangle.num[1]:=Geosets[i].Faces[ii,j];//������ ������ ������
     Triangle.num[2]:=Geosets[i].Faces[ii,j+1];
     Triangle.num[3]:=Geosets[i].Faces[ii,j+2];
     j:=j+3;
     //������ �������
     Triangle.Z:=(Vertices2D[Triangle.num[1]].z+
                 Vertices2D[Triangle.num[2]].z+
                 Vertices2D[Triangle.num[3]].z)*0.3333333-j*1e-6-
                 0.005*(Triangle.GeoNum and $FFFF);
     //��������: � ����� ������ ��������
     if Materials[Geosets[i].MaterialID].Layers[jj].FilterMode=FullAlpha then begin
      inc(PrLength1);SetLength(PrSorted1,PrLength1);
      PrSorted1[PrLength1-1]:=Triangle;//�������� � ������
     end else begin                //Additive, ������ ������
      inc(PrLength2);SetLength(PrSorted2,PrLength2);
      PrSorted2[PrLength2-1]:=Triangle;//�������� � ������
     end;//of if (TypeOfDraw)
    until j>=len;
   end;//of for ii
  end;//of for jj
 end;//of for i
 PopFunction;
End;
//---------------------------------------------------------
//initialization
end.
