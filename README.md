# Analog Communication I - Project

##  Aim of the Project

The purpose of the project is to simulate the basic components of an analog communication system:

- **SSB modulation**
- **NBFM modulation**
- **Super-heterodyne receiver**

---

##  Design Process

The code is divided into **4 main functions**:

1. `modUnify` – Modulation function  
2. `SuperHeterodyneReceiver` – Super-heterodyne Receiver  
3. `FreqSpec` – Frequency spectrum function  
4. `main` – Main execution function

---

##  SSB Modulation Process

- Uses **Hilbert Transform** and **phase shift technique**
- Implements **Phase Discrimination Method**

---

##  NBFM Modulation Process

NBFM is approximated as:

ϕ(t) ≈ A · cos[(2πf<sub>c</sub>t) − k<sub>f</sub> · a(t) · sin(2πf<sub>c</sub>t)]  
where a(t) = ∫ m(t) dt

---

##  Function Details

### 1. `modUnify` Function

**Inputs:**
- Cell array of audio files
- Carrier frequency list (`fc_list`)
- Deviation ratio (β)

**Process:**
- Reads and processes mono audio files
- Upsamples them to meet Nyquist criterion
- Pads signals to match maximum length
- Modulates each signal using either SSB or NBFM
- Combines all into one FDM signal
- Uses `FreqSpec` to plot individual and total spectrums

---

### 2. `FreqSpec` Function

Calculates and returns the **normalized frequency spectrum** using FFT and plots it.

---

### 3. `SuperHeterodyneReceiver` Function

**Stages:**
- **RF Stage**: Applies IIR Chebyshev Type II Bandpass Filter  
- **Mixer Stage**: Translates to Intermediate Frequency (IF)  
- **IF Stage**: Applies highly selective Bandpass Filter  
- **Baseband Detection**:
  - For **SSB**: Multiplies with IF carrier, applies LPF, gain = 5  
  - For **NBFM**: Uses Hilbert Transform, phase unwrapping, and derivative to extract message

---

### 4. `main` Function

- Defines audio files and carrier frequencies
- Calls `modUnify` to generate FDM signal
- Sets demodulation bandwidth (15 kHz)
- Loops through each signal to:
  - Demodulate using `SuperHeterodyneReceiver`
  - Resample to original rate
  - Compare original and recovered signals
  - Play recovered sound using:  
    ```matlab
    sound(m_out, fm)
    ```
