# Verzeichnis für ÖV taugliche Skitouren ab Aarau

Das Repository stellt ein Verzeichnis für ÖV taugliche Skitouren ab Aarau zur Verfügung.
Dabei stehen zwei Formate zur Verfügung: [PDF](https://sac-aarau.github.io/public-transport-ski-tours/oev-skitouren-ab-aarau.pdf) und [HTML](https://sac-aarau.github.io/public-transport-ski-tours/).
Diese werden über [GitHub Pages](https://docs.github.com/en/pages) publiziert.

## Entwicklungsumgebung

* [Pandoc](https://pandoc.org/)
* [GNU Make](https://www.gnu.org/software/make/)
* [TeX Live](https://tug.org/texlive/)
* Bash Kommandozeile
* Standard UNIX Werkzeuge

## Bauen & Publizieren

Es wird stets auf dem `master` Branch entwickelt.
Der `page` Branch wird auf GitHub Pages publiziert, dazu das entsprechende Target im [Makefile](./Makefile) verwenden.

```bash
# PDF und Webpage bauen
make all

# Nach GitHub Pages publizieren
make publish
```
