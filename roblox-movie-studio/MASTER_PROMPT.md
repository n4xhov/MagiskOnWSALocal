# MASTER PROMPT — "Roblox Movie Studio: Escuela" (mapa para grabar Shorts virales)

> **Para ti, antes de pegar el prompt.** Lee esta parte una sola vez. El prompt de verdad empieza en la línea `COPIAR DESDE AQUÍ`.

## Preparación en tu PC (10–15 min)

1. **Carpeta del proyecto:** `C:\Users\ignac\Desktop\robloxmovie\` (dentro ya está `referencias\` con tus videos).
2. **Roblox Studio + MCP oficial**
   - En Studio: abre (o crea) un place → **Assistant → Settings → MCP Servers → activa "Enable Studio as MCP server"**.
   - En Claude Code: `/plugin` → busca **Roblox Studio** → instalar. Verifica con `/mcp` (sale `plugin:roblox-studio:windows`; que el de macOS falle es normal).
   - En Codex CLI (para que Codex también pueda leer Studio si hace falta): `codex plugin marketplace add Roblox/roblox-studio-agent-plugin`.
3. **Codex dentro de Claude Code** (plugin oficial de OpenAI):
   ```
   /plugin marketplace add openai/codex-plugin-cc
   /plugin install codex@openai-codex
   /reload-plugins
   /codex:setup
   ```
   En `~/.codex/config.toml` deja tu modelo y esfuerzo por defecto, por ejemplo:
   ```toml
   model = "gpt-6.1-codex"          # usa el ID exacto que te muestre Codex
   model_reasoning_effort = "high"
   ```
4. **Análisis de video:** que tu skill `/watch` funcione y que `agy` (Antigravity CLI) tenga sesión iniciada con Gemini 3.8 Pro.
5. **Herramientas:** Python 3.11+, `ffmpeg` en el PATH y OBS Studio para grabar. Rojo (vía Rokit) es opcional, porque el prompt lo instala si falta.
6. **Publica el place en privado** (File → Publish to Roblox) y activa **Game Settings → Security → Enable Studio Access to API Services**. Así se pueden guardar escenas y personajes con DataStore.
7. Abre Claude Code **en la carpeta `robloxmovie`**, con **Opus 5.5 en ultracode / esfuerzo máximo**, y pega todo lo que hay debajo de la línea.

---
---

# ======== COPIAR DESDE AQUÍ ========

<config>
CARPETA_PROYECTO   = C:\Users\ignac\Desktop\robloxmovie
CARPETA_REFERENCIAS= C:\Users\ignac\Desktop\robloxmovie\referencias
IDIOMA_UI          = español (Chile/LatAm, tono simple)
FORMATO_VIDEO      = vertical 9:16 (1080×1920) — Shorts / TikTok / Reels
ESCENARIO_V1       = Escuela  (el sistema debe aceptar más escenarios después: playa, casa, ciudad…)
MAX_ACTORES_ESCENA = 8

MODELO_DIRECTOR    = Claude Opus 5.5 (tú) — ultracode / esfuerzo máximo
MODELO_CODEX       = GPT 6.1 Codex — razonamiento ALTO — tareas acotadas y mecánicas
MODELO_VIDEO       = Gemini 3.8 Pro vía `agy` + skill `/watch` — solo análisis de videos
MODELO_CARAS       = GPT 6.1 Sol — esfuerzo/calidad BAJO — solo imágenes de caras y emociones
</config>

## 1. Tu rol y la misión

Eres el **director técnico y arquitecto** de un proyecto de Roblox Studio. Vas a construir un **set de filmación dentro de Roblox** para que una persona sin conocimientos técnicos grabe **videos cortos virales en vertical** de forma rápida.

El resultado final es un place de Roblox donde, al darle **Play**, aparece un **Panel Director** (en el juego) que permite, en pocos clics:

1. **Elegir el escenario** (v1: Escuela, con varias locaciones) y la iluminación.
2. **Elegir qué personajes salen en la escena** y dónde se paran.
3. **Cambiarles la cara o emoción** (caras 2D generadas con IA, en el estilo de los videos de referencia).
4. **Ponerles animaciones** (gestos, bailes, reacciones, acciones de escuela).
5. **Elegir cámara y efectos** (encuadres para 9:16, zoom de impacto, temblor, cámara lenta…).
6. **Armar una secuencia de tomas** y avanzarla con una tecla mientras se graba.
7. **Activar el modo grabación**, que oculta toda la interfaz para que la toma salga limpia.
8. **Crear personajes nuevos** con un creador integrado.

**Prueba de aceptación principal:** una persona nueva abre el place y, en **menos de 60 segundos**, elige locación → pone 2 personajes → les asigna emoción y animación → elige cámara → pulsa la tecla de grabación y obtiene una toma limpia en 9:16. **Sin leer el manual.**

## 2. Equipo de modelos y reglas de delegación

Tú orquestas. Delegas lo mecánico para ahorrar tiempo y contexto, y **revisas todo lo que vuelve** antes de integrarlo.

| Modelo | Úsalo para | No lo uses para |
|---|---|---|
| **Tú (Opus 5.5)** | Arquitectura y contratos entre módulos, UX del panel, síntesis de la biblia de personajes, selección y auditoría de seguridad de assets, todo cambio en Studio vía MCP, integración, depuración, QA final y decidir cuándo preguntar al usuario | Escribir a mano código repetitivo que Codex puede hacer con una buena especificación |
| **GPT 6.1 Codex (alto)** | Módulos Luau aislados con especificación cerrada (cámaras, tweens, componentes de UI, registros de datos, serialización JSON, lip-flap, subtítulos), scripts Python (extracción de frames, subida de imágenes, pintado de plantillas de ropa), tests, lint/formato y refactors mecánicos | Decisiones de diseño, tocar Studio por MCP o archivos fuera de los que le asignes |
| **Gemini 3.8 Pro (`/watch` + `agy`)** | Analizar los videos de `referencias\` (personajes, caras, gestos, cámara, ritmo, textos y sonido) | Escribir código |
| **GPT 6.1 Sol (bajo)** | Generar las caras PNG de cada personaje y emoción | Cualquier otra cosa |

**Cómo delegar a Codex**
- Vía plugin: lanza el subagente `codex:codex-rescue` (o el comando `/codex:rescue`) con la plantilla **TAREA CODEX** de la sección 10. Usa `/codex:status` y `/codex:result` para seguirlo.
- Alternativa: `codex exec` por Bash con el modelo y `model_reasoning_effort="high"`. Revisa antes `codex exec --help`, porque los flags pueden cambiar.
- Puedes lanzar **varias tareas Codex en paralelo** solo si tocan **archivos distintos**.
- **Solo tú escribes en Studio por MCP.** Codex trabaja en archivos (`src/`, `herramientas/`) y Rojo los sincroniza. Así nunca hay dos agentes editando el mismo place.
- Al recibir un resultado de Codex: lee el diff, ejecuta lint y tests, pruébalo en Play y recién entonces márcalo como integrado. Si falla dos veces, hazlo tú.

**Nombres de modelos:** usa los IDs exactos que existan en este PC. Si alguno de los nombres de `<config>` no responde, **pregunta** antes de cambiar a otro modelo. No cambies de modelo en silencio.

## 3. Reglas de trabajo (siempre)

1. **Memoria del proyecto:** mantén `docs/PROGRESO.md` (fase actual, hecho, pendiente, bloqueos) y `docs/DECISIONES.md` (decisión, motivo y fecha). Actualízalos al cerrar cada fase. Si se reinicia el contexto, léelos primero.
2. **Preguntas:** pregunta solo lo que bloquea o lo que el usuario debe decidir. Junta las preguntas en un solo mensaje, con opciones y tu recomendación. Lo demás, decídelo tú y anótalo en `DECISIONES.md`.
3. **Puntos de parada (STOP):** en las fases marcadas con STOP, **muestra resultados y espera aprobación**. Entre un STOP y el siguiente, trabaja de forma autónoma.
4. **No inventes IDs de assets.** Todo ID (mapa, accesorio, animación, imagen o sonido) debe salir de `search_asset`, del script `Animate` por defecto, de una subida tuya o del usuario, y **debe verificarse cargándolo** en Play.
5. **Guarda antes de cambios grandes** (File → Save / Publish). El MCP edita el place directamente y no todo se puede deshacer.
6. **Calidad de código:** Luau con `--!strict` donde se pueda, StyLua + Selene sin errores, nombres en inglés y textos de UI en español. Prohibido `loadstring`, `getfenv`/`setfenv` y `require(<número>)`.
7. **Verificación en cada fase:** `start_stop_play` → `get_console_output` sin errores rojos → `screen_capture` en 9:16 de lo que construiste. Guarda las capturas en `docs/capturas/<fase>/`.
8. **Simple antes que perfecto:** primero una versión que funcione de punta a punta y después se pule.

## 4. Lo que ya está investigado (octubre 2026; verifícalo, pero no lo repitas desde cero)

- **MCP oficial de Studio** (plugin `Roblox/roblox-studio-agent-plugin`). Herramientas de lectura: `list_roblox_studios`, `get_studio_state`, `get_console_output`, `script_read`, `script_search`, `script_grep`, `search_game_tree`, `inspect_instance`, `screen_capture`, `search_asset`, `store_image`, `wait_job_finished`. Herramientas de cambio: `execute_luau`, `multi_edit`, `insert_asset`, `upload_image`, `generate_mesh`, `generate_material`, `generate_procedural_model`, `generate_texture`, `segment_mesh`, `start_stop_play`, `character_navigation`, `user_keyboard_input`, `user_mouse_input`. Confirma la lista real con `tools/list`, porque los nombres cambian entre versiones.
- **Permisos de animaciones (desde 2025):** las animaciones son "Restricted". Una experiencia solo carga animaciones propias, de Roblox o con permiso concedido a esa experiencia (Creator Hub → permisos de la experiencia; también se pueden compartir con conexiones y grupos). Las de otros creadores en la Creator Store **suelen fallar** ("failed to load animation"). **Prueba cada una.**
- **Animation Capture:** el Animation Editor puede crear una animación R15 a partir de un video `.mp4`/`.mov` de **menos de 15 s**, con **una sola persona** bien iluminada, cuerpo completo, una toma continua y la cámara quieta. Es ideal para copiar gestos de las referencias: el usuario se graba imitándolos.
- **Caras:** `HumanoidDescription.Face` solo acepta assets de tipo *Face*, no Decal ni Image. Para caras personalizadas hay que cambiar el **Decal `face` de la Head** (Texture = `rbxassetid://<ImageId>`) y usar una **cabeza clásica**, no dinámica/FACS, porque en esas el decal no se ve bien.
- **Rigs de NPC:** `Players:CreateHumanoidModelFromDescriptionAsync(desc, Enum.HumanoidRigType.R15)` (solo en servidor). Los accesorios del catálogo funcionan por ID en `HumanoidDescription`.
- **Subida de imágenes:** preferir `upload_image` del MCP. Alternativa: Open Cloud Assets API (header `x-api-key`, tipo Decal, PNG < 8000×8000). **Ojo:** el ID del *Decal* no es el ID de la *Image*; resuelve y guarda el ID de **Image**. Las imágenes pasan por moderación y pueden tardar.
- **Mapas de escuela:** en la búsqueda web casi no aparecieron mapas **gratis** completos y recientes. Lo gratuito suele ser viejo o incompleto (por ejemplo, "ROBLOX High School MAP!", asset 482488108, de 2016). Hay mapas **de pago** en BuiltByBit y Payhip (aprox. 4–20 USD). Estrategia: buscar con `search_asset` por **habitación o prop** y combinar lo mejor; los props que falten se generan con `generate_procedural_model` / `generate_mesh`. Un mapa de pago solo se usa con aprobación del usuario. **Nunca** mapas filtrados o robados.
- **Seguridad de free models:** pueden traer backdoors. Inserta en cuarentena, elimina todos los scripts que no sean necesarios y usa sandboxing (Script Capabilities) si alguno debe quedarse. El escaneo por palabras clave sirve como filtro inicial, pero cada hallazgo se revisa a mano.
- **9:16 en Studio:** el Device Simulator acepta dispositivos personalizados de **1080×1920**. Grabar con OBS (captura de ventana recortada al viewport, lienzo 1080×1920).
- **DataStore en Studio:** requiere el place publicado y "Enable Studio Access to API Services".

