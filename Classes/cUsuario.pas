unit cUsuario;

interface

uses FireDAC.Comp.Client, FireDAC.DApt, System.SysUtils, FMX.Graphics;

type
  TUsuario = class

  private
    Fconn: TFDConnection;
    FEMAIL: string;
    FSENHA: string;
    FNOME: string;
    FIND_LOGIN: string;
    FID_USUARIO: Integer;
    FFOTO: TBitMap;

  public
    constructor Create(conn: TFDConnection);
    property ID_USUARIO: Integer read FID_USUARIO write FID_USUARIO;
    property NOME: string read FNOME write FNOME;
    property EMAIL: string read FEMAIL write FEMAIL;
    property SENHA: string read FSENHA write FSENHA;
    property IND_LOGIN: string read FIND_LOGIN write FIND_LOGIN;
    property FOTO: TBitMap read FFOTO write FFOTO;

    function ListarUsuario(out erro: string): TFDQuery;
    function Inserir(out erro: string): Boolean;
    function Alterar(out erro: string): Boolean;
    function Excluir(out erro: string): Boolean;
    function ValidarLogin(out erro: string): Boolean;
    function Logout(out erro: string): Boolean;

  end;

implementation

{ TCategoria }

constructor TUsuario.Create(conn: TFDConnection);
begin
  Fconn := conn;
end;

function TUsuario.Inserir(out erro: string): Boolean;
var
  qry: TFDQuery;

begin
  // Valida��es
  if NOME = '' then
  begin
    erro := 'Informe o nome do usu�rio';
    Result := false;
    exit;
  end;
  if EMAIL = '' then
  begin
    erro := 'Informe o email do usu�rio';
    Result := false;
    exit;
  end;
  if SENHA = '' then
  begin
    erro := 'Informe o senha do usu�rio';
    Result := false;
    exit;
  end;

  try
    try
      qry := TFDQuery.Create(nil);
      qry.Connection := Fconn;

      with qry do
      begin
        Active := false;
        sql.Clear;
        sql.Add('INSERT INTO TAB_USUARIO(NOME, EMAIL, SENHA, IND_LOGIN, FOTO)');
        sql.Add('VALUES(:NOME, :EMAIL, :SENHA, :IND_LOGIN, :FOTO');
        ParamByName('NOME').Value := NOME;
        ParamByName('EMAIL'). Value := EMAIL;
        ParamByName('SENHA'). Value := SENHA;
        ParamByName('IND_LOGIN').Value := IND_LOGIN;
        ParamByName('FOTO').Assign(FOTO);
        ExecSQL;
      end;

      Result := true;
      erro := '';

    except
      on ex: exception do
      begin
        Result := false;
        erro := 'Erro ao inserir usu�rio: ' + ex.Message;
      end;
    end;

  finally
    qry.DisposeOf;
  end;
end;

function TUsuario.Alterar(out erro: string): Boolean;
var
  qry: TFDQuery;

begin
  // Validacoes...
  if NOME = '' then
  begin
    erro := 'Informe o nome do usu�rio';
    Result := false;
    exit;
  end;
  if EMAIL = '' then
  begin
    erro := 'Informe o email do usu�rio';
    Result := false;
    exit;
  end;
  if SENHA = '' then
  begin
    erro := 'Informe o senha do usu�rio';
    Result := false;
    exit;
  end;

  try
    try
      qry := TFDQuery.Create(nil);
      qry.Connection := Fconn;

      with qry do
      begin
        Active := false;
        sql.Clear;
        sql.Add('UPDATE TAB_USUARIO SET NOME=:NOME, EMAIL=:EMAIL, SENHA=:SENHA, IND_LOGIN=:IND_LOGIN, FOTO=:FOTO');
        sql.Add('WHERE ID_USUARIO = :ID_USUARIO');
        ParamByName('ID_USUARIO').Value := ID_USUARIO;
        ParamByName('NOME').Value := NOME;
        ParamByName('EMAIL'). Value := EMAIL;
        ParamByName('SENHA'). Value := SENHA;
        ParamByName('IND_LOGIN').Value := IND_LOGIN;
        ParamByName('FOTO').Assign(FOTO);
        ExecSQL;
      end;

      Result := true;
      erro := '';

    except
      on ex: exception do
      begin
        Result := false;
        erro := 'Erro ao alterar usu�rio: ' + ex.Message;
      end;
    end;

  finally
    qry.DisposeOf;
  end;
