# Semafor cu Buton pentru Pietoni pe FPGA 🚦

## 🔎 Descriere

Acest proiect implementează un **semafor controlat de buton pentru pietoni**, scris în **Verilog** și implementat pe o placă FPGA **Lattice MachXO3LF**, folosind software-ul **Lattice Diamond**.

Sistemul controlează atât semaforul pentru mașini, cât și pentru pietoni, cu reguli stricte de comutare, folosind o mașină de stări finite (FSM) și semnale sincronizate.

---

## ⚙️ Funcționare

### 🔻 Semaforul pentru mașini:
- **Roșu:** 15 secunde
- **Verde:** 10 secunde
- **Galben:** 2 secunde

### 🧍‍♂️ Semaforul pentru pietoni:
- **Roșu** când mașinile au **verde** sau **galben**
- **Verde** doar când mașinile sunt pe **roșu**

### 🔘 Buton pentru pietoni:
- Activ pe nivel logic **1**
- **Ignorat** dacă pietonii au deja verde
- **Memorează apăsarea** dacă e pe roșu și comută semaforul doar când mașinile sunt pregătite (în starea `INITIAL`)
- **Detecția se face pe front crescător** (rising edge) prin registru `t_prev`

---

## ⏱️ Temporizare și Ceas
- Ceasul are frecvența de **1 Hz** (1 ciclu pe secundă)
- Intern, se folosește un contor pentru a genera un **impuls de 1 secundă** pe baza ceasului FPGA (`numar == nrstop`)

---

## 💻 Platformă și Software Utilizat
- **Placă FPGA:** Lattice MachXO3LF
- **Software de design:** Lattice Diamond
- **Simulator:** ModelSim (cu script `.do` pentru simulare + waveform configurat)

---

## 🧠 Etape de Implementare

### 🔨 1. Proiectare și Simulare
- Cod scris în **Verilog HDL**
- Mașină de stări finite (FSM) cu stări: `INITIAL`, `GREEN`, `YELLOW`, `RED`, `DONE`
- Testbench complet (`test.v`) + scripturi (`sim.do`, `wave.do`)
- Simulare în ModelSim pentru verificarea funcționării

### ⚙️ 2. Implementare pe FPGA
- Integrarea în Lattice Diamond
- Crearea fișierului `.lpf` pentru maparea pinilor (buton, LED-uri, etc.)
- Generarea bitstream-ului `.jed`
- Programarea plăcii

### ✅ 3. Testare fizică
- Se conectează LED-uri pentru semafoare (roșu/galben/verde mașini + pietoni)
- Se simulează apăsări de buton pentru a declanșa traversarea
- Se observă corectitudinea secvenței și temporizării

---

## 📂 Fișiere în Repository

| Fișier        | Descriere                            |
|---------------|--------------------------------------|
| `counter.v`   | Modul Verilog principal (semafor FSM)|
| `test.v`      | Testbench complet                    |
| `sim.do`      | Script ModelSim pentru rulare        |
| `wave.do`     | Configurație semnale în waveform     |
| `README.md`   | Documentația completă                |

---

## 📷 Fotografii (opțional)

![Screenshot 2025-06-07 114356](https://github.com/user-attachments/assets/7df54524-42e7-427a-84fb-2ab52d7072eb)

---

## 📜 Licență

Proiect educațional, realizat pentru învățare și practică pe FPGA. Codul este open-source și poate fi reutilizat sau adaptat în scop academic.

---

