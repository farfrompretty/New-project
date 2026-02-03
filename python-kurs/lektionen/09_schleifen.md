# 🔁 Lektion 9: Schleifen (for & while)

## 📖 Inhaltsverzeichnis
- [Was sind Schleifen?](#was-sind-schleifen)
- [while-Schleife](#while-schleife)
- [for-Schleife](#for-schleife)
- [range()](#range)
- [break und continue](#break-und-continue)
- [else bei Schleifen](#else-bei-schleifen)
- [Verschachtelte Schleifen](#verschachtelte-schleifen)
- [Praktische Beispiele](#praktische-beispiele)
- [Übungen](#übungen)

---

## 🤔 Was sind Schleifen?

**Schleifen** = Code wiederholen

### Ohne Schleife

```python
print("Python!")
print("Python!")
print("Python!")
print("Python!")
print("Python!")
# Mühsam! 😰
```

### Mit Schleife

```python
for i in range(5):
    print("Python!")
# Viel besser! 🎉
```

### Zwei Arten

1. **while** - Solange Bedingung wahr ist
2. **for** - Über Elemente iterieren

---

## ⚡ while-Schleife

### Syntax

```python
while bedingung:
    # Code wird wiederholt solange bedingung True ist
    anweisungen
```

### Einfaches Beispiel

```python
# Zähle von 1 bis 5
zahl = 1

while zahl <= 5:
    print(zahl)
    zahl += 1

# Ausgabe:
# 1
# 2
# 3
# 4
# 5
```

**Schritt für Schritt:**
1. `zahl = 1` → Bedingung `1 <= 5` = True → print(1), zahl wird 2
2. `zahl = 2` → Bedingung `2 <= 5` = True → print(2), zahl wird 3
3. `zahl = 3` → Bedingung `3 <= 5` = True → print(3), zahl wird 4
4. `zahl = 4` → Bedingung `4 <= 5` = True → print(4), zahl wird 5
5. `zahl = 5` → Bedingung `5 <= 5` = True → print(5), zahl wird 6
6. `zahl = 6` → Bedingung `6 <= 5` = False → Schleife endet

### Countdown

```python
countdown = 10

while countdown > 0:
    print(countdown)
    countdown -= 1

print("Start!")

# Ausgabe:
# 10
# 9
# 8
# ...
# 1
# Start!
```

### User-Input wiederholen

```python
password = ""

while password != "geheim":
    password = input("Passwort: ")
    if password != "geheim":
        print("Falsch! Versuche es nochmal.")

print("Richtig! Zugang gewährt.")
```

### Summe berechnen

```python
summe = 0
zahl = 1

while zahl <= 100:
    summe += zahl
    zahl += 1

print(f"Summe von 1-100: {summe}")
# Ausgabe: Summe von 1-100: 5050
```

### ⚠️ Endlosschleife vermeiden!

```python
# ❌ ENDLOSSCHLEIFE!
zahl = 1
while zahl <= 5:
    print(zahl)
    # zahl wird nie erhöht! → Läuft für immer!

# ✅ Richtig
zahl = 1
while zahl <= 5:
    print(zahl)
    zahl += 1  # Wichtig!
```

**Endlosschleife stoppen:**
- Windows: Strg+C
- Mac/Linux: Strg+C oder Cmd+C

### while True (Absichtliche Endlosschleife)

```python
while True:
    eingabe = input("Befehl (quit zum Beenden): ")
    
    if eingabe == "quit":
        break  # Schleife beenden!
    
    print(f"Du hast eingegeben: {eingabe}")
```

---

## 🔄 for-Schleife

### Syntax

```python
for variable in sequenz:
    # Code wird für jedes Element ausgeführt
    anweisungen
```

### Über Liste iterieren

```python
# Liste
fruechte = ["Apfel", "Banane", "Kirsche"]

for frucht in fruechte:
    print(frucht)

# Ausgabe:
# Apfel
# Banane
# Kirsche
```

**Was passiert:**
1. `frucht = "Apfel"` → print("Apfel")
2. `frucht = "Banane"` → print("Banane")
3. `frucht = "Kirsche"` → print("Kirsche")

### Über String iterieren

```python
for buchstabe in "Python":
    print(buchstabe)

# Ausgabe:
# P
# y
# t
# h
# o
# n
```

### Über Dictionary iterieren

```python
person = {"name": "Max", "alter": 25, "stadt": "Berlin"}

# Über Keys
for key in person:
    print(key)

# Über Values
for value in person.values():
    print(value)

# Über Key-Value Paare
for key, value in person.items():
    print(f"{key}: {value}")

# Ausgabe:
# name: Max
# alter: 25
# stadt: Berlin
```

### Über Tupel/Set iterieren

```python
# Tupel
koordinaten = (10, 20, 30)
for wert in koordinaten:
    print(wert)

# Set
zahlen = {1, 2, 3, 4, 5}
for zahl in zahlen:
    print(zahl)
```

---

## 🔢 range()

**range()** erstellt eine Sequenz von Zahlen.

### range(stop)

```python
# Von 0 bis stop-1
for i in range(5):
    print(i)

# Ausgabe:
# 0
# 1
# 2
# 3
# 4
```

### range(start, stop)

```python
# Von start bis stop-1
for i in range(1, 6):
    print(i)

# Ausgabe:
# 1
# 2
# 3
# 4
# 5
```

### range(start, stop, step)

```python
# Von start bis stop-1, Schrittweite step

# Jede 2. Zahl
for i in range(0, 10, 2):
    print(i)
# Ausgabe: 0, 2, 4, 6, 8

# Countdown
for i in range(10, 0, -1):
    print(i)
# Ausgabe: 10, 9, 8, ..., 1
```

### Praktische Beispiele

```python
# 1 bis 10
for i in range(1, 11):
    print(i)

# 10 bis 1 (Countdown)
for i in range(10, 0, -1):
    print(i)

# Gerade Zahlen von 0-20
for i in range(0, 21, 2):
    print(i)

# Ungerade Zahlen von 1-19
for i in range(1, 20, 2):
    print(i)
```

### Kleines 1x1

```python
for i in range(1, 11):
    for j in range(1, 11):
        print(f"{i} × {j} = {i*j}")
```

---

## 🛑 break und continue

### break - Schleife beenden

**Bricht die Schleife sofort ab:**

```python
# Suche Zahl
for zahl in range(1, 11):
    if zahl == 5:
        print("Gefunden!")
        break
    print(zahl)

# Ausgabe:
# 1
# 2
# 3
# 4
# Gefunden!
```

**Praktisch:**
```python
# Passwort maximal 3 Versuche
versuche = 0

while versuche < 3:
    password = input("Passwort: ")
    versuche += 1
    
    if password == "geheim":
        print("Richtig!")
        break
    
    print(f"Falsch! Noch {3 - versuche} Versuche.")
else:
    print("Zu viele Versuche!")
```

### continue - Zur nächsten Iteration

**Springt zum nächsten Durchlauf:**

```python
# Gerade Zahlen überspringen
for zahl in range(1, 11):
    if zahl % 2 == 0:
        continue  # Gehe zur nächsten Zahl
    print(zahl)  # Wird nur für ungerade ausgeführt

# Ausgabe:
# 1
# 3
# 5
# 7
# 9
```

**Praktisch:**
```python
# Nur positive Zahlen addieren
zahlen = [5, -3, 8, -1, 4, -7, 2]
summe = 0

for zahl in zahlen:
    if zahl < 0:
        continue  # Negative überspringen
    summe += zahl

print(f"Summe der positiven: {summe}")
# Ausgabe: 19
```

### break vs continue

```python
# break - Schleife ENDET
for i in range(5):
    if i == 3:
        break
    print(i)
# Ausgabe: 0, 1, 2

# continue - Dieser Durchlauf wird ÜBERSPRUNGEN
for i in range(5):
    if i == 3:
        continue
    print(i)
# Ausgabe: 0, 1, 2, 4
```

---

## 🔚 else bei Schleifen

**else-Block wird ausgeführt wenn Schleife NICHT durch break beendet wurde.**

### Mit for

```python
# Zahl suchen
zahlen = [1, 2, 3, 4, 5]
suche = 7

for zahl in zahlen:
    if zahl == suche:
        print(f"{suche} gefunden!")
        break
else:
    print(f"{suche} nicht gefunden!")

# Ausgabe: 7 nicht gefunden!
```

### Mit while

```python
# Primzahl-Test
zahl = 17
ist_prim = True

i = 2
while i < zahl:
    if zahl % i == 0:
        ist_prim = False
        break
    i += 1
else:
    # Schleife lief durch ohne break
    ist_prim = True

if ist_prim:
    print(f"{zahl} ist eine Primzahl")
else:
    print(f"{zahl} ist keine Primzahl")
```

**Wann else ausgeführt wird:**

```python
# OHNE break → else wird ausgeführt
for i in range(5):
    print(i)
else:
    print("Fertig!")

# MIT break → else wird NICHT ausgeführt
for i in range(5):
    if i == 3:
        break
    print(i)
else:
    print("Fertig!")  # Wird nicht ausgeführt!
```

---

## 🔁 Verschachtelte Schleifen

**Schleife in Schleife:**

### Einfaches Beispiel

```python
# Äußere Schleife
for i in range(1, 4):
    # Innere Schleife
    for j in range(1, 4):
        print(f"i={i}, j={j}")

# Ausgabe:
# i=1, j=1
# i=1, j=2
# i=1, j=3
# i=2, j=1
# i=2, j=2
# ...
```

### Multiplikationstabelle

```python
print("    ", end="")
for i in range(1, 11):
    print(f"{i:4}", end="")
print()
print("-" * 44)

for i in range(1, 11):
    print(f"{i:2} |", end="")
    for j in range(1, 11):
        print(f"{i*j:4}", end="")
    print()

# Ausgabe:
#        1   2   3   4   5   6   7   8   9  10
# --------------------------------------------
#  1 |   1   2   3   4   5   6   7   8   9  10
#  2 |   2   4   6   8  10  12  14  16  18  20
# ...
```

### Muster zeichnen

```python
# Dreieck
for i in range(1, 6):
    for j in range(i):
        print("*", end="")
    print()

# Ausgabe:
# *
# **
# ***
# ****
# *****

# Quadrat
for i in range(5):
    for j in range(5):
        print("*", end=" ")
    print()

# Ausgabe:
# * * * * *
# * * * * *
# * * * * *
# * * * * *
# * * * * *
```

### Matrix durchlaufen

```python
matrix = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
]

for zeile in matrix:
    for element in zeile:
        print(element, end=" ")
    print()

# Mit Indizes
for i in range(len(matrix)):
    for j in range(len(matrix[i])):
        print(f"[{i}][{j}] = {matrix[i][j]}")
```

---

## 🎯 Praktische Beispiele

### 1. Summe und Durchschnitt

```python
zahlen = []

while True:
    eingabe = input("Zahl (Enter für Fertig): ")
    if eingabe == "":
        break
    zahlen.append(float(eingabe))

if zahlen:
    summe = sum(zahlen)
    durchschnitt = summe / len(zahlen)
    
    print(f"Anzahl: {len(zahlen)}")
    print(f"Summe: {summe}")
    print(f"Durchschnitt: {durchschnitt:.2f}")
    print(f"Min: {min(zahlen)}")
    print(f"Max: {max(zahlen)}")
else:
    print("Keine Zahlen eingegeben.")
```

### 2. Primzahlen finden

```python
start = int(input("Start: "))
end = int(input("Ende: "))

print(f"Primzahlen von {start} bis {end}:")

for zahl in range(start, end + 1):
    if zahl < 2:
        continue
    
    ist_prim = True
    for teiler in range(2, int(zahl ** 0.5) + 1):
        if zahl % teiler == 0:
            ist_prim = False
            break
    
    if ist_prim:
        print(zahl, end=" ")
print()
```

### 3. Fibonacci-Folge

```python
n = int(input("Wie viele Fibonacci-Zahlen? "))

a, b = 0, 1
count = 0

while count < n:
    print(a, end=" ")
    a, b = b, a + b
    count += 1
print()

# Ausgabe für n=10:
# 0 1 1 2 3 5 8 13 21 34
```

### 4. Fakult ät berechnen

```python
n = int(input("Zahl: "))
fakultaet = 1

for i in range(1, n + 1):
    fakultaet *= i

print(f"{n}! = {fakultaet}")

# Beispiel: 5! = 120
```

### 5. Wörter-Raten

```python
import random

woerter = ["python", "programmieren", "computer", "schleife", "funktion"]
wort = random.choice(woerter)
versuche = 0
max_versuche = 5

print("Errate das Wort!")
print(f"Hinweis: {len(wort)} Buchstaben")

while versuche < max_versuche:
    eingabe = input("Dein Tipp: ").lower()
    versuche += 1
    
    if eingabe == wort:
        print(f"Richtig! Du hast {versuche} Versuche gebraucht.")
        break
    
    print(f"Falsch! Noch {max_versuche - versuche} Versuche.")
else:
    print(f"Verloren! Das Wort war: {wort}")
```

### 6. Todo-Liste

```python
todos = []

while True:
    print("\n--- TODO LISTE ---")
    if todos:
        for i, todo in enumerate(todos, 1):
            print(f"{i}. {todo}")
    else:
        print("Keine Todos")
    
    print("\n1. Todo hinzufügen")
    print("2. Todo entfernen")
    print("3. Beenden")
    
    wahl = input("\nWahl: ")
    
    if wahl == "1":
        todo = input("Neues Todo: ")
        todos.append(todo)
    elif wahl == "2":
        if todos:
            nr = int(input("Nummer: "))
            if 1 <= nr <= len(todos):
                todos.pop(nr - 1)
    elif wahl == "3":
        break
```

---

## 📝 Übungen

### Übung 1: Zahlen-Reihen
```python
# Gib aus:
# a) Zahlen von 1-100
# b) Gerade Zahlen von 2-50
# c) Countdown von 20-1
# d) Jede 5. Zahl von 0-100
```

### Übung 2: Summe berechnen
```python
# Berechne:
# a) Summe von 1-1000
# b) Summe aller geraden Zahlen von 1-100
# c) Summe aller durch 3 teilbaren Zahlen von 1-100
```

### Übung 3: Fakultät
```python
# Schreibe Programm das Fakultät berechnet
# Beispiel: 5! = 5 * 4 * 3 * 2 * 1 = 120
```

### Übung 4: Primzahl-Checker
```python
# Frage nach Zahl
# Prüfe ob Primzahl
# Wenn ja: "X ist eine Primzahl"
# Wenn nein: "X ist keine Primzahl, teilbar durch Y"
```

### Übung 5: Passwort-Generator
```python
# Generiere zufälliges Passwort mit:
# - Benutzer wählt Länge
# - Mindestens 1 Großbuchstabe
# - Mindestens 1 Kleinbuchstabe
# - Mindestens 1 Zahl
# - Mindestens 1 Sonderzeichen
```

### Übung 6: Muster zeichnen
```python
# Zeichne folgende Muster:

# a)
# *
# **
# ***
# ****
# *****

# b)
#     *
#    **
#   ***
#  ****
# *****

# c)
# *****
# ****
# ***
# **
# *
```

### Übung 7: Zahlenraten
```python
# Computer wählt zufällige Zahl 1-100
# User rät
# Gib Hinweise: "Zu hoch" / "Zu niedrig"
# Zähle Versuche
# Am Ende: "Du hast X Versuche gebraucht"
```

### Übung 8: Durchschnitts-Rechner
```python
# User gibt beliebig viele Zahlen ein
# (Enter = fertig)
# Berechne:
# - Durchschnitt
# - Minimum
# - Maximum
# - Wie viele über/unter Durchschnitt
```

---

## 🎓 Was du gelernt hast

✅ **while-Schleifen** - Solange Bedingung wahr  
✅ **for-Schleifen** - Über Sequenzen iterieren  
✅ **range()** - Zahlensequenzen erstellen  
✅ **break** - Schleife beenden  
✅ **continue** - Iteration überspringen  
✅ **else** bei Schleifen  
✅ Verschachtelte Schleifen  

---

## 🧠 Wichtige Takeaways

1. **while** für unbekannte Anzahl Wiederholungen
2. **for** für bekannte Anzahl oder Iteration über Sequenzen
3. **range(start, stop, step)** für Zahlen
4. **break** beendet Schleife komplett
5. **continue** überspringt nur aktuelle Iteration
6. **else** nach Schleife = kein break aufgetreten
7. **Endlosschleifen vermeiden!** (Counter erhöhen)

---

## ➡️ Weiter geht's

In der nächsten Lektion lernst du über:
- **Funktionen** - Code wiederverwenden
- **Parameter und Argumente**
- **Return-Werte**
- **Scope** (Gültigkeitsbereich)

**Bereit? Auf zur [Lektion 10: Funktionen](10_funktionen.md)!**
