# 📝 Lektion 4: Strings im Detail

## 📖 Inhaltsverzeichnis
- [Was sind Strings?](#was-sind-strings)
- [Strings erstellen](#strings-erstellen)
- [String-Indizierung](#string-indizierung)
- [String-Slicing](#string-slicing)
- [String-Methoden](#string-methoden)
- [String-Formatierung](#string-formatierung)
- [Escape-Zeichen](#escape-zeichen)
- [Übungen](#übungen)

---

## 🤔 Was sind Strings?

**String** = Zeichenkette = Text

```python
"Hallo"      # String
'Python'     # String
"123"        # String (nicht Zahl!)
""           # Leerer String
```

### Strings sind Sequenzen

Ein String ist eine **Sequenz von Zeichen**:

```
"PYTHON"
 ↓↓↓↓↓↓
 P Y T H O N
 0 1 2 3 4 5  (Indizes)
```

Jedes Zeichen hat eine **Position** (Index).

---

## ✍️ Strings erstellen

### Einfache und doppelte Anführungszeichen

```python
# Beide gleich
name1 = "Max"
name2 = 'Max'

>>> name1 == name2
True
```

### Wann welche?

```python
# Wenn String ' enthält:
text = "Er sagte: 'Hallo'"

# Wenn String " enthält:
text = 'Sie fragte: "Wie geht es dir?"'

# Oder mit Escape:
text = "Sie fragte: \"Wie geht es dir?\""
```

### Mehrzeilige Strings

```python
# Mit """ oder '''
text = """Das ist
eine mehrzeilige
Nachricht"""

gedicht = '''Rosen sind rot,
Veilchen sind blau,
Python ist toll,
und das weißt du genau!'''

print(gedicht)
```

**Ausgabe:**
```
Rosen sind rot,
Veilchen sind blau,
Python ist toll,
und das weißt du genau!
```

### Raw Strings

Ignoriert Escape-Zeichen:

```python
# Normal
pfad = "C:\neuer\ordner"  # \n wird als Newline interpretiert

# Raw String
pfad = r"C:\neuer\ordner"  # Backslash bleibt Backslash
print(pfad)  # C:\neuer\ordner
```

---

## 🔢 String-Indizierung

### Positive Indizes

Index beginnt bei **0**:

```python
text = "PYTHON"
#       012345

>>> text[0]
'P'

>>> text[1]
'Y'

>>> text[5]
'N'

>>> text[6]
IndexError: string index out of range
```

**Letztes Zeichen:**
```python
text = "PYTHON"
letztes = text[len(text) - 1]
print(letztes)  # N
```

### Negative Indizes

Zählt von **hinten**:

```python
text = "PYTHON"
#      -6-5-4-3-2-1

>>> text[-1]
'N'  # Letztes Zeichen

>>> text[-2]
'O'  # Vorletztes

>>> text[-6]
'P'  # Erstes (von hinten gezählt)
```

**Praktisch:**
```python
text = "Hallo Welt"
print(text[-1])   # t
print(text[-4])   # W
```

### Länge eines Strings

```python
>>> len("Python")
6

>>> len("")
0

>>> len("Hallo Welt")
10  # Leerzeichen zählt mit!

>>> text = "Programmierung"
>>> print(f"'{text}' hat {len(text)} Zeichen")
'Programmierung' hat 14 Zeichen
```

---

## ✂️ String-Slicing

**Slicing** = Teilstring extrahieren

### Syntax

```python
string[start:end:step]
```

- **start**: Startindex (inklusive)
- **end**: Endindex (EXKLUSIVE!)
- **step**: Schrittweite (optional, default: 1)

### Grundlegendes Slicing

```python
text = "PYTHON"
#       012345

>>> text[0:3]
'PYT'  # Index 0, 1, 2 (nicht 3!)

>>> text[2:5]
'THO'  # Index 2, 3, 4

>>> text[1:4]
'YTH'
```

**Wichtig:** Der End-Index ist **NICHT** dabei!

```python
text = "PYTHON"
>>> text[0:6]
'PYTHON'  # 0 bis 5

>>> text[0:10]
'PYTHON'  # Geht nicht über String hinaus
```

### Start oder End weglassen

```python
text = "PYTHON"

# Vom Anfang:
>>> text[:3]
'PYT'  # Gleich wie text[0:3]

>>> text[:4]
'PYTH'

# Bis zum Ende:
>>> text[2:]
'THON'  # Von Index 2 bis Ende

>>> text[3:]
'HON'

# Alles:
>>> text[:]
'PYTHON'
```

### Mit negativen Indizes

```python
text = "PYTHON"

>>> text[-3:]
'HON'  # Letzte 3 Zeichen

>>> text[:-2]
'PYTH'  # Alle außer letzte 2

>>> text[-4:-1]
'THO'  # Von -4 bis -1 (exklusiv)
```

### Mit Schrittweite

```python
text = "PYTHON"

# Jedes 2. Zeichen:
>>> text[::2]
'PTO'  # Index 0, 2, 4

# Jedes 3. Zeichen:
>>> text[::3]
'PH'  # Index 0, 3

# Von Index 1, jedes 2. Zeichen:
>>> text[1::2]
'YHN'  # Index 1, 3, 5
```

### String umkehren

```python
text = "PYTHON"

>>> text[::-1]
'NOHTYP'  # Rückwärts!

>>> name = "Max"
>>> name[::-1]
'xaM'

# Palindrom prüfen:
wort = "radar"
ist_palindrom = wort == wort[::-1]
print(ist_palindrom)  # True
```

### Praktische Beispiele

```python
email = "max.mustermann@example.com"

# Username (vor @)
>>> email[:email.index("@")]
'max.mustermann'

# Domain (nach @)
>>> email[email.index("@")+1:]
'example.com'

# Erste 3 Zeichen
>>> email[:3]
'max'

# Letzte 3 Zeichen
>>> email[-3:]
'com'
```

---

## 🔧 String-Methoden

Strings haben viele eingebaute **Methoden**.

### Groß-/Kleinschreibung

```python
text = "Python"

# Alles Großbuchstaben
>>> text.upper()
'PYTHON'

# Alles Kleinbuchstaben
>>> text.lower()
'python'

# Erster Buchstabe groß
>>> text.capitalize()
'Python'

>>> "hallo welt".capitalize()
'Hallo welt'  # Nur das ERSTE Wort!

# Jedes Wort beginnt groß
>>> "hallo welt".title()
'Hallo Welt'

# Groß/Klein vertauschen
>>> "Python".swapcase()
'pYTHON'
```

**Praktisch für Vergleiche:**
```python
eingabe = input("Weiter? (ja/nein): ")

if eingabe.lower() == "ja":
    print("OK, weiter geht's!")
```

### Whitespace entfernen

```python
text = "  Hallo  "

# Beide Seiten
>>> text.strip()
'Hallo'

# Links
>>> text.lstrip()
'Hallo  '

# Rechts
>>> text.rstrip()
'  Hallo'

# Bestimmte Zeichen entfernen
>>> "***Hallo***".strip("*")
'Hallo'

>>> "...Test...".strip(".")
'Test'
```

**Praktisch:**
```python
# User-Input oft mit Leerzeichen
name = input("Name: ").strip()
# "  Max  " → "Max"
```

### Suchen und Prüfen

```python
text = "Python ist toll"

# Enthält?
>>> "Python" in text
True

>>> "Java" in text
False

# Beginnt mit?
>>> text.startswith("Python")
True

>>> text.startswith("Hallo")
False

# Endet mit?
>>> text.endswith("toll")
True

>>> text.endswith("!")
False

# Position finden
>>> text.find("ist")
7  # Index wo "ist" beginnt

>>> text.find("Java")
-1  # Nicht gefunden

# Index (wie find, aber Fehler wenn nicht gefunden)
>>> text.index("ist")
7

>>> text.index("Java")
ValueError: substring not found
```

**Praktisch:**
```python
email = "max@example.com"

if email.find("@") != -1 and email.endswith(".com"):
    print("Email scheint gültig")
```

### Zählen

```python
text = "Hallo Hallo Hallo"

>>> text.count("Hallo")
3

>>> text.count("l")
6

>>> text.count("x")
0
```

### Ersetzen

```python
text = "Hallo Welt"

>>> text.replace("Hallo", "Hi")
'Hi Welt'

>>> text.replace("Welt", "Python")
'Hallo Python'

# Mehrfach
>>> "aaabbbccc".replace("a", "x")
'xxxbbbccc'

# Limit setzen
>>> "aaabbbccc".replace("a", "x", 2)
'xxabbbccc'  # Nur erste 2
```

**Original bleibt unverändert:**
```python
>>> text = "Hallo"
>>> text.replace("Hallo", "Hi")
'Hi'
>>> print(text)
'Hallo'  # Unverändert!

# Wenn du es ändern willst:
>>> text = text.replace("Hallo", "Hi")
>>> print(text)
'Hi'
```

### Teilen und Verbinden

```python
# Split (String → Liste)
>>> text = "Hallo Welt Python"
>>> text.split()
['Hallo', 'Welt', 'Python']

>>> text = "Max,Anna,Tom"
>>> text.split(",")
['Max', 'Anna', 'Tom']

>>> text = "Zeile1\nZeile2\nZeile3"
>>> text.split("\n")
['Zeile1', 'Zeile2', 'Zeile3']

# Join (Liste → String)
>>> woerter = ["Hallo", "Welt"]
>>> " ".join(woerter)
'Hallo Welt'

>>> "-".join(["2024", "01", "15"])
'2024-01-15'

>>> "".join(["P", "y", "t", "h", "o", "n"])
'Python'
```

**Praktisch:**
```python
# CSV verarbeiten
csv_zeile = "Max,25,Berlin"
daten = csv_zeile.split(",")
name, alter, stadt = daten
print(f"Name: {name}, Alter: {alter}, Stadt: {stadt}")

# Path zusammensetzen
path_teile = ["home", "user", "documents", "file.txt"]
path = "/".join(path_teile)
print(path)  # home/user/documents/file.txt
```

### Typ-Prüfungen

```python
# Nur Buchstaben?
>>> "Python".isalpha()
True

>>> "Python3".isalpha()
False

# Nur Zahlen?
>>> "123".isdigit()
True

>>> "12.3".isdigit()
False

# Buchstaben oder Zahlen?
>>> "Python3".isalnum()
True

>>> "Python 3".isalnum()
False  # Leerzeichen

# Nur Leerzeichen?
>>> "   ".isspace()
True

# Nur Kleinbuchstaben?
>>> "python".islower()
True

# Nur Großbuchstaben?
>>> "PYTHON".isupper()
True
```

**Praktisch:**
```python
password = input("Password: ")

if not password.isalnum():
    print("Nur Buchstaben und Zahlen erlaubt!")
```

### Ausrichten

```python
text = "Python"

# Zentrieren
>>> text.center(20)
'       Python       '

>>> text.center(20, "*")
'*******Python*******'

# Linksbündig
>>> text.ljust(20)
'Python              '

>>> text.ljust(20, "-")
'Python--------------'

# Rechtsbündig
>>> text.rjust(20)
'              Python'

>>> text.rjust(20, "0")
'00000000000000Python'
```

**Praktisch:**
```python
print("Name".ljust(20) + "Alter")
print("-" * 25)
print("Max".ljust(20) + "25")
print("Anna".ljust(20) + "30")

# Ausgabe:
# Name                Alter
# -------------------------
# Max                 25
# Anna                30
```

---

## 🎨 String-Formatierung

### 1. f-Strings (Modern, Python 3.6+)

**Am besten und lesbarsten!**

```python
name = "Max"
alter = 25

# Einfach
>>> f"Ich bin {name}"
'Ich bin Max'

# Mehrere Variablen
>>> f"{name} ist {alter} Jahre alt"
'Max ist 25 Jahre alt'

# Berechnungen
>>> f"In 5 Jahren: {alter + 5}"
'In 5 Jahren: 30'

# Funktionsaufrufe
>>> f"Name groß: {name.upper()}"
'Name groß: MAX'
```

**Formatierung:**
```python
pi = 3.14159265

# Dezimalstellen
>>> f"Pi: {pi:.2f}"
'Pi: 3.14'

>>> f"Pi: {pi:.4f}"
'Pi: 3.1416'

# Breite
>>> f"Zahl: {42:5}"
'Zahl:    42'  # Rechtsbündig

>>> f"Zahl: {42:05}"
'Zahl: 00042'  # Mit Nullen

# Links-/Rechtsbündig
>>> f"{'Python':>10}"
'    Python'  # Rechtsbündig

>>> f"{'Python':<10}"
'Python    '  # Linksbündig

>>> f"{'Python':^10}"
'  Python  '  # Zentriert
```

**Praktisch:**
```python
artikel = "Apfel"
preis = 2.5
anzahl = 3

print(f"{artikel:<15} {anzahl:>3} × {preis:>6.2f}€ = {anzahl * preis:>7.2f}€")
# Apfel             3 ×   2.50€ =    7.50€
```

### 2. format() Methode

```python
name = "Max"
alter = 25

# Mit Positionen
>>> "Ich bin {} und {} Jahre alt".format(name, alter)
'Ich bin Max und 25 Jahre alt'

# Mit Indizes
>>> "{0} ist {1} Jahre alt. {0} wohnt in Berlin.".format(name, alter)
'Max ist 25 Jahre alt. Max wohnt in Berlin.'

# Mit Namen
>>> "{name} ist {alter} Jahre alt".format(name="Max", alter=25)
'Max ist 25 Jahre alt'
```

### 3. % Operator (Alt)

```python
name = "Max"
alter = 25

>>> "Ich bin %s und %d Jahre alt" % (name, alter)
'Ich bin Max und 25 Jahre alt'

# %s = String
# %d = Integer
# %f = Float

>>> "Pi: %.2f" % 3.14159
'Pi: 3.14'
```

**Empfehlung:** Verwende **f-Strings**! Am modernsten und lesbarsten.

---

## 🔤 Escape-Zeichen

Spezielle Zeichen mit **Backslash** `\`:

```python
# Neue Zeile
>>> print("Zeile 1\nZeile 2")
Zeile 1
Zeile 2

# Tab
>>> print("Name:\tMax")
Name:	Max

# Backslash
>>> print("C:\\Users\\Max")
C:\Users\Max

# Anführungszeichen
>>> print("Er sagte: \"Hallo\"")
Er sagte: "Hallo"

>>> print('It\'s Python')
It's Python

# Backspace (löscht vorheriges Zeichen)
>>> print("Hallo\bx")
Hallx
```

### Übersicht Escape-Zeichen

| Escape | Bedeutung | Beispiel |
|--------|-----------|----------|
| `\n` | Neue Zeile | `"Zeile1\nZeile2"` |
| `\t` | Tab | `"Name:\tMax"` |
| `\\` | Backslash | `"C:\\Users"` |
| `\'` | Einfaches Anführungszeichen | `'It\'s'` |
| `\"` | Doppeltes Anführungszeichen | `"\"Hi\""` |
| `\r` | Carriage Return | Selten |
| `\b` | Backspace | Selten |

### Raw Strings (r"")

Ignoriert Escape-Zeichen:

```python
# Normal
>>> print("C:\new\folder")
C:
ew\folder  # \n wird als Newline interpretiert!

# Raw
>>> print(r"C:\new\folder")
C:\new\folder  # Genau wie geschrieben
```

---

## 🎯 Praktische Beispiele

### Beispiel 1: Email-Validator

```python
email = input("Email: ").strip()

# Prüfungen
hat_at = "@" in email
hat_punkt = "." in email
laenge_ok = len(email) >= 5
at_position = email.find("@")
punkt_nach_at = at_position != -1 and "." in email[at_position:]

if hat_at and hat_punkt and laenge_ok and punkt_nach_at:
    print("✓ Email scheint gültig")
else:
    print("✗ Ungültige Email")
```

### Beispiel 2: Wort-Statistik

```python
text = input("Gib einen Text ein: ")

print(f"Zeichen gesamt: {len(text)}")
print(f"Zeichen (ohne Leerzeichen): {len(text.replace(' ', ''))}")
print(f"Wörter: {len(text.split())}")
print(f"Buchstabe 'e': {text.lower().count('e')}×")
print(f"Großbuchstaben: {sum(1 for c in text if c.isupper())}")
print(f"Kleinbuchstaben: {sum(1 for c in text if c.islower())}")
```

### Beispiel 3: Passwort-Generator

```python
import random
import string

laenge = int(input("Passwort-Länge: "))

# Zeichen-Pool
kleinbuchstaben = string.ascii_lowercase
grossbuchstaben = string.ascii_uppercase
zahlen = string.digits
sonderzeichen = "!@#$%^&*()"

alle_zeichen = kleinbuchstaben + grossbuchstaben + zahlen + sonderzeichen

passwort = ''.join(random.choice(alle_zeichen) for _ in range(laenge))
print(f"Dein Passwort: {passwort}")
```

### Beispiel 4: Text-Box

```python
def textbox(text, breite=40):
    # Oben
    print("┌" + "─" * (breite - 2) + "┐")
    
    # Text (zentriert)
    padding = (breite - 2 - len(text)) // 2
    zeile = "│" + " " * padding + text + " " * (breite - 2 - padding - len(text)) + "│"
    print(zeile)
    
    # Unten
    print("└" + "─" * (breite - 2) + "┘")

textbox("WILLKOMMEN", 30)
# ┌────────────────────────────┐
# │        WILLKOMMEN          │
# └────────────────────────────┘
```

---

## 📝 Übungen

### Übung 1: String-Basics
```python
text = "Python Programming"
# 1. Gib das 5. Zeichen aus
# 2. Gib die letzten 4 Zeichen aus
# 3. Gib jeden 2. Buchstaben aus
# 4. Kehre den String um
# 5. Wandle in Großbuchstaben um
```

### Übung 2: Slicing-Übung
```python
satz = "Ich lerne Python Programmierung"
# Extrahiere:
# - "lerne"
# - "Python"
# - "Programmierung"
# - "Ich lerne"
# - Alles außer "Ich "
```

### Übung 3: Name formatieren
Schreibe ein Programm:
```python
# Input: "max mustermann"
# Output: "Max Mustermann"
# (Jedes Wort groß)
```

### Übung 4: Wörter zählen
```python
text = input("Gib einen Satz ein: ")
# Zähle:
# - Anzahl Zeichen
# - Anzahl Wörter
# - Anzahl Vokale (a,e,i,o,u)
# - Häufigstes Zeichen
```

### Übung 5: Palindrom-Checker
```python
wort = input("Wort: ").lower()
# Prüfe ob Palindrom (vorwärts = rückwärts)
# z.B. "radar", "anna", "lol"
```

### Übung 6: Zensur
```python
text = input("Text: ")
bad_words = ["schlecht", "böse", "doof"]
# Ersetze jedes bad word mit "***"
```

### Übung 7: Initialen
```python
name = input("Voller Name: ")
# Extrahiere Initialen
# z.B. "Max Mustermann" → "M.M."
```

### Übung 8: Tabelle
Erstelle eine Tabelle:
```python
personen = [
    ("Max", 25, "Berlin"),
    ("Anna", 30, "München"),
    ("Tom", 22, "Hamburg")
]

# Ausgabe:
# Name      | Alter | Stadt
# ----------|-------|----------
# Max       |    25 | Berlin
# Anna      |    30 | München
# Tom       |    22 | Hamburg
```

---

## 🎓 Was du gelernt hast

✅ Strings erstellen (einfach, doppelt, mehrzeilig)  
✅ Indizierung (positiv und negativ)  
✅ Slicing (start:end:step)  
✅ Viele String-Methoden (upper, lower, split, join, etc.)  
✅ String-Formatierung (f-strings!)  
✅ Escape-Zeichen (\n, \t, \\)  

---

## 🧠 Wichtige Takeaways

1. **Strings sind immutable** (unveränderlich)
2. **Index startet bei 0**, negativ von hinten
3. **Slicing: [start:end:step]**, end ist exklusiv
4. **[::-1]** kehrt String um
5. **f-strings** für Formatierung nutzen!
6. **Methoden ändern Original nicht**, geben neuen String zurück
7. **.strip(), .lower()** für User-Input

---

## ➡️ Weiter geht's

In der nächsten Lektion lernst du über:
- **Listen** - Mehrere Werte speichern
- **Listen-Methoden** - append, remove, sort, etc.
- **List Comprehensions** - Elegante Listen-Erstellung

**Bereit? Auf zur [Lektion 5: Listen](05_listen.md)!**
