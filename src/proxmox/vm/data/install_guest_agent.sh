#!/bin/bash

# Script to install QEMU Guest Agent and optionally setup GitHub SSH keys
# Supports Debian family (Ubuntu, Debian) and Red Hat family (RHEL, CentOS, Fedora, Rocky, AlmaLinux)
# Usage: ./install_guest_agent.sh [github_username]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to detect distribution family
detect_distro_family() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian)
                echo "debian"
                ;;
            rhel|centos|fedora|rocky|almalinux)
                echo "redhat"
                ;;
            *)
                echo "unknown"
                ;;
        esac
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    elif [[ -f /etc/redhat-release ]]; then
        echo "redhat"
    else
        echo "unknown"
    fi
}

# Function to check if guest agent is already installed
is_guest_agent_installed() {
    case "$1" in
        debian)
            dpkg -l qemu-guest-agent >/dev/null 2>&1
            ;;
        redhat)
            rpm -q qemu-guest-agent >/dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

# Function to wait for apt lock to be released
wait_for_apt_lock() {
    local timeout=300  # 5 minutes timeout
    local elapsed=0
    local interval=5

    log_info "Checking for apt lock..."

    while fuser /var/lib/apt/lists/lock >/dev/null 2>&1 || \
          fuser /var/lib/dpkg/lock >/dev/null 2>&1 || \
          fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do

        if [ $elapsed -ge $timeout ]; then
            log_error "Timeout waiting for apt lock to be released after $timeout seconds"
            exit 1
        fi

        log_warn "Waiting for apt lock to be released... (${elapsed}s elapsed)"
        sleep $interval
        elapsed=$((elapsed + interval))
    done

    log_info "Apt lock is available"
}

# Function to setup SSH keys from GitHub
setup_github_ssh_keys() {
    local github_username="$1"
    local target_user="$2"
    local user_home

    log_info "Setting up SSH keys for user '$target_user' from GitHub user '$github_username'..."

    # Get the user's home directory
    if ! user_home=$(getent passwd "$target_user" | cut -d: -f6); then
        log_error "User '$target_user' does not exist on this system"
        return 1
    fi

    # Check if user home directory exists
    if [[ ! -d "$user_home" ]]; then
        log_error "Home directory '$user_home' does not exist for user '$target_user'"
        return 1
    fi

    # Create .ssh directory if it doesn't exist
    local ssh_dir="$user_home/.ssh"
    if [[ ! -d "$ssh_dir" ]]; then
        log_info "Creating SSH directory: $ssh_dir"
        mkdir -p "$ssh_dir"
        chown "$target_user:$(id -gn "$target_user")" "$ssh_dir"
        chmod 700 "$ssh_dir"
    fi

    # Download GitHub SSH keys
    local github_keys_url="https://github.com/$github_username.keys"
    local temp_keys_file
    temp_keys_file=$(mktemp)

    log_info "Downloading SSH keys from: $github_keys_url"

    if command -v curl >/dev/null 2>&1; then
        if ! curl -fsSL "$github_keys_url" -o "$temp_keys_file"; then
            log_error "Failed to download SSH keys from GitHub for user '$github_username'"
            rm -f "$temp_keys_file"
            return 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if ! wget -q -O "$temp_keys_file" "$github_keys_url"; then
            log_error "Failed to download SSH keys from GitHub for user '$github_username'"
            rm -f "$temp_keys_file"
            return 1
        fi
    else
        log_error "Neither curl nor wget is available to download SSH keys"
        rm -f "$temp_keys_file"
        return 1
    fi

    # Check if we got any keys
    if [[ ! -s "$temp_keys_file" ]]; then
        log_error "No SSH keys found for GitHub user '$github_username' or user doesn't exist"
        rm -f "$temp_keys_file"
        return 1
    fi

    # Validate SSH keys format
    local valid_keys=0
    while IFS= read -r line; do
        if [[ -n "$line" && "$line" =~ ^(ssh-rsa|ssh-ed25519|ssh-dss|ecdsa-sha2-nistp256|ecdsa-sha2-nistp384|ecdsa-sha2-nistp521) ]]; then
            ((valid_keys++))
        fi
    done < "$temp_keys_file"

    if [[ $valid_keys -eq 0 ]]; then
        log_error "No valid SSH keys found in the downloaded content"
        rm -f "$temp_keys_file"
        return 1
    fi

    log_info "Found $valid_keys valid SSH key(s)"

    # Setup authorized_keys file
    local authorized_keys_file="$ssh_dir/authorized_keys"

    # Create authorized_keys if it doesn't exist
    if [[ ! -f "$authorized_keys_file" ]]; then
        touch "$authorized_keys_file"
        chown "$target_user:$(id -gn "$target_user")" "$authorized_keys_file"
        chmod 600 "$authorized_keys_file"
    fi

    # Backup existing authorized_keys
    if [[ -s "$authorized_keys_file" ]]; then
        log_info "Backing up existing authorized_keys file"
        cp "$authorized_keys_file" "${authorized_keys_file}.backup.$(date +%Y%m%d_%H%M%S)"
    fi

    # Add GitHub keys to authorized_keys (avoiding duplicates)
    local added_keys=0
    while IFS= read -r key; do
        if [[ -n "$key" && "$key" =~ ^(ssh-rsa|ssh-ed25519|ssh-dss|ecdsa-sha2-nistp256|ecdsa-sha2-nistp384|ecdsa-sha2-nistp521) ]]; then
            # Check if key already exists
            if ! grep -Fq "$key" "$authorized_keys_file" 2>/dev/null; then
                echo "$key # Added from GitHub user: $github_username on $(date)" >> "$authorized_keys_file"
                ((added_keys++))
            else
                log_info "SSH key already exists in authorized_keys, skipping duplicate"
            fi
        fi
    done < "$temp_keys_file"

    # Clean up
    rm -f "$temp_keys_file"

    if [[ $added_keys -gt 0 ]]; then
        log_info "Successfully added $added_keys SSH key(s) to $authorized_keys_file"
        log_info "SSH key setup completed for user '$target_user'"
    else
        log_warn "No new SSH keys were added (all keys already existed)"
    fi

    return 0
}

