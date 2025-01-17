import processing.core.PApplet;
import processing.core.PVector;

import java.util.ArrayList;
import java.util.List;
import java.util.function.UnaryOperator;



public class Formula {
    private final List<Variation> variations = new ArrayList<>();
    private final List<Operation> operations = new ArrayList<>();
    private final UnaryOperator<PVector> operator;

    public Formula(PApplet pApplet) {

        int numberOfVariations = floor(pApplet.random(MINIMUM_VARIATIONS, MAXIMUM_VARIATIONS));

        for (int i = 0; i < numberOfVariations; i++) {
            variations.add(Variation.values()[floor(pApplet.random(Variation.values().length))]);
        }
        for (int i = 1; i < numberOfVariations; i++) {
            operations.add(Operation.values()[floor(pApplet.random(Operation.values().length))]);
        }

        UnaryOperator<PVector> tmpOperator = variations.get(0).operator;
        for (int i = 0; i < operations.size(); i++) {
            tmpOperator = operations.get(i).operator.apply(tmpOperator, variations.get(i + 1).operator);
        }
        operator = tmpOperator;
    }

    public PVector apply(PVector p) {
        return operator.apply(p);
    }

    public String getName() {
        StringBuilder stringBuilder = new StringBuilder(variations.get(0).displayName);
        for (int i = 0; i < operations.size(); i++) {
            stringBuilder.append(" ");
            stringBuilder.append(operations.get(i).displayName);
            stringBuilder.append(" ");
            stringBuilder.append(variations.get(i + 1).displayName);
        }
        return stringBuilder.toString();
    }
}
