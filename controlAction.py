import os
import time
import serial
import csv 
import socket

HOST = '172.26.21.168'  # Replace with Mac's public or LAN IP
PORT = 5008
k_p = -2.5

# Open serial port
ser = serial.Serial(
    port='/dev/ttyUSB1',       # Adjust as needed
    baudrate=115200,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS,
)


def my_action():
    bluePixels = load_and_normalize_grid(file_to_watch)


    print_8x8_grid(bluePixels)

    ser.write(bytes(bluePixels))

        
    maxGreenColumn = ser.read()  # Reads a single byte from FPGA
    maxGreenRow = ser.read()  # Reads a single byte from FPGA

    print("FPGA Response ROW: " + str(maxGreenRow));
    print("FPGA Response COLUMN: " + str(maxGreenColumn));

    value = int.from_bytes(maxGreenColumn, byteorder='big')

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((HOST, PORT))
        action = str((value - 4) * k_p) + "\n"
        s.sendall(action.encode('utf-8'))
        print("Data sent.")



def load_and_normalize_grid(csv_path):
    # Load the CSV into a 2D list
    grid = []
    with open(csv_path, "r", newline="") as f:
        reader = csv.reader(f)
        for row in reader:
            grid.append([float(val) for val in row])
    
    # Flatten the 2D grid into 1D
    flat_grid = [val for row in grid for val in row]

    # Normalize to 0–255
    min_val = min(flat_grid)
    max_val = max(flat_grid)
    if max_val == min_val:
        # Avoid division by zero if all values are the same
        normalized = [0 for _ in flat_grid]
    else:
        normalized = [
            int(255 * (val - min_val) / (max_val - min_val))
            for val in flat_grid
        ]

    return normalized

def monitor_file(file_path):
    last_modified_time = None

    while True:
        # Get the current modification time of the file
        try:
            current_modified_time = os.path.getmtime(file_path)
        except FileNotFoundError:
            print(f"File {file_path} not found.")
            break
        
        # If the file's modification time has changed, call the action function
        if last_modified_time is None:
            last_modified_time = current_modified_time
        elif current_modified_time != last_modified_time:
            print(f"File {file_path} was modified.")
            my_action()  # Call your function when the file changes
            last_modified_time = current_modified_time

        # Sleep for a short period before checking again
        time.sleep(.05)



def print_8x8_grid(arr):
    if len(arr) != 64:
        raise ValueError("Array must have exactly 64 elements.")
    
    for i in range(8):
        row = arr[i*8:(i+1)*8]
        print(" ".join(f"{val:3}" for val in row))  # :3 for alignment



if __name__ == "__main__":
    file_to_watch = "photo.csv"  # Path to the file you want to monitor
    monitor_file(file_to_watch)
