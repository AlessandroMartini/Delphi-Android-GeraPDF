unit GeradorPDF;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Objects;

type
  TForm1 = class(TForm)
    Image1: TImage;
    btGerarPDF: TButton;
    procedure btGerarPDFClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses Androidapi.JNI.GraphicsContentViewText, Androidapi.JNI.JavaTypes,
  Androidapi.JNI.Net, Androidapi.Helpers, System.IOUtils, FMX.Helpers.android,
  FMX.surfaces;

{$R *.fmx}

function FileNameToUri(const FileName: string): Jnet_Uri;
var
  JavaFile: JFile;
begin
  JavaFile := TJFile.JavaClass.init(StringToJString(FileName));
  Result := TJnet_Uri.JavaClass.fromFile(JavaFile);
end;

procedure TForm1.btGerarPDFClick(Sender: TObject);
var
  Document: JPdfDocument;
  PageInfo: JPdfDocument_PageInfo;
  Page: JPdfDocument_Page;
  Canvas: JCanvas;
  Paint: JPaint;
  Recto: JRect;
  Rect: JRect;
  FileName: string;
  OutputStream: JFileOutputStream;
  Intent: JIntent;
  NativeBitmap: JBitmap;
  sBitMap: TBitmapSurface;
begin
  // create Pdf document
  Document := TJPdfDocument.JavaClass.init;
  try
    // create page  1
    PageInfo := TJPageInfo_Builder.JavaClass.init(100, 100, 1).create;
    Page := Document.startPage(PageInfo);

    Canvas := Page.getCanvas;
    Paint := TJPaint.JavaClass.init;

    Paint.setARGB($FF, 0, 0, $FF);
    Canvas.drawText(StringToJString('Página 1'), 10, 50, Paint);

    Document.finishPage(Page);

    // create page 2
    PageInfo := TJPageInfo_Builder.JavaClass.init(100, 100, 2).create;
    Page := Document.startPage(PageInfo);

    Canvas := Page.getCanvas;
    Paint := TJPaint.JavaClass.init;

    Paint.setARGB($FF, $FF, 0, 0);
    Canvas.drawLine(10, 10, 90, 10, Paint);

    Paint.setStrokeWidth(1);
    Paint.setARGB($FF, 0, $FF, 0);
    Canvas.drawLine(10, 20, 90, 20, Paint);

    Paint.setStrokeWidth(2);
    Paint.setARGB($FF, 0, 0, $FF);
    Canvas.drawLine(10, 30, 90, 30, Paint);

    Paint.setARGB($FF, $FF, $FF, 0);
    Canvas.drawRect(10, 40, 90, 60, Paint);

    Rect := TJRect.JavaClass.init;
    Rect.&set(15, 50, 65, 100);
    Recto := TJRect.JavaClass.init;
    Recto.&set(0, 0, Image1.Bitmap.Width, Image1.Bitmap.Height);
    Paint.setARGB($FF, $FF, 0, $FF);

    NativeBitmap := TJBitmap.JavaClass.createBitmap(Image1.Bitmap.Width,
      Image1.Bitmap.Height, TJBitmap_Config.JavaClass.ARGB_8888);
    sBitMap := TBitmapSurface.create;
    sBitMap.Assign(Image1.Bitmap);
    SurfaceToJBitmap(sBitMap, NativeBitmap);

    Canvas.drawBitmap(NativeBitmap, Recto, Rect, Paint);

    Document.finishPage(Page);

    // write PDF document to file
    FileName := TPath.Combine(TPath.GetSharedDocumentsPath, 'demo.pdf');
    OutputStream := TJFileOutputStream.JavaClass.init
      (StringToJString(FileName));
    try
      Document.writeTo(OutputStream);
    finally
      OutputStream.close;
    end;
  finally
    Document.close;
  end;

  // start PDF viewer
  Intent := TJIntent.JavaClass.init;
  Intent.setAction(TJIntent.JavaClass.ACTION_VIEW);
  Intent.setDataAndType(FileNameToUri(FileName),
    StringToJString('application/pdf'));
  Intent.setFlags(TJIntent.JavaClass.FLAG_ACTIVITY_NO_HISTORY or
    TJIntent.JavaClass.FLAG_ACTIVITY_CLEAR_TOP);
  SharedActivity.StartActivity(Intent);
end;

end.

