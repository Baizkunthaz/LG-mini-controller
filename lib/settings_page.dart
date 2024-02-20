import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'connections/ssh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'connections/connection_flag.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool connectionStatus = false;
  late SSH ssh;

  Future<void> _connectToLG() async {
    bool? result = await ssh.connectToLG();
    setState(() {
      connectionStatus = result!;
    });
  }

  @override
  void initState() {
    super.initState();

    ssh = SSH();
    _connectToLG();
    _loadSettings();
    _saveSettings();
  }

  void refresh() async {
    bool? connect = await ssh.connectToLG();

    if (connect == true) {
      setState(() {
        connectionStatus = true;
      });
    }
  }

  final TextEditingController ipAddressController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController sshPortController = TextEditingController();
  final TextEditingController numberOfVMsController = TextEditingController();

  @override
  void dispose() {
    final TextEditingController _ipController =
        TextEditingController(); // Define the _ipController variable
    _ipController.dispose();
    final TextEditingController _usernameController =
        TextEditingController(); // Define the _usernameController variable
    _usernameController.dispose();
    final TextEditingController _passwordController =
        TextEditingController(); // Define the _passwordController variable
    _passwordController.dispose();
    final TextEditingController _sshPortController =
        TextEditingController(); // Define the _sshPortController variable
    _sshPortController.dispose();
    final TextEditingController _rigsController =
        TextEditingController(); // Define the _rigsController variable
    _rigsController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await Future.delayed(Duration(milliseconds: 700));
    setState(() {
      ipAddressController.text = prefs.getString('ipAddress') ?? '';
      usernameController.text = prefs.getString('username') ?? '';
      passwordController.text = prefs.getString('password') ?? '';
      sshPortController.text = prefs.getString('sshPort') ?? '';
      numberOfVMsController.text = prefs.getString('numberOfVMs') ?? '';
    });
  }

  Future<void> _saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (ipAddressController.text.isNotEmpty) {
      await prefs.setString('ipAddress', ipAddressController.text);
    }
    if (usernameController.text.isNotEmpty) {
      await prefs.setString('username', usernameController.text);
    }
    if (passwordController.text.isNotEmpty) {
      await prefs.setString('password', passwordController.text);
    }
    if (sshPortController.text.isNotEmpty) {
      await prefs.setString('sshPort', sshPortController.text);
    }
    if (numberOfVMsController.text.isNotEmpty) {
      await prefs.setString('numberOfVMs', numberOfVMsController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Container(
              width: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ConnectionFlag(
                        status: connectionStatus,
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  _buildTextField(
                    controller: ipAddressController,
                    labelText: 'Enter Your IP Address',
                    icon: Icons.add_location_sharp,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _buildTextField(
                    controller: usernameController,
                    labelText: 'Enter your Username',
                    icon: Icons.person,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _buildTextField(
                    controller: passwordController,
                    labelText: 'Enter your Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _buildTextField(
                    controller: sshPortController,
                    labelText: 'SSH Port',
                    icon: Icons.settings_input_hdmi,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _buildTextField(
                    controller: numberOfVMsController,
                    labelText: 'No. of VMs',
                    icon: Icons.device_hub,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () async {
                      await _saveSettings();
                      SSH ssh = SSH();
                      bool? result = await ssh.connectToLG();
                      if (result == true) {
                        setState(() {
                          connectionStatus = true;
                        });
                        print('Connected to LG successfully');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      backgroundColor: Color.fromARGB(255, 0, 128, 233),
                      elevation: 7,
                      shadowColor: Colors.grey.shade500,
                    ),
                    child: Text(
                      'Connect',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: GoogleFonts.montserrat().fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.nunito().fontFamily),
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(23),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }
}
