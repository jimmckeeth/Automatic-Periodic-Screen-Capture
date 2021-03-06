unit apscMain;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
	System.Classes, Vcl.Graphics,
	Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
	System.ImageList, Vcl.ImgList, Vcl.Mask, RzEdit, RzSpnEdt, RzButton,
	RzRadChk, RzPanel, RzLstBox, RzLabel, RzBtnEdt, RzCommon,
  Vcl.BaseImageCollection, Vcl.ImageCollection, Vcl.VirtualImageList,
  System.Actions, Vcl.ActnList, RzShellDialogs, Vcl.AppEvnts, Vcl.ComCtrls;

type
	TForm15 = class(TForm)
    ListBox1: TRzListBox;
    Panel1: TRzPanel;
    Timer1: TTimer;
    RzButton1: TRzButton;
    RzSpinEdit1: TRzSpinEdit;
    RzLabel1: TRzLabel;
		RzButtonEdit1: TRzButtonEdit;
    Label1: TLabel;
    RzPanel1: TRzPanel;
    VirtualImageList1: TVirtualImageList;
    ImageCollection1: TImageCollection;
    RzSelectFolderDialog1: TRzSelectFolderDialog;
    RzPanel2: TRzPanel;
    RzPanel3: TRzPanel;
    ApplicationEvents1: TApplicationEvents;
    lblBackGropIntro: TLabel;
    Image1: TImage;
    chkOnlyChanges: TCheckBox;
    procedure ListBox1Click(Sender: TObject);
		procedure RzButton1Click(Sender: TObject);
		procedure RzSpinEdit1Change(Sender: TObject);
		procedure Timer1Timer(Sender: TObject);
    procedure RzButtonEdit1ButtonClick(Sender: TObject);
		procedure FormCreate(Sender: TObject);
    procedure ApplicationEvents1Minimize(Sender: TObject);
    procedure ApplicationEvents1Restore(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
	private
		{ Private declarations }
    FLastBitmap : TBitmap;
		procedure Capture;
    procedure Clear;
    procedure SavePnG(vBmp: TBitmap; vWhen: TDateTime);
	public
		{ Public declarations }
	end;

var
	Form15: TForm15;

implementation

{$R *.dfm}

uses System.IOUtils, Vcl.Imaging.pngimage, System.DateUtils;

//https://stackoverflow.com/questions/1352312/what-is-the-fastest-way-to-check-if-two-tbitmaps-are-the-same
function IsSameBitmap(Bitmap1, Bitmap2: TBitmap): Boolean;
var
 Stream1, Stream2: TMemoryStream;
begin
//  Assert((Bitmap1 <> nil) and (Bitmap2 <> nil), 'Params can''t be nil');
  Result:= False;
  if (Bitmap1 = nil) or (Bitmap2 = nil) then
    Exit;
  if (Bitmap1.Height <> Bitmap2.Height) or (Bitmap1.Width <> Bitmap2.Width) then
     Exit;
  Stream1:= TMemoryStream.Create;
  try
    Bitmap1.SaveToStream(Stream1);
    Stream2:= TMemoryStream.Create;
    try
      Bitmap2.SaveToStream(Stream2);
      if Stream1.Size = Stream2.Size Then
        Result:= CompareMem(Stream1.Memory, Stream2.Memory, Stream1.Size);
    finally
      Stream2.Free;
    end;
  finally
    Stream1.Free;
  end;
end;

function ScreenShot: TBitmap;
begin
	Result := TBitmap.Create;
	try
		var
		c := TCanvas.Create;
		c.Handle := GetWindowDC(GetDesktopWindow);
		try
			var
			r := Rect(0, 0, Screen.Width, Screen.Height);
			Result.Width := Screen.Width;
			Result.Height := Screen.Height;
			Result.Canvas.CopyRect(r, c, r);
		finally
			ReleaseDC(0, c.Handle);
			c.Free;
		end;
	except
		Result.Free;
		Raise;
	end;
end;

procedure TForm15.ApplicationEvents1Minimize(Sender: TObject);
begin
  FLastBitmap:=nil;
	Timer1.Enabled := True;
end;

procedure TForm15.ApplicationEvents1Restore(Sender: TObject);
begin
  Timer1.Enabled := False;
  FLastBitmap:=nil;
end;

procedure TForm15.Capture;
begin
	var oldWidth := Self.Width;
	var oldHeight := Self.Height;
	try
		if Visible and (Self.WindowState <> wsMinimized) then
		begin
			Self.BorderStyle := bsNone;
			Self.Width := 0;
			Self.Height := 0;
		end;
		var bmp := ScreenShot;
		var when := Now;
		ListBox1.Items.AddObject(TimeToStr(when), bmp);

		Image1.Picture.Bitmap.Assign(bmp);
    if chkOnlyChanges.Checked then
    begin
      if IsSameBitmap(bmp,FLastBitmap) then
        SavePnG(bmp,when);
    end
    else
      SavePnG(bmp,when);

    FLastBitmap:=bmp;

	finally
		if Visible and (Self.WindowState <> wsMinimized) then
		begin
			Self.BorderStyle := bsSizeable;
			Width := oldWidth;
			Height := oldHeight;
		end;
	end;
end;

procedure TForm15.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Clear;
end;

procedure TForm15.FormCreate(Sender: TObject);
begin
  Image1.Picture.Bitmap.Assign(nil);
	RzSelectFolderDialog1.SelectedFolder.PathName := TPath.GetPicturesPath;
	RzButtonEdit1.Text := TPath.GetPicturesPath;
	VirtualImageList1.GetBitmap(
		VirtualImageList1.GetIndexByName('folder'),
		RzButtonEdit1.ButtonGlyph);
	var png  := TPngImage.Create;
	try
    var theImageFolder :=ExtractFilePath(Application.ExeName)+'..\..\..\icons\black\folder_96px.png';
		png.LoadFromFile(theImageFolder);
		RzButtonEdit1.ButtonGlyph.Assign(nil);
		//RzButtonEdit1.ButtonGlyph.Assign(png);
		RzButtonEdit1.ButtonGlyph.SetSize(16,16);
		RzButtonEdit1.ButtonGlyph.Canvas.StretchDraw(Rect(0,0,16,16),png);
		invalidate;
	finally
		png.Free;
	end;
end;

procedure TForm15.Clear;
begin
  FLastBitmap:=nil;
	ListBox1.Items.BeginUpdate;
	try
		for var idx := 0 to pred(ListBox1.Items.Count) do
		begin
			ListBox1.Items.Objects[idx].Free;
			ListBox1.Items.Objects[idx] := nil;
		end;
	finally
		ListBox1.Clear;
		ListBox1.Items.EndUpdate;
		Image1.Picture.Bitmap.Assign(nil);
		Repaint;
	end;
end;

procedure TForm15.ListBox1Click(Sender: TObject);
begin
	if (ListBox1.ItemIndex > -1) and (ListBox1.ItemIndex < ListBox1.Items.Count) then
		Image1.Picture.Bitmap.Assign(ListBox1.Items.Objects[ListBox1.ItemIndex] as TBitmap);
end;

procedure TForm15.RzButton1Click(Sender: TObject);
begin
	Capture;
end;

procedure TForm15.RzButtonEdit1ButtonClick(Sender: TObject);
begin
	if RzSelectFolderDialog1.Execute then
	begin
		RzButtonEdit1.Text := RzSelectFolderDialog1.SelectedFolder.PathName;
	end;
end;

procedure TForm15.RzSpinEdit1Change(Sender: TObject);
begin
  Timer1.Interval := RzSpinEdit1.IntValue * 1000;
end;

procedure TForm15.SavePnG(vBmp: TBitmap; vWhen: TDateTime);
begin
  var png := TPngImage.Create;
  try
    png.Assign(vbmp);

    var fileName :=  Format('%.4d-%s.png',
      [ListBox1.Items.Count,
       FormatDateTime('hhmmss',vwhen)]);
    png.SaveToFile(TPath.Combine(RzButtonEdit1.Text, filename));
  finally
    png.Free;
  end;
end;

procedure TForm15.Timer1Timer(Sender: TObject);
begin
	Timer1.Enabled := False;
	try
		capture;
	finally
		Timer1.Enabled := True;
		Timer1.Interval := RzSpinEdit1.IntValue * 1000;
	end;
end;

end.
