object DmConsulta: TDmConsulta
  OldCreateOrder = False
  Height = 508
  Width = 670
  object ConnectionTabela: TSQLConnection
    DriverName = 'DevartOracleDirect'
    LoginPrompt = False
    Params.Strings = (
      'LibraryName=dbexpoda40.dll'
      'VendorLib=dbexpoda40.dll'
      'DriverUnit=DbxDevartOracle'
      
        'DriverPackageLoader=TDBXDynalinkDriverLoader,DBXCommonDriver210.' +
        'bpl'
      
        'MetaDataPackageLoader=TDBXDevartOracleMetaDataCommandFactory,Dbx' +
        'DevartOracleDriver210.bpl'
      'ProductName=DevartOracle'
      'GetDriverFunc=getSQLDriverORADirect'
      'MaxBlobSize=-1'
      'LocaleCode=0000'
      'Oracle TransIsolation=ReadCommitted'
      'RoleName=Normal'
      'LongStrings=True'
      'EnableBCD=True'
      'UseQuoteChar=False'
      'CharLength=0'
      'UseUnicode=True'
      'UnicodeEnvironment=False'
      'IPVersion=IPv4'
      'DelegateConnection=DBXPool'
      'DBXPool.MaxConnections=20'
      'DBXPool.MinConnections=1'
      'DBXPool.ConnectTimeout=1000'
      'DBXPool.DriverUnit=Data.DBXPool'
      'DBXPool.DelegateDriver=True'
      'DBXPool.DBXPool.MaxConnections=20'
      'DBXPool.DBXPool.MinConnections=1'
      'DBXPool.DBXPool.ConnectTimeout=1000'
      'DBXPool.DBXPool.DriverUnit=Data.DBXPool'
      'DBXPool.DBXPool.DelegateDriver=True'
      'DBXPool.DBXPool.DriverName=DBXPool'
      'DBXPool.DriverName=DBXPool')
    Left = 88
    Top = 56
  end
  object cdsTabela: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'dspTabela'
    Left = 160
    Top = 56
  end
  object dsTabela: TDataSource
    DataSet = cdsTabela
    Left = 216
    Top = 56
  end
  object dspTabela: TDataSetProvider
    DataSet = qryTabela
    Left = 296
    Top = 64
  end
  object qry: TSQLQuery
    MaxBlobSize = -1
    Params = <>
    SQLConnection = ConnectionTabela
    Left = 496
    Top = 72
  end
  object qryTabela: TSQLQuery
    DataSource = dsTabela
    MaxBlobSize = -1
    Params = <>
    SQL.Strings = (
      'SELECT * FROM CONSULTAENDERECO')
    SQLConnection = ConnectionTabela
    Left = 416
    Top = 96
  end
end
