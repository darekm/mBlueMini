{%RunFlags BUILD-}
unit mbmain;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  xlbtdevice,
  SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Memo1: TMemo;
    procedure buttonscan(Sender: TObject);
    procedure buttonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    BLE: tBtDevice;
    machine_state: integer;
    run: boolean;
    { private declarations }
    procedure print(s: string);
  public
    { public declarations }
    procedure Initialize;
    procedure scan(aAddr : string);
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

const
  DEVICE_INIT_STATE = 0;
  GET_PARAM_STATE   = 1;
  INQUIRY_STATE     = 2;
  CANCEL_INQUIRY_STATE = 3;
  LINK_REQ_ESTABLISH_STATE = 4;
  ATT_WRITE_VALUE_STATE = 5;
  ATT_WRITE_BEHAVIOUR_STATE = 6;
  WAITING_NOTIFICATION_STATE = 7;
  TERMINATING_LINK_STATE = 8;


    MAX_INQUIRY_ROUNDS          = 100;


procedure TForm1.FormCreate(Sender: TObject);
begin
  print('Bluetooth Low Energy simple demo under Linux.');
  print('---------------------------------------------');
  // serial._fd globally defined
  BLE := tBtDevice.Create(3);
  BLE.OnDebug := @print;

end;

procedure TForm1.buttonClick(Sender: TObject);
begin
  run := True;
  Initialize();
end;

procedure TForm1.buttonscan(Sender: TObject);
begin

  scan(edit1.text);
end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
  BLE.Destroy;
end;

procedure tForm1.print(s: string);
begin
  memo1.Append(s+#10);
end;



procedure tForm1.scan(aAddr : string);
var
  lp : integer;
  inquiry_rounds : integer;
  operation_multiplier: double;
begin
  print('start scan');
  inquiry_rounds:=0;
  label1.Caption := 'scan';
  machine_state := LINK_REQ_ESTABLISH_STATE;
    operation_multiplier := HCI_NORMAL_MULTIPLIER;
    Inc(lp);
    print('REQ establish state '+asHex(GAP_EstablishLinkRequest+aAddr));
    BLE.Write(GAP_EstablishLinkRequest+aAddr);
    BLE.Read(operation_multiplier);



  print('end scan');

end;

procedure tForm1.Initialize();
var
  inquiry_rounds: integer;
  operation_multiplier: double;
  lp: integer;
begin
  //    os.system("clear")
  // machine states
  // inquiry rounds
  inquiry_rounds := 0;
  machine_state := DEVICE_INIT_STATE;
  print('start');

  // continuous bucle state_machine
  while (machine_state < LINK_REQ_ESTABLISH_STATE) do
  begin
    // operation timeout
    operation_multiplier := HCI_NORMAL_MULTIPLIER;
    Inc(lp);
    //      label1.caption:=inttostr(lp);


    // Tx command sent to serial
    // Rx event HCI_LE_ExtEvent (command status from HCI)
    // + Rx event (command results from GAP)
    // + Rx event (command END from HCI)
    if machine_state = DEVICE_INIT_STATE then
    begin
      print('GAP_DeviceInit');
      BLE.Write(GAP_DeviceInit);
      Inc(machine_state);
    end
    else if machine_state = GET_PARAM_STATE then
    begin
      // really, now we are not doing anything here"
      print('get param state');
      BLE.Write(GAP_GetParam+TGAP_CONN_EST_INT_MIN);
      Inc(machine_state);
    end
    else if machine_state = INQUIRY_STATE then
    begin
      operation_multiplier := INQUIRY_MULTIPLIER;

      if (inquiry_rounds < MAX_INQUIRY_ROUNDS) then
      begin
        if (inquiry_rounds = 0) then
        begin
          // first time
          print('GAP_DeviceDiscoveryRequest');
          BLE.Write(GAP_DeviceDiscoveryRequest+tGAP_DiscoveryActive);
        end;
        Inc(inquiry_rounds);
        if BLE.connectable then
           inc(machine_state);
      end
      else if (inquiry_rounds = MAX_INQUIRY_ROUNDS) then
      begin
          // last time
          Inc(machine_state);

      end;
    end
    else if machine_state = CANCEL_INQUIRY_STATE then
    begin
      edit1.Text:=BLE.peerAddr;
  //    print('Canceling GAP_DeviceDiscoveryRequest just-in-case:');
 //     BLE.Write(GAP_DeviceDiscoveryCancel);
      // next statement situates machine_state in LINK_REQ_ESTABLISH_STATE, and we finish this little demo here
      Inc(machine_state);
    end;

    // always try to read after state_machine
    BLE.Read(operation_multiplier);
    if not run then
      break;
    application.ProcessMessages;
  end;
  print('End initialize');
end;


end.
