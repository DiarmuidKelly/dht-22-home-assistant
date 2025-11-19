# This is a utility script to read the log files created by the main application.
# Run this script from the MicroPython REPL to view the logs.
#
# Example usage in Thonny or mpremote:
# >>> %Run -c read_logs.py

import os

# --- Configuration ---
# These should match the filenames used in your main.py's logger configuration.
CURRENT_LOG_FILE = '../app.log'
BACKUP_LOG_FILE = '../app.old.log'

def print_log_file(filename):
    """Opens and prints the contents of a given log file."""
    print("=" * 50)
    print(f"--- Reading: {filename} ---")
    print("=" * 50)
    try:
        with open(filename, 'r') as f:
            # Read and print the file content line by line
            line_count = 0
            for line in f:
                print(line.strip())
                line_count += 1
            if line_count == 0:
                print(f"*** Log file is empty. ***")
    except OSError:
        print(f"*** Log file not found. It may not have been created yet. ***")
    print("\n")


if __name__ == "__main__":
    print("--- Pico Log Reader ---")
    # Print the current log first, as it's the most recent.
    print_log_file(CURRENT_LOG_FILE)
    # Then print the older, rotated log file.
    print_log_file(BACKUP_LOG_FILE)