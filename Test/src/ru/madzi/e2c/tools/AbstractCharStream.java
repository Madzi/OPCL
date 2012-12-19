package ru.madzi.e2c.tools;

/**
 *
 * @author de
 */
public abstract class AbstractCharStream {

    public static final char EOF = (char) -1;

    private int index = 0;

    private int line = 1;

    private int charPositionInLine = 0;

    public int getLine() {
        return line;
    }

    public AbstractCharStream setLine(int line) {
        this.line = line;
        return this;
    }

    public int getCharPositionInLine() {
        return charPositionInLine;
    }

    public AbstractCharStream setCharPositionInLine(int charPositionInLine) {
        this.charPositionInLine = charPositionInLine;
        return this;
    }

    public int index() {
        return index;
    }

    public char readChar() {
        char ch = read();
        index++;
        charPositionInLine++;
        if (ch == '\n') {
            line++;
            charPositionInLine = 0;
        }
        return ch;
    }

    protected abstract char read();

    protected abstract void reset();

}
