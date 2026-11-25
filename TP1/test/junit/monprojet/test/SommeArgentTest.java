package junit.monprojet.test;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import junit.monprojet.SommeArgent;
import junit.monprojet.UniteDistincteException;

class SommeArgentTest {
    private SommeArgent m12CHF;
    private SommeArgent m14CHF;
    private SommeArgent m14USD;

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

    @Test
    void testAddUnitesDistinctes() {
        UniteDistincteException thrown = assertThrows(UniteDistincteException.class, () -> {
            m12CHF.add(m14USD);   // CHF + USD → exception
        });
        assertEquals("unité distincte : CHF != USD", thrown.toString());
    }
}
