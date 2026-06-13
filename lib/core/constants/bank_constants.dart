class BankInfo {
  final String code;
  final String name;
  final String accountNumber;
  final String accountHolder;
  final String logo; // emoji fallback

  const BankInfo({
    required this.code,
    required this.name,
    required this.accountNumber,
    required this.accountHolder,
    required this.logo,
  });
}

class BankConstants {
  BankConstants._();

  static const List<BankInfo> banks = [
    BankInfo(
      code: 'bca',
      name: 'Bank BCA',
      accountNumber: '1234567890',
      accountHolder: 'PT CornMarket Indonesia',
      logo: '🏦',
    ),
    BankInfo(
      code: 'mandiri',
      name: 'Bank Mandiri',
      accountNumber: '0987654321',
      accountHolder: 'PT CornMarket Indonesia',
      logo: '🏦',
    ),
    BankInfo(
      code: 'bri',
      name: 'Bank BRI',
      accountNumber: '1122334455',
      accountHolder: 'PT CornMarket Indonesia',
      logo: '🏦',
    ),
    BankInfo(
      code: 'bni',
      name: 'Bank BNI',
      accountNumber: '5544332211',
      accountHolder: 'PT CornMarket Indonesia',
      logo: '🏦',
    ),
  ];

  static BankInfo? findByCode(String code) =>
      banks.where((b) => b.code == code).firstOrNull;
}
