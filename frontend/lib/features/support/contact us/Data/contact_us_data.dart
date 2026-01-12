class ContactUsData {
  final String phoneNumber = "03171292355";
  final String email = "youbook210@gmail.com";

  final List<Map<String, String>> contacts = [
    {
      'title': 'Call Us',
      'description': 'Call our support team directly.',
      'detail': 'Phone : 03171292355',
      'buttonText': 'Call Now',
      'assetIcon': 'assets/support/contact_us_icon.png',
      'type': 'phone',
    },
    {
      'title': 'WhatsApp',
      'description': 'Chat with our support team on WhatsApp.',
      'detail': 'WhatsApp : 03171292355',
      'buttonText': 'Chat Now',
      'assetIcon': 'assets/support/whatsapp_icon.png',
      'type': 'whatsapp',
    },
    {
      'title': 'Email',
      'description': 'Email our support team they will reach you soon.',
      'detail': 'Email : youbook210@gmail.com',
      'buttonText': 'Email Now',
      'assetIcon': 'assets/support/email_icon.png',
      'type': 'email',
    },
  ];
}
