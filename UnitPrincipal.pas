unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.Ani, FireDAC.Comp.Client, FireDAC.DApt, Data.DB;

type
  TFormPrincipal = class(TForm)
    Layout1: TLayout;
    ImageMenu: TImage;
    C_icone: TCircle;
    Image1: TImage;
    Label1: TLabel;
    Layout2: TLayout;
    Label3: TLabel;
    lbl_saldo: TLabel;
    Layout3: TLayout;
    Layout4: TLayout;
    Layout5: TLayout;
    Layout6: TLayout;
    Image2: TImage;
    lbl_receitas: TLabel;
    Label5: TLabel;
    Layout7: TLayout;
    Image3: TImage;
    lbl_despesas: TLabel;
    Label7: TLabel;
    Layout8: TLayout;
    Rectangle1: TRectangle;
    img_add: TImage;
    Rectangle2: TRectangle;
    Layout9: TLayout;
    Label8: TLabel;
    lblTodos: TLabel;
    lv_lancamento: TListView;
    imgCategoria: TImage;
    StyleBook1: TStyleBook;
    LayoutPrincipal: TLayout;
    rect_menu: TRectangle;
    AnimationMenu: TFloatAnimation;
    img_fechar_menu: TImage;
    Layout_menu_cat: TLayout;
    Label9: TLabel;
    Layout_menu_logout: TLayout;
    Label10: TLabel;
    procedure FormShow(Sender: TObject);
    procedure lv_lancamentoUpdateObjects(const Sender: TObject;
      const AItem: TListViewItem);
    procedure lblTodosClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ImageMenuClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure AnimationMenuFinish(Sender: TObject);
    procedure AnimationMenuProcess(Sender: TObject);
    procedure img_fechar_menuClick(Sender: TObject);
    procedure Layout_menu_catClick(Sender: TObject);
    procedure img_addClick(Sender: TObject);
    procedure lv_lancamentoItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure Layout_menu_logoutClick(Sender: TObject);
  private
    procedure ListarUltLanc;
    procedure MontarPainel;
    procedure CarregaIcone;
    { Private declarations }
  public
    procedure SetupLancamento(lv: TListView; Item: TListViewItem);
    procedure AddLancamento(ListView: TListView;
      id_lancamento, descricao, categoria: string; valor: double; dt: TDateTime;
      foto: TStream);
    procedure AddCategoria(ListView: TListView; id_categoria, categoria: string;
      foto: TStream);
    procedure SetupCategoria(lv: TListView; Item: TListViewItem);
    { Public declarations }
  end;

var
  FormPrincipal: TFormPrincipal;

implementation

{$R *.fmx}

uses UnitLancamentos, UnitCategorias, cLancamento, UnitDM, UnitLancamentosCad,
  cUsuario, UnitLogin, System.DateUtils;

// UNIT FUNÇÕES GLOBAIS
procedure TFormPrincipal.CarregaIcone;
var
  u : TUsuario;
  qry : TFDQuery;
  erro : string;
  foto : TStream;
begin
  try
    u := TUsuario.Create(dm.Conn);
    qry := u.ListarUsuario(erro);

    if qry.FieldByName('FOTO').AsString <> '' then
      foto := qry.CreateBlobStream(qry.FieldByName('FOTO'), TBlobStreamMode.bmRead)
    else
      foto := nil;

    if foto <> nil then
    begin
      C_icone.Fill.Bitmap.Bitmap.LoadFromStream(foto);
      foto.DisposeOf;
    end;

  finally
    u.DisposeOf;;
    qry.DisposeOf;
  end;
end;

procedure TFormPrincipal.MontarPainel;
var
  lanc : TLancamento;
  qry : TFDQuery;
  erro : string;

  vlr_rec, vlr_desp : Double;
begin
  try
    lanc := TLancamento.Create(dm.Conn);
    lanc.DATA_DE := FormatDateTime('YYYY-MM-DD', StartOfTheMonth(date));
    lanc.DATA_ATE := FormatDateTime('YYYY-MM-DD', EndOfTheMonth(date));
    qry := lanc.ListarLancamento(0, erro);

    if erro <> '' then
    begin
      ShowMessage(erro);
      Exit;
    end;

    while NOT qry.Eof do
    begin
