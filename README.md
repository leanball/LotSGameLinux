# LotSGame Launcher Installer

This repository contains the **LotSGame Launcher Installer**, currently in development.

## 📥 Installer Download

### **Linux**

**1. Open the terminal.**

**2. Create a directory for the game in your home folder:**

```bash
mkdir -p "$HOME/leanballgames"
cd "$HOME/leanballgames"
```

**3. Download the installer:**
```bash
wget https://raw.githubusercontent.com/leanball/LotSGameLinux/refs/heads/main/setup.sh
chmod +x setup.sh
```

*   **With administrative access** (installs system packages):
```bash
./setup.sh
```
*   **Without administrative access** (installs locally via pip):
```bash
./setup.sh --no-sudo
```

After installation, the launcher will be created in your **Desktop** folder. If not, you can copy it manually:
```bash
cp LotSLauncher.desktop ~/Desktop/
```
To run the game, use the launcher or the following command:
```bash
python3 LotSClient.py
```
---
### **Windows**
For the Windows version will click Use the link below:
[**here**](https://github.com/leanball/LotSGame)

---

### **Android**
For Android devices, the launcher is available for testers via Google Play. Use the link below:  
[**Google Play (Testing Version)**](https://play.google.com/apps/internaltest/4700379673975068225)

---

## About the Project

The launcher is currently in **development** and may undergo changes and improvements over time. If you encounter any issues, feel free to open an [Issue](https://github.com/leanball/LotSGame/issues) or contribute.

---

## 📢 Contact

For questions, suggestions, or support, you can access our official Discord channel:  
[**LotSGame - Support and Testing**](https://discord.gg/Uh4rMkes)

Alternatively, you can also open an **Issue** in this repository to report problems or suggest improvements.

### ⚖️ License Agreement

This software is licensed under the terms described in the [LICENSE](./LICENSE) file.  

By downloading, installing, or using this software, you acknowledge that you have read, understood, and agree to the terms of the [LICENSE](./LICENSE).  
If you do not agree with the terms, do not proceed with downloading or using the software.






