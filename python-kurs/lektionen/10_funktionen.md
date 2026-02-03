# 🔧 Lektion 10: Funktionen

## 📖 Inhaltsverzeichnis
- [Was sind Funktionen?](#was-sind-funktionen)
- [Funktionen definieren](#funktionen-definieren)
- [Parameter und Argumente](#parameter-und-argumente)
- [Return-Werte](#return-werte)
- [Scope (Gültigkeitsbereich)](#scope)
- [Default-Parameter](#default-parameter)
- [*args und **kwargs](#args-und-kwargs)
- [Lambda-Funktionen](#lambda-funktionen)
- [Docstrings](#docstrings)
- [Übungen](#übungen)

---

## 🤔 Was sind Funktionen?

**Funktion** = Wiederverwendbarer Code-Block

### Die Rezept-Analogie

Stell dir ein **Kochrezept** vor:

```
FUNKTION: Kuchen_backen(mehl, zucker, eier)
    1. Mische Zutaten
    2. Backe 30 Minuten
    3. GEBE Kuchen zurück
```

In Python:

```python
def kuchen_backen(mehl, zucker, eier):
    # Schritte...
    return kuchen
```

### Warum Funktionen?

**Ohne Funktionen (Code-Wiederholung):**
```python
# Begrüßung 1
print("Hallo Max!")
print("Willkommen!")
print("Schön dass du da bist!")

# Begrüßung 2
print("Hallo Anna!")
print("Willkommen!")
print("Schön dass du da bist!")

# Mühsam! 😰
```

**Mit Funktion:**
```python
def begruesse(name):
    print(f"Hallo {name}!")
    print("Willkommen!")
    print("Schön dass du da bist!")

begruesse("Max")
begruesse("Anna")
# Viel besser! 🎉
```

### Vorteile

1. **Code-Wiederverwendung** - Einmal schreiben, oft nutzen
2. **Übersichtlichkeit** - Code in logische Blöcke aufteilen
3. **Wartbarkeit** - Änderung nur an einer Stelle
4. **Testing** - Funktionen einzeln testen

---

## ✍️ Funktionen definieren

### Syntax

```python
def funktionsname(parameter1, parameter2):
    """Docstring (optional)"""
    # Code der Funktion
    anweisungen
    return ergebnis  # optional
```

### Einfache Funktion

```python
def sage_hallo():
    print("Hallo!")

# Funktion aufrufen
sage_hallo()
# Ausgabe: Hallo!
```

### Mit Parametern

```python
def sage_hallo(name):
    print(f"Hallo {name}!")

sage_hallo("Max")
sage_hallo("Anna")

# Ausgabe:
# Hallo Max!
# Hallo Anna!
```

### Mehrere Parameter

```python
def addiere(a, b):
    ergebnis = a + b
    print(f"{a} + {b} = {ergebnis}")

addiere(5, 3)
addiere(10, 20)

# Ausgabe:
# 5 + 3 = 8
# 10 + 20 = 30
```

---

## 📥📤 Parameter und Argumente

### Begriffe

- **Parameter** = Variablen in Funktions-Definition
- **Argument** = Werte beim Funktions-Aufruf

```python
def funktion(parameter):  # Parameter
    pass

funktion(argument)  # Argument
```

### Positions-Argumente

**Reihenfolge wichtig!**

```python
def stelle_vor(name, alter, stadt):
    print(f"Ich bin {name}, {alter} Jahre alt, aus {stadt}")

stelle_vor("Max", 25, "Berlin")
# Ich bin Max, 25 Jahre alt, aus Berlin

stelle_vor("Berlin", "Max", 25)  # ❌ Falsch!
# Ich bin Berlin, Max Jahre alt, aus 25
```

### Keyword-Argumente

**Reihenfolge egal!**

```python
def stelle_vor(name, alter, stadt):
    print(f"Ich bin {name}, {alter} Jahre alt, aus {stadt}")

stelle_vor(name="Max", alter=25, stadt="Berlin")
stelle_vor(stadt="Berlin", name="Max", alter=25)  # ✅ Gleich!
stelle_vor(alter=25, stadt="Berlin", name="Max")  # ✅ Auch gleich!
```

### Gemischt

**Positions-Argumente MÜSSEN vor Keyword-Argumenten stehen:**

```python
# ✅ Richtig
stelle_vor("Max", alter=25, stadt="Berlin")

# ❌ Falsch
stelle_vor(name="Max", 25, "Berlin")
# SyntaxError!
```

---

## 🔙 Return-Werte

### Mit return

**Gibt Wert zurück:**

```python
def addiere(a, b):
    return a + b

ergebnis = addiere(5, 3)
print(ergebnis)  # 8

# Direkt verwenden
print(addiere(10, 20))  # 30
```

### Ohne return

**Gibt None zurück:**

```python
def sage_hallo():
    print("Hallo!")

ergebnis = sage_hallo()
print(ergebnis)  # None
```

### Mehrere Return-Werte

```python
def min_max(liste):
    return min(liste), max(liste)

minimum, maximum = min_max([1, 5, 3, 9, 2])
print(f"Min: {minimum}, Max: {maximum}")
# Min: 1, Max: 9
```

**Technisch: Tupel wird zurückgegeben:**
```python
def get_name_alter():
    return "Max", 25

# Als Tupel
daten = get_name_alter()
print(daten)  # ('Max', 25)

# Entpackt
name, alter = get_name_alter()
print(name)  # Max
print(alter)  # 25
```

### Frühes Return

```python
def ist_volljährig(alter):
    if alter >= 18:
        return True
    return False

# Kürzer:
def ist_volljährig(alter):
    return alter >= 18

print(ist_volljährig(20))  # True
print(ist_volljährig(15))  # False
```

### Return beendet Funktion

```python
def pruefe_zahl(zahl):
    if zahl < 0:
        return "Negativ"
    
    if zahl == 0:
        return "Null"
    
    return "Positiv"
    
    print("Diese Zeile wird NIE ausgeführt!")

print(pruefe_zahl(-5))  # Negativ
print(pruefe_zahl(0))   # Null
print(pruefe_zahl(10))  # Positiv
```

---

## 🌐 Scope (Gültigkeitsbereich)

### Lokale Variablen

**Nur innerhalb Funktion verfügbar:**

```python
def funktion():
    x = 10  # Lokale Variable
    print(x)

funktion()  # 10
print(x)    # ❌ NameError! x existiert hier nicht!
```

### Globale Variablen

**Außerhalb Funktion definiert:**

```python
x = 10  # Globale Variable

def funktion():
    print(x)  # Kann gelesen werden

funktion()  # 10
print(x)    # 10
```

### Lokale überschreibt Globale

```python
x = 10  # Global

def funktion():
    x = 20  # Lokale Variable (überschreibt nicht global!)
    print(x)

funktion()  # 20
print(x)    # 10 (unverändert!)
```

### global-Keyword

**Globale Variable ändern:**

```python
x = 10

def funktion():
    global x  # Jetzt wird globale x verwendet
    x = 20
    print(x)

funktion()  # 20
print(x)    # 20 (geändert!)
```

**⚠️ Best Practice:** Vermeide `global`! Verwende stattdessen Return.

```python
# ❌ Mit global (schlecht)
counter = 0

def increment():
    global counter
    counter += 1

# ✅ Ohne global (besser)
def increment(counter):
    return counter + 1

counter = 0
counter = increment(counter)
```

---

## 🎯 Default-Parameter

**Standard-Wert wenn Argument fehlt:**

```python
def begruesse(name, gruss="Hallo"):
    print(f"{gruss} {name}!")

begruesse("Max")              # Hallo Max!
begruesse("Anna", "Hi")       # Hi Anna!
begruesse("Tom", gruss="Hey") # Hey Tom!
```

### Mehrere Default-Parameter

```python
def stelle_vor(name, alter=0, stadt="Unbekannt"):
    print(f"{name}, {alter} Jahre, aus {stadt}")

stelle_vor("Max")                      # Max, 0 Jahre, aus Unbekannt
stelle_vor("Anna", 25)                 # Anna, 25 Jahre, aus Unbekannt
stelle_vor("Tom", 30, "Berlin")        # Tom, 30 Jahre, aus Berlin
stelle_vor("Lisa", stadt="München")    # Lisa, 0 Jahre, aus München
```

### ⚠️ Wichtig: Default-Parameter am Ende!

```python
# ❌ Fehler
def funktion(a=1, b):  # SyntaxError!
    pass

# ✅ Richtig
def funktion(b, a=1):
    pass
```

### Veränderbare Default-Werte vermeiden!

```python
# ❌ PROBLEM!
def add_item(item, liste=[]):
    liste.append(item)
    return liste

print(add_item(1))  # [1]
print(add_item(2))  # [1, 2] ← Überraschung!
print(add_item(3))  # [1, 2, 3]

# ✅ RICHTIG
def add_item(item, liste=None):
    if liste is None:
        liste = []
    liste.append(item)
    return liste

print(add_item(1))  # [1]
print(add_item(2))  # [2] ✓
print(add_item(3))  # [3] ✓
```

---

## 📦 *args und **kwargs

### *args - Variable Anzahl von Argumenten

**Tupel mit allen Argumenten:**

```python
def addiere(*zahlen):
    print(type(zahlen))  # <class 'tuple'>
    return sum(zahlen)

print(addiere(1, 2))           # 3
print(addiere(1, 2, 3, 4, 5))  # 15
print(addiere(10))             # 10
```

**Beispiele:**

```python
def durchschnitt(*zahlen):
    if not zahlen:
        return 0
    return sum(zahlen) / len(zahlen)

print(durchschnitt(1, 2, 3, 4, 5))  # 3.0
print(durchschnitt(10, 20))         # 15.0

def liste_werte(*werte):
    for i, wert in enumerate(werte, 1):
        print(f"{i}. {wert}")

liste_werte("Apfel", "Banane", "Kirsche")
# 1. Apfel
# 2. Banane
# 3. Kirsche
```

### **kwargs - Variable Keyword-Argumente

**Dictionary mit allen Keyword-Argumenten:**

```python
def zeige_info(**daten):
    print(type(daten))  # <class 'dict'>
    for key, value in daten.items():
        print(f"{key}: {value}")

zeige_info(name="Max", alter=25, stadt="Berlin")
# name: Max
# alter: 25
# stadt: Berlin
```

**Beispiele:**

```python
def erstelle_profil(**infos):
    profil = {
        "name": infos.get("name", "Unbekannt"),
        "alter": infos.get("alter", 0),
        "stadt": infos.get("stadt", "Unbekannt")
    }
    return profil

p1 = erstelle_profil(name="Max", alter=25)
p2 = erstelle_profil(name="Anna", stadt="München", beruf="Lehrerin")

print(p1)
# {'name': 'Max', 'alter': 25, 'stadt': 'Unbekannt'}
```

### Kombination: Parameter, *args, **kwargs

**Reihenfolge:** `parameter, *args, **kwargs`

```python
def funktion(a, b, *args, **kwargs):
    print(f"a: {a}")
    print(f"b: {b}")
    print(f"args: {args}")
    print(f"kwargs: {kwargs}")

funktion(1, 2, 3, 4, 5, x=10, y=20)

# Ausgabe:
# a: 1
# b: 2
# args: (3, 4, 5)
# kwargs: {'x': 10, 'y': 20}
```

---

## ⚡ Lambda-Funktionen

**Anonyme Ein-Zeilen-Funktionen:**

### Syntax

```python
lambda parameter: ausdruck
```

### Einfache Beispiele

```python
# Normal
def quadrat(x):
    return x ** 2

# Lambda
quadrat = lambda x: x ** 2

print(quadrat(5))  # 25
```

**Weitere Beispiele:**

```python
# Summe
addiere = lambda a, b: a + b
print(addiere(5, 3))  # 8

# Maximum
maximum = lambda a, b: a if a > b else b
print(maximum(10, 20))  # 20

# Gerade?
ist_gerade = lambda x: x % 2 == 0
print(ist_gerade(4))  # True
```

### Mit map()

```python
zahlen = [1, 2, 3, 4, 5]

# Alle quadrieren
quadrate = list(map(lambda x: x**2, zahlen))
print(quadrate)  # [1, 4, 9, 16, 25]

# Alle verdoppeln
doppelt = list(map(lambda x: x*2, zahlen))
print(doppelt)  # [2, 4, 6, 8, 10]
```

### Mit filter()

```python
zahlen = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

# Nur gerade
gerade = list(filter(lambda x: x % 2 == 0, zahlen))
print(gerade)  # [2, 4, 6, 8, 10]

# Nur größer als 5
gross = list(filter(lambda x: x > 5, zahlen))
print(gross)  # [6, 7, 8, 9, 10]
```

### Mit sorted()

```python
personen = [
    {"name": "Max", "alter": 25},
    {"name": "Anna", "alter": 30},
    {"name": "Tom", "alter": 22}
]

# Nach Alter sortieren
sortiert = sorted(personen, key=lambda p: p["alter"])
print(sortiert)
# [{'name': 'Tom', 'alter': 22}, {'name': 'Max', 'alter': 25}, {'name': 'Anna', 'alter': 30}]

# Nach Name sortieren
sortiert = sorted(personen, key=lambda p: p["name"])
```

---

## 📄 Docstrings

**Dokumentation für Funktionen:**

### Syntax

```python
def funktion(parameter):
    """Das ist ein Docstring.
    
    Erklärt was die Funktion macht.
    """
    pass
```

### Einfaches Beispiel

```python
def addiere(a, b):
    """Addiert zwei Zahlen und gibt das Ergebnis zurück."""
    return a + b

# Docstring abrufen
print(addiere.__doc__)
# Addiert zwei Zahlen und gibt das Ergebnis zurück.

# Mit help()
help(addiere)
```

### Ausführlicher Docstring

```python
def berechne_durchschnitt(zahlen):
    """
    Berechnet den Durchschnitt einer Liste von Zahlen.
    
    Args:
        zahlen (list): Liste von Zahlen
    
    Returns:
        float: Durchschnitt der Zahlen
        
    Raises:
        ValueError: Wenn Liste leer ist
    
    Examples:
        >>> berechne_durchschnitt([1, 2, 3, 4, 5])
        3.0
        >>> berechne_durchschnitt([10, 20])
        15.0
    """
    if not zahlen:
        raise ValueError("Liste darf nicht leer sein")
    return sum(zahlen) / len(zahlen)
```

---

## 🎯 Praktische Beispiele

### 1. Temperatur-Umrechner

```python
def celsius_zu_fahrenheit(celsius):
    """Wandelt Celsius in Fahrenheit um."""
    return celsius * 9/5 + 32

def fahrenheit_zu_celsius(fahrenheit):
    """Wandelt Fahrenheit in Celsius um."""
    return (fahrenheit - 32) * 5/9

print(celsius_zu_fahrenheit(0))    # 32.0
print(celsius_zu_fahrenheit(100))  # 212.0
print(fahrenheit_zu_celsius(32))   # 0.0
```

### 2. Passwort-Validator

```python
def ist_passwort_sicher(passwort, min_laenge=8):
    """
    Prüft ob Passwort sicher ist.
    
    Kriterien:
    - Mindestlänge
    - Mindestens 1 Zahl
    - Mindestens 1 Großbuchstabe
    - Mindestens 1 Kleinbuchstabe
    """
    if len(passwort) < min_laenge:
        return False, "Zu kurz"
    
    if not any(c.isdigit() for c in passwort):
        return False, "Keine Zahl"
    
    if not any(c.isupper() for c in passwort):
        return False, "Kein Großbuchstabe"
    
    if not any(c.islower() for c in passwort):
        return False, "Kein Kleinbuchstabe"
    
    return True, "Sicher"

sicher, grund = ist_passwort_sicher("Test123")
print(f"Sicher: {sicher}, Grund: {grund}")
```

### 3. Liste filtern und transformieren

```python
def verarbeite_liste(liste, filter_func=None, map_func=None):
    """
    Filtert und transformiert Liste.
    
    Args:
        liste: Input-Liste
        filter_func: Filterfunktion (optional)
        map_func: Transformationsfunktion (optional)
    """
    ergebnis = liste
    
    if filter_func:
        ergebnis = [x for x in ergebnis if filter_func(x)]
    
    if map_func:
        ergebnis = [map_func(x) for x in ergebnis]
    
    return ergebnis

zahlen = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

# Nur gerade, dann quadrieren
ergebnis = verarbeite_liste(
    zahlen,
    filter_func=lambda x: x % 2 == 0,
    map_func=lambda x: x ** 2
)
print(ergebnis)  # [4, 16, 36, 64, 100]
```

---

## 📝 Übungen

### Übung 1: Grundlagen
```python
# Schreibe Funktionen:
# a) ist_gerade(zahl) → True/False
# b) maximum(a, b, c) → größte Zahl
# c) laenge_text(text) → Anzahl Zeichen ohne Leerzeichen
```

### Übung 2: Rechner
```python
# Erstelle Taschenrechner mit Funktionen:
# - addiere(a, b)
# - subtrahiere(a, b)
# - multipliziere(a, b)
# - dividiere(a, b) (mit Fehlerbehandlung!)
```

### Übung 3: Listen-Funktionen
```python
# Schreibe:
# a) finde_maximum(liste)
# b) summe_gerade(liste) → Summe aller geraden Zahlen
# c) entferne_duplikate(liste) → Liste ohne Duplikate
```

### Übung 4: String-Funktionen
```python
# Schreibe:
# a) zaehle_woerter(text)
# b) reverse_text(text) → Text rückwärts
# c) ist_palindrom(text) → True/False
```

### Übung 5: Mit Return
```python
# primfaktoren(zahl) → Liste der Primfaktoren
# Beispiel: primfaktoren(12) → [2, 2, 3]
```

### Übung 6: Default-Parameter
```python
# erstelle_rechteck(breite, hoehe=None, zeichen="*")
# Wenn hoehe=None: mache Quadrat
# Zeichne Rechteck aus zeichen
```

### Übung 7: *args
```python
# berechne_statistik(*zahlen)
# Gibt zurück: Dict mit min, max, durchschnitt, summe
```

### Übung 8: Komplexe Funktion
```python
# wort_statistik(text)
# Gibt Dict zurück mit:
# - anzahl_woerter
# - anzahl_zeichen
# - durchschnittliche_wortlaenge
# - laengstes_wort
# - haefigstes_wort
```

---

## 🎓 Was du gelernt hast

✅ Funktionen definieren mit `def`  
✅ Parameter und Argumente  
✅ Return-Werte  
✅ Scope (lokal vs global)  
✅ Default-Parameter  
✅ *args und **kwargs  
✅ Lambda-Funktionen  
✅ Docstrings  

---

## 🧠 Wichtige Takeaways

1. **def funktionsname(parameter):** für Definition
2. **return** gibt Wert zurück, beendet Funktion
3. **Lokale Variablen** nur in Funktion sichtbar
4. **Default-Parameter** müssen am Ende stehen
5. ***args** für variable Anzahl Argumente (Tupel)
6. ****kwargs** für variable Keyword-Argumente (Dict)
7. **Lambda** für kurze anonyme Funktionen
8. **Docstrings** für Dokumentation

---

## ➡️ Weiter geht's

Glückwunsch! Du hast die Grundlagen von Python gemeistert!

**Was als nächstes?**
- Module und Imports
- Fehlerbehandlung (try/except)
- Dateioperationen
- Objektorientierung
- Projekte bauen!

**Starte mit echten Projekten:**
- Todo-Liste
- Passwort-Manager
- Taschenrechner
- Spiele (Tic-Tac-Toe, Snake, etc.)

**Keep coding! 🚀**
