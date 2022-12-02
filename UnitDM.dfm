object dm: Tdm
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 437
  Width = 319
  object Conn: TFDConnection
    Params.Strings = (
      'Database=C:\Users\Beto\Desktop\99Money\DB\banco.db'
      'OpenMode=ReadWrite'
      'LockingMode=Normal'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 24
    Top = 24
  end
end
