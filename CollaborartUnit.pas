unit CollaborartUnit;

interface

uses
  System.SysUtils,System.IOUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.StrUtils,
  System.Threading,
  IdGlobal, IdContext,
  JsonDataObjects,
   System.JSON.Readers, System.JSON.Types, // android only --> System.Net.HttpClient,network,
  WebSocketServer, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, FMX.Edit, System.Rtti, FMX.Grid.Style, FMX.Grid;

type
  TCollaborArt = class(TForm)
    Tstr: TPanel;
    Button1: TButton;
    Button2: TButton;
    Memo1: TMemo;
    Button3: TButton;
    CheckBox1: TCheckBox;
    Edit1: TEdit;
    Label1: TLabel;
    Button4: TButton;
    Memo2: TMemo;
    Splitter1: TSplitter;
    Edit2: TEdit;
    StyleBook1: TStyleBook;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
    FServer: TWebSocketServer;
    FSendCirclesThread: ITask;
    FSendCirclesThreadWorking: boolean;
    ConnectionCount:integer;
    JsonMsg: TJsonObject;
    procedure Connect(AContext: TIdContext);
    procedure Disconnect(AContext: TIdContext);
    procedure Execute(AContext: TIdContext);
    procedure SendCircles;
  public
    { Public declarations }
     //   constructor Create;
   // destructor Destroy; override;
  end;

var
  CollaborArt: TCollaborArt;

implementation

{$R *.fmx}

procedure TCollaborArt.Button1Click(Sender: TObject);
begin

 //  jsonmsg.SaveToFile('MyCirclesJsonFile.txt');
//    Memo1.Lines.add('nothing button does nothing');
{  FSendCirclesThreadWorking := false;
  FSendCirclesThread.Wait;

  FServer.Active := false;
  FServer.DisposeOf;

         CheckBox1.IsChecked:=false;

  FServer := TWebSocketServer.Create;

  FServer.DefaultPort := 8080;
  FServer.OnExecute := Execute;
  FServer.OnConnect := Connect;
  FServer.OnDisconnect := Disconnect;

  FServer.Active := true;

  FSendCirclesThreadWorking := true;

  FSendCirclesThread := TTask.Run(SendCircles);

  ConnectionCount:=0;

  memo1.Text:='Listening on port: ' +edit1.Text+ ' for incoming requests.';
   }

end;

procedure TCollaborArt.FormCreate(Sender: TObject);
begin
       CheckBox1.IsChecked:=false;

  FServer := TWebSocketServer.Create;
  FServer.DefaultPort := 8080;
  FServer.OnExecute := Execute;
  FServer.OnConnect := Connect;
  FServer.OnDisconnect := Disconnect;
  FServer.Active := true;


  FSendCirclesThreadWorking := true;
  FSendCirclesThread := TTask.Run(SendCircles);



  ConnectionCount:=0;

 // try
    // jsonmsg.LoadFromFile('MYDemoFile.txt');
 // except
  //

  //end;
  //inherited;
end;

procedure TCollaborArt.FormDestroy(Sender: TObject);
begin
     //     jsonmsg.SaveToFile('MyCirclesJsonFile.txt');

  FSendCirclesThreadWorking := false;
  FSendCirclesThread.Wait(2000);

  FServer.Active := false;
  FServer.DisposeOf;


  inherited;
end;
procedure TCollaborArt.Button2Click(Sender: TObject);
begin
     memo1.Text:= 'Please wait while gracefully close.'+#13#10+'This could be seconds or minutes.';
    formDestroy(self);
end;

procedure TCollaborArt.Button3Click(Sender: TObject);
begin
      memo1.Text:= '';
end;