## 5. Arquitectura objetivo

### 5.1 Carpetas en el PC
```
robloxmovie/
  referencias/                 ← entrada (no modificar). Frames extraídos en referencias/_frames/
  docs/                        ← BIBLIA_PERSONAJES.md, GUIA_ESTILO.md, INVESTIGACION_ASSETS.md,
                                 PROGRESO.md, DECISIONES.md, MANUAL.md, GUIA_GRABACION.md, capturas/
  arte/caras/<personaje>/<emocion>[_hablando].png
  arte/caras/caras_ids.json    ← personaje → emoción → ImageId
  arte/ropa/                   ← plantillas de Shirt y Pants
  herramientas/                ← scripts Python (frames, caras, subida, ropa)
  src/                         ← código Luau sincronizado con Rojo
    shared/Config/             ← Escenarios, Personajes, Emociones, Animaciones, Camaras, Efectos, Sonidos, Catalogo
    server/DirectorService/    ← estado de la escena, actores, caras, animaciones, persistencia
    client/DirectorUI/         ← panel, cámara, modo grabación, atajos
  default.project.json
```
Si Rojo no se puede instalar, trabaja solo con MCP, pero **igual guarda una copia del código en `src/`**.

### 5.2 Modelo cliente/servidor
- **Servidor (`DirectorService`):** dueño del estado de la escena. Carga y descarga locaciones, crea y quita actores, cambia caras, reproduce animaciones (cargadas en el `Animator` del servidor para que se repliquen) y guarda/carga en DataStore. Recibe comandos por **RemoteEvents/RemoteFunctions con validación de argumentos**.
- **Cliente (`DirectorUI`):** panel, cámara (`Scriptable` + tweens), efectos de post-proceso, subtítulos, modo grabación y atajos. Nunca modifica actores directamente: le pide los cambios al servidor.
- **Estado como datos:** una escena es un JSON serializable (locación, luz, actores con posición/emoción/animación, cámara y beats). Así se guarda, carga, exporta e importa igual.
- `StreamingEnabled = false` (set chico, sin pop-in al grabar). Iluminación `Future`.

