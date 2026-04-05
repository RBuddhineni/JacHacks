sv import from ..services.vision { analyze_frame }

def:pub OpenAEyeApp() -> JsxElement {
    has monitoring: bool = False;
    has camera_denied: bool = False;
    has prox_score: int = 0;
    has prox_label: str = "Clear";
    has prox_history: list = [];
    has scan_count: int = 0;
    has alert_count: int = 0;
    has alert_active: bool = False;
    has alert_time: int = 0;
    has status_text: str = "Starting…";
    has last_scan_ms: int = 0;

    def record_score(score: int) -> None {
        new_hist = prox_history + [score];
        if len(new_hist) > 5 { new_hist = new_hist[-5:]; }
        prox_history = new_hist;
    }

    def should_alert(score: int) -> bool {
        if score < 3 { return False; }
        if len(prox_history) < 2 { return False; }
        prev = prox_history[:-1];
        for s in prev {
            if s >= 2 { return True; }
        }
        return False;
    }

    async def acquire_camera_stream() -> any {
        try {
            return await navigator.mediaDevices.getUserMedia({
                "video": {
                    "facingMode": {"ideal": "environment"},
                    "width": {"ideal": 1920},
                    "height": {"ideal": 1080}
                },
                "audio": False
            });
        } except Exception {
            return await navigator.mediaDevices.getUserMedia({
                "video": {
                    "facingMode": "user",
                    "width": {"ideal": 1280},
                    "height": {"ideal": 720}
                },
                "audio": False
            });
        }
    }

    async def start_camera(from_tap: bool) -> None {
        camera_denied = False;
        status_text = "Requesting camera…";
        if from_tap {
            window.speechSynthesis.speak(SpeechSynthesisUtterance(""));
        }
        try {
            stream = await acquire_camera_stream();
            video = document.getElementById("oe-video");
            video.srcObject = stream;
            await video.play();
            prox_history = [];
            scan_count = 0;
            alert_count = 0;
            alert_active = False;
            prox_score = 0;
            prox_label = "Clear";
            status_text = "Live";
            monitoring = True;
        } except Exception {
            camera_denied = True;
            monitoring = False;
            status_text = "Camera blocked. Tap to try again.";
        }
    }

    async can with entry {
        await start_camera(False);
    }

    async def run_scan() -> None {
        now = Date.now();
        if now - last_scan_ms < 500 { return; }
        last_scan_ms = now;

        video = document.getElementById("oe-video");
        canvas = document.getElementById("oe-canvas");
        if not video or video.readyState < 2 { return; }

        w = 320;
        h = 240;
        canvas.width = w;
        canvas.height = h;
        ctx = canvas.getContext("2d");
        ctx.drawImage(video, 0, 0, w, h);
        b64 = canvas.toDataURL("image/jpeg", 0.65).split(",")[1];

        result = await analyze_frame(b64);
        score = result["score"];
        label = result["label"];

        record_score(score);
        scan_count = scan_count + 1;
        prox_score = score;
        prox_label = label;

        if alert_active and Date.now() - alert_time > 3000 {
            alert_active = False;
        }

        if should_alert(score) {
            alert_active = True;
            alert_time = Date.now();
            alert_count = alert_count + 1;
            if not window.speechSynthesis.speaking {
                msg = "Stop now, obstacle ahead";
                if score < 4 { msg = "Stop, obstacle ahead"; }
                utt = SpeechSynthesisUtterance(msg);
                utt.rate = 1.1;
                utt.volume = 1.0;
                window.speechSynthesis.speak(utt);
            }
        } else {
            if score < 3 { alert_active = False; }
        }
    }

    can with [monitoring] entry {
        if not monitoring { return; }
        interval_id = setInterval(run_scan, 500);
        def cleanup() -> None {
            clearInterval(interval_id);
        }
        return cleanup;
    }

    async def handle_retry() -> None {
        await start_camera(True);
    }

    def handle_stop() -> None {
        monitoring = False;
        video = document.getElementById("oe-video");
        if video and video.srcObject {
            video.srcObject.getTracks().forEach(lambda t: any -> None { t.stop(); });
            video.srcObject = None;
        }
        prox_history = [];
        alert_active = False;
        prox_score = 0;
        prox_label = "Clear";
        status_text = "Stopped";
    }

    live_cls = "max-w-[min(100%,10rem)] rounded-2xl border border-white/15 bg-black/55 px-3 py-2 text-right text-[11px] font-semibold leading-tight text-emerald-300 shadow-lg backdrop-blur-md";
    live_txt = "Starting…";
    if camera_denied {
        live_cls = "max-w-[min(100%,10rem)] rounded-2xl border border-amber-400/35 bg-amber-500/15 px-3 py-2 text-right text-[11px] font-semibold leading-tight text-amber-200 shadow-lg backdrop-blur-md";
        live_txt = "Camera off";
    } elif monitoring {
        live_cls = "max-w-[min(100%,10rem)] rounded-2xl border border-emerald-400/35 bg-emerald-950/60 px-3 py-2 text-right text-[11px] font-semibold leading-tight text-emerald-200 shadow-lg backdrop-blur-md";
        live_txt = "Active";
    } elif status_text == "Stopped" {
        live_txt = "Stopped";
        live_cls = "max-w-[min(100%,10rem)] rounded-2xl border border-slate-500/35 bg-black/55 px-3 py-2 text-right text-[11px] font-semibold leading-tight text-slate-300 shadow-lg backdrop-blur-md";
    }

    return (
        <main
            className="fixed inset-0 z-0 flex flex-col bg-black text-white"
            style={{
                "paddingTop": "env(safe-area-inset-top, 0px)",
                "paddingBottom": "env(safe-area-inset-bottom, 0px)",
                "paddingLeft": "env(safe-area-inset-left, 0px)",
                "paddingRight": "env(safe-area-inset-right, 0px)"
            }}
        >
            <div className="relative flex min-h-0 min-w-0 flex-1 flex-col">
                <div className="pointer-events-none absolute inset-x-0 top-0 z-20 flex justify-between gap-2 bg-gradient-to-b from-black/75 via-black/40 to-transparent px-3 pb-10 pt-2">
                    <div className="pointer-events-auto flex min-w-0 max-w-[75%] items-center gap-2.5">
                        <svg
                            className="h-9 w-9 shrink-0 sm:h-10 sm:w-10"
                            viewBox="0 0 2000 2000"
                            fill="none"
                            aria-hidden="true"
                        >
                            <g transform="translate(0 2000) scale(.1 -.1)" fill="#ffffff">
                                <path d="M9919 15098 c-75 -106 -264 -343 -553 -693 -108 -132 -281 -343 -384 -470 -103 -126 -205 -249 -228 -272 l-41 -43 -161 0 c-157 0 -482 -18 -727 -40 -296 -27 -437 -42 -535 -56 -58 -8 -135 -19 -172 -24 -38 -6 -98 -14 -135 -20 -38 -5 -90 -12 -118 -15 -27 -4 -70 -10 -95 -15 -25 -5 -88 -16 -140 -25 -52 -9 -120 -20 -150 -25 -30 -6 -100 -17 -155 -25 -55 -9 -131 -22 -170 -30 -38 -7 -97 -18 -130 -24 -186 -32 -260 -45 -350 -63 -55 -11 -127 -24 -160 -29 -73 -10 -191 -30 -345 -58 -177 -31 -231 -40 -285 -46 -27 -3 -77 -10 -110 -15 -33 -5 -113 -17 -178 -26 -84 -12 -120 -21 -124 -32 -3 -8 11 -55 32 -106 170 -408 238 -581 575 -1461 230 -600 428 -1073 609 -1458 28 -60 51 -114 51 -122 0 -7 -44 -100 -97 -207 -97 -192 -197 -399 -268 -553 -53 -115 -99 -214 -202 -440 -30 -66 -65 -142 -78 -170 -13 -27 -55 -120 -93 -205 -66 -147 -92 -203 -215 -465 -28 -60 -102 -212 -164 -338 -62 -125 -113 -236 -113 -246 0 -15 19 -22 113 -41 187 -38 580 -126 802 -180 1249 -304 1496 -360 1975 -449 375 -70 746 -121 1062 -146 106 -9 196 -19 199 -23 3 -4 68 -85 143 -181 76 -95 224 -277 329 -405 489 -592 583 -707 742 -911 59 -77 112 -144 116 -149 4 -4 29 20 56 55 109 144 426 535 674 834 145 175 330 400 410 499 l145 181 255 12 c498 23 1075 89 1689 194 476 81 649 111 830 144 480 88 1200 205 1260 205 18 0 11 25 -40 137 -69 156 -215 520 -370 923 -364 952 -453 1176 -600 1520 -63 145 -63 145 -45 175 202 350 503 959 868 1760 242 532 340 741 473 1013 68 139 124 256 124 261 0 13 -6 14 -215 56 -192 38 -327 69 -629 141 -104 25 -216 52 -250 59 -33 7 -92 22 -131 33 -38 10 -92 24 -120 30 -67 15 -401 96 -550 133 -66 17 -163 39 -215 50 -52 11 -140 30 -195 44 -96 23 -259 58 -355 76 -25 4 -79 15 -120 24 -41 9 -111 23 -155 30 -44 8 -147 25 -230 40 -319 55 -678 97 -1020 120 -110 7 -201 13 -202 14 -1 0 -75 92 -165 204 -195 243 -237 294 -534 653 -256 310 -443 543 -549 682 -38 50 -77 92 -85 92 -9 0 -45 -42 -81 -92z m9 -3395 c-3 -678 -4 -710 -22 -745 -11 -21 -25 -38 -32 -38 -6 0 -58 49 -115 108 l-104 109 -262 542 c-144 298 -264 549 -265 558 -4 17 50 40 201 83 179 52 385 86 529 89 l73 1 -3 -707z m476 677 c182 -31 411 -98 562 -165 49 -22 55 -27 48 -47 -9 -31 -53 -117 -74 -148 -18 -26 -82 -138 -275 -485 -244 -438 -232 -419 -337 -520 -99 -96 -183 -155 -197 -139 -5 5 -20 44 -35 87 l-26 77 0 687 0 686 108 -6 c59 -4 161 -16 226 -27z m-1176 -757 c302 -624 297 -608 309 -854 l6 -126 -33 -6 c-58 -12 -312 -7 -431 7 -151 19 -230 40 -304 80 -77 43 -859 487 -863 491 -6 5 79 136 153 235 80 108 274 313 385 405 107 89 235 177 375 256 66 38 123 69 126 69 3 0 128 -251 277 -557z m2053 424 c226 -142 445 -337 609 -542 116 -146 267 -392 257 -418 -5 -14 -81 -52 -577 -294 -162 -79 -302 -147 -311 -152 -9 -5 -47 -18 -85 -28 -59 -15 -108 -18 -329 -18 -181 0 -273 4 -303 13 l-43 13 7 62 c4 34 19 124 34 199 l28 136 273 484 c331 585 338 598 348 598 4 0 46 -24 92 -53z m-3418 -1003 c18 -9 223 -124 457 -256 386 -217 430 -245 484 -301 79 -83 188 -225 238 -310 67 -113 86 -110 -717 -113 -357 -1 -672 1 -699 4 l-49 5 7 91 c15 201 59 423 121 607 33 98 113 289 122 289 2 0 18 -7 36 -16z m4412 -230 c35 -93 69 -217 94 -340 24 -120 55 -393 46 -403 -4 -3 -322 -6 -708 -6 -620 0 -705 2 -730 16 l-29 15 63 85 c35 46 111 131 169 189 l105 105 200 95 c110 52 322 154 470 226 309 151 271 148 320 18z m-3181 -924 c55 -19 104 -43 110 -52 16 -27 -9 -63 -136 -193 -95 -97 -131 -127 -190 -157 -93 -47 -529 -259 -626 -304 -41 -19 -135 -65 -210 -103 -75 -37 -159 -76 -185 -86 -58 -22 -52 -29 -107 112 -53 136 -106 321 -130 457 -23 135 -44 342 -35 356 4 7 232 10 708 8 l702 -3 99 -35z m3321 -47 c-27 -308 -84 -541 -200 -820 -56 -133 -89 -185 -111 -176 -13 5 -667 373 -1021 575 -62 35 -175 152 -257 267 l-59 82 18 39 c19 43 16 41 135 81 l85 28 708 1 709 0 -7 -77z m-3135 -470 c-1 -73 -22 -218 -45 -308 -27 -104 -50 -151 -200 -415 -45 -80 -94 -165 -108 -190 -98 -175 -245 -430 -259 -449 l-16 -23 -49 33 c-146 100 -326 265 -452 415 -110 132 -274 376 -260 388 2 2 256 126 564 275 552 267 562 271 655 285 52 7 112 14 133 15 34 1 37 -1 37 -26z m1555 -46 l110 -22 530 -299 c292 -164 536 -304 543 -310 16 -15 -20 -72 -125 -203 -142 -177 -266 -297 -453 -439 -83 -63 -195 -134 -213 -134 -8 0 -48 71 -92 163 -43 89 -137 281 -208 427 -187 384 -202 418 -215 495 -16 96 -32 240 -32 298 0 57 -4 56 155 24z m-996 -135 c11 -21 35 -84 55 -141 l36 -103 0 -685 0 -686 -92 6 c-183 12 -380 47 -531 94 -199 62 -481 187 -493 218 -3 8 88 180 202 382 114 202 239 423 277 491 61 108 80 133 162 209 139 127 313 253 352 253 7 0 21 -17 32 -38z m440 -55 c29 -23 105 -93 169 -157 l116 -115 139 -285 c203 -416 357 -738 357 -747 0 -27 -285 -138 -475 -186 -139 -35 -350 -67 -447 -67 l-68 0 0 686 0 687 31 91 c17 50 40 108 51 129 l19 39 27 -18 c15 -9 51 -35 81 -57z" />
                            </g>
                        </svg>
                        <div className="min-w-0">
                            <h1 className="truncate text-lg font-bold tracking-tight sm:text-xl">OpenAEye</h1>
                            <p className="truncate text-[10px] font-medium uppercase tracking-[0.2em] text-white/55 sm:text-[11px]">
                                Path ahead
                            </p>
                        </div>
                    </div>
                    <div className="pointer-events-auto flex flex-col items-end gap-1.5">
                        <div className={live_cls}>
                            <span className="block">{live_txt}</span>
                        </div>
                        {alert_active and (
                            <div
                                className="max-w-[min(100%,11rem)] rounded-2xl border border-rose-400/50 bg-rose-600/90 px-3 py-2 text-right text-[11px] font-bold leading-snug text-white shadow-lg backdrop-blur-md"
                                role="status"
                                aria-live="assertive"
                            >
                                Obstacle — stop
                            </div>
                        )}
                    </div>
                </div>

                <div className="relative min-h-0 flex-1 bg-black">
                    <video
                        id="oe-video"
                        autoPlay
                        playsInline
                        muted
                        className="absolute inset-0 h-full w-full object-cover"
                    />
                    <canvas id="oe-canvas" style={{"display": "none"}} />

                    {(not monitoring or camera_denied) and (
                        <div className="absolute inset-0 flex flex-col items-center justify-center bg-black/80 px-6 text-center">
                            {camera_denied and (
                                <>
                                    <p className="max-w-sm text-base font-semibold leading-snug">Camera access is needed</p>
                                    <p className="mt-2 max-w-sm text-sm leading-relaxed text-white/65">
                                        OpenAEye uses your camera to watch the path ahead. Allow access in your browser settings, then tap below.
                                    </p>
                                    <button
                                        type="button"
                                        className="mt-6 min-h-[52px] min-w-[200px] rounded-2xl bg-sky-500 px-6 py-3 text-base font-bold text-white active:scale-[0.98]"
                                        onClick={handle_retry}
                                    >
                                        Allow camera
                                    </button>
                                </>
                            )}
                            {not camera_denied and not monitoring and status_text != "Stopped" and (
                                <p className="text-sm font-medium text-white/70">Starting camera…</p>
                            )}
                            {not camera_denied and status_text == "Stopped" and (
                                <>
                                    <p className="text-base font-semibold">Camera off</p>
                                    <button
                                        type="button"
                                        className="mt-6 min-h-[52px] min-w-[200px] rounded-2xl bg-sky-500 px-6 py-3 text-base font-bold text-white active:scale-[0.98]"
                                        onClick={handle_retry}
                                    >
                                        Resume
                                    </button>
                                </>
                            )}
                        </div>
                    )}
                </div>

                <div className="z-30 flex shrink-0 items-center justify-center gap-3 border-t border-white/10 bg-black/90 px-4 py-3 backdrop-blur-md">
                    {monitoring and (
                        <button
                            type="button"
                            className="min-h-12 min-w-[120px] flex-1 rounded-2xl border border-white/20 bg-white/10 px-4 py-3 text-sm font-semibold text-white active:scale-[0.98] sm:max-w-xs"
                            onClick={handle_stop}
                        >
                            Stop camera
                        </button>
                    )}
                </div>
            </div>

            <p className="sr-only">
                OpenAEye is a prototype assistive app, not a certified safety device.
            </p>
        </main>
    );
}
