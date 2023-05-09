# Plot the waveform
using Plots
using FourierAnalysis
using Random: bitrand
gr()


default_plots = (
    fontfamily="computer modern",
    lims = :round,
    minorgrid=true,
    legend=false,
    color_palette=:lighttest,
    widen=true,
)


β = 0.5
Tp = 2e-9
r(t) = 4*β*(cos((1+β)*pi*t/Tp)+sin((1-β)*pi*t/Tp)/(4*β*(t/Tp)))/(pi*sqrt(Tp)*(1-(4*β*t/Tp)^2))

f_carrier=6.5e9
T_dsym = 128.21e-9
T_bpm = T_dsym/2
T_c = Tp
N_burst = 8
N_hop = 2
N_cpb = 8
N_c = 64
f_s = 40000000000 # sampling frequency in Hz
T_s = 1/f_s # sampling period in seconds
N_s = round(Int, T_c/T_s) # number of samples per chip
T_burst = T_dsym/N_burst

time_offset = -T_dsym/2

# Define a function to generate a BPM-BPSK symbol for two bits
function bpmbpsk(bits, position, len)
    # Check if the input is valid
    if length(bits) != 2 || !all(x -> x in [0, 1], bits)
        error("Invalid input bits")
    end
    
    # Allocate an array for the symbol waveform
    t = range(time_offset, length=len, step=T_s) # time vector for one pulse
    wave = zeros(Float64, len)

    for (i, time) in enumerate(t)
        chips = range(1, N_cpb)

        burst = 0

        for chip in chips
            pulse = (1-2*(chip%2))*r(time - bits[1]*T_bpm - chip*T_c - position*T_dsym)
            if isnan(pulse)
                pulse = (1-2*(chip%2))*r(time - bits[1]*T_bpm - chip*T_c - 1e-20 - position*T_dsym)
                pulse = r(time - bits[1]*T_bpm - chip*T_c - 1e-20 - position*T_dsym)
            end
            burst += pulse
        end

        wave[i] = (1-2*bits[2])*burst
    end

    print(maximum(abs.(wave)))
    return wave
end

function bpmbpsk_waveform(bits)
    # Check if the input is valid
    if length(bits) % 2 != 0 || !all(x -> x in [0, 1], bits)
        error("Invalid input bits")
    end
    
    # Allocate an array for the waveform
    len = round(Int, abs(N_s*N_c+time_offset/T_dsym) + N_s*N_c*length(bits)÷2)
    wave = zeros(Float64, len)
    
    # Loop over each pair of bits and generate a symbol
    for i in 1:2:length(bits)
        wave += bpmbpsk(bits[i:i+1], (i-1)÷2, len) # generate a symbol for two bits
        # wave[(i-1)*N_s*N_c÷2+1 : (i+1)*N_s*N_c÷2] = sym # insert the symbol into the waveform
    end

    wave /= maximum(abs.(wave))


    
    return wave
end

bits = bitrand(12)
wave = bpmbpsk_waveform(bits)



pl = plot(t*1e9, wave;default_plots..., legend=true, xlabel="Time (ns)", ylabel="Amplitude", title="BPM-BPSK waveform")
vline!(pl, [0, 128.21, 256.42, 384.63, 512.84], label="Symbols", color=:black, linestyle=:dash)
vline!(pl, [T_bpm, 3*T_bpm, 5*T_bpm, 7*T_bpm]*1e9, label="Bursts", color=:blue, linestyle=:dash)
annotate!(pl, 0, 0.5, text("0 0", :center))
display(pl)

readline()
