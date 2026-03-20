# Space Survivors Android — Plan de Proyecto

## 1. Resumen ejecutivo

**Idea base:** un juego para Android tipo *Vampire Survivors* / *Brotato* / *survivors-like* / *reverse bullet heaven*, pero con **naves espaciales retro pixel art**.

El jugador controla una nave en el espacio, sobrevive a oleadas, derrota enemigos, recoge experiencia, sube de nivel y escoge mejoras que cambian la build en tiempo real.

**Pilar de fantasía:** “soy una nave pequeña pero cada minuto mi build se vuelve absurda y espectacular”.

**Referencia directa de diseño:**
- loop principal tipo *Vampire Survivors*
- lectura visual arcade tipo shooter espacial
- progresión de builds y decisiones rápidas
- sesiones móviles cortas, rejugables y altamente escalables

---

## 2. Nombre del género

Los nombres más útiles para definirlo son:

- **Survivors-like**
- **Reverse bullet heaven**
- **Auto-shooter roguelite**

Para documentación y marketing interno, usa este:

**"survivors-like space auto-shooter roguelite"**

---

## 3. Evaluación de la idea

## Lo bueno
- Es una fórmula ya validada.
- Encaja bien en móvil con partidas de 10–20 minutos.
- Permite scopear una primera versión pequeña y divertida.
- El tema espacial encaja muy bien con pixel art, VFX simples y progresión visual muy clara.
- Tiene muchísimo margen para contenido futuro: naves, armas, perks, élites, biomas, bosses, meta-progresión.

## Riesgos
- Puede quedarse en un clon sin identidad si no defines un hook claro.
- El caos visual puede romper la legibilidad en móvil.
- El control de la nave y el aiming deben sentirse muy bien desde el día 1.
- El balance entre builds es el gran agujero negro del proyecto.

## Hook recomendado
Para diferenciarlo, define desde el principio uno de estos hooks:

### Opción A — Build modular de nave
Cada mejora añade módulos físicos o semi-visibles a la nave:
- drones
- satélites
- cañones laterales
- escudo orbital
- láser de proa
- minas traseras

Esto da identidad visual brutal.

### Opción B — Espacio con navegación real
En vez de fondo decorativo, el mapa tiene:
- asteroides
- restos de naves
- zonas radiactivas
- agujeros de gravedad
- estaciones abandonadas

Esto añade posicionamiento real, no solo kiteo.

### Opción C — Sinergias de facción/tecnología
Las mejoras pertenecen a familias:
- plasma
- balística
- energía
- drones
- alien tech

Combinar ramas desbloquea evoluciones especiales.

**Recomendación:** mezcla **A + C**. Es la combinación con mejor retorno para una primera versión potente.

---

## 4. Formato del juego

## Decisión cerrada
El juego será **horizontal (landscape)**.

## Motivos
- Más espacio lateral para leer enemigos, proyectiles y pickups.
- El combate de naves se siente más natural en horizontal.
- La fantasía de “surcar el espacio” luce mejor.
- La legibilidad de builds complejas será claramente superior.
- Encaja mejor con la experiencia arcade/shooter espacial.

## Implicación de diseño
Toda la UI, el layout del HUD, el framing de cámara y el espacio de combate deben diseñarse desde el principio para **landscape**.

---

## 5. Recomendación de stack tecnológico

## Stack recomendado

### Motor
**Godot 4.6**

### Lenguaje
**GDScript** para velocidad de desarrollo inicial

### Arte y contenido generado por IA
- sprites y concepts generados con IA
- iteración de UI y layouts con IA
- apoyo de agentes para crear placeholders, prompts, variantes y documentación visual
- integración posterior de arte refinado sin romper pipeline

### Audio
- SFX retro sintetizados
- música chip/synthwave ligera
- primeras versiones también generables/asistibles con IA

### Persistencia
- save local en JSON / recursos serializados

### Control de versiones
- desarrollo inicial en local
- exportación posterior a **GitHub**

### IDE / entorno de desarrollo
- **Cursor** como primera opción
- **Claude Code** como segunda si quieres más disciplina de arquitectura
- **Antigravity** como apoyo para automatizaciones agresivas y orquestación
- incluso puedes combinar varios si defines bien roles y documentos guía

## Por qué Godot sigue siendo la mejor decisión aquí
- Menor fricción para arrancar un 2D móvil pequeño.
- Muy rápido para iterar gameplay con ayuda de IA.
- Muy buen encaje para pixel art y proyectos 2D.
- Export a Android razonable.
- Menor overhead que Unity para llegar a una build jugable este fin de semana.
- Suficiente para profesionalizar después el proyecto, incluyendo monetización y publicación.

