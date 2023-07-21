import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:slipmarks/helpers/constants.dart';
import 'package:slipmarks/models/bookmark.dart';
import 'package:slipmarks/services/auth_service.dart';
import 'package:http/http.dart' as http;

class Links extends StatefulWidget {
  const Links({super.key});

  @override
  State<Links> createState() => _LinksState();
}

class _LinksState extends State<Links> {
  late Future<List<Bookmark>> futureTemporaryBookmarks;

  @override
  void initState() {
    super.initState();

    futureTemporaryBookmarks = fetchLinks();
  }

  Future<List<Bookmark>> fetchLinks() async {
    final url = Uri.parse("$SERVER_HOST/links");
    final accessToken = AuthService.instance.accessToken;
    final response =
        await http.get(url, headers: {'Authorization': 'Bearer $accessToken'});

    if (response.statusCode == 200) {
      final res = (json.decode(response.body) as List)
          .map((bookmarkJson) => Bookmark.fromJson(bookmarkJson))
          .toList();

      return res;
    } else {
      // TODO: show an error in UI instead
      throw Exception('Failed to load temporary bookmarks');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: const Color(0xFF1f1f1f),
            body: FutureBuilder<List<Bookmark>?>(
                future: futureTemporaryBookmarks,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(snapshot.data?[index].name ?? "got null",
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  )),
                              Text(snapshot.data?[index].url ?? "no url",
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ))
                            ]);
                      },
                    );
                  }

                  // By default, show a loading spinner.
                  return const CircularProgressIndicator();
                })));
  }
}


// class Links extends StatelessWidget {
//   const Links({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Column(children: [
//         const Text(
//           'This is the Home page',
//           style: TextStyle(
//             fontFamily: 'Inter',
//             color: Colors.white,
//           ),
//         ),
//         ElevatedButton(
//             onPressed: () async {
//               await AuthService.instance.logout();
//               if (context.mounted) {
//                 Navigator.of(context).replace(
//                   oldRoute: ModalRoute.of(context)!,
//                   newRoute: MaterialPageRoute(
//                       builder: (BuildContext context) => const Login()),
//                 );
//               }
//             },
//             child: const Text(
//               'Logout',
//               style: TextStyle(
//                 fontFamily: 'Inter',
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 11,
//               ),
//             ))
//       ]),
//     );
//   }
// }
