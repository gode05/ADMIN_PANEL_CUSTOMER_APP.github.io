import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../controllers/menu_controller.dart';
import '../screens/loading_manager.dart';
import '../services/global_method.dart';
import '../services/utils.dart';
import '../widgets/buttons.dart';
import '../widgets/header.dart';
import '../widgets/side_menu.dart';
import '../widgets/text_widget.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({
    Key? key,
    required this.id,
    required this.title,
    required this.description,
    required this.productCat,
    required this.price,
    required this.imageUrl,
    required this.salePrice,
    required this.isOnSale,
  }) : super(key: key);

  final String id, title, price, imageUrl, description, productCat;
  final bool isOnSale;
  final double salePrice;
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  // Title and price controllers
  late final TextEditingController _titleController,
      _priceController,
      _descriptionController;

  String? _salePercent;
  late String percToShow;
  late double _salePrice;
  late bool _isOnSale;

  late String _catValue;
  File? _pickedImage;
  Uint8List webImage = Uint8List(10);
  late String _imageUrl;

  @override
  void initState() {
    // set the price and title initial values and initialize the controllers
    _priceController = TextEditingController(text: widget.price);
    _titleController = TextEditingController(text: widget.title);
    _descriptionController = TextEditingController(text: widget.description);
    _imageUrl = widget.imageUrl;
    _catValue = widget.productCat;
    _salePrice = widget.salePrice;
    _isOnSale = widget.isOnSale;
    percToShow = (100 -
                (_salePrice * 100) /
                    double.parse(
                        widget.price)) // WIll be the price instead of 1.88
            .round()
            .toStringAsFixed(1) +
        '%';
    super.initState();
  }

  @override
  void dispose() {
    // Dispose the controllers
    _priceController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  // this method to edit and re-upload the images,title and price from admin app to firebase
  void _updateProduct() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();

      try {
        Uri? imageUri;
        setState(() {
          _isLoading = true;
        });
        if (_pickedImage != null) {
          fb.StorageReference storageRef = fb
              .storage()
              .ref()
              .child('productsImages')
              .child(widget.id + 'jpg');
          final fb.UploadTaskSnapshot uploadTaskSnapshot =
              await storageRef.put(kIsWeb ? webImage : _pickedImage).future;
          imageUri = await uploadTaskSnapshot.ref.getDownloadURL();
        }
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.id)
            .update({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'price': _priceController.text,
          'productCategoryName': _catValue,
          'imageUrl':
              _pickedImage == null ? widget.imageUrl : imageUri.toString(),
          'isOnSale': _isOnSale,
          'salePrice': _salePrice,
        });
        // this method to show massage after update
        await Fluttertoast.showToast(
          msg: "Product has been updated",
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

  @override
  Widget build(BuildContext context) {
    final color = Utils(context).color;
    final _scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    Size size = Utils(context).getScreenSize;

    return Scaffold(
      //key
      key: context.read<MenuController>().getEditProductscaffoldKey,
      drawer: const SideMenu(),
      body: LoadingManager(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                // header
                Header(
                  showTexField: false,
                  title: 'Modifier ce produit',
                  fct: () {
                    context.read<MenuController>().controlEditProductsMenu();
                  },
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
                          text: 'Titre du produit*',
                          color: color,
                          isTitle: true,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        // to edit title
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
                        // to edit description
                        TextWidget(
                          text: 'Description du produit',
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
                        const SizedBox(height: 20),
                        TextWidget(
                          text: 'Catégorie de produit*',
                          color: color,
                          isTitle: true,
                        ),
                        const SizedBox(height: 10),

                        // Drop down menu code here
                        Container(
                          color: _scaffoldColor,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                style: TextStyle(color: color),
                                items: const [
                                  DropdownMenuItem<String>(
                                    child: Text('Électronique'),
                                    value: 'Electronics',
                                  ),
                                  DropdownMenuItem<String>(
                                    child: Text('Accessoires'),
                                    value: 'Accessories',
                                  ),
                                  DropdownMenuItem<String>(
                                    child: Text('Chaussures'),
                                    value: 'Shoes',
                                  ),
                                  DropdownMenuItem<String>(
                                    child: Text('Vêtements'),
                                    value: 'Clothing',
                                  ),
                                  DropdownMenuItem<String>(
                                    child: Text('Téléphones'),
                                    value: 'Phones',
                                  ),
                                  DropdownMenuItem<String>(
                                    child: Text('Ordinateur'),
                                    value: 'Computer',
                                  ),
                                  DropdownMenuItem<String>(
                                    child: Text('Home'),
                                    value: 'Home',
                                  ),
                                  DropdownMenuItem<String>(
                                    child: Text('Livres'),
                                    value: 'Books',
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _catValue = value!;
                                  });
                                },
                                hint: const Text('Sélectionnez une catégorie'),
                                value: _catValue,
                              ),
                            ),
                          ),
                        ),

                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: FittedBox(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                      // to edit price
                                      child: TextFormField(
                                        controller: _priceController,
                                        key: const ValueKey('Price \FCFA'),
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Le prix n'est pas respecté";
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
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: _isOnSale,
                                          onChanged: (newValue) {
                                            setState(() {
                                              _isOnSale = newValue!;
                                            });
                                          },
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        TextWidget(
                                          text: 'Remises',
                                          color: color,
                                          isTitle: true,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    AnimatedSwitcher(
                                      duration: const Duration(seconds: 1),
                                      child: !_isOnSale
                                          ? Container()
                                          : Row(
                                              children: [
                                                TextWidget(
                                                    text: "\FCFA" +
                                                        _salePrice
                                                            .toStringAsFixed(2),
                                                    color: color),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
                                                    style:
                                                        TextStyle(color: color),
                                                    items: const [
                                                      DropdownMenuItem<String>(
                                                        child: Text('5%'),
                                                        value: '5',
                                                      ),
                                                      DropdownMenuItem<String>(
                                                        child: Text('10%'),
                                                        value: '10',
                                                      ),
                                                      DropdownMenuItem<String>(
                                                        child: Text('15%'),
                                                        value: '15',
                                                      ),
                                                      DropdownMenuItem<String>(
                                                        child: Text('25%'),
                                                        value: '25',
                                                      ),
                                                      DropdownMenuItem<String>(
                                                        child: Text('50%'),
                                                        value: '50',
                                                      ),
                                                      DropdownMenuItem<String>(
                                                        child: Text('75%'),
                                                        value: '75',
                                                      ),
                                                      DropdownMenuItem<String>(
                                                        child: Text('0%'),
                                                        value: '0',
                                                      ),
                                                    ],
                                                    onChanged: (value) {
                                                      if (value == '0') {
                                                        return;
                                                      } else {
                                                        setState(() {
                                                          _salePercent = value;
                                                          _salePrice = double
                                                                  .parse(widget
                                                                      .price) -
                                                              (double.parse(
                                                                      value!) *
                                                                  double.parse(
                                                                      widget
                                                                          .price) /
                                                                  100);
                                                        });
                                                      }
                                                    },
                                                    hint: Text(_salePercent ??
                                                        percToShow),
                                                    value: _salePercent,
                                                  ),
                                                )
                                              ],
                                            ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Container(
                                  height: size.width > 650
                                      ? 350
                                      : size.width * 0.45,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      12,
                                    ),
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(12)),
                                    // to edit image
                                    child: _pickedImage == null
                                        ? Image.network(_imageUrl)
                                        : (kIsWeb)
                                            ? Image.memory(
                                                webImage,
                                                fit: BoxFit.fill,
                                              )
                                            : Image.file(
                                                _pickedImage!,
                                                fit: BoxFit.fill,
                                              ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    FittedBox(
                                      child: TextButton(
                                        onPressed: () {
                                          _pickImage();
                                        },
                                        child: TextWidget(
                                          text: "Mettre à jour l'image",
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ButtonsWidget(
                                onPressed: () async {
                                  GlobalMethods.warningDialog(
                                      title: 'Delete?',
                                      subtitle: 'Press okay to confirm',
                                      fct: () async {
                                        await FirebaseFirestore.instance
                                            .collection('products')
                                            .doc(widget.id)
                                            .delete();
                                        await Fluttertoast.showToast(
                                          msg: "Product has been deleted",
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIosWeb: 1,
                                        );
                                        while (Navigator.canPop(context)) {
                                          Navigator.pop(context);
                                        }
                                      },
                                      context: context);
                                },
                                text: 'Supprimer',
                                icon: IconlyBold.danger,
                                backgroundColor: Colors.red.shade700,
                              ),
                              ButtonsWidget(
                                onPressed: () {
                                  _updateProduct();
                                },
                                text: 'Mise a jour',
                                icon: IconlyBold.setting,
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
      ),
    );
  }

  Future<void> _pickImage() async {
    // MOBILE
    if (!kIsWeb) {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        var selected = File(image.path);

        setState(() {
          _pickedImage = selected;
        });
      } else {
        log('No file selected');
        // showToast("No file selected");
      }
    }
    // WEB
    else if (kIsWeb) {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var f = await image.readAsBytes();
        setState(() {
          _pickedImage = File("a");
          webImage = f;
        });
      } else {
        log('No file selected');
      }
    } else {
      log('Perm not granted');
    }
  }
}
