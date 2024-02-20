class BalloonMakers {
  static String balloon() {
    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
    <Document id ="logo">
         <name>Task2</name>
             <Folder>
                  <name>Splash Screen</name>
                  <ScreenOverlay>
                      <name>Logo</name>
                      <Icon><href>https://raw.githubusercontent.com/Baizkunthaz/LG_image/main/BaikunthaLG.png</href> </Icon>
                      <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
                      <screenXY x="0.36" y="0.97" xunits="fraction" yunits="fraction"/>
                      <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
                      <size x="500" y="500" xunits="pixels" yunits="pixels"/>
                  </ScreenOverlay>
             </Folder>
    </Document>
</kml>''';
  }



  static blankBalloon() => '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
</Document>
</kml>''';
}
