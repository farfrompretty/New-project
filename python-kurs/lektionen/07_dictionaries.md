# 📚 Lektion 7: Dictionaries (Wörterbücher)

## 📖 Inhaltsverzeichnis
- [Was sind Dictionaries?](#was-sind-dictionaries)
- [Dictionaries erstellen](#dictionaries-erstellen)
- [Zugriff auf Werte](#zugriff-auf-werte)
- [Dict-Methoden](#dict-methoden)
- [Dict manipulieren](#dict-manipulieren)
- [Durch Dicts iterieren](#durch-dicts-iterieren)
- [Verschachtelte Dicts](#verschachtelte-dicts)
- [Dict Comprehensions](#dict-comprehensions)
- [Übungen](#übungen)

---

## 🤔 Was sind Dictionaries?

**Dictionary** = Wörterbuch = Key-Value Paare

### Die Telefonbuch-Analogie

Stell dir ein **Telefonbuch** 📞 vor:

```
Max        → 0123456789
Anna       → 0234567890
Tom        → 0345678901
```

- **Name** = Key (Schlüssel)
- **Nummer** = Value (Wert)

In Python:

```python
telefonbuch = {
    "Max": "0123456789",
    "Anna": "0234567890",
    "Tom": "0345678901"
}
```

### Warum Dictionaries?

**Ohne Dict (mit Listen):**
```python
namen = ["Max", "Anna", "Tom"]
nummern = ["0123456789", "0234567890", "0345678901"]

# Nummer von Anna finden? Mühsam!
index = namen.index("Anna")
nummer = nummern[index]  # 😰
```

**Mit Dict:**
```python
telefonbuch = {
    "Max": "0123456789",
    "Anna": "0234567890",
    "Tom": "0345678901"
}

nummer = telefonbuch["Anna"]  # Direkt! 🎉
```

### Eigenschaften

- ✅ **Key-Value Paare** (Schlüssel → Wert)
- ✅ **Keys sind eindeutig** (keine Duplikate)
- ✅ **Mutable** (veränderlich)
- ✅ **Ungeordnet** (seit Python 3.7 Einfüge-Reihenfolge erhalten)
- ✅ **Schneller Zugriff** (O(1))

---

## ✍️ Dictionaries erstellen

### Leeres Dictionary

```python
# Methode 1: {}
dict1 = {}

# Methode 2: dict()
dict2 = dict()

>>> type(dict1)
<class 'dict'>
```

### Dict mit Werten

```python
# Syntax: {key: value, key: value, ...}

# Strings als Keys
person = {
    "name": "Max",
    "alter": 25,
    "stadt": "Berlin"
}

# Zahlen als Keys
noten = {
    1: "Sehr gut",
    2: "Gut",
    3: "Befriedigend"
}

# Gemischte Keys
gemischt = {
    "name": "Max",
    42: "Die Antwort",
    True: "Wahr"
}
```

### Mit dict()

```python
# Mit Keyword-Arguments
>>> person = dict(name="Max", alter=25, stadt="Berlin")
>>> print(person)
{'name': 'Max', 'alter': 25, 'stadt': 'Berlin'}

# Aus Liste von Tupeln
>>> paare = [("a", 1), ("b", 2), ("c", 3)]
>>> d = dict(paare)
>>> print(d)
{'a': 1, 'b': 2, 'c': 3}

# Aus zwei Listen (zip)
>>> keys = ["name", "alter", "stadt"]
>>> values = ["Max", 25, "Berlin"]
>>> person = dict(zip(keys, values))
>>> print(person)
{'name': 'Max', 'alter': 25, 'stadt': 'Berlin'}
```

### Mehrzeilig (übersichtlich!)

```python
person = {
    "vorname": "Max",
    "nachname": "Mustermann",
    "alter": 25,
    "stadt": "Berlin",
    "beruf": "Programmierer",
    "hobbies": ["Programmieren", "Lesen", "Sport"]
}
```

---

## 🔍 Zugriff auf Werte

### Mit [] - Direkt

```python
person = {
    "name": "Max",
    "alter": 25,
    "stadt": "Berlin"
}

>>> person["name"]
'Max'

>>> person["alter"]
25

>>> person["stadt"]
'Berlin'
```

**ACHTUNG: KeyError wenn nicht vorhanden:**
```python
>>> person["email"]
KeyError: 'email'
```

### Mit get() - Sicher

```python
person = {
    "name": "Max",
    "alter": 25
}

# Mit get()
>>> person.get("name")
'Max'

# Key nicht vorhanden → None
>>> person.get("email")
None

# Default-Wert angeben
>>> person.get("email", "Keine Email")
'Keine Email'

>>> person.get("alter", 0)
25  # Alter vorhanden, also echten Wert
```

**Best Practice: get() verwenden!**

```python
# ❌ Unsicher
if "email" in person:
    email = person["email"]
else:
    email = "Keine Email"

# ✅ Besser
email = person.get("email", "Keine Email")
```

### Prüfen ob Key existiert

```python
person = {
    "name": "Max",
    "alter": 25
}

>>> "name" in person
True

>>> "email" in person
False

>>> "email" not in person
True
```

---

## 🛠️ Dict-Methoden

### keys() - Alle Schlüssel

```python
>>> person = {"name": "Max", "alter": 25, "stadt": "Berlin"}
>>> person.keys()
dict_keys(['name', 'alter', 'stadt'])

# Zu Liste
>>> list(person.keys())
['name', 'alter', 'stadt']

# Iterieren
>>> for key in person.keys():
...     print(key)
name
alter
stadt
```

### values() - Alle Werte

```python
>>> person.values()
dict_values(['Max', 25, 'Berlin'])

# Zu Liste
>>> list(person.values())
['Max', 25, 'Berlin']

# Iterieren
>>> for value in person.values():
...     print(value)
Max
25
Berlin
```

### items() - Key-Value Paare

```python
>>> person.items()
dict_items([('name', 'Max'), ('alter', 25), ('stadt', 'Berlin')])

# Zu Liste
>>> list(person.items())
[('name', 'Max'), ('alter', 25), ('stadt', 'Berlin')]

# Iterieren (am nützlichsten!)
>>> for key, value in person.items():
...     print(f"{key}: {value}")
name: Max
alter: 25
stadt: Berlin
```

### pop() - Element entfernen

```python
>>> person = {"name": "Max", "alter": 25, "stadt": "Berlin"}

>>> alter = person.pop("alter")
>>> print(alter)
25
>>> print(person)
{'name': 'Max', 'stadt': 'Berlin'}

# Mit Default wenn nicht vorhanden
>>> email = person.pop("email", "N/A")
>>> print(email)
N/A
```

### popitem() - Letztes Element entfernen

```python
>>> person = {"name": "Max", "alter": 25, "stadt": "Berlin"}
>>> letztes = person.popitem()
>>> print(letztes)
('stadt', 'Berlin')
>>> print(person)
{'name': 'Max', 'alter': 25}
```

### update() - Dict erweitern/aktualisieren

```python
>>> person = {"name": "Max", "alter": 25}

# Mit anderem Dict
>>> zusatz = {"stadt": "Berlin", "beruf": "Programmierer"}
>>> person.update(zusatz)
>>> print(person)
{'name': 'Max', 'alter': 25, 'stadt': 'Berlin', 'beruf': 'Programmierer'}

# Mit Keywords
>>> person.update(alter=26, email="max@example.com")
>>> print(person)
{'name': 'Max', 'alter': 26, 'stadt': 'Berlin', 'beruf': 'Programmierer', 'email': 'max@example.com'}

# Überschreibt vorhandene Keys!
>>> person.update(name="Anna")
>>> print(person)
{'name': 'Anna', ...}
```

### clear() - Alles löschen

```python
>>> person = {"name": "Max", "alter": 25}
>>> person.clear()
>>> print(person)
{}
```

### copy() - Dict kopieren

```python
>>> original = {"a": 1, "b": 2}
>>> kopie = original.copy()

>>> kopie["c"] = 3
>>> print(original)
{'a': 1, 'b': 2}  # Unverändert ✅
>>> print(kopie)
{'a': 1, 'b': 2, 'c': 3}
```

**Falle vermeiden:**
```python
>>> dict1 = {"a": 1}
>>> dict2 = dict1  # Keine Kopie! Referenz!
>>> dict2["b"] = 2
>>> print(dict1)
{'a': 1, 'b': 2}  # Auch geändert! 😱

# Richtig:
>>> dict1 = {"a": 1}
>>> dict2 = dict1.copy()
```

### setdefault() - Wert setzen wenn nicht vorhanden

```python
>>> person = {"name": "Max"}

# Key vorhanden → gibt Wert zurück
>>> person.setdefault("name", "Anna")
'Max'

# Key nicht vorhanden → setzt und gibt Wert zurück
>>> person.setdefault("alter", 25)
25
>>> print(person)
{'name': 'Max', 'alter': 25}
```

**Praktisch für Zähler:**
```python
woerter = ["python", "ist", "toll", "python", "macht", "spaß", "python"]
zaehler = {}

for wort in woerter:
    zaehler.setdefault(wort, 0)
    zaehler[wort] += 1

print(zaehler)
# {'python': 3, 'ist': 1, 'toll': 1, 'macht': 1, 'spaß': 1}
```

---

## 🔧 Dict manipulieren

### Werte hinzufügen/ändern

```python
>>> person = {"name": "Max"}

# Neuen Key hinzufügen
>>> person["alter"] = 25
>>> print(person)
{'name': 'Max', 'alter': 25}

# Vorhandenen Key ändern
>>> person["alter"] = 26
>>> print(person)
{'name': 'Max', 'alter': 26}
```

### Werte löschen

```python
>>> person = {"name": "Max", "alter": 25, "stadt": "Berlin"}

# Mit del
>>> del person["alter"]
>>> print(person)
{'name': 'Max', 'stadt': 'Berlin'}

# Mit pop() (gibt Wert zurück)
>>> stadt = person.pop("stadt")
>>> print(stadt)
Berlin
>>> print(person)
{'name': 'Max'}
```

### Werte inkrementieren

```python
>>> zaehler = {"apfel": 5, "banane": 3}

# Inkrementieren
>>> zaehler["apfel"] += 1
>>> print(zaehler)
{'apfel': 6, 'banane': 3}

# Neuen Key (braucht Prüfung!)
>>> if "kirsche" in zaehler:
...     zaehler["kirsche"] += 1
... else:
...     zaehler["kirsche"] = 1

# Besser:
>>> zaehler["kirsche"] = zaehler.get("kirsche", 0) + 1
```

---

## 🔄 Durch Dicts iterieren

### Über Keys

```python
person = {"name": "Max", "alter": 25, "stadt": "Berlin"}

# Direkt (iteriert über Keys)
for key in person:
    print(key)

# Explizit
for key in person.keys():
    print(key)

# Ausgabe:
# name
# alter
# stadt
```

### Über Values

```python
for value in person.values():
    print(value)

# Ausgabe:
# Max
# 25
# Berlin
```

### Über Key-Value Paare

```python
for key, value in person.items():
    print(f"{key}: {value}")

# Ausgabe:
# name: Max
# alter: 25
# stadt: Berlin
```

### Praktische Beispiele

**Schöne Ausgabe:**
```python
person = {
    "Name": "Max Mustermann",
    "Alter": 25,
    "Stadt": "Berlin",
    "Beruf": "Programmierer"
}

print("=" * 40)
for key, value in person.items():
    print(f"{key:.<20} {value}")
print("=" * 40)

# Ausgabe:
# ========================================
# Name.................. Max Mustermann
# Alter................. 25
# Stadt................. Berlin
# Beruf................. Programmierer
# ========================================
```

**Filtern:**
```python
produkte = {
    "Apfel": 2.50,
    "Banane": 1.80,
    "Kirsche": 4.00,
    "Dattel": 3.50
}

# Nur Produkte über 3€
teuer = {k: v for k, v in produkte.items() if v > 3.0}
print(teuer)
# {'Kirsche': 4.0, 'Dattel': 3.5}
```

---

## 📦 Verschachtelte Dicts

**Dict in Dict:**

```python
users = {
    "user1": {
        "name": "Max",
        "alter": 25,
        "email": "max@example.com"
    },
    "user2": {
        "name": "Anna",
        "alter": 30,
        "email": "anna@example.com"
    }
}

# Zugriff
>>> users["user1"]["name"]
'Max'

>>> users["user2"]["alter"]
30

# Ändern
>>> users["user1"]["alter"] = 26

# Hinzufügen
>>> users["user3"] = {
...     "name": "Tom",
...     "alter": 22,
...     "email": "tom@example.com"
... }
```

**Praktisches Beispiel - Kontaktverwaltung:**

```python
kontakte = {
    "Max": {
        "telefon": "0123456789",
        "email": "max@example.com",
        "adresse": {
            "strasse": "Hauptstraße 1",
            "plz": "10115",
            "stadt": "Berlin"
        }
    },
    "Anna": {
        "telefon": "0234567890",
        "email": "anna@example.com",
        "adresse": {
            "strasse": "Bahnhofstraße 5",
            "plz": "80335",
            "stadt": "München"
        }
    }
}

# Zugriff
print(kontakte["Max"]["adresse"]["stadt"])  # Berlin

# Iterieren
for name, daten in kontakte.items():
    print(f"\n{name}:")
    print(f"  Tel: {daten['telefon']}")
    print(f"  Email: {daten['email']}")
    print(f"  Stadt: {daten['adresse']['stadt']}")
```

**Liste von Dicts:**

```python
studenten = [
    {"name": "Max", "alter": 25, "note": 1.7},
    {"name": "Anna", "alter": 23, "note": 1.3},
    {"name": "Tom", "alter": 24, "note": 2.0}
]

# Iterieren
for student in studenten:
    print(f"{student['name']} (Note: {student['note']})")

# Durchschnittsnote
durchschnitt = sum(s["note"] for s in studenten) / len(studenten)
print(f"Durchschnittsnote: {durchschnitt:.2f}")
```

---

## 🚀 Dict Comprehensions

**Elegante Dict-Erstellung!**

### Syntax

```python
{key_expression: value_expression for item in iterable}
```

### Einfache Beispiele

```python
# Quadratzahlen
>>> quadrate = {x: x**2 for x in range(1, 6)}
>>> print(quadrate)
{1: 1, 2: 4, 3: 9, 4: 16, 5: 25}

# String-Längen
>>> woerter = ["Python", "ist", "toll"]
>>> laengen = {wort: len(wort) for wort in woerter}
>>> print(laengen)
{'Python': 6, 'ist': 3, 'toll': 4}

# Keys und Values tauschen
>>> original = {"a": 1, "b": 2, "c": 3}
>>> getauscht = {v: k for k, v in original.items()}
>>> print(getauscht)
{1: 'a', 2: 'b', 3: 'c'}
```

### Mit Bedingung

```python
# Nur gerade Zahlen
>>> gerade = {x: x**2 for x in range(10) if x % 2 == 0}
>>> print(gerade)
{0: 0, 2: 4, 4: 16, 6: 36, 8: 64}

# Filtern nach Wert
>>> zahlen = {"a": 10, "b": 5, "c": 20, "d": 8}
>>> gross = {k: v for k, v in zahlen.items() if v > 8}
>>> print(gross)
{'a': 10, 'c': 20}
```

### Praktische Beispiele

**Wörter zählen:**
```python
text = "python ist toll python macht spaß"
woerter = text.split()

# Count occurrences
count = {wort: woerter.count(wort) for wort in set(woerter)}
print(count)
# {'python': 2, 'ist': 1, 'toll': 1, 'macht': 1, 'spaß': 1}
```

**Notensystem:**
```python
punkte = {"Max": 85, "Anna": 92, "Tom": 78, "Lisa": 95}

# Noten vergeben
def note(punkte):
    if punkte >= 90: return "A"
    if punkte >= 80: return "B"
    if punkte >= 70: return "C"
    return "F"

noten = {name: note(p) for name, p in punkte.items()}
print(noten)
# {'Max': 'B', 'Anna': 'A', 'Tom': 'C', 'Lisa': 'A'}
```

---

## 📝 Übungen

### Übung 1: Benutzer-Profil
```python
# Erstelle ein Dict mit deinen Daten:
# - name, alter, stadt, hobbies (Liste), email
# Gib alles schön formatiert aus
```

### Übung 2: Wörterzähler
```python
text = input("Gib einen Satz ein: ")
# Zähle wie oft jedes Wort vorkommt
# Gib aus: "Wort: X×"
```

### Übung 3: Telefonbuch-App
```python
# Erstelle ein Programm:
# - add: Kontakt hinzufügen (Name + Nummer)
# - search: Kontakt suchen
# - delete: Kontakt löschen
# - list: Alle Kontakte
# - quit: Beenden
```

### Übung 4: Notenverwaltung
```python
# Dict mit Schülern und ihren Noten (Liste)
schueler = {
    "Max": [1.7, 2.0, 1.3],
    "Anna": [1.0, 1.3, 1.0],
    "Tom": [2.3, 2.7, 2.0]
}

# Berechne für jeden:
# - Durchschnittsnote
# - Beste Note
# - Schlechteste Note
```

### Übung 5: Inventar-System
```python
inventar = {
    "Apfel": {"menge": 50, "preis": 0.50},
    "Banane": {"menge": 30, "preis": 0.30},
    "Kirsche": {"menge": 20, "preis": 2.00}
}

# Funktionen:
# - Gesamtwert berechnen
# - Produkt hinzufügen
# - Menge ändern
# - Alle Produkte unter 1€ anzeigen
```

### Übung 6: Dict Comprehension
```python
# a) Erstelle Dict: {1: 1, 2: 4, 3: 9, ..., 10: 100}
# b) Aus ["a", "b", "c"] erstelle {"a": 0, "b": 1, "c": 2}
# c) Filtere alle Keys die mit "a" beginnen:
#    {"apfel": 1, "banane": 2, "ananas": 3}
```

### Übung 7: Gruppen bilden
```python
studenten = [
    {"name": "Max", "kurs": "Python"},
    {"name": "Anna", "kurs": "Java"},
    {"name": "Tom", "kurs": "Python"},
    {"name": "Lisa", "kurs": "Java"}
]

# Gruppiere nach Kurs:
# {"Python": ["Max", "Tom"], "Java": ["Anna", "Lisa"]}
```

### Übung 8: Config-Parser
```python
# Lies eine Config-Datei (simuliert):
config_text = """
name=MyApp
version=1.0
debug=true
port=8080
"""

# Parse zu Dict: {"name": "MyApp", "version": "1.0", ...}
```

---

## 🎓 Was du gelernt hast

✅ Dictionaries erstellen (Key-Value Paare)  
✅ Zugriff mit [] und get()  
✅ Dict-Methoden (keys, values, items, update, pop, etc.)  
✅ Durch Dicts iterieren  
✅ Verschachtelte Dicts  
✅ Dict Comprehensions  

---

## 🧠 Wichtige Takeaways

1. **Dict**: `{key: value}`
2. **get()** sicherer als `[]`
3. **items()** für Iteration über Key-Value Paare
4. **Keys müssen eindeutig** sein
5. **Keys müssen immutable** sein (str, int, tuple)
6. **Schneller Zugriff** mit Keys (O(1))
7. **Dict Comprehensions**: `{k: v for k, v in ...}`

---

## ➡️ Weiter geht's

In der nächsten Lektion lernst du über:
- **if/elif/else** - Entscheidungen treffen
- **Bedingungen** - Wann wird was ausgeführt?
- **Verschachtelte Bedingungen**

**Bereit? Auf zur [Lektion 8: Kontrollstrukturen](08_kontrollstrukturen.md)!**