## Consideración sobre monetización futura
Aunque el primer objetivo es tener una versión funcional, el proyecto debe dejar abierta la puerta a una fase posterior de profesionalización:
- anuncios puntuales / rewarded ads
- compras in-app
- progresión persistente
- pase de temporada / suscripción / monetización recurrente

Esto **no cambia** la recomendación de stack para el MVP: **Godot 4.6 + GDScript** sigue siendo la mejor apuesta para llegar rápido a jugable. La monetización se diseña como fase posterior, no como condicionante del primer slice.

## Alternativa seria
**Unity 6 + C#** si priorizaras desde ya monetización avanzada, SDKs publicitarios y ecosistema third-party desde etapa temprana.

## Decisión recomendada hoy
- **Motor:** Godot 4.6
- **Lenguaje:** GDScript
- **Orientación:** horizontal
- **Plataforma inicial:** Android solo
- **Resolución base lógica:** 320x180 o 480x270 escalada
- **Objetivo inmediato:** build jugable este mismo fin de semana

---

## 6. Principio rector del proyecto

## Estrategia
Primero se construye un juego **funcional y divertido**. Después se profesionaliza.

Orden correcto:
1. conseguir una versión jugable
2. validar sensaciones y bucle principal
3. ordenar arquitectura y contenido
4. profesionalizar arte, UX, monetización, retención y publicación

## Consecuencia práctica
No debes sobrediseñar sistemas de live ops, tienda, suscripción o economy ahora. Solo debes dejar el proyecto preparado para que esas capas puedan añadirse después sin rehacer el núcleo.

---

## 7. Core loop

1. Entras en una partida.
2. La nave dispara automáticamente o semi-automáticamente.
3. Te mueves esquivando enemigos y recogiendo experiencia.
4. Subes de nivel.
5. Eliges una de varias mejoras.
6. Tu build cambia y escala.
7. Aparecen enemigos más duros y nuevos patrones.
8. Llegan élites y bosses.
9. Mueren o sobrevives al límite de tiempo.
10. Obtienes moneda/meta-progreso.
11. Desbloqueas mejoras persistentes o contenido nuevo.

---

## 8. Pilares de diseño

## Pilar 1 — Legibilidad
Todo debe ser entendible en móvil en 1 segundo:
- enemigo reconocible
- pickup claro
- hit feedback claro
- armas claramente diferenciadas

## Pilar 2 — Power fantasy
El minuto 8 debe sentirse muchísimo más espectacular que el minuto 1.

## Pilar 3 — Decisiones simples pero significativas
Cada level-up debe ofrecer decisiones comprensibles:
- más daño
- más cadencia
- drones
- escudo
- perforación
- chain lightning

## Pilar 4 — Partidas cortas y reintento rápido
El usuario debe tardar segundos en volver a jugar.

---

## 9. Diseño del MVP

## Contenido MVP

### Nave inicial
- 1 nave base
- disparo frontal automático
- dash opcional más adelante, no de inicio

### Armas / sistemas
- blaster frontal
- láser continuo
- misiles buscadores
- dron orbital
- torreta lateral
- mina trasera

### Stats
- damage
- fire rate
- projectile speed
- range
- crit chance
- armor
- max HP
- move speed
- pickup radius
- luck

### Enemigos
- drone básico
- kamikaze rápido
- tanque lento
- tirador a distancia
- élite con aura
- boss simple

### Escenario
- 1 arena espacial
- fondo con parallax
- obstáculos opcionales mínimos

### Meta-progreso
- moneda al acabar
- árbol muy pequeño o upgrades persistentes simples

### UI
- barra HP
- XP bar
- reloj/tiempo
- contador de nivel
- popup de level up
- resumen post-run

---

## 10. Sistemas que debes construir primero

Orden recomendado:

1. movimiento de la nave
2. spawn de enemigos
3. disparo base
4. daño y muerte
5. drops de experiencia
6. level up con elección de upgrades
7. stats y escalado
8. oleadas / director de dificultad
9. HUD
10. boss
11. meta-progresión
12. polish audiovisual

---

## 11. Arquitectura recomendada

## Estructura de carpetas propuesta