procedure TCollaborArt.Button4Click(Sender: TObject);
var
  i,j,k,ifrom,ito:integer;
   ito1,theCount:integer;
   s,s2:string;
   // place holders for the data so it can be used to construct fields to hand to the create()
   // the create process below can handle the type conversion sofor now the fields are text
   myx,myy:single;
  mywidth,myheight,myzindex, mycolor,mydodelete,mytext,myextratext:string;
   memStream:tMemoryStream;
  begin

      memstream:=tmemorystream.Create;

    if FileExists(System.IOUtils.TPath.GetDocumentsPath +
      System.SysUtils.PathDelim +edit2.text) then begin
          memstream.LoadFromFile(System.IOUtils.TPath.GetDocumentsPath +
      System.SysUtils.PathDelim +edit2.text);
          Memo1.Lines.LoadFromStream(memstream);
       freeandnil(memstream);
     end

       else begin
        freeandnil(memstream);
       exit;
     end;



         // Memo1.Lines.savetoFile(edit1.Text);
         //   Memo1.Lines.LoadFromFile('TheData.txt');

      // it would be easier and mor efficient to just parse this without
      // making a json record parser.
      // the file construct is simple
      //  it has  '{['  '}]'  markers which can be removed
      //  and '},{' which can be replaced with a #13#10
      //   This will give strings like:
      //  "id":"772093C1-6613-43C4-92AC-B4AA6B44C692","x":244,"y":146,"width":"500","height":"0","color":"","zindex":"1","doDelete":"textarea","text":"Bozo","extratext":""
      // Note the delimiter  ":"  only exists once
      //     and therefter  ": and ", are where the daa portion is
      //     but keeping mind that he fields are named
       //  "x": "y:"  "width:" "height:"  "zindex:"  "color:"  "doDelete:" "Atext:" "AExtraText:"


       // this could be a massive string which spans many lines but it'd be wiser to replace every
       // },{ with a slinebreak
           i:=0;

            Memo1.Text:=(Memo1.Text.Replace('},{', '(eol)'+slinebreak, [rfReplaceAll]));
           // the next line should maybe a copy or delete the 1st chars [{
           // replace will search the entire text
            Memo1.Text:=copy(Memo1.Text,3,length(memo1.Text));
            Memo1.Text:=(Memo1.Text.Replace('{"id":"', '', [rfReplaceAll]));
            Memo1.Text:=(Memo1.Text.Replace('"id":"', '', [rfReplaceAll]));
            Memo1.Text:=(Memo1.Text.Replace('}]', '(eol)', [rfReplaceAll]));

     //   ","x":150,"y":444,"width":"500","height":"0","zindex":"1","color":"","doDelete":"textarea","text":
           Memo1.Text:=(Memo1.Text.Replace('","x":', '', [rfReplaceAll]));   // ( is a marker
         // note - todo - maybe this would be best to have the 'header' upto text seperated from
         // the replace - this is much safer because hten any other text
         // in the html data wouldnt  slip through the cracks
          Memo1.Text:=(Memo1.Text.Replace('"y":', '', [rfReplaceAll]));
          Memo1.Text:=(Memo1.Text.Replace(',"width":"',   ',', [rfReplaceAll]));
          Memo1.Text:=(Memo1.Text.Replace('","height":"',  ',', [rfReplaceAll]));
          Memo1.Text:=(Memo1.Text.Replace('","zindex":"',  ',', [rfReplaceAll]));
          Memo1.Text:=(Memo1.Text.Replace('","color":"',    ',', [rfReplaceAll]));
          Memo1.Text:=(Memo1.Text.Replace('","doDelete":"', ',', [rfReplaceAll]));
          Memo1.Text:=(Memo1.Text.Replace('","text":"', ',', [rfReplaceAll]));

          // handle the last segment it will just be blank and there
          // will be a discrepency if extraext is there ie it has data in the field
          Memo1.Text:=(Memo1.Text.Replace('","extratext":"', ' wq,wq', [rfReplaceAll]));
          Memo1.Text:=(Memo1.Text.Replace(' wq,wq"', ',', [rfReplaceAll]));



         // next is to strip off the id part - always 37 chars long
         //  pos out the id - its not wanted
            for i:=  0 to Memo1.Lines.Count -1 do begin
            memo1.Lines[i] :=memo1.Lines[i]+slinebreak ; // needs that to coult the records
           end;

           for i:=  0 to Memo1.Lines.Count -1 do begin
            memo1.Lines[i] :=copy( memo1.Lines[i], 37, length( memo1.Lines[i]))+slinebreak ;
           end;

         // this must retain the amount of iterations to make
        //   theCount:=i;
      //       showmessage('theCount: '+i.ToString);
           //  the lines will now look like this:
         //   150,444,500,0,1,,textarea,80m8, (eol)
         // this means that the csv looking text needs to be read into seperate
         // fields to they can be used to make the object


          // now the objective is to get each comma deliited line of the memo into
          // seperate fields so the can be used to make the circle
          // For each iteration (line) the following must happen
          //  1 read the string in memo.lines[?]
          //  2 pos copy everything into their right field place
          //  3 use the data to make the circle

             for i:=  0 to Memo1.Lines.Count -1 do begin //downto 0 do begin

                try
                      j:=pos(',',memo1.Lines[i],1);
                      myx:=  Copy( memo1.Lines[i],0,j-1).ToSingle ;
                      s:=   Copy( memo1.Lines[i],j+1,length(memo1.Lines[i]));
                      memo2.lines.add('x: '+ myx.ToString );// + ' j: '+j.ToString +'  s: '+s);

                 // maybe here a marker can block this comme ain the next rearch
                     // it does not mateer if the data pto there is not right anymore -
                     //it must be exclued  from the pos searches
                        s:=s;//force s to refresh
                        j:=pos(',',s,1);    // new start point
                        myy:=  Copy(s,0,j-1).ToSingle  ;    // set the var
                        // note this time its before the memo update
                        s:=   Copy( s,j +1,length(memo1.Lines[i]));
                        memo2.lines.add('y: '+ myy.ToString  );//+ ' --> j: '+j.ToString +'   ---> s: '+s );


         //mywidth,myheight,myzindex,mycolor,mydodelete,mytext,myextratext:string;
                        s:=s;//force s to refresh
                            //  ---> s: 500,0,1,,textarea,oiu,(eol)
                          j:=pos(',', s , 1 );    // new start point
                          mywidth:=  Copy(s,0 , j-1);
                          s:=   Copy( s,  j+1 , length(s));
                          memo2.lines.add('w: '+ mywidth );//+ ' j: '+j.ToString +' ----> s: '+s );


         //myheight,myzindex,mycolor,mydodelete,mytext,myextratext:string;
                        s:=s;//force s to refresh
                         j:=pos(',', s , 1 );    // new start point
                         myheight:=  Copy(s,0,j-1);
                         s:=   Copy( s,j+1 ,length(s));
                         memo2.lines.add('h: '+ myheight );//+ '  s: '+s );



         //myzindex,mycolor,mydodelete,mytext,myextratext:string;
                        s:=s;//force s to refresh
                        j:=pos(',',s,1);    // new start point
                        myzindex:=  Copy(s,0,j-1)  ;
                        s:=   Copy( s,j+1 ,length(s));
                        memo2.lines.add('z: '+ myzindex);//+ '  s: '+s );

        //mycolor,mydodelete,mytext,myextratext:string;
                        s:=s;//force s to refresh
                        j:=pos(',',s,1);    // new start point
                        mycolor:=  Copy( s,0,j-1) ;
                        s:=   Copy( s,j+1 ,length(s));
                       memo2.lines.add('c: '+ mycolor );//+ '  s: '+s );

         //mydodelete,mytext,myextratext:string;
                        s:=s;//force s to refresh
                        j:=pos(',',s,1);    // new start point
                        mydodelete:=  Copy(s,0,j-1) ;
                        s:=   Copy( s,j+1 ,length(s));
                       memo2.lines.add('d: '+ mydodelete);//+ '  s: '+s );


         //mytext,myextratext:string;
                        s:=s;//force s to refresh
                        j:=pos(',',s,1);    // new start point
                        mytext:=  Copy(s,0,j-1) ;
                        s:=   Copy( s,j +1 ,length(s));
                       memo2.lines.add('t: '+ mytext);//+ '  s: '+s );

         //myextratext:string;
                        s:=s;//force s to refresh
                        j:=pos(',',s,1);    // new start point
                        myextratext:=  Copy(s,0,j-1) ;
                        s:=   Copy( s,j +1 ,length(s));
                       memo2.lines.add('et: '+ myextratext);//+ '  s: '+s );

                 // NOW THE  CREATE PROCEDURE CAN BE CALLED   !


                     except
                     on e:exception do
                   memo1.Lines.Add('Error in creating from reding file : '+e.Message);
                end;
                TCircle.Create(myx, myy, mywidth, myheight, myzindex ,  mycolor,
                                  mydodelete ,  mytext,  myextratext);
            end;

            memo1.Text:='';
            memo2.Text:='';
