// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

// class PdfViewerScreen extends StatelessWidget {
//   final String pdfUrl;
//   final String title;

//   const PdfViewerScreen({
//     Key? key,
//     required this.pdfUrl,
//     required this.title,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//         centerTitle: true,
//       ),
//       body: SfPdfViewer.network(
//         pdfUrl,
//         enableTextSelection: true,
//         enableDocumentLinkAnnotation: true,
//         enableHyperlinkNavigation: true,
//         pageLayoutMode: PdfPageLayoutMode.single,
//       ),
//     );
//   }
// }
