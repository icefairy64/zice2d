unit screen_lua;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, screen, lua, layers;

function Renderer_CreateLayer(State: Plua_State): Integer; cdecl;
procedure RegisterFunctions(State: Plua_State);

implementation

function Renderer_CreateLayer(State: Plua_State): Integer; cdecl;
var
  name: String;
begin
  // 1: Name [string]

  name := lua_tostring(State, 1);
  lua_pop(State, 1);

  lua_pushinteger(State, lua_Integer(Pointer(GlobalRenderer.CreateLayer(name))));
  Result := 1;
end;

procedure RegisterFunctions(State: Plua_State);
begin
  // Creating a table
  lua_newtable(State);
  // Pushing functions into it
  lua_pushcfunction(State, @Renderer_CreateLayer);
  lua_setfield(State, -2, 'createLayer');
  // Pushing table into global environment
  lua_setglobal(State, 'renderer');
end;

end.

