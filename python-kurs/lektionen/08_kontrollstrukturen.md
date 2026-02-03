# 🔀 Lektion 8: Kontrollstrukturen (if/elif/else)

## 📖 Inhaltsverzeichnis
- [Was sind Kontrollstrukturen?](#was-sind-kontrollstrukturen)
- [if-Anweisung](#if-anweisung)
- [if-else](#if-else)
- [if-elif-else](#if-elif-else)
- [Verschachtelte Bedingungen](#verschachtelte-bedingungen)
- [Ternary Operator](#ternary-operator)
- [Praktische Beispiele](#praktische-beispiele)
- [Übungen](#übungen)

---

## 🤔 Was sind Kontrollstrukturen?

**Kontrollstrukturen** = Entscheidungen im Code

### Alltags-Beispiel

```
WENN es regnet:
    Nimm einen Regenschirm
SONST:
    Lass den Schirm zu Hause
```

In Python:

```python
if es_regnet:
    nimm_regenschirm()
else:
    lass_schirm_zu_hause()
```

### Warum wichtig?

Ohne Bedingungen würde jede Zeile **immer** ausgeführt:

```python
print("Guten Morgen!")
print("Gute Nacht!")
# Beide werden immer ausgeführt! 😅
```

Mit Bedingungen können wir **entscheiden**:

```python
if stunde < 12:
    print("Guten Morgen!")
else:
    print("Gute Nacht!")
# Nur eines wird ausgeführt! ✅
```

---

## 🔹 if-Anweisung

### Syntax

```python
if bedingung:
    # Code wird nur ausgeführt wenn bedingung True ist
    anweisung1
    anweisung2
```

**Wichtig:**
- `if` mit Kleinbuchstaben
- Bedingung ohne Klammern
- **Doppelpunkt `:` am Ende!**
- **Einrückung** (4 Leerzeichen oder Tab)

### Einfache Beispiele

```python
# Beispiel 1: Alter prüfen
alter = 18

if alter >= 18:
    print("Du bist volljährig")

# Beispiel 2: Positiv prüfen
zahl = 10

if zahl > 0:
    print("Die Zahl ist positiv")

# Beispiel 3: String prüfen
name = "Max"

if name == "Max":
    print("Hallo Max!")
```

### Mit Variablen

```python
temperatur = 25

if temperatur > 20:
    print("Es ist warm draußen")
    print("Zieh etwas Leichtes an")
    
# Code nach if wird immer ausgeführt
print("Dieser Text kommt immer")
```

**Ausgabe wenn temperatur = 25:**
```
Es ist warm draußen
Zieh etwas Leichtes an
Dieser Text kommt immer
```

**Ausgabe wenn temperatur = 15:**
```
Dieser Text kommt immer
```

### Mit User-Input

```python
alter = int(input("Wie alt bist du? "))

if alter >= 18:
    print("Willkommen! Du darfst eintreten.")
    
if alter < 18:
    print("Tut mir leid, du bist noch zu jung.")
```

### Mehrere Bedingungen (and/or)

```python
alter = 25
hat_ticket = True

if alter >= 18 and hat_ticket:
    print("Einlass gewährt!")

username = "admin"
password = "geheim"

if username == "admin" or username == "root":
    print("Admin-Zugriff")
```

---

## 🔷 if-else

### Syntax

```python
if bedingung:
    # Wird ausgeführt wenn bedingung True
    anweisungen_wenn_true
else:
    # Wird ausgeführt wenn bedingung False
    anweisungen_wenn_false
```

**Genau EINS davon wird ausgeführt!**

### Einfache Beispiele

```python
# Beispiel 1: Gerade oder Ungerade
zahl = 7

if zahl % 2 == 0:
    print("Gerade")
else:
    print("Ungerade")
# Ausgabe: Ungerade

# Beispiel 2: Positiv oder Negativ
zahl = -5

if zahl >= 0:
    print("Positiv oder Null")
else:
    print("Negativ")
# Ausgabe: Negativ

# Beispiel 3: Erwachsen oder Kind
alter = 15

if alter >= 18:
    print("Erwachsener")
else:
    print("Kind/Jugendlicher")
# Ausgabe: Kind/Jugendlicher
```

### Mit mehreren Anweisungen

```python
punkte = 45

if punkte >= 50:
    print("✓ Bestanden!")
    print("Glückwunsch!")
    note = "Bestanden"
else:
    print("✗ Durchgefallen")
    print("Versuche es nochmal!")
    note = "Nicht bestanden"

print(f"Ergebnis: {note}")
```

### User-Interaktion

```python
antwort = input("Möchtest du fortfahren? (ja/nein): ").lower()

if antwort == "ja":
    print("Super! Weiter geht's...")
else:
    print("Okay, vielleicht später!")
```

---

## 🔶 if-elif-else

### Syntax

```python
if bedingung1:
    # Wenn bedingung1 True
    anweisungen1
elif bedingung2:
    # Wenn bedingung1 False aber bedingung2 True
    anweisungen2
elif bedingung3:
    # Wenn bedingung1 und bedingung2 False aber bedingung3 True
    anweisungen3
else:
    # Wenn alle False
    anweisungen_sonst
```

**Nur der ERSTE True-Block wird ausgeführt!**

### Notensystem

```python
punkte = 85

if punkte >= 90:
    note = "Sehr gut (1)"
elif punkte >= 80:
    note = "Gut (2)"
elif punkte >= 70:
    note = "Befriedigend (3)"
elif punkte >= 60:
    note = "Ausreichend (4)"
elif punkte >= 50:
    note = "Mangelhaft (5)"
else:
    note = "Ungenügend (6)"

print(f"Deine Note: {note}")
# Ausgabe: Deine Note: Gut (2)
```

### Tageszeit

```python
stunde = 15

if stunde < 6:
    tageszeit = "Nacht"
elif stunde < 12:
    tageszeit = "Morgen"
elif stunde < 18:
    tageszeit = "Nachmittag"
else:
    tageszeit = "Abend"

print(f"Guten {tageszeit}!")
# Ausgabe: Guten Nachmittag!
```

### Temperatur

```python
temperatur = 25

if temperatur < 0:
    print("🥶 Eiskalt! Unter 0°C")
    print("Zieh dich sehr warm an!")
elif temperatur < 10:
    print("❄️ Kalt! 0-10°C")
    print("Jacke nicht vergessen!")
elif temperatur < 20:
    print("😊 Kühl. 10-20°C")
    print("Eine Jacke wäre gut.")
elif temperatur < 30:
    print("☀️ Angenehm! 20-30°C")
    print("Perfektes Wetter!")
else:
    print("🔥 Heiß! Über 30°C")
    print("Viel trinken!")
```

### BMI-Rechner

```python
gewicht = float(input("Gewicht in kg: "))
groesse = float(input("Größe in m: "))

bmi = gewicht / (groesse ** 2)

print(f"Dein BMI: {bmi:.1f}")

if bmi < 18.5:
    kategorie = "Untergewicht"
elif bmi < 25:
    kategorie = "Normalgewicht"
elif bmi < 30:
    kategorie = "Übergewicht"
else:
    kategorie = "Adipositas"

print(f"Kategorie: {kategorie}")
```

---

## 🔄 Verschachtelte Bedingungen

**if in if:**

```python
alter = 25
hat_fuehrerschein = True

if alter >= 18:
    print("Du bist alt genug.")
    if hat_fuehrerschein:
        print("Du darfst fahren! ✓")
    else:
        print("Du brauchst einen Führerschein!")
else:
    print("Du bist zu jung zum Fahren.")
```

### Login-System

```python
username = input("Username: ")
password = input("Password: ")

if username == "admin":
    if password == "geheim123":
        print("✓ Login erfolgreich!")
        print("Willkommen Admin!")
    else:
        print("✗ Falsches Passwort!")
else:
    print("✗ Unbekannter Username!")
```

### Drei Zahlen vergleichen

```python
a = 10
b = 20
c = 15

if a > b:
    if a > c:
        groesste = a
    else:
        groesste = c
else:
    if b > c:
        groesste = b
    else:
        groesste = c

print(f"Größte Zahl: {groesste}")
```

**Besser mit and:**
```python
a, b, c = 10, 20, 15

if a >= b and a >= c:
    groesste = a
elif b >= a and b >= c:
    groesste = b
else:
    groesste = c

print(f"Größte Zahl: {groesste}")

# Oder einfach:
groesste = max(a, b, c)
```

### Rabatt-System

```python
preis = 100
ist_mitglied = True
alter = 65

if ist_mitglied:
    if alter >= 65:
        rabatt = 0.30  # 30% für Senior-Mitglieder
    else:
        rabatt = 0.10  # 10% für normale Mitglieder
else:
    if alter >= 65:
        rabatt = 0.15  # 15% für Senioren
    else:
        rabatt = 0  # Kein Rabatt

endpreis = preis * (1 - rabatt)
print(f"Preis: {preis}€")
print(f"Rabatt: {rabatt * 100}%")
print(f"Zu zahlen: {endpreis}€")
```

---

## ⚡ Ternary Operator (Bedingte Ausdrücke)

**Kurzform für if-else:**

### Syntax

```python
wert_wenn_true if bedingung else wert_wenn_false
```

### Beispiele

```python
# Normal
alter = 25
if alter >= 18:
    status = "Erwachsen"
else:
    status = "Minderjährig"

# Ternary
status = "Erwachsen" if alter >= 18 else "Minderjährig"

# Weitere Beispiele
zahl = 10
typ = "gerade" if zahl % 2 == 0 else "ungerade"

punkte = 85
bestanden = "Ja" if punkte >= 50 else "Nein"

temperatur = 25
kleidung = "T-Shirt" if temperatur > 20 else "Jacke"
```

### In print()

```python
alter = 17
print("Zugang" if alter >= 18 else "Kein Zugang")

punkte = 45
print(f"Du hast {'bestanden' if punkte >= 50 else 'nicht bestanden'}")
```

### Verschachtelt (vermeiden!)

```python
# ❌ Schwer zu lesen
zahl = 15
ergebnis = "negativ" if zahl < 0 else "null" if zahl == 0 else "positiv"

# ✅ Besser:
if zahl < 0:
    ergebnis = "negativ"
elif zahl == 0:
    ergebnis = "null"
else:
    ergebnis = "positiv"
```

---

## 🎯 Praktische Beispiele

### 1. Login-Programm

```python
CORRECT_USER = "admin"
CORRECT_PASS = "1234"

username = input("Username: ")
password = input("Password: ")

if username == CORRECT_USER and password == CORRECT_PASS:
    print("\n✓ Login erfolgreich!")
    print("Willkommen im System!")
else:
    print("\n✗ Login fehlgeschlagen!")
    if username != CORRECT_USER:
        print("Fehler: Unbekannter Username")
    else:
        print("Fehler: Falsches Passwort")
```

### 2. Taschenrechner

```python
zahl1 = float(input("Erste Zahl: "))
operator = input("Operator (+, -, *, /): ")
zahl2 = float(input("Zweite Zahl: "))

if operator == "+":
    ergebnis = zahl1 + zahl2
elif operator == "-":
    ergebnis = zahl1 - zahl2
elif operator == "*":
    ergebnis = zahl1 * zahl2
elif operator == "/":
    if zahl2 != 0:
        ergebnis = zahl1 / zahl2
    else:
        print("Fehler: Division durch 0!")
        ergebnis = None
else:
    print("Fehler: Unbekannter Operator!")
    ergebnis = None

if ergebnis is not None:
    print(f"Ergebnis: {ergebnis}")
```

### 3. Schaltjahr-Prüfer

```python
jahr = int(input("Jahr: "))

if jahr % 4 == 0:
    if jahr % 100 == 0:
        if jahr % 400 == 0:
            print(f"{jahr} ist ein Schaltjahr ✓")
        else:
            print(f"{jahr} ist kein Schaltjahr")
    else:
        print(f"{jahr} ist ein Schaltjahr ✓")
else:
    print(f"{jahr} ist kein Schaltjahr")

# Kürzer:
ist_schaltjahr = (jahr % 4 == 0 and jahr % 100 != 0) or (jahr % 400 == 0)
```

### 4. Passwort-Stärke-Checker

```python
password = input("Passwort eingeben: ")

laenge = len(password)
hat_zahl = any(c.isdigit() for c in password)
hat_gross = any(c.isupper() for c in password)
hat_klein = any(c.islower() for c in password)
hat_sonder = any(not c.isalnum() for c in password)

punkte = 0
if laenge >= 8:
    punkte += 1
if laenge >= 12:
    punkte += 1
if hat_zahl:
    punkte += 1
if hat_gross and hat_klein:
    punkte += 1
if hat_sonder:
    punkte += 1

if punkte <= 1:
    staerke = "Sehr schwach"
elif punkte == 2:
    staerke = "Schwach"
elif punkte == 3:
    staerke = "Mittel"
elif punkte == 4:
    staerke = "Stark"
else:
    staerke = "Sehr stark"

print(f"Passwort-Stärke: {staerke}")
print(f"Punkte: {punkte}/5")
```

---

## 🐛 Häufige Fehler

### 1. Doppelpunkt vergessen

```python
# ❌ Fehler
if alter >= 18
    print("Erwachsen")

# ✅ Richtig
if alter >= 18:
    print("Erwachsen")
```

### 2. Keine Einrückung

```python
# ❌ Fehler
if alter >= 18:
print("Erwachsen")

# ✅ Richtig
if alter >= 18:
    print("Erwachsen")
```

### 3. = statt ==

```python
# ❌ Falsch (Zuweisung!)
if alter = 18:
    print("18 Jahre alt")

# ✅ Richtig (Vergleich!)
if alter == 18:
    print("18 Jahre alt")
```

### 4. Klammern wie in anderen Sprachen

```python
# ❌ Nicht nötig (aber funktioniert)
if (alter >= 18):
    print("Erwachsen")

# ✅ Python-Style
if alter >= 18:
    print("Erwachsen")
```

### 5. Falsche Einrückung nach if

```python
# ❌ Fehler - nicht alles eingerückt
if alter >= 18:
    print("Erwachsen")
    print("Du darfst wählen")
print("Und Auto fahren")  # Immer ausgeführt!

# ✅ Richtig
if alter >= 18:
    print("Erwachsen")
    print("Du darfst wählen")
    print("Und Auto fahren")
```

---

## 📝 Übungen

### Übung 1: Einfache Prüfungen
```python
# Frage nach einer Zahl
# Gib aus ob sie:
# - Positiv, negativ oder null
# - Gerade oder ungerade
# - Einstellig, zweistellig oder mehrstellig
```

### Übung 2: Mindestalter
```python
# Frage nach Alter
# Prüfe für verschiedene Aktivitäten:
# - Kino ab 6: Darf ins Kino?
# - FSK 12: Darf FSK-12-Filme sehen?
# - FSK 16: Darf FSK-16-Filme sehen?
# - FSK 18: Darf FSK-18-Filme sehen?
```

### Übung 3: Rabatt-Rechner
```python
# Frage nach:
# - Einkaufswert
# - Ist Kunde Mitglied? (ja/nein)
# - Ist es Montag? (ja/nein)

# Rabatte:
# - Ab 50€: 5%
# - Ab 100€: 10%
# - Ab 200€: 15%
# - Mitglieder: +5%
# - Montag: +10%

# Berechne und zeige Endpreis
```

### Übung 4: Noten-Umrechner
```python
# Frage nach Punkten (0-100)
# Wandle um in:
# - Deutsche Note (1-6)
# - Amerikanische Note (A-F)
# - Bestanden/Durchgefallen (ab 50%)
```

### Übung 5: Rock-Paper-Scissors
```python
# Spieler wählt: Stein, Papier, Schere
# Computer wählt zufällig
# Wer gewinnt?
# (Stein > Schere > Papier > Stein)
```

### Übung 6: Größte von drei Zahlen
```python
# Frage nach 3 Zahlen
# Finde die größte
# (OHNE max() zu verwenden!)
```

### Übung 7: Jahreszeitcheck
```python
# Frage nach Monat (1-12)
# Gib Jahreszeit aus:
# - 12, 1, 2: Winter
# - 3, 4, 5: Frühling
# - 6, 7, 8: Sommer
# - 9, 10, 11: Herbst
```

### Übung 8: Triangle-Validator
```python
# Frage nach 3 Seitenlängen
# Prüfe:
# - Ist es ein gültiges Dreieck?
#   (Summe zweier Seiten > dritte Seite)
# - Welcher Typ?
#   - Gleichseitig (alle gleich)
#   - Gleichschenklig (2 gleich)
#   - Ungleichseitig (alle verschieden)
```

---

## 🎓 Was du gelernt hast

✅ if-Anweisungen (Einfache Bedingungen)  
✅ if-else (Entweder-Oder)  
✅ if-elif-else (Mehrere Möglichkeiten)  
✅ Verschachtelte Bedingungen  
✅ Ternary Operator (Kurzform)  
✅ Praktische Anwendungen  

---

## 🧠 Wichtige Takeaways

1. **if** für Bedingungen
2. **Doppelpunkt `:` nicht vergessen!**
3. **Einrückung** ist PFLICHT (4 Leerzeichen)
4. **elif** nicht "else if"
5. **Nur der ERSTE True-Block** wird ausgeführt
6. **== für Vergleich**, = für Zuweisung
7. **Ternary** für einfache if-else in einer Zeile

---

## ➡️ Weiter geht's

In der nächsten Lektion lernst du über:
- **Schleifen** - Code wiederholen
- **while-Schleifen** - Solange Bedingung erfüllt
- **for-Schleifen** - Über Sequenzen iterieren

**Bereit? Auf zur [Lektion 9: Schleifen](09_schleifen.md)!**
