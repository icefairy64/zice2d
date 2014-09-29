unit automation;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, timer;

type

  { TAutomation }

  TAutomation = class(TInterfacedObject, ITickable)
    protected
      Time: Double;
      CurrentPos: Word;
      Pos: array of Double;
      FActive: Boolean;

      procedure Automate(APos: Double); virtual; abstract;

    public
      Loop: Boolean;
      property Active: Boolean read FActive;

      procedure Tick(DT: Double);
      procedure Restart;
  end;

implementation

{ TAutomation }

procedure TAutomation.Tick(DT: Double);
begin
  if not FActive then
    Exit;

  Time += DT;

  if Time >= Pos[CurrentPos] then
    CurrentPos += 1;

  if CurrentPos = Length(Pos) then
    if Loop then
      Time -= Pos[Length(Pos) - 1]
    else begin
      Time := Pos[Length(Pos) - 1];
      FActive := False;
      Exit;
    end;

  if CurrentPos = 0 then
    Automate(Time / Pos[0])
  else
    Automate((Time - Pos[CurrentPos - 1]) / (Pos[CurrentPos] - Pos[CurrentPos - 1]));
end;

procedure TAutomation.Restart;
begin
  Time := 0;
  CurrentPos := 0;
  FActive := True;
end;

end.