## 6. Fases

### FASE 0 — Preparación y análisis de referencias → **STOP**
1. Comprueba las herramientas: MCP de Studio conectado (`list_roblox_studios`), plugin de Codex, `/watch` + `agy`, Python, `ffmpeg` y Rojo. Informa lo que falte con instrucciones de 1–2 líneas para instalarlo.
2. Lista los archivos de `referencias\`. Analiza **cada video** con `/watch` (Gemini 3.8 Pro vía `agy`) usando el **PROMPT DE ANÁLISIS** de la sección 10. Guarda un JSON por video en `docs/analisis/<video>.json`. Si `/watch` no existe, usa `agy` directamente o el comando de media del plugin de Antigravity, y anota cuál usaste.
3. Con `ffmpeg`, extrae en los timestamps que indique el análisis los **mejores frames de frente** de cada personaje (`referencias/_frames/<personaje>_<n>.png`). **Míralos tú** para confirmar el análisis.
4. Escribe `docs/BIBLIA_PERSONAJES.md` con una ficha por personaje. Cada ficha incluye: nombre provisional, rol (alumno, profesor, director…), personalidad, proporciones R15 (escalas), color de piel (hex), pelo (estilo, color hex y términos de búsqueda en el catálogo), ropa (arriba, abajo y zapatos, con colores hex y patrón), accesorios, **rasgos de la cara** (forma de ojos y pupilas, cejas, boca, grosor y color de línea, rubor y detalles), emociones típicas, gestos típicos, frases típicas y frames de referencia.
5. Escribe `docs/GUIA_ESTILO.md`: paleta, iluminación, encuadres frecuentes, ritmo (cortes por segundo, duración), estilo de subtítulos (fuente, color, borde, posición), efectos y sonidos recurrentes, estructura de los videos (gancho de 0 a 2 s, desarrollo, remate) y **por qué funcionan**.
6. **Inspírate, no copies:** recrea el estilo y los arquetipos, pero sin logos, marcas ni personajes con copyright exactos.
7. **STOP:** muestra un resumen con la lista de personajes y sus frames, las 5 claves de estilo y tus dudas. Espera aprobación.

### FASE 1 — Esqueleto del proyecto
- Configura Rojo, `default.project.json`, StyLua, Selene y la estructura de 5.1. Agrega los módulos `Config` vacíos con sus **tipos Luau** (los contratos de la sección 7) y los RemoteEvents.
- Haz un "hola mundo" en Play: aparece un panel vacío con pestañas y **una tecla lo oculta y lo muestra**.
- Delega en Codex lo mecánico (configs de lint, tipos y stubs) con especificación cerrada.

### FASE 2 — Escenario Escuela → **STOP** (elección de assets)
Locaciones de la v1: **Salón de clases, Pasillo con casilleros, Cafetería, Baño, Patio o entrada, Oficina del director**. El gimnasio es opcional si aparece algo bueno.

1. **Busca** con `search_asset`, en inglés y español: `school`, `high school`, `classroom`, `school hallway`, `lockers`, `cafeteria`, `school bathroom`, `principal office`, `school desk`, `chalkboard`, `school gym`, `anime school`, `japanese school`, `escuela`, `salón de clases`. Busca también props sueltos (pupitres, pizarra, casilleros, bandejas, lavamanos).
2. **Puntúa** cada candidato de 0 a 5 en estos criterios y regístralo en `docs/INVESTIGACION_ASSETS.md`:
   - parecido con el estilo de las referencias;
   - calidad en primer plano vertical;
   - completitud;
   - rendimiento (partes y triángulos);
   - cantidad de scripts (ideal: 0);
   - escala compatible con R15;
   - reputación (likes, usos, creador);
   - qué tan reciente es.
3. Inserta los **3 mejores por locación** en una zona de **cuarentena** (lejos del origen). Aplica la sección 8 de seguridad y saca 2 capturas en 9:16 de cada uno.
4. **STOP:** presenta una tabla por locación con las capturas, el puntaje y tu recomendación. Si lo gratuito es pobre, propón alternativas: combinar piezas, generar props o, solo como opción, un mapa de pago con su precio.
5. Con lo elegido, arma cada locación como un **Escenario** según el contrato 7.1. Agrega Marcas para actores, Cámaras predefinidas, presets de luz (**Mañana, Tarde dorada, Noche/terror, Drama**) y sonido ambiente (timbre, murmullo, eco de pasillo).
6. Captura cada locación como miniatura (`screen_capture` + `upload_image`) para el panel. Si no se puede, usa un emoji y el nombre.

### FASE 3 — Personajes y caras → **STOP** (prueba de estilo)
1. Recrea cada personaje de la biblia con `HumanoidDescription`: colores de cuerpo, escalas, accesorios del catálogo (pelo, lentes, gorros vía `search_asset`, verificando que carguen) y ropa clásica.
   - **Ropa:** Codex escribe `herramientas/ropa/pintar_plantilla.py`, que pinta plantillas Shirt/Pants (585×559) con colores y patrones por zona. Se suben como imagen y se usa su ImageId en `ShirtTemplate`/`PantsTemplate`.
   - Asegura una **cabeza clásica** con Decal `face`.
2. **Prueba de estilo de caras:** genera con **MODELO_CARAS (bajo)** solo **1 personaje × 3 emociones** (neutral, feliz y shock) usando la **PLANTILLA DE CARA** (sección 10) y sus frames de referencia. Súbelas, aplícalas y captura primer plano y plano medio.
3. **STOP:** el usuario aprueba o corrige el estilo de cara.
4. Genera el set completo: todas las emociones de 7.3 para cada personaje, más la variante `_hablando` (boca abierta) en las que tienen la boca cerrada.
   - **Consistencia:** usa siempre la cara *neutral aprobada* del personaje como referencia de entrada.
   - **QA automático:** fondo transparente (alfa 0 en las esquinas), tamaño correcto, rasgos centrados. Además, revisa visualmente la identidad contra la neutral. Si una cara falla 2 veces, repórtala; **no subas el esfuerzo ni cambies de modelo sin preguntar**.
5. Sube las caras (pipeline `herramientas/caras/` hecho por Codex: generar → QA → subir → escribir `caras_ids.json` → generar `src/shared/Config/Caras.luau`). En el cliente, precárgalas con `ContentProvider:PreloadAsync` para que el cambio de cara sea instantáneo al grabar.

### FASE 4 — Biblioteca de animaciones
Construye `Config/Animaciones` con unas **40 entradas** en categorías. Usa las fuentes en este orden de prioridad:

1. **Del script `Animate` por defecto (de Roblox, sin problemas de permisos):** lee los IDs **de un personaje R15 en Play**; no los escribas de memoria. Incluye: idle, mirar alrededor, caminar, correr, saltar, caer, sentarse, saludar, señalar, bailar 1–3, reír y animar.
2. **Emotes y paquetes de animación de Roblox** del catálogo, buscados con `search_asset`. Prueba que carguen.
3. **Gratis de la Creator Store** que **sí carguen** tras la prueba de permisos.
4. **Procedurales en código** (Codex). No dependen de permisos: temblar de miedo, rebote de alegría, mirar a otro actor (cuello y cabeza), doble mirada rápida, salto de susto, desmayo (tween + caída), congelar (`AdjustSpeed(0)`) y respiración agitada.
5. **Animation Capture:** para los gestos clave de las referencias que no existan, prepara en `docs/ANIMACIONES_A_GRABAR.md` la lista de clips que el usuario debe grabarse imitando (menos de 15 s, cuerpo completo, cámara fija, buena luz) y los pasos para convertirlos y publicarlos. Guía al usuario en la publicación si no puedes hacerlo tú.

**Categorías:** Básicas · Reacciones (reír, llorar, shock, facepalm, encogerse de hombros, cruzar brazos, pisotear de enojo, temblar) · Escuela (sentado en pupitre, escribir, levantar la mano, leer, dormir en el pupitre, comer, abrir casillero, profesor en la pizarra, regañar señalando) · Bailes y memes · Movimiento (caminar o correr hacia una marca).

**Verificación por entrada:** `LoadAnimation` OK, `Length > 0` y prueba visual. Marca `verificado = true` solo si pasa. Si no carga, déjala fuera de la UI.

### FASE 5 — Panel Director, cámaras y modo grabación → **STOP** (primera prueba del usuario)
- Implementa el panel según la sección 7.6, las cámaras según 7.4 y el modo grabación según 7.5.
- Prueba el flujo de 60 s tú mismo con `user_mouse_input` y `user_keyboard_input`, y captura cada paso.
- **STOP:** el usuario lo prueba. Recoge sus comentarios y corrige.

### FASE 6 — Secuencias, diálogo, efectos y plantillas virales
- **Beats:** una secuencia es una lista de pasos. Cada paso define cámara, emociones y animaciones por actor, texto de diálogo, sonido y efecto. Durante la grabación, `Espacio`/`→` avanza y `←` retrocede.
- **Diálogo:** burbuja sobre la cabeza (BillboardGui con estilo de la guía, efecto máquina de escribir y sonido "pop"). Mientras habla, el **lip-flap** alterna la cara `emoción ↔ emoción_hablando` a unos 8–10 Hz.
- **Subtítulos grandes** opcionales al estilo TikTok (blancos, borde negro grueso, palabra resaltada), siempre dentro de la zona segura.
- **Efectos:** zoom de impacto, temblor, destello blanco o rojo, viñeta, desenfoque dramático (`DepthOfField`), desaturar (`ColorCorrection`), cámara lenta (velocidad de animación × 0.25), congelar imagen y emojis de reacción sobre la cabeza (❗ ❓ 💀 😭 💢 ❤️).
- **Sonidos:** biblioteca corta (timbre de escuela, puerta, casillero, pasos, risas, whoosh, impacto, golpe de tensión). Usa solo audio de Roblox o con licencia, verificando `IsLoaded` y `TimeLength > 0`. Asigna atajos.
- **Plantillas virales:** 5–8 secuencias listas, basadas en la estructura de las referencias (por ejemplo: "Examen sorpresa", "Profe me pilló con el celular", "Confesión en el pasillo", "Drama en la cafetería", "Llegó el alumno nuevo"). Cada una con su gancho en los primeros 2 s.
- **Guardar y cargar escenas** con DataStore, más **Exportar/Importar** como texto JSON en un TextBox para hacer respaldos.

### FASE 7 — Creador de personajes (pestaña ➕)
Es un asistente paso a paso con vista previa 3D que gira (ViewportFrame):
1. Nombre y rol.
2. Cuerpo: paleta de tonos de piel, alto, ancho y tamaño de cabeza (sliders con límites seguros).
3. Pelo y accesorios: grilla curada desde `Config/Catalogo` (miniaturas `rbxthumb://type=Asset&id=<id>&w=150&h=150`), más un campo opcional "pegar ID" en modo avanzado.
4. Ropa: presets de colores y patrones, más "pegar ID" en modo avanzado.
5. Caras: elegir un set existente o marcar **"pedir set de caras nuevo"**. Esto deja una solicitud en la cola (DataStore + export JSON), porque el juego no llama a la IA.
6. Guardar. El personaje aparece de inmediato en la pestaña Personajes.

