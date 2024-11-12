import subprocess
import sys

def install_requirements():
    try:
        # Run the pip install command
        subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])
        print("Packages installed successfully.")
    except subprocess.CalledProcessError as e:
        print(f"Error occurred while installing packages: {e}")

if __name__ == "__main__":
    install_requirements()
