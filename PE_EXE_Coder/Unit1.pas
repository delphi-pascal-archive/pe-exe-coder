{
 ������ ���������� � (����������� ������ ���) ���� (����, ���� �����, ������) �������� ������.
  ��������:
  1. ��������� ������, ���� ������ ��� 2.
  2. ��������� ������, ���� ������ �� �����.
  3. ��������� ��� � ������� (������ - ���������, ��� � hex
     ��������� ����� �����).
  4. ������ ���� � ���� ������.
     (��� ���������� ������ ���������� ��������� �� �����
      ����� ����� � ������� ���������� "�����" ����� ������).
  ����� ����: ������� ������.
              peexe@mail.ru
  � ����� ������ ������� ����������� ������ ��� � �����
  ��������� ��������.
}

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, XPMan;  // ������� ����� ��� Delphi7

Type
 TForm1 = class(TForm)
   Edit1: TEdit;
   Label1: TLabel;
   OpenPEEXE: TButton;
   SetPass: TButton;
   OpenDialog1: TOpenDialog;
   XPManifest1: TXPManifest;
    Label2: TLabel;
   procedure SetPassClick(Sender: TObject);
   procedure OpenPEEXEClick(Sender: TObject);
 end;
 //----------- ��������� ������. ------------------------------
Type
 TSect = packed record
   Name: Array [0..7] of Char;          // ���.
   VSiz: DWORD;                         // ����������� ������.
   VOfs: DWORD;                         // ����������� ��������.
   FSiz: DWORD;                         // ������ � �����.
   FOfs: DWORD;                         // �������� � �����.
   Res: Array [0..11] of Byte;          // �� ����������.
   Flag: DWORD;                         // �����.
 end;
 //----------------------------------------------------------------------------------
