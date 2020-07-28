#!/usr/bin/env python
from scipy.signal import argrelmax
from numpy.fft import fft, fftfreq
from matplotlib.pyplot import figure, show
from numpy import linspace, zeros, log10, diff, sin, pi
import seaborn as sns

sns.set_context("talk", font_scale=1.3)

N = 100000
tend = 0.01
fc = 109e3  # [Hz]

t = linspace(0, tend, N)

x = zeros((N,))
x[:914] = sin(2 * pi * fc * t[:914])

F = fft(x)
f = fftfreq(N, tend / N)
Fabs = abs(F)

figure(1).clf()
ax = figure(1).gca()
ax.plot(t * 1e6, x)
ax.set_xlim((0, 200))
ax.set_xlabel(r"time [$\mu$s]")
ax.set_ylabel("Normalized amplitude")
ax.set_title("MARSIS AIS transmit waveform: $f_c=${} kHz".format(fc / 1e3))

pkind = argrelmax(20 * log10(Fabs), order=1, mode="wrap")[0]
fpks = f[pkind]
dfpks = diff(fpks)

figure(2).clf()
ax = figure(2).gca()
ax.plot(f / 1e3, 20 * log10(Fabs))
ax.plot(
    fpks / 1e3, 20 * log10(Fabs[pkind]),
    linestyle="none", marker=".", markersize=20
)
ax.set_xlabel("Frequency [kHz]")
ax.set_ylabel("Relative Amplitude [dB]")
ax.set_title("Simulated MARSIS Excitation: $f_c=${} kHz".format(fc / 1e3))
ax.set_ylim((0, None))
ax.set_xlim((0, 210))

show()
