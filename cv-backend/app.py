from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from ocr import extract_medicine_name

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://127.0.0.1:5173",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/scan")
async def scan(file: UploadFile = File(...)):
    image_bytes = await file.read()
    medicine = extract_medicine_name(image_bytes)
    return {"medicine": medicine}

@app.get("/")
async def root():
    return {"message": "Backend is alive!"}    