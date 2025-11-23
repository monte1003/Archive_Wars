// ====================================================================
// CONFIGURACIÓN INICIAL DEL JUEGO
// ====================================================================

//   Variables para la pantalla de "Game Over"  

PImage imgIntro;
import processing.sound.*;
SoundFile musicaIntro;
int tiempoInicioIntro;
int duracionIntro = 12000;
int opacidadGameOver = 0;
int velocidadFade = 3;
int estadoIntro = 0;   
int delayTextoGameOver = 60; 
int contadorDelayGameOver = 0; 
long milisFinalizados = 0; 
int estadoJuego = 1; 
int seccionMenu = 1;
boolean juegoIniciado = false;

//   Variables de Dimensiones del Tablero (Grid)  
int filas = 5;
int columnas = 9;
int tCelda = 72;

//   Matrices del Tablero para las Tropas (Defensas)  
int[][] tipoTropa = new int[filas][columnas];
int[][] enfriamientoTropa = new int[filas][columnas];
int[][] vidaTropa = new int[filas][columnas];

//   Variables de Economía (Elixir) y Costos de Tropas  
int elixir = 0,
    elixirMax = 10,
    contadorElixirTick = 0,
    costoCortafuegos = 1,
    costoAntivirus = 2,
    costoCuarentena = 3;

//propiedades de las Tropas: Cooldown (cd), Rango y Daño
int cdCortafuegos = 8,
    cdAntivirus = 12,
    cdCuarentenaMin = 16,
    cdCuarentenaMax = 20;

int rangoCortafuegos = 4,
    rangoAntivirus = 999, // Ilimitado en la fila
    rangoCuarentena = 1; // 3x3 al frente

int danoCortafuegos = 1,
    danoAntivirus = 2,
    danoCuarentena = 3;

//Variables de los Enemigos
int maxEnemigos = 120;
int[] tipoEnemigo = new int[maxEnemigos];
int[] filaEnemigo = new int[maxEnemigos];
int[] colEnemigo  = new int[maxEnemigos];
int[] vidaEnemigo = new int[maxEnemigos];
int[] proximoMovimiento = new int[maxEnemigos];
boolean[] enemigoVivo = new boolean[maxEnemigos];

String[] nombreEnemigo = new String[maxEnemigos]; 
String nombreCriticoVirus = "VirusCritico.exe"; 

int vidaVirus = 5;
int vidaRansom = 8;
int vidaMalware =20;
int vidaOblivion = 65;

int pasoVirus = 1;
int pasoRansom = 2;
int pasoMalware = 3;
int pasoOblivion = 2;

int tic = 0;
int duracionTicMs = 700;
int ultimoMilis = 0;

int ola = 1;
boolean hayQueIniciarOla = true;
int porAparecer = 0;
int aparecidos = 0;
int enemigosVivos = 0;
int proximoAparecerTic = 0;
int cadaCuantosAparece = 3;

int tropaSeleccionada = 1;

PImage imgCortafuegos, imgAntivirus, imgCuarentena;
PImage imgVirus, imgRansomware, imgMalware, imgOblivion;
PImage fondo;

boolean perdiste = false, ganaste  = false;

java.util.Random random = new java.util.Random();
boolean ratonPresionadoAnterior = false, teclaPresionadaAnterior = false;

// ====================================================================
// MINIJUEGO DE MEMORIA (RECUPERAR SISTEMA)
// ====================================================================

int filasMem = 4;
int columnasMem = 5; 
int totalCartas = filasMem * columnasMem; 
int[] cartas = new int[totalCartas];
boolean[] volteadas = new boolean[totalCartas];
boolean[] encontradas = new boolean[totalCartas];
int cartaSel1 = -1;
int cartaSel2 = -1;
int tiempoMostrar = 0;
boolean esperando = false;
int intentos = 24;
boolean minijuegoGanado = false;
boolean minijuegoTerminado = false;
boolean mostrandoMinijuego = false;
int mem_anchoCarta = 92, mem_altoCarta = 110, mem_espacio = 12, mem_inicioY = 120;

