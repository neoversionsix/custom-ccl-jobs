Option Explicit

Sub GenerateTextAndSaveToClipboard()

    Dim wsBase As Worksheet
    Dim wsGenerator As Worksheet
    Dim tbl As ListObject
    Dim rngCodes As Range
    Dim cell As Range
    Dim starterText As String
    Dim generatedText As String
    Dim allGeneratedText As String

    ' Set worksheets and table
    Set wsBase = ThisWorkbook.Sheets("BASE CODE")
    Set wsGenerator = ThisWorkbook.Sheets("GENERATOR")
    Set tbl = wsGenerator.ListObjects("Table1")

    ' Get starter text
    starterText = wsBase.Range("A2").Value

    ' Get range of CODES column
    Set rngCodes = tbl.ListColumns("CODES").DataBodyRange

    ' Initialize string that will hold all generated text
    allGeneratedText = ""

    ' Iterate over each cell in the CODES column
    For Each cell In rngCodes
        ' Replace "swapme123" with current cell's value
        generatedText = Replace(starterText, "swapme123", cell.Value)
        
        ' Append to allGeneratedText
        allGeneratedText = allGeneratedText & generatedText & vbNewLine
    Next cell

    ' Save allGeneratedText to clipboard using hidden sheet
    Dim wsTemp As Worksheet
    On Error Resume Next ' If worksheet doesn't exist
    Set wsTemp = ThisWorkbook.Sheets("TempSheet")
    If wsTemp Is Nothing Then
        Set wsTemp = ThisWorkbook.Sheets.Add
        wsTemp.Name = "TempSheet"
        wsTemp.Visible = xlSheetVeryHidden ' Hide it
    End If
    On Error GoTo 0

    ' Use cell A1 on wsTemp to transfer data to clipboard
    wsTemp.Range("A1").Value = allGeneratedText
    wsTemp.Range("A1").Copy

End Sub