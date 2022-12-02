unit UnitLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.Edit, FMX.Objects, FMX.Layouts, FMX.Ani,
  FMX.StdCtrls, FMX.TabControl, System.Actions, FMX.ActnList,
  FMX.MediaLibrary.Actions, FMX.StdActns, FireDAC.Comp.Client, FireDAC.DApt,
  // uses utiizados
  u99Permissions, FMX.VirtualKeyboard, FMX.Platform;

type
  TFormLogin = class(TForm)
    Layout1: TLayout;
    imgLogin: TImage;
    Layout2: TLayout;
    RoundRect1: TRoundRect;
    EditLoginEmail: TEdit;
    StyleBook1: TStyleBook;
    Layout3: TLayout;
    RoundRect2: TRoundRect;
    EditLoginSenha: TEdit;
    PasswordEditButton1: TPasswordEditButton;
    TabControl1: TTabControl;
    TabLogin: TTabItem;
    TabCriarConta: TTabItem;
    Layout5: TLayout;
    Image1: TImage;
    Layout6: TLayout;
    RoundRect4: TRoundRect;
    EditCadNome: TEdit;
    Layout7: TLayout;
    RoundRect5: TRoundRect;
    EditCadSenha: TEdit;
    PasswordEditButton2: TPasswordEditButton;
    Layout8: TLayout;
    RectContaProximo: TRoundRect;
    Label2: TLabel;
    Layout9: TLayout;
    RoundRect7: TRoundRect;
    EditCadEmail: TEdit;
    TabFoto: TTabItem;
    Layout10: TLayout;
    CFotoEditar: TCircle;
    Layout11: TLayout;
    RectConta: TRoundRect;
    Label3: TLabel;
    TabEscolha: TTabItem;
    Layout12: TLayout;
    Label4: TLabel;
    Image2: TImage;
    Image3: TImage;
    LImgFoto: TLayout;
    LImgLibrary: TLayout;
    Layout15: TLayout;
    Label5: TLabel;
    Label6: TLabel;
    Layout16: TLayout;
    Layout4: TLayout;
    RectLogin: TRoundRect;
    Label1: TLabel;
    Layout17: TLayout;
    ImgFoto: TImage;
    Layout18: TLayout;
    Image5: TImage;
    Layout19: TLayout;
    Layout20: TLayout;
    lblLogin: TLabel;
    lblCriarConta: TLabel;
    Rectangle1: TRectangle;
    ActionList1: TActionList;
    ActConta: TChangeTabAction;
    ActEscolha: TChangeTabAction;
    ActFoto: TChangeTabAction;
    ActLogin: TChangeTabAction;
    Layout21: TLayout;
    Layout22: TLayout;
    lblContaLogin: TLabel;
    Label8: TLabel;
    Rectangle2: TRectangle;
    ActLibrary: TTakePhotoFromLibraryAction;
    ActCamera: TTakePhotoFromCameraAction;
    Timer1: TTimer;
    procedure lblCriarContaClick(Sender: TObject);
    procedure lblContaLoginClick(Sender: TObject);
    procedure ImgFotoClick(Sender: TObject);
    procedure RectContaProximoClick(Sender: TObject);
    procedure CFotoEditarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LImgFotoClick(Sender: TObject);
    procedure LImgLibraryClick(Sender: TObject);
    procedure Image5Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ActLibraryDidFinishTaking(Image: TBitmap);
    procedure ActCameraDidFinishTaking(Image: TBitmap);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure RectLoginClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure RectContaClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormVirtualKeyboardShown(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardHidden(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
  private
    { Private declarations }
    permissao: T99Permissions;
    procedure TrataErroPermissao(Sender: TObject);
  public
    { Public declarations }
  end;

var
  FormLogin: TFormLogin;

implementation

{$R *.fmx}

uses UnitPrincipal, UnitDM, cUsuario;

procedure TFormLogin.ActCameraDidFinishTaking(Image: TBitmap);
begin
  CFotoEditar.Fill.Bitmap.Bitmap := Image;
  ActFoto.Execute;
end;

procedure TFormLogin.ActLibraryDidFinishTaking(Image: TBitmap);
begin
  CFotoEditar.Fill.Bitmap.Bitmap := Image;
  ActFoto.Execute;
end;

procedure TFormLogin.CFotoEditarClick(Sender: TObject);
begin
  ActEscolha.Execute;
end;

procedure TFormLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  FormLogin := nil;
end;

procedure TFormLogin.FormCreate(Sender: TObject);
begin
  permissao := T99Permissions.Create;
end;

procedure TFormLogin.FormDestroy(Sender: TObject);
begin
  permissao.DisposeOf;
end;

procedure TFormLogin.FormKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
{$IFDEF ANDROID}
var
  FService: IFMXVirtualKeyboardService;
{$ENDIF}
begin
{$IFDEF ANDROID}
  if (Key = vkHardwareBack) then
  begin
    TPlatformSerices.Current.SupportsPlatformService(IFMXVirtualKeyboardService,
      IInterface(FService));
    if (FService <> nill) and (TVirtualKeyboardState.Visible
      in FService.TVirtualKeyboardState) then
    begin
      // Botao back precionado e teclado virtual
      // apenas fecha o teclado
    end
    else
    begin
      // Boatao back precionato e teclado nao visivel
      // Key := 0;
      if TabControl1.ActiveTab = TabCriarConta then
      begin
        Key := 0;
        ActLogin.Execute;
      end
      else if TabControl1.ActiveTab = TabFoto then
      begin
        Key := 0;
        ActConta.Execute;
      end
      else if TabControl1.ActiveTab = TabEscolha then
      begin
        Key := 0;
        ActFoto.Execute;
      end;
    end;
  end;
{$ENDIF}
end;

procedure TFormLogin.FormShow(Sender: TObject);
begin
  TabControl1.ActiveTab := TabLogin;
  // Timer1.Enabled := False;
end;

procedure TFormLogin.FormVirtualKeyboardHidden(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
  TabControl1.Margins.Bottom := 0;
end;

procedure TFormLogin.FormVirtualKeyboardShown(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
  TabControl1.Margins.Bottom := 140;
end;

procedure TFormLogin.Image5Click(Sender: TObject);
begin
  ActFoto.Execute;
end;

procedure TFormLogin.ImgFotoClick(Sender: TObject);
begin
  ActConta.Execute;
end;

procedure TFormLogin.lblContaLoginClick(Sender: TObject);
begin
  ActLogin.Execute;
end;

procedure TFormLogin.lblCriarContaClick(Sender: TObject);
begin
  ActConta.Execute;
end;

procedure TFormLogin.Timer1Timer(Sender: TObject);
var
  u : TUsuario;
  erro : string;
  qry : TFDQuery;
begin
//  Timer1.Enabled := False;

  TabControl1.ActiveTab := TabLogin;

  try
    u := TUsuario.Create(dm.Conn);
    qry := TFDQuery.Create(nil);

    qry := u.ListarUsuario(erro);

    if qry.FieldByName('IND_LOGIN').AsString <> 'S' then
      Exit;
  finally
    qry.DisposeOf;
    u.DisposeOf;
  end;

  if NOT Assigned(FormPrincipal) then
    Application.CreateForm(TFormPrincipal, FormPrincipal);

  Application.MainForm := FormPrincipal;
  FormPrincipal.Show;
  FormLogin.Close;
end;

procedure TFormLogin.TrataErroPermissao(Sender: TObject);
begin
  ShowMessage('Você não tem permissão para acesso ao recurso!');
end;

procedure TFormLogin.LImgFotoClick(Sender: TObject);
begin
  permissao.Camera(ActCamera, TrataErroPermissao);
end;

procedure TFormLogin.LImgLibraryClick(Sender: TObject);
begin
  permissao.PhotoLibrary(ActLibrary, TrataErroPermissao)
end;

procedure TFormLogin.RectContaClick(Sender: TObject);
var
  u : TUsuario;
  erro : string;
begin
  try
    u := TUsuario.Create(dm.Conn);
    u.NOME := EditCadNome.Text;
    u.EMAIL := EditCadEmail.Text;
    u.SENHA := EditCadSenha.Text;
    u.IND_LOGIN := 'S';
    u.FOTO := CFotoEditar.Fill.Bitmap.Bitmap;

    // Excluir conta existente...
    if NOT u.Excluir(erro) then
    if erro <> '' then
    begin
      ShowMessage(erro);
      Exit;
    end;

    // Cadastrar novo usuário...
    if NOT u.Inserir(erro) then
    begin
      ShowMessage(erro);
      Exit;
    end;

  finally
    u.DisposeOf;
  end;

  if NOT Assigned(FormPrincipal) then
    Application.CreateForm(TFormPrincipal, FormPrincipal);

  Application.MainForm := FormPrincipal;
  FormPrincipal.Show;
  FormLogin.Close;
end;

procedure TFormLogin.RectContaProximoClick(Sender: TObject);
begin
  ActFoto.Execute;
end;

procedure TFormLogin.RectLoginClick(Sender: TObject);
var
  u : TUsuario;
  erro : string;
begin
  try
    u := TUsuario.Create(dm.Conn);
    u.EMAIL := EditLoginEmail.Text;
    u.SENHA := EditLoginSenha.Text;

    if NOT u.ValidarLogin(erro) then
    begin
      ShowMessage(erro);
      Exit;
    end;

  finally
    u.DisposeOf;
  end;

  if NOT Assigned(FormPrincipal) then
    Application.CreateForm(TFormPrincipal, FormPrincipal);

  Application.MainForm := FormPrincipal;
  FormPrincipal.Show;
  FormLogin.Close;
end;

end.
