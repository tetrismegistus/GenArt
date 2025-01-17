import processing.core.PVector;

import java.util.function.BinaryOperator;
import java.util.function.UnaryOperator;

public enum Operation {
    ADD("+", (a, b) ->
            v -> PVector.add(a.apply(v), b.apply(v))),
    SUBTRACT("-", (a, b) ->
            v -> PVector.sub(a.apply(v), b.apply(v))),
    COMBINATION("o", (a, b) ->
            v -> a.apply(b.apply(v))),
    MUTIPLICATION("*", (a, b) ->
            v -> {
                PVector aV = a.apply(v);
                PVector bV = b.apply(v);
                return new PVector(aV.x * bV.x, aV.y * bV.y);
            }),
    DIVISION("/", (a, b) ->
            v -> {
                PVector aV = a.apply(v);
                PVector bV = b.apply(v);
                return new PVector(bV.x == 0 ? 0 : aV.x / bV.x, bV.y == 0 ? 0 : aV.y / bV.y);
            });

    public final BinaryOperator<UnaryOperator<PVector>> operator;
    public final String displayName;

    Operation(String displayName, BinaryOperator<UnaryOperator<PVector>> operator) {
        this.displayName = displayName;
        this.operator = operator;
    }
}
