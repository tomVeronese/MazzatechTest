using MazzatechTest.Models;
using System.Text;

namespace MazzatechTest;

class Program
{  
    /// <summary>
    /// Main method
    /// </summary>
    /// <param name="args"></param>
    static void Main(string[] args)
    {
        // Read lines from Input
        void ReadLines()
        {
            Console.WriteLine("Paste the lines below (leave a blank line to finish):");

            StringBuilder stringBuilder = new StringBuilder();
            string line;

            // Read each line until a blank line is encountered
            while ((line = Console.ReadLine()!) != string.Empty)
            {
                stringBuilder.AppendLine(line);
            }

            string input = stringBuilder.ToString();

            LinesToInstruments(input);
        }

        // Parses each line and inserts the financial instrument
        void LinesToInstruments(string jsonString)
        {
            string[] lines = jsonString.Split('\n', StringSplitOptions.RemoveEmptyEntries);

            foreach (string line in lines)
            {
                string[] parts = line.Split(new char[] { ' ', '{', '}', '=', ';' }, StringSplitOptions.RemoveEmptyEntries);

                if (parts.Length >= 4)
                {
                    double marketValue = double.Parse(parts[2].Replace(",", ""));
                    string type = parts[4].Replace("\"", "");
                    FinancialInstrument financialInst = new FinancialInstrument(type, marketValue);
                }
            }
        }

        // Inserts the 3 initial categories
        Category.InsertCategory("Low Value",    0,       1000000);
        Category.InsertCategory("Medium Value", 1000000, 5000000);
        Category.InsertCategory("High Value",    5000000, 0);

        // Call method
        ReadLines();

        // Print Output
        FinancialInstrument.ShowAllInstrumentsCategories();
    }
}
