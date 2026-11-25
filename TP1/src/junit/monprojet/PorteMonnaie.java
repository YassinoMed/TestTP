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
}
