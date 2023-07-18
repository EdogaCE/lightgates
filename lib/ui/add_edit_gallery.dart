import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_pal/blocs/gallery/gallery.dart';
import 'package:school_pal/models/gallery.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/posts/add_event_gallery_requests.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/utils/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:school_pal/utils/system.dart';
import 'general.dart';

class AddEditGallery extends StatelessWidget {
  final Gallery gallery;
  final bool editing;
  AddEditGallery({this.gallery, this.editing});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GalleryBloc(addEventGalleryRepository: AddEventGalleryRequests()),
      child: AddEditGalleryPage(gallery, editing),
    );
  }
}

// ignore: must_be_immutable
class AddEditGalleryPage extends StatelessWidget {
  final Gallery gallery;
  final bool editing;
  AddEditGalleryPage(this.gallery, this.editing);

  GalleryBloc _galleryBloc;
  String sessionDropdownValue = '---session---';
  List<String> sessionSpinnerItems = ["---session---"];
  List<String> sessionSpinnerIds = ['0'];
  final titleController = TextEditingController();
  final youtubeLinkController = TextEditingController();
  final descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<Asset> selectedImages = List<Asset>();
  List<String> youtubeLinkList = List();
  List<String> imageList = List();
  
  final formatDate = DateFormat("yyyy-MM-dd");
  DateTime selectedDate = DateTime.now();
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(selectedDate.year - 500),
        lastDate: DateTime(selectedDate.year + 500));
    if (picked != null && picked != selectedDate)
      _galleryBloc.add(ChangeDateEvent(picked));
  }

  void _viewSessions() async {
    _galleryBloc.add(GetSessionsEvent(await getApiToken()));
  }

  void _loadMultipleImages() async {
    _galleryBloc.add(LoadImagesFromEvent(await loadAssets(selectedImages)));
  }

  void _populateForm(){
    if(editing){
      titleController.text=gallery.title;
      descriptionController.text=gallery.description;
      selectedDate=convertDateFromString(gallery.date);
      if(gallery.videos.isNotEmpty){
        youtubeLinkList.addAll(gallery.videos.split(','));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    _galleryBloc = BlocProvider.of<GalleryBloc>(context);
    _populateForm();
    _viewSessions();
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.image),
                onPressed: () {
                  _loadMultipleImages();
                }),
          ],
          elevation: 0.0,
          backgroundColor: Colors.white,
          //Todo: to change back button color
          iconTheme: IconThemeData(color: MyColors.primaryColor),
          title: Text("Gallery", style: TextStyle(color: MyColors.primaryColor)),
        ),
        body: CustomPaint(
          painter: BackgroundPainter(),
          child: Form(
            key: _formKey,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            BlocListener<GalleryBloc, GalleryStates>(
                              listener: (BuildContext context,
                                  GalleryStates state) {
                                if (state is ImagesLoaded) {
                                  if (state.images.isNotEmpty)
                                    selectedImages = state.images;
                                  //convertAssetToBase64();
                                }else   if (state is Processing) {
                                  Scaffold.of(context).showSnackBar(
                                    SnackBar(
                                      duration: Duration(minutes: 30),
                                      content: General.progressIndicator("Processing..."),
                                    ),
                                  );
                                } else if (state is NetworkErr) {
                                  Scaffold.of(context)
                                    ..removeCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(
                                        content:
                                        Text(state.message, textAlign: TextAlign.center),
                                      ),
                                    );
                                } else if (state is ViewError) {
                                  Scaffold.of(context)
                                    ..removeCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(
                                        content:
                                        Text(state.message, textAlign: TextAlign.center),
                                      ),
                                    );
                                } else if (state is GalleryAdded) {
                                  Navigator.pop(context, state.message);
                                }  else if (state is GalleryUpdated) {
                                  Navigator.pop(context, state.message);
                                }else if (state is GalleryImageAdded) {
                                  imageList.add(state.imageName);
                                }
                              },
                              child: BlocBuilder<GalleryBloc, GalleryStates>(
                                builder: (BuildContext context,
                                    GalleryStates state) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8.0),
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(25.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(25.0),
                                          border: Border.all(
                                              color: MyColors.primaryColor,
                                              style: BorderStyle.solid,
                                              width: 0.80),
                                        ),
                                        height: 100.0,
                                        child: GestureDetector(
                                          onTap: () {
                                            _loadMultipleImages();
                                          },
                                          child: Stack(
                                            children: <Widget>[
                                              selectedImages.isEmpty
                                                  ? Center(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize
                                                                  .min,
                                                          children: <Widget>[
                                                            Icon(
                                                                Icons
                                                                    .add_photo_alternate,
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.3)),
                                                            Text("Images",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.3))),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  : Container(),
                                              GridView.count(
                                                crossAxisCount: 3,
                                                children: List.generate(
                                                    selectedImages.length,
                                                    (index) {
                                                  Asset asset =
                                                      selectedImages[index];
                                                  return AssetThumb(
                                                    asset: asset,
                                                    width: 300,
                                                    height: 300,
                                                  );
                                                }),
                                              ),
                                              (selectedImages.length > 3)
                                                  ? Align(
                                                      alignment: Alignment
                                                          .bottomRight,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      25.0),
                                                          child: Container(
                                                            color: Colors
                                                                .white
                                                                .withOpacity(
                                                                    0.5),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .all(
                                                                      8.0),
                                                              child: Text(
                                                                  '+${selectedImages.length - 3}',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .deepPurple)),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : Container()
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: <Widget>[
                                  BlocListener<GalleryBloc, GalleryStates>(
                                    listener: (BuildContext context,
                                        GalleryStates state) {
                                      if (state is LinkAddedToList) {
                                        if (state.link.isNotEmpty)
                                          youtubeLinkList.add(state.link);
                                      } else if (state
                                          is LinkRemovedFromList) {
                                        youtubeLinkList.remove(state.link);
                                      }
                                    },
                                    child: BlocBuilder<GalleryBloc,
                                        GalleryStates>(
                                      builder: (BuildContext context,
                                          GalleryStates state) {
                                        return Wrap(
                                          children:
                                              _buildLinkList(youtubeLinkList),
                                        );
                                      },
                                    ),
                                  ),
                                  TextFormField(
                                    controller: youtubeLinkController,
                                    keyboardType: TextInputType.url,
                                    validator: (value) {
                                     /* if (value.isEmpty) {
                                        return 'Please enter video link.';
                                      }*/
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              const BorderRadius.all(
                                            const Radius.circular(25.0),
                                          ),
                                        ),
                                        //icon: Icon(Icons.email),
                                        prefixIcon: Icon(Icons.video_library,
                                            color: Colors.red),
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            _galleryBloc.add(
                                                AddLinkToListEvent(
                                                    youtubeLinkController
                                                        .text));
                                            youtubeLinkController.clear();
                                          },
                                          icon: Icon(
                                            Icons.add_circle,
                                            color: MyColors.primaryColor,
                                          ),
                                        ),
                                        labelText: 'Youtube Link',
                                        labelStyle: new TextStyle(
                                            color: Colors.grey[800]),
                                        filled: true,
                                        fillColor: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: titleController,
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter event title.';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(25.0),
                                      ),
                                    ),
                                    //icon: Icon(Icons.email),
                                    prefixIcon:
                                        Icon(Icons.title, color: Colors.blue),
                                    labelText: 'Title',
                                    labelStyle: new TextStyle(
                                        color: Colors.grey[800]),
                                    filled: true,
                                    fillColor: Colors.white70),
                              ),
                            ),
                            BlocListener<GalleryBloc, GalleryStates>(
                              listener: (BuildContext context,
                                  GalleryStates state) {
                                if (state is SessionSelected) {
                                  sessionDropdownValue = state.session;
                                } else if (state is SessionsLoaded) {
                                  sessionSpinnerItems.addAll(state.sessions[0]);
                                  sessionSpinnerIds.addAll(state.sessions[1]);

                                  _galleryBloc.add(SelectSessionEvent(state.sessions[2][1]));
                                  if(editing){
                                    _galleryBloc.add(SelectSessionEvent(gallery.sessions.sessionDate));
                                  }

                                }
                              },
                              child: BlocBuilder<GalleryBloc, GalleryStates>(
                                builder: (BuildContext context,
                                    GalleryStates state) {
                                  return Stack(
                                    children: <Widget>[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 30.0),
                                            child: Text("Select session",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: MyColors.primaryColor,
                                                    fontWeight:
                                                        FontWeight.normal)),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0,
                                                right: 8.0,
                                                bottom: 8.0,
                                                top: 1.0),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10.0),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.5),
                                                borderRadius: BorderRadius.circular(25.0),
                                                border: Border.all(color: MyColors.primaryColor,
                                                    style: BorderStyle.solid,
                                                    width: 0.80),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                        left: 10.0,
                                                        right: 20.0),
                                                child: DropdownButton<String>(
                                                  isExpanded: true,
                                                  value: sessionDropdownValue,
                                                  icon: Icon(
                                                      Icons.arrow_drop_down),
                                                  iconSize: 24,
                                                  elevation: 16,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18),
                                                  underline: Container(
                                                    height: 0,
                                                    color: Colors
                                                        .deepPurpleAccent,
                                                  ),
                                                  onChanged: (String data) {
                                                    _galleryBloc.add(
                                                        SelectSessionEvent(
                                                            data));
                                                  },
                                                  items: sessionSpinnerItems
                                                      .map<
                                                          DropdownMenuItem<
                                                              String>>((String
                                                          value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      (state is GalleryLoading)
                                          ? Align(
                                              alignment: Alignment.center,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0),
                                                child: Container(
                                                    color: Colors.white,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets
                                                              .all(20.0),
                                                      child:
                                                          CircularProgressIndicator(
                                                        valueColor:
                                                            new AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors
                                                                    .deepPurple),
                                                        backgroundColor:
                                                            Colors.pink,
                                                      ),
                                                    )),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: descriptionController,
                                keyboardType: TextInputType.multiline,
                                maxLines: 5,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter your description.';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(25.0),
                                      ),
                                    ),
                                    //icon: Icon(Icons.email),
                                    prefixIcon: Icon(Icons.description,
                                        color: Colors.blue),
                                    labelText: 'Description',
                                    labelStyle: new TextStyle(
                                        color: Colors.grey[800]),
                                    filled: true,
                                    fillColor: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                        BlocListener<GalleryBloc, GalleryStates>(
                          listener:
                              (BuildContext context, GalleryStates state) {
                            if (state is EventDateChanged) {
                              selectedDate = state.date;
                            }
                          },
                          child: BlocBuilder<GalleryBloc, GalleryStates>(
                            builder:
                                (BuildContext context, GalleryStates state) {
                              return GestureDetector(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 30.0),
                                      child: Text("Event Date",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: MyColors.primaryColor,
                                              fontWeight:
                                                  FontWeight.normal)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0,
                                          right: 8.0,
                                          bottom: 8.0,
                                          top: 1.0),
                                      child: Container(
                                        width: double.maxFinite,
                                        padding: EdgeInsets.all(15.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white70,
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          border: Border.all(
                                              color:
                                                  MyColors.primaryColor,
                                              style: BorderStyle.solid,
                                              width: 0.80),
                                        ),
                                        child: Text(
                                            "${selectedDate.toLocal()}"
                                                .split(' ')[0],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                                fontWeight:
                                                    FontWeight.normal)),
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () => _selectDate(context),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _sendButtonFill(context),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  _buildLinkList(List<String> youtubeLinkList) {
    List<Widget> choices = List();
    youtubeLinkList.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(item),
              Icon(
                Icons.cancel,
                size: 15,
              )
            ],
          ),
          selected: false,
          onSelected: (selected) {
            _galleryBloc.add(RemoveLinkToListEvent(item));
          },
        ),
      ));
    });
    return choices;
  }

  bool validateSpinner() {
    bool valid = true;
    if (sessionDropdownValue == '---session---') {
      valid = false;
      showToast(message: 'Please select session');
    }
    return valid;
  }

  void _upLoadFiles() async {
    imageList.clear();
     for (var byteData in selectedImages) {
       print(byteData.name);
      ByteData bytes = await byteData.getByteData(quality: 100);
      var buffer = bytes.buffer;
       _galleryBloc.add(AddGalleryImageEvent(editing?gallery.id:'', 'data:image/jpeg;base64,${base64Encode(await compressList(Uint8List.view(buffer)))}', byteData.name.split('.').last));
    }
      print(imageList.join(','));

     if(editing){
       _galleryBloc.add(UpdateGalleryEvent(gallery.id,
           titleController.text,
           sessionSpinnerIds[sessionSpinnerItems.indexOf(sessionDropdownValue)],
           descriptionController.text, imageList, youtubeLinkList,
           formatDate.format(selectedDate.toLocal()), []));
     }else{
       _galleryBloc.add(AddGalleryEvent(
           titleController.text,
           sessionSpinnerIds[sessionSpinnerItems.indexOf(sessionDropdownValue)],
           descriptionController.text, imageList, youtubeLinkList,
           formatDate.format(selectedDate.toLocal())));
     }

  }


  Widget _sendButtonFill(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: RaisedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            if (validateSpinner()) {
              if(youtubeLinkController.text.isNotEmpty){
                youtubeLinkList.add(youtubeLinkController.text);
                youtubeLinkController.clear();
              }
              _upLoadFiles();
            }
          }
        },
        textColor: Colors.white,
        color: MyColors.primaryColor,
        padding: const EdgeInsets.all(0.0),
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(25.0),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 8.0, top: 15.0, right: 8.0, bottom: 15.0),
          child: const Text("Publish", style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}
