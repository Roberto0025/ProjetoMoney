unit UnitCategoriasCad;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListBox, FMX.Edit,
  FireDAC.Comp.Client, FireDAC.DApt, FMX.DialogService;

type
  TFormCategoriasCad = class(TForm)
    Layout1: TLayout;
    lbl_titulo: TLabel;
    ImgVoltar: TImage;
    ImgSave: TImage;
    Layout2: TLayout;
    Descrição: TLabel;
    Edit_Descricao: TEdit;
    Line1: TLine;
    Label1: TLabel;
    lb_icones: TListBox;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    ListBoxItem4: TListBoxItem;
    ListBoxItem5: TListBoxItem;
    ListBoxItem6: TListBoxItem;
    ListBoxItem7: TListBoxItem;
    ListBoxItem8: TListBoxItem;
    ListBoxItem9: TListBoxItem;
    ListBoxItem10: TListBoxItem;
    ListBoxItem11: TListBoxItem;
    ListBoxItem12: TListBoxItem;
    ListBoxItem13: TListBoxItem;
    ListBoxItem14: TListBoxItem;
    ListBoxItem15: TListBoxItem;
    ListBoxItem16: TListBoxItem;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Image9: TImage;
    Image10: TImage;
    Image11: TImage;
    Image12: TImage;
    Image13: TImage;
    Image14: TImage;
    Image15: TImage;
    Image16: TImage;
    img_selecao: TRectangle;
    rect_delete: TRectangle;
    ImgDelete: TImage;
    procedure ImgVoltarClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ImgSaveClick(Sender: TObject);
    procedure ImgDeleteClick(Sender: TObject);
  private
    icone_selecionado: TBitmap;
    indice_selecionado: Integer;
    procedure SelecionaIcone(img: TImage);
    { Private declarations }
  public
    { Public declarations }
    modo: string; // I = inclussao ou A = Alteração
    id_cat: Integer;
  end;

var
  FormCategoriasCad: TFormCategoriasCad;

implementation

{$R *.fmx}

uses UnitPrincipal, cCategoria, UnitDM, UnitCategorias;

procedure TFormCategoriasCad.SelecionaIcone(img: TImage);
begin
  icone_selecionado := img.Bitmap; // salva o icone selecionado

  indice_selecionado := TListBoxItem(img.Parent).Index;
  img_selecao.Parent := img.Parent;
end;

procedure TFormCategoriasCad.FormResize(Sender: TObject);
begin
  lb_icones.Columns := Trunc(lb_icones.Width / 80);
end;

procedure TFormCategoriasCad.FormShow(Sender: TObject);
var
  cat: TCategoria;
  qry: TFDQuery;
  erro: string;
  item: TListBoxItem;
  img: TImage;
begin
  if modo = 'I' then
  begin
    rect_delete.Visible := false;
    Edit_Descricao.Text := '';
    SelecionaIcone(Image1);
  end
  else
  begin
    try
      rect_delete.Visible := true;
      cat := TCategoria.Create(dm.Conn); // instancia a categoria
      cat.ID_CATEGORIA := id_cat; // passa o id da categoria

      qry := cat.ListarCategoria(erro);
      // select na base e tras a categoria do id

      Edit_Descricao.Text := qry.FieldByName('DESCRICAO').AsString;
      // tras a descrição

      // icone
      item := lb_icones.ItemByIndex(qry.FieldByName('INDICE_ICONE').AsInteger);
      img_selecao.Parent := item;

      img := FormCategoriasCad.FindComponent('Image' + (item.Index + 1).ToString) as TImage;
      SelecionaIcone(img);
    finally
      qry.DisposeOf;
      cat.DisposeOf;
    end;
  end;
end;

procedure TFormCategoriasCad.Image1Click(Sender: TObject);
begin
  SelecionaIcone(TImage(Sender));
end;

// ao clicar em delete...
procedure TFormCategoriasCad.ImgDeleteClick(Sender: TObject);
var
  cat: TCategoria;
  erro: string;
begin
  TDialogService.MessageDialog('Confimar exclussão da categoria?',
    TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
    TMsgDlgBtn.mbNo, 0,
    procedure(const AResult: TModalResult)
    var
      erro: string;
    begin
      if AResult = mrYes then
      begin
        try
          cat := TCategoria.Create(dm.Conn);
          cat.ID_CATEGORIA := id_cat;

          // if NOT cat.Excluir(erro) then >>>mesma coisa abaixo
          if cat.Excluir(erro) = false then
          begin
            ShowMessage(erro);
            Exit;
          end;

          FormCategorias.ListarCategorias;
          Close;

        finally
          cat.DisposeOf;
        end;
      end;
    end);
end;

procedure TFormCategoriasCad.ImgSaveClick(Sender: TObject);
var
  cat: TCategoria;
  erro: string;
begin
  try
    cat := TCategoria.Create(dm.Conn);
    cat.DESCRICAO := Edit_Descricao.Text;
    cat.ICONE := icone_selecionado;
    cat.INDICE_ICONE := indice_selecionado;

    if modo = 'I' then
      cat.Inserir(erro)
    else
    begin
      cat.ID_CATEGORIA := id_cat;
      cat.Alterar(erro);
    end;

    if erro <> '' then
    begin
      ShowMessage(erro);
      Exit;
    end;

    FormCategorias.ListarCategorias;
    Close;

  finally
    cat.DisposeOf;
  end;
end;

procedure TFormCategoriasCad.ImgVoltarClick(Sender: TObject);
begin
  Close;
end;

end.
