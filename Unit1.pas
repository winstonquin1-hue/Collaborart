unit Unit1;

interface

uses
  System.SysUtils,System.IOUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.StrUtils,
  System.Threading, system.AnsiStrings, FMX.ImgList, FMX.Objects, FMX.DialogService,
   inifiles, System.WideStrUtils,
  JsonDataObjects, System.JSON.Utils, FMX.Platform,  System.Permissions,
   System.JSON.Readers, System.JSON.Types, // android only --> System.Net.HttpClient,network,
  WebSocketServer,  // --> Fserver variable
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, FMX.Edit, System.Rtti, FMX.Grid.Style, FMX.Grid,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, System.ImageList, web.HTTPApp,  MobilePermissions.Component,
   {$IFDEF ANDROID}
    Androidapi.JNI.Java.Net,
   Androidapi.JNI.JavaTypes, Androidapi.Helpers,
   Androidapi.JNIBridge,
  {$ENDIF}
   {$IFDEF WINDOWS}
    Winapi,  Posix.Unistd, Posix.Stdio,
  {$ENDIF}
   IDContext, IdHTTP,  IdStack, IdMultipartFormData,   IdComponent, IdCoderMIME,
  IdCustomHTTPServer,IdHTTPServer, IdHeaderList,IDThread,IdThreadComponent,
   IdTCPConnection, IdTCPClient,  IdGlobal,
  IdMessageCoder, IdCustomTCPServer,IdExceptionCore,  IdBaseComponent,
  IdMessageCoderMIME, IdMessage, IdGlobalProtocols, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL,
  IdCoder, IdCoder3to4;


