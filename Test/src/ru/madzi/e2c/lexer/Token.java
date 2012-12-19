package ru.madzi.e2c.lexer;

/**
 *
 * @author de
 */
public enum Token {

    NULL("", Category.WHITESPACE, 0),
    TIMES("*", Category.OPERATOR, 1),
    SLASH("/", Category.OPERATOR, 2),
    DIV("DIV", Category.OPERATOR, 3),
    MOD("MOD", Category.OPERATOR, 4),
    AND("&", Category.OPERATOR, 5),
    PLUS("+", Category.OPERATOR, 6),
    MINUS("-", Category.OPERATOR, 7),
    OR("OR", Category.OPERATOR, 8),
    EQL("=", Category.OPERATOR, 9),
    NEQ("#", Category.OPERATOR, 10),
    LSS("<", Category.OPERATOR, 11),
    LEQ("<=", Category.OPERATOR, 12),
    GTR(">", Category.OPERATOR, 13),
    GEQ(">=", Category.OPERATOR, 14),
    IN("IN", Category.OPERATOR, 15),
    IS("IS", Category.KEYWORD, 16),
    ARROW("^", Category.RELATION, 17),
    PERIOD(".", Category.SEPARATOR, 18),
    COMMA(",", Category.SEPARATOR, 19),
    COLON(":", Category.SEPARATOR, 20),
    UPTO("..", Category.SEPARATOR, 21),
    RPAREN(")", Category.SEPARATOR, 22),
    RBRAK("]", Category.SEPARATOR, 23),
    RBRACE("}", Category.SEPARATOR, 24),
    OF("OF", Category.KEYWORD, 25),
    THEN("THEN", Category.KEYWORD, 26),
    DO("DO", Category.KEYWORD, 27),
    TO("TO", Category.KEYWORD, 28),
    BY("BY", Category.KEYWORD, 29),
    LPAREN("(", Category.SEPARATOR, 30),
    LBRAK("[", Category.SEPARATOR, 31),
    LBRACE("{", Category.SEPARATOR, 32),
    NOT("~", Category.OPERATOR, 33),
    BECOMES(":=", Category.OPERATOR, 34),
    NUMBER("", Category.NUMBER, 35),
    NIL("NIL", Category.KEYWORD, 36),
    TRUE("TRUE", Category.KEYWORD, 37),
    FALSE("FALSE", Category.KEYWORD, 38),
    STRING("", Category.STRING, 39),
    IDENTIFIER("", Category.IDENTIFIER, 40),
    SEMICOLON(";", Category.SEPARATOR, 41),
    BAR("|", Category.SEPARATOR, 42),
    END("END", Category.KEYWORD, 43),
    ELSE("ELSE", Category.KEYWORD, 44),
    ELSIF("ELSIF", Category.KEYWORD, 45),
    UNTIL("UNTIL", Category.KEYWORD, 46),
    IF("IF", Category.KEYWORD, 47),
    CASE("CASE", Category.KEYWORD, 48),
    WHILE("WHILE", Category.KEYWORD, 49),
    REPEAT("REPEAT", Category.KEYWORD, 50),
    FOR("FOR", Category.KEYWORD, 51),
    LOOP("LOOP", Category.KEYWORD, 52),
    WITH("WITH", Category.KEYWORD, 53),
    EXIT("EXIT", Category.KEYWORD, 54),
    RETURN("RETURN", Category.KEYWORD, 55),
    ARRAY("ARRAY", Category.KEYWORD, 56),
    OBJECT("OBJECT", Category.KEYWORD, 57),
    RECORD("RECORD", Category.KEYWORD, 58),
    POINTER("POINTER", Category.KEYWORD, 59),
    BEGIN("BEGIN", Category.KEYWORD, 60),
    CODE("CODE", Category.KEYWORD, 61),
    CONST("CONST", Category.KEYWORD, 62),
    TYPE("TYPE", Category.KEYWORD, 63),
    VAR("VAR", Category.KEYWORD, 64),
    PROCEDURE("PROCEDURE", Category.KEYWORD, 65),
    IMPORT("IMPORT", Category.KEYWORD, 66),
    MODULE("MODULE", Category.KEYWORD, 67),
    EOF("", Category.WHITESPACE, 68),
    COMMENT("", Category.WHITESPACE, 69),
    ERROR("", Category.ERROR, 70);

    private Token(String name, Category category, int id) {
        this.id = id;
        this.name = name;
        this.category = category;
    }

    private int id;

    private String name;

    private Category category;

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public Category getCategory() {
        return category;
    }

}
