unit layers_lua;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, layers, drawables, lua;

function Layer_Create(State: Plua_State): Integer; cdecl;
function Layer_InsertDrawable(State: Plua_State): Integer; cdecl;
procedure RegisterFunctions(State: Plua_State);

implementation

function Layer_Create(State: Plua_State): Integer; cdecl;
var
  w, h: Word;
  name: String;
begin
  // 1: Name   [string]
  // 2: Width  [uint]
  // 3: Height [uint]

  name := lua_tostring(State, 1);
  w := lua_tointeger(State, 2);
  h := lua_tointeger(State, 3);
  lua_pop(State, 3);

  lua_pushinteger(State, lua_Integer(Pointer(TLayer.Create(name, w, h))));
  Result := 1;
end;

function Layer_InsertDrawable(State: Plua_State): Integer; cdecl;
var
  layer: TLayer;
  drawable: TDrawable;
  ordered: Boolean;
begin
  // 1: Layer
  // 2: Drawable
  // 3: Ordered  [bool, optional]

  layer := TLayer(Pointer(lua_tointeger(State, 1)));
  drawable := TDrawable(Pointer(lua_tointeger(State, 2)));
  if lua_gettop(State) > 2 then
    ordered := lua_toboolean(State, 3)
  else
    ordered := False;
  lua_pop(State, lua_gettop(State));

  layer.InsertDrawable(Drawable, ordered);
end;

procedure RegisterFunctions(State: Plua_State);
begin
  // Creating a table
  lua_newtable(State);
  // Pushing functions into it
  lua_pushcfunction(State, @Layer_Create);
  lua_setfield(State, -2, 'create');
  lua_pushcfunction(State, @Layer_InsertDrawable);
  lua_setfield(State, -2, 'insertDrawable');
  // Pushing table into global environment
  lua_setglobal(State, 'layer');
end;

end.