end;



procedure TCollaborArt.Connect(AContext: TIdContext);
begin
   CheckBox1.IsChecked:=true;
   inc(ConnectionCount);
 // Memo1.textmemo1.Lines.Add('Clients connected: '+ ConnectionCount.ToString );
end;

procedure TCollaborArt.Disconnect(AContext: TIdContext);
begin


   dec(ConnectionCount);
  // something needs to check if ther are any more connections!!!!!!!!!!
 ///  TODO - - FIRST GET THE COUNT
  if ConnectionCount = 0 then
      CheckBox1.IsChecked:=false;

 // Memo1.text :=('Clients connected: ' + ConnectionCount.ToString);
end;

procedure TCollaborArt.Execute(AContext: TIdContext);
var
  io: TWebSocketIOHandlerHelper;
  msg: string;
 // JsonMsg: TJsonObject;
  Json: TJsonArray;
  s,s1:string;

  Clients: TList;
 // ClientsP:pointer;
  //aCircle:TCircle;
  //  Clients: TList;
  JsonUpdate: TJsonArray;
  JsonStr: string;
 // JsonItem: PJsonDataValue;
  i,j,historyNumber:integer;
 x1,y1:single;
   memstream: TMemoryStream;
   Bytes: TArray<byte>;
   aBuf: TIdBytes;
   const sx:single = 0;
   const sy:single = 0;

