unit storage_lua;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, storage, lua;

function Storage_Set(State: Plua_State): Integer; cdecl;
function Storage_Get(State: Plua_State): Integer; cdecl;
procedure RegisterFunctions(State: Plua_State);

implementation

function Storage_Set(State: Plua_State): Integer; cdecl;
var
  name: String;
  value: LongInt;
begin
  // 1: Name  [string]
  // 2: Value [int]

  name := lua_tostring(State, 1);
  value := lua_tointeger(State, 2);

  GlobalStorage.SetValue(Name, Value);
end;

function Storage_Get(State: Plua_State): Integer; cdecl;
var
  name: String;
begin
  // 1: Name  [string]

  name := lua_tostring(State, 1);
  lua_pop(State, 1);

  lua_pushinteger(State, GlobalStorage.GetValue(Name));
  Result := 1;
end;

procedure RegisterFunctions(State: Plua_State);
begin
  // Creating a table
  lua_newtable(State);
  // Pushing functions into it
  lua_pushcfunction(State, @Storage_Get);
  lua_setfield(State, -2, 'get');
  lua_pushcfunction(State, @Storage_Set);
  lua_setfield(State, -2, 'set');
  // Pushing table into global environment
  lua_setglobal(State, 'storage');
end;

end.

