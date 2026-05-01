#!/bin/bash

# FAH Retail Backend - Setup and Start Script
# Usage: ./start_backend.sh [setup|start|reset]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/backend"
VENV_DIR="$BACKEND_DIR/venv"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Check if MySQL is running
check_mysql() {
    if command -v mysql &> /dev/null; then
        if mysql -u root -e "SELECT 1" &> /dev/null; then
            print_status "MySQL is running"
            return 0
        fi
    fi
    print_warning "MySQL check skipped (ensure MySQL is running)"
    return 0
}

# Setup virtual environment and dependencies
setup() {
    echo "========================================="
    echo "  FAH Retail Backend Setup"
    echo "========================================="
    echo ""

    cd "$BACKEND_DIR"

    # Create virtual environment if it doesn't exist
    if [ ! -d "$VENV_DIR" ]; then
        print_status "Creating virtual environment..."
        python3 -m venv venv
    else
        print_status "Virtual environment already exists"
    fi

    # Activate virtual environment
    print_status "Activating virtual environment..."
    source "$VENV_DIR/bin/activate"

    # Install dependencies
    print_status "Installing dependencies..."
    pip install -r requirements.txt --quiet

    # Create .env file if it doesn't exist
    if [ ! -f "$BACKEND_DIR/.env" ]; then
        if [ -f "$BACKEND_DIR/.env.example" ]; then
            cp "$BACKEND_DIR/.env.example" "$BACKEND_DIR/.env"
            print_warning ".env file created from .env.example"
            print_warning "Please edit .env with your MySQL credentials"
        else
            print_error ".env.example not found. Please create .env manually"
        fi
    else
        print_status ".env file already exists"
    fi

    echo ""
    print_status "Setup complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Ensure MySQL is running"
    echo "  2. Create database: mysql -u root -p -e 'CREATE DATABASE IF NOT EXISTS fah_retail;'"
    echo "  3. Import schema: mysql -u root -p fah_retail < backend/schema.sql"
    echo "  4. Edit backend/.env with your MySQL credentials"
    echo "  5. Run: ./start_backend.sh start"
}

# Start the server
start() {
    echo "========================================="
    echo "  Starting FAH Retail Backend Server"
    echo "========================================="
    echo ""

    cd "$BACKEND_DIR"

    # Check if virtual environment exists
    if [ ! -d "$VENV_DIR" ]; then
        print_error "Virtual environment not found. Run './start_backend.sh setup' first"
        exit 1
    fi

    # Activate virtual environment
    source "$VENV_DIR/bin/activate"

    # Check if .env exists
    if [ ! -f "$BACKEND_DIR/.env" ]; then
        print_error ".env file not found. Run './start_backend.sh setup' first"
        exit 1
    fi

    check_mysql

    echo ""
    print_status "Starting server on http://localhost:8000"
    print_status "API Docs: http://localhost:8000/docs"
    print_status "Press Ctrl+C to stop"
    echo ""

    uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
}

# Reset environment
reset() {
    echo "========================================="
    echo "  Resetting FAH Retail Backend"
    echo "========================================="
    echo ""

    cd "$BACKEND_DIR"

    if [ -d "$VENV_DIR" ]; then
        print_status "Removing virtual environment..."
        rm -rf "$VENV_DIR"
    fi

    print_status "Reset complete. Run './start_backend.sh setup' to reinstall"
}

# Main script
case "${1:-start}" in
    setup)
        setup
        ;;
    start)
        start
        ;;
    reset)
        reset
        ;;
    *)
        echo "Usage: $0 [setup|start|reset]"
        echo ""
        echo "Commands:"
        echo "  setup  - Create venv, install dependencies, configure .env"
        echo "  start  - Start the backend server (default)"
        echo "  reset  - Remove venv and start fresh"
        exit 1
        ;;
esac
