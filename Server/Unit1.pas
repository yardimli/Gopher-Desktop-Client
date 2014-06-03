unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdBaseComponent, IdComponent, IdContext,
  IdCustomTCPServer, IdCustomHTTPServer, IdHTTPServer, Vcl.StdCtrls,
  Vcl.Samples.Spin, JvBaseDlg, JvBrowseFolder, js15decl,jsintf;

type

  [JSClassName('App')]
  TJSAppObject = class(TJSClass)
  public
    procedure testCall;
  end;

  TForm1 = class(TForm)
    IdHTTPServer1: TIdHTTPServer;
    Memo1: TMemo;
    Button1: TButton;
    SpinEdit1: TSpinEdit;
    Label1: TLabel;
    JvBrowseForFolderDialog1: TJvBrowseForFolderDialog;
    Label2: TLabel;
    Edit1: TEdit;
    Button2: TButton;
    Button3: TButton;
    Button5: TButton;
    procedure IdHTTPServer1SessionEnd(Sender: TIdHTTPSession);
    procedure IdHTTPServer1SessionStart(Sender: TIdHTTPSession);
    procedure IdHTTPServer1CommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
     FHTMLDir: string;

    FJSEngine: TJSEngine;
    FJSAppObject: TJSAppObject;

 public
    { Public declarations }
  end;


  TJSGlobalFunctions = class
    class procedure ShowMessage(s: string);
  end;

var
  Form1: TForm1;

implementation

uses ioutils,typinfo,RTTI,superobject;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
 if IdHTTPServer1.Active then
 begin
  IdHTTPServer1.Active := False;
  Button1.Caption := 'Start Server';
 end else
 begin
  Button1.Caption := 'Stop Server';
  IdHTTPServer1.DefaultPort := SpinEdit1.Value;
  IdHTTPServer1.AutoStartSession := true;
  IdHTTPServer1.Active := True;
 end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
 if JvBrowseForFolderDialog1.Execute then
 begin
  FHTMLDir := JvBrowseForFolderDialog1.Directory;
  Edit1.Text := FHTMLDir;
 end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  FJSEngine := TJSEngine.Create;
  FJSEngine.registerGlobalFunctions(TJSGlobalFunctions);
  FJSAppObject:= TJSAppObject.CreateJSObject(FJSEngine, 'App') ;
  TJSClass.CreateJSObject(Self, FJSEngine, 'Form1', [cfaInheritedMethods, cfaInheritedProperties]);
  FJSEngine.EvaluateFile(FHTMLDir + '\parser.js');
//  FJSEngine.CallFunction('main');
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
 FJSEngine.CallFunction('main');
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 IdHTTPServer1.Active := false;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FHTMLDir := 'c:\Gopher\wwwroot';
  Edit1.Text := FHTMLDir;
end;

procedure TForm1.IdHTTPServer1CommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  LFilename: string;
  LPathname: string;
  xType : string;
  xFileStream : TFileStream;
  Bytes: TBytes;
  s,s2 : String;

  obj,pos: ISuperObject;
  returnval : jsval;
begin
 Memo1.Lines.Add(' File: ' + ARequestInfo.Document);
 Memo1.Lines.Add( 'Command: ' + ARequestInfo.Command +
  ', Host: ' + ARequestInfo.Host +
  ', URI: ' + ARequestInfo.URI +
  ', UserAgent: ' + ARequestInfo.UserAgent);
 Memo1.Lines.Add('-------------------------');
//
  LFilename := ARequestInfo.Document;
  if LFilename='/' then LFilename := 'index.html';


  LPathname := FHTMLDir + '\' + LFilename;
 if FileExists(LPathname) then
 begin
  if pos('.htm',LowerCase(LPathname))<>0 then xType :='text/html';
  if pos('.css',LowerCase(LPathname))<>0 then xType :='text/css';
  if pos('.js',LowerCase(LPathname))<>0 then xType :='application/javascript';
  if pos('.png',LowerCase(LPathname))<>0 then xType :='image/png';
  if pos('.gif',LowerCase(LPathname))<>0 then xType :='image/gif';
  if pos('.jpg',LowerCase(LPathname))<>0 then xType :='image/jpeg';
  if pos('.svg',LowerCase(LPathname))<>0 then xType :='image/svg+xml';


  if (xType='text/html') or (xType='text/css') or (xType='application/javascript') then
  begin
   Bytes := TFile.ReadAllBytes(LPathname);
   S := TEncoding.UTF8.GetString(Bytes);
   s2 := s;
   if (xType='application/javascript') then
   begin
     s2 := StringReplace(s2,chr(13)+chr(10),'\n\'+chr(13)+chr(10),[rfReplaceAll]);
//     s := StringReplace(s,chr(10),' ',[rfReplaceAll]);
     Memo1.Lines.Add('call parser with: '+s2);

     FJSEngine.Evaluate('ParseMe("'+s2+'");',returnval);
     Memo1.Lines.Add( JSValToString(FJSEngine.Context,returnval ) );

     obj := SO( JSValToString(FJSEngine.Context,returnval ) );
     for pos in obj['items'] do begin

           // get the values like this
           ShowMessage(pos['name'].AsString)
       end;

//     FJSEngine.CallFunction('ParseMe()', FJSEngine. );
   end;

   AResponseInfo.ContentText := s;
   AResponseInfo.ContentEncoding := 'utf-8';
  //AResponseInfo.ContentLength := AResponseInfo.ContentStream.Size;
   AResponseInfo.ContentType := xType;
   AResponseInfo.ResponseNo := 200;
   AResponseInfo.CharSet := 'UTF-8';
   AResponseInfo.ContentVersion :='HTTP/1.1';
   AResponseInfo.ResponseText := '200 OK';

   AResponseInfo.WriteHeader;
   AResponseInfo.WriteContent;
   AResponseInfo.ContentStream.Free;
   AResponseInfo.ContentStream := nil;
  end else
  begin
   AResponseInfo.ContentStream := TFileStream.Create(LPathname, fmOpenRead + fmShareDenyWrite);
   AResponseInfo.ContentLength := AResponseInfo.ContentStream.Size;
   AResponseInfo.ContentType := xType;
   AResponseInfo.ResponseNo := 200;
   AResponseInfo.ContentVersion :='HTTP/1.1';
   AResponseInfo.ResponseText := 'OK';
   AResponseInfo.WriteHeader;
   AResponseInfo.WriteContent;
   AResponseInfo.ContentStream.Free;
   AResponseInfo.ContentStream := nil;
  end;
 end else
 begin
  AResponseInfo.ResponseNo := 404;
  AResponseInfo.ContentText := 'The requested URL ' + ARequestInfo.Document
  + ' was not found on this server.';
 end;

end;

procedure TForm1.IdHTTPServer1SessionEnd(Sender: TIdHTTPSession);
begin
//
end;

procedure TForm1.IdHTTPServer1SessionStart(Sender: TIdHTTPSession);
begin
//
end;

{ TJSGlobalFunctions }

class procedure TJSGlobalFunctions.ShowMessage(s: string);
begin
  Form1.Memo1.Lines.Add('MSG FROM JS:' + s);
end;

{ TJSAppObject }

procedure TJSAppObject.testCall;
begin
  Form1.Memo1.Lines.Add('I WAS Called to RUN FROM THE JavaScript File');
end;


end.
