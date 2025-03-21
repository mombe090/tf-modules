#!/usr/bin/env bash

#$1 = url de l'image talos à télécharger
#$2 = Refresh Talos Image

pve_iso_path="/var/lib/vz/template/iso"
image_name="talos-nocloud-amd64-qemu-agent"
installer_image_url=$1

#Cette vérification est faite pour éviter de télécharger le fichier si il existe déjà, ce qui permet de gagner du temps et surtout de la bande passante
if [[ -f "$pve_iso_path/$image_name" && $2 == "false" ]]; then
    echo "$1 existe déjà"
else
    raw_filename="talos-nocloud-amd64.raw"
    echo "Installation si nécessaire du package xz-utils qui permet de décompresser les fichiers .xz"
    sudo apt-get install xz-utils -y

    echo "Téléchargement du fichier image Talos Linux"
    curl -o $raw_filename.xz $1

    echo "Décompression du fichier image Talos Linux"
    xz -d $raw_filename.xz

    echo "Déplacement du fichier raw dans le dossier des fichiers iso de proxmox"
    mv $raw_filename $pve_iso_path/$image_name.img

    echo "Suppression du script dont on a plus besoin"
    rm download-talos.sh
fi
