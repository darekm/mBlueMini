unit xlbthost;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  xlbtdevice;
type
  tBtHost = class
    private
      Addr : string;
      BT   : tBtDevice;
      fLink: boolean;
      procedure SetLink(aLink:boolean);
    public
      constructor create(abt : tBtDevice;aAddr  : string);
      property Link:boolean read fLink write SetLink;
  end;

implementation


constructor tBtHost.create;
begin
  Addr:=aAddr;

end;
procedure tBtHost.SetLink(aLink : boolean);
begin
  fLink:=aLink;
end;


procedure tForm1.EstablishLink();
var
  lp : integer;
  inquiry_rounds : integer;
  operation_multiplier: double;
begin
//  print('start scan');
  inquiry_rounds:=0;
  label1.Caption := 'scan';
  machine_state := LINK_REQ_ESTABLISH_STATE;
  while (machine_state < TERMINATING_LINK_STATE) do
  begin
    operation_multiplier := HCI_NORMAL_MULTIPLIER;
    Inc(lp);
    if machine_state = LINK_REQ_ESTABLISH_STATE then begin
       print('REQ establish state '+asHex(GAP_EstablishLinkRequest+BLE.peerAddr));
      BLE.Write(GAP_EstablishLinkRequest+BLE.PeerAddr);
      Inc(machine_state);

    end else begin
      Inc(machine_state);
    end;
      BLE.Read(operation_multiplier);
       if not run then
         break;
       application.ProcessMessages;



  end;
  print('end scan');

end;

end.

