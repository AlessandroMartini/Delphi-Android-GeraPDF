program GeraPDF;

uses
  System.StartUpCopy,
  FMX.Forms,
  GeradorPDF in 'GeradorPDF.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
