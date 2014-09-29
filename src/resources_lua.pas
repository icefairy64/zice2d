unit resources_lua;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, resources, lua;

function Resource_LoadSprite(State: Plua_State): Integer; cdecl;
procedure RegisterFunctions(State: Plua_State);

implementation

function Resource_LoadSprite(State: Plua_State): Integer; cdecl;
var
  filename: String;
begin
  // 1: Filename [string]

  filename := lua_tostring(State, 1);
  lua_pop(State, 1);

  lua_pushinteger(State, lua_Integer(Pointer(TResSprite.Create(Filename))));
  Result := 1;
end;

procedure RegisterFunctions(State: Plua_State);
begin
  // Creating a table
  lua_newtable(State);
  // Pushing functions into it
  lua_pushcfunction(State, @Resource_LoadSprite);
  lua_setfield(State, -2, 'loadSprite');
  // Pushing table into global environment
  lua_setglobal(State, 'resource');
end;

end.

