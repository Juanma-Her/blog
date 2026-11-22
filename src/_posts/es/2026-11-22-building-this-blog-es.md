---
title: "Cómo (vibe)codee este blog"
date: 2026-11-22
description: "Un blog bilingüe, estático y con paleta Gruvbox: las decisiones detrás del proyecto y cómo fue construirlo con ayuda de IA."
tags: [tooling]
ref: building-this-blog
---

Estuve haciendo un montón de cosas interesantes últimamente y caí en la cuenta de que debería empezar a documentarlas. Hace un tiempo que vengo haciendo (o intentando hacer) un kernel, y este último año también participé en mi primera Student Cluster Competition en CARLA 2026 obteniendo el tercer puesto, fui parte de mi primer hackatón en el NASA Space Apps Challenge y armé un juego web para la materia Ingeniería de Software en la facu que estuvo bastante divertido de hacer. Así que, pensándolo bien ahora, documentar lo que hago sería un golazo para cuando quiera conseguir laburo en algún lado! jeje.

Así que, después de procrastinarlo por un tiempo, decidí armar un blog a modo de portafolio, usando muchísima IA, obvio, porque no me interesa mucho el desarrollo web y no quería perder demasiado tiempo en un proyecto así.

## La versión corta

- Sitio estático armado con **Jekyll**, alojado en **GitHub Pages** y replicado (*mirrored*) en **Codeberg**.
- **Inglés y español**, con cada texto de la interfaz traducido y los posts enlazados entre idiomas.
- **Gruvbox**, en tema claro y oscuro, con el contraste de cada color de texto verificado.
- **Funciona sin JavaScript.** Los cinco scripts del sitio suman unos 9 KB y solo agregan comodidades.
- **CI que se niega a desplegar contenido roto:** esquemas para cada archivo de datos, verificación de enlaces y un *build* que falla si hay errores matemáticos.

## Por qué estático y por qué Jekyll

Un blog es mayormente texto que cambia cuando publico algo, no cuando alguien entra a leer. Para eso mismo existen los sitios estáticos: sin servidor, sin base de datos, sin nada que parchar ¡y el hosting es gratis!

Elegí Jekyll porque GitHub Pages lo soporta de forma nativa. Y para lo que lo quiero, sobra: Markdown, HTML y CSS es todo lo que necesito para escribir un par de posts de vez en cuando y tener un portafolio bonito. Todo lo que Jekyll no pueda hacer, lo resuelven un par de líneas de Ruby en `_plugins/`.

## Planificar antes de programar

Antes de escribir una sola línea de código hubo un documento: un plan, una especificación, un documento de diseño, los "contratos" JSON para cada archivo de datos y una lista de tickets (de BLG-01 a BLG-53) agrupados en hitos (*milestones*). Al lado, un canvas con cada página dibujada en ambos temas.

Esto terminó importando más que cualquier decisión técnica. Cada ticket tenía criterios de aceptación, así que "terminado" significaba algo concreto. Y cuando la IA se desviaba del diseño, había un canva al cual señalar.

Creo que cuando se trabaja con IA es muy importante planificar todo de antemano ¡tener la menor cantidad posible de cabos sueltos es fundamental! Uno puede llegar a programar poco (o nada) usando IA, pero el diseño, la arquitectura y la planificación son las cosas esenciales en las que no hay que errar si se quiere un buen producto final trabajando con IA.

Como dijo uno de mis profesores: *"En la era de la IA, escribir código ya no es el cuello de botella de un proyecto complejo"*.

## Dos idiomas, un sitio

Vivo en Argentina, un país hispanohablante obviamente, así que decidí agregar soporte para español e inglés en el sitio. Nunca se sabe si algún *recruiter* lo va a valorar...

Cada post vive en `_posts/en/` o `_posts/es/`. Las dos versiones comparten un `ref`:

```yaml
---
title: "Why the concept of skibidi toilet is so funny (in my opinion)."
date: 2026-06-07
tags: [memes]
ref: skibidi-toilet
---
```
{: data-file="_posts/en/2026-06-07-skibidi-toilet.md"}

El `ref` enlaza las traducciones para el selector de idioma, y también es la clave bajo la cual se guardan los comentarios. De esa forma, ambas versiones de un post comparten un mismo hilo de comentarios.

Los textos de la interfaz (menús, encabezados, botones) viven en dos archivos JSON: `i18n/en.json` e `i18n/es.json`. Si falta una clave en cualquiera de los dos, el *build* falla. No hay ningún "lo traduzco después" que termine mostrando inglés en silencio a quienes leen en español.

Una regla que agregué es: si un post todavía no tiene versión en español, aparece igual en las páginas en español, pero en inglés. Una vez que existe la traducción, ocupa su lugar:

```ruby
def posts_for(lang)
  site = @context.registers[:site]
  default = site.config["default_lang"]
  site.posts.docs.reverse.select do |post|
    post_lang = post.data["lang"]
    post_lang == lang || (post_lang == default && !post.data.dig("translations", lang))
  end
end
```
{: data-file="_plugins/i18n.rb"}

> ¡No está hecho al revés porque siempre voy a escribir primero los posts en inglés!
{: .note}

## Gruvbox, pero legible

Gruvbox es el esquema de colores que ya usan mi terminal, mi editor, mi gestor de ventanas, los temas de mis apps... ¡así que el blog TENÍA QUE usar Gruvbox! Cada color es un par, claro y oscuro, usando la función `light-dark()` de CSS:

```css
:root {
  color-scheme: light dark;
  --bg:     light-dark(#fbf1c7, #282828);
  --text:   light-dark(#3c3836, #ebdbb2);
  --accent: light-dark(#af3a03, #fabd2f);
}
```
{: data-file="assets/css/_tokens.css"}