if qry.FieldByName('VALOR').AsFloat > 0 then
        vlr_rec := vlr_rec + qry.FieldByName('VALOR').AsFloat
      else
        vlr_desp := vlr_desp + qry.FieldByName('VALOR').AsFloat;
      qry.Next;
    end;

    lbl_receitas.Text := FormatFloat('#,##0.00', vlr_rec);
    lbl_despesas.Text := FormatFloat('#,##0.00', vlr_desp);
    lbl_saldo.Text := FormatFloat('#,##0.00', vlr_rec + vlr_desp); //soma posi + neg

  finally
    lanc.DisposeOf;
    qry.DisposeOf;
  end;
end;

procedure TFormPrincipal.AddLancamento(ListView: TListView; id_lancamento, descricao, categoria: string; valor: double; dt: TDateTime; foto: TStream);
var
  txt: TListItemText;
  img: TListItemImage;
  bmp: TBitmap;
begin
  with ListView.Items.Add do
  begin
    TagString := id_lancamento;
    txt := TListItemText(Objects.FindDrawable('txtDescricao'));
    txt.Text := descricao;

    TListItemText(Objects.FindDrawable('txtCategoria')).Text := categoria;
    TListItemText(Objects.FindDrawable('txtValor')).Text := FormatFloat('#,##0.00', valor);
    TListItemText(Objects.FindDrawable('txtData')).Text := FormatDateTime('dd/mm', dt);

    // icone...
    img := TListItemImage(Objects.FindDrawable('imgIcone'));

    if foto <> nil then
    begin
      bmp := TBitmap.Create;
      bmp.LoadFromStream(foto);

      img.OwnsBitmap := true;
      img.Bitmap := bmp;
    end;

  end;
end;

// Inverte a animação do menu
procedure TFormPrincipal.AnimationMenuFinish(Sender: TObject);
begin
  LayoutPrincipal.Enabled := AnimationMenu.Inverse;
  AnimationMenu.Inverse := NOT AnimationMenu.Inverse;
end;

procedure TFormPrincipal.AnimationMenuProcess(Sender: TObject);
begin
  LayoutPrincipal.Margins.Right := -260 - rect_menu.Margins.Left;
end;

procedure TFormPrincipal.SetupLancamento(lv: TListView; Item: TListViewItem);
var
  txt: TListItemText;
begin
  txt := TListItemText(Item.Objects.FindDrawable('txtDescricao'));
  txt.Width := lv.Width - txt.PlaceOffset.x - 100;
end;

procedure TFormPrincipal.AddCategoria(ListView: TListView; id_categoria, categoria: string; foto: TStream);
var
  txt: TListItemText;
  img: TListItemImage;
  bmp: TBitmap;
begin
  with ListView.Items.Add do
  begin
    TagString := id_categoria;

    txt := TListItemText(Objects.FindDrawable('txtCategoria'));
    txt.Text := categoria;

    // icone...
    img := TListItemImage(Objects.FindDrawable('imgIcone'));

    if foto <> nil then
    begin
      bmp := TBitmap.Create;
      bmp.LoadFromStream(foto);

      img.OwnsBitmap := true;
      img.Bitmap := bmp;
    end;

  end;
end;

procedure TFormPrincipal.SetupCategoria(lv: TListView; Item: TListViewItem);
var
  txt: TListItemText;
begin
  txt := TListItemText(Item.Objects.FindDrawable('txtCategoria'));
  txt.Width := lv.Width - txt.PlaceOffset.x - 20;
end;

procedure TFormPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FormLancamento) then
  begin
    FormLancamento.DisposeOf;
    FormLancamento := nil;
  end;
  Action := TCloseAction.caFree;
  FormPrincipal := nil;
end;

procedure TFormPrincipal.FormCreate(Sender: TObject);
begin
  rect_menu.Margins.Left := -260;
  rect_menu.Align := TAlignLayout.Left;
  rect_menu.Visible := true;
