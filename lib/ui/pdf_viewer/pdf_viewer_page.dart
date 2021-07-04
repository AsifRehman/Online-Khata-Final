import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'dart:io';

class PdfViewerPage extends StatelessWidget {
  final String path;
  final File fileUri;
  const PdfViewerPage({Key key, this.path,this.fileUri}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          deleteFile(fileUri);
          return true;
        },
        child: Scaffold(
          body: Container(
            // height: MediaQuery.of(context).size.height-100,
            child: Column(
              children: [
                // Container(
                //   margin: EdgeInsets.fromLTRB(5.0, 0, 0.0, 0.0),
                //   child: new IconButton(
                //     icon: Image.asset(
                //       'assets/ic_back.png',
                //       width: 40,
                //       height: 40,
                //       color: Colors.blueAccent,
                //     ),
                //     onPressed: () => Navigator.of(context).pop(),
                //   ),
                // ),
                PDFViewerScaffold(
                  path: path,
                ),
              ],
            ),
          ),
        ),
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