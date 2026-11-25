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
