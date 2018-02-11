
{******************************************}
{                                          }
{ MarkOptionItem Add-In Object (FastReport)}
{                                          }
{            Copyright (c) 2017            }
{               by Sony NS,                }
{              CrossoverLab.               }
{                                          }
{******************************************}

unit frxMarkOptionItem;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Menus, frxClass, frxMarkUtils
{$IFDEF FR_COM}
, FastReport_TLB
{$ENDIF}
{$IFDEF Delphi6}
, Variants
{$ENDIF};
  

type
  TfrxMarkOptionItemObject = class(TComponent)  // fake component
  end;

  TfrxMarkOptionItem = class(TfrxView)
  private
    FCellHeader: TfrxCellHeader;
    FCell: TfrxCell;
    //Scale XY
    FCellHHeight: Integer;
    FCellHWidth: Integer;
    FCellHeight: Integer;
    FCellWidth: Integer;
    FCellItems: String;
    FDefaultValues: String;
    FColumnSpace: Integer;
    FFontSize: Integer;
    FFontHeight: Integer;
    FOrientation: TfrxCellOrientation;
    FStripPosition: TfrxStripPosition;
    FStripColor: TColor;
    procedure CalcSize;
    procedure DrawHeader(ACanvas: TCanvas; ARect: TRect);
    procedure DrawCell(ACanvas: TCanvas; ARect: TRect);
    procedure DrawStrip(ACanvas: TCanvas; ARect: TRect);
    procedure SetColumnSpace(const AValue: Integer);
    procedure SetCellHeader(const Value: TfrxCellHeader);
    procedure SetOrientation(const Value: TfrxCellOrientation);
    procedure SetStripColor(const Value: TColor);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Diff(AComponent: TfrxComponent): String; override;
    procedure Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended); override;
    class function GetDescription: String; override;

    property FontSize: Integer read FFontSize write FFontSize;
    property FontHeight: Integer read FFontHeight write FFontHeight;
  published
    //property BrushStyle;
    property CellHeader: TfrxCellHeader read FCellHeader write SetCellHeader;
    property Cell: TfrxCell read FCell write FCell;
    property CellItems: String read FCellItems write FCellItems;
    property ColumnSpace: Integer read FColumnSpace write SetColumnSpace;
    property DefaultValues: String read FDefaultValues write FDefaultValues;
    //property Color;
    //property Cursor;
    property Font;
    property Frame;
    property Orientation: TfrxCellOrientation read FOrientation write SetOrientation;// default orHorizontal;
    property StripPosition: TfrxStripPosition read FStripPosition write FStripPosition default spOdd;
    property StripColor: TColor read FStripColor write SetStripColor;
  end;

implementation

uses frxMarkOptionItemRTTI, frxGraphicUtils, frxUtils, frxDsgnIntf, frxRes,
  frxXML, StrUtils;

procedure TfrxMarkOptionItem.CalcSize;
begin
  if FOrientation = orVertical then
  begin
    Width:= 200;
    Height:= 60;
  end else
  begin
    Height:= 40;
    Width:= 320;
  end;
end;

constructor TfrxMarkOptionItem.Create(AOwner: TComponent);
begin
  inherited;
  FCellHeader:= TfrxCellHeader.Create;
  FCellHeader.VisibleStyle:= False;
  FCellHeader.VisibleText:= False;
  FCellHeader.Visible:= False;
  FCell:= TfrxCell.Create;
  FStripColor:= FCell.StripColor;
  FColumnSpace:= 5;
  //FDefaultValues:= '';
  FFontSize:= 8;
  FCellItems:= 'Option1:Option2:Option3#Option4:Option5:Option6';
  FOrientation:= orHorizontal;
  FStripPosition:= spOdd;

  Frame.Color:= clRed;
  Frame.Typ:= [ftLeft, ftRight, ftTop, ftBottom];

  FCellHHeight:= FCellHeader.Height;
  FCellHWidth:= FCellHeader.Width;
  FCellHeight:= FCell.Height;
  FCellWidth:= FCell.Width;

  CalcSize;
end;

class function TfrxMarkOptionItem.GetDescription: String;
begin
  Result := 'Mark OptionItems';//frxResources.Get('obMarkOptionItem');
end;

procedure TfrxMarkOptionItem.SetCellHeader(const Value: TfrxCellHeader);
begin
  FCellHeader.Assign(Value);
end;

procedure TfrxMarkOptionItem.SetColumnSpace(const AValue: Integer);
begin
  if AValue <> FColumnSpace then
  begin
    if AValue <= 0 then
      FColumnSpace:= 1
    else
      FColumnSpace:= AValue;
  end;
end;

procedure TfrxMarkOptionItem.SetOrientation(const Value: TfrxCellOrientation);
begin
  if Value <> FOrientation then
  begin
    FOrientation:= Value;
  end;
