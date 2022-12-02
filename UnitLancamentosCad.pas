unit UnitLancamentosCad;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Edit,
  FMX.DateTimeCtrls, FMX.ListBox, FireDAC.Comp.Client, FireDAC.DApt, uFormat,
  FMX.DialogService;

  {$IFDEF AUTOREFCOUNT}
  type
    TIntegerWrapper = class
    public
      value: Integer;
      constructor Create(AVlaue: Integer);
  end;
  {$ENDIF}

type
  TFormLancamentosCad = class(TForm)
    Layout1: TLayout;
    Label1: TLabel;
    ImgVoltar: TImage;
    ImgSave: TImage;
    Layout2: TLayout;
    Descrição: TLabel;
    edit_descricao: TEdit;
    Line1: TLine;
    Layout3: TLayout;
    edit_valor: TEdit;
    Line2: TLine;
    Layout4: TLayout;
    Label3: TLabel;
    Layout5: TLayout;
    Label4: TLabel;
    dt_lancamento: TDateEdit;
    Rect_hoje: TRectangle;
    Label5: TLabel;
    RectOntem: TRectangle;
    Label6: TLabel;
    rect_delete: TRectangle;
    ImgDelete: TImage;
    img_receita: TImage;
    Label2: TLabel;
    img_tipo_lancamento: TImage;
    img_despesa: TImage;
    lbl_categoria: TLabel;
    Line3: TLine;
    Image1: TImage;
    procedure ImgVoltarClick(Sender: TObject);
    procedure img_tipo_lancamentoClick(Sender: TObject);
    procedure Rect_hojeClick(Sender: TObject);
    procedure RectOntemClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ImgSaveClick(Sender: TObject);
    procedure edit_valorTyping(Sender: TObject);
    procedure lbl_categoriaClick(Sender: TObject);
    procedure ImgDeleteClick(Sender: TObject);
  private
    //procedure comboCategoria;
    { Private declarations }
  public
    { Public declarations }
    modo: string; // I = inclussao ou A = Alteração
    id_lancamento: Integer;
  end;

var
  FormLancamentosCad: TFormLancamentosCad;

implementation

{$R *.fmx}

uses UnitPrincipal, cCategoria, UnitDM, cLancamento, UnitComboCategoria;

{$IFDEF AUTOREFCOUNT}
constructor TIntegerWrapper.Create(AValue: Intger);
begin
  inherited Create;
  Value := AValue;
end;
{$ENDIF}

