---
layout: default
title: FPGA-Based Control for Robotics
---

# 🔧 FPGA-Based Control System

**By Ayush Garg and Alan Wang**  
_16-299: Introduction to Feedback Control Systems_

Welcome to our course project page! This project explores how **Field Programmable Gate Arrays (FPGAs)** can be used to implement **high-frequency control systems and image processing algorithms** directly in hardware using **SystemVerilog**.

After several weeks of design, simulation, and hardware implementation, we have successfully completed and demonstrated the project.

---

## 📽 Final Demo Video

Watch our completed video walkthrough, which explains:

- What FPGAs are and why they’re ideal for control systems  
- The full architecture and SystemVerilog implementation  
- A live working demo of our FPGA-based system in action

<div style="position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden;">
  <iframe src="https://drive.google.com/file/d/1vkFJ1gqCDn_TWnkpy9AIMkSjLia_XL-l/preview" 
          style="position: absolute; top:0; left: 0; width: 100%; height: 100%;" 
          frameborder="0" allowfullscreen>
  </iframe>
</div>

> 🎥 Prefer a direct link? [Watch the full demo on Google Drive](https://drive.google.com/file/d/1vkFJ1gqCDn_TWnkpy9AIMkSjLia_XL-l/view)

---

## 💡 Why FPGAs for Control?

FPGAs offer key advantages for robotics and control applications:

- 🕒 **Real-Time Speed**: No OS or software stack — pure hardware-level execution  
- 🧠 **Parallelism**: Execute multiple control steps simultaneously  
- ⚙️ **Customization**: Hardware tailored exactly to the control problem

We implemented a **PID-style feedback controller** and a **simple image-processing pipeline** fully on the FPGA fabric.

---

## ✅ What We Accomplished

- ✅ Designed a **custom controller datapath** in SystemVerilog  
- ✅ Built a **UART interface** for PC communication (with fallback to GPIO)  
- ✅ Synthesized and deployed to FPGA hardware  
- ✅ Captured a successful real-time control demo on video  
- ✅ Documented everything for reproducibility

---

## 🛠 Reproducing the Project

Want to build on or replicate our work? Follow the steps below:

### 1. Clone the Repo
### 2. Synthesize and run SystemVerilog code on FPGA-accessible computers (found in Hamerschlag Hall ECE Labs)
### 3. Turn on the robot and program it with Arduino code from this Repo (Robot Model: 4WD 60mm Mecanum Wheel Arduino Robot).
### 4. Run the Python script on a camera-accessible computer to communicate between the FPGA and the robot.
### 5. Use a piece of paper with distinctly different colors near the center to let the camera images detect color movement in.

---

## 🧠 How to Improve Upon Our Results

While our project successfully demonstrated FPGA-based control and image processing, there are several ways to build on this work listed below:

- Extend the image processing pipeline, e.g., edge detection or basic filters
- Scale the design to control multiple devices in parallel
- Create a GUI or web interface for live tuning and visualization
- Use a higher-capacity FPGA to explore more complex or multi-threaded designs

These extensions would increase the project’s robustness, usability, and real-world applicability.

## 🙏 Acknowledgments

Thanks to the CMU ECE Department for hardware/toolchain support and to our professor and TA in _16-299: Introduction to Feedback Control Systems_ for their guidance.
