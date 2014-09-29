unit timer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, zglHeader, simplelist, fpTimer, dateutils;

type
  ITickable = interface
    procedure Tick(DT: Double);
  end;

  TTickableListItem = class(TListItem)
    Body: ITickable;
  end;

  TTimer = class
    private
      Internal: TFPTimer;
      Attached: TSimpleList;
      LastTick: TDateTime;

      function GetInterval: LongWord;
      procedure SetInterval(Value: LongWord);
      function GetEnabled: Boolean;
      procedure SetEnabled(Value: Boolean);
      procedure Tick(Sender: TObject);

    public
      property Interval: LongWord read GetInterval write SetInterval;
      property Enabled: Boolean read GetEnabled write SetEnabled;

      constructor Create(AInterval: LongWord; AEnabled: Boolean = False);
      destructor Destroy; override;
      procedure Attach(Client: ITickable);
      procedure Detach(Client: ITickable);
  end;

implementation

// TTimer

constructor TTimer.Create(AInterval: LongWord; AEnabled: Boolean);
begin
  Attached := TSimpleList.Create;
  Internal := TFPTimer.Create(nil);
  Internal.Interval := AInterval;
  Internal.OnTimer := @Tick;
  Internal.Enabled := AEnabled;
  LastTick := Now;
end;

destructor TTimer.Destroy;
begin
  Internal.Free;
  Attached.Free;
  inherited Destroy;
end;

function TTimer.GetInterval: LongWord;
begin
  Result := Internal.Interval;
end;

procedure TTimer.SetInterval(Value: LongWord);
begin
  Internal.Interval := Value;
end;

function TTimer.GetEnabled: Boolean;
begin
  Result := Internal.Enabled;
end;

procedure TTimer.SetEnabled(Value: Boolean);
begin
  Internal.Enabled := Value;
end;

procedure TTimer.Tick(Sender: TObject);
var
  dt: Double;
  point: TTickableListItem;
begin
  dt := MilliSecondSpan(Now, LastTick);
  point := TTickableListItem(Attached.Head);
  while Assigned(point) do begin
    if Assigned(point.Body) then
      point.Body.Tick(dt);
    point := TTickableListItem(point.Next);
  end;
  LastTick := Now;
end;

procedure TTimer.Attach(Client: ITickable);
begin
  Attached.Insert(TTickableListItem.Create);
  TTickableListItem(Attached.Tail).Body := Client;
end;

procedure TTimer.Detach(Client: ITickable);
var
  point: TTickableListItem;
begin
  point := TTickableListItem(Attached.Head);
  while Assigned(point) do begin
    if Assigned(point.Body) and (point.Body = Client) then begin
      if Assigned(point.Next) then
        point.Next.Prev := point.Prev
      else if Assigned(point.Prev) then
        point.Prev.Next := point.Next;
    end;
    point := TTickableListItem(point.Next);
  end;
end;

end.

