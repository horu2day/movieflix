import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  Future<List<MovieModel>> popMovies = ApiService.getMovies("popular");
  Future<List<MovieModel>> nowMovies = ApiService.getMovies("now-playing");
  Future<List<MovieModel>> commingMovies = ApiService.getMovies("coming-soon");

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
                //scrollDirection: Axis.vertical,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      "Popular Movies",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FutureBuilder(
                    future: popMovies,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Flexible(
                          fit: FlexFit.loose,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 15,
                              ),
                              SizedBox(
                                height: 240,
                                child: makeList(snapshot, 1, 340, 220),
                              ),
                            ],
                          ),
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      "Now in Cinemas",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  FutureBuilder(
                    future: nowMovies,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Flexible(
                          fit: FlexFit.loose,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 230,
                                child: makeList(snapshot, 2, 150, 150),
                              ),
                            ],
                          ),
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      "Comming Soon",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FutureBuilder(
                    future: commingMovies,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Flexible(
                          fit: FlexFit.loose,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 300,
                                child: makeList(snapshot, 2, 150, 150),
                              ),
                            ],
                          ),
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  ListView makeList(AsyncSnapshot<List<MovieModel>> snapshot, int movieType,
      double width, double height) {
    const String imageBaseUrl = "https://image.tmdb.org/t/p/w500";
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: snapshot.data!.length,
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 12),
      itemBuilder: (context, index) {
        //print(index);
        var movie = snapshot.data![index];

        String pPath = movie.posterPath;
        var posterUrl = "$imageBaseUrl$pPath";
        return Movie(
          title: movie.title,
          posterPath: posterUrl.toString(),
          id: movie.id,
          movieType: movieType,
          width: width,
          height: height,
        );
      },
      separatorBuilder: (context, index) => const SizedBox(
        width: 15,
      ),
    );
  }
}

class Movie extends StatelessWidget {
  final String title, posterPath, id;
  final int movieType;
  final double width, height;
  const Movie({
    super.key,
    required this.title,
    required this.posterPath,
    required this.id,
    required this.movieType,
    required this.width,
    required this.height,
  });
  //const Webtoon({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => DetailScreen(
        //       title: title,
        //       thumb: thumb,
        //       id: id,
        //     ),
        //     fullscreenDialog: true,
        //   ),
        // );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Hero(
            tag: id,
            child: Container(
                width: width,
                height: height,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 15,
                        offset: const Offset(10, 10),
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ]),
                child: Image.network(
                  posterPath,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                )),
          ),
          const SizedBox(
            height: 10,
          ),
          if (movieType > 1)
            SizedBox(
              width: 150,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ApiService {
  static const String baseUrl = "https://movies-api.nomadcoders.workers.dev";

  //pub.dev 에서 dart, flutter 공식 패키지
  //웹서비스를 위해서 http
  static Future<List<MovieModel>> getMovies(String movieType) async {
    List<MovieModel> movieInstances = [];
    final url = Uri.parse('$baseUrl/$movieType');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);

      // movies 변수를 올바른 형식으로 처리
      final movies = decodedResponse['results'] as List<dynamic>;

      for (var movie in movies) {
        final instance = MovieModel.fromJson(movie);
        movieInstances.add(instance);
        print(instance.id);
        print(instance.posterPath);
        print(instance.title);
      }

      return movieInstances;
    }
    throw Error();
  }

  // static Future<WebtoonDetailModel> getToonById(String id) async {
  //   final url = Uri.parse('$baseUrl/$id');
  //   final response = await http.get(url);
  //   if (response.statusCode == 200) {
  //     final webtoon = jsonDecode(response.body);
  //     final instance = WebtoonDetailModel.fromJson(webtoon);
  //     return instance;
  //   }
  //   throw Error();
  // }

  // static Future<List<WebtoonEpisodeModel>> getLatestEpisodesById(
  //     String id) async {
  //   List<WebtoonEpisodeModel> webtoonEpisodes = [];
  //   final url = Uri.parse('$baseUrl/$id/episodes');
  //   final response = await http.get(url);
  //   if (response.statusCode == 200) {
  //     final episodes = jsonDecode(response.body);
  //     for (var episode in episodes) {
  //       final instance = WebtoonEpisodeModel.fromJson(episode);
  //       webtoonEpisodes.add(instance);
  //     }
  //     return webtoonEpisodes;
  //   }
  //   throw Error();
  // }
}