end;

procedure TfrxMarkOptionItem.SetStripColor(const Value: TColor);
begin
  if FStripColor <> Value then
  begin
    FStripColor := Value;
    FCell.StripColor:= FStripColor;
  end;
end;

destructor TfrxMarkOptionItem.Destroy;
begin
  FCellHeader.Free;
  FCell.Free;
  inherited;
end;

function TfrxMarkOptionItem.Diff(AComponent: TfrxComponent): String;
begin
  Result := inherited Diff(AComponent);

  if FCellItems <> TfrxMarkOptionItem(AComponent).FCellItems then
    Result := Result + ' CellItems="' + frxValueToXML(FCellItems) + '"';
  if FColumnSpace <> TfrxMarkOptionItem(AComponent).FColumnSpace then
    Result := Result + ' ColumnSpace="' + frxValueToXML(FColumnSpace) + '"';
  if FDefaultValues <> TfrxMarkOptionItem(AComponent).FDefaultValues then
    Result := Result + ' DefaultValues="' + frxValueToXML(FDefaultValues) + '"';
  if FOrientation <> TfrxMarkOptionItem(AComponent).FOrientation then
    Result := Result + ' Orientation="' + frxValueToXML(FOrientation) + '"';
  if FStripPosition <> TfrxMarkOptionItem(AComponent).FStripPosition then
    Result := Result + ' StripPosition="' + frxValueToXML(FStripPosition) + '"';
end;

procedure TfrxMarkOptionItem.Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX,
  OffsetY: Extended);
begin
  BeginDraw(Canvas, ScaleX, ScaleY, OffsetX, OffsetY);

  DrawBackground;

  FCellHHeight:= Round(FCellHeader.Height * FScaleY);
  FCellHWidth:= Round(FCellHeader.Width * FScaleX);
  FCellHeight:= Round(FCell.Height * FScaleY);
  FCellWidth:= Round(FCell.Width * FScaleX);

  DrawHeader(Canvas, Rect(FX, FY, FX1, FY1));
  DrawFrame;
end;

procedure TfrxMarkOptionItem.DrawCell(ACanvas: TCanvas; ARect: TRect);
var LX, LY, LIdx, LIdy: Integer;
    {$IFDEF Delphi12}
    Sz: TSize;
    LStr, LStrI, LStrD, LStrT: AnsiString;
    {$ELSE}
    LStr, LStrI, LStrD, LStrT: String;
    {$ENDIF}

    function FindDefaultValues(Str: String): String;
    var i: Integer;
        tmp: String;
    begin
      Result:= '';
      i:= 1;
      tmp:= frxRemoveStrByByte(FDefaultValues, ':', i);
      while tmp <> '' do
      begin
        if CompareText(Str, tmp) = 0 then
        begin
          Result:= tmp;
          Break;
        end;
        Inc(i);
        tmp:= frxRemoveStrByByte(FDefaultValues, ':', i);
      end;
    end;
begin
  DrawStrip(ACanvas, ARect);

  with ACanvas do
  begin
    Font:= Self.Font;
    if FOrientation = orHorizontal then
    begin
      LY:= ARect.Top;
      LIdy:= 1;
      repeat
        LStrI:= frxRemoveStrByByte(FCellItems, '#', LIdy);

        LX:= ARect.Left;
        LIdx:= 1;
        repeat
          LStr:= frxRemoveStrByByte(LStrI, ':', LIdx);
          LStrT:= '';
          if LStr <> '' then
          begin
            LStrT:= FindDefaultValues(LStr);
            FCell.DrawOption(ACanvas, Rect(LX, LY, LX + FCellWidth, LY + FCellHeight),
              FCellHeight, FCellWidth, LStrT, FScaleX, FScaleY);

            FCell.DrawText(ACanvas, Rect(LX + FCellWidth + FCell.VerticalSpace, LY,
               LX + FCellWidth + Round(FColumnSpace * FCell.Width * FScaleX),
               LY + FCellHeight + Round(FColumnSpace * FCell.Height * FScaleY)),
               FCell.Height, Round(FColumnSpace * FCell.Width * FScaleX),
               FontSize, LStr, FScaleY);
          end;

          LX:= LX + Round(FColumnSpace * FCell.Width * FScaleX);
          Inc(LIdx);
        until LX > ((ARect.Right - ARect.Left) + ARect.Left - FCellWidth);
        LY:= LY + FCellHeight;
        Inc(LIdy);
      until LY > ((ARect.Bottom - ARect.Top) + ARect.Top - FCellHeight);
    end else
    begin
      LX:= ARect.Left;
      LIdy:= 1;
      repeat
        LStrI:= frxRemoveStrByByte(FCellItems, '#', LIdy);
        LY:= ARect.Top;
        LIdx:= 1;
        repeat
          LStr:= frxRemoveStrByByte(LStrI, ':', LIdx);
          LStrT:= '';
          if LStr <> '' then
          begin
            if Pos(LStr, FDefaultValues) > 0 then
               LStrT:= FDefaultValues;
            FCell.DrawOption(ACanvas, Rect(LX, LY, LX + FCellWidth, LY + FCellHeight),
              FCellHeight, FCellWidth, LStrT, FScaleX, FScaleY);

            FCell.DrawVerticalText(ACanvas,
              Rect(LX, LY + FCellHeight + 2, LX + FCellWidth, LY + FCellHeight),
              FCell.VerticalSpace, Round(FColumnSpace * FCell.Height), FontSize,
              LStr, FScaleY);
          end;

          LY:= LY + FCellHeight;
          Inc(LIdx);
        until LY > ((ARect.Bottom - ARect.Top) + ARect.Top - FCellHeight);
        LX:= LX + Round(FColumnSpace * FCell.Width * FScaleX);
        Inc(LIdy);
      until LX > (((ARect.Right - ARect.Left)) + ARect.Left - FCellWidth);
    end;
  end;