# Function to install guest agent on Debian family
install_debian_guest_agent() {
    log_info "Installing QEMU Guest Agent on Debian family system..."

    # Wait for any existing apt processes to finish
    wait_for_apt_lock

    # Update package lists
    log_info "Updating package lists..."
    apt update

    # Install qemu-guest-agent
    log_info "Installing qemu-guest-agent package..."
    apt install -y qemu-guest-agent

    # Enable and start the service
    log_info "Enabling and starting qemu-guest-agent service..."
    systemctl enable qemu-guest-agent
    systemctl start qemu-guest-agent
}

# Function to install guest agent on Red Hat family
install_redhat_guest_agent() {
    log_info "Installing QEMU Guest Agent on Red Hat family system..."

    # Determine package manager
    if command -v dnf >/dev/null 2>&1; then
        PKG_MGR="dnf"
    elif command -v yum >/dev/null 2>&1; then
        PKG_MGR="yum"
    else
        log_error "Neither dnf nor yum package manager found!"
        exit 1
    fi

    # Install qemu-guest-agent
    log_info "Installing qemu-guest-agent package using $PKG_MGR..."
    $PKG_MGR install -y qemu-guest-agent

    # Enable and start the service
    log_info "Enabling and starting qemu-guest-agent service..."
    systemctl enable qemu-guest-agent
    systemctl start qemu-guest-agent
}

# Function to verify installation
verify_installation() {
    if systemctl is-active --quiet qemu-guest-agent; then
        log_info "QEMU Guest Agent is running successfully!"
        systemctl status qemu-guest-agent --no-pager -l
    else
        log_error "QEMU Guest Agent is not running!"
        exit 1
    fi
}

# Main execution
main() {
    local github_username=""
    local target_user="root"  # Default to root user

    # Parse command line arguments
    if [[ $# -gt 0 ]]; then
        github_username="$1"
        log_info "GitHub username provided: $github_username"

        # If a second argument is provided, use it as the target user
        if [[ $# -gt 1 ]]; then
            target_user="$2"
            log_info "Target user specified: $target_user"
        else
            # Try to detect a non-root user with a home directory
            for user in $(getent passwd | awk -F: '$3 >= 1000 && $3 < 65534 {print $1}'); do
                if [[ -d "/home/$user" ]]; then
                    target_user="$user"
                    log_info "Auto-detected target user: $target_user"
                    break
                fi
            done
        fi
    fi

    log_info "Starting QEMU Guest Agent installation..."

    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi

    # Detect distribution family
    DISTRO_FAMILY=$(detect_distro_family)
    log_info "Detected distribution family: $DISTRO_FAMILY"

    # Check if guest agent is already installed
    if is_guest_agent_installed "$DISTRO_FAMILY"; then
        log_warn "QEMU Guest Agent is already installed"
        if systemctl is-active --quiet qemu-guest-agent; then
            log_info "QEMU Guest Agent is already running"
            exit 0
        else
            log_info "Starting existing QEMU Guest Agent service..."
            systemctl start qemu-guest-agent
            verify_installation
            exit 0
        fi
    fi

    # Install based on distribution family
    case "$DISTRO_FAMILY" in
        debian)
            install_debian_guest_agent
            ;;
        redhat)
            install_redhat_guest_agent
            ;;
        unknown)
            log_error "Unsupported distribution family. This script only supports Debian and Red Hat families."
            log_error "Supported distributions:"
            log_error "  Debian family: Ubuntu, Debian"
            log_error "  Red Hat family: RHEL, CentOS, Fedora, Rocky Linux, AlmaLinux"
            exit 1
            ;;
        *)
            log_error "Unknown distribution family: $DISTRO_FAMILY"
            exit 1
            ;;
    esac

    # Verify installation
    verify_installation

    log_info "QEMU Guest Agent installation completed successfully!"

    # Setup GitHub SSH keys if username was provided
    if [[ -n "$github_username" ]]; then
        if setup_github_ssh_keys "$github_username" "$target_user"; then
            log_info "SSH key setup completed successfully!"
        else
            log_warn "SSH key setup failed, but guest agent installation was successful"
        fi
    fi
}

# Run main function
main "$@"
