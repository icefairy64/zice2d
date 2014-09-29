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
      procedure SetValue(Name: String; Value: LongInt);
      function GetValue(Name: String): LongInt;
  end;

implementation

{ TStorage }

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
begin
  Result := PLongInt(Items.Find(Name))^;
end;

end.

