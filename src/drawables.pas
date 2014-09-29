unit drawables;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, zglHeader, simplelist, resources, timer;

type
  TDrawable = class(TListItem)
    Pos: zglPPoint2D;
    ZOrder: Integer;
    Scale: Double;
    Angle: Double;
    Alpha: Byte;
    FX: LongWord;
    Blend: Byte;

    constructor Create;
    //constructor Create(ALayer: TLayer);
    procedure Init(AX, AY: Double; AAlpha: Byte = $FF; AScale: Double = 1.0; ABlend: Byte = FX_BLEND_NORMAL; AFX: LongWord = FX_BLEND);
    procedure MoveTo(AX, AY: Double);
    procedure Render;
    procedure AttachPos(Target: zglPPoint2D);

    protected
      procedure Draw; virtual; abstract;
  end;

  TDrawableList = class(TSimpleList)
    function InsertOrdered(Item: TDrawable): TDrawable;
  end;

  { TSprite }

  TSprite = class(TDrawable, ITickable)
    private
      FFrame: Word;
      Time: Double;

      procedure SetFrame(AFrame: Word);
      function GetFrame: Word;
      procedure Draw; override;

    public
      Source: TResSprite;
      AnimSpeed: Double;
      property Frame: Word read GetFrame write SetFrame;

      constructor Create(ARes: TResSprite);
      procedure Tick(DT: Double);
      procedure SetResource(ARes: TResSprite);
  end;

implementation

// TDrawable

constructor TDrawable.Create;
begin
  inherited Create;
  Pos := GetMem(SizeOf(zglTPoint2D));
  Pos^.X := 0;
  Pos^.Y := 0;
  ZOrder := 0;
  Scale := 1;
  Angle := 0;
  Alpha := $FF;
  Blend := FX_BLEND_NORMAL;
  FX := FX_BLEND;
end;

{constructor TDrawable.Create(ALayer: TLayer);
begin
  Create;
  Layer := ALayer;
end;}

procedure TDrawable.Init(AX, AY: Double; AAlpha: Byte; AScale: Double; ABlend: Byte; AFX: LongWord);
begin
  //Layer := ALayer;
  MoveTo(AX, AY);
  Alpha := AAlpha;
  Scale := AScale;
  FX := AFX;
  Blend := ABlend;
end;

procedure TDrawable.MoveTo(AX, AY: Double);
begin
  Pos^.X := AX;
  Pos^.Y := AY;
end;

procedure TDrawable.Render;
begin
  fx_SetBlendMode(Blend);
  //rtarget_Set(Layer.Target);
  Draw;
  fx_SetBlendMode(FX_BLEND_NORMAL);
end;

procedure TDrawable.AttachPos(Target: zglPPoint2D);
begin
  if Assigned(Pos) then
    FreeMem(Pos);
  Pos := Target;
end;

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

// TSprite

procedure TSprite.Tick(DT: Double);
begin
  Time += DT;
  if Time >= Source.FrameStart[Frame + 1] then begin
    FFrame += 1;
    if FFrame >= Source.Cols * Source.Rows then begin
      FFrame := 0;
      Time -= Source.FrameStart[Source.Cols * Source.Rows];
    end;
  end;
end;

procedure TSprite.SetResource(ARes: TResSprite);
begin
  Source := ARes;
  SetFrame(0);
end;

procedure TSprite.Draw;
var
  rscale: Double;
begin
  rscale := (Scale - 1) / 2;
  asprite2d_Draw(Source.Texture,
                 Pos^.X - Source.Width * rscale,
                 Pos^.Y - Source.Height * rscale,
                 Source.Width * Scale,
                 Source.Height * Scale,
                 Angle,
                 FFrame,
                 Alpha,
                 FX);
end;

constructor TSprite.Create(ARes: TResSprite);
begin
  inherited Create;
  Source := ARes;
end;

procedure TSprite.SetFrame(AFrame: Word);
begin
  FFrame := AFrame;
  Time := Source.FrameStart[AFrame];
end;

function TSprite.GetFrame: Word;
begin
  Result := FFrame;
end;

end.