class MovieModel {
  final String title, posterPath, id;

  MovieModel.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        posterPath = json['poster_path'],
        id = json['id'].toString();
}

////////////////////////////////////////////////////////////////////
// class DetailScreen extends StatefulWidget {
//   final String title, thumb, id;

//   const DetailScreen({
//     super.key,
//     required this.title,
//     required this.thumb,
//     required this.id,
//   });

//   @override
//   State<DetailScreen> createState() => _DetailScreenState();
// }

// class _DetailScreenState extends State<DetailScreen> {
//   late Future<WebtoonDetailModel> webtoon;
//   late Future<List<WebtoonEpisodeModel>> episodes;
//   late SharedPreferences pref;
//   bool isLiked = false;

//   Future initPrefs() async {
//     pref = await SharedPreferences.getInstance();
//     final likedToons = pref.getStringList('likedToons');
//     if (likedToons != null) {
//       if (likedToons.contains(widget.id)) {
//         setState(() {
//           isLiked = true;
//         });
//       }
//     } else {
//       pref.setStringList('likedToons', []);
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     webtoon = []; //ApiService.getToonById(widget.id);
//     episodes =[];// ApiService.getLatestEpisodesById(widget.id);
//     initPrefs();
//   }

//   onHeartTap() async {
//     final likedToons = pref.getStringList('likedToons');
//     if (likedToons != null) {
//       if (isLiked) {
//         likedToons.remove(widget.id);
//       } else {
//         likedToons.add(widget.id);
//       }
//       await pref.setStringList('likedToons', likedToons);
//       setState(() {
//         isLiked = !isLiked;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         centerTitle: true,
//         elevation: 2,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.green,
//         actions: [
//           IconButton(
//             onPressed: onHeartTap,
//             icon: Icon(
//               isLiked ? Icons.favorite : Icons.favorite_outline_outlined,
//             ),
//           ),
//         ],
//         title: Text(
//           widget.title,
//           style: const TextStyle(
//             fontSize: 24,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Hero(
//                     tag: widget.id,
//                     child: Container(
//                         width: 250,
//                         clipBehavior: Clip.hardEdge,
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(15),
//                             boxShadow: [
//                               BoxShadow(
//                                 blurRadius: 15,
//                                 offset: const Offset(10, 10),
//                                 color: Colors.black.withOpacity(0.5),
//                               ),
//                             ]),
//                         child: Image.network(widget.thumb)),
//                   ),
//                 ],
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               FutureBuilder(
//                 future: webtoon,
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData) {
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           snapshot.data!.about,
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                         const SizedBox(
//                           height: 15,
//                         ),
//                         Text(
//                           '${snapshot.data!.genre} / ${snapshot.data!.age}',
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                       ],
//                     );
//                   }
//                   return const Text('...');
//                 },
//               ),
//               const SizedBox(
//                 height: 25,
//               ),
//               FutureBuilder(
//                 future: episodes,
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData) {
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         for (var episode in snapshot.data!)
//                           Episode(episode: episode, webtoonId: widget.id),
//                       ],
//                     );
//                   }
//                   return Container();
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// ////////////////////////////////////////////////////////////////
// class WebtoonEpisodeModel {
//   final String id, title, rating, data;

//   WebtoonEpisodeModel.fromJson(Map<String, dynamic> json)
//       : id = json['id'],
//         title = json['title'],
//         rating = json['rating'],
//         data = json['date'];
// }

// class Episode extends StatelessWidget {
//   const Episode({
//     Key? key,
//     required this.episode,
//     required this.webtoonId,
//   }) : super(key: key);

//   final WebtoonEpisodeModel episode;
//   final String webtoonId;

//   onButtonTap() async {
//     await launchUrlString(
//         "https://comic.naver.com/webtoon/detail?titleId=$webtoonId&no=${episode.id}");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onButtonTap,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: const Border(
//             top: BorderSide(color: Colors.green),
//             left: BorderSide(color: Colors.green),
//             right: BorderSide(color: Colors.green),
//             bottom: BorderSide(color: Colors.green),
//           ),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               blurRadius: 15,
//               offset: const Offset(5, 5),
//               color: Colors.black.withOpacity(0.5),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 episode.title,
//                 style: const TextStyle(
//                   color: Colors.green,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const Icon(
//                 Icons.chevron_right_rounded,
//                 color: Colors.green,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
