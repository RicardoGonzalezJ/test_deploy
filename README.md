# Test Deploy

**Test Deploy** is an experimental project for learning and exploring deployment strategies for full-stack JavaScript applications.

This project does not include a full-featured UI - it simply server a basic Vite-built frontend as part of a complete deployment pipeline simulation

---

## 🎯 Purpose

The goal of this project is to:

- Practice packaging and deploying a Node.js + React application
- Learn how to install a Node.js backend as a Windows service using [WinSW](https://github.com/winsw/winsw)
- Automate deployment stetps such as building, copying, zipping, and installing dependencies

---

## 🛠️ Tech stack
- **Frontend**: React + TypeScript + Vite
- **Backend**: Node.js + Express
- **Build Tools**: 
    - Shell script (`build-package.sh`) for macOS/Linux
    - Batch script (`build-package.bat`) for Windows
- **Deployment**: Windows service setup using WinSW

---

## ⚙️ Features

- Cross-platform build support (macOS/Linux/Windows)
- Builds frontend and backend
- Prunes `devDependencies` for a leaner package
- Creates a `.zip` package ready for deployment
- Install Node.js backend as a Windows service using WinSW

---

## 🚧 Project Status

> This is an **experimental and educational** project. It is not production-ready.

---

## 📂 Project structure
```bash
├── dist # Built frontend (Vite output)
├── package # Final deployable package (service-ready)
├── public # Static assets for the frontend (Vite default)
├── scripts # Batch files and WinSW configuration
├── scripts-dist # Compiled backend server (Node.js/Express)
├── src # Source code for the frontend (Vite default)
├── testDeploy-package.zip # Deployment archive (created by build script)
```

## 📦 How to Build

Run the build script for your platform:
- **On macOS/Linux:**
    ```bash
        ./build-package.sh
    ```
- **On Windows (CMD or double-click):**
    ```bash
        ./build-package.bat
    ```

The script will:
- Install dependencies
- Build the frontend and backend
- Prune dev dependencies
- Download WinSW (if not already present)
- Create a deployable `.zip` file

---

## 🖥️ How to Deploy on Windows

1. Transfer the `.zip` file to a Windows machine
2. Unzip the contents
3. Run install.bat (double-click or **Run as Administrator**)
4. The service should appear in the Services manager (service.msc) as testDeploy