end;

procedure TfrxMarkOptionItem.DrawHeader(ACanvas: TCanvas; ARect: TRect);
var LX, LY, LIdx: Integer;
    {$IFDEF Delphi12}
    Sz: TSize;
    LStr: AnsiString;
    {$ELSE}
    LStr: String;
    {$ENDIF}
begin
  with ACanvas do
  begin
    Brush.Style:= bsClear;
    Pen.Color:= FCellHeader.Color;
    LX:= ARect.Left;
    LY:= ARect.Top;
    LIdx:= 1;//FStartNumber;

    if FOrientation = orVertical then
    begin
      if FCellHeader.Visible then
      begin
        repeat
          if FCellHeader.VisibleStyle then
          begin
            case FCellHeader.HeaderStyle of
             ckBubble:
               Ellipse(LX + FCellHeader.HorizontalSpace,
                 LY + FCellHeader.VerticalSpace,
                 LX + FCellHWidth - FCellHeader.HorizontalSpace,
                 LY + FCellHHeight - FCellHeader.VerticalSpace);
             ckEllipse:
               Ellipse(LX + FCellHeader.HorizontalSpace,
                 LY + 3 + FCellHeader.VerticalSpace,
                 LX + FCellHWidth - FCellHeader.HorizontalSpace,
                 LY + FCellHHeight - FCellHeader.VerticalSpace - 2);
             ckRectangle:
               Rectangle(LX + FCellHeader.HorizontalSpace,
                 LY + FCellHeader.VerticalSpace,
                 LX + FCellHWidth - FCellHeader.HorizontalSpace + 1,
                 LY + FCellHHeight - FCellHeader.VerticalSpace + 1);
            end;
          end else
             DrawLine(LX, LY + FCellHHeight - 1,
               LX + FCellHWidth, LY + FCellHHeight - 1, FFrameWidth);

          if FCellHeader.VisibleText then
          begin
            LStr:= frxIntPad3Str(LIdx);
            Font.Height := - ((LY + FCellHHeight) - LY);
            Font.Size:= 8;
            Font.Color:= FCellHeader.Color;
            SetBkMode(Handle, Transparent);
            {$IFDEF Delphi12}
            GetTextExtentPoint32A(Handle, PAnsiChar(LStr), Length(LStr), Sz);
            ExtTextOutA(ACanvas.Handle, LX + ((LX + FCellHWidth) - LX - Sz.cx) div 2,
              LY + 1, ETO_CLIPPED, @ARect, PAnsiChar(LStr), 3, nil);
            {$ELSE}
            ExtTextOut(Handle, LX + ((LX + FCellHWidth) - LX - TextWidth(LStr)) div 2,
              LY + 1, ETO_CLIPPED, @ARect, PChar(LStr), 3, nil);
            {$ENDIF}
          end;

          LX:= LX + FCellHWidth;
          Inc(LIdx);
        until LX > ((ARect.Right - ARect.Left) + ARect.Left - FCellHWidth);
        DrawCell(ACanvas, Rect(ARect.Left, ARect.Top + FCellHHeight, ARect.Right,
          ARect.Bottom));
      end else
        DrawCell(ACanvas, Rect(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom));
    end else
    begin
      if FCellHeader.Visible then
      begin
        repeat
          if FCellHeader.VisibleStyle then
          begin
            case FCellHeader.HeaderStyle of
             ckBubble:
               Ellipse(LX + FCellHeader.HorizontalSpace,
                 LY + FCellHeader.VerticalSpace,
                 LX + FCellHWidth - FCellHeader.HorizontalSpace,
                 LY + FCellHHeight - FCellHeader.VerticalSpace);
             ckEllipse:
               Ellipse(LX + FCellHeader.HorizontalSpace,
                 LY + 3 + FCellHeader.VerticalSpace,
                 LX + FCellHWidth - FCellHeader.HorizontalSpace,
                 LY + FCellHHeight - FCellHeader.VerticalSpace - 2);
             ckRectangle:
               Rectangle(LX + FCellHeader.HorizontalSpace,
                 LY + FCellHeader.VerticalSpace,
                 LX + FCellHWidth - FCellHeader.HorizontalSpace + 1,
                 LY + FCellHHeight - FCellHeader.VerticalSpace + 1)
             end;
          end else
             DrawLine(LX + FCellHWidth - 1, LY, LX + FCellHWidth - 1,
               LY + FCellHHeight, FFrameWidth);

          if FCellHeader.VisibleText then
          begin
            LStr:= frxIntPad3Str(LIdx);
            Font.Height := - ((LY + FCellHHeight) - LY);
            Font.Size:= 8;
            Font.Color:= FCellHeader.Color;
            SetBkMode(Handle, Transparent);
            {$IFDEF Delphi12}
            GetTextExtentPoint32A(Handle, PAnsiChar(LStr), Length(LStr), Sz);
            ExtTextOutA(Handle, LX + ((LX + FCellHWidth) - LX - Sz.cx) div 2,
              LY + 1, ETO_CLIPPED, @ARect, PAnsiChar(LStr), 3, nil);
            {$ELSE}
            ExtTextOut(Handle, LX + ((LX + FCellHWidth) - LX - TextWidth(LStr)) div 2,
              LY + 1, ETO_CLIPPED, @ARect, PChar(LStr), 3, nil);
            {$ENDIF}
          end;
          LY:= LY + FCellHHeight;
          Inc(LIdx);
        until LY > ((ARect.Bottom - ARect.Top) + ARect.Top - FCellHHeight);
        DrawCell(ACanvas, Rect(ARect.Left + FCellHWidth, ARect.Top,
          ARect.Right, ARect.Bottom));
      end else
        DrawCell(ACanvas, Rect(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom));
    end;
  end;
