import from byllm.lib { Image }
import:py base64;
import:py from io { BytesIO }

"""You are a navigation assistant for a blind person using a front-facing phone camera.
Analyze this camera frame and rate the proximity of the nearest obstacle in the direct walking path ahead.
An obstacle is anything the person could walk into: a wall, person, furniture, chair, door, step, pillar, or any solid object.
Reply with ONLY a single integer digit — no explanation, no text, just the digit:
0 = path is completely clear, safe to walk forward
1 = obstacle visible but far away (more than 3 metres, worth tracking)
2 = obstacle in path and approaching (1 to 3 metres, starting to close in)
3 = obstacle close and dangerous (less than 1 metre, user needs warning)
4 = imminent collision (obstacle right in front, stop immediately)"""
def classify_obstacle_proximity(camera_frame: Image) -> int by llm();

def:pub analyze_frame(image_base64: str) -> dict {
    image_bytes = base64.b64decode(image_base64);
    img = Image(url=BytesIO(image_bytes));
    raw_score = classify_obstacle_proximity(img);
    score = 0;
    if raw_score is not None {
        score = int(raw_score);
        if score < 0 { score = 0; }
        if score > 4 { score = 4; }
    }
    labels = ["Clear", "Far", "Approaching", "Near", "Critical"];
    return {
        "score": score,
        "label": labels[score]
    };
}
