import from byllm.lib { Image }

"""You are a navigation assistant for a blind person. The camera is pointed along their direction of travel (typically the phone's rear camera facing forward).
Analyze this camera frame and rate the proximity of the nearest obstacle in the direct walking path ahead.
An obstacle is anything the person could walk into: a wall, person, furniture, chair, door, step, pillar, or any solid object.
Reply with ONLY one character: 0, 1, 2, 3, or 4. No words, no punctuation, no explanation.
0 = path is completely clear, safe to walk forward
1 = obstacle visible but far away (more than 3 metres, worth tracking)
2 = obstacle in path and approaching (1 to 3 metres, starting to close in)
3 = obstacle close and dangerous (less than 1 metre, user needs warning)
4 = imminent collision (obstacle right in front, stop immediately)"""
def classify_obstacle_proximity_text(camera_frame: Image) -> str by llm();

def score_from_llm_raw(raw: any) -> int {
    if raw is None { return 0; }
    s = str(raw).strip();
    i = 0;
    while i < len(s) {
        ch = s[i];
        if ch == "0" { return 0; }
        if ch == "1" { return 1; }
        if ch == "2" { return 2; }
        if ch == "3" { return 3; }
        if ch == "4" { return 4; }
        i = i + 1;
    }
    return 0;
}

def:pub analyze_frame(image_base64: str) -> dict {
    img = Image("data:image/jpeg;base64," + image_base64);
    raw = classify_obstacle_proximity_text(img);
    score = score_from_llm_raw(raw);
    labels = ["Clear", "Far", "Approaching", "Near", "Critical"];
    return {
        "score": score,
        "label": labels[score]
    };
}
