#!/bin/bash
# Setup Demonica Tool 2.5
# Pastikan Anda menjalankan script ini di Termux

# Warna ANSI untuk output
red="\e[31m"
green="\e[32m"
yellow="\e[33m"
blue="\e[34m"
reset="\e[0m"

# Direktori utama untuk tool
DEMONICA_DIR="$HOME/Demonica-Tool"

# Fungsi logging (jika diperlukan)
LOG_FILE="$DEMONICA_DIR/logs/$(date +%Y-%m-%d).log"
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# Fungsi instalasi dependensi
install_dependency() {
    case "$1" in
        "coreutils")
            if ! command -v realpath &>/dev/null || ! command -v sha256sum &>/dev/null; then
                echo -e "${yellow}Menginstal coreutils...${reset}"
                pkg install -y coreutils
            fi
            ;;
        "bash-obfuscate")
            if ! command -v bash-obfuscate &>/dev/null; then
                echo -e "${yellow}Menginstal Node.js dan bash-obfuscate...${reset}"
                pkg install -y nodejs
                npm install -g bash-obfuscate
            fi
            ;;
        "shc")
            if ! command -v shc &>/dev/null; then
                echo -e "${yellow}Menginstal shc...${reset}"
                pkg install -y shc
            fi
            ;;
        "rustc")
            if ! command -v rustc &>/dev/null; then
                echo -e "${yellow}Menginstal Rust...${reset}"
                pkg install -y rust
            fi
            ;;
        "git")
            if ! command -v git &>/dev/null; then
                echo -e "${yellow}Menginstal git...${reset}"
                pkg install -y git
            fi
            ;;
        *)
            echo -e "${red}Dependensi tidak dikenal: $1${reset}"
            exit 1
            ;;
    esac
}

# Instal semua dependensi yang diperlukan
for dep in coreutils bash-obfuscate shc rustc git; do
    install_dependency "$dep"
done

# Buat struktur direktori
DIRECTORIES=(
    "$DEMONICA_DIR"
    "$DEMONICA_DIR/output"
    "$DEMONICA_DIR/keys"
    "$DEMONICA_DIR/bin"
    "$DEMONICA_DIR/src"
    "$DEMONICA_DIR/logs"
)
for dir in "${DIRECTORIES[@]}"; do
    mkdir -p "$dir"
done

# Set permission untuk semua folder dan file yang dibuat
chmod -R 755 "$DEMONICA_DIR"
echo -e "${green}Struktur direktori dan izin telah diatur di: $DEMONICA_DIR${reset}"

################################################################################
# Bagian utama script Demonica Tool 2.5 dengan beberapa mode enkripsi.
################################################################################

# Fungsi progress bar simulasi (untuk mode EVAL, SHC, DEMONIC)
progress_bar_sim() {
    local total_steps=20
    local sleep_interval=0.2
    echo -ne "${yellow}Memproses: ["
    for ((i=0; i<=total_steps; i++)); do
        percent=$(( i * 100 / total_steps ))
        bar=$(printf "%-${i}s" "" | tr ' ' '#')
        printf "\r${yellow}Memproses: [%-20s] %3d%%" "$bar" "$percent"
        sleep $sleep_interval
    done
    echo -e "\n${reset}"
}

