# Okapi: Data logger with integrated solar charging and modular telemetry
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3766482.svg)](https://doi.org/10.5281/zenodo.3766482)

![Project Okapi Data Logger.](Documentation/images/Resnik_v040_FullyLoaded_perspective_20200428.png)

***Okapi data logger (Resnik v0.4.0), with a micro-SD card for local storage and a Particle Boron telemetry module.***

The **Okapi** data logger responds to the need for a robust, flexible, and power-efficient open-source option to record and transmit data from remote locations. It is programmable using the open-source standard Arduino framework via a standard USB-C cable and supports a wide range of sensor input/output options. It connects to dual power supplies to ensure consistent recordings, and interfaces with a range of “Feather”-form-factor boards for telemetry.

## Namesake

The Okapi, a relative of the giraffe, communicates over long distances using [infrasound](https://en.wikipedia.org/wiki/Infrasound). The telemetry capabilities of this data logger inspired this namesake.

![Okapi](https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/Okapi-Wald1.png/1280px-Okapi-Wald1.png)

## Technical specifications

### Electronic Hardware

* Microcontroller (computer) core
  * ATMega1284p
  * Arduino compatible
  * Programmable using C++
  * 8 MHz
* Real-time clock
  * DS3231M
  * Temperature-compensated crystal for high accuracy (±5 ppm)
* Sensor and general-purpose connections
  * Primary Rail (selectable 3.3V or 5V)
    * I2C (up to 128 sensors permitted; expansion ports provided by Project Heptapod)
    * SPI
    * 2x 16-bit analog
    * Analog voltage reference
    * 12-bit Digital-to-analog conversion
    * 2x General-purpose input/output
    * USART
    * 2x Vbus (selectable 3.3V or 5V)
    * 2x Ground
  * Secondary Rail (selectable 3.3V or 5V)
    * I2C (up to 128 sensors permitted; expansion ports provided by Project Heptapod)
    * 2x 16-bit analog
    * 2x General-purpose input/output
    * USART
    * 2x Vbus (selectable 3.3V or 5V)
    * 2x Ground
* Data storage and return
  * Local storage: micro SD card
  * Telemetry: support for Feather-profile boards, including Particle devices:
    * Mobile phone networks
    * WiFi
    * Bluetooth
    * [In development] Iridium satellite
* Power
  * Dual power supply
  * Primary Power
    * Built-in maximum-power-point-tracking solar-charge-control circuitry
    * Lithium-Ion battery
  * Backup Power
    * Alkaline AA batteries
  * Real-time clock
    * Coin cell
  * Power consumption
    * Primary power, sleeping: 80 μA
    * Backup power, sleeping: 4 μA
    * Active (typical: data logger without sensors): 10 mA
    * Transmitting (mobile networks, typical: Particle Boron):
      * 16 mA background
      * 40 mA burst
  * Power generation
  * Solar, low light: 100 mA
* User interface
  * “Log” button: instantaneous reading (for testing)
  * “Reset” button
  * 2x 3-color indicator LEDs for the logger, a 3-color LED for the B-series module, and eight single LEDs on a PCA9634 LED driver
  * Computer readout via a serial monitor, included in the Arduino software
* Open-source licensing via CC BY-SA 4.0

>> @bschulz1701: Any updates needed? I think that there is also a WDT (correct?)

### Electronic Software and Firmware

* Programmable using the Arduino IDE https://www.arduino.cc/en/main/software
* Custom bootloader and board definition for ATMega1284p available via https://github.com/NorthernWidget/Arduino_Boards
* Custom libraries from Northern Widget and the open-source community
  * Primary data-logger functions
  * Libraries available with each sensor, exposing a standard interface
* Open-source licensing via GNU GPL 3.0

### Pinout and board interfaces

![Data logger with pins, connectors, and interactive items annotated.](Documentation/images/Resnik_v040_top_annotated_20200428.png)

***Okapi data logger (Resnik v0.4.0) with pins, connectors, and interactive items annotated.***

**Pins are colored following this convention:**
* Ground: black
* Power supply: red
* Universal Serial Asynchronous Receiver--Transmitter (USART or UART): blue
* General-purpose I/O pins: gray
* Analog inputs and associated reference voltage: green
* Digital communications buses (SPI and I2C): purple
* Analog adjustable voltage output: salmon

**The power and programming connectors at the "south" end of the board are as follows:**
* USB-C connector (J10), to the logger's USB-serial converter (FT231X)
  * May be programmed using any USB-C cable that is not charging-only (i.e. that can carry data)
  * Can be used with our [clock-setting program](https://github.com/NorthernWidget/SetTime_GUI) to set the time on the real-time clock.
  * Provides power to the data logger while it is connected; this power source is isolated from the batteries and solar panel, and therefore may be plugged in safely at any time.
* Micro-USB connector (USB2), wired to the USB port of the B-series SoM on the M.2 socket, for that module rather than the logger
* Solar panel, up to 16 V open-circuit. A wide range of panels can work with this: as built the charger starts at 7.2 V, and [Solar charger set points](#solar-charger-set-points) gives the resistors for other panels. The charger accepts up to 32 V, but the v0.7.0 board's input capacitor (C10) is rated 16 V; [#44](https://github.com/NorthernWidget/Project-Okapi/issues/44) brings the full range in v0.8.0.
* Li-Ion battery, 2.60--4.475 V. This works with standard 18650 Li-ion batteries. It can work well with just a single battery, but if more storage is required, multiple 18650 batteries may be connected in parallel; we have a circuit-board design to do this: https://github.com/NorthernWidget/LiIon-18650-Parallel. ***CAUTION***: most commercially available multiple-18650-battery holders connect them in series; this voltage is ***TOO HIGH*** for the data logger.
* Primary batteries. This is ideally a pack of 3 primary (i.e., not reusable) Alkaline (or better) AA batteries with a long shelf life. The Okapi data logger will switch to these if its rechargeable power supply shuts down. The internal electronics reduce the quiescent power consumption while under backup power (see the above list of [electronic hardware technical specifications](#electronic-hardware)) and inform the logger about which power supply is being used, allowing it to, for example, reduce or temporarily terminate data transmission.

>> @bschulz1701: Solar panel supply current / size?

**"RST" and "LOG" buttons:**
* Reset ("RST"): stop the program that is currently executing on the main logger and return it to its boot sequence.
* Log Now ("LOG"): take a reading immediately. This is useful for diagnoses and testing.

>> General note: we may want to have an LED flash whenever the logger takes a reading -- even for 1/10 of a second. With an option to disable this, of course. But it is often better to know while in the field that a system is working

**Other notes, clockwise from the top:**
* The socket holds a [Feather-form-factor board](https://learn.adafruit.com/adafruit-feather/feather-specification).
  * This standard, designed by [Adafruit](https://www.adafruit.com/), has been widely adopted, including by the IoT/telemetry module designer [Particle](https://www.particle.io/).
  * We often use a [Particle Boron mobile-phone telemetry unit](https://docs.particle.io/boron/).
* Mounting holes for [\#4 screws](https://www.mcmaster.com/91772A106/)
* CR1220 battery; can power the real-time clock for up to 7 years
* ISP header (also called an ICSP header): This 3x2 header is used with an in-system programmer (in-circuit system programmer) to upload the [bootloader](#installing-the-bootloader) to the data logger.
* A micro-SD card holds a copy of all data, whether or not any telemetry is used

>> @bschulz1701: check my clock 7-year figure

![Data logger with key microchips, LEDs, and switches marked.](Documentation/images/Resnik_v040_top_annotated_interior_20200428.png)

***Okapi data logger (Resnik v0.4.0) with key microchips, LEDs, and switches marked.*** *MCU: Microcontroller. RTC: Real-time clock. LED: Light-emitting diode. Bus: a subsystem for connections and data transfer.*

The Okapi data logger contains two buses (see above), each of which has an independent voltage. The primary bus is on the left and the secondary bus is on the right. These can be selected as 3.3V (switches slid towards the inside of the board) or 5V (switches towards the outside of the board).

>> @bschulz1701: How much power can each bus source/sink?

Two LEDs, status and auxiliary, flash messages to the user to provide information on proper operations vs. a variety of possible errors. These are useful for field diagnoses, and are further described in [the field guide section, below](#field-operators-guide).

>> Design note: move STAT label to left of LED so it can be better seen

The Li-ion override button, which can be pressed with the tip of a pen or other small object, ...

>> @bschulz1701: This somehow overrides the Li-Ion battery electronics to allow something to happen... but I am not remembering what!

## On-board Devices

### I2C

| **Device** | **Address** | **Reprogrammable address** | **Function** |
|---|---|---|---|
| MLX90393 | 0x0C | N | Magnetometer |
| PAC1934 | 0x10 | N (R51) | Power monitor on the V_LI, V_PRIME, V_BETA and V_SOLAR_IN rails |
| BMA456 | 0x18 | N | Accelerometer |
| [MCP23018](https://github.com/NorthernWidget-Skunkworks/MCP23018) | 0x20 | N | I/O Expander |
| VEML6030 | 0x48 | N | Ambient light |
| [ADS1115](https://github.com/adafruit/Adafruit_ADS1X15) | 0x49 | N | ADC (sensor port), on the 5 V bus segment |
| MB85RC512T | 0x50 | N | FRAM |
| PCA9634 | 0x52 (also 0x03 and 0x70) | N | LED driver |
| MCP4726A2 | 0x62 | N | DAC, on the 5 V bus segment |
| [DS3231M](https://github.com/NorthernWidget/DS3231_Logger) | 0x68 | N | Real-time clock |
| [BME280](https://github.com/NorthernWidget/BME_Library) | 0x77 | N | On-board barometric pressure, temperature, and relative humidity |

### SPI

* SD Card

### UART (USART)

* FTDI USB-Serial converter
* Feather form-factor telemetry board; typically [Particle Boron](https://docs.particle.io/boron/)

## Assembly

Assembling this data logger is possible by hand with sufficient skill and the following tools:
* Temperature-controlled soldering iron
* Hot-air rework station
* Equipment for stenciling with solder paste
* ESD-safe tweezers and workstation
* Solder wick

Mechanized assembly by a professional circuit-board assembly house, which is available in many parts of the world, may be preferred due to the complexity of this data logger board.

**Do not build v0.7.0.** It is the 2024 design converted to KiCad, and the 2024 design's solar charger has no current-sense resistor: the LT3652's SENSE and BAT pins share one net, so it would charge the LiPo at its switch's current limit and never end the charge ([#32](https://github.com/NorthernWidget/Project-Okapi/issues/32)). v0.8.0 adds the resistor. The v0.7.0 files are the reference for that work.

The files for an assembly house are in `Production/`: the Gerbers, drill files and pick-and-place in `Okapi_0v7_2026-11-13.zip`, and the parts list in `Okapi_BoM_0v7_2026-11-13.csv`. `Production/make_production.sh` builds them from the KiCad design in `Hardware/KiCAD-10import/`. The KiCad board is the 2024 Eagle board (`Hardware/Okapi.brd`) converted, and its copper, drills and placement match the 2024 fabrication files in `Hardware/Okapi_2024-11-02/` except where a recorded change differs (JP8 and R62 removed, smaller lands under R1, R5, R7, R8, C1 and C22, dual lands for R22, R48 and R69–R71, slots for the micro-USB shell, and the USB-C shell's slots and its link to ground).

>> THOUGHT: I have basic instructions for assembly on the [Project Walrus](https://github.com/NorthernWidget-Skunkworks/Project-TPDH-Walrus) README; I will not reproduce these here just yet, as we might want to set up a separate assembly guide, mostly with good links to existing resources, since our writing something of this nature would be to reinvent the wheel.

## Programming

### Downloading and installing the Arduino IDE

Go to https://www.arduino.cc/en/main/software. Choose the proper IDE version for your computer. For Windows, we suggest the non-app version to have more control over Arduino; this might change in the future. You will have to add custom libraries, so the web version will not work (at least, as of the time of writing). Download and install the Arduino IDE. Open it to begin the next steps.

### Installing the bootloader

Before a data logger can receive programs via the convenient USB port, it must have a *bootloader* that tells it to expect to receive new programs that way.  You can read more about bootloaders in general here: https://www.arduino.cc/en/Hacking/Bootloader.

Because you can't upload the bootloader via USB, you use the 2x3-pin 6-pin ICSP (also called ISP) header with a special device called an "in-circuit system programmer" (or just "in-system programmer; yup, that's what the acronym stands for).

Many devices exist to upload a bootloader including:
* The official [AVR ISP mkII](http://ww1.microchip.com/downloads/en/DeviceDoc/Atmel-42093-AVR-ISP-mkII_UserGuide.pdf) (no longer produced but available used)
* Using an [Arduino as an ISP](https://www.arduino.cc/en/tutorial/arduinoISP)
* The versatile [Olimex AVR-ISP-MK2](https://www.olimex.com/Products/AVR/Programmers/AVR-ISP-MK2/open-source-hardware)
* The [Adafruit USBtinyISP](https://www.adafruit.com/product/46)

To upload the bootloader, do the following:

1. Open the Arduino IDE. If you have not yet installed the Northern Widget board definitions, find and install them here (instructions provided): https://github.com/NorthernWidget/Arduino_Boards
2. Select the desired board -- most likely ***ATMega1284p 8MHz*** under *Northern Widget Boards*.
3. Plug the data logger into your computer via a USB-C cable to provide power.
4. Plug your ISP of choice into your computer (via a USB cable) and onto the 6-pin header. There are two ways to place it on; the header is aligned such that the ribbon cable should be facing away from the board while programming. If this fails without being able to upload, try flipping the header around.
5. Go to Tools --> Programmer and select the appropriate programmer based on what you are using.
6. Go to Tools --> Burn bootloader. Typically, within a few seconds, you learn whether you succeeded or failed. Hopefully it worked!

***Important note for Linux users:*** You must supply permissions to the Arduino IDE for it to be able to use the ICSP, or you will have to run it using `sudo`. The former option is better; the latter is easier in the moment.

***Note: Be sure to download and/or update drivers for your ISP.***

### Installing the requisite software libraries

>> @awickert: Add a full list of the requisite software to install; finish the firmware aggregator and use those directions (or the Arduino ones) to help users install that + sdfat. Include screenshots and host those directions at https://github.com/NorthernWidget-Skunkworks/Firmware-Aggregator.

### How to write a program

The below program is an example that you can copy and paste directly into the Arduino IDE in order to upload to your data logger. We'll walk you through what each piece of the code is and does.

#### Full program
```c++
/*
 * Okapi example: connected with a Walrus pressure--temperature sensor, often
 * used for water-level measurements, via the Longbow I2C/RS-485 translator.
 * Written by Bobby Schulz with a few comments added by Andy Wickert.
 */

#include "Okapi.h"
#include <TP_Downhole_Longbow.h>

TP_Downhole_Longbow Walrus; // Instantiate Walrus sensor; relict library name
Okapi Logger; // Instantiate data logger object

String Header = ""; // Information header; starts as an empty string
uint8_t I2CVals[1] = {0x22}; // I2C addresses of sensors

unsigned long UpdateRate = 60; // Number of seconds between readings

void setup() {
  Header = Header + Walrus.GetHeader();
  Logger.begin(I2CVals, sizeof(I2CVals), Header); // Pass header info to logger
  Init();
}

void loop() {
  Logger.run(Update, UpdateRate);
}

String Update()
{
  Init();
  delay(1500);
  return Walrus.GetString();
}

void Init()
{
  Walrus.begin(13, 0x22); // Instantiate Walrus (at address = 13)
                          // and Longbow Widget (at address = 0x22)
}
```

#### "Include" statements

```c++
#include "Okapi.h"
#include <TP_Downhole_Longbow.h>
```

These bring in the two code libraries involved, the former for the data logger and the latter for the sensors. This allows the user to access the classes and functions within these two libraries, as we will show in more detail below.

#### Instantiate a sensor object

```c++
TP_Downhole_Longbow Walrus; // Instantiate Walrus sensor; relict library name
Okapi Logger; // Instantiate data logger object
```

"Instantiating an object" means that we create our own specific versions of the a class of items. This can be thought of as: `Breakfast myBreakfast`. Breakfast is the general concept, but I create "myBreakfast", which I can then modify. In this same way, "Logger" is what we call our Okapi data logger, and "Walrus" is what we call our "TP_Downhole_Longbow" sensor; this name is a holdover from an earlier design that is the ancestor of the Walrus. We can then access functions and variables within these two instantiated objects.

#### Declare the header string

```c++
String Header = ""; // Information header; starts as an empty string
```

We start with an empty header, but will soon add information to it.

#### Create a list of the I2C addresses of the sensors

```c++
uint8_t I2CVals[1] = {0x22}; // I2C addresses of sensors
```

This is the trickiest step. You need to know what the I2C address of your sensor is. You can skip this, but then the logger will not run a check to see if the sensor is properly connected.

>> Let's make sure that we record this one each page, or find a way to replace this.

#### Declare the amount of time between logging events

```c++
unsigned long UpdateRate = 60; // Number of seconds between readings
```

This is the number of seconds between logging events. If it takes 2 seconds to record data, make sure that you give the logger at least 3 seconds between events. The maximum logging time is set by the watchdog timer, which [FINISH HERE]

>> @BSCHULZ1701: Is there an external WDT on Okapi?

#### `setup()` step: runs once at the start

```c++
void setup() {
  Header = Header + Walrus.GetHeader();
  Logger.begin(I2CVals, sizeof(I2CVals), Header); //Pass header info to logger
  Init();
}
```

`setup()` is a special function that runs just once when the logger boots up. In this case, it first adds the Walrus' header to the header string. `GetHeader()` is a standard function that lies within each of our sensor libraries and returns this header information as a `String`. We then pass the header and the I2C values to the Okapi library's `begin()` function. This sets up the header and prepares the data loger to record data. Finally, this function calls `Init()`, which we skip ahead to describe immediately below.

>> (awickert): I still don't understand why we have to pass `sizeof()` and can't just compute that within the function.

#### `Init()` function: skipping ahead to understand `setup()`

```c++
void Init()
{
  Walrus.begin(13, 0x22); // Instantiate Walrus (at address = 13)
                          // and Longbow Widget (at address = 0x22)
}
```

The `Init()` function calls the `begin()` function, standard within each Northern Widget sensor library, to instantiate the connection ports (e.g., I2C, RS-485) used to communicate between the sensor and the logger. In this case, there is only one sensor, but two ports are needed: An RS-485 signal goes from the Walrus to the Longbow Widget, which then converts the signal into an I2C signal with its own address. The reason for this is that an I2C signal can travel only ~3 m, but an RS-485 signal can travel ~100 m.

#### `loop()` step: keeps running until stopped

```c++
void loop() {
  Logger.run(Update, UpdateRate);
}
```

The loop calls the main function of the Okapi library, `run()`, repeatedly. This puts the logger into a low-power sleep mode and wakes it up only when interrupted by the clock or the "LOG" button. `Update` refers to the function described immediately below. `UpdateRate` is our logging interval defined above.

#### `Update()` function: Gives data for the logger to record

```c++
String Update()
{
  Init();
  delay(1500);
  return Walrus.GetString();
}
```

The `Update()` function first calls the `Init()` function to be sure that the sensor is ready to log. It then in this case delays 1500 milliseconds; this is an ad-hoc solution to the question of how long it takes the pressure transducer to settle after being started up, and is a safe large amount of time. This function then can `return` a string of all of the Walrus' readings (one pressure and two temperature measurements) separated by commas. This is then concatenated to a list of logger-internal measurements -- date/time; on-board temperature, pressure, and relative humidity; and onboard voltages for battery and solar-panel status -- and recorded to the SD card. If telemetry were present, these data could also be sent to a remote location.

### Reference

A full index of the public variables and functions within the Okapi data logger library is available at https://github.com/NorthernWidget/Okapi_Library.

>> Send user to library page

>> Thoughts: We should make all comments compatible with doxygen (following) what I did with the ALog library. It also looks like TravisCI has support for Arduino(!) This means that we could also automate construction of the documentation for these libraries.

### Integration with Particle Boron

>> @bschulz1701?

#### The 66-minute timer

The telemetry module (a Boron on the FeatherWing socket, or a B-SoM on the M.2 socket) is not powered all the time. Its battery input comes through a load switch (U10) that a TPL5111 timer (U8) controls, and the timer runs on its own clock with an interval set by R20: 130 kΩ gives 66 minutes (3943 s by the TPL5111 datasheet's Equation 1; 3854 to 4033 s with a 1 % resistor). The 2024 Eagle files also carry JP8, which selects R62 (330 kΩ) instead. That value is above the part's 170 kΩ maximum and does nothing, and the KiCad board removes both (#34).

Three things happen on that interval:

1. **It powers the module every 66 minutes whether or not the logger asks.** This is the purpose of the timer: a cellular module receives only while it is powered and attached, so the hourly wake is the window in which a command, a request to resend, or a firmware update for the module can arrive from outside, and the slowest the module can ever be heard from is once an interval, even if the ATmega is asleep past its schedule or hung. For that to work the module must connect on every wake, not only when it has rows to send, and then say it is done.
2. **It bounds every session.** From the moment the module is powered, by the timer or by the logger, it has at most one interval before the timer cuts its power for 50 ms and starts over. A module that hangs is power-cycled once an hour, and this is the only reset path to the module on the board.
3. **It is the counter the logger restarts.** Pulling PARTICLE_EN low for 20 to 30 ms (expander port B pin 7, through Q3 onto the timer's DELAY/M_DRV pin) powers the module at once and restarts the interval. Hold it low and the module stays on past the interval, so pulse it. A request while the module is already on is ignored.

The module ends its own session by pulsing WD_DONE (the FeatherWing's A3, the B-SoM's ADC3): the timer drops the switch and the module draws nothing until the next interval or the next request. The 2019 Boron sketch does this from a 90-second watchdog that it refreshes on every line received from the logger, so the module stays up while rows arrive and shuts itself off 90 seconds after the last one.

As of 2026-11-05 the logger firmware does not drive PARTICLE_EN (Okapi_Library's backhaul writes the pin high, which on the open-drain expander releases it, and never configures it as an output), so on the boards in the field the timer alone powers the module and the backhaul succeeds only when it lands inside a module's on-window. The intended cycle, pulse PARTICLE_EN when there are rows to send and let the module pulse DONE when they are sent, is the firmware fix on the list.

## Wiring

>> Example needed

## Power supply

* **Lithium-ion 18650 rechargeable batteries**; this board can hold two in parallel: https://github.com/NorthernWidget/LiIon-18650-Parallel
* **Solar panel**. A wide range is acceptable, but we like [Voltaic Systems' 6-watt panel](https://voltaicsystems.com/6-watt-panel/). If you do not want to snip off the barrel jack, [this extension plug from Adafruit should work](https://www.adafruit.com/product/2788) (though we have not tested it... and you'll also have to cut *it* in half).
* **Primary alkaline batteries**; we typically use three high-quality (e.g., Duracell) AAs. These are the backup power supply, and we place them in a [3xAA holder (in series for the proper voltage) with a switch](https://www.jameco.com/z/SBH-331-AS-R-3x-AA-Battery-Holder-with-Cover-and-Switch_216144.html).

>> @bschulz1701: new smarter 18650 holder?

### Solar charger set points

Two resistor pairs set how the LT3652 charger (U4) uses your panel. Both sit on lands that take an 0402 or an 0603 part, so you can change them by hand to suit the panel you deploy:

* **MPPT, R22 over R69.** The charger holds the panel at 2.7 V × (1 + R22 / R69), close to the panel's maximum-power voltage, and draws less current rather than let the panel sag below it.
* **Start, R71 over R70.** The charger starts once the panel rises above 1.2 V × (1 + R71 / R70). Keep this below the panel's open-circuit voltage. The charger also needs the panel about 3.3 V above the cell to start (7.5 V on a full cell).

| Panel | Examples | R22 / R69 | MPPT | R71 / R70 | Start | Board |
|---|---|---|---|---|---|---|
| 6 V, 12-cell (as built) | Voltaic P126 (2 W); older 6 V panels such as Voltaic's 6 W P106C | 143 kΩ / 100 kΩ | 6.56 V | 1 MΩ / 200 kΩ | 7.2 V | v0.7.0 |
| 5–6 V, 10-cell ETFE | Voltaic P105, P110, P120, P124 | 143 kΩ / 120 kΩ | 5.92 V | 1 MΩ / 205 kΩ | 7.05 V | v0.7.0 |
| 12 V, 36-cell | Campbell SP10 and SP20, Renogy RNG-10D-SS, Ameresco 10M and 20J, Voltaic P108 and P152 | 1 MΩ / 200 kΩ | 16.2 V | 1 MΩ / 100 kΩ | 13.2 V | v0.8.0 |

As built, a 10-cell panel cannot always start the charger: its open-circuit voltage (6.6–7.3 V at 25 °C) sits at or below the 7.2 V start threshold, and lower still on a warm day. Change R70 to 205 kΩ, and R69 to 120 kΩ for the lower maximum-power voltage. A 12 V panel reaches 27 V open-circuit at −40 °C, beyond the 16 V input capacitor on v0.7.0, so 12 V panels wait for v0.8.0 ([#44](https://github.com/NorthernWidget/Project-Okapi/issues/44), [#46](https://github.com/NorthernWidget/Project-Okapi/issues/46)). Panel figures are from the makers' datasheets; the study behind this table is in NW-Status (`studies/okapi-hardware-audit/sources/2026-11-09-solar-panels-agent-report.md`).

### Regulator feedback dividers

The two adjustable regulators set their outputs with resistor dividers that follow their datasheets: the TLV61220 (U1, the 5 V core boost) with R4 1.62 MΩ over R5 180 kΩ, the datasheet's own example value for the lower resistor, and the TPS62822 (U2, the 3.3 V aux buck) with R6 820 kΩ over R7 180 kΩ and C6 68 pF as its feed-forward capacitor, which is the datasheet's 12 ms / R2 exactly.

The TPS62822's divider sits above the datasheet's center value (R2 of 100 kΩ, at most 120 kΩ, for 5 µA in the divider). That is a trade the datasheet names: a lower divider buys noise immunity at the FB node and costs light-load efficiency. Here the divider draws 3.3 µA instead of 6 µA, about 9 µW less from a rail that spends its life at light load and is switched off in sleep, and the node's sensitivity to pin bias and leakage is about twice the datasheet's, which on a regulator with a 1 % reference feeding sensors through their own switches is below anything measurable. Decided 2026-11-05 to keep the values as built (Project-Okapi #22).

### Sensor port current limits

Each sensor bus (PRIME and SEC) is fed through a pair of MIC2544 high-side switches, one from the 5 V rail and one from the 3.3 V rail. A slide switch on each bus (S1 for SEC, S2 for PRIME) picks 5 V or 3.3 V, and the firmware turns the bus on or off. Logic gates make the two choices exclusive: an AND gate passes the bus enable to the 5 V switch only when the slide is at 5 V, and through an inverter to the 3.3 V switch only when it is not, so both can never be on together. On v0.7.0, move a slide switch only with the logger off: between positions its common pin floats, and the gates may then turn both switches on together. v0.8.0 adds a pull-down that holds the 3.3 V side while the slider moves ([#53](https://github.com/NorthernWidget/Project-Okapi/issues/53)), so you can move it with the logger running. Set it to your sensor's voltage before you connect the sensor. Each switch limits its output current with a resistor on its ILIM pin: 232 Ω for 1 A, which is the default on every port.

To let one port draw up to 1.5 A, close its solder jumper (JP1 to JP4, one per switch). This puts 464 Ω in parallel with the 232 Ω, 154.7 Ω in all, which is the most the MIC2544 is rated to pass: its ILIM resistor may be no smaller than 154 Ω.

Do not close them all. The 5 V rail is one boost converter running from the battery, and it also feeds the telemetry module, whose transmit bursts reach about 2 A. One ampere per port is what that rail can promise every port at once (the sensors we use draw far less: an Apis with its LiDAR on draws about 100 mA). The jumper is for the one port that needs more, when you know the others are light. The limit also protects the cable and the sensor: a shorted port at 1 A heats the switch and the wiring less than at 1.5 A, and the switch reports the fault to the I/O expander either way.

### Power metering

A PAC1934 four-channel power monitor (U32) sits on the on-board I2C bus at address 0x10 and meters four rails through 0805 sense resistors: the Li-ion cell (V_LI, R72), the backup battery (V_PRIME, R73), the input to the boost converters (V_BETA, R75), and the solar panel (V_SOLAR_IN, R74). Each channel reads the rail voltage (0 to 32 V in 488 µV steps) and the drop across its resistor (100 mV full scale in 16 bits), and the chip multiplies the two for power. The cell channel is wired for both directions: charging reads positive and discharge reads negative.

| Rail | Sense resistor | Range | One count | Floor (offset at 25 °C / over −40 to +85 °C) |
|---|---|---|---|---|
| V_LI | R72, 20 mΩ | ±5 A | 153 µA | ±1 mA / ±10 mA |
| V_BETA | R75, 20 mΩ | 0 to 5 A | 76 µA | ±1 mA / ±10 mA |
| V_PRIME | R73, 20 mΩ | 0 to 5 A | 76 µA | ±1 mA / ±10 mA |
| V_SOLAR_IN | R74, 50 mΩ | 0 to 2 A | 31 µA | ±0.4 mA / ±4 mA |

The offset sets the floor, not the count size. Expect to see the logger awake (about 10 mA), a sensor port, a transmit burst (about 500 mA, read to ±10 mA with the gain and resistor tolerances), and the charge current once the panel reaches the charger's start voltage (7.2 V as built; see [Solar charger set points](#solar-charger-set-points)). Do not expect to see the sleep floor (tens of µA): measure that on the bench. For readings near zero, use bipolar mode with 8× averaging, as the datasheet recommends.

The sense resistors are 0.5 W parts (Panasonic ERJ-6BW). A 3 A transmit burst on 20 mΩ dissipates 0.18 W and drops 60 mV from the cell. The chip is powered from the core 3.3 V rail whenever the board is, with no jumper, and draws 5 µA between the single-shot readings the firmware takes, 16 µA sampling eight times a second with its SLOW pin high, and 585 µA at its power-up default of 1,024 samples per second. The firmware moves it out of that default at boot (Okapi_Library sets single-shot mode) and today reads only the cell and solar voltages from it. Current and energy readings are to come.

What a reading means depends on the mode. In single-shot mode each reading is the power at that instant, and energy over a logging interval is the sum of those snapshots times the interval. For true energy, leave the chip sampling between logs and read its accumulators, at the 16 µA or 585 µA cost above.

### Reference voltage on the sensor port

The 2024 design carries a 2.5 V shunt reference (D6, an LM4040) that feeds the on-board DAC and pin 2 of the PRIME sensor terminal (J2, labeled VREF), beside its analog input. A sensor can use that pin as an ADC reference, or to excite a ratiometric part such as a potentiometer or a thermistor divider, so that the reading does not move with the supply. A load cell is not a use for it: those come on their own bridge converter, with their own excitation.

The reference is biased from the 5 V rail through R48, and the current through R48 is (5 − 2.5) V / R48 whatever is attached; the reference takes what the sensor leaves. On v0.7.0 as planned R48 is 1 kΩ, which is 2.5 mA, so the pin supplies up to 2 mA to a sensor with the 5 V rail running low (any potentiometer of 1.5 kΩ or more). The 2024 design's 330 Ω was 7.6 mA, about 7 mA to a sensor. Both cost current only while the 5 V rail is up, which is the whole of each logging cycle and none of the sleep. The pads take an 0603 or an 0402 part: the board ships with the 0402, and a user who needs the larger current can hot-air it off and fit a 330 Ω 0603 (RC0603FR-07330RL). The reference needs at least 60 µA left over, so do not draw more than the pin supplies.

## Housing

The below suggestions encompass what we use and suggest for the housing. In the end, any sufficiently waterproof enclosure will work.

### Materials

* **Enclosure**: [PolyCase WH-16-03 outdoor-rated hinged enclosure](https://www.polycase.com/wh-16)
* **Cable glands**: [RDC07AA](https://www.elecdirect.com/catalogsearch/result/?q=RDC07AA). One per sensor, plus one for the solar panel.
>> AW: Photo didn't take; look up
* **Fasteners**
  * [M5-0.8 x 10 mm truss head screws](https://www.mcmaster.com/92467A320/) x4 to attach mounting plate to threaded inserts in the enclosure
  * [\#4-40 x 1/4 in pan head screws](https://www.mcmaster.com/91772A106/) x22 to attach Okapi, battery packs, and mounting plate to standoffs
  * [\#4-40 x 2 in Female Threaded Hex Standoffs](https://www.mcmaster.com/91115A173/) x3 to stand off Okapi from mounting plate
  * [\#4-40 x 1/2 in Female Threaded Hex Standoffs](https://www.mcmaster.com/91920A533/) x8 to stand off AA battery pack and Li-Ion battery pack from mounting plate
* **Mounting plate for Okapi** (Milled, ABS)
  * [Mounting Plate Design](Mounting_Plate)
* **Power**
>> Solar panel
  * [3x AA battery pack BK-1280-PC6](https://www.digikey.com/en/products/detail/mpd-memory-protection-devices/BK-1280-PC6/1640076) for alkaline battery backup, mounting holes included for #4-40 screws
>> Li-Ion battery and holder

### Tools

* CNC mill and/or drill press
* Deburring tool or knife + skill and patience
* Torque wrench(es) for 1.0, 1.2 N m

### Assembly

>> Guide with photos. Perhaps ask @superchap123 to use his CNC

>> Placeholder for Now

>> Also include information on passing wiring through

## Field operator's guide

### Initialize
1. Ensure that all connections are secure and SD card is inserted
2. Turn battery pack on
3. Wait for GREEN - GREEN - 5x Blue Flash
	- If you see this, the logger is properly recording data. To double-check, go to "Check"
	- If you see a different flash pattern, go to "Error"

### Check
1. After going through "Initialize", wait 2-3 minutes
2. Follow the instructions in the "Download" section
3. Check to make sure that all the data are being recorded at the proper (UTC) time
4. Check that valid values are being recorded for sensors
7. Whether or not files are properly recorded, return to "Initialize"
	- If files are not recorded, replace the SD card, check all connections, turn the logger back
	  on, and try again
	- If there is an issue with a specific sensor, check connections and troubleshoot
	- If files are recorded properly, return to Initilaize and do not return to "Check"

### SD card swap
1. Turn battery pack off
2. Remove SD card. Ensure that it is labeled. Put it somewhere safe and memorable
3. Replace the SD card with an equivalently labeled SD card
4. Go to "Initialize"

### Download
1. Turn battery pack off
2. Remove SD card
3. Insert SD card in computer
4. Navigate in the SD card to the most recent "log" file (NW→<serial_number>→Log<number>.txt)
5. Save the data file in a well-labeled and organized place.
6. Safely eject the SD card from the computer
7. Go to "Initialize"


### Error

#### Status Codes

The first LED (AUX) will turn green so long as power is applied.
The second LED (STAT) will have one of the colors below.

**Green:**: All systems check out OK, logging will proceed

**Orange:**: A sensor system is not registering properly, some sensor data may be missing or incorrect
* Verify correct polarity of sensor connection
* Ensure the right sensor is connected
* Verify the screw terminals are well connected to the wires (a loose connection can cause a failure)
* Make sure battery power is applied, some sensors can fail otherwise

**Cyan:**: Clock time is incorrect, but logger is otherwise working correctly
* Connect the logger to a computer and reset the clock using the Northern Widget Time Set GUI
* Start Processing
* Open the Northern Widget Time Set program
* Note and record the wrong time if the logger has been out in the field, alongside the current (correct) time, to correct the prior measurements
* Click the "set time" button and check that you are <3 seconds off of the correct time
* Click the "close" button

**Pink**: (looks like purple to some people): SD card is not inserted
* Insert the SD card, or remove and re-insert to make sure card is fully seated

**Red**: Critical on board component is not functioning correctly, such as SD card or clock; Logging will likely not be able to proceed
* Attempt power cycle
* Try different SD card
* Disconnect all sensors; reconnect one by one and check

**Yellow, Fast Blinking**: <50% battery capacity
* Replace batteries: turn battery pack off, replace batteries, and turn battery pack back on

**Red, Fast Blinking**: Batteries <3.3V. Voltage too low to properly function
* Replace batteries: turn battery pack off, replace batteries, and turn battery pack back on.

#### General tips to solve many kinds of errors
* Turn the the logger off and on
* Verify the quality of all screw terminal connections by gently tugging on the wires and making sure they stay in place, if not, remove, replace, and re-tighten the connection
* Ensure sensors and/or cables are not damaged, this can result is shorts or other problems
* Make sure batteries have sufficient voltage to run the logger (>3.3 V)


## NW-Device-Specification schema

Okapi's serial number scheme is [Schema 0](https://github.com/NorthernWidget/NW-Device-Specification) — the same 8-byte EEPROM block used by Margay, predating the formal specification. Schema 1 formalizes it as Page 0 and defines a putative Page 1 for the case where Okapi communicates its status to a higher-level device (e.g., the Particle Boron telemetry board). **Okapi has no current peripheral interface; Page 1 is hypothetical.**

Over I²C this would follow the standard register-addressed read. Over UART (the current Okapi↔Boron link) a framing layer is required; see the [NW-Device-Specification transport section](https://github.com/NorthernWidget/NW-Device-Specification) for the Magic Preamble and COBS options.

### Current EEPROM serial number (Schema 0)

Eight bytes at `EEPROM[length−8]` through `EEPROM[length−1]`, big-endian uint16 per field, written by the setup sketch `SN Set` command — identical scheme to Margay:

| Bytes | Field | Example (Okapi v1.0) |
|-------|-------|----------------------|
| 0–1 | Board type | `0x4F01` (`'O'` = 0x4F, revision 1) |
| 2–3 | Group ID | operator-assigned |
| 4–5 | Unique ID | monotonically increasing |
| 6–7 | FirmwareID | `0x0000` (hardcoded) |

Legacy units manufactured as "Resnik" carry board type `0x9950`.

### Proposed register layout (NW-Device-Specification Schema 1)

**Page 0 (0x00–0x1F) — Identity (EEPROM)**

```
Block 0 (0x00–0x07)   Core identity
  0x00        0x01                          Schema (NW-Device-Specification v1)
  0x01–0x05   'O','k','a','p','i'           Device name (5 bytes)
  0x06–0x07   0x00,0x00                     Reserved

Block 1 (0x08–0x0F)   Version
  0x08        HW major
  0x09        HW minor
  0x0A        FW patch
  0x0B–0x0D   0x00,0x00,0x00               Unused (combined repo convention)
  0x0E–0x0F   0x00,0x00                    Reserved

Block 2 (0x10–0x17)   Serial number
  0x10–0x11   0x4F,0x01                    Board type ('O'=0x4F, revision index)
  0x12–0x13   [manufacture]                Group ID
  0x14–0x15   [manufacture]                Unique ID
  0x16–0x17   0x00,0x00                    FirmwareID (legacy, reserved)

Block 3 (0x18–0x1F)   Integrity + administration
  0x18–0x1C   0x00 ×5                      Reserved
  0x1D        0x00                         Magic byte (reserved; purpose TBD)
  0x1E        [computed]                   CRC-8 of bytes 0x00–0x1D
  0x1F        0x00                         Peripheral address (unassigned;
                                           Okapi is currently controller only)
```

**Page 1 (0x20–0x3F) — Logger status (SRAM) — HYPOTHETICAL**

Okapi is currently an I²C controller communicating with the Particle Boron via UART; it has no peripheral interface. This layout is proposed for the case where Okapi reports status to the Boron (or any higher-level device) using the NW schema. A natural peripheral address would be `0x4F` (ASCII `'O'`).

Okapi's dual power system (LiPo primary + solar charging + AA backup) differs from Margay. Full power monitoring signals are not yet implemented in the library (`GetPowerStats()` is reserved); fields marked TBD will be defined when that work is completed.

Subsystem table (a logger's "chips" are its subsystems; same index rules):

| Index | Subsystem |
|-------|-----------|
| 0 | SD card |
| 1 | DS3231M RTC |
| 2 | BME280 onboard environment |
| 3 | Sensor bus |
| 4 | LiPo / solar charger |
| 5 | AA backup rail |

Block 0 (0x20–0x27) is the universal block defined by [NW-Device-Specification](https://github.com/NorthernWidget/NW-Device-Specification#page-1-sensor-data): status (ready, per-chip fault bits, pan-fault), control (trigger, chip select, sleep), reading counter, device config byte at 0x26, latched fault code at 0x27. Device data begins at 0x28. Config (0x26): reserved. Logger state continues on Page 3 (0x60–0x7F).

```
Block 1 (0x28–0x2F)   Power
  0x28        LiPo %       uint8, 0–100
  0x29–0x2A   LiPo voltage uint16, 0.01 V
  0x2B–0x2C   Solar input  uint16, TBD (V or mW pending GetPowerStats() impl.)
  0x2D        Backup volt  uint8, 0.1 V (AA backup rail)
  0x2E–0x2F   Reserved

Block 2 (0x30–0x37)   BME280 — onboard environment
  0x30–0x31   Temperature  int16, 0.01 °C
  0x32–0x33   Humidity     uint16, 0.01 %RH
  0x34–0x37   Pressure     uint32, 0.01 hPa

Block 3 (0x38–0x3F)   DS3231M — RTC
  0x38–0x3B   Timestamp    uint32, Unix time (seconds since 1970-01-01 UTC)
  0x3C–0x3D   Temperature  int16, 0.01 °C
  0x3E–0x3F   Reserved

Page 3, Block 0 (0x60–0x67)   Logger state
  0x60–0x61   Ext interrupts  uint16, accumulated count
  0x62–0x63   Log file #      uint16
  0x64–0x67   Log interval    uint32, seconds
```

No Page 2. Calibration constants are hardcoded in the library.

## Development namesake

Designing a large-platform, multi-power-system, and telemetry-enabled data logger is the single most complex task that our group has undertaken. Bobby Schulz, lead engineer, code-named the dev version of this work "Project Resnik", after Dr. Judy Resnik, electrical engineer and astronaut. Although we don't have to manage the complexities of space travel, we think that our design will do pretty well down here on Planet Earth.

![Astronaut Dr. Judy Resnik](https://upload.wikimedia.org/wikipedia/commons/4/43/Judy_Resnik_%2817126382249%29.jpg)


## Acknowledgments

Support for this project provided by:

<img src="https://pbs.twimg.com/profile_images/1139626463932637186/qCak0yvY_400x400.png" alt="UMN ESCI" width="240px">

<img src="https://upload.wikimedia.org/wikipedia/commons/0/08/USGS_logo.png" alt="USGS" width="240px">

<img src="https://ane4bf-datap1.s3-eu-west-1.amazonaws.com/wmocms/s3fs-public/styles/featured_media_detail/public/advanced_page/featured_media/wmologo2016_fulltext_horizontal_rgb_en-2.jpg?C4guHHfFZ0Uv029Eo5AvJLFg6nMR47hI&itok=NVNNIT7H" alt="WMO" width="240px">

<br/>
<br/>
<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
