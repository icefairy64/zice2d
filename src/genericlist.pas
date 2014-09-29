unit genericlist;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, simplelist;

type

  { TGenericListItem }

  generic TGenericListItem<T> = class(TSimpleList)
    type
      TI = specialize TGenericListItem<T>;

    private
      procedure SetTypedPrev(AValue: T);

    public
      property TypedPrev: TI read FTypedPrev write SetTypedPrev;
  end;

implementation

{ TGenericListItem }

procedure TGenericListItem.SetTypedPrev(AValue: T);
begin
  if FTypedPrev = AValue then Exit;
  FTypedPrev := AValue;
end;

end.

