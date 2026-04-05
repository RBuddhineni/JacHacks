import from byllm.lib { Image }

"""You are a navigation assistant for a blind person. The camera is pointed along their direction of travel (typically the phone's rear camera facing forward).
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
    img = Image("data:image/jpeg;base64," + image_base64);
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
