unit drawables_lua;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, drawables, lua, resources;

function Drawable_MoveTo(State: Plua_State): Integer; cdecl;
function Sprite_Create(State: Plua_State): Integer; cdecl;
procedure RegisterFunctions(State: Plua_State);

implementation

function Drawable_MoveTo(State: Plua_State): Integer; cdecl;
var
  x, y: Single;
  drawable: TDrawable;
begin
  // 2: X [single]
  // 3: Y [single]

  drawable := TDrawable(Pointer(lua_tointeger(State, 1)));
  x := lua_tonumber(State, 2);
  y := lua_tonumber(State, 3);
  lua_pop(State, 2);

  drawable.MoveTo(x, y);
end;

function Sprite_Create(State: Plua_State): Integer; cdecl;
var
  res: TResSprite;
begin
  // 1: Resource [pointer to TResSprite]

  res := TResSprite(Pointer(lua_tointeger(State, 1)));
  lua_pop(State, 1);

  lua_pushinteger(State, lua_Integer(Pointer(TSprite.Create(res))));
  Result := 1;
end;

procedure RegisterFunctions(State: Plua_State);
begin
  // Creating a table
  lua_newtable(State);
  // Pushing functions into it
  lua_pushcfunction(State, @Drawable_MoveTo);
  lua_setfield(State, -2, 'moveTo');
  // Pushing table into global environment
  lua_setglobal(State, 'drawable');

  // Creating a table
  lua_newtable(State);
  // Pushing functions into it
  lua_pushcfunction(State, @Sprite_Create);
  lua_setfield(State, -2, 'create');
  // Pushing table into global environment
  lua_setglobal(State, 'sprite');
end;

end.