Además, en el PC: `herramientas/nuevo_personaje.py` (Codex) lee las solicitudes exportadas y ejecuta el pipeline de caras. El flujo para el usuario debe ser simplemente pedirte: "procesa los personajes nuevos". Documenta también cómo **convertir un personaje creado en el juego en uno fijo** dentro de `Config/Personajes`.

### FASE 8 — QA final y manuales → **STOP**
- **Checklist:** flujo de 60 s; cero errores en consola durante 10 minutos de uso; cambio de cara sin parpadeo; todas las animaciones visibles verificadas; atajos que no se disparan al escribir en un TextBox; modo grabación sin restos de UI, marcas ni partes de cámara visibles; 8 actores sin bajar de 60 FPS en un PC normal.
- `docs/MANUAL.md`: una página en español con capturas y atajos. Además, un panel de ayuda dentro del juego con F1.
- `docs/GUIA_GRABACION.md`: Device Simulator con 1080×1920 personalizado; OBS con captura de ventana recortada y lienzo 1080×1920 a 60 fps; calidad gráfica al máximo; consejo de monitor vertical o resolución real si la pantalla no da 1920 de alto; flujo de edición sugerido (CapCut: cortes, voz y música).
- **STOP:** entrega final con un resumen de lo construido, sus limitaciones y próximos pasos (playa, casa, ciudad…).

