// lib/widgets/slide_up_card.dart
import 'package:flutter/material.dart';

class SlideUpCard extends StatelessWidget {
  final VoidCallback onClose;

  const SlideUpCard({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 300,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("영남대학교 IT관", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Icon(Icons.star)
              ],
            ),
            SizedBox(height: 10),
            Text("경북 경산시 삼풍동 영남대학교 공과대학본관", style: TextStyle(fontSize: 14, color: Color(0xFF868E96)),),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6), // 18px → 6LP
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44, // 44px → 15LP
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF20C997),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          )
                        ),
                        child: Text("출발"),
                      ),
                    ),
                  ),
                  SizedBox(width: 14), // 14px → 5LP
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE6FCF5),
                          foregroundColor: Color(0xFF20C997),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          )
                        ),
                        child: Text("도착"),
                      ),
                    ),
                  ),
                ],
              ),
            )
            ,
            Center(
              child: IconButton(
                icon: Icon(Icons.keyboard_arrow_down),
                onPressed: onClose,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
