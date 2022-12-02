unit UnitLancamentos;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FireDAC.Comp.Client, FireDAC.DApt, Data.DB, DateUtils;

type
  TFormLancamento = class(TForm)
    Layout1: TLayout;
    Label1: TLabel;
    ImgVoltar: TImage;
    Layout2: TLayout;
    img_anterior: TImage;
    img_proximo: TImage;
    Rectangle1: TRectangle;
    lbl_mes: TLabel;
    Rectangle2: TRectangle;
    Layout3: TLayout;
    Label5: TLabel;
    lbl_receita: TLabel;
    lbl_despesas: TLabel;
    Label6: TLabel;
    lbl_saldo: TLabel;
    Label8: TLabel;
    ImgAdd: TImage;
    lv_lancamento: TListView;
    img_resumo: TImage;
    procedure ImgVoltarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lv_lancamentoUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
    procedure lv_lancamentoItemClick(const Sender: TObject; const AItem: TListViewItem);
    procedure ImgAddClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure img_anteriorClick(Sender: TObject);
    procedure img_proximoClick(Sender: TObject);
    procedure img_resumoClick(Sender: TObject);
  private
    dt_filtro : TDate;
    procedure AbrirLancamento(id_lancamento: string);
    procedure ListarLancamentos;
    procedure NavegarMes(num_mes: integer);
    function NomeMes: string;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormLancamento: TFormLancamento;

implementation

{$R *.fmx}

uses UnitPrincipal, UnitLancamentosCad, cLancamento, UnitDM, UnitLancResumo;

procedure TFormLancamento.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Action := TCloseAction.caFree;
  // FormLancamento := nil;    //Estamos destruindo no close do frmprincipal
end;

function TFormLancamento.NomeMes() : string;
begin
  case MonthOf(dt_filtro) of
    1 : Result := 'Janeiro';
    2 : Result := 'Fevereiro';
    3 : Result := 'Março';
    4 : Result := 'Abril';
    5 : Result := 'Maio';
    6 : Result := 'Junho';
    7 : Result := 'Julho';
    8 : Result := 'Agosto';
    9 : Result := 'Setembro';
    10 : Result := 'Outubro';
    11 : Result := 'Novembro';
    12 : Result := 'Dezembro';
  end;
  Result := Result + ' / ' + yearOf(dt_filtro).ToString;
end;

procedure TFormLancamento.ListarLancamentos;
var
  lanc: TLancamento;
  qry: TFDQuery;
  erro: string;
  x: integer;
  foto: TStream;
  vlr_rec, vlr_desp: double;
begin
  try
    FormLancamento.lv_lancamento.Items.Clear;
    vlr_rec := 0;
    vlr_desp := 0;

    lanc := TLancamento.Create(dm.conn);
    lanc.DATA_DE := FormatDateTime('YYYY-MM-DD', StartOfTheMonth(dt_filtro));
    lanc.DATA_ATE := FormatDateTime('YYYY-MM-DD', EndOfTheMonth(dt_filtro));
    qry := lanc.ListarLancamento(0, erro);

    if erro <> '' then
    begin
      ShowMessage(erro);
      Exit;
    end;

    while NOT qry.Eof do
    begin
      if qry.FieldByName('ICONE').AsString <> '' then
        foto := qry.CreateBlobStream(qry.FieldByName('ICONE'),
          TBlobStreamMode.bmRead)
      else
        foto := nil;

      FormPrincipal.AddLancamento(FormLancamento.lv_lancamento,
        qry.FieldByName('ID_LANCAMENTO').AsString,
        qry.FieldByName('DESCRICAO').AsString,
        qry.FieldByName('DESCRICAO_CATEGORIA').AsString,
        qry.FieldByName('VALOR').AsFloat,
        qry.FieldByName('DATA').AsDateTime,
        foto);

      if qry.FieldByName('VALOR').AsFloat > 0 then
        vlr_rec := vlr_rec + qry.FieldByName('VALOR').AsFloat
      else
        vlr_desp := vlr_desp + qry.FieldByName('VALOR').AsFloat;

      qry.Next;
      foto.DisposeOf;
    end;

    lbl_receita.Text := FormatFloat('#,##0.00', vlr_rec);
    lbl_despesas.Text := FormatFloat('#,##0.00', vlr_desp);
    lbl_saldo.Text := FormatFloat('#,##0.00', vlr_rec + vlr_desp); //soma posi + neg

  finally
    lanc.DisposeOf;
  end;
end;

procedure TFormLancamento.NavegarMes(num_mes: integer);
begin
  dt_filtro := IncMonth(dt_filtro, num_mes);
  lbl_mes.Text := NomeMes;
  ListarLancamentos;
end;

procedure TFormLancamento.FormShow(Sender: TObject);
begin
  dt_filtro := Date;
  NavegarMes(0);
end;

procedure TFormLancamento.ImgAddClick(Sender: TObject);
begin
  AbrirLancamento('');
end;

procedure TFormLancamento.ImgVoltarClick(Sender: TObject);
begin
  Close;
end;

procedure TFormLancamento.img_anteriorClick(Sender: TObject);
begin
  NavegarMes(-1);
end;

procedure TFormLancamento.img_proximoClick(Sender: TObject);
begin
  NavegarMes(1);
end;

procedure TFormLancamento.img_resumoClick(Sender: TObject);
begin
  if not Assigned(FormLancResumo) then
    Application.CreateForm(TFormLancResumo, FormLancResumo);

    FormLancResumo.lbl_mes.Text := FormLancamento.lbl_mes.Text;
    FormLancResumo.dt_filtro := FormLancamento.dt_filtro;
    FormLancResumo.Show;
end;

procedure TFormLancamento.AbrirLancamento(id_lancamento: string);
begin
  if NOT Assigned(FormLancamentosCad) then
    Application.CreateForm(TFormLancamentosCad, FormLancamentosCad);

  if id_lancamento <> '' then
  begin
    FormLancamentosCad.modo := 'A';
    FormLancamentosCad.id_lancamento := id_lancamento.ToInteger();
  end
  else
  begin
    FormLancamentosCad.modo := 'I';
    FormLancamentosCad.id_lancamento := 0;
  end;

  FormLancamentosCad.ShowModal(procedure(ModalResult: TModalResult)
  begin
    ListarLancamentos;
  end)
end;

procedure TFormLancamento.lv_lancamentoItemClick(const Sender: TObject; const AItem: TListViewItem);
begin
  AbrirLancamento(AItem.TagString);
end;

procedure TFormLancamento.lv_lancamentoUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
begin
  FormPrincipal.SetupLancamento(FormLancamento.lv_lancamento, AItem);
end;

end.
