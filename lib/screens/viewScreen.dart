import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../module/frameEdit.dart';
import '../module/image.dart';
import 'editScreen.dart';

class ViewScreen extends StatefulWidget {
  @override
  State<ViewScreen> createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  String? imagePath;
  List<ImageItem>? images;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Jenny\'s Frame',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        elevation: 8,
        leading: IconButton(
          onPressed: () async {
          },
          icon: Icon(Icons.arrow_back),
        ),
        actions: [
          Icon(Icons.search),
          SizedBox(width: 10),
          Icon(Icons.bookmark_border_rounded),
          SizedBox(width: 10),
          Icon(Icons.shopping_bag_outlined),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top Section
          SizedBox(
              height: 2,
              child: Container(
                color: Colors.grey.shade200,
              )),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(width: 15),
                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      AssetImage('assets/img.png'), // Replace with actual image
                ),
                SizedBox(width: 20),
                Text(
                  'Jenny Wilson',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(
              height: 8,
              child: Container(
                color: Colors.grey.shade200,
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
                'Lorem Ipsum is simply dummy text of printing and typesetting industry lorem ipsum news.'),
          ),
          // Bio Section
          SizedBox(height: 5),
          Text(
            '#Organic | #ClassyAffair | #Multicolor | ',
            style: TextStyle(fontSize: 14, color: Color(0xFF7E59E7)),
          ),
          Text('#Oversized | #Minimalism',
              style: TextStyle(fontSize: 14, color: Color(0xFF7E59E7))),
          SizedBox(height: 16),
          SizedBox(
              height: 8,
              child: Container(
                color: Colors.grey.shade200,
              )),

          // Your Frames Section

          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Frames',
                          style: TextStyle(
                              fontSize: 16, )),
                      SizedBox(height: 5,),
                      Expanded(
                        child: imagePath != null
                            ? Image.file(File(imagePath!),fit :BoxFit.fill, width: 320, )
                            : Icon(Icons.image_outlined, size: 100),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Section
          SizedBox(height: 10),
          Container(
            width: 320,
            child: OutlinedButton(
              onPressed: () async {
                EditFrameResult? result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditFrameScreen(images: images,prevImgPath: imagePath,)),
                );

                setState(() {
                  images = result?.imageItems;
                  imagePath = result?.imagePath;
                });
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius:BorderRadius.zero,
                    side: BorderSide(color: Colors.purple),
                  ),
                ),
              ),
              child: Text('Edit Frame'),
            ),
          ),
          SizedBox(height: 24,
              child: Container(
                color: Colors.grey.shade200,
              )),
        ],
      ),
    );
  }
}
