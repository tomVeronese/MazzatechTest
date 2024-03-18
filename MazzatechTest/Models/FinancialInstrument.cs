namespace MazzatechTest.Models;

/// <summary>
/// Category FinancialInstrument implements interface IFinancialInstrument
/// </summary>
internal class FinancialInstrument : IFinancialInstrument
{
    /// <summary>
    /// List of registered Instruments Categories
    /// </summary>
    public static List<FinancialInstrument> FinancialInstruments = new List<FinancialInstrument>();

    /// <summary>
    /// Constructor of the 'FinancialInstrument' class
    /// </summary>
    /// <param name="type"></param>
    /// <param name="marketValue"></param>
    public FinancialInstrument(string type, double marketValue)
    {
        Type = type;
        MarketValue = marketValue;
        FinancialInstruments.Add(this);
    }

    /// <summary>
    /// Property: Type
    /// </summary>
    public string Type { get; private set; }

    /// <summary>
    /// Property: MarketValue
    /// </summary>
    public double MarketValue { get; private set; }

    /// <summary>
    /// Property: Category
    /// </summary>
    public Category? Category 
    { 
        get
        {
            var category = Category.FindCategory(this.MarketValue);
            if (category != null) { return category; } else { return null; }
        } 
    }

    /// <summary>
    /// Method responsible for displaying on the screen the previously defined Output
    /// </summary>
    public static void ShowAllInstrumentsCategories()
    {
        string resposta = "instrumentCategories = {";

        int indice = 0;
        foreach (FinancialInstrument instrument in FinancialInstruments)
        {
            resposta += $"\"{instrument.Category.Name}\"";
            if (indice != FinancialInstruments.Count - 1)
            {
                resposta += ", ";
            }
            indice++;
        }
        resposta += "}";
        Console.WriteLine(resposta);
    }

}