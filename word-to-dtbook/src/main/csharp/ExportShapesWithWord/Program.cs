using Microsoft.Office.Core;
using Microsoft.Office.Interop.Word;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;
using MSWord = Microsoft.Office.Interop.Word;

namespace Daisy.SaveAsDAISY.Exporter
{

    internal class Program
    {

        static int Main(string[] args)
        {
            System.Windows.Forms.Application.EnableVisualStyles();
            System.Windows.Forms.Application.SetCompatibleTextRenderingDefault(false);
            FileInfo inputFile = null;
            bool useOpenedDocument = false;
            // Defaults to SaveAsDAISY folder in AppData if no output folder is specified
            // (this is to be changed later when this 
            DirectoryInfo outputFolder = Directory.CreateDirectory(
                Path.Combine(
                    Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
                    "SaveAsDAISY"
                )
            );
            try
            {
                if (args.Length == 0)
                {
                    return 1;
                }
                else
                {
                    string input = args[0];
                    if (input == "--current")
                    {
                        useOpenedDocument = true;
                    } else
                    {
                        if (input.StartsWith("file:/"))
                        {
                            input = new Uri(input).LocalPath;
                        }
                        inputFile = new FileInfo(input);
                        if (!inputFile.Exists)
                        {
                            Console.Error.WriteLine(string.Format("{0} not found", inputFile.FullName));
                            return 2;
                        }
                    }
                    if (args.Length > 1)
                    {
                        string output = args[1];
                        if (output.StartsWith("file:/"))
                        {
                            output = new Uri(output).LocalPath;
                        }
                        outputFolder = Directory.CreateDirectory(output);
                    }
                }

                bool closeWordWhenDone = false;
                MSWord.Application app = null;
                Console.WriteLine("Connecting to Word instance...");
                try
                {
                    app = (MSWord.Application)System.Runtime.InteropServices.Marshal.GetActiveObject("Word.Application");
                }
                catch (COMException ecom)
                {
                    if (useOpenedDocument)
                    {
                        Console.Error.WriteLine("Word is not opened, cannot retrieve the active document");
                        Console.Error.WriteLine(ecom.Message);
                        Console.Error.WriteLine(ecom.StackTrace);
                        return 252;
                    }
                    try
                    {
                        Console.WriteLine($"Word is not opened, trying launch it ...");
                        app = new MSWord.Application()
                        {
                            Visible = false,
                            AutomationSecurity = Microsoft
                                .Office
                                .Core
                                .MsoAutomationSecurity
                                .msoAutomationSecurityForceDisable
                        };
                        closeWordWhenDone = true;
                    }
                    catch (COMException e1)
                    {
                        Console.Error.WriteLine("Could not retrieve or open Word application for export");
                        Console.Error.WriteLine(e1.Message);
                        Console.Error.WriteLine(e1.StackTrace);
                        return 252;
                    }
                    catch (Exception e2)
                    {
                        Console.Error.WriteLine("Could not retrieve or open Word application for export");
                        Console.Error.WriteLine(e2.Message);
                        Console.Error.WriteLine(e2.StackTrace);
                        return 252;
                    }
                }
                Console.WriteLine("Connected to Word, opening the document...");

                // Start treatment
                try
                {
                    
                    MSWord.Document doc = useOpenedDocument ? app.ActiveDocument : app.Documents.Open(inputFile.FullName, ReadOnly: true, Visible: false);
                    string outputPath = outputFolder.FullName;
                    string fileName = doc.Name.ToString().Replace(" ", "_");
                    string shapeOutputPrefix = Path.Combine(outputPath, Path.GetFileNameWithoutExtension(fileName));
                    
                    Dictionary<int, Tuple<ShapeType, int>> shapesOrder = new Dictionary<int, Tuple<ShapeType, int>>();

                    for (int i = 1; i <= doc.InlineShapes.Count; i++)
                    {
                        MSWord.InlineShape inlineShape = doc.InlineShapes[i];
                        int order = inlineShape.Range.Start;
                        shapesOrder.Add(order, new Tuple<ShapeType, int>(ShapeType.Inlined, i));
                    }

                    for (int i = 1; i <= doc.Shapes.Count; i++)
                    {
                        MSWord.Shape shape = doc.Shapes[i];
                        int order = shape.Anchor.Start;
                        shapesOrder.Add(order, new Tuple<ShapeType, int>(ShapeType.Anchored, i));
                    }

                    List<Tuple<ShapeType, int>> orderedShapes = shapesOrder.OrderBy(x => x.Key).Select(x => x.Value).ToList();

                    for (int i = 0; i < orderedShapes.Count; i++)
                    {
                        int shapeIndex = i + 1;
                        string message = "";
                        Thread thread = new Thread(() => message = SaveShape(shapeIndex, orderedShapes[i], doc, shapeOutputPrefix));
                        thread.SetApartmentState(ApartmentState.STA); // Nécessaire pour le Clipboard
                        thread.Start();
                        thread.Join();
                        Console.WriteLine(message);

                    }

                    if(!useOpenedDocument)
                    {
                        Console.WriteLine("Closing document...");
                        doc.Close(false);
                    }

                    if (closeWordWhenDone)
                    {
                        Console.WriteLine("Closing Word...");
                        app.Quit();
                    }

                    return 0;
                }
                catch (Exception ex)
                {
                    Console.Error.WriteLine("An error occured while trying to export shapes");
                    Console.Error.WriteLine(ex.Message);
                    Console.Error.WriteLine(ex.StackTrace);
                    return 253;
                }
            } catch (Exception ex)
            {
                Console.Error.WriteLine("An error occured while parsing arguments");
                Console.Error.WriteLine(ex.Message);
                Console.Error.WriteLine(ex.StackTrace);
                return 254;
            }
            

        }

