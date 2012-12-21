MODULE ELF32;

TYPE
    Header = RECORD
        ident:      ARRAY OF CHAR;  (* Сигнатура *)
        type:       Elf32_Half;     (* Тип объектного файла *)
        machine:    Elf32_Half;     (* Аппаратная платформа *)
        version:    Elf32_Word;     (* Номер версии *)
        entry:      Elf32_Addr;     (* Точка входа *)
        phoff:      Elf32_Off;      (* Таблица программных заголовков *)
        shoff:      Elf32_Off;      (* Таблица заголовков секций *)
        flags:      Elf32_Word;     (* Флаги процессора *)
        ehsize:     Elf32_Half;     (* Размер заголовка в байтах *)
        phentsize:  Elf32_Half;     (* Размер записи в таблице програнмых заголовков *)
        phnum:      Elf32_Half;     (* Количество записей в таблице программных заголовков *)
        shentsize:  Elf32_Half;     (* Размер записи в таблице заголовков секций *)
        shnum:      Elf32_Half;     (* Количество записей в таблице заголовков секций *)
        shstrndx:   Elf32_Half;     (* Расположение сегмента, содержащего таблицу строк *)
    END;

END ELF32.