
# RNA-seq-Analysis

### Sobre Saccharomyces cerevisiae
<p align="justify">
Saccharomyces cerevisiae es un hongo unicelular eucariota ampliamente utilizado como organismo modelo en biología molecular, genética y biotecnología. Sus principales ventajas son: ciclo de vida corto, cultivo sencillo y económico, un genoma completamente secuenciado y una enorme colección de herramientas genéticas (bibliotecas de mutantes, colecciones de ORFs, sistemas de etiquetado y edición genética). Estas características permiten realizar experimentos de alto rendimiento y estudios mecanísticos sobre procesos celulares conservados en eucariotas superiores, como la transcripción, el procesamiento de ARN, la traducción y la respuesta al estrés.
</p>

### Función de la subunidad Rpb4
<p align="justify">
**Rpb4** es una de las subunidades clave de la **ARN polimerasa II (Pol II)** y desempeña un papel esencial en procesos como el reclutamiento del complejo transcripcional, la elongación del ARN y el acoplamiento entre los eventos nucleares y citoplasmáticos relacionados con el ARNm. Junto con Rpb7, forma un subcomplejo estable que se asocia a Pol II y contribuye tanto a su función reguladora como a su integridad estructural.

Estudios recientes han identificado varios residuos fosforilables en Rpb4 —S125, S197, T134, T144 y T193— lo que sugiere que la fosforilación podría ser un mecanismo regulador importante para su actividad. La modificación de estos residuos podría influir en la función de Rpb4 y, en consecuencia, en el rendimiento y la regulación global de la ARN polimerasa II.
</p>

### Contexto del proyecto
<p align="justify">
Este proyecto, desarrollado en el **Instituto de Biología Funcional y Genómica (IBFG)**, tiene como objetivo principal estudiar y caracterizar la subunidad Rpb4 de la ARN polimerasa II bajo distintas condiciones mutagénicas. Para ello se generaron dos cepas mediante mutagénesis dirigida, diseñadas específicamente para alterar los residuos fosforilables de la proteína:

* Rpb4‑S/T‑A: los cinco residuos fosforilables identificados en Rpb4 se sustituyen por alanina, eliminando así cualquier posibilidad de fosforilación o interacción regulada por estos sitios.

* Rpb4‑S/T‑D: los mismos cinco residuos se sustituyen por aspartato, introduciendo una carga negativa que imita el estado fosforilado de serinas y treoninas.

El propósito de estas construcciones es determinar el papel funcional de estos residuos en la actividad de Rpb4 y, por extensión, en el correcto desempeño de la ARN polimerasa II, evaluando cómo la fosforilación (o su ausencia) modula procesos clave de la transcripción.
</p>

### Estructura general del proyecto
<p align="justify">
El proyecto se organiza en dos grandes bloques de trabajo. En primer lugar, se lleva a cabo un análisis **RNA‑seq** utilizando los archivos de secuenciación generados a partir de las muestras experimentales, que incluyen 6 réplicas para la condición WT y 3 réplicas para cada una de las cepas mutantes descritas previamente.

En la segunda fase, se realiza un **análisis estadístico** basado en la matriz de conteos obtenida tras el procesamiento de los datos de secuenciación.

Por motivos de privacidad y restricciones de uso, los archivos crudos de secuencia no pueden ser publicados en este repositorio. Sin embargo, se proporciona la matriz de conteos, así como los archivos derivados del análisis estadístico, garantizando que el flujo completo de análisis quede documentado, explicado y reproducible dentro del repositorio.
</p>
