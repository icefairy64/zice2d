unit gamestates;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, timer, messenger, actors, simplelist, drawables;

const
  GAMESTATE_RETURN = MSGTYPE_GAMESTATE + $0000;

type

  { TGameState }

  TGameState = class(TInterfacedObject, IMsgNode, ITickable)
    protected
      Actors: TSimpleList;

      procedure DoUpdate(DT: Double); virtual;

    public
      Prev: TGameState;
      Next: TGameState;

      procedure Tick(DT: Double);
      procedure ReceiveMsg(Sender: IMsgNode; Head: Word; Data: Pointer); virtual;
      function InsertActor(Actor: TActor): TActor;
      function CreateActor(Name: String; Drawable: TDrawable): TActor;
  end;

implementation

// TGameState

procedure TGameState.DoUpdate(DT: Double);
var
  point: TActor;
begin
  point := Actors.Head as TActor;
  while Assigned(point) do begin
    point.Tick(DT);
    point := point.Next as TActor;
  end;
end;

procedure TGameState.Tick(DT: Double);
begin
  if Assigned(Next) then
    Next.Tick(DT)
  else
    DoUpdate(DT);
end;

procedure TGameState.ReceiveMsg(Sender: IMsgNode; Head: Word; Data: Pointer);
begin
  if Head = GAMESTATE_RETURN then
    FreeAndNil(Prev);
end;

function TGameState.InsertActor(Actor: TActor): TActor;
begin
  Actors.Insert(Actor);
  Result := Actor;
end;

function TGameState.CreateActor(Name: String; Drawable: TDrawable): TActor;
begin
  Result := InsertActor(TActor.Create(Name, Drawable));
end;

end.

