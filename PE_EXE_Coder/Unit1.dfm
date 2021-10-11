object Form1: TForm1
  Left = 229
  Top = 125
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'PE EXE Coder'
  ClientHeight = 98
  ClientWidth = 250
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 120
  TextHeight = 16
  object Label1: TLabel
    Left = 8
    Top = 40
    Width = 32
    Height = 16
    Caption = #1048#1084#1103':'
  end
  object Label2: TLabel
    Left = 8
    Top = 16
    Width = 63
    Height = 16
    Caption = 'Password:'
  end
  object SetPass: TButton
    Left = 128
    Top = 64
    Width = 113
    Height = 26
    Caption = 'Set password'
    Enabled = False
    TabOrder = 0
    OnClick = SetPassClick
  end
  object Edit1: TEdit
    Left = 80
    Top = 8
    Width = 162
    Height = 25
    Enabled = False
    TabOrder = 1
  end
  object OpenPEEXE: TButton
    Left = 8
    Top = 64
    Width = 113
    Height = 25
    Caption = 'Open'
    TabOrder = 2
    OnClick = OpenPEEXEClick
  end
  object OpenDialog1: TOpenDialog
    Filter = 'PortableExecutables (PE EXE)|*.exe'
    OptionsEx = [ofExNoPlacesBar]
    Left = 136
    Top = 16
  end
  object XPManifest1: TXPManifest
    Left = 104
    Top = 16
  end
end
