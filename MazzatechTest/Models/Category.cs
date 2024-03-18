namespace MazzatechTest.Models;

/// <summary>
/// Category class
/// </summary>
internal class Category
{
    /// <summary>
    /// List of registered categories
    /// </summary>
    public static List<Category> Categories = new List<Category>();

    /// <summary>
    /// Constructor of the 'Category' class
    /// </summary>
    public Category() { }

    /// <summary>
    /// Property: Id
    /// </summary>
    public int Id { get; private set; }

    /// <summary>
    /// Property: Name
    /// </summary>
    public string Name { get; set; }

    /// <summary>
    /// Property: StartValue
    /// Defines the beginning of a range
    /// </summary>
    public double StartValue { get; set; }

    /// <summary>
    /// Property: StartValue
    /// defines the end of a range
    /// </summary>
    public double EndValue { get; set; }

    /// <summary>
    /// Method responsible for finding a category
    /// </summary>
    /// <param name="marketValue"></param>
    /// <returns></returns>
    public static Category FindCategory(double marketValue)
    {
        var category = Categories.Where(item => (item.StartValue <= marketValue && item.EndValue > marketValue) || (item.StartValue <= marketValue && item.EndValue == 0)).FirstOrDefault();
        if(category != null) 
        { 
            return category;
        }
        else
        {
            Category newCategory = new Category();
            return newCategory;
        }
    }

    /// <summary>
    /// Method responsible for inserting a category
    /// </summary>
    /// <param name="newName"></param>
    /// <param name="newStartValue"></param>
    /// <param name="newEndValue"></param>
    public static void InsertCategory(string newName, double newStartValue, double newEndValue)
    {
        try
        {
            Category category = new Category() { Name = newName, StartValue = newStartValue, EndValue = newEndValue };

            int biggestId = 0;

            Category findLastCategory = Categories.OrderByDescending(item => item.Id).FirstOrDefault();

            if (findLastCategory != null)
            {
                biggestId = findLastCategory.Id;
            }

            biggestId++;

            Categories.Add(category);
        }
        catch(Exception ex)
        {
            Console.WriteLine($"Ocorreu o seguinte erro ao tentar inserir a categoria: \n{ex.ToString()}");
        }
    }

    /// <summary>
    /// Method responsible for editing a category
    /// </summary>
    /// <param name="idCategory"></param>
    /// <param name="newName"></param>
    /// <param name="newStartValue"></param>
    /// <param name="newEndValue"></param>
    public static void EditCategory(int idCategory, string newName, double newStartValue, double newEndValue)
    {
        Category? categoriaEncontrada = Categories.FirstOrDefault(c => c.Id == idCategory);

        if(categoriaEncontrada != null)
        {
            categoriaEncontrada.Name = newName;
            categoriaEncontrada.StartValue = newStartValue;
            categoriaEncontrada.EndValue = newEndValue;
            Console.WriteLine("Category success updated!");
        }
        else
        {
            Console.WriteLine("Category not found!");
            return;
        }
    }

    /// <summary>
    /// Method responsible for deleting a category
    /// </summary>
    /// <param name="category"></param>
    public static void DeleteCategory(Category category) 
    {
        Categories.Remove(category);
    }
}