type
  TForm1 = class(TForm)
    pnlTop: TPanel;
    CheckButton: TButton;
    Memo1: TMemo;
    ClearMemoButton: TButton;
    CheckBox1: TCheckBox;
    Memo2: TMemo;
    editFilename: TEdit;
    CloseButton: TButton;
    StyleBook1: TStyleBook;
    SaveButton: TButton;
    Label2: TLabel;
    Label3: TLabel;
    btnLoadFile: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Edit10: TEdit;
    btnListFiles: TButton;
    ListView1: TListView;
    btnDelete: TButton;
    ImageList1: TImageList;
    Image1: TImage;
    edtPort: TEdit;
    lblPort: TLabel;
    btnSaveIniFile: TButton;
    btnClear: TButton;
    Splitter2: TSplitter;
    btnImport: TButton;
    Label1: TLabel;
    btnSayIt: TButton;
    Label4: TLabel;
    btnExport: TButton;
    Label5: TLabel;
    edtRelay: TEdit;
    lblServerContexts: TLabel;
    edtPublish: TEdit;
    Label6: TLabel;
    IdHTTP1: TIdHTTP;
    MIME1: TIdEncoderMIME;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ClearMemoButtonClick(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
    procedure Memo1ChangeTracking(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure CheckButtonClick(Sender: TObject);
    procedure btnLoadFileClick(Sender: TObject);
    procedure btnListFilesClick(Sender: TObject);
    procedure ListView1ItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnSaveIniFileClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure btnSayItClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure IdHTTP1Status(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: string);
    procedure IdHTTP1Work(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure IdHTTP1Connected(Sender: TObject);
    procedure IdHTTP1Disconnected(Sender: TObject);

  private
    { Private declarations }
    didSend:Boolean;
    FServer: TWebSocketServer;

    FSendCirclesThread: ITask;
    FSendCirclesThreadWorking: boolean;
    ConnectionCount:integer;
    JsonMsg: TJsonObject;
    Sr: TStringReader;
    Reader: TJsonTextReader;
    theTalbeData:string;
    itemCount:integer;
    saidOnce:integer; // to stop the files permissions popping up twice set to 1 when done once
    relayList,PublishList:tStringlist;
    amBusy:integer;   // set by publist to say http is busy
     {$IFDEF ANDROID}
    addreList:TIdStackLocalAddressList;
    {$ENDIF}
   // sendCount:integer;
  //  random1Id,random2Id:string;
//      SvcEvents: IFMXApplicationEventService;
//      AppEventSvc: IFMXApplicationEventService;
    //function AppEvent(AAppEvent: TApplicationEvent; AContext: TObject) : Boolean;
    procedure CreateReader(Str: string);
    procedure ParseObject;
    procedure SendBroadcast(Sender: TObject; AContext: TIdContext; theMessage:string);
    procedure SendRandom(Sender: TObject; AContext: TIdContext; theMessage:string);
//    procedure addCustomButtonToFile;
    procedure Connect(AContext: TIdContext);
    procedure Disconnect(AContext: TIdContext);
    procedure Execute(AContext: TIdContext);
    procedure SendCircles;
    procedure SendRelay;
    procedure PublishFile(theFile: string);

    {$IFDEF ANDROID}
      procedure DisplayRationale(Sender: TObject; const APermissions: TArray<string>; const APostRationaleProc: TProc);
    procedure RequestPermissionsResult(Sender: TObject; const APermissions: TArray<string>; const AGrantResults: TArray<TPermissionStatus>);

   procedure GetLocalAddressList(const AAddresses: TIdStackLocalAddressList);

   {$ENDIF}

  public
    { Public declarations }
     //   constructor Create;
   // destructor Destroy; override;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}
  uses
  FMX.Surfaces;

  {$IFDEF ANDROID}
procedure TForm1.GetLocalAddressList(const AAddresses: TIdStackLocalAddressList);
var
  LInterfaces, LAddresses: JEnumeration;
  LInterface: JNetworkInterface;
  LAddress: JInetAddress;
  LName, LHostAddress: string;
begin
  AAddresses.Clear;
  LInterfaces := TJNetworkInterface.JavaClass.getNetworkInterfaces;
  while LInterfaces.hasMoreElements do
  begin
    LInterface := TJNetworkInterface.Wrap(LInterfaces.nextElement);
    LAddresses := LInterface.getInetAddresses;
    while LAddresses.hasMoreElements do
    begin
      LAddress := TJInetAddress.Wrap(LAddresses.nextElement);
      if LAddress.isLoopbackAddress then
        Continue;
      // Hack until I can find out how to check properly
      LName := JStringToString(LAddress.getClass.getName);
      LHostAddress := JStringToString(LAddress.getHostAddress);
      // Trim excess stuff
      if LHostAddress.IndexOf('%') > -1 then
        LHostAddress := LHostAddress.Substring(0, LHostAddress.IndexOf('%'));
      if LName.Contains('Inet4Address') then
        TIdStackLocalAddressIPv4.Create(AAddresses, LHostAddress, '')
      else if LName.Contains('Inet6Address') then
        TIdStackLocalAddressIPv6.Create(AAddresses, LHostAddress);
    end;
  end;
       //   memo1.Lines.insert(0,'On IP Address: '+jstringtostring(LAddress.tostring));
    //   memo1.Lines.insert(0,'Network Name: '+LName);
     memo1.lines.insert(0,'IP Address: '+LHostAddress);
end;
{$ENDIF}

(*

  function TForm1.AppEvent(AAppEvent: TApplicationEvent; AContext: TObject) : Boolean;
  var
  //tempLog:Tstrings;
  //FOnStop:TnotifyEvent;
  memStream:TMemoryStream;
  begin
         {   if Assigned(FOnStop) then
       ///     FOnStop(FOnStop(self))
              myLog.Add('Got fOnStop');  }
           // then
          //  begin
      ////register for the notification to call AppEvent
        // myLog.Add('Got a notify event')
          //  end
         // /
         //   else begin
         //      myLog.Add('GotNO notify event')
        //  end;


          //if myT = TApplicationEvent.EnteredBackground then  begin

           //    myLog.insert(0,frmMain.Memo1.text);
           //    myLog.SaveToFile(System.IOUtils.TPath.GetDocumentsPath +
             //                             System.SysUtils.PathDelim +
             //                              'Log'+ formatdatetime('ddd-mmm-yyyy-hh-mm-ss',now)+'.txt');
             // myLog.Clear;
          // end;

      case AAppEvent of
        //  TApplicationEvent.FinishedLaunching: myLog.Add('Finisher Launching') ;
        //  TApplicationEvent.BecameActive:myLog.Add('Became Active') ;
        //  TApplicationEvent.WillBecomeInactive:    memo1.Lines.insert(0,'You system may close apps which are left inactive.');
        //  TApplicationEvent.EnteredBackground:     memo1.Lines.insert(0,'Entered Background.') ;
        //  TApplicationEvent.WillBecomeForeground:  memo1.Lines.insert(0,'Entered Foreground') ;

        //-- the user has let the app go to background for too long.
        //-- save a recover file - just in case
         TApplicationEvent.WillTerminate: begin

           memstream:=TMemoryStream.Create;
             try

              {$IFDEF MSWINDOWS}
               memstream.LoadFromFile(format('%s\TheData.txt', [GetHomePath]));
               memstream.SaveToFile(format('%s\backed-up-project.txt', [GetHomePath]));//trim(editFilename.Text)) ;
               {$ELSE}
               memstream.LoadFromFile(format('%s/TheData.txt', [GetHomePath]));
                   memstream.SaveToFile(format('%s/backed-up-project.txt', [GetHomePath]));//trim(editFilename.Text)) ;
              {$ENDIF}

                freeandnil(memstream);
               // memo1.Lines.insert(0,'File Saved: '+ editFilename.text);
                except
                 on e:exception do begin
               //    memo1.Lines.insert(0,'File Save Error: '+ e.Message);
                   freeandnil(memstream);
                  exit;
                 end;
             end;
         // playthis(self);
         end;

        // TApplicationEvent.LowMemory: myLog.Add('CollaborArt App has low memory');
       //   TApplicationEvent.TimeChange: begin
       //                                    icount:=icount+1;
       //                                    label4.Text:=icount.ToString;
       //                                  end;
        // TApplicationEvent.OpenURL: ;
       end;
    Result := True;
  end;


*)

 {$IFDEF ANDROID}
procedure TForm1.RequestPermissionsResult(Sender: TObject; const APermissions: TArray<string>; const AGrantResults: TArray<TPermissionStatus>);
begin
  if (Length(AGrantResults) = 1) then
  begin
    case AGrantResults[0] of
      TPermissionStatus.Granted:
        try
             // FMicrophone.StartCapture ;
            //   memo1.Lines.insert(0,'Microphone Permissions Granted');
        except
          memo1.Lines.insert(0,'Permissons : Operation not supported.');
        end;
      TPermissionStatus.Denied: memo1.Lines.insert(0,'Cannot change files without the relevant permission being granted.');
      TPermissionStatus.PermanentlyDenied: memo1.Lines.insert(0,'If you want to import or export files these permissions are required.');
    end;
  end
  else
    memo1.Lines.insert(0,'Something went wrong with the permissions.'+slinebreak+'Please do this through your device Settings.');
end;

procedure TForm1.DisplayRationale(Sender: TObject; const APermissions: TArray<string>; const APostRationaleProc: TProc);
begin
  // Show an explanation to the user *asynchronously* - don't block this thread waiting for the user's response!
  // After the user sees the explanation, invoke the post-rationale routine to request the permissions
   if saidonce = 0  then // dont show the message twice
  TDialogService.ShowMessage('Collaborart needs to be given permissions to read and write files to complete this procedure.',
    procedure(const AResult: TModalResult)
    begin
      APostRationaleProc;
    end)
end;
  {$ENDIF}

procedure TForm1.FormCreate(Sender: TObject);
 var
 aSize:tSizef;
 ini: TIniFile;
 i:integer;
 aName:string;
  {$IFDEF ANDROID}
 //  myTIdStackLocalAddress:TIdStackLocalAddress;
const
  PermissionReadFiles = 'android.permission.READ_EXTERNAL_STORAGE';
  PermissionWriteFiles = 'android.permission.WRITE_EXTERNAL_STORAGE';
    {$ENDIF}
begin
 {$IFDEF ANDROID}
  saidOnce:=0;
PermissionsService.RequestPermissions([PermissionReadFiles], RequestPermissionsResult, DisplayRationale);
 saidOnce:=1;
PermissionsService.RequestPermissions([PermissionWriteFiles], RequestPermissionsResult, DisplayRationale);

   addreList := TIdStackLocalAddressList.Create;

  // addreList :=GetLocalAddressList(addreList);

  //  memo1.Lines.insert(0,'IP Address: '+jstringtostring(addreList[0].tostring));
  //     memo1.Lines.insert(0,'On Host Address: '+jstringtostring(LHostAddress.tostring));
  //   memo1.Lines.insert(0,'On Host Address: '+jstringtostring(LHostAddress.tostring));

  // addreList.IPv4ToHex(LAddress);

  addreList.Free;

   {$ENDIF}

 // two things need to happen here at the very start
  // 1. The log file must be renamed and can then be renamed again by the user for data recovery
  // 2. The value of the port must come from an ini file.

            //*--*-*-*-*-*-**-* read in settings *-*-*-*-*-**-

         try
                ini := TIniFile.Create(format('%s/collaborart-config.ini', [GetHomePath]));
                   try
                     edtPort.text:= Ini.ReadString( 'edtPort', 'text', edtPort.text );
                     edtRelay.text:= Ini.ReadString( 'edtRelay', 'text', edtRelay.text );
                     edtPublish.text:= Ini.ReadString( 'edtPublish', 'text', edtPublish.text );
                     finally
                     ini.Free;
                     memo1.Lines.Insert(0,'Using Port: '+  edtPort.text);
                  end;
          except
          on e:exception do
           memo1.Lines.insert(0,'Please note: No Port settings were found in an .ini file! '+
                                   slinebreak+'Port 8080 will be used. Click ''Set Port'' to Save Settings.');
        end;



  if fileexists(format('%s/TheData.txt', [GetHomePath])) then
     renamefile(format('%s/TheData.txt', [GetHomePath]),format('%s/last-project.txt', [GetHomePath]));

  // if TPlatformServices.Current.SupportsPlatformService(IFMXApplicationEventService, IInterface(AppEventSvc)) then
  //     AppEventSvc.SetApplicationEventHandler(AppEvent);

  itemCount:=0;
 //   icount:=0;

  // here the only realy way to set the port is via an ini file or simialar
       CheckBox1.IsChecked:=false;

  FServer := TWebSocketServer.Create;

   //-- if no setting found then use default of 8080
   try
       i:= edtPort.Text.ToInteger;
    except
    i:=8080;
    memo1.Lines.insert(0,'The config.ini file was not found,'+slinebreak+'Will try use port 8080.');
   end;

  FServer.DefaultPort := i;//;
  FServer.OnExecute := Execute;
  FServer.OnConnect := Connect;
  FServer.OnDisconnect := Disconnect;
  FServer.Active := true;
    memo1.Lines.insert(0,'Server is Active.');

  FSendCirclesThreadWorking := true;
  FSendCirclesThread := TTask.Run(SendCircles);
{
     memo1.Lines.insert(0,'Import/Export File path: '+ System.IOUtils.TPath.GetSharedDocumentsPath);
     memo1.Lines.insert(0,'App File path: '+ GetHomePath  );
     memo1.Lines.insert(0,'Server is Active.');
}

  ConnectionCount:=0;

  // haveCustomButton:=false;
   aSize.Width:=250;
   aSize.Height:=55;
   image1.Bitmap:=imagelist1.Bitmap(aSize,0);

   relayList:=tStringlist.Create;
   PublishList:=tStringlist.Create;
   amBusy:=0;
 // {$IFDEF MACOS}
//{$R *.mac.res}
//{$ENDIF}
//{$IFDEF MSWINDOWS}
  //     memo1.Lines.insert(0,format('%s\'+editFilename.text+'', [GetHomePath]));
//{$ELSE}
//    memo1.Lines.insert(0,format('%s/'+editFilename.text+'', [GetHomePath]));
//  {$ENDIF}

 btnListFilesClick(Self);
inherited;
end;

procedure TForm1.FormDestroy(Sender: TObject);
//var
//circles:tcircle;
//j:integer;
begin {
         try
           circles.DestroyAllCircles();
         except
         on e:exception do
            //      memo1.Lines.insert(0,'Error while Destroy All objects: '+e.Message);
         end;
         }
      freeandnil(relayList);
      freeandnil(PublishList);

         try
            FSendCirclesThreadWorking := false;
              except
             on e:exception do
           //       memo1.Lines.insert(0,'Error while closing threads: '+e.Message);
         end;


        try
          FSendCirclesThread.Cancel; //* wq put this here
                      except
         on e:exception do
          //        memo1.Lines.insert(0,'Error while Cancelling the thread: '+e.Message);
         end;


         try
            FSendCirclesThread.Wait(2000);
                 except
             on e:exception do
           //       memo1.Lines.insert(0,'Error while waiting for close: '+e.Message);
         end;

         try
           FServer.Active := false;
                   except
          on e:exception do
         //         memo1.Lines.insert(0,'Error setting server to inactive: '+e.Message);
         end;

        try
          freeandNil(Fserver);    //* wq put this here
                 except
         on e:exception do
         //         memo1.Lines.insert(0,'Error while emptying the object: '+e.Message);
        end;

         try
         FServer.DisposeOf;  //*uncommented by wq - mayb a bad idea but freeandnil should do that
                     except
            on e:exception do
         //         memo1.Lines.insert(0,'Error while emptying the object: '+e.Message);
         end;

  inherited;
end;



procedure TForm1.IdHTTP1Connected(Sender: TObject);
begin
    memo1.Lines.Insert(0,'Remote Connected.');
end;

procedure TForm1.IdHTTP1Disconnected(Sender: TObject);
begin
 amBusy := 0;
  memo1.Lines.Insert(0,'Remote Disonnected.');
end;

procedure TForm1.IdHTTP1Status(ASender: TObject; const AStatus: TIdStatus;
  const AStatusText: string);
begin
  memo1.Lines.Insert(0,AstatusText);
end;

procedure TForm1.IdHTTP1Work(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
     memo1.Lines.Insert(0,'Work Count: '+AWorkCount.ToString);
end;

procedure TForm1.ListView1ItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
    editFileName.Text:=extractfilename(AItem.Text);
end;

procedure TForm1.Memo1ChangeTracking(Sender: TObject);
var
i:integer;
begin
       // If the user visits the log it may be empty and maybe some
       //  important piece of info is not visible anymore.
       if memo1.Lines.Count > 300 then
         for i:= 300 downto 100 do
              memo1.Lines.Delete(i);
             //   memo1.Text:='';
             //   memo1.Lines.Clear;
end;

procedure TForm1.SendBroadcast(Sender: TObject; AContext: TIdContext; theMessage:string);
var
   Clients: TList;
    i:integer;
begin
       if Assigned(FServer.Contexts) then begin
            Clients := FServer.Contexts.LockList;
          try
          for i := 0 to Clients.Count - 1 do
              try
               if didsend = true   then begin   // the next iterationin the loop shold kill it
                                                // that would be the clients next roll of the random
                FServer.Contexts.UnlockList;
                  didsend:=false; // reset it
                 exit;
               end;
                if TIdContext(Clients[i]).Connection.Connected then
                  if TIdContext(Clients[i]).Connection.Connected then
                     TWebSocketIOHandlerHelper(TIdContext(Clients[i]).Connection.IOHandler).WriteString(theMessage);
             // memo1.Lines.insert(0,'Posted Update random: ' + JsonMsg.S['boxnumber']);
              sleep(100);
               except
                 on e:exception do begin
                    memo1.Lines.insert(0,'Can''t Write String re.  '+ e.message);
                      FServer.Contexts.UnlockList;
                    exit;
                 end;
            end;
           finally
           FServer.Contexts.UnlockList;
          end ;
        end; // end if
end;

procedure TForm1.SendRandom(Sender: TObject; AContext: TIdContext; theMessage:string);
var
   Clients: TList;
    i:integer;
begin
       if Assigned(FServer.Contexts) then begin
            Clients := FServer.Contexts.LockList;
          try
          for i := 0 to Clients.Count - 1 do
              try
               if didsend = true   then begin   // the next iterationin the loop shold kill it
                                                // that would be the clients next roll of the random
                FServer.Contexts.UnlockList;
                didsend:=false; // reset it
                 exit;
               end;
                if TIdContext(Clients[i]).Connection.Connected then
                  if TIdContext(Clients[i]).Connection.Connected then
                     TWebSocketIOHandlerHelper(TIdContext(Clients[i]).Connection.IOHandler).WriteString(theMessage);
             // memo1.Lines.insert(0,'Posted Update random: ' + JsonMsg.S['boxnumber']);
              sleep(100);
               except
                 on e:exception do begin
                    memo1.Lines.insert(0,'Can''t Write String re.  '+ e.message);
                      FServer.Contexts.UnlockList;
                    exit;
                 end;
            end;
           finally
           FServer.Contexts.UnlockList;
          end ;
        end; // end if
end;


procedure TForm1.btnDeleteClick(Sender: TObject);
begin
           {$IFDEF MSWINDOWS}
           if FileExists(format('%s\'+editFilename.text+'', [GetHomePath])) then
              begin
                 try
                  deletefile(format('%s\'+editFilename.text+'', [GetHomePath]));
                  memo1.Lines.insert(0,'Deleted :'+editFilename.text);
                    except
                    on e:exception do
                      memo1.Lines.insert(0,'Problem Deleting :'+editFilename.text);
                 end;
               end;
             {$ELSE}
           if FileExists(format('%s/'+editFilename.text+'', [GetHomePath])) then
              begin
                         try
                          deletefile(format('%s/'+editFilename.text+'', [GetHomePath]));
                         memo1.Lines.insert(0,'Deleted :'+editFilename.text);
                          except
                     on e:exception do
                      memo1.Lines.insert(0,'Problem Deleting :'+editFilename.text);
                 end;
               end;
            {$ENDIF}

 btnListFilesClick(Self);

  //  memo1.GoToTextEnd;
end;

procedure TForm1.btnImportClick(Sender: TObject);
begin
      if uppercase(trim( editFilename.text)) = 'CONFIG.INI' then  // never overwrite it
      exit;

                //-- preserve the old file if it exists
          try  // the full path shoud be shown in case of an error
                  {$IFDEF MSWINDOWS}
                 // note that with Windows the PUBLIC is the home path for shared documents

                  //-- does the file exist as a local copy already? if so rename it...
                  if FileExists(format('%s\'+editFilename.text+'', [GetHomePath])) then begin
                   System.IOUtils.TFile.Copy(System.IOUtils.TPath.GetSharedDocumentsPath +pathdelim+ editFilename.text,
                      format('%s\'+extractfilename(editFilename.text)+'-import.txt', [GetHomePath]),true);
                      renamefile(format('%s\'+editFilename.text+'', [GetHomePath]),format('%s\'+editFilename.text+'-old', [GetHomePath]));
                     memo1.Lines.insert(0,'Your existing file has been renamed to ' + editFilename.text+'-old');
                  end
                   else
                    if not FileExists(format('%s\'+editFilename.text+'', [GetHomePath])) then  begin
                    System.IOUtils.TFile.Copy(System.IOUtils.TPath.GetSharedDocumentsPath +pathdelim+ editFilename.text,
                      format('%s\'+editFilename.text, [GetHomePath]),true);
                      memo1.Lines.insert(0,editFilename.text + ' did not exist in Collaborart'+slinebreak+'so no existing file was overwritten. Use ''Load File'' to load the project');
                   end;
                //  memo1.Lines.insert(1,'Looking for: ' +System.IOUtils.TPath.GetSharedDocumentsPath +pathdelim+ editFilename.text);

                 {$ELSE}

                   if FileExists(format('%s/'+editFilename.text+'', [GetHomePath])) then begin
                   System.IOUtils.TFile.Copy(format('%s/'+editFilename.text+'', [GetHomePath]),
                      format('%s/'+extractfilename(editFilename.text)+'-import.txt', [GetHomePath]),true);
                      renamefile(format('%s/'+editFilename.text+'', [GetHomePath]),format('%s/'+editFilename.text+'-old', [GetHomePath]));
                     memo1.Lines.insert(0,'Your existing file has been renamed to ' + editFilename.text+'-old');
                  end
                  else

                 if not FileExists(format('%s/'+editFilename.text+'', [GetHomePath])) then  begin
                    System.IOUtils.TFile.Copy(System.IOUtils.TPath.GetSharedDocumentsPath +pathdelim+ editFilename.text,
                      format('%s/'+editFilename.text, [GetHomePath]),true);
                      memo1.Lines.insert(0,editFilename.text + ' did not exist in Collaborart'+slinebreak+'so no existing file was overwritten. Use ''Load File'' to load the project');
                   end;

            //       if FileExists(format('%s/'+editFilename.text+'', [GetHomePath])) then begin
            //         renamefile(format('%s/'+editFilename.text+'', [GetHomePath]),format('%s/'+editFilename.text+'-old', [GetHomePath]));
            //         memo1.Lines.insert(0,'Your existing file has been renamed to ' + editFilename.text+'-old');
             //     end;
           //         System.IOUtils.TFile.Copy(System.IOUtils.TPath.GetSharedDocumentsPath +pathdelim+ editFilename.text,
           //           format('%s/'+editFilename.text+'-import', [GetHomePath]),true);
(*
                     if FileExists(format('%s/'+editFilename.text+'', [GetHomePath])) then begin
                        renamefile(format('%s/'+editFilename.text+'', [GetHomePath]),format('%s/'+editFilename.text+'-old.txt', [GetHomePath]));
                        memo1.Lines.insert(0,'Your existing file has been renamed to ' + editFilename.text+'-old.txt');
                       end;

                      //-- now get the file from user folder to collaborart folder
                   System.IOUtils.TFile.Copy(System.IOUtils.TPath.GetSharedDocumentsPath +pathdelim+ editFilename.text,
                    format('%s/'+editFilename.text+'', [GetHomePath]),true);
                         memo1.Lines.insert(0,'File Saved: '+ editFilename.text);
*)
                  {$ENDIF}
          //     memo1.Lines.insert(0,'Imported From: '+format('%s/'+editFilename.text+'', [GetHomePath]));
             btnListFilesClick(Self);
             except
                on e:exception do begin
                 {$IFDEF MSWINDOWS}
                     memo1.Lines.insert(0,'File Save Error: '+ e.Message+slinebreak+ System.IOUtils.TPath.GetSharedDocumentsPath +pathdelim+editFilename.text+
                                     slinebreak+'Note that on MS Windows the Public Documents folder is the home path for c:\Users\Public\Documents where CollaborArt is looking for your file.');
                    {$ELSE}
                        memo1.Lines.insert(0,'File Save Error: '+ e.Message+slinebreak+ System.IOUtils.TPath.GetSharedDocumentsPath +pathdelim+editFilename.text);
                     {$ENDIF}
                    exit;
                end;
         end;

     //  memoFileContents.Lines.Clear;
      // memoFileContents.Visible:=false;
       btnListFilesclick(self);
      //  memo1.GoToTextEnd;
end;

procedure TForm1.btnListFilesClick(Sender: TObject);
var
  LList: TStringDynArray;
  I: Integer;
  LSearchOption: TSearchOption;
begin
// list files and send result back to user
  { Select the search option }
  //if cbDoRecursive.Checked then
  //  LSearchOption := TSearchOption.soAllDirectories
 // else
    LSearchOption := TSearchOption.soTopDirectoryOnly;
  listview1.Items.Clear;
  try
    { For all entries use GetFileSystemEntries method }
    //if cbIncludeDirectories.Checked and cbIncludeFiles.Checked then
    //  LList := TDirectory.GetFileSystemEntries(edtPath.Text, LSearchOption, nil);

    { For directories use GetDirectories method }
   // if cbIncludeDirectories.Checked and not cbIncludeFiles.Checked then
    //  LList := TDirectory.GetDirectories(edtPath.Text, edtFileMask.Text, LSearchOption);

    { For files use GetFiles method }
    //if not cbIncludeDirectories.Checked and cbIncludeFiles.Checked then
      LList := TDirectory.GetFiles(GetHomePath, '*.*', LSearchOption);
  except
    { Catch the possible exceptions }
    on e:exception do
    memo1.Lines.insert(0,'Incorrect path or search mask' + e.Message);
   // Exit;
  end;

  { Populate with the results }
         memo2.Lines.Clear;
  for I := 0 to Length(LList) - 1 do begin
     memo2.Lines.Add(LList[I]);
     listview1.Items.Add();
  end;

    for I := 0 to memo2.Lines.Count  - 1 do
     listview1.Items[i].Text:=extractfilename(memo2.Lines[I]);


     listView1.visible:=true;
     memo2.Lines.Clear;
end;

procedure TForm1.btnLoadFileClick(Sender: TObject);
begin
         if trim(editfilename.Text) = '' then
              exit;

       // -- parse the file - -memo will cry if theres an invalid filename  when loading
        ParseObject;
end;

procedure TForm1.btnSaveIniFileClick(Sender: TObject);
 var
   Ini: TIniFile;
 begin
     try
      // ini := TIniFile.Create(format('%s/config.ini', [GetHomePath]));
      //ini := TIniFile.Create('config.ini');
                   ini:= TIniFile.Create(System.IOUtils.TPath.GetDownloadsPath+
                         System.SysUtils.PathDelim+'collaborart-config.ini');

        except
             on e:exception do begin
               showmessage('Unable to save the ini file re: '+e.Message);
               exit;
             end;
     end;

           try
               Ini.WriteString( 'edtPort', 'text', edtPort.Text);
               Ini.WriteString( 'edtRelay', 'text', edtRelay.Text);
               Ini.WriteString( 'edtPublish', 'text', edtRelay.Text);
                 finally
               showmessage('Close and Restart the Server for changes to take effect.' +
               slinebreak+ 'Saved to: '+ini.FileName);
               Ini.Free;
           end;


end;

procedure TForm1.btnSayItClick(Sender: TObject);
begin
           if btnSayIt.Text = '' then begin
              btnSayIT.Text:='✓';
			     end
               else begin
                 btnSayIT.Text:='';
              end;
end;

procedure TForm1.btnClearClick(Sender: TObject);
begin
memo1.Lines.Clear;
end;

procedure TForm1.btnExportClick(Sender: TObject);
begin
      if uppercase(trim( editFilename.text)) = 'CONFIG.INI' then  // never overwrite it
      exit;

                //-- preserve the old file if it exists
       try
           if FileExists(System.IOUtils.TPath.GetSharedDocumentsPath +pathdelim+ editFilename.text) then begin

                        renamefile(System.IOUtils.TPath.GetSharedDocumentsPath +pathdelim+ editFilename.text,
                        System.IOUtils.TPath.GetSharedDocumentsPath +pathdelim+ editFilename.text+'-old.txt');
                        memo1.Lines.insert(0,'Your existing file has been renamed to ' + editFilename.text+'-old.txt');
          end;
         System.IOUtils.TFile.Copy(format('%s/'+editFilename.text+'', [GetHomePath]),
                      System.IOUtils.TPath.GetSharedDocumentsPath +pathdelim+ editFilename.text,true);
            memo1.Lines.insert(0,'Exported to: '+System.IOUtils.TPath.GetSharedDocumentsPath +pathdelim+ editFilename.text);

              except
                on e:exception do begin
                     memo1.Lines.insert(0,'File Save Error: '+ e.Message);
                     memo1.Lines.insert(0,'Collaborart needs file permissions.');
                     memo1.Lines.insert(0,'Do this from your devices settings.');
                    exit;
                end;
      end;
       btnListFilesclick(self);
   //    memo1.GoToTextEnd;
end;

// this wants a param for the input json or loads it - as a function it can have a result
procedure TForm1.ParseObject;
  var
  i,j,k:integer;
  sysBlockFound:boolean;
  s:string; // use to copy and test just a chunk for id instead of looking through the whole body of text
  aStrings:Tstringlist;
//   Svc: IFMXClipboardService;
aWide:Widestring;
//testSingle:single;
//fs:tFormatSettings;
//aDouble:double;
begin
    //  fs := TFormatSettings.Create(SysLocale.DefaultLCID);  // needed to convert mouse pos x like 23.3253543 to 23
   {    if  ConnectionCount = 0 then begin
           memo1.Lines.insert(0,'You need to connect to this server with a browser client first.');
           exit
       end;
     }

     // what will need to happen is that if a 'random butons' file is loaded
     // 1. is there already a random button <button> on the screen ?
     // 2. has a file been loaded
     // By default a rendom button is placed on the screen but this is not a good idea
     //  because the next thing is a person opens a file which has buttons
     // This means that there will be more than one occurance of a random button
     // and this is a big problem ! can't have that
     // Possible solutions:
     // The first thing to find out is if the text area being made has a random button in it.
     // ie. random1 or random2
     // Only then make a random button 'circle'

         aStrings:=tStringlist.Create;
        try
            {$IFDEF MSWINDOWS}
            aStrings.LoadFromFile(format('%s\'+editFilename.text+'', [GetHomePath]));
             {$ELSE}
             aStrings.LoadFromFile(format('%s/'+editFilename.text+'', [GetHomePath]));
            //   memo2.EndUpdate;
           //  aStrings:=aStrings;// force an android update
            {$ENDIF}
             //   memoFileContents.Text:=aStrings.Text;
        //-- put it in the clipboard -- this means a person can transport it via email or edit in
        // another text editor.
         {  if btnSayIt.Text = '✓' then// begin // start the engine by saying something
              if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, Svc) then begin
              Svc.SetClipboard(aStrings[0]);
              memo1.Lines.insert(0,editFilename.text+' contents are on your clipboard.');
                 awide:=svc.GetClipboard.AsString;
             end;
             }
          except
          on e:exception do begin
            memo1.Lines.insert(0,'Could not load the file: '+e.Message );
          end;
        end;


      //-- first test to see if it actually a json file
          //   s:=copy(memo2.Lines[0],0,40);
           s:=copy(aStrings[0],0,40);

          k:= pos('"id":"', s,1);
            //      k:= pos('"id":"', memo2.Text,1);

          if k <= 1 then begin // it is valid keep-alive message
                memo1.Lines.insert(0,'The file '+editFilename.Text+' is not a CollaborArt project file. ');
               // not a project but show the the files contents anywat

(*
                  try
                      //  {$IFDEF MSWINDOWS}
                           memoFileContents.BeginUpdate;
                           memoFileContents.Lines.LoadFromFile(format('%s\'+editFilename.text+'', [GetHomePath]));
                           memoFileContents.EndUpdate;
                       //  {$ELSE}
                           memoFileContents.BeginUpdate;
                           memoFileContents.Lines.LoadFromFile(format('%s/'+editFilename.text+'', [GetHomePath]));
                           memoFileContents.EndUpdate;
                       // {$ENDIF}
                     except
                      on e:exception do begin
                        memo1.Lines.insert(0,'Could not load the file: ' +e.Message );
                      end;
                  end;

*)

                 // listView1.visible:=false;
                //  lblScrollbar.Visible:=true;
               //    btnImport.visible:=true;
              //     memoFileContents.Visible:=true;
            exit;
         end;

    // Guess what - the clipboard 'fixes' the text
    // so get the text from the clipboard into the aWide again
    awide:=aStrings.Text;
  //  aStrings.Text:=aWide;


   CreateReader('{"Transaction":'+ awide{aStrings.Text}+ '}');

     // listView1.visible:=false;
    //  lblScrollbar.Visible:=true;
      btnImport.visible:=true;

     //-- reuse astrings for reader
     aStrings.Clear;

        while Reader.read do
        
         case Reader.TokenType of
 // ++          TJsonToken.String:  Memo2.Lines.Add(Reader.Value.ToString ) ;
 // ++          TJsonToken.Integer: Memo2.Lines.Add(Reader.Value.ToString ) ;
             TJsonToken.String: aStrings.Add(Reader.Value.ToString ) ;
             TJsonToken.Integer: aStrings.Add(Reader.Value.ToString ) ;
              // DO NOT REMOVE  - end object may be needed sometime

   TJsonToken.Float:  begin   // if the mouse pos x was say 345.45734556 then it will not be added
     aStrings.Add(Reader.Value.ToString ); 
  // memo1.Lines.insert(0,'float found: '+ Reader.Value.ToString);

   end;
              {   TJsonToken.Boolean:
                 memo1.Lines.insert(0,'Boolean Value : ' + Reader.Value.ToString + '- Token Path : ' + Reader.Path);
                 TJsonToken.Null:
                 memo1.Lines.insert(0,'Null Value : ' + Reader.Value.ToString + '- Token Path : ' + Reader.Path);
                 TJsonToken.EndArray:
                 memo1.Lines.insert(0,'(EndArray) ' + '- Token Path : ' + Reader.Path);
                 TJsonToken.EndObject:
                 memo1.Lines.insert(0,'(EndObject) ' + '- Token Path : ' + Reader.Path);  }
         end;

     j:=0;
           sysBlockFound:=false;
 //++    for i:= 0 to memo2.lines.count - 1 do begin
     for i:= 0 to aStrings.count -1 do begin

          //-- look for the notify
 //++           if trim(memo2.lines[i]) = 'notifyblock' then begin
             if trim(aStrings[i]) = 'notifyblock' then begin
             sysBlockFound:=true;
               //    memo2.lines[i]:='NOTIFYBLOCK WILL NOT BE INCLUDED';
            end;


            // it will be important to remove any existing round randoms first.
          //-- look for the random1
          //  if trim(memo2.lines[i]) = 'randomblock1' then begin
          //   sysBlockFound:=true;
               //     memo2.lines[i]:='RANDOMBLOCK 1 WILL NOT BE INCLUDED';
          //  end;

          //-- look for the random2
        //    if trim(memo2.lines[i]) = 'randomblock2' then begin
        //     sysBlockFound:=true;
              //  memo2.lines[i]:='RANDOMBLOCK 2 WILL NOT BE INCLUDED';
        //    end;

       if j = 10  then begin
            // The fields are inheriting the memo's formatting which means that
            // they will need to be stored into another 'type' eg .. edit box

                    edit1.Text:= aStrings[i-10];      // id
                    edit2.Text:= aStrings[i-9];       // x
                    edit3.Text:= aStrings[i-8];       // y
                    edit4.Text:= aStrings[i-7];       // width
                    edit5.Text:= aStrings[i-6];       // height
                    edit6.Text:= aStrings[i-5];       // zindex
                    edit7.Text:= aStrings[i-4];       // Color
                    edit8.Text:= aStrings[i-3];       // doDelete
                    edit9.Text:= aStrings[i-2];       // Atext
                    edit10.Text:= aStrings[i-1];      // AExtraText


               // The problem here is that the mouse position 'x' could look like 123.342343
               // same for y position. This means that the whole process gets thrown
               // out of sync.
               // Two solutions can be made, 1 is to search for a period '.'
               // other is to type cast from float to single.

               //    memo1.Lines.insert(0,'id: ' + edit1.Text);
               //    memo1.Lines.insert(0,'x: ' + edit2.Text);
               //    memo1.Lines.insert(0,'y: ' + edit3.Text);


             if sysBlockFound = false then begin                          

                  //*************************************************************************** 
                      try
                              TCircle.CreateFromFile(
                                  edit2.Text.ToSingle,         // x
                                  edit3.Text.ToSingle,        // y
                                  edit4.Text,                   // width
                                  edit5.Text,             // height
                                  edit6.Text,             // zindex
                                  edit7.Text,             // Color
                                  edit8.Text,              // doDelete
                                  edit9.Text,             // Atext
                                  edit10.Text,              // AExtraText
                                  edit1.Text
                                   );
                        //   memo1.Lines.insert(0,'Made: ' + edit1.Text);
                        itemCount:=itemCount+1;
                         except
                         on e:exception do
                         memo1.Lines.insert(0,'Conversion Error at: ' + edit1.Text+ '  error: '+ e.Message);

                       end;
                     //*********************************************************************    
            end;

          sysBlockFound:=false;
         j:=0;
       end;
         j:=j+1;
     end;
           //  memo1.Lines.insert(0,'END: ' + aStrings[i-1]);
           //  memo1.Lines.insert(0,'id: ' + aStrings[i-10]);
           //  memo1.Lines.insert(0,'x: ' + aStrings[i-9]);
           //  memo1.Lines.insert(0,'y: ' +aStrings[i-8]);


                    edit1.Text:= aStrings[i-10];      // id
                    edit2.Text:= aStrings[i-9];       // x
                    edit3.Text:= aStrings[i-8];       // y
                    edit4.Text:= aStrings[i-7];       // width
                    edit5.Text:= aStrings[i-6];       // height
                    edit6.Text:= aStrings[i-5];       // zindex
                    edit7.Text:= aStrings[i-4];       // Color
                    edit8.Text:= aStrings[i-3];       // doDelete
                    edit9.Text:= aStrings[i-2];       // Atext
                    edit10.Text:= aStrings[i-1];      // AExtraText

               if length(trim(aStrings[i-10])) = 36 then begin
                        try
                              TCircle.CreateFromFile(
                                  edit2.Text.ToSingle,         // x
                                  edit3.Text.ToSingle,        // y
                                  edit4.Text,                   // width
                                  edit5.Text,             // height
                                  edit6.Text,             // zindex
                                  edit7.Text,             // Color
                                  edit8.Text,              // doDelete
                                  edit9.Text,             // Atext
                                  edit10.Text,              // AExtraText
                                  edit1.Text
                                   );
                        //   memo1.Lines.insert(0,'Made: ' + edit1.Text);
                        itemCount:=itemCount+1;
                         except
                         on e:exception do
                         memo1.Lines.insert(0,'Conversion Error at: ' + edit1.Text+ '  error: '+ e.Message);

                       end;
               end;

             // -- clean up
             // memo2.Lines.Clear;
              //    memoFileContents.Text:=aStrings.Text;
             freeandNil(aStrings);
              //    Reader.Destroy;
                    edit1.Text:='';
                    edit2.Text:= '';
                    edit3.Text:= '';
                    edit4.Text:= '';
                    edit5.Text:='';
                    edit6.Text:='';
                    edit7.Text:= '';
                    edit8.Text:= '';
                    edit9.Text:= '';
                    edit10.Text:='';

    //   memoFileContents.Visible:=true;

(*
               try
                  {$IFDEF MSWINDOWS}
                     memoFileContents.BeginUpdate;
                     memoFileContents.Lines.LoadFromFile(format('%s\'+editFilename.text+'', [GetHomePath]));
                     memoFileContents.EndUpdate;
                   {$ELSE}
                     memoFileContents.BeginUpdate;
                     memoFileContents.Lines.LoadFromFile(format('%s/'+editFilename.text+'', [GetHomePath]));
                     memoFileContents.EndUpdate;
                  {$ENDIF}
               except
                on e:exception do begin
                  memo1.Lines.insert(0,'Could not load the file ' + editFilename.Text+ '  for viewing.  '+e.Message);
                end;
              end;
                  memoFileContents.Visible:=true;
      //-- let the user know that for android the text goes to the clipboard
*)

      // freeandNil(Reader); <-- create reader frees the reader
           memo1.Lines.insert(0,'Finished Loading: '+editFilename.text);
           memo1.Lines.insert(0,'Items: '+itemCount.ToString);
            itemCount:=0;
       //   memo1.GoToTextEnd;
end;

procedure TForm1.CreateReader(Str: string);
begin
  if Reader <> nil then
     Reader.Free;
  if Sr <> nil then
    Sr.Free;
    Sr := TStringReader.Create(Str);
   Reader := TJsonTextReader.Create(Sr);
end;


procedure TForm1.CheckButtonClick(Sender: TObject);
begin
      if FServer.Active then
       memo1.Lines.insert(0,'Server is active. Listening Queue: '+FServer.ListenQueue.ToString)
       else
        memo1.Lines.insert(0,'Server is inactive.');

        try
          memo1.Lines.insert(0,'File path is: '+ GetHomePath  );
        except
         memo1.Lines.insert(0,'File path to ' + editFilename.Text + ' not found: ');
        end;
       Memo1.Lines.insert(0, 'Server Contexts: '+ FServer.Contexts.Count.ToString );

        memo1.Lines.insert(0,'Import/Export File path: '+ System.IOUtils.TPath.GetSharedDocumentsPath);
     //   memo1.Lines.insert(0,'App File path: '+ GetHomePath  );
      //  memo1.Lines.insert(0,'Server is Active.');
end;


procedure TForm1.ClearMemoButtonClick(Sender: TObject);
begin
     memo1.Lines.Clear;
end;

procedure TForm1.CloseButtonClick(Sender: TObject);
begin
      memo1.Lines.Clear;

      memo1.Lines.insert(0,'Please wait for the clients to shutdown.'+slinebreak+slinebreak+
                   'Connection timeouts are set to 2 minutes.'+slinebreak+
                   'You can also use the Task Manager or'+slinebreak+
                   ' App Manager on your device to shutdown.');
        Memo1.Lines.insert(0, 'Server Contexts: '+ FServer.Contexts.Count.ToString );

       close;
end;

procedure TForm1.SaveButtonClick(Sender: TObject);
var
memStream:TMemoryStream;
begin
   //    memo1.Lines.insert(0, System.IOUtils.TPath.GetSharedDocumentsPath);

    if uppercase(trim( editFilename.text)) = 'CONFIG.INI' then  // never overwrite it
      exit;

         memstream:=TMemoryStream.Create;
           try
            {$IFDEF MSWINDOWS}
             memstream.LoadFromFile(format('%s\TheData.txt', [GetHomePath]));
             memstream.SaveToFile(format('%s\'+editFilename.text+'', [GetHomePath]));//trim(editFilename.Text)) ;
             {$ELSE}
             memstream.LoadFromFile(format('%s/TheData.txt', [GetHomePath]));
             memstream.SaveToFile(format('%s/'+editFilename.text+'', [GetHomePath]));//trim(editFilename.Text)) ;
            {$ENDIF}

              freeandnil(memstream);
              memo1.Lines.insert(0,'File Saved: '+ editFilename.text);
              except
               on e:exception do begin
                 memo1.Lines.insert(0,'File Save Error: '+ e.Message);
                 freeandnil(memstream);
                exit;
               end;
           end;
  //   memo1.GoToTextEnd;
end;

procedure TForm1.Connect(AContext: TIdContext);
var
  io: TWebSocketIOHandlerHelper;
  msg: string;
  s: String;
begin
      CheckBox1.IsChecked:=true;
      // inc(ConnectionCount);
     //   if ConnectionCount <> 0 then
  //   if  trim(Memo1.Lines[0])<> 'Server Contexts: 1' then
      ConnectionCount:= FServer.Contexts.Count;
   // TODO - THIS  SHOULD GO INTO A SEPERATE LABLE
   lblServerContexts.Text:= 'Server Contexts: '+ ConnectionCount.ToString;
 // lblServerContexts.Text:=  'Server AContext: '+ AContext.ToString;
 //  Memo1.Lines.insert(0,  'Server Context: '+ AContext.Data.ToString);
  Memo1.Lines.insert(0,  'New Connection Made.');
 //  Memo1.Lines.insert(0, 'Server WorkTarget: '+ FServer.WorkTarget.ToString );




{  //----------------
          io:= TWebSocketIOHandlerHelper(AContext.Connection.IOHandler);

        if  io.CheckForDataOnSource(10) then
            msg := io.ReadString;

          //memo1.Lines.Add('Server msg is: '+msg);
       //
          // memo1.Lines.Add('Server msg is: '+msg);

            if msg = '' then//begin
             //  memo1.Lines.Add('Server msg found but it is empty. ');
               exit;
          // end;
        //  memo1.Text:='';
          // else
           //    memo1.Lines.Add(msg);
           memo1.Lines.Add('Server Connect msg is: '+msg);
  //--------------  }



end;

procedure TForm1.Disconnect(AContext: TIdContext);
begin
    //  dec(ConnectionCount);
      //  if  trim(Memo1.Lines[0])<> 'Server Contexts: 1' then
        ConnectionCount:= ConnectionCount-1;
      lblServerContexts.Text:= 'Server Contexts: '+  ConnectionCount.ToString;
   //   Memo1.Lines.insert(0, 'Server Contexts: '+ FServer.Contexts.Count.ToString );
     //  TODO - - FIRST GET THE COUNT
     // something needs to check if there are any more connections!!!!!!!!!!
     // This will cause the message to pop up all the time which
     // will make the memo look messy with too much info
         //  if ConnectionCount <> 0 then
         //    CheckBox1.IsChecked:=false;
         //    Memo1.lines.insert(0, 'No clients are connected.')
         // else
        // if ConnectionCount >= 1 then
        //  Memo1.lines.insert(0, 'Clients connected: ' + ConnectionCount.ToString);
end;

procedure TForm1.Execute(AContext: TIdContext);
var
  io: TWebSocketIOHandlerHelper;
  msg: string;
  s, params: String;
  JsonStr: string;
  i,j:integer;
       // for relaying to www

       memstream: TMemoryStream;
       didIt: boolean;
   const sx:single = 0;
   const sy:single = 0;
begin
         //   params := AContext.Connection.IOHandler.ReadLn();
           //  memo1.Lines.Add('Params: '+params);
          //  exit;

          io:= TWebSocketIOHandlerHelper(AContext.Connection.IOHandler);

      if  io.CheckForDataOnSource(10) then
          msg := io.ReadString;

        //memo1.Lines.Add('Server msg is: '+msg);
     //
        // memo1.Lines.Add('Server msg is: '+msg);

          if msg = '' then//begin
           //  memo1.Lines.Add('Server msg found but it is empty. ');
             exit;
        // end;
      //  memo1.Text:='';
        // else
         //    memo1.Lines.Add(msg);
        //  memo1.Lines.Add('Server msg is: '+msg);
        try
         JsonMsg := TJsonObject(TJsonObject.Parse(msg));
          except
          JsonMsg := nil;
        end;

  // HERE SEE WHATS WHAT

//  memo1.Lines.insert(0,'Execute: '+ TJsonObject.Parse(msg).ToString );

     if JsonMsg = nil then
     exit;

     if JsonMsg.S['act'] = 'create' then   begin
             // here the values of x and y must be checked for a 34.34535 floting point
             // number and typecast it into a single. A saved file with x and y
             // values as float will crash when reloaded at the poit where the float is found
             // The parseObject will read it as a float and not a strig value
             // and does not give it overt to the proc and 
             // 

            // somewhere here the text must look for a random
            // id="randomNum1" or id="randomNum2"
             // and thats going to be in the 'text' part of the create param submitted

         // whats needed to be known now is if a random number already exists
         // The Tcircles will have to know this -
         // At this point the files will be inconsistent   - the end user will need to know this
         // if the ser creates a new object using buttons they will get a new random id assigned
         // to the new set. They will not be the same id's but should still work.
         // That is because the buttons will have the same name and call the same procedure with the same values.

           // here setidRandomNumber1 will check if there is a random id
           // the problem is that a new number gets generated every time
           // but this has to be established
           s:= Fserver.setidRandomNumber1(JsonMsg.S['id']);


             i:= pos('id="randomNum1"',  JsonMsg.S['text'] ,1);
             didIt :=false;

            if s <> 'ID_Exists' then
                s:=''
                  else
            if i <> 0 then begin
                  TCircle.CreateRandomBlock(JsonMsg.F['-100'], JsonMsg.F['-100'] ,
                      JsonMsg.S['width'] , JsonMsg.S['height'], JsonMsg.S['zindex'] ,// always zero
                      JsonMsg.S['color'] , 'randomblock1',
                      JsonMsg.S['text'],'random1'  );
                    // -- throttle it a bit
                 Sleep(200);

              TCircle.CreateRandomBlock(JsonMsg.F['-100'], JsonMsg.F['-100'] ,
                         JsonMsg.S['width'] , JsonMsg.S['height'], JsonMsg.S['zindex'] ,// always zero
                         JsonMsg.S['color'] , 'randomblock2',
                         JsonMsg.S['text'],'random2'  );
                // -- throttle it down a tiny bit
                 Sleep(10);
           end
           else
            if didIt =false then  begin
                  s:= Fserver.setidRandomNumber2(JsonMsg.S['id']);
              if s <> 'ID_Exists' then begin
                   s:='';
               j:= pos('id="randomNum2"',  JsonMsg.S['text'] ,1);
                if j <> 0 then begin
                    // memo1.Lines.insert(0,'Got random 2 in the text. ');
                       TCircle.CreateRandomBlock(JsonMsg.F['-100'], JsonMsg.F['-100'] ,
                           JsonMsg.S['width'] , JsonMsg.S['height'], JsonMsg.S['zindex'] ,// always zero
                           JsonMsg.S['color'] , 'randomblock2',
                           JsonMsg.S['text'],'random2'  );
                    // -- throttle it down a tiny bit
                     Sleep(10);
                end;
              end;
            end;

           if (JsonMsg.S['doDelete'] = 'notifyblock') and (JsonMsg.S['text'] = 'wqx1b4') then  begin  // every other time
             //memo1.Lines.insert(0,'Notify Block: '+ TJsonObject.Parse(msg).ToString );
              if itemCount = 0  then
                TCircle.Create(JsonMsg.F['x'], JsonMsg.F['y'] ,
                      JsonMsg.S['width'] , JsonMsg.S['height'], {JsonMsg.S['zindex']}'2001' ,// always zero
                     { JsonMsg.S['color']} '#e6005c', JsonMsg.S['doDelete'] ,
           '&#160;&#160;',// 'Changes were made. Click ''Update View'' to get the servers copy!',
                JsonMsg.S['extratext']);//+s1+'wx']);

             // make random1 and 2 so its the random number used this to find it by the client

              // these get sent to the client way to fast for the client to handle
              // so it looses either ramdom 1 or 2 along the way
              // -- throttle it  abit
              {**********
             sleep(200);
             TCircle.CreateRandomBlock(JsonMsg.F['-100'], JsonMsg.F['-100'] ,
                       JsonMsg.S['width'] , JsonMsg.S['height'], JsonMsg.S['zindex'] ,// always zero
                       JsonMsg.S['color'] , 'randomblock1',
             JsonMsg.S['text'],'random1'  );
              // -- throttle it  abit
               Sleep(200);

              TCircle.CreateRandomBlock(JsonMsg.F['-100'], JsonMsg.F['-100'] ,
                       JsonMsg.S['width'] , JsonMsg.S['height'], JsonMsg.S['zindex'] ,// always zero
                       JsonMsg.S['color'] , 'randomblock2',
             JsonMsg.S['text'],  'random2'  );
             //  Sleep(200);
             ********* }
           end
             else
             // here two things can happen - the person clicked on the 'Text' button but there
             // but the textarea's edit block was empty
             // OR the person had entered text and then clicked the 'Text' button

           if (JsonMsg.S['doDelete']  = 'textarea') and ( trim(JsonMsg.S['text']) = s) then begin

                  TCircle.Create(JsonMsg.F['x'], JsonMsg.F['y'] ,
                       JsonMsg.S['width'] , JsonMsg.S['height'], JsonMsg.S['zindex'] ,
                       JsonMsg.S['color'] , JsonMsg.S['doDelete'] ,

                 // TODO - add in some formatting eg. <font color> to make it nice for the client to see
                 //        but remember the clients code must get updated to share the same
                 //       text as below in order to make sure it gets past the if(whatever = whatever){}
                 //
                  'Click me first then enter text in the text area at the bottom of the menu on the left of the screen.<br>Click and drag to new location.',JsonMsg.S['extratext']);

               { memo1.Lines.insert(0,'empty textarea :' + JsonMsg.S['text']+#13#10+
                                'zindex :' + JsonMsg.S['zindex'] +#13#10+
                                'width :' + JsonMsg.S['width']  +#13#10+
                                'height :' + JsonMsg.S['height']   );
                          }
                      // 'Click me first then enter text in the text area at the bottom of the menu on the left of the screen.<br>Click and drag to new location.');
           end
              else
           if (JsonMsg.S['doDelete']  = 'textarea') and (JsonMsg.S['text'] <> s) then begin
                   TCircle.Create(JsonMsg.F['x'], JsonMsg.F['x'] ,
                       JsonMsg.S['width'] , JsonMsg.S['height'],  JsonMsg.S['zindex'] ,
                       {JsonMsg.S['color']} '#0099cc' , JsonMsg.S['doDelete'] ,
                         JsonMsg.S['text'],JsonMsg.S['extratext'] );

             {   memo1.Lines.insert(0,'custom textarea :' + JsonMsg.S['text']+#13#10+
                                'zindex :' + JsonMsg.S['zindex'] +#13#10+
                                'width :' + JsonMsg.S['width'] +#13#10+
                                'height :' + JsonMsg.S['height'] );   }
           end;

           // this is made to be a 'animation - move' circleButton
              if JsonMsg.S['doDelete'] = 'circle' then begin
                TCircle.Create(JsonMsg.F['x'], JsonMsg.F['x'] ,
                       JsonMsg.S['width'] , JsonMsg.S['height'], JsonMsg.S['zindex'] ,
                     {  JsonMsg.S['color']}'#0099cc' , JsonMsg.S['doDelete'] ,
                       JsonMsg.S['text'],  JsonMsg.S['extratext']);

                   {    memo1.text:=('create : '+ JsonMsg.F['x'].ToString +'  : '+ JsonMsg.F['y'].ToString + '  : '+
                              JsonMsg.F['width'].ToString +'  : '+ JsonMsg.F['height'].ToString+  '  : '+
                              JsonMsg.S['color'] +'  : '+ JsonMsg.S['doDelete'] +  '  : '+
                              JsonMsg.S['text']  +'  : '+ JsonMsg.S['text']);
                    }
         end;

        // NOTE -VERY IMPORTANT - it is ASSUMED that an item was created !
        // This should be set by websocketserver
       //  itemCount:=itemCount+1;
       //   memo1.Lines.insert(0,'Items: '+itemCount.ToString);
     end;   // if JsonMsg.S['act'] = 'create'

      if JsonMsg.S['act'] = 'move' then begin
           TCircle.Move(JsonMsg.S['id'], JsonMsg.F['x'], JsonMsg.F['y']);
      end;


      if JsonMsg.S['act'] = 'changecolor' then begin
           TCircle.ChangeColorForCircle(JsonMsg.S['id']);
          //log   memo1.Lines.insert(0,'Color requested: '+ JsonMsg.S['id']);
      end;

      if JsonMsg.S['act'] = 'newcolor' then begin  //NewColor(ID:string; Acolor:string);
       //   memo1.Lines.insert(0,' action newcolor: '+JsonMsg.S['id'] +'  color:' + JsonMsg.S['theColor'] );
          TCircle.NewColor(JsonMsg.S['id'],JsonMsg.S['theColor'] );
      end;

      if JsonMsg.S['act'] = 'destroy' then   begin
         TCircle.DestroyCircle(JsonMsg.S['id']);
          itemCount:=itemCount-1;  // loading a file adds this but
                                   // needs to be decreased if an item is deleted
        //  memo1.Lines.insert(0,'Items: '+itemCount.ToString);
       //  memo1.Lines.insert(0,'Deleted: '+JsonMsg.S['id']);
      end;

      if JsonMsg.S['act'] = 'changetext' then begin
      // this resets the color circle to white to let the text be a  text block with no circle
       //             changetext(const Id, theText, color :string; width, height: single)
            TCircle.changetext(JsonMsg.S['id'],JsonMsg.S['text'],JsonMsg.S['color'], JsonMsg.S['width'] , JsonMsg.S['height'], JsonMsg.S['zindex'], JsonMsg.S['extratext']);

         { log  memo1.Lines.insert(0,'5 CHANGE TEXT :'+JsonMsg.S['id']+#13#10 +
                                'color :' + JsonMsg.S['text']+#13#10+
                                'color :' + JsonMsg.S['color']+#13#10+
                                'width :' + JsonMsg.S['width']+#13#10+
                                'height :' + JsonMsg.S['height'] +#13#10+
                                'zindex :' + JsonMsg.S['zindex'] ); }
      end;

      if JsonMsg.S['act'] = 'save' then begin
              memstream:=tMemoryStream.Create;

            try
              editFilename.Text:=JsonMsg.S['filename'];

             if trim(editfilename.Text) = '' then
                 exit;

           {$IFDEF MSWINDOWS}
             memstream.LoadFromFile(format('%s\TheData.txt', [GetHomePath]));
             memstream.SaveToFile(format('%s\'+editFilename.text+'', [GetHomePath]));//trim(editFilename.Text)) ;
             {$ELSE}
              memstream.LoadFromFile(format('%s/TheData.txt', [GetHomePath]));
              memstream.SaveToFile(format('%s/'+editFilename.Text+'', [GetHomePath]));//trim(editFilename.Text)) ;
            {$ENDIF}
                memo1.Lines.insert(0,'Saved: '+ JsonMsg.S['filename']);
                freeandnil(memstream);
           except
               on e:exception do begin
                 memo1.Lines.insert(0,'File Save Error: '+ JsonMsg.S['filename']+'  --> '+ e.Message);
                 freeandnil(memstream);
                exit;
               end;
           end;
      end;

      if JsonMsg.S['act'] = 'load' then begin
            editFilename.Text:=JsonMsg.S['filename'];
            if trim(editfilename.Text) = '' then
               exit
             else
               parseobject;
      end;

      if JsonMsg.S['act'] = 'delete' then begin
           {$IFDEF MSWINDOWS}
           if FileExists(format('%s\'+JsonMsg.S['filename']+'', [GetHomePath])) then
              begin
                deletefile(format('%s\'+JsonMsg.S['filename']+'', [GetHomePath]));
                memo1.Lines.insert(0,'Deleted :'+JsonMsg.S['filename']);
               end;
             {$ELSE}
           if FileExists(format('%s/'+JsonMsg.S['filename']+'', [GetHomePath])) then
              begin
                deletefile(format('%s/'+JsonMsg.S['filename']+'', [GetHomePath]));
                 memo1.Lines.insert(0,'Deleted :'+JsonMsg.S['filename']);
               end;
            {$ENDIF}
      end;

      if JsonMsg.S['act'] = 'ListFiles' then begin
        memo1.Lines.insert(0,'Listing files.. one day in the future');
      end;

      // ACTUALLY --- StartOver - DestroyAll clears all circles
      if JsonMsg.S['act'] = 'reset' then begin

          s:= TCircle.DestroyAllCircles; // returns 'Done' when finished

          if s = 'Done' then begin
            JsonStr :=( '[{"id":"BUBBLEGUM-AAAA-AAAA-AAAA-AAAAAAAAAAAA","x":0,"y":0,"width":"0","height":"0","zindex":"0","color":"#006699","doDelete":"custommessage","text":"Ready for new project.","extratext":" "}]');
            sendBroadcast(self, Acontext, JsonStr);
            itemCount:=0;
           // memo1.Lines.insert(0,'Items: '+itemCount.ToString);
          // memo1.Lines.insert(0,'Items: '+itemCount.ToString);
         end
          else
          memo1.Lines.Insert(0,'Could not reset. Please try again.')
      end;


      if JsonMsg.S['act'] = 'updaterandom' then begin
                 {act: 'updaterandom',
									   id: $myRandomAID ,
									  boxnumber:xr}
           // This is an indicator that there is a custom random number set of buttons.
           // The app has no knowledge of this because it came from an external source
           // and as a resukt will not save the data to a file because it simply does not exist.
           // This cmd get wind of this and here is becomes possible to interact with the client.
           // What is required is a way to know the button set so the table must contain a
           // ID which says how many buttons there are in it so the tag called data can have that.
           // eg. a set with two buttons means an ID of 2 - one button and id od 1 and so on.
           //  Then the server will know how many buttons to construct a json entry for it
           // This will need to know all the info about the position etc.
           // as this piece of data is sent so the server must be notified of it.
           // There shold only be one set of buttons.
           // maybe not because the server can just get sent the table tag in its entirety.

            TCircle.UpdateTheRandom1(trim(JsonMsg.S['id']), JsonMsg.S['randomboxnumber'], JsonMsg.S['boxnumber'] );
          //   memo1.Lines.insert(0,'action updaterandom1:  thenumber: '+ JsonMsg.S['boxnumber']);

           JsonStr :=( '[{"id":"ACEFACED-AAAA-AAAA-AAAA-AAAAAAAAAAAA","x":0,"y":0,"width":"0","height":"0","zindex":"0","color":"#006699","doDelete":"custommessage","text":"'+JsonMsg.S['randomboxnumber']+'","extratext":"'+JsonMsg.S['boxnumber']+'"}]');
            //  memo1.Lines.insert(0,' Got past.... while FSendCirclesThreadWorking do  ');
           sendRandom(self, Acontext, JsonStr);
      end;


      if JsonMsg.S['act'] = 'custombutton' then begin // from function myFindClass() in web page
         // A client has added a custom button <table>
         // just make a circle and on the client side the table is removed ...
         // The problem here is if the customer chops and changes the table
         // Therfore its vial to build a string that looks exactly like a circle
       theTalbeData := ',{"id":"ACBUTTON-AAAA-AAAA-AAAA-AAAAAAAAAAAA","x":'+JsonMsg.S['x']+'","y":'+JsonMsg.S['y']+'":0,"width":"0","height":"0","zindex":"2003","color":"","doDelete":"custombutton","text":"'+JsonMsg.S['tabletext']+'","extratext":""}] ';
        //  memo1.Lines.insert(0,'Added: '+ JsonMsg.F['x'].ToString + ',' + JsonMsg.F['y'].ToString +','+JsonMsg.S['tabletext']);
        //  memo1.Lines.insert(0,'Added: '+ theTableData);
      end;

    if JsonMsg.S['act'] = 'broadcast' then begin
            {act: 'broadcast',
					  message: "my message text"}
      memo1.Lines.insert(0,'Posted message: ' +trim(JsonMsg.S['message']));

       if trim(JsonMsg.S['message']) <> '' then begin
           JsonStr :=( '[{"id":"BUBBLEGUM-AAAA-AAAA-AAAA-AAAAAAAAAAAA","x":0,"y":0,"width":"0","height":"0","zindex":"0","color":"#006699","doDelete":"custommessage","text":"'+JsonMsg.S['message']+'","extratext":" "}]');

          sendBroadcast(self, Acontext, JsonStr);
         //    memo1.Lines.insert(0,' Got past.... while FSendCirclesThreadWorking do  ');
       end;
   end;


       if JsonMsg.S['act'] = 'photo' then begin
           //   memo1.Lines.insert(0,'Added: '+ JsonMsg.F['x'].ToString + ',' + JsonMsg.F['y'].ToString +','+JsonMsg.S['id']);
           //**  memo1.Lines.insert(0,'Added: '+JsonMsg.S['text']);
           memo1.Lines.insert(0,'Got Picture Data ');
           // the other clients need to know also
      end;

      if JsonMsg.S['act'] = 'audio' then begin // from function myFindClass() in web page
         //  memo1.Lines.insert(0,'Posted message: ' +trim(JsonMsg.S['message']));
         if trim(JsonMsg.S['message']) <> '' then begin
             JsonStr :=( '[{"id":"VOICE-AAAA-AAAA-AAAA-AAAAAAAAAAAA","x":0,"y":0,"width":"0","height":"0","zindex":"0","color":"#006699","doDelete":"custommessage","text":"'+JsonMsg.S['message']+'","extratext":" "}]');

             sendBroadcast(self, Acontext, JsonStr);
        end;
      end;

      if JsonMsg.S['act'] = 'relay' then begin
      //log        memo1.Lines.Insert(0,'Relaying to '+edtrelay.Text);
          relayList.Add(JsonMsg.S['filename']);

          sendRelay;

        //  JsonMsg.DisposeOf;
       //   exit;
      end;

       if JsonMsg.S['act'] = 'publish' then begin
      //log        memo1.Lines.Insert(0,'Relaying to '+edtrelay.Text);  ///
          publishList.Add(JsonMsg.S['filename']);

       //   if amBusy = 1 then
       //   repeat
       //   i:=0;
       //   until amBusy = 0;

         //if amBusy = 0 then  // set to false at form.create (should default to that anyway)
           PublishFile(JsonMsg.S['filename']);
       //  else
       //  repeat

       //  until ambusy ;



         //   memo1.Lines.insert(0,'Publishing: '+JsonMsg.S['filename']);
        //  JsonMsg.DisposeOf;
        //  exit;
      end;


  JsonMsg.DisposeOf;
 end;

function StreamToString(const AStream: TStream): String;
begin
  Result := '';
  with TStringStream.Create() do
  try
    LoadFromStream(AStream);
    Result := DataString;
  finally
    Free;
  end;
end;


procedure TForm1.SendRelay;
var
    memstream:tMemoryStream;
    sFilename, sPOST: String;
    Params: TIdMultipartFormDataStream;
    Clients: TList;
begin
     //-- send to a remote php in json format
      if btnSayIt.Text = '✓' then begin

         if Assigned(FServer.Contexts) then  begin
           Clients := FServer.Contexts.LockList;

             sFilename:= System.IOUtils.TPath.GetHomePath +
                         System.SysUtils.PathDelim +
                         'TheSendData'+ formatdatetime('ddd-mmm-yyyy-hh-mm-ss',now)+'.txt';
            try
               memstream:=tMemoryStream.Create;
              {$IFDEF MSWINDOWS}
               memstream.LoadFromFile(format('%s\TheData.txt', [GetHomePath]));
               memstream.savetoFile(sFilename);
              {$ELSE}
               memstream.LoadFromFile(format('%s/TheData.txt', [GetHomePath]));
               memstream.savetoFile(sFilename);
              {$ENDIF}
              freeandnil(memstream);
             except
               on e:exception do begin
                 memo1.Lines.insert(0,'Transmit Error: '+ e.Message);
               end;
           end;
               //  thisRelayHTTP.Create(self);
              //   thisRelayHTTP.OnStatus:=idHTTP1Status;
                  try
                   Params := TIdMultipartFormDataStream.Create;
                   Params.AddFile('my_file', sFilename,'application/octet-stream');
                  except
                  on e:exception do
                    memo1.Lines.insert(0,'Upload Params error: '+e.Message);
                 end;

             memo1.Lines.Insert(0,'Starting to transfer: '+sFilename);

              try
                   sPOST := idHTTP1.Post(edtRelay.Text, Params);
                    memo1.Lines.insert(0,trim(sPOST));//+slinebreak+'At: '+ formatdatetime('ddd-mmm-yyyy-hh-mm-ss',now));
                except
                on e:exception do
// log  memo1.Lines.insert(0,'Error while trying to relay: '+e.Message);
                 //??? switch off trying to send
                 //   --> btnSayIT.Text:='';   ???
              end;
  //log  memo1.Lines.Insert(0,'Transfer of '+sFilename+ ' done.');
             freeandnil(params);
                  System.SysUtils.DeleteFile(sFilename);
        end;
         FServer.Contexts.UnlockList;
     end;
end;


procedure TForm1.PublishFile(theFile: string);
var
    memstream:tMemoryStream;
    sFilename, sPOST: String;
    Params: TIdMultipartFormDataStream;
    Clients: TList;
    i:integer;
begin
     //-- send to a remote php in json format
     // if btnSayIt.Text = '✓' then begin

       //  if Assigned(FServer.Contexts) then  begin
      //     Clients := FServer.Contexts.LockList;

     // Here the  publishList item[0] has the filename to publish.
     // This must send that file then remove it from the list.
     // If there are more items in the list then call this procedure again.
     // Since the prcedure is called with the filename to start with it is
     // possible to just remove and use the next line.
     // The 'theFile' submitted

        //  sFilename:= System.IOUtils.TPath.GetDownloadsPath;
        //  memo1.Lines.Insert(0,'Folder: '+sFilename);

      //  if publishList[0] <> theFile then  begin
        //  memo1.Lines.Insert(0,'Added to list: '+theFile);
     //   memo1.Lines.Insert(0,'Added to list: '+ publishList[0]);
       // end;

  amBusy:=1; // This stops this procedure being called by execute 'publish' with jsonstr[filename]

             {$IFDEF MSWINDOWS}
         //    sFilename:= System.IOUtils.TPath.GetDownloadsPath+
        //                 System.SysUtils.PathDelim+'Collaborart'+System.SysUtils.PathDelim+theFile;

              sFilename:= System.IOUtils.TPath.GetDownloadsPath+
                          System.SysUtils.PathDelim+'Collaborart'+System.SysUtils.PathDelim+publishList[0];
   //   sFilename:=  ' C:\Users\winst\AppData\Local\Collaborart\video2.mp4';
       //   memo1.Lines.Insert(0,'File to find: '+sFilename);


  //    if fileexists(sFilename) then begin

       // The filesize needs to be greater that 0
   i:=FileSizeByName(System.IOUtils.TPath.GetDownloadsPath+System.SysUtils.PathDelim+'Collaborart'+System.SysUtils.PathDelim+publishList[0]);
        if i  < 5000 then
          repeat
          sleep(50);
           i:=FileSizeByName(System.IOUtils.TPath.GetDownloadsPath+System.SysUtils.PathDelim+'Collaborart'+System.SysUtils.PathDelim+publishList[0]);
          until i > 5000;

      // This mother sends an empty file - get the filesize ?
      // It says bytes sent
         //  sleep(500);
          //    memo1.Lines.Insert(0,'Found file to send: '+sFilename);
         memo1.Lines.Insert(0,'Starting to transfer: '+sFilename + ' ' +i.ToString+ '  bytes' );

                  try
                   Params := TIdMultipartFormDataStream.Create;
                   Params.AddFile('my_file', sFilename,'application/octet-stream');
                  except
                  on e:exception do
                    memo1.Lines.insert(0,'Upload Params error: '+e.Message);
                 end;

              try
                sPOST := idHTTP1.Post(edtPublish.Text, Params);
                 memo1.Lines.insert(0,trim(sPOST));//+slinebreak+'At: '+ formatdatetime('ddd-mmm-yyyy-hh-mm-ss',now));

                except
                on e:exception do   // log
                 memo1.Lines.insert(0,'Error while trying to relay: '+e.Message);
               //  thisHTTP.Destroy;
              end;
  // memo1.Lines.Insert(0,'Transfer of '+sFilename+ ' done.');
             freeandnil(params);
            //

  //******* VIP                System.SysUtils.DeleteFile(sFilename);
  //  The file upload needs to be 100% finished before it gets deleted otherwise it never gets sent
  //  deleting  will send tiny files but bigger ones just vanish without being sent!

               publishList.Delete(0);
           (*
                 if publishList[0] <> ''  then begin
                   PublishFile(publishList[0]);
                    exit;
                 end;
            *)
       //  for i:=0 to publishList.count do
        //     memo1.Lines.Add('Publish List: ' +i.ToString+ '  '+ publishlist[i]);
             amBusy:=0;
            //   exit;
   //  end;

   //  if not fileexists(sFilename) then begin
   //   memo1.Lines.Insert(0,'Found no file to send: '+sFilename);
   //  end;
 {
     else

       begin

         memo1.Lines.Insert(0,'Found no file to send: '+sFilename);
         sleep(1000);
             amBusy:=0;
          // TODO !!!! - THIS MUST HAVE A COUNTER WHICH EXPIRES THE EFFORT !!
         PublishFile(theFile);
       end;

}


        {$ENDIF}

end;


procedure TForm1.SendCircles;
var
  Clients: TList;
  Json: TJsonArray;
  JsonStr: string;
  i: integer;
begin

     // NOTE that the ] IS ADEED TO THE END OF THE STRING

     while FSendCirclesThreadWorking do   begin
        if Assigned(FServer.Contexts) then  begin
          Json := TCircle.SerializeAllCircles;
          JsonStr := Json.ToJSON;

          // save a log so it can be saved for when the client wants a file from it
         try
            {$IFDEF MSWINDOWS}
           //if FileExists(format('%s\TheData.txt', [GetHomePath])) then
              begin
                json.SaveToFile( format('%s\TheData.txt', [GetHomePath]));
               end;
             {$ELSE}
          // if FileExists(format('%s/'+JsonMsg.S['filename']+'', [GetHomePath])) then
              begin
           json.SaveToFile( format('%s/TheData.txt', [GetHomePath]));
               end;
            {$ENDIF}
            except
            on e:exception do
            // not a major issue of it is not saved .. it will get done on the next round

           //   memo1.Lines.insert(0,'Error saving file: '+e.Message);

         end;


          Json.DisposeOf;

          Clients := FServer.Contexts.LockList;
          try
            for i := 0 to Clients.Count - 1 do
              if TIdContext(Clients[i]).Connection.Connected then
                    TWebSocketIOHandlerHelper(TIdContext(Clients[i]).Connection.IOHandler).WriteString(JsonStr);
            finally
            FServer.Contexts.UnlockList;
          end;
        end;

      sleep(100);
     end;



         // a custom button tag may have need to be added
         // then the file is reloaded and the
         // stringreplace can be used to append the data

         // NOTE: the client may remove the button baut that should show up in the next write
         //       also after the save it will stil be possible to edit the raw json file.
    //     if haveCustomButton=true then begin
       //     addCustomButtonToFile;
    //     end;

end;
  {
procedure TForm1.addCustomButtonToFile;
begin
             memo2.Visible:=false;
             memo2.BeginUpdate;

            // HEY REMEMBER THE COMPILER DIRECTIVES IFDEF !!!!!

             // HEY REMEMBER THE COMPILER DIRECTIVES IFDEF !!!!!

             // HEY REMEMBER THE COMPILER DIRECTIVES IFDEF !!!!!



       //   theTalbeData  has html formatted text so this will have to be stripped out
            theTalbeData:=(theTalbeData.Replace('\"', '"', [rfReplaceAll]));
            theTalbeData:=(theTalbeData.Replace('\#"', '#', [rfReplaceAll]));   //color
            theTalbeData:=(theTalbeData.Replace('\n"', '', [rfReplaceAll]));


             memo2.Lines.LoadFromFile( format('%s/TheData.txt', [GetHomePath]));

             Memo2.Text:=(Memo2.Text.Replace(']',theTalbeData , [rfReplaceAll]));
             memo2.Lines.Clear;
             memo2.EndUpdate;
             memo2.Visible:=true;
          //   haveCustomButton:=false;
end;  }

end.