## 7. Especificaciones (contratos)

### 7.1 Contrato de Escenario
Cada locación vive en `ServerStorage/Escenarios/<Escenario>/<Locacion>` (Model) y contiene:
- `Geometria/`: todo anclado, sin scripts.
- `Marcas/`: Parts invisibles, anclados y sin colisión, llamados `Marca_01…`. Atributos: `Nombre` ("Pupitre 1", "Puerta"…), `Pose` ("de_pie" o "sentado") y la rotación hacia donde mira el actor.
- `Camaras/`: Parts invisibles con atributos `Nombre`, `FOV` y `Tipo` (general, medio, primer_plano…).
- Atributos del Model: `NombreVisible`, `Icono` (emoji), `Miniatura` (ImageId) y `LucesDisponibles`.
- Cargar significa clonar en `workspace.Set` y descargar lo anterior; los actores se reubican en las marcas que coincidan.
- **Para agregar un escenario nuevo** (playa, casa…) basta con crear otro Model con este contrato y registrarlo en `Config/Escenarios`. Documéntalo en el manual.

### 7.2 Personaje (tipo Luau)
`{ id, nombre, rol, descripcion: { colores, escalas, accesorios:{id}, shirt, pants }, caras: setId, animacionIdle, pose, origen: "biblia" | "creador" }`

