import 'dart:io';
import 'dart:typed_data';

import 'package:admin_panel_customers_app/services/utils.dart';
import 'package:admin_panel_customers_app/widgets/buttons.dart';
import 'package:admin_panel_customers_app/widgets/side_menu.dart';
import 'package:admin_panel_customers_app/widgets/text_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../controllers/menu_controller.dart';
import '../responsive.dart';
import '../screens/loading_manager.dart';
import '../services/global_method.dart';
import '../widgets/header.dart';

class AddProducts extends StatefulWidget {
  static const routeName = '/AddProducts';

  const AddProducts({Key? key}) : super(key: key);

  @override
  _AddProductsState createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  final _formKey = GlobalKey<FormState>();
  String _catValue = 'Electronics';
  late final TextEditingController _titleController,
      _priceController,
      _descriptionController;
  File? _pickedImage;
  Uint8List webImage = Uint8List(8);

  @override
  void initState() {
    _priceController = TextEditingController();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    if (mounted) {
      _priceController.dispose();
      _titleController.dispose();
      _descriptionController.dispose();
    }
    super.dispose();
  }

  bool _isLoading = false;

  // this method to upload the images ,title and price from admin app to firebase
  void _uploadForm() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      if (_pickedImage == null) {
        GlobalMethods.errorDialog(
            subtitle: 'Please pick up an image', context: context);
        return;
      }
      final _uuid = const Uuid().v4();
      try {
        setState(() {
          _isLoading = true;
        });
        fb.StorageReference storageRef =
            fb.storage().ref().child('productsImages').child(_uuid + 'jpg');
        final fb.UploadTaskSnapshot uploadTaskSnapshot =
            await storageRef.put(kIsWeb ? webImage : _pickedImage).future;
        Uri imageUri = await uploadTaskSnapshot.ref.getDownloadURL();
        await FirebaseFirestore.instance.collection('products').doc(_uuid).set({
          'id': _uuid,
          'title': _titleController.text,
          'description': _descriptionController.text,
          'price': _priceController.text,
          'imageUrl': imageUri.toString(),
          'productCategoryName': _catValue,
          'createdAt': Timestamp.now(),
          'isOnSale': false,
          'salePrice': 0.1,
        });
        _clearForm();
        // this method to show massage after update
        Fluttertoast.showToast(
          msg: "Produit téléchargé avec succès",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
        );
      } on FirebaseException catch (error) {
        GlobalMethods.errorDialog(
            subtitle: '${error.message}', context: context);
        setState(() {
          _isLoading = false;
        });
      } catch (error) {
        GlobalMethods.errorDialog(subtitle: '$error', context: context);
        setState(() {
          _isLoading = false;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // this method to remove the images ,title and price from firebase
  void _clearForm() {
    _priceController.clear();
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _pickedImage = null;
      webImage = Uint8List(8);
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Utils(context).color;
    final _scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    Size size = Utils(context).getScreenSize;

    return Scaffold(
      // key
      key: context.read<MenuController>().getAddProductscaffoldKey,
      drawer: const SideMenu(),
      body: LoadingManager(
        isLoading: _isLoading,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              const Expanded(
                child: SideMenu(),
              ),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      // header
                      child: Header(
                          fct: () {
                            context
                                .read<MenuController>()
                                .controlAddProductsMenu();
                          },
                          title: 'Add product',
                          showTexField: false),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Container(
                      width: size.width > 650 ? 650 : size.width,
                      color: Theme.of(context).cardColor,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextWidget(
                              text: 'Product title*',
                              color: color,
                              isTitle: true,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: _titleController,
                              key: const ValueKey('Title'),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter a Title';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: _scaffoldColor,
                                border: InputBorder.none,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: color,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextWidget(
                              text: 'Description du produit*',
                              color: color,
                              isTitle: true,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: _descriptionController,
                              key: const ValueKey('Description'),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter a Description';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: _scaffoldColor,
                                border: InputBorder.none,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: color,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: FittedBox(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        TextWidget(
                                          text: 'Prix en \FCFA*',
                                          color: color,
                                          isTitle: true,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: TextFormField(
                                            controller: _priceController,
                                            key: const ValueKey('Prix \FCFA'),
                                            keyboardType: TextInputType.number,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Price is missed';
                                              }
                                              return null;
                                            },
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'[0-9.]')),
                                            ],
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: _scaffoldColor,
                                              border: InputBorder.none,
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: color,
                                                  width: 1.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        TextWidget(
                                          text: 'Catégorie de produit*',
                                          color: color,
                                          isTitle: true,
                                        ),
                                        const SizedBox(height: 10),
                                        // Drop down menu code here
                                        Container(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18,
                                              ),
                                              value: _catValue,
                                              onChanged: (value) {
                                                setState(() {
                                                  _catValue = value!;
                                                });
                                                print(_catValue);
                                              },
                                              hint: const Text(
                                                  'Select a category'),
                                              items: const [
                                                DropdownMenuItem(
                                                  child: Text(
                                                    'Electronics',
                                                  ),
                                                  value: 'Electronics',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text(
                                                    'Accessories',
                                                  ),
                                                  value: 'Accessories',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text(
                                                    'Shoes',
                                                  ),
                                                  value: 'Shoes',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text(
                                                    'Clothing',
                                                  ),
                                                  value: 'Clothing',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text(
                                                    'Phones',
                                                  ),
                                                  value: 'Phones',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text(
                                                    'Computer',
                                                  ),
                                                  value: 'Computer',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text(
                                                    'Home',
                                                  ),
                                                  value: 'Home',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text(
                                                    'Books',
                                                  ),
                                                  value: 'Books',
                                                ),
                                              ],
                                            )),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Image to be picked code is here
                                Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                        height: size.width > 650
                                            ? 350
                                            : size.width * 0.45,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: _pickedImage == null
                                            ? dottedBorder(color: color)
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: kIsWeb
                                                    ? Image.memory(webImage,
                                                        fit: BoxFit.fill)
                                                    : Image.file(_pickedImage!,
                                                        fit: BoxFit.fill),
                                              )),
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: FittedBox(
                                      child: Column(
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _pickedImage = null;
                                                webImage = Uint8List(8);
                                              });
                                            },
                                            child: TextWidget(
                                              text: 'Clear',
                                              color: Colors.red,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {},
                                            child: TextWidget(
                                              text: "Mise à jour l'image",
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ButtonsWidget(
                                    onPressed: _clearForm,
                                    text: 'Clear form',
                                    icon: IconlyBold.danger,
                                    backgroundColor: Colors.red.shade300,
                                  ),
                                  ButtonsWidget(
                                    onPressed: () {
                                      _uploadForm();
                                    },
                                    text: 'Upload',
                                    icon: IconlyBold.upload,
                                    backgroundColor: Colors.blue,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // this method to upload the images from device to firebase
  Future<void> _pickImage() async {
    if (!kIsWeb) {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var selected = File(image.path);
        setState(() {
          _pickedImage = selected;
        });
      } else {
        print('No image has been picked');
      }
    } else if (kIsWeb) {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var f = await image.readAsBytes();
        setState(() {
          webImage = f;
          _pickedImage = File('a');
        });
      } else {
        print('No image has been picked');
      }
    } else {
      print('Something went wrong');
    }
  }

  Widget dottedBorder({
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DottedBorder(
          dashPattern: const [6.7],
          borderType: BorderType.RRect,
          color: color,
          radius: const Radius.circular(12),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_outlined,
                  color: color,
                  size: 50,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextButton(
                    onPressed: (() {
                      _pickImage();
                    }),
                    child: TextWidget(
                      text: 'Choose an image',
                      color: Colors.blue,
                    ))
              ],
            ),
          )),
    );
  }
}
