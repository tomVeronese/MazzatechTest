namespace MazzatechTest.Models;

/// <summary>
/// Interface provided in the business rule
/// </summary>
internal interface IFinancialInstrument
{
    double MarketValue { get; }

    string Type { get; }

}