# Main menu Demonica Tool 2.5
while true; do
    clear
    echo -e "${red}====================================="
    echo -e "${yellow}      DEMONICA TOOL 2.5       "
    echo -e "${red}=====================================${reset}"
    echo -e "${blue}Pilih Mode:${green}"
    echo "1) Enkripsi EVAL"
    echo "2) Enkripsi XOR"
    echo "3) Enkripsi SHC"
    echo "4) Enkripsi DEMONIC"
    echo "5) Keluar"
    read -p "Pilihan (1-5): " choice

    case $choice in
        5)
            echo -e "${yellow}Keluar...${reset}"
            log "INFO" "Tool dihentikan oleh pengguna."
            exit 0
            ;;
        [1-5])
            read -p "Masukkan path file: " input
            input=$(realpath "$input" 2>/dev/null)
            if [[ ! -f "$input" ]]; then
                echo -e "${red}File tidak ditemukan!${reset}"
                log "ERROR" "File tidak ditemukan: $input"
                sleep 2
                continue
            fi
            chmod +x "$input" 2>/dev/null
            # Ambil shebang dari file input dan tentukan interpreter
            shebang=$(head -n1 "$input")
            interpreter=$(echo "$shebang" | sed 's/^#!//')
            log "INFO" "Shebang ditemukan: $shebang (Interpreter: $interpreter)"
            basename=$(basename -- "$input")
            basename_no_ext="${basename%.*}"
            log "INFO" "Memproses file: $basename (Mode: $choice) dengan interpreter: $interpreter"
            ;;
        *)
            echo -e "${red}Pilihan tidak valid!${reset}"
            log "WARNING" "Pilihan tidak valid: $choice"
            sleep 1
            continue
            ;;
    esac

    case $choice in
        1)
            # Mode EVAL
            echo -e "${blue}Mengenkripsi dengan Eval...${reset}"
            log "INFO" "Mulai enkripsi Eval untuk file $basename"
            progress_bar_sim
            output_file="$DEMONICA_DIR/output/${basename_no_ext}.sh"
            encoded=$(base64 -w0 "$input")
            {
                echo "#!/bin/bash"
                echo "echo '$encoded' | base64 -d | $interpreter"
            } > "$output_file"
            bash-obfuscate "$output_file" -o "$output_file"
            sed -i '1s|^|#!/bin/bash\n|' "$output_file"
            echo -e "${green}File terenkripsi tersimpan di: $output_file${reset}"
            log "INFO" "Enkripsi Eval berhasil: $output_file"
            ;;
        2)
            # Mode XOR dengan kunci 32-byte dan progress bar real-time
            echo -e "${blue}Membuat kunci XOR 32-byte...${reset}"
            log "INFO" "Mulai enkripsi XOR untuk file $basename"
            KEY_LEN=32
            key=$(head -c $KEY_LEN /dev/urandom | xxd -p -u | tr -d '\n')
            key_file="$DEMONICA_DIR/keys/${basename_no_ext}.key"
            echo "$key" > "$key_file"
            echo -e "${yellow}Memulai enkripsi...${reset}"
            encoded=$(base64 -w0 "$input")
            total_length=${#encoded}
            encrypted=""
            bar_width=20
            # Warna untuk progress bar
            bar_filled_color="${green}"
            bar_empty_color="${red}"
            progress_label_color="${blue}"
            for ((i=0; i<total_length; i++)); do
                char="${encoded:$i:1}"
                ascii=$(printf "%d" "'$char")
                key_byte=0x${key:$(( (i % KEY_LEN) * 2 )):2}
                encrypted+=$(printf "%02X" $((ascii ^ key_byte)))" "
                percent=$(( (i+1)*100/total_length ))
                filled=$(( percent * bar_width / 100 ))
                bar_filled=$(printf "%-${filled}s" "" | tr ' ' '#')
                empty_width=$(( bar_width - filled ))
                bar_empty=$(printf "%-${empty_width}s" "" | tr ' ' '-')
                printf "\r${progress_label_color}Enkripsi Progress: [${bar_filled_color}${bar_filled}${bar_empty_color}${bar_empty}${progress_label_color}] %3d%%${reset}" "$percent"
            done
            printf "\n"
            rust_file="$DEMONICA_DIR/src/${basename_no_ext}.rs"
            bin_file="$DEMONICA_DIR/bin/${basename_no_ext}"
            cat <<EOF > "$rust_file"
use std::process::Command;

fn decrypt(encrypted: &str, key: &[u8]) -> String {
    encrypted.split_whitespace()
        .enumerate()
        .map(|(i, hex)| {
            let byte = u8::from_str_radix(hex, 16).unwrap();
            byte ^ key[i % key.len()]
        })
        .map(|b| b as char)
        .collect()
}

fn main() {
    let encrypted_data = "$encrypted";
    let key_hex = "$key";
    let key: Vec<u8> = (0..key_hex.len())
        .step_by(2)
        .map(|i| u8::from_str_radix(&key_hex[i..i+2], 16).unwrap())
        .collect();
    let decoded = decrypt(encrypted_data, &key);
    let output = Command::new("$interpreter")
        .arg("-c")
        .arg(decoded)
        .output()
        .expect("Gagal menjalankan perintah");
    println!("{}", String::from_utf8_lossy(&output.stdout));
}
EOF
            if ! rustc -C opt-level=3 "$rust_file" -o "$bin_file"; then
                echo -e "${red}Gagal mengompilasi Rust!${reset}"
                log "ERROR" "Kompilasi Rust gagal untuk $rust_file"
                exit 1
            fi
            checksum=$(sha256sum "$bin_file" | awk '{print $1}')
            log "INFO" "Checksum XOR binary: $checksum"
            echo -e "${green}Binary terenkripsi tersimpan di: $bin_file${reset}"
            log "INFO" "Enkripsi XOR berhasil: $bin_file"
            ;;
        3)
            # Mode SHC
            echo -e "${blue}Mengenkripsi dengan SHC...${reset}"
            log "INFO" "Mulai enkripsi SHC untuk file $basename"
            progress_bar_sim
            temp_file="$DEMONICA_DIR/output/${basename_no_ext}_temp.sh"
            {
                echo "#!/bin/bash"
                cat "$input"
            } > "$temp_file"
            bash-obfuscate "$temp_file" -o "$temp_file"
            sed -i '1s|^|#!/bin/bash\n|' "$temp_file"
            output_file="$DEMONICA_DIR/output/${basename_no_ext}_shc"
            shc -r -f "$temp_file" -o "$output_file"
            strip --strip-all "$output_file" 2>/dev/null
            rm -f "$temp_file"
            checksum=$(sha256sum "$output_file" | awk '{print $1}')
            log "INFO" "Checksum SHC binary: $checksum"
            echo -e "${green}Binary SHC terenkripsi tersimpan di: $output_file${reset}"
            log "INFO" "Enkripsi SHC berhasil: $output_file"
            ;;
        4)
            # Mode DEMONIC (Berlapis)
            echo -e "${blue}Mengenkripsi Berlapis...${reset}"
            log "INFO" "Mulai enkripsi berlapis untuk file $basename"
            progress_bar_sim
            encoded=$(base64 -w0 "$input")
            intermediate="$DEMONICA_DIR/output/${basename_no_ext}_layered.sh"
            {
                echo "#!/bin/bash"
                echo "echo '$encoded' | base64 -d | $interpreter"
            } > "$intermediate"
            bash-obfuscate "$intermediate" -o "$intermediate"
            sed -i '1s|^|#!/bin/bash\n|' "$intermediate"
            final_output="$DEMONICA_DIR/output/${basename_no_ext}_layered_bin"
            shc -r -f "$intermediate" -o "$final_output"
            strip --strip-all "$final_output" 2>/dev/null
            checksum=$(sha256sum "$final_output" | awk '{print $1}')
            log "INFO" "Checksum Layered binary: $checksum"
            echo -e "${green}Binary enkripsi berlapis tersimpan di: $final_output${reset}"
            log "INFO" "Enkripsi berlapis berhasil: $final_output"
            ;;
    esac

    sleep 3
done
