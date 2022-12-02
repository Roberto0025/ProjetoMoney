unit UnitComboCategoria;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,FireDAC.Comp.Client,
  FireDAC.DApt, Data.DB;

type
  TFormComboCategoria = class(TForm)
    Layout1: TLayout;
    Label1: TLabel;
    ImgVoltar: TImage;
    lv_categorias: TListView;
    procedure ImgVoltarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lv_categoriasItemClick(const Sender: TObject;
      const AItem: TListViewItem);
  private
    procedure ListarCategorias;
    { Private declarations }
  public
    { Public declarations }
    CategoriaSelecao: string;
    IdCategoriaSelecao: Integer;
  end;

var
  FormComboCategoria: TFormComboCategoria;

implementation

{$R *.fmx}

uses UnitPrincipal, cCategoria, UnitDM;

procedure TFormComboCategoria.ListarCategorias;
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

      FormPrincipal.AddCategoria(FormComboCategoria.lv_categorias, qry.FieldByName('ID_CATEGORIA')
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

procedure TFormComboCategoria.lv_categoriasItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  IdCategoriaSelecao := AItem.TagString.ToInteger;
  CategoriaSelecao := TListItemText(AItem.Objects.FindDrawable('txtCategoria')).Text;
  Close;
end;

procedure TFormComboCategoria.FormShow(Sender: TObject);
begin
  ListarCategorias;
end;

procedure TFormComboCategoria.ImgVoltarClick(Sender: TObject);
begin
  IdCategoriaSelecao := 0;
  CategoriaSelecao := '';
  close;
end;

end.
