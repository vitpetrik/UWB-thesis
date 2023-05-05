# Define some parameters
Tc = 250e-9 # chip duration in seconds
Tdsym = 1e-6 # symbol duration in seconds
Nc = round(Int, Tdsym/Tc) # number of chips per symbol
Np = 2 # number of pulses per burst
fc = 0.5e9 # carrier frequency in Hz
fs = 20e9 # sampling frequency in Hz
Ts = 1/fs # sampling period in seconds
Ns = round(Int, Tc/Ts) # number of samples per chip

# Define a function to generate a single UWB pulse
function pulse(t)
    return exp(-t^2/(Tc/4)^2) * cos(2*pi*fc*t)
end

β = 0.5
Tp = 2e-9
r(t) = 4*β*(cos((1+β)*pi*t/Tp)+sin((1-β)*pi*t/Tp)/(4*β*(t/Tp)))/(pi*sqrt(Tp)*(1-(4*β*t/Tp)^2))

# Define a function to generate a BPM-BPSK symbol for two bits
function bpmbpsk(bits)
    # Check if the input is valid
    if length(bits) != 2 || !all(x -> x in [0, 1], bits)
        error("Invalid input bits")
    end
    
    # Allocate an array for the symbol waveform
    sym = zeros(Float64, Ns*Nc)
    
    # Determine the burst position and phase from the bits
    pos = bits[1] == 0 ? 1 : Nc÷2 + 1 # first or second half of the symbol
    phase = bits[2] == 0 ? 1 : -1 # positive or negative polarity
    
    # Generate the burst waveform by adding Np pulses
    burst = zeros(Float64, 0)
    for i in 1:Np
        t = range((i-1)*Tc, length=Ns, step=Ts) # time vector for one pulse
        append!(burst, pulse.(t))
        # burst += pulse.(t) # add the pulse to the burst
    end
    
    # Apply the phase to the burst
    burst *= phase
    
    # Insert the burst into the symbol at the correct position
    sym[(pos-1)*Ns+1 : (pos+Np-1)*Ns] = burst
    
    return sym
end

# Define a function to generate a BPM-BPSK waveform for a bit sequence
function bpmbpsk_waveform(bits)
    # Check if the input is valid
    if length(bits) % 2 != 0 || !all(x -> x in [0, 1], bits)
        error("Invalid input bits")
    end
    
    # Allocate an array for the waveform
    wave = zeros(Float64, Ns*Nc*length(bits)÷2)
    
    # Loop over each pair of bits and generate a symbol
    for i in 1:2:length(bits)
        sym = bpmbpsk(bits[i:i+1]) # generate a symbol for two bits
        wave[(i-1)*Ns*Nc÷2+1 : (i+1)*Ns*Nc÷2] = sym # insert the symbol into the waveform
    end
    
    return wave
end

# Example usage: generate a BPM-BPSK waveform for 8 bits
bits = [0, 1, 1, 0, 0, 1, 0, 1]
wave = bpmbpsk_waveform(bits)

# Plot the waveform
using Plots
pyplot()

t = range(0, length=length(wave), step=Tdsym/(Ns*Nc)) # time vector for the waveform
pl = plot(t*1e9, wave, xlabel="Time (ns)", ylabel="Amplitude", title="BPM-BPSK waveform")
display(pl)

readline()
