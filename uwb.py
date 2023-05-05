import numpy as np
import matplotlib.pyplot as plt

# Define waveform parameters
pulse_duration = 1e-9 # Pulse duration of 1 nanosecond
pulse_shape = 'rectangular' # Rectangular pulse shape
carrier_frequency = 6.5e9 # Carrier frequency of 6.5 GHz

# Define binary bit sequence
bits = [0, 0]

# Create time axis for plotting
t = np.linspace(0, pulse_duration*len(bits), len(bits)*100)

# Create pulse waveform
if pulse_shape == 'rectangular':
    pulse = np.ones(int(pulse_duration*len(t)))
else:
    # Add code to define other pulse shapes here
    pass

# Modulate pulse waveform with binary bits
signal = np.zeros(len(t))
for i, bit in enumerate(bits):
    signal[i*int(pulse_duration*100):(i+1)*int(pulse_duration*100)] = pulse*bit

# Modulate pulse waveform with carrier frequency
carrier_wave = np.sin(2*np.pi*carrier_frequency*t)
uwb_waveform = signal*carrier_wave

# Plot waveform
plt.plot(t, uwb_waveform)
plt.xlabel('Time (s)')
plt.ylabel('Amplitude')
plt.title('UWB Waveform for Bit Combination 00')
plt.show()