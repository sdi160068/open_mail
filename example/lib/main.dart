// ignore_for_file: use_build_context_synchronously


import 'package:flutter/material.dart';
import 'package:open_mail/open_mail.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Open Mail Example"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // Button to open a mail app
            ElevatedButton(
              child: const Text("Open Mail App"),
              onPressed: () async {
                // Try to open the mail app
                var result = await OpenMail.openMailApp(
                  nativePickerTitle: 'Select email app to open',
                );

                // If no mail apps are installed
                if (!result.didOpen && !result.canOpen) {
                  showNoMailAppsDialog(context);
                }
                // If multiple mail apps are available on iOS, show a picker
                else if (!result.didOpen && result.canOpen) {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return MailAppPickerDialog(
                        mailApps: result.options,
                      );
                    },
                  );
                }
              },
            ),

            // Button to test mail app detection
            ElevatedButton(
              child: const Text("Debug Mail App Detection"),
              onPressed: () async {
                try {
                  // Get installed mail apps with detailed logging
                  // Debug print removed
                  var options = await OpenMail.getMailApps();
                  // Debug print removed
                  // Debug print removed
                  // Show the list of detected mail apps
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: Text('Detected ${options.length} Mail Apps'),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: options
                                .map((app) => ListTile(
                                      title:
                                          Text('${app.name} (${app.nativeId})'),
                                      subtitle: Text(
                                          'ID: ${app.nativeId ?? "No ID"}, Scheme: ${app.iosLaunchScheme ?? "No Scheme"}'),
                                    ))
                                .toList(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Close'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      );
                    },
                  );
                } catch (e) {
                  // Debug print removed
                }
              },
            ),

            // Button to compose an email in the mail app
            ElevatedButton(
              child: const Text('Open mail app, with email already composed'),
              onPressed: () async {
                // Define the content of the email with debug info
                EmailContent email = EmailContent(
                  to: ['user@domain.com'], // Recipient(s)
                  subject: 'Hello!', // Email subject
                  body:
                      'How are you doing? [Debug: ${DateTime.now()}]', // Email body with timestamp for debugging
                  cc: ['user2@domain.com', 'user3@domain.com'], // CC recipients
                  bcc: ['boss@domain.com'], // BCC recipients
                );

                // Debug log
                // Debug print removed

                OpenMailAppResult result;

                try {
                  // Try to compose a new email in a mail app
                  result = await OpenMail.composeNewEmailInMailApp(
                      nativePickerTitle: 'Select email app to compose',
                      emailContent: email);

                  // Debug log after attempt
                  // Debug print removed

                  // If no mail apps are installed
                  if (!result.didOpen && !result.canOpen) {
                    showNoMailAppsDialog(context);
                  }
                  // If multiple mail apps are available on iOS, show a picker
                  else if (!result.didOpen && result.canOpen) {
                    showDialog(
                      context: context,
                      builder: (_) => MailAppPickerDialog(
                        mailApps: result.options,
                        emailContent: email,
                      ),
                    );
                  }
                } catch (e) {
                  // Catch and print any exceptions
                  // Debug print removed
                  // Show error dialog to user
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Error'),
                      content: Text('Failed to compose email: $e'),
                      actions: [
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),

            // Button to get the list of installed mail apps
            ElevatedButton(
              child: const Text("Get Mail Apps"),
              onPressed: () async {
                try {
                  // Retrieve the list of installed mail apps
                  var apps = await OpenMail.getMailApps();

                  // Debug print removed
                  // Debug print removed

                  // If no mail apps are installed
                  if (apps.isEmpty) {
                    showNoMailAppsDialog(context);
                  }
                  // Show a dialog listing all available mail apps
                  else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return MailAppPickerDialog(
                          mailApps: apps,
                          emailContent: EmailContent(
                            to: ['user@domain.com'], // Pre-filled recipient
                            subject: 'Hello!', // Pre-filled subject
                            body: 'How are you doing?', // Pre-filled body
                            cc: [
                              'user2@domain.com',
                              'user3@domain.com'
                            ], // Pre-filled CC
                            bcc: ['boss@domain.com'], // Pre-filled BCC
                          ),
                        );
                      },
                    );
                  }
                } catch (e) {
                  // Debug print removed
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to show a dialog when no mail apps are found
  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Open Mail App"),
          content: const Text("No mail apps installed"),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
            )
          ],
        );
      },
    );
  }
}
