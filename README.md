# 📘 **IndexOf Downloader** - Overview

**IndexOf Downloader** is a Bash utility that scans a public `/index`-style directory webpage, extracts direct download links, and downloads all available files automatically.
It supports a wide variety of file types including documents, archives, executables, media files, and disk images.

This tool is designed for convenience, automation, and efficiency when downloading files from directory listings commonly found on servers, mirrors, and open file repositories.

---

## ✨ Features

* ✔ **Automatic link extraction** from `/index` pages
* ✔ **Supports dozens of file extensions** (documents, media, archives, ISOs, installers, etc.)
* ✔ **Automatic retry logic** for unstable connections
* ✔ **Proxy detection** (uses system `$http_proxy`)
* ✔ **Auto-generated download directory** if none is specified
* ✔ **Clean built-in help menu**

---

## 📥 Supported File Types

### Documents

`pdf, epub, djvu, doc, docx, txt, rtf, odt, odp, ods, ppt, pptx, xls, xlsx, csv, md`

### Source / Code Files

`asm, s, c, h, cpp, cc, hh, hpp, ps1, vb, bat, whl`

### Archives & Compressed Formats

`gz, rar, zip, 7z, z, bz2, xz, lzh, tar, zipx, 7a`

### Disk Images / Installers

`vhd, vmdk, img, deb, rpm, jar, apk, ios`

### Media

`mp4, flv, mov, wmv, avi, mkv, m4a, mp3`

### Image Formats

`jpg, png, webp, bmp, svg`

---

## 🚀 Usage

### **Basic Usage**

```bash
./indexof_downloader.sh <URL>
```

Downloads all detected files into a randomly generated directory.

### **Specify Download Directory**

```bash
./indexof_downloader.sh <URL> <TARGET_DIRECTORY>
```

Example:

```bash
./indexof_downloader.sh "https://example.com/files/" my_downloads
```

---

## 🆘 Help Menu

Show help automatically when no arguments are provided:

```bash
./indexof_downloader.sh
```

---

## 🧱 Script Workflow

1. Detects proxy settings
2. Extracts file extensions using `grep` + regex
3. Saves links into `<Target>.txt`
4. Downloads each file using `wget`
5. Logs failures to `logs/`
6. Displays progress + final status

---

## 📦 Requirements

* Bash (v4 or higher recommended)
* curl
* wget
* grep with extended regex support

---

## ⚠️ Disclaimer

This script is intended for legal use only.
Always ensure you have permission to download files from the target server.

---