void iniciarMinijuego() {
  for (int i = 0; i < totalCartas; i++) {
    cartas[i] = i / 2 + 1;
    volteadas[i] = false;
    encontradas[i] = false;
  }
  for (int i = totalCartas - 1; i > 0; i--) {
    int j = int(random.nextInt(i + 1));
    int tmp = cartas[i];
    cartas[i] = cartas[j];
    cartas[j] = tmp;
  }
  cartaSel1 = -1;
  cartaSel2 = -1;
  tiempoMostrar = 0;
  esperando = false;
  intentos = 24;
  minijuegoGanado = false;
  minijuegoTerminado = false;
  mostrandoMinijuego = true;
}

void dibujarMinijuego() {
  background(18, 40, 55);

  // === Escalado automático de las cartas según tamaño de pantalla ===
  float margenHorizontal = width * 0.08;   // 8% de margen lateral
  float margenSuperior = height * 0.15;    // margen superior para el título

  // Tamaño dinámico de carta según resolución
  mem_anchoCarta = int((width - 2 * margenHorizontal) / columnasMem * 0.9);
  mem_altoCarta = int((height - margenSuperior - 100) / filasMem * 0.8);
  mem_espacio = int(min(mem_anchoCarta, mem_altoCarta) * 0.1);
  mem_inicioY = int(margenSuperior + 60);

  // === Texto del encabezado ===
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(height / 25.0);
  text("MINIJUEGO: RECUPERAR SISTEMA", width / 2, height * 0.08);

  textSize(height / 45.0);
  text("Encuentra los 10 pares antes de agotar los 24 intentos", width / 2, height * 0.12);
  text("Intentos restantes: " + intentos, width / 2, height * 0.15);

  // === Calcular inicio centrado ===
  int gridWidth = columnasMem * mem_anchoCarta + (columnasMem - 1) * mem_espacio;
  int inicioX = (width - gridWidth) / 2;

  // === Dibujar cartas ===
  for (int fr = 0; fr < filasMem; fr++) {
    for (int c = 0; c < columnasMem; c++) {
      int idx = fr * columnasMem + c;
      int x = inicioX + c * (mem_anchoCarta + mem_espacio);
      int y = mem_inicioY + fr * (mem_altoCarta + mem_espacio);

      // Fondo según estado
      if (encontradas[idx]) fill(40, 180, 90);
      else if (volteadas[idx]) fill(245);
      else fill(70, 110, 200);
      rect(x, y, mem_anchoCarta, mem_altoCarta, 8);

      // Mostrar número si está volteada o encontrada
      if (volteadas[idx] || encontradas[idx]) {
        fill(0);
        textSize(min(mem_anchoCarta, mem_altoCarta) / 3);
        text(cartas[idx], x + mem_anchoCarta / 2, y + mem_altoCarta / 2 - 6);
      }
    }
  }

  // === Comportamiento (espera 1s para voltear o confirmar par) ===
  if (esperando && cartaSel1 != -1 && cartaSel2 != -1) {
    if (millis() - tiempoMostrar >= 1000) {
      if (cartas[cartaSel1] == cartas[cartaSel2]) {
        encontradas[cartaSel1] = true;
        encontradas[cartaSel2] = true;
      } else {
        volteadas[cartaSel1] = false;
        volteadas[cartaSel2] = false;
      }
      cartaSel1 = -1;
      cartaSel2 = -1;
      esperando = false;
    }
  }

  // === Verificar victoria o derrota ===
  boolean todasEncontradas = true;
  for (int i = 0; i < totalCartas; i++) {
    if (!encontradas[i]) {
      todasEncontradas = false;
      break;
    }
  }
  if (todasEncontradas) {
    minijuegoGanado = true;
    minijuegoTerminado = true;
    mostrandoMinijuego = false;
  }
  if (intentos <= 0 && !minijuegoGanado) {
    minijuegoTerminado = true;
    mostrandoMinijuego = false;
  }

  // === Pantalla final ===
  if (minijuegoTerminado) {
    fill(0, 170);
    rect(0, 0, width, height);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(height / 20.0);
    if (minijuegoGanado) {
      text("¡ÉXITO! Has recuperado parte del sistema.", width / 2, height / 2 - 30);
      textSize(height / 30.0);
      text("Haz clic para volver al Menú Principal", width / 2, height / 2 + 10);
    } else {
      text("No ha sido posible recuperar el sistema.", width / 2, height / 2 - 30);
      textSize(height / 30.0);
      text("Haz clic para volver al Game Over", width / 2, height / 2 + 10);
    }
  }
}

