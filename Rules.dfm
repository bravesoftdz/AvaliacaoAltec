object dmRules: TdmRules
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 625
  Width = 807
  object mtClientes: TFDMemTable
    AfterPost = mtClientesAfterPost
    FieldDefs = <>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    Left = 112
    Top = 72
    object mtClientesnome: TStringField
      DisplayLabel = 'Nome do cliente:'
      DisplayWidth = 50
      FieldName = 'nome'
      Size = 100
    end
    object mtClientesrg: TStringField
      DisplayLabel = 'RG:'
      FieldName = 'rg'
      Size = 10
    end
    object mtClientescpf: TStringField
      DisplayLabel = 'CPF:'
      FieldName = 'cpf'
      Size = 11
    end
    object mtClientestelefone: TStringField
      DisplayLabel = 'Telefone:'
      DisplayWidth = 11
      FieldName = 'telefone'
      Size = 11
    end
    object mtClientesemail: TStringField
      DisplayLabel = 'e-Mail:'
      FieldName = 'email'
      Size = 50
    end
    object mtClientescep: TStringField
      DisplayLabel = 'CEP:'
      FieldName = 'cep'
      EditMask = '00000-000;0;_'
      Size = 8
    end
    object mtClientesendereco: TStringField
      DisplayLabel = 'Endere'#231'o:'
      FieldName = 'endereco'
      Size = 150
    end
    object mtClientesnumero: TStringField
      DisplayLabel = 'N'#186
      FieldName = 'numero'
      Size = 10
    end
    object mtClientescomplemento: TStringField
      DisplayLabel = 'Complemento:'
      FieldName = 'complemento'
      Size = 50
    end
    object mtClientesbairro: TStringField
      DisplayLabel = 'Bairro:'
      FieldName = 'bairro'
      Size = 100
    end
    object mtClientescidade: TStringField
      DisplayLabel = 'Cidade:'
      FieldName = 'cidade'
      Size = 50
    end
    object mtClientesuf: TStringField
      DisplayLabel = 'UF:'
      FieldName = 'uf'
      Size = 2
    end
    object mtClientespais: TStringField
      DisplayLabel = 'Pa'#237's:'
      FieldName = 'pais'
    end
  end
  object RESTClient1: TRESTClient
    BaseURL = 'http://viacep.com.br/ws/'
    Params = <>
    Left = 112
    Top = 176
  end
  object RESTRequest1: TRESTRequest
    Client = RESTClient1
    Params = <
      item
        Kind = pkURLSEGMENT
        Name = 'CEP'
        Options = [poAutoCreated]
      end>
    Resource = '{CEP}/json/'
    Response = RESTResponse1
    SynchronizedEvents = False
    Left = 64
    Top = 256
  end
  object RESTResponse1: TRESTResponse
    Left = 168
    Top = 256
  end
end
