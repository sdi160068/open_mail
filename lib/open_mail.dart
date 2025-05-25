// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:collection/collection.dart'; // Import for firstWhereOrNull
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platform/platform.dart';
import 'package:url_launcher/url_launcher.dart';

/// Launch Schemes for supported apps:
const String _LAUNCH_SCHEME_APPLE_MAIL = 'message://';
const String _LAUNCH_SCHEME_GMAIL = 'googlegmail://';
const String _LAUNCH_SCHEME_DISPATCH = 'x-dispatch://';
const String _LAUNCH_SCHEME_SPARK = 'readdle-spark://';
const String _LAUNCH_SCHEME_AIRMAIL = 'airmail://';
const String _LAUNCH_SCHEME_OUTLOOK = 'ms-outlook://';
const String _LAUNCH_SCHEME_YAHOO = 'ymail://';
const String _LAUNCH_SCHEME_FASTMAIL = 'fastmail://';
const String _LAUNCH_SCHEME_SUPERHUMAN = 'superhuman://';
const String _LAUNCH_SCHEME_PROTONMAIL = 'protonmail://';

/// A list of mail apps that can be used to open email.
///
/// This list is not exhaustive and may not include all mail apps available on
/// the user's device.
final List<MailApp> mailApps = <MailApp>[
  MailApp(
    name: 'Apple Mail',
    iosLaunchScheme: _LAUNCH_SCHEME_APPLE_MAIL,
    composeData: ComposeData(
      scheme: 'message://',
    ),
  ),
  MailApp(
    name: 'Gmail',
    iosLaunchScheme: _LAUNCH_SCHEME_GMAIL,
    composeData: ComposeData(
      scheme: '$_LAUNCH_SCHEME_GMAIL/co',
    ),
  ),
  MailApp(
    name: 'Dispatch',
    iosLaunchScheme: _LAUNCH_SCHEME_DISPATCH,
    composeData: ComposeData(
      scheme: '$_LAUNCH_SCHEME_DISPATCH/compose',
    ),
  ),
  MailApp(
    name: 'Spark',
    iosLaunchScheme: _LAUNCH_SCHEME_SPARK,
    composeData: ComposeData(
      scheme: '${_LAUNCH_SCHEME_SPARK}compose',
      toParameter: 'recipient',
    ),
  ),
  MailApp(
    name: 'Airmail',
    iosLaunchScheme: _LAUNCH_SCHEME_AIRMAIL,
    composeData: ComposeData(
      scheme: '${_LAUNCH_SCHEME_AIRMAIL}compose',
      bodyParameter: 'plainBody',
    ),
  ),
  MailApp(
    name: 'Outlook',
    iosLaunchScheme: _LAUNCH_SCHEME_OUTLOOK,
    composeData: ComposeData(
      scheme: '${_LAUNCH_SCHEME_OUTLOOK}compose',
    ),
  ),
  MailApp(
    name: 'Yahoo Mail',
    iosLaunchScheme: _LAUNCH_SCHEME_YAHOO,
    composeData: ComposeData(
      scheme: '${_LAUNCH_SCHEME_YAHOO}mail/compose',
    ),
  ),
  MailApp(
    name: 'Fastmail',
    iosLaunchScheme: _LAUNCH_SCHEME_FASTMAIL,
    composeData: ComposeData(
      scheme: '${_LAUNCH_SCHEME_FASTMAIL}mail/compose',
    ),
  ),
  MailApp(
    name: 'Superhuman',
    iosLaunchScheme: _LAUNCH_SCHEME_SUPERHUMAN,
    composeData: ComposeData(scheme: _LAUNCH_SCHEME_SUPERHUMAN),
  ),
  MailApp(
    name: 'ProtonMail',
    iosLaunchScheme: _LAUNCH_SCHEME_PROTONMAIL,
    composeData: ComposeData(
      scheme: '${_LAUNCH_SCHEME_PROTONMAIL}mailto:',
    ),
  ),
];

class OpenMail {
  OpenMail._();

  @visibleForTesting
  static Platform platform = const LocalPlatform();

  static bool get _isAndroid => platform.isAndroid;

  static bool get _isIOS => platform.isIOS;