```text
project/
  addons/
  assets/
    art/
      ships/
      enemies/
      bullets/
      ui/
      backgrounds/
      fx/
    audio/
      sfx/
      music/
    fonts/
  data/
    weapons/
    enemies/
    upgrades/
    ships/
    balance/
  scenes/
    main/
    player/
    enemies/
    bullets/
    pickups/
    ui/
    systems/
    bosses/
  scripts/
    core/
    components/
    systems/
    factories/
    utils/
  tests/
  docs/
  .cursor/
    rules/
  agents/
  AGENTS.md
  CLAUDE.md
  README.md
```

## Principios arquitectónicos
- datos fuera del código cuando sea posible
- escenas pequeñas y reutilizables
- composición antes que herencia profunda
- separación clara entre gameplay, datos y UI
- balance configurable por archivos de datos

## Patrones útiles
- component-based light architecture
- event bus / signals de Godot para desacoplar UI y gameplay
- resources para definir armas, enemigos y upgrades
- factory/spawner para enemigos y pickups

---

## 12. Roadmap por fases

## Fase 0 — Preproducción
Objetivo: cerrar visión y evitar empezar a ciegas.

Entregables:
- género definido
- orientación definida
- stack definitivo
- lista de features MVP
- documento de pillars
- esquema de carpetas

## Fase 1 — Vertical Slice técnico
Objetivo: demostrar que el juego “se siente bien”.

Entregables:
- nave moviéndose
- disparo automático
- 2 tipos de enemigos
- XP drop
- subir nivel
- elegir 3 upgrades
- HUD mínima

## Fase 2 — MVP jugable
Objetivo: una partida completa funcional.

Entregables:
- 6–8 enemigos
- 6 armas/sistemas
- 20–30 upgrades
- 1 boss
- escalado de dificultad
- menú principal
- game over / victory
- guardado básico

## Fase 3 — Retención y contenido
Objetivo: convertir prototipo en juego rejugable.

Entregables:
- meta-progresión
- 2ª nave
- evoluciones de armas
- mejoras persistentes
- más bosses
- balancing serio

## Fase 4 — Profesionalización / Android release
Objetivo: preparar el proyecto para publicación real.

Entregables:
- rendimiento estable
- controles táctiles bien ajustados
- tamaños UI correctos
- audio mejorado
- onboarding mínimo
- build firmada Android
- integración de monetización futura
- pipeline de publicación y analítica

---

## 13. Riesgos técnicos y cómo mitigarlos

## Riesgo 1 — Demasiados nodos / proyectiles
Mitigación:
- pooling de proyectiles
- limitar número máximo de entidades
- simplificar colisiones
- evitar efectos innecesarios

## Riesgo 2 — Caos visual en pantallas pequeñas
Mitigación:
- sprites claros
- paleta controlada
- proyectiles del jugador muy legibles
- reducir clutter de pickups

## Riesgo 3 — Juego aburrido tras 3 minutos
Mitigación:
- asegurar upgrades impactantes desde el minuto 1
- introducir sinergias temprano
- variar oleadas y ritmos

## Riesgo 4 — Scope creep
Mitigación:
- congelar MVP por escrito
- no meter crafting, multiplayer ni historia al principio

---

## 14. Recomendaciones de diseño de controles

## Decisión cerrada
Los controles serán un **simple joystick**.

## Implementación recomendada
- un joystick virtual para mover la nave
- disparo automático
- sin segundo stick en el MVP
- sin botones extra salvo que más adelante añadas una habilidad activa

## Ventajas
- menor fricción en móvil
- fácil de aprender
- perfecto para survivors-like
- reduce carga cognitiva y simplifica la UI

## Regla de diseño
Todo el combate debe diseñarse en torno a:
- movimiento satisfactorio
- esquiva clara
- autofire consistente
- builds que se expresan solas sin exigir inputs complejos

---

## 15. Recomendaciones de monetización futuras (no para el MVP)

No implementes esto en la primera fase, pero deja espacio mental para:
- premium único
- ads rewarded para reintento/recompensa
- cosméticos
- DLC de naves o expansiones

Para el MVP, ignóralo.

---

## 16. Siguientes pasos recomendados

## Paso 1
Cierra esta decisión hoy:
- **Godot 4.6 + GDScript + horizontal + joystick único**

## Paso 2
Crea el proyecto en local con esta estructura mínima:

```text
/assets
/data
/scenes
/scripts
/docs
/agents
/.cursor/rules
AGENTS.md
CLAUDE.md
README.md
```

