import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:slipmarks/helpers/constants.dart';
import 'package:slipmarks/services/auth_service.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:slipmarks/elements/stickyActionBarWrapper.dart';
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

class OpenAndSendSheet {
  final Bookmark bookmark;
  final BuildContext context;

  const OpenAndSendSheet({required this.bookmark, required this.context});

  WoltModalSheetPage openAndSendSheet(BuildContext modalSheetContext) {
    return WoltModalSheetPage.withSingleChild(
      backgroundColor: const Color(0xFF2D2D2D),
      stickyActionBar: StickyActionBarWrapper(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.of(modalSheetContext).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
      pageTitle: const Text('Open and Send'),
      topBarTitle: const Text('Open and Send'),
      closeButton: CloseButton(onPressed: Navigator.of(modalSheetContext).pop),
      mainContentPadding: const EdgeInsetsDirectional.all(16),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 120, top: 16),
        child: Consumer(
          builder: (context, ref, child) {
            final devicesAsyncValue = ref.watch(devicesProvider);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(modalSheetContext).pop(); // Close the sheet
                    _launchURL(bookmark.url); // Open the link
                  },
                  child: const Text('Open Link'),
                ),
                const SizedBox(height: 16),
                devicesAsyncValue.when(
                  data: (devicesList) {
                    return ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet<void>(
                          context: modalSheetContext,
                          builder: (BuildContext context) {
                            return ListView.builder(
                              itemCount: devicesList.length,
                              itemBuilder: (context, index) {
                                final device = devicesList[index];
                                return ListTile(
                                  leading: const Icon(Icons.phone_android),
                                  title: Text(
                                      device.device_name ?? 'Not named Device'),
                                  onTap: () {
                                    final notificationPayload = {
                                      "title": bookmark
                                          .name, // Use the bookmark's name
                                      "url": bookmark
                                          .url, // Use the bookmark's URL
                                    };

                                    final url = Uri.parse(
                                        '$SERVER_HOST/notify/${device.id}');
                                    final accessToken =
                                        AuthService.instance.accessToken;
                                    http
                                        .post(
                                      url,
                                      headers: {
                                        'Authorization': 'Bearer $accessToken',
                                        'Content-Type': 'application/json',
                                      },
                                      body: jsonEncode(notificationPayload),
                                    )
                                        .then((response) {
                                      if (response.statusCode == 200) {
                                        Navigator.pop(
                                            context); // Close the devices list
                                        Navigator.pop(
                                            modalSheetContext); // Close the open and send sheet
                                      } else {
                                        print(
                                            'Error sending notification: HTTP ${response.statusCode}');
                                      }
                                    }).catchError((error) {
                                      // Handle error
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
                    return CircularProgressIndicator();
                  },
                  error: (error, stackTrace) {
                    return Text('Error loading devices');
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
