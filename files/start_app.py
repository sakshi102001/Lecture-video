import subprocess
import time
import webbrowser
from pathlib import Path


def main() -> None:
    base = Path(__file__).resolve().parent
    backend_main = base / "backend" / "main.py"

    if not backend_main.exists():
        print("backend/main.py not found. Copy backend folder first.")
        return

    subprocess.Popen(["python", "-m", "uvicorn", "backend.main:app", "--host", "127.0.0.1", "--port", "8000", "--reload"], cwd=str(base))
    time.sleep(5)
    webbrowser.open("http://localhost:8000")


if __name__ == "__main__":
    main()
