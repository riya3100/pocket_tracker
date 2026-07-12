import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../auth/login_screen.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final themeProvider = Provider.of<ThemeProvider>(context);

    final theme = Theme.of(context);

    String name = user?.email?.split("@")[0] ?? "User";

    name = name[0].toUpperCase() + name.substring(1);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,

        backgroundColor: Colors.green,

        foregroundColor: Colors.white,

        title: const Text("Profile"),

        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 20),

            CircleAvatar(
              radius: 55,

              backgroundColor: Colors.green.withOpacity(0.2),

              child: Icon(Icons.person, size: 60, color: Colors.green.shade600),
            ),

            const SizedBox(height: 18),

            Text(
              name,

              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(user?.email ?? "", style: theme.textTheme.bodyMedium),

            const SizedBox(height: 35),

            profileTile(
              context,
              Icons.email_outlined,
              "Email",
              user?.email ?? "",
            ),

            profileTile(
              context,
              Icons.account_circle_outlined,
              "Account",
              "Personal",
            ),

            profileTile(
              context,
              Icons.verified_user_outlined,
              "Status",
              "Verified",
            ),

            profileTile(
              context,
              Icons.wallet_outlined,
              "App",
              "Pocket Tracker",
            ),

            profileTile(context, Icons.info_outline, "Version", "1.0.0"),

            const SizedBox(height: 15),

            Card(
              elevation: 3,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),

              child: SwitchListTile(
                secondary: CircleAvatar(
                  backgroundColor: Colors.green.withOpacity(0.2),

                  child: const Icon(Icons.dark_mode, color: Colors.green),
                ),

                title: const Text(
                  "Dark Mode",

                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                subtitle: const Text("Enable dark theme"),

                value: themeProvider.isDarkMode,

                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              ),
            ),

            const SizedBox(height: 40),

           SizedBox(
  width: double.infinity,
  height: 65,

  child: OutlinedButton.icon(

    onPressed: () async {

      bool? confirmLogout =
          await showDialog<bool>(

        context: context,

        builder: (context) {

          final theme = Theme.of(context);

          return AlertDialog(

            backgroundColor: theme.cardColor,

            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(20),
            ),

            title: const Row(
              children: [

                CircleAvatar(
                  backgroundColor:
                      Colors.redAccent,

                  child: Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                ),

                SizedBox(width:12),

                Text(
                  "Logout",
                ),
              ],
            ),


            content: const Text(
              "Are you sure you want to logout?",
            ),


            actions: [

              TextButton(

                onPressed: () {
                  Navigator.pop(
                    context,
                    false,
                  );
                },

                child:
                    const Text("Cancel"),

              ),


              ElevatedButton(

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      Colors.redAccent,

                  foregroundColor:
                      Colors.white,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),


                onPressed: () {

                  Navigator.pop(
                    context,
                    true,
                  );

                },


                child:
                    const Text(
                  "Logout",
                ),
              ),
            ],
          );
        },
      );


      if(confirmLogout == true){

        await logout(context);

      }

    },


    icon: Container(

      padding:
          const EdgeInsets.all(8),

      decoration:
          BoxDecoration(

        color:
            Colors.red.withOpacity(0.15),

        shape:
            BoxShape.circle,

      ),


      child:
          const Icon(
        Icons.logout,

        color:
            Colors.red,

      ),
    ),



    label:
        const Text(

      "Logout",

      style:
          TextStyle(

        fontSize:18,

        fontWeight:
            FontWeight.bold,

        color:
            Colors.red,

      ),

    ),



    style:
        OutlinedButton.styleFrom(

      side:
          const BorderSide(

        color:
            Colors.red,

        width:
            1.5,

      ),


      shape:
          RoundedRectangleBorder(

        borderRadius:
            BorderRadius.circular(18),

      ),

    ),

  ),
),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget profileTile(
    BuildContext context,

    IconData icon,

    String title,

    String subtitle,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.2),

          child: Icon(icon, color: Colors.green),
        ),

        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

        subtitle: Text(subtitle, style: theme.textTheme.bodyMedium),

        trailing: Icon(
          Icons.arrow_forward_ios,

          size: 16,

          color: theme.iconTheme.color,
        ),
      ),
    );
  }
}
