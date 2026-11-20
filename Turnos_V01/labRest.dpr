program labRest;

uses
  Forms,
  uLabRest in 'uLabRest.pas' {frmLabRest};

begin
  Application.Initialize;
  Application.Title := 'SageLab - Terminal liviana';
  Application.CreateForm(TfrmLabRest, frmLabRest);
  Application.Run;
end.
