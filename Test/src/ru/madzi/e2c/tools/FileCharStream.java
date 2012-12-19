package ru.madzi.e2c.tools;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author de
 */
public class FileCharStream extends AbstractCharStream {

    private static final Logger LOG = Logger.getLogger(FileCharStream.class.getName());

    private File file;

    private FileInputStream fis;

    public FileCharStream(String fileName) {
        file = new File(fileName);
        try {
            fis = new FileInputStream(file);
        } catch (FileNotFoundException ex) {
            LOG.log(Level.SEVERE, null, ex);
        }
    }

    @Override
    protected char read() {
        if (fis != null) {
            int it = -1;
            try {
                it = fis.read();
            } catch (IOException ex) {
                LOG.log(Level.SEVERE, null, ex);
            }
            return (it != -1) ? (char) it : EOF;
        }
        return EOF;
    }

    @Override
    protected void reset() {
        try {
            fis = new FileInputStream(file);
        } catch (FileNotFoundException ex) {
            LOG.log(Level.SEVERE, null, ex);
        }
    }

}