Const
 { ��������� �������� ������ (��. DisASM)
   String - ���� � �������� � ��������� �� �������� %). }
 //---------------- ������� ���������� -----------------------------------------------
 mov_eax_:         String = 'B8';       // MOV EAX,�������� DWORD
 mov_ecx_:         String = 'B9';       // MOV ECX,�������� DWORD
 mov_esi_:         String = 'BE';       // MOV ESI,�������� DWORD
 mov_edi_:         String = 'BF';       // MOV EDI,�������� DWORD
 mov_IXI_:         String = 'C705';     // MOV [����� � ������],����� ������ ��������
 mov_IXI_eax:      String = 'A3';       // MOV [����� � ������],EAX (�������� EAX � ������)
 mov_eax_esp:      String = '89E0';     // MOV EAX,ESP
 mov_edx_IeaxI:    String = '8B10';     // MOV EDX,[EAX] (���������� EDX �������� �� ������ � EAX)
 mov_eax_IediI:    String = '8B07';     // MOV EAX,[EDI]
 mov_esi_IesiI:    String = '8B36';     // MOV ESI,[ESI]
 mov_esi_Ieax1ChI: String = '8B701C';   // MOV ESI,[EAX+$1C]
 mov_edx_Ieax3ChI: String = '8B503C';   // MOV EDX,[EAX+$3C] $3C - �������� ��.
 mov_edi_Ieax20hI: String = '8B7820';   // MOV EDI,[EAX+$20]
 mov_eax_Ieax78hI: String = '8B4078';   // MOV EAX,[EAX+$78] $78 - �������� ����. ��������.
 //----------------- ������� �������� -------------------------------------------------
 add_eax_edx:      String = '01D0';     // ADD EAX,EDX
 add_edx_eax:      String = '01C2';     // ADD EDX,EAX  (EDX:= EDX + EAX)
 add_edi_edx:      String = '01D7';     // ADD EDI,EDX
 add_esi_edx:      String = '01D6';     // ADD ESI,EDX
 add_edi_ecx:      String = '01CF';     // ADD EDI,ECX
 add_esi_ecx:      String = '01CE';     // ADD ESI,ECX
 sub_eax_:         String = '2D';       // SUB EAX ������ �� ������ �� EAX
 //------------------ ������� ������ �� ������ ------------------------------------------
 pushBy_:          String = '6A';       // PUSH ��������� � ���� (Byte)
 pushDW_:          String = '68';       // PUSH ��������� � ���� (DWORD)
 push_eax:         String = '50';       // PUSH ��������� � ���� EAX
 push_edx:         String = '52';       // PUSH ��������� � ���� EDX
 push_IXI:         String = 'FF35';     // PUSH [����� � ������] (��������� � ���� ����. �� ���. � ���.)
 pop_eax:          String = '58';       // POP EAX  ������� �� ����� � EAX
 //------------------ ������� ��������� (if) -------------------------------------------
 cmp_dx_:          String = '6681FA';   // CMP DX, �������� ��� ��������� (Byte)
 cmp_Ieax4hI_:     String = '817804';   // CMP [EAX+4],�������� ��� ��������� (DWORD)
 cmp_dw_Ieax08hI_: String = '817808';   // CMP Dword Ptr [EAX+$08],�������� ��� ��������� (DWORD)
 cmp_dw_Ieax0ChI_: String = '81780C';   // CMP Dword Ptr [EAX+$0C],�������� ��� ��������� (DWORD)
 //------------------- ������� ������� --------------------------------------------
 jz_:              String = '74';       // JZ �������� ������ (������ � ��������� ����� 0)
 jnz_:             String = '0F85';     // JNZ �������� ������ (������ � ��������� ����� 1)
 jmp_:             String = 'EB';       // JMP �������� ������ (������ ��� �������)
 jmpe_:            String = 'FF25';     // JMP ����� (������ �� �����)
 jmp_eax:          String = 'FFE0';     // JMP EAX ������ �� (DWORD ��������) � EAX
 //------------------- ������� ������ ���������� ---------------------------------
 call_eax:         String = 'FFD0';     // CALL E�� ����� ��������� �� ������ � EAX
 call_esi:         String = 'FFD6';     // CALL ESI ����� ��������� �� ������ � ESI
 call_dword_ptr_:  String = 'FF15';     // CALL Dword Ptr [����� � ������]
 //--------------------- ���������� �������� -----------------------------------------
 xor_ax_ax:        String = '6631C0';   // XOR AX,AX  (������� AX)
 or_eax_eax:       String = '09C0';     // OR EAX,EAX �������� ��� ��� EAX
 xchg_eax_edx:     String = '87C2';     // XCHG EAX,EDX (�������� �������� ��������� �������)
 //--------------- ����. ������� ��� ��������� ----------------------------------------------
 cld:              String = 'FC';       // CLD ���������� ������� (�������� ������ � ������� ����������� ���.)
 repe_cmpsb:       String = 'F3A6';     // REPE CMPSB (������� ��������� ���� �����)
 //----------------------------------------------------------------------------------
{ ������ ������������� ����� �-��, �����, �������, ������ ������������ � ���������� �����. }
 //----------------------------------------------------------------------------------
 MZ:               String = '4D5A';     // ��������� MZ.
 rocA:             String = '726F6341'; // GetP[rocA]ddress ��� � ������ ���������� 4-�� ����.
 USER32:           String = '5573657233322E646C6C00';   // User32.dll � �.�.
 LoadLibraryA:     String = '4C6F61644C6962726172794100';
 GetModuleHandleA: String = '4765744D6F64756C6548616E646C654100';
 RegisterClassExA: String = '5265676973746572436C61737345784100';
 CreateWindowExA:  String = '43726561746557696E646F7745784100';
 ShowWindow:       String = '53686F7757696E646F7700';
 GetMessageA:      String = '4765744D6573736167654100';
 TranslateMessage: String = '5472616E736C6174654D65737361676500';
 DispatchMessageA: String = '44697370617463684D6573736167654100';
 ExitProcess:      String = '4578697450726F6365737300';
 DefWindowProcA:   String = '44656657696E646F7750726F634100';
 PostQuitMessage:  String = '506F7374517569744D65737361676500';
 SendMessageA:     String = '53656E644D6573736167654100';
 TWinClass:        String = '5457696E436C61737300';
 WinTitle:         String = 'C2E2E5E4E8F2E520EFE0F0EEEBFC2E00'; // ������� ������.
 OK:               String = '4F4B00';
 Button:           String = '427574746F6E00';
 Edit:             String = '4564697400';

Var
  Form1: TForm1;
  OpenFileName: String;         // ��� � ���� � ��������� �����.
  BuffCode:     String;         // ����� ���������� ������� ���������� �����
  CodeAdd:      Array of Byte;  // ����� ���������� ������� �����. �����.

implementation