end;

procedure TFormPrincipal.ListarUltLanc;
var
  lanc: TLancamento;
  qry: TFDQuery;
  erro: string;
  x: integer;
  foto: TStream;
begin
  try
    FormPrincipal.lv_lancamento.Items.Clear;
    lanc := TLancamento.Create(dm.conn);
    qry := lanc.ListarLancamento(10, erro);

    if erro <> '' then
    begin
      ShowMessage(erro);
      Exit;
    end;

    while NOT qry.Eof do
    begin
      if qry.FieldByName('ICONE').AsString <> '' then
        foto := qry.CreateBlobStream(qry.FieldByName('ICONE'), TBlobStreamMode.bmRead)
      else
        foto := nil;

      AddLancamento(FormPrincipal.lv_lancamento,
        qry.FieldByName('ID_LANCAMENTO').AsString,
        qry.FieldByName('DESCRICAO').AsString,
        qry.FieldByName('DESCRICAO_CATEGORIA').AsString,
        qry.FieldByName('VALOR').AsFloat,
        qry.FieldByName('DATA').AsDateTime,
        foto);

      qry.Next;
      foto.DisposeOf;
    end;

  finally
    lanc.DisposeOf;
  end;

  MontarPainel;
end;

procedure TFormPrincipal.FormShow(Sender: TObject);
begin
  ListarUltLanc;
  CarregaIcone;
end;

procedure TFormPrincipal.ImageMenuClick(Sender: TObject);
begin
  AnimationMenu.Start;

  { if NOT Assigned(FormCategorias) then
    Application.CreateForm(TFormCategorias, FormCategorias);

    FormCategorias.Show; }
end;

procedure TFormPrincipal.img_addClick(Sender: TObject);
begin
  if NOT Assigned(FormLancamentosCad) then
    Application.CreateForm(TFormLancamentosCad, FormLancamentosCad);

  FormLancamentosCad.modo := 'I';
  FormLancamentosCad.id_lancamento := 0;
  FormLancamentosCad.ShowModal(procedure(ModalResulta: TModalResult)
  begin
    ListarUltLanc;
  end);
end;

procedure TFormPrincipal.img_fechar_menuClick(Sender: TObject);
begin
  AnimationMenu.Start;
end;

procedure TFormPrincipal.Layout_menu_catClick(Sender: TObject);
begin
  AnimationMenu.Start;

  if NOT Assigned(FormCategorias) then
    Application.CreateForm(TFormCategorias, FormCategorias);

  FormCategorias.Show;
end;

procedure TFormPrincipal.Layout_menu_logoutClick(Sender: TObject);
var
  u : TUsuario;
  erro : string;
begin
  try
    u := TUsuario.Create(dm.Conn);
    if NOT u.Logout(erro) then
    begin
      ShowMessage(erro);
      Exit;
    end;
  finally
    u.DisposeOf;
  end;
 if NOT Assigned(FormLogin) then
   Application.CreateForm(TFormLogin, FormLogin);

  Application.MainForm := FormLogin;
  FormLogin.Show;
  FormPrincipal.Close;
end;

// fecha o menu, verifica se formulario está criado ou não e exibe ele
procedure TFormPrincipal.lblTodosClick(Sender: TObject);
begin
  if NOT Assigned(FormLancamento) then
    Application.CreateForm(TFormLancamento, FormLancamento);

  FormLancamento.Show;
end;

procedure TFormPrincipal.lv_lancamentoItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  if NOT Assigned(FormLancamentosCad) then
    Application.CreateForm(TFormLancamentosCad, FormLancamentosCad);

  FormLancamentosCad.modo := 'A';
  FormLancamentosCad.id_lancamento := AItem.TagString.ToInteger;

  FormLancamentosCad.ShowModal(procedure(ModalResult: TModalResult)
  begin
    ListarUltLanc;
  end);
end;

procedure TFormPrincipal.lv_lancamentoUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
begin
  SetupLancamento(FormPrincipal.lv_lancamento, AItem);
end;

end.
