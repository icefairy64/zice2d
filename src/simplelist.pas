unit simplelist;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  ENilItem = class(Exception)

  end;

  { TListItem }

  TListItem = class(TInterfacedObject)
    private
      function FGetNext: TListItem;
      function FGetPrev: TListItem;
      procedure FSetNext(Item: TListItem);
      procedure FSetPrev(Item: TListItem);
    protected
      FNext: TListItem;
      FPrev: TListItem;
    public
      property Next: TListItem read FGetNext write FSetNext;
      property Prev: TListItem read FGetPrev write FSetPrev;
      constructor Create;
      destructor Destroy; override;
      procedure SetNext(Item: TListItem);
      procedure SetPrev(Item: TListItem);
  end;

  { TSimpleList }

  TSimpleList = class
    Head: TListItem;
    Tail: TListItem;

    constructor Create;
    destructor Destroy; override;
    procedure InsertAt(Point: TListItem; Item: TListItem);
    function Insert: TListItem; virtual;
    function Insert(Item: TListItem): TListItem; virtual;
    procedure Remove(Item: TListItem; DoFree: Boolean = True);
    procedure Clear(DoFree: Boolean = True);
  end;

implementation

// TListItem

constructor TListItem.Create;
begin
  inherited Create;
  FNext := nil;
  FPrev := nil;
end;

destructor TListItem.Destroy;
begin
  if Assigned(FNext) then
    FNext.Prev := FPrev
  else if Assigned(FPrev) then
    FPrev.Next := FNext;
  inherited Destroy;
end;

function TListItem.FGetNext: TListItem;
begin
  Result := FNext;
end;

function TListItem.FGetPrev: TListItem;
begin
  Result := FPrev;
end;

procedure TListItem.FSetNext(Item: TListItem);
begin
  FNext := Item;
  if Assigned(Item) then
    Item.SetPrev(Self);
end;

procedure TListItem.FSetPrev(Item: TListItem);
begin
  FPrev := Item;
  if Assigned(Item) then
    Item.SetNext(Self);
end;

procedure TListItem.SetNext(Item: TListItem);
begin
  FNext := Item;
end;

procedure TListItem.SetPrev(Item: TListItem);
begin
  FPrev := Item;
end;

// TSimpleList

constructor TSimpleList.Create;
begin
  inherited Create;
  Head := nil;
  Tail := nil;
end;

destructor TSimpleList.Destroy;
var
  point, last: TListItem;
begin
  point := Head;
  last := nil;
  while Assigned(point) do begin
    last := point;
    point := point.Next;
    Remove(last);
  end;
  inherited Destroy;
end;

procedure TSimpleList.InsertAt(Point: TListItem; Item: TListItem);
begin
  if not Assigned(Point) then
    raise ENilItem.Create('Trying to insert non-existing item');
  Item.Next := Point.Next;
  Item.Prev := Point;
end;

function TSimpleList.Insert: TListItem;
begin
  Result := TListItem.Create;
  Result.Prev := Tail;
  Tail := Result;
  if Head = nil then
    Head := Result;
end;

function TSimpleList.Insert(Item: TListItem): TListItem;
begin
  if not Assigned(Item) then
    raise ENilItem.Create('Trying to insert non-existing item');
  Result := Item;
  Result.Prev := Tail;
  Tail := Result;
  if Head = nil then
    Head := Result;
end;

procedure TSimpleList.Remove(Item: TListItem; DoFree: Boolean);
begin
  if not Assigned(Item) then
    raise ENilItem.Create('Trying to remove non-existing item');
  if Assigned(Item.Next) then
    Item.Next.Prev := Item.Prev
  else if Assigned(Item.Prev) then
    Item.Prev.Next := Item.Next;
  if Head = Item then
    Head := nil;
  if Tail = Item then
    Tail := nil;
  if DoFree then
    Item.Free;
end;

procedure TSimpleList.Clear(DoFree: Boolean);
var
  point, prev: TListItem;
begin
  point := Head;
  while Assigned(point) do begin
    prev := point;
    point := point.Next;
    Remove(prev);
  end;
end;

end.