void procesarClickMinijuego() {
  if (minijuegoTerminado) {
    if (minijuegoGanado) {
      estadoJuego = 1; // volver al menú principal
    } else {
      estadoJuego = 3; // volver al Game Over
    }
    minijuegoTerminado = false;
    minijuegoGanado = false;
    mostrandoMinijuego = false;
    return;
  }

  if (!esperando) {
    int gridWidth = columnasMem * mem_anchoCarta + (columnasMem - 1) * mem_espacio;
    int inicioX = (width - gridWidth) / 2;
    for (int fr = 0; fr < filasMem; fr++) {
      for (int c = 0; c < columnasMem; c++) {
        int idx = fr * columnasMem + c;
        int x = inicioX + c * (mem_anchoCarta + mem_espacio);
        int y = mem_inicioY + fr * (mem_altoCarta + mem_espacio);
        if (mouseX > x && mouseX < x + mem_anchoCarta && mouseY > y && mouseY < y + mem_altoCarta) {
          if (!encontradas[idx] && !volteadas[idx]) {
            volteadas[idx] = true;
            if (cartaSel1 == -1) cartaSel1 = idx;
            else if (cartaSel2 == -1) {
              cartaSel2 = idx;
              intentos = intentos - 1;
              esperando = true;
              tiempoMostrar = millis();
            }
          }
        }
      }
    }
  }
}

// ====================================================================
// CONFIGURACIÓN DE LA VENTANA PRINCIPAL
// ====================================================================

void settings() {
  size(columnas*tCelda, filas*tCelda + 44);
}

// ====================================================================
// SETUP Y DRAW COMPLETOS DEL JUEGO PRINCIPAL
// ====================================================================

void setup() {
  imgIntro = loadImage("fondoinicio.png");   // Tu archivo JPG
musicaIntro = new SoundFile(this, "musicaintro.mp3");  // Tu archivo MP3
musicaIntro.play(); // Reproduce al inicio
tiempoInicioIntro = millis();
  imgCortafuegos = loadImage("firewall.png");
  imgAntivirus   = loadImage("antivirus.png");
  imgCuarentena  = loadImage("quarantine.png");
  imgVirus       = loadImage("virus.png");
  imgRansomware  = loadImage("ransomware.png");
  imgMalware     = loadImage("malware.png");
  imgOblivion    = loadImage("oblivion.png");
  fondo = loadImage("fondo.png");
  ultimoMilis = millis();
}

