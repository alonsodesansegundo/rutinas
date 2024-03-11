import 'dart:convert';
import 'dart:io';

import 'package:TresEnUno/db/obj/grupo.dart';
import 'package:TresEnUno/widgets/ElementAccion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets/ImageTextButton.dart';

class AddRutina extends StatefulWidget {
  @override
  _AddRutinaState createState() => _AddRutinaState();
}

class _AddRutinaState extends State<AddRutina> {
  double titleSize = 0.0,
      textSize = 0.0,
      espacioPadding = 0.0,
      espacioAlto = 0.0,
      imgVolverHeight = 0.0,
      textSituacionWidth = 0.0,
      btnWidth = 0.0,
      btnHeight = 0.0,
      imgWidth = 0.0;

  late ImageTextButton btnVolver;

  late bool loadGrupos;

  late List<Grupo> grupos;

  Grupo? selectedGrupo; // Variable para almacenar el grupo seleccionado

  late String situacionText;

  late ElevatedButton btnPersonajeExistente,
      btnGaleria,
      btnArasaac,
      btnGaleriaAccion,
      btnArasaacAccion;

  late Dialog existPersonajeDialog;
  late AlertDialog incompletedParamsDialog;

  late List<String> personajes;

  late String personajePath;

  late List<ElementAccion> acciones;

  late bool firstLoad;

  XFile? personajeImage;

  late Color colorSituacion, colorGrupo;