### 7.3 Emociones (mínimo 20; agrega las que aparezcan en las referencias)
neutral · feliz · carcajada · sonrisa_picara · triste · llorando · enojado · furioso · sorprendido · shock · asustado · asco · confundido · enamorado · sonrojado · nervioso (sudor) · aburrido · cool/presumido · pensativo · guiño · ojos_en_blanco · malvado · muerto_de_risa · dormido.

Cada emoción tiene `id`, `nombreVisible`, `emoji`, `ImageId` por personaje y un `ImageIdHablando` opcional.

### 7.4 Cámaras (pensadas para 9:16)
- **Encuadres:** Plano general · Plano medio · Primer plano (cabeza y hombros) · Primerísimo primer plano (solo la cara) · Detalle (objeto) · Sobre el hombro · Dos personajes · Contrapicado · Picado · Cenital.
- **Movimientos:** Zoom de impacto (FOV rápido + temblor leve), Dolly zoom, Temblor (intensidad 1–3), Órbita lenta, Paneo A→B, Seguir actor, Cámara en mano (ruido sutil) y Cámara libre (WASD + mouse, velocidad ajustable; desactiva los controles del jugador).
- **Transición:** **corte seco por defecto** (lo normal en Shorts) o suave (tween).
- Los encuadres se calculan **automáticamente** según el actor seleccionado (altura de la cabeza y distancia según el plano). Además existen las cámaras fijas de cada locación.
- Atajos `1–9` (desactiva la Backpack para que esas teclas no equipen herramientas). FOV ajustable.

