using _Excel = Microsoft.Office.Interop.Excel;
using System.Reflection;
using System.IO;
using Microsoft.Office.Interop.Excel;
using System.Runtime.InteropServices.Marshalling;

namespace ExcelScript
{
    public class ExcelHandler
    {
        // Variables //////////////////////////////////////////////////////////////
        string mPath = "";
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
            AccessExcel(@"FILEPATH_HERE");

            // Clean up
            GC.Collect();
            GC.WaitForPendingFinalizers();
        }

        static void AccessExcel(string path)
        {
            ExcelHandler eh = new ExcelHandler(path, 1);

            try
            {
                Console.WriteLine(eh.ReadCell(0, 1));
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


