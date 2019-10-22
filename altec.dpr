program altec;

uses
  Vcl.Forms,
  Main in 'Main.pas' {fCadCliente},
  Rules in 'Rules.pas' {dmRules: TDataModule},
  ViaCEP in 'ViaCEP.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfCadCliente, fCadCliente);
  Application.CreateForm(TdmRules, dmRules);
  Application.Run;
end.
