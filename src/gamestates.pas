unit gamestates;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, timer, messenger;

const
  GAMESTATE_RETURN = MSGTYPE_GAMESTATE + $0000;

type
  TGameState = class(TInterfacedObject, IMsgNode)
    protected
      procedure DoUpdate(DT: Double); virtual; abstract;

    public
      Prev: TGameState;
      Next: TGameState;

      procedure Update(DT: Double);
      procedure ReceiveMsg(Sender: IMsgNode; Head: Word; Data: Pointer); virtual;
  end;

implementation

// TGameState

procedure TGameState.Update(DT: Double);
begin
  if Assigned(Next) then
    Next.Update(DT)
  else
    DoUpdate(DT);
end;

procedure TGameState.ReceiveMsg(Sender: IMsgNode; Head: Word; Data: Pointer);
begin
  if Head = GAMESTATE_RETURN then
    FreeAndNil(Prev);
end;

end.