{$R *.dfm}
//----------------------------------------------------------------------------------
// �-�� ��� ���������� ������ ������� � �����.
// AddOpCod(���� �������� � ������; �����): ����� ������ ������� � ������;
Function AddOpCod(Base: DWORD; OpCOD: String): DWORD;
begin
 Result:= DWORD(Length(BuffCode) div 2) + Base;
 BuffCode:= BuffCode + OpCOD;
end;
//----------------------------------------------------------------------------------
// �-�� ��� �������������� ������ ���� (String) � ��������
// � ������ ���� (array of byte) � ������� ������������ �����.
Procedure Compile;
var
 r,i,k: Integer;
 temp: String;
begin
 k:= 1;
 r:= Length(BuffCode) div 2;
 SetLength(CodeAdd, r);
 For i:= 0 To r - 1 Do
  begin
   temp:= Copy(BuffCode,k,2);
   k:= k + 2;
   CodeAdd[i]:= StrToInt('$' + temp);
  end;
end;
//----------------------------------------------------------------------------------
// �������������� DWORD --> (String � �������� ��������)
Function DwToStr(D: DWORD): String;
var
 temp0,temp1: String;
begin
 temp1:= '';
 temp0:= IntToHex(D,8);
 temp1:= temp1 + Copy(temp0,7,2);
 temp1:= temp1 + Copy(temp0,5,2);
 temp1:= temp1 + Copy(temp0,3,2);
 temp1:= temp1 + Copy(temp0,1,2);
 Result:= temp1;
end;
//----------------------------------------------------------------------------------
// ���������� ������ (32 �����) Edit1 c �������.
Function GetPasword():String;
var
 S0,S1: String;
 i: Integer;
begin
 S1:='';
 S0:= Form1.Edit1.Text;
 For i:=1 To 32 Do
  begin
  if i <= Length(S0) Then S1:= S1 + IntToHex(Ord(S0[i]),2)
                     Else S1:= S1 + '00';
  end;
 Result:= S1;
end;
//----------------------------------------------------------------------------------
// ������� ����������� ���������� �����.
// ProgramList(���� �������� � ������;����� ����� ���������� �����): ����� ����� �����;
Function ProgramList(Bas,Old_Ram_EP: DWORD): DWORD;
var // ������ ��������.
 AdrUser,AdrLoadLibrar,AdrRegClasExA,AdrCreateWExA,AdrShowWindow,
 AdrGetMesageA,AdrTranslMess,AdrDispMesagA,AdrExitProces,AdrGetModuleH,
 AdrDefWinProA,AdrPostQitMes,AdrSendMesagA: DWORD;
 wcxSize,wcxStyle,wcxWndProc,wcxClsExtra,wcxWndExtra,hInst,
 wcxBkgndBrush,wcxMenuName,wcxClassName,wcxIcon,wcxSmallIcon,
 wcxCursor: DWORD;
 AdrWinClass,AdrWinTitle,hWnd,AdrOK,AdrButton,AdrEdit,hEDi,
 hwndd,EditBuff,BuffPasword: DWORD;
