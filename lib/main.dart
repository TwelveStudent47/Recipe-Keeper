import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(RecipeApp());
}

class RecipeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recept Gyűjtemény',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.orange[600],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: RecipeHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Recipe {
  final String id;
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final int cookingTime;
  final int difficulty; // 1-5
  final String category;
  final double rating;
  final String imageUrl;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.cookingTime,
    required this.difficulty,
    required this.category,
    required this.rating,
    required this.imageUrl,
  });
}

class RecipeHomePage extends StatefulWidget {
  @override
  _RecipeHomePageState createState() => _RecipeHomePageState();
}

class _RecipeHomePageState extends State<RecipeHomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final List<Recipe> _recipes = [
    Recipe(
      id: '1',
      title: 'Gulyásleves',
      description: 'Hagyományos magyar gulyásleves',
      ingredients: ['500g marhahús', '2 hagyma', '2 ek paprika', '3 krumpli', 'só, bors'],
      instructions: ['Hús megpirítása', 'Hagyma hozzáadása', 'Paprika hozzáadása', 'Főzés 1 órán át'],
      cookingTime: 90,
      difficulty: 3,
      category: 'Magyar',
      rating: 4.8,
      imageUrl: '🍲',
    ),
    Recipe(
      id: '2',
      title: 'Carbonara',
      description: 'Olasz carbonara tészta',
      ingredients: ['400g spagetti', '200g bacon', '3 tojás', '100g parmezan', 'fekete bors'],
      instructions: ['Tészta főzése', 'Bacon kisütése', 'Tojás kevereése', 'Összekeverés'],
      cookingTime: 25,
      difficulty: 2,
      category: 'Olasz',
      rating: 4.6,
      imageUrl: '🍝',
    ),
    Recipe(
      id: '3',
      title: 'Palacsinta',
      description: 'Finom palacsinta lekvárral',
      ingredients: ['2 tojás', '250ml tej', '150g liszt', '1 ek cukor', 'csipet só'],
      instructions: ['Tészta elkészítése', 'Pihentetés', 'Sütés', 'Lekvár hozzáadása'],
      cookingTime: 30,
      difficulty: 1,
      category: 'Desszert',
      rating: 4.9,
      imageUrl: '🥞',
    ),
    Recipe(
      id: '4',
      title: 'Sushi',
      description: 'Hagyományos japán sushi',
      ingredients: ['200g sushi rizs', '4 nori lap', '200g lazac', 'wasabi', 'szójaszósz'],
      instructions: ['Rizs elkészítése', 'Hal felszeletelése', 'Tekerés', 'Vágás'],
      cookingTime: 45,
      difficulty: 4,
      category: 'Japán',
      rating: 4.7,
      imageUrl: '🍣',
    ),
  ];

  List<Recipe> _filteredRecipes = [];
  String _selectedCategory = 'Összes';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _filteredRecipes = _recipes;
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterRecipes() {
    setState(() {
      _filteredRecipes = _recipes.where((recipe) {
        final matchesCategory = _selectedCategory == 'Összes' || recipe.category == _selectedCategory;
        final matchesSearch = recipe.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                             recipe.description.toLowerCase().contains(_searchController.text.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _showRecipeDetails(Recipe recipe) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => RecipeDetailPage(recipe: recipe),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: Offset(1.0, 0.0), end: Offset.zero).chain(
                CurveTween(curve: Curves.easeInOut),
              ),
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _showAddRecipeDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final ingredientsController = TextEditingController();
    final instructionsController = TextEditingController();
    final cookingTimeController = TextEditingController();
    String selectedCategory = 'Magyar';
    int selectedDifficulty = 1;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_circle, color: Colors.orange),
            SizedBox(width: 8),
            Text('Új recept hozzáadása'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Recept neve',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Leírás',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 12),
              TextField(
                controller: ingredientsController,
                decoration: InputDecoration(
                  labelText: 'Hozzávalók (vesszővel elválasztva)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.list),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 12),
              TextField(
                controller: instructionsController,
                decoration: InputDecoration(
                  labelText: 'Elkészítés (lépéseket vesszővel válaszd el)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.receipt),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 12),
              TextField(
                controller: cookingTimeController,
                decoration: InputDecoration(
                  labelText: 'Főzési idő (perc)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategória',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: ['Magyar', 'Olasz', 'Japán', 'Desszert', 'Egyéb'].map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) => selectedCategory = value!,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Text('Nehézség: '),
                  Expanded(
                    child: Slider(
                      value: selectedDifficulty.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: selectedDifficulty.toString(),
                      onChanged: (value) {
                        setState(() {
                          selectedDifficulty = value.round();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Mégse'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && descController.text.isNotEmpty) {
                final newRecipe = Recipe(
                  id: DateTime.now().toString(),
                  title: titleController.text,
                  description: descController.text,
                  ingredients: ingredientsController.text.split(',').map((e) => e.trim()).toList(),
                  instructions: instructionsController.text.split(',').map((e) => e.trim()).toList(),
                  cookingTime: int.tryParse(cookingTimeController.text) ?? 30,
                  difficulty: selectedDifficulty,
                  category: selectedCategory,
                  rating: 4.0 + Random().nextDouble(),
                  imageUrl: ['🍲', '🍝', '🥞', '🍣', '🥗', '🍰'][Random().nextInt(6)],
                );
                
                setState(() {
                  _recipes.add(newRecipe);
                  _filterRecipes();
                });
                
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Recept sikeresen hozzáadva!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text('Hozzáad'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recept Gyűjtemény'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.home), text: 'Főoldal'),
            Tab(icon: Icon(Icons.search), text: 'Keresés'),
            Tab(icon: Icon(Icons.favorite), text: 'Kedvencek'),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildHomeTab(),
            _buildSearchTab(),
            _buildFavoritesTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRecipeDialog,
        backgroundColor: Colors.orange,
        icon: Icon(Icons.add),
        label: Text('Új recept'),
      ),
    );
  }

  Widget _buildHomeTab() {
    return Column(
      children: [
        // Kategória szűrő
        Container(
          height: 60,
          padding: EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ['Összes', 'Magyar', 'Olasz', 'Japán', 'Desszert'].map((category) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                      _filterRecipes();
                    });
                  },
                  selectedColor: Colors.orange[200],
                ),
              );
            }).toList(),
          ),
        ),
        
        // Receptek lista
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: _filteredRecipes.length,
            itemBuilder: (ctx, index) {
              final recipe = _filteredRecipes[index];
              return Hero(
                tag: recipe.id,
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    onTap: () => _showRecipeDetails(recipe),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                recipe.imageUrl,
                                style: TextStyle(fontSize: 32),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipe.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  recipe.description,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.timer, size: 16, color: Colors.orange),
                                    SizedBox(width: 4),
                                    Text('${recipe.cookingTime} perc'),
                                    SizedBox(width: 16),
                                    Row(
                                      children: List.generate(5, (i) {
                                        return Icon(
                                          i < recipe.difficulty ? Icons.star : Icons.star_border,
                                          size: 16,
                                          color: Colors.orange,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    recipe.category,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Keresés receptek között...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _filterRecipes();
                },
              ),
            ),
            onChanged: (value) => _filterRecipes(),
          ),
          SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _filteredRecipes.length,
              itemBuilder: (ctx, index) {
                final recipe = _filteredRecipes[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    onTap: () => _showRecipeDetails(recipe),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 80,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(recipe.imageUrl, style: TextStyle(fontSize: 40)),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            recipe.title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            recipe.description,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${recipe.cookingTime}\'', style: TextStyle(fontSize: 12)),
                              Row(
                                children: [
                                  Icon(Icons.star, size: 14, color: Colors.orange),
                                  Text('${recipe.rating.toStringAsFixed(1)}', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    final favoriteRecipes = _recipes.where((r) => r.rating > 4.7).toList();
    
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Legjobbra értékelt receptek',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: favoriteRecipes.length,
              itemBuilder: (ctx, index) {
                final recipe = favoriteRecipes[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(recipe.imageUrl, style: TextStyle(fontSize: 24)),
                      ),
                    ),
                    title: Text(recipe.title),
                    subtitle: Text('${recipe.category} • ${recipe.cookingTime} perc'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 16),
                        Text(recipe.rating.toStringAsFixed(1)),
                      ],
                    ),
                    onTap: () => _showRecipeDetails(recipe),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;

  RecipeDetailPage({required this.recipe});

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  bool _isIngredientsExpanded = true;
  bool _isInstructionsExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.title),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Hozzáadva a kedvencekhez!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recept kép
            Hero(
              tag: widget.recipe.id,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange[300]!, Colors.orange[500]!],
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.recipe.imageUrl,
                    style: TextStyle(fontSize: 80),
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cím és leírás
                  Text(
                    widget.recipe.title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.recipe.description,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  
                  // Statisztikák
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(Icons.timer, '${widget.recipe.cookingTime} perc', 'Főzési idő'),
                      _buildStatCard(Icons.star, '${widget.recipe.rating.toStringAsFixed(1)}', 'Értékelés'),
                      _buildStatCard(Icons.trending_up, '${widget.recipe.difficulty}/5', 'Nehézség'),
                    ],
                  ),
                  SizedBox(height: 20),
                  
                  // Hozzávalók
                  ExpansionTile(
                    title: Text('Hozzávalók', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    initiallyExpanded: _isIngredientsExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _isIngredientsExpanded = expanded;
                      });
                    },
                    children: widget.recipe.ingredients.map((ingredient) {
                      return ListTile(
                        leading: Icon(Icons.check_circle_outline, color: Colors.orange),
                        title: Text(ingredient),
                      );
                    }).toList(),
                  ),
                  
                  // Elkészítés
                  ExpansionTile(
                    title: Text('Elkészítés', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    initiallyExpanded: _isInstructionsExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _isInstructionsExpanded = expanded;
                      });
                    },
                    children: widget.recipe.instructions.asMap().entries.map((entry) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Text('${entry.key + 1}', style: TextStyle(color: Colors.white)),
                        ),
                        title: Text(entry.value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: Colors.orange, size: 24),
            SizedBox(height: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}