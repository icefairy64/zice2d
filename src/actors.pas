unit actors;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, drawables, timer, zglHeader, simplelist;

type

  { TScriptMovementPoint }

  TScriptMovementPoint = class(TListItem)
    Target: zglTPoint2D;
    Speed: Double;

    constructor Create(ATarget: zglPPoint2D; ASpeed: Double);
    constructor Create(AX, AY: Single; ASpeed: Double);
  end;

  { TActor }

  TActor = class(TListItem, ITickable)
    type
      TScriptedMovementFinish = procedure(Sender: TActor);

    private
      ScriptMovementVector: zglTPoint2D;
      ScriptMovementStart: Double;
      ScriptMovementLen: Double;

      function GetPPos: zglPPoint2D;
      function GetX: Single;
      function GetY: Single;
      procedure SetScriptMovement(AValue: Boolean);
      procedure SetX(AValue: Single);
      procedure SetY(AValue: Single);
      procedure CalculateMovement;
      procedure NextScriptPoint;

    protected
      FPos: zglTPoint2D;
      FName: String;
      Time: Double;
      ScriptMovement: TSimpleList;
      CurrentScriptPoint: TScriptMovementPoint;
      FScriptMovementEnabled: Boolean;
      FMovementFinished: Boolean;

    public
      Drawable: TDrawable;
      OnScriptedMovementFinish: TScriptedMovementFinish;
      property X: Single read GetX write SetX;
      property Y: Single read GetY write SetY;
      property Name: String read FName;
      property PPos: zglPPoint2D read GetPPos;
      property IsMovementFinished: Boolean read FMovementFinished;
      property ScriptMovementEnabled: Boolean read FScriptMovementEnabled write SetScriptMovement;

      constructor Create(AName: String; ADrawable: TDrawable);
      destructor Destroy; override;
      procedure Tick(DT: Double); virtual;
      procedure MoveTo(AX, AY: Single);
      procedure Move(DX, DY: Single);
      procedure AddScriptMovementPoint(AX, AY: Single; ASpeed: Double);
      procedure ClearScriptMovement;
  end;

implementation

{ TScriptMovementPoint }

constructor TScriptMovementPoint.Create(ATarget: zglPPoint2D; ASpeed: Double);
begin
  Create(ATarget^.X, ATarget^.Y, ASpeed);
end;

constructor TScriptMovementPoint.Create(AX, AY: Single; ASpeed: Double);
begin
  inherited Create;
  Target.X := AX;
  Target.Y := AY;
  Speed := ASpeed;
end;

{ TActor }

function TActor.GetPPos: zglPPoint2D;
begin
  Result := @FPos;
end;

function TActor.GetX: Single;
begin
  Result := FPos.X;
end;

function TActor.GetY: Single;
begin
  Result := FPos.Y;
end;

procedure TActor.SetScriptMovement(AValue: Boolean);
begin
  if FScriptMovementEnabled = AValue then Exit;
  FScriptMovementEnabled := AValue;
  FMovementFinished := not AValue;

  if AValue then begin
    CurrentScriptPoint := ScriptMovement.Head as TScriptMovementPoint;
    CalculateMovement;
  end;
end;

procedure TActor.SetX(AValue: Single);
begin
  if FPos.X = AValue then Exit;
  FPos.X := AValue;
  //Drawable.X := AValue;
end;

procedure TActor.SetY(AValue: Single);
begin
  if FPos.Y = AValue then Exit;
  FPos.Y := AValue;
  //Drawable.Y := AValue;
end;

procedure TActor.CalculateMovement;
var
  R: Single;
begin
  if not Assigned(CurrentScriptPoint) then
    Exit;

  R := Sqrt(Sqr(FPos.X - CurrentScriptPoint.Target.X) +
            Sqr(FPos.Y - CurrentScriptPoint.Target.Y));
  ScriptMovementStart := Time;
  ScriptMovementLen := 1000 * R / CurrentScriptPoint.Speed;
  ScriptMovementVector.X := (CurrentScriptPoint.Target.X - FPos.X) / ScriptMovementLen;
  ScriptMovementVector.Y := (CurrentScriptPoint.Target.Y - FPos.Y) / ScriptMovementLen;
end;

procedure TActor.NextScriptPoint;
begin
  if not Assigned(CurrentScriptPoint) then
    Exit;

  CurrentScriptPoint := CurrentScriptPoint.Next as TScriptMovementPoint;
  //ScriptMovement.Remove(ScriptMovement.Head as TScriptMovementPoint);

  if Assigned(CurrentScriptPoint) then begin
    CalculateMovement;
  end else begin
    FMovementFinished := True;
    FScriptMovementEnabled := False;
    if Assigned(OnScriptedMovementFinish) then
      OnScriptedMovementFinish(Self);
  end;
end;

constructor TActor.Create(AName: String; ADrawable: TDrawable);
begin
  Time := 0;
  FPos.X := 0;
  FPos.Y := 0;
  FName := AName;
  Drawable := ADrawable;
  Drawable.AttachPos(@FPos);
  ScriptMovement := TSimpleList.Create;
end;

destructor TActor.Destroy;
begin
  if Assigned(Drawable) then
    Drawable.Free;
  ScriptMovement.Free;
  inherited Destroy;
end;

procedure TActor.Tick(DT: Double);
begin
  Time += DT;

  // Movement
  if FScriptMovementEnabled then begin
    FPos.X += ScriptMovementVector.X * DT;
    FPos.Y += ScriptMovementVector.Y * DT;
    if Time >= ScriptMovementStart + ScriptMovementLen then begin
      FPos.X := CurrentScriptPoint.Target.X;
      FPos.Y := CurrentScriptPoint.Target.Y;
      NextScriptPoint;
    end;
  end;
end;

procedure TActor.MoveTo(AX, AY: Single);
begin
  SetX(AX);
  SetY(AY);
end;

procedure TActor.Move(DX, DY: Single);
begin
  MoveTo(FPos.X + DX, FPos.Y + DY);
end;

procedure TActor.AddScriptMovementPoint(AX, AY: Single; ASpeed: Double);
begin
  ScriptMovement.Insert(TScriptMovementPoint.Create(AX, AY, ASpeed));
end;

procedure TActor.ClearScriptMovement;
begin
  ScriptMovement.Clear;
end;

end.