## Paso 3
Escribe 4 documentos base antes de programar demasiado:
- `docs/game-pillars.md`
- `docs/mvp-scope.md`
- `docs/technical-architecture.md`
- `docs/content-schema.md`

## Paso 4
Construye una **versión jugable este mismo fin de semana** con foco absoluto en:
- movimiento
- autofire
- enemigos
- XP
- level-up
- mejoras
- game over loop

## Paso 5
Solo cuando el gameplay base sea divertido, mete:
- más contenido
- meta-progresión
- polish visual
- monetización futura
- export a GitHub y consolidación del pipeline

---

## 17. AGENTS y archivos markdown recomendados

Dado que el proyecto estará fuertemente asistido por IA, la capa documental de agentes no es opcional: es parte central del sistema de producción.

## Archivo raíz obligatorio

### `AGENTS.md`
Este archivo debe contener:
- visión del proyecto
- stack
- estructura del repo
- reglas de arquitectura
- checklist antes de cerrar tareas
- reglas de testing y validación
- restricciones de scope
- instrucciones explícitas para trabajo asistido por IA

## Archivo específico para Claude Code

### `CLAUDE.md`
Úsalo como adaptación del AGENTS.md con foco en:
- cómo navegar el repo
- cómo implementar features
- qué no tocar sin pedirlo
- comandos útiles
- estilo de commits y validación

## Carpeta `agents/`
Crea agentes especializados en markdown.

### `agents/game-director.md`
Responsable de:
- mantener coherencia global del proyecto
- decidir prioridades del MVP
- bloquear scope creep
- convertir ideas en tareas ejecutables

### `agents/gameplay-architect.md`
Responsable de:
- diseñar systems y gameplay loops
- validar coherencia entre armas, stats, enemigos y upgrades
- proponer cambios con bajo acoplamiento

### `agents/godot-engineer.md`
Responsable de:
- escenas
- nodos
- signals
- resources
- performance 2D móvil
- export Android

### `agents/pixel-art-integration.md`
Responsable de:
- integrar spritesheets
- generar o adaptar prompts de arte
- naming y slicing
- pivots
- capas visuales
- readability guidelines

### `agents/ai-art-director.md`
Responsable de:
- dirigir generación visual con IA
- definir estilo pixel art coherente
- crear prompts reutilizables para naves, enemigos, UI y FX
- validar consistencia visual entre assets

### `agents/balance-designer.md`
Responsable de:
- curvas de dificultad
- tablas de stats
- pesos de upgrades
- DPS esperado
- pacing por minuto

### `agents/qa-playtest.md`
Responsable de:
- crear checklists de test
- reproducir bugs
- validar game feel
- detectar regresiones

### `agents/android-release.md`
Responsable de:
- input táctil
- rendimiento en Android
- perfiles de build
- firma y export
- checklist pre-release

## 18. Skills recomendadas para potenciar el IDE

Crea una carpeta de skills/documentación operativa para que los agentes sepan ejecutar tareas recurrentes de forma consistente.

## Carpeta sugerida

```text
/docs/skills/
```

## Skills recomendadas

### `docs/skills/create-enemy-skill.md`
Define el proceso estándar para añadir un enemigo nuevo:
- resource de datos
- escena
- controlador
- stats
- tabla de spawn
- test manual

### `docs/skills/create-weapon-skill.md`
Proceso para nuevas armas:
- data model
- projectile scene
- cooldown
- targeting
- scaling
- feedback visual

### `docs/skills/create-upgrade-skill.md`
Proceso para upgrades:
- definición de rareza
- efectos
- restricciones
- sinergias
- UI card

### `docs/skills/create-ai-asset-skill.md`
Proceso para generar assets con IA:
- definir objetivo visual
- fijar estilo pixel art
- generar prompt reusable
- guardar variantes
- seleccionar versión válida
- adaptar naming y pipeline de importación

### `docs/skills/rebalance-run-skill.md`
Proceso para rebalancear una run:
- revisar TTK
- revisar XP/min
- revisar time-to-first-power-spike
- revisar dificultad por minuto

### `docs/skills/fix-performance-skill.md`
Checklist de optimización:
- pooling
- colisiones
- conteo de entidades
- profiler
- draw calls visuales

### `docs/skills/android-build-skill.md`
Checklist de export Android:
- SDK/JDK
- export preset
- firma
- iconos
- permisos
- build release

### `docs/skills/bug-triage-skill.md`
Método para procesar bugs:
- reproducir
- aislar
- proponer causa raíz
- parche mínimo
- validación regresión

