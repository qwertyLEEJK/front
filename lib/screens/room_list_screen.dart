import 'package:flutter/material.dart';

final List<Map<String, dynamic>> roomData = [
  {
    "room": "301 임베디드설계실",
    "left": 160,
    "top": 250
  },
  {
    "room": "303 이동통신실험실",
    "left": 160,
    "top": 480
  },
  {
    "room": "307 멀티미디어신호처리실험실",
    "left": 160,
    "top": 710
  },
  {
    "room": "314 학과사무실",
    "left": 950,
    "top": 230
  },
  {
    "room": "318 창의설계학습실",
    "left": 1220,
    "top": 230
  },
  {
    "room": "319 멀티미디어실습실",
    "left": 1650,
    "top": 230
  },
  {
    "room": "322 HW실습실",
    "left": 1220,
    "top": 580
  },
  {
    "room": "323 세미나실",
    "left": 1650,
    "top": 580
  },
  {
    "room": "327 화장실(여)",
    "left": 2500,
    "top": 300
  },
  {
    "room": "328 화장실(남)",
    "left": 2500,
    "top": 550
  },
  {
    "room": "338 무선통신실험실",
    "left": 2500,
    "top": 800
  }
];

class RoomListScreen extends StatelessWidget {
  const RoomListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('강의실 목록')),
      body: ListView.builder(
        itemCount: roomData.length,
        itemBuilder: (context, index) {
          final room = roomData[index];
          return ListTile(
            title: Text(room['room']),
            subtitle: Text('좌표: left ${room['left']}, top ${room['top']}'),
          );
        },
      ),
    );
  }
}
