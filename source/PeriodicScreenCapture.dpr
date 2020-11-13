program PeriodicScreenCapture;

uses
  Vcl.Forms,
  apscMain in 'apscMain.pas' {Form15};

{$R *.res}

begin
	Application.Initialize;
	ReportMemoryLeaksOnShutdown := True;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm15, Form15);
  Application.Run;
end.
