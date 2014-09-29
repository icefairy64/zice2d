unit primitives;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, zglHeader, drawables;

type
  TRectangle = class(TDrawable)
    W: Double;
    H: Double;
    Color: LongWord;

    procedure SetDimensions(AW, AH: Double);

    private
      procedure Draw; override;
  end;

implementation

// TRectangle

procedure TRectangle.SetDimensions(AW, AH: Double);
begin
  W := AW;
  H := AH;
end;

procedure TRectangle.Draw;
begin
  pr2d_Rect(Pos^.X, Pos^.Y, W, H, Color, Alpha, FX);
end;

end.

