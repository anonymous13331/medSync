import easyocr
import cv2
import numpy as np

# initialize OCR reader
reader = easyocr.Reader(['en'])

def extract_medicine_name(image_bytes):
    # convert bytes to image
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    # preprocessing
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    blur = cv2.GaussianBlur(gray, (5, 5), 0)

    # OCR detection
    results = reader.readtext(blur)

    best_text = "Unknown"
    max_area = 0

    for (bbox, text, confidence) in results:
        # bounding box points
        (tl, tr, br, bl) = bbox

        # calculate width & height
        width = np.linalg.norm(np.array(tr) - np.array(tl))
        height = np.linalg.norm(np.array(bl) - np.array(tl))
        area = width * height

        # clean text
        cleaned_text = text.strip()

        # filter conditions
        if (
            area > max_area
            and confidence > 0.4
            and len(cleaned_text) > 3
            and not cleaned_text.isdigit()
        ):
            max_area = area
            best_text = cleaned_text

    return best_text