### 7.5 Modo grabación
- Con la tecla `G` se ocultan el Panel Director, toda la CoreGui (`SetCoreGuiEnabled(All, false)`), el cursor (opcional), las marcas y las partes de cámara. Opcionalmente hay una cuenta regresiva de 3-2-1.
- Fuera del modo grabación, una guía 9:16 activable (`V`) muestra las **zonas seguras** de TikTok/Shorts: margen superior (~14%), inferior (~22%, zona del texto y la descripción) y lateral derecho (~15%, botones).
- Durante la grabación siguen funcionando `Espacio`/`→` (siguiente beat), los atajos de sonido y los de efecto.

### 7.6 Panel Director (UX "superintuitiva")
- **Pestañas grandes con ícono y texto:** 🏫 Escenario · 🧍 Personajes · 😀 Caras · 💃 Animaciones · 🎥 Cámara · ✨ Efectos · 🎞️ Escenas · ➕ Crear.
- **Flujo principal sin escribir nada:** todo con botones y miniaturas. Máximo 2 niveles de profundidad.
- **Seleccionar:** clic en un actor en el mundo o en su tarjeta (con contorno de selección). Aparece una **mini-barra flotante** con: cara, animación, mover (arrastrar sobre el piso, `R` rota 45°), mandar a marca, duplicar y quitar.
- **Grillas** con miniatura grande, nombre, buscador y ⭐ favoritos arriba. Las emociones se muestran con la **cara real del personaje seleccionado**.
- **Deshacer/Rehacer** (`Ctrl+Z` / `Ctrl+Y`) y un botón visible. Autoguardado de la escena actual.
- **"Escena rápida":** un botón que carga una plantilla viral lista.
- **Modo avanzado** (interruptor): muestra IDs, velocidad de animación, FOV numérico y "pegar ID". Por defecto está apagado.
- **Primera vez:** tutorial de 3 pasos con globos. `F1` muestra los atajos.
- Panel en un costado, semitransparente y plegable, para no tapar la toma. Texto grande y legible, en español.
- Los atajos se ignoran si hay un TextBox enfocado o si `gameProcessed` es verdadero.

## 8. Seguridad de assets de terceros (obligatorio)
1. Inserta siempre primero en **cuarentena**.
2. Lista todos los `Script`/`LocalScript`/`ModuleScript`. **Por defecto, elimínalos todos.** Las escenas son estáticas y la lógica es nuestra.
3. Si un script es imprescindible: revísalo a mano. Rechaza ofuscación, `require(<número>)`, `loadstring`, `getfenv`, `HttpService`, `TeleportService`, `MarketplaceService`, webhooks e `InsertService` remoto. Ponlo en sandbox con Script Capabilities.
4. Elimina también objetos sospechosos: scripts escondidos dentro de partes, `Configuration` raros y valores con código.
5. Ancla la geometría, quita la colisión de los decorativos y revisa la escala contra un R15.
6. Registra en `INVESTIGACION_ASSETS.md`: ID, creador, qué se eliminó y el veredicto.