end;

procedure TfrxMarkOptionItem.DrawStrip(ACanvas: TCanvas; ARect: TRect);
var LX, LY, LIdx: Integer;
begin
  if (FStripPosition = spNone) then exit;
  with ACanvas do
  begin
    if FOrientation = orHorizontal then
    begin
      LY:= ARect.Top;
      LIdx:= 1;
      repeat
        if (FStripPosition = spOdd) then
        begin
          if (LIdx mod 2) > 0 then
          begin
            Brush.Style:= bsSolid;
            Brush.Color:= FCell.StripColor;
            Pen.Style:= psSolid;
            Pen.Color:= FCell.StripColor;
          end else
          begin
            Brush.Style:= bsClear;
            Pen.Style:= psClear;
          end;
        end else
        begin
          if (LIdx mod 2) = 0 then
          begin
            Brush.Style:= bsSolid;
            Brush.Color:= FCell.StripColor;
            Pen.Style:= psSolid;
            Pen.Color:= FCell.StripColor;
          end else
          begin
            Brush.Style:= bsClear;
            Pen.Style:= psClear;
          end;
        end;
        Rectangle(ARect.Left + 1, LY, ARect.Right, LY + FCellHeight);

        LY:= LY + FCellHeight;
        Inc(LIdx);
      until LY > ((ARect.Bottom - ARect.Top) + ARect.Top - FCellHeight);
    end else
    begin
      LX:= ARect.Left;
      LIdx:= 1;
      repeat
        if (FStripPosition = spOdd) then
        begin
          if (LIdx mod 2) > 0 then
          begin
            Brush.Style:= bsSolid;
            Brush.Color:= FCell.StripColor;
            Pen.Style:= psSolid;
            Pen.Color:= FCell.StripColor;
          end else
          begin
            Brush.Style:= bsClear;
            Pen.Style:= psClear;
          end;
        end else
        begin
          if (LIdx mod 2) = 0 then
          begin
            Brush.Style:= bsSolid;
            Brush.Color:= FCell.StripColor;
            Pen.Style:= psSolid;
            Pen.Color:= FCell.StripColor;
          end else
          begin
            Brush.Style:= bsClear;
            Pen.Style:= psClear;
          end;
        end;
        Rectangle(LX, ARect.Top + 1, LX + FCellWidth, ARect.Bottom);

        LX:= LX + FCellWidth;
        Inc(LIdx);
      until LX > ((ARect.Right - ARect.Left) + ARect.Left - FCellWidth);
    end;
  end;
end;

initialization
  frxObjects.RegisterObject1(TfrxMarkOptionItem, nil, '', '', 0, 20);

finalization
  frxObjects.UnRegister(TfrxMarkOptionItem);


end.
