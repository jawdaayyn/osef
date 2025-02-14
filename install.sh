jawdan
kcjawdan
Invisible

jawdan — Aujourd’hui à 02:47
si tu veux demain je passe a la bibliotheque apres mon taff on finit ça comme ça c'est fini
Nassima — Aujourd’hui à 02:47
vasy toi aussi repose toi, tkt je vais resté enccore 30 min, et je dors
Nassima — Aujourd’hui à 02:48
oui oui moi c parfait
jawdan — Aujourd’hui à 02:49
ouais tkt c ce que je vais faire mdrrr le taff ça ma tue la
jawdan — Aujourd’hui à 02:49
tu vas à laquelle d’habitude
Nassima — Aujourd’hui à 02:51
bpi chatelet, mais si tu veux une autre tu me dis
prcq on peut pas trop parlé labas en vrai
jawdan — Aujourd’hui à 02:54
ahhh je sais pas comme tu veux
jawdan — Aujourd’hui à 02:54
moi je sais juste que celle de biblotheque françois mitterand tu peux réserver une salle en vrai
Nassima — Aujourd’hui à 02:55
tu fini à quel heure toi demain?
jawdan — Aujourd’hui à 02:55
après jsp si c blindé quoi
je finis à 18h et toi??
Nassima — Aujourd’hui à 02:56
moi je bosse pas demain, j'ai posé aujourd'hui et demain (les  5 jours de révisions par an qu'on a j'ai pris 2 jrs j'ai laissé 3 pour l'autre semestre  ), j'étais un peu malade le début de la semaine donc je prefere me reposé un peu deja avnt la semaine pro
mais au final a cause de ce projet il m'as plus fatiguée lol
François mitterrand ferme à 20h c'est tot non ? vu que tu fini à 18h
bpi jusqu'a 22h
jawdan — Aujourd’hui à 02:59
ptnnnnn j’avoue c pas bête ça les 5 jours faut jles dépense à un moment
nn mais ta raison repose toi semaine pro ça va être hardcore
faut être prêt
moi j’ai posé 3 semaines en mai mdr jveux me reposer en mai c tout
vas-y go BPI alors ouais j’avoue jsavais aps ça ferme à 20h
Nassima — Aujourd’hui à 03:00
oui je vais etre a la bpi vers 15h -16h je vais essayer d'avancé , tu me rejoins apres
on analysant mon fichier de log je vois que le partitionnement et le montage fonctionnent parfaitement , et c'est le grep qui est mal installé je vais l'installé manuellement pour etre sur que c'est ça, on le corrige ca devrait aller
Image
Image
vasy bonne nuit à demain, je fini juste le test je dors
jawdan — Aujourd’hui à 03:03
vasyyy on fait comme ça jsuis là à 18h30 normalement
Nassima — Aujourd’hui à 03:03
oki parfait
a demain
jawdan — Aujourd’hui à 03:04
ahhhh ptnnn y’a grave moyen c’est ça okok
vas-y bonne nuit à demain
reste pas trop tard dessus
Nassima — Aujourd’hui à 03:05
tkt tkt , vasy bonne nuit, c'est le last test
jawdan — Aujourd’hui à 17:02
salut nassima ça va ? du coup c’est toujours bon si j’viens a la bibliothèque à 18h30?? 
Nassima — Aujourd’hui à 17:03
Salut Jawdan, ca av et toi ? oui oui je suis à la bibliotheque
Image
Je suis en train de tester ça
Nassima — Aujourd’hui à 17:54
omg, l'Install est fini, je redémarre j'ai peur lol
jawdan — Aujourd’hui à 18:15
vas-y c’est bon j’arrive là
jawdan — Aujourd’hui à 18:15
ça va ça va, att il est trop sympa wsh il t’a tout donné
jawdan — Aujourd’hui à 18:16
vas-y j’espère ça passe mdrrrr
jawdan — Aujourd’hui à 18:40
je suis rentré faut aller ou mdrrr
Nassima — Aujourd’hui à 18:41
attends j'arrive
T ou je suis à l’entrée
jawdan — Aujourd’hui à 18:42
moi aussi
Nassima — Aujourd’hui à 18:42
Image
jawdan — Aujourd’hui à 18:42
faut monter en haut ??
Nassima — Aujourd’hui à 18:43
Oui  ’étage Bpi
jawdan — Aujourd’hui à 18:43
okok j’arrive
Nassima — Aujourd’hui à 18:43
Vas-y
Tu as manqué un appel de Nassima qui a duré quelques secondes. — Aujourd’hui à 18:48
Nassima — Aujourd’hui à 18:57
#!/bin/bash