begin
 // ��������� ������ �������� ���������� �����.
 AdrUser:=       AddOpCod(Bas,USER32);
 AdrLoadLibrar:= AddOpCod(Bas,LoadLibraryA);
 AdrGetModuleH:= AddOpCod(Bas,GetModuleHandleA);
 AdrRegClasExA:= AddOpCod(Bas,RegisterClassExA);
 AdrCreateWExA:= AddOpCod(Bas,CreateWindowExA);
 AdrShowWindow:= AddOpCod(Bas,ShowWindow);
 AdrGetMesageA:= AddOpCod(Bas,GetMessageA);
 AdrTranslMess:= AddOpCod(Bas,TranslateMessage);
 AdrDispMesagA:= AddOpCod(Bas,DispatchMessageA);
 AdrExitProces:= AddOpCod(Bas,ExitProcess);
 AdrDefWinProA:= AddOpCod(Bas,DefWindowProcA);
 AdrPostQitMes:= AddOpCod(Bas,PostQuitMessage);
 AdrSendMesagA:= AddOpCod(Bas,SendMessageA);
 AdrWinClass:=   AddOpCod(Bas,TWinClass);
 AdrWinTitle:=   AddOpCod(Bas,WinTitle); 
 AdrOK:=         AddOpCod(Bas,OK);
 AdrButton:=     AddOpCod(Bas,Button);
 AdrEdit:=       AddOpCod(Bas,Edit);
 BuffPasword:=   AddOpCod(Bas,GetPasword());
 EditBuff:=      AddOpCod(Bas,'0000000000000000000000000000000000000000000000000000000000000000');
 hWnd:=          AddOpCod(Bas,'00000000');
 hEDi:=          AddOpCod(Bas,'00000000');
 hInst:=         AddOpCod(Bas,'00000000');
 // ��������� ��� ����������� ����.
 wcxSize:=       AddOpCod(Bas,'00000000');
 wcxStyle:=      AddOpCod(Bas,'00000000');
 wcxWndProc:=    AddOpCod(Bas,'00000000');
 wcxClsExtra:=   AddOpCod(Bas,'00000000');
 wcxWndExtra:=   AddOpCod(Bas,'00000000');
                 AddOpCod(Bas,'00000000');
 wcxIcon:=       AddOpCod(Bas,'00000000');
 wcxCursor:=     AddOpCod(Bas,'00000000');
 wcxBkgndBrush:= AddOpCod(Bas,'00000000');
 wcxMenuName:=   AddOpCod(Bas,'00000000');
 wcxClassName:=  AddOpCod(Bas,'00000000');
 wcxSmallIcon:=  AddOpCod(Bas,'00000000');
 hwndd:=         AddOpCod(Bas,'00000000');
 // ���������� ��� �����.
 Result:= AddOpCod(Bas,pop_eax);
 // ������� ���� Kernel32.dll � ������� � ��� GetProcAddress
 AddOpCod(Bas, xor_ax_ax);
 AddOpCod(Bas, mov_edx_IeaxI);
 AddOpCod(Bas, cmp_dx_+MZ);
 AddOpCod(Bas, jz_+'07'); // 07h - ����������� ���� ������ �����.
 AddOpCod(Bas, sub_eax_+DwToStr($10000));
 AddOpCod(Bas, jmp_+'F0'); // FF - F0 = ����������� ���� ������ �����.
 AddOpCod(Bas, mov_edx_Ieax3ChI);
 AddOpCod(Bas, add_edx_eax);
 AddOpCod(Bas, xchg_eax_edx);
 AddOpCod(Bas, mov_eax_Ieax78hI);
 AddOpCod(Bas, add_eax_edx);
 AddOpCod(Bas, mov_esi_Ieax1ChI);
 AddOpCod(Bas, add_esi_edx);
 AddOpCod(Bas, mov_edi_Ieax20hI);
 AddOpCod(Bas, add_edi_edx);
 AddOpCod(Bas, mov_ecx_+DwToStr($04));
 AddOpCod(Bas, mov_eax_IediI);
 AddOpCod(Bas, add_eax_edx);
 AddOpCod(Bas, cmp_Ieax4hI_+rocA);
 AddOpCod(Bas, jz_+'06');
 AddOpCod(Bas, add_edi_ecx);
 AddOpCod(Bas, add_esi_ecx);
 AddOpCod(Bas, jmp_+'ED');
 AddOpCod(Bas, mov_esi_IesiI);
 AddOpCod(Bas, add_esi_edx);
 // � edx - ���� Kernel, � esi - ����� GetProcAddress
 // ������ �������� � ���� ����� ������ ��� �-�� � ����
 AddOpCod(Bas, pushDW_+DwToStr(AdrGetModuleH));
 AddOpCod(Bas, push_edx);
 AddOpCod(Bas, pushDW_+DwToStr(AdrExitProces));
 AddOpCod(Bas, push_edx);
 AddOpCod(Bas, pushDW_+DwToStr(AdrLoadLibrar));
 AddOpCod(Bas, push_edx);
 AddOpCod(Bas, call_esi);
 AddOpCod(Bas, pushDW_+DwToStr(AdrUser));
 AddOpCod(Bas, call_eax);
 AddOpCod(Bas, pushDW_+DwToStr(AdrRegClasExA));
 AddOpCod(Bas, push_eax);
 AddOpCod(Bas, pushDW_+DwToStr(AdrCreateWExA));
 AddOpCod(Bas, push_eax);
 AddOpCod(Bas, pushDW_+DwToStr(AdrShowWindow));
 AddOpCod(Bas, push_eax);
 AddOpCod(Bas, pushDW_+DwToStr(AdrGetMesageA));
 AddOpCod(Bas, push_eax);
 AddOpCod(Bas, pushDW_+DwToStr(AdrTranslMess));
 AddOpCod(Bas, push_eax);
 AddOpCod(Bas, pushDW_+DwToStr(AdrDispMesagA));
 AddOpCod(Bas, push_eax);
 AddOpCod(Bas, pushDW_+DwToStr(AdrDefWinProA));
 AddOpCod(Bas, push_eax);
 AddOpCod(Bas, pushDW_+DwToStr(AdrPostQitMes));
 AddOpCod(Bas, push_eax);
 AddOpCod(Bas, pushDW_+DwToStr(AdrSendMesagA));
 AddOpCod(Bas, push_eax);
 // �������� GetProcAddress ��� ������ �-�� � �����
 // � ���������� ������ �-�� ������ �� ��� (��� �������� �������)
 AddOpCod(Bas, call_esi);
 AddOpCod(Bas, mov_IXI_eax+DwToStr(AdrSendMesagA));
 AddOpCod(Bas, call_esi);
 AddOpCod(Bas, mov_IXI_eax+DwToStr(AdrPostQitMes));
 AddOpCod(Bas, call_esi);
 AddOpCod(Bas, mov_IXI_eax+DwToStr(AdrDefWinProA));
 AddOpCod(Bas, call_esi);
 AddOpCod(Bas, mov_IXI_eax+DwToStr(AdrDispMesagA));
 AddOpCod(Bas, call_esi);
 AddOpCod(Bas, mov_IXI_eax+DwToStr(AdrTranslMess));
 AddOpCod(Bas, call_esi);
 AddOpCod(Bas, mov_IXI_eax+DwToStr(AdrGetMesageA));
 AddOpCod(Bas, call_esi);
 AddOpCod(Bas, mov_IXI_eax+DwToStr(AdrShowWindow));
 AddOpCod(Bas, call_esi);
 AddOpCod(Bas, mov_IXI_eax+DwToStr(AdrCreateWExA));
 AddOpCod(Bas, call_esi);
 AddOpCod(Bas, mov_IXI_eax+DwToStr(AdrRegClasExA));
 AddOpCod(Bas, call_esi);
 AddOpCod(Bas, mov_IXI_eax+DwToStr(AdrExitProces));
 AddOpCod(Bas, call_esi);
 AddOpCod(Bas, mov_IXI_eax+DwToStr(AdrGetModuleH));
 // ����� ��� ���������� ����, ���� �����, ������ (��. WinApi ���. ����)
 //------------------------------------------------------------
 AddOpCod(Bas, pushBy_+'00');
 AddOpCod(Bas, call_eax);
 //------------------------------------------------------------
 AddOpCod(Bas, mov_IXI_+DwToStr(wcxSize)+DwToStr($30));
 AddOpCod(Bas, mov_IXI_+DwToStr(wcxStyle)+DwToStr($03));
 AddOpCod(Bas, mov_IXI_+DwToStr(wcxWndProc)+DwToStr(Bas+$375));
 AddOpCod(Bas, mov_IXI_eax+DwToStr(hInst));
 AddOpCod(Bas, mov_IXI_+DwToStr(wcxBkgndBrush)+DwToStr($10));
 AddOpCod(Bas, mov_IXI_+DwToStr(wcxClassName)+DwToStr(AdrWinClass));
 //-------------------------------------------------------------
 AddOpCod(Bas, pushDW_+DwToStr(wcxSize));
 AddOpCod(Bas, call_dword_ptr_+DwToStr(AdrRegClasExA));
 //-------------------------------------------------------------
 AddOpCod(Bas, pushBy_+'00');
 AddOpCod(Bas, push_IXI+DwToStr(hInst));
 AddOpCod(Bas, pushBy_+'00');
 AddOpCod(Bas, pushBy_+'00');
 AddOpCod(Bas, pushDW_+DwToStr($6E));
 AddOpCod(Bas, pushDW_+DwToStr($E1));
 AddOpCod(Bas, pushDW_+DwToStr($14A));
 AddOpCod(Bas, pushDW_+DwToStr($19A));
 AddOpCod(Bas, pushDW_+DwToStr($80000));
 AddOpCod(Bas, pushDW_+DwToStr(AdrWinTitle));
 AddOpCod(Bas, push_IXI+DwToStr(wcxClassName));
 AddOpCod(Bas, pushBy_+'00');
 AddOpCod(Bas, call_dword_ptr_+DwToStr(AdrCreateWExA));
 AddOpCod(Bas, mov_IXI_eax+DwToStr(hWnd));
 //-------------------------------------------------------------
 AddOpCod(Bas, pushBy_+'01');
 AddOpCod(Bas, push_eax);
 AddOpCod(Bas, call_dword_ptr_+DwToStr(AdrShowWindow));
 //-------------------------------------------------------------
 AddOpCod(Bas, pushBy_+'00');
 AddOpCod(Bas, push_IXI+DwToStr(hInst));
 AddOpCod(Bas, pushBy_+'64');
 AddOpCod(Bas, push_IXI+DwToStr(hWnd));
 AddOpCod(Bas, pushBy_+'1D');
 AddOpCod(Bas, pushBy_+'50');
 AddOpCod(Bas, pushBy_+'28');
 AddOpCod(Bas, pushBy_+'41');
 AddOpCod(Bas, pushDW_+DwToStr($50000001));
 AddOpCod(Bas, pushDW_+DwToStr(AdrOK));
 AddOpCod(Bas, pushDW_+DwToStr(AdrButton));
 AddOpCod(Bas, pushDW_+DwToStr($20000));
 AddOpCod(Bas, call_dword_ptr_+DwToStr(AdrCreateWExA));
 //-------------------------------------------------------------
 AddOpCod(Bas, pushBy_+'00');
 AddOpCod(Bas, push_IXI+DwToStr(hInst));
 AddOpCod(Bas, pushDW_+DwToStr($C8));
 AddOpCod(Bas, push_IXI+DwToStr(hWnd));
 AddOpCod(Bas, pushBy_+'14');
 AddOpCod(Bas, pushDW_+DwToStr($C3));
 AddOpCod(Bas, pushBy_+'0A');
 AddOpCod(Bas, pushBy_+'0B');
 AddOpCod(Bas, pushDW_+DwToStr($50000000));
 AddOpCod(Bas, pushBy_+'00');
 AddOpCod(Bas, pushDW_+DwToStr(AdrEdit));
 AddOpCod(Bas, pushDW_+DwToStr($20000));
 AddOpCod(Bas, call_dword_ptr_+DwToStr(AdrCreateWExA));
 AddOpCod(Bas, mov_IXI_eax+DwToStr(hEDi));
 //-------------------------------------------------------------
 AddOpCod(Bas, pushBy_+'00');
 AddOpCod(Bas, pushBy_+'00');
 AddOpCod(Bas, pushBy_+'00');
 AddOpCod(Bas, pushDW_+DwToStr(hwndd));
 AddOpCod(Bas, call_dword_ptr_+DwToStr(AdrGetMesageA));
 //-------------------------------------------------------------
 AddOpCod(Bas, or_eax_eax);
 AddOpCod(Bas, jz_+'18');
 AddOpCod(Bas, pushDW_+DwToStr(hwndd));
 AddOpCod(Bas, call_dword_ptr_+DwToStr(AdrTranslMess));
 //-------------------------------------------------------------
 AddOpCod(Bas, pushDW_+DwToStr(hwndd));
 AddOpCod(Bas, call_dword_ptr_+DwToStr(AdrDispMesagA));
 AddOpCod(Bas, jmp_+'D3');
 //-------------------------------------------------------------
 AddOpCod(Bas, pushBy_+'00');
 AddOpCod(Bas, call_dword_ptr_+DwToStr(AdrExitProces));
 //-------------------------------------------------------------
 AddOpCod(Bas, mov_eax_esp);
 AddOpCod(Bas, cmp_dw_Ieax0ChI_+DwToStr($64));
 AddOpCod(Bas, jz_+'15');
 AddOpCod(Bas, cmp_dw_Ieax08hI_+DwToStr($02));
 AddOpCod(Bas, jnz_+'4A000000');
 //-------------------------------------------------------------
 AddOpCod(Bas, pushBy_+'00');
 AddOpCod(Bas, call_dword_ptr_+DwToStr(AdrPostQitMes));
 //-------------------------------------------------------------
 AddOpCod(Bas, pushDW_+DwToStr(EditBuff));
 AddOpCod(Bas, pushBy_+'40');
 AddOpCod(Bas, pushBy_+'0D');
 AddOpCod(Bas, push_IXI+DwToStr(hEDi));
 AddOpCod(Bas, call_dword_ptr_+DwToStr(AdrSendMesagA));
 //-------------------------------------------------------------
 AddOpCod(Bas, cld);
 AddOpCod(Bas, mov_ecx_+DwToStr($20));
 AddOpCod(Bas, mov_esi_+DwToStr(EditBuff));
 AddOpCod(Bas, mov_edi_+DwToStr(BuffPasword));
 AddOpCod(Bas, repe_cmpsb);
 AddOpCod(Bas, jnz_+'15000000');
 //-------------------------------------------------------------
 AddOpCod(Bas, pushBy_+'00');
 AddOpCod(Bas, push_IXI+DwToStr(hWnd));
 AddOpCod(Bas, call_dword_ptr_+DwToStr(AdrShowWindow));
 //-------------------------------------------------------------
 AddOpCod(Bas, mov_eax_+DwToStr(Old_Ram_EP));
 AddOpCod(Bas, jmp_eax);
 //-------------------------------------------------------------
 AddOpCod(Bas, jmpe_+DwToStr(AdrDefWinProA));
 //-------------------------------------------------------------
 //��������� ������ ���� � ������.
 Compile;
