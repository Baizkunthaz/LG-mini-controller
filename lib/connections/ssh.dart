import 'dart:async';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_app/entities/look_at_entity.dart';
import 'package:task_app/kml_makers/balloon_makers.dart';
import 'package:task_app/entities/orbit_entity.dart';
import 'package:path_provider/path_provider.dart';

class SSH {
  late String _host;
  late String _port;
  late String _username;
  late String _passwordOrKey;
  late String _numberOfVMs;
  SSHClient? _client;

  // Initialize connection details from shared preferences
  Future<void> initConnectionDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('ipAddress') ?? '_host';
    _port = prefs.getString('sshPort') ?? '_port';
    _username = prefs.getString('username') ?? '_username';
    _passwordOrKey = prefs.getString('password') ?? '_passwordOrKey';
    _numberOfVMs = prefs.getString('numberOfVMs') ?? '_numberOfVMs';
  }

  // Connect to the Liquid Galaxy system
  Future<bool?> connectToLG() async {
    await initConnectionDetails();

    try {
      final socket = await SSHSocket.connect(_host, int.parse(_port));

      _client = SSHClient(
        socket,
        username: _username,
        onPasswordRequest: () => _passwordOrKey,
      );
      print(
          'IP : $_host, port : $_port, username : $_username, noOfVMs: $_numberOfVMs ');
      return true;
    } on SocketException catch (e) {
      print('Failed to connect: $e');
      return false;
    }
  }

  Future<SSHSession?> searchplace(String place) async {
    try {
      if (_client == null) {
        if (kDebugMode) {
          print('SSH client is not initialized.');
        }
        return null;
      }

      final execResult =
          await _client!.execute('echo "search=$place" >/tmp/query.txt');
      return execResult;
    } catch (e) {
      if (kDebugMode) {
        print('An error occurred while executing the command: $e');
      }
      return null;
    }
  }

  Future<void> rebootLG() async {
    try {
      await connectToLG();

      for (var i = int.parse(_numberOfVMs); i >= 0; i--) {
        await _client?.run(
            'sshpass -p $_passwordOrKey ssh -t lg$i "echo $_passwordOrKey | sudo -S reboot"');
      }
    } catch (error) {
      print(error);
    }
  }

  String orbitLookAtLinear(double latitude, double longitude, double zoom,
      double tilt, double bearing) {
    return '<gx:duration>1.2</gx:duration><gx:flyToMode>smooth</gx:flyToMode><LookAt><longitude>$longitude</longitude><latitude>$latitude</latitude><range>$zoom</range><tilt>$tilt</tilt><heading>$bearing</heading><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>';
  }

  Future<void> orbitAtRourkela() async {
    try {
      if (_client == null) {
        print('SSH client is not initialized.');
        return;
      }

      await cleanKML();

      String orbitKML = OrbitEntity.buildOrbit(OrbitEntity.tag(LookAtEntity(
          lng: 84.8536,
          lat: 22.2604,
          range: '1000',
          tilt: '45',
          heading: '0')));

      File inputFile = await makeFile("OrbitKML", orbitKML);
      await kmlFileUpload(inputFile, "OrbitKML", "Orbit");
    } catch (e) {
      print("An error occurred while executing the command: $e");
    }
  }

  makeFile(String filename, String content) async {
    var localPath = await getApplicationDocumentsDirectory();
    File localFile = File('${localPath.path}/$filename.kml');
    await localFile.writeAsString(content);
    return localFile;
  }

  kmlFileUpload(File inputFile, String kmlName, String content) async {
    try {
      // ignore: unused_local_variable
      bool uploading = true;
      final sftp = await _client!.sftp();
      final file = await sftp.open('/var/www/html/$kmlName.kml',
          mode: SftpFileOpenMode.create |
              SftpFileOpenMode.truncate |
              SftpFileOpenMode.write);
      var fileSize = await inputFile.length();
      file.write(inputFile.openRead().cast(), onProgress: (progress) async {
        if (fileSize == progress) {
          uploading = false;
          if (content == "Orbit") {
            await runKML("OrbitKML", content);
          } else if (content == "Balloon") {
            await runKML("BalloonKML", content);
          }
        }
      });
    } catch (e) {
      print("An error occurred while executing the command: $e");
    }
  }

  runKML(String kmlName, String context) async {
    try {
      await _client!.execute(
          "echo 'http://lg1:81/$kmlName.kml' > /var/www/html/kmls.txt");

      if (context == "Orbit") {
        await beginOrbiting();
      } else if (context == "Balloon") {
        await renderInSlave();
      }
    } catch (e) {
      print("An error occurred while executing the command: $e");
      await runKML(context, kmlName);
    }
  }

  beginOrbiting() async {
    try {
      await _client!.run('echo "playtour=Orbit" > /tmp/query.txt');
    } catch (e) {
      print("An error occurred while executing the command: $e");
      await beginOrbiting();
    }
  }

  Future<SSHSession?> RightRigLogo() async {
    try {
      if (_client == null) {
        if (kDebugMode) {
          print('SSH client is not initialized.');
        }
        return null;
      }
      int totalScreen = int.parse(_numberOfVMs);
      int rightMostScreen = (totalScreen / 2).floor() + 1;

      final execResult = await _client!.execute(
          "echo '${BalloonMakers.balloon()}' > /var/www/html/kml/slave_$rightMostScreen.kml");
      return execResult;
    } catch (e) {
      if (kDebugMode) {
        print('An error occurred while executing the command: $e');
      }
      return null;
    }
  }

  renderInSlave() async {
    try {
      String kmlContent = await BalloonMakers.balloon();

      await _client!.run("echo '$kmlContent' > /var/www/html/kml/slave_2.kml");

      await cleanKML();
    } catch (e) {
      print("An error occurred while executing the command: $e");
      await renderInSlave();
    }
  }

  setRefresh() async {
    try {
      for (var i = 2; i <= int.parse(_numberOfVMs); i++) {
        String search = '<href>##LG_PHPIFACE##kml\\/slave_$i.kml<\\/href>';
        String replace =
            '<href>##LG_PHPIFACE##kml\\/slave_$i.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';

        await _client!.execute(
            'sshpass -p $_passwordOrKey ssh -t lg$i \'echo $_passwordOrKey | sudo -S sed -i "s/$replace/$search/" ~/earth/kml/slave/myplaces.kml\'');
        await _client!.execute(
            'sshpass -p $_passwordOrKey ssh -t lg$i \'echo $_passwordOrKey | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml\'');
      }
    } catch (e) {
      print("An error occurred while executing the command: $e");
    }
  }

  Future<void> balloonAtHome() async {
    try {
      if (_client == null) {
        print('SSH client is not initialized.');
        return;
      }

      String balloonKML = BalloonMakers.balloon();

      File inputFile = await makeFile("BalloonKML", balloonKML);
      await kmlFileUpload(inputFile, "Balloon", "BalloonKML");
    } catch (e) {
      print("An error occurred while executing the command: $e");
    }
  }

  cleanBalloon() async {
    try {
      await _client!.run(
          "echo '${BalloonMakers.blankBalloon()}' > /var/www/html/kml/slave_2.kml");
      await _client!.run(
          "echo '${BalloonMakers.blankBalloon()}' > /var/www/html/kml/slave_3.kml");
    } catch (e) {
      print("An error occurred while executing the command: $e");
      await cleanBalloon();
    }
  }

  cleanKML() async {
    try {
      await cleanBalloon();
      await stopOrbit();
      await _client!.run("echo '' > /tmp/query.txt");
      await _client!.run("echo '' > /var/www/html/kmls.txt");
    } catch (e) {
      print('An error occurred while executing the command: $e');
      await cleanKML();
    }
  }

  cleanSlaves() async {
    try {
      await _client!.run("echo '' > /var/www/html/kml/slave_2.kml");
    } catch (e) {
      print("An error occurred while executing the command: $e");
      await cleanSlaves();
    }
  }

  startOrbit() async {
    try {
      await _client!.run('echo "playtour=Orbit" > /tmp/query.txt');
    } catch (e) {
      print("An error occurred while executing the command: $e");
      stopOrbit();
    }
  }

  stopOrbit() async {
    try {
      await _client!.run('echo "exittour=true" > /tmp/query.txt');
    } catch (e) {
      print("An error occurred while executing the command: $e");
      stopOrbit();
    }
  }
}
