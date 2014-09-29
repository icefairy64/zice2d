unit screen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, drawables, layers, timer, simplelist, contnrs, zglHeader;

type
  TRenderer = class(TInterfacedObject, ITickable)
    Layers: TSimpleList;
    Buffer: zglPRenderTarget;
    Width: LongWord;
    Height: LongWord;
    Time: Double;

    constructor Create(ABuffer: zglPRenderTarget); virtual;
    procedure Tick(DT: Double); virtual;
    procedure Render; virtual;
  end;

implementation

// TRenderer

constructor TRenderer.Create(ABuffer: zglPRenderTarget);
begin
  Time := 0;
  Buffer := ABuffer;
  Layers := TSimpleList.Create;
end;

procedure TRenderer.Tick(DT: Double);
begin
  Time += DT;
end;

procedure TRenderer.Render;
var
  layer: TLayer;
begin
  layer := TLayer(Self.Layers.Head);
  while Assigned(layer) do begin
    layer.Draw(Buffer);
    layer := TLayer(layer.Next);
  end;

  rtarget_Set(nil);
  //ssprite2d_Draw(Buffer^.Surface, 0, 0, Width, Height, 0);
end;

end.

