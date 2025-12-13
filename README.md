<img src="https://github.com/user-attachments/assets/42eb93fd-8082-4080-97ec-71f413da9847" width="1000" height="1000" /> Steer BeamNG (Experimental)

**Steer BeamNG** is an **experimental hobby project** that lets you control **BeamNG.drive** using an **Android phone as a steering wheel** — no physical wheel required.

Built purely for **fun, learning, and experimentation**, this project explores how far a mobile device can replicate real steering hardware.

---

## 📸 Screenshot

![steerBeamng](https://github.com/user-attachments/assets/de07cf42-f6e3-4830-940c-f554a8eecbe3)

---

## ⬇️ Downloads

### 📱 Android Controller App

👉 **GitHub Release (v1.0.0+1)**
[https://github.com/Abubakar-doc/steer_beamng/releases/tag/android-v1.0.0%2B1](https://github.com/Abubakar-doc/steer_beamng/releases/tag/android-v1.0.0%2B1)

👉 **Google Drive (backup)**
[https://drive.google.com/drive/folders/1v5a4XZ01TdK4u7N93i6R76977p9U6g6d?usp=drive_link](https://drive.google.com/drive/folders/1v5a4XZ01TdK4u7N93i6R76977p9U6g6d?usp=drive_link)

---

### 🖥️ Windows Helper App

👉 **GitHub Release (v1.0.0)**
[https://github.com/Abubakar-doc/steer_beamng/releases/tag/v1.0.0](https://github.com/Abubakar-doc/steer_beamng/releases/tag/v1.0.0)

👉 **Google Drive (backup)**
[https://drive.google.com/drive/folders/1TUNcVbo4Q0VQBiAy46MAfK1aTaKlzSSX](https://drive.google.com/drive/folders/1TUNcVbo4Q0VQBiAy46MAfK1aTaKlzSSX)

---

<details>
<summary><strong>🚀 Project Overview</strong></summary>

Steer BeamNG works as a **two-part system**:

* **Windows Helper App**

  * Creates a virtual steering wheel using **vJoy**
* **Android Controller App**

  * Sends real-time control input over network

BeamNG detects the setup as a **real steering wheel**.

</details>

---

<details>
<summary><strong>🖥️ Windows Helper App</strong></summary>

### Features

* Runs on **Windows**
* Built using **vJoy public library**
* Creates a **virtual steering wheel device**
* BeamNG detects it as real hardware

### Installer

The installer automatically:

* Installs the Helper App
* Installs **vJoy**
* Configures **Windows Firewall**

  * Allows UDP send/receive

### Networking

* **Protocol:** UDP
* **Port:** 5000
* Supports:

  * Single Android user
  * Multiple Android users simultaneously

</details>

---

<details>
<summary><strong>📱 Android Controller App (Detailed)</strong></summary>

### Real-Time Network Status

* Live **ping indicator (ms)**
* Shows connection health instantly

---

### 🎛️ Vehicle Action Buttons

* Fix vehicle
* Flip vehicle
* Gearbox mode change
* Ignition
* Fog light
* Headlight
* Flash
* Left / Right indicator
* Hazard light
* Diff lock
* ESC
* 4WD
* Camera zoom in / out
* Camera change
* Camera behind
* Horn

**Hold supported**

* Fix
* Ignition
* Zoom in / out
* Camera behind

---

### 🛞 Steering Wheel

* Real steering-wheel behavior
* Thumb-rotation based
* Smooth & sensitive input
* Springs back to center

**Supported angles**

* 270°
* 360°
* **450° (default)**
* 540°
* 720°
* 900°

**Special**

* Horn in wheel center
* Hold center → speedy flashes

---

### ⚙️ Gearbox System

**Automatic**

* P / R / N / D / S

**Manual**

* 5-speed
* 6-speed
* 7-speed
* 8-speed

**Interaction**

* Grab knob anywhere inside bounds
* Drag like a real shifter
* Snaps to nearest gear on release
* No need to look at the screen

---

### 🦶 Pedal System (3-in-1)

Single pedal supports:

* Accelerator
* Brake / Reverse
* Handbrake

**Usage**

* Drag up → accelerate
* Drag down → brake
* Left side → handbrake

**Advanced**

* Accelerator + handbrake
* Brake + handbrake
* Neutral + handbrake

All with **one thumb**.

---

### 🎥 Camera Controls

* Camera buttons
* Free camera joystick
* Double-tap joystick → camera reset

---

### ⭐ Favorites & Auto Connect

* Favorite a Windows device
* Auto-discover & auto-connect on app restart

---

### 🔄 Connectivity Handling

* Automatic reconnect
* Manual connect / disconnect from settings
* Restart app if required

</details>

---

<details>
<summary><strong>🔧 Input & Game Binding</strong></summary>

* All inputs map to **vJoy axes & buttons**
* Users must bind controls inside **BeamNG**
* Works like any real steering wheel
* **vJoy Monitor** can be used to verify inputs

</details>

---

<details>
<summary><strong>🎯 Purpose of This Project</strong></summary>

* Learn **Flutter & real-time networking**
* Explore **virtual input devices**
* Experiment with **vJoy**
* Enjoy BeamNG without physical hardware

</details>

---

<details>
<summary><strong>🔮 Planned Next Update</strong></summary>

* BeamNG → Mobile **telemetry**
* Sync controller UI with game:

  * Gear state
  * Speed
  * RPM
  * Vehicle status

</details>

---

<details>
<summary><strong>⚠️ Disclaimer</strong></summary>

* Personal hobby project
* Experimental & unstable by nature
* Not affiliated with BeamNG or vJoy
* Use at your own risk

</details>

---

<details>
<summary><strong>🤝 Contributions</strong></summary>

Open for:

* Learning
* Experimentation
* Improvements

Feel free to fork or suggest ideas.

</details>
