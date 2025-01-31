set -e

cd /mnt/etc/nixos/Flakes

function set_user_name {
    echo $'\e[1;32mset your user login name\e[0m'
    read -p  $'\e[1;32mEnter your name: \e[0m' -r name_hash 
}
function set_user_passwd {
    echo $'\e[1;32mset your user login password\e[0m'
    passwd_hash=$(mkpasswd -m sha-512  2>/dev/null)
}
while true; do
    echo "The partition is now complete, please select the device you wish to install:"
    echo "1. laptop"
    echo "2. laptop_minimal"
    read -p  $'\e[1;32mEnter your choice(number): \e[0m' -r device

    case $device in
        1)
            set_user_name
            sed -i "/user\ =/c\ \ \ \ \  user\ =\ \"$name_hash\";" ./flake.nix
            sed -i "/hostName/c\ \ \ \ hostName\ =\ \"${name_hash^}\";" ./hosts/system.nix

            set_user_passwd
            sed -i "/initialHashedPassword/c\ \ \ \ initialHashedPassword\ =\ \"$passwd_hash\";" ./hosts/laptop/{wayland,x11}/default.nix
            nixos-install --option substituters https://mirror.sjtu.edu.cn/nix-channels/store  --no-root-passwd --flake .#laptop
            break ;;
        2)
            set_user_name
            sed -i "/user\ =/c\ \ \ \ \  user\ =\ \"$name_hash\";" ./flake.nix
            sed -i "/hostName/c\ \ \ \ hostName\ =\ \"${name_hash^}\";" ./hosts/system.nix

            set_user_passwd
            sed -i "/initialHashedPassword/c\ \ \ \ initialHashedPassword\ =\ \"$passwd_hash\";" ./hosts/laptop_minimal/default.nix
            nixos-install --option substituters https://mirror.sjtu.edu.cn/nix-channels/store --no-root-passwd --flake .#laptop-minimal
            break ;;
        *)
            echo "Invalid choice, please try again."
            ;;
    esac
done