// ⚔️ draw() del juego (no modificado, salvo integración del minijuego al final)
void draw() {
  boolean clicRealizado = mousePressed && !ratonPresionadoAnterior;

if (estadoIntro == 0) {
  // Fondo con la imagen
  if (imgIntro != null) {
    image(imgIntro, 0, 0, width, height);
  } else {
    background(20);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(36);
    text("CIBERDEFENSA", width / 2, height / 2);
  }

  // Botón "Avanzar"
  float anchoBoton = width * 0.25;
  float altoBoton = height * 0.08;
  float xBoton = width / 2 - anchoBoton / 2;
  float yBoton = height * 0.8;

  // Efecto hover
  boolean sobreBoton = (mouseX > xBoton && mouseX < xBoton + anchoBoton && 
                        mouseY > yBoton && mouseY < yBoton + altoBoton);

  if (sobreBoton) {
    fill(100, 220, 255);
    cursor(HAND);
  } else {
    fill(60, 160, 220);
    cursor(ARROW);
  }

  rect(xBoton, yBoton, anchoBoton, altoBoton, 15);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(height / 25.0);
  text("AVANZAR", xBoton + anchoBoton / 2, yBoton + altoBoton / 2);

  // Si el usuario hace clic en el botón, pasar al menú
  if (mousePressed && mouseButton == LEFT) {
    if (sobreBoton) {
      if (musicaIntro != null) {
        musicaIntro.stop();
        musicaIntro = null;
      }
      System.gc(); // liberar memoria
      estadoIntro = 1; // pasar al menú principal
      delay(200); // evitar clics dobles
    }
  }

  return; // no continuar con el resto del draw()
}else if(estadoJuego == 1) {
    // === ESTADO 1: MENÚ PRINCIPAL ===

    // Calcula el tamaño base de la fuente y márgenes
    float factorEscalaFuente = height / 25.0;
    float margenX = width * 0.05;
    float alturaBase = height * 0.25;
    float anchoBoton = width * 0.3;
    float altoBoton = factorEscalaFuente * 1.5;
    float espacioEntreBotones = width * 0.05;

    float xBotonDefensa = width / 2 - anchoBoton - espacioEntreBotones / 2;
    float xBotonAmenaza = width / 2 + espacioEntreBotones / 2;

    // LÓGICA DE CLIC EN BOTONES
    if (clicRealizado) {
      // Detectar clic en botón de DEFENSA
      if (mouseX > xBotonDefensa && mouseX < xBotonDefensa + anchoBoton &&
        mouseY > alturaBase && mouseY < alturaBase + altoBoton) {
        seccionMenu = 1;
      }
      // Detectar clic en botón de AMENAZAS
      if (mouseX > xBotonAmenaza && mouseX < xBotonAmenaza + anchoBoton &&
        mouseY > alturaBase && mouseY < alturaBase + altoBoton) {
        seccionMenu = 2;
      }
    }

    // DIBUJO DEL MENÚ
    background(28);
    fill(255);

    // TÍTULO Y OBJETIVO
    textAlign(CENTER, CENTER);
    textSize(factorEscalaFuente * 1.5);
    text("CIBERDEFENSA: ¡PROTEGER LOS ARCHIVOS!", width / 2, height * 0.1);

    textAlign(CENTER, TOP);
    textSize(factorEscalaFuente * 0.8);
    fill(255, 255, 0);
    text("OBJETIVO: Impedir que cualquier virus llegue a la Columna 0 (Izquierda).", width / 2, height * 0.18);

    // BOTÓN DEFENSAS
    if (seccionMenu == 1) {
      fill(100, 200, 255);
    } else {
      fill(50, 100, 150);
    }
    rect(xBotonDefensa, alturaBase, anchoBoton, altoBoton, 5);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(factorEscalaFuente * 0.9);
    text("TROPAS DE DEFENSA", xBotonDefensa + anchoBoton / 2, alturaBase + altoBoton / 2);

    // BOTÓN AMENAZAS
    if (seccionMenu == 2) {
      fill(255, 100, 100);
    } else {
      fill(150, 50, 50);
    }
    rect(xBotonAmenaza, alturaBase, anchoBoton, altoBoton, 5);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(factorEscalaFuente * 0.9);
    text("AMENAZAS (VIRUS)", xBotonAmenaza + anchoBoton / 2, alturaBase + altoBoton / 2);

    // ZONA DE CONTENIDO DINÁMICO
    float posVertical = alturaBase + altoBoton + factorEscalaFuente * 1.5;
    textAlign(LEFT, TOP);
    textSize(factorEscalaFuente * 0.8);

    if (seccionMenu == 1) {
      // Muestra Defensas
      fill(100, 200, 255);
      text("Fuerzas de protección del sistema:", margenX, posVertical);

      posVertical += factorEscalaFuente * 1.5;
      text("• (1) Cortafuegos ($" + costoCortafuegos + "): Rango corto (r=" + rangoCortafuegos + "), Daño simple (d=" + danoCortafuegos + ").", margenX, posVertical);

      posVertical += factorEscalaFuente * 1.3;
      text("• (2) Antivirus ($" + costoAntivirus + "): Rango ilimitado en fila, Daño moderado (d=" + danoAntivirus + ").", margenX, posVertical);

      posVertical += factorEscalaFuente * 1.3;
      text("• (3) Cuarentena ($" + costoCuarentena + "): Ataque de área 3x3 al frente, Daño alto (d=" + danoCuarentena + ").", margenX, posVertical);

    } else if (seccionMenu == 2) {
      // Muestra Amenazas
      fill(255, 100, 100);
      text("Amenazas (Velocidad = Tics por paso):", margenX, posVertical);

      posVertical += factorEscalaFuente * 1.5;
      text("• Virus (Vida " + vidaVirus + ", Velocidad " + pasoVirus + ")", margenX, posVertical);

      posVertical += factorEscalaFuente * 1.3;
      text("• Ransomware (Vida " + vidaRansom + ", Velocidad " + pasoRansom + ")", margenX, posVertical);

      posVertical += factorEscalaFuente * 1.3;
      text("• Malware (Vida " + vidaMalware + ", Velocidad " + pasoMalware + ")", margenX, posVertical);

      posVertical += factorEscalaFuente * 1.3;
      text("• Oblivion (Vida " + vidaOblivion + ", Velocidad " + pasoOblivion + "): ¡Jefe de la Ola 4!", margenX, posVertical);
    }

    // LLAMADA A LA ACCIÓN
    fill(200, 255, 200);
    textAlign(CENTER, CENTER);
    textSize(factorEscalaFuente * 1.1);
    text("PRESIONA CUALQUIER TECLA PARA INICIAR LA DEFENSA", width / 2, height * 0.9);

    // Lógica de transición al juego
    if (keyPressed && !teclaPresionadaAnterior) {
      estadoJuego = 2;
      // Reinicio de variables de juego
      juegoIniciado = false;
      perdiste = false;
      ganaste = false;
      ola = 1;
      elixir = 0;
      tic = 0;
      contadorElixirTick = 0;
      hayQueIniciarOla = true;
      opacidadGameOver = 0;
      contadorDelayGameOver = 0;

      // Resetear matrices del Tablero
      for (int f = 0; f < filas; f++) {
        for (int c = 0; c < columnas; c++) {
          tipoTropa[f][c] = 0;
          enfriamientoTropa[f][c] = 0;
          vidaTropa[f][c] = 1;
        }
      }

      // Resetear el arreglo de Enemigos
      for (int i = 0; i < maxEnemigos; i++) {
        enemigoVivo[i] = false;
        vidaEnemigo[i] = 0;
      }
      enemigosVivos = 0;
    }

  } else if (estadoJuego == 2) {
    // === ESTADO 2: JUGANDO ===

    // Inicialización de tiempo
    if (!juegoIniciado) {
      ultimoMilis = millis();
      juegoIniciado = true;
    }

    // Lógica de Ticks
    int ahora = millis();
    if (ahora - ultimoMilis >= duracionTicMs) {
      ultimoMilis = ahora;
      tic = tic + 1;
      contadorElixirTick = contadorElixirTick + 1;
      if (contadorElixirTick >= 1) {
        contadorElixirTick = 0;
        if (elixir < elixirMax) {
          elixir = elixir + 1;
        }
      }
    }

    // Detección de pérdida
    if (perdiste) {
      estadoJuego = 3;
      opacidadGameOver = 0;
      contadorDelayGameOver = 0;
      milisFinalizados = 0; // Importante para el delay real en estado 3
      return;
    }

    // Lógica de Inicialización de Ola
    if (hayQueIniciarOla) {
      if (ola == 1) {
        porAparecer = 5;
      } else {
        if (ola == 2) {
          porAparecer = 9;
        } else {
          if (ola == 3) {
            porAparecer = 12;
          } else {
            porAparecer = 1;
          }
        }
      }
      aparecidos = 0;
      enemigosVivos = 0;
      proximoAparecerTic = tic + 1;
      cadaCuantosAparece = 3 + random.nextInt(2);
      hayQueIniciarOla = false;
    }

    if (!perdiste && !ganaste) {
      // Lógica de Aparición de Enemigos
      if (aparecidos < porAparecer) {
        if (tic >= proximoAparecerTic) {
          int idx = -1;
          for (int i = 0; i < maxEnemigos; i++) {
            if (!enemigoVivo[i]) {
              idx = i;
              break;
            }
          }
          if (idx != -1) {
            int tipo = 1;
            if (ola < 4) {
              int r = random.nextInt(3);
              if (r == 0) {
                tipo = 1;
              } else {
                if (r == 1) {
                  tipo = 2;
                } else {
                  tipo = 3;
                }
              }
            } else {
              tipo = 4;
            }
            int fila = random.nextInt(filas);
            tipoEnemigo[idx] = tipo;
            filaEnemigo[idx] = fila;
            colEnemigo[idx] = columnas - 1;
            enemigoVivo[idx] = true;
            int vidaBase = (tipo == 1) ? vidaVirus : (tipo == 2) ? vidaRansom : (tipo == 3) ? vidaMalware : vidaOblivion;
            int pasoBase = (tipo == 1) ? pasoVirus : (tipo == 2) ? pasoRansom : (tipo == 3) ? pasoMalware : pasoOblivion;

            vidaEnemigo[idx] = vidaBase;
            proximoMovimiento[idx] = tic + pasoBase;

            // Si aparece un enemigo en una celda con tropa, la elimina
            if (tipoTropa[filaEnemigo[idx]][colEnemigo[idx]] != 0) {
              tipoTropa[filaEnemigo[idx]][colEnemigo[idx]] = 0;
              enfriamientoTropa[filaEnemigo[idx]][colEnemigo[idx]] = 0;
              vidaTropa[filaEnemigo[idx]][colEnemigo[idx]] = 0;
            }
            aparecidos = aparecidos + 1;
            enemigosVivos = enemigosVivos + 1;
            proximoAparecerTic = tic + cadaCuantosAparece;
          }
        }
      }

      // Lógica de Movimiento de Enemigos
      for (int i = 0; i < maxEnemigos; i++) {
        if (enemigoVivo[i]) {
          if (tic >= proximoMovimiento[i]) {
            int nuevaCol = colEnemigo[i] - 1;
            if (nuevaCol < 0) {
              // Enemigo llegó a la columna 0
              perdiste = true;
              break;
            } else {
              // Si el enemigo se mueve a una celda con tropa, la elimina
              if (tipoTropa[filaEnemigo[i]][nuevaCol] != 0) {
                tipoTropa[filaEnemigo[i]][nuevaCol] = 0;
                enfriamientoTropa[filaEnemigo[i]][nuevaCol] = 0;
                vidaTropa[filaEnemigo[i]][nuevaCol] = 0;
              }
              colEnemigo[i] = nuevaCol;
              int tipo = tipoEnemigo[i];
              int paso = (tipo == 1) ? pasoVirus : (tipo == 2) ? pasoRansom : (tipo == 3) ? pasoMalware : pasoOblivion;
              proximoMovimiento[i] = tic + paso;
            }
          }
          // Eliminación del enemigo si vida <= 0
          if (vidaEnemigo[i] <= 0) {
            enemigoVivo[i] = false;
            enemigosVivos = enemigosVivos - 1;
          }
        }
      }

      // Lógica de Ataque de Tropas
      for (int f = 0; f < filas; f++) {
        for (int c = 0; c < columnas; c++) {
          int t = tipoTropa[f][c];
          if (t != 0) {
            if (enfriamientoTropa[f][c] > 0) {
              enfriamientoTropa[f][c] = enfriamientoTropa[f][c] - 1;
            } else {
              if (t == 1) { // Cortafuegos
                int mejor = -1;
                int mejorDist = 9999;
                for (int i = 0; i < maxEnemigos; i++) {
                  if (enemigoVivo[i] && filaEnemigo[i] == f) {
                    int d = colEnemigo[i] - c;
                    if (d > 0 && d <= rangoCortafuegos && d < mejorDist) {
                      mejorDist = d;
                      mejor = i;
                    }
                  }
                }
                if (mejor != -1) {
                  vidaEnemigo[mejor] = vidaEnemigo[mejor] - danoCortafuegos;
                }
                enfriamientoTropa[f][c] = cdCortafuegos;
              } else if (t == 2) { // Antivirus
                int mejor = -1;
                int mejorDist = 999999;
                for (int i = 0; i < maxEnemigos; i++) {
                  if (enemigoVivo[i] && filaEnemigo[i] == f) {
                    int d = colEnemigo[i] - c;
                    if (d > 0 && d < mejorDist) {
                      mejorDist = d;
                      mejor = i;
                    }
                  }
                }
                if (mejor != -1) {
                  vidaEnemigo[mejor] = vidaEnemigo[mejor] - danoAntivirus;
                }
                enfriamientoTropa[f][c] = cdAntivirus;
              } else { // Cuarentena
                int frente = c + 1;
                // Ataque de área 3x3
                for (int ff = f - rangoCuarentena; ff <= f + rangoCuarentena; ff++) {
                  for (int cc = frente - rangoCuarentena; cc <= frente + rangoCuarentena; cc++) {
                    if (ff >= 0 && ff < filas && cc >= 0 && cc < columnas) {
                      for (int i = 0; i < maxEnemigos; i++) {
                        if (enemigoVivo[i] && filaEnemigo[i] == ff && colEnemigo[i] == cc) {
                          vidaEnemigo[i] = vidaEnemigo[i] - danoCuarentena;
                        }
                      }
                    }
                  }
                }
                // Cooldown aleatorio de Cuarentena
                int delta = random.nextInt(cdCuarentenaMax - cdCuarentenaMin + 1);
                enfriamientoTropa[f][c] = cdCuarentenaMin + delta;
              }
            }
          }
        }
      }

      // Lógica de Selección de Tropa
      if (keyPressed && !teclaPresionadaAnterior) {
        if (key == '1') {
          tropaSeleccionada = 1;
        } else if (key == '2') {
          tropaSeleccionada = 2;
        } else if (key == '3') {
          tropaSeleccionada = 3;
        }
      }

      // Lógica de Colocación de Tropas
      if (clicRealizado) {
        int c = mouseX / tCelda;
        int f = mouseY / tCelda;

        if (f >= 0 && f < filas && c >= 0 && c < columnas && tipoTropa[f][c] == 0) {
          int costo = (tropaSeleccionada == 1) ? costoCortafuegos : (tropaSeleccionada == 2) ? costoAntivirus : costoCuarentena;
          
          if (elixir >= costo) {
            tipoTropa[f][c] = tropaSeleccionada;
            enfriamientoTropa[f][c] = 0;
            vidaTropa[f][c] = 1;
            elixir = elixir - costo;
          }
        }
      }

      // Lógica de Avance de Ola / Victoria
      if (aparecidos == porAparecer && enemigosVivos == 0) {
        if (ola < 4) {
          ola = ola + 1;
          hayQueIniciarOla = true;
        } else {
          ganaste = true;
        }
      }
    }

    // Parte gráfica del juego
    background(28);
    stroke(60);

    // Dibuja la cuadrícula y las tropas
    for (int f = 0; f < filas; f++) {
      for (int c = 0; c < columnas; c++) {
        fill((f % 2 == 0) ? 42 : 50);
        rect(c * tCelda, f * tCelda, tCelda, tCelda);

        int t = tipoTropa[f][c];
        PImage img = (t == 1) ? imgCortafuegos : (t == 2) ? imgAntivirus : (t == 3) ? imgCuarentena : null;
        
        if (img != null) {
          image(img, c * tCelda, f * tCelda, tCelda, tCelda);
        } else if (t != 0) {
          fill((t == 1) ? color(255, 140, 0) : (t == 2) ? color(0, 200, 255) : color(180, 255, 0));
          rect(c * tCelda + 8, f * tCelda + 8, tCelda - 16, tCelda - 16);
        }
      }
    }

    // Dibuja los enemigos y sus barras de vida
    for (int i = 0; i < maxEnemigos; i++) {
      if (enemigoVivo[i]) {
        int x = colEnemigo[i] * tCelda;
        int y = filaEnemigo[i] * tCelda;
        int tipo = tipoEnemigo[i];
        
        PImage img = (tipo == 1) ? imgVirus : (tipo == 2) ? imgRansomware : (tipo == 3) ? imgMalware : imgOblivion;
        
        if (img != null) {
          image(img, x, y, tCelda, tCelda);
        } else {
          fill((tipo == 1) ? color(255, 0, 0) : (tipo == 2) ? color(255, 120, 0) : (tipo == 3) ? color(180, 0, 180) : color(0));
          rect(x + 8, y + 8, tCelda - 16, tCelda - 16);
        }
        
        // Dibuja la barra de vida
        fill(200, 0, 0);
        rect(x + 8, y + tCelda - 10, tCelda - 16, 6);
        
        float vidaMax = (tipo == 1) ? vidaVirus : (tipo == 2) ? vidaRansom : (tipo == 3) ? vidaMalware : vidaOblivion;
        float fraccion = max(0, min(1, vidaEnemigo[i] / vidaMax));

        fill(0, 200, 0);
        rect(x + 8, y + tCelda - 10, (tCelda - 16) * fraccion, 6);
      }
    }

    // Dibuja el HUD
    fill(255);
    textAlign(LEFT, TOP);
    textSize(15);
    String nombreTropa = (tropaSeleccionada == 1) ? "Cortafuegos" : (tropaSeleccionada == 2) ? "Antivirus" : "Cuarentena";

    text("Ola: " + ola + "   Tic: " + tic, 8, filas * tCelda + 6);
    text("Elixir: " + elixir + "/" + elixirMax + "   Tropa: " + nombreTropa + " (1/2/3)", 160, filas * tCelda + 6);

    // Comprobación de Victoria
    if (ganaste) {
      fill(80, 255, 120);
      textAlign(CENTER, CENTER);
      textSize(22);
      text("¡Archivos protegidos! ¡Victoria!", width / 2, height / 2);
    }

  } else if (estadoJuego == 3) {
    // === ESTADO 3: GAME OVER ===

    background(0);

    // Efecto fade a negro
    opacidadGameOver = min(opacidadGameOver + velocidadFade, 255);
    fill(0, opacidadGameOver);
    rect(0, 0, width, height);

    // Lógica de delay para el texto
    if (opacidadGameOver == 255 && milisFinalizados == 0) {
      milisFinalizados = millis();
    }

    // Muestra texto y botón después del delay de 500ms
    if (opacidadGameOver == 255 && millis() >= milisFinalizados + 500) {
      fill(255);
      textAlign(CENTER, CENTER);
      textSize(40);
      text("¡HAS SIDO DESTRUIDO!", width / 2, height / 2 - 50);

      textSize(20);
      text("La seguridad del sistema ha sido comprometida.", width / 2, height / 2 + 10);

      // Botón de Reinicio
      float botonAncho = 200;
      float botonAlto = 50;
      float botonX = width / 2 - botonAncho / 2;
      float botonY = height / 2 + 80;

      fill(50, 150, 200);
      rect(botonX, botonY, botonAncho, botonAlto, 10);
      fill(255);
      textSize(18);
      text("Volver al Menú Principal", botonX + botonAncho / 2, botonY + botonAlto / 2);

      // NUEVO: Botón para intentar recuperar con minijuego
      float botonAncho2 = 300;
      float botonAlto2 = 50;
      float botonX2 = width / 2 - botonAncho2 / 2;
      float botonY2 = botonY + botonAlto + 18;

      fill(200, 80, 80);
      rect(botonX2, botonY2, botonAncho2, botonAlto2, 10);
      fill(255);
      textSize(18);
      text("Intentar recuperar el sistema (Minijuego)", botonX2 + botonAncho2 / 2, botonY2 + botonAlto2 / 2);

      // Lógica para el clic en el botón de reinicio
      if (clicRealizado) {
        if (mouseX > botonX && mouseX < botonX + botonAncho &&
          mouseY > botonY && mouseY < botonY + botonAlto) {

          // Reinicio de Variables
          estadoJuego = 1;
          milisFinalizados = 0;
          juegoIniciado = false;
          perdiste = false;
          ganaste = false;
          ola = 1;
          elixir = 0;
          tic = 0;
          contadorElixirTick = 0;
          hayQueIniciarOla = true;
          opacidadGameOver = 0;
          contadorDelayGameOver = 0;

          // Resetear matrices del Tablero
          for (int f = 0; f < filas; f++) {
            for (int c = 0; c < columnas; c++) {
              tipoTropa[f][c] = 0;
              enfriamientoTropa[f][c] = 0;
              vidaTropa[f][c] = 1;
            }
          }

          // Resetear el arreglo de Enemigos
          for (int i = 0; i < maxEnemigos; i++) {
            enemigoVivo[i] = false;
            vidaEnemigo[i] = 0;
          }
          enemigosVivos = 0;
        }

        // Clic en el botón de intentar recuperar
        if (mouseX > botonX2 && mouseX < botonX2 + botonAncho2 &&
          mouseY > botonY2 && mouseY < botonY2 + botonAlto2) {
          // Iniciar minijuego (opcional) - estado 4
          iniciarMinijuego();
          estadoJuego = 4;
        }
      }
    }
  }

  if (estadoJuego == 4) {
    dibujarMinijuego();
    if (clicRealizado) procesarClickMinijuego();
  }

  ratonPresionadoAnterior = mousePressed;
  teclaPresionadaAnterior = keyPressed;
}