  static const MethodChannel _channel = MethodChannel('open_mail');
  static List<String> _filterList = <String>['paypal'];
  static final List<MailApp> _supportedMailApps = [
    MailApp(
      name: 'Apple Mail',
      iosLaunchScheme: _LAUNCH_SCHEME_APPLE_MAIL,
      composeData: ComposeData(
        scheme: 'message://',
      ),
    ),
    MailApp(
      name: 'Gmail',
      iosLaunchScheme: _LAUNCH_SCHEME_GMAIL,
      composeData: ComposeData(
        scheme: '$_LAUNCH_SCHEME_GMAIL/co',
      ),
    ),
    MailApp(
      name: 'Dispatch',
      iosLaunchScheme: _LAUNCH_SCHEME_DISPATCH,
      composeData: ComposeData(
        scheme: '$_LAUNCH_SCHEME_DISPATCH/compose',
      ),
    ),
    MailApp(
      name: 'Spark',
      iosLaunchScheme: _LAUNCH_SCHEME_SPARK,
      composeData: ComposeData(
        scheme: '${_LAUNCH_SCHEME_SPARK}compose',
        toParameter: 'recipient',
      ),
    ),
    MailApp(
      name: 'Airmail',
      iosLaunchScheme: _LAUNCH_SCHEME_AIRMAIL,
      composeData: ComposeData(
        scheme: '${_LAUNCH_SCHEME_AIRMAIL}compose',
        bodyParameter: 'plainBody',
      ),
    ),
    MailApp(
      name: 'Outlook',
      iosLaunchScheme: _LAUNCH_SCHEME_OUTLOOK,
      composeData: ComposeData(
        scheme: '${_LAUNCH_SCHEME_OUTLOOK}compose',
      ),
    ),
    MailApp(
      name: 'Yahoo Mail',
      iosLaunchScheme: _LAUNCH_SCHEME_YAHOO,
      composeData: ComposeData(
        scheme: '${_LAUNCH_SCHEME_YAHOO}mail/compose',
      ),
    ),
    MailApp(
      name: 'Fastmail',
      iosLaunchScheme: _LAUNCH_SCHEME_FASTMAIL,
      composeData: ComposeData(
        scheme: '${_LAUNCH_SCHEME_FASTMAIL}mail/compose',
      ),
    ),
    MailApp(
      name: 'Superhuman',
      iosLaunchScheme: _LAUNCH_SCHEME_SUPERHUMAN,
      composeData: ComposeData(scheme: _LAUNCH_SCHEME_SUPERHUMAN),
    ),
    MailApp(
      name: 'ProtonMail',
      iosLaunchScheme: _LAUNCH_SCHEME_PROTONMAIL,
      composeData: ComposeData(
        scheme: '${_LAUNCH_SCHEME_PROTONMAIL}mailto:',
      ),
    ),
  ];

