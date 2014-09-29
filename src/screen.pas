unit screen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, drawables, layers, timer, simplelist, contnrs, zglHeader;

type

  { TRenderer }

  TRenderer = class(TInterfacedObject, ITickable)
    Layers: TSimpleList;
    HashedLayers: TFPHashList;
    Buffer: zglPRenderTarget;
    Width: LongWord;
    Height: LongWord;
    Time: Double;

    constructor Create(ABuffer: zglPRenderTarget); virtual;
    destructor Destroy; override;
    procedure Tick(DT: Double); virtual;
    procedure Render; virtual;
    function InsertLayer(ALayer: TLayer): TLayer;
    function CreateLayer(Name: String): TLayer;
  end;

procedure InitRenderer(Width, Height: LongWord);

var
  GlobalRenderer: TRenderer;

implementation

// Helpers

procedure InitRenderer(Width, Height: LongWord);
begin
  GlobalRenderer := TRenderer.Create(rtarget_Add(tex_CreateZero(Width, Height), RT_DEFAULT));
  GlobalRenderer.Width  := Width;
  GlobalRenderer.Height := Height;
end;

// TRenderer

constructor TRenderer.Create(ABuffer: zglPRenderTarget);
begin
  Time := 0;
  Buffer := ABuffer;
  Layers := TSimpleList.Create;
  HashedLayers := TFPHashList.Create;
end;

destructor TRenderer.Destroy;
begin
  Layers.Free;
  rtarget_Del(Buffer);
  inherited Destroy;
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

function TRenderer.InsertLayer(ALayer: TLayer): TLayer;
begin
  Layers.Insert(ALayer);
  HashedLayers.Add(ALayer.Name, ALayer);
  Result := ALayer;
end;

function TRenderer.CreateLayer(Name: String): TLayer;
begin
  Result := InsertLayer(TLayer.Create(Name, Width, Height));
end;

end.

