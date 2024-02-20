// ignore_for_file: deprecated_member_use, unnecessary_null_comparison, unused_import

import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dartssh2/dartssh2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'connections/ssh.dart';
import 'settings_page.dart';
import 'connections/connection_flag.dart';
import 'package:http/http.dart';
import 'entities/orbit_entity.dart';
import 'entities/look_at_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SSH ssh;

  bool connectionStatus = false;

  @override
  void initState() {
    super.initState();
    ssh = SSH();
  }

  Future<void> _connectToLG() async {
    bool? result = await ssh.connectToLG();
    setState(() {
      connectionStatus = result!;
    });
  }

  Future<void> _showRebootConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 3,
            sigmaY: 3,
          ),
          child: AlertDialog(
            contentPadding: EdgeInsets.all(16),
            title: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: 40,
                ),
                SizedBox(width: 10),
                Text('Warning !',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                      fontFamily: GoogleFonts.nunito().fontFamily,
                    )),
              ],
            ),
            content: Container(
              width: 600,
              height: 50,
              child: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                      'Are you sure you want to Reboot the system?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: GoogleFonts.nunito().fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await ssh.rebootLG();
                },
                child: const Text(
                  'Reboot',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool isOrbiting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 189, 35),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            color: Colors.grey.withOpacity(0.5),
            height: 1.0,
          ),
        ),
        title: Text(
          'Liquid Galaxy Mini Controller',
          style: TextStyle(
            color: Colors.black,
            fontSize: 26.0,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.montserrat().fontFamily,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                await ssh.cleanKML();
                await ssh.setRefresh();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
              ),
              label: Row(
                children: [
                  Text(
                    'Clean KML',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w800,
                      fontFamily: GoogleFonts.montserrat().fontFamily,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              icon: const Icon(Icons.cleaning_services,
                  color: Colors.white, size: 30.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
                _connectToLG();
              },
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 30.0,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsets.only(top: 5, left: 10),
                  child: ConnectionFlag(
                    status: connectionStatus,
                  )),
              Image.asset(
                'assets/liquidgalaxy.png',
                alignment: Alignment.center,
                width: 300,
                height: 300,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _build3DButton(
                    onPressed: () async {
                      await _showRebootConfirmationDialog();
                    },
                    label: 'Reboot',
                  ),
                  _build3DButton(
                    onPressed: () async {
                      await ssh.searchplace('Rourkela');
                    },
                    label: 'Launch Home City',
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _build3DButton(
                    onPressed: () async {
                      if (isOrbiting) {
                        await ssh.stopOrbit();
                      } else {
                        await ssh.orbitAtRourkela();
                      }
                      setState(() {
                        isOrbiting = !isOrbiting;
                      });
                    },
                    label: isOrbiting ? 'Stop Orbit' : 'Start Orbit',
                    isStopMode: isOrbiting,
                  ),
                  _build3DButton(
                    onPressed: () async {
                      await ssh.RightRigLogo();
                    },
                    label: 'Launch Logo',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DButton({
    required VoidCallback onPressed,
    required String label,
    bool isStopMode = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary:
            isStopMode ? Colors.redAccent : Color.fromARGB(255, 12, 110, 190),
        fixedSize: Size(400, 150),
        elevation: 5,
        shadowColor: Colors.blueGrey,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 30,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: GoogleFonts.montserrat().fontFamily,
        ),
      ),
    );
  }
}
