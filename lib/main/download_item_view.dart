import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter_svg/svg.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../../generated/assets.dart';
import '../generated/app_colors.dart';

class DownloadItemView extends StatefulWidget {
  // bool isHavingDownLoad;
  String downloadUrl;
  String fileType;

  DownloadItemView({Key? key, required this.fileType, required this.downloadUrl /*required this.isHavingDownLoad*/}) : super(key: key);

  @override
  _DownloadItemViewState createState() => _DownloadItemViewState();
}

class _DownloadItemViewState extends State<DownloadItemView> {
  bool isHAveDownloading = false;

  bool downloading = false;
  var progressString = "0%";
  String downloadStart = "Yuklab olinmoqda...";
  var isDownloadContainerVisible = false;
  String filePath = '';
  var error = '';
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        requestPermission();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.fileType,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontFamily: "bold",
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top:8, bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: AppColors.GREY_AS,
                borderRadius: BorderRadius.all(Radius.circular(12))),
            child: Row(
              children: [
                InkWell(
                    onTap: () {
                      requestPermission();
                    },
                    child: Stack(
                      children: <Widget>[
                        if (!downloading)
                          SvgPicture.asset(
                            (isHAveDownloading)
                                ? Assets.svgDocumentDownloaded
                                : Assets.svgFileDownloadOutline,
                            color: AppColors.COLOR_BG,
                            width: 50,
                            height: 50,
                          ),
                        downloading
                            ? Container(
                            width: 50,
                            height: 50,
                            padding: const EdgeInsets.all(8),
                            child: CircularProgressIndicator(
                              color: AppColors.COLOR_BG,
                            ))
                            : Container(),
                        // ShowOrHideDownloadDialog(),
                      ],
                    )),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "File Name dynamic",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: "regular",
                          ),
                        ),
                        Row(
                          children: [
                            if (downloading)
                              Expanded(
                                child: RichText(
                                  text: TextSpan(children: <TextSpan>[
                                    TextSpan(
                                      text: downloadStart,
                                      style: TextStyle(color: AppColors.MIDDLE_GREY_AS),
                                    ),
                                    TextSpan(
                                      text: "$progressString   ",
                                      style: TextStyle(color: AppColors.MIDDLE_GREY_AS),
                                    ),
                                  ]),
                                ),
                              ),

                            const Text(
                              "File size",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: "regular",
                              ),
                            ),
                          ],
                        )
                      ],
                    )),
                IconButton(onPressed: () {}, icon: Icon(Icons.share))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> requestPermission() async {
    try {
      final status = await Permission.storage.request();
      PermissionStatus _permissionStatus = status;
      if (_permissionStatus.isGranted) {
        openFile(widget.downloadUrl);
      } else if (_permissionStatus.isDenied) {
        print( "Faylni ochish uchun tizim ruxsati olinmagan");
      } else if (_permissionStatus.isPermanentlyDenied) {
        print( "Faylni ochish uchun tizim ruxsati olinmagan");
        AppSettings.openAppSettings();
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = "Faylni ochish uchun tizimdan ruxsat olib bo'lmadi";
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = "Ruxsat rad etildi - foydalanuvchidan uni ilova sozlamalaridan yoqishini so'rang";
      }
      if (Platform.isIOS) print( "Faylni ochish uchun tizimdan ruxsat olib bo'lmadi");
    } catch (_) {
      if (Platform.isIOS) print( "Faylni ochish uchun tizimdan ruxsat olib bo'lmadi");
      return;
    }
  }

  void openFile(String url) async {
    var dir;
    if (Platform.isAndroid) {
      dir = (await getExternalStorageDirectory())?.path;
    } else {
      dir = (await getApplicationDocumentsDirectory()).path;
    }
    filePath = "$dir/${url.substring(url.lastIndexOf('/') + 1)}";
    print("fayl yo'li $filePath");

    File file = File(filePath);
    var isExist = await file.exists();
    if (isExist) {
      print('Fayl mavjud----------');
      await OpenFile.open(filePath);
      setState(() {
        isDownloadContainerVisible = false;
      });
    } else {
      print('Fayl mavjud emas ----------');
      downloadFile(url);
    }
  }

  Future<void> downloadFile(String url) async {
    Dio dio = Dio();

    setState(() {
      progressString = "0%";
      downloadStart = "Yuklanmoqda...";
      downloading = true;
      isDownloadContainerVisible = true;
    });
    try {
      await dio.download(url, filePath, onReceiveProgress: (
          rec,
          total,
          ) {
        print("Rec: $rec , Total: $total");
        setState(() {
          progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
        });
      });
    } catch (e) {
      print(e);
    }

    setState(() {
      downloading = false;
      progressString = "";
      downloadStart = "";
      isHAveDownloading = true;
    });

    print("Yuklash yakunlandi");
  }
}