end;
 //-------------------------------------------------------------
 // ������� ���������� ������ �� 1 ��. (��. ������ PE)
Function RazshirSection(S: String; var Fofs,BaZ: DWORD): Boolean;
Const
 B: Byte = $00;
Var
 F: TFileStream;
 Sect: TSect;
 OfsPE, Vmax, Fmax, ImSize, Base, Vofs: DWORD;
 NumSect: WORD;
 i,n1,n2: Integer;
Begin
 Result:= False;
 F:= TFileStream.Create(S,fmOpenReadWrite);
 F.Position:= $3C;
 F.Read(OfsPE, 4);
 F.Position:= OfsPE + $06;
 F.Read(NumSect, 2);
 F.Position:= OfsPE + $34;
 F.Read(Base, 4);
 F.Position:= OfsPE + $50;
 F.Read(ImSize,4);
 Vmax:= 0; n1:= 0;
 Fmax:= 0; n2:= 0;
 F.Position:= OfsPE + $F8;
 For i:=0 To NumSect - 1 Do
  begin
  F.Read(Sect, $28);
  if Sect.VOfs >= Vmax Then
   begin
   Vmax:= Sect.VOfs + Sect.VSiz;
   n1:= i;
   end;
  if Sect.FOfs >= Fmax Then
   begin
   Fmax:= Sect.FOfs + Sect.FSiz;
   n2:= i;
   end;
  end;
 if Fmax <> F.Size Then begin F.Free; Exit; end;
 if n1 <> n2 Then begin F.Free; Exit; end;
 F.Position:= OfsPE + $F8 + n1 * $28;
 F.Read(Sect, $28);
 Fofs:= Sect.FOfs + Sect.FSiz;
 Vofs:= Sect.VOfs + Sect.FSiz;
 F.Position:= OfsPE + $F8 + n1 * $28;
 Sect.VSiz:= Sect.VSiz + $400;
 Sect.FSiz:= Sect.FSiz + $400;
 Sect.Flag:= $C0000020;
 F.Write(Sect, $28);
 ImSize:= Sect.VOfs + Sect.VSiz;
 F.Position:= OfsPE + $50;
 F.Write(ImSize,4);
 F.Position:= F.Size;
 For i:=1 To $400 Do F.Write(B,1);
 BaZ:= Vofs + Base;
 Result:= True;
 F.Free;
