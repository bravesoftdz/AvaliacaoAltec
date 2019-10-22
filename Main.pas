unit Main;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Actions,
  Data.DB,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Imaging.pngimage,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.Mask,
  Vcl.DBCtrls,
  Vcl.Grids,
  Vcl.DBGrids,
  Vcl.WinXPanels,
  Vcl.Buttons,
  Vcl.ActnList,
  Vcl.WinXCtrls;

type
  TfCadCliente = class(TForm)
    Panel2: TPanel;
    Image1: TImage;
    Panel1: TPanel;
    Panel3: TPanel;
    CardPanel1: TCardPanel;
    Card1: TCard;
    Card2: TCard;
    DBGrid1: TDBGrid;
    Label1: TLabel;
    DBEdit1: TDBEdit;
    dsCadCliente: TDataSource;
    Panel4: TPanel;
    Label2: TLabel;
    DBEdit2: TDBEdit;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    DBEdit3: TDBEdit;
    Label4: TLabel;
    DBEdit4: TDBEdit;
    Label5: TLabel;
    DBEdit5: TDBEdit;
    Label6: TLabel;
    DBEdit6: TDBEdit;
    Label8: TLabel;
    DBEdit8: TDBEdit;
    Label9: TLabel;
    DBEdit9: TDBEdit;
    Label10: TLabel;
    DBEdit10: TDBEdit;
    Label11: TLabel;
    DBEdit11: TDBEdit;
    Label12: TLabel;
    DBEdit12: TDBEdit;
    Label13: TLabel;
    DBEdit13: TDBEdit;
    Label14: TLabel;
    DBEdit14: TDBEdit;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    alCadCliente: TActionList;
    ActionInserir: TAction;
    ActionGravar: TAction;
    ActionCancelar: TAction;
    ActionExcluir: TAction;
    ActionEditar: TAction;
    ActionProximo: TAction;
    ActionAnterior: TAction;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    ToggleSwitch1: TToggleSwitch;
    procedure ActionInserirExecute(Sender: TObject);
    procedure ActionGravarExecute(Sender: TObject);
    procedure ActionCancelarExecute(Sender: TObject);
    procedure ActionExcluirExecute(Sender: TObject);
    procedure ActionEditarExecute(Sender: TObject);
    procedure ActionProximoExecute(Sender: TObject);
    procedure ActionAnteriorExecute(Sender: TObject);
    procedure dsCadClienteStateChange(Sender: TObject);
    procedure DBEdit6Exit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ToggleSwitch1Click(Sender: TObject);
  private
    { Private declarations }
    procedure ChangeActiveCard;
  public
    { Public declarations }
  end;

var
  fCadCliente: TfCadCliente;

implementation

uses
  Rules,
  ViaCEP;

{$R *.dfm}

procedure TfCadCliente.ActionAnteriorExecute(Sender: TObject);
begin
  Self.dsCadCliente.DataSet.Prior;
end;

procedure TfCadCliente.ActionCancelarExecute(Sender: TObject);
begin
  Self.dsCadCliente.DataSet.Cancel;
end;

procedure TfCadCliente.ActionEditarExecute(Sender: TObject);
begin
  Self.dsCadCliente.DataSet.Edit;
end;

procedure TfCadCliente.ActionExcluirExecute(Sender: TObject);
const
  C_MESSAGE = 'Confirma a exclusão do cliente %s?' + #13#10#13#10 + 'Não tem volta hein?';
var
  mrRet   : Integer;
  sMessage: string;
begin
  sMessage := Format(C_MESSAGE, [Self.dsCadCliente.DataSet.FieldByName('nome').AsString]);
  mrRet    := MessageBox(Self.Handle, PWideChar(sMessage), 'Atenção!', MB_YESNO + MB_DEFBUTTON2 + MB_ICONWARNING);

  if (mrRet = mrYes) then
  begin
    Self.dsCadCliente.DataSet.Delete;
  end;
