using _Excel = Microsoft.Office.Interop.Excel;
using System.Reflection;
using System.IO;
using Microsoft.Office.Interop.Excel;
using System.Runtime.InteropServices.Marshalling;
using HtmlAgilityPack;
using System.Net;

namespace ExcelScript
{
    public class ExcelHandler
    {
        // Variables //////////////////////////////////////////////////////////////
        string mPath = "";

        // Define the URL
        string url = "";

        _Application mExcel;
        readonly _Excel._Workbook mWB;
        readonly _Excel._Worksheet mWS;

        // Constructor ////////////////////////////////////////////////////////////
        ExcelHandler(string FilePath, int Sheet) // open excel file
        {
            mPath = FilePath;

            if (Path.Exists(mPath))
            {
                // create new excel application only if the path is valid
                mExcel = new _Excel.Application();
                mWB = mExcel.Workbooks.Open(mPath);
                mWS = (_Excel._Worksheet)mWB.Worksheets[Sheet];
            }
            else
            {
                throw new FileNotFoundException("File not found! Please Check File Path.");
            }
        }

        // Functions //////////////////////////////////////////////////////////////
        static void Main()
        {
            AccessExcel("..\\TEST.xlsx");

            // Clean up
            GC.Collect();
            GC.WaitForPendingFinalizers();
        }

        static async void AccessExcel(string path)
        {
            ExcelHandler eh = new ExcelHandler(path, 1);

            try
            {
                Console.WriteLine(eh.ReadCell(0, 0));

                // Access the build server
                try
                {
                    // load the website
                    HtmlWeb web = new();
                    HtmlDocument doc = web.Load(eh.url);

                    // log into the website
                    HtmlNode username = doc.GetElementbyId("j_username");
                    if (username == null)
                    {
                        Console.WriteLine("Error: Username not found");
                    }
                    else
                    {
                        Console.WriteLine("Username found");
                        username.SetAttributeValue("value", "remanence");
                    }
                    
                    //HtmlNode password = doc.GetElementbyId("j_password");
                    //password.SetAttributeValue("value", "tosoftware");
                    //HtmlNode submit = doc.GetElementbyId("yui-gen1-button");

                }
                catch (Exception e)
                {
                    Console.WriteLine("Error Accessing Build Server: ");
                    Console.WriteLine(e.Message);
                }
            }
            catch (Exception theException)
            {
                String errorMessage;
                errorMessage = "Error: ";
                errorMessage = String.Concat(errorMessage, theException.Message);
                errorMessage = String.Concat(errorMessage, " Line: ");
                errorMessage = String.Concat(errorMessage, theException.Source);
                Console.WriteLine(errorMessage, "Error");
                Console.WriteLine();
            }
            finally
            {
                //Close the workbook
                eh.mWB.Close();
                eh.mExcel.Workbooks.Close();

                //Quit the excel application
                eh.mExcel.Quit();
            }
        }

        public string ReadCell(int i, int j) // read cell
        {
            // Because excel cells start from 1,1
            i++;
            j++;

            if (mWS.Cells[i, j].Value2 != null) // if cell is not empty
            {
                return mWS.Cells[i, j].Value2;
            }
            else
            {
                return "";
            }
        }
    }
}


