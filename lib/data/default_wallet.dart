import '../model/wallet_model.dart';

List<Wallet> defaultWallets = [
  Wallet(
    walletId: 'default_wallet_1',
    userId: 'default',
    initialBalance: 0,
    currentBalance: 0,
    name: 'Ví tiền mặt',
    icon: 'IconData(U+0F53A)',
    color: 'Color(0xFFFFEB3B)',
    excludeFromTotal: false,
    createdAt: DateTime.now(),
  ),
  Wallet(
    walletId: 'default_wallet_2',
    userId: 'default',
    initialBalance: 0,
    currentBalance: 0,
    name: 'Ví ngân hàng',
    icon: 'IconData(U+0F19C)',
    color: 'Color(0xFF4CAF50)',
    excludeFromTotal: false,
    createdAt: DateTime.now(),
  ),
  Wallet(
    walletId: 'default_wallet_3',
    userId: 'default',
    initialBalance: 0,
    currentBalance: 0,
    name: 'Ví tiết kiệm',
    icon: 'IconData(U+0F4D3)',
    color: 'Color(0xFF2196F3)',
    excludeFromTotal: false,
    createdAt: DateTime.now(),
  ),
];

List<Wallet> fixedWallets = [
  Wallet(
    walletId: 'fixed_wallet',
    userId: 'default',
    initialBalance: 0,
    currentBalance: 0,
    name: 'Ví chính',
    icon: 'IconData(U+0F555)',
    color: 'Color(0xFFF44336)',
    excludeFromTotal: false,
    createdAt: DateTime.now(),
    isDefault: true,
  ),
];
