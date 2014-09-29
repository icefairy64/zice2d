unit layers;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, zglHeader, simplelist, drawables;

type

  { TLayer }

  TLayer = class(TListItem)
    Name: String;
    Drawables: TDrawableList;
    Target: zglPRenderTarget;
    Width: Word;
    Height: Word;
    Alpha: Byte;
    FX: LongWord;
    Blend: Byte;
    constructor Create(AName: String; AWidth, AHeight: Word);
    destructor Destroy; override;
    procedure InsertDrawable(ADrawable: TDrawable; Ordered: Boolean = False);
    procedure Draw(Buffer: zglPRenderTarget);
  end;

implementation

// TLayer

constructor TLayer.Create(AName: String; AWidth, AHeight: Word);
begin
  inherited Create;
  Name := AName;
  Width := AWidth;
  Height := AHeight;
  Alpha := $FF;
  FX := FX_BLEND;
  Blend := FX_BLEND_NORMAL;
  Target := rtarget_Add(tex_CreateZero(Width, Height), RT_DEFAULT);
  Drawables := TDrawableList.Create;
end;

destructor TLayer.Destroy;
begin
  rtarget_Del(Target);
  inherited Destroy;
end;

procedure TLayer.InsertDrawable(ADrawable: TDrawable; Ordered: Boolean);
begin
  if Ordered then
    Drawables.InsertOrdered(ADrawable)
  else
    Drawables.Insert(ADrawable);
end;

procedure TLayer.Draw(Buffer: zglPRenderTarget);
var
  drawable: TDrawable;
begin
  rtarget_Set(Target);

  drawable := TDrawable(Drawables.Head);
  while Assigned(drawable) do begin
    drawable.Render;
    drawable := TDrawable(drawable.Next);
  end;

  rtarget_Set(Buffer);
  fx_SetBlendMode(Blend);
  ssprite2d_Draw(Target^.Surface, 0, 0, Width, Height, 0, Alpha, FX);
  fx_SetBlendMode(FX_BLEND_NORMAL);
end;

end.

