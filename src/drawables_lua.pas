unit drawables_lua;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, drawables, lua, resources, layers;

function Sprite_Create(State: Plua_State): Integer; cdecl;
procedure RegisterFunctions(State: Plua_State);

implementation

function Sprite_Create(State: Plua_State): Integer; cdecl;
var
  res: TResSprite;
  layer: TLayer;
begin
  // 1: Resource [pointer to TResSprite]
  // 2: Layer    [pointer to TLayer]

  res := TResSprite(Pointer(lua_tointeger(State, 1)));
  layer := TLayer(Pointer(lua_tointeger(State, 2)));
  lua_pop(State, 2);

  lua_pushinteger(State, lua_Integer(Pointer(TSprite.Create(layer, res))));
  Result := 1;
end;

procedure RegisterFunctions(State: Plua_State);
begin
  // Creating a table
  lua_newtable(State);
  // Pushing functions into it
  lua_pushcfunction(State, @Sprite_Create);
  lua_setfield(State, -2, 'create');
  // Pushing table into global environment
  lua_setglobal(State, 'sprite');
end;

end.