end;
 //-------------------------------------------------------------
 // ������� ���������� ������ �������� 1 ��. (��. ������ PE)
Function AddSection(S: String; var Fofs,BaZ: DWORD): Boolean;
Const
 B: Byte = $00;
Var
 F: TFileStream;
 Sect: TSect;
 OfsPE, EP, VAlign, FAlign, Fmin, Vmin, Vmax, ImSize,
 Base, Vofs: DWORD;
 NumSect: WORD;
 i,P: Integer;
begin
 Result:= False;
 F:= TFileStream.Create(S,fmOpenReadWrite);
 F.Position:= $3C;
 F.Read(OfsPE, 4);
 F.Position:= OfsPE + $06;
 F.Read(NumSect, 2);
 F.Position:= OfsPE + $28;
 F.Read(EP, 4);
 F.Position:= OfsPE + $34;
 F.Read(Base, 4);
 F.Position:= OfsPE + $38;
 F.Read(VAlign, 4);
 F.Read(FAlign, 4);
 F.Position:= OfsPE + $50;
 F.Read(ImSize,4);
 Fmin:= $40000000; // 1Gb.
 Vmax:= 0; Vmin:= 0;
 F.Position:= OfsPE + $F8;
 For i:=0 To NumSect - 1 Do
  begin
  F.Read(Sect, $28);
  if (Sect.FOfs <> 0)and(Sect.FOfs <= Fmin) Then
   begin
   Fmin:= Sect.FOfs;
   Vmin:= Sect.VOfs;
   end;
  if Sect.VOfs >= Vmax Then Vmax:= Sect.VOfs + Sect.VSiz;
  end;
 P:= OfsPE + $F8 + NumSect * $28;
 if (Fmin - P) < $28 Then begin F.Free; Exit; end;
 if EP < Vmin Then begin F.Free; Exit; end;
 if ((Vmax) Mod VAlign) = 0 Then Vofs:= Vmax
    Else Vofs:= ((Vmax Div VAlign) + 1) * VAlign;
 if (F.Size Mod FAlign) = 0 Then Fofs:= F.Size
    Else Fofs:=((F.Size Div FAlign) + 1) * FAlign;
 Sect.VOfs:= Vofs;
 Sect.VSiz:= $400;
 Sect.FOfs:= Fofs;
 Sect.FSiz:= $400;
 Sect.Flag:= $C0000020;
 F.Position:= P;
 F.Write(Sect, $28);
 NumSect:= NumSect + 1;
 F.Position:= OfsPE + $06;
 F.Write(NumSect, 2);
 ImSize:= ImSize + $400;
 F.Position:= OfsPE + $50;
 F.Write(ImSize,4);
 F.Position:= Fofs;
 For i:=1 To $400 Do F.Write(B,1);
 BaZ:= Vofs + Base;
 Result:= True;
 F.Free;
