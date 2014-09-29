unit storage;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, contnrs;

type

  { TStorage }

  TStorage = class
    private
      Items: TFPHashList;

    public
      constructor Create;
      destructor Destroy; override;
      procedure SetValue(Name: String; Value: LongInt);
      function GetValue(Name: String): LongInt;
  end;

var
  GlobalStorage: TStorage;

implementation

{ TStorage }

constructor TStorage.Create;
begin
  Items := TFPHashList.Create;
end;

destructor TStorage.Destroy;
begin
  Items.Free;
  inherited Destroy;
end;

procedure TStorage.SetValue(Name: String; Value: LongInt);
var
  point: PLongInt;
begin
  point := Items.Find(Name);
  if Assigned(point) then
    point^ := Value
  else begin
    point := GetMem(SizeOf(LongInt));
    point^ := Value;
    Items.Add(Name, point);
  end;
end;

function TStorage.GetValue(Name: String): LongInt;
var
  point: PLongInt;
begin
  point := Items.Find(Name);
  if Assigned(point) then
    Result := PLongInt(point)^
  else
    Result := 0;
end;

end.

