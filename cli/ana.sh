#!/usr/bin/env bash

USAGE_MESSAGE=$(cat <<-END

  Usage: coach [options] [<command> [command-options]]

  Options:
      -h, --help         Show help message
      -v, --version      Show version information

  Commands (required unless using -h or -v):
      devc               Starts the coach devcontainers 
      start              Starts the coach application
      stop               Stops the coach application
      status             Shows the status of the coach application

  For more information on a specific command, including available options, use:
      coach <command> -h
END
)

VERSION="Coach version 1.0.0"

# Function to display help message
show_help() {
  echo "$USAGE_MESSAGE"
}

# Function to show version information
show_version() {
  echo "$VERSION"
}

# Command-specific help functions
show_dev_help() {
  echo "Usage: coach devc"
  echo "Starts the coach devcontainers"
}

show_start_help() {
  echo "Usage: coach start"
  echo "Starts the coach application"
}

show_stop_help() {
  echo "Usage: coach stop"
  echo "Stops the coach application"
}

show_status_help() {
  echo "Usage: coach status"
  echo "Shows the status of the coach application"
}

# Command functions
devc() {
  echo "Starting coach devcontainers..."
  # Add actual command logic here
}

start() {
  echo "Starting coach application..."
  # Add actual command logic here
}

stop() {
  echo "Stopping coach application..."
  # Add actual command logic here
}

status() {
  echo "Coach application status:"
  # Add actual command logic here
}

# Parse options and arguments using getopt
PARSED=$(getopt --options hv --longoptions help,version --name "$0" -- "$@")
if [[ $? -ne 0 ]]; then
    # If getopt has an error
    show_help
    exit 1
fi
eval set -- "$PARSED"

# Handle global options
while true; do
  case "$1" in
    -h|--help)
      show_help
      exit 0
      ;;
    -v|--version)
      show_version
      exit 0
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Invalid option: $1" 1>&2
      show_help
      exit 1
      ;;
  esac
done

# If no command is provided, show usage message
if [ $# -eq 0 ]; then
  show_help
  exit 0
fi

# Parse command and command options
COMMAND=$1
shift

case "$COMMAND" in
  devc)
    # Parse devc command options
    PARSED=$(getopt --options h --longoptions help --name "$0" -- "$@")
    if [[ $? -ne 0 ]]; then
        show_dev_help
        exit 1
    fi
    eval set -- "$PARSED"
    while true; do
      case "$1" in
        -h|--help)
          show_dev_help
          exit 0
          ;;
        --)
          shift
          break
          ;;
        *)
          echo "Invalid option: $1" 1>&2
          show_dev_help
          exit 1
          ;;
      esac
    done
    devc
    ;;
  start)
    # Parse start command options
    PARSED=$(getopt --options h --longoptions help --name "$0" -- "$@")
    if [[ $? -ne 0 ]]; then
        show_start_help
        exit 1
    fi
    eval set -- "$PARSED"
    while true; do
      case "$1" in
        -h|--help)
          show_start_help
          exit 0
          ;;
        --)
          shift
          break
          ;;
        *)
          echo "Invalid option: $1" 1>&2
          show_start_help
          exit 1
          ;;
      esac
    done
    start
    ;;
  stop)
    # Parse stop command options
    PARSED=$(getopt --options h --longoptions help --name "$0" -- "$@")
    if [[ $? -ne 0 ]]; then
        show_stop_help
        exit 1
    fi
    eval set -- "$PARSED"
    while true; do
      case "$1" in
        -h|--help)
          show_stop_help
          exit 0
          ;;
        --)
          shift
          break
          ;;
        *)
          echo "Invalid option: $1" 1>&2
          show_stop_help
          exit 1
          ;;
      esac
    done
    stop
    ;;
  status)
    # Parse status command options
    PARSED=$(getopt --options h --longoptions help --name "$0" -- "$@")
    if [[ $? -ne 0 ]]; then
        show_status_help
        exit 1
    fi
    eval set -- "$PARSED"
    while true; do
      case "$1" in
        -h|--help)
          show_status_help
          exit 0
          ;;
        --)
          shift
          break
          ;;
        *)
          echo "Invalid option: $1" 1>&2
          show_status_help
          exit 1
          ;;
      esac
    done
    status
    ;;
  *)
    echo "Invalid command: $COMMAND" 1>&2
    show_help
    exit 1
    ;;
esac