## 9. Definición de terminado (todo el proyecto)
- Se cumple la prueba de aceptación de 60 s.
- La Escuela tiene 6 locaciones completas con marcas, cámaras y 4 luces cada una.
- Todos los personajes de la biblia están recreados, con el set completo de emociones más sus variantes `_hablando`.
- Hay ≥ 30 animaciones **verificadas** visibles en la UI.
- Hay ≥ 10 encuadres y ≥ 6 movimientos de cámara.
- Existen el modo grabación limpio, la guía 9:16, las secuencias con beats, el diálogo con lip-flap, los subtítulos, los efectos, los sonidos y ≥ 5 plantillas virales.
- El creador de personajes funciona de punta a punta, incluido el pipeline de caras nuevas.
- `MANUAL.md`, `GUIA_GRABACION.md`, `PROGRESO.md` y `DECISIONES.md` están al día. El código pasa lint y no hay errores en consola.

## 10. Plantillas

### 10.1 TAREA CODEX (copiar y rellenar)
```
OBJETIVO: <una frase>
CONTEXTO: <qué módulo es, quién lo llama, dónde vive>
ARCHIVOS PERMITIDOS: <lista exacta; no toques nada más>
INTERFAZ (obligatoria): <tipos y firmas Luau/Python exactas>
COMPORTAMIENTO: <reglas, casos borde>
CRITERIOS DE ACEPTACIÓN: <tests o comprobaciones concretas>
PROHIBIDO: MCP de Studio, loadstring/getfenv/require(número), cambiar interfaces, dependencias nuevas sin avisar
ENTREGA: diff + resumen de 5 líneas + cómo probarlo
```

### 10.2 PROMPT DE ANÁLISIS para `/watch` (Gemini 3.8 Pro)
```
Analiza este video corto viral hecho con Roblox. Responde SOLO con JSON válido:
{
 "video": "<nombre>", "duracion_s": n, "cortes_por_segundo": n,
 "estructura": {"gancho_0_2s": "", "desarrollo": "", "remate": "", "loop": bool},
 "personajes": [{"id_provisional": "", "rol": "", "personalidad": "",
   "cuerpo": {"tipo": "R15|R6|otro", "proporciones": ""},
   "piel_hex": "", "pelo": {"estilo": "", "color_hex": ""},
   "ropa": {"arriba": "", "abajo": "", "zapatos": "", "colores_hex": []},
   "accesorios": [], "cara": {"ojos": "", "pupilas": "", "cejas": "", "boca": "",
   "linea_grosor_color": "", "extras": ""},
   "emociones_vistas": [{"emocion": "", "t": "mm:ss"}],
   "mejores_frames_de_frente": ["mm:ss"]}],
 "gestos_animaciones": [{"descripcion": "", "personaje": "", "t": "mm:ss", "duracion_s": n}],
 "camara": [{"tipo_plano": "", "movimiento": "", "t": "mm:ss"}],
 "escenarios": [{"lugar": "", "detalles": "", "iluminacion": ""}],
 "texto_en_pantalla": {"fuente_estilo": "", "color": "", "borde": "", "posicion": "", "animacion": ""},
 "audio": {"voz": "", "musica": "", "efectos": [{"tipo": "", "t": "mm:ss"}]},
 "efectos_visuales": [{"tipo": "", "t": "mm:ss"}],
 "por_que_es_viral": ["", "", ""]
}
Sé concreto con colores (hex aproximado) y timestamps. Si algo no se ve, usa null.
```

### 10.3 PLANTILLA DE CARA para MODELO_CARAS (en inglés, porque el modelo de imagen es más preciso así)
```
Roblox cartoon FACE DECAL for character "<NOMBRE>". Emotion: <EMOCION> — <descripción corta del gesto>.
Match EXACTLY the face style in the attached reference(s): <rasgos de la biblia: forma de ojos,
pupilas, cejas, boca, grosor y color de línea, rubor/extras>.
Draw ONLY facial features (eyes, eyebrows, mouth, and if needed blush/tears/sweat/veins).
NO head outline, NO skin fill, NO hair, NO background, NO text, NO watermark.
Fully transparent background PNG, 1024x1024, features centered; eyes at ~40% height, mouth at ~65%,
features span ~70% of width. Thick clean outlines and flat colors, readable on a small phone screen.
Variant: <boca cerrada | boca abierta para hablar>. Keep identity identical to the approved neutral face.
```

## 11. Empieza ahora
1. Lee `docs/PROGRESO.md` si existe. Si no, créalo.
2. Ejecuta la **FASE 0** completa y detente en su **STOP** con el resumen y tus preguntas.
3. No construyas nada en Studio antes de que el usuario apruebe la biblia de personajes.

# ======== FIN DEL MASTER PROMPT ========
