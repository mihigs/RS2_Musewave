import 'package:flutter/material.dart';
import 'package:frontend/models/constants/result_card_types.dart';
import 'dart:ui';

class ResultItemCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final ResultCardType type;
  final String? imageUrl;
  final VoidCallback? onTap;
  final String? credits;

  const ResultItemCard({
    Key? key,
    required this.title,
    this.subtitle,
    required this.type,
    this.imageUrl,
    this.onTap,
    this.credits,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: 1, // Makes the widget square
            child: Card(
              child: Stack(
                children: [
                  // Background Image or Placeholder
                  if (imageUrl != null)
                    Positioned.fill(
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Positioned.fill(
                      child: ResultCardPlaceholder(type: type),
                    ),
                  // Backdrop Filter
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ),
                  ),
                  // Text Content
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              subtitle!,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
        if (credits != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 0, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                textAlign: TextAlign.left,
                "By: ${credits!}",
                style: Theme.of(context).textTheme.labelSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    );
  }
}

class ResultCardPlaceholder extends StatelessWidget {
  final ResultCardType type;

  const ResultCardPlaceholder({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getGradientColors(),
        ),
      ),
    );
  }

  List<Color> _getGradientColors() {
    switch (type) {
      case ResultCardType.Track:
        return [Colors.blue, Colors.lightBlueAccent];
      case ResultCardType.Album:
        return [Colors.green, Colors.lightGreenAccent];
      case ResultCardType.Artist:
        return [Colors.red, Colors.pinkAccent];
      case ResultCardType.Playlist:
        return [Colors.orange, Colors.deepOrangeAccent];
      default:
        return [Colors.deepPurple, Colors.purpleAccent];
    }
  }
}



// import 'package:flutter/material.dart';
// import 'package:frontend/models/constants/result_card_types.dart';
// import 'dart:ui';

// class ResultItemCard extends StatelessWidget {
//   final String title;
//   final String? subtitle;
//   final ResultCardType type;
//   final String? imageUrl;
//   final VoidCallback? onTap;

//   const ResultItemCard({
//     Key? key,
//     required this.title,
//     this.subtitle,
//     required this.type,
//     this.imageUrl,
//     this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AspectRatio(
//         aspectRatio: 1, // Makes the widget square
//         child: Card(
//           child: Stack(
//             children: [
//               // Background Image or Placeholder
//               if (imageUrl != null)
//                 Positioned.fill(
//                   child: Image.network(
//                     imageUrl!,
//                     fit: BoxFit.cover,
//                   ),
//                 )
//               else
//                 Positioned.fill(
//                   child: ResultCardPlaceholder(type: type),
//                 ),
//               // Backdrop Filter
//               Positioned.fill(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.4),
//                   ),
//                 ),
//               ),
//               // Text Content
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     Expanded(
//                       child: Text(
//                         title,
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                               color: Colors.white,
//                             ),
//                       ),
//                     ),
//                     if (subtitle != null)
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.only(top: 4.0),
//                           child: Text(
//                             subtitle!,
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .labelSmall
//                                 ?.copyWith(color: Colors.white),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ResultCardPlaceholder extends StatelessWidget {
//   final ResultCardType type;

//   const ResultCardPlaceholder({required this.type});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: _getGradientColors(),
//         ),
//       ),
//     );
//   }

//   List<Color> _getGradientColors() {
//     switch (type) {
//       case ResultCardType.Track:
//         return [Colors.blue, Colors.lightBlueAccent];
//       case ResultCardType.Album:
//         return [Colors.green, Colors.lightGreenAccent];
//       case ResultCardType.Artist:
//         return [Colors.red, Colors.pinkAccent];
//       case ResultCardType.Playlist:
//         return [Colors.orange, Colors.deepOrangeAccent];
//       default:
//         return [Colors.deepPurple, Colors.purpleAccent];
//     }
//   }
// }
