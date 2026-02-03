# ➕➖✖️➗ Lektion 3: Operatoren und Ausdrücke

## 📖 Inhaltsverzeichnis
- [Was sind Operatoren?](#was-sind-operatoren)
- [Arithmetische Operatoren](#arithmetische-operatoren)
- [Vergleichsoperatoren](#vergleichsoperatoren)
- [Logische Operatoren](#logische-operatoren)
- [Zuweisungsoperatoren](#zuweisungsoperatoren)
- [Operator-Priorität](#operator-priorität)
- [Weitere Operatoren](#weitere-operatoren)
- [Übungen](#übungen)

---

## 🤔 Was sind Operatoren?

**Operatoren** sind Symbole, die Operationen (Aktionen) auf Werten durchführen.

### Alltags-Beispiel

In der Mathematik:
```
5 + 3 = 8
```

- **5 und 3** = Operanden (Werte)
- **+** = Operator (Aktion)
- **8** = Ergebnis

In Python funktioniert es genauso!

```python
>>> 5 + 3
8
```

### Typen von Operatoren

Python hat 7 Haupttypen:

1. **Arithmetisch** - Rechnen (+, -, *, /)
2. **Vergleich** - Vergleichen (==, !=, <, >)
3. **Logisch** - Logik (and, or, not)
4. **Zuweisung** - Wert zuweisen (=, +=, -=)
5. **Identity** - Gleiche Objekt? (is, is not)
6. **Membership** - Ist enthalten? (in, not in)
7. **Bitwise** - Bit-Operationen (&, |, ^) - Fortgeschritten

Wir konzentrieren uns auf 1-4 (die wichtigsten).

---

## ➕ Arithmetische Operatoren

Für **Berechnungen** mit Zahlen.

### Addition (+)

```python
>>> 5 + 3
8

>>> 10.5 + 2.3
12.8

>>> x = 100
>>> y = 50
>>> print(x + y)
150
```

**Mit Strings:**
```python
>>> "Hallo" + "Welt"
'HalloWelt'

>>> "Hallo " + "Welt"
'Hallo Welt'

>>> name = "Max"
>>> nachricht = "Hallo " + name
>>> print(nachricht)
Hallo Max
```

**⚠️ Achtung:**
```python
>>> "5" + "3"
'53'  # String-Verkettung, nicht 8!

>>> 5 + "3"
TypeError!  # Kann nicht mischen!

>>> 5 + int("3")
8  # ✅ Erst konvertieren!
```

### Subtraktion (-)

```python
>>> 10 - 3
7

>>> 5 - 10
-5

>>> 100.5 - 0.5
100.0

>>> x = 50
>>> y = 30
>>> differenz = x - y
>>> print(differenz)
20
```

**Negation (Vorzeichen ändern):**
```python
>>> x = 10
>>> -x
-10

>>> y = -5
>>> -y
5
```

### Multiplikation (*)

```python
>>> 5 * 3
15

>>> 2.5 * 4
10.0

>>> preis = 9.99
>>> anzahl = 5
>>> gesamt = preis * anzahl
>>> print(gesamt)
49.95
```

**Mit Strings (Wiederholung):**
```python
>>> "Ha" * 5
'HaHaHaHaHa'

>>> "Python! " * 3
'Python! Python! Python! '

>>> "-" * 20
'--------------------'

>>> "=" * 10
'=========='
```

**Praktisches Beispiel:**
```python
print("=" * 30)
print("WILLKOMMEN".center(30))
print("=" * 30)

# Ausgabe:
# ==============================
#         WILLKOMMEN
# ==============================
```

### Division (/)

```python
>>> 10 / 2
5.0  # Immer Float!

>>> 7 / 2
3.5

>>> 1 / 3
0.3333333333333333

>>> 10.0 / 2.0
5.0
```

**⚠️ Wichtig:**
```python
# Division gibt IMMER Float zurück!
>>> type(10 / 2)
<class 'float'>

>>> 10 / 2
5.0  # Nicht 5!
```

**Division durch Null:**
```python
>>> 10 / 0
ZeroDivisionError: division by zero

# Immer prüfen!
if anzahl != 0:
    durchschnitt = summe / anzahl
else:
    print("Kann nicht durch 0 teilen!")
```

### Ganzzahl-Division (//)

Teilt und **rundet ab** (gibt Integer zurück).

```python
>>> 7 // 2
3  # Nicht 3.5!

>>> 10 // 3
3  # Nicht 3.333...

>>> 15 // 4
3

>>> 20 // 6
3
```

**Mit negativen Zahlen:**
```python
>>> -7 // 2
-4  # Rundet zur -∞

>>> 7 // -2
-4
```

**Float auch möglich:**
```python
>>> 7.0 // 2
3.0

>>> 10 // 2.5
4.0
```

**Praktisches Beispiel:**
```python
# Wie viele 5er-Packs brauchst du für 23 Items?
items = 23
pack_groesse = 5
packs = (items + pack_groesse - 1) // pack_groesse
print(packs)  # 5

# Oder: items // pack_groesse + (1 if items % pack_groesse else 0)
```

### Modulo (%)

Gibt den **Rest** einer Division zurück.

```python
>>> 7 % 2
1  # 7 ÷ 2 = 3 Rest 1

>>> 10 % 3
1  # 10 ÷ 3 = 3 Rest 1

>>> 20 % 5
0  # 20 ÷ 5 = 4 Rest 0

>>> 15 % 4
3  # 15 ÷ 4 = 3 Rest 3
```

**Gerade oder Ungerade?**
```python
zahl = 17

if zahl % 2 == 0:
    print("Gerade")
else:
    print("Ungerade")  # ✅
```

**Jede n-te Zeile:**
```python
for i in range(1, 21):
    if i % 5 == 0:
        print(f"Zeile {i} - Markierung!")
    else:
        print(f"Zeile {i}")
```

**Letzte Ziffer:**
```python
>>> 12345 % 10
5  # Letzte Ziffer!
```

### Potenz (**)

```python
>>> 2 ** 3
8  # 2³ = 2 * 2 * 2

>>> 5 ** 2
25  # 5² = 5 * 5

>>> 10 ** 6
1000000  # 10⁶

>>> 2 ** 0
1  # Alles hoch 0 ist 1
```

**Quadratwurzel:**
```python
>>> 16 ** 0.5
4.0  # √16

>>> 27 ** (1/3)
3.0  # ³√27

>>> 100 ** 0.5
10.0  # √100
```

**Wissenschaftliche Notation:**
```python
>>> 10 ** 3
1000

>>> 10 ** -3
0.001

>>> 1.5e3
1500.0  # 1.5 * 10³
```

### Zusammenfassung Arithmetik

| Operator | Name | Beispiel | Ergebnis |
|----------|------|----------|----------|
| + | Addition | 5 + 3 | 8 |
| - | Subtraktion | 5 - 3 | 2 |
| * | Multiplikation | 5 * 3 | 15 |
| / | Division | 5 / 2 | 2.5 |
| // | Ganzzahl-Division | 5 // 2 | 2 |
| % | Modulo (Rest) | 5 % 2 | 1 |
| ** | Potenz | 5 ** 2 | 25 |

---

## 🔍 Vergleichsoperatoren

Vergleichen zwei Werte. Ergebnis ist **immer** `True` oder `False`.

### Gleich (==)

**⚠️ Zwei Gleichheitszeichen!**

```python
>>> 5 == 5
True

>>> 5 == 3
False

>>> "Hallo" == "Hallo"
True

>>> "Hallo" == "hallo"
False  # Case-sensitive!

>>> 10 == 10.0
True  # Typ egal bei Zahlen

>>> x = 5
>>> y = 5
>>> x == y
True
```

**Häufiger Fehler:**
```python
# ❌ Falsch
if x = 5:  # SyntaxError!

# ✅ Richtig
if x == 5:  # Vergleich
```

### Ungleich (!=)

```python
>>> 5 != 3
True

>>> 5 != 5
False

>>> "ja" != "nein"
True

>>> x = 10
>>> x != 20
True
```

### Kleiner als (<)

```python
>>> 3 < 5
True

>>> 5 < 3
False

>>> 5 < 5
False  # Nicht kleiner, gleich!

>>> "a" < "b"
True  # Alphabetisch!

>>> "A" < "a"
True  # Großbuchstaben < Kleinbuchstaben
```

### Größer als (>)

```python
>>> 5 > 3
True

>>> 3 > 5
False

>>> 5 > 5
False

>>> alter = 25
>>> alter > 18
True
```

### Kleiner oder gleich (<=)

```python
>>> 3 <= 5
True

>>> 5 <= 5
True  # Auch gleich!

>>> 7 <= 5
False
```

### Größer oder gleich (>=)

```python
>>> 5 >= 3
True

>>> 5 >= 5
True

>>> 3 >= 5
False

>>> punkte = 50
>>> bestanden = punkte >= 50
>>> print(bestanden)
True
```

### Verkettete Vergleiche

Python erlaubt mathematische Notation:

```python
>>> x = 5
>>> 1 < x < 10
True

>>> 10 < x < 20
False

# Entspricht:
>>> (1 < x) and (x < 10)
True
```

**Mehr Beispiele:**
```python
>>> alter = 25
>>> 18 <= alter <= 65
True

>>> note = 2.3
>>> 1.0 <= note <= 4.0
True

>>> 0 < x < 100 < y < 200
# Prüft alle Bedingungen!
```

### String-Vergleich

Strings werden **alphabetisch** verglichen:

```python
>>> "Apfel" < "Banane"
True

>>> "Zebra" > "Affe"
True

>>> "10" < "2"
True  # String-Vergleich, nicht Zahl!

>>> "100" > "20"
False  # '1' < '2'
```

**Tipp:** Bei Zahlen-Strings erst konvertieren!
```python
>>> int("10") < int("2")
False  # Jetzt als Zahlen!
```

### Zusammenfassung Vergleich

| Operator | Bedeutung | Beispiel | Ergebnis |
|----------|-----------|----------|----------|
| == | Gleich | 5 == 5 | True |
| != | Ungleich | 5 != 3 | True |
| < | Kleiner | 3 < 5 | True |
| > | Größer | 5 > 3 | True |
| <= | Kleiner/Gleich | 5 <= 5 | True |
| >= | Größer/Gleich | 5 >= 3 | True |

---

## 🧠 Logische Operatoren

Kombinieren **Boolean-Werte** (True/False).

### and - UND

Beide müssen `True` sein:

```python
>>> True and True
True

>>> True and False
False

>>> False and True
False

>>> False and False
False
```

**Mit Vergleichen:**
```python
>>> alter = 25
>>> hat_fuehrerschein = True
>>> alter >= 18 and hat_fuehrerschein
True

>>> x = 15
>>> 10 < x and x < 20
True

# Besser:
>>> 10 < x < 20
True
```

**Praktisches Beispiel:**
```python
username = "Max"
password = "geheim123"

if username == "Max" and password == "geheim123":
    print("Login erfolgreich!")
else:
    print("Falsche Anmeldedaten!")
```

**Wahrheitstabelle:**
| A | B | A and B |
|---|---|---------|
| False | False | False |
| False | True | False |
| True | False | False |
| True | True | True |

### or - ODER

Mindestens einer muss `True` sein:

```python
>>> True or True
True

>>> True or False
True

>>> False or True
True

>>> False or False
False
```

**Praktisches Beispiel:**
```python
tag = "Samstag"

if tag == "Samstag" or tag == "Sonntag":
    print("Wochenende! 🎉")
else:
    print("Arbeitstag 😴")
```

**Mehrere Bedingungen:**
```python
alter = 70

if alter < 18 or alter > 65:
    print("Rabatt verfügbar!")
```

**Wahrheitstabelle:**
| A | B | A or B |
|---|---|--------|
| False | False | False |
| False | True | True |
| True | False | True |
| True | True | True |

### not - NICHT

Kehrt den Wert um:

```python
>>> not True
False

>>> not False
True

>>> x = 5
>>> not (x > 10)
True

>>> ist_regen = False
>>> not ist_regen
True  # Es regnet nicht
```

**Praktisches Beispiel:**
```python
ist_eingeloggt = False

if not ist_eingeloggt:
    print("Bitte einloggen!")
```

**Doppelte Negation:**
```python
>>> not not True
True  # Zwei not heben sich auf

>>> not not False
False
```

### Kombination

```python
# Komplex
>>> x = 15
>>> (x > 10 and x < 20) or x == 0
True

>>> alter = 25
>>> hat_ticket = True
>>> ist_vip = False

>>> if (alter >= 18 and hat_ticket) or ist_vip:
...     print("Einlass erlaubt")
```

**Praktisches Beispiel:**
```python
username = input("Username: ")
password = input("Password: ")
remember_me = input("Angemeldet bleiben? (ja/nein): ") == "ja"

if (username == "admin" and password == "1234") or remember_me:
    print("Zugriff gewährt")
else:
    print("Zugriff verweigert")
```

### Short-Circuit Evaluation

Python wertet nur aus, was nötig ist:

```python
# and
>>> False and print("Das wird nie ausgeführt")
False  # print() wird nicht aufgerufen!

>>> True and print("Das wird ausgeführt")
Das wird ausgeführt
None

# or
>>> True or print("Das wird nie ausgeführt")
True  # print() wird nicht aufgerufen!

>>> False or print("Das wird ausgeführt")
Das wird ausgeführt
None
```

**Nützlich für Fehler-Vermeidung:**
```python
x = 0
# Verhindert Division durch 0:
if x != 0 and 10 / x > 2:
    print("Bedingung erfüllt")
# 10/x wird nur ausgeführt wenn x != 0
```

### Zusammenfassung Logik

| Operator | Bedeutung | Beispiel | Ergebnis |
|----------|-----------|----------|----------|
| and | Beide True | True and False | False |
| or | Mind. einer True | True or False | True |
| not | Umkehrung | not True | False |

---

## 📝 Zuweisungsoperatoren

Verkürzte Schreibweisen für Berechnungen.

### Einfache Zuweisung (=)

```python
>>> x = 10
>>> name = "Max"
>>> ist_aktiv = True
```

### Addition Zuweisung (+=)

```python
>>> x = 10
>>> x = x + 5
>>> print(x)
15

# Kürzer:
>>> x = 10
>>> x += 5  # x = x + 5
>>> print(x)
15
```

**Mit Strings:**
```python
>>> text = "Hallo"
>>> text += " Welt"
>>> print(text)
Hallo Welt

>>> nachricht = ""
>>> nachricht += "Zeile 1\n"
>>> nachricht += "Zeile 2\n"
>>> print(nachricht)
Zeile 1
Zeile 2
```

### Subtraktion Zuweisung (-=)

```python
>>> x = 100
>>> x -= 30  # x = x - 30
>>> print(x)
70

>>> leben = 100
>>> schaden = 25
>>> leben -= schaden
>>> print(leben)
75
```

### Multiplikation Zuweisung (*=)

```python
>>> x = 5
>>> x *= 3  # x = x * 3
>>> print(x)
15

>>> preis = 10.0
>>> preis *= 1.19  # +19% MwSt
>>> print(preis)
11.9
```

### Division Zuweisung (/=)

```python
>>> x = 100
>>> x /= 4  # x = x / 4
>>> print(x)
25.0

>>> summe = 500
>>> anzahl = 5
>>> summe /= anzahl
>>> print(summe)
100.0
```

### Ganzzahl-Division Zuweisung (//=)

```python
>>> x = 17
>>> x //= 5  # x = x // 5
>>> print(x)
3
```

### Modulo Zuweisung (%=)

```python
>>> x = 17
>>> x %= 5  # x = x % 5
>>> print(x)
2
```

### Potenz Zuweisung (**=)

```python
>>> x = 2
>>> x **= 10  # x = x ** 10
>>> print(x)
1024
```

### Zusammenfassung Zuweisung

| Operator | Beispiel | Entspricht |
|----------|----------|------------|
| = | x = 5 | - |
| += | x += 3 | x = x + 3 |
| -= | x -= 3 | x = x - 3 |
| *= | x *= 3 | x = x * 3 |
| /= | x /= 3 | x = x / 3 |
| //= | x //= 3 | x = x // 3 |
| %= | x %= 3 | x = x % 3 |
| **= | x **= 3 | x = x ** 3 |

---

## 🎯 Operator-Priorität

Welche Operation wird **zuerst** ausgeführt?

### Die Rangfolge

Von **höchster** zu **niedrigster** Priorität:

1. **()** - Klammern
2. **\*\*** - Potenz
3. **+x, -x, not x** - Unäres Plus, Minus, not
4. **\*, /, //, %** - Multiplikation, Division
5. **+, -** - Addition, Subtraktion
6. **<, <=, >, >=, ==, !=** - Vergleiche
7. **and** - Logisches UND
8. **or** - Logisches ODER

### Beispiele

```python
>>> 2 + 3 * 4
14  # Nicht 20! (3*4 zuerst)

>>> (2 + 3) * 4
20  # Klammern zuerst!

>>> 2 ** 3 ** 2
512  # 3**2=9, dann 2**9=512

>>> (2 ** 3) ** 2
64  # 2**3=8, dann 8**2=64
```

**Komplex:**
```python
>>> 10 + 5 * 2 - 3 / 3
19.0

# Schritt für Schritt:
# 1. 5 * 2 = 10
# 2. 3 / 3 = 1.0
# 3. 10 + 10 = 20
# 4. 20 - 1.0 = 19.0
```

**Mit Vergleichen:**
```python
>>> 5 + 3 > 2 * 4
False

# Schritt für Schritt:
# 1. 5 + 3 = 8
# 2. 2 * 4 = 8
# 3. 8 > 8 = False
```

**Mit Logik:**
```python
>>> True or False and False
True

# Schritt für Schritt:
# 1. False and False = False
# 2. True or False = True

>>> (True or False) and False
False  # Andere Klammern = anderes Ergebnis!
```

### Best Practice: Klammern verwenden!

Mach deinen Code **lesbar**:

```python
# ❌ Schwer zu lesen
if x > 10 and y < 20 or z == 0 and not w > 5:
    pass

# ✅ Viel klarer!
if (x > 10 and y < 20) or (z == 0 and not (w > 5)):
    pass
```

---

## 🔧 Weitere Operatoren

### Identity-Operatoren (is, is not)

Prüft ob **gleiche Objekt** (nicht nur gleicher Wert):

```python
>>> x = [1, 2, 3]
>>> y = [1, 2, 3]
>>> z = x

>>> x == y
True  # Gleicher Inhalt

>>> x is y
False  # Verschiedene Objekte!

>>> x is z
True  # Gleiches Objekt (z zeigt auf x)
```

**Mit None:**
```python
>>> x = None
>>> x is None
True

>>> x == None
True  # Funktioniert auch, aber...

# ✅ Best Practice:
if x is None:
    print("x ist None")
```

**is not:**
```python
>>> x = 5
>>> x is not None
True
```

### Membership-Operatoren (in, not in)

Prüft ob **enthalten in**:

```python
>>> "a" in "Hallo"
True

>>> "x" in "Hallo"
False

>>> "Hallo" in "Hallo Welt"
True

>>> 3 in [1, 2, 3, 4]
True

>>> 10 in [1, 2, 3, 4]
False
```

**not in:**
```python
>>> "z" not in "Hallo"
True

>>> 5 not in [1, 2, 3]
True
```

**Praktisch:**
```python
email = input("Email: ")

if "@" in email and "." in email:
    print("Email scheint gültig")
else:
    print("Ungültige Email")
```

---

## 📝 Übungen

### Übung 1: Rechner
Erstelle Variablen:
```python
a = 10
b = 3
```
Berechne und gib aus:
- Summe
- Differenz
- Produkt
- Division
- Ganzzahl-Division
- Rest
- a hoch b

### Übung 2: Vergleiche
```python
x = 15
y = 20
```
Prüfe:
- Ist x gleich y?
- Ist x kleiner als y?
- Ist x größer oder gleich 10?
- Ist y zwischen 15 und 25?

### Übung 3: Logik
```python
alter = 25
hat_ticket = True
ist_student = False
```
Prüfe:
- alter >= 18 und hat_ticket
- ist_student oder alter < 18
- nicht ist_student
- (alter >= 18 und hat_ticket) oder ist_student

### Übung 4: Gerade/Ungerade
Schreibe ein Programm:
```python
zahl = int(input("Zahl: "))
# Prüfe ob gerade oder ungerade
# Gib aus: "Gerade" oder "Ungerade"
```

### Übung 5: Rabatt-Rechner
```python
preis = float(input("Preis: "))
rabatt_prozent = float(input("Rabatt %: "))

# Berechne:
# - Rabatt-Betrag
# - Endpreis
# Gib beides aus
```

### Übung 6: Operator-Priorität
Was ist das Ergebnis? (Erst überlegen, dann testen!)
```python
a) 2 + 3 * 4
b) (2 + 3) * 4
c) 10 - 2 * 3
d) 2 ** 3 * 2
e) 15 / 3 + 2
f) 5 > 3 and 10 < 20
g) True or False and False
h) not True or False
```

### Übung 7: String-Check
```python
text = input("Gib einen Text ein: ")

# Prüfe:
# - Länge größer als 5?
# - Enthält "Python"?
# - Beginnt mit Großbuchstaben?
```

---

## 🎓 Was du gelernt hast

✅ Alle arithmetischen Operatoren (+, -, *, /, //, %, **)  
✅ Vergleichsoperatoren (==, !=, <, >, <=, >=)  
✅ Logische Operatoren (and, or, not)  
✅ Zuweisungsoperatoren (=, +=, -=, etc.)  
✅ Operator-Priorität und Klammern  
✅ Identity (is) und Membership (in) Operatoren  

---

## 🧠 Wichtige Takeaways

1. **= ist Zuweisung**, == ist Vergleich
2. **/ gibt immer Float**, // gibt Integer
3. **% gibt Rest** (nützlich für gerade/ungerade)
4. **and/or/not** für logische Verknüpfungen
5. **Operator-Priorität** wie in Mathe (Punkt vor Strich)
6. **Klammern verwenden** für Klarheit!

---

## ➡️ Weiter geht's

In der nächsten Lektion lernst du über:
- **Strings im Detail** - Indizierung, Slicing, Methoden
- **String-Formatierung** - f-strings, format()
- **String-Operationen** - upper, lower, split, join

**Bereit? Auf zur [Lektion 4: Strings](04_strings.md)!**
