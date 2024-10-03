import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:expense_management/widget/custom_header_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/profile_model.dart';
import '../../utils/language_notifier.dart';
import '../../view_model/user/edit_profile_view_model.dart';
import '../../widget/custom_ElevatedButton_1.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<EditProfileViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              CustomHeader_2(title: tr('profile')),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: viewModel.imageFile != null
                              ? FileImage(File(viewModel.imageFile!.path))
                              : (viewModel.networkImageUrl != null
                              ? NetworkImage(viewModel.networkImageUrl!)
                              : const AssetImage('assets/images/profile.png'))
                          as ImageProvider,
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          viewModel.displayName,
                          style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Text(
                              tr('edit_profile'),
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                            ),
                          ),
                          onTap: () async {
                            final updatedProfile = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                            if (updatedProfile != null && updatedProfile is Profile) {
                              await viewModel.loadProfile();
                            }
                          },
                        ),
                        const SizedBox(height: 50.0),
                        // Settings Section
                        Text(
                          tr('settings'),
                          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        ListTile(
                          onTap: () {
                            // Navigate to Change Password screen
                            Navigator.pushNamed(context, '/change-password');
                          },
                          leading: const Icon(Icons.lock),
                          title: Text(tr('change_password')),
                        ),
                        ListTile(
                          title: Text(tr('change_language')),
                          leading: const Icon(Icons.language),
                          onTap: () {
                            // Show Language Selection Dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(tr('select_language')),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      // Show Confirmation Dialog for Vietnamese
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(tr('confirm_language_change')),
                                          content: RichText(
                                            text: TextSpan(
                                              text: '${tr('confirm_language_change_to')} ',
                                              style: const TextStyle(color: Colors.black, fontSize: 16),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: tr('vietnamese'),
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                                ),
                                                const TextSpan(
                                                  text: '?',
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context); 
                                              },
                                              child: Text(
                                                tr('no'),
                                                style: const TextStyle(color: Colors.red),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                context.setLocale(const Locale('vi'));
                                                languageNotifier.changeLanguage(const Locale('vi'));
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                tr('yes'),
                                                style: const TextStyle(color: Colors.blue),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        SizedBox(
                                            width: 26,
                                            height: 26,
                                            child: Image.asset('assets/images/vietnamese_flag.png')
                                        ),
                                        SizedBox(width: 10),
                                        Text(tr('vietnamese'), style: const TextStyle(color: Colors.red, fontSize: 18)),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(tr('confirm_language_change')),
                                          content: RichText(
                                            text: TextSpan(
                                              text: '${tr('confirm_language_change_to')} ',
                                              style: const TextStyle(color: Colors.black, fontSize: 16),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: tr('english'),
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                                ),
                                                const TextSpan(
                                                  text: '?',
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                tr('no'),
                                                style: const TextStyle(color: Colors.red, fontSize: 18),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                context.setLocale(const Locale('en'));
                                                languageNotifier.changeLanguage(const Locale('en'));
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                tr('yes'),
                                                style: const TextStyle(color: Colors.blue, fontSize: 18),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        SizedBox(
                                            width: 26,
                                            height: 26,
                                            child: Image.asset('assets/images/english_flag.png')
                                        ),
                                        SizedBox(width: 10),
                                        Text(tr('english'), style: const TextStyle(color: Colors.blue, fontSize: 18)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20.0),
                        // Logout Button
                        CustomElavatedButton_1(
                          text: tr('logout'),
                            onPressed: () {
                              _showSignOutConfirmationDialog(context, viewModel);
                            },
                          ),
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
  void _showSignOutConfirmationDialog(BuildContext context, EditProfileViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tr('confirm_logout')),
          content: Text(tr('are_you_sure_you_want_to_logout')),
          actions: <Widget>[
            TextButton(
              child: Text(tr('cancel'), style: const TextStyle(color: Colors.red),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(tr('logout'), style: const TextStyle(color: Colors.blue),),
              onPressed: () {
                Navigator.of(context).pop();
                viewModel.signOut(context);
              },
            ),
          ],
        );
      },
    );
  }

}
