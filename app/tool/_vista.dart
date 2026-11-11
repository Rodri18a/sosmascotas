import 'dart:io';
import 'package:image/image.dart';
void main() {
  final fs = Directory('assets/ilustraciones').listSync().whereType<File>().toList()..sort((a,b)=>a.path.compareTo(b.path));
  final hoja = Image(width: 1500, height: 1050, numChannels: 4);
  fill(hoja, color: ColorRgba8(0x1F, 0x4F, 0xD1, 255));
  var x = 10, y = 10;
  for (final f in fs) {
    final i = decodePng(f.readAsBytesSync())!;
    final r = copyResize(i, width: i.width >= i.height ? 340 : null, height: i.height > i.width ? 340 : null);
    if (x + 360 > 1500) { x = 10; y += 350; }
    compositeImage(hoja, r, dstX: x, dstY: y);
    drawString(hoja, f.path.split(Platform.pathSeparator).last, font: arial14, x: x, y: y + 330);
    x += 370;
  }
  File('${Platform.environment['VISTA']}').writeAsBytesSync(encodePng(hoja));
}
