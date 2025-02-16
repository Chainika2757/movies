import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movies/LoginPage.dart'; // Ensure correct import

class MoviesPage extends StatefulWidget {
  @override
  _MoviesPageState createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  final String apiKey = "8b782ec3"; // Replace with your valid OMDb API key
  List movies = [];
  bool isLoading = false;
  int currentPage = 1;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "Harry"; // Default search query

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
        } else {
          movies = [];
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

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage(isDarkMode: false, toggleTheme: (value) {})),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text(
          "Movies",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: logout,
          ),
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
            child: movies.isEmpty && !isLoading
                ? Center(child: Text("No movies found"))
                : ListView.builder(
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies[index];
                      return ListTile(
                        leading: SizedBox(
                          width: 50,
                          height: 75,
                          child: Image.network(movie["Poster"], fit: BoxFit.cover),
                        ),
                        title: Text(movie["Title"]),
                        subtitle: Text(movie["Year"]),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieDetailsPage(movie: movie),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          if (isLoading)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            color: Colors.black12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: currentPage > 1 ? previousPage : null,
                  child: Text("Previous", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Text("Page $currentPage", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: movies.isNotEmpty ? nextPage : null,
                  child: Text("Next", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Movie Details Page
class MovieDetailsPage extends StatelessWidget {
  final Map movie;
  MovieDetailsPage({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text(movie["Title"]),
      ),
      body: Column(
        children: [
          Image.network(movie["Poster"]),
          SizedBox(height: 10),
          Text(movie["Title"], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text("Year: ${movie["Year"]}"),
          Text("Type: ${movie["Type"]}"),
        ],
      ),
    );
  }
}
