import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'dart:io';
import 'dart:io' show Platform;

class PdfViewerPage extends StatelessWidget {
  final String path;
  final File fileUri;
  const PdfViewerPage({Key key, this.path,this.fileUri}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        deleteFile(fileUri);
        return true;
      },
      child: PDFViewerScaffold(
         appBar:     AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.blueAccent),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            path: path,
          ),


    );
  }


  Future<int> deleteFile(File filePath) async {
    try {
      final file = await filePath;

      await file.delete();
    } catch (e) {
      return 0;
    }
  }
}