El tema sigue la configuración de tu sistema hasta que elijas uno con el botón. Con JavaScript desactivado, sigue respetando tu sistema.

El detalle: algunos colores de Gruvbox no son legibles como texto. El rojo de Gruvbox sobre una tarjeta oscura tiene un contraste de más o menos 3.8:1, por debajo del 4.5:1 que pide WCAG para texto normal. Así que se verificó cada color del sitio contra cada fondo sobre el que aparece, y se ajustaron un par: un rojo apenitas más claro, comentarios más claros en los bloques de código y un verde más oscuro en el tema claro. Seguramente a simple vista no se note, pero la fatiga ocular se acumula.

## Matemática renderizada en tiempo de compilación

Algunos posts van a tener fórmulas, así que el sitio las renderiza con KaTeX cuando se compila (*build*), no en el navegador. Una fórmula como $$O(n \log n)$$ llega como HTML ya terminado, sin JavaScript.

Antes, una fórmula rota fallaba en silencio. Ahora, un error de TeX o un `$$` sin cerrar hace que falle el *build* de producción, así el primero en enterarse soy yo.

## Comentarios sin rastreo

Los comentarios usan giscus, que los guarda en GitHub Discussions. Pero usar giscus implica cargar un script desde otro sitio, así que solo se carga cuando se scrollea cerca de la sección de comentarios:

```js
const observer = new IntersectionObserver(
  (entries) => {
    if (!entries.some((entry) => entry.isIntersecting)) return;
    observer.disconnect();
    load();
  },
  { rootMargin: "600px" },
);
observer.observe(section);
```
{: data-file="assets/js/comments.js"}

Si abrís un post y te vas, tu navegador nunca se comunica con nadie más que con GitHub Pages.

## RSS que funciona en lectores de verdad

Hay un feed Atom completo, además de uno por etiqueta. Probandolo en NewsFlash me di cuenta que los lectores de feeds no son navegadores: eliminan los estilos y algunos descartan el MathML que genera KaTeX. Ahora los feeds llevan bloques de código plano y muestran las fórmulas como código fuente de TeX. No es muy lindo, pero siempre es legible.

## CI que dice que no

Cada *push* corre el mismo *pipeline* antes de desplegar nada:

1. Verifica el *front matter* de cada post y cada archivo de datos contra un JSON Schema, además de validaciones cruzadas: una etiqueta debe existir, la reseña de un proyecto debe apuntar a un post real y cada idioma debe tener exactamente las mismas claves.
2. Compila el sitio en modo producción. Ahí es donde saltan los errores de TeX y las traducciones faltantes.
3. Verifica que cada feed sea un XML válido y tenga entradas.
4. Verifica cada enlace interno e imagen con html-proofer.
5. Despliega en GitHub Pages y luego replica el repositorio en Codeberg.

Si algún paso falla, el sitio en producción queda intacto como estaba.

## Construyéndolo con el mejor ingeniero 10x, Claude

¡Y ahora la vergüenza! Armé todo esto con Claude Code, trabajando desde mi editor y la terminal. La división del trabajo fue más o menos así:

- **Yo:** qué debía ser el sitio, el plan y el diseño, cada decisión y la revisión de cada página antes de publicarla.
- **Claude:** la mayor parte del código, las verificaciones y muchas de las partes tediosas, como calcular las relaciones de contraste para cada par de colores.

Lo que funcionó:
- **Ticket por ticket.** Cada ticket era lo suficientemente chico como para revisarlo bien: compilar en local, mirarlo yo y recién ahí subirlo.
- **Un diseño contra el cual comparar.** "Hacé que quede igual al lienzo" es una instrucción mucho mejor que "hacé que se vea lindo".
- **Verificaciones como barreras de seguridad.** Los esquemas, el chequeo de enlaces y la validación matemática atrapan errores de cualquiera de los dos.

Lo que no funcionó, o me necesitó a mí:
- **Detalles visuales:** una tarjeta descentrada, los puntos de una línea de tiempo corridos por un par de píxeles, un título que hacía salto de línea antes de tiempo. Hizo falta que yo señalara capturas de pantalla para dejar eso bien.
- **Criterio estético.** Él proponía; yo elegía. A veces seguía al pie de la letra el diseño cuando el diseño mismo estaba mal. La página de archivo era más angosta que el resto porque el lienzo decía eso.
- **Pruebas en el mundo real.** Un feed que pasa perfecto en un validador puede verse roto en un lector real.

Para un proyecto del que realmente no me interesaba aprender demasiado, salió muy bien y rápido: toda la planificación llevó una tarde-noche y programar todo llevó un día. Fue divertido y una buena experiencia y experimento. Al final aprendí bastantes cosas sobre el *stack*, pero no me andaría vendiendo como un experto en desarrollo web (ni siquiera como principiante), ya que si tuviera que rehacer todo esto por mi cuenta estaría más perdido que turco en la neblina. Capaz no completamente perdido, pero me llevaría muchísimo más que un día volver a programar todo desde cero.

## Lo que sigue

El código fuente es público en [GitHub](https://github.com/Juanma-Her/blog) y [Codeberg](https://codeberg.org/Strinix/blog), el código bajo licencia GPL-3.0 y los posts bajo CC BY-SA 4.0.

En un futuro cercano voy a estar escribiendo sobre un rasterizador en el que estuve trabajando para aprender C++ y sobre un pequeño sistema operativo (kernel) en el que también vengo trabajando desde hace ya un tiempo, pero al que todavía no le dediqué el esfuerzo suficiente (¡Hasta ahora!).

Si encontrás algún error, cada post tiene un enlace al final para sugerir una edición.
