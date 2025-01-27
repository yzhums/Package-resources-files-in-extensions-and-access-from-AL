pageextension 50105 ItemListExt extends "Item List"
{
    actions
    {
        addafter(CopyItem)
        {
            action(ImportItems)
            {
                Caption = 'Import Items';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Import;
                ToolTip = 'Import Items';
                trigger OnAction()
                var
                    InS: InStream;
                    Item: Record Item;
                    LineNo: Integer;
                begin
                    CSVBuffer.Reset();
                    CSVBuffer.DeleteAll();
                    NavApp.GetResource('a.txt', InS, TextEncoding::UTF8);
                    CSVBuffer.LoadDataFromStream(InS, ',');
                    for LineNo := 2 to CSVBuffer.GetNumberOfLines() do begin
                        Item.Init();
                        Item.Validate("No.", GetValueAtCell(LineNo, 1));
                        Item.Insert(true);
                        Item.Validate(Description, GetValueAtCell(LineNo, 2));
                        case GetValueAtCell(LineNo, 3) of
                            'Inventory':
                                Item.Validate(Type, Item.Type::"Inventory");
                            'Service':
                                Item.Validate(Type, Item.Type::"Service");
                            'Non-Inventory':
                                Item.Validate(Type, Item.Type::"Non-Inventory");
                        end;
                        Item.Validate(GTIN, GetValueAtCell(LineNo, 4));
                        Evaluate(Item."Unit Price", GetValueAtCell(LineNo, 5));
                        Item.Validate("Base Unit of Measure", GetValueAtCell(LineNo, 6));
                        Item.Modify(true);
                    end;
                end;
            }
            action(ImportMultipleItemPictures)
            {
                Caption = 'Import Multiple Item Pictures';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Import;
                ToolTip = 'Import Multiple Item Pictures';
                trigger OnAction()
                var
                    File: Text;
                    InS: InStream;
                    Item: Record Item;
                    ItemNo: Code[20];
                    RootPathList: List of [Text];
                    FileMgt: Codeunit "File Management";
                begin
                    foreach File in NavApp.ListResources('ItemPictures/*.jpg') do begin
                        NavApp.GetResource(File, InS, TextEncoding::UTF8);
                        RootPathList := File.Split('/');
                        ItemNo := FileMgt.GetFileNameWithoutExtension(RootPathList.Get(RootPathList.Count));
                        if Item.Get(ItemNo) then begin
                            Clear(Item.Picture);
                            Item.Picture.ImportStream(InS, 'Demo picture for item ' + Format(Item."No."));
                            Item.Modify(true);
                        end;
                    end;
                end;
            }
        }
    }

    var
        CSVBuffer: Record "CSV Buffer" temporary;

    local procedure GetValueAtCell(RowNo: Integer; ColNo: Integer): Text
    begin
        if CSVBuffer.Get(RowNo, ColNo) then
            exit(CSVBuffer.Value)
        else
            exit('');
    end;
}