end;
 //-------------------------------------------------------------
 // ����.
procedure TForm1.OpenPEEXEClick(Sender: TObject);
begin
if OpenDialog1.Execute Then
 OpenFileName:= OpenDialog1.FileName
 Else OpenFileName:= '';
if OpenFileName <> '' Then
 begin
  Edit1.Enabled:= True;
  SetPass.Enabled:= True;
  Label1.Caption:='���: '+ExtractFileName(OpenFileName);
  end
 Else
 begin
  Edit1.Enabled:= False;
  SetPass.Enabled:= False;
 end;
end;
 //-------------------------------------------------------------
 // ��������� ������.
procedure TForm1.SetPassClick(Sender: TObject);
Var
 F: TFileStream;
 Fofs,BaZ,RamEP,NewEP,OfsPE,Bas,OldEP: DWORD;
 i: Integer;
begin
 if Not AddSection(OpenFileName, Fofs,BaZ) Then
 if Not RazshirSection(OpenFileName, Fofs,BaZ) Then
 begin
 MessageBox(Application.Handle,'� ����� ����� ������ ����������.','Win32',MB_OK);
 Exit;
 end;
 F:= TFileStream.Create(OpenFileName,fmOpenReadWrite);
 F.Position:= $3C;
 F.Read(OfsPE, 4);
 F.Position:= OfsPE + $28;
 F.Read(OldEP, 4);
 F.Position:= OfsPE + $34;
 F.Read(Bas, 4);
 RamEP:= ProgramList(BaZ,OldEP+Bas);
 NewEP:= RamEP - Bas;
 F.Position:= OfsPE + $28;
 F.Write(NewEP, 4);
 F.Position:= Fofs;
 For i:= 0 To Length(CodeAdd) - 1 Do F.Write(CodeAdd[i],1);
 F.Free;
 BuffCode:= '';
 SetLength(CodeAdd,0);
 MessageBox(Application.Handle,'������ ����������.','Win32',MB_OK);
 Edit1.Text:='';
 OpenFileName:='';
 Edit1.Enabled:= False;
 SetPass.Enabled:= False;
end;

end.