  /// Attempts to open an email app installed on the device.
  ///
  /// Android: Will open mail app or show native picker if multiple.
  ///
  /// iOS: Will open mail app if single installed mail app is found. If multiple
  /// are found will return a [OpenMailAppResult] that contains list of
  /// [MailApp]s. This can be used along with [MailAppPickerDialog] to allow
  /// the user to pick the mail app they want to open.
  ///
  /// Also see [openSpecificMailApp] and [getMailApps] for other use cases.
  ///
  /// Android: [nativePickerTitle] will set the title of the native picker.
  static Future<OpenMailAppResult> openMailApp({
    String nativePickerTitle = '',
  }) async {
    if (_isAndroid) {
      final result = await _channel.invokeMethod<bool>(
            'openMailApp',
            <String, dynamic>{'nativePickerTitle': nativePickerTitle},
          ) ??
          false;
      return OpenMailAppResult(didOpen: result);
    } else if (_isIOS) {
      final apps = await _getIosMailApps();
      if (apps.length == 1) {
        // Ensure iosLaunchScheme is not null before parsing
        final launchScheme = apps.first.iosLaunchScheme;
        if (launchScheme != null) {
          final result = await launchUrl(
            Uri.parse(launchScheme),
          );
          return OpenMailAppResult(didOpen: result);
        }
        return OpenMailAppResult(didOpen: false); // Fallback if scheme is null
      } else {
        return OpenMailAppResult(didOpen: false, options: apps);
      }
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }

  /// Allows you to open a mail application installed on the user's device
  /// and start composing a new email with the contents in [emailContent].
  ///
  /// [EmailContent] Provides content for  the email you're composing
  /// [String] (android) sets the title of the native picker.
  /// throws an [Exception] if you're launching from an unsupported platform.
  static Future<OpenMailAppResult> composeNewEmailInMailApp({
    String nativePickerTitle = '',
    required EmailContent emailContent,
  }) async {
    if (_isAndroid) {
      final result = await _channel.invokeMethod<bool>(
            'composeNewEmailInMailApp',
            <String, dynamic>{
              // Changed from <String, String> to <String, dynamic>
              'nativePickerTitle': nativePickerTitle,
              // Ensure toJson() returns a Map, then jsonEncode if native side expects a string
              'emailContent': jsonEncode(emailContent.toJson()),
            },
          ) ??
          false;

      return OpenMailAppResult(didOpen: result);
    } else if (_isIOS) {
      List<MailApp> installedApps = await _getIosMailApps();
      if (installedApps.length == 1) {
        bool result = false;
        String? launchScheme =
            installedApps.first.composeLaunchScheme(emailContent);
        if (launchScheme != null) {
          result = await launchUrl(Uri.parse(launchScheme),
              mode: LaunchMode.externalNonBrowserApplication);
        }
        return OpenMailAppResult(didOpen: result);
      } else {
        // This isn't ideal since you can't do anything with this...
        // Need to adapt the flow with that popup to also allow to pass emailcontent there.
        return OpenMailAppResult(didOpen: false, options: installedApps);
      }
    } else {
      throw UnsupportedError('Platform currently not supported.');
    }
  }

  /// Allows you to compose a new email in the specified [mailApp] witht the
  /// contents from [emailContent]
  ///
  /// [MailApp] (required) the maill app you wish to launch. Get it by calling [getMailApps]
  /// [EmailContent] provides content for the email you're composing
  /// throws an [Exception] if you're launching from an unsupported platform.
  static Future<bool> composeNewEmailInSpecificMailApp({
    required MailApp mailApp,
    required EmailContent emailContent,
  }) async {
    if (_isAndroid) {
      final result = await _channel.invokeMethod<bool>(
            'composeNewEmailInSpecificMailApp',
            <String, dynamic>{
              'name': mailApp.name,
              'emailContent': jsonEncode(emailContent.toJson()),
            },
          ) ??
          false;
      return result;
    } else if (_isIOS) {
      String? launchScheme = mailApp.composeLaunchScheme(emailContent);
      if (launchScheme != null) {
        return await launchUrl(Uri.parse(launchScheme),
            mode: LaunchMode.externalNonBrowserApplication);
      }

      return false;
    } else {
      throw UnsupportedError('Platform currently not supported');
    }
  }

  /// Attempts to open a specific email app installed on the device.
  /// Get a [MailApp] from calling [getMailApps]
  static Future<OpenMailAppResult> openSpecificMailApp(
    // Changed return type to Future<OpenMailAppResult>
    String name,
    EmailContent? emailContent,
  ) async {
    final mailApp = _supportedMailApps
        .firstWhereOrNull((x) => x.name == name); // Use _supportedMailApps
    if (mailApp == null || mailApp.iosLaunchScheme == null) {
      return OpenMailAppResult(didOpen: false);
    }
    String? launchScheme =
        mailApp.iosLaunchScheme; // No need for '!' if already checked
    if (emailContent != null) {
      launchScheme = mailApp.composeLaunchScheme(emailContent);
    }

    if (launchScheme != null && await canLaunchUrl(Uri.parse(launchScheme))) {
      await launchUrl(Uri.parse(launchScheme));
      return OpenMailAppResult(didOpen: true);
    }
    return OpenMailAppResult(didOpen: false);
  }

  /// Returns a list of mail apps that can be used to open email.
  static Future<List<MailApp>> getMailApps() async {
    if (_isAndroid) {
      // Use static getter
      return await _getAndroidMailApps();
    } else if (_isIOS) {
      // Use static getter
      final List<MailApp> apps = [];
      for (final app in _supportedMailApps) {
        // Use _supportedMailApps
        if (app.iosLaunchScheme != null &&
            await canLaunchUrl(Uri.parse(app.iosLaunchScheme!))) {
          // Assert non-null after check
          apps.add(app);
        }
      }
      return apps;
    }
    return [];
  }

  static Future<List<MailApp>> _getAndroidMailApps() async {
    var appsJson = await _channel.invokeMethod<String>('getMainApps');
    var apps = <MailApp>[];

    if (appsJson != null) {
      try {
        final List<dynamic> parsedList = jsonDecode(appsJson);

        apps = parsedList
            .map((item) => MailApp(
                  name: item['name'] ?? '',
                  nativeId: item['nativeId'],
                ))
            .where((app) => !_filterList.contains(app.name.toLowerCase()))
            .toList();
      } catch (e) {
        print('Error parsing mail apps: $e');
      }
    }

    return apps;
  }

  static Future<List<MailApp>> _getIosMailApps() async {
    var installedApps = <MailApp>[];
    for (var app in _supportedMailApps) {
      // Ensure iosLaunchScheme is not null before parsing
      final launchScheme = app.iosLaunchScheme;
      if (launchScheme != null &&
          await canLaunchUrl(Uri.parse(launchScheme)) &&
          !_filterList.contains(app.name.toLowerCase())) {
        installedApps.add(app);
      }
    }
    return installedApps;
  }

  /// Clears existing filter list and sets the filter list to the passed values.
  /// Filter list is case insensitive. Listed apps will be excluded from the results
  /// of `getMailApps` by name.
  ///
  /// Default filter list includes PayPal, since it implements the mailto: intent-filter
  /// on Android, but the intention of this plugin is to provide
  /// a utility for finding and opening apps dedicated to sending/receiving email.
  static void setFilterList(List<String> filterList) {
    _filterList = filterList.map((e) => e.toLowerCase()).toList();
  }
}

/// A simple dialog for allowing the user to pick and open an email app
/// Use with [OpenMail.getMailApps] or [OpenMail.openMailApp] to get a
/// list of mail apps installed on the device.
class MailAppPickerDialog extends StatelessWidget {
  /// The title of the dialog
  final String title;

