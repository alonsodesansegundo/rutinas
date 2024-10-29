import 'dart:io';

import 'package:Rutirse/widgets/ElementRespuestaSentimientos.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:sqflite/sqflite.dart';

import '../../db/obj/nivel.dart';
import '../../db/obj/preguntaSentimiento.dart';
import '../../db/obj/situacion.dart';
import '../../widgets/ArasaacImageDialog.dart';
import '../../widgets/ImageTextButton.dart';
import '../main.dart';

///Pantalla que le permite al terapeuta la edición de una pregunta del juego Sentimientos y sus respuestas
class EditSentimiento extends StatefulWidget {
  PreguntaSentimiento preguntaSentimiento;
  Nivel nivel;

  EditSentimiento({required this.preguntaSentimiento, required this.nivel});

  @override
  EditSentimientoState createState() => EditSentimientoState();
}

/// Estado asociado a la pantalla [EditSentimiento] que gestiona la lógica
/// y la interfaz de usuario de la pantalla
class EditSentimientoState extends State<EditSentimiento> {
  late double titleSize,
      textSize,
      espacioPadding,
      espacioAlto,
      imgVolverHeight,
      textSituacionWidth,
      btnWidth,
      btnHeight,
      imgWidth;
  late ImageTextButton btnVolver;

  late List<Nivel> nivels;

  Nivel? selectedNivel; // Variable para almacenar el nivel seleccionado

  late String preguntaText, correctText;

  late ElevatedButton btnGaleria, btnArasaac, btnEliminarImage;

  late ArasaacImageDialog arasaacImageDialog;

  late AlertDialog incompletedParamsDialog,
      completedParamsDialog,
      noInternetDialog,
      noMinAnswers;

  late bool firstLoad = true, changeNivel, isVisible;

  late List<int> image;

  late List<ElementRespuestaSentimientos> respuestas, situacionesToDelete;

  late Color colorSituacion,
      colorNivel,
      colorCorrectText,
      colorBordeImagen,
      colorCheckbox;

  late Nivel defaultNivel;

  late int sizeRespuestasInitial;

  late AlertDialog removePreguntaOk;

  @override
  void initState() {
    super.initState();
    defaultNivel = widget.nivel;
    nivels = [];
    preguntaText = "";
    correctText = "";
    respuestas = [];
    situacionesToDelete = [];
    image = [];
    selectedNivel = null;
    colorSituacion = Colors.transparent;
    colorCorrectText = Colors.transparent;
    colorNivel = Colors.transparent;
    colorBordeImagen = Colors.transparent;
    colorCheckbox = Colors.transparent;
    changeNivel = false;

    if (firstLoad) {
      firstLoad = false;
      _getNivels();
      isVisible = widget.preguntaSentimiento.visible == 1; // true si es 1, false si es 0
      preguntaText = widget.preguntaSentimiento.enunciado;
      if (widget.preguntaSentimiento.imagen != null) {
        setState(() {
          image = widget.preguntaSentimiento.imagen!;
        });
      } else
        image = [];

      _loadRespuestas();
    }
    _initializeState();
  }

  Future<void> _initializeState() async {
    await _getNivels();
    _createDialogs();
  }

