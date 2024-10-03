import 'package:expense_management/widget/custom_header_1.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../data/icon_list.dart';
import '../../model/wallet_model.dart';
import '../../data/color_list.dart';
import '../../view_model/wallet/edit_wallet_view_model.dart';
import '../../widget/custom_ElevatedButton_2.dart';
import '../../widget/custom_snackbar_2.dart';
import 'package:easy_localization/easy_localization.dart';

class EditWalletScreen extends StatefulWidget {
  final Wallet wallet;

  const EditWalletScreen({super.key, required this.wallet});

  @override
  State<EditWalletScreen> createState() => _EditWalletScreenState();
}

class _EditWalletScreenState extends State<EditWalletScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditWalletViewModel>(
      create: (context) => EditWalletViewModel()..initialize(widget.wallet),
      child: Consumer<EditWalletViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Column(
              children: [
                CustomHeader_1(
                  title: tr('edit_wallet_title'),
                  action: IconButton(
                    icon: const Icon(Icons.save, color: Colors.white),
                    onPressed: viewModel.enableButton
                        ? () async {
                      final updatedWallet = await viewModel.updateWallet(
                          widget.wallet.walletId, widget.wallet.createdAt, widget.wallet);
                      if (updatedWallet != null) {
                        await CustomSnackBar_2.show(
                            context, tr('update_successful'));
                        Navigator.pop(context, updatedWallet);
                      }
                    }
                        : null,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 70),
                                child: TextFormField(
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(50),
                                  ],
                                  controller: viewModel.walletNameController,
                                  decoration: InputDecoration(labelText: tr('wallet_name_label')),
                                  maxLines: null,
                                  onChanged: (_) => viewModel.updateButtonState(),
                                ),
                              ),
                              if (viewModel.selectedIcon != null)
                                Positioned(
                                  left: 2.0,
                                  top: 5.0,
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: viewModel.selectedColor ?? Colors.blueGrey.shade200,
                                    ),
                                    child: Icon(
                                      viewModel.selectedIcon,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              if (viewModel.selectedIcon == null)
                                Positioned(
                                  left: 2.0,
                                  top: 5.0,
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: viewModel.selectedColor ?? Colors.blueGrey.shade200,
                                    ),
                                    child: const Icon(
                                      FontAwesomeIcons.question,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(15),
                                  ],
                                  controller: viewModel.currentBalanceController,
                                  readOnly: true,
                                  decoration: InputDecoration(labelText: tr('current_balance_label')),
                                  style: const TextStyle(fontSize: 28, color: Colors.green, fontWeight: FontWeight.w500),
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.right,
                                  onChanged: (_) => viewModel.updateButtonState(),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 20.0),
                                child: Text(
                                  '₫',
                                  style: TextStyle(fontSize: 28),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Text(
                                tr('icon_label'),
                                style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.7)),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  viewModel.toggleShowPlusButtonIcon();
                                },
                                child: Icon(
                                  viewModel.showPlusButtonIcon
                                      ? Icons.arrow_drop_down
                                      : Icons.arrow_drop_up,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          if (viewModel.showPlusButtonIcon)
                            GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 1,
                              ),
                              itemCount: walletIcons.length,
                              itemBuilder: (BuildContext context, int index) {
                                final icon = walletIcons[index];
                                final isSelected = viewModel.selectedIcon?.codePoint == icon.codePoint;

                                return GestureDetector(
                                  onTap: () {
                                    viewModel.setSelectedIcon(icon);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: isSelected ? Border.all(color: Colors.black, width: 1.0) : null,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? (viewModel.selectedColor ?? Colors.blueGrey.shade200)
                                              : Colors.blueGrey.shade200,
                                        ),
                                        child: Icon(
                                          icon,
                                          size: 38,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Text(
                                tr('color_label'),
                                style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.7)),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  viewModel.toggleShowPlusButtonColor();
                                },
                                child: Icon(
                                  viewModel.showPlusButtonColor
                                      ? Icons.arrow_drop_down
                                      : Icons.arrow_drop_up,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          if (viewModel.showPlusButtonColor)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                mainAxisSpacing: 15,
                                crossAxisSpacing: 15,
                              ),
                              itemCount: colors_list.length,
                              itemBuilder: (BuildContext context, int index) {
                                final color = colors_list[index];
                                final isSelected = viewModel.selectedColor?.value == color.value;

                                return GestureDetector(
                                  onTap: () {
                                    viewModel.setSelectedColor(color);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                    child: isSelected
                                        ? const Icon(Icons.check, color: Colors.white, size: 24)
                                        : null,
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 10),
                          SwitchListTile(
                            title: Text(tr('exclude_from_total_label')),
                            value: viewModel.excludeFromTotal,
                            onChanged: (bool value) {
                              viewModel.setExcludeFromTotal(value);
                            },
                          ),
                          const SizedBox(height: 20),
                          CustomElevatedButton_2(
                            text: tr('save_button'),
                            onPressed: viewModel.enableButton
                                ? () async {
                              final updatedWallet = await viewModel.updateWallet(
                                  widget.wallet.walletId, widget.wallet.createdAt, widget.wallet);
                              if (updatedWallet != null) {
                                await CustomSnackBar_2.show(context, tr('update_successful'));
                                Navigator.pop(context, updatedWallet);
                              }
                            }
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
