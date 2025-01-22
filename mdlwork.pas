unit mdlwork;
//��������� ��� �������� mdl � mdx, ������ � �� �������
interface
uses windows,messages,OpenGL,sysUtils,glow;

type
TVertex=array[1..3] of GLFloat; //���������� (GL+War)
TNormal=TVertex;//array[1..3] of GLFloat; //������� (����������)
TTVertex=array[1..2] of GLFloat;//���������� ��������
TCrds=record                    //���������� ����������
 TVertices:array of TTVertex;   //������ �����. ������
 CountOfTVertices:integer;      //��� �����
end;//of TCrds
TFace=array of integer;         //�������� (������ ������)
TAnim=record                    //������� ��������
 MinimumExtent,MaximumExtent:TVertex;//�������
 BoundsRadius:GLfloat;          //��������� ������
end;
ATAnim=array of TAnim;          //���: ������ ��������
TMidNormal=record               //������ ��� "�����������" �������
 GeoID,VertID:integer;          //"�����" �������
end;//of TMidNormal
TConstNormal=record             //���: ������� � ����������� ������������
 GeoId,VertID:integer;          //"�����" �������
 n:TNormal;                     //���� �������
end;//of TConstNormal                          
TTexture=record                 //���: ��������
// ListNum:integer;               //����� ����������� ������
 FileName:string;               //��� ����� ��������
 ReplaceableID:integer;         //��� ��������
 IsWrapWidth,IsWrapHeight:boolean;//��������� ���
 pImg:pointer;                  //��������� �� �����������
 ImgWidth,ImgHeight:integer;    //��������� �����������
 ListNum:integer;               //����� ������ ��������
end;//of TTexture
TContItem=record                //���: ������� ����������� ��������
 Frame:integer;                   //����� �����
 Data,                            //������ � �����
 InTan,                           //�������� (��� ���������� ���������)
 OutTan:array[1..5] of GLfloat;
end;//of TContItem
TController=record              //���: ���������� ��������
 ContType:integer;                //��� �����������
 GlobalSeqId:integer;             //ID ��������������� ������������������
 SizeOfElement:integer;           //����������� �������� ������ 
 Items:array of TContItem;        //������
end;//of TController
TTexMatrix=array[0..3,0..3] of GLDouble;
TLayer=record                   //���: ���� ���������
 FilterMode:integer;            //����� ��������
 IsUnshaded,IsTwoSided,IsUnfogged,IsSphereEnvMap,
 IsNoDepthTest,IsNoDepthSet:boolean;//��������� �����������
 TextureID:integer;             //ID �������� ����
 IsTextureStatic:boolean;       //true, ���� �����. �����������
 Alpha:GLfloat;                 //������������ ����
 IsAlphaStatic:boolean;         //true, ���� Alpha - �����������
 NumOfGraph:integer;            //����� ����� �������� �����
 NumOfTexGraph:integer;         //����� �������� ��������
 TVertexAnimID:integer;         //ID ���������� ��������
 CoordID:integer;               //ID ���������, ��� ��?
 AAlpha:GLFloat;                //������������ ���� (���. ����)
 TexMatrix:TTexMatrix;          //������� ���������� ��������������
 ATextureID:integer;            //ID �������� � �����
end;//of TLayer
TMaterial=record                //���: ��������
 ListNum:integer;               //����� ����������� ������
 TypeOfDraw:integer;            //��� ������ (������. ��� ���������� ������)
 Excentry:GLFloat;              //�������������� ��������� (��� ��������� �������)
 IsConstantColor:boolean;       //��������� �� �������� �����
 IsSortPrimsFarZ:boolean;       //���������� ����������
 IsFullResolution:boolean;      //? ����� �������� 
 PriorityPlane:integer;         //? �����-�� ��������
 CountOfLayers:integer;         //���-�� �����
 Layers:array of TLayer;        //���� ���������
end;//of TMaterial
TTextureAnim=record             //�������� ��������
 TranslationGraphNum,
 RotationGraphNum,
 ScalingGraphNum:integer;       //��������������
end;//of TTextureAnim
TGroup=array of TFace;          //���: ������ (����. � �������)
TGeoset=record                  //���: �����������
 Vertices:array of TVertex;
 Normals:array of TNormal;      //�������
 CountOfCoords:integer;         //���-�� �������� ���������� ���������
 Crds:array of TCrds;           //���������� ����������
 VertexGroup:array of integer;  //������ ������
 Faces:array of TFace;          //���������
 Groups:TGroup;                 //���������� � �������
 Anims:ATAnim;                  //������� ��������
 MinimumExtent:TVertex;         //�������
 MaximumExtent:TVertex;
 BoundsRadius:GLfloat;          //��������� ������
 CountOfAnims:integer;          //���-�� ������
 MaterialID:integer;            //�������� �����������
 SelectionGroup:integer;        //������ ���������
 Unselectable:boolean;          //���� ��������������

 CountOfVertices:integer;       //���-�� ������
 CountOfNormals:integer;        //���-�� ��������
// CountOfTVertices:integer;      //���-�� �����. ���������.
 CountOfFaces:integer;          //���-�� ����������
 CountOfMatrices:integer;       //���-�� ���������� � �������
 CurrentListNum:integer;        //����� �������� ������ GLU
 Color4f:array[1..4] of GLfloat;//������ ������� �����������
 ChildVertices:array of integer;//�������, ��������� � ������
 CountOfChildVertices:integer;  //�� ���-��
 DirectCV:array of integer;     //�������, �������� ��������������� � ���. ��.
 CountOfDirectCV:integer;       //���-�� ����� ������
 HierID:integer;                //id ��������
// HierName:string;
end;//of type
TNrm=record                     //������������ ��� ������� ��������
 x,y,z:GLfloat;
// count:integer;
end;
TSequence=record                //��� - ������������������
 Name:string;                   //���
 IntervalStart,IntervalEnd:integer;//�������� (�����)
 Rarity:integer;                //��������
 IsNonLooping:boolean;          //���� �����������
 MoveSpeed:integer;             //�������� ��������
 Bounds:TAnim;                  //�������
end;//of TSequence
TGeosetAnim=record              //�������� �����������
 Alpha:GLFloat;                 //������������
 Color:TVertex;                 //���� (r,g,b)
 GeosetID:integer;              //ID ��������������� �����������
 IsAlphaStatic,IsColorStatic:boolean;
 IsDropShadow:boolean;          //?
 AlphaGraphNum,ColorGraphNum:integer;//������ ������
end;//of TGeosetAnim
TQuaternion=record           //���: ����������
 x,y,z,w:GLfloat;             //����������
end;//of TQuaternion
TRotMatrix=array [0..2,0..2] of GLfloat;//���: ������� ��������
TBone=record                    //���: �����/��������
 Name:string;                   //���
 ObjectID,GeosetID,GeosetAnimID:integer;
 IsBillboarded:boolean;
 IsBillboardedLockX,
 IsBillboardedLockY,
 IsBillboardedLockZ,
 IsCameraAnchored:boolean;
 Parent:integer;               //ID ��������
 Translation,Rotation,Scaling,Visibility:integer;//������ ����� ��������
 IsDIRotation,IsDITranslation,IsDIScaling:boolean;//"�� �������������"
 //��������� (��� ��������) ���������
 IsReady:boolean;                 //true, ���� ��������� ��� ���������
 AbsQuaternion:TQuaternion;
 AbsMatrix:TRotMatrix;
 AbsVector:TVertex;
 AbsScaling:TVertex;
 AbsVisibility:boolean;
end;//of TBone
TLight=record                     //���: �������� �����
 Skel:TBone;                       //������ �������
 LightType:integer;                //��� ���������
 AttenuationStart:single;          //��������� �������
 AttenuationEnd:single;            //�������� �������
 Intensity:single;                 //�������������
 Color:TVertex;                    //����
 AmbIntensity:single;
 AmbColor:TVertex;                  //
 //�����������
 IsASStatic,IsAEStatic,IsIStatic,
 IsCStatic,IsAIStatic,IsACStatic:boolean;
end;//of TLight
TAttachment=record                //����� ������������
 Skel:TBone;                       //������ �������
 AttachmentID:integer;
 Path:string;                      //?
end;//of TAttachment
TParticleEmitter=record           //�������� ������ 1
 Skel:TBone;                      //������ �������
 UsesType:integer;                //��� ������������� �������
 EmissionRate,Gravity,
 Longitude,Latitude:single;
 LifeSpan,InitVelocity:single;
 Path:string;
 IsERStatic,IsGStatic,IsLongStatic,
 IsLatStatic,IsLSStatic,IsIVStatic:boolean;
end;//of TParticleEmitter
TParticleEmitter2=record          //���: �������� ������(2-� ������)
 Skel:TBone;                      //������ �������
 IsSortPrimsFarZ,IsUnshaded,IsLineEmitter,IsUnfogged,
 IsModelSpace,IsXYQuad:boolean;
 Speed,Variation,Latitude,Gravity:single;
 IsSquirt:boolean;
 LifeSpan,EmissionRate:single;
 Width,Length:single;
 BlendMode:integer;              //����� ��������
 Rows,Columns:integer;
 ParticleType:integer;           //��� �����������(tail/head/both)
 TailLength,Time:single;
 SegmentColor:array[1..3] of TVertex;
 Alpha:array[1..3] of integer;
 ParticleScaling:TVertex;
 LifeSpanUVAnim,DecayUVAnim,TailUVAnim,TailDecayUVAnim:array[1..3] of integer;
 TextureID:integer;
 ReplaceableId,PriorityPlane:integer;
 IsSStatic,IsVStatic,IsLStatic,IsGStatic,
 IsEStatic,IsWStatic,IsHStatic:boolean;
end;//of TParticleEmitters2
TRibbonEmitter=record             //�������� �����
 Skel:TBone;                      //������ �������
 HeightAbove,HeightBelow:single;
 alpha:single;
 Color:TVertex;
 TextureSlot:integer;
 EmissionRate:integer;
 LifeSpan,Gravity:single;
 Rows,Columns:integer;
 MaterialID:integer;
 IsHAStatic,IsHBStatic,IsAlphaStatic,
 IsColorStatic,IsTSStatic:boolean;
end;//of TRibonEmitter
TCamera=record                    //���: ������
 Name:string;
 Position:TVertex;
 TranslationGraphNum,RotationGraphNum:integer;
 FieldOfView,FarClip,NearClip:single;
 TargetPosition:TVertex;
 TargetTGNum:integer;
end;//of TCamera
TEventObject=record               //�������(����������)
 Skel:TBone;                      //������ �������
 CountOfTracks:integer;
 Tracks:array of integer;         //������ ������������
end;//of TEventObject
TCollisionShape=record            //���: ������ ������
 Skel:TBone;                      //������ �������
 objType:integer;                 //�����/����
 CountOfVertices:integer;
 Vertices:array of TVertex;
 BoundsRadius:single;
end;//of TCollisionShape
TFSize=record                     //���������� � �������
 fPos:integer;                    //������� ��� ������
 IsI:boolean;                     //��� �������
end;//of TFSize

//����� ����. �������� ��� ������� WoW (m2):
TSubMesh=record                   //������ ���� � ��������������
 coIndices,                       //���-�� �������� (������ ������)
 ipIndices,                       //��������
 coFaces,                         //��������� (3*����� �����.)
 ipFaces,
 ipMesh,
 coTexs,                          //���������� ������ (?)
 ipTexs,
 id:integer;                      //ID �������������
end;//of TSubMesh
TIJCore=record                    //��������� ��� ������� IJPEG
 UseIJPEGProperties:integer;      //������ 0
 DIBBytes:pointer;                //��������� �� DIB-�����.
 width,height:integer;            //�������
 DIBPadBytes,DIBChannels:integer;
 DIBColor,DIBSubsampling:integer;
 //IJ-��������
 IJFile:PChar;                    //��� ���� ��� ������
 IJBytes:pointer;                 //����� IJ
 IJSizeBytes:integer;             //������ �����������
 IJWidth,IJHeight:integer;        //���������(�������)
 IJChannels,IJColor:integer;
 IJSubsampling:integer;
 IJThumbWidth,IJThumbHeight:integer;
 //��������� ���������
 IsConvRequired:integer;
 IsUnsamplingRequired:integer;
 Quality:integer;                 //����-� ��������
 ijprops:array[0..20000] of byte; //���������� �����
end;//of TIJCore
{THierarchy=record                 //���: WoW-��������
 id:integer;                      //id ��������
 Name:string;                     //� ���
 geoids:array of integer;         //������ ������������
end;//of THierarchy}
//����-������� (��� �����������)
ATTexture=array of TTexture;
ATTextureAnims=array of TTextureAnim;
ATMaterial=array of TMaterial;
ATGeoset=array of TGeoset;
ATSequence=array of TSequence;
ATI=array of integer;
ATGeosetAnim=array of TGeosetAnim;
ATBone=array of TBone;
ATAttachment=array of TAttachment;
ATVertex=array of TVertex;
ATParticleEmitter=array of TParticleEmitter;
ATParticleEmitter2=array of TParticleEmitter2;
ATRibbonEmitter=array of TRibbonEmitter;
ATEventObject=array of TEventObject;
ATCamera=array of TCamera;
ATCollisionShape=array of TCollisionShape;
ATLight=array of TLight;
ATController=array of TController;
ATMidNormal=array of array of TMidNormal;
ATConstNormal=array of TConstNormal;
TWMO=record                       //��������� ��� �������� WMO-��������
 pRoot,                           //��������� �� �������� root-WMO
 pGroup:pointer;                  //��������� �� �������� group-WMO
 ppSV,ppRoot:integer;
 //������ ������
 Textures:ATTexture;              //������ �������
 TextureAnims:ATTextureAnims;     //������ ���������� ��������
 Materials:ATMaterial;            //������ ����������
 Geosets:ATGeoset;                //�������� ������������
 Sequences:ATSequence;            //������ �������������������
 GlobalSequences:ATI;             //���������� ������������������
 GeosetAnims:ATGeosetAnim;        //�������� ������������
 Bones:ATBone;                    //������ ������
 Helpers:ATBone;                  //������ ����������
 Attachments:ATAttachment;        //������ ������������
 PivotPoints:ATVertex;            //������ �������������� �������
 ParticleEmitters1:ATParticleEmitter;
 pre2:ATParticleEmitter2;         //��������� ������
 Ribs:ATRibbonEmitter;            //��������� �����
 Events:ATEventObject;            //�������
 Cameras:ATCamera;                //������
 Collisions:ATCollisionShape;
 CountOfTextures:integer;    //���-�� �������
 CountOfMaterials:integer;   //���-�� ����������
 CountOfPivotPoints:integer; //���-�� �������
 CountOfTextureAnims:integer;//���-�� ���������� ��������
 CountOfGeosets:integer;     //���-�� ������������
 CountOfGeosetAnims,         //���-�� �������� ������������
 CountOfLights,              //���-�� ���������� �����
 CountOfHelpers,             //���-�� "����������"
 CountOfBones,               //���-�� ������
 CountOfAttachments,         //���-�� ������������
 CountOfParticleEmitters1,   //���. ������ 1-� ������
 CountOfParticleEmitters,    //��������� ������
 CountOfRibbonEmitters,      //��������� �����
 CountOfEvents:integer;      //�������
 CountOfCameras:integer;     //���-�� �����
 CountOfCollisionShapes:integer;//���-�� ��������� ��������
 BlendTime:integer;          //����� ��������
 CountOfSequences:integer;   //���-�� �������������������
 CountOfGlobalSequences:integer;//���-�� ����. �-���
 AnimBounds:TAnim;           //�������, ������ ������
 Lights:ATLight;             //������ ���������� �����
 Controllers:ATController;   //������ ������������ ��������
 ModelName:string;
end;//of TWMO

//����, �������������� ��� ��������������� WMO:
const MaxElement=1000000;//����. ���-�� ��������� � ��������
type TMOPY=packed array [0..MaxElement] of byte;
     PMOPY=^TMOPY;
     TMOVI=packed array [0..MaxElement*2] of word;
     PMOVI=^TMOVI;
     TMOVT=packed array [0..MaxElement*3] of single;
     PMOVT=^TMOVT;
     TMONR=packed array [0..MaxElement*3] of single;
     PMONR=^TMONR;
     TMOTV=packed array [0..MaxElement*2] of single;
     PMOTV=^TMOTV;

//��������� ������� ��������
const Opaque=1;ColorAlpha=2;FullAlpha=3;Additive=4;
      Modulate=5;Modulate2X=6;AddAlpha=7;
      AlphaKey=8;

//��������� ����� ������������
      DontInterp=1;Linear=2;Hermite=3;Bezier=4;
      OnOff=5;//������ ��� (0,1)
//��������� ������ ID ������/����������
      None=-2;Multiple=-3;
//��������� ����� ���������� �����
      Omnidirectional=1;Directional=2;Ambient=3;
//��� �������
      EmitterUsesTGA=0;EmitterUsesMDL=1;
//����������� ������
      ptHead=0;ptTail=1;ptBoth=2;
//��� ���������� �������
      cSphere=0;cBox=1;
//��������� ����������
      cNone=-1e6;
//���� �����
 TagGLBS=$53424C47;TagMTLS=$534C544D;TagTEXS=$53584554;
 TagTXAN=$4E415854;TagGEOS=$534F4547;TagGEOA=$414F4547;
 TagBONE=$454E4F42;TagLITE=$4554494C;TagHELP=$504C4548;
 TagATCH=$48435441;TagPIVT=$54564950;TagPREM=$4D455250;
 TagPRE2=$32455250;TagRIBB=$42424952;TagCAMS=$534D4143;
 TagEVTS=$53545645;TagCLID=$44494C43;TagMODL=$4C444F4D;
 TagLAYS=$5359414C;TagVRTX=$58545256;TagNRMS=$534D524E;
 TagPVTX=$58545650;TagGNDX=$58444E47;TagMTGC=$4347544D;
 TagMATS=$5354414D;TagUVAS=$53415655;TagUVBS=$53425655; 

 tagKMTA=$41544D4B;tagKMTF=$46544D4B;TagSEQS=$53514553;
 tagKTAT=$5441544B;tagKTAR=$5241544B;tagKTAS=$5341544B;
 tagKGAO=$4F41474B;tagKGAC=$4341474B;tagKGTR=$5254474B;
 tagKGRT=$5452474B;tagKGSC=$4353474B;tagKATV=$5654414B;
 tagKLAI=$49414C4B;tagKLAV=$56414C4B;tagKLAC=$43414C4B;
 tagKLBC=$43424C4B;tagKLBI=$49424C4B;tagKPEV=$5645504B;
 tagKLAS=$53414C4B;tagKLAE=$45414C4B;tagKP2S=$5332504B;
 tagKP2R=$5232504B;tagKP2L=$4C32504B;tagKP2G=$4732504B;
 tagKP2E=$4532504B;tagKP2V=$5632504B;tagKP2N=$4E32504B;
 tagKP2W=$5732504B;tagKRVS=$5356524B;tagKRHA=$4148524B;
 tagKRHB=$4248524B;tagKRAL=$4C41524B;tagKRCO=$4F43524B;
 tagKCTR=$5254434B;tagKCRL=$4C52434B;tagKTTR=$5254544B;
 tagKPEE=$4545504B;tagKPEG=$4745504B;tagKPLN=$4E4C504B;
 tagKPLT=$544C504B;tagKPEL=$4C45504B;tagKPES=$5345504B;
 tagMDVI=$4956444D;
 //����. ����
 tagiWoW=0; tagiSmooth=1;
 //��������� ��������
 typHELP=0;typBONE=256;typLITE=512;typEVTS=1024;typATCH=2048;
 typCLID=8192;typPRE2=65536;
 //��������� ����� ��������� ��������
 CODE_COMMA=$2C;     //�������
 CODE_COLON=$3A;     //Tab
 CODE_OBRACKET=$7B;  //{
 CODE_CBRACKET=$7D;  //}
 CODE_QM=$22;        //"
 //����� ��������� ���������:
 scError='������:';
 //��������� ��������� (��� m2-�������):
 wowmult=50;
var f:file;                     //�������� ����
    p:pointer;                  //���������� ���������
    pp:integer;                 //������������� ����� ���������
    ft:text;
    fm:file;
    fSizes:array[0..20] of TFSize;//������ ����������
    fsCurNum:integer;           //��������� �� ����. �����
    FCont,                      //���������� ����� (��� ����� ��������)
    FileContent:string;         //������ ���������� �����
    CurGeoPos:cardinal;         //������� ������� �����������
    IsShowTexError:boolean;     //���������� �� ������ �������� �������
    Textures:ATTexture;         //������ �������
    TextureAnims:ATTextureAnims;//������ ���������� ��������
    Materials:ATMaterial;       //������ ����������
    Geosets:ATGeoset;           //�������� ������������
    Sequences:ATSequence;       //������ �������������������
    GlobalSequences:ATI;        //���������� ������������������
    GeosetAnims:ATGeosetAnim;   //�������� ������������
    Bones:ATBone;               //������ ������
    Helpers:ATBone;             //������ ����������
    Attachments:ATAttachment;   //������ ������������
    PivotPoints:ATVertex;       //������ �������������� �������
    ParticleEmitters1:ATParticleEmitter;
    pre2:ATParticleEmitter2;    //��������� ������
    Ribs:ATRibbonEmitter;       //��������� �����
    Events:ATEventObject;       //�������
    Cameras:ATCamera;           //������
    Collisions:ATCollisionShape;
    CountOfTextures:integer;    //���-�� �������
    CountOfMaterials:integer;   //���-�� ����������
    CountOfPivotPoints:integer; //���-�� �������
    //�������� ���������:
    ModelName:string;           //��� ������
    CountOfTextureAnims:integer;//���-�� ���������� ��������
    CountOfGeosets:integer;     //���-�� ������������
    CountOfGeosetAnims,         //���-�� �������� ������������
    CountOfLights,              //���-�� ���������� �����
    CountOfHelpers,             //���-�� "����������"
    CountOfBones,               //���-�� ������
    CountOfAttachments,         //���-�� ������������
    CountOfParticleEmitters1,   //���. ������ 1-� ������
    CountOfParticleEmitters,    //��������� ������
    CountOfRibbonEmitters,      //��������� �����
    CountOfEvents:integer;      //�������
    CountOfCameras:integer;     //���-�� �����
    CountOfCollisionShapes:integer;//���-�� ��������� ��������
    BlendTime:integer;          //����� ��������
    CountOfSequences:integer;   //���-�� �������������������
    CountOfGlobalSequences:integer;//���-�� ����. �-���
    AnimBounds:TAnim;           //�������, ������ ������
//    TextureAnims:string;        //������ ���������� ��������
    Lights:ATLight;             //������ ���������� �����
    nrms:array of TNrm;         //��������� ������
    Controllers:ATController;   //������ ������������ ��������
    CurrentCoordID:integer;       //������� ���� ���������� ������

//    BeginGeosetsPos:cardinal;   //������� ������ ������������
//    EndGeosetsPos:cardinal;     //��������� ������������
    CurrentListNum:integer;//����� ������
    VisGeosets:array of boolean;  //��������� ������������
    SFAVertices:array of array of TVertex;//���������� ������
//    SFATVertices:array of array of TCrds; //���������� ���������� ������
    SFAPivots:array of TVertex;   //���������� �������
    CurFrame:integer;             //����� �������� �����
    TexErr:string;                //����� ������������� ������ �������� �������
    IsCanSaveMDVI,                //true, ���� ��������� ������ ������. ������.
    IsWoW:boolean;                //true, ���� ������� ������ WoW
    WarPath:string;               //���� � War
    Version:integer;              //������ ������ WoW

    //����������� ��������
    MidNormals:ATMidNormal;       //������ ����������� ��������
    COMidNormals:integer;         //����� ����� ������
    ConstNormals:ATConstNormal;   //������ "�����������" ��������
    COConstNormals:integer;       //����� ����� ������
//    Hierarchy:array of THierarchy;//������ WoW-��������
    //����������-���������:
    ijlFree:function(p:pointer):integer;stdcall;
    ijlInit:function(p:pointer):integer;stdcall;
    ijlRead:function(p:pointer;par:integer):integer;stdcall;
    ijlWrite:function(p:pointer;par:integer):integer;stdcall;
    //��������� �� storm.dll
    IsLoadMPQ:boolean;
    hWar3,hWar3x,hWar3patch:integer;    
    SFileOpenArchive:function(lpName:PChar;dwPriority,dwFlags:integer;
                              var hMPQ:integer):boolean;stdcall;
    SFileOpenFileEx:function(hMPQ:integer;lpFileName:PChar;
                             dwSearchScope:integer;
                             var hFile:integer):boolean;stdcall;
//    SFileOpenFileEx:function(fname:PChar;var a1,a2:integer;a3,a4:integer):boolean;stdcall;
    SFileCloseFile:function(hFile:integer):boolean;stdcall;
    SFileGetFileSize:function(hFile:integer;var dwHigh:integer):integer;stdcall;
    SFileReadFile:function(hFile:integer;pBuf:pointer;dwToRead,pdwRead:integer;
                           lpOverlapped:pointer):boolean;stdcall;
//    SFileSetLocale:function(id:integer):integer;stdcall;
//--����� �������� ����������� ��������� ������������ ��������
//����������� ����������:
procedure cpyMaterial(var src,dst:TMaterial);
//�������� Geoset'�.
//����������� ��������: ���������, ��� Faces ������� �
//1 �������. ���� ���� ChildVertices � CurrentListNum -
//�� ����������.
procedure cpyGeoset(var src,dst:TGeoset);
//����������� ����������� ��������
procedure cpyController(var src,dest:TController);
//����������� ������ Crds ������� �� Start-�������
procedure cpyCrds(var scr,dest:TCrds;Start:integer);
//���-���������: ������� ���-����
//procedure CreateLogFile;
//���-���������: ������� � ��� ������-���������
procedure WriteToLog(s:string);
//-------------------------------------------------
//��������� "���������" ��� �����, ����� ����
function GetOnlyFileName(fname:string):string;
//��������� ���� mdl, �������� ���. ����������
procedure OpenMDL(fname:string);
//��������� ���� MDX, ��������� ����� ���
procedure OpenMDX(fname:string);
//��������� ���� M2 (������ WoW) � �������� �������������� ���.
//�������� ��� ����� (��� ����������) ����� ��������.
procedure OpenM2(fname:string);
//��������� wmo-����� (������ RootWMO).
//�������� ������� ��� OpenGroupWMO.
//�������� ��� ����� ��� ���������� ����� ��������.
//� ������ ������ ���������� ������ ������.
//� ������ ������/�������������� �����. �� �����. 
function OpenWMO(fname:string):string;
//��������� ���� ������
procedure CloseMDL;
//��������������� ������� ��� �������� �����������
procedure RecalcNormals(geonum:integer);
//�������� "�����������" ����� ���������� ��������
procedure SmoothWithNormals(geoID:integer);
//�������� ����� ������� � ConstNormals.
//���� ��� ��� ����, �����. ID �����. ������. ����� (-1).
function FindConstNormal(geoID,VertID:integer):integer;
//��������� ������ ����������� � ��������
procedure ApplySmoothGroups;
//�������� "�������������" ������������� ���,
//����� ��� ��������������� ����� ��������.
procedure NormalizeTriangles(geoID:integer);
//������������ �������� ������� � ���������� �����������
//�� MidNormals � ConstNormals (���� ��� ������� ��� ���,
//������ �� ����������)
procedure DeleteRecFromSmoothGroups(nrm:TMidNormal);
//����������� ���������� ������� (����� �������� 2 ������� �����),
//��� �������� � ���������� �����������.
procedure RoundModel;
//������� ������������� �������� (�������� ���-�� �� �������)
procedure ReduceRepTextures;
//������� ������������� ���������
procedure ReduceRepMaterials;
//��������� ����
procedure SaveMDL(fname:string);
//��������� ������ � ������� MDX
procedure SaveMDX(fname:string);
//��������� ��������, ���������� ����� �����������
//� � width,height - ������� ������ ��������
procedure LoadTexture(dirName,fname:string;
                      var Width,Height:integer;var pReturn:pointer);
//������� ��� LoadTexture: ��������� ������� ������ ���� ������� �� �����,
//��� ���� ����������
//���������� true ��� ������
//�������� ������ ���� ����������, ������ ������� �������
function CreateAllTextures(dirName:string;r,g,b:GLfloat):boolean;
//������� ������ GL ��� ��������� ���������
//MatID - ID ���������, rgb - �������� ����� �������.
//��� �������� ������ ���� �������������� �������
//(� ������ ����� �������!)
//�������� ������ ���� ����������!
function MakeMaterialList(MatID:integer):boolean;
//������������ �������� WoW � blp1 (WC3).
//���������� ������������ � ��� �� ����.
//��� �������� ��������� ���������� true
function ConvertBLP2ToBLP(fname:string;IsBatch:boolean):boolean;
//���������� ������� ��������� �����������
procedure CalcBounds(geoID:integer;var anim:TAnim);
//������ ������ GeosetAnim (�.�. �� ����������,
//������� 1 Alpha � Color) ��� ��������� GeosetID.
//� ������ �������������, GeosetAnimID ����������
//���������� ID ��������� �������� ���������
//��� �� (-1), ���� ������� ��� ����������
function CreateGeosetAnim(GeosetID:integer):integer;
//���������������: ������� RDTSC
function GetTSC:cardinal;

//������� (������������) ���������/�������
function FindSym(StartAddr:pointer;SymCode:integer):cardinal;external;
function ExpGoToCipher(StartAddr:pointer):cardinal;external;
function GetIntVal(StartAddr:pointer;var rs:integer):integer;external;
function ExpGetFloat(StartAddr:pointer;var rs:single):integer;external;
{$L findsym.obj}
{$L gotocipher.obj}
{$L getintval.obj}
{$L expgetfloat.obj}

//��������� ������ OpenGL (���������� ��������):
procedure glGenTextures(n:GLsizei;textures:PGLuint);stdcall;external opengl32;
procedure glBindTexture(target:GLEnum;texture:GLuint);stdcall;external opengl32;
procedure glDeleteTextures(n:GLsizei;textures:PGLuint);stdcall;
          external opengl32;
//��� ��������� (������� ������):
procedure glVertexPointer(size:GLInt;typ:GLEnum;stride:GLSizei;p:pointer);
          stdcall;external opengl32;
procedure glEnableClientState(aarray:GLEnum);stdcall;external opengl32;
procedure glDisableClientState(aarray:GLEnum);stdcall;external opengl32;
procedure glDrawArrays(mode:GLEnum;first:GLint;count:GLsizei);stdcall;
          external opengl32;
procedure glArrayElement(index:GLint);stdcall;external opengl32;
procedure glNormalPointer(typ:GLEnum;stride:GLSizei;p:pointer);
          stdcall;external opengl32;
procedure glTexCoordPointer(size:GLInt;typ:GLEnum;stride:GLSizei;p:pointer);
          stdcall;external opengl32;
function SFileSetLocale(id:integer):integer;stdcall;
         external 'storm.dll' index 272;


const GL_VERTEX_ARRAY=$8074;
      GL_NORMAL_ARRAY=$8075;
      GL_COLOR_ARRAY =$8076;
      GL_TEXTURE_COORD_ARRAY=$8078;

//=========================================================
implementation
Var fblp:file;                    //���: ���� blp
    hIJL:hInst;

//���������������: �������������� ���������� � ������� ��������
procedure QuaternionToMatrix(q:TQuaternion;var m:TRotMatrix);
Var wx,wy,wz,xx,yy,yz,xy,xz,zz,x2,y2,z2:GLfloat;
Begin
 x2:=q.x+q.x;
 y2:=q.y+q.y;
 z2:=q.z+q.z;
 xx:=q.x*x2; xy:=q.x*y2; xz:=q.x*z2;
 yy:=q.y*y2; yz:=q.y*z2; zz:=q.z*z2;
 wx:=q.w*x2; wy:=q.w*y2; wz:=q.w*z2;

 m[0,0]:=1.0-(yy+zz); m[1,0]:=xy-wz;       m[2,0]:=xz+wy;
 m[0,1]:=xy+wz;       m[1,1]:=1.0-(xx+zz); m[2,1]:=yz-wx;
 m[0,2]:=xz-wy;       m[1,2]:=yz+wx;       m[2,2]:=1.0-(xx+yy);
End;

//����� �������� ����������� ������� ��������
//�������� ��������:
procedure cpyMaterial(var src,dst:TMaterial);
Var i:integer;
Begin
 dst.ListNum:=src.ListNum;
 dst.TypeOfDraw:=src.TypeOfDraw;
 dst.Excentry:=src.Excentry;
 dst.IsConstantColor:=src.IsConstantColor;
 dst.IsSortPrimsFarZ:=src.IsSortPrimsFarZ;
 dst.IsFullResolution:=src.IsFullResolution;
 dst.PriorityPlane:=src.PriorityPlane;
 dst.CountOfLayers:=src.CountOfLayers;
 SetLength(dst.Layers,dst.CountOfLayers);
 for i:=0 to dst.CountOfLayers-1 do dst.Layers[i]:=src.Layers[i];
End;
//---------------------------------------------------------
//�������� Geoset'�:
procedure cpyGeoset(var src,dst:TGeoset);
Var j,i,ii,len:integer;
Begin
 dst.CountOfVertices:=src.CountOfVertices;
 SetLength(dst.Vertices,dst.CountOfVertices);
 for i:=0 to dst.CountOfVertices-1 do dst.Vertices[i]:=src.Vertices[i];

 dst.CountOfNormals:=src.CountOfNormals;
 SetLength(dst.Normals,dst.CountOfNormals);
 for i:=0 to dst.CountOfNormals-1 do dst.Normals[i]:=src.Normals[i];

 //�������� ������ ���������� ���������
 dst.CountOfCoords:=src.CountOfCoords;
 SetLength(dst.Crds,dst.CountOfCoords);
 for j:=0 to dst.CountOfCoords-1 do begin
  dst.Crds[j].CountOfTVertices:=src.Crds[j].CountOfTVertices;
  SetLength(dst.Crds[j].TVertices,dst.Crds[j].CountOfTVertices);
  for i:=0 to dst.Crds[j].CountOfTVertices-1
  do dst.Crds[j].TVertices[i]:=src.Crds[j].TVertices[i];
 end;//of for j 

 len:=High(src.VertexGroup);
 SetLength(dst.VertexGroup,len+1);
 for i:=0 to len do dst.VertexGroup[i]:=src.VertexGroup[i];

 SetLength(dst.Faces,1);
 len:=High(src.Faces[0]);
 SetLength(dst.Faces[0],len+1);
 for i:=0 to len do dst.Faces[0,i]:=src.Faces[0,i];
 dst.CountOfFaces:=1;

 dst.CountOfMatrices:=src.CountOfMatrices;
 SetLength(dst.Groups,dst.CountOfMatrices);
 for i:=0 to dst.CountOfMatrices-1 do begin
  len:=High(src.Groups[i]);
  SetLength(dst.Groups[i],len+1);
  for ii:=0 to len do dst.Groups[i,ii]:=src.Groups[i,ii];
 end;//of for i

 dst.CountOfAnims:=src.CountOfAnims;
 SetLength(dst.Anims,dst.CountOfAnims);
 for i:=0 to dst.CountOfAnims-1 do dst.Anims[i]:=src.Anims[i];

 dst.MinimumExtent:=src.MinimumExtent;
 dst.MaximumExtent:=src.MaximumExtent;
 dst.BoundsRadius:=src.BoundsRadius;
 dst.MaterialID:=src.MaterialID;
 dst.SelectionGroup:=src.SelectionGroup;
 dst.Unselectable:=src.Unselectable;
End;
//---------------------------------------------------------
//����������� ����������� ��������
procedure cpyController(var src,dest:TController);
Var i,len:integer;
Begin
 dest.ContType:=src.ContType;
 dest.GlobalSeqId:=src.GlobalSeqID;
 dest.SizeOfElement:=src.SizeOfElement;
 len:=length(src.Items);
 SetLength(dest.Items,len);
 for i:=0 to len-1 do dest.Items[i]:=src.Items[i];
End;
//---------------------------------------------------------
//����������� ������ Crds ������� �� Start-�������
procedure cpyCrds(var scr,dest:TCrds;Start:integer);
Var i:integer;
Begin
 dest.CountOfTVertices:=scr.CountOfTVertices;
 SetLength(dest.TVertices,scr.CountOfTVertices);
 for i:=Start to scr.CountOfTVertices-1 do Dest.TVertices[i]:=scr.TVertices[i];
End;
//---------------------------------------------------------
//���-���������: ������� ���-����
{procedure CreateLogFile;
Var fLog:text;
Begin
 AssignFile(fLog,'mdlvis.log');
 rewrite(fLog);
 writeln(fLog,'MdlVis �����������');
 CloseFile(fLog);
End;}
//---------------------------------------------------------
//���-���������: ������� � ��� ������-���������
procedure WriteToLog(s:string);
Var fLog:text;
Begin
 AssignFile(fLog,'mdlvis.log');
 append(fLog);
 writeln(fLog,s);
 CloseFile(fLog);
End;

//=========================================================
//��������������� ���������: ��������� ����o
function GetFloat(s:string;ps:cardinal):single;
Var si:string;i:integer;
Begin
 i:=ps;si:='';  //������ ������ ������
 while ((s[i]>='0') and (s[i]<='9')) or
       (s[i]='.') or (s[i]='-') or
       (s[i]='+') or (s[i]='e') or
       (s[i]='E') do begin
  si:=si+s[i];inc(i);
 end;//of while
 GetFloat:=strtofloat(si);//��������� � �����
End;

//���������������: ������� � ��������� �����
//ps - �������, ������� � ������� ���� ����� �����
//�� ������ - ������� ���������� �����
function GoToCipher(ps:cardinal):cardinal;
Var i:cardinal;
Begin
 i:=ps;
 while ((FileContent[i]<'0') or (FileContent[i]>'9')) and
       (FileContent[i]<>'-') do inc(i);
 GoToCipher:=i;
End;
//���������������: ����� ������ �� ������
//!err ������, ���� ����� ��������� ������ ���
function PosNext(substr,str:string;ps:cardinal):cardinal;
Var cps:cardinal;l,l2:integer;
Begin
 l2:=length(str);
 cps:=ps;l:=length(substr);
 
 while (copy(str,cps,l)<>substr) and
       (cps<l2) do begin
  inc(cps);
 end;
 PosNext:=cps;
 if cps>=l2 then PosNext:=$FFFFFFFF; //������
End;

//������ ���������� �����. ps - ������� �����
//NumGeo - ����� �����������, ��� ������� ���� ������
//NumVert - ���������� ����� �������� �����
procedure ReadVertex(var ps:cardinal;NumGeo,NumVert:integer);
Begin
 ps:=ps+FindSym(@FileContent[ps],CODE_OBRACKET);
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
 ps:=ps+ExpGetFloat(@FileContent[ps],Geosets[NumGeo-1].Vertices[NumVert-1,1]);
 ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
 ps:=ps+ExpGetFloat(@FileContent[ps],Geosets[NumGeo-1].Vertices[NumVert-1,2]);
 ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
 ps:=ps+ExpGetFloat(@FileContent[ps],Geosets[NumGeo-1].Vertices[NumVert-1,3]);
End;
//������ ���������� �������. ps - ������� �����
//NumGeo - ����� �����������, ��� ������� ���� ������
//NumNorm - ���������� ����� �������� �������
procedure ReadNormal(var ps:cardinal;NumGeo,NumNorm:integer);
Begin
 ps:=ps+FindSym(@FileContent[ps],CODE_OBRACKET);
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
 ps:=ps+ExpGetFloat(@FileContent[ps],Geosets[NumGeo-1].Normals[NumNorm-1,1]);
 ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
 ps:=ps+ExpGetFloat(@FileContent[ps],Geosets[NumGeo-1].Normals[NumNorm-1,2]);
 ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
 ps:=ps+ExpGetFloat(@FileContent[ps],Geosets[NumGeo-1].Normals[NumNorm-1,3]);
End;
//������ ���������� ��������. ps - ������� �����
//NumGeo - ����� �����������, ��� ������� ���� ������
//NumTex - ���������� ����� �������� ���� ���������
procedure ReadTexV(var ps:cardinal;NumGeo,IdCrds,NumTex:integer);
Begin
 ps:=ps+FindSym(@FileContent[ps],CODE_OBRACKET);
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
 ps:=ps+ExpGetFloat(@FileContent[ps],Geosets[NumGeo-1].Crds[IdCrds].TVertices[NumTex-1,1]);
 ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
 ps:=ps+ExpGetFloat(@FileContent[ps],Geosets[NumGeo-1].Crds[IdCrds].TVertices[NumTex-1,2]);
End;
//������ ������ ������, �������� � ��������
//NumGeo - ����� �����������, ��� ������� ���� ������
//NumFace - ����� ��������� ���������
{ TODO -o������� -c���������� : ������, ���� }
procedure ReadFace(var ps:cardinal;NumGeo,NumFace:integer);
Var EndPos:cardinal;cnt:integer;//���-�� ������ � ���������
Begin
 ps:=ps+FindSym(@FileContent[ps],CODE_OBRACKET);
 EndPos:=ps+FindSym(@FileContent[ps],CODE_CBRACKET);
// ps:=PosNext('{',FileContent,ps); //������ ������
// EndPos:=PosNext('}',FileContent,ps);//���� ����� �������
 cnt:=1;
 repeat
  SetLength(geosets[NumGeo-1].Faces[NumFace-1],cnt);//������
//  ps:=GoToCipher(ps);             //���� �����
  ps:=ps+ExpGoToCipher(@FileContent[ps]);
  ps:=ps+GetIntVal(@FileContent[ps],Geosets[NumGeo-1].Faces[NumFace-1,cnt-1]);
  //Geosets[NumGeo-1].Faces[NumFace-1,cnt-1]:=round(GetFloat(FileContent,ps));
  //ps:=PosNext(',',FileContent,ps);
  ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
  inc(cnt);
 until ps>EndPos;
End;

//������ ������� ���������� � �������
procedure ReadMatrices(var ps:cardinal;NumGeo:integer);
Var i,cnt:integer;EndPos:cardinal;
Begin
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
 //���������� ����� ������ ����������
 ps:=ps+GetIntVal(@FileContent[ps],Geosets[NumGeo-1].CountOfMatrices);
 SetLength(Geosets[NumGeo-1].Groups,Geosets[NumGeo-1].CountOfMatrices);
 for i:=0 to Geosets[NumGeo-1].CountOfMatrices-1 do begin
  ps:=PosNext('matrices',fileContent,ps);
  EndPos:=ps+FindSym(@FileContent[ps],CODE_CBRACKET);
  cnt:=1;
  repeat
   //���������� ������ �������
   SetLength(Geosets[NumGeo-1].Groups[i],cnt);
   ps:=ps+ExpGoToCipher(@FileContent[ps]);
   ps:=ps+GetIntVal(@FileContent[ps],Geosets[NumGeo-1].Groups[i,cnt-1]);
   ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
   inc(cnt);
  until  ps>=EndPos;
 end;//of for
End;
//������ ������ ������
procedure ReadExtents(var ps:cardinal;NumGeo:integer);
Var i:integer;
Begin
 //1. ������ BoundsRadius, ���� �� ����, ��� �����������
 //���� ���������� ������
 while (FileContent[ps]<>'a') and (FileContent[ps]<>'}') and
       (FileContent[ps]<>'b') do inc(ps);
 //�����-�� ������
 if (FileContent[ps]='}') or
    ((FileContent[ps]='b') and (Copy(FileContent,ps,12)<>'boundsradius'))then
 begin
  Geosets[NumGeo-1].CountOfAnims:=0;
  Geosets[NumGeo-1].BoundsRadius:=0;
  exit;
 end;//of if
 if FileContent[ps]='b' then begin //������ ������!
  ps:=ps+ExpGoToCipher(@FileContent[ps]);
  ps:=ps+ExpGetFloat(@FileContent[ps],Geosets[NumGeo-1].BoundsRadius);
 end;//of if
 Geosets[NumGeo-1].CountOfAnims:=0;
 //2. ������ ������ Anim
repeat
 while (FileContent[ps]<>'a') and (FileContent[ps]<>'}') do inc(ps);
 if copy(FileContent,ps,4)<>'anim' then exit;
// if FileContent[ps]='}' then exit; //���
 inc(Geosets[NumGeo-1].CountOfAnims);//���������� ���-�� ��������
 SetLength(Geosets[NumGeo-1].Anims,Geosets[NumGeo-1].CountOfAnims);//������
 //������ ����������
 ps:=PosNext('anim',FileContent,ps);
 //ps:=PosNext('minimumextent',FileContent,ps);
 //���� ������ �������
 ps:=ps+FindSym(@FileContent[ps],CODE_OBRACKET)+1;
 ps:=ps+FindSym(@FileContent[ps],CODE_OBRACKET);
 asm
  fninit
 end;
 for i:=1 to 3 do begin
  ps:=ps+ExpGoToCipher(@FileContent[ps]);
  ps:=ps+ExpGetFloat(@FileContent[ps],
    Geosets[NumGeo-1].Anims[Geosets[NumGeo-1].CountOfAnims-1].MinimumExtent[i]);
  ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
 end;//of for
// ps:=PosNext('maximumextent',FileContent,ps);
 //���� ������� �������
 ps:=ps+FindSym(@FileContent[ps],CODE_OBRACKET); 
 for i:=1 to 3 do begin
  ps:=ps+ExpGoToCipher(@FileContent[ps]);
  ps:=ps+ExpGetFloat(@FileContent[ps],
    Geosets[NumGeo-1].Anims[Geosets[NumGeo-1].CountOfAnims-1].MaximumExtent[i]);
  ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
 end;//of for
 ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
 while (FileContent[ps]<>'}') and (FileContent[ps]<>'b') do inc(ps);
 if FileContent[ps]<>'}' then begin
// ps:=PosNext('boundsradius',FileContent,ps);
  ps:=ps+ExpGoToCipher(@FileContent[ps]);
  ps:=ps+ExpGetFloat(@FileContent[ps],
      Geosets[NumGeo-1].Anims[Geosets[NumGeo-1].CountOfAnims-1].BoundsRadius);
 end else begin
  Geosets[NumGeo-1].Anims[Geosets[NumGeo-1].CountOfAnims-1].BoundsRadius:=600;
 end;//of if
 ps:=ps+FindSym(@FileContent[ps],CODE_CBRACKET)+1;
// ps:=PosNext('}',FileContent,ps)+1;
until false;
End;
//������ "���������" �������� �����������: ��������, ��. ��������� � ��.
procedure ReadTail(var ps:cardinal;num:integer);
Begin with Geosets[num-1] do begin
 ps:=ps-300;                      //���������� �� ����� ��������
 ps:=PosNext('materialid',FileContent,ps);//���� ID ���������
 ps:=GoToCipher(ps);              //������ �����
 MaterialID:=round(GetFloat(FileContent,ps));//������
 //������ ����������
 Unselectable:=false;SelectionGroup:=0;
repeat
 while (FileContent[ps]<>'s') and (FileContent[ps]<>'}') and
       (FileContent[ps]<>'u') do inc(ps);
 if FileContent[ps]='}' then exit;
 if FileContent[ps]='s' then begin
  ps:=GoToCipher(ps);SelectionGroup:=round(GetFloat(FileContent,ps));
 end;//of if
 if FileContent[ps]='u' then begin
  Unselectable:=true;
  exit;
 end;//of if
until false;
end;End;
//������ �����������. num - �����, CurGeoPos-������� � �����
//������ �� ������ geoset. ���. � ����� Geosets.
procedure ReadGeoset(num:integer);
Var ps{,tmpps}:cardinal;i,cnt:integer;s:string;
Begin
 //1. ������ ���-�� ������
 ps:=PosNext('vertices ',FileContent,CurGeoPos);//!err
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
 ps:=ps+GetIntVal(@FileContent[ps],Geosets[num-1].CountOfVertices);
 SetLength(Geosets[num-1].Vertices,Geosets[num-1].CountOfVertices);
 //2. ������ ������ ������
 asm
  fninit
 end;
 for i:=1 to Geosets[num-1].CountOfVertices do ReadVertex(ps,num,i);
 //3. ������ ���-�� ��������
 ps:=PosNext('normals ',FileContent,CurGeoPos);//!err
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
 ps:=ps+GetIntVal(@FileContent[ps],Geosets[num-1].CountOfNormals);
 SetLength(Geosets[num-1].Normals,Geosets[num-1].CountOfNormals);
 //4. ������ ������ ��������
 asm
  fninit
 end;
 for i:=1 to Geosets[num-1].CountOfNormals do ReadNormal(ps,num,i);

 //5. ������ ���������� ���������� (����� ������ ����� ���� ���������!)
 //5a. ���� ��������� ������
// ps:=CurGeoPos; (!dbg: ��������, ������� ����������������)
 asm
  fninit
 end;
 with Geosets[num-1] do repeat
  ps:=PosNext('tvertices ',FileContent,ps);//!err
  ps:=ps+ExpGoToCipher(@FileContent[ps]);
  //ps:=GoToCipher(ps); //������ �����
  inc(CountOfCoords);
  SetLength(Crds,CountOfCoords);
  ps:=ps+GetIntVal(@FileContent[ps],Crds[CountOfCoords-1].CountOfTVertices);
//  Crds[CountOfCoords-1].CountOfTVertices:=round(GetFloat(FileContent,ps));
  SetLength(Crds[CountOfCoords-1].TVertices,
            Crds[CountOfCoords-1].CountOfTVertices);
  //5b. ������ ������ ��������� ��������.
  for i:=1 to Crds[CountOfCoords-1].CountOfTVertices
  do ReadTexV(ps,num,CountOfCoords-1,i);
  s:=copy(FileContent,ps,50);
 until pos('tvertices',s)=0;

 //7. ������ ������ �����
 CurGeoPos:=ps;
 ps:=PosNext('vertexgroup ',FileContent,CurGeoPos);//!err
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
// ps:=GoToCipher(ps); //������ �����
 SetLength(Geosets[num-1].VertexGroup,Geosets[num-1].CountOfVertices);
 for i:=1 to Geosets[num-1].CountOfVertices do begin
  ps:=ps+GetIntVal(@FileContent[ps],Geosets[num-1].VertexGroup[i-1]);
  ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
  ps:=ps+ExpGoToCipher(@FileContent[ps]);
{  Geosets[num-1].VertexGroup[i-1]:=round(GetFloat(FileContent,ps));
  ps:=PosNext(',',FileContent,ps);
  ps:=GoToCipher(ps);              //���� �����}
 end;//of for
 //8. ������ ���-�� ���������� (Faces)
 ps:=PosNext('faces ',FileContent,CurGeoPos);//!err
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
 //! ��������������: ��� �������� � ���� ������
 while FileContent[ps]<>' ' do inc(ps);
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
 ps:=ps+GetIntVal(@FileContent[ps],cnt); //������ ��� ���-��
 Geosets[num-1].CountOfFaces:=1;
 SetLength(Geosets[num-1].Faces,Geosets[num-1].CountOfFaces);
 SetLength(Geosets[num-1].Faces[0],cnt);//���������� ������
 ps:=ps+FindSym(@FileContent[ps],CODE_OBRACKET);
 for i:=0 to cnt-1 do begin       //������ ������ ������
  ps:=ps+ExpGoToCipher(@FileContent[ps]);
  ps:=ps+GetIntVal(@FileContent[ps],Geosets[num-1].Faces[0,i]);
  ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
 end;//of for i                           

 //10. ������ �������(����. � �������)
 ps:=PosNext('groups',FileContent,ps);     //!err
 ReadMatrices(ps,num);
 //11. ������ ������� �����������
 ps:=PosNext('minimumextent',FileContent,ps);//������
 for i:=1 to 3 do begin
  ps:=ps+ExpGoToCipher(@FileContent[ps]);
  ps:=ps+ExpGetFloat(@FileContent[ps],Geosets[num-1].MinimumExtent[i]);
  ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
 end;//of for
 ps:=PosNext('maximumextent',FileContent,ps);//������������ �������
 for i:=1 to 3 do begin
  ps:=ps+ExpGoToCipher(@FileContent[ps]);
  ps:=ps+ExpGetFloat(@FileContent[ps],Geosets[num-1].MaximumExtent[i]);
  ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
 end;//of for
 ReadExtents(ps,num);//������ ������ Anim
 //������ "�����" �������� �����������
 ReadTail(ps,num); //������
 ps:=PosNext('}',FileContent,ps); //���� ���������
// EndGeosetsPos:=ps+2;             //������ enter
 //�, �������, ���������� ������:
 Geosets[num-1].CurrentListNum:=1; //��� ������
 CurGeoPos:=ps;
End;
//��������� ����� ������ �������� � ������ Textures,
//������������� CountOfTextures
{procedure LoadTexturesNames;
Var i,len,ps,ps2:cardinal;s:string;
Begin
 i:=1;len:=length(FileContent)-8;
 //����� ����� "Textures"
 repeat
  if (FileContent[i]='t') or (FileContent[i]='T') then begin
   if lowercase(copy(FileContent,i,8))='textures' then break;
  end;//of if
  inc(i);
 until i>=len;
 //���������, ������� �� ��������
 if lowercase(copy(FileContent,i,8))<>'textures' then begin
  CountOfTextures:=0;             //��� �������
  MessageBox(0,'������ ������� �� �������',scError,
                MB_ICONEXCLAMATION or MB_APPLMODAL);
  exit;                           //�����
 end;//of if
 //�������� �������! ��������� �� ����������
 ps:=GoToCipher(i);               //�����
 CountOfTextures:=round(GetFloat(FileContent,ps));
 SetLength(Textures,CountOfTextures);//���������� ������ �������
 //������ ������ ����� ������ ��������
 i:=0;
 while i<CountOfTextures do begin
  ps:=PosNext('"',FileContent,ps);inc(ps);//���� ���
  //��������, ������������� �� ��� - ��� ��������
  s:=lowercase(copy(FileContent,ps-20,20));
  if pos('image',s)=0 then begin  //�������� ���������� ���������
   CountOfTextures:=i;
   break;
  end;//of if
  ps2:=PosNext('"',FileContent,ps);//dec(ps);
  Textures[i].FileName:=copy(FileContent,ps,ps2-ps);
  ps:=ps2+1;
  inc(i);
 end;//of while
 //������ ��������, ��� �� �������������� �������
 repeat
  s:=lowercase(copy(FileContent,ps,100));
  if pos('bitmap',s)<>0 then begin //���� ���. ��������
   inc(CountOfTextures);
   SetLength(Textures,CountOfTextures);
   //������ ������ ����� ��������
   ps:=PosNext('"',FileContent,ps);inc(ps);//���� ���
   ps2:=PosNext('"',FileContent,ps);//dec(ps);
   Textures[CountOfTextures-1].FileName:=copy(FileContent,ps,ps2-ps);
   ps:=ps2+1;
  end else break;
 until false;
End;          }
//--------------------------------------------------------
//��������� ����� � ��������� �������
procedure LoadTextures;
Var i:integer;ps:cardinal;
Begin
 ps:=pos('textures ',FileContent);
 if ps=0 then begin
  MessageBox(0,'�������� �� �������.','������',MB_ICONSTOP);
  CountOfTextures:=0;
  exit;
 end;//of if
 //���� ��������
 i:=-1;
 repeat
  inc(i);
  SetLength(Textures,i+1);        //�������� ������
  FillChar(Textures[i],SizeOf(Textures[i]),0);
  Textures[i].FileName:='';
  //������ ����� ��������
  ps:=PosNext('image',FileContent,ps);
  ps:=ps+FindSym(@FileContent[ps],CODE_QM)+1;
  while FCont[ps]<>'"' do begin
   Textures[i].FileName:=Textures[i].FileName+FCont[ps];
   inc(ps);
  end;//of while

  ps:=PosNext(',',FileContent,ps);//����� �� ������ ���������
  while FileContent[ps]<>'}' do begin
   inc(ps);
   if (FileContent[ps]='w') or (FileContent[ps]='r') then begin
    if copy(FileContent,ps,13)='replaceableid' then begin
     ps:=GoToCipher(ps);          //���� � �����
     Textures[i].ReplaceableID:=round(GetFloat(FileContent,ps));
    end;//of if ReplID
    if copy(FileContent,ps,9)='wrapwidth' then begin
     Textures[i].IsWrapWidth:=true;
     ps:=PosNext(',',FileContent,ps);
    end;//of if
    if copy(FileContent,ps,10)='wrapheight' then begin
     Textures[i].IsWrapHeight:=true;
     ps:=PosNext(',',FileContent,ps);
    end;//of if
   end;//of if
  end;//of while
  inc(ps);

  while (FileContent[ps]<>'}') and (FileContent[ps]<>'{') do inc(ps);
 Until FileContent[ps]='}';
 CountOfTextures:=i+1;
End;
//---------------------------------------------------------
//������������ �������� ����������� � ������ Controllers
//� ���������� ����� ������ �����������
//ps-������� � FileContent (������� �� "{")
//CountOfKeyFrames - ���-�� �������� ������ �����������
//SizeOfElement - ������ ������ �����������
function LoadController(var ps:cardinal;CountOfKeyFrames,
                        SizeOfElement:integer):integer;
Var len,i,ii:integer;psIn,SavePs:cardinal;
Begin
 //1. ������� ����� �������-����������
 len:=length(Controllers);
 SetLength(Controllers,len+1);
 LoadController:=len;             //������� ����� ��������
 Controllers[len].GlobalSeqId:=-1;//���� ��� ����������� ID
 //2. ������� ����� ��������� �����������
 Controllers[len].SizeOfElement:=SizeOfElement;
 SetLength(Controllers[len].Items,CountOfKeyFrames);
 //3. ���������� ��� �����������
 psIn:=ps;
 repeat
  while (FileContent[psIn]<>'l') and (FileContent[psIn]<>'d') and
        (FileContent[psIn]<>'b') and (FileContent[psIn]<>'h') do inc(psIn);
 until (copy(FileContent,psIn,6)='linear') or
       (copy(FileContent,psIn,10)='dontinterp') or
       (copy(FileContent,psIn,6)='bezier') or
       (copy(FileContent,psIn,7)='hermite');
 if FileContent[psIn]='l' then Controllers[len].ContType:=Linear;
 if FileContent[psIn]='d' then Controllers[len].ContType:=DontInterp;
 if FileContent[psIn]='b' then Controllers[len].ContType:=Bezier;
 if FileContent[psIn]='h' then Controllers[len].ContType:=Hermite;
 //������ GlobalSeqID
 SavePs:=psIn;                      //���� �������� �������
 while (FileContent[psIn]<>':') and (FileContent[psIn]<>'g') do inc(psIn);
 if copy(FileContent,psIn,11)='globalseqid' then begin//�������!
  psIn:=psIn+ExpGoToCipher(@FileContent[psIn]);
  psIn:=psIn+GetIntVal(@FileContent[psIn],Controllers[len].GlobalSeqId);
  psIn:=psIn+FindSym(@FileContent[psIn],CODE_COMMA);
 end else psIn:=SavePs;                    //��������������
 //4. ���������� �������� (� ����������� �� ����)
 asm
  fninit
 end;
 for i:=0 to CountOfKeyFrames-1 do begin
  psIn:=psIn+ExpGoToCipher(@FileContent[psIn]);
  psIn:=psIn+GetIntVal(@FileContent[psIn],Controllers[len].Items[i].Frame);
  psIn:=psIn+FindSym(@FileContent[psIn],CODE_COLON);
  for ii:=1 to SizeOfElement do begin
   psIn:=psIn+ExpGoToCipher(@FileContent[psIn]);
   asm
    fninit
   end;
   psIn:=psIn+ExpGetFloat(@FileContent[psIn],Controllers[len].Items[i].Data[ii]);
   psIn:=psIn+FindSym(@FileContent[psIn],CODE_COMMA);
  end;//of for ii
  //���� ���� �������� �����, ������ ��
  if (Controllers[len].ContType=Bezier) or
     (Controllers[len].ContType=Hermite) then begin
   //������ InTan
   for ii:=1 to SizeOfElement do begin
    psIn:=psIn+ExpGoToCipher(@FileContent[psIn]);
    psIn:=psIn+ExpGetFloat(@FileContent[psIn],Controllers[len].Items[i].InTan[ii]);
    psIn:=psIn+FindSym(@FileContent[psIn],CODE_COMMA);
   end;//of for ii
   //������ OutTan
   for ii:=1 to SizeOfElement do begin
    psIn:=psIn+ExpGoToCipher(@FileContent[psIn]);
    psIn:=psIn+ExpGetFloat(@FileContent[psIn],Controllers[len].Items[i].OutTan[ii]);
    psIn:=psIn+FindSym(@FileContent[psIn],CODE_COMMA);
   end;//of for ii
  end;//of if
 end;//of for i
 //���� ����������� ������
 psIn:=psIn+FindSym(@FileContent[psIn],CODE_CBRACKET);

 //������� ����� �������
 ps:=psIn;
End;
//---------------------------------------------------------
//������ ���� ��� ��������� � ������� mnum
procedure ReadLayer(mnum:integer;var ps:cardinal);
Var lnum{,tmp}:integer;StaticFound:boolean;
Begin with Materials[mnum-1] do begin
 lnum:=CountOfLayers;             //���� ��� �������
 inc(CountOfLayers);              //�� 1 ���� ������
 SetLength(Layers,CountOfLayers); //���������� ������ ������ �����
 ps:=PosNext('filtermode',FileContent,ps);//������ ������ ��������
 ps:=ps+10;                       //������� FilterMode
 while FileContent[ps]=' ' do inc(ps);//������� ��������
 //���������� ������ ������
 if copy(FileContent,ps,4)='none' then layers[lnum].FilterMode:=Opaque;
 if copy(FileContent,ps,11)='transparent' then layers[lnum].FilterMode:=ColorAlpha;
 if copy(FileContent,ps,5)='blend' then layers[lnum].FilterMode:=FullAlpha;
 if copy(FileContent,ps,8)='additive' then layers[lnum].FilterMode:=Additive;
 if copy(FileContent,ps,8)='addalpha' then layers[lnum].FilterMode:=AddAlpha;
 if copy(FileContent,ps,8)='modulate' then layers[lnum].FilterMode:=Modulate;
 if copy(FileContent,ps,10)='modulate2x' then layers[lnum].FilterMode:=Modulate2X;
 //���� ������
 ps:=PosNext(',',FileContent,ps);
 Layers[lnum].IsUnshaded:=false;Layers[lnum].IsTwoSided:=false;
 Layers[lnum].IsUnfogged:=false;Layers[lnum].IsNoDepthTest:=false;
 Layers[lnum].IsSphereEnvMap:=false;
 Layers[lnum].IsNoDepthSet:=false;Layers[lnum].Alpha:=-1;
 Layers[lnum].IsAlphaStatic:=true;
 Layers[lnum].CoordID:=-1;
 //���������:
 Layers[lnum].IsTextureStatic:=true;
 Layers[lnum].TextureID:=-1;
 Layers[lnum].TVertexAnimID:=-1;
 StaticFound:=false; //���� �� ������� ��� �����
 repeat                           //����������� ����
  while (FileContent[ps]<>'u') and (FileContent[ps]<>'t')
         and (FileContent[ps]<>'n') and (FileContent[ps]<>'s')
         and (FileContent[ps]<>'c') and (FileContent[ps]<>'a')
         and (FileContent[ps]<>'}') do inc(ps);
  if FileContent[ps]='}' then break; //��������� ����� ������
  if copy(FileContent,ps,8)='unshaded' then Layers[lnum].IsUnshaded:=true;
  if copy(FileContent,ps,8)='twosided' then Layers[lnum].IsTwoSided:=true;
  if copy(FileContent,ps,8)='unfogged' then Layers[lnum].IsUnfogged:=true;
  if copy(FileContent,ps,11)='nodepthtest' then Layers[lnum].IsNoDepthTest:=true;
  if copy(FileContent,ps,10)='nodepthset' then Layers[lnum].IsNoDepthSet:=true;
  if copy(FileContent,ps,12)='sphereenvmap' then Layers[lnum].IsSphereEnvMap:=true;
  if copy(FileContent,ps,6)='static' then begin //��������, �����
   ps:=ps+7;//!
   StaticFound:=true;
  end;

  if copy(FileContent,ps,9)='textureid' then begin//����� �� ��������
   ps:=GoToCipher(ps);            //���� �����
   Layers[lnum].TextureID:=round(GetFloat(FileContent,ps));//������ ID
   Layers[lnum].IsTextureStatic:=true;
   if not StaticFound then begin  //�������� �������������
    Layers[lnum].IsTextureStatic:=false;
    while FileContent[ps]<>'{' do inc(ps);//���������� � ������
    Layers[lnum].NumOfTexGraph:=LoadController(ps,Layers[lnum].TextureID,1);
    inc(ps);
   end;//of if (NotStatic)
   StaticFound:=false;            //���� ��� �����������
   Continue;                      //���������� ����
  end;//of if(TextureID)

  if copy(FileContent,ps,5)='alpha' then begin//����� �� ��������
   ps:=GoToCipher(ps);            //���� �����
   Layers[lnum].Alpha:=GetFloat(FileContent,ps);//������ ID
   Layers[lnum].IsAlphaStatic:=true;
   if not StaticFound then begin  //�������� �������������
    Layers[lnum].IsAlphaStatic:=false;
    while FileContent[ps]<>'{' do inc(ps);//���������� � ������
    Layers[lnum].NumOfGraph:=LoadController(ps,round(Layers[lnum].Alpha),1);
    inc(ps);
   end;//of if (NotStatic)
   StaticFound:=false;            //���� ��� �����������
   Continue;                      //���������� ����
  end;//of if(TextureID)

  if copy(FileContent,ps,13)='tvertexanimid' then begin//������� ����.
   ps:=GoToCipher(ps);
   Layers[lnum].TVertexAnimID:=round(GetFloat(FileContent,ps));
  end;//of if(TVertexAnimID)

  if copy(FileContent,ps,7)='coordid' then begin
   ps:=GoToCipher(ps);
   Layers[lnum].CoordID:=round(GetFloat(FileContent,ps));
  end;//of if(CoordId)

  ps:=PosNext(',',FileContent,ps);//����������� ����� ��������
 until false;                     //����� ��
 inc(ps);                         //������� �������� ������
end;End;

//��������� (��������) ��������� � ������������� �� ���-��
procedure LoadMaterials;
Var ps:cardinal;m:integer;
Begin
 ps:=pos('materials',FileContent);//���� ������ ����������
 ps:=GoToCipher(ps);              //�����
 if ps=0 then begin               //��� ������
  MessageBox(0,'������ ���������� �� �������',scError,
                mb_iconexclamation or mb_applmodal);
  CountOfMaterials:=0;exit;
 end;//of if      
 CountOfMaterials:=round(GetFloat(FileContent,ps));//������ ���-�� ����������
 SetLength(Materials,CountOfMaterials);//����������� �����
 //���� ������ ����������
 for m:=0 to CountOfMaterials-1 do begin
  Materials[m].ListNum:=-1;
  Materials[m].Layers:=nil;Materials[m].CountOfLayers:=0;
  Materials[m].IsConstantColor:=false;
  Materials[m].PriorityPlane:=-1;
  Materials[m].IsSortPrimsFarZ:=false;
  Materials[m].IsFullResolution:=false;
  ps:=PosNext('material',FileContent,ps);//������ ������
  ps:=ps+9;                       //������� ����� "material"
  repeat                          //����������� ����
  //���� ���� ��� �������� ��������
  while (FileContent[ps]<>'c') and (FileContent[ps]<>'l')
        and (FileContent[ps]<>'}')
        and (FileContent[ps]<>'m')
        and (FileContent[ps]<>'p')
        and (FileContent[ps]<>'s')
        and (FileContent[ps]<>'f') do inc(ps);
  if FileContent[ps]='m' then break;//����� �� ��
  if FileContent[ps]='c' then begin
   Materials[m].IsConstantColor:=true;
{   ps:=PosNext('layer',FileContent,ps);//���� � ����
   ReadLayer(m+1,ps);                 //������ ����}
   ps:=ps+13;
//   ps:=PosNext('}',FileContent,ps);
  end;//of if
  if copy(FileContent,ps,13)='priorityplane' then begin
   ps:=GoToCipher(ps);
   Materials[m].PriorityPlane:=round(GetFloat(FileContent,ps));
   //ps:=ps+13;
  end;//of if

  if copy(FileContent,ps,13)='sortprimsfarz' then begin
   Materials[m].IsSortPrimsFarZ:=true;
   ps:=ps+13;
  end;//of if (SortPrimsFarZ)

  if copy(FileContent,ps,14)='fullresolution' then begin
   Materials[m].IsFullResolution:=true;
   ps:=ps+14;
  end;//of if
  if FileContent[ps]='}' then break;//����� �� ��
  //������ ����
  if FileContent[ps]='l' then ReadLayer(m+1,ps);
  until false;                    //����� ��
 end;//of for (m)
End;

//���������������: ������ ���������� ���� � �������� ������
//� ���������� ��� � ���� float-�����
function ReadField(FieldName:string):single;
Var ps:cardinal;
Begin
 ReadField:=0;
 ps:=pos(FieldName,FileContent);  //���� ����
 if ps=0 then exit;               //�� �������
 if copy(FileContent,ps,20)='numparticleemitters2' then begin
  FileContent[ps+20]:='x';
  ps:=GoToCipher(ps);inc(ps);
//  while FileContent[ps]<>' ' do inc(ps);
 end;//of if
 ps:=GoToCipher(ps);              //������ �����
 ReadField:=GetFloat(FileContent,ps);//������� ��������
End;      
//��������� �������� (�������, ������)
procedure LoadAnimBounds(var ps:cardinal;var a:Tanim);
Var psIn:cardinal;i:integer;
Begin
 psIn:=ps;
 a.MinimumExtent[1]:=0;a.MinimumExtent[2]:=0;a.MinimumExtent[3]:=0;
 a.MaximumExtent[1]:=0;a.MaximumExtent[2]:=0;a.MaximumExtent[3]:=0;
 a.BoundsRadius:=0;
 //���� �������
 repeat
 while (FileContent[psIn]<>'}') and (FileContent[psIn]<>'m')
       and (FileContent[psIn]<>'b') do inc(psIn);
 if FileContent[psIn]='}' then break;//����� ������
 //������ ������� ���.
 if copy(FileContent,psIn,13)='minimumextent' then begin
  for i:=1 to 3 do begin
   psIn:=GoToCipher(psIn);
   a.MinimumExtent[i]:=GetFloat(FileContent,psIn);
   psIn:=PosNext(',',FileContent,psIn);
  end;//of for
  inc(psIn);                      //������� �������
 end;//of if
 //������ ������� ����.
 if copy(FileContent,psIn,13)='maximumextent' then begin
  for i:=1 to 3 do begin
   psIn:=GoToCipher(psIn);
   a.MaximumExtent[i]:=GetFloat(FileContent,psIn);
   psIn:=PosNext(',',FileContent,psIn);
  end;//of for
  inc(psIn);                      //������� �������
 end;//of if
 //��������� ������
 if copy(FileContent,psIn,12)='boundsradius' then begin
  psIn:=GoToCipher(psIn);
  a.BoundsRadius:=GetFloat(FileContent,psIn);
 end;//of if
 inc(psIn);
 until false;

 ps:=psIn;
End;
//������ ���-�� ������������������� � �� �����
(*procedure LoadSeqNames;
Var ps,len:cardinal;i:integer;s:string;
Begin
 //1. ������ ������ �������������������
 ps:=pos('}',FileContent);        //������ ������
 repeat
  inc(ps);
  while (FileContent[ps]<>'S') and (FileContent[ps]<>'s') do begin
   inc(ps);
   if ps>=length(FileContent) then begin
    CountOfSequences:=0;
    exit;
   end;//of if
  end;//of while
 until lowercase(copy(FileContent,ps,10))='sequences ';
 //2. ������� ���-�� �������������������
 ps:=GoToCipher(ps);
 CountOfSequences:=round(GetFloat(FileContent,ps));
 SetLength(Sequences,CountOfSequences);
 //3. ���� ������ ����
 i:=0;len:=Length(FileContent);
 while i<CountOfSequences do begin
  while (FileContent[ps]<>'"') and (ps<len) do inc(ps);//����� �����
  //��������, �� ��������� �� ������������������
  s:=lowercase(copy(FileContent,ps-40,40));
  if pos('anim',s)=0 then begin   //��� ���������
   CountOfSequences:=i;
   break;
  end;//of if
  Sequences[i].Name:='';          //�������������
  inc(ps);
  while FileContent[ps]<>'"' do begin//���� ������
   Sequences[i].Name:=Sequences[i].Name+FileContent[ps];
   inc(ps);
  end;//of while
  inc(ps);
  inc(i);
 end;//of while

 //��������, �� �������� �� �� �� ������ ������
 repeat
  s:=lowercase(copy(FileContent,ps,256));
  if pos('anim',s)<>0 then begin
   inc(CountOfSequences);
   SetLength(Sequences,CountOfSequences);
   while (FileContent[ps]<>'"') and (ps<len) do inc(ps);//����� �����
   Sequences[CountOfSequences-1].Name:=''; //�������������
   inc(ps);
   while FileContent[ps]<>'"' do begin//���� ������
    Sequences[CountOfSequences-1].Name:=
             Sequences[CountOfSequences-1].Name+FileContent[ps];
    inc(ps);
   end;//of while
   inc(ps);
  end else break;
 until false;
End;                 *)
//----------------------------------------------------------
//�������� ������ (� �.�. �����) �������������������
procedure LoadSeqData;
Var ps:cardinal;i:integer;
Begin
 //if CountOfSequences=0 then exit;
 //1. ���������� � ����������
 ps:=pos('sequences ',FileContent);
 if ps=0 then begin
  CountOfSequences:=0;
  exit;
 end;//of if

 //2. ���� ������
 i:=-1;
 repeat
  inc(i);
  SetLength(Sequences,i+1);
  Sequences[i].Name:='';
  Sequences[i].IntervalStart:=0;
  Sequences[i].IntervalEnd:=0;
  Sequences[i].Rarity:=-1;        //�������������
  Sequences[i].IsNonLooping:=false;
  Sequences[i].MoveSpeed:=-1;
  Sequences[i].Bounds.BoundsRadius:=0;
  //������ ����� ������ ���
  ps:=PosNext('anim ',FileContent,ps);//������ ���������
  ps:=ps+FindSym(@FileContent[ps],CODE_QM)+1;
  while FCont[ps]<>'"' do begin
   Sequences[i].Name:=Sequences[i].Name+FCont[ps];
   inc(ps);
  end;//of while

  ps:=PosNext('{',FileContent,ps);//������� � ������
  repeat                          //������������
   while (FileContent[ps]<>'i') and (FileContent[ps]<>'r')
         and (FileContent[ps]<>'}') and (FileContent[ps]<>'m')
         and (FileContent[ps]<>'n') and (FileContent[ps]<>'b') do inc(ps);
   if FileContent[ps]='}' then break;//����� ���������
   if copy(FileContent,ps,8)='interval' then begin//������ ���������
    ps:=GoToCipher(ps);//���� �����
    Sequences[i].IntervalStart:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>',' do inc(ps);
    ps:=GoToCipher(ps);//���� �����
    Sequences[i].IntervalEnd:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>',' do inc(ps);    
   end;//of if
   if copy(FileContent,ps,10)='nonlooping' then Sequences[i].IsNonLooping:=true;
   if copy(FileContent,ps,6)='rarity' then begin
    ps:=GoToCipher(ps);
    Sequences[i].Rarity:=round(GetFloat(FileContent,ps));
   end;//of if (rarity)
   if copy(FileContent,ps,9)='movespeed' then begin
    ps:=GoToCipher(ps);
    Sequences[i].MoveSpeed:=round(GetFloat(FileContent,ps));
   end;//of if
   if (copy(FileContent,ps,13)='minimumextent') or
      (copy(FileContent,ps,13)='maximumextent') or
      (copy(FileContent,ps,12)='boundsradius') then begin
    LoadAnimBounds(ps,Sequences[i].Bounds);
    inc(ps);
    break;                        //����� �����
   end;//of if
   inc(ps);                       //��� �����������
  until false;
  while (FileContent[ps]<>'a') and (FileContent[ps]<>'}') do inc(ps);
 until FileContent[ps]='}';

 CountOfSequences:=i+1;
End;
//----------------------------------------------------------
//�������� ���������� �������������������
procedure LoadGlobalSequences;
Var ps:cardinal;i:integer;
Begin
 ps:=pos('globalsequences',FileContent);//������ ������
 if ps=0 then begin               //��� ����� ������
  CountOfGlobalSequences:=0;
  GlobalSequences:=nil;           //���������� ������
  exit;                           //�����
 end;//of if
 //���� ������ ����
 ps:=GoToCipher(ps);              //����� �� ���-��
 CountOfGlobalSequences:=round(GetFloat(FileContent,ps));
 SetLength(GlobalSequences,CountOfGlobalSequences);
 while FileContent[ps]<>'{' do inc(ps);//����� � ������
 for i:=0 to CountOfGlobalSequences-1 do begin
  ps:=GoTocipher(ps);             //����� �����
  GlobalSequences[i]:=round(GetFloat(FileContent,ps));
//  if GlobalSequences[i]=0 then GlobalSequences[i]:=2;
  while FileContent[ps]<>',' do inc(ps);
 end;//of for
End;
//������ ������ GeosetAnims � ��������������� ������
procedure ReadGeosetAnims;
Var i,ii:integer;ps:cardinal;IsStatic:boolean;s:string;
Begin
 ps:=pos('geosetanim ',FileContent);//������ ������ ������
 if ps=0 then begin               //������ ��� ����� ������
  CountOfGeosetAnims:=0;
  exit;
 end;//of if
 SetLength(GeosetAnims,CountOfGeosetAnims);//�������� �����
 i:=0;
 while i<CountOfGeosetAnims do with GeosetAnims[i] do begin
  //1. �������������
  Alpha:=-1;
  Color[1]:=-1;Color[2]:=-1;Color[3]:=-1;
  GeosetID:=-1;
  IsAlphaStatic:=true;IsColorStatic:=true;
  IsStatic:=false;IsDropShadow:=false;
  //2. ���� ������ ������
  while FileContent[ps]<>'{' do inc(ps);
  //3. �����+������ ����������
  //��� ������ ��������, �� ��������� �� ������
  s:=copy(FileContent,ps-40,40);
  if pos('geosetanim',s)=0 then begin //���������
   CountOfGeosetAnims:=i;
   break;
  end;//of if
  repeat                          //�� �������
   while (FileContent[ps]<>'a') and (FileContent[ps]<>'c') and
         (FileContent[ps]<>'g') and (FileContent[ps]<>'s') and
         (FileContent[ps]<>'}') and (FileContent[ps]<>'d') do inc(ps);
   if FileContent[ps]='}' then break;//����� ������
   if copy(FileContent,ps,10)='dropshadow' then begin
    ps:=ps+10;
    continue;
   end;//of if (DropShadow)

   if copy(FileContent,ps,6)='static' then begin
    IsStatic:=true;ps:=ps+6;
   end;//of if (static)

   if copy(FileContent,ps,8)='geosetid' then begin
    ps:=GoToCipher(ps);
    GeosetID:=round(GetFloat(FileContent,ps));//������ ID
   end;//of if

   if copy(FileContent,ps,5)='alpha' then begin
    ps:=GoToCipher(ps);           //������� �������
    Alpha:=GetFloat(FileContent,ps);
    if IsStatic then begin        //����������� ������� 
     IsAlphaStatic:=true;IsStatic:=false;
    end else begin                //������������ �������
     IsAlphaStatic:=false;
     while FileContent[ps]<>'{' do inc(ps);
     AlphaGraphNum:=LoadController(ps,round(alpha),1);
     inc(ps);
    end;//of if (static/dynamic)
   end;//of if (alpha)

   if copy(FileContent,ps,5)='color' then begin
    ps:=GoToCipher(ps);           //������� �����
    if IsStatic then begin        //����������� �������
     IsColorStatic:=true;IsStatic:=false;
     for ii:=1 to 3 do begin
      ps:=GoToCipher(ps);
      Color[ii]:=GetFloat(FileContent,ps);
      ps:=PosNext(',',FileContent,ps);
     end;//of for ii
    end else begin                //������������ �������
     Color[1]:=GetFloat(FileContent,ps);//������ ���-�� ������
     IsColorStatic:=false;
     while FileContent[ps]<>'{' do inc(ps);
     ColorGraphNum:=LoadController(ps,round(Color[1]),3);
     inc(ps);
    end;//of if (static/dynamic)
   end;//of if (color)
  until false;                    //����� ��

  //�������, ��� �� ���� �� ������ ������
  if i=CountOfGeosetAnims-1 then begin
   s:=copy(FileContent,ps,100);
   if pos('geosetanim',s)<>0 then begin
    inc(CountOfGeosetAnims);
    SetLength(GeosetAnims,CountOfGeosetAnims);
   end;//of if
  end;//of if
  inc(i);
 end;//of with/while i
End;
//���������������: ��������� ��������� �����/���������
//� ���������� ��. ps-������� "Bone" ��� "Helper"
function ReadTBone(var ps:cardinal):TBone;
Var b:TBone;{i:integer;}psIn,psStart,psEnd:cardinal;
    s:string;
Begin
 //0. �������������
 b.ObjectID:=-1;b.GeosetID:=-1;b.GeosetAnimID:=-1;
 b.IsBillboarded:=false;b.Parent:=-1;
 b.IsBillboardedLockX:=false;
 b.IsBillboardedLockY:=false;
 b.IsBillboardedLockZ:=false;
 b.IsCameraAnchored:=false;
 b.Translation:=-1;b.Rotation:=-1;b.Scaling:=-1;b.Visibility:=-1;
 b.IsDIRotation:=false;b.IsDITranslation:=false;b.IsDIScaling:=false;
 //1. ������ ���
 s:='';
 while FileContent[ps]<>'"' do inc(ps);//����� �����
 inc(ps);                         //ps-��������� �� ���
 psStart:=ps;
 while FileContent[ps]<>'"' do inc(ps);
 psEnd:=ps;
 b.Name:=copy(FCont,psStart,psEnd-psStart);                       //��� ���������
 //2. �������� ������ ����� ����������
 while FileContent[ps]<>'{' do inc(ps);//������ ������
 repeat                           //�� ������
  while (FileContent[ps]<>'o') and (FileContent[ps]<>'g') and
        (FileContent[ps]<>'b') and (FileContent[ps]<>'p') and
        (FileContent[ps]<>'t') and (FileContent[ps]<>'r') and
        (FileContent[ps]<>'s') and (FileContent[ps]<>'v') and
        (FileContent[ps]<>'}') and (FileContent[ps]<>'/') and
        (FileContent[ps]<>'d') and (FileContent[ps]<>'c') do inc(ps);
  //��������, ��� ����� �������
  if FileContent[ps]='}' then break;//����� ������
  if FileContent[ps]='/' then begin //�����������
   while FileContent[ps]<>#13 do inc(ps);
   continue;
  end;//of if

  if copy(FileContent,ps,8)='objectid' then begin
   ps:=GoToCipher(ps);
   b.ObjectID:=round(GetFloat(FileContent,ps));
   continue;
  end;//of if

  if copy(FileContent,ps,8)='geosetid' then begin
   psIn:=ps+8;                    //�������� �� "Multiple"
   while (FileContent[psIn]<>'m') and (FileContent[psIn]<>',') do inc(psIn);
   if FileContent[psIn]=',' then begin//�����
    ps:=GoToCipher(ps);
    b.GeosetID:=round(GetFloat(FileContent,ps));
   end else begin                 //Multiple
    b.GeosetID:=Multiple;
   end;//of if(��� GeosetID)
   ps:=psIn;
   continue;
  end;//of if

  if copy(FileContent,ps,12)='geosetanimid' then begin
   psIn:=ps+12;                   //�������� �� "None"
   while (FileContent[psIn]<>'n') and (FileContent[psIn]<>',') do inc(psIn);
   if FileContent[psIn]=',' then begin//�����
    ps:=GoToCipher(ps);
    b.GeosetAnimID:=round(GetFloat(FileContent,ps));
   end else begin                 //Multiple
    b.GeosetAnimID:=None;
   end;//of if(��� GeosetID)
   ps:=psIn;
   continue;
  end;//of if

  if copy(FileContent,ps,16)='billboardedlockz' then begin
   b.IsBillboardedLockZ:=true;
   while FileContent[ps]<>',' do inc(ps);
   continue;
  end;//of if
  if copy(FileContent,ps,16)='billboardedlockx' then begin
   b.IsBillboardedLockX:=true;
   while FileContent[ps]<>',' do inc(ps);
   continue;
  end;//of if
  if copy(FileContent,ps,16)='billboardedlocky' then begin
   b.IsBillboardedLockY:=true;
   while FileContent[ps]<>',' do inc(ps);
   continue;
  end;//of if

  if copy(FileContent,ps,11)='billboarded' then begin
   b.IsBillboarded:=true;
   while FileContent[ps]<>',' do inc(ps);
   continue;
  end;//of if

  if copy(FileContent,ps,13)='cameraanchored' then begin
   b.IsCameraAnchored:=true;
   while FileContent[ps]<>',' do inc(ps);
   continue;
  end;//of if

  if copy(FileContent,ps,6)='parent' then begin
   ps:=GoToCipher(ps);
   b.Parent:=round(GetFloat(FileContent,ps));
   continue;
  end;//of if

  if copy(FileContent,ps,11)='dontinherit' then begin
   ps:=ps+11;                     //������� ����� ���������
   repeat
   while (FileContent[ps]<>'r') and (FileContent[ps]<>'}') and
         (FileContent[ps]<>'t') and (FileContent[ps]<>'s') do inc(ps);
    if FileContent[ps]='r' then begin
     b.IsDIRotation:=true;ps:=ps+8;
    end;//of if (Rotation)
    if FileContent[ps]='t' then begin 
     b.IsDITranslation:=true;ps:=ps+11;
    end;//of if (Translation)
    if FileContent[ps]='s' then begin
     b.IsDIScaling:=true;ps:=ps+7;
    end;//of if
   until FileContent[ps]='}';
  end;//of if

  //������ - ��������� ��������������
  if copy(FileContent,ps,11)='translation' then begin
   ps:=GoToCipher(ps);
   b.Translation:=round(GetFloat(FileContent,ps));
   while FileContent[ps]<>'{' do inc(ps);
   b.Translation:=LoadController(ps,b.Translation,3);
   inc(ps);
   continue;
  end;//of if

  if copy(FileContent,ps,8)='rotation' then begin
   ps:=GoToCipher(ps);
   b.Rotation:=round(GetFloat(FileContent,ps));
   while FileContent[ps]<>'{' do inc(ps);
   b.Rotation:=LoadController(ps,b.Rotation,4);
   inc(ps);
   continue;
  end;//of if

  if copy(FileContent,ps,7)='scaling' then begin
   ps:=GoToCipher(ps);
   b.Scaling:=round(GetFloat(FileContent,ps));
   while FileContent[ps]<>'{' do inc(ps);
   b.Scaling:=LoadController(ps,b.Scaling,3);
   inc(ps);
   continue;
  end;//of if

  if copy(FileContent,ps,10)='visibility' then begin
   ps:=GoToCipher(ps);
   b.Visibility:=round(GetFloat(FileContent,ps));
   while FileContent[ps]<>'{' do inc(ps);
   b.Visibility:=LoadController(ps,b.Visibility,1);
   inc(ps);
   continue;
  end;//of if

  //MessageBox
  inc(ps);
 until false;                     //����� ��
 ReadTBone:=b;                    //������� ��������
End;
//��������� ������ ������
procedure ReadBones;
Var ps:cardinal;i:integer;
Begin
 ps:=pos('bone ',FileContent);
 SetLength(bones,CountOfBones);
 //���� ��������
 for i:=0 to CountOfBones-1 do begin
  ps:=PosNext('bone',FileContent,ps);
  bones[i]:=ReadTBone(ps);        //������
 end;//of for
 inc(ps);
 while (FileContent[ps]=#13) or (FileContent[ps]=#10)
       or (FileContent[ps]=' ') do inc(ps);
 //� ������ ������������� ������� ��������� ObjectID=0
 if (CountOfBones=1) and (Bones[0].ObjectID<0) then Bones[0].ObjectID:=0;
// EndGeosetsPos:=ps-1;
end;
//�������� ������ ����������
procedure ReadHelpers;
Var ps:cardinal;i:integer;
Begin
 ps:=pos('helper ',FileContent);
 SetLength(helpers,CountOfHelpers);
 //���� ��������
 for i:=0 to CountOfHelpers-1 do begin
  ps:=PosNext('helper',FileContent,ps);
  helpers[i]:=ReadTBone(ps);        //������
 end;//of for
 if CountOfHelpers<>0 then begin
  inc(ps);
  while (FileContent[ps]=#13) or (FileContent[ps]=#10)
        or (FileContent[ps]=' ') do inc(ps);
//  EndGeosetsPos:=ps-1;
 end;//of if
end;
//��������� ������ �������������� �������
procedure LoadPivotPoints;
Var i,ii:integer;ps:cardinal;
Begin
 //1. ����� ������ � ������ ���-�� �������
 ps:=pos('pivotpoints ',FileContent);
 ps:=GoToCipher(ps);
 CountOfPivotPoints:=round(GetFloat(FileContent,ps));
 while FileContent[ps]<>'{' do inc(ps);
 //2. �������� �����
 SetLength(pivotPoints,CountOfPivotPoints);
 for i:=0 to CountOfPivotPoints-1 do begin
  for ii:=1 to 3 do begin
   ps:=GoToCipher(ps);
   PivotPoints[i,ii]:=GetFloat(FileContent,ps);
   while FileContent[ps]<>',' do inc(ps);
  end;//of for ii
 end;//of for
End;

//���������������: ���������������� ������ TBone
procedure InitTBone(var b:TBone);
Begin
 b.Name:='';
 b.ObjectID:=-1;
 b.GeosetID:=-1;
 b.GeosetAnimID:=-1;
 b.IsBillboarded:=false;
 b.IsBillboardedLockX:=false;
 b.IsBillboardedLockY:=false;
 b.IsBillboardedLockZ:=false;
 b.IsCameraAnchored:=false;
 b.Parent:=-1;
 b.Translation:=-1;
 b.Rotation:=-1;
 b.Scaling:=-1;
 b.Visibility:=-1;
 b.IsDIRotation:=false;
 b.IsDITranslation:=false;
 b.IsDIScaling:=false;
End;

//��������� ��������� �����
procedure LoadLights(var ps:cardinal);
Var {ps,}{len:cardinal;}i,ii:integer;StaticFound:boolean;
Begin
 //1. ����������� ����� � ������� ������ ����������
 if CountOfLights=0 then exit;     //��� ���������� �����
 SetLength(Lights,CountOfLights);  //������. �����
 ps:=pos('light ',FileContent);    //���� ������

 //������ ���� ����������
 for i:=0 to CountOfLights-1 do begin
  ps:=PosNext('light ',FileContent,ps);
  //1. ���������� ��������� ��������
  InitTBone(Lights[i].Skel);
  Lights[i].AttenuationStart:=-1;Lights[i].AttenuationEnd:=-1;
  Lights[i].Intensity:=-1;
  Lights[i].Color[1]:=-1;Lights[i].Color[2]:=-1;Lights[i].Color[3]:=-1;
  Lights[i].IsASStatic:=true;Lights[i].IsAEStatic:=true;
  Lights[i].IsIStatic:=true;Lights[i].IsCStatic:=true;
  Lights[i].IsAIStatic:=true;Lights[i].IsACStatic:=true;
  //2. ��������� ��� ���������
  while FileContent[ps]<>'"' do inc(ps); //���� ���
  inc(ps);Lights[i].Skel.Name:='';
  while FCont[ps]<>'"' do begin
   Lights[i].Skel.Name:=Lights[i].Skel.Name+FCont[ps];
   inc(ps);
  end;//of while

  //3. �������� ���� ������ �����
  StaticFound:=false;
  repeat
   while (FileContent[ps]<>'}') and (FileContent[ps]<>'o') and
         (FileContent[ps]<>'p') and (FileContent[ps]<>'b') and
         (FileContent[ps]<>'c') and (FileContent[ps]<>'d') and
         (FileContent[ps]<>'a') and (FileContent[ps]<>'s') and
         (FileContent[ps]<>'i') and (FileContent[ps]<>'v') and
         (FileContent[ps]<>'t') and (FileContent[ps]<>'r') do inc(ps);
   if FileContent[ps]='}' then break;//����� ������
   if copy(FileContent,ps,8)='objectid' then begin
    ps:=GoToCipher(ps);
    Lights[i].Skel.ObjectID:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (ObjectID)

   if copy(FileContent,ps,6)='parent' then begin
    ps:=GoToCipher(ps);
    Lights[i].Skel.Parent:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if

   if copy(FileContent,ps,16)='billboardedlockz' then begin
    ps:=ps+16;
    Lights[i].Skel.IsBillboardedLockZ:=true;
    Continue;
   end;//of if
   if copy(FileContent,ps,16)='billboardedlockx' then begin
    ps:=ps+16;
    Lights[i].Skel.IsBillboardedLockX:=true;
    Continue;
   end;//of if
   if copy(FileContent,ps,16)='billboardedlocky' then begin
    ps:=ps+16;
    Lights[i].Skel.IsBillboardedLockY:=true;
    Continue;
   end;//of if
   if copy(FileContent,ps,11)='billboarded' then begin
    ps:=ps+11;
    Lights[i].Skel.IsBillboarded:=true;
    Continue;
   end;//of if

   //����������
   if copy(FileContent,ps,14)='cameraanchored' then begin
    ps:=ps+14;
    Lights[i].Skel.IsCameraAnchored:=true;
    Continue;
   end;//of if

   //������ ������������
   if copy(FileContent,ps,11)='dontinherit' then begin
    ps:=ps+11;
    repeat                        //��
     while (FileContent[ps]<>'}') and (FileContent[ps]<>'r') and
           (FileContent[ps]<>'t') and (FileContent[ps]<>'s') do inc(ps);
     if copy(FileContent,ps,8)='rotation' then begin
      Lights[i].Skel.IsDIRotation:=true;
      ps:=ps+8;
      continue;
     end;//of if
     if copy(FileContent,ps,11)='translation' then begin
      Lights[i].Skel.IsDITranslation:=true;
      ps:=ps+11;
      continue;
     end;//of if
     if copy(FileContent,ps,7)='scaling' then begin
      Lights[i].Skel.IsDIScaling:=true;
      ps:=ps+7;
      continue;
     end;//of if
     inc(ps);
    until false;                  //����� ��
    inc(ps);
   end;//of if

   //����������. ��� ���������:
   if copy(FileContent,ps,15)='omnidirectional' then begin
    ps:=ps+15;
    Lights[i].LightType:=Omnidirectional;
    continue;
   end;//of if
   if copy(FileContent,ps,11)='directional' then begin
    ps:=ps+11;
    Lights[i].LightType:=Directional;
    continue;
   end;//of if
   if copy(FileContent,ps,7)='ambient' then begin
    ps:=ps+7;
    Lights[i].LightType:=Ambient;
    continue;
   end;//of if

   //������ �����������
   if copy(FileContent,ps,6)='static' then begin
    ps:=ps+6;
    StaticFound:=true;
    continue;
   end;//of if

   //�������������
   if copy(FileContent,ps,16)='attenuationstart' then begin
    ps:=GoToCipher(ps);
    Lights[i].AttenuationStart:=GetFloat(FileContent,ps);
    if not StaticFound then begin //������ �����������
     while FileContent[ps]<>'{' do inc(ps);
     Lights[i].AttenuationStart:=LoadController(ps,
                                 round(Lights[i].AttenuationStart),1);
     inc(ps);
     Lights[i].IsASStatic:=false;
    end;//of if (not Static)
    StaticFound:=false;
   end; //of if (AttenuationStart)
   if copy(FileContent,ps,14)='attenuationend' then begin
    ps:=GoToCipher(ps);
    Lights[i].AttenuationEnd:=GetFloat(FileContent,ps);
    if not StaticFound then begin //������ �����������
     while FileContent[ps]<>'{' do inc(ps);
     Lights[i].AttenuationEnd:=LoadController(ps,
                                round(Lights[i].AttenuationEnd),1);
     inc(ps);
     Lights[i].IsAEStatic:=false;
    end;//of if (not Static)
    StaticFound:=false;
   end;//of if (AttenuationEnd)
   if copy(FileContent,ps,9)='intensity' then begin
    ps:=GoToCipher(ps);
    Lights[i].Intensity:=GetFloat(FileContent,ps);
    if not StaticFound then begin //������ �����������
     while FileContent[ps]<>'{' do inc(ps);
     Lights[i].Intensity:=LoadController(ps,round(Lights[i].Intensity),1);
     inc(ps);
     Lights[i].IsIStatic:=false;
    end;//of if (not Static)
    StaticFound:=false;
   end;//of if (Intensity)

   //������ �����
   if copy(FileContent,ps,5)='color' then begin
    if StaticFound then begin     //����������� ����
     for ii:=1 to 3 do begin      //������ ���������
      ps:=GoToCipher(ps);
      Lights[i].Color[ii]:=GetFloat(FileContent,ps);
      ps:=PosNext(',',FileContent,ps);
     end;//of for ii
     StaticFound:=false;
    end else begin                //���� ����������
     ps:=GoToCipher(ps);
     Lights[i].Color[1]:=round(GetFloat(FileContent,ps));
     while FileContent[ps]<>'{' do inc(ps);
     Lights[i].Color[1]:=LoadController(ps,round(Lights[i].Color[1]),3);
     inc(ps);
     Lights[i].IsCStatic:=false;
    end;//of if(ColorStatic)
   end;//of if(Color)

   //��� ���� �������������
   if copy(FileContent,ps,12)='ambintensity' then begin
    ps:=GoToCipher(ps);
    Lights[i].AmbIntensity:=GetFloat(FileContent,ps);
    if not StaticFound then begin //������ �����������
     while FileContent[ps]<>'{' do inc(ps);
     Lights[i].AmbIntensity:=LoadController(ps,round(Lights[i].AmbIntensity),1);
     inc(ps);
     Lights[i].IsAIStatic:=false;
    end;//of if (not Static)
    StaticFound:=false;
   end;//of if (Intensity)

   //��� ���� ����
   if copy(FileContent,ps,8)='ambcolor' then begin
    if StaticFound then begin     //����������� ����
     for ii:=1 to 3 do begin      //������ ���������
      ps:=GoToCipher(ps);
      Lights[i].AmbColor[ii]:=GetFloat(FileContent,ps);
      ps:=PosNext(',',FileContent,ps);
     end;//of for ii
     StaticFound:=false;
    end else begin                //���� ����������
     ps:=GoToCipher(ps);
     Lights[i].AmbColor[1]:=round(GetFloat(FileContent,ps));
     while FileContent[ps]<>'{' do inc(ps);
     Lights[i].AmbColor[1]:=LoadController(ps,round(Lights[i].AmbColor[1]),3);
     inc(ps);
     Lights[i].IsACStatic:=false;
    end;//of if(ColorStatic)
   end;//of if(Color)

   //������ - ����������� ��������������
   if copy(FileContent,ps,10)='visibility' then begin
    ps:=GoToCipher(ps);
    Lights[i].Skel.Visibility:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Lights[i].Skel.Visibility:=LoadController(ps,Lights[i].Skel.Visibility,1);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,11)='translation' then begin
    ps:=GoToCipher(ps);
    Lights[i].Skel.Translation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Lights[i].Skel.Translation:=LoadController(ps,Lights[i].Skel.Translation,3);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,8)='rotation' then begin
    ps:=GoToCipher(ps);
    Lights[i].Skel.Rotation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Lights[i].Skel.Rotation:=LoadController(ps,Lights[i].Skel.Rotation,4);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,7)='scaling' then begin
    ps:=GoToCipher(ps);
    Lights[i].Skel.Scaling:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Lights[i].Skel.Scaling:=LoadController(ps,Lights[i].Skel.Scaling,3);
    inc(ps);
   end;//of if
   inc(ps);//!
  until false;                    //����� ��
 end;//of for i
End;

//��������� ���������� ��������
procedure LoadTextureAnims;
Var i,KeyNum:integer;
    ps:cardinal;
Begin
 //1. ������� ������ ������
 ps:=pos('textureanims ',FileContent);//!
 if ps=0 then begin               //������ �� �������
  CountOfTextureAnims:=0;
  TextureAnims:=nil;
  exit;
 end;//of if (TextureAnims Not Found)

 //2. ������ ���������� ��������� ������
 ps:=GoToCipher(ps);
 CountOfTextureAnims:=round(GetFloat(FileContent,ps));
 SetLength(TextureAnims,CountOfTextureAnims);//����������� �����

 //3. ���������� ������ (������������)
 for i:=0 to CountOfTextureAnims-1 do begin
  TextureAnims[i].TranslationGraphNum:=-1;
  TextureAnims[i].RotationGraphNum:=-1;
  TextureAnims[i].ScalingGraphNum:=-1;
  //���� ������ ���������
  ps:=PosNext('tvertexanim {',FileContent,ps)+13;
  //���� �������� ���������
  repeat
   while (FileContent[ps]<>'}') and (FileContent[ps]<>'t') and
         (FileContent[ps]<>'r') and (FileContent[ps]<>'s') do inc(ps);
   if FileContent[ps]='}' then break;//�����, ����� ������
   //������ ������������
   if copy(FileContent,ps,11)='translation' then begin
    ps:=GoToCipher(ps);
    KeyNum:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    TextureAnims[i].TranslationGraphNum:=LoadController(ps,KeyNum,3);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,8)='rotation' then begin
    ps:=GoToCipher(ps);
    KeyNum:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    TextureAnims[i].RotationGraphNum:=LoadController(ps,KeyNum,4);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,7)='scaling' then begin
    ps:=GoToCipher(ps);
    KeyNum:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    TextureAnims[i].ScalingGraphNum:=LoadController(ps,KeyNum,3);
    inc(ps);
   end;//of if
  until false;                    //����� ��
 end;//of for i
End;

{procedure LoadAttachmentsNames;//�������� ���� ������������
Var i:integer;len,ps:cardinal;s:string;
Begin
 if CountOfAttachments=0 then exit;//��� �����
 SetLength(Attachments,CountOfAttachments);
 len:=length(FileContent);ps:=0;
 i:=0;
 while i<CountOfAttachments do begin
  //1. ���� �����
  repeat
   while (FileContent[ps]<>'a') and (FileContent[ps]<>'A')
         and (ps<len) do inc(ps);
   if lowercase(copy(FileContent,ps,11))='attachment ' then break;
   if ps>=len then begin          //������
    MessageBox(0,'�� ������� ����� Attachments:'#13#10+
               '��������, ���� MDL ���������',scError,mb_applmodal);
    exit;
   end;//of if
   inc(ps);
  until false;

  //2. ����� �������
  while (FileContent[ps]<>'"') and (ps<len) do inc(ps);
  //��������, �� ����������� �� ����� ������������
  s:=lowercase(copy(FileContent,ps-40,40));
  if pos('attachment',s)=0 then begin//�����������
   CountOfAttachments:=i;
   break;
  end;//of if
  InitTBone(Attachments[i].Skel);
  Attachments[i].Skel.Name:='';inc(ps);
  while FileContent[ps]<>'"' do begin
   Attachments[i].Skel.Name:=Attachments[i].Skel.Name+FileContent[ps];
   inc(ps);
  end;//of while
  inc(i);
 end;//of while
End;         }
//��������� ������ ����� ������������
procedure LoadAttachments;
Var i:integer;ps:cardinal;
Begin
 CountOfAttachments:=0;           //���� ��� ����� �����
 //�������� ������������
 ps:=pos('attachment ',FileContent);
 if ps=0 then exit;               //�� ������������� ���

 i:=-1;
 repeat
  inc(i);
  SetLength(Attachments,i+1);

  //�������������
  InitTBone(Attachments[i].Skel);
  Attachments[i].Path:='';
  Attachments[i].AttachmentID:=-1;

  //������ �����
  ps:=ps+FindSym(@FileContent[ps],CODE_QM)+1;
  while FCont[ps]<>'"' do begin
   Attachments[i].Skel.Name:=Attachments[i].Skel.Name+FCont[ps];
   inc(ps);
  end;//of while

  //������ ��������� ������
  while FileContent[ps]<>'{' do inc(ps);//���� ������ ������
  repeat                          //�������� ���� �������
   while (FileContent[ps]<>'o') and (FileContent[ps]<>'}') and
         (FileContent[ps]<>'p') and (FileContent[ps]<>'b') and
         (FileContent[ps]<>'c') and (FileContent[ps]<>'d') and
         (FileContent[ps]<>'a') and (FileContent[ps]<>'t') and
         (FileContent[ps]<>'r') and (FileContent[ps]<>'s') and
         (FileContent[ps]<>'v') do inc(ps);
   if FileContent[ps]='}' then break;
   //����������� �������� �������
   if copy(FileContent,ps,8)='objectid' then begin
    ps:=GoToCipher(ps);
    Attachments[i].Skel.ObjectID:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (ObjectID)

   if copy(FileContent,ps,6)='parent' then begin
    ps:=GoToCipher(ps);
    Attachments[i].Skel.Parent:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (Parent)

   if copy(FileContent,ps,16)='billboardedlockz' then begin
    ps:=ps+16;
    Attachments[i].Skel.IsBillboardedLockZ:=true;
    Continue;
   end;//of if
   if copy(FileContent,ps,16)='billboardedlockx' then begin
    ps:=ps+16;
    Attachments[i].Skel.IsBillboardedLockX:=true;
    Continue;
   end;//of if
   if copy(FileContent,ps,16)='billboardedlocky' then begin
    ps:=ps+16;
    Attachments[i].Skel.IsBillboardedLockY:=true;
    Continue;
   end;//of if
   if copy(FileContent,ps,11)='billboarded' then begin
    ps:=ps+11;
    Attachments[i].Skel.IsBillboarded:=true;
    Continue;
   end;//of if

   //����������
   if copy(FileContent,ps,14)='cameraanchored' then begin
    ps:=ps+14;
    Attachments[i].Skel.IsCameraAnchored:=true;
    Continue;
   end;//of if

   //������ ������������
   if copy(FileContent,ps,11)='dontinherit' then begin
    ps:=ps+11;
    repeat                        //��
     while (FileContent[ps]<>'}') and (FileContent[ps]<>'r') and
           (FileContent[ps]<>'t') and (FileContent[ps]<>'s') do inc(ps);
     if FileContent[ps]='}' then break;
     if copy(FileContent,ps,8)='rotation' then begin
      Attachments[i].Skel.IsDIRotation:=true;
      ps:=ps+8;
      continue;
     end;//of if
     if copy(FileContent,ps,11)='translation' then begin
      Attachments[i].Skel.IsDITranslation:=true;
      ps:=ps+11;
      continue;
     end;//of if
     if copy(FileContent,ps,7)='scaling' then begin
      Attachments[i].Skel.IsDIScaling:=true;
      ps:=ps+7;
      continue;
     end;//of if
     inc(ps);
    until false;                  //����� ��
    inc(ps);
   end;//of if (DontInh)

   //������ �����
   if copy(FileContent,ps,12)='attachmentid' then begin
    ps:=GoToCipher(ps);
    Attachments[i].AttachmentID:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (ObjectID)

   //����
   if copy(FileContent,ps,4)='path' then begin
    while FileContent[ps]<>'"' do inc(ps);
    Attachments[i].Path:='';inc(ps);
    while FCont[ps]<>'"' do begin
     Attachments[i].Path:=Attachments[i].Path+FCont[ps];
     inc(ps);
    end;//of while
    continue;
   end;//of if(Path)

   //�����������
   if copy(FileContent,ps,10)='visibility' then begin
    ps:=GoToCipher(ps);
    Attachments[i].Skel.Visibility:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Attachments[i].Skel.Visibility:=
                   LoadController(ps,Attachments[i].Skel.Visibility,1);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,11)='translation' then begin
    ps:=GoToCipher(ps);
    Attachments[i].Skel.Translation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Attachments[i].Skel.Translation:=LoadController(ps,
                   Attachments[i].Skel.Translation,3);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,8)='rotation' then begin
    ps:=GoToCipher(ps);
    Attachments[i].Skel.Rotation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Attachments[i].Skel.Rotation:=
                        LoadController(ps,Attachments[i].Skel.Rotation,4);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,7)='scaling' then begin
    ps:=GoToCipher(ps);
    Attachments[i].Skel.Scaling:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Attachments[i].Skel.Scaling:=
                        LoadController(ps,Attachments[i].Skel.Scaling,3);
    inc(ps);
   end;//of if
   inc(ps);
  until false;                    //����� ��
  while (FileContent[ps]<>'p') and (FileContent[ps]<>'a') do inc(ps);
 Until FileContent[ps]='p';

 CountOfAttachments:=i+1;
End;

//�������� 1-� ������ ���������� ������
procedure LoadParticleEmitters;
Var ps:cardinal;i:integer;StaticFound,SubSection:boolean;
Begin
 if CountOfParticleEmitters1=0 then exit;//��� ����� ����������
 SetLength(ParticleEmitters1,CountOfParticleEmitters1);
 //���� ������ ���������� ������-1
 ps:=pos('particleemitter ',FileContent);
 for i:=0 to CountOfParticleEmitters1-1 do begin
  ps:=PosNext('particleemitter ',FileContent,ps);
  //�������������
  InitTBone(ParticleEmitters1[i].Skel);
  ParticleEmitters1[i].UsesType:=EmitterUsesTGA;
  ParticleEmitters1[i].EmissionRate:=-1;ParticleEmitters1[i].Gravity:=cNone;
  ParticleEmitters1[i].Longitude:=-1;ParticleEmitters1[i].Latitude:=-1;
//  ParticleEmitters1[i].VisibilityGraphNum:=-1;
  ParticleEmitters1[i].LifeSpan:=-1;
  ParticleEmitters1[i].InitVelocity:=cNone;
  ParticleEmitters1[i].Path:='';
  ParticleEmitters1[i].IsERStatic:=true;
  ParticleEmitters1[i].IsGStatic:=true;
  ParticleEmitters1[i].IsLongStatic:=true;
  ParticleEmitters1[i].IsLatStatic:=true;
  ParticleEmitters1[i].IsLSStatic:=true;
  ParticleEmitters1[i].IsIVStatic:=true;
//  ParticleEmitters1[i].TranslationGraphNum:=-1;
//  ParticleEmitters1[i].RotationGraphNum:=-1;
//  ParticleEmitters1[i].ScalingGraphNum:=-1;
//  ParticleEmitters1[i].Parent:=-1;
  StaticFound:=false;
  //������ �����
  while FileContent[ps]<>'"' do inc(ps); //���� ���
  inc(ps);ParticleEmitters1[i].Skel.Name:='';
  while FCont[ps]<>'"' do begin
   ParticleEmitters1[i].Skel.Name:=
           ParticleEmitters1[i].Skel.Name+FCont[ps];
   inc(ps);
  end;//of while

  //�������� ��� ���� ������
  while FileContent[ps]<>'{' do inc(ps);//������ ������
  repeat                          //��
   while (FileContent[ps]<>'o') and (FileContent[ps]<>'p') and
         (FileContent[ps]<>'e') and (FileContent[ps]<>'s') and
         (FileContent[ps]<>'g') and (FileContent[ps]<>'l') and
         (FileContent[ps]<>'v') and (FileContent[ps]<>'}') and
         (FileContent[ps]<>'t') and (FileContent[ps]<>'r') and
         (FileContent[ps]<>'i') do inc(ps);
   if FileContent[ps]='}' then begin
    if not SubSection then break; //����� ������
    SubSection:=false;
    inc(ps);
    continue;
   end;//of if

   //����������� �������� �������
   if copy(FileContent,ps,8)='objectid' then begin
    ps:=GoToCipher(ps);
    ParticleEmitters1[i].Skel.ObjectID:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (ObjectID)

   if copy(FileContent,ps,6)='parent' then begin
    ps:=GoToCipher(ps);
    ParticleEmitters1[i].Skel.Parent:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (Parent)

   if copy(FileContent,ps,14)='emitterusesmdl' then begin
    ParticleEmitters1[i].UsesType:=EmitterUsesMDL;
    ps:=ps+14;
   end;//of if

   if copy(FileContent,ps,6)='static' then begin
    ps:=ps+6;
    StaticFound:=true;
   end;//of if(Static)

   //������ �����
   if copy(FileContent,ps,12)='emissionrate' then begin
    ps:=GoToCipher(ps);
    ParticleEmitters1[i].EmissionRate:=GetFloat(FileContent,ps);
    if not StaticFound then begin //������ �����������
     while FileContent[ps]<>'{' do inc(ps);
     ParticleEmitters1[i].EmissionRate:=
        LoadController(ps,round(ParticleEmitters1[i].EmissionRate),1);
     inc(ps);
     ParticleEmitters1[i].IsERStatic:=false;
    end;//of if (not Static)
    StaticFound:=false;
   end;//of if (EmisionRate)
   if copy(FileContent,ps,7)='gravity' then begin
    ps:=GoToCipher(ps);
    ParticleEmitters1[i].Gravity:=GetFloat(FileContent,ps);
    if not StaticFound then begin //������ �����������
     while FileContent[ps]<>'{' do inc(ps);
     ParticleEmitters1[i].Gravity:=
        LoadController(ps,round(ParticleEmitters1[i].Gravity),1);
     inc(ps);
     ParticleEmitters1[i].IsGStatic:=false;
    end;//of if (not Static)
    StaticFound:=false;
   end;//of if (Gravity)
   if copy(FileContent,ps,9)='longitude' then begin
    ps:=GoToCipher(ps);
    ParticleEmitters1[i].Longitude:=GetFloat(FileContent,ps);
    if not StaticFound then begin //������ �����������
     while FileContent[ps]<>'{' do inc(ps);
     ParticleEmitters1[i].Longitude:=
        LoadController(ps,round(ParticleEmitters1[i].Longitude),1);
     inc(ps);
     ParticleEmitters1[i].IsLongStatic:=false;
    end;//of if (not Static)
    StaticFound:=false;
   end;//of if (Longitude)
   if copy(FileContent,ps,8)='latitude' then begin
    ps:=GoToCipher(ps);
    ParticleEmitters1[i].Latitude:=GetFloat(FileContent,ps);
    if not StaticFound then begin //������ �����������
     while FileContent[ps]<>'{' do inc(ps);
     ParticleEmitters1[i].Latitude:=
        LoadController(ps,round(ParticleEmitters1[i].Latitude),1);
     inc(ps);
     ParticleEmitters1[i].IsLatStatic:=false;
    end;//of if (not Static)
    StaticFound:=false;
   end;//of if (Latitude)

   //��������� �������� �������
   if copy(FileContent,ps,8)='particle' then begin
    SubSection:=true;             //��������� ���������
    ps:=ps+8;
    continue;
   end;//of if (Particle)

   //���� ���������
   if copy(FileContent,ps,8)='lifespan' then begin
    ps:=GoToCipher(ps);
    ParticleEmitters1[i].LifeSpan:=GetFloat(FileContent,ps);
    if not StaticFound then begin //������ �����������
     while FileContent[ps]<>'{' do inc(ps);
     ParticleEmitters1[i].LifeSpan:=
        LoadController(ps,round(ParticleEmitters1[i].LifeSpan),1);
     inc(ps);
     ParticleEmitters1[i].IsLSStatic:=false;
    end;//of if (not Static)
    StaticFound:=false;
   end;//of if (LifeSpan)
   if copy(FileContent,ps,12)='initvelocity' then begin
    ps:=GoToCipher(ps);
    ParticleEmitters1[i].InitVelocity:=GetFloat(FileContent,ps);
    if not StaticFound then begin //������ �����������
     while FileContent[ps]<>'{' do inc(ps);
     ParticleEmitters1[i].InitVelocity:=
        LoadController(ps,round(ParticleEmitters1[i].InitVelocity),1);
     inc(ps);
     ParticleEmitters1[i].IsIVStatic:=false;
    end;//of if (not Static)
    StaticFound:=false;
   end;//of if (InitVelocity)

   //����
   if copy(FileContent,ps,4)='path' then begin
    while FileContent[ps]<>'"' do inc(ps);
    ParticleEmitters1[i].Path:='';inc(ps);
    while FileContent[ps]<>'"' do begin
     ParticleEmitters1[i].Path:=ParticleEmitters1[i].Path+FileContent[ps];
     inc(ps);
    end;//of while
    continue;
   end;//of if(Path)

   //�����������
   if copy(FileContent,ps,10)='visibility' then begin
    ps:=GoToCipher(ps);
    ParticleEmitters1[i].Skel.Visibility:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    ParticleEmitters1[i].Skel.Visibility:=
        LoadController(ps,ParticleEmitters1[i].Skel.Visibility,1);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,11)='translation' then begin
    ps:=GoToCipher(ps);
    ParticleEmitters1[i].Skel.Translation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    ParticleEmitters1[i].Skel.Translation:=LoadController(ps,
                                   ParticleEmitters1[i].Skel.Translation,3);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,8)='rotation' then begin
    ps:=GoToCipher(ps);
    ParticleEmitters1[i].Skel.Rotation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    ParticleEmitters1[i].Skel.Rotation:=
                        LoadController(ps,ParticleEmitters1[i].Skel.Rotation,4);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,7)='scaling' then begin
    ps:=GoToCipher(ps);
    ParticleEmitters1[i].Skel.Scaling:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    ParticleEmitters1[i].Skel.Scaling:=
                        LoadController(ps,ParticleEmitters1[i].Skel.Scaling,3);
    inc(ps);
   end;//of if

   inc(ps);
  until false;                    //����� ��
 end;//of for i
End;

//���������������: ��������� ������ ������� � ���������� ���
//����� ��� ����� �����������
function GetSingleData(var ps:cardinal;IsStat:boolean):single;
Var rtn:single;
Begin
 ps:=GoToCipher(ps);
 rtn:=GetFloat(FileContent,ps);
 if not IsStat then begin //������ �����������
  while FileContent[ps]<>'{' do inc(ps);
  rtn:=LoadController(ps,round(rtn),1);
  inc(ps);
//     ParticleEmitters1[i].IsLatStatic:=false;
 end;//of if (not Static)
// StaticFound:=false;
 GetSingleData:=rtn;
End;
//���������������: ��������� ������ TVertex
procedure LoadTVertex(var ps:cardinal;var v:TVertex);
Var i:integer;
Begin
 for i:=1 to 3 do begin
  ps:=GoToCipher(ps);
  v[i]:=GetFloat(FileContent,ps);
  ps:=PosNext(',',FileContent,ps);
 end;//of for i
End;
//�������� 2-� ������ ���������� ������
procedure LoadParticleEmitters2;
Var i,ii:integer;ps:cardinal;StaticFound:boolean;
Begin
 if CountOfParticleEmitters=0 then exit;//������ ���������
 SetLength(Pre2,CountOfParticleEmitters);//������
 ps:=pos('particleemitter2 ',FileCOntent);
 for i:=0 to CountOfParticleEmitters-1 do begin
  ps:=posNext('"',FileContent,ps);
  //�������������
  InitTBone(pre2[i].Skel);
//  pre2[i].Name:='';
//  pre2[i].IsDIRotation:=false;pre2[i].IsDiTranslation:=false;
  {pre2[i].IsDIScaling:=false;}pre2[i].IsSortPrimsFarZ:=false;
  pre2[i].IsUnshaded:=false;pre2[i].IsLineEmitter:=false;
  pre2[i].IsUnfogged:=false;pre2[i].IsModelSpace:=false;
  pre2[i].IsXYQuad:=false;pre2[i].Speed:=cNone;
  pre2[i].Variation:=-1;pre2[i].Latitude:=cNone;
  pre2[i].Gravity:=cNone;pre2[i].IsSquirt:=false;
  pre2[i].LifeSpan:=cNone;pre2[i].EmissionRate:=cNone;
  pre2[i].Width:=0;pre2[i].Length:=0;
  pre2[i].BlendMode:=FullAlpha;
  pre2[i].Rows:=1;pre2[i].Columns:=1;
  pre2[i].ParticleType:=ptHead;
  pre2[i].TailLength:=cNone;pre2[i].Time:=cNone;
  pre2[i].TextureID:=0;
  pre2[i].ReplaceableId:=0;pre2[i].PriorityPlane:=-1;
//  pre2[i].TranslationGraphNum:=-1;pre2[i].RotationGraphNum:=-1;
//  pre2[i].ScalingGraphNum:=-1;pre2[i].VisibilityGraphNum:=-1;
  pre2[i].IsSStatic:=true;pre2[i].IsVStatic:=true;
  pre2[i].IsLStatic:=true;pre2[i].IsGStatic:=true;
  pre2[i].IsEStatic:=true;pre2[i].IsWStatic:=true;
  pre2[i].IsHStatic:=true;
//  pre2[i].Parent:=-1;
  StaticFound:=false;
  //������ �����
  inc(ps);
  while FCont[ps]<>'"' do begin
   pre2[i].Skel.Name:=pre2[i].Skel.Name+FCont[ps];
   inc(ps);
  end;//of while
  repeat                          //�������� ���� ������
   while (FileContent[ps]<>'}') and (FileContent[ps]<>'o') and
         (FileContent[ps]<>'p') and (FileContent[ps]<>'d') and
         (FileContent[ps]<>'s') and (FileContent[ps]<>'u') and
         (FileContent[ps]<>'l') and (FileContent[ps]<>'m') and
         (FileContent[ps]<>'x') and (FileContent[ps]<>'v') and
         (FileContent[ps]<>'g') and (FileContent[ps]<>'e') and
         (FileContent[ps]<>'w') and (FileContent[ps]<>'b') and
         (FileContent[ps]<>'a') and (FileContent[ps]<>'r') and
         (FileContent[ps]<>'c') and (FileContent[ps]<>'h') and
         (FileContent[ps]<>'t') do inc(ps);
   if FileContent[ps]='}' then break; //�����
   //����������� �������� �������
   if copy(FileContent,ps,8)='objectid' then begin
    ps:=GoToCipher(ps);
    Pre2[i].Skel.ObjectID:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (ObjectID)

   if copy(FileContent,ps,6)='parent' then begin
    ps:=GoToCipher(ps);
    Pre2[i].Skel.Parent:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (Parent)

   //������ ������������
   if copy(FileContent,ps,11)='dontinherit' then begin
    ps:=ps+11;
    repeat                        //��
     while (FileContent[ps]<>'}') and (FileContent[ps]<>'r') and
           (FileContent[ps]<>'t') and (FileContent[ps]<>'s') do inc(ps);
     if copy(FileContent,ps,8)='rotation' then begin
      Pre2[i].Skel.IsDIRotation:=true;
      ps:=ps+8;
      continue;
     end;//of if
     if copy(FileContent,ps,11)='translation' then begin
      Pre2[i].Skel.IsDITranslation:=true;
      ps:=ps+11;
      continue;
     end;//of if
     if copy(FileContent,ps,7)='scaling' then begin
      Pre2[i].Skel.IsDIScaling:=true;
      ps:=ps+7;
      continue;
     end;//of if
     inc(ps);
    until false;                  //����� ��
    inc(ps);
   end;//of if (DontInh)

   //��� ��� ������
   if copy(FileContent,ps,13)='sortprimsfarz' then begin
    ps:=ps+13;
    pre2[i].IsSortPrimsFarZ:=true;
    continue;
   end;//of if (SortPrimsFarZ)

   if copy(FileContent,ps,8)='unshaded' then begin
    ps:=ps+8;
    pre2[i].IsUnshaded:=true;
    continue;
   end;//of if(Unshaded)

   if copy(FileContent,ps,11)='lineemitter' then begin
    ps:=ps+11;
    pre2[i].IsLineEmitter:=true;
    continue;
   end;//of if

   if copy(FileContent,ps,8)='unfogged' then begin
    ps:=ps+8;
    pre2[i].IsUnfogged:=true;
    continue;
   end;//of if

   if copy(FileContent,ps,10)='modelspace' then begin
    ps:=ps+10;
    pre2[i].IsModelSpace:=true;
    continue;
   end;//of if

   if copy(FileContent,ps,6)='xyquad' then begin
    ps:=ps+6;
    pre2[i].IsXYQuad:=true;
    continue;                
   end;//of if

   if copy(FileContent,ps,6)='static' then begin
    ps:=ps+6;
    StaticFound:=true;
    continue;
   end;//of if

   if copy(FileContent,ps,5)='speed' then begin
    pre2[i].Speed:=GetSingleData(ps,StaticFound);
    pre2[i].IsSStatic:=StaticFound;
    StaticFound:=false;
    continue;
   end;//of if

   if copy(FileContent,ps,9)='variation' then begin
    pre2[i].Variation:=GetSingleData(ps,StaticFound);
    pre2[i].IsVStatic:=StaticFound;
    StaticFound:=false;
    continue;
   end;//of if

   if copy(FileContent,ps,8)='latitude' then begin
    pre2[i].Latitude:=GetSingleData(ps,StaticFound);
    pre2[i].IsLStatic:=StaticFound;
    StaticFound:=false;
    continue;
   end;//of if

   if copy(FileContent,ps,7)='gravity' then begin
    pre2[i].Gravity:=GetSingleData(ps,StaticFound);
    pre2[i].IsGStatic:=StaticFound;
    StaticFound:=false;
    continue;
   end;//of if

   if copy(FileContent,ps,6)='squirt' then begin
    pre2[i].IsSquirt:=true;
    ps:=ps+6;
    continue;
   end;//of if

   if copy(FileContent,ps,9)='lifespan ' then begin
    ps:=GoToCipher(ps);
    pre2[i].LifeSpan:=GetFloat(FileContent,ps);
    continue;
   end;//of if

   if copy(FileContent,ps,12)='emissionrate' then begin
    pre2[i].EmissionRate:=GetSingleData(ps,StaticFound);
    pre2[i].IsEStatic:=StaticFound;
    StaticFound:=false;
    continue;
   end;//of if

   if copy(FileContent,ps,5)='width' then begin
    pre2[i].Width:=GetSingleData(ps,StaticFound);
    pre2[i].IsWStatic:=StaticFound;
    StaticFound:=false;
    continue;
   end;//of if

   if copy(FileContent,ps,6)='length' then begin
    pre2[i].Length:=GetSingleData(ps,StaticFound);
    pre2[i].IsHStatic:=StaticFound;
    StaticFound:=false;
    continue;
   end;//of if

   //��� ��������
   if copy(FileContent,ps,5)='blend' then begin
    pre2[i].BlendMode:=FullAlpha;
    ps:=ps+5;
    continue;
   end;//of if
   if copy(FileContent,ps,8)='additive' then begin
    pre2[i].BlendMode:=Additive;
    ps:=ps+8;
    continue;
   end;//of if
   if copy(FileContent,ps,8)='modulate' then begin
    pre2[i].BlendMode:=Modulate;
    ps:=ps+8;
    continue;
   end;//of if
   if copy(FileContent,ps,8)='alphakey' then begin
    pre2[i].BlendMode:=AlphaKey;
    ps:=ps+8;
    continue;
   end;//of if

   //������, �������...
   if copy(FileContent,ps,4)='rows' then begin
    ps:=GoToCipher(ps);
    pre2[i].Rows:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if
   if copy(FileContent,ps,7)='columns' then begin
    ps:=GoToCipher(ps);
    pre2[i].Columns:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if

   //������ ����������� �������
   if copy(FileContent,ps,4)='head' then begin
    ps:=ps+4;
    pre2[i].ParticleType:=ptHead;
    continue;
   end;//of if
   if copy(FileContent,ps,5)='tail ' then begin
    ps:=ps+4;
    pre2[i].ParticleType:=ptTail;
    continue;
   end;//of if
   if copy(FileContent,ps,4)='both' then begin
    ps:=ps+4;
    pre2[i].ParticleType:=ptBoth;
    continue;
   end;//of if

   //���������� ����������� ����
   if copy(FileContent,ps,10)='taillength' then begin
    ps:=GoToCipher(ps);
    pre2[i].TailLength:=GetFloat(FileContent,ps);
    continue;
   end;//of if
   if copy(FileContent,ps,4)='time' then begin
    ps:=GoToCipher(ps);
    pre2[i].Time:=GetFloat(FileContent,ps);
    continue;
   end;//of if

   //������ ����
   if copy(FileContent,ps,12)='segmentcolor' then begin
    for ii:=1 to 3 do LoadTVertex(ps,pre2[i].SegmentColor[ii]);
    while FileContent[ps]<>'}' do inc(ps);//���� ����� ���������
    inc(ps);
    continue;
   end;//of if

   //������ TVertex-�����
   if copy(FileContent,ps,5)='alpha' then begin
    for ii:=1 to 3 do begin
     ps:=GoToCipher(ps);
     pre2[i].Alpha[ii]:=round(GetFloat(FileCOntent,ps));
     ps:=PosNext(',',FileContent,ps);
    end;//of for i
    continue;
   end;//of if
   if copy(FileContent,ps,15)='particlescaling' then begin
    LoadTVertex(ps,pre2[i].ParticleScaling);
    continue;
   end;//of if
   if copy(FileContent,ps,14)='lifespanuvanim' then begin
    for ii:=1 to 3 do begin
     ps:=GoToCipher(ps);
     pre2[i].LifeSpanUVAnim[ii]:=round(GetFloat(FileContent,ps));
     ps:=PosNext(',',FileContent,ps);
    end;//of for i
    continue;
   end;//of if
   if copy(FileContent,ps,11)='decayuvanim' then begin
    for ii:=1 to 3 do begin
     ps:=GoToCipher(ps);
     pre2[i].DecayUVAnim[ii]:=round(GetFloat(FileContent,ps));
     ps:=PosNext(',',FileContent,ps);
    end;//of for i
    continue;
   end;//of if
   if copy(FileContent,ps,10)='tailuvanim' then begin
    for ii:=1 to 3 do begin
     ps:=GoToCipher(ps);
     pre2[i].TailUVAnim[ii]:=round(GetFloat(FileContent,ps));
     ps:=PosNext(',',FileContent,ps);
    end;//of for i
    continue;
   end;//of if
   if copy(FileContent,ps,15)='taildecayuvanim' then begin
    for ii:=1 to 3 do begin
     ps:=GoToCipher(ps);
     pre2[i].TailDecayUVAnim[ii]:=round(GetFloat(FileContent,ps));
     ps:=PosNext(',',FileContent,ps);
    end;//of for i
    continue;
   end;//of if

   //����� �������� ����
   if copy(FileContent,ps,9)='textureid' then begin
    ps:=GoToCipher(ps);
    pre2[i].TextureID:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if
   if copy(FileContent,ps,13)='replaceableid' then begin
    ps:=GoToCipher(ps);
    pre2[i].ReplaceableId:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if
   if copy(FileContent,ps,13)='priorityplane' then begin
    ps:=GoToCipher(ps);
    pre2[i].PriorityPlane:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if

   //�� �, �������, ����� ������������
   if copy(FileContent,ps,10)='visibility' then begin
    ps:=GoToCipher(ps);
    pre2[i].Skel.Visibility:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Pre2[i].Skel.Visibility:=LoadController(ps,Pre2[i].Skel.Visibility,1);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,11)='translation' then begin
    ps:=GoToCipher(ps);
    pre2[i].Skel.Translation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Pre2[i].Skel.Translation:=LoadController(ps,Pre2[i].Skel.Translation,3);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,8)='rotation' then begin
    ps:=GoToCipher(ps);
    Pre2[i].Skel.Rotation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Pre2[i].Skel.Rotation:=LoadController(ps,Pre2[i].Skel.Rotation,4);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,7)='scaling' then begin
    ps:=GoToCipher(ps);
    Pre2[i].Skel.Scaling:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Pre2[i].Skel.Scaling:=LoadController(ps,Pre2[i].Skel.Scaling,3);
    inc(ps);
   end;//of if

   inc(ps);
  until false;                    //����� ��
 end;//of for i
End;

//��������� ��������� �����
procedure LoadRibbonEmitters;
Var ps:cardinal;i,ii:integer;StaticFound:boolean;
Begin
 if CountOfRibbonEmitters=0 then exit;
 SetLength(Ribs,CountOfRibbonEmitters);
 ps:=pos('ribbonemitter ',FileContent);
 for i:=0 to CountOfRibbonEmitters-1 do begin
  ps:=PosNext('"',FileContent,ps);
  //�������������
  InitTBone(ribs[i].Skel);
//  ribs[i].Name:='';ribs[i].Parent:=-1;
  ribs[i].HeightAbove:=cNone;ribs[i].HeightBelow:=cNone;
  ribs[i].alpha:=-1;ribs[i].TextureSlot:=-1;
  ribs[i].EmissionRate:=-1;
  ribs[i].LifeSpan:=-1;ribs[i].Gravity:=cNone;
  ribs[i].Rows:=1;ribs[i].Columns:=1;
  ribs[i].MaterialID:=0;
  ribs[i].IsHAStatic:=true;ribs[i].IsHBStatic:=true;
  ribs[i].IsAlphaStatic:=true;
  ribs[i].IsColorStatic:=true;
  ribs[i].IsTSStatic:=true;
//  ribs[i].VisibilityGraphNum:=-1;ribs[i].TranslationGraphNum:=-1;
//  ribs[i].RotationGraphNum:=-1;ribs[i].ScalingGraphNum:=-1;
  StaticFound:=false;
  //������ �����
  inc(ps);
  while FCont[ps]<>'"' do begin
   ribs[i].Skel.Name:=ribs[i].Skel.Name+FCont[ps];
   inc(ps);
  end;//of while
  inc(ps);

  //�������� ���� ������
  repeat                          //��
   while (FileContent[ps]<>'}') and (FileContent[ps]<>'o') and
         (FileContent[ps]<>'p') and (FileContent[ps]<>'s') and
         (FileContent[ps]<>'h') and (FileContent[ps]<>'a') and
         (FileContent[ps]<>'c') and (FileContent[ps]<>'t') and
         (FileContent[ps]<>'v') and (FileContent[ps]<>'e') and
         (FileContent[ps]<>'l') and (FileContent[ps]<>'g') and
         (FileContent[ps]<>'r') and (FileContent[ps]<>'m') do inc(ps);
   if FileContent[ps]='}' then break;

   //����������� �������� �������
   if copy(FileContent,ps,8)='objectid' then begin
    ps:=GoToCipher(ps);
    Ribs[i].Skel.ObjectID:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (ObjectID)

   if copy(FileContent,ps,6)='parent' then begin
    ps:=GoToCipher(ps);
    Ribs[i].Skel.Parent:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (Parent)

   if copy(FileContent,ps,6)='static' then begin
    StaticFound:=true;
    ps:=ps+6;
    continue;
   end;//of if

   //������ ���� �����
   if copy(FileContent,ps,11)='heightabove' then begin
    Ribs[i].HeightAbove:=GetSingleData(ps,StaticFound);
    Ribs[i].IsHAStatic:=StaticFound;
    StaticFound:=false;
    continue;
   end;//of if
   if copy(FileContent,ps,11)='heightbelow' then begin
    Ribs[i].HeightBelow:=GetSingleData(ps,StaticFound);
    Ribs[i].IsHBStatic:=StaticFound;
    StaticFound:=false;
    continue;
   end;//of if
   if copy(FileContent,ps,5)='alpha' then begin
    Ribs[i].Alpha:=GetSingleData(ps,StaticFound);
    Ribs[i].IsAlphaStatic:=StaticFound;
    StaticFound:=false;
    continue;
   end;//of if

   //��������� ����
   if copy(FileContent,ps,5)='color' then begin
    ps:=GoToCipher(ps);           //������� �����
    if StaticFound then begin        //����������� �������
     Ribs[i].IsColorStatic:=true;//IsStatic:=false;
     for ii:=1 to 3 do begin
      ps:=GoToCipher(ps);
      Ribs[i].Color[ii]:=GetFloat(FileContent,ps);
      ps:=PosNext(',',FileContent,ps);
     end;//of for ii
    end else begin                //������������ �������
     Ribs[i].Color[1]:=GetFloat(FileContent,ps);//������ ���-�� ������
     Ribs[i].IsColorStatic:=false;
     while FileContent[ps]<>'{' do inc(ps);
     Ribs[i].Color[1]:=LoadController(ps,round(Ribs[i].Color[1]),3);
     inc(ps);
    end;//of if (static/dynamic)
    StaticFound:=false;
   end;//of if (color)

   //���� ��������
   if copy(FileContent,ps,11)='textureslot' then begin
    Ribs[i].TextureSlot:=round(GetSingleData(ps,StaticFound));
    Ribs[i].IsTSStatic:=StaticFound;
    StaticFound:=false;
    continue;
   end;//of if

   //��������� ���������� ����
   if copy(FileContent,ps,12)='emissionrate' then begin
    ps:=GoToCipher(ps);
    Ribs[i].EmissionRate:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if
   if copy(FileContent,ps,8)='lifespan' then begin
    ps:=GoToCipher(ps);
    Ribs[i].LifeSpan:=GetFloat(FileContent,ps);
    continue;
   end;//of if
   if copy(FileContent,ps,7)='gravity' then begin
    ps:=GoToCipher(ps);
    Ribs[i].Gravity:=GetFloat(FileContent,ps);
    continue;
   end;//of if
   if copy(FileContent,ps,4)='rows' then begin
    ps:=GoToCipher(ps);
    Ribs[i].Rows:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if
   if copy(FileContent,ps,7)='columns' then begin
    ps:=GoToCipher(ps);
    Ribs[i].Columns:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if
   if copy(FileContent,ps,10)='materialid' then begin
    ps:=GoToCipher(ps);
    Ribs[i].MaterialID:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if

   //������ - �����������
   if copy(FileContent,ps,10)='visibility' then begin
    ps:=GoToCipher(ps);
    Ribs[i].Skel.Visibility:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Ribs[i].Skel.Visibility:=LoadController(ps,Ribs[i].Skel.Visibility,1);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,11)='translation' then begin
    ps:=GoToCipher(ps);
    Ribs[i].Skel.Translation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Ribs[i].Skel.Translation:=LoadController(ps,Ribs[i].Skel.Translation,3);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,8)='rotation' then begin
    ps:=GoToCipher(ps);
    Ribs[i].Skel.Rotation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Ribs[i].Skel.Rotation:=LoadController(ps,Ribs[i].Skel.Rotation,4);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,7)='scaling' then begin
    ps:=GoToCipher(ps);
    Ribs[i].Skel.Scaling:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Ribs[i].Skel.Scaling:=LoadController(ps,Ribs[i].Skel.Scaling,3);
    inc(ps);
   end;//of if

   inc(ps);
  until false;                    //����� ��
 end;//of for i
End;

//�������� ������� (������������)
procedure LoadEvents;
Var ps:cardinal;i,ii:integer;
Begin
 if CountOfEvents=0 then exit;
 SetLength(Events,CountOfEvents);
 ps:=pos('eventobject ',FileContent);
 for i:=0 to CountOfEvents-1 do begin
  //�������������
  InitTBone(Events[i].Skel);
  Events[i].CountOfTracks:=0;
  //������ �����
  while FileContent[ps]<>'"' do inc(ps);
  inc(ps);
  while FCont[ps]<>'"' do begin
   Events[i].Skel.Name:=Events[i].Skel.Name+FCont[ps];
   inc(ps);
  end;//of while

  //�������� ���� ������
  repeat
   while (FileContent[ps]<>'}') and (FileContent[ps]<>'o') and
         (FileContent[ps]<>'p') and (FileContent[ps]<>'e') and
         (FileContent[ps]<>'t') and (FileContent[ps]<>'r') and
         (FileContent[ps]<>'s') do inc(ps);
   if FileContent[ps]='}' then break;//����� ������
   //������ ID
   if copy(FileContent,ps,8)='objectid' then begin
    ps:=GoToCipher(ps);
    Events[i].Skel.ObjectID:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (ObjectID)

   if copy(FileContent,ps,6)='parent' then begin
    ps:=GoToCipher(ps);
    Events[i].Skel.Parent:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (Parent)

   //������ ���������� ������ �������
   if copy(FileContent,ps,10)='eventtrack' then begin
    ps:=GoToCipher(ps);
    Events[i].CountOfTracks:=round(GetFloat(FileContent,ps));
    SetLength(Events[i].Tracks,Events[i].CountOfTracks);
    while FileContent[ps]<>'{' do inc(ps);//������ ������
    //������ ��� ������� ������
    for ii:=0 to Events[i].CountOfTracks-1 do begin
     ps:=GoToCipher(ps);
     Events[i].Tracks[ii]:=round(GetFloat(FileContent,ps));
     ps:=PosNext(',',FileContent,ps);
    end;//of for i
    //������� �� ������� ������
    while FileContent[ps]<>'}' do inc(ps);
    inc(ps);
    continue;
   end;//of if(EventTrack)

   //������ �����������
   if copy(FileContent,ps,11)='translation' then begin
    ps:=GoToCipher(ps);
    Events[i].Skel.Translation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Events[i].Skel.Translation:=LoadController(ps,Events[i].Skel.Translation,3);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,8)='rotation' then begin
    ps:=GoToCipher(ps);
    Events[i].Skel.Rotation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Events[i].Skel.Rotation:=LoadController(ps,Events[i].Skel.Rotation,4);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,7)='scaling' then begin
    ps:=GoToCipher(ps);
    Events[i].Skel.Scaling:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Events[i].Skel.Scaling:=LoadController(ps,Events[i].Skel.Scaling,3);
    inc(ps);
   end;//of if

   inc(ps);
  until false;                    //����� ��
 end;//of for i
End;

procedure LoadCameras;            //�������� �����
Var ps:cardinal;i:integer;
Begin
 CountOfCameras:=0;               //���� �� ���
 ps:=pos('camera ',FileContent);
 if ps=0 then exit;               //��� �����
 repeat
  inc(CountOfCameras);            //���-�� �����
  SetLength(Cameras,CountOfCameras);
  i:=CountOfCameras-1;            //������� �����
  Cameras[i].TranslationGraphNum:=-1;
  Cameras[i].RotationGraphNum:=-1;
  Cameras[i].TargetTGNum:=-1;
  Cameras[i].Name:='';
  Cameras[i].FieldOfView:=-1;
  Cameras[i].FarClip:=cNone;
  Cameras[i].NearClip:=cNone;
  while FileContent[ps]<>'"' do inc(ps);
  inc(ps);
  while FCont[ps]<>'"' do begin
   Cameras[i].Name:=Cameras[i].Name+FCont[ps];
   inc(ps);
  end;//of while
  repeat                          //�������� ���� ������
   while (FileContent[ps]<>'}') and (FileContent[ps]<>'p') and
         (FileContent[ps]<>'t') and (FileContent[ps]<>'r') and
         (FileContent[ps]<>'f') and (FileContent[ps]<>'n') do inc(ps);
   if FileContent[ps]='}' then break;//����� ������
   if copy(FileContent,ps,8)='position' then begin
    LoadTVertex(ps,Cameras[i].Position);
    continue;
   end;//of if

   //������ �����������
   if copy(FileContent,ps,11)='translation' then begin
    ps:=GoToCipher(ps);
    Cameras[i].TranslationGraphNum:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Cameras[i].TranslationGraphNum:=LoadController(ps,
                                   Cameras[i].TranslationGraphNum,3);
    inc(ps);
    continue;
   end;//of if
   if copy(FileContent,ps,8)='rotation' then begin
    ps:=GoToCipher(ps);
    Cameras[i].RotationGraphNum:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Cameras[i].RotationGraphNum:=LoadController(ps,Cameras[i].RotationGraphNum,1);
    inc(ps);
    continue;
   end;//of if

   //���������� ������ �����
   if copy(FileContent,ps,11)='fieldofview' then begin
    ps:=GoToCipher(ps);
    Cameras[i].FieldOfView:=GetFloat(FileContent,ps);
    continue;
   end;//of if
   if copy(FileContent,ps,7)='farclip' then begin
    ps:=GoToCipher(ps);
    Cameras[i].FarClip:=GetFloat(FileContent,ps);
    continue;
   end;//of if
   if copy(FileContent,ps,8)='nearclip' then begin
    ps:=GoToCipher(ps);
    Cameras[i].NearClip:=GetFloat(FileContent,ps);
    continue;
   end;//of if

   //������� ������
   if copy(FileContent,ps,6)='target' then begin
    while FileContent[ps]<>'p' do inc(ps);//������ �������
    LoadTVertex(ps,Cameras[i].TargetPosition);
    while (FileContent[ps]<>'}') and (FileContent[ps]<>'t') do inc(ps);
    if FileContent[ps]='t' then begin//������ �����������
     ps:=GoToCipher(ps);
     Cameras[i].TargetTGNum:=round(GetFloat(FileContent,ps));
     while FileContent[ps]<>'{' do inc(ps);
     Cameras[i].TargetTGNum:=LoadController(ps,Cameras[i].TargetTGNum,3);
     inc(ps);
     while FileContent[ps]<>'}' do inc(ps);
     inc(ps);
    end;//of if(Translation)
   end;//of if
   inc(ps);
  until false;                    //����� ��
  //������ - ���� ��������� ������ "������"
  ps:=PosNext('camera ',FileContent,ps);
 until ps>=length(FileContent);
End;

procedure LoadCollisionShapes;
Var ps:cardinal;i,ii,k:integer;
Begin
 CountOfCollisionShapes:=0;       //���� �� ���
 ps:=pos('collisionshape ',FileContent);
 if ps=0 then exit;               //��� ��������
 repeat
  inc(CountOfCollisionShapes);            //���-�� �����
  SetLength(Collisions,CountOfCollisionShapes);
  i:=CountOfCollisionShapes-1;            //������� �����
  //�������������
  InitTBone(Collisions[i].Skel);
  Collisions[i].objType:=cSphere;
  Collisions[i].CountOfVertices:=0;
  Collisions[i].BoundsRadius:=-1;
  //������ �����
  while FileContent[ps]<>'"' do inc(ps);
  inc(ps);
  while FCont[ps]<>'"' do begin
   Collisions[i].Skel.Name:=Collisions[i].Skel.Name+FCont[ps];
   inc(ps);
  end;//of while
  repeat                          //�������� ���� ������
   while (FileContent[ps]<>'}') and (FileContent[ps]<>'o') and
         (FileContent[ps]<>'p') and (FileContent[ps]<>'b') and
         (FileContent[ps]<>'s') and (FileContent[ps]<>'v') and
         (FileContent[ps]<>'t') and (FileContent[ps]<>'r') do inc(ps);
   if FileContent[ps]='}' then break;//����� ������
   //������ ����������� �����
   if copy(FileContent,ps,8)='objectid' then begin
    ps:=GoToCipher(ps);
    Collisions[i].Skel.ObjectID:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (ObjectID)

   if copy(FileContent,ps,6)='parent' then begin
    ps:=GoToCipher(ps);
    Collisions[i].Skel.Parent:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (Parent)

   //������ ��� �������
   if copy(FileContent,ps,3)='box' then begin
    ps:=ps+3;
    Collisions[i].objType:=cBox;
    continue;
   end;//of if
   if copy(FileContent,ps,6)='sphere' then begin
    ps:=ps+6;
    Collisions[i].objType:=cSphere;
    continue;
   end;//of if

   //������ ������
   if copy(FileContent,ps,8)='vertices' then begin
    ps:=GoToCipher(ps);
    Collisions[i].CountOfVertices:=round(GetFloat(FileContent,ps));
    SetLength(Collisions[i].Vertices,Collisions[i].CountOfVertices);
    ps:=PosNext('{',FileContent,ps);
    //������ ���� ������ ������
    for ii:=0 to Collisions[i].CountOfVertices-1 do for k:=1 to 3 do begin
     ps:=GoToCipher(ps);
     Collisions[i].Vertices[ii,k]:=GetFloat(FileContent,ps);
     ps:=PosNext(',',FileContent,ps);
    end;//of for ii
    while FileContent[ps]<>'}' do inc(ps);
    inc(ps);
    continue;
   end;//of if(Vertices)

   //������
   if copy(FileContent,ps,12)='boundsradius' then begin
    ps:=GoToCipher(ps);
    Collisions[i].BoundsRadius:=GetFloat(FileContent,ps);
    continue;
   end;//of if

   //�����������
   if copy(FileContent,ps,11)='translation' then begin
    ps:=GoToCipher(ps);
    Collisions[i].Skel.Translation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Collisions[i].Skel.Translation:=
     LoadController(ps,Collisions[i].Skel.Translation,3);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,8)='rotation' then begin
    ps:=GoToCipher(ps);
    Collisions[i].Skel.Rotation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Collisions[i].Skel.Rotation:=
     LoadController(ps,Collisions[i].Skel.Rotation,4);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,7)='scaling' then begin
    ps:=GoToCipher(ps);
    Collisions[i].Skel.Scaling:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Collisions[i].Skel.Scaling:=LoadController(ps,Collisions[i].Skel.Scaling,3);
    inc(ps);
   end;//of if

   inc(ps);
  until false;                    //����� ��
  //������ - ���� ��������� ������ "������"
  ps:=PosNext('collisionshape ',FileContent,ps);
 until ps>=length(FileContent);
End;
//----------------------------------------------------
//������ �������� (���� ����), ��������� � �������.
//fname - ��� ����� ������.
//���� �������� ����, IsWoW:=true
procedure ReadHierarchy(fname:string);
Var fh:file of integer;tmp:PChar;i:integer;
Begin
 fname[length(fname)]:='h';       //MDH
 //���������, ��������� �� ����
 if SearchPath(nil,PChar(fname),nil,0,nil,tmp)=0 then exit;
 //����������. ������.
 AssignFile(fh,fname);
 reset(fh);
// read(fh,i);
 for i:=0 to CountOfGeosets-1 do begin
  if EOF(fh) then begin
   IsWoW:=false;
   CloseFile(fh);
   exit;
  end;//of if
  read(fh,Geosets[i].HierID);
 end;//of for i
 CloseFile(fh);
 IsWoW:=true;
End;
//----------------------------------------------------
//���� � ����������� ������ ��������� ������
//� �������� �� ���������
procedure FixModel;
Var i,j,len:integer;
Begin
 //1. ���� ����� ��������� AnimTransfer:
 //���� ��� ���������� �������������������, �� �� ������ ����
 //� ������ �� ���
 len:=High(Controllers);
 if CountOfGlobalSequences=0 then for i:=0 to len
 do if Controllers[i].GlobalSeqId>=0 then Controllers[i].GlobalSeqId:=-1;

 //2. ���� � VertexGroup (����� ������� ������ �������
 //�� ������� ������� Matrices).
 for j:=0 to CountOfGeosets-1 do for i:=0 to Geosets[j].CountOfVertices-1
 do if Geosets[j].VertexGroup[i]>=Geosets[j].CountOfMatrices
 then Geosets[j].VertexGroup[i]:=0;

 //3. ���� � ���������� (��. ������) Alpha � ����. �����������
 len:=High(Controllers);
 for j:=0 to len do for i:=0 to High(Controllers[j].Items) do
 with Controllers[j].Items[i] do begin
  if abs(Controllers[j].Items[i].Data[1])<1e-23 then Data[1]:=0;
  if abs(Controllers[j].Items[i].Data[2])<1e-23 then Data[2]:=0;
  if abs(Controllers[j].Items[i].Data[3])<1e-23 then Data[3]:=0;
  if abs(Controllers[j].Items[i].Data[4])<1e-23 then Data[4]:=0;
  if abs(Controllers[j].Items[i].Data[5])<1e-23 then Data[5]:=0;
 end;//of with/for i/j

 //4. ���� � �������������� GeosetId:
 for j:=0 to CountOfGeosetAnims-1 do if GeosetAnims[j].GeosetID<0
 then GeosetAnims[j].GeosetId:=0;

 //5. ���� � �������������� ���������� ���������
 for i:=0 to CountOfParticleEmitters-1 do if pre2[i].TextureID<0
 then pre2[i].TextureID:=0;

 //���������� ����� ���� ��������
 //! �� ������ �� ���������� ������������ GlobalSeq.
{ for i:=0 to High(Controllers) do for j:=0 to High(Controllers[i].Items)
 do Controllers[i].Items[j].Frame:=Controllers[i].Items[j].Frame*2;
 for i:=0 to CountOfSequences-1 do begin
  Sequences[i].IntervalStart:=Sequences[i].IntervalStart*2;
  Sequences[i].IntervalEnd:=Sequences[i].IntervalEnd*2;
 end;//of for i}
End;

//������ ���������� �� ������ MdlVis
function MDLReadMdlVisInformation:boolean;
Var ps,ps2,len,i,ii,lng:cardinal;
Begin
 IsCanSaveMDVI:=true;             //������ ����� ��������� ������

 //���� ������ MDLVisInformation
 //���� ��� - �������
 ps:=pos('mdlvisinformation',FileContent);
 if ps=0 then begin
  COMidNormals:=0;
  COConstNormals:=0;
  MidNormals:=nil;
  ConstNormals:=nil;
  IsWoW:=false;
  Result:=false;
  exit;
 end;

 //1. �������� �������� WoW-��������
 ps2:=PosNext('wowhierarchy',FileContent,ps);
 len:=length(FileContent);
 if ps2<len then begin
  IsWoW:=true;
  ps:=ps2;
  for i:=0 to CountOfGeosets-1 do begin
   ps:=GoToCipher(ps);
   Geosets[i].HierID:=round(GetFloat(FileContent,ps));
   ps:=PosNext(',',FileContent,ps);
  end;//of for i
 end;//of if

 //2. �������� �������� ������ �����������
 ps2:=PosNext('smoothgroups ',FileContent,ps);
 if ps2<len then begin
  ps:=GoToCipher(ps2);
  COMidNormals:=round(GetFloat(FileContent,ps));
  SetLength(MidNormals,COMidNormals);
  for i:=0 to COMidNormals-1 do begin
   ps:=PosNext('sgroup ',FileContent,ps);
   ps:=GoToCipher(ps);
   lng:=round(GetFloat(FileContent,ps));
   SetLength(MidNormals[i],lng);
   ps:=PosNext('{',FileContent,ps);
   for ii:=0 to lng-1 do begin
    ps:=GoToCipher(ps);
    MidNormals[i,ii].GeoID:=round(GetFloat(FileContent,ps));
    ps:=PosNext(',',FileContent,ps);
    ps:=GoToCipher(ps);
    MidNormals[i,ii].VertID:=round(GetFloat(FileContent,ps));
    ps:=PosNext(',',FileContent,ps);
   end;//of for i
  end;//of for i
 end;//of if

 //3. �������� �������� ��������� �������
 ps2:=PosNext('editednormals',FileContent,ps);
 if ps2<len then begin
  ps:=GoToCipher(ps2);
  COConstNormals:=round(GetFloat(FileContent,ps));
  SetLength(ConstNormals,COConstNormals);
  for i:=0 to COConstNormals-1 do begin
   ps:=PosNext('{',FileContent,ps);
   ps:=GoToCipher(ps);
   ConstNormals[i].GeoId:=round(GetFloat(FileContent,ps));
   ps:=PosNext(',',FileContent,ps);
   ps:=GoToCipher(ps);
   ConstNormals[i].VertId:=round(GetFloat(FileContent,ps));
   ps:=PosNext(',',FileContent,ps);
   ps:=GoToCipher(ps);
   ConstNormals[i].n[1]:=GetFloat(FileContent,ps);
   ps:=PosNext(',',FileContent,ps);
   ps:=GoToCipher(ps);
   ConstNormals[i].n[2]:=GetFloat(FileContent,ps);
   ps:=PosNext(',',FileContent,ps);
   ps:=GoToCipher(ps);
   ConstNormals[i].n[3]:=GetFloat(FileContent,ps);
  end;//of for i
 end;//of if
End;

//��������� "���������" ��� �����, ����� ����
function GetOnlyFileName(fname:string):string;
Var i:integer; s:string;
Begin
 s:='';
 for i:=length(fname) downto 0 do begin
  if (fname[i]='\') or (fname[i]='/') then break;
  insert(fname[i],s,1);
 end;//of for i
 Result:=s;
End;

//��������� ���� mdl, �������� ���. ����������
procedure OpenMDL(fname:string);
Var ps{,ps2}:cardinal;i,j:integer;IsFound:boolean;
Begin
 Controllers:=nil;
 IsWoW:=false;
 FileContent:='';   //���� ���������� ���
 FCont:='';         //�� �� �����
 assign(f,fname);
 reset(f,1);
 SetLength(FileContent,FileSize(f));
 BlockRead(f,FileContent[1],FileSize(f));
 //--------------------------------------------------------
 FCont:=FileContent;              //���������� ����� ��� ��������� ��������
 FileContent:=lowercase(FileContent); //� ������ �������
 close(f);

 //0. ������ ��� ������
 ps:=pos('model ',FileContent);   //������� � �����
 ps:=ps+FindSym(@FileContent[ps],CODE_QM);
 ModelName:='';
 inc(ps);
 while FCont[ps]<>'"' do begin
  ModelName:=ModelName+FCont[ps];
  inc(ps);
 end;//of while

 //�������: �������� �������
 {if CountOfTextures<>0 then} LoadTextures;
 //�������: �������� ����������
 LoadMaterials;
 LoadTextureAnims;                //�������� ���������� ��������
 //������� �����:
 //1. ������ ��������� (��� ����):
 CountOfGeosets:=round(ReadField('numgeosets '));
 if CountOfGeosets=0 then begin
  MessageBox(0,'������ �� �������� ������������,'#13#10+
               '��� ������ ��������� �� ������������ ����� ������.'#13#10+
               '(��������, ��� - ������ �����������).',
               scError,mb_iconexclamation or mb_applmodal);
  exit;
 end;//of if
 CountOfGeosetAnims:=round(ReadField('numgeosetanims '));
 CountOfLights:=round(ReadField('numlights '));
 CountOfHelpers:=round(ReadField('numhelpers '));
 CountOfBones:=round(ReadField('numbones '));
// CountOfAttachments:=round(ReadField('numattachments '));
 CountOfParticleEmitters:=round(ReadField('numparticleemitters2 '));
 CountOfParticleEmitters1:=round(ReadField('numparticleemitters '));
 CountOfRibbonEmitters:=round(ReadField('numribbonemitters '));
 ps:=pos('model ',FileContent);
 CountOfEvents:=round(ReadField('numevents '));
 BlendTime:=round(ReadField('blendtime '));
 LoadAnimBounds(ps,AnimBounds);   //������� ������ (���������)
 //�������� ������ �������������������
 LoadSeqData;
 LoadGlobalSequences;
 //2. ���������� ����� �������
 SetLength(Geosets,CountOfGeosets);//���������� ����� �������
 //3. ������ ������ ���� ������������
 CurGeoPos:=pos('geoset ',FileContent);
 i:=1;//CountOfGeosets:=1;
 While i<=CountOfGeosets do begin
  ReadGeoset(i);
  IsFound:=false;
  for j:=0 to 10 do if copy(FileContent,CurGeoPos+j,7)='geoset ' then begin
   IsFound:=true;
   CurGeoPos:=CurGeoPos+j;
   break;
  end;//of if/for j

  if not IsFound then begin
   CountOfGeosets:=i;SetLength(Geosets,CountOfGeosets);//���������� ����� �������
   break;
  end;//of if
  inc(i);
  if i=CountOfGeosets+1 then begin
   inc(CountOfGeosets);
   SetLength(Geosets,CountOfGeosets);
  end;//of if
 end;//of while

// ReadHierarchy(fname);
 //������ �������� ������������
 ReadGeosetAnims;
 //������ ������
 ReadBones;                       //�����
 LoadLights(ps);                  //������ ���������� �����
 ReadHelpers;                     //���������
 LoadAttachments;                 //����� ������������
 //������ ����. �������
 LoadPivotPoints;
 //������ ���� ��������� ��������
 LoadParticleEmitters;            //��������� ������ (������ ������)
 LoadParticleEmitters2;           //��������� ������ (����� ������)
 LoadRibbonEmitters;              //��������� �����
 LoadCameras;                     //������
 LoadEvents;                      //�������� �������
 LoadCollisionShapes;             //�������� �������� ������
 MDLReadMdlVisInformation;        //�������� ���������� MdlVis

 FileContent:=''; //���������� ������
 FCont:='';       //���������� ������
 //��������� ���������� �������
 SetLength(VisGeosets,CountOfGeosets);
 for i:=0 to CountOfGeosets-1 do VisGeosets[i]:=true;
 FixModel;                        //��������� ������
End;
//---------------------------------------------------------
//��������� ��������� ��� ������ ���������
function ReadLong:integer;
Var q:integer;
Begin
 move(pointer(pp)^,q,4);          //��������
 pp:=pp+4;                        //����� ���������
 ReadLong:=q;                     //������� �����
End;

function ReadShort:integer;
Var q:word;
Begin
 move(pointer(pp)^,q,2);          //��������
 pp:=pp+2;                        //����� ���������
 ReadShort:=q;                     //������� �����
End;

function ReadByte:integer;
Var q:byte;qi:integer;
Begin
 move(pointer(pp)^,q,1);          //��������
 inc(pp);                         //����� ���������
 qi:=q;
 ReadByte:=qi;                    //������� �����
End;

function ReadFloat:single;
Var q:single;
Begin
 move(pointer(pp)^,q,4);          //��������
 pp:=pp+4;                        //����� ���������
 ReadFloat:=q;                    //������� �����
End;

function ReadASCII(size:integer):string;
Var s:string;i,p2:integer;
    c:char;
Begin
 s:='';p2:=pp;
 for i:=1 to size do begin
  Move(pointer(pp)^,c,1);
  inc(pp);
  if c=#0 then break else s:=s+c;
 end;//of for
 ReadASCII:=s;
 pp:=p2+size;                     //��������� ���������
End;
//---------------------------------------------------------
//������ ��������� MDX
procedure MDXReadHeader;
Var i:integer;
Begin
 pp:=pp+8;                        //������� ���� MODL � �������
 ModelName:=ReadASCII($150);      //�������� ��� ������
 pp:=pp+4;                        //���������� 0
 //������ �������
 AnimBounds.BoundsRadius:=ReadFloat;
 if floattostr(AnimBounds.BoundsRadius)='INF' then AnimBounds.BoundsRadius:=-1;
 for i:=1 to 3 do AnimBounds.MinimumExtent[i]:=ReadFloat;
 for i:=1 to 3 do AnimBounds.MaximumExtent[i]:=ReadFloat;
 //����� ��������
 BlendTime:=ReadLong;
End;
//---------------------------------------------------------
procedure MDXReadSequences;
Var i,ii,tmp,num:integer;
Const SizeOfSeq=$50+13*4;         //������ ����� ������������������
Begin
// pp:=pp+4;                        //������� ���� SEQS
 num:=ReadLong;                   //������� ������ ������
 CountOfSequences:=num div SizeOfSeq; //���������� ���-�� �������������������
 SetLength(Sequences,CountOfSequences);
 //�������� ���� ������
 for i:=0 to CountOfSequences-1 do begin
  Sequences[i].Name:=ReadASCII($50);
  Sequences[i].IntervalStart:=ReadLong;
  Sequences[i].IntervalEnd:=ReadLong;
  Sequences[i].MoveSpeed:=round(ReadFloat); //!
  if Sequences[i].MoveSpeed=0 then Sequences[i].MoveSpeed:=-1;
  tmp:=ReadLong;
  if tmp=0 then Sequences[i].IsNonLooping:=false
           else Sequences[i].IsNonLooping:=true;
  Sequences[i].Rarity:=round(ReadFloat);       //!
  if Sequences[i].Rarity=0 then Sequences[i].Rarity:=-1;
  pp:=pp+4;                       //������� 0
  with Sequences[i].Bounds do begin
   BoundsRadius:=ReadFloat;
   if floattostr(BoundsRadius)='INF' then BoundsRadius:=-1;
   for ii:=1 to 3 do MinimumExtent[ii]:=ReadFloat;
   for ii:=1 to 3 do MaximumExtent[ii]:=ReadFloat;   
  end;//of with
 end;//of for i
End;
//---------------------------------------------------------
procedure MDXReadGlobalSeq;
Var i,num:integer;
Begin
 num:=ReadLong;
 CountOfGlobalSequences:=num shr 2;
 SetLength(GlobalSequences,CountOfGlobalSequences);
 for i:=0 to CountOfGlobalSequences-1 do GlobalSequences[i]:=ReadLong;
End;
//---------------------------------------------------------
//�������.: ������ ����������
//��������� ���������� � ��������� �����.
//���� ���������� ��. ���������� - ������ �� ����������
//� ������������ true (static).
//����� ������������ false, � Result ��������� ����� �����������.
function MDXReadController(tag,SizeOfElement:integer;IsStateLong:boolean;
                           var Rsult:integer):boolean;
Var tmp,CntNum,COF,i,ii:integer;
Begin
 //1. ��������, ��� �� ���������� ������
 tmp:=ReadLong;                   //������ ���
 if tmp<>tag then begin           //�� ��� ����������
  pp:=pp-4;                       //��������� ���������
  MDXReadController:=true;        //static
  exit;                           //�����
 end;//of if

 //2. ��� � �������. �������� ������.
 CntNum:=Length(Controllers);
 SetLength(Controllers,CntNum+1); //�������� ������ ��� ����������
 Rsult:=CntNum;                   //���������
 Controllers[CntNum].SizeOfElement:=SizeOfElement;
 with Controllers[CntNum] do begin
  COF:=ReadLong;                  //���-�� ������
  SetLength(items,COF);           //�������� ������ ��� �����
  ContType:=ReadLong+1;           //��� �����������
  GlobalSeqID:=ReadLong;
  //������ ������ �����
  //����� ������ � �������� �������
{  if (tag=tagKGAC) or (tag=tagKLAC) or
     (tag=tagKLBC) or (tag=tagKRCO) then begin
   for i:=0 to COF-1 do begin
    items[i].Frame:=ReadLong;      //������
    for ii:=SizeOfElement downto 1 do if IsStateLong then items[i].Data[ii]:=ReadLong
                                             else items[i].Data[ii]:=ReadFloat;
    if (ContType=Bezier) or (ContType=Hermite) then begin
     for ii:=SizeOfElement downto 1 do items[i].InTan[ii]:=ReadFloat;
     for ii:=SizeOfElement downto 1 do items[i].OutTan[ii]:=ReadFloat;
    end;//of if (ContType)
   end;//of for i
  end else begin}
   for i:=0 to COF-1 do begin
    items[i].Frame:=ReadLong;      //������
    for ii:=1 to SizeOfElement do if IsStateLong then items[i].Data[ii]:=ReadLong
                                             else items[i].Data[ii]:=ReadFloat;
    if (ContType=Bezier) or (ContType=Hermite) then begin
     for ii:=1 to SizeOfElement do items[i].InTan[ii]:=ReadFloat;
     for ii:=1 to SizeOfElement do items[i].OutTan[ii]:=ReadFloat;
    end;//of if (ContType)
   end;//of for i
{  end;//of if(CGAC)}
 end;//of with

 MDXReadController:=false;        //������� ���������
End;
//---------------------------------------------------------
//�������.: ������ ���������� ����
procedure MDXReadLayer(var l:TLayer);
Var tmp:integer;
Begin
 pp:=pp+4;                        //������� �������
 tmp:=ReadLong;                   //������ ���� ��������
 case tmp of                      //��� ������
  0:l.FilterMode:=Opaque;
  1:l.FilterMode:=ColorAlpha;
  2:l.FilterMode:=FullAlpha;
  3:l.FilterMode:=Additive;
  4:l.FilterMode:=AddAlpha;
  5:l.FilterMode:=Modulate;
  else l.FilterMode:=Modulate2X;
 end;//of case

 //������ �����
 tmp:=ReadLong;
 if (tmp and 1)<>0 then l.IsUnshaded:=true
                   else l.IsUnshaded:=false;
 if (tmp and 2)<>0 then l.IsSphereEnvMap:=true
                   else l.IsSphereEnvMap:=false;
 if (tmp and 16)<>0 then l.IsTwoSided:=true
                    else l.IsTwoSided:=false;
 if (tmp and 32)<>0 then l.IsUnfogged:=true
                    else l.IsUnfogged:=false;
 if (tmp and 64)<>0 then l.IsNoDepthTest:=true
                    else l.IsNoDepthTest:=false;
 if (tmp and 128)<>0 then l.IsNoDepthSet:=true
                     else l.IsNoDepthSet:=false;
 //������ ���� ��������
 l.TextureID:=ReadLong;
// l.TextureID:=l.TextureID and ($FFFFFFFF-128-64-32);
 //������ �����
 l.TVertexAnimID:=ReadLong;
 l.CoordID:=ReadLong;
 if l.CoordID=0 then l.CoordID:=-1;
 l.Alpha:=ReadFloat;if l.Alpha=1 then l.Alpha:=-1;

 //������ ����������� � �����������
 l.NumOfGraph:=-1;l.NumOfTexGraph:=-1;
 l.IsAlphaStatic:=MDXReadController(tagKMTA,1,false,l.NumOfGraph);
 l.IsTextureStatic:=MDXReadController(tagKMTF,1,true,l.NumOfTexGraph);
End;
//---------------------------------------------------------
//������ ����������
procedure MDXReadMaterials;
Var tmp,pEnd,i:integer;
Begin
 CountOfMaterials:=0;
 tmp:=ReadLong;                   //������ ������ ������
 pEnd:=pp+tmp;                    //��������� ����. ����
 repeat                           //�������� ���� ������
  inc(CountOfMaterials);
  SetLength(Materials,CountOfMaterials);
  with Materials[CountOfMaterials-1] do begin
   ListNum:=-1;
   pp:=pp+4;                      //������� ������� ���������
   PriorityPlane:=ReadLong;
   if PriorityPlane=0 then PriorityPlane:=-1;
   //������ ����� ���������
   tmp:=ReadLong;
   if (tmp and 1)<>0 then IsConstantColor:=true
                     else IsConstantColor:=false;
   if (tmp and 16)<>0 then IsSortPrimsFarZ:=true
                      else IsSortPrimsFarZ:=false;
   if (tmp and 32)<>0 then IsFullResolution:=true
                      else IsFullResolution:=false;
   //������ ��������� LAYS (����)
   pp:=pp+4;                      //������� ���� LAYS
   CountOfLayers:=ReadLong;       //���-�� �����
   SetLength(Layers,CountOfLayers);//�������� ������ ��� ����
   for i:=0 to CountOfLayers-1 do MDXReadLayer(Layers[i]);
  end;//of with
//  Materials[CountOfMaterials-1]
 until pp>=pEnd;
End;
//---------------------------------------------------------
//������ ������ �������
procedure MDXReadTextures;
Const TEXSize=$100+3*4;
Var tmp,i:integer;
Begin
 tmp:=ReadLong;                   //������ ������ ������
 CountOfTextures:=tmp div TEXSize;//��������� ���-�� �������
 SetLength(Textures,CountOfTextures);
 for i:=0 to CountOfTextures-1 do begin
  FillChar(Textures[i],SizeOf(TTexture),0);
  Textures[i].ReplaceableID:=ReadLong;
  Textures[i].FileName:=ReadASCII($100);
  pp:=pp+4;                       //������� 0
  //������ �����
  tmp:=ReadLong;
  if (tmp and 1)<>0 then Textures[i].IsWrapWidth:=true
                    else Textures[i].IsWrapWidth:=false;
  if (tmp and 2)<>0 then Textures[i].IsWrapHeight:=true
                    else Textures[i].IsWrapHeight:=false;
 end;
End;
//---------------------------------------------------------
//������ ���������� ��������
procedure MDXReadTexAnims;
Var pEnd:integer;
Begin
 pEnd:=pp+ReadLong;               //������� ����� ������
 CountOfTextureAnims:=0;
 repeat                           //�������� ���� ������
  inc(CountOfTextureAnims);
  SetLength(TextureAnims,CountOfTextureAnims);
  pp:=pp+4;                       //������� �������
  with TextureAnims[CountOfTextureAnims-1] do begin
   TranslationGraphNum:=-1;
   RotationGraphNum:=-1;
   ScalingGraphNum:=-1;
   MDXReadController(tagKTAT,3,false,TranslationGraphNum);
   MDXReadController(tagKTAR,4,false,RotationGraphNum);
   MDXReadController(tagKTAS,3,false,ScalingGraphNum);
  end;//of with
 until pp>=pEnd;
End;
//---------------------------------------------------------
//������ ����������� ������
procedure MDXReadGeosets;
Var pEnd,j,i,ii,tmp:integer;
Begin
 pEnd:=pp+ReadLong;               //��������� ����� ������
 CountOfGeosets:=0;
 repeat                           //�������� ���� ������
  inc(CountOfGeosets);
  SetLength(Geosets,CountOfGeosets);
  pp:=pp+4;                       //������� �������
  //1. ������ ������ ������
  pp:=pp+4;                       //������� ���� VRTX
  with Geosets[CountOfGeosets-1] do begin
   CountOfVertices:=ReadLong;     //������ ���-�� �����
   SetLength(Vertices,CountOfVertices);
   for i:=0 to CountOfVertices-1 do for ii:=1 to 3 do Vertices[i,ii]:=ReadFloat;

   //2. ������ ������ ��������
   pp:=pp+4;                      //������� ���� NRMS
   CountOfNormals:=ReadLong;     //������ ���-�� �����
   SetLength(Normals,CountOfNormals);
   for i:=0 to CountOfNormals-1 do for ii:=1 to 3 do Normals[i,ii]:=ReadFloat;

   //3. ���������� ��� ��������� (�� ���� � ��� ��)
   pp:=pp+4;                      //������� ���� PTYP
   tmp:=ReadLong;                 //���-�� �����
   pp:=pp+4*tmp;                  //������� �������
   pp:=pp+4;                      //������� ���� PCNT
   tmp:=ReadLong;                 //���-�� �������
   pp:=pp+4*tmp;                  //�������

   //4. ������ ��� ���� �������������:
   pp:=pp+4;                      //������� ���� PVTX
   SetLength(Faces,1);            //����� 1 ������
   CountOfFaces:=1;
   tmp:=ReadLong;                 //���-�� �����
   SetLength(Faces[0],tmp);       //�������� ������
   for i:=0 to tmp-1 do Faces[0,i]:=ReadShort;

   //5. ������ ������ ������� ����� (VertexGroup)
   pp:=pp+4;                      //������� ���� GNDX
   tmp:=ReadLong;                 //������ ���-�� �����
   SetLength(VertexGroup,tmp);
   for i:=0 to tmp-1 do VertexGroup[i]:=ReadByte;
   SetLength(VertexGroup,CountOfVertices);

   //6. ������ ������ ���� �����
   pp:=pp+4;                      //������� ���� MTGC
   CountOfMatrices:=ReadLong;
   SetLength(Groups,CountOfMatrices);
   //������ ��������� ����� ������ �������:
   for i:=0 to CountOfMatrices-1 do begin
    tmp:=ReadLong;                //������ �����
    SetLength(Groups[i],tmp);     //���������� ��
   end;//of for i

   //7. ������ ����� ������
   pp:=pp+8;                      //������� ���� MATS � �����
   for i:=0 to CountOfMatrices-1 do for ii:=0 to length(Groups[i])-1 do begin
    Groups[i,ii]:=ReadLong;
   end;//of for i

   //8. ������ ���� �����
   MaterialID:=ReadLong;
   SelectionGroup:=ReadLong;
   tmp:=ReadLong;
   if tmp=4 then Unselectable:=true else Unselectable:=false;

   //9. ������ ������
   BoundsRadius:=ReadFloat;
   if floattostr(BoundsRadius)='INF' then BoundsRadius:=-1;
   for i:=1 to 3 do MinimumExtent[i]:=ReadFloat;
   for i:=1 to 3 do MaximumExtent[i]:=ReadFloat;
   //10. ������ ������ �������� (Anim)
   CountOfAnims:=ReadLong;
   SetLength(Anims,CountOfAnims);
   for i:=0 to CountOfAnims-1 do with Anims[i] do begin
    BoundsRadius:=ReadFloat;      
//    MessageBox(0,PChar(floattostr(BoundsRadius)),'',0);
    if floattostr(BoundsRadius)='0' then BoundsRadius:=-1;
    for ii:=1 to 3 do MinimumExtent[ii]:=ReadFloat;
    for ii:=1 to 3 do MaximumExtent[ii]:=ReadFloat;
   end;//of for i
            
   //11. ������ ������ TVertices (���������� �������)
   //11a. ������ UVBA - ���-�� ������������ ������
   pp:=pp+4;                      //������� ����
   CountOfCoords:=ReadLong;       //������� ���-��
   SetLength(Crds,CountOfCoords);
   //11b. ������ ������ ����� ������
   for j:=0 to CountOfCoords-1 do with Crds[j] do begin
    pp:=pp+2*4;                    //������� ���� ����� � ����
    CountOfTVertices:=CountOfVertices;
    SetLength(TVertices,CountOfTVertices);
    for i:=0 to CountOfTVertices-1 do begin
     TVertices[i,1]:=ReadFloat;
     TVertices[i,2]:=ReadFloat;
    end;//of for i
   end;//of for j

  end;//of with
 until pp>=pEnd;
End;
//---------------------------------------------------------
//������ �������� �������� ������������
procedure MDXReadGeosetAnims;
Var pEnd,tmp:integer;
Begin
 pEnd:=pp+ReadLong;               //���������� ����� ������
 CountOfGeosetAnims:=0;
 repeat                           //�������� ���� ������
  inc(CountOfGeosetAnims);
  SetLength(GeosetAnims,CountOfGeosetAnims);
  with GeosetAnims[CountOfGeosetAnims-1] do begin
   pp:=pp+4;                      //������� �������
   Alpha:=ReadFloat;              //������������
   //������ �����
   tmp:=ReadLong;
   if (tmp and 1)<>0 then IsDropShadow:=true
                     else IsDropShadow:=false;
   if (tmp and 2)<>0 then begin   //������������ ����
    Color[3]:=ReadFloat;          //�������� �������!
    Color[2]:=ReadFloat;
    Color[1]:=ReadFloat;
   end else begin                 //���� �����������!
    Color[1]:=-1;Color[2]:=-1;Color[3]:=-1;
    pp:=pp+3*4;                   //������� �����
    IsColorStatic:=true;
   end;//of if

   GeosetID:=ReadLong;
   IsAlphaStatic:=MDXReadController(TagKGAO,1,false,AlphaGraphNum);
   IsColorStatic:=MDXReadController(TagKGAC,3,false,ColorGraphNum);
  end;//of with
 until pp>=pEnd;
End;
//---------------------------------------------------------
//���������������: ������ �������
//���������� ��� ��������� ��������
{procedure MDXReadOBJ(Var name:string;Var ObjectID,Parent:integer;
                     Var IsDITranslation,IsDIRotation,IsDIScaling,
                     IsBillboarded,IsBillboardedLockX,
                     IsBillboardedLockY,IsBillboardedLockZ,
                     IsCameraAnchored:boolean;var t,r,s,v:integer);}
procedure MDXReadOBJ(var b:TBone);                     
Var tmp:integer;
Begin with b do begin
 InitTBone(b);                    //�������������
 pp:=pp+4;                        //������� �������
 name:=ReadASCII($50);            //���
 ObjectID:=ReadLong;              //ID �������
 Parent:=ReadLong;                //ID ��������
 //������ ��� (�� �� �����) � �����:
 tmp:=ReadLong;
 if (tmp and 1)<>0 then IsDITranslation:=true
                   else IsDITranslation:=false;
 if (tmp and 2)<>0 then IsDIScaling:=true
                   else ISDIScaling:=false;
 if (tmp and 4)<>0 then IsDIRotation:=true
                   else IsDIRotation:=false;
 if (tmp and 8)<>0 then IsBillboarded:=true
                   else IsBillboarded:=false;
 if (tmp and 16)<>0 then IsBillboardedLockX:=true
                    else IsBillboardedLockX:=false;
 if (tmp and 32)<>0 then IsBillboardedLockY:=true
                    else IsBillboardedLockY:=false;
 if (tmp and 64)<>0 then IsBillboardedLockZ:=true
                    else IsBillboardedLockZ:=false;
 if (tmp and 128)<>0 then IsCameraAnchored:=true
                     else IsCameraAnchored:=false;
 //������ �����������
// Rotation:=-1;Translation:=-1;Scaling:=-1;Visibility:=-1;
 MDXReadController(tagKGTR,3,false,Translation);
 MDXReadController(tagKGRT,4,false,Rotation);
 MDXReadController(tagKGSC,3,false,Scaling);
 MDXReadController(tagKATV,1,false,Visibility);
end;End;
//---------------------------------------------------------
//������ ������
procedure MDXReadBones;
Var pEnd:integer;
Begin
 pEnd:=pp+ReadLong;               //��������� ����� ������
 CountOfBones:=0;
 repeat                           //���� ������
  inc(CountOfBones);
  SetLength(Bones,CountOfBones);
  with Bones[CountOfBones-1] do begin
   //������ OBJ
   MDXReadObj(Bones[CountOfBones-1]);
   //���������� ����
   GeosetID:=ReadLong;if GeosetID=-1 then GeosetID:=-3;
   GeosetAnimID:=ReadLong;if GeosetAnimID=-1 then GeosetAnimID:=-2;
  end;//of with
 until pp>=pEnd;
 //� ������ ������������� ������� ��������� ObjectID=0
 if (CountOfBones=1) and (Bones[0].ObjectID<0) then Bones[0].ObjectID:=0;
End;
//---------------------------------------------------------
//������ ���������� �����
procedure MDXReadLights;
Var pEnd,tmp,i:integer;
Begin
 pEnd:=pp+ReadLong;
 CountOfLights:=0;
 repeat
  inc(CountOfLights);
  SetLength(Lights,CountOfLights);
  with Lights[CountOfLights-1] do begin
   pp:=pp+4;                      //������� �������
   MDXReadObj(Skel);
   //������ ��� ��������� �����
   LightType:=ReadLong+1;         //������ ��� ���������
   AttenuationStart:=ReadFloat;
   AttenuationEnd:=ReadFloat;

   //������ ����
   for i:=3 downto 1 do Color[i]:=ReadFloat;
   Intensity:=ReadFloat;
   for i:=3 downto 1 do AmbColor[i]:=ReadFloat;
   AmbIntensity:=ReadFloat;

   //��������� static-�����
{   IsASStatic:=true;
   IsAEStatic:=true;}
   //������ ����� ������������
   IsASStatic:=MDXReadController(tagKLAS,1,false,tmp);
   if not IsASStatic then AttenuationStart:=tmp;
   IsAEStatic:=MDXReadController(tagKLAE,1,false,tmp);
   if not IsAEStatic then AttenuationEnd:=tmp;

   IsIStatic:=MDXReadController(tagKLAI,1,false,tmp);
   if not IsIStatic then Intensity:=tmp;
   MDXReadController(tagKLAV,1,false,Skel.Visibility);
   IsCStatic:=MDXReadController(tagKLAC,3,false,tmp);
   if not IsCStatic then Color[1]:=tmp;
   IsACStatic:=MDXReadController(tagKLBC,3,false,tmp);
   if not IsACStatic then AmbColor[1]:=tmp;
   IsAIStatic:=MDXReadController(tagKLBI,1,false,tmp);
   if not IsAIStatic then AmbIntensity:=tmp;
  end;//of with
 until pp>=pEnd;
End;
//---------------------------------------------------------
//������ ����������
procedure MDXReadHelpers;
Var pEnd:integer;
Begin
 pEnd:=pp+ReadLong;               //����� ������
 CountOfHelpers:=0;
 repeat
  inc(CountOfHelpers);
  SetLength(Helpers,CountOfHelpers);
  with Helpers[CountOfHelpers-1] do begin
   //������ OBJ
   MDXReadObj(Helpers[CountOfHelpers-1]);
   GeosetID:=-1;
   GeosetAnimID:=-1;
  end;//of with
 until pp>=pEnd;
End;
//---------------------------------------------------------
//������ ����� ������������
procedure MDXReadAttachments;
Var pEnd{,tmp}:integer;
Begin
 pEnd:=pp+ReadLong;
 CountOfAttachments:=0;
 repeat
  inc(CountOfAttachments);
  SetLength(Attachments,CountOfAttachments);
  with Attachments[CountOfAttachments-1] do begin
   pp:=pp+4;                      //������� �������
   MDXReadObj(Skel);
   Path:=ReadASCII($100);
   pp:=pp+4;                      //������� 0
   AttachmentID:=ReadLong;

   //������ ���������� ���������
   MdxReadController(TagKATV,1,false,Skel.Visibility);
  end;//of with
 until pp>=pEnd;   
End;
//---------------------------------------------------------
//�������� �������������� �������
procedure MDXReadPivotPoints;
Var i,ii:integer;
Const PivSize=4*3;
Begin
 CountOfPivotPoints:=ReadLong div PivSize; //���-�� �����
 SetLength(PivotPoints,CountOfPivotPoints);
 for i:=0 to CountOfPivotPoints-1 do
     for ii:=1 to 3 do PivotPoints[i,ii]:=ReadFloat;
End;
//---------------------------------------------------------
//������ ��������� ������ ������ ������
//! �� �������������
procedure MDXReadParticleEmitters1;
Var pEnd,tmp:integer;
Begin
 pEnd:=pp+ReadLong;               //����� ������
 if pEnd=pp then exit;
 CountOfParticleEmitters1:=0;
 repeat
  inc(CountOfParticleEmitters1);
  SetLength(ParticleEmitters1,CountOfParticleEmitters1);
  with ParticleEmitters1[CountOfParticleEmitters1-1] do begin
   pp:=pp+2*4;                    //������� ��������
   Skel.Name:=ReadASCII($50);     //������ ���
   Skel.ObjectID:=ReadLong;
   Skel.Parent:=ReadLong;
   //������ �����
   tmp:=ReadLong;
   if (tmp and $8000)<>0 then UsesType:=EmitterUsesMDL;
   if (tmp and $10000)<>0 then UsesType:=EmitterUsesTGA;

   //������ �����������
{   Skel.Translation:=-1;
   Skel.Rotation:=-1;
   Skel.Scaling:=-1;}
   InitTBone(Skel);
   MDXReadController(TagKGTR,3,false,Skel.Translation);
   MDXReadController(TagKGRT,4,false,Skel.Rotation);
   MDXReadController(TagKGSC,3,false,Skel.Scaling);

   //����������� ���������
   IsERStatic:=true;
   IsGStatic:=true;
   IsLongStatic:=true;
   IsLatStatic:=true;
   IsLSStatic:=true;
   IsIVStatic:=true;
   //���������� ������
   EmissionRate:=ReadFloat;
   Gravity:=ReadFloat;
   Longitude:=ReadFloat;
   Latitude:=ReadFloat;
   Path:=ReadASCII($100);
   pp:=pp+4;                      //������� 0
   LifeSpan:=ReadFloat;
   InitVelocity:=ReadFloat;
   //������ �����������
   IsERStatic:=MDXReadController(tagKPEE,1,false,tmp);
   if not IsERStatic then EmissionRate:=tmp;
   IsGStatic:=MDXReadController(tagKPEG,1,false,tmp);
   if not IsGStatic then Gravity:=tmp;
   IsLongStatic:=MDXReadController(tagKPLN,1,false,tmp);
   if not IsLongStatic then Longitude:=tmp;
   IsLatStatic:=MDXReadController(tagKPLT,1,false,tmp);
   if not IsLatStatic then Latitude:=tmp;
   IsLSStatic:=MDXReadController(tagKPEL,1,false,tmp);
   if not IsLSStatic then LifeSpan:=tmp;
   IsIVStatic:=MDXReadController(tagKPES,1,false,tmp);
   if not IsIVStatic then InitVelocity:=tmp;

   MDXReadController(TagKPEV,1,false,Skel.Visibility);
  end;//of with
 until pp>=pEnd;    
End;
//---------------------------------------------------------
//������ "�����������" ���������� ������
procedure MDXReadParticleEmitters2;
Var pEnd,tmp,OldPP,i,ii:integer;bTmp:boolean;
Begin
 pEnd:=pp+ReadLong;
 CountOfParticleEmitters:=0;
 repeat                           //���� ������
  inc(CountOfParticleEmitters);
  SetLength(pre2,CountOfParticleEmitters);
  with pre2[CountOfParticleEmitters-1] do begin
   pp:=pp+2*4;                    //������� ��������
   //�������������:
   InitTBone(Skel);
{   TranslationGraphNum:=-1;
   RotationGraphNum:=-1;
   ScalingGraphNum:=-1;
   VisibilityGraphNum:=-1;}
   Skel.Name:=ReadASCII($50);
   Skel.ObjectID:=ReadLong;
   Skel.Parent:=ReadLong;
   //������ �����
   tmp:=ReadLong;
   if (tmp and 1)<>0 then Skel.IsDITranslation:=true
                     else Skel.IsDITranslation:=false;
   if (tmp and $2)<>0 then Skel.IsDIScaling:=true
                      else Skel.ISDIScaling:=false;
   if (tmp and $4)<>0 then Skel.IsDIRotation:=true
                      else Skel.IsDIRotation:=false;
   if (tmp and $8000)<>0 then IsUnshaded:=true
                         else IsUnshaded:=false;
   if (tmp and $100000)<>0 then IsXYQuad:=true
                           else IsXYQuad:=false;
   if (tmp and $80000)<>0 then IsModelSpace:=true
                          else IsModelSpace:=false;
   if (tmp and $40000)<>0 then IsUnfogged:=true
                          else IsUnfogged:=false;
   if (tmp and $20000)<>0 then IsLineEmitter:=true
                          else IsLineEmitter:=false;
   if (tmp and $10000)<>0 then IsSortPrimsFarZ:=true
                          else IsSortPrimsFarZ:=false;

   //����� ������������
   MDXReadController(TagKGTR,3,false,Skel.Translation);
   MDXReadController(TagKGRT,4,false,Skel.Rotation);
   MDXReadController(TagKGSC,3,false,Skel.Scaling);

   //���������� ������ �����
   Speed:=ReadFloat;
   Variation:=ReadFloat;
   Latitude:=ReadFloat;
   Gravity:=ReadFloat;
   Lifespan:=ReadFloat;
   EmissionRate:=ReadFloat;
   Length:=ReadFloat;
   Width:=ReadFloat;
   //������ �������� � ������
   tmp:=ReadLong;
   BlendMode:=FullAlpha;
   if tmp=0 then BlendMode:=FullAlpha;
   if tmp=1 then BlendMode:=Additive;
   if tmp=2 then BlendMode:=Modulate;
   if tmp=4 then BlendMode:=AlphaKey;
   Rows:=ReadLong;
   Columns:=ReadLong;

   ParticleType:=ReadLong;
   TailLength:=ReadFloat;
   Time:=ReadFloat;
   //������ ����� ��������
   for i:=1 to 3 do for ii:=3 downto 1 do SegmentColor[i,ii]:=ReadFloat;
   //������ ������������
   for i:=1 to 3 do Alpha[i]:=ReadByte;
   //���������� ���������
   for i:=1 to 3 do ParticleScaling[i]:=ReadFloat;
   //����� ���������� (�� �������)
   for i:=1 to 3 do LifeSpanUVAnim[i]:=ReadLong;
   for i:=1 to 3 do DecayUVAnim[i]:=ReadLong;
   for i:=1 to 3 do TailUVAnim[i]:=ReadLong;
   for i:=1 to 3 do TailDecayUVAnim[i]:=ReadLong;

   //��� ����
   TextureID:=ReadLong;
   tmp:=ReadLong;if tmp=1 then IsSquirt:=true
                          else IsSquirt:=false;
   PriorityPlane:=ReadLong;
   if PriorityPlane=0 then PriorityPlane:=-1;
   ReplaceableID:=ReadLong;

   //������ - �������������� ����� ������������
   IsVStatic:=true; IsLStatic:=true; IsGStatic:=true;
   IsEStatic:=true; IsSStatic:=true; IsHStatic:=true;
   IsWStatic:=true;
   repeat
    oldPP:=pp;
    if not MDXReadController(tagKP2R,1,false,tmp) then begin
     IsVStatic:=false;
     Variation:=tmp;
    end;//of if
    if not MDXReadController(tagKP2L,1,false,tmp) then begin
     IsLStatic:=false;
     Latitude:=tmp;     
    end;//of if
    if not MDXReadController(tagKP2G,1,false,tmp) then begin
     IsGStatic:=false;
     Gravity:=tmp;
    end;//of if

    MDXReadController(tagKP2V,1,false,Skel.Visibility);

    if not MDXReadController(tagKP2E,1,false,tmp) then begin
     IsEStatic:=false;
     EmissionRate:=tmp;
    end;//of if
    if not MDXReadController(tagKP2S,1,false,tmp) then begin
     IsSStatic:=false;
     Speed:=tmp;
    end;//of if
    if not MDXReadController(tagKP2N,1,false,tmp) then begin
     IsHStatic:=false;
     Length:=tmp;
    end;//of if
    if not MDXReadController(tagKP2W,1,false,tmp) then begin
     IsWStatic:=false;
     Width:=tmp;
    end;//of if
   until pp=oldPP;
  end;//of with
 until pp>=pEnd;
End;
//---------------------------------------------------------
//������ ���������� �����
procedure MDXReadRibbonEmitters;
Var pEnd,tmp,i:integer;
Begin
 pEnd:=pp+ReadLong;
 CountOfRibbonEmitters:=0;
 repeat
  inc(CountOfRibbonEmitters);
  SetLength(ribs,CountOfRibbonEmitters);
  with ribs[CountOfRibbonEmitters-1] do begin
   pp:=pp+2*4;                    //������� �������
   InitTBone(Skel);
{   TranslationGraphNum:=-1;
   RotationGraphNum:=-1;
   ScalingGraphNum:=-1;
   VisibilityGraphNum:=-1;}
   Skel.Name:=ReadASCII($50);
   Skel.ObjectID:=ReadLong;
   Skel.Parent:=ReadLong;
   pp:=pp+4;                      //������� ����
   //����� ������������
   MDXReadController(TagKGTR,3,false,Skel.Translation);
   MDXReadController(TagKGRT,4,false,Skel.Rotation);
   MDXReadController(TagKGSC,3,false,Skel.Scaling);
   //����
   HeightAbove:=ReadFloat;
   HeightBelow:=ReadFloat;
   Alpha:=ReadFloat;
   for i:=3 downto 1 do Color[i]:=ReadFloat;
   LifeSpan:=ReadFloat;
   TextureSlot:=ReadLong;
   EmissionRate:=ReadLong;
   Rows:=ReadLong;
   Columns:=ReadLong;
   MaterialID:=ReadLong;
   Gravity:=ReadFloat;

   //������ - ������������� �����������
   IsTSStatic:=true; //��� ���� ���������...
   IsHAStatic:=MDXReadController(tagKRHA,1,false,tmp);
   if not IsHAStatic then HeightAbove:=tmp;
   IsHBStatic:=MDXReadController(tagKRHB,1,false,tmp);
   if not IsHBStatic then HeightBelow:=tmp;
   IsAlphaStatic:=MDXReadController(tagKRAL,1,false,tmp);
   if not IsAlphaStatic then Alpha:=tmp;
   IsColorStatic:=MDXReadController(tagKRCO,3,false,tmp);
   if not IsColorStatic then Color[1]:=tmp;
   //���������� ���������
   MDXReadController(tagKRVS,1,false,Skel.Visibility);
  end;//of with
 until pp>=pEnd;    
End;
//---------------------------------------------------------
//��������� ������ �����
procedure MDXReadCameras;
Var pEnd,i:integer;
Begin
 pEnd:=pp+ReadLong;
 CountOfCameras:=0;
 repeat
  inc(CountOfCameras);
  SetLength(Cameras,CountOfCameras);
  with Cameras[CountOfCameras-1] do begin
   pp:=pp+4;                      //������� �������
   Name:=ReadASCII($50);
   for i:=1 to 3 do Position[i]:=ReadFloat;
   FieldOfView:=ReadFloat;
   FarClip:=ReadFloat;
   NearClip:=ReadFloat;
   //��������� ����
   for i:=1 to 3 do TargetPosition[i]:=ReadFloat;
   TargetTGNum:=-1;
   RotationGraphNum:=-1;
   TranslationGraphNum:=-1;
   MDXReadController(tagKCTR,3,false,TargetTGNum);
   //������ ������������
   MDXReadController(tagKCRL,1,false,RotationGraphNum);
   MDXReadController(tagKTTR,3,false,TranslationGraphNum);
  end;//of with
 until pp>=pEnd;  
End;
//---------------------------------------------------------
//������ �������
procedure MDXReadEvents;
Var pEnd{,tmp},i:integer;//bN:boolean;
Begin
 pEnd:=pp+ReadLong;
 CountOfEvents:=0;
 repeat
  inc(CountOfEvents);
  SetLength(Events,CountOfEvents);
  with Events[CountOfEvents-1] do begin
//   bN:=true;//tmp:=0;
   MDXReadOBJ(Skel);
   pp:=pp+4;                      //������� KEVT
   CountOfTracks:=ReadLong;
   SetLength(Tracks,CountOfTracks);
   pp:=pp+4;                      //������� (-1)
   for i:=0 to CountOfTracks-1 do Tracks[i]:=ReadLong;
  end;//of with
 until pp>=pEnd; 
End;
//---------------------------------------------------------
//������ �������� ������
procedure MDXReadCollisionObjects;
Var pEnd,tmp,i,ii:integer;//bN:boolean;
Begin
 pEnd:=pp+ReadLong;
 CountOfCollisionShapes:=0;
 repeat
  inc(CountOfCollisionShapes);
  SetLength(Collisions,CountOfCollisionShapes);
  with Collisions[CountOfCollisionShapes-1] do begin
{   TranslationGraphNum:=-1;
   RotationGraphNum:=-1;
   ScalingGraphNum:=-1;
   bN:=false;
   tmp:=0;}
   MDXReadOBJ(Skel);
   //������ ����� ������� (���)           
   tmp:=ReadLong;
   objType:=cSphere;
   if tmp=0 then objType:=cBox;
   if tmp=2 then objType:=cSphere;
   //��������� ������ �������
   if objType=cBox then begin
    CountOfVertices:=2;
    SetLength(Vertices,CountOfVertices);
    for i:=0 to 1 do for ii:=1 to 3 do Vertices[i,ii]:=ReadFloat;
   end else begin
    CountOfVertices:=1;
    SetLength(Vertices,CountOfVertices);
    for ii:=1 to 3 do Vertices[0,ii]:=ReadFloat;
    BoundsRadius:=ReadFloat;
    if floattostr(BoundsRadius)='INF' then BoundsRadius:=-1;
   end;//of if
  end;//of with
 until pp>=pEnd;
End;
//---------------------------------------------------------
//������������ �������� ������ � ����������� MdlVis.
//���� ������� �� �������, �����. false
//� ��������� ��������������� ��� ��� ������ ������
function MDXReadMdlVisInformation:boolean;
Var tmp,i,ii,len:integer;
Begin
 IsCanSaveMDVI:=true;             //������ ����� ��������� ������
 pp:=pp-4;                        //��������� � ����
 //������ ���. ���� ��� ���. ������ - �������
 if ReadLong<>tagMDVI then begin
  COMidNormals:=0;
  COConstNormals:=0;
  MidNormals:=nil;
  ConstNormals:=nil;
  IsWoW:=false;
  Result:=false;
  exit;
 end;

 //���������� ���� �����
 pp:=pp+4;
 //������ ������ WoW-�������� (���� ����)
 tmp:=ReadLong;
 if tmp=tagiWoW then begin
  IsWoW:=true;
  for i:=0 to CountOfGeosets-1 do Geosets[i].HierID:=ReadLong;
  tmp:=ReadLong;
 end;//of if

 //������ ������ �����������
 if tmp=tagiSmooth then begin
  COMidNormals:=ReadLong;
  SetLength(MidNormals,COMidNormals);
  for i:=0 to COMidNormals-1 do begin
   len:=ReadLong;
   SetLength(MidNormals[i],len);
   for ii:=0 to len-1 do begin
    MidNormals[i,ii].GeoID:=ReadLong;
    MidNormals[i,ii].VertID:=ReadLong;
   end;//of for ii
  end;//of for i

  COConstNormals:=ReadLong;
  SetLength(ConstNormals,COConstNormals);
  for i:=0 to COConstNormals-1 do begin
   ConstNormals[i].GeoId:=ReadLong;
   ConstNormals[i].VertID:=ReadLong;
   ConstNormals[i].n[1]:=ReadFloat;
   ConstNormals[i].n[2]:=ReadFloat;
   ConstNormals[i].n[3]:=ReadFloat;
  end;//of for i

{  tmp:=ReadLong;! �� ������ �������� ����� ���. ������ �����}
 end;//of if
 Result:=true;
End;
//---------------------------------------------------------
//��������� ���� MDX, ��������� ����� ���
procedure OpenMDX(fname:string);
Var tag,i:integer;
Begin
 IsWoW:=false;
 //1. ������� ��� ����
 assignFile(f,fname);
 reset(f,1);                      //���������� ������
 //2. �������� ������ ��� ����
 GetMem(p,FileSize(f)+8);         //�������� � ��������
 //3. �������� ���� ���� � ������
 BlockRead(f,p^,FileSize(f));
 tag:=0;
 move(tag,pointer(integer(p)+FileSize(f))^,4);//������ ����
 //4. ������� ����
 CloseFile(f);
 Controllers:=nil;
 FileContent:='';   //���� ���������� ���
//------------------���������� ������----------
 pp:=integer(p);                  //�������� �����
 pp:=pp+$10;                      //������� 10 �������� :)
 MDXReadHeader;                   //������ ���������
 tag:=ReadLong;                   //������ ���
 if tag=TagSEQS then begin
  MDXReadSequences;               //������ ��������
  tag:=ReadLong;
 end else CountOfSequences:=0;
 if tag=TagGLBS then begin
  MDXReadGlobalSeq;               //������ ���������� ����.
  tag:=ReadLong;
 end else CountOfGlobalSequences:=0;
 if tag=TagMTLS then begin
  MDXReadMaterials;               //������ ����������
  tag:=ReadLong;
 end else CountOfMaterials:=0;
 if tag=TagTEXS then begin
  MDXReadTextures;               //������ �������
  tag:=ReadLong;
 end else CountOfTextures:=0;
 if tag=TagTXAN then begin
  MDXReadTexAnims;               //������ ���������� ��������
  tag:=ReadLong;
 end else CountOfTextureAnims:=0;
 if tag=TagGEOS then begin
  MDXReadGeosets;                //������ ������������
  tag:=ReadLong;
 end else begin                  //��� ������������, ������
  CountOfGeosets:=0;
  MessageBox(0,'������ �� �������� ������������.'+
               '��������, ��� ������ �����������.'+
               'MdlVis �� ����� �������� � ������ ��������',
               scError,MB_APPLMODAL or MB_ICONSTOP);
  exit;
 end;//of if
// ReadHierarchy(fname);
 if tag=TagGEOA then begin
  MDXReadGeosetAnims;               //������ �������� ���������
  tag:=ReadLong;
 end else CountOfGeosetAnims:=0;
 if tag=TagBONE then begin
  MDXReadBones;                     //������ ������
  tag:=ReadLong;
 end else CountOfBones:=0;
 if tag=TagLITE then begin
  MDXReadLights;                    //������ ���������� �����
  tag:=ReadLong;
 end else CountOfLights:=0;
 if tag=TagHELP then begin
  MDXReadHelpers;                   //������ ����������
  tag:=ReadLong;
 end else CountOfHelpers:=0;
 if tag=TagATCH then begin
  MDXReadAttachments;               //������ ����� ������������
  tag:=ReadLong;
 end else CountOfAttachments:=0;
 if tag=TagPIVT then begin
  MDXReadPivotPoints;               //������ �������������� �������
  tag:=ReadLong;
 end else CountOfPivotPoints:=0;
 if tag=TagPREM then begin
  MDXReadParticleEmitters1;         //������ ���������� ������ (v.1)
  tag:=ReadLong;
 end else CountOfParticleEmitters1:=0;
 if tag=TagPRE2 then begin
  MDXReadParticleEmitters2;         //������ ���������� ������ (v.2)
  tag:=ReadLong;
 end else CountOfParticleEmitters:=0;
 if tag=TagRIBB then begin
  MDXReadRibbonEmitters;            //������ ���������� �����
  tag:=ReadLong;
 end else CountOfRibbonEmitters:=0;
 if tag=TagCAMS then begin
  MDXReadCameras;                   //������ �����
  tag:=ReadLong;
 end else CountOfCameras:=0;
 if tag=TagEVTS then begin
  MDXReadEvents;                    //������ �������
  tag:=ReadLong;
 end else CountOfEvents:=0;
 if tag=TagCLID then begin
  MDXReadCollisionObjects;          //������ ��������� ��������
  tag:=ReadLong;
 end else CountOfCollisionShapes:=0;
 //����������� �������� �� ������:
 if tag=TagCAMS then MDXReadCameras;
 MDXReadMdlVisInformation;          //�������� ������ MdlVis
//---------------------------------------------
 //���������� ������
 FreeMem(p);
// CountOfGeosetAnims:=0;
 //��������� ���������� �������
 SetLength(VisGeosets,CountOfGeosets);
 for i:=0 to CountOfGeosets-1 do VisGeosets[i]:=true;
 FixModel;                        //��������� ���� ������ (���� ����)
 //������� ���������� ��������
{ for i:=0 to High(Controllers) do
  if Controllers[i].ContType>2 then Controllers[i].ContType:=2;}
End;
//---------------------------------------------------------
//��������������� (������ M2)
//��� ��������� ����������� (Geoset) ���������, �����
//������ ����� ������ ������ ������. ���� ����� �������
//��� ���, ��� ��������.
function GetMakedGroupNum(geo,bn1,bn2,bn3,bn4:integer):integer;
Var i,ii,j,ln:integer;
    a:array [0..3] of integer;
    IsFound:boolean;
Begin with Geosets[geo] do begin
 ln:=0;
// GetMakedGroupNum:=0;
 if bn1>=0 then begin a[ln]:=bn1;inc(ln);end;
 if bn2>=0 then begin a[ln]:=bn2;inc(ln);end;
 if bn3>=0 then begin a[ln]:=bn3;inc(ln);end;
 if bn4>=0 then begin a[ln]:=bn4;inc(ln);end;
{ if ln=0 then begin               //�������� �� ������
  MessageBox(0,'������� ����������� �������:'#13#10+
               '��������, ������ ���������.'#13#10+
               '�������� ��� ������ ������������ MdlVis','��������:',
               mb_iconexclamation);
  exit;
 end;//of if}

 //����� � ������� ������ (Groups)
 IsFound:=false;                  //���� �� �������
 for i:=0 to CountOfMatrices-1 do begin
  if ln<>length(Groups[i]) then continue; //����� ������� �� ���������
  for ii:=0 to ln-1 do begin
   IsFound:=false;                //���� ��� ����� �� �������
   for j:=0 to length(Groups[i])-1 do if Groups[i,ii]=a[j] then begin
    IsFound:=true;                //����� ���� � ������
    break;                        //��������� �����
   end;//of if/for j
   if IsFound=false then break;   //���� �� ������ �� �������
  end;//of for ii
  if IsFound=true then begin      //�������! ������� ������ � �����
   GetMakedGroupNum:=i;
   exit;
  end;//of if
 end;//of for i

 //������ �� �������, ���������� �
 inc(CountOfMatrices);
 SetLength(Groups,CountOfMatrices);
 SetLength(Groups[CountOfMatrices-1],ln);
 for i:=0 to ln-1 do Groups[CountOfMatrices-1,i]:=a[i];
 GetMakedGroupNum:=CountOfMatrices-1;
end;End;
//---------------------------------------------------------
//���������� ������ ������� �� M2-����� (WoW)
procedure M2ReadTextures(ct,it:integer);
Var i,id,flg,flen,fofs,pps:integer;
Begin
 CountOfTextures:=ct;
 SetLength(Textures,CountOfTextures);
 pp:=it;                          //��������� � ������ ��������
 //�������� ���� �������
 for i:=0 to CountOfTextures-1 do with Textures[i] do begin
  FillChar(Textures[i],SizeOf(TTexture),0);
  id:=ReadLong;                   //������ ID ��������
  flg:=ReadShort;                 //����� ��������
  if (flg and 1)<>0 then IsWrapWidth:=true else IsWrapWidth:=false;
  if (flg and 2)<>0 then IsWrapHeight:=true else IsWrapHeight:=false;
  pp:=pp+2;                       //������� 0
  flen:=ReadLong;                 //����� ����� �����
  fofs:=ReadLong+integer(p);      //��� �����

  //��������� ���� ����������
  ReplaceableID:=0;
  pImg:=nil;

  //����� ��� ����� ��������
  FileName:='';
  if id=0 then begin              //����� ������ ��� �����
   pps:=pp;
   pp:=fofs;
   FileName:=ReadASCII(flen);
   pp:=pps;
   continue;
  end;//of if

  //�������� ����������...
  FileName:=ModelName;            //������ - ��� ������
  case id of
   1:FileName:=FileName+'Body.blp';
   2:FileName:=FileName+'Cape.blp';
   6:FileName:=FileName+'Hair.blp';
   8:FileName:=FileName+'Tauren.blp';
   11:FileName:=FileName+'_Skin01.blp';
   12:FileName:=FileName+'_Skin02.blp';
   13:FileName:=FileName+'_Skin03.blp';
   else FileName:='Unknown.ERR';//�� ������ ������
  end;//of case
 end;//of for i
End;
//---------------------------------------------------------
//����� �������� ��� ������ ������������ ������������:
//(�� ������ ������ pp ��������� �� ������ ������,
//����� ������ - �� ����. ����)
//� ������ ���������� �������� � �����������, �����. -1
//1. ������ float-�����������
function M2ReadControllerf(count:integer):integer;
Var iofs,i,ii,svpp,coFrames,ipFrames,ipValues,
    CountOfControllers:integer;
Begin
 iofs:=integer(p);
 CountOfControllers:=length(Controllers)+1;
// inc(CountOfControllers);
 SetLength(Controllers,CountOfControllers);
 with Controllers[CountOfControllers-1] do begin
  ContType:=ReadShort+1;          //������ ��� ������������
  GlobalSeqID:=ReadShort;         //������ ����. ����.
  if GlobalSeqID>$8888 then GlobalSeqID:=-1;
  pp:=pp+2*4;                     //������� InterpolationRanges
  SizeOfElement:=count;
  coFrames:=ReadLong;             //���-�� ������
  ipFrames:=ReadLong+iofs;        //�������� ������� ������
  pp:=pp+4;                       //������� ���-�� ������
  ipValues:=ReadLong+iofs;        //�������� ��������
  SetLength(items,coFrames);      //�������� ����� ��� �����
  if coFrames<=1 then begin       //��� ��������
   M2ReadControllerf:=-1;
   if coFrames<1 then begin
    dec(CountOfControllers);
    SetLength(Controllers,CountOfControllers);
    exit;
   end;//of if
  end;//of if
  svpp:=pp;                       //��������� ��������
  pp:=ipFrames;                   //������ ������
  //������ ����� ������� (�������� ����� ������)
  for i:=0 to coFrames-1 do Items[i].Frame:=ReadLong;
  pp:=ipValues;                   //��������� � ������ ��������
  //������ float-��������
  for i:=0 to coFrames-1 do begin 
   for ii:=1 to count do Items[i].Data[ii]:=ReadFloat;
   //������ �������� (���� �����)
   if (ContType=Hermite) or (ContType=Bezier) then begin
    for ii:=1 to count do Items[i].InTan[ii]:=ReadFloat;
    for ii:=1 to count do Items[i].OutTan[ii]:=ReadFloat;
   end;//of if ii
  end;//of for i
  pp:=svpp;                       //������������ �������
 end;//of with

 if coFrames>1 then M2ReadControllerf:=CountOfControllers-1
              else Result:=-2;
End;

//1. ������ short(word)-����������� � ���������������� [0..1]
function M2ReadControllerw(count:integer):integer;
Var iofs,i,ii,svpp,coFrames,ipFrames,ipValues,
    CountOfControllers:integer;
Begin
 iofs:=integer(p);
// inc(CountOfControllers);
 CountOfControllers:=length(Controllers)+1;
 SetLength(Controllers,CountOfControllers);
 with Controllers[CountOfControllers-1] do begin
  ContType:=ReadShort+1;          //������ ��� ������������
  GlobalSeqID:=ReadShort;         //������ ����. ����.
  if GlobalSeqID>$8888 then GlobalSeqID:=-1;
  pp:=pp+2*4;                     //������� InterpolationRanges
  SizeOfElement:=count;
  coFrames:=ReadLong;             //���-�� ������
  ipFrames:=ReadLong+iofs;        //�������� ������� ������
  pp:=pp+4;                       //������� ���-�� ������
  ipValues:=ReadLong+iofs;        //�������� ��������
  SetLength(items,coFrames);      //�������� ����� ��� �����
  if coFrames<=1 then begin       //��� ��������
   M2ReadControllerw:=-1;
   dec(CountOfControllers);
   SetLength(Controllers,CountOfControllers);
   exit;
  end;//of if
  svpp:=pp;                       //��������� ��������
  pp:=ipFrames;                   //������ ������
  //������ ����� ������� (�������� ����� ������)
  for i:=0 to coFrames-1 do Items[i].Frame:=ReadLong;
  pp:=ipValues;                   //��������� � ������ ��������
  //������ float-��������
  for i:=0 to coFrames-1 do begin
   for ii:=1 to count do Items[i].Data[ii]:=ReadShort/32767;
   //������ �������� (���� �����)
   if (ContType=Hermite) or (ContType=Bezier) then begin
    for ii:=1 to count do Items[i].InTan[ii]:=ReadShort/32767;
    for ii:=1 to count do Items[i].OutTan[ii]:=ReadShort/32767;
   end;//of if ii
  end;//of for i
  pp:=svpp;                       //������������ �������
 end;//of with

 M2ReadControllerw:=CountOfControllers-1;
End;
//---------------------------------------------------------
//����������������� (debug)
function M2ReadControllerExp(count:integer):integer;
Var iofs,i,ii,svpp,coFrames,ipFrames,ipValues,
    CountOfControllers,r:integer; px:pointer; pw:PWord;
Begin
 iofs:=integer(p);
// inc(CountOfControllers);
 CountOfControllers:=length(Controllers)+1;
 SetLength(Controllers,CountOfControllers);
 with Controllers[CountOfControllers-1] do begin
  ContType:=ReadShort+1;          //������ ��� ������������
  GlobalSeqID:=ReadShort;         //������ ����. ����.
  if GlobalSeqID>$8888 then GlobalSeqID:=-1;
  pp:=pp+2*4;                     //������� InterpolationRanges
  SizeOfElement:=count;
  coFrames:=ReadLong;             //���-�� ������
  ipFrames:=ReadLong+iofs;        //�������� ������� ������
  pp:=pp+4;                       //������� ���-�� ������
  ipValues:=ReadLong+iofs;        //�������� ��������
  SetLength(items,coFrames);      //�������� ����� ��� �����
  if coFrames<=1 then begin       //��� ��������
   M2ReadControllerExp:=-1;
   if coFrames<1 then begin
    dec(CountOfControllers);
    SetLength(Controllers,CountOfControllers);
    exit;
   end;//of if
  end;//of if
  svpp:=pp;                       //��������� ��������
  pp:=ipFrames;                   //������ ������
  //������ ����� ������� (�������� ����� ������)
  for i:=0 to coFrames-1 do Items[i].Frame:=ReadLong;
  pp:=ipValues;                   //��������� � ������ ��������
  //������ float-��������
  for i:=0 to coFrames-1 do begin
   for ii:=1 to count do begin
    R:=ReadShort;
    Items[i].Data[ii]:=r/32767-1;
   end;//of for i
   //������ �������� (���� �����)
   if (ContType=Hermite) or (ContType=Bezier) then begin
    for ii:=1 to count do Items[i].InTan[ii]:=ReadShort/32767-1;
    for ii:=1 to count do Items[i].OutTan[ii]:=ReadShort/32767-1;
   end;//of if ii
  end;//of for i
  pp:=svpp;                       //������������ �������
 end;//of with

 if coFrames>1 then Result:=CountOfControllers-1
               else Result:=-2;
End;
//---------------------------------------------------------
//������ ������ (int) ����������� (�����. 0..1)
function M2ReadControlleri(count:integer):integer;
Var iofs,i,ii,svpp,coFrames,ipFrames,ipValues,
    CountOfControllers:integer;
Begin
 iofs:=integer(p);
// inc(CountOfControllers);
 CountOfControllers:=length(Controllers)+1;
 SetLength(Controllers,CountOfControllers);
 with Controllers[CountOfControllers-1] do begin
  ContType:=ReadShort+1;          //������ ��� ������������
  GlobalSeqID:=ReadShort;         //������ ����. ����.
  if GlobalSeqID>$8888 then GlobalSeqID:=-1;
  pp:=pp+2*4;                     //������� InterpolationRanges
  SizeOfElement:=count;
  coFrames:=ReadLong;             //���-�� ������
  ipFrames:=ReadLong+iofs;        //�������� ������� ������
  pp:=pp+4;                       //������� ���-�� ������
  ipValues:=ReadLong+iofs;        //�������� ��������
  SetLength(items,coFrames);      //�������� ����� ��� �����
  if coFrames<=1 then begin       //��� ��������
   M2ReadControlleri:=-1;
   dec(CountOfControllers);
   SetLength(Controllers,CountOfControllers);
   exit;
  end;//of if
  svpp:=pp;                       //��������� ��������
  pp:=ipFrames;                   //������ ������
  //������ ����� ������� (�������� ����� ������)
  for i:=0 to coFrames-1 do Items[i].Frame:=ReadLong;
  pp:=ipValues;                   //��������� � ������ ��������
  //������ float-��������
  for i:=0 to coFrames-1 do begin
   for ii:=1 to count do Items[i].Data[ii]:=ReadLong/32767;
   //������ �������� (���� �����)
   if (ContType=Hermite) or (ContType=Bezier) then begin
    for ii:=1 to count do Items[i].InTan[ii]:=ReadLong/32767;
    for ii:=1 to count do Items[i].OutTan[ii]:=ReadLong/32767;
   end;//of if ii
  end;//of for i
  pp:=svpp;                       //������������ �������
 end;//of with

 M2ReadControlleri:=CountOfControllers-1;
End;
//---------------------------------------------------------
//������ 1-�������� ������������
function M2ReadControllerb(count:integer):integer;
Var iofs,i,ii,svpp,coFrames,ipFrames,ipValues,
    CountOfControllers:integer;
Begin
 iofs:=integer(p);
 CountOfControllers:=length(Controllers)+1;
 SetLength(Controllers,CountOfControllers);
 with Controllers[CountOfControllers-1] do begin
  ContType:=ReadShort+1;          //������ ��� ������������
  GlobalSeqID:=ReadShort;         //������ ����. ����.
  if GlobalSeqID>$8888 then GlobalSeqID:=-1;
  pp:=pp+2*4;                     //������� InterpolationRanges
  SizeOfElement:=count;
  coFrames:=ReadLong;             //���-�� ������
  ipFrames:=ReadLong+iofs;        //�������� ������� ������
  pp:=pp+4;                       //������� ���-�� ������
  ipValues:=ReadLong+iofs;        //�������� ��������
  SetLength(items,coFrames);      //�������� ����� ��� �����
  if coFrames<=1 then begin       //��� ��������
   M2ReadControllerb:=-1;
   dec(CountOfControllers);
   SetLength(Controllers,CountOfControllers);
   exit;
  end;//of if
  svpp:=pp;                       //��������� ��������
  pp:=ipFrames;                   //������ ������
  //������ ����� ������� (�������� ����� ������)
  for i:=0 to coFrames-1 do Items[i].Frame:=ReadLong;
  pp:=ipValues;                   //��������� � ������ ��������
  //������ byte-��������
  for i:=0 to coFrames-1 do begin
   for ii:=1 to count do Items[i].Data[ii]:=ReadByte;
   //������ �������� (���� �����)
   if (ContType=Hermite) or (ContType=Bezier) then begin
    for ii:=1 to count do Items[i].InTan[ii]:=ReadByte;
    for ii:=1 to count do Items[i].OutTan[ii]:=ReadByte;
   end;//of if ii
  end;//of for i
  pp:=svpp;                       //������������ �������
 end;//of with

 M2ReadControllerb:=CountOfControllers-1;
End;

//---------------------------------------------------------
//���������������: ���������� 2 ���������.
//� ������ ���������� ���������� true.
function IsMatsEqual(var m1,m2:TMaterial):boolean;
Var i:integer;
Begin
 IsMatsEqual:=false;              //���� ��� ����������
 if (m1.IsConstantColor<>m2.IsConstantColor) or
    (m1.CountOfLayers<>m2.CountOfLayers) then exit;
 //������ ������� ����:
 for i:=0 to m1.CountOfLayers-1 do begin
  if m1.Layers[i].FilterMode<>m2.Layers[i].FilterMode then exit;
  if (m1.Layers[i].IsUnshaded<>m2.Layers[i].IsUnshaded) or
     (m1.Layers[i].IsTwoSided<>m2.Layers[i].IsTwoSided) or
     (m1.Layers[i].IsUnfogged<>m2.Layers[i].IsUnfogged) or
     (m1.Layers[i].IsNoDepthTest<>m2.Layers[i].IsNoDepthTest) or
     (m1.Layers[i].IsNoDepthSet<>m2.Layers[i].IsNoDepthSet) then exit;
  if m1.Layers[i].TextureID<>m2.Layers[i].TextureID then exit;
  if m1.Layers[i].IsAlphaStatic<>m2.Layers[i].IsAlphaStatic then exit;
  if m1.Layers[i].Alpha<>m1.Layers[i].Alpha then exit;
  if m1.Layers[i].TVertexAnimID<>m2.Layers[i].TVertexAnimID then exit;
  if (m1.Layers[i].NumOfGraph<0) and (m2.Layers[i].NumOfGraph<0) then continue;
  if (m1.Layers[i].NumOfGraph<0) and
     (m1.Layers[i].NumOfGraph<>m2.Layers[i].NumOfGraph) then exit; 
  if length(Controllers[m1.Layers[i].NumOfGraph].items)<>
     length(Controllers[m2.Layers[i].NumOfGraph].items) then exit;
  if Controllers[m1.Layers[i].NumOfGraph].GlobalSeqId<>
     Controllers[m2.Layers[i].NumOfGraph].GlobalSeqId then exit;
 end;//of for i
 IsMatsEqual:=true;
End;
//---------------------------------------------------------
//���������������: ������ �������� �� M2-����� (WoW).
//���������� ID ������������ ���������
//lCount - ���-�� ������� ���� ��� �����.
//� ������ ������ pp ������ ��������� �� ������ ������ ����,
//CountOfMaterials - ��������� ���-�� ���-���.
function M2ReadMaterial(lCount,MeshID,GeoID,ipColors,ipRender,
                        ipTexUnits,ipTransp,ipAnLookup,
                        ipTexLookup:integer):integer;
Var i,ii,j,iofs,flg,tmp,svpp:integer;
    lr:TLayer;IsGACreated:boolean;
//��������� �� 0 ����� ���������� �����������
//������ ����� Color � ������� ���� ����������
procedure PopFloatColor(var color:TVertex);
Begin
 Color[1]:=Controllers[High(Controllers)].Items[0].Data[1];
 Color[2]:=Controllers[High(Controllers)].Items[0].Data[2];
 Color[3]:=Controllers[High(Controllers)].Items[0].Data[3];
 SetLength(Controllers,High(Controllers));
End;
Begin
 IsGACreated:=false;
 inc(CountOfMaterials);
 SetLength(Materials,CountOfMaterials);//������� ��������
 Materials[CountOfMaterials-1].CountOfLayers:=0;//���� ��� ����
 Materials[CountOfMaterials-1].IsConstantColor:=false;
 Materials[CountOfMaterials-1].ListNum:=-1;
 //�������� ������ ������ ����:
 for i:=1 to lCount do begin
  flg:=ReadShort;                 //������ ����� (�������, ��� �� �����)
//  if flg>0 then lr.IsTextureStatic:=true else lr.IsTextureStatic:=false;
  pp:=pp+2;                       //PriorityPlane?
  tmp:=ReadShort;                 //������ ID �����������
  if tmp<>MeshID then begin       //��� �� ��� ����
   pp:=pp+24-6;
   continue;
  end;//of if

  //������ ������ ����. ����� ������� ���.
  pp:=pp+2;                       //������� �������������� MeshID
  tmp:=ReadShort;                 //������ ������ �����
  if (CountOfGeosetAnims=0) or (not IsGACreated) then begin
   inc(CountOfGeosetAnims);        //������� GeosetAnim
   SetLength(GeosetAnims,CountOfGeosetAnims);
   with GeosetAnims[CountOfGeosetAnims-1] do begin
    GeosetID:=GeoID;
    IsDropShadow:=false;
    IsColorStatic:=true;
    IsAlphaStatic:=true;
    Alpha:=1;Color[1]:=1;Color[2]:=1;Color[3]:=1;
   end;//of with
   IsGACreated:=true;
  end;//of if
  if tmp<$8888 then begin
   //���� ������������, ����� ������� GeosetAnim.
   Materials[CountOfMaterials-1].IsConstantColor:=true;
   with GeosetAnims[CountOfGeosetAnims-1] do begin
    //��������� ���� ����������
    IsColorStatic:=false;
    IsAlphaStatic:=false;
    //������
    svpp:=pp;                      //��������� �������
    pp:=ipColors+$38*tmp;          //������ �������� ������
    ColorGraphNum:=M2ReadControllerf(3);
    if ColorGraphNum<0 then begin //����������� ����
     IsColorStatic:=true;
     Color[1]:=1;Color[2]:=1;Color[3]:=1;
    end;//of if(ColorStatic)
    if ColorGraphNum<-1 then PopFloatColor(Color);
    AlphaGraphNum:=M2ReadControllerw(1);//������ ������������(�����)
    if AlphaGraphNum<0 then begin
     IsAlphaStatic:=true;
     Alpha:=1;
    end;//of if(AlphaStatic)
    pp:=svpp;                     //������������ �������
   end;//of with
  end;//of if(����� �������� ���������)

  //������ ����� ����������:
  tmp:=ReadShort;                 //������ � ������� ������
  svpp:=pp;                       //��������� �������
  pp:=ipRender+4*tmp;             //����� ���� ������
  flg:=ReadShort;                 //������ ����� �����
  //������ ������
  if (flg and 1)<>0 then lr.IsUnshaded:=true else lr.IsUnshaded:=false;//!att
  if (flg and 2)<>0 then lr.IsUnfogged:=true else lr.IsUnfogged:=false;
  if (flg and 4)<>0 then lr.IsTwoSided:=true else lr.IsTwoSided:=false;
  {if (flg and 16)<>0 then lr.IsNoDepthSet:=true else} lr.IsNoDepthSet:=false;
  //����������� ��������� ������
  lr.IsSphereEnvMap:=false;
  lr.IsNoDepthTest:=false;
  //������ ����� ������ ��������:
  flg:=ReadShort;     //������
  case flg of
   0:lr.FilterMode:=Opaque;
   1:lr.FilterMode:=ColorAlpha;
   2:lr.FilterMode:=FullAlpha;
   3:lr.FilterMode:=Additive;
   4:begin lr.FilterMode:=Additive;end;
   5:lr.FilterMode:=Modulate;
   else lr.FilterMode:=Additive;
  end;//of case
  pp:=svpp;                       //������� � ���� ���������

  //������ ����� ���� � ��������� (-1,0,1)
  tmp:=ReadShort;
  svpp:=pp;
  pp:=ipTexUnits+2*tmp;           //���� � ������� ��������
  lr.CoordID:=ReadShort;          //������ (���� - � �������������� ���� ����)
//  if lr.CoordID>$8888 then lr.CoordID:=-1;
  pp:=svpp+2;                     //�������+������� ����

  lr.TextureID:=ReadShort;        //�������� ����
  //��������� �������� ID �������� (�� Lookup-�������):
  svpp:=pp;
  pp:=ipTexLookup+2*lr.TextureID;
  lr.TextureID:=ReadShort;
  pp:=svpp;

  pp:=pp+2;                       //������� ����

  //������������ (�����) � � ��������
  tmp:=ReadShort;                 //����� �������� �����
  svpp:=pp;
  pp:=ipTransp+tmp*$1C;           //���� ����������
  lr.IsAlphaStatic:=false;
  lr.NumOfGraph:=M2ReadControllerw(1);//������ ����������
  if lr.NumOfGraph<0 then begin
   lr.Alpha:=1;
   lr.IsAlphaStatic:=true;
  end;//of if
  //��������, ���� �� ���� ���������� � ����������� ��������������
  if (lr.FilterMode=Opaque) and (not lr.IsAlphaStatic) then begin
   if Controllers[lr.NumOfGraph].ContType<>DontInterp
   then lr.FilterMode:=ColorAlpha;
  end;//of if
  pp:=svpp;

  //����������� �������
  lr.NumOfTexGraph:=-1;
  lr.IsTextureStatic:=true;

  //������ ������ ID ���������� �������� (���� ������� ����)
  tmp:=ReadShort;                 //����� ������
  svpp:=pp;
  pp:=ipAnLookup+2*tmp;           //������ ������
  lr.TVertexAnimID:=ReadShort;
  if lr.TVertexAnimID>$8888 then lr.TVertexAnimID:=-1;
  pp:=svpp;

  //���! ������ ���� � ����� ��������.
  //������ ��� ����� �������� � ��������� � ���������� �����

  //���� ��� ����. ����, ���� ��������� (�� ������� CoordID):
  with Materials[CountOfMaterials-1] do begin
   for ii:=0 to CountOfLayers do begin

    if ii=CountOfLayers then begin//�����, ����� ��������
     inc(CountOfLayers);              //������� ����������
     SetLength(Layers,CountOfLayers);
     Layers[CountOfLayers-1]:=lr;
     break;                       //����� �� �����
    end;//of if

    if lr.CoordID<Layers[ii].CoordID then begin//�������
     inc(CountOfLayers);
     SetLength(Layers,CountOfLayers);
     for j:=CountOfLayers-2 downto ii do Layers[j+1]:=Layers[j];
     Layers[ii]:=lr;
     break; 
    end;//of if

   end;//of for ii

  end;//of with

 end;//of for i

 //������ - ����� CoordID ��� ���� ����
 with Materials[CountOfMaterials-1] do
      for ii:=0 to CountOfLayers-1 do Layers[ii].CoordID:=-1;
 //�����: ����� ���� ����� ��������?
 for i:=0 to CountOfMaterials-2 do
  if IsMatsEqual(Materials[i],Materials[CountOfMaterials-1]) then begin
  M2ReadMaterial:=i;
  dec(CountOfMaterials);
  exit;
 end;//of for i
 //��� ������
 M2ReadMaterial:=CountOfMaterials-1;
// Materials[CountOfMaterials-1]
End;
//---------------------------------------------------------
//���������������: ������ ��������-�������� � �����. ��� ID
function CreateFakedMaterial:integer;
Begin
 MessageBox(0,'�� ������ �������� �����������.'#13#10+
              '��������� ��� ������ ������ MdlVis',
              scError,mb_iconstop);
 CreateFakedMaterial:=0;
End;
//---------------------------------------------------------
//���������������: ������ ���������� �������� WoW
procedure M2ReadTextureAnims(coTexAnims,ipTexAnims:integer);
Var i:integer;
Begin
 CountOfTextureAnims:=coTexAnims;
 SetLength(TextureAnims,CountOfTextureAnims);
 pp:=ipTexAnims;
 for i:=0 to CountOfTextureAnims-1 do with TextureAnims[i] do begin
  TranslationGraphNum:=M2ReadControllerf(3);
  //�������� ���� �� ������:
  pp:=pp+$1C;
  RotationGraphNum:=-1;
  ScalingGraphNum:=M2ReadControllerf(3);
//  RotationGraphNum:=M2ReadControllerf(3);
 end;//of with/for
End;
//---------------------------------------------------------
//���������������: ������ ������ ���������� �������������������
procedure M2ReadGlobalSequences(coGlb,ipGlb:integer);
Var i:integer;
Begin
 pp:=ipGlb;
 CountOfGlobalSequences:=coGlb;
 SetLength(GlobalSequences,CountOfGlobalSequences);
 for i:=0 to CountOfGlobalSequences-1 do GlobalSequences[i]:=ReadLong;
End;
//---------------------------------------------------------
//���������������: ������ ������ �������� (Sequences),
//������� Anim'� � ������ �����������
procedure M2ReadSequences(coSeq,ipSeq:integer);
Var i,ii,j,id,flg,coCin,coSeqs:integer;
    minx,miny,minz,maxx,maxy,maxz:GLFloat;
Const sst='Cinematic';
Begin
 coCin:=1;
 CountOfSequences:=coSeq;
 SetLength(Sequences,CountOfSequences);
 pp:=ipSeq;
 for i:=0 to CountOfSequences-1 do with Sequences[i] do begin
  id:=ReadLong;                   //ID ��������
  IntervalStart:=ReadLong;
  IntervalEnd:=ReadLong;
  MoveSpeed:=round(ReadFloat);
  flg:=ReadLong;
  if (flg and 1)<>0 then IsNonLooping:=true else IsNonLooping:=false;
  pp:=pp+4*4;                     //������� ����� �����
  //--����� ����� ������������ ����� �� ID
  case id of
   0:Name:='Stand';
   1:Name:='Death';
   2:Name:='Spell';
   3:Name:='Cinematic Stop';
   4:Name:='Walk';
   5:Name:='Walk Fast';
   6:Name:='Decay Flesh';
   7:Name:=sst+' Rise';
   8:Name:='Stand Hit';
   9:Name:='Stand Hit Large';
   10:Name:='Stand Hit Critical';
   11:Name:=sst+' ShuffleLeft';
   12:Name:=sst+' ShuffleRight';
   13:Name:=sst+' WalkBackward';
   14:Name:='Stand Wounded';
   15:Name:=sst+' HandsClosed';
   16:Name:='Attack';{ Alternate'}
   17:Name:='Attack First';
   18:Name:='Attack Second';
   19:Name:='Attack Third';
   20:Name:='Stand Hit Medium';
   21:Name:='Stand Hit Medium First';
   22:Name:='Stand Hit Medium Second';
   23:Name:='Stand Hit Medium Third';
   24:Name:='Stand Hit Defend';
   25:Name:='Stand Ready';
   26:Name:='Stand Ready First';
   27:Name:='Stand Ready Second';
   28:Name:='Stand Ready Third';
   29:Name:='Stand Gold Fourth';
   30:Name:='Stand Hit Small';
   31:Name:='Spell Second';
   32:Name:='Spell Channel Second';
   33:Name:='Spell Channel Second';
   34:Name:=sst+' Welcome';
   35:Name:=sst+' Goodbye';
   36:Name:='Stand Hit';
   37:Name:=sst+' JumpStart';
   38:Name:=sst+' Jump';
   39:Name:=sst+' JumpEnd';
   40:Name:=sst+' Fall';
   41:Name:='Stand Swim';
   42:Name:='Walk Swim';
   43:Name:='Walk Right Swim';
   44:Name:='Walk Left Swim';
   45:Name:=sst+' SwimBackward';
   46:Name:='Attack Fourth';
   47:Name:='Attack Fourth';
   48:Name:='Stand Gold Fifth';
   49:Name:='Attack Fifth';
   50:Name:='Stand Victory';
   51:Name:='Spell Ready Throw';
   52:Name:='Spell Ready';
   53:Name:='Spell Throw';
   54:Name:='Spell';
   55:Name:='Spell Slam';
   56:Name:='Stand Ready Second';
   57:Name:='Attack Slam First';
   58:Name:='Attack Slam Second';
   59:Name:='Attack Off Two';
   60:Name:='Portrait Talk';
   61:Name:=sst+' Eat';
   62:Name:='Stand Work';
   63:Name:='Portrait';
   64:Name:='Portrait Talk';
   65:Name:='Portrait Talk';
   66:Name:=sst+' EmoteBow';
   67:Name:=sst+' EmoteWave';
   68:Name:=sst+' EmoteCheer';
   69:Name:=sst+' EmoteDance';
   70:Name:=sst+' EmoteLaugh';
   71:Name:=sst+' EmoteSleep';
   85:Name:='Attack First';
   86:Name:='Attack Third';
   87:Name:='Attack Off';
   88:Name:='Attack Off';
   95:Name:='Attack Upgrade';
   100:Name:='Sleep';
   105:Name:='Stand Ready Fourth';
   106:Name:='Stand Ready Fifth';
   107:Name:='Attack Puke';
   108:Name:='Stand Gold Alternate';
   109:Name:='Stand Lumber Fourth';
   110:Name:='Stand Lumber Fifth';
   111:Name:='Stand Lumber Alternate';
   112:Name:='Stand Ready Alternate';
   113:Name:='Stand Victory';
   117:Name:='Attack Off Alternate';
   118:Name:='Attack Slam';
   119:Name:='Walk Moderate';
   120:Name:='Stand Moderate';
   121:Name:='Stand Hit Slam';
   124:Name:='Stand Channel Throw';
   125:Name:='Spell Ready';
   126:Name:='Attack Walk Stand Spin';
   127:Name:='Birth';
   131:Name:='Death Swim';
   132:Name:='Decay Swim';
   135:Name:='Stand';
   143:Name:='Walk Fast';
   144:Name:='Walk';
   146:Name:=sst+' Close';
   147:Name:=sst+' Closed';
   158:Name:='Stand Lumber';
   159:Name:='Decay';
   160:Name:=sst+' BowPull';
   161:Name:=sst+' BowRelease';
   181:Name:='Attack Slam Large';
   190:Name:='Stand';
   194:Name:='Stand Victory';
   else begin                     //���������
    Name:='Cinematic '+inttostr(id)+inttostr(coCin);
    inc(coCin);
   end;
  end;//of case

  //������ ������
  for ii:=1 to 3 do Bounds.MinimumExtent[ii]:=ReadFloat*wowmult;
  for ii:=1 to 3 do Bounds.MaximumExtent[ii]:=ReadFloat*wowmult;
  Bounds.BoundsRadius:=ReadFloat*wowmult;
  pp:=pp+4;                       //������� ��� ���� �����
 end;//of with/for i

 //������� �������� (���������� �������������� � ������ ���)
 i:=0;
 while i<CountOfSequences do begin
  ii:=i+1;coSeqs:=1;
  while ii<CountOfSequences do begin
   //�������� �� �����������
   if (Sequences[ii].IntervalStart<=Sequences[i].IntervalEnd) and
      (Sequences[ii].IntervalStart>=Sequences[i].IntervalStart) then begin
    for j:=ii+1 to CountOfSequences-1 do Sequences[j-1]:=Sequences[j];
    dec(CountOfSequences);
    SetLength(Sequences,CountOfSequences);
    continue;
   end;//of if

   //�������� �� ���������� ���
   if Sequences[i].Name=Sequences[ii].Name then begin
    inc(coSeqs);
    Sequences[ii].Name:=Sequences[ii].Name+' '+inttostr(coSeqs);
//    Sequences[ii].IsNonLooping:=true;
   end;//of if
   inc(ii);
  end;//of while

  //��������� ������
  if pos('Attack',Sequences[i].Name)<>0 then Sequences[i].IsNonLooping:=true;
  if pos('Stand',Sequences[i].Name)<>0 then Sequences[i].IsNonLooping:=false;
  if pos('Walk',Sequences[i].Name)<>0 then Sequences[i].IsNonLooping:=false;
  if pos('Channel',Sequences[i].Name)<>0 then Sequences[i].IsNonLooping:=false;
  if pos('Portrait',Sequences[i].Name)<>0 then Sequences[i].IsNonLooping:=false;        
  inc(i);
 end;//of while
 //������ ������� �������������� ����� ��� ������������:
 for i:=0 to CountOfGeosets-1 do with Geosets[i] do begin
  minx:=1000;miny:=1000;minz:=1000;
  maxx:=-1000;maxy:=-1000;maxz:=-1000;
  //����� ������:
  for ii:=0 to CountOfVertices-1 do begin
   if Vertices[ii,1]<minx then minx:=Vertices[ii,1];
   if Vertices[ii,1]>maxx then maxx:=Vertices[ii,1];
   if Vertices[ii,2]<miny then miny:=Vertices[ii,2];
   if Vertices[ii,2]>maxy then maxy:=Vertices[ii,2];
   if Vertices[ii,3]<minz then minz:=Vertices[ii,3];
   if Vertices[ii,3]>maxz then maxz:=Vertices[ii,3];
  end;//of for ii
  MinimumExtent[1]:=minx;
  MinimumExtent[2]:=miny;
  MinimumExtent[3]:=minz;
  MaximumExtent[1]:=maxx;
  MaximumExtent[2]:=maxy;
  MaximumExtent[3]:=maxz;
  //��������� ������
  BoundsRadius:=sqrt(sqr(MaximumExtent[1]-MinimumExtent[1])+
                sqr(MaximumExtent[2]-MinimumExtent[2])+
                sqr(MaximumExtent[3]-MinimumExtent[3]))*0.5;
  //������ ��������� ������� �������� Anim:
  CountOfAnims:=CountOfSequences;
  SetLength(Anims,CountOfAnims);
  for ii:=0 to CountOfAnims-1 do begin
   Anims[ii].MinimumExtent:=MinimumExtent;
   Anims[ii].MaximumExtent:=MaximumExtent;
   Anims[ii].BoundsRadius:=BoundsRadius;
  end;//of for ii
 end;//of with/for i

 //������ ��������� ������� ��� ���� ������
 //��� 1.5 ��������� ������
 AnimBounds.MinimumExtent:=Geosets[0].MinimumExtent;
 AnimBounds.MaximumExtent:=Geosets[0].MaximumExtent;
 for i:=0 to CountOfGeosets-1 do with Geosets[i] do begin
  if MinimumExtent[1]<AnimBounds.MinimumExtent[1] then
     AnimBounds.MinimumExtent[1]:=MinimumExtent[1];
  if MinimumExtent[2]<AnimBounds.MinimumExtent[2] then
     AnimBounds.MinimumExtent[2]:=MinimumExtent[2];
  if MinimumExtent[3]<AnimBounds.MinimumExtent[3] then
     AnimBounds.MinimumExtent[3]:=MinimumExtent[3];

  if MaximumExtent[1]>AnimBounds.MaximumExtent[1] then
     AnimBounds.MaximumExtent[1]:=MaximumExtent[1];
  if MaximumExtent[2]>AnimBounds.MaximumExtent[2] then
     AnimBounds.MaximumExtent[2]:=MaximumExtent[2];
  if MaximumExtent[3]>AnimBounds.MaximumExtent[3] then
     AnimBounds.MaximumExtent[3]:=MaximumExtent[3];
 end;//of with/for i
 with AnimBounds do
  BoundsRadius:=sqrt(sqr(MaximumExtent[1]-MinimumExtent[1])+
                sqr(MaximumExtent[2]-MinimumExtent[2])+
                sqr(MaximumExtent[3]-MinimumExtent[3]))*0.5;
End;
//---------------------------------------------------------
//���������������: �������� ��� �������� ����������� ContID
//�� ��������� �����
procedure MultController(ContID:integer;m:single);
Var l,i,ii:integer;
Begin
 l:=High(Controllers[ContID].Items);
 for i:=0 to l do
  for ii:=1 to 5 do with Controllers[ContID].Items[i] do begin
   Data[ii]:=Data[ii]*m;
   InTan[ii]:=InTan[ii]*m;
  end;//of with/for ii/i
End;
//---------------------------------------------------------
//������ ���� �������� ������� (������).
//CurID ��� ���� ���������� �� ��������� ���������
procedure M2ReadBones(coB,ipB:integer;var CurID:integer);
Var i,ii{,j},flg:integer;
Begin
 CountOfHelpers:=0;               //��� ����������
 CountOfBones:=coB;
 CountOfPivotPoints:=coB;
 SetLength(Bones,CountOfBones);
 SetLength(PivotPoints,CountOfPivotPoints);
 //���������� ������
 pp:=ipB;
 for i:=0 to CountOfBones-1 do with Bones[i] do begin
  Name:='bone_b'+inttostr(CurID); //��� �����
  ObjectID:=CurID;                //ID �����
  GeosetID:=Multiple;
  GeosetAnimID:=-1;

  pp:=pp+4;                       //������� ������� F
  flg:=ReadLong;                  //������ �����
  if (flg and 8)<>0 then IsBillboarded:=true else IsBillboarded:=false;
  Parent:=ReadShort;
  if Parent>$8888 then Parent:=-1;
  pp:=pp+2;                       //������� ����
  if Version>=$104 then pp:=pp+4; //������� ��� ������ ����


  //����������� ���� ����������
  IsBillboardedLockX:=false;IsBillboardedLockY:=false;IsBillboardedLockX:=false;
  IsCameraAnchored:=false;
  IsDIRotation:=false;IsDITranslation:=false;IsDIScaling:=false;

  //������ ������������
  Translation:=M2ReadControllerf(3);
//  Translation:=-1;
  if Translation=-2 then Translation:=High(Controllers);
  if Version>=$104 then Rotation:=M2ReadControllerExp(4)
  else Rotation:=M2ReadControllerf(4);
  if Rotation=-2 then Rotation:=High(Controllers);
  Scaling:=M2ReadControllerf(3);
  if Scaling=-2 then Scaling:=High(Controllers);  
  Visibility:=-1;
  //��������������� ����������� �������� (Translation):

  if Translation>=0 then MultController(Translation,wowmult);

  //��������� ����� ������ (Pivot):
  for ii:=1 to 3 do PivotPoints[CurID,ii]:=ReadFloat*wowmult;
  inc(CurID);
 end;//of with/for i
// Bones[0]
End;
//---------------------------------------------------------
//���������������: ��������� ��������� ���� ������������.
//true, ���� ��� ������������
{function IsGeosEqual(var g1,g2:TGeoset):boolean;
Var i,ii,len:integer;
Begin
 IsGeosEqual:=false;              //���� ��������� ���������
 if (g1.CountOfVertices<>g2.CountOfVertices) or
    (g1.MaterialID<>g2.MaterialID) or
    (g1.CountOfMatrices<>g2.CountOfMatrices) then exit;
 //�������� ������
 for i:=0 to g1.CountOfMatrices-1 do begin
  if length(g1.Groups[i])<>length(g2.Groups[i]) then exit;
  len:=length(g1.Groups[i])-1;
  for ii:=0 to len do if g1.Groups[i,ii]<>g2.Groups[i,ii] then exit;
 end;//of for i
 //�������� ������� ����������
 if length(g1.Faces[0])<>length(g2.Faces[0]) then exit;
 len:=length(g1.Faces[0])-1;
 for i:=0 to len do if g1.Faces[0,i]<>g2.Faces[0,i] then exit;
 //����� ������ �� �������
 for i:=0 to g1.CountOfVertices-1 do
  if g1.VertexGroup[i]<>g2.VertexGroup[i] then exit;

 IsGeosEqual:=true;
End;}
//---------------------------------------------------------
//���������������: ������������ ��� �������� ������
//fname - ��� ����� ������ (������������ ��� ��������� ����)
procedure M2ConvertTextures(name,fname:string);
Var //fi:_Win32_Find_Data;
    path,tname:string;
    ps,i:integer;
    sr:TSearchRec;
    buf:array[0..512] of char;
    pBuf:PChar;
Begin
 //0. ��������, �������� �� IJL:
 if (@ijlInit=nil) or (@ijlWrite=nil) or (@ijlFree=nil) then begin
   MessageBox(0,'���������� ijl15.dll �� �������,'#13#10+
                '�������� blp-������� ����������.',
                '��������:',mb_iconstop or mb_applmodal);
   exit;                           //���������� ��� ������
 end;//of if
 //1. ������� ����
 ps:=length(fname);
 while (ps>0) and (fname[ps]<>'\') do dec(ps);
 path:=copy(fname,1,ps);
 //1. ������� ��� �����, ������������ � ����� ������
 if FindFirst(path+name+'*.blp',faAnyFile,sr)=0 then begin//����!
  ConvertBLP2ToBLP(sr.Name,true);//�������������� ���������
  //����� - ���� ��������������� ���� �������
  while FindNext(sr)=0 do ConvertBLP2ToBLP(sr.Name,true);
  FindClose(sr);
 end;//of if (���� ������)

 //2. ���� �������������� ����� (��������� � ���� ����� �����)
 for i:=0 to CountOfTextures-1 do begin
  //���������� ��� ����� �������� (��� ����):
  ps:=length(Textures[i].FileName);
  while (ps>0) and (Textures[i].FileName[ps]<>'\') do dec(ps);
  tname:=Textures[i].FileName;
  Delete(tname,1,ps);
  //����, ���� �� ����� ����
  if SearchPath(PChar(path),PChar(tname),nil,512,buf,pBuf)<>0 then
     ConvertBLP2ToBLP(path+tname,true);
 end;//of for i
End;
//---------------------------------------------------------
//���������������: ��������� ����� ����� ������������
procedure M2ReadAttachments(coA,ipA:integer;var CurID:integer);
Var i,ii,id:integer;
Begin
 pp:=ipA;
 CountOfAttachments:=coA;
 SetLength(Attachments,CountOfAttachments);
 CountOfPivotPoints:=CountOfPivotPoints+coA;
 SetLength(PivotPoints,CountOfPivotPoints);
 for i:=0 to CountOfAttachments-1 do with Attachments[i] do begin
  InitTBone(Skel);
  Skel.ObjectID:=CurID;
  id:=ReadLong;                   //������ ID �����
  //���������� ��� ����� ������������:
  with Skel do case id of
   0:Name:='Hand Second Left Ref';
   1,21,35:Name:='Hand First Right Ref';
   2,22:Name:='Hand First Left Ref';
   3:Name:='Hand Third Right Ref';
   4:Name:='Hand Third Left Ref';
   5:Name:='Hand Fourth Right Ref';
   6:Name:='Hand Fourth Left Ref';
   7:Name:='Foot Second Right Ref';
   8:Name:='Foot Second Left Ref';
   9:Name:='Unk1 Right Ref';      //����(������)
   10:Name:='Unk1 Left Ref';      //����(������), ����.
   11:Name:='Head Ref';
   12:Name:='Chest Rear Ref';
   13:Name:='Unk2 Right Ref';     //�����
   14:Name:='Unk2 Left Ref';      //�����
   15:Name:='Chest Left Ref';     //!
   16:Name:='Chest Second Ref';   //!
   17:Name:='Head Second Ref';
   18:Name:='Overhead Ref';
   19:Name:='Origin Ref';
   20:Name:='Head First Ref';

   23:Name:='Unk3 Ref';
   24:Name:='Unk4 Ref';
   25:Name:='Unk5 Ref';

   26:Name:='Weapon Rear Right Ref';
   27:Name:='Weapon Rear Left Ref';
   28:Name:='Weapon Ref';
   29:Name:='Chest Ref';
   30:Name:='Back Left Ref';
   31:Name:='Back Right Ref';
   32:Name:='Weapon Mount Left Ref';
   33:Name:='Weapon Mount Right Ref';
   34:Name:='Chest Right Ref';
   else Name:='Unk'+inttostr(ID);
  end;//of case
  //ID �����:
  Skel.Parent:=ReadLong and $FFFF;
  if Skel.Parent>$8888 then Skel.Parent:=-1;
  if Skel.Parent<0 then Skel.Parent:=-1;
  //���������� (������� �����)
  for ii:=1 to 3 do PivotPoints[CurID,ii]:=ReadFloat*wowmult;
  //���� ��������
  Skel.Visibility:=M2ReadControlleri(1);
  if Skel.Visibility>=0 then
     for ii:=0 to High(Controllers[Skel.Visibility].Items) do begin
     if Controllers[Skel.Visibility].Items[ii].Data[1]<0.007 then
      Controllers[Skel.Visibility].Items[ii].Data[1]:=0
     else Controllers[Skel.Visibility].Items[ii].Data[1]:=1;
  end;//of for/if
{  //����������� ��������:
  IsBillboardedLockX:=false;
  IsBillboardedLockY:=false;
  IsBillboardedLockZ:=false;
  IsBillboarded:=false;
  IsCameraAnchored:=false;
  IsDITranslation:=false;
  IsDIRotation:=false;
  IsDIScaling:=false;}
  AttachmentID:=-1;
  Path:='';
{  TranslationGraphNum:=-1;
  RotationGraphNum:=-1;
  ScalingGraphNum:=-1;}
  inc(CurID);
 end;//of for i
End;
//---------------------------------------------------------
//���������������: ������ �������-������ � ������� WoW
procedure M2ReadCameras(coC,ipC:integer);
Var i,ii:integer;
Begin
 pp:=ipC;
 CountOfCameras:=coC;
 SetLength(Cameras,CountOfCameras);
 for i:=0 to CountOfCameras-1 do with Cameras[i] do begin
  pp:=pp+4;                       //������� -1
  FieldOfView:=ReadFloat*35*2*0.01745329;//���� ������
  FarClip:=ReadFloat*wowmult;
  NearClip:=ReadFloat*wowmult;

  TranslationGraphNum:=M2ReadControllerf(3);
  if TranslationGraphNum>=0 then MultController(TranslationGraphNum,wowmult);
  for ii:=1 to 3 do Position[ii]:=ReadFloat*wowmult;

  TargetTGNum:=M2ReadControllerf(3);
  if TargetTGNum>=0 then MultController(TargetTGNum,wowmult);
  for ii:=1 to 3 do TargetPosition[ii]:=ReadFloat*wowmult;

  RotationGraphNum:=M2ReadControllerf(1);
  Name:='Camera'+inttostr(i);
 end;//of for i
End;
//---------------------------------------------------------
procedure M2FindTextures(fn,mn:string);
Var i,ps:integer;
    path,fnd,fnd2:string;
    IsPolyTex:boolean;
    ffnd:TSearchRec;
Begin
 //������� ����
 ps:=length(fn);
 while (ps>0) and (fn[ps]<>'\') do dec(ps);
 path:=copy(fn,1,ps);
 IsPolyTex:=false;

 //1. ��������, ������������ �� ��� �����
 for i:=0 to CountOfTextures-1 do with Textures[i] do begin
  if pos('\',FileName)<>0 then continue;//��������� ��������
  if pos('Skin',FileName)=0 then continue;//��� �� "��������" ��������
  if (pos('2',FileName)<>0) or (pos('3',FileName)<>0) then begin
   IsPolyTex:=true;
   break;
  end;//of if
 end;//of for i

 //2. ���������� ���� ������:
 for i:=0 to CountOfTextures-1 do with Textures[i] do begin
  if pos('Skin',FileName)=0 then continue;//������ ��� �������� �������
  fnd:=path+ModelName+'*'+'Skin';
  if IsPolyTex then begin         //������ �������� ��� ��������
   if pos('1',FileName)<>0 then fnd2:=fnd+'*1*.blp';
   if pos('2',FileName)<>0 then fnd2:=fnd+'*2*.blp';
   if pos('3',FileName)<>0 then fnd2:=fnd+'*3*.blp';
   if FindFirst(fnd2,faAnyFile,ffnd)=0 then begin//���� ������!
    FileName:=ffnd.Name;
    FindClose(ffnd);
   end;//of if
  end else begin
   fnd2:=fnd+'*.blp';
   if FindFirst(fnd2,faAnyFile,ffnd)=0 then begin//���� ������!
    FileName:=ffnd.Name;
    FindClose(ffnd);
   end;//of if
  end;//of if(IsPolyTex)
 end;//of for i

End;
//-------------------------------------------------------
//���������������:
//��������������� ���������� ������ WoW
procedure M2ReadParticleEmitters(coP,ipP:integer;
          var CurID:integer);
Var i,ii:integer;flg,tmp:integer;ftmp:GLFloat;
Const speedmult=3;ERmult=5;Reduct=0.5;
procedure ReduceFloatController;//���������� ����������
Var tmp:integer;
Begin
  tmp:=M2ReadControllerf(1);
  if tmp>=0 then begin
   tmp:=length(Controllers)-1;
   if tmp<0 then tmp:=0;
   SetLength(Controllers,tmp);
  end;//of if
End;
//��������� �� 0 ����� ���������� �����������
//Data-����� � ������� ���� ����������
function PopFloatValue:single;
Begin
 Result:=Controllers[High(Controllers)].Items[0].Data[1];
 SetLength(Controllers,High(Controllers));
End;
Begin
 CountOfParticleEmitters:=coP;
 SetLength(pre2,CountOfParticleEmitters);
 CountOfPivotPoints:=CountOfPivotPoints+coP;
 SetLength(PivotPoints,CountOfPivotPoints);
 pp:=ipP;
 for i:=0 to CountOfParticleEmitters-1 do with pre2[i] do begin
  //������������� ���������
  FillChar(pre2[i],SizeOf(pre2[i]),0);
  pre2[i].Speed:=cNone;
  pre2[i].Variation:=-1;pre2[i].Latitude:=cNone;
  pre2[i].Gravity:=cNone;
  pre2[i].LifeSpan:=cNone;pre2[i].EmissionRate:=cNone;
  pre2[i].Width:=0;pre2[i].Length:=0;
  pre2[i].BlendMode:=FullAlpha;
  pre2[i].Rows:=1;pre2[i].Columns:=1;
  pre2[i].ParticleType:=ptHead;
  pre2[i].TailLength:=cNone;pre2[i].Time:=cNone;
  pre2[i].PriorityPlane:=-1;
  pre2[i].IsSStatic:=true;pre2[i].IsVStatic:=true;
  pre2[i].IsLStatic:=true;pre2[i].IsGStatic:=true;
  pre2[i].IsEStatic:=true;pre2[i].IsWStatic:=true;
  pre2[i].IsHStatic:=true;
  pre2[i].LifeSpanUVAnim[3]:=1;
  pre2[i].DecayUVAnim[3]:=1;
  pre2[i].TailUVAnim[3]:=1;
  pre2[i].TailDecayUVAnim[3]:=1;
  pp:=pp+4;                       //������� ID
  flg:=ReadLong;                  //������ ���� ����������
  IsXYQuad:=(flg and $1000)<>0;
  IsLineEmitter:=true;
//  pre2[i].IsModelSpace:=true;
  //������ ������� ���������
  for ii:=1 to 3 do PivotPoints[CurID,ii]:=ReadFloat*wowmult;
  //�������������� "���������" ���� ���������
  InitTBone(Skel);
  Skel.ObjectID:=CurID;
  Skel.Parent:=ReadShort;         //��������
  Skel.Name:='Particle_'+inttostr(i);
  TextureID:=ReadShort;           //ID ��������
  //������� ����� �������
  pp:=pp+4*4;                     //4 ����

  //����� ��������
  flg:=ReadShort;     //������
  case flg of
   0:BlendMode:=Opaque;
   1:BlendMode:=ColorAlpha;
   2:BlendMode:=FullAlpha;
   3:BlendMode:=Additive;
   4:begin BlendMode:=Additive;end;
   5:BlendMode:=Modulate;
   else BlendMode:=Additive;
  end;//of case

  pp:=pp+2;                       //������� ����� ������
  pp:=pp+2;                       //������� ���� ������
  pp:=pp+2;                       //TileRotation

  //�������/������
  Rows:=ReadShort;
  Columns:=ReadShort;
  
  //������ ����� ������������ ����������
  Speed:=M2ReadControllerf(1);
  IsSStatic:=(Speed<0);
  if Speed<-1 then Speed:=PopFloatValue*speedmult;
  Variation:=M2ReadControllerf(1);
  IsVStatic:=(Variation<0);
  if Variation<-1 then Variation:=PopFloatValue*100;
  Latitude:=M2ReadControllerf(1);
  IsLStatic:=(Latitude<0);
  if Latitude<-1 then Latitude:=PopFloatValue*57.29578*Reduct;
  //���������� ����������
  ReduceFloatController;
  //���������� ������. �� ������� - ����������
  Gravity:=M2ReadControllerf(1);
  IsGStatic:=(Gravity<0);
  if Gravity<-1 then Gravity:=PopFloatValue*wowmult*speedmult;
  if not IsGStatic then MultController(round(Gravity),wowmult*speedmult);
  LifeSpan:=M2ReadControllerf(1);//War �� ������������ ��������
  LifeSpan:=PopFloatValue;
  EmissionRate:=M2ReadControllerf(1);
  IsEStatic:=(EmissionRate<0);
  if EmissionRate<-1 then EmissionRate:=PopFloatValue;
  if not IsEStatic then MultController(round(EmissionRate),ERmult);
  Length:=M2ReadControllerf(1);
  IsHStatic:=(Length<0);
  if Length<-1 then Length:=PopFloatValue*wowmult*Reduct;
  if not IsHStatic then MultController(round(Length),wowmult*Reduct);
  Width:=M2ReadControllerf(1);
  IsWStatic:=(Width<0);
  if Width<-1 then Width:=PopFloatValue*wowmult*Reduct;
  if not IsWStatic then MultController(round(Width),wowmult*Reduct);
//  tmp:=M2ReadControllerf(1);
//  if tmp<>-1 then Gravity:=Gravity+PopFloatValue;
  ReduceFloatController;          //������� Gravity2

  Time:=ReadFloat;                //���������� �����
  //������ �������� ������������
  for ii:=1 to 3 do begin
   tmp:=ReadLong;             
   SegmentColor[ii,1]:=(tmp and $0FF)/255;
   SegmentColor[ii,2]:=((tmp and $0FF00) shr 8)/255;
   SegmentColor[ii,3]:=((tmp and $0FF0000) shr 16)/255;
   Alpha[ii]:=(tmp and $FF000000) shr 24;
  end;//of for ii

  //������ ������� ������
  for ii:=1 to 3 do ParticleScaling[ii]:=ReadFloat*wowmult*reduct;

  for ii:=1 to 3 do LifeSpanUVAnim[ii]:=ReadShort;
  for ii:=1 to 3 do DecayUVAnim[ii]:=ReadShort;
  pp:=pp+4*2;                    //������� ���� ����������
  pp:=pp+3*4;                     //3 float
  //������ Scaling2
//  for ii:=1 to 3 do ParticleScaling[ii]:=ReadFloat;
  pp:=pp+3*4;                     //Scaling2 (float)
  //������ SlowDown (��� �������� � WC3).
  ftmp:=ReadFloat;
//  Gravity:=Gravity+((Speed/abs(Speed))*exp(-ftmp*LifeSpan))/LifeSpan;


  pp:=pp+1*4;                     //Rotation
  pp:=pp+10*4;                    //10 float
  pp:=pp+6*4;                     //6 float

  Skel.Visibility:=M2ReadControllerb(1);
  inc(CurID);
 end;//of for i
End;
//-------------------------------------------------------
//���������������:
//1. ������ ���
//2. ���������� ��� � ��������� �������
//3. ���� �� ��������� - ������� (�����. false).
//4. ���������� ����� ���� � tagLength
//5. ���������� ��������� �� ������ ���� � pData
//6. ��������� � ���������� ����
//� ������ ������ �����. true
function GetTAGPointer(tag:string;var tagLength:integer;var p:pointer):boolean;
var s:string;
Begin
 s:=ReadASCII(4);
 if s<>tag then begin
  MessageBox(0,'������ ������ ����� WMO.'#13#10+
               '�������� ��� ������ ������������ MdlVis.','������',MB_ICONSTOP);
  Result:=false;
 end else Result:=true;

 tagLength:=ReadLong;
 p:=pointer(pp);
 pp:=pp+tagLength;
End;
//-------------------------------------------------------
//���������������: ����� ������������ ��������� WMO
//�� ������������. ������������������ �� ������������.
procedure WMOFormGeosetFaces(var w:TWMO;mt:PMOPY;fc:PMOVI;coFaces:integer);
Var i,ii,GeoID,OldGeoCount,len:integer;IsFound:boolean;
Begin
 OldGeoCount:=w.CountOfGeosets;
 for i:=0 to coFaces-1 do begin
  IsFound:=false;                 //���� ��� �� �������
  GeoID:=0;

  //1. ����� ����������� � ������ ����������
  for ii:=w.CountOfGeosets-1 downto OldGeoCount
  do if w.Geosets[ii].MaterialID=mt^[i*2+1] then begin //�������!
   IsFound:=true;
   GeoID:=ii;                     //��������� � ID
   break;
  end;

  //2. ���� �� �������, ������� �
  if not IsFound then begin
   inc(w.CountOfGeosets);
   SetLength(w.Geosets,w.CountOfGeosets);
   GeoID:=w.CountOfGeosets-1;
   w.Geosets[GeoID].MaterialID:=mt^[i*2+1];
   w.Geosets[GeoID].CountOfFaces:=1;
   SetLength(w.Geosets[GeoID].Faces,1);
   w.Geosets[GeoID].Faces[0]:=nil;
  end;//of if

  //3. �������� � ����������� ��������� �����������
  len:=length(w.Geosets[GeoID].Faces[0]);
  SetLength(w.Geosets[GeoID].Faces[0],len+3);
  w.Geosets[GeoID].Faces[0,len]  :=fc^[i*3];
  w.Geosets[GeoID].Faces[0,len+1]:=fc^[i*3+1];
  w.Geosets[GeoID].Faces[0,len+2]:=fc^[i*3+2];
 end;//of for i
End;
//-------------------------------------------------------
//���������������: �� ��������� �������� ������������
//��������� ������� ������ ������ (Vertices, Normals, TVertices)
//��� ������ �����������.
procedure WMOFormVerticesData(var w:TWMO;vt:PMOVT;mr:PMONR;tvt:PMOTV;
                              OldGeoCount,gHierID:integer);
Var b:array of boolean;
    i,ii,j,len,ind:integer;
Begin
 for i:=OldGeoCount to w.CountOfGeosets-1 do begin
  len:=length(w.Geosets[i].Faces[0]);
  SetLength(b,len);               //��������� ������
  FillChar(b[0],len*sizeof(boolean),true);        //��������� ��������� true

  //������������������ � ������������� ����������� ������ ������
  w.Geosets[i].CountOfVertices:=0;
  w.Geosets[i].CountOfCoords:=1;  //1 ���������� ���������
  SetLength(w.Geosets[i].Crds,1); //�������� ��� �� ������
  for ii:=0 to len-1 do if b[ii] then with w.Geosets[i] do begin
   inc(CountOfVertices);          //��������� ���-�� ������ �� 1
   SetLength(Vertices,CountOfVertices);
   SetLength(Normals,CountOfVertices);
   SetLength(Crds[0].TVertices,CountOfVertices);
   ind:=Faces[0,ii];              //������ ������ ������� � WMO
   //������ ���������� �������
   Vertices[CountOfVertices-1,1]:=vt^[ind*3]*wowmult;
   Vertices[CountOfVertices-1,2]:=vt^[ind*3+1]*wowmult; 
   Vertices[CountOfVertices-1,3]:=vt^[ind*3+2]*wowmult;
   //������ ���������� �������
   Normals[CountOfVertices-1,1]:=mr^[ind*3];
   Normals[CountOfVertices-1,2]:=mr^[ind*3+1];
   Normals[CountOfVertices-1,3]:=mr^[ind*3+2];
   //������ ���������� ���������� ������
   Crds[0].TVertices[CountOfVertices-1,1]:=tvt^[ind*2];
   Crds[0].TVertices[CountOfVertices-1,2]:=tvt^[ind*2+1];
   //�������� ������� �������������
   for j:=0 to len-1 do if b[j] and (Faces[0,j]=ind) then begin
    Faces[0,j]:=CountOfVertices-1;
    b[j]:=false;                  //��� ����������
   end;//of with/if/for j   
  end;//of if/for ii

  //������������ �������������� ���� �����������
  with w.Geosets[i] do begin
   CountOfNormals:=CountOfVertices;
   Crds[0].CountOfTVertices:=CountOfVertices;
   SetLength(VertexGroup,CountOfVertices);
   FillChar(VertexGroup[0],CountOfVertices*4,0);
   SetLength(Groups,1);
   SetLength(Groups[0],1);
   Groups[0,0]:=0;
   SelectionGroup:=0;
   Unselectable:=false;
   CountOfMatrices:=1;
   HierID:=gHierID;
  end;//of with

 end;//of for i
End;
//-------------------------------------------------------
//��������� ��� ������ �� TWMO � ���������� ���������� ������
procedure WMOToModel(w:TWMO);
Begin
 Textures:=w.Textures;
 TextureAnims:=w.TextureAnims;
 Materials:=w.Materials;
 Geosets:=w.Geosets;
 Sequences:=w.Sequences;
 GlobalSequences:=w.GlobalSequences;
 GeosetAnims:=w.GeosetAnims;
 Bones:=w.Bones;
 Helpers:=w.Helpers;
 Attachments:=w.Attachments;
 PivotPoints:=w.PivotPoints;
 ParticleEmitters1:=w.ParticleEmitters1;
 pre2:=w.pre2;
 Ribs:=w.Ribs;
 Events:=w.Events;
 Cameras:=w.Cameras;
 Collisions:=w.Collisions;
 CountOfTextures:=w.CountOfTextures;
 CountOfMaterials:=w.CountOfMaterials;
 CountOfPivotPoints:=w.CountOfPivotPoints;
 CountOfTextureAnims:=w.CountOfTextureAnims;
 CountOfGeosets:=w.CountOfGeosets;
 CountOfGeosetAnims:=w.CountOfGeosetAnims;
 CountOfLights:=w.CountOfLights;
 CountOfHelpers:=w.CountOfHelpers;
 CountOfBones:=w.CountOfBones;
 CountOfAttachments:=w.CountOfAttachments;
 CountOfParticleEmitters1:=w.CountOfParticleEmitters1;
 CountOfParticleEmitters:=w.CountOfParticleEmitters;
 CountOfRibbonEmitters:=w.CountOfRibbonEmitters;
 CountOfEvents:=w.CountOfEvents;
 CountOfCameras:=w.CountOfCameras;
 CountOfCollisionShapes:=w.CountOfCollisionShapes;
 BlendTime:=w.BlendTime;
 CountOfSequences:=w.CountOfSequences;
 CountOfGlobalSequences:=w.CountOfGlobalSequences;
 AnimBounds:=w.AnimBounds;
 Lights:=w.Lights;
 Controllers:=w.Controllers;
 ModelName:=w.ModelName;
End;
//-------------------------------------------------------
//��������� � W ����������, ��������� �� ���������� GroupWMO.
//W �������������� ���������������� �� Root WMO
//��� ������ ��� ����� ����������� � err � ��������� ������� ������
procedure OpenGroupWMO(var w:TWMO;fname:string;var err:string;gHierID:integer);
Var {i,}itmp,tagLength,tagNext,CountOfTriangles,
    coLights,coDoodads,OldGeoCount:integer;
    s:string;tmp:PChar; pt:pointer;
    IsLights,IsDoodads:boolean;
    mt:PMOPY; fc,li,di:PMOVI; vt:PMOVT; nr:PMONR; tvt:PMOTV;
Begin
 //���������, ���������� �� ��������� WMO--����
 if SearchPath(nil,PChar(fname),nil,0,nil,tmp)=0 then begin
  err:=err+#13#10+fname;          //��������� ������ �� ��������� ������
  exit;
 end;//of if

 //������� ��� � ������
 assignFile(f,fname);
 reset(f,1);                      //���������� ������
 GetMem(w.pGroup,FileSize(f)+8);   //�������� � ��������
 BlockRead(f,w.pGroup^,FileSize(f));
 CloseFile(f);
 p:=w.pGroup;
 pp:=integer(p);

 //����, ��������� ���� ������. �������� ��� ���.
 s:=ReadASCII(4);                 //������ MagID ���������
 if s<>'REVM' then begin          //������: ��� �� WMO-������
  err:=err+#13#10+fname+' [�������� ������]';
  FreeMem(w.pGroup);
  exit;
 end;//of if

 pp:=pp+8;                        //�� ������ ���
 s:=ReadASCII(4);
 if s<>'PGOM' then begin
  err:=err+#13#10+fname+' [�������� ������]';
  FreeMem(w.pGroup);
  exit;
 end;//of if

 //������ �����.
 //2. ������ ���� MOGP:
 pp:=pp+4;                        //������� �����
 tagLength:=68;                   //����� ������ ���������
 tagNext:=pp+tagLength;           //����� ���������� ����
 pp:=pp+8;                        //������� ��� �����
 itmp:=ReadLong;                  //������ ������
 IsLights:=(itmp and $200)<>0;
 IsDoodads:=(itmp and $800)<>0;

 //3. ��������� ���������� �� ������ ���������.
 //a. ��������� �������������
 pp:=tagNext;
 if not GetTAGPointer('YPOM',tagLength,pt) then begin
  FreeMem(w.pRoot);
  exit;
 end;//of if
 mt:=pt;
 CountOfTriangles:=tagLength shr 1; //���-�� ������������� � ������

 //�. ������� ������ � �������������
 if not GetTAGPointer('IVOM',tagLength,pt) then begin
  FreeMem(w.pGroup);
  exit;
 end;//of if
 fc:=pt;

 //�. ������ ������
 if not GetTAGPointer('TVOM',tagLength,pt) then begin
  FreeMem(w.pGroup);
  exit;
 end;//of if
 vt:=pt;

 //�. �������
 if not GetTAGPointer('RNOM',tagLength,pt) then begin
  FreeMem(w.pGroup);
  exit;
 end;//of if
 nr:=pt;

 //�. ���������� ����������
 if not GetTAGPointer('VTOM',tagLength,pt) then begin
  FreeMem(w.pGroup);
  exit;
 end;//of if
 tvt:=pt;

 //�. ������ ���� ����������
 s:=ReadASCII(4);                 //��������� ����
 tagLength:=ReadLong;             //��� �����
 if s='ABOM' then pp:=pp+tagLength
             else pp:=pp-8;       //������� � ����

 //�. ������� ���������� ����� (���� ����):
 coLights:=0;
 if IsLights then begin           //���� ��� ����������
  if not GetTAGPointer('RLOM',tagLength,pt) then begin
   FreeMem(w.pGroup);
   exit;
  end;//of if
  li:=pt;
  coLights:=tagLength shr 1;      //���-�� ���������� �����
 end;//of if (IsLights)

 //�. ������� ��������� (���� ����):
 coDoodads:=0;
 if IsDoodads then begin
  if not GetTAGPointer('RDOM',tagLength,pt) then begin
   FreeMem(w.pGroup);
   exit;
  end;//of if
  di:=pt;
  coDoodads:=tagLength shr 1;     //���-�� ���������
 end;//of if (IsDoodads)

 //4. ������ ���������� WMO-��������� (�������� �� �����������)
 OldGeoCount:=w.CountOfGeosets;
 WMOFormGeosetFaces(w,mt,fc,CountOfTriangles); //������� �� ������������
 WMOFormVerticesData(w,vt,nr,tvt,OldGeoCount,gHierID);//������� ������ ������

 FreeMem(w.pGroup);               //���������� ������
 //debug: ����������� � ������
// WMOToModel(w);                   //��������� ������ TWMO � �������� ������
End;
//-------------------------------------------------------
//������ ��������� ���-�� ���������� ����� �� Root WMO.
//pp ������ ���� �������� �� ������ ������
procedure WMOReadLights(var w:TWMO;coLights:integer;var LastObjID:integer);
Var i,tmp:integer;ftmp:GLFloat;
const C_DV=1/255;
Begin
 if coLights=0 then exit;
 w.CountOfLights:=coLights;
 SetLength(w.Lights,coLights);
 i:=0;
 repeat with w.Lights[i] do begin
  //1. ������ � ����������� ��� ���������
  tmp:=ReadByte;                  //������
  case tmp of
   0:LightType:=Omnidirectional;
   2:LightType:=Directional;
   3:LightType:=Ambient;
   else begin                     //�������� ��������, ����������
    pp:=pp+47;
    dec(w.CountOfLights);
   end;
  end;
  pp:=pp+3;                       //������� ����� ����

  //2. ������ ����� ���������
  Color[1]:=ReadByte*C_DV;
  Color[2]:=ReadByte*C_DV;
  Color[3]:=ReadByte*C_DV;
  ftmp:=ReadByte*C_DV;
  Color[1]:=Color[1]*ftmp;
  Color[2]:=Color[2]*ftmp;
  Color[3]:=Color[3]*ftmp;

  //3. ������ ������� ��������� ����� � ��������� ��� "������"
  inc(w.CountOfPivotPoints);
  SetLength(w.PivotPoints,w.CountOfPivotPoints);
  w.PivotPoints[LastObjID,1]:=ReadFloat*wowmult;
  w.PivotPoints[LastObjID,2]:=ReadFloat*wowmult;
  w.PivotPoints[LastObjID,3]:=ReadFloat*wowmult;
  FillChar(Skel,sizeof(TBone),0);
  Skel.Name:='Light'+inttostr(i);
  Skel.ObjectID:=LastObjID;
  Skel.GeosetID:=-1;
  Skel.GeosetAnimID:=-1;
  Skel.Parent:=-1;
  Skel.Translation:=-1;
  Skel.Rotation:=-1;
  Skel.Scaling:=-1;
  Skel.Visibility:=-1;
  inc(LastObjID);

  //4. ������ ��� ��� ���������� ��������� �����
  Intensity:=ReadFloat;
  AttenuationStart:=ReadFloat*wowmult;
  AttenuationEnd:=ReadFloat*wowmult;

  pp:=pp+4*4;                     //������� �����

  //5. ����������� ���������� ���������� ���������
  AmbIntensity:=0;
  AmbColor[1]:=1; AmbColor[2]:=1; AmbColor[3]:=1;
  IsASStatic:=true;
  IsAEStatic:=true;
  IsIStatic:=true;
  IsCStatic:=true;
  IsAIStatic:=true;
  IsACStatic:=true;

  inc(i);
 end; until i=w.CountOfLights;
 SetLength(w.Lights,w.CountOfLights);//������������� ������� �������
End;
//-------------------------------------------------------
//���������������: ������������ �������������� �������
//(���������������, �������, �������)
procedure TransformVertex(var v:TVertex;rot:TRotMatrix;sc:GLFloat;ps:TVertex);
Var vx,vy,vz:GLFloat;
Begin
 v[1]:=v[1]*sc;                   //���������������
 v[2]:=v[2]*sc;
 v[3]:=v[3]*sc;

 //�������
 vx:=v[1]*rot[0,0]+v[2]*rot[1,0]+v[3]*rot[2,0];
 vy:=v[1]*rot[0,1]+v[2]*rot[1,1]+v[3]*rot[2,1];
 vz:=v[1]*rot[0,2]+v[2]*rot[1,2]+v[3]*rot[2,2];

 //�������
 v[1]:=vx+ps[1];
 v[2]:=vy+ps[2];
 v[3]:=vz+ps[3];
End;
//-------------------------------------------------------
//���������������: �������� ����� ����������� ���, �����
//�������� ���������� � 0 (��� ����������� ���������� ����.)
procedure GlobalizeController(c:TController);
Var i,len,sb:integer;
Begin
 len:=High(c.Items);
 sb:=c.Items[0].Frame;
 for i:=0 to len do c.Items[i].Frame:=c.Items[i].Frame-sb;
End;
//-------------------------------------------------------
//��������� ���������/��������� �� ������� �������� ������
//� TWMO. rot - ������� ��������
//ps - ������� (����� "0") ��� ������������� ���������
//sc - ������ ��������
procedure WMOAddFromModel(var w:TWMO;rot:TRotMatrix;ps:TVertex;sc:GLFLoat;
                          HierID:integer;var LastObjID:integer);
Var i,ii,coTextures,coMaterials,coTexAnims,coGeosets,
    coControllers,coLights,coEmitters,coGeosetAnims,
    FrameMax,FrNum,len,len2:integer;
Begin
 coTextures:=w.CountOfTextures;
 coMaterials:=w.CountOfMaterials;
 coTexAnims:=w.CountOfTextureAnims;
 coGeosets:=w.CountOfGeosets;
 coLights:=w.CountOfLights;
 coEmitters:=w.CountOfParticleEmitters;
 coGeosetAnims:=w.CountOfGeosetAnims;
 coControllers:=length(w.Controllers);
 //1. �������� ������� ��������
 w.CountOfTextures:=w.CountOfTextures+CountOfTextures;
 w.CountOfMaterials:=w.CountOfMaterials+CountOfMaterials;
 w.CountOfGeosets:=w.CountOfGeosets+CountOfGeosets;
 w.CountOfTextureAnims:=w.CountOfTextureAnims+CountOfTextureAnims;
// w.CountOfLights:=w.CountOfLights+CountOfLights;
// w.CountOfParticleEmitters:=w.CountOfParticleEmitters+CountOfParticleEmitters;
 w.CountOfGeosetAnims:=w.CountOfGeosetAnims+CountOfGeosetAnims;
 SetLength(w.Textures,w.CountOfTextures);
 SetLength(w.Materials,w.CountOfMaterials);
 SetLength(w.TextureAnims,w.CountOfTextureAnims);
 SetLength(w.Geosets,w.CountOfGeosets);
 SetLength(w.GeosetAnims,w.CountOfGeosetAnims);
// SetLength(w.Lights,w.CountOfLights);
// SetLength(w.pre2,w.CountOfParticleEmitters);

 //2. ��������� ������� (�������� � ���������)
 for i:=coTextures to w.CountOfTextures-1
 do w.Textures[i]:=Textures[i-coTextures];
 
 for i:=coMaterials to w.CountOfMaterials-1 do begin
  w.Materials[i]:=Materials[i-coMaterials];
  FillChar(Materials[i-coMaterials],sizeof(TMaterial),0);
  for ii:=0 to w.Materials[i].CountOfLayers-1
  do with w.Materials[i].Layers[ii] do begin
   //���������� ������������� ��������� � �����������
   if not IsTextureStatic then begin
    TextureID:=round(Controllers[NumOfTexGraph].Items[0].Data[1]);
    IsTextureStatic:=true;
   end;//of if
   if not IsAlphaStatic then begin
    Alpha:=1;
    IsAlphaStatic:=true;
   end;//of if
   TextureID:=TextureID+coTextures;
   TVertexAnimID:=TVertexAnimID+coTexAnims;
  end;//of with/for
 end;//of for i

 //3. ��������� ���������� �������� (���� ������� ����):
 for i:=coTexAnims to w.CountOfTextureAnims-1 do begin
  w.TextureAnims[i]:=TextureAnims[i-coTexAnims];
  FrameMax:=0;                    //���� ��� ������
  //������ �������� ����������� � ������ ����. ������������������
  if w.TextureAnims[i].TranslationGraphNum>=0 then begin
   len:=length(w.Controllers)+1;
   SetLength(w.Controllers,len);
   cpyController(Controllers[w.TextureAnims[i].TranslationGraphNum],
                 w.Controllers[len-1]);
   GlobalizeController(w.Controllers[len-1]);
   FrNum:=w.Controllers[len-1].Items[High(w.Controllers[len-1].Items)].Frame;
   w.Controllers[len-1].GlobalSeqId:=w.CountOfGlobalSequences;
   if FrNum>FrameMax then FrameMax:=FrNum;
   w.TextureAnims[i].TranslationGraphNum:=len-1;
  end;//of if(Translation)
  if w.TextureAnims[i].RotationGraphNum>=0 then begin
   len:=length(w.Controllers)+1;
   SetLength(w.Controllers,len);
   cpyController(Controllers[w.TextureAnims[i].RotationGraphNum],
                 w.Controllers[len-1]);
   GlobalizeController(w.Controllers[len-1]);
   FrNum:=w.Controllers[len-1].Items[High(w.Controllers[len-1].Items)].Frame;
   w.Controllers[len-1].GlobalSeqId:=w.CountOfGlobalSequences;
   if FrNum>FrameMax then FrameMax:=FrNum;
   w.TextureAnims[i].RotationGraphNum:=len-1;
  end;//of if(Rotation)
  if w.TextureAnims[i].ScalingGraphNum>=0 then begin
   len:=length(w.Controllers)+1;
   SetLength(w.Controllers,len);
   cpyController(Controllers[w.TextureAnims[i].ScalingGraphNum],
                 w.Controllers[len-1]);
   GlobalizeController(w.Controllers[len-1]);
   FrNum:=w.Controllers[len-1].Items[High(w.Controllers[len-1].Items)].Frame;
   w.Controllers[len-1].GlobalSeqId:=w.CountOfGlobalSequences;
   if FrNum>FrameMax then FrameMax:=FrNum;
   w.TextureAnims[i].ScalingGraphNum:=len-1;
  end;//of if(Scaling)

  //������ ������ ���������� ������������������
  inc(w.CountOfGlobalSequences);
  SetLength(w.GlobalSequences,w.CountOfGlobalSequences);
  w.GlobalSequences[w.CountOfGlobalSequences-1]:=FrameMax;
 end;//of for i

 //4. �������� ����������� (��������)
 for i:=coGeosets to w.CountOfGeosets-1 do begin
  w.Geosets[i]:=Geosets[i-coGeosets];
  FillChar(Geosets[i-coGeosets],SizeOf(TGeoset),0);
  for ii:=0 to w.Geosets[i].CountOfVertices-1 do begin
   TransformVertex(w.Geosets[i].Vertices[ii],rot,sc,ps);
//   TransformVertex(w.Geosets[i].Normals[ii],rot,sc,ps);
  end;//of for ii
  w.Geosets[i].MaterialID:=w.Geosets[i].MaterialID+coMaterials;
  w.Geosets[i].HierID:=HierID;
 end;//of for i

 //�������� ��������� ����� � ������
 //(���� �� �����������)
{ w.CountOfPivotPoints:=w.CountOfPivotPoints+CountOfLights+
                       CountOfParticleEmitters;
 SetLength(w.PivotPoints,w.CountOfPivotPoints);
 for i:=coLights to w.CountOfLights-1 do begin
  w.Lights[i]:=Lights[i-coLights];
  w.Lights[i].Skel.Name:='Light_'+inttostr(i);
  w.Lights[i]
 end;//of for i}

 //�������� �������� ���������
 for i:=coGeosetAnims to w.CountOfGeosetAnims-1 do begin
  w.GeosetAnims[i]:=GeosetAnims[i-coGeosetAnims];
  w.GeosetAnims[i].GeosetID:=i;
  if not w.GeosetAnims[i].IsAlphaStatic then begin
   w.GeosetAnims[i].Alpha:=1;
   w.GeosetAnims[i].IsAlphaStatic:=true;
   w.GeosetAnims[i].AlphaGraphNum:=-1;
  end;//of if (AlphaStatic)
  if not w.GeosetAnims[i].IsColorStatic then begin
   w.GeosetAnims[i].Color[1]:=
     Controllers[w.GeosetAnims[i].ColorGraphNum].Items[0].Data[1];
   w.GeosetAnims[i].Color[2]:=
     Controllers[w.GeosetAnims[i].ColorGraphNum].Items[0].Data[2];
   w.GeosetAnims[i].Color[3]:=
     Controllers[w.GeosetAnims[i].ColorGraphNum].Items[0].Data[3];
   w.GeosetAnims[i].IsColorStatic:=true;
   w.GeosetAnims[i].ColorGraphNum:=-1;  
  end;//of if
 end;//of for i
End;
//-------------------------------------------------------
//��������� wmo-����� (������ RootWMO).
//�������� ������� ��� OpenGroupWMO.
//�������� ��� ����� ��� ���������� ����� ��������.
//� ������ ������ ���������� ������ ������.
//���� ���� �����-�� ������/��������������,
//�����. �� �����.
function OpenWMO(fname:string):string;
type TDoodad=record               //��� ������� ��� �������� �������������� ���.
 Name,ShortName:string;
 Position:TVertex;
 Orient:TRotMatrix;
 Scale:GLFloat;
end;//of type
Var w:TWMO;s,s2,fnf,sTextures,sDoodads,fpath:string;
    cTmp:PChar;
    coTextures,coGroups,coLights,coModels,coDoodads,coSets,
    i,ii,j,tmp,tmp2,tagNext,tagLength,LastObjID:integer;
    ptmp:pointer;
    q:TQuaternion;
    Min,Max:TVertex;              //��� ������� ������ ������
    br:GlFloat;                   //��������� ������
    matColors:array of TVertex;   //����� ���������� (RGB)
    matAlpha:array of GLFloat;    //������������ ���.
    ddata:array of TDoodad;       //������ � ����������
Begin
 Result:='';                      //���� �� ���������

 //1. ������ �����, ������� ����
 assignFile(f,fname);
 reset(f,1);                      //���������� ������
 //2. �������� ������ ��� ����
 GetMem(p,FileSize(f)+8);         //�������� � ��������
 //3. �������� ���� ���� � ������
 BlockRead(f,p^,FileSize(f));
 //4. ������� ����
 CloseFile(f);
// Controllers:=nil;
 FileContent:='';   //���� ���������� ���
 //�������������� �������������:
//------------------���������� ������----------
 LastObjID:=0;                    //��� ��������
 FillChar(w,SizeOf(w),0);         //���������� ���� WMO
 w.pRoot:=p;                      //��������� �� Root
 pp:=integer(p);                  //�������� �����
 w.ppRoot:=pp;                    //��� ���� ����������
 //1. ��������, ������������� �� ��� ������ WoW-WMO-Root:
 s:=ReadASCII(4);                 //������ MagID ���������
 if s<>'REVM' then begin          //������: ��� �� WMO-������
  FreeMem(p);
  MessageBox(0,'�������� ������ ������',scError,mb_iconstop);
  exit;
 end;//of if

 //2. ���������� ��� ������
 pp:=pp+8;                        //�� ������ ���
 s:=ReadASCII(4);
 if s<>'DHOM' then begin          //�� Root-WMO
  FreeMem(p);
  MessageBox(0,'�������� ������ ������ (Group WMO)',scError,mb_iconstop);
  exit;
 end;//of if
 tmp:=ReadLong;                   //������� �����
 tagNext:=pp+64;                  //��������� �� ��������� ���

 //3. ������ ��������� (��� MOHD)
 coTextures:=ReadLong;            //��������
 coGroups:=ReadLong;
 pp:=pp+4;                        //������� ��������
 coLights:=ReadLong;
 coModels:=ReadLong;
 coDoodads:=ReadLong;
 coSets:=ReadLong;

 //4. ����������� ������ ������� � ������ ������
 pp:=tagNext;
 if not GetTAGPointer('XTOM',tagLength,ptmp) then begin
  FreeMem(w.pRoot);
  exit;
 end;//of if
 SetLength(sTextures,tagLength);
 Move(ptmp^,sTextures[1],tagLength); //�����������

 //5. ��������� ������ ������� � ����������
 s:=ReadASCII(4);                 //������ ��������� ���
 if s<>'TMOM' then begin
  MessageBox(0,'������ ������ ����� WMO.'#13#10+
               '�������� ��� ������ ������������ MdlVis.','������',MB_ICONSTOP);
  FreeMem(w.pRoot);
  exit;             
 end;//of if
 tagLength:=ReadLong;
 tagNext:=pp+tagLength;
 w.CountOfTextures:=coTextures;
 w.CountOfMaterials:=coTextures;
 SetLength(w.Textures,coTextures);
 SetLength(w.Materials,coTextures);
 SetLength(matColors,coTextures+1); //+��������� ����� ����
 SetLength(matAlpha,coTextures+1);    //+��������� Alpha=1
 for i:=0 to coTextures-1 do begin //������ 64-������� ������
  FillChar(w.Materials[i],sizeof(TMaterial),0);
  w.Materials[i].PriorityPlane:=-1;
  w.Materials[i].CountOfLayers:=1;
  SetLength(w.Materials[i].Layers,1);
  FillChar(w.Materials[i].Layers[0],SizeOf(TLayer),0);
  w.Materials[i].IsConstantColor:=true;
  with w.Materials[i].Layers[0] do begin
   tmp:=ReadLong;                 //������ �����
   IsTwoSided:=(tmp and 4)<>0;
   IsUnshaded:=(tmp and $10)<>0;
   pp:=pp+4;                      //������� ���� (???)
   tmp:=ReadLong;                 //������ ����� ��������
   if tmp=0 then FilterMode:=Opaque else FilterMode:=Transparent;
   //������ ������� ���������� ���
   tmp:=ReadLong;
   pp:=pp+8;
   tmp2:=ReadLong;
   FillChar(w.Textures[i],sizeof(TTexture),0);
   w.Textures[i].ReplaceableID:=0;
   w.Textures[i].FileName:=copy(sTextures,tmp+1,tmp2-tmp+1);
   //������� ������� ������� �� ����������� �����
   while pos(#0,w.Textures[i].FileName)<>0
   do Delete(w.Textures[i].FileName,pos(#0,w.Textures[i].FileName),1);
   w.Textures[i].IsWrapWidth:=true;
   w.Textures[i].IsWrapHeight:=true;
   //������ ����� ���������
   matColors[i,1]:=ReadByte/255;
   matColors[i,2]:=ReadByte/255;
   matColors[i,3]:=ReadByte/255;
   matAlpha[i]:=ReadByte/255;
   //��������������� ����
   TextureID:=i;
   IsTextureStatic:=true;
   Alpha:=1.0;
   IsAlphaStatic:=true;
   NumOfGraph:=-1;
   NumOfTexGraph:=-1;
   TVertexAnimID:=-1;
   CoordID:=-1;
  end;//of with
  pp:=pp+$20;
 end;//of for i
 //��������� ���������� ������/����������
 matColors[coTextures,1]:=1;
 matColors[coTextures,2]:=1;
 matColors[coTextures,3]:=1;
 matAlpha[coTextures]:=1;

 //������� ���� ������������ �����
 repeat                           //���� ��������
  pp:=tagNext;
  s:=ReadASCII(4);                //������ ��� ����
  tagLength:=ReadLong;
  tagNext:=pp+tagLength;
 until (s='TLOM') or (s='NDOM') or (s='DDOM') or
       (s='GOFM') or (s='PVCM');

 //������� root-����� (��� ������������ ��������� ���� ������������)
 LastObjID:=1;                    //0 ��� �����
 w.CountOfPivotPoints:=1;
 SetLength(w.PivotPoints,1);      //1 �����
 FillChar(w.PivotPoints[0],sizeof(TVertex),0);
 w.CountOfBones:=1;
 SetLength(w.Bones,1);
 FillChar(w.Bones[0],SizeOf(TBone),0);
 w.Bones[0].Name:='bone_root';
 w.Bones[0].GeosetID:=Multiple;
 w.Bones[0].GeosetAnimID:=None;
 w.Bones[0].Parent:=-1;
 w.Bones[0].Translation:=-1;
 w.Bones[0].Rotation:=-1;
 w.Bones[0].Scaling:=-1;
 w.Bones[0].Visibility:=-1;

 //������ ��������� ����� (���� ��� ����)
 if s='TLOM' then begin
  WMOReadLights(w,coLights,LastObjID);
  pp:=tagNext;
  s:=ReadASCII(4);
  tagLength:=ReadLong;
  tagNext:=pp+tagLength;
 end;//of if
 if s='SDOM' then begin           //������� ������� ���������
  pp:=tagNext;
//  s:=ReadASCII(4);
//  tagLength:=ReadLong;
//  tagNext:=pp+tagLength;
 end;//of if

 if coDoodads<>0 then begin       //������ ����, ���� ���� ���������
  //�������� (���� ��������) ����� M2 � ������ ������
  if not GetTAGPointer('NDOM',tagLength,ptmp) then begin
   FreeMem(w.pRoot);
   exit;
  end;//of if
  SetLength(sDoodads,tagLength);
  Move(ptmp^,sDoodads[1],tagLength); //�����������

  //������ ������ � ������ ���������
  if not GetTAGPointer('DDOM',tagLength,ptmp) then begin
   FreeMem(w.pRoot);
   exit;
  end;//of if
  //������, ��� � ���� ��������� ������ ��������� ����� ���� ������,
  //��� ������� � ���������:
  if (tagLength div 40)<coDoodads then coDoodads:=tagLength div 40;
  //�������� ������ ��� ������
  SetLength(ddata,coDoodads);
  pp:=integer(ptmp);
  for i:=0 to coDoodads-1 do with ddata[i] do begin //���� ������ ������
   tmp:=ReadLong;                 //�������� ����� ������
   Name:='';
   while (tmp<length(sDoodads)) and (sDoodads[tmp+1]<>'.') do begin
    Name:=Name+sDoodads[tmp+1];
    inc(tmp);
   end;//of while
   Name:=Name+'.m2';
   ShortName:=Name;
   while pos('\',ShortName)<>0 do Delete(ShortName,1,pos('\',ShortName));

   for ii:=1 to 3 do Position[ii]:=ReadFloat*wowmult; //�������
//   q.w:=ReadFloat;
   q.x:=ReadFloat;
   q.y:=ReadFloat;
   q.z:=ReadFloat;
   q.w:=ReadFloat;
   QuaternionToMatrix(q,Orient);
   Scale:=ReadFloat;
   pp:=pp+4;                      //������� ���������
  end;//of with/for i
 end;//of if (coDoodads<>0)

 //���������� ��������� ���� GroupWMO:
 w.ppSV:=pp;                      //�������� ��������� (debug)
 fnf:='';                         //���� ��� �� ��������� ������
 for i:=0 to coGroups-1 do begin
  //��������� �������� �����
  s:=inttostr(i);
  while length(s)<3 do s:='0'+s;
  s:='_'+s;
  s2:=fname;
  insert(s,s2,length(s2)-3);      //���_XXX.wmo
  OpenGroupWMO(w,s2,fnf,-i-10);   //������ ���� ����
 end;//of for i

 //�������, ��� ��� �� ����. �����������.
 //����������� � ����� ���������� ����� �������
 //(�������� �������� - ��������, ������������� ��� ��������� �����).
 //��� �� �����, ���� ���� �������� ������ ���������
 //���� �� ������ (����������������)
 i:=0;
 while i<w.CountOfGeosets do begin
  if w.Geosets[i].MaterialID=255 then begin
   for ii:=i to w.CountOfGeosets-2 do w.Geosets[ii]:=w.Geosets[ii+1];
   dec(w.CountOfGeosets);
   SetLength(w.Geosets,w.CountOfGeosets);
   continue;
  end;//of if
  inc(i);
 end;//of while


{ //�������, ��� ��� � ����������� - ��� �� "�����������"
 for i:=0 to w.CountOfGeosets-1 do if w.Geosets[i].MaterialID=255 then begin
  //������� �������������� ��������
  inc(w.CountOfTextures);
  SetLength(w.Textures,w.CountOfTextures);
  w.Textures[coTextures].FileName:=
                        'ReplaceableTextures\TeamColor\TeamColor08.blp';
  w.Textures[coTextures].ReplaceableID:=0;
  w.Textures[coTextures].IsWrapWidth:=true;
  w.Textures[coTextures].IsWrapHeight:=true;
  //������� �������������� ��������
  inc(w.CountOfMaterials);
  SetLength(w.Materials,w.CountOfMaterials);
  with w.Materials[coTextures] do begin
   IsConstantColor:=true;
   IsSortPrimsFarZ:=false;
   IsFullResolution:=false;
   PriorityPlane:=-1;
   CountOfLayers:=1;
   SetLength(Layers,1);
   Layers[0].FilterMode:=Additive;
   Layers[0].IsUnshaded:=true;
   Layers[0].IsTwoSided:=true;
   Layers[0].IsUnfogged:=false;
   Layers[0].IsSphereEnvMap:=false;
   Layers[0].IsNoDepthTest:=false;
   Layers[0].IsNoDepthSet:=false;
   Layers[0].TextureID:=coTextures;
   Layers[0].IsTextureStatic:=true;
   Layers[0].Alpha:=1;
   Layers[0].IsAlphaStatic:=true;
   Layers[0].NumOfGraph:=-1;
   Layers[0].NumOfTexGraph:=-1;
   Layers[0].TVertexAnimID:=-1;
   Layers[0].CoordID:=-1;
   for j:=i to w.CountOfGeosets-1
   do if w.Geosets[j].MaterialID=255 then w.Geosets[j].MaterialID:=coTextures;
  end;//of with
  break;
 end;//of for i}

 //������ �������� ���������
 w.CountOfGeosetAnims:=w.CountOfGeosets;
 SetLength(w.GeosetAnims,w.CountOfGeosetAnims);
 for i:=0 to w.CountOfGeosetAnims-1 do with w.GeosetAnims[i] do begin
  Alpha:=matAlpha[w.Geosets[i].MaterialID];
  Color:=matColors[w.Geosets[i].MaterialID];
  GeosetID:=i;
  IsAlphaStatic:=true;
  IsColorStatic:=true;
  IsDropShadow:=false;
  AlphaGraphNum:=-1;
  ColorGraphNum:=-1;
 end;//of for i

 //������ ��������� ������ ��������� ���� ���������
 for i:=0 to coDoodads-1 do with ddata[i] do begin
  //1. ��������, ���������� �� ������ ����
  fpath:=fname;
  while fpath[length(fpath)]<>'\' do Delete(fpath,length(fpath),1);
  if SearchPath(nil,PChar(fpath+ShortName),nil,0,nil,ctmp)=0 then begin
   fnf:=fnf+#13#10+Name;          //��������� ������ �� ��������� ������
//    exit;
  end else begin                 //���� ����������. �����������!
   OpenM2(fpath+ShortName);      //���������� ��������
   if CountOfGeosets=0 then fnf:=fnf+#13#10+Name+' [������]'
   else WMOAddFromModel(w,ddata[i].Orient,ddata[i].Position,ddata[i].Scale,
                        -i-1010,LastObjID);
  end;//of if (���������� �� ����)
 end;//of for i

 //������ ��������������� �����������
 for i:=0 to w.CountOfGeosets-1 do with w.Geosets[i] do begin
  SetLength(VertexGroup,CountOfVertices);
  FillChar(VertexGroup[0],CountOfVertices*4,0);
  SetLength(Groups,1);
  SetLength(Groups[0],1);
  Groups[0,0]:=0;                 //������������ root-�����
  SetLength(Anims,1);
  CountOfAnims:=1;
  CountOfMatrices:=1;
 end;//of for i

 //������� ������������ �������� Stand
 w.CountOfSequences:=1;
 SetLength(w.Sequences,1);
 with w.Sequences[0] do begin
  Name:='Stand';
  IntervalStart:=10;
  IntervalEnd:=1010;
  Rarity:=-1;
  IsNonLooping:=false;
  MoveSpeed:=-1;
 end;//of with

 //������� �� ��� �������
 SetLength(VisGeosets,w.CountOfGeosets);
 for i:=0 to w.CountOfGeosets-1 do VisGeosets[i]:=true;
 //�������� � ������
 WMOToModel(w);

 //������������ ������� � ��������������� ���� ������
 Min[1]:= 1e6;Min[2]:= 1e6;Min[3]:=1e6;
 Max[1]:=-1e6;Max[2]:=-1e6;Max[3]:=-1e6;
 for i:=0 to CountOfGeosets-1 do with Geosets[i] do begin
  CalcBounds(i,Geosets[i].Anims[0]);
  if Anims[0].MaximumExtent[1]>Max[1] then Max[1]:=Anims[0].MaximumExtent[1];
  if Anims[0].MaximumExtent[2]>Max[2] then Max[2]:=Anims[0].MaximumExtent[2];
  if Anims[0].MaximumExtent[3]>Max[3] then Max[3]:=Anims[0].MaximumExtent[3];
  if Anims[0].MinimumExtent[1]<Min[1] then Min[1]:=Anims[0].MinimumExtent[1];
  if Anims[0].MinimumExtent[2]<Min[2] then Min[2]:=Anims[0].MinimumExtent[2];
  if Anims[0].MinimumExtent[3]<Min[3] then Min[3]:=Anims[0].MinimumExtent[3];
  if Anims[0].MaximumExtent[1]<Min[1] then Min[1]:=Anims[0].MaximumExtent[1];
  if Anims[0].MaximumExtent[2]<Min[2] then Min[2]:=Anims[0].MaximumExtent[2];
  if Anims[0].MaximumExtent[3]<Min[3] then Min[3]:=Anims[0].MaximumExtent[3];
  if Anims[0].MinimumExtent[1]>Max[1] then Max[1]:=Anims[0].MinimumExtent[1];
  if Anims[0].MinimumExtent[2]>Max[2] then Max[2]:=Anims[0].MinimumExtent[2];
  if Anims[0].MinimumExtent[3]>Max[3] then Max[3]:=Anims[0].MinimumExtent[3];
  MinimumExtent:=Anims[0].MinimumExtent;
  MaximumExtent:=Anims[0].MaximumExtent;
  BoundsRadius:=Anims[0].BoundsRadius;
  ReCalcNormals(i+1);
 end;//of for i
 AnimBounds.MinimumExtent:=Min;
 AnimBounds.MaximumExtent:=Max;
 AnimBounds.BoundsRadius:=sqrt(sqr(Max[1]-Min[1])+sqr(Max[2]-Min[2])+
                          sqr(Max[3]-Min[3]))*0.5;
 Sequences[0].Bounds:=AnimBounds;
 ModelName:=fname;
 while pos('\',ModelName)<>0 do Delete(ModelName,1,pos('\',ModelName));
 ModelName[pos('.',ModelName)]:='_';

 //�����������
 ReduceRepTextures;               //������� ����. ��������
 ReduceRepMaterials;              //������� ����. ���������

 //����������� ������
 Freemem(w.pRoot);
 //������������ ��� ��������, ���. �������:
 M2ConvertTextures('__$$$___',fname);

{ if fnf<>'' then MessageBox(0,PChar('�� ������ ����� ��� ���������:'+fnf),
                            '��������:',MB_ICONEXCLAMATION);}
 if fnf<>'' then Result:='�� ������ ����� ��� ���������:'+fnf;
End;
//-------------------------------------------------------
//��������� ���� M2 (������ WoW) � �������� �������������� ���.
//�������� ��� ����� (��� ����������) ����� ��������.
procedure OpenM2(fname:string);
Var i,ii,j,tmp,iofs,coGlobalSequences,ipGlobalSequences,
    coAnims,ipAnims,coBones,ipBones,coVertices,ipVertices,
    coViews,ipViews,coColors,ipColors,coTextures,
    ipTextures,coTransparency,ipTransparency,
    coTexAnims,ipTexAnims,coRenderFlags,ipRenderFlags,
    coTexLookup,ipTexLookup,coTexUnits,ipTexUnits,coTexAnimLookup,
    ipTexAnimLookup,coAtch,ipAtch,coLights,ipLights,coCameras,ipCameras,
    coRibbons,ipRibbons,coParticles,ipParticles:integer;
    s:string;
    svnum,vnum,tnum,tcount,bn1,bn2,bn3,bn4,pp2:integer;
    CountOfSubmeshes,CurID:integer;
    CurSubmesh:TSubmesh;          //��� ���������� �����������
    submeshes:array of TSubMesh;  //������ ���������������
    tmpGeo:TGeoset;tmpGA:TGeosetAnim;
Begin
 IsWoW:=true;
 //1. ������� ���� ������:
 assignFile(f,fname);
 reset(f,1);                      //���������� ������
 //2. �������� ������ ��� ����
 GetMem(p,FileSize(f)+8);         //�������� � ��������
 //3. �������� ���� ���� � ������
 BlockRead(f,p^,FileSize(f));
 //4. ������� ����
 CloseFile(f);
 Controllers:=nil;
 FileContent:='';   //���� ���������� ���
 //�������������� �������������:
 CountOfTextures:=0;
 CountOfMaterials:=0;
 CountOfPivotPoints:=0;
 CountOfTextureAnims:=0;
 CountOfGeosets:=0;
 CountOfGeosetAnims:=0;
 CountOfLights:=0;
 CountOfHelpers:=0;
 CountOfBones:=0;
 CountOfAttachments:=0;
 CountOfParticleEmitters1:=0;
 CountOfParticleEmitters:=0;
 CountOfRibbonEmitters:=0;
 CountOfEvents:=0;
 CountOfCameras:=0;
 CountOfCollisionShapes:=0;
//------------------���������� ������----------
 pp:=integer(p);                  //�������� �����
 //1. ��������, ������������� �� ��� ������ WoW:
 s:=ReadASCII(4);                 //������ MagID ���������
 if s<>'MD20' then begin          //������: ��� �� WoW-������
  //CountOfGeosets:=0;
  if p<>nil then Freemem(p);
  MessageBox(0,'�������� ������ ������',scError,mb_iconstop);
  exit;
 end;//of if

 //2. ������ ����������. ������ � ���:
 Version:=ReadLong;               //������ ������� M2
// pp:=integer(p)+$4;               //�������� �����
 tmp:=ReadLong;                   //������ ����� �����
 iofs:=ReadLong;                  //������ �������� �����
 pp:=integer(p)+iofs;
 ModelName:=ReadASCII(tmp);       //������ ��� ������
 BlendTime:=150;

 //3. ��������� ����������� ���������, ���������
 //�������� � ��������� � ���������
 iofs:=integer(p);                //��� ��������� ���������� ��������
 pp:=iofs+$14;                    //������� ����� ���������
 coGlobalSequences:=ReadLong;     //���-�� ����. �������������������
 ipGlobalSequences:=ReadLong+iofs;//��������
 coAnims:=ReadLong;               //�� � �.�.
 ipAnims:=ReadLong+iofs;
 pp:=pp+4*4;                      //������� 4 �����
 coBones:=ReadLong;
 ipBones:=ReadLong+iofs;
 pp:=pp+2*4;
 coVertices:=ReadLong;
 ipVertices:=ReadLong+iofs;
 coViews:=ReadLong;
 ipViews:=ReadLong+iofs;
 coColors:=ReadLong;
 ipColors:=ReadLong+iofs;
 coTextures:=ReadLong;
 ipTextures:=ReadLong+iofs;
 coTransparency:=ReadLong;
 ipTransparency:=ReadLong+iofs;
 pp:=pp+2*4;
 coTexAnims:=ReadLong;
 ipTexAnims:=ReadLong+iofs;
 pp:=pp+2*4;
 coRenderFlags:=ReadLong;
 ipRenderFlags:=ReadLong+iofs;
 pp:=pp+2*4;
 coTexLookup:=ReadLong;
 ipTexLookup:=ReadLong+iofs;
 coTexUnits:=ReadLong;
 ipTexUnits:=ReadLong+iofs;
 pp:=pp+2*4;
 coTexAnimLookup:=ReadLong;
 ipTexAnimLookup:=ReadLong+iofs;
 pp:=iofs+$104;
 coAtch:=ReadLong;
 ipAtch:=ReadLong+iofs;
 pp:=iofs+$11C;                   //������� �������� �����
 coLights:=ReadLong;
 ipLights:=ReadLong+iofs;
 coCameras:=ReadLong;
 ipCameras:=ReadLong+iofs;
 pp:=pp+2*4;
 coRibbons:=ReadLong;
 ipRibbons:=ReadLong+iofs;
 coParticles:=ReadLong;
 ipParticles:=ReadLong+iofs;

 //������ ������ �������
 M2ReadTextures(coTextures,ipTextures);
 M2ConvertTextures(ModelName,fname);
 M2FindTextures(fname,ModelName); //����� ������� � ��������� �� ���
 CountOfMaterials:=0;
 CountOfGeosetAnims:=0;
 CountOfTextureAnims:=0;
 Controllers:=nil;
 //������ ����� �� ������ ���������� ��������:
 M2ReadTextureAnims(coTexAnims,ipTexAnims);

 //4. ��������� ������ ��������������� (Submeshes).
 CountOfSubmeshes:=0;             //���� ������� ���
 pp:=ipViews;
 for i:=1 to coViews do begin     //��������� ���� "�����"
  CurSubMesh.coIndices:=ReadLong;
  CurSubMesh.ipIndices:=ReadLong+iofs;
  CurSubMesh.coFaces:=ReadLong;
  CurSubMesh.ipFaces:=ReadLong+iofs;
  pp:=pp+2*4;                     //������� ����
  tmp:=ReadLong;                  //������ ���-�� ���������������
  //�������� ��� ��� ��c��
  CountOfSubmeshes:=CountOfSubmeshes+tmp;
  SetLength(Submeshes,CountOfSubmeshes);
  CurSubMesh.ipMesh:=ReadLong+iofs;//�������� ������ ��������������
  CurSubMesh.id:=0;
  CurSubMesh.coTexs:=ReadLong;
  CurSubMesh.ipTexs:=ReadLong+iofs;
  for ii:=tmp downto 1 do begin //��������� ������ ���������������
   Submeshes[CountOfSubmeshes-ii]:=CurSubMesh;
   if Version>=$104 then CurSubMesh.ipMesh:=CurSubMesh.ipMesh+48
   else CurSubMesh.ipMesh:=CurSubMesh.ipMesh+32;//��������� �����
   inc(CurSubMesh.id);
  end;//of for ii
  pp:=pp+4;                       //������� ����
 end;//of for i

 //5. ���������� � ������������ MDX-������������ (Geosets)
 CountOfGeosets:=CountOfSubmeshes;
 if CountOfGeosets=0 then begin   //�����-�� ������
  MessageBox(0,'������ ���������',scError,mb_iconstop);
  exit;
 end;//of if
 SetLength(Geosets,CountOfGeosets);//�������� �����

 //���� �������� ������������
 for i:=0 to CountOfGeosets-1 do with Geosets[i] do begin
  pp:=Submeshes[i].ipMesh;        //������ ��������������
  HierID:=ReadLong;               //ID
  vnum:=ReadShort;                //����� ������ �������
  svnum:=vnum;
  CountOfVertices:=ReadShort;     //���-�� ������ �����������
  tnum:=ReadShort;                //��������� ������ �����.
  tcount:=ReadShort;              //���-�� ������ � ����������
  CountOfNormals:=CountOfVertices;
  CountOfCoords:=1;
  SetLength(Crds,1);
  Crds[0].CountOfTVertices:=CountOfVertices;
  CountOfFaces:=1;
  CountOfMatrices:=0;             //���� ��� ������ ������
  //���������� ����� ��������
  SetLength(Vertices,CountOfVertices);
  SetLength(Normals,CountOfVertices);
  SetLength(Crds[0].TVertices,CountOfVertices);
  SetLength(VertexGroup,CountOfVertices);
  SetLength(Faces,1);             //��� ������������ �������� � ����
  SetLength(Faces[0],tcount);     //���-�� ������ � �������������
  //������� "���������" ������
  pp2:=submeshes[i].ipIndices;    //������� ������
  pp2:=pp2+vnum*2;                //�������

  //��������� �������:
  for ii:=0 to CountOfVertices-1 do begin
   vnum:=0;Move(pointer(pp2)^,vnum,2);pp2:=pp2+2;
   pp:=ipVertices+vnum*48;
   Vertices[ii,1]:=ReadFloat*wowmult;//���������� �������
   Vertices[ii,2]:=ReadFloat*wowmult;
   Vertices[ii,3]:=ReadFloat*wowmult;
   //������ ���� (� �������) ������:
   bn1:=ReadByte;
   bn2:=ReadByte;
   bn3:=ReadByte;
   bn4:=ReadByte;
   //����� ������ � ������ �����
   if bn1>1 then bn1:=ReadByte else begin
    bn1:=-1;pp:=pp+1;
   end;//of if
   if bn2>1 then bn2:=ReadByte else begin
    bn2:=-1;pp:=pp+1;
   end;//of if
   if bn3>1 then bn3:=ReadByte else begin
    bn3:=-1;pp:=pp+1;
   end;//of if
   if bn4>1 then bn4:=ReadByte else begin
    bn4:=-1;pp:=pp+1;
   end;//of if
   //������ �� ������ ������ ������ �������:
//!dbg   if (bn1<0) and (bn2<0) and (bn3<0) and (bn4<0) then MessageBox(0,'df','dfg',0);
   VertexGroup[ii]:=GetMakedGroupNum(i,bn1,bn2,bn3,bn4);
   pp:=pp+3*4;                    //������� �������
   Crds[0].TVertices[ii,1]:=ReadFloat;//���������� ����������
   Crds[0].TVertices[ii,2]:=ReadFloat;
   pp:=pp+2*4;                    //������� 0
  end;//of for ii

  //�� �� ��� � ����� �� i, ��� i - ����� ��������������
  //(� ��� MDX - ����� �����������). ������ �������
  //������ ���������� (������������):
  pp:=Submeshes[i].ipFaces;       //������ ����������
  pp:=pp+tnum*2;                  //� ������ ������� ���������
  for ii:=0 to tcount-1 do begin
   Faces[0,ii]:=ReadShort-svnum;
  end;//of for ii

  //��-�������� ���� i (����� ��������������).
  //������ ���� ������ ��������� ��������������:
  MaterialID:=-1;                 //���� ��� ���������
  pp:=Submeshes[i].ipTexs;
  for ii:=1 to Submeshes[i].coTexs do begin
   pp:=pp+4;                      //������� � ���� MeshID
   tmp:=ReadShort;                //������ ���� ID
   pp:=pp+2;
   if Submeshes[i].id=tmp then begin//��������(����) ������
    pp:=pp-8;                     //�� ������ ���� ���������
    //������ �������� (��� ����)
    MaterialID:=M2ReadMaterial(Submeshes[i].coTexs-ii+1,tmp,
                i,ipColors,ipRenderFlags,ipTexUnits,
                ipTransparency,ipTexAnimLookup,ipTexLookup);
    break;                        //����� �� �����
   end;//of if
   pp:=pp+24-8;                   //���� �����
  end;//of for ii
  if MaterialID<0 then MaterialID:=CreateFakedMaterial;//���� ��� ���������

 end;//of for i

 //������ ������������ ������:
 M2ReadGlobalSequences(coGlobalSequences,ipGlobalSequences);
 M2ReadSequences(coAnims,ipAnims);

 CurID:=0;                        //���� ��� ��������
 M2ReadBones(coBones,ipBones,CurID);//������ �������� �������

 //������ ������ �������
 M2ReadAttachments(coAtch,ipAtch,CurID);
 M2ReadParticleEmitters(coParticles,ipParticles,CurID);
 M2ReadCameras(coCameras,ipCameras);
//----------���������� ������------------------
 FreeMem(p);
 //��������� ���������� �������
 SetLength(VisGeosets,CountOfGeosets);
 for i:=0 to CountOfGeosets-1 do VisGeosets[i]:=true;

 //�, �������, �������������� �����������
 i:=0;
 while i<CountOfGeosets do begin
  coVertices:=Geosets[i].CountOfVertices;
  //���� ����������� � ����� �� ���-��� ������
  ii:=i+1;
  while ii<CountOfGeosets do begin
   if Geosets[ii].CountOfVertices=coVertices then begin
    tmpGeo:=Geosets[ii];
    tmpGA:=GeosetAnims[ii];
    inc(i);
    Geosets[ii]:=Geosets[i];
    GeosetAnims[ii]:=GeosetAnims[i];
    GeosetAnims[ii].GeosetID:=ii;
    Geosets[i]:=tmpGeo;
    GeosetAnims[i]:=tmpGA;
    GeosetAnims[i].GeosetID:=i;
   end;//of if
   inc(ii);
  end;//of while
  inc(i);
 end;//of for i

// Freemem(p);
End;
//---------------------------------------------------------
//��������� ���� ������
procedure CloseMDL;
Var i:integer;
Begin
 for i:=0 to CountOfGeosets-1 do if Geosets[i].CurrentListNum<>-1 then
   glDeleteLists(Geosets[i].CurrentListNum,1);
 Geosets:=nil;
End;
//=========================================================
//���������������: ��������� ������ Vertices
procedure SaveVertices(geonum:integer);
//Const sSpace1=#09;
Var s:string;i:integer;
Begin
 s:=#09'Vertices '+inttostr(Geosets[geonum-1].CountOfVertices)+' {';
 writeln(ft,s);
 //������ ������
 for i:=0 to Geosets[geonum-1].CountOfVertices-1 do begin
  s:=#09#09'{ ';                  //������
  s:=s+floattostrf(Geosets[geonum-1].Vertices[i,1],ffGeneral,7,5)+', '+
       floattostrf(Geosets[geonum-1].Vertices[i,2],ffGeneral,7,5)+', '+
       floattostrf(Geosets[geonum-1].Vertices[i,3],ffGeneral,7,5)+' },';
  writeln(ft,s);                  //������
 end;//of for
 s:=#09'}';
 writeln(ft,s);   //����� ������
End;
//---------------------------------------------------------
//��������������� ������� ��� �������� �����������
procedure RecalcNormals(geonum:integer);
Var i,ii:integer;
    nnum,num:integer;
    num1,num2,num3:integer;
    x1,y1,z1,x2,y2,z2,x3,y3,z3:GLfloat;
    vx1,vy1,vz1,vx2,vy2,vz2,nx,ny,nz,wrki:GLfloat;
Begin
 nnum:=1;
 SetLength(nrms,Geosets[geonum-1].CountOfVertices);//������ �������
 //�������������
 for i:=0 to Geosets[geonum-1].CountOfVertices-1 do begin
  nrms[i].x:=0;nrms[i].y:=0;nrms[i].z:=0;
//  nrms[i].count:=0;
 end;//of for
 //1. ������ �������� � ����������� ������
 for i:=0 to Length(geosets[geonum-1].Faces)-1 do begin
  for ii:=0 to length(geosets[geonum-1].Faces[i])-1 do begin
   num:=Geosets[geonum-1].Faces[i,ii];
   case nnum of
    1:begin
     x1:=Geosets[geonum-1].Vertices[num,1];
     y1:=Geosets[geonum-1].Vertices[num,2];
     z1:=Geosets[geonum-1].Vertices[num,3];
     num1:=num;inc(nnum);
    end;//of 1
    2:begin
     x2:=Geosets[geonum-1].Vertices[num,1];
     y2:=Geosets[geonum-1].Vertices[num,2];
     z2:=Geosets[geonum-1].Vertices[num,3];
     num2:=num;inc(nnum);
    end;//of 1
    3:begin
     x3:=Geosets[geonum-1].Vertices[num,1];
     y3:=Geosets[geonum-1].Vertices[num,2];
     z3:=Geosets[geonum-1].Vertices[num,3];
     num3:=num;
     //������ - ���������� �������
     nnum:=1;                     //�����
     vx1:=x1-x2;vy1:=y1-y2;vz1:=z1-z2;
     vx2:=x2-x3;vy2:=y2-y3;vz2:=z2-z3;
     nx:=vy1*vz2-vz1*vy2;
     ny:=vz1*vx2-vx1*vz2;
     nz:=vx1*vy2-vy1*vx2;
     wrki:=sqrt(nx*nx+ny*ny+nz*nz);
     if wrki=0 then wrki:=1;
     //������� ��
//     inc(nrms[num1].count);
     nrms[num1].x:=nrms[num1].x+nx/wrki;
     nrms[num1].y:=nrms[num1].y+ny/wrki;
     nrms[num1].z:=nrms[num1].z+nz/wrki;

//     inc(nrms[num2].count);
     nrms[num2].x:=nrms[num2].x+nx/wrki;
     nrms[num2].y:=nrms[num2].y+ny/wrki;
     nrms[num2].z:=nrms[num2].z+nz/wrki;

//     inc(nrms[num3].count);
     nrms[num3].x:=nrms[num3].x+nx/wrki;
     nrms[num3].y:=nrms[num3].y+ny/wrki;
     nrms[num3].z:=nrms[num3].z+nz/wrki;
    end;//of 1
   end;//of case
//   inc(nnum);
  end;//of for ii
 end;//of for i
 //2. ��. ������ ��� ������ ������: ��������� �-�� � ��������� � 1
 for i:=0 to Geosets[geonum-1].CountOfVertices-1 do begin
{  if nrms[i].count=0 then begin
   nrms[i].x:=1;nrms[i].y:=0;nrms[i].z:=0;
   wrki:=1;
  end else begin}
{   if (sqr(nrms[i].x)+sqr(nrms[i].y)+sqr(nrms[i].z))<0.2 then begin
    nrms[i].x:=1;nrms[i].count:=1;
   end;//of if}
{   nrms[i].x:=nrms[i].x/nrms[i].count;
   nrms[i].y:=nrms[i].y/nrms[i].count;
   nrms[i].z:=nrms[i].z/nrms[i].count;}
   wrki:=sqrt(sqr(nrms[i].x)+sqr(nrms[i].y)+sqr(nrms[i].z));
   if wrki=0 then wrki:=1;
//  end;//of if
   Geosets[geonum-1].Normals[i,1]:=nrms[i].x/wrki;
   Geosets[geonum-1].Normals[i,2]:=nrms[i].y/wrki;
   Geosets[geonum-1].Normals[i,3]:=nrms[i].z/wrki;
  if pos('NAN',floattostrf(Geosets[geonum-1].Normals[i,1]
               ,ffFixed,10,5))<>0 then Geosets[geonum-1].Normals[i,1]:=0;
  if pos('NAN',floattostrf(Geosets[geonum-1].Normals[i,2]
               ,ffFixed,10,5))<>0 then Geosets[geonum-1].Normals[i,2]:=0;
  if pos('NAN',floattostrf(Geosets[geonum-1].Normals[i,3]
               ,ffFixed,10,5))<>0 then Geosets[geonum-1].Normals[i,3]:=0;
 end;//of for
End;
//---------------------------------------------------------
//�������� "�������������" ������������� ���,
//����� ��� ��������������� ����� ��������.
procedure NormalizeTriangles(geoID:integer);
Var i,ii,len,tmp:integer;
    x1,x2,x3,y1,y2,y3,z1,z2,z3,
    vx1,vx2,vy1,vy2,vz1,vz2,nx,ny,nz,sp1,sp2,sp3:single;
Const OFF_LINE=0.5;//���������� ������� ����� �������
Begin with Geosets[GeoID] do begin
 for i:=0 to High(Faces) do begin
  len:=High(Faces[i]);
  ii:=0;
  repeat
   //1. ��������� ���������� ������
   x1:=Vertices[Faces[i,ii],1];
   y1:=Vertices[Faces[i,ii],2];
   z1:=Vertices[Faces[i,ii],3];
   x2:=Vertices[Faces[i,ii+1],1];
   y2:=Vertices[Faces[i,ii+1],2];
   z2:=Vertices[Faces[i,ii+1],3];
   x3:=Vertices[Faces[i,ii+2],1];
   y3:=Vertices[Faces[i,ii+2],2];
   z3:=Vertices[Faces[i,ii+2],3];
   //2. ������������ ������� (�����, ���������)
   vx1:=x1-x2;vy1:=y1-y2;vz1:=z1-z2;
   vx2:=x2-x3;vy2:=y2-y3;vz2:=z2-z3;
   nx:=vy1*vz2-vz1*vy2;
   ny:=vz1*vx2-vx1*vz2;
   nz:=vx1*vy2-vy1*vx2;
   //���������� ������������ ������� � ������������
   //������� ��������� ������������
   sp1:=nx*Normals[Faces[i,ii],1]+ny*Normals[Faces[i,ii],2]+
        nz*Normals[Faces[i,ii],3];
   sp2:=nx*Normals[Faces[i,ii+1],1]+ny*Normals[Faces[i,ii+1],2]+
        nz*Normals[Faces[i,ii+1],3];
   sp3:=nx*Normals[Faces[i,ii+2],1]+ny*Normals[Faces[i,ii+2],2]+
        nz*Normals[Faces[i,ii+2],3];
   if (abs(sp1)<1e-6) or (abs(sp2)<1e-6) or (abs(sp3)<1e-6) then begin
    ii:=ii+3;
    continue;
   end;//of if
   //��������, �� ����� �� ����������� �����������
   if ((abs(sp1)/sp1)+(abs(sp2)/sp2)+(abs(sp3)/sp3))<0 then begin
    tmp:=Faces[i,ii];
    Faces[i,ii]:=Faces[i,ii+2];
    Faces[i,ii+2]:=tmp;
   end;//of if (��������� �����.)
   ii:=ii+3;
  until ii>=len;
 end;//of for i
end;End;
//---------------------------------------------------------
//������������ �������� ������� � ���������� �����������
//�� MidNormals � ConstNormals (���� ��� ������� ��� ���,
//������ �� ����������)
procedure DeleteRecFromSmoothGroups(nrm:TMidNormal);
Var i,ii,j,len:integer;
Begin
 //1. ������� �� ����� ����������:
 i:=0;
 while i<COMidNormals do begin
  len:=length(MidNormals[i]);
  ii:=0;
  while ii<len do begin
   if (MidNormals[i,ii].GeoID=nrm.GeoID) and
      (MidNormals[i,ii].VertID=nrm.VertID)
   then begin
    for j:=ii to len-2 do MidNormals[i,j]:=MidNormals[i,j+1];
    dec(len);
    SetLength(MidNormals[i],len);
    if len=0 then begin           //������� ��� ������
     for j:=i to COMidNormals-2 do MidNormals[j]:=MidNormals[j+1];
     dec(COMidNormals);
     SetLength(MidNormals,COMidNormals);
    end;
    exit;
   end;//of if
   inc(ii);
  end;//of while
  inc(i);
 end;//of while

 //2. ������� �� ����� ���������
 i:=0;
 while i<COConstNormals do begin
  if (ConstNormals[i].GeoId=nrm.GeoID) and (ConstNormals[i].VertID=nrm.VertID)
  then begin
   for ii:=i to CoConstNormals-2 do ConstNormals[ii]:=ConstNormals[ii+1];
   dec(COConstNormals);
   exit;
  end;//of if
  inc(i);
 end;//of while
End;
//---------------------------------------------------------
//����������� ���������� ������� (����� �������� 2 ������� �����),
//��� �������� � ���������� �����������.
procedure RoundModel;
Var i,ii,j,jj,len:integer;pw:PWord;
Begin
 //1. �����������
 for i:=0 to CountOfGeosets-1 do with Geosets[i] do begin
  for ii:=0 to CountOfVertices-1 do for j:=1 to 3 do begin
   pw:=@Geosets[i].Vertices[ii,j];
   pw^:=0;
  end;//of for ii

  for ii:=0 to CountOfNormals-1 do for j:=1 to 3 do begin
   pw:=@Normals[ii,j];
   pw^:=0;
  end;//of for ii

  for ii:=0 to CountOfCoords-1
  do for j:=0 to Crds[ii].CountOfTVertices-1 do for jj:=1 to 2 do begin
   pw:=@Crds[ii].TVertices[j,jj];
   pw^:=0;
  end;//of for jj/j/ii
 end;//of for i

 //������ ��������
 len:=High(Controllers);
 for i:=0 to len do for ii:=0 to High(Controllers[i].Items)
 do with Controllers[i].Items[ii] do for j:=1 to 4 do begin
  pw:=@Controllers[i].Items[ii].Data[j];
  pw^:=0;
  pw:=@Controllers[i].Items[ii].InTan[j];
  pw^:=0;
  pw:=@Controllers[i].Items[ii].OutTan[j];
  pw^:=0;
 end;//of with/for ii/i
End;
//---------------------------------------------------------
//������� ������������� �������� (�������� ���-�� �� �������)
procedure ReduceRepTextures;
Var i,ii,j,jj,TexID:integer;
Begin
 i:=1;
 while i<CountOfTextures do begin
  ii:=0;
  while ii<i do begin
   if (Textures[i].FileName=Textures[ii].FileName) and
    (Textures[i].ReplaceableID=Textures[ii].ReplaceableID) then begin
    //�������� ���������. ������� �������
    for j:=i to CountOfTextures-2 do Textures[j]:=Textures[j+1];
    dec(CountOfTextures);
    //������ �������� ID �������
    for j:=0 to CountOfMaterials-1
    do for jj:=0 to Materials[j].CountOfLayers-1
    do begin
     if Materials[j].Layers[jj].TextureID=i
     then Materials[j].Layers[jj].TextureID:=ii;
     if Materials[j].Layers[jj].TextureID>i
     then dec(Materials[j].Layers[jj].TextureID);
    end;//of if/for jj/for j
    //����� ���������� ID ������� � ���������� ������
    for j:=0 to CountOfParticleEmitters-1 do begin
     if pre2[j].TextureID=i then pre2[j].TextureID:=ii;
     if pre2[j].TextureID>i then dec(pre2[j].TextureID);
    end;//of for j
    ii:=-1;
    dec(i);
    break;
   end;//of if
   inc(ii);
  end;//of while
  inc(i);
 end;//of while
 SetLength(Textures,CountOfTextures);
End;
//---------------------------------------------------------
//������� ������������� ���������
procedure ReduceRepMaterials;
Var i,ii,j:integer;
Begin
 i:=1;
 while i<CountOfMaterials do begin
  ii:=0;
  while ii<i do begin
   if IsMatsEqual(Materials[i],Materials[ii]) then begin
    //��������� ���������. ������� �������
    for j:=i to CountOfMaterials-2 do Materials[j]:=Materials[j+1];
    dec(CountOfMaterials);
    //������ �������� ID ����������
    for j:=0 to CountOfGeosets-1 do begin
     if Geosets[j].MaterialID=i then Geosets[j].MaterialID:=ii;
     if Geosets[j].MaterialID>i then dec(Geosets[j].MaterialID);
    end;//of if/for j
    //����� ���������� ID ���������� � ���������� �����
    for j:=0 to CountOfRibbonEmitters-1 do begin
     if Ribs[j].MaterialID=i then Ribs[j].MaterialID:=ii;
     if Ribs[j].MaterialID>i then dec(Ribs[j].MaterialID);
    end;//of for j
    ii:=-1;
    dec(i);
    break;
   end;//of if
   inc(ii);
  end;//of while
  inc(i);
 end;//of while
 SetLength(Materials,CountOfMaterials);
End;
//---------------------------------------------------------
//�������� "�����������" ����� ���������� ��������
procedure SmoothWithNormals(geoID:integer);
Var i,ii:integer;
    v:TVertex;
    n:TNormal;
    wrki:GlFloat;
    sm:array of boolean;
Const Delta=3;
Begin with Geosets[geoid] do begin
 //exit;
 //�������� ������ ������������
 SetLength(sm,CountOfVertices);
 for i:=0 to CountOfVertices-1 do sm[i]:=false;
 //���� ����������
 for i:=0 to CountOfVertices-1 do begin
  if sm[i] then continue;
  v:=Vertices[i];                 //������ �-�� �������
  n:=Normals[i];                  //�������
  //���� ������� ������
  for ii:=i+1 to CountOfVertices-1 do begin
   if sqr(Vertices[ii,1]-v[1])+sqr(Vertices[ii,2]-v[2])+
      sqr(Vertices[ii,3]-v[3])<Delta then begin
    //������� �������, �������� �������
    n[1]:=n[1]+Normals[ii,1];
    n[2]:=n[2]+Normals[ii,2];
    n[3]:=n[3]+Normals[ii,3];
   end;//of if
  end;//of for ii
  //��������� ���������� ����������:
  wrki:=sqrt(sqr(n[1])+sqr(n[2])+sqr(n[3]));
  if wrki=0 then wrki:=1;
  n[1]:=n[1]/wrki;
  n[2]:=n[2]/wrki;
  n[3]:=n[3]/wrki;
  //����������
  for ii:=i to CountOfVertices-1 do begin
   if sqr(Vertices[ii,1]-v[1])+sqr(Vertices[ii,2]-v[2])+
      sqr(Vertices[ii,3]-v[3])<Delta then begin
    Normals[ii,1]:=n[1];
    Normals[ii,2]:=n[2];
    Normals[ii,3]:=n[3];
    sm[ii]:=true;  
   end;//of if
  end;//of for ii
 end;//of for i
end;End;
//---------------------------------------------------------
//�������� ����� ������� � ConstNormals.
//���� ��� ��� ����, �����. ID �����. ������. ����� (-1).
function FindConstNormal(geoID,VertID:integer):integer;
Var i:integer;
Begin
 Result:=-1;
 for i:=0 to COConstNormals-1
 do if (ConstNormals[i].GeoID=GeoID) and (ConstNormals[i].VertID=VertID)
 then begin
  Result:=i;
  exit;
 end;//of if/for i
End;
//---------------------------------------------------------
//��������� ������ ����������� � ��������
procedure ApplySmoothGroups;
Var i,ii:integer; snrm,nrm:TVertex; n:GLFloat;
Begin
 //1. ���������� ���� ����� �����������:
 //a. ����� ���������� ������� ��� ������ ������
 //b. ��������� � �� ���� �������� ������
 for i:=0 to COMidNormals-1 do begin
  nrm[1]:=0;
  nrm[2]:=0;
  nrm[3]:=0;
  for ii:=0 to High(MidNormals[i]) do begin
   snrm:=Geosets[MidNormals[i,ii].GeoID].Normals[MidNormals[i,ii].VertID];
   nrm[1]:=nrm[1]+snrm[1];
   nrm[2]:=nrm[2]+snrm[2];
   nrm[3]:=nrm[3]+snrm[3];
  end;//of for ii
  if abs(nrm[1])+abs(nrm[2])+abs(nrm[3])<1e-6 then nrm[1]:=1;
  n:=1/sqrt(nrm[1]*nrm[1]+nrm[2]*nrm[2]+nrm[3]*nrm[3]);
  nrm[1]:=nrm[1]*n;
  nrm[2]:=nrm[2]*n;
  nrm[3]:=nrm[3]*n;

  for ii:=0 to High(MidNormals[i]) do with Geosets[MidNormals[i,ii].GeoID]
  do begin
   Normals[MidNormals[i,ii].VertID,1]:=nrm[1];
   Normals[MidNormals[i,ii].VertID,2]:=nrm[2];
   Normals[MidNormals[i,ii].VertID,3]:=nrm[3];
  end;//of for ii   
 end;//of for i

 //2. ��������� "�����������" ������� �� ���� �����. ��������
 for i:=0 to COConstNormals-1
 do Geosets[ConstNormals[i].GeoId].Normals[ConstNormals[i].VertID]:=
    ConstNormals[i].n;
End;
//---------------------------------------------------------
//������� ������ ��������
procedure SaveNormals(geonum:integer);
Var s,s2:string;i:integer;
Begin
 s:=#09'Normals '+inttostr(Geosets[geonum-1].CountOfVertices)+' {';
 writeln(ft,s);
 //������ ��������
 for i:=0 to Geosets[geonum-1].CountOfVertices-1 do begin
  s:=#09#09'{ ';                  //������
  s2:=floattostrf(Geosets[geonum-1].Normals[i,1],ffGeneral,7,5)+', '+
       floattostrf(Geosets[geonum-1].Normals[i,2],ffGeneral,7,5)+', '+
       floattostrf(Geosets[geonum-1].Normals[i,3],ffGeneral,7,5)+' },';
  if pos('NAN',s2)<>0 then s2:='0, 0, 0 },';//����� ����������
  s:=s+s2;
  writeln(ft,s);                  //������
 end;//of for
 s:=#09'}';
 writeln(ft,s);   //����� ������
End;
//---------------------------------------------------------
procedure SaveTVertices(geonum:integer);//��������� �-�� ��������
Var s:string;i,j:integer;
Begin
 for j:=0 to Geosets[Geonum-1].CountOfCoords-1 do begin
  s:=#09'TVertices '+inttostr(Geosets[geonum-1].CountOfVertices)+' {';
  writeln(ft,s);
  //������ ���������� ������
  for i:=0 to Geosets[geonum-1].CountOfVertices-1 do begin
   s:=#09#09'{ ';                  //������
   s:=s+floattostrf(Geosets[geonum-1].Crds[j].TVertices[i,1],ffGeneral,7,5)+
      ', '+
      floattostrf(Geosets[geonum-1].Crds[j].TVertices[i,2],ffGeneral,7,5)+
      ' },';
   writeln(ft,s);                  //������
  end;//of for i
  s:=#09'}';
  writeln(ft,s);   //����� ������
 end;//of for j
End;
//---------------------------------------------------------
procedure SaveVertexGroup(geonum:integer);//��������� ������ ������
Var s:string;i:integer;
Begin
 s:=#09'VertexGroup {';
 writeln(ft,s);
 //������ ��������
 for i:=0 to Geosets[geonum-1].CountOfVertices-1 do begin
  s:=#09#09;                      //������
  s:=s+inttostr(Geosets[geonum-1].VertexGroup[i])+',';
  writeln(ft,s);                  //������
 end;//of for
 s:=#09'}';
 writeln(ft,s);   //����� ������
End;
//---------------------------------------------------------
procedure SaveFaces(geonum:integer);//��������� ���������
Var s:string;i,ii,count:integer;
Begin
 //������ ������������ ���������
 s:=#09'Faces '+inttostr(Length(Geosets[geonum-1].Faces))+' ';
 //������� ���-�� �������������
 count:=0;
 for i:=0 to Length(Geosets[geonum-1].Faces)-1 do count:=count+
             Length(Geosets[geonum-1].Faces[i]);
// count:=count div 3; //������ ������ ����� �����.
 s:=s+inttostr(count)+' {';
 writeln(ft,s);                   //�������� ���������
 s:=#09#09'Triangles {';
 writeln(ft,s);                   //�������� ���������
 for i:=0 to Length(Geosets[geonum-1].Faces)-1 do begin
  s:=#09#09#09'{ ';               //������
  for ii:=0 to Length(Geosets[geonum-1].Faces[i])-1 do begin
   if ii<>0 then s:=s+', ';       //���������� ���������
   s:=s+inttostr(Geosets[geonum-1].Faces[i,ii]);
  end;//of for ii
  s:=s+' },';                     //��������� ���������
  writeln(ft,s);
 end;//of for i
 s:=#09#09'}';writeln(ft,s);      //Triangles
 s:=#09'}';writeln(ft,s);         //Faces
End;
//---------------------------------------------------------
//������� ������ ����� (����������� �� ������)
procedure SaveGroups(geonum:integer);
Var s:string;i,ii,count:integer;
Begin
 //������ ������������ ���������
 s:=#09'Groups '+inttostr(Geosets[geonum-1].CountOfMatrices)+' ';
 //������� ���-�� ������� ������
 count:=0;
 for i:=0 to Length(Geosets[geonum-1].Groups)-1 do count:=count+
             Length(Geosets[geonum-1].Groups[i]);
 s:=s+inttostr(count)+' {';
 writeln(ft,s);                   //�������� ���������
// s:=#09#09'Triangles {';
// writeln(ft,s);                   //�������� ���������
 for i:=0 to Geosets[geonum-1].CountOfMatrices-1 do begin
  s:=#09#09'Matrices { ';               //������
  for ii:=0 to Length(Geosets[geonum-1].Groups[i])-1 do begin
   if ii<>0 then s:=s+', ';       //���������� ���������
   s:=s+inttostr(Geosets[geonum-1].Groups[i,ii]);
  end;//of for ii
  s:=s+' },';                     //��������� ���������
  writeln(ft,s);
 end;//of for i
// s:=#09#09'}';writeln(ft,s);      //Triangles
 s:=#09'}';writeln(ft,s);         //Groups
End;
//---------------------------------------------------------
{ TODO -o������� -c��������� : ������� ���������� � ���������� ������ � ���������� }
//��������������� ������� ������
procedure RecalcBounds(geonum:integer);
Var xmin,ymin,zmin,xmax,ymax,zmax:GLfloat;
    DeltaXMin,DeltaYMin,DeltaZMin,
    DeltaXMax,DeltaYMax,DeltaZMax:GLfloat;
    i:integer;
Begin
 xmin:=1000;ymin:=1000;zmin:=1000;
 xmax:=-1000;ymax:=-1000;zmax:=-1000;
 //����� ������
 for i:=0 to Geosets[geonum-1].CountOfVertices-1 do begin
  if Geosets[geonum-1].Vertices[i,1]<xmin then
                       xmin:=Geosets[geonum-1].Vertices[i,1];
  if Geosets[geonum-1].Vertices[i,1]>xmax then
                       xmax:=Geosets[geonum-1].Vertices[i,1];
  if Geosets[geonum-1].Vertices[i,2]<ymin then
                       ymin:=Geosets[geonum-1].Vertices[i,2];
  if Geosets[geonum-1].Vertices[i,2]>ymax then
                       ymax:=Geosets[geonum-1].Vertices[i,2];
  if Geosets[geonum-1].Vertices[i,3]<zmin then
                       zmin:=Geosets[geonum-1].Vertices[i,3];
  if Geosets[geonum-1].Vertices[i,3]>zmax then
                       zmax:=Geosets[geonum-1].Vertices[i,3];
 end;//of for
{ //��������� ������
 DeltaXMin:=xmin-Geosets[geonum-1].MinimumExtent[1];
 DeltaYMin:=ymin-Geosets[geonum-1].MinimumExtent[2];
 DeltaZMin:=zmin-Geosets[geonum-1].MinimumExtent[3];

 DeltaXMax:=xmax-Geosets[geonum-1].MaximumExtent[1];
 DeltaYMax:=ymax-Geosets[geonum-1].MaximumExtent[2];
 DeltaZMax:=zmax-Geosets[geonum-1].MaximumExtent[3];
 //��������, ����� �� ������������� ������
 if (DeltaXMin<0) or (DeltaYMin<0) or (DeltaZMin<0) or
    (DeltaXMax<0) or (DeltaYMax<0) or (DeltaZMax<0) then begin
  //�������������
  if DeltaXMax>0 then DeltaXMax:=0;
  if DeltaYMax>0 then DeltaYMax:=0;
  if DeltaZMax>0 then DeltaZMax:=0;
  if DeltaXMin>0 then DeltaXMin:=0;
  if DeltaYMin>0 then DeltaYMin:=0;
  if DeltaZMin>0 then DeltaZMin:=0;}
  Geosets[geonum-1].MinimumExtent[1]:=xmin;
  Geosets[geonum-1].MinimumExtent[2]:=ymin;
  Geosets[geonum-1].MinimumExtent[3]:=zmin;
  Geosets[geonum-1].MaximumExtent[1]:=xmax;
  Geosets[geonum-1].MaximumExtent[2]:=ymax;
  Geosets[geonum-1].MaximumExtent[3]:=zmax;
  for i:=0 to Geosets[geonum-1].CountOfAnims-1 do begin
   Geosets[geonum-1].Anims[i].MinimumExtent[1]:=xmin;
   Geosets[geonum-1].Anims[i].MinimumExtent[2]:=ymin;
   Geosets[geonum-1].Anims[i].MinimumExtent[3]:=zmin;
   Geosets[geonum-1].Anims[i].MaximumExtent[1]:=xmax;
   Geosets[geonum-1].Anims[i].MaximumExtent[2]:=ymax;
   Geosets[geonum-1].Anims[i].MaximumExtent[3]:=zmax;
  end;//of for
  //������ ��������� ��������� ������
  for i:=0 to Geosets[geonum-1].CountOfAnims-1 do
  with Geosets[geonum-1].Anims[i] do begin
   BoundsRadius:=sqrt(sqr(MinimumExtent[1]-MaximumExtent[1])+
                 sqr(MinimumExtent[2]-MaximumExtent[2])+
                 sqr(MinimumExtent[3]-MaximumExtent[3]));
  end;//of with/for
  //������� ���� �����������
  with Geosets[geonum-1] do BoundsRadius:=
    sqrt(sqr(MinimumExtent[1]-MaximumExtent[1])+
                 sqr(MinimumExtent[2]-MaximumExtent[2])+
                 sqr(MinimumExtent[3]-MaximumExtent[3]));
End;
//---------------------------------------------------------
//��������� ������� ������ � ��������
procedure SaveBounds(geonum:integer);
Var i:integer;s:string;
Begin with geosets[geonum-1] do begin
 //����������� ������� �����������
 s:=#09'MinimumExtent { '+floattostrf(MinimumExtent[1],ffGeneral,10,5)+
    ', '+floattostrf(MinimumExtent[2],ffGeneral,7,5)+
    ', '+floattostrf(MinimumExtent[3],ffGeneral,7,5)+' },';
 writeln(ft,s);
 s:=#09'MaximumExtent { '+floattostrf(MaximumExtent[1],ffGeneral,10,5)+
    ', '+floattostrf(MaximumExtent[2],ffGeneral,7,5)+
    ', '+floattostrf(MaximumExtent[3],ffGeneral,7,5)+' },';
 writeln(ft,s);
 s:=#09'BoundsRadius '+floattostrf(BoundsRadius,ffFixed,10,5)+',';
 if pos('INF',s)=0 then writeln(ft,s);
 //������ - ������ ��������
 for i:=0 to CountOfAnims-1 do begin
  s:=#09'Anim {';writeln(ft,s);
  s:=#09#09'MinimumExtent { '
         +floattostrf(Anims[i].MinimumExtent[1],ffGeneral,10,5)+
     ', '+floattostrf(Anims[i].MinimumExtent[2],ffGeneral,10,5)+
     ', '+floattostrf(Anims[i].MinimumExtent[3],ffGeneral,10,5)+' },';
  writeln(ft,s);
  s:=#09#09'MaximumExtent { '
         +floattostrf(Anims[i].MaximumExtent[1],ffGeneral,7,5)+
     ', '+floattostrf(Anims[i].MaximumExtent[2],ffGeneral,7,5)+
     ', '+floattostrf(Anims[i].MaximumExtent[3],ffGeneral,7,5)+' },';
  writeln(ft,s);
  s:=#09#09'BoundsRadius '+floattostrf(Anims[i].BoundsRadius,ffGeneral,7,5)+',';
  if pos('INF',s)=0 then writeln(ft,s);
//  writeln(ft,s);
  s:=#09'}';writeln(ft,s);
 end;//of for
end;End;
//---------------------------------------------------------
procedure SaveTail(geonum:integer);
Var s:string;
Begin
 s:=#09'MaterialID '+inttostr(Geosets[geonum-1].MaterialID)+',';
 writeln(ft,s);
 s:=#09'SelectionGroup '+inttostr(Geosets[geonum-1].SelectionGroup)+',';
 writeln(ft,s);
 if Geosets[geonum-1].Unselectable then begin
  s:=#09'Unselectable,';writeln(ft,s);
 end;//of if
 s:='}';writeln(ft,s);
End;
//---------------------------------------------------------
//���������� ������� �������� �� A.
//sBeg - ��������� ������ (Tab'�)
procedure SaveAnimBounds(a:TAnim;sBeg:string);
Var s:string;//i:integer;
Begin with a do begin
 //������ �������
 if (MinimumExtent[1]<>0) or (MinimumExtent[2]<>0) or
    (MinimumExtent[3]<>0) then begin
  s:=sBeg+'MinimumExtent { '+floattostrf(MinimumExtent[1],ffGeneral,7,5)+
     ', '+floattostrf(MinimumExtent[2],ffGeneral,7,5)+', '+
     floattostrf(MinimumExtent[3],ffGeneral,7,5)+' },';
  writeln(ft,s);
 end;//of if
 //������� �������
 if (MaximumExtent[1]<>0) or (MaximumExtent[2]<>0) or
    (MaximumExtent[3]<>0) then begin
  s:=sBeg+'MaximumExtent { '+floattostrf(MaximumExtent[1],ffGeneral,7,5)+
     ', '+floattostrf(MaximumExtent[2],ffGeneral,7,5)+', '+
     floattostrf(MaximumExtent[3],ffGeneral,7,5)+' },';
  writeln(ft,s);
 end;//of if
 //��������� ������
 if BoundsRadius<>0 then begin
  s:=sBeg+'BoundsRadius '+floattostrf(BoundsRadius,ffGeneral,7,5)+',';
  if pos('INF',s)=0 then writeln(ft,s);
//  writeln(ft,s);
 end;//of if
end;End;
//---------------------------------------------------------
//������� (����������) ��������� MDL-�����
//Gz - ���-�� "������" ������������
procedure SaveHeader(Gz:integer);
Var s:string;
Begin
 s:='//Modified with MdlVis.';    //��������� �����������
 writeln(ft,s);
 s:='Version {'#13#10#09'FormatVersion 800,'#13#10'}';
 writeln(ft,s);                   //������ ������
 //���������� �������� ������
 s:='Model "'+ModelName+'" {';writeln(ft,s);
 s:=#09'NumGeosets '+inttostr(CountOfGeosets-Gz)+',';
 writeln(ft,s);
 if CountOfGeosetAnims<>0 then begin
  s:=#09'NumGeosetAnims '+inttostr(CountOfGeosetAnims)+',';
  writeln(ft,s);
 end;//of if
 if CountOfHelpers<>0 then begin
  s:=#09'NumHelpers '+inttostr(CountOfHelpers)+',';
  writeln(ft,s);
 end;//of if
 if CountOfLights<>0 then begin
  s:=#09'NumLights '+inttostr(CountOfLights)+',';
  writeln(ft,s);
 end;//of if
 if CountOfBones<>0 then begin
  s:=#09'NumBones '+inttostr(CountOfBones)+',';
  writeln(ft,s);
 end;//of if
 if CountOfAttachments<>0 then begin
  s:=#09'NumAttachments '+inttostr(CountOfAttachments)+',';
  writeln(ft,s);
 end;//of if
 if CountOfParticleEmitters1<>0 then begin
  s:=#09'NumParticleEmitters '+inttostr(CountOfParticleEmitters1)+',';
  writeln(ft,s);
 end;//of if
 if CountOfParticleEmitters<>0 then begin
  s:=#09'NumParticleEmitters2 '+inttostr(CountOfParticleEmitters)+',';
  writeln(ft,s);
 end;//of if
 if CountOfRibbonEmitters<>0 then begin
  s:=#09'NumRibbonEmitters '+inttostr(CountOfRibbonEmitters)+',';
  writeln(ft,s);
 end;//of if
 if CountOfEvents<>0 then begin
  s:=#09'NumEvents '+inttostr(CountOfEvents)+',';
  writeln(ft,s);
 end;//of if
 s:=#09'BlendTime 150,';writeln(ft,s);
 //������ - �������
 SaveAnimBounds(AnimBounds,#09);
 s:='}';writeln(ft,s);
End;
//---------------------------------------------------------
//���������� ������ �������������������
procedure SaveSequences;
Var s:string;i:integer;
Begin
 if CountOfSequences=0 then exit;
 //��������� ������
 s:='Sequences '+inttostr(CountOfSequences)+' {';
 writeln(ft,s);
 //��� ������������������
 for i:=0 to CountOfSequences-1 do begin
  s:=#09'Anim "'+Sequences[i].Name+'" {';
  writeln(ft,s);                  //��� ������������������
  s:=#09#09'Interval { '+inttostr(Sequences[i].IntervalStart)+
     ', '+inttostr(Sequences[i].IntervalEnd)+' },';
  writeln(ft,s);                  //��������
  //������ �������������� ���������
  if Sequences[i].IsNonLooping then begin
   s:=#09#09'NonLooping,';writeln(ft,s);
  end;//of if
  if Sequences[i].Rarity>0 then begin
   s:=#09#09'Rarity '+inttostr(Sequences[i].Rarity)+',';
   writeln(ft,s);
  end;//of if
  if Sequences[i].MoveSpeed>0 then begin
   s:=#09#09'MoveSpeed '+inttostr(Sequences[i].MoveSpeed)+',';
   writeln(ft,s);
  end;//of if
  //������ ������
  SaveAnimBounds(Sequences[i].Bounds,#09#09);
  s:=#09'}';writeln(ft,s);
 end;//of for i
 //����� ������
 s:='}';writeln(ft,s);

 //������ - ���������� ������������������
 if CountOfGlobalSequences=0 then exit;
 s:='GlobalSequences '+inttostr(CountOfGlobalSequences)+' {';
 writeln(ft,s);
 for i:=0 to CountOfGlobalSequences-1 do begin
  s:=#09'Duration '+inttostr(GlobalSequences[i])+',';
  writeln(ft,s);
 end;//of for i
 s:='}';writeln(ft,s);
End;
//---------------------------------------------------------
procedure SaveTextures;
Var s:string;i:integer;
Begin
 //������ ������
 s:='Textures '+inttostr(CountOfTextures)+' {';
 writeln(ft,s);
 //��������� �����������
 for i:=0 to CountOfTextures-1 do begin
  s:=#09'Bitmap {';writeln(ft,s);
  s:=#09#09'Image "'+Textures[i].FileName+'",';
  writeln(ft,s);
  //�������������� ����������
  if Textures[i].ReplaceableID<>0 then begin
   s:=#09#09'ReplaceableId '+inttostr(Textures[i].ReplaceableID)+',';
   writeln(ft,s);
  end;//of if
  if Textures[i].IsWrapWidth then begin
   s:=#09#09'WrapWidth,';writeln(ft,s);
  end;//of if
  if Textures[i].IsWrapHeight then begin
   s:=#09#09'WrapHeight,';writeln(ft,s);
  end;//of if
  s:=#09'}';writeln(ft,s);        //������� ���������
 end;//of for
 s:='}';writeln(ft,s);            //����� ������
End;
//---------------------------------------------------------
//��������� ���������� �� ������� Controllers � ������� cnum
//��������� � ������� ������ sBeg.
//sFirst - ������ ������ (�������������) ������ �����������
procedure SaveController(cnum:integer;sBeg,sFirst:string);
Var i,ii:integer;s:string;
Begin
 //������ ������ �����������
 s:=sFirst+inttostr(Length(Controllers[cnum].Items))+' {';
 writeln(ft,s);
 s:=sBeg;
 //������� ��� �����������:
 case Controllers[cnum].ContType of
  Linear:    s:=s+'Linear,';
  DontInterp:s:=s+'DontInterp,';
  Bezier:    s:=s+'Bezier,';
  Hermite:   s:=s+'Hermite,';
 end;//of case
 writeln(ft,s);
 //���������� ID
 if Controllers[cnum].GlobalSeqId>=0 then begin
  s:=sBeg+'GlobalSeqId '+inttostr(Controllers[cnum].GlobalSeqId)+',';
  writeln(ft,s);
 end;//of if
 //������ ������� ��������� �����
 for i:=0 to length(Controllers[cnum].Items)-1 do with Controllers[cnum] do begin
  s:=sBeg+inttostr(items[i].Frame)+': ';
  //����������� � ������ ��������� ������� �������
  if SizeOfElement>1 then s:=s+'{ ';
  for ii:=1 to SizeOfElement do begin
   s:=s+floattostrf(items[i].data[ii],ffGeneral,7,0);
   if ii<SizeOfElement then s:=s+', ';
  end;//of for ii
  if SizeOfElement>1 then s:=s+' },' else s:=s+',';
  writeln(ft,s);
  //������ ��������� ����� (���� ��� ����)
  if (ContType=Hermite) or (ContType=Bezier) then begin
   s:=sBeg+#09'InTan ';
//   if SizeOfElement>1 then s:=s+' {';
   //����������� � ������ ��������� ������� �������
   if SizeOfElement>1 then s:=s+'{ ';
   for ii:=1 to SizeOfElement do begin
    s:=s+floattostrf(items[i].InTan[ii],ffGeneral,7,0);
    if ii<SizeOfElement then s:=s+', ';
   end;//of for ii
   if SizeOfElement>1 then s:=s+' },' else s:=s+',';
   writeln(ft,s);
   s:=sBeg+#09'OutTan ';
//   if SizeOfElement>1 then s:=s+' {';
   //����������� � ������ ��������� ������� �������
   if SizeOfElement>1 then s:=s+'{ ';
   for ii:=1 to SizeOfElement do begin
    s:=s+floattostrf(items[i].OutTan[ii],ffGeneral,7,0);
    if ii<SizeOfElement then s:=s+', ';
   end;//of for ii
   if SizeOfElement>1 then s:=s+' },' else s:=s+',';
   writeln(ft,s);
  end;//of if
 end;//of with/for
 //����������: ������� ������ �����������
 Delete(sBeg,1,1);
 s:=sBeg+'}';writeln(ft,s);
End;
//---------------------------------------------------------
procedure SaveMaterials;
Var s:string;i,ii:integer;
Begin
 s:='Materials '+inttostr(CountOfMaterials)+' {';
 writeln(ft,s);
 //������ ������� ���������
 for i:=0 to CountOfMaterials-1 do begin
  s:=#09'Material {';writeln(ft,s);//���������
  if Materials[i].IsConstantColor then begin
   s:=#09#09'ConstantColor,';writeln(ft,s);
  end;//of if
  if Materials[i].IsSortPrimsFarZ then begin
   s:=#09#09'SortPrimsFarZ,';writeln(ft,s);
  end;//of if
  if Materials[i].IsFullResolution then begin
   s:=#09#09'FullResolution,';writeln(ft,s);
  end;
  if Materials[i].PriorityPlane>=0 then begin
   s:=#09#09'PriorityPlane '+inttostr(Materials[i].PriorityPlane)+',';
   writeln(ft,s);
  end;//of if(PriorityPlane)
  //������ �����
  for ii:=0 to Materials[i].CountOfLayers-1 do with Materials[i].Layers[ii]do begin
   s:=#09#09'Layer {';writeln(ft,s);
   //������
   s:=#09#09#09'FilterMode '{+inttostr(FilterMode)};
   case FilterMode of
    Opaque:    s:=s+'None,';
    ColorAlpha:s:=s+'Transparent,';
    FullAlpha: s:=s+'Blend,';
    Additive:  s:=s+'Additive,';
    AddAlpha:  s:=s+'AddAlpha,';
    Modulate:  s:=s+'Modulate,';
    Modulate2X:s:=s+'Modulate2x,';
   end;//of case
   writeln(ft,s);
   //�������������� ���������� ����
   if IsUnshaded then begin
    s:=#09#09#09'Unshaded,';writeln(ft,s);
   end;//of if
   if IsSphereEnvMap then begin
    s:=#09#09#09'SphereEnvMap,';writeln(ft,s);
   end;
   if IsUnfogged then begin
    s:=#09#09#09'Unfogged,';writeln(ft,s);
   end;//of if
   if IsTwoSided then begin
    s:=#09#09#09'TwoSided,';writeln(ft,s);
   end;//of if
   if IsNoDepthTest then begin
    s:=#09#09#09'NoDepthTest,';writeln(ft,s);
   end;//of if
   if IsNoDepthSet then begin
    s:=#09#09#09'NoDepthSet,';writeln(ft,s);
   end;//of if
   //�������� (ID)
   if IsTextureStatic then begin
    s:=#09#09#09'static TextureID '+inttostr(TextureID)+',';
    writeln(ft,s);
   end else begin
    s:=#09#09#09'TextureID ';        //��������� ������
    SaveController(NumOfTexGraph,#09#09#09#09,s);
   end;//of if (texture)
   //TVertexAnimID (���� ����)
   if TVertexAnimID>=0 then begin
    s:=#09#09#09'TVertexAnimId '+inttostr(TVertexAnimID)+',';
    writeln(ft,s);
   end;//of if
   //CoordID:
   if CoordID>=0 then begin
    s:=#09#09#09'CoordId '+inttostr(CoordID)+',';
    writeln(ft,s);
   end;//of if
   //�����-���������
//   if Alpha>=0 then begin
   if IsAlphaStatic then begin   //����� ���������
    if Alpha>=0 then begin
     s:=#09#09#09'static Alpha '+floattostrf(Alpha,ffGeneral,7,5)+',';
     writeln(ft,s);
    end;//of if
   end else begin                //����� ����������
     s:=#09#09#09'Alpha ';        //��������� ������
     SaveController(NumOfGraph,#09#09#09#09,s);
   end;//of if (AlphaStatic)
//   end;//of if (Alpha)
   //����� ���������
   s:=#09#09'}';writeln(ft,s);
  end;//of with/for ii
  s:=#09'}';writeln(ft,s);
 end;//of for i
 s:='}';writeln(ft,s);
End;
//---------------------------------------------------------
//��������� ������ ���������� ��������
procedure SaveTextureAnims;
Var i:integer;s:string;
Begin
 if CountOfTextureAnims=0 then exit;//������ ���������
 //��������� ������
 s:='TextureAnims '+inttostr(CountOfTextureAnims)+' {';
 writeln(ft,s);
 for i:=0 to CountOfTextureAnims-1 do begin
  s:=#09'TVertexAnim {';writeln(ft,s);//��������� ���������
  if TextureAnims[i].TranslationGraphNum>=0 then begin
   s:=#09#09'Translation ';
   SaveController(TextureAnims[i].TranslationGraphNum,#09#09#09,s);
  end;//of if (Translation)
  if TextureAnims[i].RotationGraphNum>=0 then begin
   s:=#09#09'Rotation ';
   SaveController(TextureAnims[i].RotationGraphNum,#09#09#09,s);
  end;//of if (Translation)
  if TextureAnims[i].ScalingGraphNum>=0 then begin
   s:=#09#09'Scaling ';
   SaveController(TextureAnims[i].ScalingGraphNum,#09#09#09,s);
  end;//of if (Translation)
  //����� ���������
  s:=#09'}';writeln(ft,s);
 end;//of for i
 s:='}';writeln(ft,s);            //����� ������
End;
//---------------------------------------------------------
//��������� �������� ��������� ������������
procedure SaveGeosetAnims;
Var i:integer;s:string;
Begin
 for i:=0 to CountOfGeosetAnims-1 do begin
  s:='GeosetAnim {';writeln(ft,s);

  //0. ���� DropShadow
  if GeosetAnims[i].IsDropShadow then begin
   s:=#09'DropShadow,';writeln(ft,s);
  end;//of if(IsDropShadow)
  //1. �����-���������
  if GeosetAnims[i].IsAlphaStatic then begin //static
   if GeosetAnims[i].Alpha>=0 then begin
    s:=#09'static Alpha '+floattostrf(GeosetAnims[i].Alpha,ffGeneral,7,0)+
      ',';
    writeln(ft,s);
   end;//of if
  end else begin                  //dynamic
   s:=#09'Alpha ';
   SaveController(GeosetAnims[i].AlphaGraphNum,#09#09,s);
  end;//of if

  //2. �������� ���������
  if GeosetAnims[i].IsColorStatic then begin //static
   if GeosetAnims[i].Color[1]>=0 then begin
    s:=#09'static Color { '+floattostrf(GeosetAnims[i].Color[1],ffGeneral,7,0)+
      ', '+floattostrf(GeosetAnims[i].Color[2],ffGeneral,7,0)+
      ', '+floattostrf(GeosetAnims[i].Color[3],ffGeneral,7,0)+
      ' },';
    writeln(ft,s);
   end;//of if
  end else begin                  //dynamic
   s:=#09'Color ';
   SaveController(GeosetAnims[i].ColorGraphNum,#09#09,s);
  end;//of if

  //3. GeosetID
  s:=#09'GeosetId '+inttostr(GeosetAnims[i].GeosetID)+',';
  writeln(ft,s);
  s:='}';writeln(ft,s); 
 end;//of for
End;
//---------------------------------------------------------
//���������������: ��������� ������� TBone
//���������� � ���� ������� b.
//���� IsBone=true, �� ���������� ��� Bone,
//����� - ��� Helper.
procedure SaveTBone(IsBone:boolean;b:TBone);
Var s:string;
Begin
 //1. ������ ������ ������
 if IsBone then s:='Bone ' else s:='Helper ';
 s:=s+'"'+b.Name+'" {';writeln(ft,s);
 //2. �� ������� ��� ����������:
 if b.ObjectID>=0 then begin
  s:=#09'ObjectId '+inttostr(b.ObjectID)+',';
  writeln(ft,s);
 end;//of if

 if b.Parent>=0 then begin
  s:=#09'Parent '+inttostr(b.Parent)+',';
  writeln(ft,s);
 end;//of if

 if b.IsBillboardedLockZ then begin
  s:=#09'BillboardedLockZ,';writeln(ft,s);
 end;//of if
 if b.IsBillboardedLockY then begin
  s:=#09'BillboardedLockY,';writeln(ft,s);
 end;//of if
 if b.IsBillboardedLockX then begin
  s:=#09'BillboardedLockX,';writeln(ft,s);
 end;//of if
 if b.IsBillboarded then begin
  s:=#09'Billboarded,';writeln(ft,s);
 end;//of if
 if b.IsCameraAnchored then begin
  s:=#09'CameraAnchored,';writeln(ft,s);
 end;//of if

 if (b.GeosetID>=0) or (b.GeosetID=Multiple) then begin
  s:=#09'GeosetId ';
  if b.GeosetID=Multiple then s:=s+'Multiple,'
                         else s:=s+inttostr(b.GeosetID)+',';
  writeln(ft,s);
 end;//of if

 if (b.GeosetAnimID=None) or (b.GeosetAnimID>=0) then begin
  s:=#09'GeosetAnimId ';
  if b.GeosetAnimID=None then s:=s+'None,'
                         else s:=s+inttostr(b.GeosetAnimID)+',';
  writeln(ft,s);
 end;//of if

 //������ ������ "��-������������"
 if b.IsDIRotation or b.IsDITranslation or b.IsDIScaling then begin
  s:=#09'DontInherit { ';
  if b.IsDIRotation then s:=s+'Rotation';
  if b.IsDITranslation then begin
   if length(s)>16 then s:=s+', ';
   s:=s+'Translation';
  end;//of if (Translation)
  if b.IsDIScaling then begin
   if length(s)>16 then s:=s+', ';
   s:=s+'Scaling';
  end;//of if (Translation)
  s:=s+' },';
  writeln(ft,s);
 end;//of if

 //������ - ��������������
 if b.Translation>=0 then begin
  s:=#09'Translation ';
  SaveController(b.Translation,#09#09,s);
 end;//of if

 if b.Rotation>=0 then begin
  s:=#09'Rotation ';
  SaveController(b.Rotation,#09#09,s);
 end;//of if

 if b.Scaling>=0 then begin
  s:=#09'Scaling ';
  SaveController(b.Scaling,#09#09,s);
 end;//of if

 if b.Visibility>=0 then begin
  s:=#09'Visibility ';
  SaveController(b.Visibility,#09#09,s);
 end;//of if

 s:='}';writeln(ft,s);
End;
//---------------------------------------------------------
//��������� ������ ������
procedure SaveBones;
Var i:integer;
Begin
 for i:=0 to CountOfBones-1 do SaveTBone(true,bones[i]);
End;
//---------------------------------------------------------
//��������� ������ ����������
procedure SaveHelpers;
Var i:integer;
Begin
 for i:=0 to CountOfHelpers-1 do SaveTBone(false,helpers[i]);
End;
//---------------------------------------------------------
//��������� ��������� �����
procedure SaveLights;
Var i:integer;s,s2:string;
Begin
 if CountOfLights=0 then exit;    //������ ���������
 for i:=0 to CountOfLights-1 do begin
  //��������� ���������
  s:='Light "'+Lights[i].Skel.Name+'" {';
  writeln(ft,s);
  s:=#09'ObjectId '+inttostr(Lights[i].Skel.ObjectID)+',';
  writeln(ft,s);
  if Lights[i].Skel.Parent>=0 then begin
   s:=#09'Parent '+inttostr(Lights[i].Skel.Parent)+',';
   writeln(ft,s);
  end;//of if(Parent)

  //����� Billboard
  if Lights[i].Skel.IsBillboardedLockZ then begin
   s:=#09'BillboardedLockZ,';writeln(ft,s);
  end;//of if
  if Lights[i].Skel.IsBillboardedLockY then begin
   s:=#09'BillboardedLockY,';writeln(ft,s);
  end;//of if
  if Lights[i].Skel.IsBillboardedLockX then begin
   s:=#09'BillboardedLockX,';writeln(ft,s);
  end;//of if
  if Lights[i].Skel.IsBillboarded then begin
   s:=#09'Billboarded,';writeln(ft,s);
  end;//of if
  if Lights[i].Skel.IsCameraAnchored then begin
   s:=#09'CameraAnchored,';writeln(ft,s);
  end;//of if

  //���� DontInherit
  if Lights[i].Skel.IsDIRotation or Lights[i].Skel.IsDITranslation or
     Lights[i].Skel.IsDIScaling then begin
   s:=#09'DontInherit { ';s2:='';
   if Lights[i].Skel.IsDIRotation then s2:='Rotation';
   if Lights[i].Skel.IsDITranslation then s2:='Translation';
   if Lights[i].Skel.IsDIScaling then s2:='Scaling';
   s:=s+s2+' },';
   writeln(ft,s);
  end;//of if (Inherit)

  //��� ��������� �����
  case Lights[i].LightType of
   Omnidirectional:s:=#09'Omnidirectional,';
   Directional:s:=#09'Directional,';
   Ambient:s:=#09'Ambient,';
  end;//of case
  writeln(ft,s);

  //������������� � ����
  if Lights[i].AttenuationStart<>-1 then begin
   if Lights[i].IsASStatic then begin
    s:=#09'static AttenuationStart '+floattostrf(Lights[i].AttenuationStart,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(Lights[i].AttenuationStart),
            #09#09,#09'AttenuationStart ');
  end;//of if(AttStart)
  if Lights[i].AttenuationEnd<>-1 then begin
   if Lights[i].IsAEStatic then begin
    s:=#09'static AttenuationEnd '+floattostrf(Lights[i].AttenuationEnd,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(Lights[i].AttenuationEnd),
            #09#09,#09'AttenuationEnd ');
  end;//of if(AttEnd)

  if Lights[i].Intensity<>-1 then begin
   if Lights[i].IsIStatic then begin
    s:=#09'static Intensity '+floattostrf(Lights[i].Intensity,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(Lights[i].Intensity),
            #09#09,#09'Intensity ');
  end;//of if(Intensity)

  if Lights[i].Color[1]>-1 then begin
   if Lights[i].IsCStatic then begin
    s:=#09'static Color { '+floattostrf(Lights[i].Color[1],ffGeneral,7,5)+', '
                           +floattostrf(Lights[i].Color[2],ffGeneral,7,5)+', '
                           +floattostrf(Lights[i].Color[3],ffGeneral,7,5)+' },';
    writeln(ft,s);
   end else SaveController(round(Lights[i].Color[1]),
            #09#09,#09'Color ');
  end;//of if(Color)

  //� ��� �������������+����
  if Lights[i].AmbIntensity<>-1 then begin
   if Lights[i].IsAIStatic then begin
    s:=#09'static AmbIntensity '+floattostrf(Lights[i].AmbIntensity,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(Lights[i].AmbIntensity),
            #09#09,#09'AmbIntensity ');
  end;//of if(AmbInt)
  if Lights[i].AmbColor[1]>-1 then begin
   if Lights[i].IsACStatic then begin
    s:=#09'static AmbColor { '+floattostrf(Lights[i].AmbColor[1],ffGeneral,7,5)+', '
                           +floattostrf(Lights[i].AmbColor[2],ffGeneral,7,5)+', '
                           +floattostrf(Lights[i].AmbColor[3],ffGeneral,7,5)+' },';
    writeln(ft,s);
   end else SaveController(round(Lights[i].AmbColor[1]),
            #09#09,#09'AmbColor ');
  end;//of if(AmbColor)

  //������ - ����������� �������������
  if Lights[i].Skel.Visibility>=0 then
     SaveController(Lights[i].Skel.Visibility,#09#09,#09'Visibility ');
  if Lights[i].Skel.Translation>=0 then
     SaveController(Lights[i].Skel.Translation,#09#09,#09'Translation ');
  if Lights[i].Skel.Rotation>=0 then
     SaveController(Lights[i].Skel.Rotation,#09#09,#09'Rotation ');
  if Lights[i].Skel.Scaling>=0 then
     SaveController(Lights[i].Skel.Scaling,#09#09,#09'Scaling ');
  s:='}';
  writeln(ft,s);   
 end;//of for i
End;
//---------------------------------------------------------
//��������� ����� ������������
procedure SaveAttachments;
Var i:integer;s,s2:string;
Begin
 for i:=0 to CountOfAttachments-1 do with Attachments[i] do begin
  //1. ��������� ������
  s:='Attachment "'+Skel.Name+'" {';
  writeln(ft,s);
  if Skel.ObjectID>=0 then begin
   s:=#09'ObjectId '+inttostr(Skel.objectID)+',';
   writeln(ft,s);
  end;//of if
  if Skel.Parent>=0 then begin
   s:=#09'Parent '+inttostr(Skel.Parent)+',';
   writeln(ft,s);
  end;//of if

  //����� Billboard
  if Skel.IsBillboardedLockZ then begin
   s:=#09'BillboardedLockZ,';writeln(ft,s);
  end;//of if
  if Skel.IsBillboardedLockY then begin
   s:=#09'BillboardedLockY,';writeln(ft,s);
  end;//of if
  if Skel.IsBillboardedLockX then begin
   s:=#09'BillboardedLockX,';writeln(ft,s);
  end;//of if
  if Skel.IsBillboarded then begin
   s:=#09'Billboarded,';writeln(ft,s);
  end;//of if
  if Skel.IsCameraAnchored then begin
   s:=#09'CameraAnchored,';writeln(ft,s);
  end;//of if

    //���� DontInherit
  if Skel.IsDIRotation or Skel.IsDITranslation or
     Skel.IsDIScaling then begin
   s:=#09'DontInherit { ';s2:='';
   if Skel.IsDIRotation then s2:='Rotation';
   if Skel.IsDITranslation then s2:='Translation';
   if Skel.IsDIScaling then s2:='Scaling';
   s:=s+s2+' },';
   writeln(ft,s);
  end;//of if (Inherit)

  //���������� ����
  if AttachmentID>=0 then begin
   s:=#09'AttachmentID '+inttostr(AttachmentID)+',';
   writeln(ft,s);
  end;//of if
  if Path<>'' then begin
   s:=#09'Path "'+path+'",';
   writeln(ft,s);
  end;//of if

  //������ - ����������� �������������
  if Skel.Visibility>=0 then
     SaveController(Skel.Visibility,#09#09,#09'Visibility ');
  if Skel.Translation>=0 then
     SaveController(Skel.Translation,#09#09,#09'Translation ');
  if Skel.Rotation>=0 then
     SaveController(Skel.Rotation,#09#09,#09'Rotation ');
  if Skel.Scaling>=0 then
     SaveController(Skel.Scaling,#09#09,#09'Scaling ');

  //����� ������
  s:='}';writeln(ft,s);
 end;//of for i
End;
//---------------------------------------------------------
//���������� �������������� �������
procedure SavePivots;
Var i:integer;s:string;
Begin
 s:='PivotPoints '+inttostr(CountOfPivotPoints)+' {';
 writeln(ft,s);
 for i:=0 to CountOfPivotPoints-1 do begin
  s:=#09'{ '+floattostrf(PivotPoints[i,1],ffGeneral,7,5)+
        ', '+floattostrf(PivotPoints[i,2],ffGeneral,7,5)+
        ', '+floattostrf(PivotPoints[i,3],ffGeneral,7,5)+' },';
  writeln(ft,s); //floattostrf
 end;//of for i
 //��������� ������
 s:='}';writeln(ft,s);
End;
//---------------------------------------------------------
//��������� ��������� ������ ������ ������
procedure SaveParticleEmitters1;
Var i:integer;s:string;
Begin
 for i:=0 to CountOfParticleEmitters1-1 do with ParticleEmitters1[i] do begin
  //������ ���������
  s:='ParticleEmitter "'+Skel.name+'" {';
  writeln(ft,s);
  //�������� ������ �����
  if Skel.ObjectID>=0 then begin
   s:=#09'ObjectId '+inttostr(Skel.objectID)+',';
   writeln(ft,s);
  end;//of if
  if Skel.Parent>=0 then begin
   s:=#09'Parent '+inttostr(Skel.Parent)+',';
   writeln(ft,s);
  end;//of if
  //���� ������
  if UsesType=EmitterUsesTGA then s:=#09'EmitterUsesTGA,'
                             else s:=#09'EmitterUsesMDL,';
  writeln(ft,s);

  //������������������� ��������
  if EmissionRate<>-1 then begin
   if IsERStatic then begin
    s:=#09'static EmissionRate '+floattostrf(EmissionRate,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(EmissionRate),
            #09#09,#09'EmissionRate ');
  end;
  if Gravity<>cNone then begin
   if IsGStatic then begin
    s:=#09'static Gravity '+floattostrf(Gravity,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(Gravity),
            #09#09,#09'Gravity ');
  end;
  if Longitude<>-1 then begin
   if IsLongStatic then begin
    s:=#09'static Longitude '+floattostrf(Longitude,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(Longitude),
            #09#09,#09'Longitude ');
  end;
  if Latitude<>-1 then begin
   if IsLatStatic then begin
    s:=#09'static Latitude '+floattostrf(Latitude,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(Latitude),
            #09#09,#09'Latitude ');
  end;

  //���������� ���������� ���������
  if Skel.Visibility>=0 then
     SaveController(Skel.Visibility,#09#09,#09'Visibility ');

  //������ - ��������� ���������� �������
  s:=#09'Particle {';writeln(ft,s);//���������
  if LifeSpan<>-1 then begin
   if IsLSStatic then begin
    s:=#09#09'static LifeSpan '+floattostrf(LifeSpan,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(LifeSpan),
            #09#09#09,#09#09'LifeSpan ');
  end;//of if(LifeSpan)
  if InitVelocity<>cNone then begin
   if IsIVStatic then begin
    s:=#09#09'static InitVelocity '+floattostrf(InitVelocity,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(InitVelocity),
            #09#09#09,#09#09'InitVelocity ');
  end;//of if(InitVelocity)
  if Path<>'' then begin
   s:=#09#09'Path "'+path+'",';
   writeln(ft,s);
  end;//of if(Path)
  //��������� ���������
  s:=#09'}';writeln(ft,s);

  //���������� �����������
  if Skel.Translation>=0 then
     SaveController(Skel.Translation,#09#09,#09'Translation ');
  if Skel.Rotation>=0 then
     SaveController(Skel.Rotation,#09#09,#09'Rotation ');
  if Skel.Scaling>=0 then
     SaveController(Skel.Scaling,#09#09,#09'Scaling ');

  //������� ������:
  s:='}';writeln(ft,s);
//  ParticleEmitters1[i]
 end;//of for i
End;
//---------------------------------------------------------
//��������� ��������� ������ ����� ������
procedure SaveParticleEmitters2;
Var i,ii{,j}:integer;s,s2:string;
Begin
 for i:=0 to CountOfParticleEmitters-1 do with pre2[i] do begin
  //�������� ���������
  s:='ParticleEmitter2 "'+Skel.name+'" {';
  writeln(ft,s);
  //����������� ID
  if Skel.ObjectID>=0 then begin
   s:=#09'ObjectId '+inttostr(Skel.objectID)+',';
   writeln(ft,s);
  end;//of if
  if Skel.Parent>=0 then begin
   s:=#09'Parent '+inttostr(Skel.Parent)+',';
   writeln(ft,s);
  end;//of if

  //������������
  if Skel.IsDIRotation or Skel.IsDITranslation or
     Skel.IsDIScaling then begin
   s:=#09'DontInherit { ';s2:='';
   if Skel.IsDIRotation then s2:='Rotation';
   if Skel.IsDITranslation then s2:='Translation';
   if Skel.IsDIScaling then s2:='Scaling';
   s:=s+s2+' },';
   writeln(ft,s);
  end;//of if (Inherit)

  if IsSortPrimsFarZ then begin
   s:=#09'SortPrimsFarZ,';writeln(ft,s);
  end;//of if
  if IsUnshaded then begin
   s:=#09'Unshaded,';writeln(ft,s);
  end;//of if
  if IsLineEmitter then begin
   s:=#09'LineEmitter,';writeln(ft,s);
  end;//of if
  if IsUnfogged then begin
   s:=#09'Unfogged,';writeln(ft,s);
  end;//of if
  if IsModelSpace then begin
   s:=#09'ModelSpace,';writeln(ft,s);
  end;//of if
  if IsXYQuad then begin
   s:=#09'XYQuad,';writeln(ft,s);
  end;//of if

  //������ ������������������� ����������
  if Speed<>cNone then begin
   if IsSStatic then begin
    s:=#09'static Speed '+floattostrf(Speed,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(Speed),
            #09#09,#09'Speed ');
  end;//of if(Speed)
  if Variation<>-1 then begin
   if IsVStatic then begin
    s:=#09'static Variation '+floattostrf(Variation,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(Variation),
            #09#09,#09'Variation ');
  end;//of if(Variation)
  if Latitude<>cNone then begin
   if IsLStatic then begin
    s:=#09'static Latitude '+floattostrf(Latitude,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(Latitude),
            #09#09,#09'Latitude ');
  end;//of if(Latitude)
  if Gravity<>cNone then begin
   if IsGStatic then begin
    s:=#09'static Gravity '+floattostrf(Gravity,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(Gravity),
            #09#09,#09'Gravity ');
  end;//of if(Gravity)

  //���������� ���������
  if Skel.Visibility>=0 then
     SaveController(Skel.Visibility,#09#09,#09'Visibility ');
  //���� �����
  if IsSquirt then begin
   s:=#09'Squirt,';writeln(ft,s);
  end;//of if
  //����� �����:
  if LifeSpan<>cNone then begin
   s:=#09'LifeSpan '+floattostrf(LifeSpan,ffGeneral,7,5)+',';
   writeln(ft,s);
  end;//of if(LifeSpan)

  //��� ������ ������������������� ����������
  if EmissionRate<>cNone then begin
   if IsEStatic then begin
    s:=#09'static EmissionRate '+floattostrf(EmissionRate,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(EmissionRate),
            #09#09,#09'EmissionRate ');
  end;//of if(EmissionRate)
  //������, ������
  if IsWStatic then begin
   s:=#09'static Width '+floattostrf(Width,ffGeneral,7,5)+',';
   writeln(ft,s);
  end else SaveController(round(Width),#09#09,#09'Width ');
  if IsHStatic then begin
   s:=#09'static Length '+floattostrf(Length,ffGeneral,7,5)+',';
   writeln(ft,s);
  end else SaveController(round(Length),#09#09,#09'Length ');

  //����� ��������
  case BlendMode of
   FullAlpha:s:=#09'Blend,';
   Additive:s:=#09'Additive,';
   Modulate:s:=#09'Modulate,';
   AlphaKey:s:=#09'AlphaKey,';
  end;//of case
  writeln(ft,s);

  //������, �������
  s:=#09'Rows '+inttostr(Rows)+',';
  writeln(ft,s);
  s:=#09'Columns '+inttostr(Columns)+',';
  writeln(ft,s);

  //��� �����������
  case ParticleType of
   ptHead:s:=#09'Head,';
   ptTail:s:=#09'Tail,';
   ptBoth:s:=#09'Both,';
  end;//of case
  writeln(ft,s);

  //����� ������, �����
  if TailLength>=0 then begin
    s:=#09'TailLength '+floattostrf(TailLength,ffGeneral,7,5)+',';
    writeln(ft,s);
  end;//of if(TailLength)
  if Time>=0 then begin
    s:=#09'Time '+floattostrf(Time,ffGeneral,7,5)+',';
    writeln(ft,s);
  end;//of if(Time)

  //�������
  s:=#09'SegmentColor {';writeln(ft,s); //���������
  for ii:=1 to 3 do begin
   s:=#09#09'Color { '+floattostrf(SegmentColor[ii,1],ffGeneral,7,5)+
            ', '+floattostrf(SegmentColor[ii,2],ffGeneral,7,5)+
            ', '+floattostrf(SegmentColor[ii,3],ffGeneral,7,5)+' },';
   writeln(ft,s);
  end;//of for ii
  s:=#09'},';writeln(ft,s);        //������� ���������

  //������������
  s:=#09'Alpha {'+inttostr(Alpha[1])+', '+inttostr(Alpha[2])+', '+
        inttostr(Alpha[3])+'},';
  writeln(ft,s);
  //�������
  s:=#09'ParticleScaling {'+floattostrf(ParticleScaling[1],ffGeneral,7,5)+
        ', '+floattostrf(ParticleScaling[2],ffGeneral,7,5)+', '+
             floattostrf(ParticleScaling[3],ffGeneral,7,5)+'},';
  writeln(ft,s);
  //UV-���������
  s:=#09'LifeSpanUVAnim {'+inttostr(LifeSpanUVAnim[1])+', '
        +inttostr(LifeSpanUVAnim[2])+', '
        +inttostr(LifeSpanUVAnim[3])+'},';
  writeln(ft,s);
  s:=#09'DecayUVAnim {'+inttostr(DecayUVAnim[1])+', '
        +inttostr(DecayUVAnim[2])+', '
        +inttostr(DecayUVAnim[3])+'},';
  writeln(ft,s);
  s:=#09'TailUVAnim {'+inttostr(TailUVAnim[1])+', '
        +inttostr(TailUVAnim[2])+', '
        +inttostr(TailUVAnim[3])+'},';
  writeln(ft,s);
  s:=#09'TailDecayUVAnim {'+inttostr(TailDecayUVAnim[1])+', '
        +inttostr(TailDecayUVAnim[2])+', '
        +inttostr(TailDecayUVAnim[3])+'},';
  writeln(ft,s);

  //�������� � ��� ID
  if TextureID>=0 then begin
   s:=#09'TextureID '+inttostr(TextureID)+',';
   writeln(ft,s);
  end;//of if (Texture)
  if ReplaceableId>0 then begin
   s:=#09'ReplaceableId '+inttostr(ReplaceableId)+',';
   writeln(ft,s);
  end;//of if (ReplaceableId)
  if PriorityPlane>=0 then begin
   s:=#09'PriorityPlane '+inttostr(PriorityPlane)+',';
   writeln(ft,s);
  end;//of if (PriorityPlane)

  //�, �������, ����������� ��������
  if Skel.Translation>=0 then
     SaveController(Skel.Translation,#09#09,#09'Translation ');
  if Skel.Rotation>=0 then
     SaveController(Skel.Rotation,#09#09,#09'Rotation ');
  if Skel.Scaling>=0 then
     SaveController(Skel.Scaling,#09#09,#09'Scaling ');

  s:='}';writeln(ft,s);           //������� ������
 end;//of for i
End;
//---------------------------------------------------------
//��������� ��������� �����
procedure SaveRibbonEmitters;
Var s:string;i:integer;
Begin
 for i:=0 to CountOfRibbonEmitters-1 do with ribs[i] do begin
  s:='RibbonEmitter "'+Skel.Name+'" {';
  writeln(ft,s);                  //������
  //����������� ID
  if Skel.ObjectID>=0 then begin
   s:=#09'ObjectId '+inttostr(Skel.objectID)+',';
   writeln(ft,s);
  end;//of if
  if Skel.Parent>=0 then begin
   s:=#09'Parent '+inttostr(Skel.Parent)+',';
   writeln(ft,s);
  end;//of if

  //������������������� ���������
  if HeightAbove<>cNone then begin
   if IsHAStatic then begin
    s:=#09'static HeightAbove '+floattostrf(HeightAbove,ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(HeightAbove),#09#09,#09'HeightAbove ');
  end;//of if
  if HeightBelow<>cNone then begin
   if IsHBStatic then begin
    s:=#09'static HeightBelow '+floattostrf(HeightBelow,ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(HeightBelow),#09#09,#09'HeightBelow ');
  end;//of if
  if Alpha>-1 then begin
   if IsAlphaStatic then begin
    s:=#09'static Alpha '+floattostrf(Alpha,ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(Alpha),#09#09,#09'Alpha ');
  end;//of if

   if IsColorStatic then begin
    s:=#09'static Color { '+floattostrf(Color[1],ffGeneral,7,5)+', '+
                           floattostrf(Color[2],ffGeneral,7,5)+', '+
                           floattostrf(Color[3],ffGeneral,7,5)+' },';
    writeln(ft,s);
   end else SaveController(round(Color[1]),#09#09,#09'Color ');

  if TextureSlot>-1 then begin
   if IsTSStatic then begin
    s:=#09'static TextureSlot '+inttostr(TextureSlot)+',';
    writeln(ft,s);
   end else SaveController(TextureSlot,#09#09,#09'TextureSlot ');
  end;//of if

  //���������� ���������
  if Skel.Visibility>=0 then
     SaveController(Skel.Visibility,#09#09,#09'Visibility ');

  //��� ������ ����������
  if EmissionRate<>cNone then begin
    s:=#09'EmissionRate '+inttostr(EmissionRate)+',';
    writeln(ft,s);
  end;//of if(EmissionRate)
  if LifeSpan>=0 then begin
    s:=#09'LifeSpan '+floattostrf(LifeSpan,ffGeneral,7,5)+',';
    writeln(ft,s);
  end;//of if(LifeSpan)
  if Gravity<>cNone then begin
    s:=#09'Gravity '+floattostrf(Gravity,ffGeneral,7,5)+',';
    writeln(ft,s);
  end;//of if(Gravity)
  if Rows>0 then begin
    s:=#09'Rows '+inttostr(Rows)+',';
    writeln(ft,s);
  end;//of if(Rows)
  if Columns>0 then begin
    s:=#09'Columns '+inttostr(Columns)+',';
    writeln(ft,s);
  end;//of if(Columns)
  if MaterialID>=0 then begin
    s:=#09'MaterialID '+inttostr(MaterialID)+',';
    writeln(ft,s);
  end;//of if(MaterialID)

  //���������� �����������
  if Skel.Translation>=0 then
     SaveController(Skel.Translation,#09#09,#09'Translation ');
  if Skel.Rotation>=0 then
     SaveController(Skel.Rotation,#09#09,#09'Rotation ');
  if Skel.Scaling>=0 then
     SaveController(Skel.Scaling,#09#09,#09'Scaling ');

  //������� ������
  s:='}';writeln(ft,s);
 end;//of for i
End;
//---------------------------------------------------------
//��������� ������
procedure SaveCameras;
Var s:string;i:integer;
Begin
 for i:=0 to CountOfCameras-1 do with Cameras[i] do begin
  //��������� ������
  s:='Camera "'+name+'" {';
  writeln(ft,s);

  //������ �������
  s:=#09'Position { '+floattostrf(position[1],ffGeneral,7,5)+', '+
                      floattostrf(position[2],ffGeneral,7,5)+', '+
                      floattostrf(position[3],ffGeneral,7,5)+' },';
  writeln(ft,s);
  //������ ������������ �������
  if TranslationGraphNum>=0 then
     SaveController(TranslationGraphNum,#09#09,#09'Translation ');
  if RotationGraphNum>=0 then
     SaveController(RotationGraphNum,#09#09,#09'Rotation ');

  //���� ������
  if FieldOfView>=0 then begin
   s:=#09'FieldOfView '+floattostrf(FieldOfView,ffGeneral,7,5)+',';
   writeln(ft,s);
  end;//of if FieldOfView
  if FarClip<>cNone then begin
   s:=#09'FarClip '+floattostrf(FarClip,ffGeneral,7,5)+',';
   writeln(ft,s);
  end;//of if FarClip
  if NearClip<>cNone then begin
   s:=#09'NearClip '+floattostrf(NearClip,ffGeneral,7,5)+',';
   writeln(ft,s);
  end;//of if NearClip

  //���� ������
  s:=#09'Target {';writeln(ft,s); //��������� ���������
  s:=#09#09'Position { '+floattostrf(Targetposition[1],ffGeneral,7,5)+', '+
                      floattostrf(Targetposition[2],ffGeneral,7,5)+', '+
                      floattostrf(Targetposition[3],ffGeneral,7,5)+' },';
  writeln(ft,s);
  if TranslationGraphNum>=0 then
     SaveController(TargetTGNum,#09#09#09,#09#09'Translation ');
  //������� ���������
  s:=#09'}';writeln(ft,s);
  //������� ������
  s:='}';writeln(ft,s);
 end;//of for i
End;
//---------------------------------------------------------
//��������� ������� (�����������)
procedure SaveEvents;
Var s:string;i,ii:integer;
Begin
 for i:=0 to CountOfEvents-1 do with events[i] do begin
  s:='EventObject "'+uppercase(Skel.name)+'" {';
  writeln(ft,s);
  //��������� �����
  if Skel.ObjectID>=0 then begin
   s:=#09'ObjectId '+inttostr(Skel.objectID)+',';
   writeln(ft,s);
  end;//of if
  if Skel.Parent>=0 then begin
   s:=#09'Parent '+inttostr(Skel.Parent)+',';
   writeln(ft,s);
  end;//of if

  //���������� ������ ������ ������������
  s:=#09'EventTrack '+inttostr(CountOfTracks)+' {';
  writeln(ft,s);
  for ii:=0 to CountOfTracks-1 do begin
   s:=#09#09+inttostr(Tracks[ii])+',';
   writeln(ft,s);
  end;//of for ii
  s:=#09'}';writeln(ft,s);

  //�����������
  if Skel.Translation>=0 then
     SaveController(Skel.Translation,#09#09,#09'Translation ');
  if Skel.Rotation>=0 then
     SaveController(Skel.Rotation,#09#09,#09'Rotation ');
  if Skel.Scaling>=0 then
     SaveController(Skel.Scaling,#09#09,#09'Scaling ');

  s:='}';writeln(ft,s);
 end;//of for i
End;
//---------------------------------------------------------
//������ �������� ������
procedure SaveCollisionObjects;
Var s:string;i,ii:integer;
Begin
 for i:=0 to CountOfCollisionShapes-1 do with Collisions[i] do begin
  s:='CollisionShape "'+Skel.name+'" {';
  writeln(ft,s);

  //��������� �����
  if Skel.ObjectID>=0 then begin
   s:=#09'ObjectId '+inttostr(Skel.objectID)+',';
   writeln(ft,s);
  end;//of if
  if Skel.Parent>=0 then begin
   s:=#09'Parent '+inttostr(Skel.Parent)+',';
   writeln(ft,s);
  end;//of if

  //��� �������
  if objType=cBox then s:=#09'Box,' else s:=#09'Sphere,';
  writeln(ft,s);
  //������ ������
  s:=#09'Vertices '+inttostr(Collisions[i].CountOfVertices)+' {';
  writeln(ft,s);
  //���������� ������ �������
  for ii:=0 to Collisions[i].CountOfVertices-1 do begin
   s:=#09#09'{ '+floattostrf(Collisions[i].Vertices[ii,1],ffGeneral,7,5)+
            ', '+floattostrf(Collisions[i].Vertices[ii,2],ffGeneral,7,5)+
            ', '+floattostrf(Collisions[i].Vertices[ii,3],ffGeneral,7,5)+
            ' },';
   writeln(ft,s);
  end;//of for ii
  s:=#09'}';writeln(ft,s);

  //��������� ������
  if (objType=cSphere) and (BoundsRadius>=0) then begin
   s:=#09'BoundsRadius '+floattostrf(BoundsRadius,ffGeneral,7,5)+',';
   if pos('INF',s)=0 then writeln(ft,s);
  end;//of if BoundsRadius

  //�����������
  if Skel.Translation>=0 then
     SaveController(Skel.Translation,#09#09,#09'Translation ');
  if Skel.Rotation>=0 then
     SaveController(Skel.Rotation,#09#09,#09'Rotation ');
  if Skel.Scaling>=0 then
     SaveController(Skel.Scaling,#09#09,#09'Scaling ');

  //����� ������
  s:='}';writeln(ft,s);
 end;//of for i
End;
//---------------------------------------------------------
//��������� �������� WoW ��� ����������� ��������
//fname - ��� ����� ������
{procedure SaveHierarchy(fName:string);
Var fh:file of integer;i:integer;
Begin
 //1. ������� ���� "MDH"
 fname[length(fname)]:='h';
 //2. �������� ���
 AssignFile(fh,fname);
 rewrite(fh);
 //3. ������ ���� HierID
 for i:=0 to CountOfGeosets-1 do write(fh,Geosets[i].HierID);
 CloseFile(fh);
End;
//---------------------------------------------------------
procedure DeleteHierarchy(fName:string);
Begin
 //1. ������� ���� "MDH"
 fname[length(fname)]:='h';
 DeleteFile(fname);
End;}
//---------------------------------------------------------

//������ ����. ���������� MdlVis
procedure MDLSaveMdlVisInformation;
Var s:string; i,ii,len:integer;
Begin
 if not IsCanSaveMDVI then exit;
 if (not IsWoW) and (COMidNormals=0) and (COConstNormals=0) then exit;
 
 s:='MDLVisInformation {'; writeln(ft,s);

 //1. ���� �����, ������� WoW-��������
 if IsWoW then begin
  s:=#09'WoWHierarchy {'; writeln(ft,s);
  s:=#09#09;
  for i:=0 to CountOfGeosets-1 do s:=s+inttostr(Geosets[i].HierID)+',';
  writeln(ft,s);
  s:=#09'}'; writeln(ft,s);
 end;//of if

 //2.0. ��������, ���� �� ������ �����������
 i:=0;
 while i<COMidNormals do begin
  if length(MidNormals[i])=0 then begin
   for ii:=i to COMidNormals-2 do MidNormals[ii]:=MidNormals[ii+1];
   dec(COMidNormals);
   SetLength(MidNormals,COMidNormals);
   continue;
  end;//of if
  inc(i);
 end;//of while
 
 //2. ���� �����, ������� ������ �����������
 if COMidNormals>0 then begin
  s:=#09'SmoothGroups '+inttostr(COMidNormals)+' {';
  writeln(ft,s);
  for i:=0 to COMidNormals-1 do begin
   len:=length(MidNormals[i]);
   s:=#09#09'SGroup '+inttostr(len)+' { ';
   for ii:=0 to len-1 do begin
    s:=s+inttostr(MidNormals[i,ii].GeoID)+', '+
         inttostr(MidNormals[i,ii].VertID)+',  ';
   end;//of for ii
   s:=s+'},'; writeln(ft,s);
  end;//of for i
  s:=#09'}';
  writeln(ft,s);
 end;//of if

 //3. ���� �����, ������� ����������� �������
 if COConstNormals>0 then begin
  s:=#09'EditedNormals '+inttostr(COConstNormals)+' {';
  writeln(ft,s);
  for i:=0 to COConstNormals-1 do begin
   s:=#09#09'{ '+inttostr(ConstNormals[i].GeoID)+', '+
                 inttostr(ConstNormals[i].VertID)+',  '+
      floattostrf(ConstNormals[i].n[1],ffGeneral,7,5)+', '+
      floattostrf(ConstNormals[i].n[1],ffGeneral,7,5)+', '+
      floattostrf(ConstNormals[i].n[1],ffGeneral,7,5)+' },';
   writeln(ft,s);
  end;//of for i
  s:=#09'}'; writeln(ft,s);
 end;//of if
 s:='}'; writeln(ft,s);
End;
//---------------------------------------------------------
//��������� ����
procedure SaveMDL(fname:string);
Var i,Gz:integer;//sEnd:string;
Begin
 assignFile(ft,fname);             //������� ����
 rewrite(ft);                      //������� ������
 //��������: ��� �� ����������� �������� �������
 //! ��� ������ ���� ��������� ����������� ������ ���.
 Gz:=0;
 for i:=0 to CountOfGeosets-1 do if Geosets[i].CountOfVertices=0 then inc(Gz);
 //������ �������� (���� ����)
 //(�������� � ������ ����. ����������)
// if IsWoW then SaveHierarchy(fname) else DeleteHierarchy(fname);
 //������ ���������
 SaveHeader(Gz);
 //������ �������������������
 SaveSequences;
 //������ �������
 SaveTextures;
 //������ ����������
 SaveMaterials;
 //������ ������ ���������� ��������
 SaveTextureAnims;

 //������ �������� ��� ������������
 for i:=1 to CountOfGeosets-1 do begin
  RecalcNormals(i);                 //����������� �������
  SmoothWithNormals(i-1);           //��������
 end;//of for i
 ApplySmoothGroups;

 //������ ���� ������������
 for i:=1 to CountOfGeosets do begin
  if Geosets[i-1].CountOfVertices=0 then continue;
  writeln(ft,'Geoset {');           //������ ���������
  SaveVertices(i);                  //������� ������ ������
  SaveNormals(i);                   //������� ������ ��������
  SaveTVertices(i);                 //������ ���������� �-�
  SaveVertexGroup(i);               //������� ������ �����
  SaveFaces(i);                     //�������� ���������
  SaveGroups(i);                    //�������� ����������� �� ������
  RecalcBounds(i);                  //����������� �������
  SaveBounds(i);                    //�������� �������
  SaveTail(i);                      //�������� �������
 end;//of for
 SaveGeosetAnims;
 SaveBones;
 SaveLights;
 SaveHelpers;
 SaveAttachments;
 SavePivots;
 SaveParticleEmitters1;
 SaveParticleEmitters2;
 SaveRibbonEmitters;              //��������� �����
 SaveCameras;
 SaveEvents;
 SaveCollisionObjects;
 MDLSaveMdlVisInformation;        //������ ���������� MdlVis (����. ������)
 closeFile(ft);
End;
//===============����� �������� ���������� MDX=============
//���������������: �������� ����� �����
procedure SaveLong(l:integer);
Begin
 BlockWrite(fm,l,4);              //������
End;
procedure SaveFloat(f:single);
Begin
 BlockWrite(fm,f,4);
End;
procedure SaveShort(s:integer);
Var s2:word;
Begin
 s2:=LoWord(s);
 BlockWrite(fm,s2,2);
End;
procedure SaveByte(b:integer);
Var b2:byte;
Begin
 b2:=LoByte(LoWord(b));
 BlockWrite(fm,b2,1);
End;
//������ ������ ���������� �������
procedure SaveASCII(s:string;sz:integer);
var c:array[0..$200] of char;
Begin
 FillChar(c[0],$200,0);           //���������� ������
 Move(s[1],c[0],length(s));       //�����������
 BlockWrite(fm,c[0],sz);          //������
End;
//��������� ������� ����� �������
procedure MemorizeSizePos(IsI:boolean);
Begin
 fSizes[fsCurNum].fPos:=FilePos(fm);
 fSizes[fsCurNum].IsI:=IsI;
 inc(fsCurNum);
End;
//�������� ���� �������
procedure SaveSize;
Var ps,sz:integer;
Begin
 ps:=FilePos(fm);
 sz:=ps-fSizes[fsCurNum-1].fPos;
 if not fSizes[fsCurNum-1].IsI then sz:=sz-4;
 Seek(fm,fSizes[fsCurNum-1].fPos);
 SaveLong(sz);
 Seek(fm,ps);
 dec(fsCurnum);
End;
//---------------------------------------------------------
//�������.: ���������� ������
procedure MDXSaveAnimBounds(b:TAnim);
Var i:integer;
Begin
 //1. ��������
{ for i:=1 to 3 do if b.MinimumExtent[i]<0 then b.MinimumExtent[i]:=0;
 for i:=1 to 3 do if b.MaximumExtent[i]<0 then b.MaximumExtent[i]:=0;}
 if b.BoundsRadius<0 then b.BoundsRadius:=0;
 //2. ������
 SaveFloat(b.BoundsRadius);
 for i:=1 to 3 do SaveFloat(b.MinimumExtent[i]);
 for i:=1 to 3 do SaveFloat(b.MaximumExtent[i]);
End;
//---------------------------------------------------------
//������ ������������ �������������������
procedure MDXSaveSequences;
Const sqSize=$50+13*4;
Var i:integer;
Begin
 if CountOfSequences=0 then exit; //��� �������������������
 SaveLong(TagSEQS);               //������ ����
 SaveLong(CountOfSequences*sqSize);//������ ������
 for i:=0 to CountOfSequences-1 do with Sequences[i] do begin
  SaveASCII(Name,$50);
  SaveLong(IntervalStart);
  SaveLong(IntervalEnd);
  if MoveSpeed<=0 then SaveFloat(0)
                  else SaveFloat(MoveSpeed);
  if IsNonLooping then SaveLong(1)
                  else SaveLong(0);
  if Rarity<=0 then SaveFloat(0)
               else SaveFloat(Rarity);
  SaveLong(0);                    //???
  MDXSaveAnimBounds(Bounds);
 end;//of for i
End;
//---------------------------------------------------------
//������ ���������� �������������������
procedure MDXSaveGlobalSequences;
Var i:integer;
Begin
 if CountOfGlobalSequences=0 then exit;
 SaveLong(TagGLBS);
 SaveLong(CountOfGlobalSequences*4);//������ ������� ������
 for i:=0 to CountOfGlobalSequences-1 do SaveLong(GlobalSequences[i]);
End;
//---------------------------------------------------------
//������ �����������
procedure MDXSaveController(tag,ContNum:integer;IsColor,IsStateLong:boolean);
Var i,ii:integer;
Begin
 if ContNum<0 then exit;          //������ �� �����
 SaveLong(tag);                   //������ ����
 with Controllers[ContNum] do begin
  SaveLong(length(items));        //���-�� ���������
  SaveLong(ContType-1);           //��� �����������
  SaveLong(GlobalSeqID);
  //������ - ���������� ������
  for i:=0 to Length(items)-1 do begin
   SaveLong(Items[i].Frame);      //������ ������ �����
   if IsColor then begin          //������ � ����� �����
    for ii:=SizeOfElement downto 1 do SaveFloat(items[i].Data[ii]);
    if (ContType=Bezier) or (ContType=Hermite) then begin
     for ii:=SizeOfElement downto 1 do SaveFloat(items[i].InTan[ii]);
     for ii:=SizeOfElement downto 1 do SaveFloat(items[i].OutTan[ii]);
    end;//of if
   end else begin                 //������� ������
    if IsStateLong then SaveLong(round(items[i].Data[1])) else begin
     for ii:=1 to SizeOfElement do SaveFloat(items[i].Data[ii]);
     if (ContType=Bezier) or (ContType=Hermite) then begin
      for ii:=1 to SizeOfElement do SaveFloat(items[i].InTan[ii]);
      for ii:=1 to SizeOfElement do SaveFloat(items[i].OutTan[ii]);
     end;//of if(ContType)
    end;//of if(IsStateLong)
   end;//of if (IsColor)
  end;//of for i
 end;//of with
End;
//---------------------------------------------------------
//������ ����
procedure MDXSaveLayer(l:TLayer);
Var tmp:integer;
Begin
 MemorizeSizePos(true);           //������ �������
 SaveLong(0);                     //������ �����
 case l.FilterMode of             //������ ������� ��������
  Opaque:tmp:=0;
  ColorAlpha:tmp:=1;
  FullAlpha:tmp:=2;
  Additive:tmp:=3;
  AddAlpha:tmp:=4;
  Modulate:l.FilterMode:=5;
  else tmp:=Modulate2X;
 end;//of case
 SaveLong(tmp);                   //��� ������

// SaveLong(l.FilterMode-1);        //������ ������ ��������
 //��������� �����
 tmp:=0;
 if l.IsUnshaded then tmp:=tmp or 1;
 if l.IsSphereEnvMap then tmp:=tmp or 2;
 if l.IsTwoSided then tmp:=tmp or 16;
 if l.IsUnfogged then tmp:=tmp or 32;
 if l.IsNoDepthTest then tmp:=tmp or 64;
 if l.IsNoDepthSet then tmp:=tmp or 128;
 SaveLong(tmp);
 if l.IsTextureStatic then SaveLong(l.TextureID)
                    else SaveLong(0);
 SaveLong(l.TVertexAnimID);
 if l.CoordID<=0 then SaveLong(0)
                 else SaveLong(l.CoordID);
 if l.IsAlphaStatic then begin
  if l.Alpha<=0 then SaveFloat(1) else SaveFloat(l.Alpha);
 end else SaveFloat(1);
 //������ ������������
 if not l.IsAlphaStatic then
        MDXSaveController(tagKMTA,l.NumOfGraph,false,false);
 if not l.IsTextureStatic then
        MDXSaveController(tagKMTF,l.NumOfTexGraph,false,true);
 //�������� ������
 SaveSize;
End;
//---------------------------------------------------------
//���������� ����������
procedure MDXSaveMaterials;
Var i,ii,tmp:integer;
Const mtSize=3*4;
Begin
 if CountOfMaterials=0 then exit;
 SaveLong(TagMTLS);               //������ ����
 //����������� ����� ��� ������ ������
 MemorizeSizePos(false);          //��������� �������
 SaveLong(0);                     //������ �����
 for i:=0 to CountOfMaterials-1 do with Materials[i] do begin
  MemorizeSizePos(true);          //������� �������
  SaveLong(0);
  if PriorityPlane<=0 then SaveLong(0)
                      else SaveLong(PriorityPlane);
  //��������� �����
  tmp:=0;
  if IsConstantColor then tmp:=tmp or 1;
  if IsSortPrimsFarZ then tmp:=tmp or 16;
  if IsFullResolution then tmp:=tmp or 32;
  SaveLong(tmp);                  //������ ������

  //������ ����� ����
  SaveLong(TagLAYS);              //������ ����
  SaveLong(CountOfLayers);        //������ ���-�� �����
  for ii:=0 to CountOfLayers-1 do MDXSaveLayer(Layers[ii]);

  SaveSize;                       //������ ������ ���������
 end;//of for i
 SaveSize;                        //����� ������ ������
End;
//---------------------------------------------------------
//��������� ��������
procedure MDXSaveTextures;
Var i,tmp:integer;
Const txSize=$100+3*4;
Begin
 if CountOfTextures=0 then exit;
 SaveLong(TagTEXS);               //��� ������
 SaveLong(txSize*CountOfTextures);//������ ������
 for i:=0 to CountOfTextures-1 do with Textures[i] do begin
  if ReplaceableID<=0 then SaveLong(0)
                      else SaveLong(ReplaceableID);
  SaveASCII(FileName,$100);
  SaveLong(0);                    //???
  //��������� �����
  tmp:=0;
  if IsWrapWidth then tmp:=tmp or 1;
  if IsWrapHeight then tmp:=tmp or 2;
  SaveLong(tmp);
 end;//of for i
End;
//---------------------------------------------------------
//������ ������ ���������� �������
procedure MDXSaveTextureAnims;
Var i:integer;
Begin
 if CountOfTextureAnims=0 then exit;
 SaveLong(TagTXAN);               //������ ����
 MemorizeSizePos(false);          //��������� �������
 SaveLong(0);                     //������ �����
 for i:=0 to CountOfTextureAnims-1 do with TextureAnims[i] do begin
  MemorizeSizePos(true);
  SaveLong(0);
  //������ ������������
  MDXSaveController(tagKTAT,TranslationGraphNum,false,false);
  MDXSaveController(tagKTAR,RotationGraphNum,false,false);
  MDXSaveController(tagKTAS,ScalingGraphNum,false,false);
  SaveSize;
 end;//of for i
 SaveSize;
End;
//---------------------------------------------------------
//���������� ���� ������������
procedure MDXSaveGeosets;
Var i,ii,j,tmp:integer;
const a:array[1..20] of byte=(
      $50, $54, $59, $50, $01, $00, $00, $00,
      $04, $00, $00, $00, $50, $43, $4E, $54,
      $01, $00, $00, $00);
Begin
 if CountOfGeosets=0 then begin
  MessageBox(0,'� ������ ����������� �����������','��������!',mb_iconstop);
  exit;
 end;//of if
 //�������� ������
 SaveLong(TagGEOS);               //������ ����
 MemorizeSizePos(false);
 SaveLong(0);                     //����� ��� ������

 for i:=0 to CountOfGeosets-1 do begin
  RecalcNormals(i+1);             //������ ��������
  SmoothWithNormals(i);
 end;//of for i
 ApplySmoothGroups;

 //������ ������ �����������
 for i:=0 to CountOfGeosets-1 do with Geosets[i] do begin
  MemorizeSizePos(true);
  SaveLong(0);                    //����� ��� ������ �����������
  //1. ������ ������ ������
  SaveLong(tagVRTX);
  SaveLong(CountOfVertices);      //������ ���-�� ������
  for ii:=0 to CountOfVertices-1 do for j:=1 to 3 do SaveFloat(Vertices[ii,j]);
  //2. ������ � ������ ��������
  SaveLong(TagNRMS);              //������ ����
  SaveLong(CountOfNormals);       //���-�� ��������
  for ii:=0 to CountOfNormals-1 do for j:=1 to 3 do SaveFloat(Normals[ii,j]);
  //3. ������ ������, ��������� � ��������������
  BlockWrite(fm,a[1],20);         //������ ������ ����������
  SaveLong(length(Faces[0]));     //������ ���-�� �����.
  SaveLong(TagPVTX);              //��� ������
  SaveLong(length(Faces[0]));     //������ ��������
  for ii:=0 to length(Faces[0])-1 do SaveShort(Faces[0,ii]);
  //4. ������ ������� ����� ������
  SaveLong(TagGNDX);              //���
  SaveLong(CountOfVertices);      //! ���� �� ���-�� �����
  for ii:=0 to CountOfVertices-1 do SaveByte(VertexGroup[ii]);
  //5. ������ ���� ������
  SaveLong(TagMTGC);
  SaveLong(CountOfMatrices);
  for ii:=0 to CountOfMatrices-1 do SaveLong(length(Groups[ii]));
  //6. ���������� ������ ������
  SaveLong(TagMATS);
  tmp:=0;                         //�������� ���-�� �����
  for ii:=0 to CountOfMatrices-1 do tmp:=tmp+length(Groups[ii]);
  SaveLong(tmp);                  //������ ���-��
  for ii:=0 to CountOfMatrices-1 do
        for j:=0 to length(Groups[ii])-1 do SaveLong(Groups[ii,j]);

  //7. ��� �������������� �����
  SaveLong(MaterialID);           //��������
  if SelectionGroup<=0 then SaveLong(0)
                       else SaveLong(SelectionGroup);
  if Unselectable then SaveLong(4)
                  else SaveLong(0);
  //8. ������� �����������
  RecalcBounds(i+1);              //����������� ��
  if BoundsRadius<0 then SaveFloat(0)
                    else SaveFloat(BoundsRadius);
  for ii:=1 to 3 do SaveFloat(MinimumExtent[ii]);
  for ii:=1 to 3 do SaveFloat(MaximumExtent[ii]);
  //9. ����� ������������ ������
  SaveLong(CountOfAnims);
  for ii:=0 to CountOfAnims-1 do MDXSaveAnimBounds(anims[ii]);

  //10. ������ �������
  SaveLong(TagUVAS);SaveLong(CountOfCoords);
  for j:=0 to CountOfCoords-1 do begin
   SaveLong(TagUVBS);
   SaveLong(Crds[j].CountOfTVertices);
   for ii:=0 to Crds[j].CountOfTVertices-1 do begin
    SaveFloat(Crds[j].TVertices[ii,1]);
    SaveFloat(Crds[j].TVertices[ii,2]);
   end;//of for ii
  end;//of for j

  SaveSize;                       //������ ������� �����������
 end;//of for i
 SaveSize;                        //������ ������ ������������
End;
//---------------------------------------------------------
//���������� �������� ��������� �����������
procedure MDXSaveGeosetAnims;
Var i,tmp:integer;
Begin
 if CountOfGeosetAnims=0 then exit;
 SaveLong(TagGEOA);               //�������� ���
 MemorizeSizePos(false);
 SaveLong(0);                     //����� ��� ������
 for i:=0 to CountOfGeosetAnims-1 do with GeosetAnims[i] do begin
  MemorizeSizePos(true);
  SaveLong(0);                    //����� ������� ������
  if IsAlphaStatic then SaveFloat(Alpha)
                   else SaveFloat(1);
  //��������� �����
  tmp:=0;
  if IsDropShadow then tmp:=tmp or 1;
  if (not IsColorStatic) or (Color[1]>=0) then tmp:=tmp or 2;
  SaveLong(tmp);
  if IsColorStatic and (Color[1]>=0) then begin
   SaveFloat(Color[3]);
   SaveFloat(Color[2]);
   SaveFloat(Color[1]);
  end else begin
   SaveFloat(1);
   SaveFloat(1);
   SaveFloat(1);
  end;//of if

  SaveLong(GeosetID);
  //������ ������������ ��������
  if not IsAlphaStatic then MDXSaveController(tagKGAO,AlphaGraphNum,false,false);
  if not IsColorStatic then MDXSaveController(tagKGAC,ColorGraphNum,false,false);
  SaveSize;                       //������ �������
 end;//of for i
 SaveSize;                        //�������� ������ ������
End;
//---------------------------------------------------------
//���������������: ��������� ��������� OBJ
{procedure MDXSaveOBJ(name:string;ObjectID,Parent,objType:integer;
                  IsDITranslation,IsDIRotation,IsDIScaling,
                  IsBillboarded,IsBillboardedLockX,IsBillboardedLockY,
                  IsBillboardedLockZ,IsCameraAnchored:boolean;
                  r,t,s,v:integer);}
procedure MDXSaveOBJ(b:TBone;objType:integer);
Var tmp:integer;
Begin with b do begin
 MemorizeSizePos(true);
 SaveLong(0);                     //������ ����� ��� ������
 SaveASCII(Name,$50);             //��� �������
 SaveLong(ObjectID);
 SaveLong(Parent);
 //��������� �����
 tmp:=objType;
 if IsDITranslation then tmp:=tmp or 1;
 if IsDIScaling then tmp:=tmp or 2;
 if IsDIRotation then tmp:=tmp or 4;
 if IsBillboarded then tmp:=tmp or 8;
 if IsBillboardedLockX then tmp:=tmp or 16;
 if IsBillboardedLockY then tmp:=tmp or 32;
 if IsBillboardedLockZ then tmp:=tmp or 64;
 if IsCameraAnchored then tmp:=tmp or 128;
 SaveLong(tmp);                   //������ ������
 MDXSaveController(tagKGTR,Translation,false,false);
 MDXSaveController(tagKGRT,Rotation,false,false);
 MDXSaveController(tagKGSC,Scaling,false,false);
 if (objType=typHELP) and (objType=typBONE) and
    (objType=typLITE) and (objType=typEVTS) and
    (objType=typATCH) then
  MDXSaveController(tagKATV,Visibility,false,false);

 SaveSize;                        //������ �������
end;End;
//---------------------------------------------------------
//��������� ������ ������
procedure MDXSaveBones;
Var i:integer;
Begin
 if CountOfBones=0 then exit;
 SaveLong(TagBONE);               //������ ����
 MemorizeSizePos(false);
 SaveLong(0);                     //������ ����� ��� ������
 for i:=0 to CountOfBones-1 do with Bones[i] do begin
  //��������� ������
  MDXSaveOBJ(Bones[i],typBONE);
  //���������� GeosetID
  if GeosetID=Multiple then SaveLong(-1)
                       else begin
   if GeosetID>=0 then SaveLong(GeosetID) else SaveLong(0);
  end;//of if
  //���������� GeosetAnimID:
  if GeosetAnimID=None then SaveLong(-1)
                       else begin
   if GeosetAnimID>=0 then SaveLong(GeosetAnimID) else SaveLong(-1);
  end;//of if

 end;//of for i
 SaveSize;                        //��������� ������ ������
End;
//---------------------------------------------------------
//���������� ���������� �����
procedure MDXSaveLights;
Var i:integer;
Begin
 if CountOfLights=0 then exit;
 SaveLong(tagLITE);
 MemorizeSizePos(false);
 SaveLong(0);                     //����� ��� ������
 for i:=0 to CountOfLights-1 do with Lights[i] do begin
  MemorizeSizePos(true);
  SaveLong(0);
  MDXSaveOBJ(Skel,typLITE);
  SaveLong(LightType-1);          //��� ���������

  //������ ������������������� �����
  if IsASStatic and (AttenuationStart>=0) then SaveFloat(AttenuationStart)
                                          else SaveFloat(0);
  if IsAEStatic and (AttenuationEnd>=0) then SaveFloat(AttenuationEnd)
                                        else SaveFloat(0);
  if IsCStatic and (Color[1]>=0) then begin
   SaveFloat(Color[3]);
   SaveFloat(Color[2]);
   SaveFloat(Color[1]);
  end else begin
   SaveFloat(1);SaveFloat(1);SaveFloat(1);
  end;//of if(IsCStatic)
  if IsIStatic and (Intensity>=0) then SaveFloat(Intensity)
                                  else SaveFloat(0);
  if IsACStatic and (AmbColor[1]>=0) then begin
   SaveFloat(AmbColor[3]);
   SaveFloat(AmbColor[2]);
   SaveFloat(AmbColor[1]);
  end else begin
   SaveFloat(1);SaveFloat(1);SaveFloat(1);
  end;//of if(IsACStatic)
  if IsAIStatic and (AmbIntensity>=0) then SaveFloat(AmbIntensity)
                                      else SaveFloat(0);

  //������ ������������
  if not IsASStatic then
         MDXSaveController(tagKLAS,round(AttenuationStart),false,false);
  if not IsAEStatic then
         MDXSaveController(tagKLAE,round(AttenuationEnd),false,false);
  if not IsIStatic then
         MDXSaveController(tagKLAI,round(Intensity),false,false);
  MDXSaveController(tagKLAV,Skel.Visibility,false,false);
  if not IsCStatic then
         MDXSaveController(tagKLAC,round(Color[1]),true,false);
  if not IsACStatic then
         MDXSaveController(tagKLBC,round(AmbColor[1]),true,false);
  if not IsAIStatic then
         MDXSaveController(tagKLBI,round(AmbIntensity),false,false);

  SaveSize;                       //��������� ������ ���������
 end;//of for i
 SaveSize;                        //��������� ������ ������
End;
//---------------------------------------------------------
procedure MDXSaveHelpers;
Var i:integer;
Begin
 if CountOfHelpers=0 then exit;
 SaveLong(tagHELP);
 MemorizeSizePos(false);
 SaveLong(0);
 for i:=0 to CountOfHelpers-1 do with Helpers[i] do begin
  //��������� ������
  MDXSaveOBJ(Helpers[i],typBONE);
 end;//of for i
 SaveSize;                        //��������� ������ ������
End;
//---------------------------------------------------------
//���������� ����� ������������
procedure MDXSaveAttachments;
Var i,AttID:integer;
Begin
 if CountOfAttachments=0 then exit;
 AttID:=0;
 SaveLong(TagATCH);               //��� ������
 MemorizeSizePos(false);
 SaveLong(0);                     //����� ��� ������
 for i:=0 to CountOfAttachments-1 do with Attachments[i] do begin
  MemorizeSizePos(true);
  SaveLong(0);                     //����� ��� ������
  MDXSaveOBJ(Skel,typATCH);
  SaveASCII(Path,$100);
  SaveLong(0);                     //???
//  if AttachmentID<=0 then begin
   SaveLong(AttID);inc(AttID);
//  end else SaveLong(AttachmentID);

  SaveSize;                        //������ ������
 end;//of for i
 SaveSize;                        //��������� ������ ������
End;
//---------------------------------------------------------
//���������� �������������� �������
procedure MDXSavePivotPoints;
Var i,ii:integer;
Const pvtSize=3*4;
Begin
 if CountOfPivotPoints=0 then exit;
 SaveLong(TagPIVT);
 SaveLong(CountOfPivotPoints*pvtSize);//������ ������
 for i:=0 to CountOfPivotPoints-1 do
     for ii:=1 to 3 do SaveFloat(PivotPoints[i,ii]);
End;
//---------------------------------------------------------
//���������� ���������� ������ ������ ������
procedure MDXSaveParticleEmitters;
Var i,tmp:integer;
Begin
 if CountOfParticleEmitters1=0 then exit;
 SaveLong(TagPREM);               //��� ������
 MemorizeSizePos(false);
 SaveLong(0);                     //����� ��� ������
 for i:=0 to CountOfParticleEmitters1-1 do with ParticleEmitters1[i] do begin
  MemorizeSizePos(true);
  SaveLong(0);                     //����� ��� ������
  //��������� �����
  tmp:=$1000;
  if UsesType=EmitterUsesMDL then tmp:=tmp or $8000
                             else tmp:=tmp or $10000;
  MDXSaveOBJ(Skel,tmp);

  //���������� ������������������� �����
  if IsERStatic and (EmissionRate>=0) then SaveFloat(EmissionRate)
                                      else SaveFloat(0);
  if IsGStatic and (Gravity<>cNone) then SaveFloat(Gravity)
                                    else SaveFloat(0);
  if IsLongStatic and (Longitude>=0) then SaveFloat(Longitude)
                                     else SaveFloat(0);
  if IsLatStatic and (Latitude>=0) then SaveFloat(Latitude)
                                   else SaveFloat(0);
  SaveASCII(Path,$100);
  SaveLong(0);                    //???
  if IsLSStatic and (LifeSpan>=0) then SaveFloat(LifeSpan)
                                  else SaveFloat(0);
  if IsIVStatic and (InitVelocity<>cNone) then SaveFloat(InitVelocity)
                                          else SaveFloat(0);
  //������ ������������
  if not IsERStatic then
         MDXSaveController(TagKPEE,round(EmissionRate),false,false);
  if not IsGStatic then
         MDXSaveController(TagKPEG,round(Gravity),false,false);
  if not IsLongStatic then
         MDXSaveController(TagKPLN,round(Longitude),false,false);
  if not IsLatStatic then
         MDXSaveController(TagKPLT,round(Latitude),false,false);
  if not IsLSStatic then
         MDXSaveController(TagKPEL,round(LifeSpan),false,false);
  if not IsIVStatic then
         MDXSaveController(TagKPES,round(InitVelocity),false,false);
  MDXSaveController(TagKPEV,Skel.Visibility,false,false);

  SaveSize;                       //������ ������
 end;//of for i
 SaveSize;                        //��������� ������ ���� ������
End;
//---------------------------------------------------------
//���������� ���������� ������ ������ ������
procedure MDXSaveParticleEmitters2;
Var i,ii,j,tmp:integer;
Begin
 if CountOfParticleEmitters=0 then exit;
 SaveLong(TagPRE2);
 MemorizeSizePos(false);
 SaveLong(0);                     //����� ��� ������
 for i:=0 to CountOfParticleEmitters-1 do with pre2[i] do begin
  MemorizeSizePos(true);
  SaveLong(0);
  //��������� �����
  tmp:=$1000;
  if IsUnshaded then tmp:=tmp or $8000;
  if IsXYQuad then tmp:=tmp or $100000;
  if IsModelSpace then tmp:=tmp or $80000;
  if IsUnfogged then tmp:=tmp or $40000;
  if IsLineEmitter then tmp:=tmp or $20000;
  if IsSortPrimsFarZ then tmp:=tmp or $10000;
  MDXSaveOBJ(Skel,tmp);
  //������ ������������������� �����
  if IsSStatic and (Speed<>cNone) then SaveFloat(Speed)
                                  else SaveFloat(0);
  if IsVStatic and (Variation>=0) then SaveFloat(Variation)
                                  else SaveFloat(0);
  if IsLStatic and (Latitude<>cNone) then SaveFloat(Latitude)
                                     else SaveFloat(0);
  if IsGStatic and (Gravity<>cNone) then SaveFloat(Gravity)
                                    else SaveFloat(0);
  if LifeSpan<>cNone then SaveFloat(LifeSpan)
                     else SaveFloat(0);
  if IsEStatic and (EmissionRate<>cNone) then SaveFloat(EmissionRate)
                                        else SaveFloat(0);
  if IsHStatic then SaveFloat(Length)
               else SaveFloat(0);
  if IsWStatic then SaveFloat(Width)
               else SaveFloat(0);
  //������ ������ ��������
  if BlendMode=FullAlpha then tmp:=0;
  if BlendMode=Additive then tmp:=1;
  if BlendMode=Modulate then tmp:=2;
  if BlendMode=AlphaKey then tmp:=4;
  SaveLong(tmp);

  //������ �����
  SaveLong(Rows);
  SaveLong(Columns);
  SaveLong(ParticleType);
  if TailLength<>cNone then SaveFloat(TailLength)
                       else SaveFloat(0);
  if Time<>cNone then SaveFloat(Time)
                 else SaveFloat(0);
  //������ ��������� ��������
  for ii:=1 to 3 do for j:=3 downto 1 do SaveFloat(SegmentColor[ii,j]);

  //������ ����� �����
  for ii:=1 to 3 do SaveByte(Alpha[ii]);
  for ii:=1 to 3 do SaveFloat(ParticleScaling[ii]);
  for ii:=1 to 3 do SaveLong(LifeSpanUVAnim[ii]);
  for ii:=1 to 3 do SaveLong(DecayUVAnim[ii]);
  for ii:=1 to 3 do SaveLong(TailUVAnim[ii]);
  for ii:=1 to 3 do SaveLong(TailDecayUVAnim[ii]);
  //��� ����
  SaveLong(TextureID);
  if IsSquirt then SaveLong(1)
              else SaveLong(0);
  if PriorityPlane>=0 then SaveLong(PriorityPlane)
                      else SaveLong(0);
  if ReplaceableID>=0 then SaveLong(ReplaceableID)
                      else SaveLong(0);

  //������ ������������
  if not IsSStatic then
         MDXSaveController(tagKP2S,round(Speed),false,false);
  if not IsVStatic then
         MDXSaveController(tagKP2R,round(Variation),false,false);
  if not IsLStatic then
         MDXSaveController(tagKP2L,round(Latitude),false,false);
  if not IsGStatic then
         MDXSaveController(tagKP2G,round(Gravity),false,false);
  if not IsEStatic then
         MDXSaveController(tagKP2E,round(EmissionRate),false,false);
  MDXSaveController(tagKP2V,Skel.Visibility,false,false);
  if not IsHStatic then
         MDXSaveController(tagKP2N,round(Length),false,false);
  if not IsWStatic then
         MDXSaveController(tagKP2W,round(Width),false,false);

  SaveSize;                       //������ ������
 end;
 SaveSize;                        //������ ������
End;
//---------------------------------------------------------
//������ ���������� ������
procedure MDXSaveRibbonEmitters;
Var i:integer;
Begin
 if CountOfRibbonEmitters=0 then exit;
 SaveLong(TagRIBB);
 MemorizeSizePos(false);
 SaveLong(0);
 for i:=0 to CountOfRibbonEmitters-1 do with Ribs[i] do begin
  MemorizeSizePos(true);
  SaveLong(0);
  MDXSaveOBJ(Skel,$4000);
  //������ ������������������� �����
  if IsHAStatic and (HeightAbove<>cNone) then SaveFloat(HeightAbove)
                                         else SaveFloat(0);
  if IsHBStatic and (HeightBelow<>cNone) then SaveFloat(HeightBelow)
                                         else SaveFloat(0);
  if IsAlphaStatic and (Alpha>=0) then SaveFloat(Alpha)
                                  else SaveFloat(1);
  if IsColorStatic and (Color[1]>=0) then begin
   SaveFloat(Color[3]);
   SaveFloat(Color[2]);
   SaveFloat(Color[1]);
  end else begin
   SaveFloat(1);SaveFloat(1);SaveFloat(1);
  end;//of if(IsColorStatic)

  //��� ����
  if LifeSpan>=0 then SaveFloat(LifeSpan)
                 else SaveFloat(0);
  if IsTSStatic and (TextureSlot>=0) then SaveLong(TextureSlot)
                                     else SaveLong(0);
  if EmissionRate>=0 then SaveLong(EmissionRate)
                    else SaveLong(0);
  SaveLong(Rows);
  SaveLong(Columns);
  if MaterialID>=0 then SaveLong(MaterialID)
                   else SaveLong(0);
  if Gravity<>cNone then SaveFloat(Gravity)
                    else SaveFloat(0);

  //�������� �����������
  if not IsHAStatic then
         MDXSaveController(TagKRHA,round(HeightAbove),false,false);
  if not IsHBStatic then
         MDXSaveController(TagKRHB,round(HeightBelow),false,false);
  if not IsAlphaStatic then
         MDXSaveController(TagKRAL,round(Alpha),false,false);
  if not IsColorStatic then
         MDXSaveController(TagKRCO,round(Color[1]),true,false);
  MDXSaveController(TagKRVS,Skel.Visibility,false,false);

  SaveSize;                       //������ ������
 end;//of for i
 SaveSize;                        //������ ������� ������
End;
//---------------------------------------------------------
//��������� ������
procedure MDXSaveCameras;
Var i,ii:integer;
Begin
 if CountOfCameras=0 then exit;
 SaveLong(TagCAMS);
 MemorizeSizePos(false);
 SaveLong(0);
 for i:=0 to CountOfCameras-1 do with Cameras[i] do begin
  MemorizeSizePos(true);
  SaveLong(0);
  SaveASCII(Name,$50);
  for ii:=1 to 3 do SaveFloat(Position[ii]);
  SaveFloat(FieldOfView);
  SaveFloat(FarClip);
  SaveFloat(NearClip);
  //����� ����:
  for ii:=1 to 3 do SaveFloat(TargetPosition[ii]);
  MDXSaveController(tagKCTR,TargetTGNum,false,false);

  //������ ������������
  MDXSaveController(tagKCRL,RotationGraphNum,false,false);
  MDXSaveController(tagKTTR,TranslationGraphNum,false,false);

  SaveSize;                       //������ ������
 end;//of for i
 SaveSize;                        //������ ������
End;
//---------------------------------------------------------
//��������� ������ ������� (������������)
procedure MDXSaveEvents;
Var i,ii:integer;
const tgKEVT=$5456454B;
Begin
 if CountOfEvents=0 then exit;
 SaveLong(TagEVTS);
 MemorizeSizePos(false);
 SaveLong(0);
 for i:=0 to CountOfEvents-1 do with Events[i] do begin
  MDXSaveOBJ(Skel,typEVTS);
  SaveLong(tgKEVT);               //����-���
  SaveLong(CountOfTracks);
  SaveLong(-1);                   //???
  for ii:=0 to CountOfTracks-1 do SaveLong(Tracks[ii]);
 end;//of for i
 SaveSize;
End;
//---------------------------------------------------------
procedure MDXSaveCollisionShapes;
Var i,ii:integer;
Begin
 if CountOfCollisionShapes=0 then exit;
 SaveLong(tagCLID);
 MemorizeSizePos(false);
 SaveLong(0);
 for i:=0 to CountOfCollisionShapes-1 do with Collisions[i] do begin
  MDXSaveOBJ(Skel,typCLID);
  if objType=cSphere then SaveLong(2)
                     else SaveLong(0);
  //��������� ������ �������
  for ii:=1 to 3 do SaveFloat(Vertices[0,ii]);
  if objType=cSphere then SaveFloat(BoundsRadius)
                     else begin
   for ii:=1 to 3 do SaveFloat(Vertices[1,ii]);
  end;//of if
 end;//of for i
 SaveSize;
End;
//---------------------------------------------------------
procedure MDXSaveMdlVisInformation; //���� �� ������ �������
Var i,ii,len:integer;
Begin
 if not IsCanSaveMDVI then exit;  //��������� ������ ����. ����
 if (COMidNormals=0) and (COConstNormals=0) and (not IsWoW) then exit;
 SaveLong(tagMDVI);               //��� ������
 MemorizeSizePos(false);
 SaveLong(0);                     //������ ����� ��� ������

 //1. ������ �������� WoW
 if IsWoW then begin
  SaveLong(tagiWoW);               //��� ������ WoW-��������
  for i:=0 to CountOfGeosets-1 do SaveLong(Geosets[i].HierID);
 end;//of if 

 //2. ������ ���������� � ������� �����������
 if (COMidNormals>0) or (COConstNormals>0) then begin
  SaveLong(tagiSmooth);            //��� ������ �����������
  SaveLong(COMidNormals);          //���-�� ���������� ��������
  for i:=0 to COMidNormals-1 do begin
   len:=length(MidNormals[i]);
   SaveLong(len);
   for ii:=0 to len-1 do begin
    SaveLong(MidNormals[i,ii].GeoID);
    SaveLong(MidNormals[i,ii].VertID);
   end;//of for ii
  end;//of for i

  //������ - ���������� �� ��������� ��������
  SaveLong(COConstNormals);
  for i:=0 to COConstNormals-1 do begin
   SaveLong(ConstNormals[i].GeoId);
   SaveLong(ConstNormals[i].VertId);
   SaveFloat(ConstNormals[i].n[1]);
   SaveFloat(ConstNormals[i].n[2]);
   SaveFloat(ConstNormals[i].n[3]);
  end;//of for i
 end;//of if

 SaveSize;
End;
//---------------------------------------------------------
//��������� ������ � ������� MDX
procedure SaveMDX(fname:string);
//������ MDX:
Const vrs:array[0..15] of byte=(
      $4D, $44, $4C, $58, $56, $45, $52, $53,
      $04, $00, $00, $00, $20, $03, $00, $00);
      hdrSize=$150+9*4;           //������ ���������
//Var i:integer;
Begin
 assignFile(fm,fname);            //������� ����
 rewrite(fm,1);                   //������� ������
 fsCurNum:=0;                     //��� ������� � �������
 //0. ������� ������ �������
 BlockWrite(fm,vrs,16);           //������
 //1. ������ ������ MODL
 SaveLong(TagMODL);               //������ ����
 SaveLong(hdrSize);               //������ �������
 SaveASCII(ModelName,$150);       //��� ������
 SaveLong(0);                     //???
 MDXSaveAnimBounds(AnimBounds);   //�������
 SaveLong(BlendTime);             //����� ��������
 //������ �������� (���� ����)
 //(���������� � ������ ���������� MdlVis)
// if IsWoW then SaveHierarchy(fname) else DeleteHierarchy(fname);
 //2. ������ ����� ����������
 MDXSaveSequences;                //������ ��������
 MDXSaveGlobalSequences;          //������ ���������� �������������������
 MDXSaveMaterials;                //������ ����������
 MDXSaveTextures;                 //������ �������
 MDXSaveTextureAnims;             //������ ���������� ��������
 MDXSaveGeosets;                  //������ ������������
 MDXSaveGeosetAnims;              //������ �������� ���������
 MDXSaveBones;                    //������ ������
 MDXSaveLights;                   //������ ���������� �����
 MDXSaveHelpers;                  //���������� ����������
 MDXSaveAttachments;              //���������� ����� ������������
 MDXSavePivotPoints;              //���������� �������������� �������
 MDXSaveParticleEmitters;         //���������� ���������� ������ (v.1)
 MDXSaveParticleEmitters2;        //���������� ���������� ������ (v.2)
 MDXSaveRibbonEmitters;           //������ ���������� �����
 MDXSaveCameras;                  //������ �����
 MDXSaveEvents;                   //���������� �������
 MDXSaveCollisionShapes;          //������ �������� ������
 MDXSaveMdlVisInformation;        //������ �������������� ���������� MdlVis
 closeFile(fm);                   //������� ����
End;
//---------------------------------------------------------
//���������������: ��������� ������������� blp,
//������� �������������� ������ ��� �����.
procedure LoadUnpackingBLP(p:pointer;var pRet:pointer;var Width,Height:integer);
Var i{,ii}:integer;
    ps,psImg,psPal,psAlpha,psDest,dta,r,g,b,tmp:cardinal;
    IsAlphaPresent:boolean;
Begin
 //1. �������� ��������� �� �������, ������� � �����-����
 //� ����� Width � Height �����������
 ps:=integer(p);                  //������� blp � ������
 Move(pointer(ps+$1C)^,psImg,4);  //������� �������� blp
 psPal:=psImg-$400;               //������� ������ �������
 Move(pointer(ps+08)^,tmp,4);     //����������� �����
 IsAlphaPresent:=tmp<>0;
 Move(pointer(ps+$0C)^,Width,4);  //������ ������ ��������
 Move(pointer(ps+$10)^,Height,4); //������ ������ ��������
 psAlpha:=psImg+Width*Height;     //������� �����-������
 //��������� ���������� �������
 psImg:=psImg+ps;
 psPal:=psPal+ps;
 psAlpha:=psAlpha+ps;

 //2. �������� ������ (����� �������������)
 GetMem(pRet,Width*Height*4);
 psDest:=integer(pRet);           //������� � ������
 //3. ������������ � 32-������ ������
 for i:=1 to Width*Height-1 do begin
  dta:=0;tmp:=0;
  Move(pointer(psImg)^,dta,1);    //������ ��� �����
  Move(pointer(psPal+dta*4)^,dta,4);//������ BGR0-��� �� �������
  r:=GetRValue(dta);
  g:=GetGValue(dta);
  b:=GetBValue(dta);
  dta:=b+(g shl 8)+(r shl 16);
  if IsAlphaPresent then Move(pointer(psAlpha)^,tmp,1)
                    else tmp:=255;  
  dta:=dta+(tmp shl 24);          //�������� RGBA-���
  Move(dta,pointer(psDest)^,4);   //����� ��� � �����
  //�������� ���������
  psImg:=psImg+1;
  psDest:=psDest+4;
  psAlpha:=psAlpha+1;
 end;//of for i
End;

//���������������: ������ ���� �� MPQ, ���� ��� ��������
function LoadFileFromMPQs(fname:PChar;var hFile:integer):boolean;
Begin
 Result:=false;
 if not IsLoadMPQ then exit;      //MPQ �� ���������
 Result:=true;
 if SFileOpenFileEx(hWar3patch,fname,0,hFile) then exit;
 if SFileOpenFileEx(hWar3x,fname,0,hFile) then exit;
 if SFileOpenFileEx(hWar3,fname,0,hFile) then exit;
 Result:=false;
End;

//���������������: ��������� �������� � ����� P
//(�������������� ������� ������).
//��� ������ ���������� false.
function LoadTexInBuf(dirName,fname:string;var p:pointer;CInt:integer;
                      var len:integer):boolean;
Var ps,hFile,tmp:integer;f:file;oldname:string;
Begin
 Result:=false;
 oldname:=fname;
 //1. �������� ��������� �� �����
  assignFile(f,dirName+'\'+fname);
  {$I-}
  reset(f,1);                     //������� �������� �����
  if IOResult<>0 then begin       //���� ���� �� ������
   ps:=length(fname);
   while (fname[ps]<>'\') and (ps>0) do dec(ps);
   delete(fname,1,ps);
   assignFile(f,dirName+'\'+fname);
   reset(f,1);                    //��������� ��-�������...
   if IOResult<>0 then begin      //���� ���-���� �� �����
    //��� �, ������� ���������� �� MPQ...
    if not LoadFileFromMPQs(PChar(oldname),hFile) then begin
     TexErr:=TexErr+fname+#13#10;  //�������� � ������ ������
     //��� �� �����, ����� ��������...
     GetMem(p,8*8*4);
     FillChar(p^,8*8*4,CInt); //��������� �����
     exit;
    end;//of if

    len:=SFileGetFileSize(hFile,tmp);
    if len<=0 then begin
     TexErr:=TexErr+fname+#13#10;  //�������� � ������ ������
     //��� �� �����, ����� ��������...
     GetMem(p,8*8*4);
     FillChar(p^,8*8*4,CInt); //��������� �����
     exit;
    end;//of if (len equ Err)
    
    GetMem(p,len);
    if not SFileReadFile(hFile,p,len,0,nil) then begin
     TexErr:=TexErr+fname+#13#10;  //�������� � ������ ������
     //����� ��� �������, ������ ���������
     FillChar(p^,8*8*4,CInt); //��������� �����
     exit;
    end;//of if(ErrRead)
    SFileCloseFile(hFile);        //������� ����
    Result:=true;                 //���������� �������
    exit;                         //�����
   end;//of if
  end;//of if
  {$I+}
  //2. ���� ������ ���� ��� ������
  len:=fileSize(f);
  GetMem(p,len);          //�������� ������
  BlockRead(f,p^,len);    //��������� ����
  //������� ����
  closeFile(f);
  Result:=true;
End;

//��������� ��������, ���������� ����� �����������
//� � width,height - ������� ������ ��������
procedure LoadTexture(dirName,fname:string;
                      var Width,Height:integer;var pReturn:pointer);
Var f:file;ps,texWidth,texHeight,len,{ListNum,}i,ii,
    lOfs,lZero,spos,dpos,tmp,r,g,b,a:integer;
    wWidth,wHeight:word;
    p,ppos,pposs,pImg:pointer;
    pWrk1,pWrk2:PByte;
    bTmp:byte;
    BLP_INFO:array[0..6000] of integer;
Const CIntensity=200;//������������� ����� ��� ������� ��������
Begin
 pReturn:=nil;                    //���� ������ �� ���������
 Width:=8;
 Height:=8;
 if length(fname)<3 then begin
//  MessageBox(0,'�������� ��� ��������.','������',mb_iconstop or mb_applmodal);
  TexErr:='������ ����������'#13#10;
  GetMem(pReturn,8*8*4);
  FillChar(pReturn^,8*8*4,CIntensity); //��������� �����
  exit;
 end;//of if
 //��������� ��� ����� ��������
 if LowerCase(copy(fname,length(fname)-3,4))='.blp' then begin //��� - BLP
  if (@ijlInit=nil) or (@ijlRead=nil) or (@ijlFree=nil) then begin
   MessageBox(0,'���������� ijl15.dll �� �������,'#13#10+
                '�������� blp-������� ����������.',
                '��������:',mb_iconstop or mb_applmodal);
   exit;                           //���������� ��� ������
  end;//of if
(*  //1. ���� ��� ���� �� �����
  assignFile(f,dirName+'\'+fname);
  {$I-}
  reset(f,1);                     //������� �������� �����
  if IOResult<>0 then begin       //���� ���� �� ������
   ps:=length(fname);
   while (fname[ps]<>'\') and (ps>0) do dec(ps);
   delete(fname,1,ps);
   assignFile(f,dirName+'\'+fname);
   reset(f,1);                    //��������� ��-�������...
   if IOResult<>0 then begin      //���� ���-���� �� �����
    TexErr:=TexErr+fname+#13#10;  //�������� � ������ ������
{    MessageBox(0,PChar('���� '+fname+' �� ������.'),
               '������:',mb_iconexclamation or mb_applmodal);}
    //��� �� �����, ����� ��������...
    GetMem(pReturn,8*8*4);
    FillChar(pReturn^,8*8*4,CIntensity); //��������� �����
    exit;
   end;//of if
  end;//of if
  {$I+}
  //2. ���� ������ ���� ��� ������
  len:=fileSize(f);
  GetMem(p,len);          //�������� ������
  BlockRead(f,p^,len);    //��������� ����
  //������� ����
  closeFile(f);  *)
  if not LoadTexInBuf(dirName,fname,p,CIntensity,len) then begin
   pReturn:=p;
   exit;
  end;//of if
  //2.4 �������, �� WoW �� ��� blp
  ppos:=pointer(integer(p));
  Move(ppos^,lZero,4);
  if lZero<>$31504C42 then begin
    TexErr:=TexErr+fname+' [�� WC3-������]'#13#10;  //�������� � ������ ������
    GetMem(pReturn,8*8*4);
    FillChar(pReturn^,8*8*4,CIntensity); //��������� �����
    exit;
  end;//of if
  //2.5 �������, ��� ��� �� ��� �������� (����������� blp)
  ppos:=pointer(integer(p)+4);
  Move(ppos^,lZero,4);            //������ ���� ����
  if lZero=1 then begin           //������������� blp
   LoadUnpackingBLP(p,pReturn,width,height);//������ ���
   FreeMem(p);
   exit;                          //������
  end;//of if (������������� blp)
  //3. �������������� IJL
  if ijlInit(@BLP_INFO)<>0 then begin
   MessageBox(0,'�� ������� ���������������� IJL.',
                scError,mb_iconstop or mb_applmodal);
   FreeMem(p);                     //���������� ������
   exit;
  end;//of if
  //������� ��������� IJPEG ��������
  ppos:=pointer(integer(p)+$1C);
  move(ppos^,lofs,4);
  ppos:=pointer(integer(p)+$310); //�������� �� 0
  move(ppos^,lZero,4);
  if (lOfs>$310) and (lZero=0) then begin
   ppos:=pointer(integer(p)+$49C);
   pposs:=pointer(integer(p)+$310);
   move(ppos^,pposs^,len-$49C);        //��������
  end;//of if
  //4. �������� ��������� BLP_INFO
  ppos:=pointer(integer(p)+12);move(ppos^,texWidth,4);//��������� �������
  ppos:=pointer(integer(p)+16);move(ppos^,texHeight,4);
  GetMem(pImg,texWidth*texHeight*8);//������ ��� ����������
  BLP_INFO[0]:=0;                 //!
  BLP_INFO[1]:=integer(pImg);     //��������� �� ������ ��� ����������
  BLP_INFO[2]:=texWidth;
  BLP_INFO[3]:=texHeight;
  BLP_INFO[4]:=0;                 //!
  BLP_INFO[5]:=4;
  BLP_INFO[6]:=$0FF;
  BLP_INFO[7]:=0;
  BLP_INFO[8]:=0;                 //!
  BLP_INFO[9]:=integer(p)+$0A0;   //������� JFIF
  BLP_INFO[10]:=len-$0A0;         //?
  BLP_INFO[11]:=texWidth;
  BLP_INFO[12]:=texHeight;
  BLP_INFO[13]:=4;
  BLP_INFO[14]:=$0FF;
  BLP_INFO[15]:=0;
  BLP_INFO[18]:=1;
  BLP_INFO[19]:=1;
  BLP_INFO[20]:=$64;
  //5. ���������� �������� ����������
  if ijlRead(@BLP_INFO,3)<>0 then begin
   MessageBox(0,'�� ������� ����������� BLP.',
                scError,mb_iconstop or mb_applmodal);
   FreeMem(p);                     //���������� ������
   FreeMem(pImg);
   GetMem(pReturn,8*8*4);         //������� ����� �����
   FillChar(pReturn^,8*8*4,CIntensity);  //��������� �����
   exit;
  end;//of if
  //6. ���!!! ���� ����������. ������ �������� �������� ����� � �����
  pWrk1:=PByte(pImg);
  pWrk2:=PByte(integer(pImg)+2);
  for i:=0 to texWidth*texHeight do begin
   bTmp:=pWrk1^;
   pWrk1^:=pWrk2^;
   pWrk2^:=bTmp;
   pWrk1:=PByte(integer(pWrk1)+4);
   pWrk2:=PByte(integer(pWrk2)+4);
  end;//of for
  //7. ������ ������ ��������
  pReturn:=pImg;                  //�������
  width:=texWidth;height:=texHeight;//������� �������
  //���������� ������
  FreeMem(p);                     //���������� ������
//  FreeMem(pImg);
 end else begin                   //��� TGA-����
  //1. ���� ��� ���� �� �����
  assignFile(f,dirName+'\'+fname);
  {$I-}
  reset(f,1);                     //������� �������� �����
  if IOResult<>0 then begin       //���� ���� �� ������
   ps:=length(fname);
   while (fname[ps]<>'\') and (ps>0) do dec(ps);
   delete(fname,1,ps);
   assignFile(f,dirName+'\'+fname);
   reset(f,1);                    //��������� ��-�������...
   if IOResult<>0 then begin      //���� ���-���� �� �����
    TexErr:=TexErr+fname+#13#10;
{    MessageBox(0,PChar('���� '+fname+' �� ������.'),
               '������:',mb_iconexclamation or mb_applmodal);}
    GetMem(pReturn,8*8*4);        //������� ����� �����
    FillChar(pReturn^,8*8*4,CIntensity); //��������� �����
    exit;
   end;//of if
  end;//of if
  {$I+}
  //2. ���� ������ ���� ��� ������
  len:=fileSize(f);
  GetMem(p,len);          //�������� ������
  BlockRead(f,p^,len);    //��������� ����
  ppos:=pointer(integer(p)+$0C); //������� ���������
  move(ppos^,wWidth,2);
  ppos:=pointer(integer(p)+$0E);
  move(ppos^,wHeight,2);
  width:=wWidth;height:=wHeight;
  wWidth:=0;
  ppos:=pointer(integer(p)+$10);
  move(ppos^,wWidth,1);           //�������� ����������� TGA
  ppos:=pointer(integer(p)+$11);
  tmp:=0;
  move(ppos^,tmp,1);              //������ ����� TGA
  ppos:=pointer(integer(p)+$12);  //�������� ��������� �� ������
  //������� ����
  closeFile(f);
  //6. ������ �������� �������� ����� � �����
  if (tmp and 32)<>0 then begin   //������� ������� �����
   if wWidth=32 then begin
    GetMem(pReturn,width*height*4);
    spos:=integer(ppos);
    dpos:=integer(pReturn);
    for i:=0 to Width*Height do begin
     move(pointer(spos)^,lOfs,4); //������ RGBA
     r:=GetRValue(lOfs);
     g:=GetGValue(lOfs);
     b:=GetBValue(lOfs);
     a:=(lOfs and $FF000000);
     lOfs:=(b+(g shl 8)+(r shl 16)) or a;
     move(lOfs,pointer(dpos)^,4);
     dpos:=dpos+4;
     spos:=spos+4;
    end;//of for i
   end else begin
    GetMem(pReturn,width*height*4);
    spos:=integer(ppos);
    dpos:=integer(pReturn);
    for i:=0 to width*height do begin
     lOfs:=0;
     move(pointer(spos)^,lOfs,3); //������ RGB
     r:=GetRValue(lOfs);
     g:=GetGValue(lOfs);
     b:=GetBValue(lOfs);
     lOfs:=(b+(g shl 8)+(r shl 16)) or $FF000000;
     move(lOfs,pointer(dpos)^,4); //�������� RGBA
     spos:=spos+3;
     dpos:=dpos+4;
    end;//of for i
   end;//of if
  end else begin                  //�������� ������� �����
   if wWidth=32 then begin
    GetMem(pReturn,width*height*4);
    //�������� ������ � �������� �������
    spos:=integer(ppos)+width*height*4-width*4;//��������
    dpos:=integer(pReturn);        //��������
    for ii:=height-1 downto 0 do begin
     for i:=0 to width-1 do begin
      tmp:=0;
      Move(pointer(spos)^,tmp,4);
      r:=GetRValue(tmp);
      g:=GetGValue(tmp);
      b:=GetBValue(tmp);
      a:=(tmp and $FF000000);
      tmp:=(b+(g shl 8)+(r shl 16)) or a;
      Move(tmp,pointer(dpos)^,4);   //��������
      spos:=spos+4;                 //����� ���������
      dpos:=dpos+4;
     end;//of for i
     spos:=spos-width*8;
    end; //of for ii
   end else begin
    GetMem(pReturn,width*height*4);
    spos:=integer(ppos)+width*height*3-width*3;//��������
    dpos:=integer(pReturn);        //��������
    for ii:=height-1 downto 0 do begin
     for i:=0 to width-1 do begin
      tmp:=0;
      Move(pointer(spos)^,tmp,3);
      r:=GetRValue(tmp);
      g:=GetGValue(tmp);
      b:=GetBValue(tmp);
      tmp:=(b+(g shl 8)+(r shl 16)) or $FF000000;
      Move(tmp,pointer(dpos)^,4);   //��������
      spos:=spos+3;                 //����� ���������
      dpos:=dpos+4;
     end;//of for i
     spos:=spos-width*6;
    end; //of for ii
   end; //of if(Depth)
  end;//of if(������� �����)
   FreeMem(p);
 end;//of if
End;
//---------------------------------------------------------
//����� ��������������� �������� ��� ����������� ��������
//������� ���������� ������������
procedure AddOpaque(pBuf,pTex:pointer;xt,yt,xb,yb,iAlpha:integer);
Var i,ii,j,jj,cntx,cnty,dta,psBuf,psTex:integer;
Begin
 cntx:=xb div xt;
 cnty:=yb div yt;
 psBuf:=integer(pBuf);
 psTex:=integer(pTex);
 for jj:=1 to yt do begin            //���������� �����
  for j:=1 to cnty do begin          //���������� �����
   for ii:=1 to xt do begin          //������ ������
    Move(pointer(psTex)^,dta,4);     //������ ������
    dta:=dta and $00FFFFFF;
    dta:=dta or (iAlpha shl 24);     //���������� ������������ ����
    for i:=1 to cntx do begin        //������ �������
     Move(dta,pointer(psBuf)^,4);    //�����
     psBuf:=psBuf+4;                 //���� �����
    end;//of for i
    psTex:=psTex+4;                  //��������� �������
   end;//of for ii
   psTex:=psTex-xt*4;                //�������� � ������
  end;//of for j
  psTex:=psTex+xt*4;
 end;//of jj
end;

//������������ 75% (Transparent)
procedure Add2Alpha(pBuf,pTex:pointer;xt,yt,xb,yb,iAlpha:integer);
Var i,ii,j,jj,cntx,cnty,psBuf,psTex:integer;
    dta:cardinal;//alpha:GLFloat;
Begin
 cntx:=xb div xt;
 cnty:=yb div yt;
 psBuf:=integer(pBuf);
 psTex:=integer(pTex);
 for jj:=1 to yt do begin            //���������� �����
  for j:=1 to cnty do begin          //���������� �����
   for ii:=1 to xt do begin          //������ ������
    Move(pointer(psTex)^,dta,4);     //������ ������
    if (dta and $FF000000)<$C0000000 then begin
     psTex:=psTex+4;                 //������� �������
     psBuf:=psBuf+4*cntx;
     continue;                       //���������� (��� ������)
    end;//of if
//    alpha:=(dta shr 8*3)*iAlpha*0.00392;
    dta:=dta and $00FFFFFF;
    if iAlpha>191 then iAlpha:=255
    else iAlpha:=0;
    dta:=dta or (iAlpha shl 24);     //���������� ������������ ����
    for i:=1 to cntx do begin        //������ �������
     Move(dta,pointer(psBuf)^,4);    //�����
     psBuf:=psBuf+4;                 //���� �����
    end;//of for i
    psTex:=psTex+4;                  //��������� �������
   end;//of for ii
   psTex:=psTex-xt*4;                //�������� � ������
  end;//of for j
  psTex:=psTex+xt*4;
 end;//of jj
end;

//������ ��������
procedure BlendTex(pBuf,pTex:pointer;xt,yt,xb,yb:integer;fAlpha:GLFloat);
Var i,ii,j,jj,cntx,cnty,dta,dta2,psBuf,psTex:integer;
    r1,r2,g1,g2,b1,b2,a1,a2,dl:GLfloat;
Const dv=1/255;
Begin
 cntx:=xb div xt;
 cnty:=yb div yt;
 psBuf:=integer(pBuf);
 psTex:=integer(pTex);
 for jj:=1 to yt do begin            //���������� �����
  for j:=1 to cnty do begin          //���������� �����
   for ii:=1 to xt do begin          //������ ������
    Move(pointer(psTex)^,dta,4);     //������ ������
    Move(pointer(psBuf)^,dta2,4);    //������ ������ �� ������
    r1:=(dta and $FF);
    g1:=(dta and $FF00) shr 8;
    b1:=(dta and $FF0000) shr 16;
    a1:=((dta and $FF000000) shr 24)*dv*fAlpha;
    r2:=(dta2 and $FF);
    g2:=(dta2 and $FF00) shr 8;
    b2:=(dta2 and $FF0000) shr 16;
    a2:=((dta2 and $FF000000) shr 24)*dv;
    dl:=1-a1;
    r2:=r1*a1+r2*dl;
    g2:=g1*a1+g2*dl;
    b2:=b1*a1+b2*dl;
    a2:=a1+a2;if a2>1 then a2:=1;
    dta2:=round(a2*255) shl 8;
    dta2:=(dta2+round(b2)) shl 8;
    dta2:=(dta2+round(g2)) shl 8;
    dta2:=dta2+round(r2);
    dta:=dta2;
    for i:=1 to cntx do begin        //������ �������
     Move(dta,pointer(psBuf)^,4);    //�����
     psBuf:=psBuf+4;                 //���� �����
    end;//of for i
    psTex:=psTex+4;                  //��������� �������
   end;//of for ii
   psTex:=psTex-xt*4;                //�������� � ������
  end;//of for j
  psTex:=psTex+xt*4;
 end;//of jj
end;

//������� (Additive)
procedure AddAdd(pBuf,pTex:pointer;xt,yt,xb,yb,iAlpha:integer);
Var i,ii,j,jj,cntx,cnty,dta,psBuf,psTex:integer;
    r1,g1,b1,r2,g2,b2,a2:integer;
Begin
 cntx:=xb div xt;
 cnty:=yb div yt;
 psBuf:=integer(pBuf);
 psTex:=integer(pTex);
 for jj:=1 to yt do begin            //���������� �����
  for j:=1 to cnty do begin          //���������� �����
   for ii:=1 to xt do begin          //������ ������
    r1:=0;r2:=0;g1:=0;g2:=0;
    b1:=0;b2:=0;{a1:=0;}a2:=0;
    Move(pointer(psTex)^,r1,1);inc(psTex);
    Move(pointer(psTex)^,g1,1);inc(psTex);
    Move(pointer(psTex)^,b1,1);inc(psTex);inc(psTex);
    psTex:=psTex-4;
    Move(pointer(psBuf)^,r2,1);inc(psBuf);
    Move(pointer(psBuf)^,g2,1);inc(psBuf);
    Move(pointer(psBuf)^,b2,1);inc(psBuf);
    Move(pointer(psBuf)^,a2,1);inc(psBuf);
    psBuf:=psBuf-4;
    r2:=r2+r1;g2:=g2+g1;b2:=b2+b1;a2:=a2+iAlpha;
    if r2>255 then r2:=255;
    if g2>255 then g2:=255;
    if b2>255 then b2:=255;
    if a2>255 then a2:=255;
    dta:=a2 shl 8;
    dta:=(dta+b2) shl 8;
    dta:=(dta+g2) shl 8;
    dta:=dta+r2;
    for i:=1 to cntx do begin        //������ �������
     Move(dta,pointer(psBuf)^,4);    //�����
     psBuf:=psBuf+4;                 //���� �����
    end;//of for i
    psTex:=psTex+4;                  //��������� �������
   end;//of for ii
   psTex:=psTex-xt*4;                //�������� � ������
  end;//of for j
  psTex:=psTex+xt*4;
 end;//of jj
end;

//������� ������ GL ��� ��������� ���������
//MatID - ID ���������, rgb - �������� ����� �������.
//��� �������� ������ ���� �������������� �������
//(� ������ ����� �������!)
//�������� ������ ���� ����������!
function MakeMaterialList(MatID:integer):boolean;
Var i,x,y,TexID{,ipos}:integer;
    pBuf{,ppos}:pointer;
Begin with Materials[MatID] do begin
 MakeMaterialList:=true;
// glDeleteLists(ListNum,1);
 if ListNum>0 then glDeleteTextures(1,@ListNum);
 //1. �������� ������ ����� "���������" ��������
 x:=0;y:=0;
 for i:=0 to CountOfLayers-1 do if Layers[i].IsTextureStatic then begin
  TexID:=Layers[i].TextureID;
  if Textures[TexID].ImgWidth>x then x:=Textures[TexID].ImgWidth;
  if Textures[TexID].ImgHeight>y then y:=Textures[TexID].ImgHeight;
 end else begin                   //��� ������������ ��������
  //!dbg: ���� �� ����� �������� � �������������
  TexID:=round(Controllers[Layers[i].NumOfTexGraph].Items[0].Data[1]);
  if Textures[TexID].ImgWidth>x then x:=Textures[TexID].ImgWidth;
  if Textures[TexID].ImgHeight>y then y:=Textures[TexID].ImgHeight;
 end;//of if/for

 Excentry:=x/y;
 //2. ������� ���������� �����
 GetMem(pBuf,x*y*4);              //����� RGBA
 FillChar(pBuf^,x*y*4,0);         //������ ������

 //3. ��������� ������������ ���������
 //(���� ��� ���� � ������������ �� �����������,
 //� ����� �������� ������������).
 TypeOfDraw:=Additive;
 for i:=0 to CountOfLayers-1 do begin
  if Layers[i].IsTextureStatic then TexID:=Layers[i].TextureID
     else TexID:=round(Controllers[Layers[i].NumOfTexGraph].Items[0].Data[1]);
  //��������: ������� �� ��������   
  if Textures[TexID].pImg=nil then begin
   MakeMaterialList:=false;
   exit;
  end;//of if
  case Layers[i].FilterMode of
   Opaque:begin
    AddOpaque(pBuf,Textures[TexID].pImg,Textures[TexID].ImgWidth,
              Textures[TexID].ImgHeight,x,y,255);
    TypeOfDraw:=Opaque;
   end;//of Opaque
   ColorAlpha:begin
    Add2Alpha(pBuf,Textures[TexID].pImg,Textures[TexID].ImgWidth,
              Textures[TexID].ImgHeight,x,y,255);
    if TypeOfDraw<>Opaque then TypeOfDraw:=ColorAlpha;
   end;//of 2 Color Alpha
   FullAlpha,5,6,8:begin
    BlendTex(pBuf,Textures[TexID].pImg,Textures[TexID].ImgWidth,
             Textures[TexID].ImgHeight,x,y,1.0);
    //TypeOfDraw:=FullAlpha;
    if TypeOfDraw<>Opaque then TypeOfDraw:=FullAlpha;
   end;//of FullAlpha
   Additive,AddAlpha:begin
    AddAdd(pBuf,Textures[TexID].pImg,Textures[TexID].ImgWidth,
             Textures[TexID].ImgHeight,x,y,255);
   end;//of Additive
  end;//of for case
 end;//of for i

 //����� ������. ������ ������� ������:
 glGenTextures(1,@ListNum);       //����� ����������� ������
// ListNum:=glGenLists(1);
// glNewList(ListNum,GL_COMPILE);  //������� ������ ��������
 glBindTexture(GL_TEXTURE_2D,ListNum);//�������� ������
  glTexImage2D(GL_TEXTURE_2D,0,4,x,y,0,GL_RGBA,GL_UNSIGNED_BYTE,pBuf);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
// glEndList;                      //����� ������
                 
 FreeMem(pBuf);
end;End;
//---------------------------------------------------------
//������� ��� LoadTexture: ��������� ������� ������ ���� ������� �� �����,
//��� ���� ����������
//���������� true ��� ������
function CreateAllTextures(dirName:string;r,g,b:GLfloat):boolean;
Var i,j,w,h{,d}:integer;sName:string;
    a:array[1..8*8*4] of byte;
    ag:array[1..32*32*4] of byte;
    pRet:pointer;
Begin
 CreateAllTextures:=false;        //���� ������� ���
 TexErr:='';                      //��� ������
 //1. ���������� ������, ���� ��� ��� ������:
 for i:=0 to CountOfTextures-1 do if Textures[i].pImg<>nil then begin
  FreeMem(Textures[i].pImg);
  Textures[i].pImg:=nil;
 end;//of for i
 //���� �� ���� ���������
 for i:=0 to CountOfTextures-1 do begin
  case Textures[i].ReplaceableID of
   0:begin                        //���������� ��������
    sName:=Textures[i].FileName;  //��� ��������
    LoadTexture(dirName,sName,w,h,pRet);
    Textures[i].pImg:=pRet;
    if pRet=nil then exit;
    Textures[i].ImgWidth:=w;
    Textures[i].ImgHeight:=h;
   end;//of 0
   1:begin                        //���� �������
    j:=1;
    repeat
     a[j]:=round(r*255);
     a[j+1]:=round(g*255);
     a[j+2]:=round(b*255);a[j+3]:=255;
     j:=j+4;
    until j>8*8*4;
    //����������� � �����
    GetMem(Textures[i].pImg,8*8*4);
    Move(a,Textures[i].pImg^,8*8*4);
    Textures[i].ImgWidth:=8;
    Textures[i].ImgHeight:=8;
   end;//of 1
   2:begin                          //������ (����)
    j:=1;
    repeat
     ag[j+3]:=TeamGlowAlpha[(j shr 2)+1];//������������� ������
     ag[j]:=round(r*ag[j+3]);
     ag[j+1]:=round(g*ag[j+3]);
     ag[j+2]:=round(b*ag[j+3]);
     j:=j+4;
    until j>32*32*4;
    //����������� � �����
    GetMem(Textures[i].pImg,32*32*4);
    Move(ag,Textures[i].pImg^,32*32*4);
    Textures[i].ImgWidth:=32;
    Textures[i].ImgHeight:=32;
   end;//of TeamGlow;
  end;//of case
  if Textures[i].ReplaceableID>=3 then begin //��������� ��������� �������
   case Textures[i].ReplaceableID of
    11:sName:='ReplaceableTextures\Cliff\Cliff0.blp';
    31:sName:='ReplaceableTextures\LordaeronTree\LordaeronSummerTree.blp';
    32:sName:='ReplaceableTextures\AshenvaleTree\AshenTree.blp';
    33:sName:='ReplaceableTextures\BarrensTree\BarrensTree.blp';
    34:sName:='ReplaceableTextures\NorthrendTree\NorthTree.blp';
    35:sName:='ReplaceableTextures\Mushroom\MushroomTree.blp';
   else sName:='ReplaceableTextures\LordaeronTree\LordaeronSummerTree.blp';
   end;//of case
   LoadTexture(dirName,sName,w,h,pRet);
   Textures[i].pImg:=pRet;
   if pRet=nil then exit;
   Textures[i].ImgWidth:=w;
   Textures[i].ImgHeight:=h;
  end;//of if
 end;//of for
 //���� ���� ��������� �� ������� - ������:
 if (TexErr<>'') and IsShowTexError then begin
    MessageBox(0,
    PChar('�� ������� ����� �������:'+#13#10+TexErr),
    scError,mb_iconexclamation);
    IsShowTexError:=false;        //������ �� ���������� ������
 end;//of if
 CreateAllTextures:=true;         //��� ������
End;

//---------------------------------------------------------
//���������������: ����������� DXT1 � DXT3-�����������
//�����������. pSrc - ��������� �� �����������
//w,h - ��� ������� (� ��������), frmt - ��� ��������
//(0,1 - DXT1, 8 - DXT3).
//�������� ������ � pDest � ������������� �����������
//� ���� �����.
procedure DecompressDXT(pSrc:pointer;w,h,frmt:integer;var pDest:pointer);
type TClr=record
 r,g,b:byte;
end;//of TClr
Var i,j,x,y,psSrc,psDest,dd,c0,c1:integer;
    index:byte;
    alp,a:int64;
    Color:array [0..3] of TClr;
Begin
 GetMem(pDest,w*h*4);             //�������� ������
 psSrc:=integer(pSrc);
 psDest:=integer(pDest);
 //�������� �������������
 y:=0;
 repeat                           //���� �� y
  x:=0;
  repeat                          //���� �� x
   //1. ������ �����-����, ���� �� ����
   if frmt=8 then begin
    Move(pointer(psSrc)^,alp,8); //������ ����� �����
    psSrc:=psSrc+8;               //������� ���������
   end;//of if (DXT3)
   //2. ������ ������������ �����: c0 � c1
   c0:=0;c1:=0;
   Move(pointer(psSrc)^,c0,2);psSrc:=psSrc+2;
   Move(pointer(psSrc)^,c1,2);psSrc:=psSrc+2;
   //3. �������� �������� ����
   color[0].b:=((c0 shr 11) and $1f) shl 3;
   color[0].g:=((c0 shr  5) and $3f) shl 2;
   color[0].r:=(c0 and $1f) shl 3;
   color[1].b:=((c1 shr 11) and $1f) shl 3;
   color[1].g:=((c1 shr  5) and $3f) shl 2;
   color[1].r:=(c1 and $1f) shl 3;
   if c0>c1 then begin
    color[2].r:=(color[0].r * 2 + color[1].r) div 3;
    color[2].g:=(color[0].g * 2 + color[1].g) div 3;
    color[2].b:=(color[0].b * 2 + color[1].b) div 3;
    color[3].r:=(color[0].r + color[1].r * 2) div 3;
    color[3].g:=(color[0].g + color[1].g * 2) div 3;
    color[3].b:=(color[0].b + color[1].b * 2) div 3;
   end else begin
    color[2].r:=(color[0].r + color[1].r) shr 1;
    color[2].g:=(color[0].g + color[1].g) shr 1;
    color[2].b:=(color[0].b + color[1].b) shr 1;
    color[3].r:=0;
    color[3].g:=0;
    color[3].b:=0;
   end;//of if

   //������� �����������
   for j:=0 to 3 do begin
    Move(pointer(psSrc)^,index,1);inc(psSrc);
    dd:=psDest+(w*(y+j)+x)*4;
    for i:=0 to 3 do begin
     Move(Color[index and 3].r,pointer(dd)^,1);inc(dd);
     Move(Color[index and 3].g,pointer(dd)^,1);inc(dd);
     Move(Color[index and 3].b,pointer(dd)^,1);inc(dd);
     if frmt=8 then begin         //����� �����
      a:=(alp and $0F) shl 4;
      Move(a,pointer(dd)^,1);inc(dd);
      alp:=alp shr 4;
     end else begin
      if ((index and 3)=3) and (c0 <= c1) then a:=0
                                          else a:=255;
      Move(a,pointer(dd)^,1);inc(dd);
     end;//of if(format)
     index:=index shr 2;
    end;//of for i
   end;//of for j

   x:=x+4;                        //�������� ����� (���� 4x4)
  until x>=w;                     //����� ������ �� X
  y:=y+4;                         //��������� ����� (���� 4x4)
 until y>=h;
End;
//---------------------------------------------------------
//���������������: ���������� � ��������� ������� (ips)
//����������� ����������� (������ �� ���� � ��� ���������
//���� � dblp).
//true, ���� �� � �������
function WriteMipMap(var ips:integer;hdrSize,bufSize:integer;
                     var dblp:TIJCore):boolean;
Begin
 //1. ��������� ��������� � ������� �����������
 WriteMipMap:=true;
 dblp.IJBytes:=pointer(ips);
 dblp.IJSizeBytes:=bufSize;

{ dblp.ijprops[0]:=255;
 dblp.ijprops[1]:=255;
 dblp.ijprops[2]:=255;
 dblp.ijprops[3]:=255;
 dblp.ijprops[4]:=$0B;
 dblp.ijprops[5]:=0;
 dblp.ijprops[6]:=0;
 dblp.ijprops[7]:=0;}
 if ijlWrite(@dblp,13)<>0 then begin
  WriteMipMap:=false;
  exit;
 end;//of if (Err)
 
 Move(pointer(integer(dblp.IJBytes)+4)^,dblp.IJBytes^,dblp.IJSizeBytes-4);
 ips:=ips+dblp.IJSizeBytes-4;
End;
//---------------------------------------------------------
//���������������: ��������� ����������� pImg � 2 ����
//�� ���� x � y. ������������ ���� width/height � dblp.
//���� ��������� ��� ������, ���������� false
function MinimizeImage(pImg:pointer;var dblp:TIJCore):boolean;
Var i,ii,psSrc,psDst:integer;
Begin
 MinimizeImage:=true;
 if (dblp.width=1) and (dblp.height=1) then begin
  MinimizeImage:=false;
  exit;
 end;//of if
 if dblp.width=1 then begin
  dblp.height:=dblp.height shr 1;
  exit;
 end;//of dblp.width
 if dblp.height=1 then begin
  dblp.width:=dblp.width shr 1;
  exit;
 end;//of dblp.height

 i:=0;psSrc:=integer(pImg);psDst:=psSrc;
 repeat                           //���� �� y
  ii:=0;
  repeat                          //���� �� x
   Move(pointer(psSrc)^,pointer(psDst)^,4);
   psSrc:=psSrc+8;                //������� 1 �������
   psDst:=psDst+4;
   ii:=ii+2;
  until ii>=dblp.width;
  i:=i+2;                         //��������
  psSrc:=psSrc+4*dblp.width;      //������� 1 ������
 until i>=dblp.height;

 dblp.width:=dblp.width shr 1;
 dblp.height:=dblp.height shr 1;
 dblp.IJWidth:=dblp.width;
 dblp.IJHeight:=dblp.height;
End;
//---------------------------------------------------------
//���������������: ����������� �����������,
//���������� �� �������
procedure DecompressPAL(pDta:pointer;width,height,m2:integer;var pImg:pointer);
Var psPal,psSrc,psDest,psAlpha,i,tmp,a:integer;
Begin
 GetMem(pImg,width*height*4);     //�������� ������
 psSrc:=integer(pDta);            //��������� �� ����� �����
 psPal:=psSrc-256*4;              //��������� �� �������
 psDest:=integer(pImg);           //������� � ������
 if m2=8 then psAlpha:=psSrc+width*height; //������� �����-�����
 //���� ����������
 for i:=1 to width*height do begin
  tmp:=0;a:=0;
  Move(pointer(psSrc)^,tmp,1);    //������ ��� �����
  inc(psSrc);
  Move(pointer(psPal+tmp*4)^,tmp,4);//������ RGB �����
  if m2=8 then Move(pointer(psAlpha)^,a,1)//������ �����
          else a:=255;
  inc(psAlpha);
  tmp:=tmp or (a shl 24);        //�������� RGBA
  Move(tmp,pointer(psDest)^,4);   //��������
  psDest:=psDest+4;
 end;//of for i
End;
//---------------------------------------------------------
//������������ �������� WoW � blp1 (WC3).
//���������� ������������ � ��� �� ����.
//���� IsBatch=true, �� ��-BLP ����� ������������
//��� ������ ��������� �� �������s
//���������� true � ������ �������� ���������
function ConvertBLP2ToBLP(fname:string;IsBatch:boolean):boolean;
type TBlpHeader=record
 sign,tp,cd,w,h,d,one:integer;
end;//of TBlpHeader
Var i,ips,tmp,width,height,hdrSize:integer;
    p,pImg,pBuf:pointer;
    m1,m2:byte;
    blph:TBlpHeader;
    mipofs:array[0..15] of integer;//�������� mip-����
    miplengths:array[0..15] of integer;//����� mip-����
//    pmips:pointer;
    dblp:TIJCore;
Begin
 Result:=false;
 AssignFile(fblp,fname);
 {$I-}
 reset(fblp,1);                   //������� ����
 if IOResult<>0 then exit;
 {$I+}
 //������ ������ �������� ����
 GetMem(p,FileSize(fblp)+10);
 BlockRead(fblp,p^,FileSize(fblp));
 CloseFile(fblp);                 //������� ����

 //�������� ������ �����.
 //1. ���������, ��� �� ��� blp.
 ips:=integer(p);
 Move(p^,tmp,4);                  //������ ID �����
 if tmp<>$32504C42 then begin     //������
  if not IsBatch then MessageBox(0,'�������� ������ �����',scError,mb_iconstop);
  FreeMem(p);
  exit;
 end;//of if(err)

 //2. ���������� ������ �������� �����������.
 Move(pointer(ips+4)^,tmp,4);     //������ ��� �������
 Move(pointer(ips+8)^,m1,1);      //������ �������
 Move(pointer(ips+9)^,m2,1);
 if (tmp<>1) or ((m1<>2) and (m1<>1)) then begin
  MessageBox(0,'IJ-�������� �� ��������������',scError,mb_iconstop);
  FreeMem(p);
  exit;
 end;//of if(err)

 Move(pointer(ips+$0C)^,width,4);    //x
 Move(pointer(ips+$10)^,height,4);   //y
 Move(pointer(ips+$14)^,tmp,4);      //�������� �����������

 //������ ���������� � �������������:
 if m1=1 then DecompressPAL(pointer(tmp+ips),width,height,m2,pImg) else
 case m2 of
  0,1,8:DecompressDXT(pointer(tmp+ips),width,height,m2,pImg);
  else begin
   MessageBox(0,'������ ������ �� ���������',scError,mb_iconstop);
   FreeMem(p);
   exit;
  end;
 end;//of case

 //������ ����� ����� ������������, ������ ��� � WC3-blp.
 //a. �������������� IJL:
 if (@ijlInit=nil) or (@ijlWrite=nil) or (@ijlFree=nil) then begin
  MessageBox(0,'���������� ijl15.dll �� �������.'#13#10+
               '�������� blp-������� ����������.',
               scError,mb_iconstop);
  FreeMem(pImg);
  FreeMem(p);
  exit;
 end;//of if
 FillChar(dblp,SizeOf(dblp),0);
 if ijlInit(@dblp)<>0 then begin
  MessageBox(0,'������ ������������� IJL.'#13#10+
               '�������� blp-������� ����������.',
               scError,mb_iconstop);
  FreeMem(pImg);
  FreeMem(p);
  exit;
 end;//of if

 //b. �������� ����� ����������� �������.
 GetMem(pBuf,4*width*height*5);   //�������, ������ :)
 FillChar(pBuf^,4*width*height,0);

 dblp.UseIJPEGProperties:=0;
 dblp.DIBBytes:=pImg;
 dblp.width:=width;
 dblp.height:=height;
 dblp.DIBPadBytes:=0;
 dblp.DIBChannels:=4;
 dblp.DIBColor:=$0FF;         //?
 dblp.DIBSubsampling:=0;

 ips:=integer(pBuf)+sizeof(blph)+16*4*2+4;
 dblp.IJBytes:=pointer(ips);//��������
 dblp.IJSizeBytes:=4*width*height*5;
 dblp.IJWidth:=width;
 dblp.IJHeight:=height;
 dblp.IJChannels:=4;
 dblp.IJColor:=$0FF;
 dblp.IJSubsampling:=0;
 dblp.IsConvRequired:=1;
 dblp.IsUnsamplingRequired:=1;
 dblp.Quality:=75;

 //���������� � ����� ��������� IJPEG
 if ijlWrite(@dblp,11)<>0 then begin
  MessageBox(0,'������ ��������:'#13#10+
               '�������� blp-������� ����������.',
               scError,mb_iconstop);
  FreeMem(pImg);
  FreeMem(pBuf);
  FreeMem(p);
  exit;
 end;//of if
 hdrSize:=dblp.IJSizeBytes;       //������ ������ ���������
 FillChar(pointer(integer(pBuf)+$30F)^,1,$C0);//DBG!

 //c. ���� ������������ ���� mip-���� ��������
// FillChar(integer(pBuf)^,
 ips:=integer(pBuf)+$49C;
 FillChar(mipofs,sizeof(mipofs),0);
 FillChar(miplengths,sizeof(miplengths),0);
 for i:=0 to 15 do begin
  mipofs[i]:=ips-integer(pBuf);
  if not WriteMipMap(ips,hdrSize,4*width*height*5,dblp) then begin
   MessageBox(0,'������ ��������:'#13#10+
                '�������� blp-������� ����������.',
                scError,mb_iconstop);
   FreeMem(pImg);
   FreeMem(pBuf);
   FreeMem(p);
   exit;
  end;//of if
  miplengths[i]:=dblp.IJSizeBytes-4;
  if not MinimizeImage(pImg,dblp) then break;
 end;//of for i

 //d. ��������� � ������ ��� ����������
 blph.sign:=$31504C42;            //���������
 blph.tp:=0;
 blph.cd:=8;
 blph.w:=width;
 blph.h:=height;
 blph.d:=4;
 blph.one:=1;
 Move(blph,pBuf^,SizeOf(blph));   //��������� �����!
 Move(mipofs[0],pointer(integer(pBuf)+SizeOf(blph))^,16*4);
 Move(miplengths[0],pointer(integer(pBuf)+SizeOf(blph)+16*4)^,16*4);
 Move(hdrSize,pointer(integer(pBuf)+SizeOf(blph)+16*4*2)^,4);

 AssignFile(fblp,fname);
 Rewrite(fblp,1);
 BlockWrite(fblp,pBuf^,ips-integer(pBuf));
 CloseFile(fblp);

 ijlFree(@dblp);                  //���������� ����������
 FreeMem(pImg);
 FreeMem(pBuf);
 FreeMem(p);
 Result:=true;
End;
//----------------------------------------------------------
//���������� ������� ��������� �����������
procedure CalcBounds(geoID:integer;var anim:TAnim);
Var minx,maxx,miny,maxy,minz,maxz:GLFloat;
    ii:integer;
Begin with Geosets[geoID],anim do begin
  if geoID>length(Geosets)-1 then MessageBox(0,'asf','asdf',0); 
  minx:=Vertices[0,1];miny:=Vertices[0,2];minz:=Vertices[0,3];
  maxx:=Vertices[0,1];maxy:=Vertices[0,2];maxz:=Vertices[0,3];
  //����� ������:
  for ii:=0 to CountOfVertices-1 do begin
   if Vertices[ii,1]<minx then minx:=Vertices[ii,1];
   if Vertices[ii,1]>maxx then maxx:=Vertices[ii,1];
   if Vertices[ii,2]<miny then miny:=Vertices[ii,2];
   if Vertices[ii,2]>maxy then maxy:=Vertices[ii,2];
   if Vertices[ii,3]<minz then minz:=Vertices[ii,3];
   if Vertices[ii,3]>maxz then maxz:=Vertices[ii,3];
  end;//of for ii
  if MinimumExtent[1]<0 then MinimumExtent[1]:=minx*2;
  if MinimumExtent[2]<0 then MinimumExtent[2]:=miny*2;
  if MinimumExtent[3]<0 then MinimumExtent[3]:=minz*2;
  MaximumExtent[1]:=maxx*2;
  MaximumExtent[2]:=maxy*2;
  MaximumExtent[3]:=maxz*2;
  //��������� ������
  BoundsRadius:=sqrt(sqr(MaximumExtent[1]-MinimumExtent[1])+
                sqr(MaximumExtent[2]-MinimumExtent[2])+
                sqr(MaximumExtent[3]-MinimumExtent[3]))*0.5;
end;End;

//----------------------------------------------------
//������ ������ GeosetAnim (�.�. �� ����������,
//������� 1 Alpha � Color) ��� ��������� GeosetID.
//� ������ �������������, GeosetAnimID ����������
//���������� ID ��������� �������� ���������
//��� �� (-1), ���� ������� ��� ����������
function CreateGeosetAnim(GeosetID:integer):integer;
Var {ID,}i:integer;
Begin
 //1. ��������, ���������� �� ��� ����� GeosetAnim.
 //������ ��������� ����� GeosetAnim � ������
 Result:=-1;
 for i:=0 to CountOfGeosetAnims-1 do with GeosetAnims[i] do begin
//  if
 end;//of for i
End;
//----------------------------------------------------
//���������������: ������� RDTSC
function GetTSC:cardinal;
Var tsc:cardinal;
Begin
 asm
  db 0Fh,31h
  mov tsc,eax
 end;
 GetTSC:=tsc;
End;

//���������������: ���������� ���� � ����� War'�
function GetWarPath:string;
Var hndKey:HKEY;tmp,num:integer;
    a:array[1..1000] of Char;
    pc:PChar;
Begin
 pc:=@a;
 num:=1000;
 FillChar(a[1],1000,0);
 RegOpenKeyEx(HKEY_CURRENT_USER,'Software\Blizzard Entertainment\Warcraft III',
              0,KEY_READ,hndKey);
 RegQueryValueEx(hndKey,'InstallPath',nil,@tmp,@a[1],@num);
 RegCloseKey(hndKey);
 GetWarPath:=string(pc)+'\';  //������� ������
End;

//�������� storm.dll � MPQ-�������
procedure InitMPQs;
Var hStorm:integer;stui:TStartupInfo;pi:_Process_Information;
Begin
 IsLoadMPQ:=false;                //���� MPQ �� ���������

// CreateProcess('readmpq.mvp',nil,nil,nil,false,0,nil,nil,stui,pi);
 hStorm:=LoadLibrary('storm.dll');
 if hStorm=0 then hStorm:=LoadLibrary(PChar(WarPath+'storm.dll'));
 if hStorm=0 then exit;           //������ ��������

 //Storm ���������. �������� ������ �������
 @SFileOpenArchive:=GetProcAddress(hStorm,pointer(266));
 @SFileOpenFileEx:=GetProcAddress(hStorm,pointer(268));
// @SFileOpenFileEx:=GetProcAddress(hStorm,pointer(279));
 @SFileGetFileSize:=GetProcAddress(hStorm,pointer(265));
 @SFileCloseFile:=GetProcAddress(hStorm,pointer(253));
 @SFileReadFile:=GetProcAddress(hStorm,pointer(269));
// @SFileSetLocale:=GetProcAddress(hStorm,pointer(272));
 if (@SFileOpenArchive=nil) or (@SFileOpenFileEx=nil) or
    (@SFileGetFileSize=nil) or (@SFileCloseFile=nil) or
    (@SFileReadFile=nil) or (@SFileSetLocale=nil) then exit;

 //������ ��������. ������ �������� ���������� MPQ:
 SFileSetLocale($409);
 if not SFileOpenArchive('war3.mpq',0,0,hWar3)
 then SFileOpenArchive(PChar(WarPath+'war3.mpq'),0,0,hWar3);

 if not SFileOpenArchive('war3x.mpq',1,0,hWar3x)
 then SFileOpenArchive(PChar(WarPath+'war3x.mpq'),0,0,hWar3x);

 if not SFileOpenArchive('war3patch.mpq',8,0,hWar3patch)
 then SFileOpenArchive(PChar(WarPath+'war3patch.mpq'),0,0,hWar3patch);

 IsLoadMPQ:=true;
End;

//���������������
//���������� ������� ������� ������, ��������������� ����������
procedure AddExtension(StrtKey,StrtKey2:PChar;descr:string);
Var Disp,tmp:integer;
    Key,Key2,Key3,Key4:HKey;
    s:string;
    a:array[0..1024] of char;
    pc:PChar;
Begin
 //1. ������� ��� ������� ��� MDL-������ (��� ������� ���� ������)
 pc:=@a[0];
 RegCreateKeyEx(HKEY_CLASSES_ROOT,StrtKey,0,nil,0,KEY_ALL_ACCESS,nil,Key,@Disp);
 if Disp=REG_CREATED_NEW_KEY then begin //���� �� �����������
  s:=string(StrtKey2)+#0;
  RegSetValueEx(Key,nil,0,REG_SZ,@s[1],length(s));
  s:=string(StrtKey2);            //��� ������ �������
 end else begin                   //���� ����. ������ ��� �������
  Disp:=1024;
  if RegQueryValueEx(Key,nil,nil,@tmp,@a[0],@Disp)<>ERROR_SUCCESS then exit;
  s:=string(pc);  
 end;//of if
 RegCloseKey(Key);                //������� ��� �������� ����

 //2. ����������� � �������� mdl_auto_file
 RegCreateKeyEx(HKEY_CLASSES_ROOT,PChar(s),0,nil,0,KEY_ALL_ACCESS,
                nil,Key,@Disp);
 if Disp=REG_CREATED_NEW_KEY then begin //���� �� �����������
  //�������� ��������
  s:=descr+#0;
  RegSetValueEx(Key,nil,0,REG_SZ,@s[1],length(s));
  //������� ��� ����������� ��������
  RegCreateKeyEx(Key,'shell',0,nil,0,KEY_ALL_ACCESS,
                 nil,Key2,@Disp);
  RegCreateKeyEx(Key2,'open',0,nil,0,KEY_ALL_ACCESS,
                 nil,Key3,@Disp);
  RegCreateKeyEx(Key3,'command',0,nil,0,KEY_ALL_ACCESS,
                 nil,Key4,@Disp);
  //� ��������� ��������� ������
  s:='"'+ParamStr(0)+'" "%1"'#0;
  RegSetValueEx(Key4,nil,0,REG_SZ,@s[1],length(s));
  //������ ����������� �����
  RegCloseKey(Key4);
  RegCloseKey(Key3);
 end else begin                   //�� ��� ����. ������� ���� "Shell"
  RegCreateKeyEx(Key,'shell',0,nil,0,KEY_ALL_ACCESS,
                 nil,Key2,@Disp);
 end;

 //������ ���� 2 �������� �����. ����� ����������� �����.
 RegCreateKeyEx(Key2,'Open with MdlVis',0,nil,0,KEY_ALL_ACCESS,
                nil,Key3,@Disp);
 if Disp=REG_CREATED_NEW_KEY then begin  //������ ����� ���������
  RegCreateKeyEx(Key3,'command',0,nil,0,KEY_ALL_ACCESS,
                 nil,Key4,@Disp);
  //� ��������� ��������� ������
  s:='"'+ParamStr(0)+'" "%1"'#0;
  RegSetValueEx(Key4,nil,0,REG_SZ,@s[1],length(s));
  //������ ����������� �����
  RegCloseKey(Key4);
//  RegCloseKey(Key3);
 end;//of if

 RegCloseKey(Key3);
 RegCloseKey(Key2);
 RegCloseKey(Key);
 
End;

initialization
 IsShowTexError:=true;
 IsCanSaveMDVI:=true;
 //������� ���� � ����� War:
 WarPath:=GetWarPath;
 InitMPQs;                        //�������� MPQ � Storm.dll
 AddExtension('.mdl','mdl_auto_file','������ War');
 AddExtension('.mdx','mdx_auto_file','������ War [�������� ������]'); 
 //���������� ��������� ��� ������ ����������
 hIJL:=LoadLibrary('ijl15.dll');  //������� ��������
 if hIJL=0 then begin
  hIJL:=LoadLibrary(PChar(WarPath+'ijl15.dll'));
 end;//of if
 @ijlInit:=GetProcAddress(hIJL,'ijlInit');
 @ijlRead:=GetProcAddress(hIJL,'ijlRead');
 @ijlFree:=GetProcAddress(hIJL,'ijlFree');
 @ijlWrite:=GetProcAddress(hIJL,'ijlWrite');
end.