{
procedure TFormLancamentosCad.comboCategoria;
var
  cat : TCategoria;
  erro : string;
  qry : TFDQuery;
begin
  try
    cmb_categoria.Items.Clear;

    cat := TCategoria.Create(dm.conn);
    qry := cat.ListarCategoria(erro);

    if erro <> '' then
    begin
      ShowMessage(erro);
      Exit;
    end;

    while NOT qry.Eof do
    begin
      //cmb_categoria.Items.AddObject(qry.FieldByName('DESCRICAO').AsString, TObject(qry.FieldByName('ID_CATEGORIA').AsInteger));

      cmb_categoria.Items.AddObject(qry.FieldByName('DESCRICAO').AsString,
        {$IFDEF AUTOREFCOUNT}
{          TIntegerWrapper.Create(qry.FieldByName('ID_CATEGORIA').AsInteger)
        {$ELSE}
{          TObject(qry.FieldByName('ID_CATEGORIA').AsInteger)
        {$ENDIF}//);

{      qry.Next;
    end;

  finally
    qry.DisposeOf;
    cat.DisposeOf;
  end;
end;
}

procedure TFormLancamentosCad.edit_valorTyping(Sender: TObject);
begin
  Formatar(edit_valor, TFormato.Valor);
end;

procedure TFormLancamentosCad.FormShow(Sender: TObject);
var
  lanc : TLancamento;
  qry : TFDQuery;
  erro : string;
begin
//  comboCategoria;

  if modo = 'I' then
  begin
    edit_descricao.Text := '';
    dt_lancamento.Date := Date;
    edit_valor.Text := '';
    img_tipo_lancamento.Bitmap := img_despesa.Bitmap;
    img_tipo_lancamento.Tag := -1;
    rect_delete.Visible := false;
    lbl_categoria.Text := '';
    lbl_categoria.Tag := 0;
  end
  else
  begin
    try
      lanc := TLancamento.Create(dm.conn);
      lanc.ID_LANCAMENTO := id_lancamento;
      qry := lanc.ListarLancamento(0, erro);

      if qry.RecordCount = 0 then
      begin
        ShowMessage('Lançamento não encontrado.');
        Exit;
      end;

    edit_descricao.Text := qry.FieldByName('DESCRICAO').AsString;
    dt_lancamento.Date := qry.FieldByName('DATA').AsDateTime;

    if qry.FieldByName('VALOR').AsFloat < 0 then
    begin
    edit_valor.Text := FormatFloat('#,##0.00', qry.FieldByName('VALOR').AsFloat);
    img_tipo_lancamento.Bitmap := img_despesa.Bitmap;
    img_tipo_lancamento.Tag := -1;
    end
    else
    begin
    edit_valor.Text := FormatFloat('#,##0.00', qry.FieldByName('VALOR').AsFloat);
    img_tipo_lancamento.Bitmap := img_receita.Bitmap;
    img_tipo_lancamento.Tag := 1;
    end;
    // trás ao combo a descricação da categoria salva no lançamento
    // cmb_categoria.ItemIndex := cmb_categoria.Items.IndexOf(qry.FieldByName('DESCRICAO_CATEGORIA').AsString);
    lbl_categoria.Text := qry.FieldByName('DESCRICAO_CATEGORIA').AsString;
    lbl_categoria.Tag := qry.FieldByName('ID_CATEGORIA').AsInteger;
    rect_delete.Visible := true;

    finally
      qry.DisposeOf;
      lanc.DisposeOf;
    end;
  end;

end;

function TrataValor(str: string): double;
begin
// não consegue converter . e , para número float
// Result := StrToFloat(str);
  str := StringReplace(str, '.', '', [rfReplaceAll]);
  str := StringReplace(str, ',', '', [rfReplaceAll]);

  try
    Result := StrToFloat(str) / 100;
  except
    Result := 0;
  end;
end;

procedure TFormLancamentosCad.ImgDeleteClick(Sender: TObject);
var
  lanc: TLancamento;
  erro: string;
begin
  TDialogService.MessageDialog('Confimar exclussão do lançamento?',
    TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
    TMsgDlgBtn.mbNo, 0,
    procedure(const AResult: TModalResult)
    var
      erro: string;
    begin
      if AResult = mrYes then
      begin
        try
          lanc := TLancamento.Create(dm.Conn);
          lanc.ID_LANCAMENTO := id_lancamento;

          if lanc.Excluir(erro) = false then
          begin
            ShowMessage(erro);
            Exit;
          end;

          Close;

        finally
          lanc.DisposeOf;
        end;
      end;
    end);
end;

procedure TFormLancamentosCad.ImgSaveClick(Sender: TObject);
var
  lanc : TLancamento;
  erro : string;
begin
  try
    lanc := TLancamento.Create(dm.Conn);
    lanc.DESCRICAO := edit_descricao.Text;
    lanc.VALOR := TrataValor(edit_valor.Text) * img_tipo_lancamento.Tag;

    {$IFDEF AUTOREFCOUNT}
    //lanc.ID_CATEGORIA := integer(cmb_categoria.Items.Objects[cmb_categoria.ItemIndex]);
    {$ELSE}
    //lanc.DATA := Integer(cmb_categoria.Items.Objects[cmb_categoria.ItemIndex]);
    {$ENDIF}

    lanc.ID_CATEGORIA := lbl_categoria.Tag;
    lanc.DATA := dt_lancamento.Date;

  if modo = 'I' then
    lanc.Inserir(erro)
  else
  begin
    lanc.ID_LANCAMENTO := id_lancamento;
    lanc.Alterar(erro)
  end;

  if erro <> '' then
  begin
    ShowMessage(erro);
    Exit;
  end;

  Close;

  finally
    lanc.DisposeOf;
  end;
//  comboCategoria;
end;

procedure TFormLancamentosCad.ImgVoltarClick(Sender: TObject);
begin
  close;
end;

procedure TFormLancamentosCad.img_tipo_lancamentoClick(Sender: TObject);
begin
  if img_tipo_lancamento.Tag = 1 then //receita
  begin
    img_tipo_lancamento.Bitmap := img_despesa.Bitmap;
    img_tipo_lancamento.Tag := -1;
  end
  else //inverte para despesa
  begin
    img_tipo_lancamento.Bitmap := img_receita.Bitmap;
    img_tipo_lancamento.Tag := 1;
  end;
end;

procedure TFormLancamentosCad.lbl_categoriaClick(Sender: TObject);
begin
  // Abre litagem categoria
  if NOT Assigned(FormComboCategoria) then
    Application.CreateForm(TFormComboCategoria, FormComboCategoria);

  FormComboCategoria.ShowModal(procedure(ModalResul: TModalResult)
  begin
    if FormComboCategoria.IdCategoriaSelecao > 0 then
    begin
      lbl_categoria.Text := FormComboCategoria.CategoriaSelecao;
      lbl_categoria.Tag := FormComboCategoria.IdCategoriaSelecao;
    end;
  end);

end;

procedure TFormLancamentosCad.RectOntemClick(Sender: TObject);
begin
  dt_lancamento.Date := Date - 1;
end;

procedure TFormLancamentosCad.Rect_hojeClick(Sender: TObject);
begin
  dt_lancamento.Date := Date;
end;

end.
