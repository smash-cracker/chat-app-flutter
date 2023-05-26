// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:typed_data';

import 'package:chat/auth/auth_methods.dart';
import 'package:chat/auth/class/controller.dart';
import 'package:chat/auth/phone_login.dart';
import 'package:chat/screen/mainpage.dart';
import 'package:chat/utils/loader.dart';
import 'package:chat/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class Name extends ConsumerStatefulWidget {
  final String phone;
  const Name({super.key, required this.phone});

  @override
  ConsumerState<Name> createState() => _NameState();
}

class _NameState extends ConsumerState<Name> {
  final TextEditingController _nameController = TextEditingController();
  Uint8List? _image;
  bool _isloading = false;

  void SignuUser() async {
    setState(() {
      _isloading = true;
    });
    String results = await authMethods().signupuser(
        name: _nameController.text, file: _image!, phone: widget.phone);
    setState(() {
      _isloading = false;
    });
    if (results != 'success') {
      showSnakBar(results, context);
    } else {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => MainPage()));
    }
  }

  pickImage(ImageSource source) async {
    final ImagePicker _imgpick = ImagePicker();
    XFile? _file = await _imgpick.pickImage(source: source);
    if (_file != null) {
      return await _file.readAsBytes();
    }
    print('NO Image is selected');
  }

  void selectImage() async {
    Uint8List? im = await pickImage(ImageSource.gallery);

    setState(() {
      _image = im;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
            child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 150),
              Stack(
                children: [
                  _image != null
                      ? CircleAvatar(
                          radius: 64,
                          backgroundImage: MemoryImage(_image!),
                        )
                      : const CircleAvatar(
                          radius: 64,
                          backgroundImage: AssetImage(
                            'assets/G0.jpeg',
                          ),
                        ),
                  Positioned(
                    bottom: -5,
                    right: -5,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(Icons.add_a_photo),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: _nameController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'What should we call you?',
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.pink.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  SignuUser();
                  ref.watch(userDataAuthProvider).when(
                        data: (user) {
                          if (user == null) {
                            return MyPhone();
                          }
                          return MainPage();
                        },
                        error: (error, trace) {
                          return Container();
                        },
                        loading: () => Scaffold(
                          body: Center(
                            child: Loader(),
                          ),
                        ),
                      );
                },
                child: Text("Submit"),
              ),
            ],
          ),
        )),
      ),
    );
  }
}
