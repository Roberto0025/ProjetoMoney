unit UnitCategorias;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FireDAC.Comp.Client, FireDAC.DApt, Data.DB;

type
  TFormCategorias = class(TForm)
    Layout1: TLayout;
    Label1: TLabel;
    ImgVoltar: TImage;
    Rectangle2: TRectangle;
    Layout3: TLayout;
    Label7: TLabel;
    ImgAdd: TImage;
    lv_categorias: TListView;
    procedure ImgVoltarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure lv_categoriasUpdateObjects(const Sender: TObject;
      const AItem: TListViewItem);
    procedure ImgAddClick(Sender: TObject);
    procedure lv_categoriasItemClick(const Sender: TObject;
      const AItem: TListViewItem);
  private
    procedure CadCategoria(id_cat: string);
    { Private declarations }
  public
    { Public declarations }
    procedure ListarCategorias;
  end;

var
  FormCategorias: TFormCategorias;

implementation

{$R *.fmx}

uses UnitPrincipal, UnitCategoriasCad, cCategoria, UnitDM;

//carrega todas as categorias no list view
procedure TFormCategorias.ListarCategorias;
var
  cat: TCategoria;
  qry: TFDQuery;
  erro: string;
  icone: TStream;
begin
  try
    lv_categorias.items.Clear;

    cat := TCategoria.Create(dm.Conn);
    qry := cat.ListarCategoria(erro);

    while NOT qry.Eof do
    begin
      // Icone
      if qry.FieldByName('ICONE').AsString <> '' then
        icone := qry.CreateBlobStream(qry.FieldByName('ICONE'),
          TBlobStreamMode.bmRead)
      else
        icone := nil;

      FormPrincipal.AddCategoria(lv_categorias, qry.FieldByName('ID_CATEGORIA')
        .AsString, qry.FieldByName('DESCRICAO').AsString, icone);

      if icone <> nil then
        icone.DisposeOf;

      qry.Next;
    end;

  finally
    qry.DisposeOf;
    cat.DisposeOf;
  end;
end;

//responsavel por inserir ou alterar a categoria
procedure TFormCategorias.CadCategoria(id_cat: string);
begin
  if NOT Assigned(FormCategoriasCad) then
    Application.CreateForm(TFormCategoriasCad, FormCategoriasCad);

  //Inclussão
  if id_cat = '' then
  begin
    FormCategoriasCad.id_cat := 0;
    FormCategoriasCad.modo := 'I';
    FormCategoriasCad.lbl_titulo.text := 'Nova Categoria'
  end
  else
  //Alteração
  begin
    FormCategoriasCad.id_cat := id_cat.ToInteger();
    FormCategoriasCad.modo := 'A';
    FormCategoriasCad.lbl_titulo.text := 'Editar Categoria';
  end;
  //exibe o formulario
  FormCategoriasCad.Show;
end;


procedure TFormCategorias.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  FormCategorias := nil;
end;

procedure TFormCategorias.FormShow(Sender: TObject);
{ var
  foto: TStream;
  x: integer; }
begin
  { foto := TMemoryStream.Create;
    FormPrincipal.imgCategoria.Bitmap.SaveToStream(foto);
    foto.Position := 0;

    for x := 1 to 10 do
    FormPrincipal.AddCategoria(lv_categorias, '0001', 'Transporte', foto);
    foto.DisposeOf; }

  ListarCategorias;
end;

//caso queira inserir o id vai vazio
procedure TFormCategorias.ImgAddClick(Sender: TObject);
begin
  CadCategoria('');
end;

procedure TFormCategorias.ImgVoltarClick(Sender: TObject);
begin
  Close;
end;

//clicando el alguma categoria abre a edicação passando o id
procedure TFormCategorias.lv_categoriasItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  CadCategoria(AItem.TagString);
end;

procedure TFormCategorias.lv_categoriasUpdateObjects(const Sender: TObject;
  const AItem: TListViewItem);
begin
  FormPrincipal.SetupCategoria(lv_categorias, AItem);
end;

end.
