object frmPrincipal: TfrmPrincipal
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Consulta de Endere'#231'os'
  ClientHeight = 406
  ClientWidth = 638
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object FPanelPrincipal: TPanel
    Left = 0
    Top = 0
    Width = 638
    Height = 406
    Align = alClient
    TabOrder = 0
    object lbCEP: TLabel
      Left = 9
      Top = 28
      Width = 23
      Height = 13
      Caption = 'CEP:'
    end
    object edtCEP: TEdit
      Left = 34
      Top = 24
      Width = 206
      Height = 21
      Hint = 'Digite o CEP.'
      TabOrder = 0
    end
    object btnBuscar: TButton
      Left = 7
      Top = 101
      Width = 212
      Height = 25
      Caption = 'Buscar Endere'#231'o pelo CEP'
      TabOrder = 1
      OnClick = btnBuscarClick
    end
    object gbResultados: TGroupBox
      Left = 1
      Top = 137
      Width = 636
      Height = 268
      Align = alBottom
      Caption = '  Resultados'
      TabOrder = 2
      object gridConsulta: TDBGrid
        Left = 2
        Top = 15
        Width = 632
        Height = 251
        Align = alClient
        DataSource = DmConsulta.dsTabela
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        Columns = <
          item
            Expanded = False
            FieldName = 'CODIGO'
            Width = 85
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'CEP'
            Width = 86
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'Logradouro'
            Width = 93
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'complemento'
            Width = 73
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'bairro'
            Width = 93
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'localidade'
            Width = 84
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'uf'
            Width = 86
            Visible = True
          end>
      end
    end
    object gbEnderecoCompleto: TGroupBox
      Left = 9
      Top = 46
      Width = 626
      Height = 44
      Caption = '  Endere'#231'o Completo'
      TabOrder = 3
      object lbEstado: TLabel
        Left = 9
        Top = 23
        Width = 37
        Height = 13
        Caption = 'Estado:'
      end
      object lbCidade: TLabel
        Left = 202
        Top = 23
        Width = 37
        Height = 13
        Caption = 'Cidade:'
      end
      object lbEndereco: TLabel
        Left = 407
        Top = 23
        Width = 49
        Height = 13
        Caption = 'Endere'#231'o:'
      end
      object edtEstado: TEdit
        Left = 48
        Top = 19
        Width = 151
        Height = 21
        Hint = 'Digite o endere'#231'o.'
        TabOrder = 0
      end
      object edtCidade: TEdit
        Left = 239
        Top = 19
        Width = 164
        Height = 21
        Hint = 'Digite o endere'#231'o.'
        TabOrder = 1
      end
      object edtEndereco: TEdit
        Left = 456
        Top = 19
        Width = 166
        Height = 21
        Hint = 'Digite o endere'#231'o.'
        TabOrder = 2
      end
    end
    object rgResultado: TRadioGroup
      Left = 250
      Top = 3
      Width = 185
      Height = 48
      Caption = 'Resultado por:'
      ItemIndex = 0
      Items.Strings = (
        'Json'
        'XML')
      TabOrder = 4
    end
    object btnBuscarCompleto: TButton
      Left = 222
      Top = 101
      Width = 212
      Height = 25
      Caption = 'Buscar Endere'#231'o Completo'
      TabOrder = 5
      OnClick = btnBuscarCompletoClick
    end
  end
end
