# Atelier 1 : Test unitaire avec JUnit 5 — Corrigé

Structure du projet :

```
src/
 └── junit/monprojet/
      ├── SommeArgent.java
      ├── UniteDistincteException.java
      └── PorteMonnaie.java
test/
 └── junit/monprojet/test/
      ├── SommeArgentTest.java
      └── PorteMonnaieTest.java
```

---

## Exercice 1 — Première partie

### Q1 — Classe `SommeArgent` (version initiale)

```java
package junit.monprojet;

public class SommeArgent {
    private int quantite;
    private String unite;

    public SommeArgent(int amount, String currency) {
        quantite = amount;
        unite = currency;
    }

    public int getQuantite() {
        return quantite;
    }

    public String getUnite() {
        return unite;
    }

    public SommeArgent add(SommeArgent m) {
        return new SommeArgent(getQuantite() + m.getQuantite(), getUnite());
    }
}
```

### Q2 — Méthode `equals()`

Deux sommes sont égales si elles ont **même unité** et **même quantité**.

```java
@Override
public boolean equals(Object anObject) {
    if (this == anObject) return true;
    if (anObject == null || getClass() != anObject.getClass()) return false;
    SommeArgent autre = (SommeArgent) anObject;
    return quantite == autre.quantite && unite.equals(autre.unite);
}

// Bonne pratique : redéfinir hashCode() avec equals()
@Override
public int hashCode() {
    return java.util.Objects.hash(quantite, unite);
}
```

### Q3 — Création de la classe de test

Dans le package `junit.monprojet.test` : *New → JUnit Test Case* → choisir **JUnit Jupiter (JUnit 5)** → nommer `SommeArgentTest`. Eclipse ajoute automatiquement la bibliothèque JUnit 5 au Build Path.

### Q4 — Test de l'addition

```java
package junit.monprojet.test;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;
import junit.monprojet.SommeArgent;

class SommeArgentTest {

    @Test
    void testAdd() {
        SommeArgent m12CHF = new SommeArgent(12, "CHF"); // (1)
        SommeArgent m14CHF = new SommeArgent(14, "CHF");
        SommeArgent expected = new SommeArgent(26, "CHF");
        SommeArgent result = m12CHF.add(m14CHF);          // (2)
        assertTrue(expected.equals(result));              // (3)
    }
}
```

### Q5 — Lancement

*Clic droit sur la classe → Run As → JUnit Test*. La barre doit être **verte** : « Keep the bar green to keep the code clean ».

---

## Seconde partie

### Q6 — Test de `equals()`

```java
@Test
void testEquals() {
    SommeArgent m12CHF = new SommeArgent(12, "CHF");
    SommeArgent m14CHF = new SommeArgent(14, "CHF");
    SommeArgent m14USD = new SommeArgent(14, "USD");

    assertTrue(!m12CHF.equals(null));
    assertEquals(m12CHF, m12CHF);
    assertEquals(m12CHF, new SommeArgent(12, "CHF"));
    assertTrue(!m12CHF.equals(m14CHF));
    assertTrue(!m14USD.equals(m14CHF));
}
```

**Scénarios testés :**

| Instruction | Scénario |
|---|---|
| `!m12CHF.equals(null)` | Une somme n'est jamais égale à `null` |
| `assertEquals(m12CHF, m12CHF)` | **Réflexivité** : un objet est égal à lui-même |
| `assertEquals(m12CHF, new SommeArgent(12, "CHF"))` | Deux objets distincts, **même quantité et même unité** → égaux |
| `!m12CHF.equals(m14CHF)` | **Même unité, quantité différente** → non égaux |
| `!m14USD.equals(m14CHF)` | **Même quantité, unité différente** → non égaux |

### Q7 — Initialisations communes : `@BeforeEach`

```java
import org.junit.jupiter.api.BeforeEach;

class SommeArgentTest {
    private SommeArgent m12CHF;
    private SommeArgent m14CHF;
    private SommeArgent m14USD;

    @BeforeEach
    void setUp() {
        m12CHF = new SommeArgent(12, "CHF");
        m14CHF = new SommeArgent(14, "CHF");
        m14USD = new SommeArgent(14, "USD");
    }

    @Test
    void testAdd() throws UniteDistincteException {
        SommeArgent expected = new SommeArgent(26, "CHF");
        SommeArgent result = m12CHF.add(m14CHF);
        assertTrue(expected.equals(result));
    }

    @Test
    void testEquals() {
        assertTrue(!m12CHF.equals(null));
        assertEquals(m12CHF, m12CHF);
        assertEquals(m12CHF, new SommeArgent(12, "CHF"));
        assertTrue(!m12CHF.equals(m14CHF));
        assertTrue(!m14USD.equals(m14CHF));
    }
}
```

