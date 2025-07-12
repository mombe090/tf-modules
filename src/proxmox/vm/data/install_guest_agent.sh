#!/bin/bash

# Script to install QEMU Guest Agent
# Supports Debian family (Ubuntu, Debian) and Red Hat family (RHEL, CentOS, Fedora, Rocky, AlmaLinux)

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

# Function to install guest agent on Debian family
install_debian_guest_agent() {
    log_info "Installing QEMU Guest Agent on Debian family system..."

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
}

# Run main function
main "$@"