  @override
  Widget build(BuildContext context) {
    if (!firstLoad) {
      firstLoad = true;
      _createVariablesSize();
      _createButtons();
    }

    return Scaffold(
      body: DynMouseScroll(
        durationMS: myDurationMS,
        scrollSpeed: myScrollSpeed,
        animationCurve: Curves.easeOutQuart,
        builder: (context, controller, physics) => SingleChildScrollView(
          controller: controller,
          physics: physics,
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
                          'Sentimientos',
                          style: TextStyle(
                            fontFamily: 'ComicNeue',
                            fontSize: titleSize,
                          ),
                        ),
                        Text(
                          'Editar pregunta',
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
                        'Aquí tienes la posibilidad de editar la pregunta y sus posibles respuestas, incluso el nivel al que pertenece.',
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
                          'Nivel*:',
                          style: TextStyle(
                            fontFamily: 'ComicNeue',
                            fontSize: textSize,
                          ),
                        ),
                        SizedBox(width: espacioPadding),
                        Container(
                          decoration: BoxDecoration(
                            color: colorNivel,
                          ),
                          child: DropdownButton<Nivel>(
                            padding: EdgeInsets.only(
                              left: espacioPadding,
                            ),
                            hint: Text(
                              widget.nivel.nombre,
                              style: TextStyle(
                                fontFamily: 'ComicNeue',
                                fontSize: textSize,
                              ),
                            ),
                            value: selectedNivel,
                            items: nivels.map((Nivel nivel) {
                              return DropdownMenuItem<Nivel>(
                                value: nivel,
                                child: Text(
                                  nivel.nombre,
                                  style: TextStyle(
                                    fontFamily: 'ComicNeue',
                                    fontSize: textSize,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (Nivel? nivel) {
                              setState(() {
                                changeNivel = true;
                                selectedNivel = nivel;
                                respuestas = respuestas.asMap().entries.map((entry) {
                                  var respuesta = entry.value; // Obtener el elemento actual

                                  return ElementRespuestaSentimientos(
                                    id: respuesta.id,
                                    text1: respuesta.text1,
                                    respuestaText: respuesta.respuestaText,
                                    respuestaImage: respuesta.respuestaImage!.toList(),
                                    isCorrect: respuesta.isCorrect,
                                    textSize: respuesta.textSize,
                                    espacioPadding: respuesta.espacioPadding,
                                    espacioAlto: respuesta.espacioAlto,
                                    btnWidth: respuesta.btnWidth,
                                    btnHeight: respuesta.btnHeight,
                                    imgWidth: respuesta.imgWidth,
                                    onPressedGaleria: () => respuesta.onPressedGaleria,
                                    onPressedArasaac: () => respuesta.onPressedArasaac,
                                    showPregunta: respuesta.showPregunta,
                                    flagDificil: (selectedNivel!.nombre == "Difícil"),
                                    flagFacil: (selectedNivel!.nombre == "Fácil"),
                                    onRemoveAnswer: () => respuesta.onRemoveAnswer,
                                  );
                                }).toList();
                                if(selectedNivel!.nombre=="Fácil"){
                                  setState(() {
                                    respuestas.removeRange(2, respuestas.length);
                                  });
                                }
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
                  'Pregunta*:',
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
                    controller: TextEditingController(text: this.preguntaText),
                    onChanged: (text) {
                      this.preguntaText = text;
                    },
                    maxLines: 5,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(
                      fontFamily: 'ComicNeue',
                      fontSize: textSize,
                    ),
                  ),
                ),
                SizedBox(height: espacioAlto), // Espacio entre los textos
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colorBordeImagen, // Color del borde verde
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Container(
                        width: getWidthOfText("(máx. 30 caracteres)", context) +
                            espacioPadding * 1.5,
                        child: Text(
                          'Imagen*:',
                          style: TextStyle(
                            fontFamily: 'ComicNeue',
                            fontSize: textSize,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          btnGaleria,
                          SizedBox(height: espacioAlto / 3),
                          btnArasaac,
                          if (image.isNotEmpty)
                            Column(
                              children: [
                                SizedBox(height: espacioAlto / 3),
                                btnEliminarImage,
                              ],
                            )
                        ],
                      ),
                      SizedBox(width: espacioPadding),
                      if (image.isNotEmpty)
                        Container(
                          child: Align(
                              alignment: Alignment.center,
                              child: Image.memory(
                                Uint8List.fromList(image),
                                width: imgWidth,
                              )),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: espacioAlto),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: respuestas.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: respuestas[index].color),
                          ),
                          child: Row(
                            children: [respuestas[index]],
                          ),
                        ),
                        SizedBox(height: espacioAlto),
                      ],
                    );
                  },
                ),
                if ((changeNivel && selectedNivel!.nombre != "Fácil") ||
                    (!changeNivel && defaultNivel!.nombre != "Fácil"))
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          textStyle: TextStyle(
                            fontFamily: 'ComicNeue',
                            fontSize: textSize,
                          ),
                        ),
                        onPressed: _addRespuesta,
                        child: Text("Añadir respuesta"),
                      ),
                    ],
                  ),
                SizedBox(height: espacioAlto),
                Row(
                  children: [
                    Text(
                      '¿Hacer visible?',
                      style: TextStyle(
                        fontFamily: 'ComicNeue',
                        fontSize: textSize,
                      ),
                    ),
                    Checkbox(
                      value: isVisible, // Checkbox para "Sí"
                      onChanged: (bool? value) {
                        setState(() {
                          isVisible = true; // Establece visible a true
                        });
                      },
                    ),
                    Text(
                      'Sí',
                      style: TextStyle(
                        fontFamily: 'ComicNeue',
                        fontSize: textSize,
                      ),
                    ),
                    Checkbox(
                      value: !isVisible, // Checkbox para "No"
                      onChanged: (bool? value) {
                        setState(() {
                          isVisible = false; // Establece visible a false
                        });
                      },
                    ),
                    Text(
                      'No',
                      style: TextStyle(
                        fontFamily: 'ComicNeue',
                        fontSize: textSize,
                      ),
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
                        if (!changeNivel) {
                          for (Nivel nivel in nivels) {
                            if (nivel.nombre == widget.nivel.nombre) {
                              selectedNivel = nivel;
                              break;
                            }
                          }
                        }
                        if (!_completedParams()) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return incompletedParamsDialog;
                            },
                          );
                        } else {
                          if (respuestas.length < 2 ||
                              !_hayRespuestaCorrecta()) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return noMinAnswers;
                              },
                            );
                            return;
                          }

                          _editSentimiento();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return completedParamsDialog;
                            },
                          );
                        }
                      },
                      child: Text("Editar pregunta"),
                    ),
                  ],
                ),
                SizedBox(height: espacioAlto / 3),
                Row(
                  children: [
                    const Spacer(), // Agrega un espacio flexible
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(btnWidth, btnHeight / 2),
                        backgroundColor: Colors.red,
                        textStyle: TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: textSize,
                        ),
                      ),
                      onPressed: () {
                        AlertDialog aux = AlertDialog(
                          title: Text(
                            'Aviso',
                            style: TextStyle(
                              fontFamily: 'ComicNeue',
                              fontSize: titleSize * 0.75,
                            ),
                          ),
                          content: Text(
                            'Estás a punto de eliminar la siguiente pregunta del nivel ${widget.nivel.nombre}:\n'
                            '${widget.preguntaSentimiento.enunciado}\n'
                            '¿Estás seguro de ello?',
                            style: TextStyle(
                              fontFamily: 'ComicNeue',
                              fontSize: textSize,
                            ),
                          ),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _removePregunta(
                                        widget.preguntaSentimiento.id!);
                                    Navigator.of(context).pop();
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return removePreguntaOk;
                                      },
                                    );
                                  },
                                  child: Text(
                                    'Sí, eliminar',
                                    style: TextStyle(
                                      fontFamily: 'ComicNeue',
                                      fontSize: textSize,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: espacioPadding,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Cancelar',
                                    style: TextStyle(
                                      fontFamily: 'ComicNeue',
                                      fontSize: textSize,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return aux;
                          },
                        );
                      },
                      child: Text("Eliminar pregunta"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///Método que sirve para contar las respuestas correctas, para comprobar que al menos hay una
  bool _hayRespuestaCorrecta() {
    for (int i = 0; i < respuestas.length; i++) {
      if (respuestas[i].isCorrect) return true;
    }
    return false;
  }

  ///Método que nos permite añadir un nuevo [ElementRespuestaSentimientos] para que haya más respuestas en la pregunta
  void _addRespuesta() {
    setState(() {
      int currentIndex = respuestas.length; // Captura el índice actual

      ElementRespuestaSentimientos aux = new ElementRespuestaSentimientos(
        text1: "Respuesta",
        textSize: textSize,
        espacioPadding: getWidthOfText("(máx. 30 caracteres)", context) +
            espacioPadding * 1.5,
        espacioAlto: espacioAlto,
        btnWidth: btnWidth,
        btnHeight: btnHeight,
        imgWidth: imgWidth,
        onPressedGaleria: () => _selectNewActionGallery(currentIndex),
        onPressedArasaac: () => _selectNewRespuestaArasaac(currentIndex),
        onRemoveAnswer: () => _removeAnswerButton(currentIndex),
        isCorrect: true,
        showPregunta: true,
        flagFacil: (!changeNivel && defaultNivel!.nombre == "Fácil") ||
            (changeNivel && selectedNivel!.nombre == "Fácil"),
        flagDificil: (!changeNivel && defaultNivel!.nombre == "Difícil") ||
            (changeNivel && selectedNivel!.nombre == "Difícil"),
      );

      respuestas.add(aux); // Agrega el elemento a la lista
    });
  }

  ///Método que nos permite eliminar la respuesta [index]
  void _removeAnswerButton(int index) {
    setState(() {
      situacionesToDelete.add(respuestas[index]);
      respuestas.removeAt(index);
      for(int i=index;i<respuestas.length;i++){
        respuestas[i]= new ElementRespuestaSentimientos(
            text1: respuestas[i].text1,
            textSize: respuestas[i].textSize,
            espacioPadding: respuestas[i].espacioPadding,
            espacioAlto: respuestas[i].espacioAlto,
            btnWidth: respuestas[i].btnWidth,
            btnHeight: respuestas[i].btnHeight,
            imgWidth: respuestas[i].imgWidth,
            onPressedGaleria: () => _selectNewActionGallery(i),
            onPressedArasaac: () => _selectNewRespuestaArasaac(i),
      onRemoveAnswer: () => _removeAnswerButton(i),
      isCorrect: respuestas[i].isCorrect,
      showPregunta: respuestas[i].showPregunta,
      respuestaText: respuestas[i].respuestaText,
      respuestaImage: respuestas[i].respuestaImage,
      flagDificil: respuestas[i].flagDificil,
      flagFacil: respuestas[i].flagFacil);
      }
    });
  }

  ///Método encargado de editar una pregunta y sus respectivas respuestas
  Future<void> _editSentimiento() async {
    _editPregunta();
    _editRespuestas();
  }

  ///Metodo que nos permite eliminar una pregunta del juego Sentimientos a partir de su identificador
  ///<br><b>Parámetros</b><br>
  ///[preguntaId] Identificador de la pregunta que queremos eliminar
  void _removePregunta(int preguntaId) {
    removePreguntaSentimiento(preguntaId);
  }

  ///Método encargado de editar una pregunta juego Sentimientos
  Future<void> _editPregunta() async {
    Database db = await openDatabase('rutinas.db');
    int visibility = isVisible ? 1 : 0;

    await updatePregunta(db, widget.preguntaSentimiento.id!, preguntaText,
        Uint8List.fromList(image), selectedNivel!.id, visibility: visibility);
  }

  ///Método encargado de editar las respuestas a una pregunta del juego Sentimientos
  Future<void> _editRespuestas() async {
    Database db = await openDatabase('rutinas.db');
    for (int i = 0; i < respuestas.length; i++) {
      if (i < this.sizeRespuestasInitial) {
        if (selectedNivel!.nombre != "Difícil") {

          await db.update(
            'situacion',
            {
              'texto': respuestas[i].respuestaText,
              'correcta': respuestas[i].isCorrect ? 1 : 0,
              'imagen': respuestas[i].respuestaImage,
              'preguntaSentimientoId': widget.preguntaSentimiento.id,
            },
            where: 'id = ?',
            whereArgs: [respuestas[i].id],
          );
        } else {

          await db.update(
            'situacion',
            {
              'texto': "",
              'correcta': respuestas[i].isCorrect ? 1 : 0,
              'imagen': respuestas[i].respuestaImage,
              'preguntaSentimientoId': widget.preguntaSentimiento.id,
            },
            where: 'id = ?',
            whereArgs: [respuestas[i].id],
          );
        }
      } else {
        if (selectedNivel!.nombre != "Difícil") {
          await db.insert(
            'situacion',
            {
              'texto': respuestas[i].respuestaText,
              'correcta': respuestas[i].isCorrect ? 1 : 0,
              'imagen': respuestas[i].respuestaImage,
              'preguntaSentimientoId': widget.preguntaSentimiento.id,
            },
          );
        } else {
          await db.insert(
            'situacion',
            {
              'texto': "",
              'correcta': respuestas[i].isCorrect ? 1 : 0,
              'imagen': respuestas[i].respuestaImage,
              'preguntaSentimientoId': widget.preguntaSentimiento.id,
            },
          );
        }
      }
    }
    for (int i = 0; i < situacionesToDelete.length; i++) {
      deleteSituacion(db, situacionesToDelete[i].id!);
    }
  }

  ///Método que nos permite obtener los nivels con los que cuenta la aplicación y almacenarlos en la variable [nivels]
  Future<void> _getNivels() async {
    try {
      List<Nivel> nivelsList = await getNiveles();
      setState(() {
        nivels = nivelsList;
      });
    } catch (e) {
      print("Error al obtener la lista de nivels: $e");
    }
  }

  ///Método que nos permite obtener el ancho que se supone que ocuparía una cadena de texto
  ///<br><b>Parámetros</b><br>
  ///[text] Cadena de texto de la que queremos obtener el valor de ancho<br>
  ///[context] El contexto de la aplicación, que proporciona acceso a información
  ///sobre el entorno en el que se está ejecutando el widget, incluyendo el tamaño de la pantalla
  double getWidthOfText(String text, BuildContext context) {
    final TextSpan span = TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: 'ComicNeue',
        fontSize: textSize * 0.5,
        fontWeight: FontWeight.bold,
      ),
    );
    final TextPainter tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: MediaQuery.of(context).size.width);
    return tp.width;
  }

  ///Método que se utiliza para darle valor a las variables relacionadas con tamaños de fuente, imágenes, etc.
  void _createVariablesSize() {
    Size screenSize = MediaQuery.of(context).size; // tamaño del dispositivo

    titleSize = screenSize.width * 0.10;
    textSize = screenSize.width * 0.03;
    espacioPadding = screenSize.height * 0.03;
    espacioAlto = screenSize.width * 0.03;
    imgVolverHeight = screenSize.height / 32;
    textSituacionWidth = screenSize.width - espacioPadding * 2;
    btnWidth = screenSize.width / 3;
    btnHeight = screenSize.height / 15;
    imgWidth = screenSize.width / 4.5;
  }

  ///Método encargado de inicializar los botones que tendrá la pantalla
  void _createButtons() {
    // boton para dar volver a la pantalla principal de ironías
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

    btnGaleria = ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(btnWidth, btnHeight),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      child: Text(
        'Nueva imagen\n'
        '(desde galería)',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
        ),
      ),
      onPressed: () {
        _selectNewImageGallery();
      },
    );

    btnArasaac = ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(btnWidth, btnHeight),
        backgroundColor: Colors.lightGreen,
      ),
      child: Text(
        'Nueva imagen\n'
        '(desde ARASAAC)',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
        ),
      ),
      onPressed: () async {
        var connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult == ConnectivityResult.none) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return noInternetDialog;
            },
          );
        } else if (connectivityResult == ConnectivityResult.mobile ||
            connectivityResult == ConnectivityResult.wifi) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return arasaacImageDialog;
            },
          );
        }
      },
    );

    btnEliminarImage = ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(btnWidth, btnHeight / 2),
        backgroundColor: Colors.redAccent,
      ),
      child: Text(
        'Eliminar imagen',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize * 0.75,
        ),
      ),
      onPressed: () {
        setState(() {
          image = [];
        });
      },
    );
  }

  ///Método encargado de inicializar los cuadros de dialogo que tendrá la pantalla
  void _createDialogs() {
    removePreguntaOk = AlertDialog(
      title: Text(
        'Éxito',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: titleSize * 0.75,
        ),
      ),
      content: Text(
        'La pregunta ha sido eliminada correctamente.\n'
        '¡Muchas gracias por tu colaboración!',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                'Aceptar',
                style: TextStyle(
                  fontFamily: 'ComicNeue',
                  fontSize: textSize,
                ),
              ),
            ),
          ],
        ),
      ],
    );

    // cuadro de dialogo para escoger un personaje de arasaac
    arasaacImageDialog = ArasaacImageDialog(
      espacioAlto: espacioAlto,
      espacioPadding: espacioPadding,
      btnWidth: btnWidth,
      btnHeigth: btnHeight,
      imgWidth: imgWidth,
      onImageArasaacChanged: (newValue) async {
        final response = await http.get(Uri.parse(newValue));
        List<int> bytes = response.bodyBytes;
        setState(() {
          image = bytes;
        });
      },
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
        'La pregunta no se ha podido editar. Por favor, revisa que has completado todos los campos obligatorios e inténtalo de nuevo.\n',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
        ),
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
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

    // cuadro de dialogo para cuando ironía añadida con éxito
    completedParamsDialog = AlertDialog(
      title: Text(
        '¡Fántastico!',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: titleSize * 0.75,
        ),
      ),
      content: Text(
        'La pregunta se ha editado con éxito. Agradecemos tu colaboración, y los jugadores seguro que todavía más!',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
        ),
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
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

    // cuadro de diálogo para cuando no hay conexión a internet
    noInternetDialog = AlertDialog(
      title: Text(
        'Problema',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: titleSize * 0.75,
        ),
      ),
      content: Text(
        'Hemos detectado que no tienes conexión a internet, y para realizar esta acción es necesario.\nPor favor, inténtalo de nuevo o más tarde.',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
        ),
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
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

    // cuadro de dialogo cuando no hay al menos dos posibles respuestas o ninguna de ellas es correcta
    noMinAnswers = AlertDialog(
      title: Text(
        'Error',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: titleSize * 0.75,
        ),
      ),
      content: Text(
        'No hemos podido editar la pregunta con éxito. Recuerda que debe de haber al'
        ' menos dos posibles respuestas y al menos una de ellas debe de ser correcta.',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
        ),
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
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
  }

  ///Método que nos permite seleccionar una nueva imagen para la pregunta a través de la galería
  Future<void> _selectNewImageGallery() async {
    final picker = ImagePicker();
    final imageAux = await picker.pickImage(source: ImageSource.gallery);
    if (imageAux != null) {
      File imageFile = File(imageAux!.path);
      List<int> bytes = await imageFile.readAsBytes();

      setState(() {
        image = bytes;
      });
    }
  }

  ///Método que nos permite seleccionar una nueva imagen para la respuesta [index] a través de un cuadro de
  ///dialogo que muestra pictogramas de ARASAAC y permite la búsqueda por palabras clave
  Future<void> _selectNewRespuestaArasaac(int index) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return noInternetDialog;
        },
      );
    } else if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      ArasaacImageDialog aux = ArasaacImageDialog(
        espacioAlto: espacioAlto,
        espacioPadding: espacioPadding,
        btnWidth: btnWidth,
        btnHeigth: btnHeight,
        imgWidth: imgWidth,
        onImageArasaacChanged: (newValue) async {
          final response = await http.get(Uri.parse(newValue));
          List<int> bytes = response.bodyBytes;
          setState(() {
            respuestas[index] = new ElementRespuestaSentimientos(
                text1: respuestas[index].text1,
                textSize: respuestas[index].textSize,
                espacioPadding: respuestas[index].espacioPadding,
                espacioAlto: respuestas[index].espacioAlto,
                btnWidth: respuestas[index].btnWidth,
                btnHeight: respuestas[index].btnHeight,
                imgWidth: respuestas[index].imgWidth,
                onPressedGaleria: () => _selectNewActionGallery(index),
                onPressedArasaac: () => _selectNewRespuestaArasaac(index),
                onRemoveAnswer: () => _removeAnswerButton(index),
                isCorrect: respuestas[index].isCorrect,
                showPregunta: respuestas[index].showPregunta,
                respuestaText: respuestas[index].respuestaText,
                respuestaImage: bytes,
                flagDificil: respuestas[index].flagDificil,
                flagFacil: respuestas[index].flagFacil);
          });
        },
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return aux;
        },
      );
    }
  }

  ///Método que nos permite seleccionar una nueva imagen para la accion [index] a través de la galería
  Future<void> _selectNewActionGallery(int index) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File imageFile = File(image!.path);
      List<int> bytes = await imageFile.readAsBytes();
      setState(() {
        respuestas[index] = new ElementRespuestaSentimientos(
            text1: respuestas[index].text1,
            textSize: respuestas[index].textSize,
            espacioPadding: respuestas[index].espacioPadding,
            espacioAlto: respuestas[index].espacioAlto,
            btnWidth: respuestas[index].btnWidth,
            btnHeight: respuestas[index].btnHeight,
            imgWidth: respuestas[index].imgWidth,
            onPressedGaleria: () => _selectNewActionGallery(index),
            onPressedArasaac: () => _selectNewRespuestaArasaac(index),
            onRemoveAnswer: () => _removeAnswerButton(index),
            isCorrect: respuestas[index].isCorrect,
            showPregunta: respuestas[index].showPregunta,
            respuestaText: respuestas[index].respuestaText,
            respuestaImage: bytes,
            flagDificil: respuestas[index].flagDificil,
            flagFacil: respuestas[index].flagFacil);
      });
    }
  }

  ///Método que se encarga de comprobar que están rellenados todos los campos y opciones para poder añadir una nueva pregunta al juego Rutinas
  ///<br><b>Salida</b><br>
  ///[true] si los campos obligatorios están completos, [false] en caso contrario
  bool _completedParams() {
    bool correct = true;
    // compruebo que todos los parametros obligatorios están completos
    if (selectedNivel == null) {
      correct = false;
      setState(() {
        colorNivel = Colors.red;
      });
    } else
      colorNivel = Colors.transparent;

    if (preguntaText.trim().isEmpty) {
      correct = false;
      setState(() {
        colorSituacion = Colors.red;
      });
    } else
      colorSituacion = Colors.transparent;

    if (image.isEmpty) {
      correct = false;
      setState(() {
        colorBordeImagen = Colors.red;
      });
    } else
      colorBordeImagen = Colors.transparent;

    // si es el nivel adolescencia, la imagen no puede estar vacia
    // en cualquier otro el texto no puede estar vacio
    for (int i = 0; i < respuestas.length; i++)
      if (respuestas[i].respuestaImage.isEmpty ||
          (respuestas[i].respuestaText.trim().isEmpty &&
              selectedNivel!.nombre != "Difícil")) {
        correct = false;
        setState(() {
          respuestas[i].color = Colors.red;
        });
      } else
        respuestas[i].color = Colors.transparent;

    return correct;
  }

  ///Método que nos permite cargar las respuestas de la pregunta actual
  void _loadRespuestas() async {
    List<Situacion> aux = await getSituaciones(widget.preguntaSentimiento.id!);
    for (int i = 0; i < aux.length; i++) {
      ElementRespuestaSentimientos elementRespuestaSentimientos =
          new ElementRespuestaSentimientos(
        id: aux[i].id,
        text1: "Respuesta",
        isCorrect: aux[i].correcta == 1,
        textSize: textSize,
        espacioPadding: getWidthOfText("(máx. 30 caracteres)", context) +
            espacioPadding * 1.5,
        espacioAlto: espacioAlto,
        btnWidth: btnWidth,
        btnHeight: btnHeight,
        respuestaText: aux[i].texto,
        respuestaImage: aux[i].imagen!.toList(),
        imgWidth: imgWidth,
            onPressedGaleria: () =>_selectNewActionGallery(i),
        onPressedArasaac: () => _selectNewRespuestaArasaac(i),
        onRemoveAnswer: () => _removeAnswerButton(i),
        showPregunta: (i != 0 && i != 1),
        flagDificil: (widget.nivel.nombre == "Difícil"),
        flagFacil: (widget.nivel.nombre == "Fácil"),
      );
      setState(() {
        this.respuestas.add(elementRespuestaSentimientos);
      });
    }
    this.sizeRespuestasInitial = this.respuestas.length;
  }
}
