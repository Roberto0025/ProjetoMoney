program Money;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnitLogin in 'UnitLogin.pas' {FormLogin},
  u99Permissions in 'Units\u99Permissions.pas',
  UnitPrincipal in 'UnitPrincipal.pas' {FormPrincipal},
  UnitLancamentos in 'UnitLancamentos.pas' {FormLancamento},
  UnitLancamentosCad in 'UnitLancamentosCad.pas' {FormLancamentosCad},
  UnitCategorias in 'UnitCategorias.pas' {FormCategorias},
  UnitCategoriasCad in 'UnitCategoriasCad.pas' {FormCategoriasCad},
  UnitDM in 'UnitDM.pas' {dm: TDataModule},
  cCategoria in 'Classes\cCategoria.pas',
  cLancamento in 'Classes\cLancamento.pas',
  uFormat in 'Units\uFormat.pas',
  UnitComboCategoria in 'UnitComboCategoria.pas' {FormComboCategoria},
  cUsuario in 'Classes\cUsuario.pas',
  UnitLancResumo in 'UnitLancResumo.pas' {FormLancResumo};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormLogin, FormLogin);
  Application.CreateForm(Tdm, dm);
  Application.CreateForm(TFormComboCategoria, FormComboCategoria);
  Application.CreateForm(TFormLancResumo, FormLancResumo);
  Application.Run;
end.
