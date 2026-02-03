# 📋 Lektion 5: Listen - Deine erste Datenstruktur

## 📖 Inhaltsverzeichnis
- [Was sind Listen?](#was-sind-listen)
- [Listen erstellen](#listen-erstellen)
- [Listen-Indizierung](#listen-indizierung)
- [Listen-Slicing](#listen-slicing)
- [Listen-Methoden](#listen-methoden)
- [Listen verändern](#listen-verändern)
- [Listen sortieren](#listen-sortieren)
- [List Comprehensions](#list-comprehensions)
- [Verschachtelte Listen](#verschachtelte-listen)
- [Übungen](#übungen)

---

## 🤔 Was sind Listen?

**Liste** = Sammlung von mehreren Werten

### Die Container-Analogie

Stell dir einen **Einkaufszettel** 📝 vor:

```
1. Milch
2. Brot
3. Eier
4. Käse
```

In Python:

```python
einkaufsliste = ["Milch", "Brot", "Eier", "Käse"]
```

### Warum Listen?

**Ohne Liste:**
```python
item1 = "Milch"
item2 = "Brot"
item3 = "Eier"
item4 = "Käse"
# ... mühsam! 😰
```

**Mit Liste:**
```python
items = ["Milch", "Brot", "Eier", "Käse"]
# Alle zusammen! 🎉
```

### Listen vs. Strings

| String | Liste |
|--------|-------|
| Zeichenkette | Sammlung von Werten |
| Immutable (unveränderlich) | Mutable (veränderlich) |
| `"Python"` | `["P", "y", "t", "h", "o", "n"]` |

---

## ✍️ Listen erstellen

### Leere Liste

```python
# Methode 1: []
liste1 = []

# Methode 2: list()
liste2 = list()

>>> len(liste1)
0
```

### Liste mit Werten

```python
# Zahlen
zahlen = [1, 2, 3, 4, 5]

# Strings
namen = ["Max", "Anna", "Tom"]

# Gemischt
gemischt = [1, "Hallo", 3.14, True, None]

# Über mehrere Zeilen
einkauf = [
    "Milch",
    "Brot",
    "Eier",
    "Käse"
]
```

### Liste aus String

```python
# Jeder Buchstabe wird Element
>>> list("Python")
['P', 'y', 't', 'h', 'o', 'n']

# Split
>>> "Hallo Welt Python".split()
['Hallo', 'Welt', 'Python']
```

### Liste aus range()

```python
>>> list(range(5))
[0, 1, 2, 3, 4]

>>> list(range(1, 6))
[1, 2, 3, 4, 5]

>>> list(range(0, 10, 2))
[0, 2, 4, 6, 8]
```

---

## 🔢 Listen-Indizierung

Genau wie bei Strings!

### Positive Indizes

```python
fruechte = ["Apfel", "Banane", "Kirsche", "Dattel"]
#             0         1          2         3

>>> fruechte[0]
'Apfel'

>>> fruechte[2]
'Kirsche'

>>> fruechte[3]
'Dattel'

>>> fruechte[4]
IndexError: list index out of range
```

### Negative Indizes

```python
fruechte = ["Apfel", "Banane", "Kirsche", "Dattel"]
#            -4        -3         -2        -1

>>> fruechte[-1]
'Dattel'  # Letztes Element

>>> fruechte[-2]
'Kirsche'

>>> fruechte[-4]
'Apfel'  # Erstes Element
```

### Element ändern

**Listen sind mutable!**

```python
>>> fruechte = ["Apfel", "Banane", "Kirsche"]
>>> fruechte[1] = "Birne"
>>> print(fruechte)
['Apfel', 'Birne', 'Kirsche']

>>> zahlen = [10, 20, 30]
>>> zahlen[0] = 100
>>> print(zahlen)
[100, 20, 30]
```

**Strings sind immutable:**
```python
>>> text = "Python"
>>> text[0] = "J"
TypeError: 'str' object does not support item assignment
```

---

## ✂️ Listen-Slicing

Exakt wie bei Strings!

### Syntax

```python
liste[start:end:step]
```

### Grundlegendes Slicing

```python
zahlen = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

>>> zahlen[2:5]
[2, 3, 4]  # Index 2, 3, 4 (nicht 5!)

>>> zahlen[0:3]
[0, 1, 2]

>>> zahlen[5:8]
[5, 6, 7]
```

### Start/End weglassen

```python
zahlen = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

# Vom Anfang
>>> zahlen[:5]
[0, 1, 2, 3, 4]

# Bis zum Ende
>>> zahlen[5:]
[5, 6, 7, 8, 9]

# Alles
>>> zahlen[:]
[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

# Kopie erstellen!
>>> kopie = zahlen[:]
```

### Mit Schrittweite

```python
zahlen = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

# Jedes 2. Element
>>> zahlen[::2]
[0, 2, 4, 6, 8]

# Jedes 3. Element
>>> zahlen[::3]
[0, 3, 6, 9]

# Von Index 1, jedes 2. Element
>>> zahlen[1::2]
[1, 3, 5, 7, 9]
```

### Liste umkehren

```python
>>> zahlen = [1, 2, 3, 4, 5]
>>> zahlen[::-1]
[5, 4, 3, 2, 1]

>>> namen = ["Max", "Anna", "Tom"]
>>> namen[::-1]
['Tom', 'Anna', 'Max']
```

### Slice zum Ändern

```python
>>> zahlen = [0, 1, 2, 3, 4, 5]
>>> zahlen[1:4] = [10, 20, 30]
>>> print(zahlen)
[0, 10, 20, 30, 4, 5]

# Löschen
>>> zahlen[1:3] = []
>>> print(zahlen)
[0, 30, 4, 5]
```

---

## 🔧 Listen-Methoden

### append() - Element hinzufügen

**Am Ende hinzufügen:**

```python
>>> fruechte = ["Apfel", "Banane"]
>>> fruechte.append("Kirsche")
>>> print(fruechte)
['Apfel', 'Banane', 'Kirsche']

>>> zahlen = [1, 2, 3]
>>> zahlen.append(4)
>>> zahlen.append(5)
>>> print(zahlen)
[1, 2, 3, 4, 5]
```

**Praktisch:**
```python
einkaufsliste = []

while True:
    item = input("Item (Enter zum Beenden): ")
    if item == "":
        break
    einkaufsliste.append(item)

print("Deine Liste:", einkaufsliste)
```

### extend() - Liste erweitern

**Mehrere Elemente hinzufügen:**

```python
>>> liste1 = [1, 2, 3]
>>> liste2 = [4, 5, 6]
>>> liste1.extend(liste2)
>>> print(liste1)
[1, 2, 3, 4, 5, 6]

>>> fruechte = ["Apfel", "Banane"]
>>> mehr_fruechte = ["Kirsche", "Dattel", "Erdbeere"]
>>> fruechte.extend(mehr_fruechte)
>>> print(fruechte)
['Apfel', 'Banane', 'Kirsche', 'Dattel', 'Erdbeere']
```

**append() vs. extend():**

```python
# append: Fügt als EINZELNES Element hinzu
>>> liste = [1, 2, 3]
>>> liste.append([4, 5])
>>> print(liste)
[1, 2, 3, [4, 5]]  # Liste in Liste!

# extend: Fügt JEDES Element hinzu
>>> liste = [1, 2, 3]
>>> liste.extend([4, 5])
>>> print(liste)
[1, 2, 3, 4, 5]
```

### insert() - An Position einfügen

```python
>>> fruechte = ["Apfel", "Kirsche", "Dattel"]
>>> fruechte.insert(1, "Banane")
>>> print(fruechte)
['Apfel', 'Banane', 'Kirsche', 'Dattel']

>>> zahlen = [1, 2, 4, 5]
>>> zahlen.insert(2, 3)  # An Index 2
>>> print(zahlen)
[1, 2, 3, 4, 5]
```

**Am Anfang einfügen:**
```python
>>> liste = [2, 3, 4]
>>> liste.insert(0, 1)
>>> print(liste)
[1, 2, 3, 4]
```

### remove() - Element entfernen

**Entfernt das ERSTE Vorkommen:**

```python
>>> fruechte = ["Apfel", "Banane", "Kirsche", "Banane"]
>>> fruechte.remove("Banane")
>>> print(fruechte)
['Apfel', 'Kirsche', 'Banane']  # Nur erste Banane weg!

>>> zahlen = [1, 2, 3, 2, 4]
>>> zahlen.remove(2)
>>> print(zahlen)
[1, 3, 2, 4]  # Nur erste 2 weg!
```

**Fehler wenn nicht vorhanden:**
```python
>>> fruechte = ["Apfel", "Banane"]
>>> fruechte.remove("Kirsche")
ValueError: list.remove(x): x not in list

# Sicher:
if "Kirsche" in fruechte:
    fruechte.remove("Kirsche")
```

### pop() - Element entfernen und zurückgeben

**Letztes Element:**
```python
>>> fruechte = ["Apfel", "Banane", "Kirsche"]
>>> letztes = fruechte.pop()
>>> print(letztes)
'Kirsche'
>>> print(fruechte)
['Apfel', 'Banane']
```

**Bestimmter Index:**
```python
>>> fruechte = ["Apfel", "Banane", "Kirsche"]
>>> zweites = fruechte.pop(1)
>>> print(zweites)
'Banane'
>>> print(fruechte)
['Apfel', 'Kirsche']
```

**Praktisch (Stack):**
```python
stapel = []

# Push
stapel.append(1)
stapel.append(2)
stapel.append(3)

# Pop
print(stapel.pop())  # 3
print(stapel.pop())  # 2
print(stapel)  # [1]
```

### clear() - Alle Elemente löschen

```python
>>> liste = [1, 2, 3, 4, 5]
>>> liste.clear()
>>> print(liste)
[]

# Alternative:
>>> liste = [1, 2, 3, 4, 5]
>>> liste = []
```

### index() - Position finden

```python
>>> fruechte = ["Apfel", "Banane", "Kirsche", "Dattel"]
>>> fruechte.index("Kirsche")
2

>>> fruechte.index("Apfel")
0

>>> fruechte.index("Erdbeere")
ValueError: 'Erdbeere' is not in list
```

**Mit Start/End:**
```python
>>> zahlen = [1, 2, 3, 2, 4, 2]
>>> zahlen.index(2)  # Erstes Vorkommen
1

>>> zahlen.index(2, 2)  # Ab Index 2 suchen
3
```

### count() - Wie oft vorhanden?

```python
>>> zahlen = [1, 2, 2, 3, 2, 4, 2]
>>> zahlen.count(2)
4

>>> fruechte = ["Apfel", "Banane", "Apfel", "Kirsche"]
>>> fruechte.count("Apfel")
2

>>> fruechte.count("Erdbeere")
0
```

---

## 🔄 Listen verändern

### Element ändern

```python
>>> zahlen = [1, 2, 3, 4, 5]
>>> zahlen[2] = 100
>>> print(zahlen)
[1, 2, 100, 4, 5]
```

### Mehrere Elemente ändern

```python
>>> zahlen = [1, 2, 3, 4, 5]
>>> zahlen[1:4] = [20, 30, 40]
>>> print(zahlen)
[1, 20, 30, 40, 5]
```

### Element löschen (del)

```python
>>> fruechte = ["Apfel", "Banane", "Kirsche", "Dattel"]
>>> del fruechte[1]
>>> print(fruechte)
['Apfel', 'Kirsche', 'Dattel']

# Mehrere löschen
>>> zahlen = [1, 2, 3, 4, 5]
>>> del zahlen[1:3]
>>> print(zahlen)
[1, 4, 5]
```

### Liste kopieren

**ACHTUNG! Falle:**
```python
>>> liste1 = [1, 2, 3]
>>> liste2 = liste1  # Keine Kopie! Referenz!
>>> liste2.append(4)
>>> print(liste1)
[1, 2, 3, 4]  # Auch liste1 geändert! 😱
```

**Richtig kopieren:**
```python
# Methode 1: Slicing
>>> liste1 = [1, 2, 3]
>>> liste2 = liste1[:]
>>> liste2.append(4)
>>> print(liste1)
[1, 2, 3]  # Unverändert ✅

# Methode 2: copy()
>>> liste1 = [1, 2, 3]
>>> liste2 = liste1.copy()
>>> liste2.append(4)
>>> print(liste1)
[1, 2, 3]  # Unverändert ✅

# Methode 3: list()
>>> liste1 = [1, 2, 3]
>>> liste2 = list(liste1)
```

---

## 🔄 Listen sortieren

### sort() - Liste selbst sortieren

**Aufsteigend:**
```python
>>> zahlen = [3, 1, 4, 1, 5, 9, 2]
>>> zahlen.sort()
>>> print(zahlen)
[1, 1, 2, 3, 4, 5, 9]

>>> namen = ["Max", "Anna", "Tom", "Bea"]
>>> namen.sort()
>>> print(namen)
['Anna', 'Bea', 'Max', 'Tom']  # Alphabetisch
```

**Absteigend:**
```python
>>> zahlen = [3, 1, 4, 1, 5, 9, 2]
>>> zahlen.sort(reverse=True)
>>> print(zahlen)
[9, 5, 4, 3, 2, 1, 1]
```

**Case-insensitive:**
```python
>>> namen = ["max", "Anna", "tom"]
>>> namen.sort()
>>> print(namen)
['Anna', 'max', 'tom']  # Großbuchstaben zuerst!

>>> namen.sort(key=str.lower)
>>> print(namen)
['Anna', 'max', 'tom']  # Alphabetisch ignoriert Groß/Klein
```

### sorted() - Neue sortierte Liste

**Original bleibt unverändert:**
```python
>>> zahlen = [3, 1, 4, 1, 5]
>>> sortiert = sorted(zahlen)
>>> print(zahlen)
[3, 1, 4, 1, 5]  # Unverändert
>>> print(sortiert)
[1, 1, 3, 4, 5]  # Neu sortiert
```

### reverse() - Umkehren

```python
>>> zahlen = [1, 2, 3, 4, 5]
>>> zahlen.reverse()
>>> print(zahlen)
[5, 4, 3, 2, 1]

# Alternative:
>>> zahlen = [1, 2, 3, 4, 5]
>>> zahlen = zahlen[::-1]
```

### min(), max(), sum()

```python
>>> zahlen = [3, 1, 4, 1, 5, 9, 2]

>>> min(zahlen)
1

>>> max(zahlen)
9

>>> sum(zahlen)
25

>>> len(zahlen)
7

# Durchschnitt
>>> sum(zahlen) / len(zahlen)
3.5714285714285716
```

---

## 🚀 List Comprehensions

**Elegante Kurzform** für Listen-Erstellung!

### Syntax

```python
[ausdruck for item in liste]
```

### Einfache Beispiele

```python
# Normal
zahlen = []
for i in range(5):
    zahlen.append(i)
# zahlen = [0, 1, 2, 3, 4]

# List Comprehension
>>> zahlen = [i for i in range(5)]
>>> print(zahlen)
[0, 1, 2, 3, 4]
```

**Quadratzahlen:**
```python
# Normal
quadrate = []
for i in range(1, 6):
    quadrate.append(i ** 2)

# List Comprehension
>>> quadrate = [i**2 for i in range(1, 6)]
>>> print(quadrate)
[1, 4, 9, 16, 25]
```

**String-Verarbeitung:**
```python
>>> namen = ["max", "anna", "tom"]
>>> gross = [name.upper() for name in namen]
>>> print(gross)
['MAX', 'ANNA', 'TOM']

>>> woerter = ["Hallo", "Welt", "Python"]
>>> laengen = [len(wort) for wort in woerter]
>>> print(laengen)
[5, 4, 6]
```

### Mit Bedingung (if)

```python
# Nur gerade Zahlen
>>> zahlen = [i for i in range(10) if i % 2 == 0]
>>> print(zahlen)
[0, 2, 4, 6, 8]

# Nur positive Zahlen
>>> liste = [-2, -1, 0, 1, 2]
>>> positiv = [x for x in liste if x > 0]
>>> print(positiv)
[1, 2]

# Wörter über 5 Zeichen
>>> woerter = ["Hallo", "Hi", "Python", "OK", "Programmieren"]
>>> lang = [wort for wort in woerter if len(wort) > 5]
>>> print(lang)
['Python', 'Programmieren']
```

### Mit if-else

```python
# Syntax: [ausdruck_if if bedingung else ausdruck_else for item in liste]

# Gerade → "gerade", Ungerade → "ungerade"
>>> ergebnis = ["gerade" if i % 2 == 0 else "ungerade" for i in range(5)]
>>> print(ergebnis)
['gerade', 'ungerade', 'gerade', 'ungerade', 'gerade']

# Positiv → "pos", Negativ → "neg"
>>> zahlen = [-2, 3, -1, 4]
>>> typ = ["pos" if x > 0 else "neg" for x in zahlen]
>>> print(typ)
['neg', 'pos', 'neg', 'pos']
```

### Verschachtelt

```python
# Alle Kombinationen
>>> paare = [(x, y) for x in [1, 2, 3] for y in ['a', 'b']]
>>> print(paare)
[(1, 'a'), (1, 'b'), (2, 'a'), (2, 'b'), (3, 'a'), (3, 'b')]

# Multiplikationstabelle
>>> tabelle = [[i * j for j in range(1, 6)] for i in range(1, 6)]
>>> for zeile in tabelle:
...     print(zeile)
[1, 2, 3, 4, 5]
[2, 4, 6, 8, 10]
[3, 6, 9, 12, 15]
[4, 8, 12, 16, 20]
[5, 10, 15, 20, 25]
```

---

## 📦 Verschachtelte Listen

**Liste in Liste** = 2D-Liste / Matrix

### Erstellen

```python
# Matrix 2×3
>>> matrix = [
...     [1, 2, 3],
...     [4, 5, 6]
... ]

# Zugriff
>>> matrix[0]
[1, 2, 3]  # Erste Zeile

>>> matrix[1]
[4, 5, 6]  # Zweite Zeile

>>> matrix[0][1]
2  # Zeile 0, Spalte 1

>>> matrix[1][2]
6  # Zeile 1, Spalte 2
```

### Praktisches Beispiel

```python
# Schüler mit Noten
schueler = [
    ["Max", 1.5, 2.0, 1.7],
    ["Anna", 1.0, 1.3, 1.2],
    ["Tom", 2.3, 2.7, 2.5]
]

# Annas Noten
>>> schueler[1]
['Anna', 1.0, 1.3, 1.2]

# Annas Name
>>> schueler[1][0]
'Anna'

# Annas zweite Note
>>> schueler[1][2]
1.3

# Durchschnitt berechnen
for s in schueler:
    name = s[0]
    noten = s[1:]
    schnitt = sum(noten) / len(noten)
    print(f"{name}: {schnitt:.2f}")

# Ausgabe:
# Max: 1.73
# Anna: 1.17
# Tom: 2.50
```

### Tic-Tac-Toe Board

```python
board = [
    ['X', 'O', 'X'],
    ['O', 'X', 'O'],
    ['X', ' ', 'O']
]

# Anzeigen
for zeile in board:
    print('|'.join(zeile))
    print('-' * 5)

# Ausgabe:
# X|O|X
# -----
# O|X|O
# -----
# X| |O
# -----
```

---

## 📝 Übungen

### Übung 1: Liste erstellen
```python
# Erstelle Liste mit Zahlen 1-10
# Gib aus: Summe, Durchschnitt, Min, Max
```

### Übung 2: Filtern
```python
zahlen = [1, -5, 3, -2, 8, -7, 4, 0, -1]
# Erstelle neue Liste nur mit positiven Zahlen
# (Ohne List Comprehension und mit)
```

### Übung 3: Duplikate entfernen
```python
liste = [1, 2, 2, 3, 1, 4, 3, 5]
# Entferne Duplikate (Reihenfolge egal)
```

### Übung 4: Todo-Liste
Erstelle eine Todo-App:
```python
# Befehle:
# - add: Todo hinzufügen
# - remove: Todo entfernen (Index)
# - show: Alle Todos anzeigen
# - quit: Beenden
```

### Übung 5: Noten-Rechner
```python
noten = []
# User kann Noten eingeben (Enter = fertig)
# Berechne: Durchschnitt, beste Note, schlechteste Note
# Wie viele 1en? 2en? etc.
```

### Übung 6: List Comprehensions
```python
# a) Erstelle Liste [1, 4, 9, 16, ..., 100] (Quadratzahlen 1-10)
# b) Erstelle Liste mit allen geraden Zahlen von 1-50
# c) Wandle ["max", "anna", "tom"] in Großbuchstaben um
# d) Erstelle Liste aller Zahlen 1-20 die durch 3 teilbar sind
```

### Übung 7: Matrix
```python
# Erstelle 3×3 Matrix mit Zahlen 1-9
# Gib schön formatiert aus
# Berechne Summe jeder Zeile
```

### Übung 8: Worte sortieren
```python
text = "Python ist eine tolle Programmiersprache"
# Sortiere Wörter alphabetisch
# Sortiere Wörter nach Länge
```

---

## 🎓 Was du gelernt hast

✅ Listen erstellen und verwenden  
✅ Indizierung und Slicing  
✅ Listen-Methoden (append, extend, insert, remove, pop, etc.)  
✅ Listen sortieren (sort, sorted, reverse)  
✅ List Comprehensions (elegante Kurzform)  
✅ Verschachtelte Listen (2D-Listen)  
✅ Listen kopieren (richtig!)  

---

## 🧠 Wichtige Takeaways

1. **Listen sind mutable** (veränderlich)
2. **Index beginnt bei 0**
3. **append()** für einzelnes Element, **extend()** für mehrere
4. **pop()** gibt Element zurück, **remove()** nicht
5. **Liste kopieren:** `liste[:]` oder `liste.copy()`
6. **List Comprehensions** = kürzer und schneller
7. **sort()** ändert Original, **sorted()** gibt neue Liste

---

## ➡️ Weiter geht's

In der nächsten Lektion lernst du über:
- **Tupel** - Unveränderliche Listen
- **Sets** - Mengen ohne Duplikate
- **Wann was verwenden?**

**Bereit? Auf zur [Lektion 6: Tupel](06_tupel.md)!**
