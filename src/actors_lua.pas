unit actors_lua;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, actors, lua;

function Actor_AddScriptMovementPoint(State: Plua_State): Integer; cdecl;
function Actor_EnableScriptMovement(State: Plua_State): Integer; cdecl;
function Actor_WaitForScriptFinish(State: Plua_State): Integer; cdecl;
function Actor_ClearScript(State: Plua_State): Integer; cdecl;
procedure RegisterFunctions(State: Plua_State);

implementation

function Actor_AddScriptMovementPoint(State: Plua_State): Integer; cdecl;
var
  instance: TActor;
  x, y: Single;
  speed: Double;
begin
  // 1: Instance [pointer to TActor]
  // 2: X        [single]
  // 3: Y        [single]
  // 4: Speed    [double]

  instance := TActor(Pointer(lua_tointeger(State, 1)));
  x := lua_tonumber(State, 2);
  y := lua_tonumber(State, 3);
  speed := lua_tonumber(State, 4);

  instance.AddScriptMovementPoint(x, y, speed);
end;

function Actor_EnableScriptMovement(State: Plua_State): Integer; cdecl;
var
  instance: TActor;
begin
  // 1: Instance [pointer to TActor]

  instance := TActor(Pointer(lua_tointeger(State, 1)));
  instance.ScriptMovementEnabled := True;
end;

function Actor_WaitForScriptFinish(State: Plua_State): Integer; cdecl;
var
  instance: TActor;
begin
  // 1: Instance [pointer to TActor]
  // Warning: call from separate thread!

  instance := TActor(Pointer(lua_tointeger(State, 1)));
  while not instance.IsMovementFinished do
    Sleep(10);
end;

function Actor_ClearScript(State: Plua_State): Integer; cdecl;
var
  instance: TActor;
begin
  // 1: Instance [pointer to TActor]

  instance := TActor(Pointer(lua_tointeger(State, 1)));
  instance.ClearScriptMovement;
end;

procedure RegisterFunctions(State: Plua_State);
begin
  // Creating a table
  lua_newtable(State);
  // Pushing functions into it
  lua_pushcfunction(State, @Actor_AddScriptMovementPoint);
  lua_setfield(State, -2, 'addScriptMovementPoint');
  lua_pushcfunction(State, @Actor_EnableScriptMovement);
  lua_setfield(State, -2, 'enableScriptMovement');
  lua_pushcfunction(State, @Actor_WaitForScriptFinish);
  lua_setfield(State, -2, 'waitForScriptFinish');
  lua_pushcfunction(State, @Actor_ClearScript);
  lua_setfield(State, -2, 'clearScript');
  // Pushing table into global
  lua_setglobal(State, 'actor');
end;

end.