### `docs/skills/weekend-mvp-skill.md`
Skill enfocada al objetivo inmediato:
- priorizar jugabilidad frente a pulido
- evitar features no esenciales
- entregar build probables rápido
- dejar deuda técnica documentada

## 19. Reglas para Cursor

## `.cursor/rules/project-overview.md`
Incluye:
- género
- pilares
- objetivo MVP
- prioridad de legibilidad y rendimiento

## `.cursor/rules/architecture.md`
Incluye:
- separación escena / lógica / data
- signals para eventos
- resources para contenido configurable
- no hardcodear balance en controladores

## `.cursor/rules/coding-standards.md`
Incluye:
- naming
- tamaño de scripts
- comentarios solo cuando aporten intención
- funciones cortas
- evitar acoplamiento circular

## `.cursor/rules/task-execution.md`
Incluye:
- no tocar varias áreas grandes sin plan
- antes de cambiar, explicar impacto
- después de cambiar, listar archivos modificados
- siempre proponer validación manual

---

## 20. Plantilla sugerida para `AGENTS.md`

```md
# AGENTS.md

## Project
Space Survivors Android is a 2D survivors-like space auto-shooter roguelite built in Godot 4.6 with GDScript.

## Product goals
- Fast, readable, replayable runs on Android
- Strong power progression during each run
- Reach a playable version as fast as possible
- Professionalize later with monetization, retention and content expansion

## Current scope
- Android only
- Landscape orientation
- Single-player only
- Offline only for MVP
- No multiplayer
- No live ops in MVP
- Simple virtual joystick + auto-fire

## Core pillars
1. Readability on small screens
2. Strong power fantasy
3. Fast iteration and simple architecture
4. Data-driven balancing
5. Mobile performance first
6. AI-assisted production across code, content and assets

## Tech stack
- Godot 4.6
- GDScript
- Local-first development
- GitHub later
- AI-assisted asset generation workflow

## Architecture rules
- Prefer composition over inheritance
- Keep balance data outside gameplay scripts
- Use Resources/data files for enemies, weapons, and upgrades
- Use signals/events to decouple UI from gameplay systems
- Keep scenes small and reusable
- Build MVP-first, professionalize later

## Folder conventions
- `scenes/` for Godot scenes
- `scripts/` for gameplay logic
- `data/` for tunable content
- `assets/` for art/audio
- `docs/` for design and implementation notes

## Coding rules
- Do not hardcode balance values in unrelated scripts
- Keep functions focused and short
- Avoid hidden side effects
- Name things by gameplay intent
- Prefer explicit data flow

## Workflow rules
Before implementing a feature:
1. Restate the goal
2. Identify files to touch
3. Minimize scope
4. Prefer the fastest path to playable if the feature belongs to MVP

After implementing:
1. Summarize what changed
2. List touched files
3. Describe manual test steps
4. Mention risks or follow-up work

## Testing rules
For any gameplay change, validate:
- player movement
- enemy spawn stability
- damage correctness
- XP collection
- level-up flow
- no obvious performance regression
- joystick comfort on mobile

## AI workflow rules
- Use AI to accelerate code, content, prompts and asset generation
- Favor reusable prompts and documented generation flows
- Keep asset naming and import conventions consistent
- Do not introduce random stylistic drift between generated assets

## Future-ready considerations
The project may later include:
- rewarded ads
- IAP
- battle pass / seasonal systems
- subscriptions

Do not implement these in MVP, but do not design the project in a way that blocks them.

## Non-goals for MVP
- online multiplayer
- procedural galaxy meta-map
- narrative campaign
- heavy shader work
- full monetization implementation
```md
# AGENTS.md

## Project
Space Survivors Android is a 2D survivors-like space auto-shooter roguelite built in Godot 4.6 with GDScript.

## Product goals
- Fast, readable, replayable runs on Android
- Strong power progression during each run
- Low-friction MVP before content expansion

## Current scope
- Android only
- Landscape orientation
- Single-player only
- Offline only
- No multiplayer
- No live ops

## Core pillars
1. Readability on small screens
2. Strong power fantasy
3. Fast iteration and simple architecture
4. Data-driven balancing
5. Mobile performance first

## Tech stack
- Godot 4.6
- GDScript
- Git + GitHub
- Local save files

## Architecture rules
- Prefer composition over inheritance
- Keep balance data outside gameplay scripts
- Use Resources/data files for enemies, weapons, and upgrades
- Use signals/events to decouple UI from gameplay systems
- Keep scenes small and reusable