begin
  io := TWebSocketIOHandlerHelper(AContext.Connection.IOHandler);
  io.CheckForDataOnSource(10);

  msg := io.ReadString;
  if msg = '' then
    exit;

  try
    JsonMsg := TJsonObject(TJsonObject.Parse(msg));
  except
    JsonMsg := nil;
  end;

  if JsonMsg = nil then
    exit;

     if JsonMsg.S['act'] = 'create' then   begin
         // this created by the web page to be a the message notification popout
         // Its made when the page loads

         // The connecting client can be uniquely identified by their
         // ip address. This is to stop popouts from showing.
         // So if its a local machine ei. user on 1 machine with multiple displays then the ip
         // is used to suppress the popout from showing.
         // If its not the same as the local machine then the messages are displayed
         // now there is a place holder required for this in the json item[x]

         s1:= AContext.Binding.PeerIP ;//          FServer.Bindings.Count.ToString;


          // s1 will need to be altered into somethingthats not an ipaddress
          // it does not arrive on the other end
           // while Pos('0', S1) > 0 do
           //   S1[Pos('0', S1)] := 'Z';
          //   memo1.Lines.Add('Incoming from: ' +s1 + ' --> '+ JsonMsg.S['extratext']);

          //set s to blank
          s:='';
           if (JsonMsg.S['doDelete'] = 'notifyblock') and (JsonMsg.S['text'] = 'wqx1b4') then  begin  // every other time

                TCircle.Create(JsonMsg.F['x'], JsonMsg.F['y'] ,
                       JsonMsg.S['width'] , JsonMsg.S['height'], JsonMsg.S['zindex'] ,// always zero
                       JsonMsg.S['color'] , JsonMsg.S['doDelete'] ,
            { JsonMsg.S['text']--->} 'Changes were made. Click ''Update View'' to get the servers copy!',JsonMsg.S['extratext']);//+s1+'wx']);
            //  memo1.Lines.Add('1 Notify : doDelete: ' +JsonMsg.S['doDelete']+ ' zindex: '+ JsonMsg.F['zindex'].ToString );

          {  memo1.Lines.Add('notify textarea :' + JsonMsg.S['text']+#13#10+
                                'zindex :' + JsonMsg.F['zindex'].ToString  +#13#10+
                                'width :' + JsonMsg.F['width'].ToString  +#13#10+
                                 'height :' + JsonMsg.F['height'].ToString    );
                 }
           end

             else

             // here two things canhappen - the person clicked on the 'Text' button but there
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

           { memo1.Lines.Add('empty textarea :' + JsonMsg.S['text']+#13#10+
                                'zindex :' + JsonMsg.S['zindex'] +#13#10+
                                'width :' + JsonMsg.S['width']  +#13#10+
                                'height :' + JsonMsg.S['height']   );
                          }
                      // 'Click me first then enter text in the text area at the bottom of the menu on the left of the screen.<br>Click and drag to new location.');
           end
              else
           if (JsonMsg.S['doDelete']  = 'textarea') and (JsonMsg.S['text'] <> s) then begin
                   TCircle.Create(JsonMsg.F['x'], JsonMsg.F['y'] ,
                       JsonMsg.S['width'] , JsonMsg.S['height'],  JsonMsg.S['zindex'] ,
                       JsonMsg.S['color'] , JsonMsg.S['doDelete'] ,
                         JsonMsg.S['text'],JsonMsg.S['extratext'] );


         {   memo1.Lines.Add('custom textarea :' + JsonMsg.S['text']+#13#10+
                                'zindex :' + JsonMsg.S['zindex'] +#13#10+
                                'width :' + JsonMsg.S['width'] +#13#10+
                                'height :' + JsonMsg.S['height'] );   }
           end;



       // this is made
           if JsonMsg.S['doDelete'] = 'circle' then begin
                TCircle.Create(JsonMsg.F['x'], JsonMsg.F['y'] ,
                       JsonMsg.S['width'] , JsonMsg.S['height'], JsonMsg.S['zindex'] ,
                       JsonMsg.S['color'] , JsonMsg.S['doDelete'] ,
                       JsonMsg.S['text'],JsonMsg.S['extratext']);
                      { memo1.text:=('create : '+ JsonMsg.F['x'].ToString +'  : '+ JsonMsg.F['y'].ToString + '  : '+
                              JsonMsg.F['width'].ToString +'  : '+ JsonMsg.F['height'].ToString+  '  : '+
                              JsonMsg.S['color'] +'  : '+ JsonMsg.S['doDelete'] +  '  : '+
                              JsonMsg.S['text'] );  }
              {    memo1.Lines.Add('4 circle :' + JsonMsg.S['text']+#13#10+
                                'zindex :' + JsonMsg.S['zindex']);}
           end;
    end;


  if JsonMsg.S['act'] = 'move' then begin
            // first extract the x and y from the text
           // JsonMsg.S['text']  will have the x,y
           // i:=pos('x', JsonMsg.S['text'],1);

          // x1:= copy(JsonMsg.S['text'],0,i).ToSingle;
         //  y1:= trim(copy(JsonMsg.S['text'],i, 4)).ToSingle;
      //  memo1.text:=('Move  : '+ x1.ToString + ' , '+y1.ToString);
       // sx:= s.ToSingle(s);
        //   s1.ToSingle(s1);
        //  showmessage('s and s1 are: '+s +' s1: '+s1);
     TCircle.Move(JsonMsg.S['id'], JsonMsg.F['x'], JsonMsg.F['y']);
     //FSendCirclesThread := TTask.Run(SendCircles);

  end;


  if JsonMsg.S['act'] = 'changecolor' then begin
    TCircle.ChangeColorForCircle(JsonMsg.S['id']);
   //log   memo1.Lines.Add('Color requested: '+ JsonMsg.S['id']);
  end;

  if JsonMsg.S['act'] = 'newcolor' then begin  //NewColor(ID:string; Acolor:string);
    //memo1.text:=('Color requested: '+ JsonMsg.S['theColor'] + ' for: '+ JsonMsg.S['id']);
    TCircle.NewColor(JsonMsg.S['id'],JsonMsg.S['theColor'] );
   //log

  end;

  if JsonMsg.S['act'] = 'destroy' then   begin
         TCircle.DestroyCircle(JsonMsg.S['id']);

        // memo1.Lines.Add(s);
  end;

      if JsonMsg.S['act'] = 'changetext' then begin
      // this resets the color circle to white to let the text be a  text block with no circle
 //             changetext(const Id, theText, color :string; width, height: single)
   TCircle.changetext(JsonMsg.S['id'],JsonMsg.S['text'],JsonMsg.S['color'], JsonMsg.S['width'] , JsonMsg.S['height'], JsonMsg.S['zindex']);

    {  memo1.Lines.Add('5 CHANGE TEXT :'+JsonMsg.S['id']+#13#10 +
                                'color :' + JsonMsg.S['text']+#13#10+
                                'color :' + JsonMsg.S['color']+#13#10+
                                'width :' + JsonMsg.S['width']+#13#10+
                                'height :' + JsonMsg.S['height'] +#13#10+
                                'zindex :' + JsonMsg.S['zindex'] ); }
    end;

          memstream:=tMemoryStream.Create;
    if JsonMsg.S['act'] = 'save' then begin
        try
         memo1.Lines.Add('Saving: '+ JsonMsg.S['id']);
          edit2.Text:= JsonMsg.S['id'];

          memstream.LoadFromFile('TheData.txt');
          memstream.SaveToFile(System.IOUtils.TPath.GetDocumentsPath +
                               System.SysUtils.PathDelim +JsonMsg.S['id']) ;
        freeandnil(memstream);
         except
           on e:exception do begin
             memo1.Lines.Add('File Save Error: '+ e.Message);
             freeandnil(memstream);
            exit;
           end;
      end;
  end;
      {   memStream:tMemoryStream;
  begin

      memstream:=tmemorystream.Create;

    if FileExists(System.IOUtils.TPath.GetDocumentsPath +
      System.SysUtils.PathDelim +edit2.text) then begin
          memstream.LoadFromFile(edit2.text);
          Memo1.Lines.LoadFromStream(memstream);
       freeandnil(memstream);
     end

       else begin
        freeandnil(memstream);
       exit;
     end;}




     if JsonMsg.S['act'] = 'delete' then begin
        memo1.Lines.Add('Deleting :'+JsonMsg.S['id']);

          if FileExists(System.IOUtils.TPath.GetDocumentsPath +
             System.SysUtils.PathDelim +JsonMsg.S['id']) then
              begin
                deletefile(System.IOUtils.TPath.GetDocumentsPath +
             System.SysUtils.PathDelim +JsonMsg.S['id']);
                end;

    end;

      if JsonMsg.S['act'] = 'ListFiles' then begin
        memo1.Lines.Add('Listing files');

      // this is gonna be very tricky - its best to do this on
      // startup and somehow get the list stored
      // this request could maybe uset guid of the notify circle
      // to update it by moving it and then
      // using the extratext field to transmit the file list.
      // therefore a unique file extension is required for this file type
      // or else a snag will happen when listing all the files


         // if FileExists(System.IOUtils.TPath.GetDocumentsPath +
          //   System.SysUtils.PathDelim +JsonMsg.S['id']) then
           //   begin
           //     deletefile(JsonMsg.S['id']);
            //    end;
    end;


    // ACTUALLY LOAD UP A FILE AND ... REDRAW

    if JsonMsg.S['act'] = 'redraw' then begin
        // here the filename is handed froe the web page to this action
        // edit2 gets this and button4.click is done.
        // Note todo: button 4 stuff must go into seperate procedure
        // Then calling the proc will cause the buttons to redraw

         if trim(JsonMsg.S['id']) <> ''then  begin
            edit2.Text:= JsonMsg.S['id'];
               button4.OnClick(self);
         end;
    end;

   // jsonmsg.SaveToFile('MYDemoFile.txt');

  JsonMsg.DisposeOf;

end;

procedure TCollaborArt.SendCircles;
var
  Clients: TList;
  Json: TJsonArray;
  JsonStr: string;
  i: integer;
begin

  while FSendCirclesThreadWorking do   begin

    if Assigned(FServer.Contexts) then     begin

      Json := TCircle.SerializeAllCircles;
      JsonStr := Json.ToJSON;

      json.SaveToFile('TheData.txt');
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
end;

end.

