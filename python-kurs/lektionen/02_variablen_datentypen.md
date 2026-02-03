# 📦 Lektion 2: Variablen und Datentypen

## 📖 Inhaltsverzeichnis
- [Was sind Variablen?](#was-sind-variablen)
- [Variablen erstellen](#variablen-erstellen)
- [Namensregeln](#namensregeln)
- [Datentypen](#datentypen)
- [Type Checking](#type-checking)
- [Type Casting](#type-casting)
- [Übungen](#übungen)

---

## 🤔 Was sind Variablen?

### Die Karton-Analogie

Stell dir vor, du hast einen **Karton** 📦:

1. Du kannst eine **Beschriftung** darauf schreiben (z.B. "Spielzeug")
2. Du kannst etwas **hineinlegen** (z.B. einen Ball)
3. Du kannst später **nachschauen**, was drin ist
4. Du kannst den **Inhalt ändern** (Ball raus, Buch rein)

**Variablen funktionieren genauso!**

```python
spielzeug = "Ball"  # Karton mit Label "spielzeug" enthält "Ball"
```

- **Variable name** = Karton-Beschriftung (`spielzeug`)
- **Wert** = Was im Karton ist (`"Ball"`)
- **=** = "Lege hinein"

### Warum brauchen wir Variablen?

**Ohne Variablen:**
```python
print("Max")
print("Max ist 25 Jahre alt")
print("Max wohnt in Berlin")
```

Was wenn du den Namen ändern willst? Du musst **alle Zeilen** ändern! 😰

**Mit Variablen:**
```python
name = "Max"
alter = 25
stadt = "Berlin"

print(name)
print(name, "ist", alter, "Jahre alt")
print(name, "wohnt in", stadt)
```

Jetzt änderst du nur `name = "Anna"` und **alles** ändert sich automatisch! 🎉

---

## ✍️ Variablen erstellen

### Syntax: Zuweisung

```python
variable_name = wert
```

- **Links** vom `=`: Variable name
- **Rechts** vom `=`: Wert
- **=** heißt "Zuweisung" (nicht "gleich"!)

### Beispiele

```python
# Zahlen
alter = 25
groesse = 1.75
temperatur = -5

# Text
name = "Lisa"
stadt = "München"
land = "Deutschland"

# True/False
ist_student = True
hat_fuehrerschein = False

# Nichts
nichts = None
```

### Variablen verwenden

```python
>>> name = "Tom"
>>> print(name)
Tom

>>> alter = 30
>>> print(alter)
30

>>> print("Ich bin", name)
Ich bin Tom

>>> print(name, "ist", alter, "Jahre alt")
Tom ist 30 Jahre alt
```

### Variablen ändern

```python
>>> zahl = 10
>>> print(zahl)
10

>>> zahl = 20  # Neuer Wert!
>>> print(zahl)
20

>>> zahl = zahl + 5  # Alte Zahl + 5
>>> print(zahl)
25
```

**Wichtig:** Das `=` ist **Zuweisung**, nicht Vergleich!

```python
zahl = zahl + 1  # In Mathe wäre das unmöglich!
```

**So liest Python das:**
1. Nimm den aktuellen Wert von `zahl` (z.B. 10)
2. Addiere 1 (= 11)
3. Speichere das Ergebnis zurück in `zahl`

### Mehrere Variablen gleichzeitig

```python
# Methode 1: Einzeln
x = 5
y = 10
z = 15

# Methode 2: In einer Zeile
x, y, z = 5, 10, 15

# Methode 3: Alle gleicher Wert
x = y = z = 0

print(x, y, z)  # 0 0 0
```

---

## 📏 Namensregeln

### MUSS-Regeln (sonst gibt's Fehler!)

#### 1. Nur Buchstaben, Zahlen, Unterstrich

```python
# ✅ Erlaubt
name = "Max"
name1 = "Max"
user_name = "Max"
userName = "Max"
_name = "Max"
name_ = "Max"
__name = "Max"

# ❌ NICHT erlaubt
user-name = "Max"  # Bindestrich ❌
user.name = "Max"  # Punkt ❌
user name = "Max"  # Leerzeichen ❌
user@name = "Max"  # Sonderzeichen ❌
```

#### 2. Darf nicht mit Zahl beginnen

```python
# ✅ Erlaubt
alter1 = 25
test2 = "ok"
abc123 = "super"

# ❌ NICHT erlaubt
1alter = 25  # ❌
2test = "fail"  # ❌
```

#### 3. Keine reservierten Wörter

Python hat 35 "reservierte Wörter" (keywords), die du nicht verwenden darfst:

```python
# ❌ Diese sind VERBOTEN als Variablennamen:
and, as, assert, break, class, continue, def, del, 
elif, else, except, False, finally, for, from, global, 
if, import, in, is, lambda, None, nonlocal, not, or, 
pass, raise, return, True, try, while, with, yield
```

```python
# ❌ Fehler
if = 5  # SyntaxError
for = 10  # SyntaxError
True = False  # SyntaxError

# ✅ Alternative
wenn = 5
fuer = 10
wahr = True
```

#### 4. Case-Sensitive

```python
name = "Tom"
Name = "Lisa"
NAME = "Max"

print(name)  # Tom
print(Name)  # Lisa
print(NAME)  # Max

# Das sind 3 VERSCHIEDENE Variablen!
```

### SOLLTE-Regeln (Best Practices)

#### 1. snake_case für Variablen

```python
# ✅ Gut (snake_case)
user_name = "Max"
max_speed = 100
is_active = True

# ❌ Nicht üblich (aber funktioniert)
userName = "Max"  # camelCase (in Python unüblich)
USERNAME = "Max"  # UPPERCASE (für Konstanten reserviert)
```

#### 2. Beschreibende Namen

```python
# ❌ Schlecht (nicht verständlich)
x = "Max"
a = 25
b = "Berlin"

# ✅ Gut (selbsterklärend)
name = "Max"
alter = 25
stadt = "Berlin"
```

#### 3. Keine einzelnen Buchstaben (Ausnahmen: i, j, k in Schleifen)

```python
# ❌ Schlecht
a = 10
b = 20
c = a + b

# ✅ Gut
preis = 10
steuer = 20
gesamt = preis + steuer
```

#### 4. GROSSBUCHSTABEN für Konstanten

```python
# Konstanten = Werte die sich nie ändern
PI = 3.14159
MAX_SPEED = 200
EARTH_RADIUS = 6371

# Dann verwenden
umfang = 2 * PI * radius
```

---

## 🎨 Datentypen

Python hat verschiedene **Datentypen**. Jeder Typ kann unterschiedliche Dinge.

### 1. Integer (int) - Ganze Zahlen

```python
alter = 25
jahr = 2024
temperatur = -10
grosse_zahl = 1000000
```

**Eigenschaften:**
- Keine Dezimalstellen
- Kann positiv oder negativ sein
- Keine Größenbeschränkung (nur Speicher-Limit)

```python
>>> x = 5
>>> type(x)
<class 'int'>

# Riesige Zahlen
>>> große_zahl = 123456789012345678901234567890
>>> print(große_zahl)
123456789012345678901234567890
```

**Unterstriche für Lesbarkeit** (Python 3.6+):
```python
million = 1_000_000
milliarde = 1_000_000_000

print(million)  # 1000000
```

### 2. Float - Dezimalzahlen

```python
groesse = 1.75
pi = 3.14159
temperatur = -5.5
wissenschaftlich = 1.5e3  # 1.5 * 10^3 = 1500
```

**Eigenschaften:**
- Mit Dezimalpunkt (nicht Komma!)
- Kann sehr klein oder sehr groß sein

```python
>>> x = 3.14
>>> type(x)
<class 'float'>

# Wissenschaftliche Notation
>>> groß = 1.5e6  # 1.5 * 10^6 = 1500000
>>> klein = 1.5e-6  # 0.0000015
```

**⚠️ Float-Genauigkeit Problem:**
```python
>>> 0.1 + 0.2
0.30000000000000004  # Nicht genau 0.3!
```

Das ist normal bei allen Programmiersprachen (Binary Floating Point).

### 3. String (str) - Text

```python
name = "Max"
nachricht = 'Hallo'
satz = "Ich bin 25 Jahre alt"
leer = ""
```

**Eigenschaften:**
- Mit `"` oder `'` (beide gleich)
- Kann leer sein
- Kann Zahlen enthalten (als Text)

```python
>>> text = "Hallo"
>>> type(text)
<class 'str'>

# Beide gleich
>>> "Hallo" == 'Hallo'
True
```

**Wann welche Anführungszeichen?**

```python
# Einfach: Egal
name = "Max"
name = 'Max'

# Wenn String Anführungszeichen enthält:
satz = "Er sagte: 'Hallo'"  # ✅
satz = 'Er sagte: "Hallo"'  # ✅
satz = "Er sagte: \"Hallo\""  # ✅ mit Escape

# Mehrzeilig
text = """Das ist
eine mehrzeilige
Nachricht"""

text = '''Auch
mit einfachen
Anführungszeichen'''
```

**String ist NICHT Zahl:**
```python
>>> alter = "25"  # String!
>>> type(alter)
<class 'str'>

>>> alter = 25  # Integer!
>>> type(alter)
<class 'int'>
```

### 4. Boolean (bool) - Wahr/Falsch

```python
ist_student = True
hat_auto = False
ist_erwachsen = True
```

**Eigenschaften:**
- Nur 2 Werte: `True` oder `False`
- Großgeschrieben! (nicht `true` oder `false`)
- Für Logik/Entscheidungen

```python
>>> x = True
>>> type(x)
<class 'bool'>

>>> print(5 > 3)
True

>>> print(10 < 5)
False
```

**Boolean aus Vergleichen:**
```python
alter = 18
ist_erwachsen = alter >= 18
print(ist_erwachsen)  # True

punkte = 45
hat_bestanden = punkte >= 50
print(hat_bestanden)  # False
```

### 5. NoneType - Nichts

```python
ergebnis = None
```

**Eigenschaften:**
- Bedeutet "kein Wert" oder "unbekannt"
- Nur ein Wert: `None`
- Wird oft als Platzhalter verwendet

```python
>>> x = None
>>> type(x)
<class 'NoneType'>

>>> print(x)
None
```

**Wann verwenden?**
```python
# Platzhalter für später
user_input = None
# ... später wird es gefüllt
user_input = "Max"

# Funktion die nichts zurückgibt
def sage_hallo():
    print("Hallo")
    # return None (implizit)

ergebnis = sage_hallo()  # ergebnis ist None
```

### 6. Complex - Komplexe Zahlen (für Mathematik)

```python
z = 3 + 4j
```

**Eigenschaften:**
- Für wissenschaftliche Berechnungen
- Real- und Imaginärteil
- Selten für Anfänger gebraucht

```python
>>> z = 3 + 4j
>>> type(z)
<class 'complex'>

>>> z.real
3.0
>>> z.imag
4.0
```

---

## 🔍 Type Checking

### type() Funktion

```python
>>> type(42)
<class 'int'>

>>> type(3.14)
<class 'float'>

>>> type("Hallo")
<class 'str'>

>>> type(True)
<class 'bool'>

>>> type(None)
<class 'NoneType'>
```

### isinstance() Funktion

Prüft, ob Variable einen bestimmten Typ hat:

```python
>>> x = 10
>>> isinstance(x, int)
True

>>> isinstance(x, str)
False

>>> name = "Max"
>>> isinstance(name, str)
True
```

**Warum nützlich?**
```python
alter = 25

if isinstance(alter, int):
    print("Alter ist eine Zahl")
else:
    print("Alter ist keine Zahl")
```

---

## 🔄 Type Casting - Typ umwandeln

### Von String zu Zahl

```python
# String → Integer
>>> x = "25"
>>> y = int(x)
>>> print(y, type(y))
25 <class 'int'>

# String → Float
>>> x = "3.14"
>>> y = float(x)
>>> print(y, type(y))
3.14 <class 'float'>
```

**Häufiger Anwendungsfall:**
```python
# User-Input ist immer String!
alter_text = input("Wie alt bist du? ")  # "25"
alter = int(alter_text)  # 25
print("In 5 Jahren bist du", alter + 5)
```

### Von Zahl zu String

```python
>>> x = 25
>>> y = str(x)
>>> print(y, type(y))
25 <class 'str'>

>>> z = 3.14
>>> w = str(z)
>>> print(w, type(w))
3.14 <class 'str'>
```

**Warum nützlich?**
```python
alter = 25
# print("Ich bin " + alter)  # ❌ Fehler!
print("Ich bin " + str(alter))  # ✅ Funktioniert!
```

### Andere Umwandlungen

```python
# Float → Integer (schneidet ab!)
>>> int(3.9)
3
>>> int(3.1)
3

# Integer → Float
>>> float(10)
10.0

# Zu Boolean
>>> bool(1)
True
>>> bool(0)
False
>>> bool("Hallo")
True
>>> bool("")
False
>>> bool(None)
False
```

### ⚠️ Fehler beim Casting

```python
# Kann nicht umgewandelt werden:
>>> int("Hallo")
ValueError: invalid literal for int()

>>> int("3.14")
ValueError: invalid literal for int()

# Richtig:
>>> float("3.14")
3.14
>>> int(float("3.14"))
3
```

---

## 🎭 Praktische Beispiele

### Beispiel 1: Rechner

```python
# User-Input
zahl1 = input("Erste Zahl: ")
zahl2 = input("Zweite Zahl: ")

# Umwandeln zu Integer
zahl1 = int(zahl1)
zahl2 = int(zahl2)

# Rechnen
summe = zahl1 + zahl2
differenz = zahl1 - zahl2
produkt = zahl1 * zahl2
quotient = zahl1 / zahl2

# Ausgabe
print("Summe:", summe)
print("Differenz:", differenz)
print("Produkt:", produkt)
print("Quotient:", quotient)
```

### Beispiel 2: Profil-Generator

```python
name = input("Dein Name: ")
alter = int(input("Dein Alter: "))
stadt = input("Deine Stadt: ")
ist_student = input("Bist du Student? (ja/nein): ")

ist_student = ist_student.lower() == "ja"

print("\n--- DEIN PROFIL ---")
print("Name:", name)
print("Alter:", alter)
print("Stadt:", stadt)
print("Student:", ist_student)
print("In 10 Jahren:", alter + 10, "Jahre alt")
```

### Beispiel 3: Typ-Checker

```python
wert = input("Gib irgendwas ein: ")

print("Typ:", type(wert))  # Immer str
print("Länge:", len(wert))

# Versuche zu konvertieren
try:
    als_int = int(wert)
    print("Als Integer:", als_int)
except:
    print("Kann nicht zu Integer konvertiert werden")

try:
    als_float = float(wert)
    print("Als Float:", als_float)
except:
    print("Kann nicht zu Float konvertiert werden")
```

---

## 🐛 Häufige Fehler

### 1. String + Integer

```python
# ❌ Fehler
alter = 25
print("Ich bin " + alter)  # TypeError!

# ✅ Lösung 1: Casting
print("Ich bin " + str(alter))

# ✅ Lösung 2: Komma
print("Ich bin", alter)

# ✅ Lösung 3: f-string (modern)
print(f"Ich bin {alter}")
```

### 2. Integer Division

```python
>>> 5 / 2
2.5  # Float!

>>> type(5 / 2)
<class 'float'>

# Wenn du Integer willst:
>>> 5 // 2
2  # Ganzzahl-Division
```

### 3. Variable nicht definiert

```python
>>> print(name)
NameError: name 'name' is not defined

# Erst definieren!
>>> name = "Max"
>>> print(name)
Max
```

### 4. Tippfehler

```python
>>> alter = 25
>>> print(Alter)  # Großgeschrieben!
NameError: name 'Alter' is not defined
```

---

## 📝 Übungen

### Übung 1: Variablen erstellen
Erstelle Variablen für:
- Dein Name
- Dein Alter
- Deine Lieblingsfarbe
- Ob du Haustiere hast (True/False)

Gib dann alles aus.

### Übung 2: Type Checking
```python
a = 10
b = "20"
c = 3.14
d = True

# Überprüfe den Typ von jeder Variable
# Gib aus: "a ist vom Typ: ..."
```

### Übung 3: Type Casting
```python
x = "100"
y = "25.5"

# Wandle x zu Integer um
# Wandle y zu Float um
# Addiere sie
# Gib das Ergebnis aus
```

### Übung 4: Alters-Rechner
Schreibe ein Programm das:
1. Nach deinem Geburtsjahr fragt
2. Das aktuelle Jahr ist 2024
3. Berechnet wie alt du bist
4. Berechnet wie alt du in 10 Jahren sein wirst
5. Alles schön ausgibt

### Übung 5: Fehler finden
Was ist falsch hier?
```python
1name = "Tom"
Name = "Lisa"
alter = "25"
print("Ich bin " + alter + " Jahre alt")
ergebnis = alter + 5
```

### Übung 6: Kreis-Rechner
```python
PI = 3.14159
radius = float(input("Radius: "))

# Berechne:
# - Umfang = 2 * PI * radius
# - Fläche = PI * radius * radius

# Gib beides aus
```

---

## 🎓 Was du gelernt hast

✅ Was Variablen sind (Kartons für Daten)  
✅ Wie man Variablen erstellt und ändert  
✅ Namensregeln (MUSS und SOLLTE)  
✅ Alle wichtigen Datentypen (int, float, str, bool, None)  
✅ Type Checking mit type() und isinstance()  
✅ Type Casting (Typ-Umwandlung)  
✅ Häufige Fehler vermeiden  

---

## 🧠 Wichtige Takeaways

1. **Variablen** = Beschriftete Container für Daten
2. **= bedeutet Zuweisung**, nicht Vergleich
3. **Namen**: klein, snake_case, beschreibend
4. **5 Haupttypen**: int, float, str, bool, None
5. **type()** zeigt den Typ
6. **int(), float(), str()** wandelt um
7. **User-Input ist immer String!**

---

## ➡️ Weiter geht's

In der nächsten Lektion lernst du über:
- **Operatoren** - Rechnen, vergleichen, logische Operationen
- **Operator-Priorität** - Was wird zuerst berechnet?
- **Erweiterte Zuweisungen** - +=, -=, etc.

**Bereit? Auf zur [Lektion 3: Operatoren](03_operatoren.md)!**

---

## 💬 Fragen?

Variablen und Datentypen sind fundamental! Wenn etwas unklar ist, frag mich! 🙂