        private enum ShapeType
        {
            Inlined,
            Anchored
        }

        private static string SaveShape(int id, Tuple<ShapeType, int> realIndex, MSWord.Document doc, string outputPrefix)
        {
            try
            {

                switch (realIndex.Item1)
                {
                    case ShapeType.Inlined:
                        MSWord.InlineShape inlineShape = doc.InlineShapes[realIndex.Item2];
                        inlineShape.Select();
                        switch (inlineShape.Type)
                        {
                            //case WdInlineShapeType.wdInlineShapePicture:
                            //    return $@"Shape {id} ({realIndex.Item1}: {realIndex.Item2}) is a picture, it will be extracted during conversion";
                            case WdInlineShapeType.wdInlineShapeEmbeddedOLEObject:
                                return $@"Shape {id} ({realIndex.Item1}: {realIndex.Item2}) is an embedded OLE object, it will not be exported";
                        }
                        break;
                    case ShapeType.Anchored:
                        MSWord.Shape shape = doc.Shapes[realIndex.Item2];
                        shape.Select();
                     
                        if (shape.Type == MsoShapeType.msoTextBox)
                        {
                            return $@"Shape {id} ({realIndex.Item1}: {realIndex.Item2}) is a text box and will not be saved as an image";
                        }

                        if (shape.Type == MsoShapeType.msoGroup)
                        {
                            // Word only puts "Ole Private Data" on the clipboard for a group shape
                            // (no CF_BITMAP/CF_DIB/CF_ENHMETAFILE), so Clipboard.ContainsImage() or data.GetDataPresent(DataFormats.Bitmap) is always false here.
                            // Read the EMF bits straight from the shape's anchor range instead (no clipboard needed).
                            byte[] emf = shape.Anchor.EnhMetaFileBits as byte[];
                            if (emf != null && emf.Length > 0)
                            {
                                ConvertEmfBufferToPng(emf, $@"{outputPrefix}-Shape{id}.png");
                                return $@"Shape {id} ({realIndex.Item1}: {realIndex.Item2}) saved as {outputPrefix}-Shape{id}.png";
                            }
                            return $@"Shape {id} ({realIndex.Item1}: {realIndex.Item2}) group could not be saved as image";
                        }

                        break;
                    default:
                        return $@"Unknown shape type {realIndex.Item1} for index {id}";
                }
                
                doc.Application.Selection.Copy();

                System.Windows.Forms.IDataObject data = Clipboard.GetDataObject();
                if (data != null && data.GetDataPresent(DataFormats.Bitmap))
                {
                    System.Drawing.Image img = (System.Drawing.Image)data.GetData(DataFormats.Bitmap, true);
                    using (Bitmap bitmap = new Bitmap(img))
                    {
                        bitmap.Save($@"{outputPrefix}-Shape{id}.png", ImageFormat.Png);
                    }
                    return $@"Shape {id} ({realIndex.Item1}: {realIndex.Item2}) saved as {outputPrefix}-Shape{id}.png";
                }
                else
                {
                    return $@"Shape {id} ({realIndex.Item1}: {realIndex.Item2}) could not be saved as image";
                }
            }
            catch (Exception e)
            {
                return $@"Shape {id} ({realIndex.Item1}: {realIndex.Item2}) could not be extracted : {e.Message}";
            }
        }

