import os
import time

class Logger:
    """
    A simple logger class that writes messages to both the console and a file.
    It supports log rotation based on the number of lines.
    """
    def __init__(self, filename='app.log', max_lines=500, rotate=True):
        self.filename = filename
        self.max_lines = max_lines
        self.rotate = rotate
        if self.rotate:
            self.backup_filename = filename.replace('.log', '.old.log')
        self.line_count = self._count_initial_lines()

    def _count_initial_lines(self):
        """Counts the number of lines in the current log file."""
        try:
            with open(self.filename, 'r') as f:
                return sum(1 for _ in f)
        except OSError:
            # File doesn't exist yet
            return 0

    def _rotate_logs(self):
        """Rotates the log file if it exceeds the max line count."""
        if not self.rotate or self.line_count < self.max_lines:
            return

        print(f"Log limit ({self.max_lines}) reached. Rotating log file.")
        try:
            # Remove the old backup if it exists
            os.remove(self.backup_filename)
        except OSError:
            pass # No old backup file, which is fine
        try:
            # Rename current log to backup
            os.rename(self.filename, self.backup_filename)
        except OSError:
            pass # Current log file might not exist
        self.line_count = 0
        # Add a note to the new log, avoiding recursive rotation check
        self.log("--- Log file rotated ---", _internal_call=True)

    def log(self, message, _internal_call=False):
        """Prints a message to the console and writes it to the log file."""
        print(message)

        if not _internal_call:
            self._rotate_logs()

        try:
            timestamp = "{:04d}-{:02d}-{:02d} {:02d}:{:02d}:{:02d}".format(*time.localtime()[:6])
            with open(self.filename, 'a') as f:
                f.write(f"[{timestamp}] {message}\n")
            self.line_count += 1
        except Exception as e:
            print(f"!!! FAILED TO WRITE TO LOG FILE: {e} !!!")


# Global logger instance. Call init_logger() from your main script to create it.
logger = None

def init_logger(filename='app.log', max_lines=500, rotate=True):
    """
    Initializes the shared logger instance.
    This should be called once from the main script.
    """
    global logger
    logger = Logger(filename, max_lines, rotate)
    return logger