Méthode annotée `@BeforeEach` : exécutée **avant chaque** méthode `@Test`. Pour vérifier, on ajoute un affichage (voir Q9).

### Q8 — Nom de ces ensembles d'objets

Ce sont des **fixtures** (*contexte de test* / *jeu d'essai*) : l'ensemble des objets (`m12CHF`, `m14CHF`, `m14USD`) recréés à l'état initial avant chaque test, ce qui garantit l'indépendance des tests entre eux.

### Q9 — Code exécuté après chaque test : `@AfterEach`

```java
import org.junit.jupiter.api.AfterEach;

private static int compteurAvant = 0;
private static int compteurApres = 0;

@BeforeEach
void setUp() {
    compteurAvant++;
    System.out.println(compteurAvant + "ime passage avant exécution d'une méthode de test");
    m12CHF = new SommeArgent(12, "CHF");
    m14CHF = new SommeArgent(14, "CHF");
    m14USD = new SommeArgent(14, "USD");
}

@AfterEach
void tearDown() {
    compteurApres++;
    System.out.println(compteurApres + "ime passage APRES exécution d'une méthode de test");
    m12CHF = null;
    m14CHF = null;
    m14USD = null;
}
```

**Sortie console obtenue (avec 2 tests) :**

```
1ime passage avant exécution d'une méthode de test
1ime passage APRES exécution d'une méthode de test
2ime passage avant exécution d'une méthode de test
2ime passage APRES exécution d'une méthode de test
```

> (Sans les `static`, les compteurs repartiraient à 0 à chaque test, car JUnit 5 crée une **nouvelle instance** de la classe de test pour chaque méthode.)

---

### Q10 — Unités distinctes : exception `UniteDistincteException`

Si les unités sont différentes, `add()` additionnerait par exemple 12 CHF et 14 USD en 26 CHF : **résultat faux**. On lève donc une exception.

```java
package junit.monprojet;

public class UniteDistincteException extends Exception {
    private SommeArgent somme1, somme2;

    public UniteDistincteException(SommeArgent sa1, SommeArgent sa2) {
        somme1 = sa1;
        somme2 = sa2;
    }

    public String toString() {
        return "unité distincte : " + somme1.getUnite() + " != " + somme2.getUnite();
    }
}
```

Méthode `add()` modifiée dans `SommeArgent` :

```java
public SommeArgent add(SommeArgent m) throws UniteDistincteException {
    if (!m.getUnite().equals(this.getUnite())) {
        throw new UniteDistincteException(this, m);
    } else {
        return new SommeArgent(getQuantite() + m.getQuantite(), getUnite());
    }
}
```

### Q11 — Correction des erreurs de compilation

`add()` lève maintenant une exception **vérifiée** (checked) : tout appelant doit soit l'attraper, soit la déclarer. Dans les tests :

```java
@Test
void testAdd() throws UniteDistincteException {
    SommeArgent expected = new SommeArgent(26, "CHF");
    SommeArgent result = m12CHF.add(m14CHF);
    assertTrue(expected.equals(result));
}
```

### Q12 — Test de l'exception

```java
import junit.monprojet.UniteDistincteException;

@Test
void testAddUnitesDistinctes() {
    UniteDistincteException thrown = assertThrows(UniteDistincteException.class, () -> {
        m12CHF.add(m14USD);   // CHF + USD → exception
    });
}
```

### Q13 — Vérification du message d'erreur

`UniteDistincteException` n'appelle pas `super(message)` : le message est exposé par `toString()`, c'est donc `toString()` qu'on vérifie.

```java
@Test
void testAddUnitesDistinctes() {
    UniteDistincteException thrown = assertThrows(UniteDistincteException.class, () -> {
        m12CHF.add(m14USD);
    });
    assertEquals("unité distincte : CHF != USD", thrown.toString());
}
```

Lancer toute la classe : tous les tests passent → **barre verte**.

---

## Troisième partie : un porte-monnaie

### Q14 — `PorteMonnaie` et `ajouteSomme()`

```java
package junit.monprojet;

import java.util.HashMap;

public class PorteMonnaie {
    private HashMap<String, Integer> contenu;

    public HashMap<String, Integer> getContenu() {
        return contenu;
    }

    public PorteMonnaie() {
        contenu = new HashMap<String, Integer>();
    }

    public void ajouteSomme(SommeArgent sa) {
        String unite = sa.getUnite();
        if (contenu.containsKey(unite)) {
            // il y a déjà cette devise : on cumule (10 € + 12 € = 22 €)
            contenu.put(unite, contenu.get(unite) + sa.getQuantite());
        } else {
            // pas encore de cette devise : on la met simplement
            contenu.put(unite, sa.getQuantite());
        }
    }
}
```

*(Équivalent plus court : `contenu.merge(sa.getUnite(), sa.getQuantite(), Integer::sum);`)*

### Q15 — `toString()`

Dans `SommeArgent` :

```java
@Override
public String toString() {
    return quantite + " " + unite;
}
```

Dans `PorteMonnaie` :

```java
@Override
public String toString() {
    if (contenu.isEmpty()) {
        return "Porte-monnaie vide";
    }
    StringBuilder sb = new StringBuilder("Porte-monnaie : ");
    for (java.util.Map.Entry<String, Integer> e : contenu.entrySet()) {
        sb.append(new SommeArgent(e.getValue(), e.getKey())).append("  ");
    }
    return sb.toString().trim();
}
```

### Q16 — `equals()` de `PorteMonnaie` et sa classe de test

`equals()` dans `PorteMonnaie` : même devises avec mêmes quantités.

```java
@Override
public boolean equals(Object obj) {
    if (this == obj) return true;
    if (obj == null || getClass() != obj.getClass()) return false;
    PorteMonnaie autre = (PorteMonnaie) obj;
    return contenu.equals(autre.contenu);   // HashMap.equals compare clés ET valeurs
}

@Override
public int hashCode() {
    return contenu.hashCode();
}
```

Classe de test :

```java
package junit.monprojet.test;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import junit.monprojet.PorteMonnaie;
import junit.monprojet.SommeArgent;

class PorteMonnaieTest {
    private PorteMonnaie pm1;
    private PorteMonnaie pm2;

    @BeforeEach
    void setUp() {
        pm1 = new PorteMonnaie();
        pm2 = new PorteMonnaie();
    }

    @Test
    void testAjouteSomme() {
        // pm1 : 5 € + 5 € ; pm2 : 10 €
        pm1.ajouteSomme(new SommeArgent(5, "EUR"));
        pm1.ajouteSomme(new SommeArgent(5, "EUR"));
        pm2.ajouteSomme(new SommeArgent(10, "EUR"));

        assertEquals(pm2, pm1);
        assertEquals(10, pm1.getContenu().get("EUR"));
    }

    @Test
    void testAjouteSommeDevisesDifferentes() {
        pm1.ajouteSomme(new SommeArgent(10, "EUR"));
        pm1.ajouteSomme(new SommeArgent(12, "EUR"));
        pm1.ajouteSomme(new SommeArgent(7, "USD"));

        assertEquals(22, pm1.getContenu().get("EUR"));
        assertEquals(7, pm1.getContenu().get("USD"));
        assertNotEquals(pm2, pm1);
    }
}
```

---

## Annexe — Classe `SommeArgent` finale

```java
package junit.monprojet;

import java.util.Objects;

public class SommeArgent {
    private int quantite;
    private String unite;

    public SommeArgent(int amount, String currency) {
        quantite = amount;
        unite = currency;
    }

    public int getQuantite() { return quantite; }
    public String getUnite()  { return unite; }

    public SommeArgent add(SommeArgent m) throws UniteDistincteException {
        if (!m.getUnite().equals(this.getUnite())) {
            throw new UniteDistincteException(this, m);
        }
        return new SommeArgent(getQuantite() + m.getQuantite(), getUnite());
    }

    @Override
    public boolean equals(Object anObject) {
        if (this == anObject) return true;
        if (anObject == null || getClass() != anObject.getClass()) return false;
        SommeArgent autre = (SommeArgent) anObject;
        return quantite == autre.quantite && unite.equals(autre.unite);
    }

    @Override
    public int hashCode() { return Objects.hash(quantite, unite); }

    @Override
    public String toString() { return quantite + " " + unite; }
}
```

## Couverture des tests (objectif de l'atelier)

Dans Eclipse : *clic droit sur la classe de test → Coverage As → JUnit Test* (EclEmma). Les lignes vertes sont couvertes, rouges non couvertes. Avec les tests ci-dessus, `SommeArgent` et `PorteMonnaie` sont couvertes à ~100 % (sauf éventuellement `hashCode()` et la branche « porte-monnaie vide » de `toString()`).
