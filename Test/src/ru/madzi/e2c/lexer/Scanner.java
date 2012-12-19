package ru.madzi.e2c.lexer;

import ru.madzi.e2c.tools.AbstractCharStream;
import ru.madzi.e2c.tools.Errors;

/**
 *
 * @author de
 */
public class Scanner {

    private AbstractCharStream stream;

    private Errors error;

    public Scanner(AbstractCharStream stream) {
        this.stream = stream;
    }

    public Token get() {
        char ch = 
        return Token.NULL;
    }

    public Token getComment() {
        int level = 1;
        char ch = '*';
        CommentState state = CommentState.ASTERISK;
        while (ch != AbstractCharStream.EOF && level > 0) {
            ch = stream.readChar();
            switch (ch) {
                case '*':
                    if (state == CommentState.LBRACE) {
                        level++;
                    }
                    state = CommentState.ASTERISK;
                    break;

                case '(':
                    state = CommentState.LBRACE;
                    break;

                case ')':
                    if (state == CommentState.ASTERISK) {
                        level--;
                    }
                    state = CommentState.TEXT;
                    break;

                default:
                    state = CommentState.TEXT;
            }
        }
        if (ch == AbstractCharStream.EOF) {
            error = Errors.UNEXPECTED_END_OF_FILE;
            return Token.ERROR;
        }
        return Token.COMMENT;
    }

    private enum CommentState {
        TEXT,
        ASTERISK,
        LBRACE
    }

}
