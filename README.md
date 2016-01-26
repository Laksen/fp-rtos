# fp-rtos

fp-rtos is a realtime OS for embedded systems written in freepascal.

It should compile with any recent trunk version of an arm-embedded FPC compiler.

## Architecture support:

* ARMv4T
* ARMv6
* AVR

## Platform support:

* ARMEmu
* Integrator/CP (QEMU)
* Openmoko Freerunner
* Raspberry PI v1

## Building:

The project right now uses a single Lazarus project file: test.lpi

Either load this into Lazarus and choose build mode, or build with lazbuild (specify build mode with the --bm argument).
