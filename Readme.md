# 🧰 Windows Server 2016 Developer Setup (Without WSL)

This guide sets up a development environment on **Windows Server 2016** (or similar Windows environments that do not support WSL). It includes:

- ✅ Git Bash shell (for bash scripting & Makefiles)
- ✅ Python 3 + pip3
- ✅ Terraform
- ✅ GNU Make
- ✅ pre-commit Git hooks

---

## 🔧 Step 1: Install Git for Windows

1. Download Git for Windows:
   👉 https://gitforwindows.org

2. Run the installer and accept the default settings.
   Make sure **Git Bash** is installed.

3. After installation, open **Git Bash** and verify:

```bash
git --version
```

---

## 🧰 Step 2: Install Chocolatey (Requires Admin Access)

### 🛠 How to Run PowerShell as Administrator

1. Press `Win + S` and search for **PowerShell**
2. Right-click **Windows PowerShell**
3. Choose **Run as administrator**
4. Confirm the UAC prompt if it appears

### 🍫 Install Chocolatey

In the **admin PowerShell window**, run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; `
[System.Net.ServicePointManager]::SecurityProtocol = `
  [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

After installation, **close and reopen PowerShell as administrator**.

Verify installation:

```powershell
choco --version
```

---

## 📦 Step 3: Install Required Tools via Chocolatey

In **PowerShell (admin)**, run the following commands:

```powershell
choco install python --pre -y
choco install make -y
choco install terraform -y
```

> These commands will:
> - Install Python 3 and pip
> - Install GNU Make
> - Install Terraform

---

## 🐍 Step 4: Install Python Packages

Open **Git Bash** or **PowerShell**, then run:

```bash
pip install pre-commit
```

---

## ✅ Step 5: Verify Your Setup

Run these commands in **Git Bash**:

```bash
python --version
pip --version
make --version
terraform version
pre-commit --version
```

You should see version numbers for all of them ✅

---

## 🚀 Step 6: Run the Project Setup

If your project includes a `Makefile`, run:

```bash
make install
```

This will:
- Check for required tools
- Install pre-commit Git hooks
- Prepare your dev environment

---

## 📘 Bonus: Where Things Get Installed

| Tool        | Installed by      | Example Location                             |
|-------------|-------------------|----------------------------------------------|
| Git Bash    | Git for Windows   | `C:\Program Files\Git\bin\bash.exe`          |
| Python 3    | Chocolatey        | `C:\PythonXX\` or `C:\Program Files\Python\` |
| pip3        | Comes with Python |                                              |
| make        | Chocolatey        | `C:\ProgramData\chocolatey\bin\make.exe`     |
| terraform   | Chocolatey        | `C:\ProgramData\chocolatey\bin\terraform.exe`|
| pre-commit  | pip               | Python’s `Scripts\` directory                |

---

## 🧪 Optional: Add Make to PATH (if needed)

If `make` doesn't work in Git Bash, add this to your Git Bash profile:

```bash
echo 'export PATH=$PATH:/c/ProgramData/chocolatey/bin' >> ~/.bashrc
source ~/.bashrc
```

Then try:

```bash
make --version
```

---

Let us know if you need a `.bat` or `.ps1` script to automate this setup!

