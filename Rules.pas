unit Rules;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Threading,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  REST.Types,
  REST.Client,
  Data.Bind.Components,
  Data.Bind.ObjectScope,
  ViaCEP,
  Xml.xmldom,
  Xml.XMLIntf,
  Xml.XMLDoc,
  IdBaseComponent,
  IdComponent,
  IdTCPConnection,
  IdTCPClient,
  IdExplicitTLSClientServerBase,
  IdSMTPBase,
  IdSMTP,
  IdMessage,
  IdIOHandler,
  IdIOHandlerSocket,
  IdIOHandlerStack,
  IdSSL,
  IdSSLOpenSSL,
  IdAttachmentFile;

type
  TdmRules = class(TDataModule)
    mtClientes: TFDMemTable;
    mtClientesnome: TStringField;
    mtClientesrg: TStringField;
    mtClientescpf: TStringField;
    mtClientestelefone: TStringField;
    mtClientesemail: TStringField;
    mtClientescep: TStringField;
    mtClientesnumero: TStringField;
    mtClientescomplemento: TStringField;
    mtClientesbairro: TStringField;
    mtClientescidade: TStringField;
    mtClientesuf: TStringField;
    mtClientespais: TStringField;
    mtClientesendereco: TStringField;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure mtClientesAfterPost(DataSet: TDataSet);
  private
    { Private declarations }
    function BuildXML: TStringStream;
    procedure SendMail(const AUserDest: string; AContent: TStringStream);
  public
    { Public declarations }
    function SearchCEP(const ACEP: string): TCEPClass;
  end;

var
  dmRules: TdmRules;

implementation

uses
  IdText;

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

function TdmRules.BuildXML: TStringStream;
var
  oXML         : TXMLDocument;
  oNodeEndereco: IXMLNode;
begin
  oXML := TXMLDocument.Create(nil);
  try
    oXML.Active := True;
    oXML.AddChild('cliente');
    oXML.DocumentElement.AddChild('nome').NodeValue     := mtClientesnome.Value;
    oXML.DocumentElement.AddChild('rg').NodeValue       := mtClientesrg.Value;
    oXML.DocumentElement.AddChild('cpf').NodeValue      := mtClientescpf.Value;
    oXML.DocumentElement.AddChild('telefone').NodeValue := mtClientestelefone.Value;
    oXML.DocumentElement.AddChild('email').NodeValue    := mtClientesemail.Value;

    oNodeEndereco                                   := oXML.DocumentElement.AddChild('endereco');
    oNodeEndereco.AddChild('logradouro').NodeValue  := mtClientesendereco.Value;
    oNodeEndereco.AddChild('numero').NodeValue      := mtClientesnumero.Value;
    oNodeEndereco.AddChild('complemento').NodeValue := mtClientescomplemento.Value;
    oNodeEndereco.AddChild('bairro').NodeValue      := mtClientesbairro.Value;
    oNodeEndereco.AddChild('cidade').NodeValue      := mtClientescidade.Value;
    oNodeEndereco.AddChild('uf').NodeValue          := mtClientesuf.Value;
    oNodeEndereco.AddChild('pais').NodeValue        := mtClientespais.Value;
  finally
    Result := TStringStream.Create();
    oXML.SaveToStream(Result);
  end;
end;

procedure TdmRules.DataModuleCreate(Sender: TObject);
begin
  Self.mtClientes.Open;
end;

procedure TdmRules.DataModuleDestroy(Sender: TObject);
begin
  Self.mtClientes.Close;
end;

procedure TdmRules.mtClientesAfterPost(DataSet: TDataSet);
var
  oContent: TStringStream;
begin
  oContent := Self.BuildXML;

  TTask.Run(
    procedure
    begin
      try
        if not Self.mtClientesemail.IsNull then
        begin
          Self.SendMail(string(Self.mtClientesemail.Value), oContent);
        end;
      finally
        oContent.Free;
      end;
    end)
end;

function TdmRules.SearchCEP(const ACEP: string): TCEPClass;
begin
  Self.RESTRequest1.Params.ParameterByName('CEP').Value := ACEP;
  Self.RESTRequest1.Execute;

  Result := TCEPClass.FromJsonString(Self.RESTResponse1.JSONText);
end;

procedure TdmRules.SendMail(const AUserDest: string; AContent: TStringStream);
const
  EMAIL_USER = '';
  EMAIL_PSWD = '';
var
  oSMTP      : TIdSMTP;
  oMessage   : TIdMessage;
  oContent   : TidText;
  oSSL       : TIdSSLIOHandlerSocketOpenSSL;
  oAttachment: TIdAttachmentFile;
begin
  oSMTP    := nil;
  oMessage := nil;
  oSSL     := nil;

  if (EMAIL_USER = EmptyStr) or (EMAIL_PSWD = EmptyStr) then
  begin
    raise Exception.Create('Credenciais do servidor de email não definidas!');
  end;

  try
    oMessage := TIdMessage.Create(nil);
    oMessage.Clear;
    oMessage.CharSet      := 'iso-8859-1';
    oMessage.Encoding     := TIdMessageEncoding.MeMIME;
    oMessage.ContentType  := 'multipart/related';
    oMessage.Subject      := 'Novo cliente cadastrado';
    oMessage.From.Address := EMAIL_USER;

    oMessage.Recipients.EMailAddresses := 'mario@arrayof.io';

    oContent             := TidText.Create(oMessage.MessageParts);
    oContent.Body.Text   := 'Foi cadastrado um novo cliente no sistema. Vide anexo.';
    oContent.ContentType := 'text/html';

    oAttachment := TIdAttachmentFile.Create(oMessage.MessageParts);
    oAttachment.LoadFromStream(AContent);
    oAttachment.FileName := 'cliente.xml';

    oSSL                        := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    oSSL.SSLOptions.Method      := TIdSSLVersion.sslvSSLv23;
    oSSL.SSLOptions.SSLVersions := [TIdSSLVersion.sslvSSLv23];
    oSSL.SSLOptions.Mode        := sslmClient;

    oSMTP                := TIdSMTP.Create(nil);
    oSMTP.ConnectTimeout := 10000;
    oSMTP.ReadTimeout    := 10000;
    oSMTP.IOHandler      := oSSL;
    oSMTP.UseTLS         := TIdUseTLS.utUseImplicitTLS;
    oSMTP.AuthType       := satDefault;
    oSMTP.Host           := 'smtp.gmail.com';
    oSMTP.Port           := 465;
    oSMTP.Username       := EMAIL_USER;
    oSMTP.Password       := EMAIL_PSWD;
    oSMTP.Connect;
    oSMTP.Send(oMessage);

  finally
    if Assigned(oSMTP) then
    begin
      oSMTP.Disconnect();
      oSMTP.Free;
    end;
    if Assigned(oMessage) then
    begin
      oMessage.Free;
    end;
    if Assigned(oSSL) then
    begin
      oSSL.Free;
    end;
  end;
end;

end.
