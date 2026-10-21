from __future__ import annotations

from pathlib import Path


MODEL_DIR = Path("models/stable-diffusion-v1-5")
MODEL_REPO_ID = "runwayml/stable-diffusion-v1-5"


def download() -> None:
    """Download the optional Stable Diffusion model only when missing."""

    try:
        from huggingface_hub import snapshot_download
    except ImportError:
        print("huggingface_hub not installed. Skipping model download.")
        return

    if MODEL_DIR.exists():
        print("Model already exists. Skipping download.")
        return

    print("Downloading model (this may take several GB)...")

    try:
        snapshot_download(
            repo_id=MODEL_REPO_ID,
            local_dir=MODEL_DIR,
            local_dir_use_symlinks=False,
        )
    except Exception as exc:
        print(f"Model download failed: {exc}")
        print("The app can still run in manual image mode without this model.")
        return

    print("Model download complete.")


if __name__ == "__main__":
    download()