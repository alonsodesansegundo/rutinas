// PREGUNTAS SENTIMIENTOS PARA EL GRUPO DE ADOLESCENCIA
import 'package:sqflite/sqflite.dart';

import '../obj/preguntaSentimiento.dart';
import '../obj/situacion.dart';

///Path correspondiente a donde se almacenan las imágenes de las preguntas del juego Sentimientos
String pathSentimientos = 'assets/img/sentimientos/';

///Path correspondiente a donde se almacenan las imágenes de los personajes del juego Rutinas
String pathPersonaje = 'assets/img/personajes/';

///Método encargado de las insercciones de preguntas predeterminadas para el juego Sentimientos del grupo Adolescencia
///<br><b>Parámetros</b><br>
///[database] Objeto Database sobre la cual se ejecutan las insercciones
void insertPreguntaSentimientoInitialDataAdolescencia(Database database) async {
  int grupoAdolescencia = 3;

  int id_P1 = await insertPreguntaSentimientoInitialData(
      database,
      'Cuando alguien esta alegre puede...',
      pathPersonaje + 'contenta.png',
      grupoAdolescencia);
  insertSituacionInitialData(
      database, "", 0, pathSentimientos + "gritar.png", id_P1);
  insertSituacionInitialData(
      database, "", 1, pathSentimientos + "reir.png", id_P1);
  insertSituacionInitialData(
      database, "", 0, pathSentimientos + "discutir.png", id_P1);
  insertSituacionInitialData(
      database, "", 1, pathSentimientos + "abrazo.png", id_P1);

  int id_P2 = await insertPreguntaSentimientoInitialData(
      database,
      '¿Qué puede hacer que nos sintamos tristes?',
      pathPersonaje + 'triste.png',
      grupoAdolescencia);
  insertSituacionInitialData(
      database, "", 1, pathSentimientos + "perder.png", id_P2);
  insertSituacionInitialData(
      database, "", 1, pathSentimientos + "perderBus.png", id_P2);
  insertSituacionInitialData(
      database, "", 0, pathSentimientos + "parque.png", id_P2);
  insertSituacionInitialData(
      database, "", 0, pathSentimientos + "cine.png", id_P2);
  insertSituacionInitialData(
      database, "", 0, pathSentimientos + "ganar.png", id_P2);

  int id_P3 = await insertPreguntaSentimientoInitialData(
      database,
      '¿Qué puede hacer que nos sintamos contentos?',
      pathPersonaje + 'contenta.png',
      grupoAdolescencia);
  insertSituacionInitialData(
      database, "", 0, pathSentimientos + "perder.png", id_P3);
  insertSituacionInitialData(
      database, "", 0, pathSentimientos + "perderBus.png", id_P3);
  insertSituacionInitialData(
      database, "", 1, pathSentimientos + "parque.png", id_P3);
  insertSituacionInitialData(
      database, "", 1, pathSentimientos + "cine.png", id_P3);
  insertSituacionInitialData(
      database, "", 1, pathSentimientos + "ganar.png", id_P3);

  int id_P4 = await insertPreguntaSentimientoInitialData(
      database,
      '¿Qué puede hacer que nos asustemos?',
      pathPersonaje + 'asustado.png',
      grupoAdolescencia);
  insertSituacionInitialData(
      database, "", 1, pathSentimientos + "fantasma.png", id_P4);
  insertSituacionInitialData(
      database, "", 0, pathSentimientos + "peluche.png", id_P4);
  insertSituacionInitialData(
      database, "", 1, pathSentimientos + "monstruo.png", id_P4);
  insertSituacionInitialData(
      database, "", 1, pathSentimientos + "serpiente.png", id_P4);

  int id_P5 = await insertPreguntaSentimientoInitialData(
      database,
      'Cuando alguien está enfadado puede...',
      pathPersonaje + 'enfadada.png',
      grupoAdolescencia);
  insertSituacionInitialData(
      database, "", 1, pathSentimientos + "gritar.png", id_P5);
  insertSituacionInitialData(
      database, "", 0, pathSentimientos + "reir.png", id_P5);
  insertSituacionInitialData(
      database, "", 1, pathSentimientos + "discutir.png", id_P5);
  insertSituacionInitialData(
      database, "", 0, pathSentimientos + "abrazo.png", id_P5);
}
