// import 'package:audioplayers/audioplayers.dart';

// class PlayerSingleton {
//   AudioCache? _player;
//   static final PlayerSingleton? _instance = PlayerSingleton._internal();

//   PlayerSingleton._internal() {
//     //if (_player == null) {
//     // _player = AudioCache();
//     // _player!.play('alarm.mp3');
//     //_player!.load('alarm.mp3');
//     // _instance = this;
//     //}
//   }
//   // static final PlayerSingleton _singleton = PlayerSingleton._internal();

//   factory PlayerSingleton() => _instance ?? PlayerSingleton._internal();

//   play() async {
//     if (_player != null) {
//       await _player!.play('alarm.mp3');
//     } else {
//       _player = AudioCache();
//       await _player!.play('alarm.mp3');
//     }
//   }
// }
