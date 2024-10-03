import 'package:expense_management/widget/custom_header_1.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../data/color_list.dart';
import '../../data/icon_list.dart';
import '../../view_model/wallet/create_wallet_view_model.dart';
import '../../widget/custom_ElevatedButton_2.dart';
import '../../widget/custom_snackbar_2.dart';
import 'package:easy_localization/easy_localization.dart';

class CreateWalletScreen extends StatefulWidget {
  const CreateWalletScreen({super.key});

  @override
  State<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CreateWalletViewModel>(context, listen: false).resetFields();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CreateWalletViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              CustomHeader_1(
                title: tr('create_wallet_title'),
                action: IconButton(
                  icon: const Icon(Icons.check, color: Colors.white),
                  onPressed: viewModel.enableButton
                      ? () async {
                          final newWallet = await viewModel.createWallet();
                          if (newWallet != null) {
                            await CustomSnackBar_2.show(
                                context, tr('creation_success'));
                            Navigator.pop(context, newWallet);
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
                                decoration:  InputDecoration(
                                  labelText: tr('wallet_name_label'),
                                ),
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
                                    color: viewModel.selectedColor ??
                                        Colors.blueGrey.shade200,
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
                                    color: viewModel.selectedColor ??
                                        Colors.blueGrey.shade200,
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
                                controller: viewModel.initialBalanceController,
                                decoration:
                                     InputDecoration(labelText: tr('initial_balance_label')),
                                style: const TextStyle(
                                    fontSize: 28,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500),
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
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              tr('icon_label'),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black.withOpacity(0.7),
                              ),
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
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 1,
                            ),
                            itemCount: walletIcons.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  viewModel.setSelectedIcon(walletIcons[index]);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: viewModel.selectedIcon ==
                                            walletIcons[index]
                                        ? Border.all(
                                            color: Colors.black, width: 1.0)
                                        : null,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: viewModel.selectedIcon ==
                                                walletIcons[index]
                                            ? (viewModel.selectedColor ??
                                                Colors.blueGrey.shade200)
                                            : Colors.blueGrey.shade200,
                                      ),
                                      child: Icon(
                                        walletIcons[index],
                                        size: 38,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            Text(
                              tr('color_label'),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black.withOpacity(0.7),
                              ),
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
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisSpacing: 15,
                              crossAxisSpacing: 15,
                            ),
                            itemCount: colors_list.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  viewModel
                                      .setSelectedColor(colors_list[index]);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: colors_list[index],
                                    shape: BoxShape.circle,
                                  ),
                                  child: viewModel.selectedColor ==
                                          colors_list[index]
                                      ? const Icon(Icons.check,
                                          color: Colors.white, size: 26)
                                      : null,
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 10),
                        SwitchListTile(
                          title:  Text(tr('exclude_from_total_label')),
                          value: viewModel.excludeFromTotal,
                          onChanged: (bool value) {
                            viewModel.setExcludeFromTotal(value);
                          },
                        ),
                        const SizedBox(height: 20),
                        CustomElevatedButton_2(
                          text: tr('create_label'),
                          onPressed: viewModel.enableButton
                              ? () async {
                                  final newWallet =
                                      await viewModel.createWallet();
                                  if (newWallet != null) {
                                    await CustomSnackBar_2.show(
                                        context, tr('creation_success'));
                                    Navigator.pop(context, newWallet);
                                  }
                                }
                              : null,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