end;

function TUsuario.Excluir(out erro: string): Boolean;
var
  qry: TFDQuery;

begin

  try
    try
      qry := TFDQuery.Create(nil);
      qry.Connection := Fconn;

      with qry do
      begin
        Active := false;
        sql.Clear;
        sql.Add('DELETE FROM TAB_USUARIO');

        if ID_USUARIO > 0 then
        begin
        sql.Add('WHERE ID_USUARIO = :ID_USUARIO');
        ParamByName('ID_USUARIO').Value := ID_USUARIO;
        end;

        ExecSQL;
      end;

      Result := true;
      erro := '';

    except
      on ex: exception do
      begin
        Result := false;
        erro := 'Erro ao excluir usu�rio: ' + ex.Message;
      end;
    end;

  finally
    qry.DisposeOf;
  end;
end;

function TUsuario.ListarUsuario(out erro: string): TFDQuery;
var
  qry: TFDQuery;

begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := Fconn;

    with qry do
    begin
      Active := false;
      sql.Clear;
      sql.Add('SELECT * from TAB_USUARIO');
      sql.Add('WHERE 1 = 1');

      if ID_USUARIO > 0 then
      begin
        sql.Add('AND ID_USUARIO = :ID_USUARIO');
        ParamByName('ID_USUARIO').Value := ID_USUARIO;
      end;

      if EMAIL <> '' then
      begin
        sql.Add('AND EMAIL = :EMAIL');
        ParamByName('EMAIL').Value := EMAIL;
      end;

      if SENHA <> '' then
      begin
        sql.Add('AND SENHA = :SENHA');
        ParamByName('SENHA').Value := SENHA;
      end;

      Active := true;
    end;

    Result := qry;
    erro := '';

  except
    on ex: exception do
    begin
      Result := nil;
      erro := 'Erro ao consultar usu�rio: ' + ex.Message;
    end;
  end;
end;

function TUsuario.ValidarLogin(out erro: string): Boolean;
var
  qry: TFDQuery;

begin
  // Validacoes...
  if EMAIL = '' then
  begin
    erro := 'Informe o email do usu�rio';
    Result := false;
    exit;
  end;
  if SENHA = '' then
  begin
    erro := 'Informe o senha do usu�rio';
    Result := false;
    exit;
  end;
  try
  qry := TFDQuery.Create(nil);
  qry.Connection := Fconn;
    try
      with qry do
      begin
        Active := false;
        sql.Clear;
        sql.Add('SELECT * FROM TAB_USUARIO');
        sql.Add('WHERE EMAIL = :EMAIL');
        sql.Add('AND SENHA = :SENHA');
        ParamByName('EMAIL').Value := EMAIL;
        ParamByName('SENHA').Value := SENHA;
        Active := true;

        if RecordCount = 0 then
        begin
          Result := false;
          erro := 'Email ou senha inv�ldo';
          Exit;
        end;

        Active := false;
        sql.Clear;
        sql.Add('UPDATE TAB_USUARIO');
        sql.Add('SET IND_LOGIN = ''S''');
        ExecSQL;
      end;

      Result := True;
      erro := '';

    except
      on ex: exception do
      begin
        Result := False;
        erro := 'Erro ao consultar usu�rio: ' + ex.Message;
      end;
    end;
  finally
    qry.DisposeOf;
  end;
end;

function TUsuario.Logout(out erro: string): Boolean;
var
  qry: TFDQuery;

begin

  try
  qry := TFDQuery.Create(nil);
  qry.Connection := Fconn;
    try
      with qry do
      begin
        Active := false;
        sql.Clear;
        sql.Add('UPDATE TAB_USUARIO');
        sql.Add('SET IND_LOGIN = ''N''');
        ExecSQL;
      end;

      Result := True;
      erro := '';

    except
      on ex: exception do
      begin
        Result := False;
        erro := 'Erro ao fazer logout: ' + ex.Message;
      end;
    end;
  finally
    qry.DisposeOf;
  end;
end;

end.
