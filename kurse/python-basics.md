# 🐍 PYTHON BASICS - Dein Einstieg

## Lektion 1: Was ist Python?

### Quick Facts
- Python ist eine Programmiersprache (keine Schlange! 🐍)
- Super einfach zu lernen - perfekt für Anfänger
- Wird überall benutzt: Instagram, Spotify, Netflix - alles Python!

### Warum Python?
- **Lesbar:** Sieht fast aus wie normales Englisch
- **Mächtig:** Kannst damit fast alles bauen
- **Gefragt:** Top-Skill auf dem Arbeitsmarkt

---

## Lektion 2: Hello World!

### Dein erstes Programm
```python
print("Hello World!")
```

Das war's! Ernsthaft. Eine Zeile.

### Was passiert hier?
- `print()` = "Zeig mir was an"
- `"Hello World!"` = Der Text, der angezeigt wird (in Anführungszeichen!)

### 🎯 Übung
Ändere den Text zu deinem Namen:
```python
print("Hallo, ich bin [dein Name]!")
```

---

## Lektion 3: Variablen

### Was sind Variablen?
Variablen sind wie beschriftete Boxen für deine Daten.

```python
name = "Lisa"
alter = 22
groesse = 1.75
```

### Regeln für Variablennamen
✅ `mein_name` - Unterstriche okay
✅ `name2` - Zahlen okay (aber nicht am Anfang!)
❌ `2name` - NICHT am Anfang mit Zahl
❌ `mein name` - KEINE Leerzeichen!

### 🎯 Übung
Erstelle 3 Variablen über dich selbst!

---

## Lektion 4: Datentypen

### Die wichtigsten Typen

| Typ | Beispiel | Beschreibung |
|-----|----------|--------------|
| **String (str)** | `"Hallo"` | Text |
| **Integer (int)** | `42` | Ganze Zahlen |
| **Float** | `3.14` | Kommazahlen |
| **Boolean (bool)** | `True` / `False` | Wahr oder Falsch |

### Typ checken
```python
print(type("Hallo"))  # <class 'str'>
print(type(42))       # <class 'int'>
print(type(3.14))     # <class 'float'>
print(type(True))     # <class 'bool'>
```

---

## Lektion 5: Rechnen mit Python

### Grundrechenarten
```python
# Addition
ergebnis = 5 + 3      # 8

# Subtraktion
ergebnis = 10 - 4     # 6

# Multiplikation
ergebnis = 4 * 3      # 12

# Division
ergebnis = 15 / 3     # 5.0

# Ganzzahlige Division
ergebnis = 17 // 3    # 5

# Rest (Modulo)
ergebnis = 17 % 3     # 2

# Potenz
ergebnis = 2 ** 3     # 8 (2 hoch 3)
```

### 🎯 Übung
Berechne dein Alter in Tagen:
```python
alter = 22
tage = alter * 365
print(f"Ich bin ungefähr {tage} Tage alt!")
```

---

## Lektion 6: Input - User fragen

### So fragst du den User
```python
name = input("Wie heißt du? ")
print(f"Hey {name}! Nice!")
```

### Achtung bei Zahlen!
`input()` gibt IMMER einen String zurück!

```python
# Das funktioniert NICHT:
alter = input("Wie alt bist du? ")
naechstes_jahr = alter + 1  # ❌ Error!

# So geht's richtig:
alter = int(input("Wie alt bist du? "))
naechstes_jahr = alter + 1  # ✅ Funktioniert!
```

---

## Lektion 7: If-Else - Entscheidungen

### Grundstruktur
```python
alter = 18

if alter >= 18:
    print("Du bist volljährig! 🎉")
else:
    print("Noch nicht ganz...")
```

### Mit elif (else if)
```python
note = 2

if note == 1:
    print("Sehr gut!")
elif note == 2:
    print("Gut!")
elif note == 3:
    print("Befriedigend")
else:
    print("Da geht noch was...")
```

### Vergleichsoperatoren
| Operator | Bedeutung |
|----------|-----------|
| `==` | Gleich |
| `!=` | Nicht gleich |
| `<` | Kleiner als |
| `>` | Größer als |
| `<=` | Kleiner gleich |
| `>=` | Größer gleich |

---

## Lektion 8: Listen

### Was sind Listen?
Listen speichern mehrere Werte in einer Variable.

```python
freunde = ["Max", "Lisa", "Tom"]
zahlen = [1, 2, 3, 4, 5]
mix = ["Hallo", 42, True, 3.14]  # Verschiedene Typen möglich!
```

### Listen benutzen
```python
freunde = ["Max", "Lisa", "Tom"]

# Einzelnes Element (Index startet bei 0!)
print(freunde[0])  # "Max"
print(freunde[1])  # "Lisa"

# Letztes Element
print(freunde[-1])  # "Tom"

# Hinzufügen
freunde.append("Anna")

# Entfernen
freunde.remove("Tom")

# Länge
print(len(freunde))  # 3
```

---

## Lektion 9: For-Schleifen

### Durch Listen loopen
```python
freunde = ["Max", "Lisa", "Tom"]

for freund in freunde:
    print(f"Hey {freund}!")
```

### Mit range() zählen
```python
# 0 bis 4
for i in range(5):
    print(i)

# 1 bis 5
for i in range(1, 6):
    print(i)

# In 2er-Schritten
for i in range(0, 10, 2):
    print(i)  # 0, 2, 4, 6, 8
```

### 🎯 Übung
Print die Zahlen 1 bis 10:
```python
for zahl in range(1, 11):
    print(zahl)
```

---

## Lektion 10: Funktionen

### Warum Funktionen?
- Code wiederverwenden
- Übersichtlicher Code
- Weniger Copy-Paste

### Eine Funktion erstellen
```python
def sag_hallo(name):
    print(f"Hallo {name}!")

# Funktion aufrufen
sag_hallo("Max")  # "Hallo Max!"
sag_hallo("Lisa")  # "Hallo Lisa!"
```

### Mit Rückgabewert
```python
def addiere(a, b):
    return a + b

ergebnis = addiere(5, 3)
print(ergebnis)  # 8
```

---

## 🏆 MINI-PROJEKT: Zahlen-Rater

```python
import random

# Zufallszahl zwischen 1 und 10
geheime_zahl = random.randint(1, 10)
versuche = 0

print("Ich denke an eine Zahl zwischen 1 und 10...")

while True:
    tipp = int(input("Dein Tipp: "))
    versuche += 1
    
    if tipp == geheime_zahl:
        print(f"🎉 Richtig! Du hast es in {versuche} Versuchen geschafft!")
        break
    elif tipp < geheime_zahl:
        print("Zu niedrig! Versuch's nochmal.")
    else:
        print("Zu hoch! Versuch's nochmal.")
```

---

## 📝 Cheat Sheet

```python
# Variablen
name = "Max"
alter = 22

# Print mit f-String
print(f"Ich bin {name} und {alter} Jahre alt")

# Input
antwort = input("Frage? ")

# If-Else
if bedingung:
    # code
elif andere_bedingung:
    # code
else:
    # code

# Listen
liste = [1, 2, 3]
liste.append(4)  # hinzufügen
liste.remove(2)  # entfernen

# For-Schleife
for item in liste:
    print(item)

# Funktion
def meine_funktion(parameter):
    return ergebnis
```

---

**🎯 Du hast Python Basics geschafft! Weiter geht's mit Level 2!**
