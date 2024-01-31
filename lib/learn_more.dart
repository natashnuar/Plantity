import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:Plantity/plantPage.dart';
import 'picture.dart';

class LearnMorePage extends StatelessWidget {
  final LearnMoreArguments arguments;
  final Function(Plant) addPlant;

  LearnMorePage({Key? key, required this.arguments})
      : addPlant = arguments.addPlant,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    print("LearnMorePage - imagePath: ${arguments.imagePath}");
    print("LearnMorePage - plantInfo: ${arguments.plantInfo}");

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Column(
          children: [
            SizedBox(
              height: size.height * 0.05,
            ),
            const SizedBox(
              child: Center(
                child: Text(
                  'Learn More',
                  style: TextStyle(
                    color: Colors.lightGreen,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Column(
              children: [
                if (arguments.imagePath != null &&
                    arguments.imagePath!.isNotEmpty)
                  Image.file(File(arguments.imagePath!)),
                if (arguments.plantInfo != null)
                  Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      ListTile(
                        title: Text(
                          'Common Name: ${arguments.plantInfo!.common_name}',
                          style: const TextStyle(
                            color: Color.fromARGB(123, 0, 61, 2),
                            fontSize: 19,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scientific Name: ${arguments.plantInfo!.scientific_name}',
                              style: const TextStyle(
                                color: Color.fromARGB(123, 0, 61, 2),
                                fontSize: 19,
                              ),
                            ),
                            Text(
                              'Sun Exposure: ${arguments.plantInfo!.sun}',
                              style: const TextStyle(
                                color: Color.fromARGB(123, 0, 61, 2),
                                fontSize: 19,
                              ),
                            ),
                            Text(
                              'Soil requirement: ${arguments.plantInfo!.soil}',
                              style: const TextStyle(
                                color: Color.fromARGB(123, 0, 61, 2),
                                fontSize: 19,
                              ),
                            ),
                            Text(
                              'Watering Schedule: ${arguments.plantInfo!.water}',
                              style: const TextStyle(
                                color: Color.fromARGB(123, 0, 61, 2),
                                fontSize: 19,
                              ),
                            ),
                            Text(
                              'Soil pH: ${arguments.plantInfo!.soilph}',
                              style: const TextStyle(
                                color: Color.fromARGB(123, 0, 61, 2),
                                fontSize: 19,
                              ),
                            ),
                            Text(
                              'Fertilizer: ${arguments.plantInfo!.fertilizer}',
                              style: const TextStyle(
                                color: Color.fromARGB(123, 0, 61, 2),
                                fontSize: 19,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                SizedBox(
                  height: 40,
                  width: 250,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen),
                    onPressed: () {
                      savePlant(
                          arguments.plantInfo!.common_name,
                          arguments.plantInfo!.scientific_name,
                          arguments.plantInfo!.sun,
                          arguments.plantInfo!.soil,
                          arguments.plantInfo!.water,
                          arguments.plantInfo!.soilph,
                          arguments.plantInfo!.fertilizer,
                          arguments.plantInfo!.growth,
                          arguments.imagePath);

                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Add to Your Plants',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(123, 0, 61, 2)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future savePlant(
      String commonName,
      scientificName,
      sunExposure,
      soilRequirement,
      wateringSchedule,
      soilph,
      fertilizer,
      growth,
      imagePath) async {
    User? user = FirebaseAuth.instance.currentUser;

    // Create a unique document ID for each plant. You can use the Timestamp or any other unique data.
    String plantId = FirebaseFirestore.instance
        .collection('user')
        .doc(user?.uid)
        .collection('savedPlant')
        .doc()
        .id;

    Reference ref = FirebaseStorage.instance
        .ref()
        .child("${user?.uid}/savedPlant/$plantId.jpg");

    Uint8List bytes = File(imagePath).readAsBytesSync();
    await ref.putData(bytes);
    String imageLink = (await ref.getDownloadURL()).toString();

    await FirebaseFirestore.instance
        .collection('user')
        .doc(user?.uid)
        .collection('savedPlant')
        .doc(plantId)
        .set({
      'commonName': commonName,
      'scientificName': scientificName,
      'sunExposure': sunExposure,
      'soilRequirement': soilRequirement,
      'wateringSchedule': wateringSchedule,
      'soilph': soilph,
      'fertilizer': fertilizer,
      'growth': growth,
      'imageLink': imageLink,
    });

    print("Successfully added");
  }
}
