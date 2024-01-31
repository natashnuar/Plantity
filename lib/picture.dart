import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'infoplant.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:collection/collection.dart';
import 'package:Plantity/profilePage.dart';
import 'plantPage.dart';
import 'learn_more.dart';

class PicturePage extends StatefulWidget {
  static const routeName = 'PicturePageRoute';
  void Function(Plant) onAddPlant;

  PicturePage({Key? key, required this.onAddPlant}) : super(key: key);

  @override
  _PicturePageState createState() => _PicturePageState();
}

class LearnMoreArguments {
  final String? imagePath;
  final InfoPlant? plantInfo;
  final Function(Plant) addPlant;

  LearnMoreArguments({
    required this.imagePath,
    required this.plantInfo,
    required this.addPlant,
  });
}

class _PicturePageState extends State<PicturePage> {
  String? _result;
  String? _uploadedImagePath;

  Future<void> _pickImageFromGallery(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Run the TensorFlow Lite model with the picked image
      _classifyImage(image.path);
      setState(() {
        _uploadedImagePath = image.path;
      });

      // Show the result popup
      _showResultPopup(context);
    }
  }

  Future<void> _classifyImage(String imagePath) async {
    try {
      await Tflite.loadModel(
        model: 'images/model_unquant2.tflite',
        labels: 'images/labels2.txt',
      );

      // Run the inference
      final List? results = await Tflite.runModelOnImage(
        path: imagePath,
        numResults: 6,
        threshold: 0.05,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      // Get the result
      setState(() {
        _result = results!.isNotEmpty ? results[0]['label'] : 'No result';
      });
    } catch (e) {
      print('Error classifying image: $e');
    } finally {
      // Release the resources used by the model
      await Tflite.close();
    }
  }

  void _showResultPopup(BuildContext context) {
    // Look up additional information based on the result label
    InfoPlant? plantInfo;
    String? resultLabel = _result?.toLowerCase();

    plantInfo = infoPlants.firstWhereOrNull(
      (plant) =>
          plant.scientific_name.toLowerCase() == resultLabel ||
          plant.common_name.toLowerCase() == resultLabel,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Result',
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
          backgroundColor: Colors.lightGreen,
          content: Column(
            children: [
              if (_uploadedImagePath != null && _uploadedImagePath!.isNotEmpty)
                Image.file(File(_uploadedImagePath!))
              else
                const Text(
                  'No image selected',
                  style: TextStyle(color: Colors.white),
                ),
              const SizedBox(height: 16),
              const Text(
                'The plant you are looking for is',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                '$_result',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              if (plantInfo != null)
                Column(
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Common Name: ${plantInfo.common_name}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Scientific Name: ${plantInfo.scientific_name}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LearnMorePage(
                            arguments: LearnMoreArguments(
                              imagePath: _uploadedImagePath,
                              plantInfo: plantInfo,
                              addPlant:
                                  widget.onAddPlant, // Pass the callback here
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Learn More',
                      style: TextStyle(color: Colors.lightGreen),
                    ),
                  )
                ],
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Column(
          children: [
            const SizedBox(
              height: 25,
            ),
            SizedBox(
              height: size.height * 0.1,
              child: const Center(
                child: Text(
                  'Plantity',
                  style: TextStyle(
                    color: Colors.lightGreen,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 55,
                    child: Text(
                      'Search up your plant',
                      style: TextStyle(
                          fontSize: 23,
                          color: Color.fromARGB(123, 0, 61, 2),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(
                    height: 55,
                    child: Text(
                      'Please upload a photo of the leaves or flowers for more accurate results',
                      style: TextStyle(
                          fontSize: 17,
                          color: Color.fromARGB(123, 0, 61, 2),
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 60,
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () {
                        // Call the function to pick an image from the gallery
                        _pickImageFromGallery(context);
                      },
                      child: const Text(
                        'Upload photo',
                        style: TextStyle(fontSize: 17, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.add_a_photo),
              onPressed: () {
                // Uncomment the line below if you want to enable the camera button
                // _pickImageFromGallery(context);
              },
            ),
            IconButton(
              icon: const Icon(Icons
                  .local_florist), // Replace with a plant icon or custom icon
              onPressed: () {
                // Navigate to the plant page
                Navigator.pushNamed(context, PlantPage.routeName);
              },
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.pushNamed(context, ProfilePage.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }
}
