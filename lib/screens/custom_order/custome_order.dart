import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';
import '../../custom/device_info.dart';
import '../../custom/my_widget.dart';
import '../../custom/toast_component.dart';
import '../../data_model/custom_order_data.dart';
import '../../data_model/uploaded_file_list_response.dart';
import '../../helpers/file_helper.dart';
import '../../helpers/shimmer_helper.dart';
import '../../my_theme.dart';
import '../../repositories/upload_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_sound/flutter_sound.dart';

class CustomOrder extends StatefulWidget {
  const CustomOrder(
      {Key? key,
      this.fileType = "",
      this.canSelect = false,
      this.canMultiSelect = false,
      this.prevData})
      : super(key: key);
  final String fileType;
  final bool canSelect;
  final bool canMultiSelect;
  final List<FileInfo>? prevData;

  @override
  State<CustomOrder> createState() => _CustomOrderState();
}

class _CustomOrderState extends State<CustomOrder>
    with TickerProviderStateMixin {
  ScrollController mainScrollController = ScrollController();
  TextEditingController searchEditingController = TextEditingController();
  String searchTxt = "";
  late TabController tabController;
  List<CustomData> _images = [];
  List<CustomData> loadedAudio = [];
  int currentPage = 1;
  int? lastPage = 1;
  String? audioPath;
  bool isAudioFile = false;
  bool dataAvailable = false;
  String dataType = "";
  int? selectedTab;
  final ImagePicker _picker = ImagePicker();

  Future<String> convertFileToBase64(File file) async {
    List<int> bytes = await file.readAsBytes();
    String base64File = base64Encode(bytes);
    return base64File;
  }

  getCustomStoreDatas() async {
    var customDataResponse =
        await FileUploadRepository().getCustomOrderDatas(page: currentPage);
    if (customDataResponse.customData!.isNotEmpty) {
      dataAvailable = true;
      List<CustomData> imageList =
      customDataResponse.customData!.where((n) => n.type == "image").toList();
      List<CustomData> audioList =
      customDataResponse.customData!.where((n) => n.type != "audio").toList();
      _images.addAll(imageList);
      loadedAudio.addAll(audioList);
      setState(() {

      });
      // customDataResponse.customData!.forEach(
      //   (customData) {
      //     print("custom order type=======>${customData.type}");
      //     if (customData.type == "image") {
      //       _images.add(customData.file!);
      //       setState(() {});
      //     } else if (customData.type == "audio") {
      //       // Add audio image asset
      //       print(customData.file);
      //       loadedAudio.add(customData.file!);
      //       setState(() {});
      //     }
      //     // _images.add(customData.file!);
      //   },
      // );
    } else {
      dataAvailable = false;
      setState(() {});
    }
  }

  Future<void> pickAndUploadImage(ImageSource source) async {
    var status = await Permission.camera.request();

    XFile? file = await _picker.pickImage(source: source);

    if (file == null) {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.no_file_is_chosen,
        gravity: Toast.center,
        duration: Toast.lengthLong,
      );
      return;
    }

    String base64Image = FileHelper.getBase64FormateFile(file.path);
    String fileName = file.path.split("/").last;

    var customOrderUpdateResponse =
        await FileUploadRepository().getCustomOrderResponse(
      base64Image,
      fileName,
    );

    if (customOrderUpdateResponse.result == false) {
      ToastComponent.showDialog(
        customOrderUpdateResponse.message,
        gravity: Toast.center,
        duration: Toast.lengthLong,
      );
    } else {
      ToastComponent.showDialog(
        customOrderUpdateResponse.message,
        gravity: Toast.center,
        duration: Toast.lengthLong,
      );
      // refresh();
      // _images.add(customOrderUpdateResponse.path!);
      setState(() {});
    }
  }

  Future<void> chooseAndUploadFile(BuildContext context) async {
    // Show dialog to choose between camera and gallery
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose Source"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text("Camera"),
                  onTap: () async {
                    Navigator.pop(context);
                    await pickAndUploadImage(ImageSource.camera);
                  },
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: Text("Gallery"),
                  onTap: () async {
                    Navigator.pop(context);
                    await pickAndUploadImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  final recorder = FlutterSoundRecorder();

  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Permission not granted';
    }
    await recorder.openRecorder();
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  Future startRecord() async {
    await recorder.startRecorder(
      toFile: "audio.aac", // Recording in WAV format
      codec: Codec.aacADTS, // Using PCM codec for WAV format
    );
  }

  Future stopRecorder() async {
    final filePath = await recorder.stopRecorder();
    final file = File(filePath!);
    // String base64File = await convertFileToBase64(file);
    print("file. path======>${file.path}");
    String base64File = FileHelper.getBase64FormateFile(file.path);
    print("file. path======>$base64File");
    String fileName = file.path.split("/").last;
    var customOrderUpdateResponse =
        await FileUploadRepository().getCustomOrderResponse(
      base64File,
      fileName,
    );
    if (customOrderUpdateResponse.result == false) {
      ToastComponent.showDialog(
        customOrderUpdateResponse.message,
        gravity: Toast.center,
        duration: Toast.lengthLong,
      );
      return;
    } else {
      ToastComponent.showDialog(
        customOrderUpdateResponse.message,
        gravity: Toast.center,
        duration: Toast.lengthLong,
      );
      // refresh();
      // loadedAudio.add(customOrderUpdateResponse.path!);
      // _images.add(customOrderUpdateResponse.path!);
      setState(() {});
    }

    print('Recorded file path: $filePath');
  }

  Future<bool> fetchData() async {
    // getImageList();
    getCustomStoreDatas();
    setState(() {});
    return true;
  }

  Future<bool> clearData() async {
    _images = [];
    loadedAudio = [];
    setState(() {});
    return true;
  }

  sorted() {
    refresh();
  }

  search() {
    searchTxt = searchEditingController.text.trim();
    refresh();
  }

  Future<bool> resetData() async {
    // await clearData();
    await fetchData();
    return true;
  }

  Future<void> refresh() async {
    await resetData();
    return Future.delayed(Duration(seconds: 1));
  }

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    selectedTab = 0;
    print("Scrolling Called");
    mainScrollController.addListener(() {
      if (mainScrollController.position.pixels ==
          mainScrollController.position.maxScrollExtent) {
        if (currentPage >= lastPage!) {
          currentPage++;
          // getImageList();
          getCustomStoreDatas();
        }
      }
    });
    // sortBy = sortList.first;
    fetchData();
    // scrollControllerPosition();
    initRecorder();
    // getCustomStoreDatas();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: MyTheme.white,
            iconTheme: IconThemeData(color: MyTheme.dark_grey),
            title: Text(
              "Upload file",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: MyTheme.dark_font_grey),
            ),
            // bottom: PreferredSize(child: buildUploadFileContainer(context),preferredSize: Size(DeviceInfo(context).getWidth(),75)),
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10),
                  width: MediaQuery.of(context).size.width,
                  child: TabBar(
                    controller: tabController,
                    labelColor: MyTheme.white,
                    unselectedLabelColor: MyTheme.accent_color,
                    indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        // Creates border
                        color: MyTheme.accent_color),
                    onTap: (index) {
                      setState(
                        () {
                          selectedTab = index;
                        },
                      );
                    },
                    tabs: [
                      Tab(
                        // icon: Icon(Icons.chat_bubble),
                        text: "Image",
                      ),
                      Tab(
                        // icon: Icon(Icons.video_call),
                        text: "Audio",
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: tabController,
                    children: [
                      Stack(
                        children: [
                          buildImageListView(),
                          buildFilterSection(context),
                        ],
                      ),
                      Stack(
                        children: [
                          buildAudioListView(),
                          buildAudioFileContainer(context),
                        ],
                      ),
                      // buildBodyCustomer(context, screenWidth),
                      // buildBodyCustomer(context, screenWidth),
                    ],
                  ),
                ),
              ],
            ),
          )
          // body: RefreshIndicator(
          //   onRefresh: refresh,
          //   child: Stack(
          //     children: [
          //       dataAvailable == false
          //           ? Center(
          //               child: Text("No data available"),
          //             )
          //           : buildImageListView(),
          //       // : buildShimmerList(context),
          //       Container(
          //         child: buildFilterSection(context),
          //       )
          //     ],
          //   ),
          // ),
          ),
    );
  }

  Widget buildShimmerList(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(
            5,
            (index) => Container(
                margin: EdgeInsets.only(bottom: 20),
                child: ShimmerHelper().buildBasicShimmer(
                    height: 96, width: DeviceInfo(context).width!))),
      ),
    );
  }

  Widget buildImageListView() {
    return Padding(
      padding: const EdgeInsets.only(top: 145.0),
      child: GridView.builder(
          controller: mainScrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          physics: BouncingScrollPhysics(),
          // shrinkWrap: true,
          padding: EdgeInsets.all(12),
          itemCount: _images.length,
          itemBuilder: (context, index) {
            return buildImageItem(index);
          }),
    );
  }

  Widget buildAudioListView() {
    return Padding(
      padding: const EdgeInsets.only(top: 145.0),
      child: GridView.builder(
          controller: mainScrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          physics: BouncingScrollPhysics(),
          // shrinkWrap: true,
          padding: EdgeInsets.all(12),
          itemCount: loadedAudio.length,
          itemBuilder: (context, index) {
            return buildAudioItem(index);
          }),
    );
  }

  Widget buildAudioItem(int index) {
    // String imageUrl = _audioImages[index];
    // String audioImage = _audioImages[index];// Assuming path contains the image URL
    final Random random = Random();
    final int r = random.nextInt(256);
    final int g = random.nextInt(256);
    final int b = random.nextInt(256);
    final Color randomBorderColor = Color.fromRGBO(r, g, b, 1);
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: randomBorderColor),
            image: DecorationImage(
              image: AssetImage(
                "assets/audio_images.jpg",
              ),
              fit: BoxFit.cover,
            ),
          ),
        )

        // Align(
        //   alignment: Alignment.topRight,
        //   child: Container(
        //     height: 30,
        //     width: 30,
        //     decoration: BoxDecoration(
        //         borderRadius: BorderRadius.all(
        //           Radius.circular(20),
        //         ),
        //         color: Colors.red.shade50),
        //     child: IconButton(onPressed: (){}, icon: Icon(Icons.clear,color: MyTheme.brick_red,size: 15,),),
        //   ),
        // ),
      ],
    );
  }

  Widget buildImageItem(int index) {
    String imageUrl = _images[index].file!;
    // String audioImage = _audioImages[index];// Assuming path contains the image URL
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                imageUrl,
              ),
              fit: BoxFit.cover,
            ),
          ),
        )

        // Align(
        //   alignment: Alignment.topRight,
        //   child: Container(
        //     height: 30,
        //     width: 30,
        //     decoration: BoxDecoration(
        //         borderRadius: BorderRadius.all(
        //           Radius.circular(20),
        //         ),
        //         color: Colors.red.shade50),
        //     child: IconButton(onPressed: (){}, icon: Icon(Icons.clear,color: MyTheme.brick_red,size: 15,),),
        //   ),
        // ),
      ],
    );
  }

  Widget buildAudioFileContainer(BuildContext context) {
    return MyWidget().myContainer(
        marginY: 10.0,
        marginX: 5,
        height: 75,
        width: DeviceInfo(context).width!,
        borderRadius: 10,
        bgColor: MyTheme.white,
        borderColor: MyTheme.accent_color,
        child: InkWell(
          onTap: () async {
            if (recorder.isRecording) {
              await stopRecorder();
              setState(() {});
            } else {
              await startRecord();
              setState(() {});
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Sent Voice",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: MyTheme.dark_font_grey),
                ),
                Icon(
                  recorder.isRecording ? Icons.stop : Icons.mic,
                  size: 18,
                  color: MyTheme.dark_font_grey,
                )
              ],
            ),
          ),
        ));
  }

  Widget buildUploadFileContainer(BuildContext context) {
    return MyWidget().myContainer(
      marginY: 10.0,
      marginX: 5,
      height: 75,
      width: DeviceInfo(context).width!,
      borderRadius: 10,
      bgColor: MyTheme.white,
      borderColor: MyTheme.accent_color,
      child: InkWell(
        onTap: () {
          isAudioFile = false;
          chooseAndUploadFile(context);
          setState(() {});
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "Upload file",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: MyTheme.dark_font_grey),
            ),
            Icon(
              Icons.upload_file,
              size: 18,
              color: MyTheme.dark_font_grey,
            )
          ],
        ),
      ),
    );
  }

  buildFilterSection(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        buildUploadFileContainer(context),
      ],
    );
  }

  Widget buildCheckContainer() {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 400),
      opacity: 1,
      child: Container(
        height: 16,
        width: 16,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0), color: Colors.green),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Icon(Icons.check, color: Colors.white, size: 10),
        ),
      ),
    );
    /* Visibility(
      visible: check,
      child: Container(
        height: 16,
        width: 16,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0), color: Colors.green),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Icon(FontAwesome.check, color: Colors.white, size: 10),
        ),
      ),
    );*/
  }
}

enum MenuOptions { Delete }