# ✅ Vérification si le script est exécuté en root
if [ "$EUID" -ne 0 ]; then
    echo "Ce script doit être exécuté en tant que root."
    exit 1
fi

# 🔹 Définition des variables
DISK="/dev/sda"
PASSWORD="azerty123"
HOSTNAME="arch-vm"

# ✅ Partitionnement du disque
parted --script $DISK mklabel gpt
parted --script $DISK mkpart primary fat32 1MiB 513MiB
parted --script $DISK set 1 esp on
parted --script $DISK mkpart primary ext4 513MiB 1GiB
parted --script $DISK mkpart primary 1GiB 100%

# ✅ Chiffrement de la partition principale
echo -n "$PASSWORD" | cryptsetup luksFormat --type luks2 ${DISK}3 -
echo -n "$PASSWORD" | cryptsetup open ${DISK}3 cryptlvm

# 📌 Vérification : Est-ce que cryptlvm est bien ouvert ?
ls /dev/mapper/
if [ ! -e "/dev/mapper/cryptlvm" ]; then
    echo "Erreur : Le chiffrement LUKS a échoué."
    exit 1
fi

# ✅ Création du volume LVM
pvcreate /dev/mapper/cryptlvm
vgcreate vg0 /dev/mapper/cryptlvm
lvcreate -L 30G -n root vg0
lvcreate -L 8G -n swap vg0
lvcreate -L 10G -n encrypted vg0
lvcreate -L 5G -n shared vg0
lvcreate -L 10G -n vbox vg0
lvcreate -l 100%FREE -n home vg0

# ✅ Formatage des partitions
mkfs.fat -F32 ${DISK}1
mkfs.ext4 ${DISK}2
mkfs.ext4 /dev/vg0/root
mkfs.ext4 /dev/vg0/home
mkfs.ext4 /dev/vg0/shared
mkfs.ext4 /dev/vg0/vbox
mkswap /dev/vg0/swap
swapon /dev/vg0/swap

# ✅ Montage des partitions
mount /dev/vg0/root /mnt
mkdir -p /mnt/boot
mount ${DISK}2 /mnt/boot
mkdir -p /mnt/boot/efi
mount ${DISK}1 /mnt/boot/efi
mkdir -p /mnt/home
mount /dev/vg0/home /mnt/home
mkdir -p /mnt/shared
mount /dev/vg0/shared /mnt/shared
mkdir -p /mnt/vbox
mount /dev/vg0/vbox /mnt/vbox

# 📌 Vérification : Tout est bien monté ?
lsblk -f

# ✅ Installation du système de base
pacstrap /mnt base linux linux-firmware lvm2 vim networkmanager

# ✅ Génération du fichier fstab
genfstab -U /mnt >> /mnt/etc/fstab

# ✅ Configuration du système
arch-chroot /mnt /bin/bash <<EOF

# ✅ Configuration du fuseau horaire et horloge
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc

# ✅ Configuration de la langue et de la console
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "$HOSTNAME" > /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

# ✅ Activation du réseau
systemctl enable NetworkManager
systemctl start NetworkManager

# ✅ Création des utilisateurs
echo "root:$PASSWORD" | chpasswd
useradd -m -G wheel -s /bin/bash papa
echo "papa:$PASSWORD" | chpasswd
useradd -m -s /bin/bash fils
echo "fils:$PASSWORD" | chpasswd
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
... (39lignes restantes)
Réduire
message.txt
5 Ko
﻿
#!/bin/bash

# ✅ Vérification si le script est exécuté en root
if [ "$EUID" -ne 0 ]; then
    echo "Ce script doit être exécuté en tant que root."
    exit 1
fi

# 🔹 Définition des variables
DISK="/dev/sda"
PASSWORD="azerty123"
HOSTNAME="arch-vm"

# ✅ Partitionnement du disque
parted --script $DISK mklabel gpt
parted --script $DISK mkpart primary fat32 1MiB 513MiB
parted --script $DISK set 1 esp on
parted --script $DISK mkpart primary ext4 513MiB 1GiB
parted --script $DISK mkpart primary 1GiB 100%

