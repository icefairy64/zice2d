unit resources;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, simplelist, contnrs, zglHeader, DOM, XMLRead;

type
  TResource = class(TListItem)
    Name: String;

    constructor Create(Filename: String); virtual;
  end;

  TResSprite = class(TResource)
    Width: Word;
    Height: Word;
    Cols: Word;
    Rows: Word;
    FrameStart: array of LongWord;
    Animated: Boolean;
    Texture: zglPTexture;

    constructor Create(Filename: String); override;
    constructor CreateFromImage(Filename: String);
    destructor Destroy; override;
  end;

  TResManager = class
    List: TSimpleList;
    HashedList: TFPHashList;
    Count: LongWord;

    constructor Create;
    destructor Destroy; override;
    procedure Insert(Item: TResource);
    function AddSprite(Filename: String): TResSprite;
    procedure Remove(Item: TResource);
  end;

implementation

// TResource

constructor TResource.Create(Filename: String);
begin
  inherited Create;
  Name := ExtractFileName(Filename);
end;

// TResSprite

constructor TResSprite.Create(Filename: String);
var
  xml: TXMLDocument;
  root: TDOMElement;
  point: TDOMNode;
  dir, fn: String;
  i, pr: LongInt;
begin
  if LowerCase(ExtractFileExt(Filename)) <> '.zi2dspr' then begin
    CreateFromImage(Filename);
    Exit;
  end;
  inherited Create(Filename);
  dir := IncludeTrailingPathDelimiter(ExtractFileDir(Filename));
  fn := ExtractFileName(Filename);
  fn := LeftStr(fn, Length(fn) - Length(ExtractFileExt(fn)));
  ReadXMLFile(xml, Filename);
  root := xml.DocumentElement;
  // Reading params
  point := root.FindNode('params');
  Cols := StrToInt(point.Attributes.GetNamedItem('cols').TextContent);
  Rows := StrToInt(point.Attributes.GetNamedItem('rows').TextContent);
  Animated := point.Attributes.GetNamedItem('animated').TextContent = '1';
  SetLength(FrameStart, Cols * Rows + 1);
  FrameStart[0] := 0;
  // Loading texture
  point := root.FindNode('texture');
  Texture := tex_LoadFromFile(dir + Format(point.Attributes.GetNamedItem('filename').TextContent, [fn]));
  Width := Texture^.Width div Cols;
  Height := Texture^.Height div Rows;
  // Managing frames
  point := root.FindNode('frames');
  pr := 0;
  tex_SetFrameSize(Texture, Width, Height);
  for i := 0 to Cols * Rows - 1 do begin
    FrameStart[i + 1] := pr + StrToInt(point.ChildNodes.Item[i].Attributes.GetNamedItem('delay').TextContent);
    pr := FrameStart[i + 1];
  end;
  xml.Free;
end;

constructor TResSprite.CreateFromImage(Filename: String);
begin
  inherited Create(Filename);
  Cols := 1;
  Rows := 1;
  Animated := False;
  Texture := tex_LoadFromFile(Filename);
  Width := Texture^.Width;
  Height := Texture^.Height;
end;

destructor TResSprite.Destroy;
begin
  tex_Del(Texture);
  inherited Destroy;
end;

// TResManager

constructor TResManager.Create;
begin
  inherited Create;
  Count := 0;
  List := TSimpleList.Create;
  HashedList := TFPHashList.Create;
end;

destructor TResManager.Destroy;
begin
  HashedList.Free;
  List.Free;
end;

procedure TResManager.Insert(Item: TResource);
begin
  List.Insert(Item);
  HashedList.Add(Item.Name, Item);
  Count += 1;
end;

function TResManager.AddSprite(Filename: String): TResSprite;
begin
  Result := TResSprite.Create(Filename);
  Insert(Result);
end;

procedure TResManager.Remove(Item: TResource);
begin
  if not Assigned(Item) then
    Exit;
  HashedList.Remove(Item);
  List.Remove(Item);
  Count -= 1;
end;

end.

