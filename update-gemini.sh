#!/usr/bin/env bash

# This script updates packages on Arch Linux.
# On Arch, it's best practice to do a full system upgrade (-Syu)
# rather than updating a single package.

echo "Checking for AUR helper 'yay'..."
if command -v yay &> /dev/null; then
    echo "'yay' found. Using it to update all packages (official and AUR)."
    # yay -Syu handles both official repository and AUR packages
    yay -Syu
else
    echo "'yay' not found. Falling back to pacman for official repositories."
    echo "If Gemini is an AUR package, you may need to update it manually or install an AUR helper like 'yay'."
    sudo pacman -Syu
fi

echo "Update process finished."
