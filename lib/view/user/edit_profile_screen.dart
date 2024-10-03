import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:expense_management/widget/custom_ElevatedButton_2.dart';
import 'package:expense_management/widget/custom_header_1.dart';
import 'package:expense_management/widget/custom_snackbar_1.dart';
import 'package:expense_management/widget/custom_snackbar_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../model/enum.dart';
import '../../view_model/user/edit_profile_view_model.dart';
import '../transaction/component/image_detail_screen.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<EditProfileViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              Column(
                children: [
                  CustomHeader_1(title: tr('edit_profile_title')),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (viewModel.networkImageUrl != null ||
                                    viewModel.imageFile != null) {
                                  _viewProfilePicture(
                                      context,
                                      viewModel.networkImageUrl,
                                      viewModel.imageFile);
                                } else {
                                  CustomSnackBar_1.show(
                                      context, tr('no_new_avatar'));
                                }
                              },
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: viewModel.imageFile != null
                                    ? FileImage(File(viewModel.imageFile!.path))
                                    : (viewModel.networkImageUrl != null
                                            ? NetworkImage(
                                                viewModel.networkImageUrl!)
                                            : const AssetImage(
                                                'assets/images/profile.png'))
                                        as ImageProvider,
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  _showAvatarOptionsDialog(context, viewModel),
                              child: Text(tr('select_avatar')),
                            ),
                            TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(30),
                              ],
                              controller: viewModel.nameController,
                              decoration: InputDecoration(
                                  labelText: tr('display_name_label')),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: viewModel.birthDateController,
                              decoration: InputDecoration(
                                labelText: tr('birthdate_label'),
                                suffixIcon: const Icon(Icons.calendar_today),
                              ),
                              readOnly: true,
                              onTap: () => viewModel.selectDate(context),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Radio<Gender>(
                                      value: Gender.male,
                                      groupValue: viewModel.gender,
                                      onChanged: (Gender? value) {
                                        if (value != null) {
                                          viewModel.setGender(value);
                                        }
                                      },
                                    ),
                                    Text(tr('male')),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Radio<Gender>(
                                      value: Gender.female,
                                      groupValue: viewModel.gender,
                                      onChanged: (Gender? value) {
                                        if (value != null) {
                                          viewModel.setGender(value);
                                        }
                                      },
                                    ),
                                    Text(tr('female')),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Radio<Gender>(
                                      value: Gender.other,
                                      groupValue: viewModel.gender,
                                      onChanged: (Gender? value) {
                                        if (value != null) {
                                          viewModel.setGender(value);
                                        }
                                      },
                                    ),
                                    Text(tr('other')),
                                  ],
                                ),
                              ],
                            ),
                            TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              controller: viewModel.addressController,
                              decoration: InputDecoration(
                                  labelText: tr('address_label')),
                              maxLines: null,
                            ),
                            const SizedBox(height: 20),
                            CustomElevatedButton_2(
                              onPressed: () async {
                                final updateProfile =
                                    await viewModel.saveProfile();
                                if (updateProfile != null) {
                                  await CustomSnackBar_2.show(
                                      context, tr('save_success'));
                                  Navigator.pop(context, updateProfile);
                                }
                              },
                              text: tr('save_button'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (viewModel.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5), // nền mờ
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        strokeWidth: 6.0, // độ dày
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

  void _showAvatarOptionsDialog(
      BuildContext context, EditProfileViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tr('change_avatar')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(tr('choose_from_library')),
                onTap: () async {
                  Navigator.pop(context);
                  await viewModel.pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(tr('take_photo')),
                onTap: () async {
                  Navigator.pop(context);
                  await viewModel.pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _viewProfilePicture(
      BuildContext context, String? networkImageUrl, File? imageFile) {
    if (networkImageUrl == null && imageFile == null) {
      CustomSnackBar_1.show(context, tr('no_new_avatar'));
      return;
    }

    if (imageFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageDetailScreen(
            imageUrls: null,
            imageFiles: [imageFile],
            initialIndex: 0,
          ),
        ),
      );
    } else if (networkImageUrl != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageDetailScreen(
            imageUrls: [networkImageUrl],
            imageFiles: null,
            initialIndex: 0,
          ),
        ),
      );
    }
  }
}
