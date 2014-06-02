object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Gopher Web Server'
  ClientHeight = 388
  ClientWidth = 689
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 528
    Top = 11
    Width = 24
    Height = 13
    Caption = 'Port:'
  end
  object Label2: TLabel
    Left = 459
    Top = 36
    Width = 48
    Height = 13
    Caption = 'wwwroot:'
  end
  object Memo1: TMemo
    Left = 8
    Top = 8
    Width = 433
    Height = 369
    Lines.Strings = (
      'MESSAGES CONSOL:'
      '-----------------------------------------')
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Button1: TButton
    Left = 606
    Top = 60
    Width = 75
    Height = 25
    Caption = 'Start Server'
    TabOrder = 1
    OnClick = Button1Click
  end
  object SpinEdit1: TSpinEdit
    Left = 558
    Top = 8
    Width = 121
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 2
    Value = 8080
  end
  object Edit1: TEdit
    Left = 513
    Top = 33
    Width = 166
    Height = 21
    TabOrder = 3
    Text = 'Edit1'
  end
  object Button2: TButton
    Left = 525
    Top = 60
    Width = 75
    Height = 25
    Caption = 'wwwroot'
    TabOrder = 4
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 525
    Top = 91
    Width = 75
    Height = 25
    Caption = 'Test JS'
    TabOrder = 5
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 525
    Top = 122
    Width = 75
    Height = 25
    Caption = 'Call JS'
    TabOrder = 6
    OnClick = Button4Click
  end
  object IdHTTPServer1: TIdHTTPServer
    Bindings = <>
    ServerSoftware = 'GopherSever'
    SessionState = True
    SessionTimeOut = 600000
    OnSessionStart = IdHTTPServer1SessionStart
    OnSessionEnd = IdHTTPServer1SessionEnd
    OnCommandGet = IdHTTPServer1CommandGet
    Left = 208
    Top = 56
  end
  object JvBrowseForFolderDialog1: TJvBrowseForFolderDialog
    Left = 304
    Top = 56
  end
end
