AI-Video-App (Windows lightweight launcher)

Folder layout:
- backend/
- frontend/
- requirements.txt
- download_model.py
- setup.bat
- run.bat
- launch_app.bat
- start_app.py
- package_lightweight.bat

Lightweight deployment goal:
- Do NOT bundle models/ or models.zip in the distribution ZIP.
- The app runs in manual image mode by default.
- AI image model download is optional and only runs when DOWNLOAD_MODEL=true.

How to create a lightweight ZIP on THIS machine:
1) Double-click package_lightweight.bat
2) It creates AI-Video-App-lightweight.zip and excludes:
   - models/
   - models.zip
   - venv/
   - frontend/node_modules/
   - logs and generated runtime data

How to use on ANOTHER PC:
1) Copy AI-Video-App-lightweight.zip to the target machine.
2) Extract it.
3) Double-click launch_app.bat.
   - It auto-runs setup first time when venv/ is missing.
   - It starts backend on http://127.0.0.1:8000.
   - If npm is installed, it starts the frontend dev server on http://localhost:5173.
   - If npm is not installed and frontend/dist exists, use http://127.0.0.1:8000/app.

Optional AI model download on target machine:
1) Open Command Prompt in the extracted app folder.
2) Run:
   set DOWNLOAD_MODEL=true
   setup.bat
3) This downloads runwayml/stable-diffusion-v1-5 to:
   models/stable-diffusion-v1-5

Optional AI image runtime:
- Manual image mode is the default.
- To try local AI images after downloading the model, start the backend with:
  set USE_AI_IMAGE_GENERATION=true
  launch_app.bat
- If torch/diffusers/model loading fails, the backend falls back instead of crashing.

Notes:
- setup.bat installs core dependencies first, then attempts optional AI dependencies best-effort.
- download_model.py skips safely if huggingface_hub is not installed.
- Video generation works with uploaded images and generated/uploaded narration audio.
- Large model files are never required for manual image mode.

If you see "module not found" on target machine:
1) Re-run setup.bat and wait for completion.
2) Then run run.bat.
3) If still failing, open Command Prompt inside AI-Video-App and run:
   - venv\Scripts\activate
   - python -m pip install -r requirements.txt
4) Ensure backend\main.py exists inside AI-Video-App.

Matplotlib build error note (compiler missing):
- This is expected on clean Windows machines without C/C++ build tools.
- setup treats image-generation/model packages as optional at runtime.
- Core app still runs in manual image mode after core dependencies install.

Python 3.14 note:
- Some AI libraries (especially tokenizers/transformers) may fail on Python 3.14.
- AI libraries are optional at runtime and lazy-loaded only when USE_AI_IMAGE_GENERATION=true.
- App server can start with core requirements.
- For full AI image stack reliability, prefer Python 3.11/3.12 on target machine.

EXE note:
- Yes, we can package this launcher as an .exe later.
- Practical recommendation: first stabilize `launch_app.bat` on target machine.
- Then convert `start_app.py` to EXE via PyInstaller if you want single-file double-click UX.