## Folder conventions
- `scenes/` for Godot scenes
- `scripts/` for gameplay logic
- `data/` for tunable content
- `assets/` for art/audio
- `docs/` for design and implementation notes

## Coding rules
- Do not hardcode balance values in unrelated scripts
- Keep functions focused and short
- Avoid hidden side effects
- Name things by gameplay intent
- Prefer explicit data flow

## Workflow rules
Before implementing a feature:
1. Restate the goal
2. Identify files to touch
3. Minimize scope

After implementing:
1. Summarize what changed
2. List touched files
3. Describe manual test steps
4. Mention risks or follow-up work

## Testing rules
For any gameplay change, validate:
- player movement
- enemy spawn stability
- damage correctness
- XP collection
- level-up flow
- no obvious performance regression

## Non-goals for MVP
- online multiplayer
- procedural galaxy meta-map
- narrative campaign
- heavy shader work
- advanced monetization
```

---

## 21. Plantilla sugerida para `CLAUDE.md`

```md
# CLAUDE.md

This project is a Godot 4.6 Android game: a survivors-like space auto-shooter roguelite.

## What matters most
- Readability on mobile
- Clean gameplay architecture
- Fast iteration
- Data-driven tuning
- Avoid overengineering
- Reach a playable weekend build first

## When implementing features
- Prefer the smallest working solution
- Keep balance values configurable
- Separate data, gameplay logic, and UI
- Avoid touching unrelated systems
- Prioritize playable output over elegance when working on MVP-critical tasks

## Before making large changes
Explain:
- what you plan to build
- which files you will edit
- why this is the smallest safe approach

## After changes
Always provide:
- summary of changes
- file list
- manual validation steps
- known limitations

## Project constraints
- Android first
- Landscape
- Single player
- Pixel art
- Retro aesthetic
- Performance first
- Simple virtual joystick controls

## Asset generation
- AI-generated content is allowed and expected
- Keep prompts reusable
- Preserve art consistency across ships, enemies, UI and VFX
- Prefer placeholder assets if they unblock gameplay faster

## Avoid
- unnecessary abstractions
- premature optimization unless performance is already affected
- big refactors without request
- adding systems outside MVP scope
- delaying gameplay for asset perfection
```md
# CLAUDE.md

This project is a Godot 4.6 Android game: a survivors-like space auto-shooter roguelite.

## What matters most
- Readability on mobile
- Clean gameplay architecture
- Fast iteration
- Data-driven tuning
- Avoid overengineering

## When implementing features
- Prefer the smallest working solution
- Keep balance values configurable
- Separate data, gameplay logic, and UI
- Avoid touching unrelated systems

## Before making large changes
Explain:
- what you plan to build
- which files you will edit
- why this is the smallest safe approach

## After changes
Always provide:
- summary of changes
- file list
- manual validation steps
- known limitations

## Project constraints
- Android first
- Landscape
- Single player
- Pixel art
- Retro aesthetic
- Performance first

## Avoid
- unnecessary abstractions
- premature optimization unless performance is already affected
- big refactors without request
- adding systems outside MVP scope
```

---

## 22. Primer backlog realista

## Sprint 1
- crear repo
- configurar Godot
- estructura de carpetas
- AGENTS.md
- CLAUDE.md
- rules de Cursor
- escena player
- movimiento
- cámara

## Sprint 2
- disparo base
- enemigo básico
- colisión y daño
- muerte enemigo
- drop XP

## Sprint 3
- level-up popup
- sistema de upgrades
- 3 upgrades reales
- HUD básica

## Sprint 4
- director de oleadas
- 3 enemigos más
- balance básico
- game over loop

## Sprint 5
- boss simple
- post-run rewards
- save local
- build Android interna

---

## 23. Recomendación final

Para este proyecto, la opción más sensata es:

- **IDE principal:** Cursor
- **Apoyo posible:** Claude Code y/o Antigravity según el rol
- **Motor:** Godot 4.6
- **Lenguaje:** GDScript
- **Formato:** horizontal
- **Controles:** joystick simple + auto-fire
- **Objetivo inmediato:** versión jugable este mismo fin de semana
- **Objetivo posterior:** profesionalización del producto, arte, retención y monetización

Tu prioridad no debe ser “hacer un juego grande”, sino **demostrar diversión, legibilidad y escalado de build en una sola partida funcional**, usando IA de forma intensiva para código, contenido, documentación y arte.

Cuando eso funcione, todo lo demás se vuelve mucho más fácil.