end;

procedure TfCadCliente.ActionGravarExecute(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    Self.dsCadCliente.DataSet.Post;
    MessageBox(Self.Handle, 'Cliente cadastrado com sucesso!', 'Tudo certo!', MB_OK + MB_ICONINFORMATION);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfCadCliente.ActionInserirExecute(Sender: TObject);
begin
  Self.ToggleSwitch1.State := tssOn;
  Self.ChangeActiveCard;
  Self.dsCadCliente.DataSet.Append;
end;

procedure TfCadCliente.ActionProximoExecute(Sender: TObject);
begin
  Self.dsCadCliente.DataSet.Next;
end;

procedure TfCadCliente.ChangeActiveCard;
begin
  case Self.ToggleSwitch1.State of
    tssOff:
      begin
        Self.CardPanel1.ActiveCard := Self.Card1;
      end;
    tssOn:
      begin
        Self.CardPanel1.ActiveCard := Self.Card2;
        Self.DBEdit1.SetFocus;
      end;
  end;
end;

procedure TfCadCliente.DBEdit6Exit(Sender: TObject);
var
  oDataCEP: TCEPClass;
begin
  if Self.dsCadCliente.DataSet.FieldByName('cep').IsNull then
  begin
    Exit;
  end;

  Screen.Cursor := crHourGlass;
  oDataCEP      := nil;
  try
    with Self.dsCadCliente.DataSet do
    begin
      FieldByName('endereco').Clear;
      FieldByName('complemento').Clear;
      FieldByName('bairro').Clear;
      FieldByName('cidade').Clear;
      FieldByName('uf').Clear;
      FieldByName('pais').Clear;
    end;

    oDataCEP := dmRules.SearchCEP(Self.dsCadCliente.DataSet.FieldByName('cep').AsString);

    if oDataCEP.erro then
    begin
      MessageBox(Self.Handle, 'Não encontramos este CEP, verifique por favor.', 'Atenção!', MB_OK + MB_ICONERROR);
      Self.DBEdit6.SetFocus;
      Abort;
    end;

    with Self.dsCadCliente.DataSet do
    begin
      FieldByName('endereco').Value    := oDataCEP.logradouro;
      FieldByName('complemento').Value := oDataCEP.complemento;
      FieldByName('bairro').Value      := oDataCEP.bairro;
      FieldByName('cidade').Value      := oDataCEP.localidade;
      FieldByName('uf').Value          := oDataCEP.uf;
      FieldByName('pais').Value        := 'Brasil';
    end;
  finally
    if Assigned(oDataCEP) then
    begin
      oDataCEP.Free;
    end;
    Screen.Cursor := crDefault;
  end;
end;

procedure TfCadCliente.dsCadClienteStateChange(Sender: TObject);
var
  oTableState: TDataSetState;
begin
  oTableState := Self.dsCadCliente.DataSet.State;

  Self.ActionInserir.Enabled  := oTableState = dsBrowse;
  Self.ActionGravar.Enabled   := oTableState <> dsBrowse;
  Self.ActionCancelar.Enabled := oTableState <> dsBrowse;
  Self.ActionExcluir.Enabled  := oTableState = dsBrowse;
  Self.ActionEditar.Enabled   := oTableState = dsBrowse;
  Self.ActionProximo.Enabled  := oTableState = dsBrowse;
  Self.ActionAnterior.Enabled := oTableState = dsBrowse;

  Self.SpeedButton4.Visible := oTableState <> dsBrowse;
  Self.SpeedButton3.Visible := oTableState <> dsBrowse;;
end;

procedure TfCadCliente.FormCreate(Sender: TObject);
begin
  ReportMemoryLeaksOnShutdown := True;

  Self.ToggleSwitch1.State := tssOff;
  Self.ChangeActiveCard;
end;

procedure TfCadCliente.ToggleSwitch1Click(Sender: TObject);
begin
  Self.ChangeActiveCard;
end;

end.