  /// The mail apps for the dialog to provide as options
  final List<MailApp> mailApps;
  final EmailContent? emailContent;

  const MailAppPickerDialog({
    super.key,
    this.title = 'Choose Mail App',
    required this.mailApps,
    this.emailContent,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(title),
      children: <Widget>[
        for (var app in mailApps)
          SimpleDialogOption(
            child: Text(app.name),
            onPressed: () {
              final content = emailContent;
              if (content != null) {
                OpenMail.composeNewEmailInSpecificMailApp(
                  mailApp: app,
                  emailContent: content,
                );
              } else {
                // Pass app.name and null for emailContent
                OpenMail.openSpecificMailApp(app.name, null);
              }

              Navigator.pop(context);
            },
          ),
      ],
    );
  }
}

class MailApp {
  /// The display name of the mail app.
  final String name;

  /// The underlying unique identifier of the mail app
  /// This is package name on Android and url scheme on iOS
  final String? nativeId;

  /// The iOS URL scheme for opening the app.
  final String? iosLaunchScheme;

  /// Data for composing an email in the app.
  final ComposeData? composeData;

  MailApp(
      {required this.name,
      this.nativeId,
      this.iosLaunchScheme,
      this.composeData});

  factory MailApp.fromJson(Map<String, dynamic> json) {
    return MailApp(
      name: json['name'] as String? ?? '', // Ensure name is not null
      nativeId: json['nativeId'] as String?,
      iosLaunchScheme: json['iosLaunchScheme'] as String?,
      composeData: json['composeData'] != null
          ? ComposeData.fromJson(json['composeData'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'nativeId': nativeId,
        'iosLaunchScheme': iosLaunchScheme,
        'composeData': composeData?.toJson(),
      }..removeWhere((key, value) => value == null);

  String? composeLaunchScheme(EmailContent? content) {
    if (composeData == null || content == null) {
      return null;
    }
    var scheme = composeData!.scheme;
    final qsSeparator = composeData!.queryStringSeparator ?? '?';
    final qsPairSeparator = composeData!.queryStringPairSeparator ?? '&';

    if (content.to?.isNotEmpty == true) {
      scheme +=
          '$qsSeparator${composeData!.toParameter}=${content.to!.join(',')}';
    }
    if (content.cc?.isNotEmpty == true) {
      scheme +=
          '$qsPairSeparator${composeData!.ccParameter}=${content.cc!.join(',')}';
    }
    if (content.bcc?.isNotEmpty == true) {
      scheme +=
          '$qsPairSeparator${composeData!.bccParameter}=${content.bcc!.join(',')}';
    }
    if (content.subject?.isNotEmpty == true) {
      scheme +=
          '$qsPairSeparator${composeData!.subjectParameter}=${Uri.encodeComponent(content.subject!)}';
    }
    if (content.body?.isNotEmpty == true) {
      scheme +=
          '$qsPairSeparator${composeData!.bodyParameter}=${Uri.encodeComponent(content.body!)}';
    }
    return scheme;
  }
}

/// Describes the content of an email to be composed.
///
/// All fields are optional.
class EmailContent {
  /// The recipient(s) of the email.
  final List<String>? to;

  /// The CC recipient(s) of the email.
  final List<String>? cc;

  /// The BCC recipient(s) of the email.
  final List<String>? bcc;

  /// The subject of the email.
  final String? subject;

  /// The body of the email.
  final String? body;

  EmailContent({
    this.to,
    this.subject,
    this.body,
    this.cc,
    this.bcc,
  });

  Map<String, dynamic> toJson() {
    return {
      'to': to,
      'subject': subject,
      'body': body,
      'cc': cc,
      'bcc': bcc,
    }..removeWhere((key, value) => value == null);
  }

  factory EmailContent.fromJson(Map<String, dynamic> json) {
    return EmailContent(
      to: json['to'] != null ? List<String>.from(json['to'] as List) : null,
      subject: json['subject'] as String?,
      body: json['body'] as String?,
      cc: json['cc'] != null ? List<String>.from(json['cc'] as List) : null,
      bcc: json['bcc'] != null ? List<String>.from(json['bcc'] as List) : null,
    );
  }
}

/// Data for composing an email in a specific app.
class ComposeData {
  final String scheme;
  final String? queryStringSeparator;
  final String? queryStringPairSeparator;
  final String toParameter;
  final String ccParameter;
  final String bccParameter;
  final String subjectParameter;
  final String bodyParameter;

  ComposeData({
    required this.scheme,
    this.queryStringSeparator,
    this.queryStringPairSeparator,
    this.toParameter = 'to',
    this.ccParameter = 'cc',
    this.bccParameter = 'bcc',
    this.subjectParameter = 'subject',
    this.bodyParameter = 'body',
  });

  factory ComposeData.fromJson(Map<String, dynamic> json) {
    return ComposeData(
      scheme: json['scheme'] as String,
      queryStringSeparator: json['queryStringSeparator'] as String?,
      queryStringPairSeparator: json['queryStringPairSeparator'] as String?,
      toParameter: json['toParameter'] as String? ?? 'to',
      ccParameter: json['ccParameter'] as String? ?? 'cc',
      bccParameter: json['bccParameter'] as String? ?? 'bcc',
      subjectParameter: json['subjectParameter'] as String? ?? 'subject',
      bodyParameter: json['bodyParameter'] as String? ?? 'body',
    );
  }

  Map<String, dynamic> toJson() => {
        'scheme': scheme,
        'queryStringSeparator': queryStringSeparator,
        'queryStringPairSeparator': queryStringPairSeparator,
        'toParameter': toParameter,
        'ccParameter': ccParameter,
        'bccParameter': bccParameter,
        'subjectParameter': subjectParameter,
        'bodyParameter': bodyParameter,
      }..removeWhere((key, value) => value == null);
}

/// Result of calling [OpenMail.openMailApp]
///
/// [options] and [canOpen] are only populated and used on iOS
class OpenMailAppResult {
  final bool didOpen;
  final List<MailApp> options;

  bool get canOpen => options.isNotEmpty;

  OpenMailAppResult({
    required this.didOpen,
    this.options = const <MailApp>[],
  });
}
