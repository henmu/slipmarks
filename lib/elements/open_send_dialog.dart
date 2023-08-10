import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:slipmarks/helpers/constants.dart';
import 'package:slipmarks/models/devices.dart';
import 'package:slipmarks/services/auth_service.dart';
import 'package:slipmarks/models/bookmark.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:slipmarks/services/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:http/http.dart' as http;

Future<void> _launchURL(String url) async {
  Uri parsedUrl = Uri.parse(url);
  if (!await launchUrl(parsedUrl, mode: LaunchMode.externalApplication)) {
    throw 'Could not launch $parsedUrl';
  }
}

class OpenAndSendDialog {
  final Bookmark bookmark;
  final BuildContext context;

  OpenAndSendDialog({required this.bookmark, required this.context});

  Future<void> openAndSendDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Bookmark handling',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  // mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(); // Close the dialog
                        _launchURL(bookmark.url); // Open the link
                      },
                      child: const Text('Open bookmark'),
                    ),
                    const SizedBox(width: 16),
                    Consumer(builder: (context, ref, _) {
                      final AsyncValue<List<Devices>> devicesAsyncValue =
                          ref.watch(devicesProvider);
                      return devicesAsyncValue.when(
                        data: (devicesList) {
                          return ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet<void>(
                                context: dialogContext,
                                builder: (BuildContext context) {
                                  return ListView.builder(
                                    itemCount: devicesList.length,
                                    itemBuilder: (context, index) {
                                      final device = devicesList[index];
                                      return ListTile(
                                        leading:
                                            const Icon(Icons.phone_android),
                                        title: Text(device.device_name ??
                                            'Not named Device'),
                                        onTap: () {
                                          final notificationPayload = {
                                            "title": bookmark.name,
                                            "url": bookmark.url,
                                          };

                                          final url = Uri.parse(
                                              '$SERVER_HOST/notify/${device.id}');
                                          final accessToken =
                                              AuthService.instance.accessToken;
                                          http
                                              .post(
                                            url,
                                            headers: {
                                              'Authorization':
                                                  'Bearer $accessToken',
                                              'Content-Type':
                                                  'application/json',
                                            },
                                            body:
                                                jsonEncode(notificationPayload),
                                          )
                                              .then((response) {
                                            if (response.statusCode == 200) {
                                              Navigator.pop(context);
                                              Navigator.pop(dialogContext);
                                            } else {
                                              print(
                                                  'Error sending notification: HTTP ${response.statusCode}');
                                            }
                                          }).catchError((error) {
                                            print(
                                                'Error sending notification: $error');
                                          });
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            child: const Text('Send to Device'),
                          );
                        },
                        loading: () {
                          return const CircularProgressIndicator();
                        },
                        error: (error, stackTrace) {
                          return const Text('Error loading devices');
                        },
                      );
                    }),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text('Close'))
              ],
            ),
          ),
        );
      },
    );
  }
}
