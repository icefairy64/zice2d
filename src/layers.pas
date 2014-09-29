unit layers;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, zglHeader, simplelist;

type
  TLayer = class(TListItem)
    Name: String;
    Target: zglPRenderTarget;
    Width: Word;
    Height: Word;
    Alpha: Byte;
    FX: LongWord;
    Blend: Byte;
    constructor Create(AName: String; AWidth, AHeight: Word);
    destructor Destroy; override;
    procedure Draw;
  end;

implementation

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
end;

destructor TLayer.Destroy;
begin
  rtarget_Del(Target);
  inherited Destroy;
end;

procedure TLayer.Draw;
begin
  fx_SetBlendMode(Blend);
  ssprite2d_Draw(Target^.Surface, 0, 0, Width, Height, 0, Alpha, FX);
  fx_SetBlendMode(FX_BLEND_NORMAL);
end;

end.

