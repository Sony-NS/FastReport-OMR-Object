unit frxMarkEditor;

interface

uses frxDsgnIntf, frxMarkDateTime, frxMarkItem, frxMarkNoItem, frxMarkOptionItem;

type
  TmrxCellItemProperty = class(TfrxStringProperty)
  public
    function GetAttributes: TfrxPropertyAttributes; override;
    procedure GetValues; override;
  end;

implementation

{ TmrxCellItemProperty }

function TmrxCellItemProperty.GetAttributes: TfrxPropertyAttributes;
begin
  Result := [paValueList, paMultiSelect];
end;

procedure TmrxCellItemProperty.GetValues;
begin
  inherited;

  Values.Clear;
  Values.Add('A:B:C:D:E');
  Values.Add('A:B:C:D:E:F:G:H:I:J:K:L:M:N:O:P:Q:R:S:T:U:V:W:X:Y:Z');
  Values.Add('a:b:c:d:e:f:g:h:i:j:k:l:m:n:o:p:q:r:s:t:u:v:w:x:y:z');
  Values.Add('0:1:2:3:4:5:6:7:8:9');
  Values.Add('A:B:C:D:E:F:G:H:I:J:K:L:M:N:O:P:Q:R:S:T:U:V:W:X:Y:Z:0:1:2:3:4:5:6:7:8:9');
  Values.Add('a:b:c:d:e:f:g:h:i:j:k:l:m:n:o:p:q:r:s:t:u:v:w:x:y:z:0:1:2:3:4:5:6:7:8:9');
  Values.Add('0:1:2:3:4:5:6:7:8:9:A:B:C:D:E:F:G:H:I:J:K:L:M:N:O:P:Q:R:S:T:U:V:W:X:Y:Z');
  Values.Add('0:1:2:3:4:5:6:7:8:9:a:b:c:d:e:f:g:h:i:j:k:l:m:n:o:p:q:r:s:t:u:v:w:x:y:z');
end;

initialization
  frxPropertyEditors.Register(TypeInfo(String), TfrxMarkItem, 'CellItems', TmrxCellItemProperty);
  frxPropertyEditors.Register(TypeInfo(String), TfrxMarkNoItem, 'CellItems', TmrxCellItemProperty);

end.
