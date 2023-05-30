// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:chat/auth/class/group/group_members.dart';
import 'package:chat/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:flutter/services.dart' show rootBundle;

class GroupName extends StatefulWidget {
  GroupName({super.key, required this.contactList});
  var contactList;
  @override
  State<GroupName> createState() => _GroupNameState();
}

class _GroupNameState extends State<GroupName> {
  void selectImage() async {
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');
    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }

  final TextEditingController groupname = TextEditingController();
  File? image;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xFF4ECDAF),
      appBar: AppBar(
        backgroundColor: Color(0xFF4ECDAF),
        title: Text('Set Group Name'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 300,
              width: width,
              child: Image(
                image: AssetImage('assets/groupname2.gif'),
              ),
            ),
            SizedBox(
              height: 100,
              child: ScrollSnapList(
                itemBuilder: _buildListItem,
                itemCount: 8,
                itemSize: 150,
                onItemFocus: (index) async {
                  print(index);

                  image = await getImageFileFromAssets('G${index}.png');
                },
                dynamicItemSize: true,
              ),
            ),
            SizedBox(
              height: height * 0.02,
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: groupname,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'set group name',
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: height * 0.02,
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: GestureDetector(
                onTap: () {
                  print(image);
                  if (image != null && groupname.text != '') {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => GroupMembers(
                              contactList: widget.contactList,
                              groupName: groupname.text,
                              image: image!,
                            )));
                  } else {
                    showSnackBar(
                        context: context,
                        content: 'Please choose dp and title');
                  }
                },
                child: Container(
                  height: height * 0.08,
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.pink[300],
                  ),
                  child: Center(
                      child: Text(
                    'Next',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                ),
              ),
            ),
            SizedBox(
              height: height * 0.03,
            ),
          ],
        )),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    if (index == 0) {
      return GestureDetector(
        onTap: selectImage,
        child: Container(
          // color: Colors.red,
          width: 150,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.pink[300],
            child: CircleAvatar(
              radius: 47,
              backgroundImage: image != null
                  ? FileImage(image!)
                  : AssetImage('assets/G0.jpeg') as ImageProvider<Object>?,
            ),
          ),
        ),
      );
    }
    return Container(
      // color: Colors.red,
      width: 150,
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.pink[300],
        child: CircleAvatar(
          radius: 47,
          backgroundImage: AssetImage(
            'assets/G${index}.png',
          ),
        ),
      ),
    );
  }
}
