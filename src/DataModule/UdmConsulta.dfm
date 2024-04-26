object DmConsulta: TDmConsulta
  Height = 330
  Width = 390
  object ConexaoBanco: TFDConnection
    Params.Strings = (
      'DriverID=MySQL'
      'Database=Lavanderia'
      'User_Name=root'
      'Password=x4nd3'
      'Server=127.0.0.1')
    Left = 184
    Top = 184
  end
  object qryConsultarEndereco: TFDQuery
    Connection = ConexaoBanco
    SQL.Strings = (
      'SELECT * FROM CONSULTAENDERECO;')
    Left = 64
    Top = 136
  end
  object qryConsultas: TFDQuery
    Connection = ConexaoBanco
    SQL.Strings = (
      'SELECT * FROM CONSULTAENDERECO;')
    Left = 200
    Top = 112
  end
end
