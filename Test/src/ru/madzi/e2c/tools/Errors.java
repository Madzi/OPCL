package ru.madzi.e2c.tools;

/**
 *
 * @author de
 */
public enum Errors {

    UNEXPECTED_END_OF_FILE("Unexpected end of file");

    private String name;

    Errors(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

}
