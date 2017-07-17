<!--
$theme: gaia
template: invert
-->
![bg](/home/cr0c0/Dokumente/Presi/dbg.jpeg)

# some _Ham_ for hunting eggs...
## Ham - 469
### PoliCTF 2017

<!-- footer: by cr0c0 --->

----

![bg](/home/cr0c0/Downloads/dbg.jpeg)

# #Recon - pt. 1
* General
```bash
$ file ham.wav
RIFF (little-endian) data, WAVE audio, Microsoft PCM, 
16 bit, stereo  
```
* Looks like it's uncompressed at first glance...
------
![bg](/home/cr0c0/Dokumente/Presi/dbg.jpeg)
# #Recon - pt. 2
* Anything in meta/tags ?
```
$ ffprobe ham.wav
Input #0, wav, from 'ham.wav':
  Metadata:
    title           : Free Software Song (CTF-edited)
    artist          : Bino
    date            : 2012
    genre           : FreeMusic
  Duration: 00:00:31.16, bitrate: 1411 kb/s
    Stream #0:0: Audio: pcm_s16le ([1][0][0][0] / 0x0001), 44100 Hz, 2 channels, s16, 1411 kb/s

```
----
![bg](/home/cr0c0/Dokumente/Presi/dbg.jpeg)
# #Recon - pt. 3
#### waveform
![waveform](/home/cr0c0/Dokumente/Presi/ham_waveform.png)

----
![bg](/home/cr0c0/Dokumente/Presi/dbg.jpeg)
# #Recon - pt. 4
#### spectrogram
![waveform](/home/cr0c0/Dokumente/Presi/ham_spectrogram.png)

* Some small-band signal around 18 kHz constantly
* Signal-To-Noise Ratio  ?
----
![bg](/home/cr0c0/Dokumente/Presi/dbg.jpeg)
# #Recon - pt. 5
#### spectrum
![waveform](/home/cr0c0/Dokumente/Presi/ham_spectrum.png)

* Quite weak with attenuation of -48 dB
----
### ???
![meme](/home/cr0c0/Dokumente/Presi/meme.jpg)

----
![bg](/home/cr0c0/Dokumente/Presi/dbg.jpeg)
# #Extracting

----
![bg](/home/cr0c0/Dokumente/Presi/dbg.jpeg)
# #Extracting - pt. 1
* Reject start and end of track
* Apply high-pass (cutoff = 18 kHz)
* Amplify ~ 45 dB

![filtered](/home/cr0c0/Dokumente/Presi/filtered.png)

----
![bg](/home/cr0c0/Dokumente/Presi/dbg.jpeg)
# #Extracting - pt. 2
* Some 2-symbol binary encoding: $a \in \{0,1\}$
* Binary Phase Shift Keying (BPSK)
* Duration of 32 ms per symbol 

----
![bg](/home/cr0c0/Dokumente/Presi/dbg.jpeg)
# #Extracting - pt. 2
* Maybe chall#s title tells us something

![filtered](/home/cr0c0/Dokumente/Presi/google.png)

----
![bg](/home/cr0c0/Dokumente/Presi/dbg.jpeg)
# #Extracting - pt. 3
* Formerly called "Varicode", now PSK31
* Fano-Code
* No symbol is proper prefix of another one
* So it can be decoded quite easily...

----
![bg](/home/cr0c0/Dokumente/Presi/dbg.jpeg)
### #Flag
----
![bg](/home/cr0c0/Dokumente/Presi/dbg.jpeg)
# #Flag - pt. 1
```python
from scipy.io import wavfile
import numpy as np

rate, data = wavfile.read("filtered.wav")

# select the second channel

data = data[:,1]
samples_per_symbol = int(rate / 1000.0 * 32)
data = data[:-(data.size % samples_per_symbol)]
symbols = np.mean(np.abs(data.reshape(-1, samples_per_symbol)), axis=1)
symbols = symbols[symbols > (symbols[0] / 2)]
cutoff = np.mean([max(symbols), symbols[0]])

print ''.join(["1" if x else "0" for x in symbols > cutoff])
```
----
![bg](/home/cr0c0/Dokumente/Presi/dbg.jpeg)
# #Flag - pt. 2
* Extracting "varicode" binary information from audio track
```
python -W ignore decode.py                                                                                                             ✭
0000000000000000000000000000000101010101001011001110110010010101001011001011010011010011100100101100111011001011001010011001101110010101001011100100101100101010011001001011011001010100101100101101001101110010110011011001101100101110100100110100111100100110011011111001010011010011110010111100101001101001110011110010011110011100110101100101100101101001011001011101001011100100111101010011111011001001101010011101011100100111101001101100101100101101100101011011100110101110011100111001011111100110100111100101101100110110110011100101010010101111001011001101001111001011111001110011010110010111001111111001111001101101001010110011001101111001111110011001011110010100101010011011100111011001011101100101100101101001100101110110011001110101100110110011010011110010110100101011010100111111111111111111111111111111111111
```
* Thanks to github, there's a decoding table for varicode already as python dictionary
----
![bg](/home/cr0c0/Dokumente/Presi/dbg.jpeg)
# #Flag - pt. 3
```
decode = {
    '1010101011' : '\x00',    '1011011011' : '\x01',
    '1011101101' : '\x02',    '1101110111' : '\x03',
    '1011101011' : '\x04',    '1101011111' : '\x05',
[...snip...]
   '11011111'   : 'x',       '1011101'    : 'y',
    '111010101'  : 'z',       '1010110111' : '{',
    '110111011'  : '|',       '1010110101' : '}',
'1011010111' : '~', '1110110101' : '\x7F' }
```
----
![bg](/home/cr0c0/Dokumente/Presi/dbg.jpeg)
# #Flag - pt. 4
 * Turning audio to flag gold
```
[...snip...]
data = data.lstrip("0").rstrip("1")
chars = data.split("00")
print ''.join([varicode[c] if c in varicode else "?" for c in chars])
```

>Ham radio amateurs are gradually in extinction nowadays :( -> flag{LookingForRainbowsInTheSpectrumMadeMeBlind}?
>
----
![bg](/home/cr0c0/Dokumente/Presi/dbg.jpeg)

# #Questions ???