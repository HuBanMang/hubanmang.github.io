---
title: Debian
date: 2019-08-01 00:00:00 +0800
categories: [CS, Linux]
tags: [linux, debian]
---

**注意**：现在使用`setup-debian.sh`脚本快速配置Debian系统，本文件可能未更新。

```sh
    Permission denied.
```

## RTFM

- [Debian用户手册](https://www.debian.org/doc/user-manuals)
- [Debian开发者手册](https://www.debian.org/doc/devel-manuals)

- [Debian Wiki](https://wiki.debian.org)
- [Arch Wiki](https://wiki.archlinux.org)

- [Debian打包门户](https://wiki.debian.org/Packaging)
- [Arch软件包指导原则](https://wiki.archlinux.org/title/Arch_package_guidelines)

## Root

```sh
    ~# nano /etc/passwd # root:x:0:0:root:/usr/sbin/nologin
    # This Account is currently not available.

    ~# nano /etc/ssh/sshd_config # PermitRootLogin no
    # Permission denied, please try again.
```

**注意**：配置`/etc/passwd`中root用户的shell为`/usr/sbin/nologin`会禁用该账户，**包括在`emergency mode`中也无法登录**

**注意**：配置`/etc/ssh/sshd_config`中的`PermitRootLogin no`会禁用root的ssh登录

## 安装系统

### ISO

- 如果使用`stable`，从镜像站的`debian-cd`中选择
- 如果使用`testing`，从镜像站的`debian-cdimage/weekly-builds`中选择
- 如果需要`non-free`固件，从镜像站的`debian-cdimage/unofficial`中选择（Debian12之后将在安装时包含非自由固件，安装镜像将统一，不再需要专门下载包含非自由固件的ISO）

**注意**：Debian官方**不提供**`debian unstable/sid`的ISO，只可以从`stable`或`testing`升级到`unstable/sid`

**注意**：部分镜像站**不提供**`debian-cdimage`，`testing`的`weekly-builds`安装镜像是自动构建的，安装过程中可能出现问题，建议使用`stable`镜像最小化安装然后升级到`testing`或`unstable/sid`，或者使用`weekly-builds`时选择`Install`终端界面安装而不要选择`Graph Install`图形安装。

### 制作启动U盘

```sh
# 制作启动U盘
    ~$ lsblk # sudo fdisk -l
    ~$ sudo umount /dev/sd<x>[1]
    ~$ sudo dd if=debian.iso of=/dev/sd<x> bs=1M
    ~$ sudo eject /dev/sd<x>
```

### 分区

**单独分区**`/, /home, /var, /tmp, /srv, /data`

```sh
# 推荐分区大小，lvm可以调整分区，或选择其他支持调整分区的文件系统
/       32G     64G     256G
/var    8G      16G     64G
/tmp    2G      4G      8G
/home   max     max     max
swap    1G      mem+2

/srv, /data     nodev,[noexec,]nosuid

# 个人电脑可以不用分这么多分区，对于数据分区的noexec选项也可以酌情使用

# swap分区，如果使用`suspend`或`hibernate`（如笔记本休眠）最好按照官方wiki添加swap，如果不需要可以只分1-2G
# swap分区的大小众说纷纭，按照官方wiki应当设置两倍内存的大小，但是如果64G*2显然太浪费了
# 一般认为
# 如果内存<2G，则设置两倍内存大小
# 如果内存>2G，则设置内存大小+2G，也有一说设置内存大小*20%
# 无论实际内存多大，如果swap分区过小（如<1G），笔记本休眠后可能会无法唤醒

# 我在实际使用中，笔记本设置swap大小和内存大小相等，暂时未出现休眠和唤醒问题
```

### sources.list & preferences

**警告**：**不建议release混用**，如果需要特定release内的软件（如firefox, virtualbox），请**提前**配置好合理的`/etc/apt/preferences`！之后再启用testing/unstable，详情参考`man 5 apt_preferences`

**警告**：系统语言设置为英文，防止tty乱码，桌面语言可以在桌面设置内更改。

**注意**：系统安装过程中可能出现包全部标记为手动安装而后不会自动删除的`bug/feature`，`apt-mark showmanual`，`apt-mark minimize-manual`，**建议最小化安装**，在安装完成后首先安装`aptitude`，然后使用`aptitude`安装桌面等程序。

**注意**：除了`main`, `contrib`, `non-free`, `Debian testing/sid`添加了`non-free-firmware`(2023.02.15)，为了即将发布的`Debian12`安装时可以使用非自由固件

```sh
# 如果没有网络连接，挂载本地ISO
    ~# mkdir -p /media/iso
    ~# mount -o loop debian-DVD.iso /media/iso/
    ~# nano /etc/apt/sources.list # deb [trusted=yes] file:///media/iso/ stable main contrib

# /etc/apt/sources.list
    ~# nano /etc/apt/sources.list
# or
    ~# cp   sources.list preferences \
            /etc/apt/
    ~# chmod 644 /etc/apt/sources.list /etc/apt/preferences
```

## 基础程序

```sh
# debootstrap required important
    ~# tasksel install standard
# Log in as Root
    ~# apt update           # apt -o Acquire::ForceIPv4=true update
    ~# apt upgrade          # apt -o Acquire::ForceIPv4=true upgrade
    ~# apt install          sudo aptitude
    ~# aptitude install     ssh vim tmux git firewalld needrestart \
                            # debian-reference debian-handbook \
                            # apt-listbugs (for testing/sid) \
                            # apt-transport-https (no longer needed after debian10)
    ~# adduser username sudo # 添加用户到某个属组，需要重新登入生效，详情参考`man adduser`, `man useradd`, `id -nG`
    ~# reboot # Or Not
```

**注意**：debian默认没有配置防火墙，记得开启并配置防火墙，开放必要的端口或服务，如`sudo firewall-cmd --add-service=ssh`

**注意**：`apt-listbugs`和`unattended-upgrades`一起使用时，`apt-listbugs`如果下载bug信息失败，`unattended-upgrades`会一直请求下载然后一直失败。不要一起使用。

### Kernel

```sh
# Kernel devel
    ~$ sudo aptitude install        dkms gcc gdb git make rsync \
                                    # linux-doc gcc-doc gdb-doc git-doc make-doc \
                                    # linux-headers-$(uname -r)

# Hold Kernel
    ~$ sudo dpkg --get-selections | grep linux      # Or uname -a
    ~$ sudo apt-mark hold linux-image-x.x.x-x
```

### Firmware

```sh
# 查看硬件信息
    ~$ sudo lspci -k | grep -E "(3D|Audio|Ethernet|Network|VGA|Wireless)"
    ~$ sudo aptitude install    firmware-linux \
                                # firmware-iwlwifi firmware-realtek \
                                # firmware-sof-signed firmware-intel-sound

# 笔记本
    ~$ sudo aptitude install task-laptop
    ~$ sudo tasksel install laptop

# 监控硬件信息（温度，SSD-S.M.A.R.T）
    ~$ sudo aptitude install hw-probe # 安装hw-probe会根据依赖安装检测硬件的各种工具

# 自动推荐固件
    ~$ sudo aptitude install isenkram
    ~$ sudo isenkram-lookup

    ~$ sudo reboot # Or not
```

```sh
# Nvidia 更多信息见官方wiki
    ~$ sudo aptitude install dkms linux-headers-amd64
    ~$ sudo aptitude install firmware-linux firmware-misc-nonfree
    ~$ sudo aptitude install nvidia-driver
    ~$ sudo /sbin/modinfo -F version nvidia-current

# 从`Debian11`开始`apt install nvidia-driver`安装完成之后已经不再需要配置，但是需要在`BIOS`里关闭安全启动或自签名内核
# 使用KDE Wayland可能需要配置内核参数，详情参考`KDE Nvidia`

# CUDA
    ~$ sudo aptitude install nvidia-cuda-dev nvidia-cuda-toolkit # nvidia-visual-profiler

# OptiX 光线追踪
    ~$ sudo aptitude install libnvoptix1

# 增加架构
    ~$ sudo dpkg --add-architecture i386 # Steam 推荐使用flatpak安装steam
    ~$ sudo aptitude install nvidia-driver-libs:i386

# 必须重启
    ~$ sudo reboot
```

其他驱动参考`debian wiki firmware`及`debian wiki +硬件名`

- 从`Debian12`开始安装系统时会检测并安装非自由固件，基本不再需要手动安装，如仍有无法驱动的硬件请手动检查`dmesg`并搜索阅读官方wiki
- `wacom`手写板、`Xbox`手柄等内核自带驱动，不需要安装驱动即可使用
- 一些专有硬件能驱动的可能性不大，比如某些笔记本的内置声卡，指纹等

安装完成使用`sudo dmesg`查看内核启动信息，确认驱动正常

- `BIOS`可能会有`ERROR`，`iwlwifi`可能会有`ERROR`，不影响使用的`ERROR`不用管
- `Intel i915 driver`包含了所有支持的iGPU，但是`update-initramfs`并不能检查你需要哪些firmware，所以会有一些如`W: Possible missing firmware /lib/firmware/i915/rkl_xxx_xxxx_xx.bin for module i915`的警告，可以忽略

## 图形界面

### 启动到tty

为了减少GUI出现bug时的影响，可以选择系统启动到tty(`multi-user.target`)，然后选择启动显示管理器(gdm/sddm)，然后选择启动桌面。

```sh
    ~$ sudo systemctl get-default
    ~$ sudo systemctl set-default multi-user.target
    ~$ sudo systemctl start gdm # or sddm
```

### GNOME

[debian wiki gnome](https://wiki.debian.org/Gnome)

```sh
# 安装最小化Gnome
    ~$ sudo aptitude install [-R]   gnome-core \
                                    fonts-noto-cjk fonts-firacode \
                                    ibus-libpinyin ibus-table-wubi \
                                    # ibus-rime \
                                    # file-roller p7zip-full p7zip-rar \
                                    # gnome-shell-extension-appindicator \
                                    # gnome-shell-extension-dash-to-panel \
                                    # gnome-shell-extension-system-monitor \
                                    #papirus-icon-theme

# 安装完整的Gnome
    ~$ sudo aptitude install [-R]   gnome

# Hide Accounts
# /var/lib/AccountsService/users/username  # SystemAccount=true

# 删除gnome-core中不需要的程序（这会打破gnome-core的依赖）
    ~$ sudo apt-get purge gnome-software gnome-contacts
    ~$ sudo apt autoremove
```

- 中文输入法
  - 在`gnome-setting`的键盘->输入源中添加中文（智能拼音）
  - `ibus-libpinyin`可以提供中文拼音输入，词库和词语联想不太丰富，胜在简单，不需要配置
- 中文字体
  - 设置语言为中文且安装`Noto Sans CJK`后等宽字体`Monospace`会缺省到`Noto Sans Mono CJK`
  - 某些应用可能会因为该字体太狭长的问题导致排版异常，详见[字体顺序](#字体顺序)章节

- 如果新添加用户无法设置wifi等，可能是不在`netdev`属组（当然也不排除GUI的bug），通过`groups`或`id`查看属组，详情参考[`debian wiki systemgroups`](https://wiki.debian.org/SystemGroups)和[`arch wiki users and groups`](https://wiki.archlinux.org/title/Users_and_groups)
- 如果深受桌面环境的各种`bug/feature`的折磨，那么欢迎来到Linux的桌面世界。

### KDE

[debian wiki kde](https://wiki.debian.org/KDE)

```sh
# 安装最小化KDE
    ~$ sudo aptitude install [-R]   kde-plasma-desktop plasma-workspace-wayland
# 安装完整的KDE
    ~$ sudo aptitude install [-R]   kde-standard \
                                    fcitx5 fcitx5-chinese-addons \
                                    # kde-full
```

## 常用程序

### 终端工具

```sh
    ~$ sudo aptitude install    fzf fd-find     # find, use `fdfind` or alias fd='fdfind'
                                p7zip-full      # tar, zip
                                ranger vifm     # vi style file manager
                                ripgrep         # grep, use `rg`
                                tldr            # man
                                htop btop       # top
```

### 网络

```sh
    ~$ sudo aptitude install    v2ray trojan proxychains4

# 记得在防火墙中开放对应的端口
```

### 开发

```sh
    ~$ sudo aptitude install    shellcheck
    ~$ sudo aptitude install     \
                                clang clang-format clang-tidy clang-tools \
                                clangd \
                                libclang-dev libc++-dev libc++abi-dev \
                                lld lldb llvm llvm-dev \
                                cmake cmake-format ccache \
                                # valgrind \
                                # global cscope universal-ctags \
                                # cppman cppreference-doc-en-html \
                                # libboost-all-dev libboost-doc \
                                # qtcreator
    ~$ sudo aptitude install    python3-doc pip \
                                # jupyter
    ~$ sudo aptitude install    # default-jdk default-jdk-doc
    ~$ sudo aptitude install    sqlite3 sqlite3-doc sqlitebrowser
    ~$ sudo aptitude install    zeal # devhelp

# Set python3 (debian11之后已默认Python3)
    ~$ sudo update-alternatives --list python
    ~$ sudo update-alternatives --install \
                                /usr/bin/python python /usr/bin/python3 1
    ~$ python --version
# Or
    ~$ echo "alias python='python3'" >> ~/.bashrc

# Tips
# cppman无法离线缓存 (因为这个bug被从testing中移除了？)
    ~$ cppman --source 'cppreference.com'
    ~$ cppman --clear-cache
    ~$ cppman --rebuild-index
    ~$ cppman --cache-all
```

### Vim

```sh
    ~$ # sudo aptitude purge vim-tiny
    ~$ sudo aptitude install    vim vim-doc \
                                # vim-gtk3 / vim-nox \
                                # vim-addon-manager \
                                # vim-ctrlp vim-python-jedi \
                                # vim-snippets vim-ultisnips \
                                # vim-voom \
                                # vim-youcompleteme \
                                # vim-scripts
    ~$ [sudo] vim-addons install [-w] some-addons

# debian仓库里提供了一些vim插件，可以通过`vim-addons install`在用户空间安装，或`vim-addons install -w`全局安装
# 全局安装在使用sudo vim(rvim)时，系统插件会报错，rvim中无法执行脚本，最好在用户空间管理插件，并且使用`sudo -e/sudoedit`编辑需要root权限的文件

# 用户vimrc
    ~$ vi ~/.vimrc
    #if filereadable(expand(\"/dotfiles/editor/vim/vimrc.local\")
    #  source /dotfiles/editor/vim/vimrc.local
    #endif

# 系统vimrc
    ~$ sudo cp /dotfiles/editor/vim/vimrc.local \
                    /etc/vim/vimrc.local

# NeoVim
    ~$ # 从apt源内安装，版本较落后
    ~$ sudo aptitude install neovim
    ~$ # 或者从github下载`nvim-linux64.deb`或Appimage
    ~$ sudo apt install ./nvim-linux64.deb
    ~$ touch ~/.vimrc # nvim使用.config/nvim/init.vim，vim使用系统配置和~/.vimrc
```

### 源码编译

从源码编译程序，以emacs为例

```sh
# Build emacs
    ~$ #sudo apt build-dep emacs # 不推荐，很难删除依赖
    ~$ #sudo aptitude build-dep emacs # 报错
    ~$ # 使用 mk-build-deps
    ~$ sudo aptitude install devscripts
    ~$ sudo mk-build-deps emacs
    ~$ sudo apt install ./emacs-build-deps*.deb # build完成后apt purge删除该包
    ~$ # Get emacs source
    ~$ git clone git://git.savannah.gnu.org/emacs.git
    ~$ cd emacs
    ~$ git branch -a
    ~$ git checkout emacs-28
    ~$ ./autogen.sh
    ~$ #sudo aptitude install libgccjit-*-dev
    ~$ ./configure --with-native-compilation
    ~$ #sudo aptitude install libgtk-*-dev libwebkit2gtk-*-
    ~$ #./configure --with-cairo --with-xwidgets --with-x-toolkit=gtk3
    ~$ make -j$(nproc)
    ~$ sudo make install
```

### 文档媒体

```sh
    ~$ sudo aptitude install    goldendict \
                                calibre pandoc \
                                texlive-xetex texlive-lang-cjk \
                                texlive-science \
                                # libreoffice \
                                # vlc gimp krita blender shotcut etc...
```

### 更多

```sh
    ~$ sudo aptitude install    fortunes-zh cowsay oneko gtypist
    ~$ fortune-zh | cowsay -f dragon-and-cow
    ~$ sudo reboot # Or unplug the power =-=
```

## 配置

### Grub引导

```sh
    ~$ sudo -e /etc/default/grub
    ~$ sudo update-grub

#GRUB_TIMEOUT=2
#GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 splash"
#GRUB_DISABLE_OS_PROBER=false
#GRUB_TERMINAL=console
#GRUB_GFXMODE=640x480

# kernel loglevel
# 0     emerg
# 1     alert
# 2     crit
# 3     err
# 4     warn
# 5     notice
# 6     info
# 7     debug
# sudo dmesg -l warn,err

# grub theme
# /etc/grub.d/05_debian_theme
```

### 区域和语言

/etc/default/locale

- `LANG` 默认语言
  - 所有未显式设置的 `LC_*` 变量会使用 `LANG` 的参数
  - `C.UTF-8`: Computer bytes/ASCII
- `LANGUAGE` 缺省语言（桌面环境，图形界面等）
  - 仅当 `LC_ALL` 和 `LANG` 没有被设置为 'C.UTF-8' 时生效
- `LC_ALL` 格式（时间，单位等）
  - `LC_ALL=C.UTF-8` 覆盖所有的 `LC_*` 设置

- 使用`sudo dpkg-reconfigure locales`配置系统locale
- 使用`/etc/locale.gen`和`locale-gen`和`/etc/default/locale`配置系统locale
- 使用`LC_ALL=* LANG=* LANGUAGE=* locale`在shell中测试
- 使用`$XDG_CONFIG_HOME/locale.conf`配置用户locale
- 图形界面语言在桌面设置中设置

```sh
# /etc/default/locale
LANG=C.UTF-8
# ~/.config/locale.conf
LANG=zh_CN.UTF-8
LANGUAGE=zh_CN.UTF-8:en_US.UTF-8

# 如果使用桌面环境，可以只在/etc/default/locale中设置`LANG=C.UTF-8`或`LANG=en_US.UTF-8`，不设置LANGUAGE，在桌面的`区域与语言`中选择语言
```

### 无人值守更新

无人值守更新尽量**不要设置删除旧包或安装新包**

[debian wiki unattended upgrade](https://wiki.debian.org/UnattendedUpgrades)

```sh
    ~$ sudo aptitude install unattended-upgrade # vi /etc/apt/apt.conf.d/50unattended-upgrades
    ~$ sudo dpkg-reconfigure unattended-upgrade # vi /etc/apt/apt.conf.d/20auto-upgrades
    ~$ sudo unattended-upgrade -d --dry-run # debug unattended-upgrade
    ~$ sudo -e /lib/systemd/system/apt-daily.timer.d/override.conf # download
    ~$ sudo -e /lib/systemd/system/apt-daily-upgrade.timer.d/override.conf # upgrade
```

### 虚拟机

```sh
# Virt Manager GUI (libvirt, virtinst)
    ~$ sudo aptitude install virt-manager virt-viewer virtinst

# commandline utils, no graphical packages (libvirt, virtinst)
    ~$ sudo aptitude install -R libvirt-daemon-system \
                            qemu-system qemu-utils virtinst bridge-utils

# add user to libvirt group
    ~$ sudo adduser username libvirt # sudo usermod -aG libvirt username

# Cockpit-Machines (libvirt, virtinst)
    ~$ sudo aptitude install cockpit cockpit-machines virtinst

# Or use VirtualBox (disable secure boot)
    ~$ sudo aptitude install virtualbox # (unstable contrib or stable fasttrack)
    ~$ sudo adduser username vboxsf # sudo usermod -aG vboxsf username
```

### 字体

#### 字体顺序

英文环境默认选中字体：

- `Serif: Noto Serif`
- `Sans-Serif: Noto Sans`
- `Monospace: Noto Sans Mono`

中文环境默认选中字体：

- `Serif: Noto Serif CJK SC`
- `Sans-Serif: Noto Sans CJK SC`
- `Monospace: Noto Sans Mono`

```sh
# `man fonts-conf`
# ~/.fonts.conf
# ~/.config/fontconfig/fonts.conf
    ~$ cp /dotfiles/pathto/.fonts.conf ~/.config/fontconfig/fonts.conf

# 安装一些本地字体
    ~$ cp -r /path/to/somefonts $HOME/.local/share/fonts
    ~$ fc-cache -fv

# 查看字体顺序列表
    ~$ fc-match -s monospace | head
    ~$ fc-match -s sans-serif | head
    ~$ fc-match -s serif | head

# 如果字体顺序有误，重新生成cache
    ~$ fc-cache -fv
    ~$ # 或者sudo执行
    ~$ sudo dpkg-reconfigure fontconfig fontconfig-config
```

**注意**：

`/etc/fonts/fonts.conf`及`/etc/fonts/conf.d/*`设置了系统字体的优先顺序

如`monospace`中文环境默认会选中`Noto Sans Mono CJK SC`，由`/etc/fonts/conf.d/70-fonts-noto-cjk.conf`配置，这是一款包含中文的等宽字体，其中的英文和数字是中文的一半宽度。

半宽英文一方面可以解决对齐问题，另一方面可能造成排版问题。

如GNOME的PDF阅读器`evince`使用的后端`poppler`，在中文环境中`Courier`等非内嵌的等宽字体会缺省为`monospace` -> `Noto Sans Mono CJK`导致排版问题，且其只遵循`fontconfig`的配置无法在应用内设置字体的缺省顺序。

事实上所有将字体缺省到`monospace`的应用都使用这款字体，而每个应用都重新设置显然不太方便，所以仍然需要使用`fontconfig fonts.conf`重新自定义字体顺序。

在`70-fonts-noto-cjk.conf`中直接修改会在字体更新时被覆盖，所以一般配置`/etc/fonts/local.conf`或`~/.config/fontconfig/fonts.conf`，详情参考`man fonts-conf`

#### 中英字体对齐

如果确实需要中英字体对齐（如有缩进对齐的表格等），需要使用“X个汉字是Y个英文字母宽度”的字体，如比较常见的“一个汉字是两个英文字母宽度”的字体。

尽管在等高的情况下，如果一个汉字是英文字母的两倍宽度会显得太宽或间距太大，如果一个英文字母是一个汉字的一半宽度会显得太瘦，但这是中英字体对齐的一种较简单的办法，在不需要对齐的情况下可以不使用这样的等宽字体。

在终端环境中一般默认一个中文汉字是两个字母宽度，虽然字间距会稍微大一点，但是不需要专门使用中英对齐的字体（不同的终端模拟器可能不同）。

```sh
每个英文字母占一个字宽
每个中文汉字占两个字宽
Each English letter occupies a character width
Each Chinese character occupies two characters width

0123456789      0123456789
一二三四五      一二三四五
abcdefghij      abcdefghij

0123456789      0123456789
一二三abcd      一二三abcd
ab一c二d三      ab一c二d三
```

#### 相似字形区分

```sh
aaaaaaaaaa \
oooooooooo \
OOOOOOOOOO \
0000000000 \
QQQQQQQQQQ \
CCCCCCCCCC \
GGGGGGGGGG \
iiiiiiiiii \
IIIIIIIIII \
llllllllll \
1111111111 \
|||||||||| \
丨丨丨丨丨(中文的 shu) \
gggggggggg \
9999999999 \
qqqqqqqqqq
```

#### 字体异形

**注意**：现在Debian和Arch都在noto字体包中包含了语言配置如`/etc/fonts/conf.d/70-fonts-noto-cjk.conf`，不再需要手动设置noto字体的语种（但仍然需要设置Monospace的缺省顺序），中文环境会优先使用中文字体`Noto Sans CJK SC`。

参考链接：

- [`arch wiki`简体中文显示为异体字形](https://wiki.archlinux.org/title/Localization/Simplified_Chinese#Fixed_Simplified_Chinese_display_as_a_variant_(Japanese)_glyph)

```sh
# /etc/fonts/local.conf
    ~$ sudo cp /dotfiles/pathto/local.conf /etc/fonts/local.conf
    ~$ fc-cache -fv
    ~$ fc-match -s | grep 'CJK'
    ~$ # NotoSansCJK-Regular.ttc: "Noto Sans CJK SC" "Regular"
```

### Tweaks

```sh
# Fonts
# 使用fontconfig设置字体缺省顺序后可以直接使用通用字体名
    Cantarell Regular       Sans Regular    12
    DejaVu Sans Book        Sans Regular    16
    DejaVu Sans Mono Book   Monospace       16
    Cantarell Blod          Sans Regular    12

    Scaling Factor          1.00/1.1

# Keyboard
    Additional Layout Options --> Ctrl position --> Caps Lock as Ctrl

# Shell/scripts
    gsetting-*.sh
```

## 2019.08

- 汇总Debian安装和使用笔记

## 2022.04

- 尝试使用脚本快速配置Debian系统，本文件可能未同步更新

## 2022.10

- 分离配置内容到`dotfiles`的各部分`READEME.md`，本文件不再更新配置内容

## 2023.02

- 添加Debian12 `non-free-firmware`相关信息

## 2023.05

- 添加本文件作为`dotfiles`中`debian`部分的`README.md`，仅作留存

## 写在最后

这是我从大学开始用Debian到现在攒出来的一份笔记，杂七杂八。
一开始学计科，我以为是要当黑客，安装了Kali Linux，从这儿开始接触了Debian，算是阴差阳错进对了门，后来学习嵌入式就一直用Debian了。
那时候花了很多时间面对着tty的黑框框，有点儿后悔没有参加算法比赛，多锻炼编程思维，之后确实付出了很多代价补课。
当然，无论怎么度过这些时间都会后悔的，或者说，只要当时不后悔，后来的后悔都不算数。
