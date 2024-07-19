// PREGUNTAS SENTIMIENTOS PARA EL GRUPO DE INFANCIA
import 'package:sqflite/sqflite.dart';

import '../obj/preguntaSentimiento.dart';
import '../obj/situacion.dart';

String pathSentimientos = 'assets/img/sentimientos/';
String pathPersonaje = 'assets/img/personajes/';

void insertPreguntaSentimientoInitialDataInfancia(Database database) async {
  int grupoInfancia = 2;

  int id_P1 = await insertPreguntaSituacionInitialData(
      database,
      'Normalmente Jaime está contento cuando va a ir a...',
      pathPersonaje + 'contento.png',
      grupoInfancia);
  insertSituacionInitialData(
      database, "Fiesta", 1, pathSentimientos + "fiesta.png", id_P1);
  insertSituacionInitialData(
      database, "Cine", 1, pathSentimientos + "cine.png", id_P1);
  insertSituacionInitialData(
      database, "Parque", 1, pathSentimientos + "parque.png", id_P1);
  insertSituacionInitialData(
      database, "Dentista", 0, pathSentimientos + "dentista.png", id_P1);
  insertSituacionInitialData(
      database, "Hospital", 0, pathSentimientos + "hospital.png", id_P1);

  int id_P2 = await insertPreguntaSituacionInitialData(
      database,
      '¿Qué puede hacer que nos sintamos tristes?',
      pathPersonaje + 'triste.png',
      grupoInfancia);
  insertSituacionInitialData(database, "Perder una carrera", 1,
      pathSentimientos + "perder.png", id_P2);
  insertSituacionInitialData(database, "Perder el autobús", 1,
      pathSentimientos + "perderBus.png", id_P2);
  insertSituacionInitialData(
      database, "Ir al parque", 0, pathSentimientos + "parque.png", id_P2);
  insertSituacionInitialData(
      database, "Ir al cine", 0, pathSentimientos + "cine.png", id_P2);
  insertSituacionInitialData(
      database, "Ganar una carrera", 0, pathSentimientos + "ganar.png", id_P2);

  int id_P3 = await insertPreguntaSituacionInitialData(
      database,
      '¿Qué puede hacer que nos sintamos contentos?',
      pathPersonaje + 'contenta.png',
      grupoInfancia);
  insertSituacionInitialData(database, "Perder una carrera", 0,
      pathSentimientos + "perder.png", id_P3);
  insertSituacionInitialData(database, "Perder el autobús", 0,
      pathSentimientos + "perderBus.png", id_P3);
  insertSituacionInitialData(
      database, "Ir al parque", 1, pathSentimientos + "parque.png", id_P3);
  insertSituacionInitialData(
      database, "Ir al cine", 1, pathSentimientos + "cine.png", id_P3);
  insertSituacionInitialData(
      database, "Ganar una carrera", 1, pathSentimientos + "ganar.png", id_P3);

  int id_P4 = await insertPreguntaSituacionInitialData(
      database,
      '¿Qué puede hacer que nos asustemos?',
      pathPersonaje + 'asustado.png',
      grupoInfancia);
  insertSituacionInitialData(
      database, "Fantasma", 1, pathSentimientos + "fantasma.png", id_P4);
  insertSituacionInitialData(
      database, "Peluche", 0, pathSentimientos + "peluche.png", id_P4);
  insertSituacionInitialData(
      database, "Monstruo", 1, pathSentimientos + "monstruo.png", id_P4);
  insertSituacionInitialData(
      database, "Serpiente", 1, pathSentimientos + "serpiente.png", id_P4);

  int id_P5 = await insertPreguntaSituacionInitialData(
      database,
      'Cuando alguien está enfadado puede...',
      pathPersonaje + 'enfadada.png',
      grupoInfancia);
  insertSituacionInitialData(
      database, "Gritar", 1, pathSentimientos + "gritar.png", id_P5);
  insertSituacionInitialData(
      database, "Reír", 0, pathSentimientos + "reir.png", id_P5);
  insertSituacionInitialData(
      database, "Discutir", 1, pathSentimientos + "discutir.png", id_P5);
  insertSituacionInitialData(
      database, "Abrazar", 0, pathSentimientos + "abrazo.png", id_P5);

  int id_P6 = await insertPreguntaSituacionInitialData(
      database,
      'Cuando alguien esta alegre puede...',
      pathPersonaje + 'contenta.png',
      grupoInfancia);
  insertSituacionInitialData(
      database, "Gritar", 0, pathSentimientos + "gritar.png", id_P6);
  insertSituacionInitialData(
      database, "Reír", 1, pathSentimientos + "reir.png", id_P6);
  insertSituacionInitialData(
      database, "Discutir", 0, pathSentimientos + "discutir.png", id_P6);
  insertSituacionInitialData(
      database, "Abrazar", 1, pathSentimientos + "abrazo.png", id_P6);
}