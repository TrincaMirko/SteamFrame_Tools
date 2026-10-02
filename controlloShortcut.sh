#!/bin/bash

# Cartelle di origine e destinazione
SYS_DIR="/usr/share/applications"
USER_DIR="$HOME/.local/share/applications"

# Crea la cartella utente se non esiste
mkdir -p "$USER_DIR"

# Ciclo su tutti i file .desktop nella cartella di sistema
for file_path in "$SYS_DIR"/*.desktop; do
    # Estrae solo il nome del file (es. cmake-gui.desktop)
    file_name=$(basename "$file_path")

    # 1. Salta il file se esiste già la versione personalizzata nella cartella utente
    if [ -f "$USER_DIR/$file_name" ]; then
        continue
    fi

    # 2. Verifica se NoDisplay=true è già presente nel file di sistema
    # (usa grep -iq per ignorare maiuscole/minuscole e spazi attorno al '=' o 'true')
    if grep -iqE "^\s*NoDisplay\s*=\s*true" "$file_path"; then
        continue
    fi

    # 3. Estrae il nome "reale" dell'app per mostrarlo nella domanda (es. Name=CMake)
    app_name=$(grep -m 1 "^Name=" "$file_path" | cut -d'=' -f2)
    [ -z "$app_name" ] && app_name="$file_name"

    # Interazione con l'utente
    echo "----------------------------------------"
    echo "Applicazione: $app_name ($file_name)"
    
    while true; do
        read -p "Vuoi continuare a vederla nel launcher? (y/n): " scelta
        case "$scelta" in
            [Yy]* ) 
                echo "Lasciata visibile."
                break
                ;;
            [Nn]* ) 
                echo "Nascondo l'applicazione..."
                cp "$file_path" "$USER_DIR/"
                echo "NoDisplay=true" >> "$USER_DIR/$file_name"
                echo "Fatto!"
                break
                ;;
            * ) 
                echo "Per favore, rispondi con 'y' per Sì o 'n' per No."
                ;;
        esac
    done
done

echo "----------------------------------------"
echo "Scansione completata!"
