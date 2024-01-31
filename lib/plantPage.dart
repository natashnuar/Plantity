import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:Plantity/profilePage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:awesome_notifications/awesome_notifications.dart';

import 'main.dart';

class PlantPage extends StatefulWidget {
  static const routeName = 'PlantPageRoute';

  const PlantPage({Key? key}) : super(key: key);

  @override
  _PlantPageState createState() => _PlantPageState();
}

class _PlantPageState extends State<PlantPage> {
  List<Plant> plants = [];

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    // Load saved plants when the page is initialized
    loadSavedPlants();
    // Initialize notifications
    initNotifications();
    AwesomeNotifications().initialize(
      null, // default settings
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic notifications',
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white,
        ),
      ],
    );
  }

  void loadSavedPlants() async {
    List<Plant> savedPlants = await getSavedPlants();
    setState(() {
      plants = savedPlants;
    });
  }

  void initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<List<Plant>> getSavedPlants() async {
    User? user = FirebaseAuth.instance.currentUser;

    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('user')
        .doc(user?.uid)
        .collection('savedPlant')
        .get();

    List<Plant> savedPlants = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Plant(
        name: doc.id,
        description: data['description'] ?? '',
        commonName: data['commonName'] ?? '',
        scientificName: data['scientificName'] ?? '',
        sunExposure: data['sunExposure'] ?? '',
        soilRequirement: data['soilRequirement'] ?? '',
        wateringSchedule: data['wateringSchedule'] ?? '',
        soilph: data['soilph'] ?? '',
        fertilizer: data['fertilizer'] ?? '',
        growth: data['growth'] ?? '',
        imagePath: data['imageLink'] ?? '',
        dailyReminder: data['dailyReminder'] ?? false,
        weeklyReminder: data['weeklyReminder'] ?? false,
        monthlyReminder: data['monthlyReminder'] ?? false,
      );
    }).toList();

    return savedPlants;
  }

  void showPlantDetails(Plant plant) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(
                                Icons.notifications), // Use the bell icon here
                            onPressed: () {
                              _showReminderDialog(context, plant);
                            },
                          ),
                        ],
                      ),
                      const Text(
                        'Common Name:',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        plant.commonName,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const Text(
                        'Scientific Name:',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        plant.scientificName,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const Text(
                        'Sun Exposure:',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        plant.sunExposure,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const Text(
                        'Growth:',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        plant.growth,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const Text(
                        'Soil Requirement:',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        plant.soilRequirement,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const Text(
                        'Watering Schedule:',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        plant.wateringSchedule,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const Text(
                        'Soil pH:',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        plant.soilph,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const Text(
                        'Fertilizer:',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        plant.fertilizer,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showReminderDialog(BuildContext context, Plant plant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SimpleDialog(
              title: Text('Set Reminder for ${plant.commonName}'),
              children: <Widget>[
                SwitchListTile(
                  title: Text('Daily'),
                  value: plant.dailyReminder,
                  onChanged: (bool value) {
                    setState(() {
                      plant.dailyReminder = value;
                      if (value) {
                        _scheduleDailyNotification(
                          'Daily Reminder for ${plant.commonName}',
                          TimeOfDay(hour: 10, minute: 0),
                          plant.name.hashCode.abs(),
                        );
                      } else {
                        _cancelNotification(plant.name.hashCode.abs());
                      }
                    });
                  },
                ),
                SwitchListTile(
                  title: Text('Once a Week'),
                  value: plant.weeklyReminder,
                  onChanged: (bool value) {
                    setState(() {
                      plant.weeklyReminder = value;
                      if (value) {
                        _scheduleNotification(
                          'Weekly Reminder for ${plant.commonName}',
                          Duration(minutes: 1),
                          plant.name.hashCode.abs() * 2,
                        );
                      } else {
                        _cancelNotification(plant.name.hashCode.abs() * 2);
                      }
                    });
                  },
                ),
                SwitchListTile(
                  title: Text('Once a Month'),
                  value: plant.monthlyReminder,
                  onChanged: (bool value) {
                    setState(() {
                      plant.monthlyReminder = value;
                      if (value) {
                        _scheduleNotification(
                          'Monthly Reminder for ${plant.commonName}',
                          Duration(minutes: 2),
                          plant.name.hashCode.abs() * 3,
                        );
                      } else {
                        _cancelNotification(plant.name.hashCode.abs() * 3);
                      }
                    });
                  },
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            );
          },
        );
      },
    );
  }

  void _scheduleDailyNotification(
      String title, TimeOfDay reminderTime, int id) async {
    print('Scheduling daily notification for ${title}');
    DateTime now = DateTime.now();
    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    if (now.isAfter(scheduledDate)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }

    Duration timeDifference = scheduledDate.difference(now);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'basic_channel',
        title: title,
        body: 'Water Your Plant!!',
      ),
      schedule: NotificationInterval(
        interval: timeDifference.inSeconds,
      ),
    );
  }

  void _scheduleNotification(String title, Duration interval, int id) async {
    print('Scheduling daily notification for ${title}');
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'basic_channel',
        title: title,
        body: 'It is time to water your plant!!',
      ),
      schedule: NotificationInterval(
        interval: interval.inSeconds,
        repeats: true,
      ),
    );
  }

  void _cancelNotification(int id) async {
    print('Scheduling daily notification for ${id}');
    await AwesomeNotifications().cancel(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            const SizedBox(
              child: Center(
                child: Text(
                  'Plantity',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const SizedBox(
              child: Center(
                child: Text(
                  'Your Plants',
                  style: TextStyle(
                    color: Color.fromARGB(123, 0, 61, 2),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            plants.isEmpty
                ? const Column(
                    children: [
                      SizedBox(
                        height: 240,
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'No plants added',
                            style: TextStyle(
                                fontSize: 23,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  )
                : Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          plants.length,
                          (index) {
                            Plant plant = plants[index];
                            return GestureDetector(
                              onTap: () {
                                // Show plant details when clicked
                                showPlantDetails(plant);
                              },
                              child: Container(
                                height: 500,
                                width: 394,
                                margin: const EdgeInsets.all(8.0),
                                child: Card(
                                  color: const Color.fromARGB(123, 0, 61, 2),
                                  child: ListTile(
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Container(
                                            child: Image.network(
                                              plant.imagePath,
                                              height: 200,
                                              width: 390,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          plant.commonName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 25,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          plant.scientificName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.add_a_photo),
              onPressed: () {
                Navigator.pushNamed(context, PicturePageRoute.routeName);
              },
            ),
            IconButton(
              icon: const Icon(Icons.local_florist),
              onPressed: () {
                // Handle navigating to the add plant page
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

class Plant {
  final String name;
  final String description;
  final String commonName;
  final String scientificName;
  final String sunExposure;
  final String soilRequirement;
  final String wateringSchedule;
  final String soilph;
  final String fertilizer;
  final String growth;
  final String imagePath;
  bool dailyReminder;
  bool weeklyReminder;
  bool monthlyReminder;

  Plant({
    required this.name,
    required this.description,
    required this.commonName,
    required this.scientificName,
    required this.sunExposure,
    required this.soilRequirement,
    required this.wateringSchedule,
    required this.soilph,
    required this.fertilizer,
    required this.growth,
    required this.imagePath,
    required this.dailyReminder,
    required this.weeklyReminder,
    required this.monthlyReminder,
  });
}
