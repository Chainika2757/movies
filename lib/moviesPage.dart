import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movies/LoginPage.dart';

class MoviesPage extends StatefulWidget {
  @override
  _MoviesPageState createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  final String apiKey = "8b782ec3";
  List movies = [];
  List filteredMovies = [];
  bool isLoading = false;
  int currentPage = 1;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "Harry";
  String selectedSort = "A-Z";
  String selectedType = "";
  String selectedYear = "";

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse("https://www.omdbapi.com/?apikey=$apiKey&s=$searchQuery&page=$currentPage"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        if (data["Response"] == "True") {
          movies = data["Search"] ?? [];
          applyFilters();
        } else {
          movies = [];
          filteredMovies = [];
        }
      });
    } else {
      print("Failed to fetch movies");
    }

    setState(() {
      isLoading = false;
    });
  }

  void onSearch() {
    setState(() {
      currentPage = 1;
      searchQuery = searchController.text;
    });
    fetchMovies();
  }

  void nextPage() {
    setState(() {
      currentPage++;
    });
    fetchMovies();
  }

  void previousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
      fetchMovies();
    }
  }

  void applyFilters() {
    List tempMovies = List.from(movies);

    if (selectedYear.isNotEmpty) {
      tempMovies = tempMovies.where((movie) => movie["Year"] == selectedYear).toList();
    }
    if (selectedType.isNotEmpty) {
      tempMovies = tempMovies.where((movie) => movie["Type"].toLowerCase() == selectedType.toLowerCase()).toList();
    }
    if (selectedSort == "A-Z") {
      tempMovies.sort((a, b) => a["Title"].compareTo(b["Title"]));
    } else if (selectedSort == "Z-A") {
      tempMovies.sort((a, b) => b["Title"].compareTo(a["Title"]));
    }

    setState(() {
      filteredMovies = tempMovies;
    });
  }

  void showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Filter & Sort"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField(
                value: selectedSort,
                decoration: InputDecoration(labelText: "Sort By"),
                items: ["A-Z", "Z-A"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (value) {
                  setState(() => selectedSort = value!);
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField(
                value: selectedType.isNotEmpty ? selectedType : null,
                decoration: InputDecoration(labelText: "Type"),
                items: ["movie", "series", "episode"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (value) {
                  setState(() => selectedType = value!);
                },
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(labelText: "Year"),
                keyboardType: TextInputType.number,
                onChanged: (value) => selectedYear = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                applyFilters();
              },
              child: Text("Apply"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text("Movies", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.filter_list, color: Colors.white), onPressed: showFilterDialog),
          IconButton(icon: Icon(Icons.logout, color: Colors.white), onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage(isDarkMode: false, toggleTheme: (value) {})));
          }),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search for a movie...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onSubmitted: (value) => onSearch(),
            ),
          ),
          Expanded(
            child: filteredMovies.isEmpty && !isLoading
                ? Center(child: Text("No movies found"))
                : ListView.builder(
                    itemCount: filteredMovies.length,
                    itemBuilder: (context, index) {
                      final movie = filteredMovies[index];
                      return ListTile(
                        leading: Image.network(movie["Poster"], width: 50, height: 75, fit: BoxFit.cover),
                        title: Text(movie["Title"]),
                        subtitle: Text(movie["Year"]),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MovieDetailsPage(movie: movie)),
                          );
                        },
                      );
                    },
                  ),
          ),
          if (!isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: currentPage > 1 ? previousPage : null,
                    child: Text("Previous", style: TextStyle(fontSize: 16)),
                  ),
                  SizedBox(width: 20),
                  Text(
                    "Page $currentPage",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 20),
                  TextButton(
                    onPressed: nextPage,
                    child: Text("Next", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class MovieDetailsPage extends StatelessWidget {
  final Map movie;
  MovieDetailsPage({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(movie["Title"])),
      body: Column(
        children: [
          Image.network(movie["Poster"]),
          Text(movie["Title"]),
          Text("Year: ${movie["Year"]}"),
          Text("Type: ${movie["Type"]}"),
        ],
      ),
    );
  }
}