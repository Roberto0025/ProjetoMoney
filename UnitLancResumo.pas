unit UnitLancResumo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FireDAC.DApt, FireDAC.Comp.Client, Data.DB, cLancamento;

type
  TFormLancResumo = class(TForm)
    Layout1: TLayout;
    Label1: TLabel;
    ImgVoltar: TImage;
    Layout2: TLayout;
    Rectangle1: TRectangle;
    lbl_mes: TLabel;
    lv_resumo: TListView;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure ImgVoltarClick(Sender: TObject);
  private
    procedure MontarResumo;
    procedure AddCategoria(ListView: TListView; categoria: string; valor: double; foto: TStream);
    { Private declarations }
  public
    dt_filtro : TDate;
    { Public declarations }
  end;

var
  FormLancResumo: TFormLancResumo;

implementation

{$R *.fmx}

uses UnitPrincipal, UnitDM, System.DateUtils;

procedure TFormLancResumo.AddCategoria(ListView: TListView; categoria: string; valor: double; foto: TStream);
var
  txt: TListItemText;
  img: TListItemImage;
  bmp: TBitmap;
begin
  with ListView.Items.Add do
  begin

    txt := TListItemText(Objects.FindDrawable('txtCategoria'));
    txt.Text := categoria;

    txt := TListItemText(Objects.FindDrawable('txtValor'));
    txt.Text := FormatFloat('#,##0.00', valor);

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

procedure TFormLancResumo.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  FormLancResumo := nil;
end;

procedure TFormLancResumo.FormShow(Sender: TObject);
begin
  MontarResumo;
end;

procedure TFormLancResumo.ImgVoltarClick(Sender: TObject);
begin
  Close;
end;

procedure TFormLancResumo.MontarResumo;
var
  lanc: TLancamento;
  qry: TFDQuery;
  erro: string;
  icone: TStream;
begin
  try
    lv_resumo.items.Clear;

    lanc := TLancamento.Create(dm.Conn);
    lanc.DATA_DE := FormatDateTime('YYYY-MM-DD', StartOfTheMonth(dt_filtro));
    lanc.DATA_ATE := FormatDateTime('YYYY-MM-DD', EndOfTheMonth(dt_filtro));
    qry := lanc.ListarResumo(erro);

    while NOT qry.Eof do
    begin
      // Icone
      if qry.FieldByName('ICONE').AsString <> '' then
        icone := qry.CreateBlobStream(qry.FieldByName('ICONE'),
          TBlobStreamMode.bmRead)
      else
        icone := nil;

      FormLancResumo.AddCategoria(lv_resumo, qry.FieldByName('DESCRICAO').AsString,
      qry.FieldByName('VALOR').AsCurrency, icone);

      if icone <> nil then
        icone.DisposeOf;

      qry.Next;
    end;

  finally
    qry.DisposeOf;
    lanc.DisposeOf;
  end;
end;

end.
