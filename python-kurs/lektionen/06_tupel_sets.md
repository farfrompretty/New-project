# 📦 Lektion 6: Tupel und Sets

## 📖 Inhaltsverzeichnis
- [Tupel - Unveränderliche Listen](#tupel)
- [Sets - Mengen ohne Duplikate](#sets)
- [Vergleich: Liste vs Tupel vs Set](#vergleich)
- [Übungen](#übungen)

---

## 🔒 TUPEL - Unveränderliche Listen

### Was sind Tupel?

**Tupel** = Unveränderliche Liste

```python
# Liste (mutable)
liste = [1, 2, 3]
liste[0] = 100  # ✅ Funktioniert

# Tupel (immutable)
tupel = (1, 2, 3)
tupel[0] = 100  # ❌ TypeError!
```

### Tupel erstellen

```python
# Mit Klammern
>>> t1 = (1, 2, 3)
>>> t2 = ("a", "b", "c")
>>> t3 = (1, "Hallo", 3.14, True)

# Ohne Klammern (auch möglich)
>>> t4 = 1, 2, 3
>>> type(t4)
<class 'tuple'>

# Leeres Tupel
>>> leer = ()
>>> type(leer)
<class 'tuple'>

# Tupel mit einem Element (Komma wichtig!)
>>> t5 = (5,)  # ✅ Tupel
>>> type(t5)
<class 'tuple'>

>>> t6 = (5)  # ❌ Keine Tupel, nur int!
>>> type(t6)
<class 'int'>
```

### Tupel-Indizierung

**Genau wie bei Listen:**

```python
>>> tupel = ("Apfel", "Banane", "Kirsche")

>>> tupel[0]
'Apfel'

>>> tupel[-1]
'Kirsche'

>>> tupel[1:3]
('Banane', 'Kirsche')

>>> len(tupel)
3
```

### ABER: Keine Änderungen!

```python
>>> tupel = (1, 2, 3)

>>> tupel[0] = 100
TypeError: 'tuple' object does not support item assignment

>>> tupel.append(4)
AttributeError: 'tuple' object has no attribute 'append'

>>> del tupel[0]
TypeError: 'tuple' object doesn't support item deletion
```

### Tupel-Methoden (nur 2!)

```python
# count() - Wie oft vorhanden?
>>> tupel = (1, 2, 2, 3, 2, 4)
>>> tupel.count(2)
3

# index() - Position finden
>>> tupel = ("a", "b", "c", "d")
>>> tupel.index("c")
2
```

### Tupel-Packing und Unpacking

**Packing:**
```python
>>> tupel = 1, 2, 3  # Werte werden "eingepackt"
>>> print(tupel)
(1, 2, 3)
```

**Unpacking:**
```python
>>> tupel = (1, 2, 3)
>>> a, b, c = tupel  # Werte werden "ausgepackt"
>>> print(a)
1
>>> print(b)
2
>>> print(c)
3
```

**Praktisch:**
```python
# Werte tauschen
>>> x, y = 10, 20
>>> x, y = y, x  # Swap!
>>> print(x, y)
20 10

# Mehrere Return-Werte
def min_max(liste):
    return min(liste), max(liste)

minimum, maximum = min_max([1, 5, 3, 9, 2])
print(f"Min: {minimum}, Max: {maximum}")

# Extended Unpacking
>>> a, *rest, b = [1, 2, 3, 4, 5]
>>> print(a)
1
>>> print(rest)
[2, 3, 4]
>>> print(b)
5
```

### Warum Tupel verwenden?

**1. Unveränderlichkeit = Sicherheit**
```python
koordinaten = (52.5200, 13.4050)  # Berlin
# Niemand kann es versehentlich ändern!
```

**2. Schneller als Listen**
```python
import timeit

liste_zeit = timeit.timeit(lambda: [1, 2, 3, 4, 5], number=1000000)
tupel_zeit = timeit.timeit(lambda: (1, 2, 3, 4, 5), number=1000000)

# Tupel ist schneller!
```

**3. Als Dictionary-Keys**
```python
# Liste geht nicht:
# d = {[1, 2]: "value"}  # ❌ TypeError

# Tupel geht:
d = {(1, 2): "value"}  # ✅
```

**4. Funktions-Rückgabewerte**
```python
def get_user():
    return "Max", 25, "Berlin"  # Automatisch Tupel!

name, alter, stadt = get_user()
```

### Tupel in Listen (und umgekehrt)

```python
# Tupel → Liste
>>> t = (1, 2, 3)
>>> l = list(t)
>>> print(l)
[1, 2, 3]

# Liste → Tupel
>>> l = [1, 2, 3]
>>> t = tuple(l)
>>> print(t)
(1, 2, 3)
```

---

## 🎲 SETS - Mengen ohne Duplikate

### Was sind Sets?

**Set** = Menge (Mathematik)

Eigenschaften:
- ✅ Keine Duplikate
- ✅ Ungeordnet (keine Indizierung!)
- ✅ Mutable (veränderlich)
- ✅ Schnelle Mitgliedschaftsprüfung

```python
>>> zahlen = {1, 2, 3, 4, 5}
>>> type(zahlen)
<class 'set'>

# Automatisch Duplikate entfernt!
>>> zahlen = {1, 2, 2, 3, 3, 3}
>>> print(zahlen)
{1, 2, 3}
```

### Set erstellen

```python
# Mit geschweiften Klammern
>>> s1 = {1, 2, 3}
>>> s2 = {"a", "b", "c"}

# Mit set()
>>> s3 = set([1, 2, 3])
>>> s4 = set("Python")
>>> print(s4)
{'P', 'y', 't', 'h', 'o', 'n'}  # Keine Duplikate!

# Leeres Set (NICHT {})
>>> leer = set()  # ✅
>>> falsch = {}  # ❌ Das ist ein Dict!
>>> type(falsch)
<class 'dict'>
```

### KEINE Indizierung!

```python
>>> s = {1, 2, 3}
>>> s[0]
TypeError: 'set' object is not subscriptable

# Sets sind ungeordnet!
>>> {1, 2, 3} == {3, 2, 1}
True  # Reihenfolge egal!
```

### Set-Methoden

**add() - Element hinzufügen:**
```python
>>> s = {1, 2, 3}
>>> s.add(4)
>>> print(s)
{1, 2, 3, 4}

>>> s.add(2)  # Schon vorhanden
>>> print(s)
{1, 2, 3, 4}  # Keine Änderung
```

**remove() - Element entfernen:**
```python
>>> s = {1, 2, 3}
>>> s.remove(2)
>>> print(s)
{1, 3}

>>> s.remove(10)
KeyError: 10  # Fehler wenn nicht vorhanden!
```

**discard() - Sicher entfernen:**
```python
>>> s = {1, 2, 3}
>>> s.discard(2)
>>> print(s)
{1, 3}

>>> s.discard(10)  # Kein Fehler!
>>> print(s)
{1, 3}
```

**pop() - Zufälliges Element entfernen:**
```python
>>> s = {1, 2, 3}
>>> element = s.pop()
>>> print(element)
1  # (Kann auch 2 oder 3 sein!)
>>> print(s)
{2, 3}
```

**clear() - Alles löschen:**
```python
>>> s = {1, 2, 3}
>>> s.clear()
>>> print(s)
set()
```

### Set-Operationen (Mathematik!)

**Union (Vereinigung) - Alle Elemente:**
```python
>>> a = {1, 2, 3}
>>> b = {3, 4, 5}

>>> a | b  # Operator
{1, 2, 3, 4, 5}

>>> a.union(b)  # Methode
{1, 2, 3, 4, 5}
```

**Intersection (Schnittmenge) - Gemeinsame:**
```python
>>> a = {1, 2, 3}
>>> b = {2, 3, 4}

>>> a & b  # Operator
{2, 3}

>>> a.intersection(b)  # Methode
{2, 3}
```

**Difference (Differenz) - Nur in a:**
```python
>>> a = {1, 2, 3}
>>> b = {2, 3, 4}

>>> a - b  # Operator
{1}

>>> a.difference(b)  # Methode
{1}
```

**Symmetric Difference - Nicht gemeinsam:**
```python
>>> a = {1, 2, 3}
>>> b = {2, 3, 4}

>>> a ^ b  # Operator
{1, 4}

>>> a.symmetric_difference(b)  # Methode
{1, 4}
```

**Praktisches Beispiel:**
```python
mathe_klasse = {"Max", "Anna", "Tom", "Lisa"}
deutsch_klasse = {"Anna", "Tom", "Ben", "Sara"}

# Beide Klassen
beide = mathe_klasse | deutsch_klasse
print("Alle Schüler:", beide)

# In beiden Klassen
gemeinsam = mathe_klasse & deutsch_klasse
print("Beide Kurse:", gemeinsam)

# Nur Mathe
nur_mathe = mathe_klasse - deutsch_klasse
print("Nur Mathe:", nur_mathe)

# Nur einer der Kurse
nur_einer = mathe_klasse ^ deutsch_klasse
print("Nur ein Kurs:", nur_einer)
```

### Set-Prüfungen

**Mitgliedschaft:**
```python
>>> s = {1, 2, 3, 4, 5}

>>> 3 in s
True

>>> 10 in s
False

>>> 10 not in s
True
```

**Teilmenge / Obermenge:**
```python
>>> a = {1, 2}
>>> b = {1, 2, 3, 4}

# Ist a Teilmenge von b?
>>> a.issubset(b)
True

>>> a <= b  # Operator
True

# Ist b Obermenge von a?
>>> b.issuperset(a)
True

>>> b >= a  # Operator
True

# Disjunkt (keine gemeinsamen Elemente)?
>>> {1, 2}.isdisjoint({3, 4})
True

>>> {1, 2}.isdisjoint({2, 3})
False
```

### Duplikate entfernen

**Häufigster Anwendungsfall:**
```python
# Liste mit Duplikaten
>>> liste = [1, 2, 2, 3, 1, 4, 3, 5]

# Zu Set (Duplikate weg)
>>> eindeutig = set(liste)
>>> print(eindeutig)
{1, 2, 3, 4, 5}

# Zurück zu Liste
>>> liste_eindeutig = list(eindeutig)
>>> print(liste_eindeutig)
[1, 2, 3, 4, 5]
```

**Praktisch:**
```python
# Eindeutige Wörter in Text
text = "Python ist toll Python macht Spaß Python ist einfach"
woerter = text.split()
eindeutige_woerter = set(woerter)
print(f"{len(eindeutige_woerter)} eindeutige Wörter")
```

### Frozen Sets

**Unveränderliche Sets:**
```python
>>> fs = frozenset([1, 2, 3])

>>> fs.add(4)
AttributeError: 'frozenset' object has no attribute 'add'

# Kann als Dict-Key verwendet werden
>>> d = {fs: "value"}  # ✅
```

---

## 📊 VERGLEICH: Liste vs Tupel vs Set

| Eigenschaft | Liste | Tupel | Set |
|-------------|-------|-------|-----|
| **Syntax** | `[1, 2, 3]` | `(1, 2, 3)` | `{1, 2, 3}` |
| **Mutable** | ✅ Ja | ❌ Nein | ✅ Ja |
| **Geordnet** | ✅ Ja | ✅ Ja | ❌ Nein |
| **Duplikate** | ✅ Ja | ✅ Ja | ❌ Nein |
| **Indizierung** | ✅ Ja | ✅ Ja | ❌ Nein |
| **Verwendung** | Allgemein | Feste Daten | Eindeutige Werte |

### Wann was verwenden?

**Liste:**
```python
# Sammlung die sich ändert
einkaufsliste = ["Milch", "Brot"]
einkaufsliste.append("Eier")

# Reihenfolge wichtig
top_10_songs = ["Song1", "Song2", "Song3", ...]

# Duplikate erlaubt
noten = [1, 2, 2, 3, 1, 4]
```

**Tupel:**
```python
# Feste Daten
koordinaten = (52.5200, 13.4050)
rgb_farbe = (255, 128, 0)

# Funktions-Rückgabe
def get_dimensions():
    return (1920, 1080)

# Als Dict-Key
positionen = {(0, 0): "Start", (10, 10): "Ziel"}
```

**Set:**
```python
# Duplikate entfernen
eindeutig = set([1, 2, 2, 3, 3])

# Mitgliedschaftsprüfung (schnell!)
erlaubte_user = {"admin", "user1", "user2"}
if username in erlaubte_user:
    print("Zugriff gewährt")

# Mengenoperationen
tags_post1 = {"python", "coding", "tutorial"}
tags_post2 = {"python", "learning", "tutorial"}
gemeinsame_tags = tags_post1 & tags_post2
```

---

## 📝 Übungen

### Übung 1: Tupel Unpacking
```python
person = ("Max", 25, "Berlin")
# Entpacke in name, alter, stadt
# Gib aus: "Max ist 25 Jahre alt und wohnt in Berlin"
```

### Übung 2: Werte tauschen
```python
a = 100
b = 200
# Tausche Werte mit Tupel-Unpacking
```

### Übung 3: Duplikate entfernen
```python
zahlen = [1, 2, 3, 2, 4, 1, 5, 3, 6]
# Entferne Duplikate
# Sortiere das Ergebnis
```

### Übung 4: Gemeinsame Freunde
```python
freunde_max = {"Anna", "Tom", "Lisa", "Ben"}
freunde_anna = {"Tom", "Lisa", "Sara", "Max"}

# Finde:
# - Gemeinsame Freunde
# - Nur Max's Freunde
# - Alle Freunde zusammen
```

### Übung 5: Eindeutige Zeichen
```python
text = input("Gib einen Text ein: ")
# Finde alle eindeutigen Zeichen (ohne Leerzeichen)
# Wie viele sind es?
```

### Übung 6: Prüfungen
```python
a = {1, 2, 3, 4, 5}
b = {2, 4}

# Prüfe:
# - Ist b Teilmenge von a?
# - Was ist a - b?
# - Was ist a | {6, 7}?
```

### Übung 7: Koordinaten
```python
# Erstelle Tupel für Koordinaten
punkt1 = (3, 4)
punkt2 = (6, 8)

# Berechne Distanz: √((x2-x1)² + (y2-y1)²)
```

### Übung 8: Wort-Analyse
```python
text = "Python ist toll Python macht Spaß"

# Finde:
# - Anzahl eindeutiger Wörter
# - Welche Wörter kommen mehrfach vor?
# - Durchschnittliche Wortlänge
```

---

## 🎓 Was du gelernt hast

✅ **Tupel** - Unveränderliche Listen  
✅ Tupel-Packing und Unpacking  
✅ **Sets** - Mengen ohne Duplikate  
✅ Set-Operationen (Union, Intersection, etc.)  
✅ Unterschiede: Liste vs Tupel vs Set  
✅ Wann was verwenden  

---

## 🧠 Wichtige Takeaways

1. **Tupel**: `(1, 2, 3)` - immutable, geordnet
2. **Set**: `{1, 2, 3}` - mutable, ungeordnet, keine Duplikate
3. **Tupel** für feste Daten (Koordinaten, RGB, etc.)
4. **Set** zum Duplikate entfernen
5. **Set-Operationen**: `|` (union), `&` (intersection), `-` (difference)
6. **Tupel Unpacking**: `a, b, c = tupel`
7. `in` ist bei Sets am schnellsten!

---

## ➡️ Weiter geht's

In der nächsten Lektion lernst du über:
- **Dictionaries** - Key-Value Paare
- **Dict-Methoden** - Zugriff und Manipulation
- **Wann Dicts verwenden?**

**Bereit? Auf zur [Lektion 7: Dictionaries](07_dictionaries.md)!**
