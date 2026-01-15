import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/models.dart';
import 'package:http/http.dart' as http;

class EmailService {
  // For development/demo purposes, we'll simulate email sending
  // In production, this should be replaced with a real email service API

  static const String _emailServiceUrl = 'https://api.resend.com/emails';
  static const String _apiKey = 're_Zaknvy3J_8jVetd7E6kkdsKy4i7WcSJWV';

  /// Send application approval email to user
  static Future<bool> sendApplicationApprovedEmail(
    ManagerApplication application,
  ) async {
    try {
      final emailBody = '''
Dear ${application.userFullName ?? 'Valued User'},

Congratulations! 🎉

Your manager application for ${application.companyName} has been APPROVED!

Application Details:
- Application ID: ${application.id}
- Approved Date: ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}
- Review Notes: ${application.reviewNotes ?? 'Your application meets all our requirements.'}

You can now access the YOUBOOK Manager Dashboard and start managing your transportation services.

Next Steps:
1. Log in to your YOUBOOK account
2. Access the Manager Dashboard
3. Set up your service offerings
4. Start accepting bookings

If you have any questions, please contact our support team:
- Email: youbook210@gmail.com
- Phone: +92 317 129 2355

Welcome to the YOUBOOK Manager community!

Best regards,
YOUBOOK Support Team
youbook210@gmail.com
''';

      final resendData = {
        'from': 'YOUBOOK Support <support@youbook.com>',
        'to': [application.userEmail],
        'subject': 'YOUBOOK Manager Application Approved! 🎉',
        'html': emailBody.replaceAll('\n', '<br>'),
        'text': emailBody,
      };

      print('📧 SENDING APPROVAL EMAIL:');
      print('To: ${application.userEmail}');
      print('Subject: ${resendData['subject']}');

      final response = await http.post(
        Uri.parse(_emailServiceUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(resendData),
      );

      if (response.statusCode == 200) {
        print('✅ Application approval email sent successfully');
        return true;
      } else {
        print('❌ Failed to send approval email: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending approval email: $e');
      return false;
    }
  }

  /// Send application rejection email to user
  static Future<bool> sendApplicationRejectedEmail(
    ManagerApplication application,
  ) async {
    try {
      final emailBody = '''
Dear ${application.userFullName ?? 'Valued User'},

We regret to inform you that your manager application for ${application.companyName} has been reviewed and unfortunately, it does not meet our current requirements at this time.

Application Details:
- Application ID: ${application.id}
- Review Date: ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}
- Review Notes: ${application.reviewNotes ?? 'Please review our requirements and submit a new application.'}

Reapplication Process:
You can reapply after addressing the feedback provided above. We recommend carefully reviewing our manager requirements and ensuring all documentation is complete and accurate.

If you believe this decision was made in error or need clarification on the requirements, please contact our support team:
- Email: youbook210@gmail.com
- Phone: +92 317 129 2355

We appreciate your interest in becoming a YOUBOOK Manager and encourage you to reapply once you've addressed the concerns raised.

Best regards,
YOUBOOK Support Team
youbook210@gmail.com
''';

      final resendData = {
        'from': 'YOUBOOK Support <support@youbook.com>',
        'to': [application.userEmail],
        'subject': 'YOUBOOK Manager Application Update',
        'html': emailBody.replaceAll('\n', '<br>'),
        'text': emailBody,
      };

      print('📧 SENDING REJECTION EMAIL:');
      print('To: ${application.userEmail}');
      print('Subject: ${resendData['subject']}');

      final response = await http.post(
        Uri.parse(_emailServiceUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(resendData),
      );

      if (response.statusCode == 200) {
        print('✅ Application rejection email sent successfully');
        return true;
      } else {
        print('❌ Failed to send rejection email: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending rejection email: $e');
      return false;
    }
  }

  /// Send validation issues email to user
  static Future<bool> sendValidationIssuesEmail(
    ManagerApplication application, {
    String? specificIssues,
  }) async {
    try {
      final emailBody = '''
Dear ${application.userFullName ?? 'Valued User'},

We have reviewed your manager application for ${application.companyName} and found some validation issues that need to be addressed.

Application Details:
- Application ID: ${application.id}
- Review Date: ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}

Validation Issues Found:
${specificIssues ?? application.reviewNotes ?? 'Please check your application details and ensure all required information is provided accurately.'}

Correction Instructions:
Please correct the issues mentioned above and resubmit your application. Make sure all documentation is complete and meets our requirements.

If you need assistance or clarification, please contact our support team:
- Email: youbook210@gmail.com
- Phone: +92 317 129 2355

We're here to help you complete your application successfully!

Best regards,
YOUBOOK Support Team
youbook210@gmail.com
''';

      final resendData = {
        'from': 'YOUBOOK Support <support@youbook.com>',
        'to': [application.userEmail],
        'subject': 'YOUBOOK Manager Application - Validation Issues Found',
        'html': emailBody.replaceAll('\n', '<br>'),
        'text': emailBody,
      };

      print('📧 SENDING VALIDATION ISSUES EMAIL:');
      print('To: ${application.userEmail}');
      print('Subject: ${resendData['subject']}');

      final response = await http.post(
        Uri.parse(_emailServiceUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(resendData),
      );

      if (response.statusCode == 200) {
        print('✅ Validation issues email sent successfully');
        return true;
      } else {
        print('❌ Failed to send validation issues email: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending validation issues email: $e');
      return false;
    }
  }
}
