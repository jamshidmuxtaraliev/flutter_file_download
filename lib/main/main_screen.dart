import 'package:flutter/material.dart';
import 'package:flutter_file_download/generated/app_colors.dart';
import 'package:flutter_file_download/main/download_item_view.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<String> resours = [
    //pdf
    "https://assets.website-files.com/603d0d2db8ec32ba7d44fffe/603d0e327eb2748c8ab1053f_loremipsum.pdf",
    //mp3
    "https://server11.mp3quran.net/sds/112.mp3",
    //mp4 video
    "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
    //image
    "https://www.fluttercampus.com/img/banner.png"
  ];

  List<String> fileTypes = [
    "Document File",
    "Music file",
    "Video file",
    "Image file "
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.LIGHT_GREY_AS,
      appBar: AppBar(
        backgroundColor: AppColors.COLOR_PRIMARY_DARK_AS,
        title: Text("Flutter File Download", style: TextStyle(color: Colors.white),),),
    body: ListView.builder(
      padding: EdgeInsets.all( 20),
      itemCount: resours.length,
        itemBuilder: (context, index){
        return DownloadItemView(downloadUrl: resours[index], fileType: fileTypes[index],);
        }),
    );
  }
}