  @override
  void initState() {
    super.initState();
    grupos = [];
    _getGrupos();
    loadGrupos = false;
    situacionText = "";
    personajePath = "";
    personajes = [];
    getExistsPersonajes('assets/img/personajes/');
    firstLoad = false;
    personajeImage = null;
    acciones = [];
    selectedGrupo = null;
    colorSituacion = Colors.transparent;
    colorGrupo = Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    _updateVariablesSize();
    _createButtons();
    _createDialogs();
    if (!firstLoad) {
      firstLoad = true;
      acciones = [
        ElementAccion(
          numberAccion: 1,
          textSize: textSize,
          espacioPadding: espacioPadding,
          espacioAlto: espacioAlto,
          btnWidth: btnWidth,
          btnHeight: btnHeight,
          onPressedGaleria: () => _selectNewActionGallery(0),
          onPressedArasaac: () => _selectNewActionArasaac(0),
          textSituacionWidth: textSituacionWidth * 0.75,
        ),
        ElementAccion(
          numberAccion: 2,
          textSize: textSize,
          espacioPadding: espacioPadding,
          espacioAlto: espacioAlto,
          btnWidth: btnWidth,
          btnHeight: btnHeight,
          onPressedGaleria: () => _selectNewActionGallery(1),
          onPressedArasaac: () => _selectNewActionArasaac(1),
          textSituacionWidth: textSituacionWidth * 0.75,
        ),
      ];
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(espacioPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rutinas',
                        style: TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: titleSize,
                        ),
                      ),
                      Text(
                        'Añadir rutina',
                        style: TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: titleSize / 2,
                        ),
                      ),
                    ],
                  ),
                  btnVolver,
                ],
              ),
              SizedBox(height: espacioAlto), // Espacio entre los textos
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Aquí puedes crear nuevas rutinas para el juego.',
                      style: TextStyle(
                        fontFamily: 'ComicNeue',
                        fontSize: textSize,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: espacioAlto), // Espacio
              Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Grupo*:',
                        style: TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: textSize,
                        ),
                      ),
                      SizedBox(width: espacioPadding),
                      Container(
                        decoration: BoxDecoration(
                          color: colorGrupo,
                        ),
                        child: DropdownButton<Grupo>(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          hint: Text(
                            'Selecciona el grupo',
                            style: TextStyle(
                              fontFamily: 'ComicNeue',
                              fontSize: textSize,
                            ),
                          ),
                          value: selectedGrupo,
                          items: grupos.map((Grupo grupo) {
                            return DropdownMenuItem<Grupo>(
                              value: grupo,
                              child: Text(
                                grupo.nombre,
                                style: TextStyle(
                                  fontFamily: 'ComicNeue',
                                  fontSize: textSize,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (Grupo? grupo) {
                            setState(() {
                              selectedGrupo = grupo;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: espacioAlto),
              Text(
                'Situación*:',
                style: TextStyle(
                  fontFamily: 'ComicNeue',
                  fontSize: textSize,
                ),
              ),
              SizedBox(height: espacioAlto / 2),
              Container(
                width: textSituacionWidth,
                decoration: BoxDecoration(
                  color: colorSituacion,
                ),
                child: TextField(
                  onChanged: (text) {
                    this.situacionText = text;
                  },
                  maxLines:
                      5, // Permite que el widget crezca según sea necesario
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              SizedBox(height: espacioAlto), // Espacio entre los textos
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'Personaje:',
                    style: TextStyle(
                      fontFamily: 'ComicNeue',
                      fontSize: textSize,
                    ),
                  ),
                  SizedBox(width: espacioPadding),
                  Column(
                    children: [
                      btnPersonajeExistente,
                      SizedBox(height: espacioAlto / 3),
                      btnGaleria,
                      SizedBox(height: espacioAlto / 3),
                      btnArasaac,
                    ],
                  ),
                  SizedBox(width: espacioPadding),
                  if (personajePath != "")
                    Container(
                      child: Align(
                        alignment: Alignment.center,
                        child: Image.asset(personajePath, width: imgWidth),
                      ),
                    ),
                  if (personajeImage != null)
                    Container(
                      child: Align(
                        alignment: Alignment.center,
                        child: Image.file(
                          File(personajeImage!.path),
                          width: imgWidth,
                          height: imgWidth + imgWidth / 2,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: espacioAlto),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: acciones.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: acciones[index].color),
                        ),
                        child: Row(
                          children: [
                            acciones[index],
                            if (acciones[index].accionImage != null)
                              Row(
                                children: [
                                  SizedBox(width: espacioPadding),
                                  Image.file(
                                    File(acciones[index].accionImage!.path),
                                    width: acciones[index].btnWidth * 0.8,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: espacioAlto * 2),
                    ],
                  );
                },
              ),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      textStyle: TextStyle(
                        fontFamily: 'ComicNeue',
                        fontSize: textSize,
                        color: Colors.blue,
                      ),
                    ),
                    onPressed: _addAccion,
                    child: Text("Añadir acción"),
                  ),
                  SizedBox(width: espacioPadding),
                  if (acciones.length > 2)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        textStyle: TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: textSize,
                          color: Colors.blue,
                        ),
                      ),
                      onPressed: _removeAccion,
                      child: Text("Eliminar acción"),
                    ),
                ],
              ),
              SizedBox(height: espacioAlto),
              Row(
                children: [
                  const Spacer(), // Agrega un espacio flexible
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(btnWidth, btnHeight),
                      textStyle: TextStyle(
                        fontFamily: 'ComicNeue',
                        fontSize: textSize,
                        color: Colors.blue,
                      ),
                    ),
                    onPressed: () {
                      if (!_completedParams()) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            // cuadro de dialogo opciones actualizadas
                            return incompletedParamsDialog;
                          },
                        );
                      }
                    },
                    child: Text("Añadir rutina"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // método para añadir un nuevo ElementAccion
  void _addAccion() {
    setState(() {
      acciones.add(ElementAccion(
        numberAccion: acciones.length + 1,
        textSize: textSize,
        espacioPadding: espacioPadding,
        espacioAlto: espacioAlto,
        btnWidth: btnWidth,
        btnHeight: btnHeight,
        textSituacionWidth: textSituacionWidth,
        onPressedGaleria: () => _selectNewActionGallery(acciones.length),
        onPressedArasaac: () => _selectNewActionArasaac(acciones.length),
      ));
    });
  }

  // método para eliminar el ultimo ElementAccion
  void _removeAccion() {
    setState(() {
      acciones.removeLast();
    });
  }

  // Método para darle valor a las variables relacionadas con tamaños de fuente, imagenes, etc.
  void _updateVariablesSize() {
    Size screenSize = MediaQuery.of(context).size; // tamaño del dispositivo

    final isHorizontal =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isHorizontal) {
      titleSize = screenSize.width * 0.08;
      textSize = screenSize.width * 0.02;
      espacioPadding = screenSize.height * 0.03;
      espacioAlto = screenSize.height * 0.03;
      imgVolverHeight = screenSize.height / 10;
      textSituacionWidth = screenSize.width - espacioPadding * 2;
      btnWidth = screenSize.width / 4;
      btnHeight = screenSize.height / 10;
      imgWidth = screenSize.width / 4;

      _updateSizeAcciones();
    } else {
      titleSize = screenSize.width * 0.10;
      textSize = screenSize.width * 0.03;
      espacioPadding = screenSize.height * 0.03;
      espacioAlto = screenSize.height * 0.03;
      imgVolverHeight = screenSize.height / 32;
      textSituacionWidth = screenSize.width - espacioPadding * 2;
      btnWidth = screenSize.width / 3;
      btnHeight = screenSize.height / 15;
      imgWidth = screenSize.width / 4;

      _updateSizeAcciones();
    }
  }

  // Método para actualizar los tamaños de los ElementAccion
  void _updateSizeAcciones() {
    for (int i = 0; i < acciones.length; i++) {
      ElementAccion updatedAccion = ElementAccion(
        textSize: textSize,
        espacioPadding: espacioPadding,
        espacioAlto: espacioAlto,
        btnHeight: btnHeight,
        btnWidth: btnWidth,
        numberAccion: acciones[i].numberAccion,
        textSituacionWidth: acciones[i].textSituacionWidth,
        onPressedGaleria: acciones[i].onPressedGaleria,
        onPressedArasaac: acciones[i].onPressedArasaac,
        accionImage: acciones[i].accionImage,
        color: acciones[i].color,
        accionText: acciones[i].accionText,
      );
      print("HOLA HOLA " + acciones[i].accionText.toString());
      acciones[i] = updatedAccion;
    }
  }

  // Método para crear los botones necesarios
  void _createButtons() {
    // boton para dar volver a la pantalla principal de rutinas
    btnVolver = ImageTextButton(
      image:
          Image.asset('assets/img/botones/home.png', height: imgVolverHeight),
      text: Text(
        'Volver',
        style: TextStyle(
            fontFamily: 'ComicNeue', fontSize: textSize, color: Colors.black),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    btnPersonajeExistente = ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(btnWidth, btnHeight),
        textStyle: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
          color: Colors.blue,
        ),
      ),
      child: Text(
        'Personaje\n '
        'existente',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
        ),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return existPersonajeDialog;
          },
        );
      },
    );

    btnGaleria = ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(btnWidth, btnHeight),
        textStyle: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
          color: Colors.blue,
        ),
      ),
      child: Text(
        'Nuevo personaje\n'
        '(desde galería)',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
        ),
      ),
      onPressed: () {
        _selectNewPersonajeGallery();
      },
    );

    btnArasaac = ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(btnWidth, btnHeight),
        textStyle: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
          color: Colors.blue,
        ),
      ),
      child: Text(
        'Nuevo personaje\n'
        '(desde ARASAAC)',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
        ),
      ),
      onPressed: () {},
    );

    btnGaleriaAccion = ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(btnWidth, btnHeight),
        textStyle: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
          color: Colors.blue,
        ),
      ),
      child: Text(
        'Nueva acción\n'
        '(desde galería)',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
        ),
      ),
      onPressed: () {},
    );

    btnArasaacAccion = ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(btnWidth, btnHeight),
        textStyle: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
          color: Colors.blue,
        ),
      ),
      child: Text(
        'Nueva acción\n'
        '(desde ARASAAC)',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
        ),
      ),
      onPressed: () {},
    );
  }

  // Metodo para crear los cuadros de dialogo necesarios
  void _createDialogs() {
    // cuadro de dialogo para escoger un personaje ya existente
    existPersonajeDialog = Dialog(
      child: Column(
        children: [
          SizedBox(height: espacioAlto),
          Center(
            child: Text(
              'Escoge un personaje',
              style: TextStyle(
                fontFamily: 'ComicNeue',
                fontSize: textSize,
              ),
            ),
          ),
          SizedBox(height: espacioAlto),
          Expanded(
            child: ListView(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: espacioAlto,
                    mainAxisSpacing: espacioAlto * 2,
                  ),
                  itemCount: personajes.length,
                  itemBuilder: (BuildContext context, int index) {
                    String imagePath = personajes[index];
                    return GestureDetector(
                      onTap: () {
                        _selectExistPersonaje(context, imagePath);
                      },
                      child: Image.asset(imagePath),
                    );
                  },
                ),
                SizedBox(height: espacioAlto * 2),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(btnWidth / 2, btnHeight),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontFamily: 'ComicNeue',
                fontSize: textSize,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          SizedBox(height: espacioAlto * 2),
        ],
      ),
    );

    // cuadro de dialogo para cuando no se han completado todos los campos obligatorios
    incompletedParamsDialog = AlertDialog(
      title: Text(
        'Error',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: titleSize * 0.75,
        ),
      ),
      content: Text(
        'No has completado todos los campos obligatorios para poder añadir una '
        'nueva rutina, revísalo e inténtalo de nuevo.',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
        ),
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
            },
            child: Text(
              'Aceptar',
              style: TextStyle(
                fontFamily: 'ComicNeue',
                fontSize: textSize,
              ),
            ),
          ),
        )
      ],
    );

    // cuadro de dialogo para cuando rutina añadida con éxito
  }

  // Método para cuando selecciono un personaje ya existente
  void _selectExistPersonaje(BuildContext context, String imagePath) {
    setState(() {
      personajePath = imagePath;
      personajeImage = null;
    });
    Navigator.of(context).pop();
  }

  // Método para seleccionar un nuevo personaje desde la galería
  Future<void> _selectNewPersonajeGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      personajeImage = image;
      personajePath = "";
    });
  }

  // Método para seleccionar una nueva imagen de accion desde la galeria
  Future<void> _selectNewActionGallery(int index) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      acciones[index].accionImage = image;
    });
  }

  void _selectNewActionArasaac(int index) {}

  // Método para obtener la lista de grupos de la BBDD
  Future<void> _getGrupos() async {
    try {
      List<Grupo> gruposList = await getGrupos();
      setState(() {
        grupos = gruposList;
      });
    } catch (e) {
      print("Error al obtener la lista de grupos: $e");
    }
  }

  // Método para obtener todos los path de los personajes
  Future<List<String>> getExistsPersonajes(String folderPath) async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final List<String> imagePaths = manifestMap.keys
        .where((String key) => key.startsWith(folderPath))
        .toList();

    setState(() {
      personajes = imagePaths;
    });

    return imagePaths;
  }

  // Método para comprobar que los parametros obligatorios están completos
  bool _completedParams() {
    bool correct = true;
    // compruebo que todos los parametros obligatorios están completos
    if (selectedGrupo == null) {
      correct = false;
      setState(() {
        colorGrupo = Colors.redAccent;
      });
    } else
      colorGrupo = Colors.transparent;

    if (situacionText.isEmpty) {
      correct = false;
      setState(() {
        colorSituacion = Colors.redAccent;
      });
    } else
      colorSituacion = Colors.transparent;

    for (int i = 0; i < acciones.length; i++) {
      if (acciones[i].accionImage == null || acciones[i].accionText.isEmpty) {
        print("IMAGEN " + acciones[i].accionImage.toString());
        print("TEXT " + acciones[i].accionText.toString());

        correct = false;
        setState(() {
          acciones[i].color = Colors.redAccent;
        });
      } else
        acciones[i].color = Colors.transparent;
    }
    return correct;
  }
}
