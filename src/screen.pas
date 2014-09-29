unit screen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, drawables, layers, timer, simplelist, contnrs, zglHeader;

type
  TDrawableList = class(TSimpleList)
    function InsertOrdered(Item: TDrawable): TDrawable;
  end;

  TRenderer = class(TInterfacedObject, ITickable)
    Layers: TSimpleList;
    Drawables: TDrawableList;
    HashedDrawables: TFPHashList;
    Buffer: zglPRenderTarget;
    Width: LongWord;
    Height: LongWord;
    Time: Double;

    constructor Create(ABuffer: zglPRenderTarget); virtual;
    procedure Tick(DT: Double); virtual;
    procedure Render; virtual;
  end;

implementation

// TDrawableList

function TDrawableList.InsertOrdered(Item: TDrawable): TDrawable;
var
  point: TDrawable;
begin
  Result := Item;
  point := TDrawable(Head);

  while Assigned(point) and (point.ZOrder <= Item.ZOrder) do
    point := TDrawable(point.Next);

  if not Assigned(point) then
    Insert(Item)
  else
    InsertAt(point, Item);
end;

// TRenderer

constructor TRenderer.Create(ABuffer: zglPRenderTarget);
begin
  Time := 0;
  Buffer := ABuffer;
  Drawables := TDrawableList.Create;
  Layers := TSimpleList.Create;
  HashedDrawables := TFPHashList.Create;
end;

procedure TRenderer.Tick(DT: Double);
begin
  Time += DT;
end;

procedure TRenderer.Render;
var
  layer: TLayer;
  drawable: TDrawable;
begin
  drawable := TDrawable(Self.Drawables.Head);
  while Assigned(drawable) do begin
    drawable.Render;
    drawable := TDrawable(drawable.Next);
  end;

  layer := TLayer(Self.Layers.Head);
  while Assigned(layer) do begin
    rtarget_Set(Buffer);
    layer.Draw;
    layer := TLayer(layer.Next);
  end;

  rtarget_Set(nil);
  //ssprite2d_Draw(Buffer^.Surface, 0, 0, Width, Height, 0);
end;

end.