        public static void SaveMetaFile(
            Stream source,
            Stream destination,
            float scale = 1f,
            Color? backgroundColor = null,
            ImageFormat format = null,
            EncoderParameters parameters = null
        )
        {
            if (source == null)
            {
                throw new ArgumentNullException(nameof(source));
            }
            if (destination == null)
            {
                throw new ArgumentNullException(nameof(destination));
            }

            using (var img = new Metafile(source))
            {
                var f = format ?? ImageFormat.Png;

                //Determine default background color.
                //Not all formats support transparency.
                if (backgroundColor == null)
                {
                    var transparentFormats = new ImageFormat[]
                    {
                        ImageFormat.Gif,
                        ImageFormat.Png,
                        ImageFormat.Wmf,
                        ImageFormat.Emf
                    };
                    var isTransparentFormat = transparentFormats.Contains(f);

                    backgroundColor = isTransparentFormat ? Color.Transparent : Color.White;
                }

                //header contains DPI information
                var header = img.GetMetafileHeader();

                //calculate the width and height based on the scale
                //and the respective DPI
                var width = (int)
                    Math.Round((scale * img.Width / header.DpiX * 100), 0, MidpointRounding.ToEven);
                var height = (int)
                    Math.Round(
                        (scale * img.Height / header.DpiY * 100),
                        0,
                        MidpointRounding.ToEven
                    );

                using (var bitmap = new Bitmap(width, height))
                {
                    using (var g = System.Drawing.Graphics.FromImage(bitmap))
                    {
                        //fills the background
                        g.Clear(backgroundColor.Value);

                        //reuse the width and height to draw the image
                        //in 100% of the square of the bitmap
                        g.DrawImage(img, 0, 0, bitmap.Width, bitmap.Height);
                    }
                    // crop image
                    int xmin = bitmap.Width - 1,
                        xmax = 0;
                    // search min and max x
                    for (int y = 0; y < bitmap.Height; ++y)
                    {
                        for (int x = 0; x <= xmin; ++x)
                        {
                            if (bitmap.GetPixel(x, y).ToArgb() != backgroundColor.Value.ToArgb())
                            {
                                xmin = Math.Min(xmin, x);
                            }
                        }

                        for (int x = bitmap.Width - 1; x >= xmax; --x)
                        {
                            if (bitmap.GetPixel(x, y).ToArgb() != backgroundColor.Value.ToArgb())
                            {
                                xmax = Math.Max(xmax, x);
                            }
                        }
                    }
                    // search min y
                    int ymin = bitmap.Height - 1,
                        ymax = 0;
                    for (int x = 0; x < bitmap.Width; ++x)
                    {
                        for (int y = 0; y <= ymin; ++y)
                        {
                            if (bitmap.GetPixel(x, y).ToArgb() != backgroundColor.Value.ToArgb())
                            {
                                ymin = Math.Min(ymin, y);
                            }
                        }
                        for (int y = bitmap.Height - 1; y >= ymax; --y)
                        {
                            if (bitmap.GetPixel(x, y).ToArgb() != backgroundColor.Value.ToArgb())
                            {
                                ymax = Math.Max(ymax, y);
                            }
                        }
                    }

                    //get codec based on GUID
                    var codec = ImageCodecInfo
                        .GetImageEncoders()
                        .FirstOrDefault(c => c.FormatID == f.Guid);

                    //bitmap.Save(destination, codec, parameters);
                    // cropping result
                    bitmap
                        .Clone(
                            new System.Drawing.Rectangle(xmin, ymin, xmax - xmin, ymax - ymin),
                            bitmap.PixelFormat
                        )
                        .Save(destination, codec, parameters);
                }
            }
        }

        /// <summary>
        /// Save a metafile buffer (obtained from shape range) to disk
        /// </summary>
        /// <param name="emfBuffer"></param>
        /// <param name="destinationFilePath"></param>
        public static void ConvertEmfBufferToPng(byte[] emfBuffer, string destinationFilePath)
        {
            using (var source = new MemoryStream(emfBuffer))
            {
                using (var destination = File.OpenWrite(destinationFilePath))
                {
                    SaveMetaFile(source, destination, 4, Color.White, ImageFormat.Png);
                }
            }
        }
    }
}