# ✅ Chiffrement de la partition principale
echo -n "$PASSWORD" | cryptsetup luksFormat --type luks2 ${DISK}3 -
echo -n "$PASSWORD" | cryptsetup open ${DISK}3 cryptlvm

# 📌 Vérification : Est-ce que cryptlvm est bien ouvert ?
ls /dev/mapper/
if [ ! -e "/dev/mapper/cryptlvm" ]; then
    echo "Erreur : Le chiffrement LUKS a échoué."
    exit 1
fi

# ✅ Création du volume LVM
pvcreate /dev/mapper/cryptlvm
vgcreate vg0 /dev/mapper/cryptlvm
lvcreate -L 30G -n root vg0
lvcreate -L 8G -n swap vg0
lvcreate -L 10G -n encrypted vg0
lvcreate -L 5G -n shared vg0
lvcreate -L 10G -n vbox vg0
lvcreate -l 100%FREE -n home vg0

# ✅ Formatage des partitions
mkfs.fat -F32 ${DISK}1
mkfs.ext4 ${DISK}2
mkfs.ext4 /dev/vg0/root
mkfs.ext4 /dev/vg0/home
mkfs.ext4 /dev/vg0/shared
mkfs.ext4 /dev/vg0/vbox
mkswap /dev/vg0/swap
swapon /dev/vg0/swap

# ✅ Montage des partitions
mount /dev/vg0/root /mnt
mkdir -p /mnt/boot
mount ${DISK}2 /mnt/boot
mkdir -p /mnt/boot/efi
mount ${DISK}1 /mnt/boot/efi
mkdir -p /mnt/home
mount /dev/vg0/home /mnt/home
mkdir -p /mnt/shared
mount /dev/vg0/shared /mnt/shared
mkdir -p /mnt/vbox
mount /dev/vg0/vbox /mnt/vbox

# 📌 Vérification : Tout est bien monté ?
lsblk -f

# ✅ Installation du système de base
pacstrap /mnt base linux linux-firmware lvm2 vim networkmanager

# ✅ Génération du fichier fstab
genfstab -U /mnt >> /mnt/etc/fstab

# ✅ Configuration du système
arch-chroot /mnt /bin/bash <<EOF

# ✅ Configuration du fuseau horaire et horloge
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc

# ✅ Configuration de la langue et de la console
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "$HOSTNAME" > /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

# ✅ Activation du réseau
systemctl enable NetworkManager
systemctl start NetworkManager

# ✅ Création des utilisateurs
echo "root:$PASSWORD" | chpasswd
useradd -m -G wheel -s /bin/bash papa
echo "papa:$PASSWORD" | chpasswd
useradd -m -s /bin/bash fils
echo "fils:$PASSWORD" | chpasswd
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# ✅ Installation des paquets essentiels
pacman -Syu --noconfirm
pacman -S sudo virtualbox virtualbox-host-dkms linux-headers firefox gcc make htop neofetch git base-devel xorg-server xorg-xinit i3 dmenu alacritty --noconfirm

# ✅ Configuration de i3 pour l’utilisateur papa
mkdir -p /home/papa/.config/i3
cat <<EOCFG > /home/papa/.config/i3/config
# i3 minimal config
exec --no-startup-id nm-applet
exec --no-startup-id feh --bg-scale /usr/share/backgrounds/archlinux.png
bindsym \$mod+Enter exec alacritty
bindsym \$mod+d exec dmenu_run
EOCFG
chown -R papa:papa /home/papa/.config

# ✅ Installation de GRUB et génération du fichier de configuration
pacman -S grub efibootmgr --noconfirm
echo "GRUB_CMDLINE_LINUX=\"cryptdevice=${DISK}3:cryptlvm root=/dev/mapper/vg0-root\"" >> /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# ✅ Correction de initramfs
sed -i 's/^HOOKS=(.*/HOOKS=(base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck)/' /etc/mkinitcpio.conf
mkinitcpio -P

EOF

# ✅ Vérifications finales avant redémarrage
lsblk -f > /mnt/install_check.txt
cat /mnt/etc/fstab >> /mnt/install_check.txt

# ✅ Nettoyage et démontage
umount -R /mnt
swapoff -a
cryptsetup close cryptlvm

echo "Installation terminée ! Vérifie le fichier /mnt/install_check.txt avant de redémarrer."
message.txt
5 Ko